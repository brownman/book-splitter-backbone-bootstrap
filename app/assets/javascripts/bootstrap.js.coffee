jQuery ->
  #$("a[rel=popover]").popover()
  #$(".tooltip").tooltip()
  #$("a[rel=tooltip]").tooltip()
  $('.accordion-group').collapse({
   toggle: true 
  })
  console.log('start')

  #fn.do_ping: () =>
    #alert('ping')
