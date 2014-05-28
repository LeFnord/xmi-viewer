# author LeFnord
# email  pscholz.le@gmail.com
# date   2013-08-28
# ==============================================================================
# application specifiic code

width = 960
height = 1000
margin = 10
pad = margin / 2
radius = 7
yfixed = pad + radius
color = d3.scale.category20()
colors = [
  [
    'rgb(228,26,28)'
    'rgba(228,26,28,0.66)'
    'rgba(228,26,28,0.13)'
  ]
  [
    'rgb(55,126,184)'
    'rgba(55,126,184,0.66)'
    'rgba(55,126,184,0.13)'
  ]
  [
    'rgb(77,175,74)'
    'rgba(77,175,74,0.66)'
    'rgba(77,175,74,0.13)'
  ]
  [
    'rgb(152,78,163)'
    'rgba(152,78,163,0.66)'
    'rgba(152,78,163,0.13)'
  ]
  [
    'rgb(255,127,0)'
    'rgba(255,127,0,0.66)'
    'rgba(255,127,0,0.13)'
  ]
  [
    'rgb(215,225,51)'
    'rgba(215,225,51,0.66)'
    'rgba(215,225,51,0.13)'
  ]
  [
    'rgb(166,86,40)'
    'rgba(166,86,40,0.66)'
    'rgba(166,86,40,0.13)'
  ]
  [
    'rgb(247,129,191)'
    'rgba(247,129,191,0.66)'
    'rgba(247,129,191,0.13)'
  ]
  [
    'rgb(153,153,153)'
    'rgba(153,153,153,0.66)'
    'rgba(153,153,153,0.13)'
  ]
]

# ToDo 2014-05-28: refactor!!!

$(".file").on "click", (event) ->
  path = $(this).attr("href")
  console.log path
  getClaimData path

@getClaimData = (path) ->
  event.preventDefault()
  
  $.ajax
    url: path
    success: (response) ->
      $("#content").empty()
      $('#arc').remove()
      $(".info").remove()
      $(".info-list").remove()
      
      buildGraph response
      $(".info-list").on "click", (event) ->
        makeLinksActive this
  return
  

makeLinksActive = (reference) ->
  hrefValue = $(reference).attr("href")
  if hrefValue
    cssColor = $(reference).css 'color'
    klass = hrefValue.substring(1,hrefValue.length)
    
    if $(reference).hasClass 'inactive-link'
      $(reference).removeClass 'inactive-link'
      $("path." + klass).show()
      newBGColor = cssColor.replace(/\)/,',0.13)').replace(/rgb/,'rgba')
      newBorderColor = cssColor.replace(/\)/,',0.9)').replace(/rgb/,'rgba')
      $("tspan ." + klass).css({'background-color': newBGColor,'border-color':newBorderColor})
    else
      $(reference).addClass 'inactive-link'
      $("path." + klass).hide()
      newBGColor = cssColor.replace(/\)/,',0.0)').replace(/rgb/,'rgba')
      newBorderColor = cssColor.replace(/\)/,',0.23)').replace(/rgb/,'rgba')
      $("tspan ." + klass).css({'background-color': newBGColor,'border-color':newBorderColor})
    return


# all for graph bulding
buildGraph = (graph) ->
  
  width = $(window).width() - $(window).width() / 13;
  height = $(window).height() * 1.7;
  
  writeClaims graph.nodes
  
  svg = d3.select("#content").append("svg").attr("id", "arc").attr("width", width).attr("height", height)
  plot = svg.append("g").attr("id", "plot").attr("transform", "translate(" + 0 + ", " + pad * 25 + ")")
  
  height += 150
  
  linearLayout graph.nodes
  arcLinks graph.nodes,graph.node_links,'grey','b','claims'
  
  $("#head").append "<span class='navbar-text info name'>" + graph.name + "</span>"
  $("#head").append "<span class='navbar-text info claims'>#Claims: " + graph.nodes.length + "</span>"
  $("#head").append "<span class='navbar-text info link_claims'>#Links: " + graph.node_links.length + "</span>"
  
  list_index = 0
  for k,v of graph.links
    act_color = colors[list_index]
    list_index += 1
    arcLinks graph.nodes,v,act_color[1],'t',k
    $("#legend").append "<li role='presentation'><a role='menuitem' tabindex='-1' href='#" + k + "' class='info-list' style='cursor:pointer;color:" + act_color[0] + "'><i class='fa fa-link'/> #" + k + ": " + v.length + "</a></li>"
    
  drawNodes graph.nodes
  
  list_index = 0
  for k,v of graph.links
    act_color = colors[list_index]
    list_index += 1
    color_named_entities k, act_color[1], act_color[2]
    draw_line_between_nes k, v

linearLayout = (nodes) ->
  xscale = d3.scale.linear().domain([
    0
    nodes.length - 1
  ]).range([
    radius * 2
    width - margin - radius * 2
  ])
  nodes.forEach (d, i) ->
    d.x = xscale(i)
    d.y = yfixed + height / 3
    return
  return

drawNodes = (nodes) ->
  d3.select("#plot").selectAll(".node").data(nodes).enter().append("circle").attr("class", "node").attr("id", (d, i) ->
    "node_" + d.id
  ).attr("name", (d, i) ->
    d.name
  ).attr("cx", (d, i) ->
    d.x
  ).attr("cy", (d, i) ->
    d.y
  ).attr("r", (d, i) ->
    radius
  ).style('cursor','pointer').style("fill", (d, i) ->
    color 7
  ).on "click", (d, i) ->
    # hideClaim d
    seeClaim d
    d3.select(this).transition()
      .duration(450)
      .delay(50)
      .attr("r",15)
    addTooltip d, d.index, 'node-index'
    return
  return

arcLinks = (nodes,links,color,d,klass) ->
  links.forEach (d, i) ->
    d.source = (if isNaN(d.source) then d.source else (nodes.where id: d.source)[0])
    d.target = (if isNaN(d.target) then d.target else (nodes.where id: d.target)[0])
    return
  
  drawLinks links,color,d,klass
  return

drawLinks = (links,color,d,klass) ->
  # scale to generate radians (just for lower-half of circle)
  if d == 't'
    radians = d3.scale.linear().range([
      -Math.PI / 2
      Math.PI / 2
    ])
  else
    radians = d3.scale.linear().range([
      Math.PI / 2
      3 * Math.PI / 2
    ])
  
  arc = d3.svg.line.radial().interpolate("monotone").tension(1).angle((d) ->
    radians d
  )
  
  link = "link "+d
  d3.select("#plot").selectAll(link).data(links).enter().append("path").attr("class", "link " + klass).attr("transform", (d, i) ->
    xshift = d.source.x + (d.target.x - d.source.x) / 2
    # ToDo 2014-04-10: 
    yshift = yfixed + height / 3
    "translate(" + xshift + ", " + yshift + ")"
  ).style({'stroke-width': 2,'stroke':color}).on("mouseover", (d,i) ->
    d3.select(this).style({'stroke': 'black', 'stroke-width': 3, 'cursor':'pointer'}).transition().duration(2000).delay(100).each "end", ->
      d3.select(this).style({'stroke': color, 'stroke-width': 2})
  ).on("click", (d, i) ->
    addTooltipToLink d, klass
    d3.selectAll("#tooltip").transition().duration(2000).delay(100).attr("y", "57px").each "end", ->
      d3.select(this).transition().duration(2000).delay(100).style('opacity',0).each "end", ->
        d3.select(this).remove()
        return
    return
  ).attr "d", (d, i) ->
    xdist = Math.abs(d.source.x - d.target.x)
    arc.radius xdist / 2
    points = d3.range(0, Math.ceil(xdist / 3))
    radians.domain [
      0
      points.length - 1
    ]
    arc points
    
  return

# add tooltips
addTooltipToLink = (link, klass) ->
  unless klass is 'claims'
    # addTooltip link.source_relatum, link.source_relatum.content
    # addTooltip link.target_relatum, link.target_relatum.content
  else
    addTooltip link.source, link.source.name
    addTooltip link.target, link.target.name
  return

addTooltip = (circle,text,klass) ->
  x = parseFloat(circle.x)
  y = parseFloat(circle.y)
  r = parseFloat(5)
  
  if klass?
    tooltip = d3.select("#plot").append("text").text(text).attr("x", x).attr("y", y).attr("dy", r * 1.2).attr("class", klass).attr("id","node_index_" + circle.index)
  else
    tooltip = d3.select("#plot").append("text").text(text).attr("x", x).attr("y", y).attr("dy", -r * 2).attr("id", "tooltip")
  offset = tooltip.node().getBBox().width / 2
  if (x - offset) < 0
    tooltip.attr "text-anchor", "start"
    tooltip.attr "dx", -r
  else if (x + offset) > (width - margin)
    tooltip.attr "text-anchor", "end"
    tooltip.attr "dx", r
  else
    tooltip.attr "text-anchor", "middle"
    tooltip.attr "dx", 0
    
  return

# claims (node texts)
writeClaims = (claims) ->
  claims.forEach (item, i) ->
    d3.select("#content").append("tspan")
      .attr("class","claim").attr("id", (d) ->
        "claim_" + item.id
      ).html( (d) ->
        "<span class='index'>" + item.index + ".</span> <span class='claim_content'>" + item.content + "</span>"
      ).insert("span").attr("class","closer").style('text-color','rgba(76, 76, 76,0.5)').text("×").on "click", (d, i) ->
        hideClaim item
        return
    d3.selectAll(".claim").call d3.behavior.drag().on("drag", moveClaim)
  return

seeClaim = (node,top) ->
  top = top
  top = '57px' unless top?
  
  d3.select("#claim_"+node.id)
    .transition()
    .duration(250)
    .delay(50)
    .style({'display':'inline','opacity':1,'top':'57px'})
  # ToDo 2014-04-14: DRY it up
  $(".claim").css
    zIndex: 0
  $("#claim_"+node.id).css
    zIndex: 3
  return

hideClaim = (node) ->
  d3.select("#claim_"+node.id).transition().duration(450).delay(50).style({'display':'none','opacity':0})
  d3.select("#node_"+node.id).transition()
    .duration(450)
    .delay(50)
    .attr("r",radius)
  d3.select("#node_index_" + node.index).transition()
    .style({"opacity":0})
    .duration(400)
    .delay(50)
    .remove()
  return

moveClaim = ->
  pos = $(this).offset()
  ypos = pos.top
  windowHeigth = $(document).height()
  eleHeigth = $(this).height()
  
  $(".claim").css
    zIndex: 0
  $(this).css
    zIndex: 3
  
  if d3.event.y + eleHeigth <= windowHeigth 
    $(this).css
      top: "+=" + (d3.event.y - pos.top) + "px"
  if d3.event.y - eleHeigth / 2 > windowHeigth
    $(this).css
      top: (d3.event.y - eleHeigth * 2) + "px"
  if d3.event.y <= 57
    $(this).css
      top: "57px"
  return

# relevant to named entities
color_named_entities = (klass,lColor,color) ->
  unless klass == 'claims'
    $("tspan." + klass).css({'background-color': color, 'border':'2px solid '+lColor})
    # $("tspan." + klass).css({'background-color': color})


draw_line_between_nes = (klass,links) ->
  # console.log klass
  # console.log links


