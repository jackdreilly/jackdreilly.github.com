// Generated by CoffeeScript 1.4.0
(function() {
  var main;

  String.prototype.format = function() {
    var formatted, i, regexp;
    formatted = this;
    i = 0;
    while (i < arguments.length) {
      regexp = new RegExp("\\{" + i + "\\}", "gi");
      formatted = formatted.replace(regexp, arguments[i]);
      i++;
    }
    return formatted;
  };

  main = function() {
    var PI, a1, a2, a3, arc, arcData, arcEndAngles, arcThickness, arcTween, arcs, axis, axisLength, b1, b2, b3, clickDemo, clickReset, congLinkFactor, fatLinkFactor, fillLink1, fillLink2, fillLink3, fillToCapacity, hMeter, hNetwork, hPlot, meter, meterContainer, meterSVG, moveArc, moveMeter, moveState, networkSVG, nextState, nodeRadius, plotLine, plotSVG, plotStates, plots, reset, resetArcs, resetMeter, resetStates, runStateAction, setArc, setMeter, setState, simTime, sink, sinkNode, source, sourceNode, state, stateRadius, superCongLinkFactor, tBounce, updateButton, updateStatus, wMeter, wNetwork, wPlot, xArc, xAxis, xNodePad, yArc, yAxis, yNodePad;
    wMeter = 75;
    hMeter = 300;
    PI = Math.PI;
    simTime = 10000;
    wNetwork = 550;
    hNetwork = 400;
    wPlot = 550;
    hPlot = 400;
    axisLength = hPlot * .8;
    stateRadius = 20;
    fatLinkFactor = 4;
    congLinkFactor = 3;
    superCongLinkFactor = 2;
    tBounce = 400;
    a1 = axisLength * .1;
    a2 = axisLength * .25;
    a3 = axisLength * .4;
    b1 = axisLength * .95;
    b2 = axisLength * .7;
    b3 = axisLength * .45;
    state = 0;
    nextState = function() {
      return state = state < 4 ? state + 1 : 0;
    };
    runStateAction = function() {
      var fn;
      if (state === 0) {
        reset();
        updateButton();
        return;
      }
      switch (state) {
        case 1:
          fn = fillLink1;
          break;
        case 2:
          fn = fillLink2;
          break;
        case 3:
          fn = fillLink3;
          break;
        case 4:
          fn = fillToCapacity;
      }
      $("#demo").attr("disabled", "disabled");
      return fn(function() {
        $("#demo").removeAttr("disabled");
        return updateButton();
      });
    };
    updateButton = function() {
      var text;
      switch (state) {
        case 0:
          text = "Start Demo";
          break;
        case 1:
          text = "Next";
          break;
        case 2:
          text = "Next";
          break;
        case 3:
          text = "Finish";
          break;
        case 4:
          text = "Reset";
      }
      return $("#demo").text(text);
    };
    clickDemo = function() {
      nextState();
      runStateAction();
      return updateStatus();
    };
    clickReset = function() {
      state = 4;
      return clickDemo();
    };
    arcData = [
      {
        "r": 2000,
        "plot": [[0, a1], [b1, a1], [0, a1 + b1]],
        "cong1": [b1 - a2 + a1, a2],
        "cong2": [b1 - a3 + a1, a3],
        "congf": [b1 - a3 - b3 + a1, a3 + b3],
        "name": "a",
        "fill": "black"
      }, {
        "r": 350,
        "name": "b",
        "cong1": [b2 - a3 + a2, a3],
        "congf": [b2 - a3 - b3 + a2, a3 + b3],
        "plot": [[0, a2], [b2, a2], [0, a2 + b2]],
        "fill": "blue"
      }, {
        "r": 250,
        "name": "c",
        "plot": [[0, a3], [b3, a3], [0, a3 + b3]],
        "congf": [0, a3 + b3],
        "fill": "yellow"
      }
    ];
    nodeRadius = 40;
    arcThickness = 10;
    xNodePad = nodeRadius * 1.5;
    yNodePad = hNetwork / 2;
    source = [xNodePad, yNodePad, nodeRadius];
    sink = [wNetwork - xNodePad, yNodePad, nodeRadius];
    xArc = wNetwork / 2;
    yArc = function(aRad) {
      return Math.sqrt(Math.pow(aRad, 2) - Math.pow(wNetwork / 2 - xNodePad, 2)) + yNodePad;
    };
    arcEndAngles = function(aRad) {
      var offSet, toMid, toOut;
      toMid = Math.acos((wNetwork / 2 - xNodePad) / aRad);
      toOut = 2 * Math.asin(nodeRadius / 2 / aRad);
      offSet = toMid + toOut;
      return [-PI / 2 + offSet, PI / 2 - offSet];
    };
    setMeter = function(a) {
      if (a) {
        return meter.attr('height', hMeter * a);
      }
    };
    moveMeter = function(a, b, t, cb) {
      setMeter(a);
      return meter.transition().ease('linear').duration(t * simTime).attr("height", hMeter * b).each("end", cb);
    };
    setState = function(elem, p1) {
      return d3.select(elem['plot-state']).attr('cx', p1[0]).attr('cy', p1[1]);
    };
    moveState = function(elem, p1, p2, t, cb) {
      if (p1) {
        setState(elem, p1);
      }
      return d3.select(elem['plot-state']).transition().ease('linear').duration(t * simTime).attr('cx', p2[0]).attr('cy', p2[1]).each("end", cb);
    };
    setArc = function(elem, thick, fill) {
      var d3El;
      d3El = d3.select(elem['arc']);
      if (thick) {
        elem['thick'] = thick;
      }
      if (thick) {
        d3El.attr('d', arc(thick * arcThickness)(elem));
      }
      if (fill) {
        return d3El.attr('fill', fill);
      }
    };
    moveArc = function(elem, t1, t2, f1, f2, t, cb) {
      var d3El, trans;
      setArc(elem, t1, f1);
      if (!t1) {
        t1 = elem['thick'];
      }
      d3El = d3.select(elem['arc']);
      trans = d3El.transition().ease('linear').duration(t * simTime);
      if (t2) {
        trans.attrTween('d', arcTween(elem, t1, t2));
      }
      if (f2) {
        trans.attr("fill", f2);
      }
      return trans.each("end", function() {
        elem['thick'] = t2;
        return cb();
      });
    };
    resetMeter = function() {
      return setMeter(1);
    };
    resetStates = function() {
      return plotStates.data(arcData).attr("cx", 0).attr("cy", function(d) {
        return d['plot'][0][1];
      });
    };
    resetArcs = function() {
      return arcs.data(arcData).attr("fill", function(r) {
        return r['fill'];
      }).attr("d", arc(arcThickness)).each(function(d) {
        return d['thick'] = 1;
      });
    };
    reset = function() {
      resetMeter();
      resetStates();
      return resetArcs();
    };
    fillLink1 = function(cb) {
      var el, t;
      t = .25;
      el = arcData[0];
      moveMeter(false, 2.0 / 3, t, function() {
        return "";
      });
      moveState(el, false, el['plot'][1], t, function() {
        setState(el, el['cong1']);
        return d3.select(el['plot-state']).transition().duration(tBounce).attr("r", stateRadius * 1.5).attr("fill", "red").each("end", function() {
          return d3.select(el['plot-state']).transition().duration(tBounce).attr("r", stateRadius).attr("fill", el['fill']).each("end", cb);
        });
      });
      return moveArc(el, false, fatLinkFactor, false, false, t, function() {
        return setArc(el, congLinkFactor, "red");
      });
    };
    fillLink2 = function(cb) {
      var el, t;
      t = .25;
      el = arcData[1];
      moveMeter(false, 1.0 / 3, t, function() {
        return "";
      });
      moveState(el, false, el['plot'][1], t, function() {
        setState(el, el['cong1']);
        setState(arcData[0], arcData[0]['cong2']);
        d3.select(el['plot-state']).transition().duration(tBounce).attr("r", stateRadius * 1.5).attr("fill", "red").each("end", function() {
          return d3.select(el['plot-state']).transition().duration(tBounce).attr("r", stateRadius).attr("fill", el['fill']);
        });
        return d3.select(arcData[0]['plot-state']).transition().duration(tBounce).attr("r", stateRadius * 1.5).each("end", function() {
          return d3.select(arcData[0]['plot-state']).transition().duration(tBounce).attr("r", stateRadius);
        });
      });
      return moveArc(el, false, fatLinkFactor, false, false, t, function() {
        setArc(el, congLinkFactor, "red");
        setArc(arcData[0], superCongLinkFactor, "#8A0007");
        return cb();
      });
    };
    fillLink3 = function(cb) {
      var el, t;
      t = .25;
      el = arcData[2];
      moveMeter(false, 0, t, function() {
        return "";
      });
      moveState(el, false, el['plot'][1], t, function() {
        return d3.select(el['plot-state']).transition().duration(tBounce).attr("r", stateRadius * 1.5).attr("fill", "red").each("end", function() {
          return d3.select(el['plot-state']).transition().duration(tBounce).attr("r", stateRadius).attr("fill", el['fill']);
        });
      });
      return moveArc(el, false, fatLinkFactor, false, false, t, cb);
    };
    fillToCapacity = function(cb) {
      var t;
      t = .25;
      moveMeter(false, .5, t * 1.05, cb);
      plotStates.data(arcData).transition().ease('linear').duration(.25 * simTime).attr("cx", function(d) {
        return d['congf'][0];
      }).attr("cy", function(d) {
        return d['congf'][1];
      });
      return arcs.data(arcData).transition().ease('linear').duration(.25 * simTime).attr("fill", "black");
    };
    updateStatus = function() {
      var info, status;
      switch (state) {
        case 0:
          status = "Network Empty";
          info = "When agents enter the network, they will prefer the black link since it has the lowest free-flow latency.";
          break;
        case 1:
          status = "Black Link in Free Flow";
          info = "As demand increases on the network, the black link will eventually reach capacity, and additional demand must be accommodated on additional links.";
          break;
        case 2:
          status = "Black Link Congests, Blue Link in Free Flow";
          info = "The black link remains congested and at a constant latency, while the blue link takes additional flux. After the blue link reaches capacity, both the black and blue links congest further and reach a higher latency.";
          break;
        case 3:
          status = "Network At Max Capacity";
          info = "Once the yellow link reaches its capacity, the network cannot any more demand. For certain latency relations, it is possible that the network reaches capacity without any demand entering the last link.";
          break;
        case 4:
          status = "Fully Congested";
          info = "While it is guaranteed the Nash equilibria exist with lower total latency, fully congested equilibria do exist for certain demands on all networks.";
      }
      $("#status").text(status);
      return $("#status-info").text(info);
    };
    $("#demo").click(clickDemo);
    $("#reset").click(clickReset);
    meterSVG = d3.select("#meter-section").append("svg").attr("id", "meter-svg").attr("width", wMeter).attr("height", hMeter).append("g").attr("transform", "translate({0},{1}) scale(1,-1)".format(0, hMeter));
    meterContainer = meterSVG.append("rect").attr("id", "meter-container").attr("width", wMeter).attr("height", hMeter);
    meter = meterSVG.append("rect").attr("id", "meter").attr("width", wMeter);
    resetMeter();
    networkSVG = d3.select("#network-section svg").attr("width", wNetwork).attr("height", hNetwork);
    sourceNode = networkSVG.append("circle").attr("id", "source-node").attr("class", "network-node").attr("cx", source[0]).attr("cy", source[1]).attr("r", source[2]);
    sinkNode = networkSVG.append("circle").attr("id", "sink-node").attr("class", "network-node").attr("cx", sink[0]).attr("cy", sink[1]).attr("r", sink[2]);
    plotSVG = d3.select("#plot-section").append("svg").attr("id", "plot-svg").attr("width", wPlot).attr("height", hPlot);
    axis = plotSVG.append("g").attr("transform", "translate({0},{1}) scale(1, -1) ".format(wPlot * .1, hPlot * .9));
    xAxis = axis.append("line").attr("class", "axis-line").attr("x1", 0).attr("y1", 0).attr("x2", axisLength * 1.3).attr("y2", 0);
    yAxis = axis.append("line").attr("class", "axis-line").attr("x1", 0).attr("y1", 0).attr("x2", 0).attr("y2", axisLength * 1.1);
    plotLine = d3.svg.line().x(function(p) {
      return p[0];
    }).y(function(p) {
      return p[1];
    });
    plots = axis.selectAll("path").data(arcData).enter().append("path").attr("class", 'plot-line').attr("d", function(d) {
      return plotLine(d['plot']);
    }).attr("stroke", function(d) {
      return d['fill'];
    });
    plotStates = axis.selectAll("circle").data(arcData).enter().append("circle").attr("class", 'plot-state').attr("r", stateRadius).attr("fill", function(d) {
      return d['fill'];
    }).attr("id", function(d) {
      return "plot-state-{0}".format(d['name']);
    }).each(function(d) {
      return d['plot-state'] = this;
    });
    arc = function(thickness) {
      return d3.svg.arc().innerRadius(function(r) {
        return r['r'] - thickness / 2;
      }).outerRadius(function(r) {
        return r['r'] + thickness / 2;
      }).startAngle(function(r) {
        return arcEndAngles(r['r'])[0];
      }).endAngle(function(r) {
        return arcEndAngles(r['r'])[1];
      });
    };
    arcs = networkSVG.selectAll("path").data(arcData).enter().append("path").attr("class", "arc").attr("transform", function(r) {
      return "translate(" + xArc + "," + yArc(r['r']) + ")";
    }).attr("id", function(r) {
      return '{0}-arc'.format(r['name']);
    }).each(function(d) {
      return d['arc'] = this;
    });
    networkSVG.selectAll("rect").data(arcData).enter().append("rect").attr("stroke", function(r) {
      return r['stroke'];
    });
    arcTween = function(data, t1, t2) {
      var _this = this;
      return function(a) {
        var next, prev;
        prev = arc(arcThickness * t1)(data);
        next = arc(arcThickness * t2)(data);
        return d3.interpolate(prev, next);
      };
    };
    return clickReset();
  };

  $(function() {
    return main();
  });

}).call(this);
