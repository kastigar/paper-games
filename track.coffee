getTangentPoints = (c1, c2, r) ->
  if c1.y == c2.y
    a = r
    b = 0
  else
    d = (c2.x - c1.x)/(c1.y - c2.y)
    b = r/Math.sqrt(1 + d*d)
    a = d*b

  line1 = {
    p1: x: c1.x - b, y: c1.y - a
    p2: x: c2.x - b, y: c2.y - a
  }

  line2 =
    p1: x: c1.x + b, y: c1.y + a
    p2: x: c2.x + b, y: c2.y + a

  return [line2, line1] if c1.y < c2.y || (c1.y == c2.y && c1.x > c2.x)
  return [line1, line2]

getLineCoef = (p1, p2) ->
  return {a: Number.NaN, b: p1.x} if (p2.x == p1.x) 

  a = (p2.y - p1.y)/(p2.x - p1.x)

  a: a, b: p1.y - a*p1.x

getCrossPoint = (l1, l2) ->
  return null if (isNaN(l1.a) && isNaN(l2.a)) || l1.a == l2.a
  return {x: l1.b, y: l2.a*l1.b + l2.b} if isNaN(l1.a) 
  return getCrossPoint(l2, l1) if isNaN(l2.a)

  x = (l2.b - l1.b)/(l1.a - l2.a)

  x: x, y: l1.a*x + l1.b

movedLine = (line, offset, axis) ->
  if axis is "x"
    return line if line.a == 0
    return a: line.a, b: line.b + offset if isNaN(line.a)
  else if axis is "y"
    return line if isNaN(line.a)
    return a: line.a, b: line.b + offset if line.a == 0
  else
    return line

  offsetB = Math.sqrt offset*offset*(1 + line.a*line.a)
  if (line.a > 0 && axis is "x")
    return a: line.a, b: line.b - offsetB if offset > 0
    return a: line.a, b: line.b + offsetB if offset < 0
  else
    return a: line.a, b: line.b + offsetB if offset > 0
    return a: line.a, b: line.b - offsetB if offset < 0

getDistance = (p1, p2) ->
  Math.sqrt (p2.x-p1.x)*(p2.x-p1.x) + (p2.y-p1.y)*(p2.y-p1.y)

class window.PaperTrack extends Kinetic.Layer
  constructor: (@isFirst) ->
    _super.call this, {}
    @borderColor = "#3b1aff"
    @trackColor  = "#cdcdcd"
    @trackAlpha  = 0.45
    @initTrack()

  checkin: (from, to) ->
    traceLine = getLineCoef from, to

    while @checkLines.length > 0 &&
          (crosspoint = getCrossPoint _.last(@checkLines), traceLine) &&
          (from.x <= crosspoint.x <= to.x || from.x >= crosspoint.x >= to.x) &&
          (from.y <= crosspoint.y <= to.y || from.y >= crosspoint.y >= to.y)
      @checkLines.pop()
      @draw()

    @checkLines.length

  initTrack: ->
    radius = 50
    width = 120
    c1 = x: 300, y: 60
    c2 = x: 400, y: 60
    c3 = x: 530, y: 320
    c4 = x: 60,  y: 320

    [tan1, tan1i] = getTangentPoints c1, c2, radius
    [tan2, tan2i] = getTangentPoints c2, c3, radius
    [tan3, tan3i] = getTangentPoints c3, c4, radius
    [tan4, tan4i] = getTangentPoints c4, c1, radius

    line1 = getLineCoef tan1.p1, tan1.p2
    line2 = getLineCoef tan2.p1, tan2.p2
    line3 = getLineCoef tan3.p1, tan3.p2
    line4 = getLineCoef tan4.p1, tan4.p2

    line1i = movedLine line1, +width, "y" 
    line2i = movedLine line2, -width, "x"
    line3i = movedLine line3, -width, "y"
    line4i = movedLine line4, +width, "x"

    cross1 = getCrossPoint line4, line1
    cross2 = getCrossPoint line1, line2
    cross3 = getCrossPoint line2, line3
    cross4 = getCrossPoint line3, line4

    cross1i = getCrossPoint line4i, line1i
    cross2i = getCrossPoint line1i, line2i
    cross3i = getCrossPoint line2i, line3i
    cross4i = getCrossPoint line3i, line4i

    @checkLines = [
      a: 0, b: 210
      getLineCoef cross4, cross4i
      getLineCoef cross3, cross3i
      getLineCoef cross2, cross2i
      getLineCoef cross1, cross1i
    ]

    self = this;

    @debugShape = new Kinetic.Shape
      stroke: "DarkRed"
      fill: "red"
      alpha: 0.45
      drawFunc: ->
        context = @getContext()

        context.beginPath()
        context.moveTo cross1.x, cross1.y
        context.lineTo cross1i.x, cross1i.y
        context.closePath()
        context.strokeStyle = "DarkRed"
        context.stroke() if self.checkLines.length > 4

        context.beginPath()
        context.moveTo cross2.x, cross2.y
        context.lineTo cross2i.x, cross2i.y
        context.closePath()
        context.strokeStyle = "DarkRed"
        context.stroke() if self.checkLines.length > 3

        context.beginPath()
        context.moveTo cross3.x, cross3.y
        context.lineTo cross3i.x, cross3i.y
        context.closePath()
        context.strokeStyle = "DarkRed"
        context.stroke() if self.checkLines.length > 2

        context.beginPath()
        context.moveTo cross4.x, cross4.y
        context.lineTo cross4i.x, cross4i.y
        context.closePath()
        @fillStroke() if self.checkLines.length > 1

        context.beginPath()
        context.moveTo 40, 210
        context.lineTo 260, 210
        context.closePath()
        @fillStroke() if self.checkLines.length > 0

    @outerShape = new Kinetic.Shape
      stroke: "#3b1aff"
      fill: "transparent"#"#cdcdcd"
      alpha: 0.45
      drawFunc: ->
        context = @getContext()

        context.beginPath()

        context.moveTo tan4.p2.x, tan4.p2.y
        context.arcTo  cross1.x, cross1.y, tan1.p1.x, tan1.p1.y, radius
        context.lineTo tan1.p2.x, tan1.p2.y

        context.arcTo  cross2.x, cross2.y, tan2.p1.x, tan2.p1.y, radius
        context.lineTo tan2.p2.x, tan2.p2.y

        context.arcTo  cross3.x, cross3.y, tan3.p1.x, tan3.p1.y, radius
        context.lineTo tan3.p2.x, tan3.p2.y

        context.arcTo  cross4.x, cross4.y, tan4.p1.x, tan4.p1.y, radius
        context.lineTo tan4.p2.x, tan4.p2.y

        context.closePath()
        @fillStroke()

    @innerShape = new Kinetic.Shape
      stroke: "#3b1aff"
      drawFunc: ->
        context = @getContext()
        
        context.beginPath()

        context.moveTo cross1i.x, cross1i.y
        context.lineTo cross2i.x, cross2i.y
        context.lineTo cross3i.x, cross3i.y
        context.lineTo cross4i.x, cross4i.y
  
        context.closePath()
        @fillStroke()

    @add(@debugShape);
    @add(@outerShape);
    @add(@innerShape);

  getCarPos: ()->
    if @isFirst then x: 150, y: 210 else x: 165, y: 210

  getOppPos: ()->
    if !@isFirst then x: 150, y: 210 else x: 165, y: 210

  isOut: (point) ->
    point = point.subtract new Point @getCenterOffset()
    !@outerShape.isPointInShape(point) || @innerShape.isPointInShape(point)

  draw: ->
    context = @getContext()
    @clear()

    # draw debug shapes
    @debugShape._draw this

    # draw outer border
    @outerShape.setFill @trackColor
    @outerShape.setStroke null
    @outerShape.setAlpha @trackAlpha
    @outerShape._draw this

    # cut off internal area
    context.globalCompositeOperation = "destination-out"
    @innerShape.setFill "black"
    @innerShape._draw this
    context.globalCompositeOperation = "source-over"

    # draw outer border
    @outerShape.setFill "transparent"
    @outerShape.setStroke @borderColor
    @outerShape.setAlpha 1
    @outerShape._draw this

    # draw inner border
    @innerShape.setFill "transparent"
    @outerShape.setStroke @borderColor
    @innerShape._draw this
