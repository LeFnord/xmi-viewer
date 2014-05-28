# author LeFnord
# email  pscholz.le@gmail.com
# date   2014-05-27

# input validation
$("#file-form").validate
  rules:
    collection:
      minlength: 3
      required: true
    "uploads[]":
      required: true

  highlight: (element) ->
    $(element).closest(".controls").removeClass("success").addClass "error"
    return
  success: (element) ->
    element.text("OK!").closest(".controls").removeClass "error"
    return
  submitHandler: (form) ->
    form.submit()
    return


$(".collection").on "click", (event) ->
  path = $(this).attr("href")
  event.preventDefault()
  $.ajax
    url: path
    success: (response) ->
      $("ul#files").replaceWith response
      animateSuccess path
    complete: ->
      handleComplete path
  return

$(".delete-collection").on "click", (event) ->
  parent = $(this).parent()
  element_to_delete = parent.children("a.collection")[0]
  collection_to_delete = $(element_to_delete).attr('href')
  $.ajax
    url: 'collection'
    type: 'DELETE'
    data: {collection: collection_to_delete}
    success: (response) ->
      $(parent).fadeOut 'slow', ->
        $("ul#files").replaceWith response
        handleComplete parent
        animateSuccess 'patents'
        $(this).remove
  return

animateSuccess = (path) ->
  $("span.list-name").replaceWith "<span class='list-name'>" + path + "</span>"
  $("#FileList").parent().animate(
    "borderColor": "rgba(249,249,249, 1)"
    "background-color": "rgba(13, 110, 161, 0.23)"
  , 1234
  ).animate
    "border-color": "rgba(213, 213, 213, 0.0)"
    "background-color": "rgba(213, 213, 213, 0.0)"
  , 1234
  return

handleComplete = (path) ->
  $(".file").on "click", (event) ->
    path = $(this).attr("href")
    # could be found in visuals, building the graph
    getClaimData path
  return
  
