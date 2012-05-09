class window.RaceMenu
  constructor: (@sheet, server) ->
    @layer = new Kinetic.Layer

    button = new Size @sheet.cellSize*10, @sheet.cellSize*3
    offsetX = (@sheet.contentSize.width - button.width)/2
    offsetX = @sheet.cellSize * Math.floor(offsetX/@sheet.cellSize)

    singleRaceRect = new Kinetic.Rect
      stroke: "#3b1aff"
      strokeWidth: 3
      width: button.width
      height: button.height
      x: offsetX
      y: @sheet.cellSize*2

    rallyRect = new Kinetic.Rect
      stroke: "#3b1aff"
      strokeWidth: 3
      width: button.width
      height: button.height
      x: offsetX
      y: @sheet.cellSize*2 + button.height + @sheet.cellSize*2

    letter1 = new Kinetic.Text
      textFill: "blue"
      text: "A"
      fontSize: 12
      fontStyle: "bold"
      fontFamily: "Calibri"
      align: "center"
      verticalAlign: "middle"
      x: 8
      y: 8

    letter2 = new Kinetic.Text
      textFill: "blue"
      text: "B"
      fontSize: 12
      fontStyle: "bold"
      fontFamily: "Calibri"
      align: "center"
      verticalAlign: "middle"
      x: 23
      y: 8

    letter3 = new Kinetic.Text
      textFill: "blue"
      text: "C"
      fontSize: 12
      fontStyle: "bold"
      fontFamily: "Calibri"
      align: "center"
      verticalAlign: "middle"
      x: 38
      y: 8

    singleRaceRect.on "click", (e) =>
      race = new SingleRace @sheet, server
      race.run => @show()

    rallyRect.on "click", (e) =>
      console.log "Start ralllllllly"

    @layer.add singleRaceRect
    @layer.add rallyRect
    @layer.add letter1
    @layer.add letter2
    @layer.add letter3

  show: ->
    @sheet.clean()
    @sheet.addContentLayer @layer
