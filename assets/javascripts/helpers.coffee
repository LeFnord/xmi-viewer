# enable touch events
foo = $(".navbar-toggle")
foo.enableTouch()

foo.on "tap", (e) ->
  $('.navbar-collapse').collapse 'toggle'
  return

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

