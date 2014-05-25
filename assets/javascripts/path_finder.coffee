# author LeFnord
# email  pscholz.le@gmail.com
# date   2014-05-24

path_input = document.getElementById('path');
if path_input?
  $('#path').on 'keypress', (event) ->
    if event.which == 13
      $.ajax
        url: '/dir'
        data: {'q': this.value},
        success: (response) ->
          console.log response
    else
      $.ajax
        url: '/path'
        data: {'q': this.value},
        success: (response) ->
          console.log response

  