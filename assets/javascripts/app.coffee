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

jQuery(document).ready ($) ->
  $(".file").click (event) ->
    path = $(this).attr("href")
    event.preventDefault()
    $.ajax
      url: path
      success: (response) ->
        $("#content").empty()
        $('#arc').remove()
        $('span.info').remove()
        
        obj = response
        
        setHistory path
        
        # $.each obj.claims, (i, item) ->
          # claim = "<p id='claim_" + item.id + "' class='claim'><span class='index'>" + item.index + ".</span> <span class='claim_content'>" + item.node_value + "</span></p>"
        #   $("#content").append claim
        
        buildGraph obj

  
setHistory = (path) ->
  if path!=window.location
    window.history.pushState({path:path},'',path)

# all for graph bulding
buildGraph = (graph) ->
  # create svg image
  svg = d3.select("#content").append("svg").attr("id", "arc").attr("width", width).attr("height", height)
  # create plot area within svg image
  plot = svg.append("g").attr("id", "plot").attr("transform", "translate(" + pad + ", " + pad*25 + ")")
  
  linearLayout graph.claims
  arcLinks graph.claims,graph.claim_links,'grey','b','claims'
  
  $("#head").append "<span class='info name navbar-brand'>" + graph.name + "</span>"
  $("#head").append "<span class='info claims navbar-brand'>#Claims: " + graph.claims.length + "</span>"
  $("#head").append "<span class='info link_claims navbar-brand'>#Links: " + graph.claim_links.length + "</span>"
  
  if graph.links && graph.links.is_parentChem_of
    arcLinks graph.claims,graph.links.is_parentChem_of,'green','t','chems'
    $("#head").append "<span class='info link_chems navbar-brand' style='color:green'>#Chems: " + graph.links.is_parentChem_of.length + "</span>"
  if graph.links && graph.links.Coreference
    arcLinks graph.claims,graph.links.Coreference,'red','t','corefs'
    $("#head").append "<span class='info link_corefs navbar-brand' style='color:red'>#Coref: " + graph.links.Coreference.length + "</span>"
  
  drawNodes graph.claims
  writeClaims graph.claims
  

linearLayout = (nodes) ->
  # used to scale node index to x position
  xscale = d3.scale.linear().domain([
    0
    nodes.length - 1
  ]).range([
    radius
    width - margin - radius
  ])
  
  # calculate pixel location for each node
  nodes.forEach (d, i) ->
    d.x = xscale(i)
    d.y = yfixed + height / 3
    return
  
  return


arcLinks = (nodes,links,color,d,klass) ->
  links.forEach (d, i) ->
    d.source = (if isNaN(d.source) then d.source else (nodes.where id: d.source)[0])
    d.target = (if isNaN(d.target) then d.target else (nodes.where id: d.target)[0])
    return
  
  drawLinks links,color,d,klass
  return

drawNodes = (nodes) ->
  # used to assign nodes color by group
  color = d3.scale.category20()
  d3.select("#plot").selectAll(".node").data(nodes).enter().append("circle").attr("class", "node").attr("id", (d, i) ->
    d.id
  ).attr("name", (d, i) ->
    d.node_name
  ).attr("cx", (d, i) ->
    d.x
  ).attr("cy", (d, i) ->
    d.y
  ).attr("r", (d, i) ->
    radius
  ).style('cursor','pointer').style("fill", (d, i) ->
    color 1
  ).on("click", (d, i) ->
    # hideClaim d
    seeClaim d
    
    return
  ).on "mouseout", (d, i) ->
    d3.select("#tooltip_" + d.id).transition().duration(2300).delay(250).style('opacity',0).each "end", ->
      d3.select(this).remove()
      return
    return
  
  return

# Draws nice arcs for each link on plot
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
  d3.select("#plot").selectAll(link).data(links).enter().append("path").attr("class", "link").attr("transform", (d, i) ->
    xshift = d.source.x + (d.target.x - d.source.x) / 2
    # ToDo 2014-04-10: 
    yshift = yfixed + height / 3
    "translate(" + xshift + ", " + yshift + ")"
  ).style({'stroke-width': 2,'stroke':color}).on("mouseover", (d,i) ->
    d3.select(this).style({'stroke': 'black', 'stroke-width': 3, 'cursor':'pointer'}).transition().duration(2000).delay(100).each "end", ->
      d3.select(this).style({'stroke': color, 'stroke-width': 2})
  ).on("click", (d, i) ->
    addTooltipToLink d, klass
    d3.selectAll("#tooltip").transition().duration(2000).delay(100).attr("y", height / 10).each "end", ->
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
    addTooltip link.source, link.source_value
    addTooltip link.target, link.target_value
  else
    addTooltip link.source, link.source.node_name
    addTooltip link.target, link.target.node_name
  return

# helper functions
addTooltip = (circle,text) ->
  x = parseFloat(circle.x)
  y = parseFloat(circle.y)
  r = parseFloat(5)
  
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



writeClaims = (claims) ->
  $.each claims, (i, item) ->
    d3.select("#content").append("p")
      .attr("class","claim").attr("id", (d) ->
        "claim_" + item.id
      ).html( (d) ->
        "<span class='index'>" + item.index + ".</span> <span class='claim_content'>" + item.node_value + "</span>"
      ).insert("span").attr("class","closer").text("×").on "click", (d, i) ->
        hideClaim item
        return
    d3.selectAll(".claim").call d3.behavior.drag().on("drag", moveClaim)
    
seeClaim = (node,top) ->
  top = top
  top = '57px' unless top?
  
  d3.select("#claim_"+node.id)
    .transition()
    .duration(900)
    .delay(150)
    .style({'display':'inline','opacity':1,'z-index':1,'top':top,'curosr':'move'})
  

hideClaim = (node) ->
  d3.select("#claim_"+node.id).transition().duration(300).delay(50).style({'display':'none','opacity':0,'top':'0px','z-index':1})
  return


moveClaim = ->
  pos = $(this).offset()
  ypos = pos.top
  windowHeigth = $(document).height()
  eleHeigth = $(this).height()
  
  if d3.event.y + eleHeigth <= windowHeigth 
    $(this).css
      top: "+=" + (d3.event.y - pos.top) + "px"
  if d3.event.y - eleHeigth / 2 > windowHeigth
    $(this).css
      top: (d3.event.y - eleHeigth * 2) + "px"
  if d3.event.y <= 57
    $(this).css
      top: "57px"
  


# accessing an array element of objects by proerty value
# ary.where property: value
# returns all elements, for which query == true
Array::where = (query) ->
  return [] if typeof query isnt "object"
  hit = Object.keys(query).length
  @filter (item) ->
    match = 0
    for key, val of query
      match += 1 if item[key] is val
    if match is hit then true else false

