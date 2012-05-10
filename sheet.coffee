class window.Point
  constructor: (x, y)->
    if _.isObject(x) and _.has(x, "x") and _.has(x, "y")
      @x = x.x
      @y = x.y
    else if _.isArray(x) and x.length == 2
      @x = x[0]
      @y = x[1]
    else if _.isNumber(x) and _.isNumber(y)
      @x = x
      @y = y
    else
      throw message: "Bad arguments for Point"

  subtract: (point)->
    new Point @x - point.x, @y - point.y

  add: (point)->
    new Point @x + point.x, @y + point.y

  mul: (num)->
    new Point @x*num, @y*num

  eq: (that)->
    that instanceof Point and @x == that.x and @y == that.y

  distance: ->
    Math.sqrt @x*@x + @y*@y

class window.Size
  constructor: (w, h)->
    if _.isObject(w) and _.has(w, "width") and _.has(w, "height")
      @width = w.width
      @height = w.height
    else if _.isArray(w) and w.length == 2
      @width = w[0]
      @height = w[1]
    else if _.isNumber(w) and _.isNumber(h)
      @width = w
      @height = h
    else
      throw message: "Bad arguments for Size"

class window.PaperSheet extends Kinetic.Stage
  constructor: (config) ->
    config.width = 645
    config.height = 450
    _super.call this, config
    
    @cellSize = 15
    @fieldWidth = 4 * @cellSize
    @cellOffset = new Point Math.round(@cellSize / 3), Math.round(@cellSize * 2 / 3)
    @contentOffset = new Point @cellSize - @cellOffset.x, 5 * @cellSize - @cellOffset.y
    @contentSize = new Size @cellSize * Math.floor((@attrs.width  - @contentOffset.x)/@cellSize),
                            @cellSize * Math.floor((@attrs.height - @contentOffset.y)/@cellSize)

    @bgLayer = new Kinetic.Layer

    @initBackground()

  initBackground: ()->
    image = new Image
    image.onload = =>
      @bgLayer.add new Kinetic.Rect
        fill: @bgLayer.getContext().createPattern(image, 'repeat')
        x: -@cellOffset.x
        y: -@cellOffset.y
        width: @attrs.width + @cellOffset.x
        height: @attrs.height + @cellOffset.y

      @bgLayer.add new Kinetic.Line
        stroke: "red"
        alpha: 0.35
        x: 0
        toX: @attrs.width
        y: @fieldWidth
        toY: @fieldWidth

      @add @bgLayer
      @bgLayer.moveToBottom()

    image.src = "./bg.png"

  clean: ()->
    @remove layer for layer in _.clone(@children) when layer isnt @bgLayer

  addContentLayer: (layer)->
    layer.setCenterOffset(-@contentOffset.x, -@contentOffset.y)
    @add layer
