class window.SingleRace
  constructor: (@sheet, @server)->
    @layer = new Kinetic.Layer

    @layer.add new Kinetic.Text
      text: @server.player.name
      textFill: "blue"
      fontSize: 30
      fontFamily: "Calibri"
      y: 30
      x: 60

    @waitingText = new Kinetic.Text
      text: "waiting..."
      textFill: "blue"
      fontSize: 18
      fontFamily: "Calibri"
      y: 30
      x: 360

    @layer.add @waitingText

    @oppName = new Kinetic.Text
      text: "..."
      textFill: "red"
      fontSize: 30
      fontFamily: "Calibri"
      y: 30
      x: 360

  run: (callback) ->
    @sheet.clean()
    @sheet.addContentLayer @layer

    @server.send "FINDSINGLERACE"
      'FOUND (\\d) (.+)': (e, isFirst, opponent) =>
        console.log arguments
        @oppName.setText(opponent)
        @layer.remove @waitingText
        @layer.add @oppName
        @layer.draw() 

        @server.unbecome()
        race = new Race @sheet, @server, isFirst == "1"
        _.delay (=> race.run callback), 2000