# author LeFnord
# email  pscholz.le@gmail.com
# date   2014-05-27

# input validation
$("#file-form").validate
  rules:
    collection:
      minlength: 2
      required: true

  highlight: (element) ->
    $(element).closest(".controls").removeClass("success").addClass "error"
    return

  success: (element) ->
    element.text("OK!").closest(".controls").removeClass "error"
    return


$(".collection").on "click", (event) ->
  path = $(this).attr("href")
  event.preventDefault()
  $.ajax
    url: path
    success: (response) ->
      $("ul#files").replaceWith response
      $("span.list-name").replaceWith path
      $("#FileList").parent().animate(
        "borderColor": "rgba(249,249,249, 1)"
        "background-color": "rgba(13, 110, 161, 0.23)"
      , 1234
      ).animate
        "border-color": "rgba(213, 213, 213, 0.0)"
        "background-color": "rgba(213, 213, 213, 0.0)"
      , 1234
    complete: ->
      $(".file").on "click", (event) ->
        path = $(this).attr("href")
        # could be found in visuals, building the graph
        getClaimData path
  return