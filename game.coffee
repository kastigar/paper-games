window.PaperGames = {}

class window.PaperGames.Paper extends Kinetic.Layer
  constructor: (config) ->
    _super.call this, config
    @cellSize = config.cellSize

    @rect = new Kinetic.Rect
      fill: "transparent"
    @add @rect

    image = new Image
    image.onload = =>
      @rect.setFill @getContext().createPattern(image, 'repeat')
      @draw() if typeof @getStage() isnt "undefined"

    image.src = config.image

  draw: ->
    @rect.setWidth @getStage().getWidth()
    @rect.setHeight @getStage().getHeight()
    super()
