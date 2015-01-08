String::format = ->
  formatted = this
  i = 0

  while i < arguments.length
    regexp = new RegExp("\\{" + i + "\\}", "gi")
    formatted = formatted.replace(regexp, arguments[i])
    i++
  formatted

main = () ->
  wMeter = 50; hMeter = 300
  PI = Math.PI

  simTime = 10000

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

  nodeRadius = wNetwork / 10;
  arcThickness = wNetwork / 30;

  xNodePad = nodeRadius*1.5
  yNodePad = hNetwork * .65

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
      when 2 then fn = fillLink2
      when 3 then fn = fillLink3
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
    state = 4
    clickDemo()




  arcData = [
    {"r": 2000
    "plot": [[0, a1], [b1, a1], [0, a1 + b1]]
    "cong1": [b1 - a2 + a1, a2]
    "cong2": [b1 - a3 + a1, a3]
    "congf": [b1 - a3 - b3 + a1, a3 + b3]
    "name": "a"
    "fill": "black"}
    {"r": 180
    "name": "b"
    "cong1": [b2 - a3 + a2, a3]
    "congf": [b2 - a3 - b3 + a2, a3 + b3]
    "plot": [[0, a2], [b2, a2], [0, a2 + b2]]
    "fill": "blue"}
    {"r": 130
    "name": "c"
    "plot": [[0, a3], [b3, a3], [0, a3 + b3]]
    "congf": [0, a3 + b3]
    "fill": "yellow"}
  ]

  source = [xNodePad, yNodePad, nodeRadius]
  sink = [wNetwork - xNodePad, yNodePad, nodeRadius ]

  xArc = wNetwork / 2
  yArc = (aRad) -> Math.sqrt(Math.pow(aRad, 2) - Math.pow((wNetwork /2 - xNodePad), 2)) + yNodePad

  arcEndAngles = (aRad) ->
    toMid = Math.acos((wNetwork / 2 - xNodePad) / aRad)
    toOut = 2*Math.asin(nodeRadius / 2 / aRad)
    offSet = (toMid + toOut)
    [-PI/2 + offSet, PI/2 - offSet]

  setMeter = (a) ->
    meter.attr('height', hMeter*a) if a


  moveMeter = (a,b,t,cb) ->
    setMeter(a)
    meter.transition().ease('linear')
    .duration(t*simTime)
    .attr("height", hMeter*b)
    .each "end", cb

  setState = (elem, p1) ->
    d3v2.select(elem['plot-state'])
    .attr('cx', p1[0])
    .attr('cy', p1[1])

  moveState = (elem, p1, p2, t, cb) ->
    setState elem, p1 if p1
    d3v2.select(elem['plot-state']).transition().ease('linear')
    .duration(t*simTime)
    .attr('cx', p2[0])
    .attr('cy', p2[1])
    .each "end", cb

  setArc = (elem, thick, fill) ->
    d3v2El = d3v2.select(elem['arc'])

    elem['thick'] = thick if thick
    d3v2El.attr('d', arc(thick*arcThickness)(elem)) if thick


    d3v2El.attr('fill', fill) if fill

  moveArc = (elem, t1, t2, f1, f2, t, cb) ->
    setArc elem, t1, f1

    t1 = elem['thick'] unless t1

    d3v2El = d3v2.select(elem['arc'])
    trans = d3v2El.transition().ease('linear').duration(t*simTime)

    trans.attrTween('d', arcTween elem, t1, t2) if t2
    trans.attr("fill", f2) if f2
    trans.each "end", () -> elem['thick'] = t2; cb()

  resetMeter = () -> setMeter 1
  resetStates = () ->
    plotStates.data(arcData)
    .attr("cx", 0)
    .attr("cy", (d) -> d['plot'][0][1])

  resetArcs = () ->
    arcs.data(arcData)
    .attr("fill", (r) -> r['fill'])
    .attr("d", arc(arcThickness))
    .each (d) -> d['thick'] = 1



  reset = () ->
    resetMeter()
    resetStates()
    resetArcs()


  fillLink1 = (cb) ->
    t = .25
    el = arcData[0]
    moveMeter false, 2.0/3, t, () -> ""

    moveState el, false, el['plot'][1], t, () ->
      setState el, el['cong1']
      d3v2.select(el['plot-state']).transition().duration(tBounce).attr("r", stateRadius*1.5).attr("fill", "red")
      .each "end", () ->
        d3v2.select(el['plot-state']).transition().duration(tBounce).attr("r", stateRadius).attr("fill", el['fill'])
        .each "end", cb

    moveArc el, false, fatLinkFactor, false, false, t, () ->
      setArc el, congLinkFactor, "red"

  fillLink2 = (cb) ->
    t = .25
    el = arcData[1]
    moveMeter false, 1.0/3, t, () -> ""

    moveState el, false, el['plot'][1], t, () ->
      setState el, el['cong1']
      setState arcData[0], arcData[0]['cong2']
      d3v2.select(el['plot-state']).transition().duration(tBounce).attr("r", stateRadius*1.5).attr("fill", "red")
      .each "end", () ->
        d3v2.select(el['plot-state']).transition().duration(tBounce).attr("r", stateRadius).attr("fill", el['fill'])
      d3v2.select(arcData[0]['plot-state']).transition().duration(tBounce).attr("r", stateRadius*1.5)
      .each "end", () ->
        d3v2.select(arcData[0]['plot-state']).transition().duration(tBounce).attr("r", stateRadius)


    moveArc el, false, fatLinkFactor, false, false, t, () ->
      setArc el, congLinkFactor, "red"
      setArc arcData[0], superCongLinkFactor, "#8A0007"
      cb()

  fillLink3 = (cb) ->
    t = .25
    el = arcData[2]
    moveMeter false, 0, t, () -> ""

    moveState el, false, el['plot'][1], t, () ->
      d3v2.select(el['plot-state']).transition().duration(tBounce).attr("r", stateRadius*1.5).attr("fill", "red")
      .each "end", () ->
        d3v2.select(el['plot-state']).transition().duration(tBounce).attr("r", stateRadius).attr("fill", el['fill'])

    moveArc el, false, fatLinkFactor, false, false, t, cb

  fillToCapacity = (cb) ->
    t = .25
    moveMeter false, .5, t*1.05, cb
    plotStates.data(arcData).transition().ease('linear').duration(.25 * simTime)
    .attr("cx", (d) -> d['congf'][0])
    .attr("cy", (d) -> d['congf'][1])

    arcs.data(arcData).transition().ease('linear').duration(.25 * simTime)
    .attr("fill", "black")


  updateStatus = () ->
    switch state
      when 0
        status = "Network Empty"
        info = "When agents enter the network, they will prefer the black link since it has the lowest free-flow latency."
      when 1
        status = "Black Link in Free Flow"
        info = "As demand increases on the network, the black link will eventually reach capacity, and additional demand must be accommodated on additional links."
      when 2
        status = "Black Link Congests, Blue Link in Free Flow"
        info = "The black link remains congested and at a constant latency, while the blue link takes additional flux. After the blue link reaches capacity, both the black and blue links congest further and reach a higher latency."
      when 3
        status = "Network At Max Capacity"
        info = "Once the yellow link reaches its capacity, the network cannot any more demand. For certain latency relations, it is possible that the network reaches capacity without any demand entering the last link."
      when 4
        status = "Fully Congested"
        info = "While it is guaranteed the Nash equilibria exist with lower total latency, fully congested equilibria do exist for certain demands on all networks."
    $("#status").text status
    $("#status-info").text info

  $("#demo").click clickDemo

  $("#reset").click clickReset

  meterSVG = d3v2.select("#meter-section").append("svg")
  .attr("id", "meter-svg")
  .attr("width", wMeter)
  .attr("height", hMeter)
  .append("g")
  .attr("transform", "translate({0},{1}) scale(1,-1)".format(0, hMeter))

  meterContainer = meterSVG.append("rect")
  .attr("id", "meter-container")
  .attr("width", wMeter)
  .attr("height", hMeter)

  meter = meterSVG.append("rect")
  .attr("id", "meter")
  .attr("width", wMeter)
  resetMeter()


  networkSVG = d3v2.select("#network-section svg")
  .attr("width", wNetwork)
  .attr("height", hNetwork)

  sourceNode = networkSVG.append("circle")
  .attr("id", "source-node")
  .attr("class", "network-node")
  .attr("cx", source[0])
  .attr("cy", source[1])
  .attr("r", source[2])

  sinkNode = networkSVG.append("circle")
  .attr("id", "sink-node")
  .attr("class", "network-node")
  .attr("cx", sink[0])
  .attr("cy", sink[1])
  .attr("r", sink[2])

  # create plotting background

  plotSVG = d3v2.select("#plot-section").append("svg")
  .attr("id", "plot-svg")
  .attr("width", wPlot)
  .attr("height", hPlot)



  axis = plotSVG.append("g")
  .attr("transform", "translate({0},{1}) scale(1, -1) ".format(wPlot*.1, hPlot*.9))


  xAxis = axis
  .append("line")
  .attr("class", "axis-line")
  .attr("x1", 0)
  .attr("y1", 0)
  .attr("x2", axisLength*1.3)
  .attr("y2", 0)

  yAxis = axis
  .append("line")
  .attr("class", "axis-line")
  .attr("x1", 0)
  .attr("y1", 0)
  .attr("x2", 0)
  .attr("y2", axisLength*1.1)

  plotLine = d3v2.svg.line()
  .x((p) -> p[0])
  .y((p) -> p[1])

  plots = axis.selectAll("path").data(arcData).enter()
  .append("path")
  .attr("class", 'plot-line')
  .attr("d", (d) -> plotLine(d['plot']))
  .attr("stroke", (d) -> d['fill'])



  plotStates = axis.selectAll("circle").data(arcData).enter()
  .append("circle")
  .attr("class", 'plot-state')
  .attr("r", stateRadius)
  .attr("fill", (d) -> d['fill'])
  .attr("id", (d) -> "plot-state-{0}".format(d['name']))
  .each (d) -> d['plot-state'] = this



  arc = (thickness) ->
    d3v2.svg.arc()
    .innerRadius((r) -> r['r'] - thickness / 2)
    .outerRadius((r) -> r['r'] + thickness / 2)
    .startAngle((r) -> arcEndAngles(r['r'])[0])
    .endAngle((r) -> arcEndAngles(r['r'])[1])

  arcs = networkSVG.selectAll("path")
  .data(arcData)
  .enter()
  .append("path")
  .attr("class", "arc")
  .attr("transform", (r) -> "translate(" + xArc + "," + yArc(r['r']) + ")")
  .attr("id", (r) -> '{0}-arc'.format(r['name']))
  .each (d) -> d['arc'] = this

  networkSVG.selectAll("rect")
  .data(arcData)
  .enter()
  .append("rect")
  .attr("stroke", (r) -> r['stroke'])

  arcTween = (data, t1, t2) ->
    (a) =>
      prev = arc(arcThickness*t1)(data)
      next = arc(arcThickness*t2)(data)
      d3v2.interpolate prev, next

  clickReset()


$ -> main()
