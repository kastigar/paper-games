class window.Car
  constructor: (@colors)->
    @shape = new Kinetic.Circle
      radius: 4
      fill: @colors.main

class window.Race
  constructor: (@sheet, @server, @isFirst) ->
    @track = new PaperTrack(@isFirst)
    @traceLayer = new Kinetic.Layer
    @carLayer = new Kinetic.Layer
    @choosingLayer = new Kinetic.Layer
    @finalLayer = new Kinetic.Layer

    @winMessage = new Kinetic.Text
      text: "WIN"
      textFill: "green"
      alpha: 0.5
      fontSize: 144
      fontFamily: "Calibri"
      x: @sheet.getWidth()/2
      y: @sheet.getHeight()/2
      rotationDeg: -15
      stroke: "green"
      strokeWidth: 8
      padding: 20
      align: "center"
      verticalAlign: "middle"

    @loseMessage = new Kinetic.Text
      text: "LOSE"
      textFill: "red"
      alpha: 0.5
      fontSize: 144
      fontFamily: "Calibri"
      x: @sheet.getWidth()/2
      y: @sheet.getHeight()/2
      rotationDeg: -15
      stroke: "red"
      strokeWidth: 8
      padding: 20
      align: "center"
      verticalAlign: "middle"

    @drawMessage = new Kinetic.Text
      text: "DRAW"
      textFill: "blue"
      alpha: 0.5
      fontSize: 128
      fontFamily: "Calibri"
      x: @sheet.getWidth()/2
      y: @sheet.getHeight()/2
      rotationDeg: -15
      stroke: "blue"
      strokeWidth: 8
      padding: 20
      align: "center"
      verticalAlign: "middle"

    @myCar = new Car
      main: "red"
      choosing: "#A04020"

    @oppCar = new Car
      main: "green"
      choosing: "#40A020"

    @carLayer.add @myCar.shape
    @carLayer.add @oppCar.shape

  run: (callback)->
    state =
      pos: new Point @track.getCarPos()
      velocity: new Point(0, 0)

    oppPos = new Point @track.getOppPos()

    @myCar.shape.setPosition state.pos.x, state.pos.y
    @oppCar.shape.setPosition oppPos.x, oppPos.y

    @sheet.clean()
    @sheet.addContentLayer @track
    @sheet.addContentLayer @traceLayer
    @sheet.addContentLayer @carLayer
    @sheet.addContentLayer @choosingLayer

    @server.send "READY"
      'OPPTURN (\\d+) (\\d+)': (e, x, y) =>
        oppNewPos = new Point parseInt(x), parseInt(y)
        @drawTurn @oppCar, oppPos, oppNewPos
        oppPos = oppNewPos

      'FINAL ([WLD])': (e, state) =>
        @server.unbecome()
        switch state
          when "W" then @finalLayer.add @winMessage
          when "L" then @finalLayer.add @loseMessage
          when "D" then @finalLayer.add @drawMessage

        @sheet.add @finalLayer
        _.delay callback, 3000

      "TURN": () =>
        inertialPoint = state.pos.add(state.velocity)

        line = new Kinetic.Line
          x: state.pos.x
          y: state.pos.y
          toX: inertialPoint.x
          toY: inertialPoint.y
          strokeWidth: 1
          stroke: @myCar.colors.choosing

        @choosingLayer.add line

        points =
          for offsetX in [-1..1]
            for offsetY in [-1..1]
              point = new Point(offsetX, offsetY).mul(@sheet.cellSize).add(inertialPoint)
              continue if point.eq(state.pos) or point.eq(oppPos) or @track.isOut(point)

              circle = new Kinetic.Circle
                x: point.x
                y: point.y
                radius: 3
                stroke: @myCar.colors.choosing
                fill: "transparent"
                strokeWidth: 2

              circle.on "click", (e) => 
                newPos = new Point(e.shape.attrs)
                newState =
                  pos: newPos
                  velocity: newPos.subtract(state.pos)

                vel = Math.round newState.velocity.distance()/@sheet.cellSize * 10
                console.log "Velocity", vel

                @drawTurn @myCar, state.pos, newPos

                @choosingLayer.removeChildren()
                @choosingLayer.clear()

                checkinsLeft = @track.checkin state.pos, newPos

                if checkinsLeft > 0
                  @server.send "TURN #{newPos.x} #{newPos.y}"
                else
                  @server.send "LASTTURN #{newPos.x} #{newPos.y}"

                state = newState

              circle.on "mouseover", (e) =>
                document.body.style.cursor = "pointer";

                line.to e.shape.attrs.x, e.shape.attrs.y
                @choosingLayer.draw()

              circle.on "mouseout", (e) =>
                document.body.style.cursor = "default"

                line.to inertialPoint.x, inertialPoint.y
                @choosingLayer.draw()

              @choosingLayer.add circle
              point

        console.log points if points.length == 0

        @choosingLayer.draw()

  drawTurn: (car, oldPos, newPos) ->
    @traceLayer.add new Kinetic.Circle
      x: oldPos.x
      y: oldPos.y
      radius: 3
      fill: car.colors.main

    @traceLayer.add new Kinetic.Line
      x: oldPos.x
      y: oldPos.y
      toX: newPos.x
      toY: newPos.y
      stroke: car.colors.main

    @traceLayer.draw()

    car.shape.setPosition newPos.x, newPos.y
    @carLayer.draw()