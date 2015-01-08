#####################
# hacky
#####################

d3 = d3v2

#####################
# meter class, let the flow go down!
#####################

class Meter
  constructor: (@width, @height) ->

  insert: (@parentID) ->
    @svg = d3.select(@parentID).append('svg')
    .attr("height", @height)
    .attr('width', "100%")

    g = @svg.append("g")
    .attr("transform", "translate({0},{1}) scale(1,-1)".format(0, @height))

    innerContainer = g.append("rect")
    .attr("id", "meter-container")
    .attr("height", "100%")
    .attr('width', "100%")

    @meter = g.append("rect")
    .attr("id", "meter")
    .attr("height", "100%")
    .attr('width', "100%")

    outerContainer = g.append("rect")
    .attr("id", "meter-container-outside")
    .attr("height", "100%")
    .attr('width', "100%")

  set: (a) ->
    @meter.attr('height', @height*a) if a


  move: (a,b,t,cb) ->
    @set a
    @meter.transition().ease('linear')
    .duration(t*simTime)
    .attr("height", hMeter*b)
    .each "end", cb

  reset: () -> @set 1

#####################
# plot state, the ball that moves essentially
#####################

class Point
  constructor: (@x, @y) ->

  midPoint: (that) ->
    new Point(.5*(this.x + that.x), .5*(this.y + that.y))

class PlotState
  constructor: (@color, @radius, @point0) ->

  insert: (@parent) ->
    @state = d3
    .select(@parent)
    .append('circle')
    .attr('class','plot-state')

    @setRadius @radius
    @reset()
    @setColor @color


  setRadius: (r) ->
    @state.attr('r', r)

  show: () ->
    $(@state[0][0]).show()

  hide: () ->
    $(@state[0][0]).hide()

  disappear: (t, cb) ->
    @state.transition().duration(t).attr("r", 0).each "end", () =>
      @hide()
      @setRadius @radius
      cb()





  setColor: (c) ->
    @state.attr('fill', c)


  setLocation: (p) ->
    @location = p
    @state.attr('cx', p.x).attr('cy', p.y)

  setRadius: (r) -> @state.attr('r', r)

  moveLocation: (p1, p2, t, cb) ->
    (@setState p1) if p1
    @state.transition().ease('linear')
    .duration(t*simTime)
    .attr('cx', p2.x)
    .attr('cy', p2.y)
    .each "end", cb

  move: (p, c, t, cb) ->
    @state.transition().ease('linear')
    .duration(t*simTime)
    .attr('cx', p.x)
    .attr('cy', p.y)
    .attr('fill', c)
    .each "end", cb

  reset: () ->
    @setLocation @point0
    @setColor @color

  bounce: (t, color, cb) ->
    @state.transition().duration(t).attr("r", @radius*1.5).attr("fill", color).each "end", () =>
      @state.transition().duration(t).attr("r", @radius).attr("fill", @color).each "end", cb

class PlotLine
  lineD = d3.svg.line()
  .x((p) -> p.x)
  .y((p) -> p.y)

  constructor: (@a, @xmax, @color) ->
    @points = [
      new Point(0, @a)
      new Point(@xmax, @a)
      new Point(0, @xmax + @a)
    ]
    @state = new PlotState @color, stateRadius, @points[0]

  insert: (@parent) ->
    @parent = @parent[0][0]
    @line = d3
    .select(@parent)
    .append('path')
    .attr('d', lineD(@points))
    .attr('class', 'plot-line')
    .style('stroke', @color)
    .style('fill', 'none')

    @state.insert @parent

class Axis
  constructor: (@w, @h) ->

  insert: (@parent) ->
    @origin = @parent.append("g")
    .attr("transform", "scale(1, -1) ")

    xAxis = @origin
    .append("line")
    .attr("class", "axis-line")
    .attr("x1", 0)
    .attr("y1", 0)
    .attr("x2", @w)
    .attr("y2", 0)

    yAxis = @origin
    .append("line")
    .attr("class", "axis-line")
    .attr("x1", 0)
    .attr("y1", 0)
    .attr("x2", 0)
    .attr("y2", @h)

    xArrow = @origin
    .append('g')
    .attr('transform', 'translate({0},{1}) rotate({2})'.format @w, 0, 90)
    .append('path')
    .attr('d', d3v2.svg.symbol().type('triangle-up').size(300))
    .attr('class', 'arrow-head')

    yArrow = @origin
    .append('g')
    .attr('transform', 'translate({0},{1}) rotate({2})'.format 0, @h, 180)
    .append('path')
    .attr('d', d3v2.svg.symbol().type('triangle-up').size(300))
    .attr('class', 'arrow-head')

    xLabel = @origin
    .append('g')
    .attr('transform', 'translate({0},{1}) rotate(180) scale(-1,1)'.format @w*.5, 10)
    .append('text').text('Flow').style('font-size', 20).style('dominant-baseline', 'bottom')

    yLabel = @origin
    .append('g')
    .attr('transform', 'translate({0},{1}) rotate(270) scale(-1,1)'.format -20, @h*.6)
    .append('text').text('Latency').style('font-size', 20)



    @origin.append('rect').attr('x',-1.5).attr('y',-1.5).attr('width', 3.5).attr('height', 3.5).attr('class', 'black')

class Plot

  constructor: (@lines, @axis) ->

  insert: (@axisLocation) ->
    @axis.insert @axisLocation
    (line.insert @axis.origin for line in @lines)
    labelSVG = @axis.origin.append('svg')
    # (labelSVG.append('text').attr('x', line.points[0].x).attr('y', line.points[0].y).text(line.color).attr('transform','rotate {0} {1} {2}'.format(line.points[0].x,line.points[0].y,180)) for line in @lines)
    (labelSVG.append('g').attr('transform','translate({0},{1}) scale(-1,1) rotate({2})'.format line.points[0].x,line.points[0].y,180).append('text').attr('x',30).attr('y',-10).text('a_{0}'.format line.color[0] + line.color[line.color.length - 1]).attr('text-anchor', 'left').attr('style', 'dominant-baseline: central;').style('fill', '#444') for line in @lines)
    (labelSVG.append('g').attr('transform','translate({0},{1}) scale(-1,1) rotate({2})'.format line.points[1].x,line.points[1].y,180).append('text').attr('x',0).attr('y',10).text('xm_{0}'.format line.color[0] + line.color[line.color.length - 1]).attr('text-anchor', 'middle').attr('style', 'dominant-baseline: central;').style('fill', '#444') for line in @lines)

  reset: () ->
    (line.state.reset() for line in @lines)

  show: () ->
    $(@axisLocation).show()

  hide: () ->
    $(@axisLocation).hide()

  hideStates: () ->
    (line.state.hide() for line in @lines)

#####################
# create network
#####################


class Arc
  constructor: (@color, @radius) ->
    @network = false
    @arc = false
    @thickness = false
    @arcFn = (thickness) =>
      d3v2.svg.arc()
      .innerRadius((r) => @radius - thickness / 2)
      .outerRadius((r) => @radius + thickness / 2)
      .startAngle((r) => @network.arcEndAngles(@radius)[0])
      .endAngle((r) => @network.arcEndAngles(@radius)[1])

  setArc: (thick, fill) ->
    @thick = thick if thick
    @arc.attr('d', @arcFn(thick*@thickness)(this)) if thick
    @arc.attr('fill', fill) if fill


  moveArc: (t1, t2, f1, f2, t, cb) ->
    @setArc t1, f1

    t1 = @thick unless t1

    trans = @arc.transition().ease('linear').duration(t*simTime)

    trans.attrTween('d', @arcTween this, t1, t2) if t2
    trans.attr("fill", f2) if f2
    trans.each "end", () => @thick = t2 if t2; cb()

  reset: () ->
    @setArc 1, @color

  arcTween: (data, t1, t2) ->
    (a) =>
      prev = @arcFn(@thickness*t1)(data)
      next = @arcFn(@thickness*t2)(data)
      d3.interpolate prev, next

class Network

  constructor: (@width, @height, @arcs) ->
    @nodeRadius = @width / 10;
    @xNodePad = @nodeRadius * 1.5
    @yNodePad = @height
    @xArc = @width / 2
    @arcThickness = @width / 30;
    @yArc = (aRad) -> Math.sqrt(Math.pow(aRad, 2) - Math.pow((@width /2 - @xNodePad), 2)) + @yNodePad


  insertArc: (arc) ->
    arc.network = this
    arc.thickness = @arcThickness
    arc.arc = @parentSVG.append('path').attr('class', 'arc').attr('transform', 'translate({0},{1})'.format @xArc, @yArc arc.radius)



  insert: (@parentSVG) ->
    @parentSVG = @parentSVG[0][0]
    @parentSVG = d3.select(@parentSVG)

    source = [@xNodePad, @height, @nodeRadius]
    sink = [@width - @xNodePad, @height, @nodeRadius ]
    sourceNode = @parentSVG.append("circle")
    .attr("id", "source-node")
    .attr("class", "network-node")
    .attr("cx", source[0])
    .attr("cy", source[1])
    .attr("r", source[2])

    sinkNode = @parentSVG.append("circle")
    .attr("id", "sink-node")
    .attr("class", "network-node")
    .attr("cx", sink[0])
    .attr("cy", sink[1])
    .attr("r", sink[2])

    sourceLabel = @parentSVG.append('text')
    .attr('x', source[0])
    .attr('y', source[1])
    .attr('class', 'node-label')
    .attr('text-anchor', 'middle')
    .attr('style', 'dominant-baseline: central;')
    .text("Source")

    sinkLabel = @parentSVG.append('text')
    .attr('x', sink[0])
    .attr('y', sink[1])
    .attr('class', 'node-label')
    .attr('text-anchor', 'middle')
    .attr('style', 'dominant-baseline: central;')
    .text("Sink")

    ((@insertArc arc ) for arc in @arcs)

  arcEndAngles: (aRad) ->
    toMid = Math.acos((@width / 2 - @xNodePad) / aRad)
    toOut = 2*Math.asin(@nodeRadius / 2 / aRad)
    offSet = (toMid + toOut)
    [-PI/2 + offSet, PI/2 - offSet]

  reset: () ->
    (arc.reset() for arc in @arcs)


#####################
# constants
#####################

simTime = 6000
hMeter = 300
PI = Math.PI

wNetwork = 350; hNetwork = 150
wPlot = 350; hPlot = 400

axisLength = hPlot*.8
stateRadius = wNetwork / 20;

fatLinkFactor = 4
congLinkFactor = 3
superCongLinkFactor = 2

tBounce = 400

a1 = axisLength*.1
a2 = axisLength*.25
a3 = axisLength*.4
b1 = axisLength*.95
b2 = axisLength*.7
b3 = axisLength*.45

arcData = [
  {"r": 2000
  "a": a1
  "xmax": b1
  "cong1": new Point(b1 - a2 + a1, a2)
  "cong2": new Point(b1 - a3 + a1, a3)
  "congf": new Point(b1 - a3 - b3 + a1, a3 + b3)
  "name": "a"
  "fill": "black"}
  {"r": 180
  "name": "b"
  "cong2": new Point(b2 - a3 + a2, a3)
  "congf": new Point(b2 - a3 - b3 + a2, a3 + b3)
  "a": a2
  "xmax": b2
  "fill": "blue"}
  {"r": 130
  "name": "c"
  "a": a3
  "xmax": b3
  "congf": new Point(0, a3 + b3)
  "fill": "yellow"}
]

arcDataEx = [
  {"r": 2000
  "a": a1
  "xmax": b1
  "cong1": new Point(b1 - a2 + a1, a2)
  "cong2": new Point(b1 - a3 + a1, a3)
  "congf": new Point(b1 - a3 - b3 + a1, a3 + b3)
  "name": "a"
  "fill": "black"}
  {"r": 180
  "name": "b"
  "cong2": new Point(b2 - a3 + a2, a3)
  "congf": new Point(b2 - a3 - b3 + a2, a3 + b3)
  "a": a2
  "xmax": b2
  "fill": "blue"}
  {"r": 130
  "name": "c"
  "a": a3
  "xmax": b3*.3
  "congf": new Point(0, a3 + b3)
  "fill": "yellow"}
]



#####################
# string formatting
######################

String::format = ->
  formatted = this
  i = 0

  while i < arguments.length
    regexp = new RegExp("\\{" + i + "\\}", "gi")
    formatted = formatted.replace(regexp, arguments[i])
    i++
  formatted


#####################
# run specific code for simulation
#####################


fillUpNetwork = () ->

  state = 0

  nextState = () ->
    state = if state< 4 then state + 1 else 0

  runStateAction = () ->
    if state == 0
      reset()
      updateButton()
      return
    switch state
      when 1 then fn = fillLink1
      when 2 then fn = congestLink1
      when 3 then fn = fillLink2
      when 4 then fn = fillToCapacity
    $("#demo").attr("disabled", "disabled")
    fn () ->
      $("#demo").removeAttr("disabled")
      updateButton()
  updateButton = () ->
    switch state
      when 0 then text = "Start"
      when 1 then text = "Next"
      when 2 then text = "Next"
      when 3 then text = "Finish"
      when 4 then text = "Reset"

    $("#demo").text text

  clickDemo = () ->
    nextState()
    runStateAction()
    updateStatus()

  clickReset = () ->
    state = 6
    clickDemo()

  reset = () ->
    (object.reset() for object in [network, plot, meter])


  fillLink1 = (cb) ->
    t = .25
    link1 = plot.lines[0]
    arc1 = network.arcs[0]

    meter.move false, 2.0/3, t, -> ""

    link1.state.moveLocation false, new Point(link1.points[1].x*.88, link1.points[1].y), t, cb


    arc1.moveArc false, fatLinkFactor, false, false, t, -> ""

  congestLink1 = (cb) ->
    t = .25
    link1 = plot.lines[0]
    arc1 = network.arcs[0]
    diff = arcData[0]['xmax'] - link1.state.state.attr('cx')
    link1.state.moveLocation false, new Point(link1.state.state.attr('cx'), arcData[0]['a'] + diff), t, cb
    arc1.moveArc false, fatLinkFactor*.8, false, "red", t, -> ""

  fillLink2 = (cb) ->
    t = .25
    link1 = plot.lines[0]
    arc1 = network.arcs[0]
    link2 = plot.lines[1]
    arc2 = network.arcs[1]

    link1.state.moveLocation false, arcData[0]['cong1'], t, cb
    link2.state.moveLocation false, new Point(link1.points[1].x*.12, link2.points[1].y), t, ->
    arc1.moveArc false, superCongLinkFactor*.8, false, "#8A0007", t, -> ""

  fillToCapacity = (cb) ->
    t = .25
    y = arcData[2]['a'] + .8*arcData[2]['xmax']
    points = [
      new Point(arcData[0]['xmax'] - (y - arcData[0]['a']), y),
      new Point(arcData[1]['xmax'] - (y - arcData[1]['a']), y),
      new Point(arcData[2]['xmax'] - (y - arcData[2]['a']), y),
    ]
    ((plot.lines[i].state.moveLocation false, points[i], t, ->) for i in [0,1])
    plot.lines[2].state.moveLocation false, points[2], t, cb

    ((arc.moveArc false, false, false, "red", t, ->) for arc in network.arcs)


  updateStatus = () ->
    switch state
      when 0
        status = "Network Empty"
        info = ""
      when 1
        status = "Black Link in Free Flow"
        info = ""
      when 2
        status = "Black Link congested"
        info = ""
      when 3
        status = "Blue link in free flow, black link congested"
        info = ""
      when 4
        status = "Fully Congested"
        info = ""
    $("#status").text status
    $("#status-info").text info

  $("#demo").click clickDemo
  $("#reset").click clickReset


  # make meter
  meter = new Meter 300, hMeter
  meter.insert '#meter-section'

  # make network
  networkSVG = d3v2.select("#network-section svg")
  arcs = (new Arc(data['fill'], data['r']) for data in arcData)
  network = new Network wNetwork, hNetwork, arcs
  network.insert networkSVG


  # make plot
  # create plotting background
  plotLocation = d3v2.select("#plot-section").append("svg")
  .attr("id", "plot-svg")
  .append('g')
  .attr('transform', 'translate({0},{1})'.format wPlot * .3, hPlot * .95 )

  lines = (new PlotLine line['a'], line['xmax'], line['fill'] for line in arcData)
  axis = new Axis wPlot, hPlot*.9
  plot = new Plot lines, axis
  plot.insert plotLocation

  clickReset()

class PossibleModes

  constructor: () ->

  insert: () ->
    # make plot
    # create plotting background
    plotLocation = d3v2.select("#nash-equilibria-allowable-states .svg").append("svg")
    .attr("id", "plot-svg")
    .append('g')
    .attr('transform', 'translate({0},{1})'.format wPlot * .2, hPlot * .95 )

    lines = (new PlotLine line['a'], line['xmax'], line['fill'] for line in arcData)
    axis = new Axis wPlot, hPlot*.9
    @plot = new Plot lines, axis
    @plot.insert plotLocation

    @setup()

  setup: ->
    @plot.hideStates()

  firstPoint: ->
    l2 = @plot.lines[1]
    d2 = arcData[1]
    l3 = @plot.lines[2]
    l2.state.setLocation d2['cong2']
    l3.state.setLocation new Point(0, l3.points[0].y).midPoint l3.points[0]
    l2.state.show()
    l3.state.show()

  addDash: ->
    p2y = @plot.lines[1].state.state.attr('cy')
    p2x = @plot.lines[1].state.state.attr('cx')
    p1y = p2y
    p1x = 0
    line = d3.svg.line().x((p)->p.x).y((p)->p.y)([new Point(p1x,p1y), new Point(p2x,p2y)])

    @dashedLine = @plot.axis.origin.append('path').attr('d', line).style('stroke', 'black').style('stroke-dasharray', '4px 4px')

  putCongestedLink2: ->
    t = .25
    x = arcData[0]['cong2'].x
    l1 = @plot.lines[0]
    startPoint = new Point(x, arcData[0]['a'])
    l1.state.setLocation startPoint
    l1.state.setColor "green"
    l1.state.show()

  moveCongestedLink2: ->
    t = .25
    l1 = @plot.lines[0]
    endPoint = arcData[0]['cong2']
    l1.state.move endPoint, "red", t, ->

  resetInBetween: ->
    @plot.reset()
    @plot.hideStates()
    try
      $(@dashedLine[0][0]).hide()
    catch e
      console.log e

  ff1: ->
    ls2 = @plot.lines[1].state
    ls1 = @plot.lines[0].state
    d2 = arcData[1]
    d1 = arcData[0]
    p2 = new Point(d2['xmax']*.5, d2['a'])
    p1 = d1['cong1']
    ls2.setLocation p2
    ls1.setLocation p1
    ls1.show()
    ls2.show()

  ff2: ->
    ls3 = @plot.lines[2].state
    data3 = arcData[2]
    p = new Point(data3['xmax']*.5, data3['a'])
    ls3.setLocation p
    ls3.show()

  ff3: ->
    ls3 = @plot.lines[2].state
    ls3.disappear(1000, -> "")

class BNE

  constructor: () ->

  insert: () ->
    # make plot
    # create plotting background
    plotLocation = d3v2.select("#free-flow-existence-slide .svg").append("svg")
    .attr("id", "plot-svg")
    .append('g')
    .attr('transform', 'translate({0},{1})'.format wPlot * .2, hPlot * .95 )

    @lines = (new PlotLine line['a'], line['xmax'], line['fill'] for line in arcData)
    axis = new Axis wPlot, hPlot*.9
    @plot = new Plot @lines, axis
    @plot.insert plotLocation
    @setup()

  setup: ->
    @plot.hideStates()

  start: ->
    @yEx = (@lines[2].points[2].y - @lines[2].points[0].y)*.6
    p1 = new Point(arcData[0]['cong2'].x - @yEx, arcData[0]['cong2'].y + @yEx)
    p2 = new Point(arcData[1]['cong2'].x - @yEx, arcData[1]['cong2'].y + @yEx)
    p3 = new Point(@lines[2].points[1].x - @yEx, @lines[2].points[1].y + @yEx)
    points = [p1,p2,p3]
    (@lines[i].state.setLocation points[i] for i in [0,1,2])
    (line.state.show() for line in @lines)
    @line = d3.svg.line().x((p)->p.x).y((p)->p.y)
    try
      @dashedLine.junk
      p1 = new Point 0, @lines[0].state.state.attr('cy')
      p2 = new Point @lines[0].state.state.attr('cx'), @lines[0].state.state.attr('cy')
      @dashedLine.attr('d', @line([p1,p2]))
    catch e
      p1 = new Point 0, @lines[0].state.state.attr('cy')
      p2 = new Point @lines[0].state.state.attr('cx'), @lines[0].state.state.attr('cy')
      @dashedLine = @plot.axis
      .origin
      .append('path')
      .attr('d', @line([p1,p2]))
      .style('stroke', 'black')
      .style('stroke-dasharray', '4px 4px')
    $(@dashedLine[0][0]).show()

  moveHor: ->
    t = .25
    points = [
      arcData[0]['cong2']
      arcData[1]['cong2']
      new Point arcData[2]['xmax']*-.3, arcData[2]['a']
    ]
    ((@lines[i].state.moveLocation false, points[i], t, ->) for i in [0,1])
    @lines[2].state.moveLocation false, points[2], t, =>
      @lines[2].state.bounce 500, 'red', ->

    try
      @dashedLine
      .transition()
      .duration(t*simTime)
      .ease('linear')
      .attr('d', @line([
        @lines[2].points[0],
        arcData[0]['cong2']
        ]))
    catch e
      console.log e

  disappear: ->
    ls3 = @plot.lines[2].state
    ls3.disappear(500, -> "")

  moveHor2: ->
    t = .25
    l1 = @lines[0]
    l2 = @lines[1]
    points = [
      arcData[0]['cong1']
      l2.points[0].midPoint l2.points[1]
    ]
    try
      @dashedLine
      .transition()
      .duration(t*simTime)
      .ease('linear')
      .attr('d', @line([
        @lines[1].points[0],
        arcData[0]['cong1']
        ]))
    catch e
      console.log e

    l1.state.moveLocation false, points[0], t, () =>
      l1.state.bounce 500, 'green', ->
    l2.state.moveLocation false, points[1], t, () =>
      l2.state.bounce 500, 'green', ->



  resetInBetween: ->
    @plot.reset()
    @lines[2].state.setRadius @lines[2].state.radius
    @plot.hideStates()
    try
      $(@dashedLine[0][0]).hide()
    catch e
      console.log e


class RBNE

  constructor: () ->

  insert: () ->
    # make plot
    # create plotting background
    plotLocation = d3v2.select("#bne-slide .svg").append("svg")
    .attr("id", "plot-svg")
    .append('g')
    .attr('transform', 'translate({0},{1})'.format wPlot * .2, hPlot * .95 )

    @lines = (new PlotLine line['a'], line['xmax'], line['fill'] for line in arcData)
    axis = new Axis wPlot, hPlot*.9
    @plot = new Plot @lines, axis
    @plot.insert plotLocation
    @setup()

  setup: ->
    @plot.hideStates()

  start: ->
    @r = arcData[0]['xmax']*1.15
    @lines[0].state.setLocation new Point(@r, arcData[0]['a'])
    @lines[0].state.show()

  turnRed: ->
    @lines[0].state.bounce 500, "red", ->

  showSecond: ->
    @lines[1].state.setLocation @lines[1].points[0]
    @lines[1].state.show()

  move: ->
    t = .25
    s1 = @lines[0].state
    s2 = @lines[1].state
    s1.moveLocation false, arcData[0]['cong1'], t, =>
      s1.bounce 500, 'green', ->
    s2.moveLocation false, new Point(@r - arcData[0]['cong1'].x, arcData[1]['a']), t, =>
      s2.bounce 500, 'green', ->

  resetInBetween: ->
    @plot.reset()
    @plot.hideStates()









window.modes = new PossibleModes()
window.bne = new BNE()
window.rbne = new RBNE()


$ ->
  fillUpNetwork()
  window.modes.insert()
  window.bne.insert()
  window.rbne.insert()

