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
