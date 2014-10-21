pieData = [
  {
    label: "SETTLEMENTS"
    value: 0
  }
  {
    label: "JURY VERDICTS"
    value: 0
  }
]

lineData = [
  key: "Case"
  values: [
  ]
]

$(document).ready ->
  $("#btnFilterReset").click ->
    $.ajax
      url: "/insights/filter_cases"
      method: "get"
      data: {}
      success: (response) ->
        console.log response

        tData = []
        total_count = response.length

        response.forEach (c, i) ->
          # bar Data
          if c.resolution.resolution_type is "settlement"
            pieData[0].value += 1
          else
            pieData[1].value += 1

          # line Data
          tData.push { value: parseFloat(c.resolution.resolution_amount), state: c.state, total: 1 }

        # rearrange line Data
        linq = Enumerable.From(tData)
        gData = linq.GroupBy((v) ->
          v.value
        ).Select((v) ->
          value: v.Key()
          total: v.Sum((t) ->
            t.total | 0
          )
        ).ToArray()
        line_result = gData.sort((a, b) ->
          a.value - b.value
        )
        console.log line_result

        lineData[0].values.push([0, 0])
        line_result.forEach (c, i) ->
          lineData[0].values.push([c.value, parseFloat(c.total / total_count * 100)]);

        console.log lineData
        renderChart()

      error: ->
        console.log "Something failed"

renderChart = ->
  colors = d3.scale.category20()
  keyColor = (d, i) ->
    colors d.key

  nv.addGraph ->
    chart_line = nv.models.stackedAreaChart().margin(right: 100).x((d) ->
      d[0]
    ).y((d) ->
      d[1]
    ).useInteractiveGuideline(true).rightAlignYAxis(false).transitionDuration(500).showControls(false).clipEdge(true)
    
    #Format x-axis labels with custom function.
    #chart_line.xAxis.tickFormat (d) ->
    #  d3.time.format("%x") new Date(d)
    chart_line.xAxis.tickFormat d3.format(",.2f")

    chart_line.yAxis.tickFormat d3.format(",.2f")
    d3.select("#stackedArea_chart svg").datum(lineData).call chart_line
    nv.utils.windowResize chart_line.update
    chart_line

  nv.addGraph ->
    chart_pie = nv.models.pieChart().x((d) -> #Configure how big you want the donut hole size to be.
      d.label
    ).y((d) ->
      d.value
    ).showLabels(true).labelThreshold(.05).labelType("percent").donut(true).donutRatio(0.35)
    d3.select("#pie_chart svg").datum(pieData).transition().duration(350).call chart_pie
    chart_pie

  map = new Datamap(
    element: document.getElementById("map_chart")
    scope: "usa"
  )