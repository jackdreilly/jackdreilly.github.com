# function(){
#
#     $('#first-test').focus(function(){
#

#       $('#old-class-button').click(function(){
#         $("#old-class-circles").show()
#       })
#     })

nashOff = 1
braessOff = 3
osXlink = 15 - braessOff
osOldClass = 19 - braessOff
osFD = 24 - braessOff
osNewLat = 30 - braessOff
osPS = 39 - braessOff - nashOff
osBNE = 52 - braessOff - nashOff
osRBNE = 60 - braessOff
fdVel = 24





lookup = {}
lookup[0]= 'init'
lookup[osXlink]= 'cross-link'
lookup[osOldClass]= 'old-class-1'
lookup[osOldClass+2]= 'old-class-2'
lookup[osFD]= 'fd-1'
lookup[osFD+2]= 'fd-2'
lookup[osNewLat]= 'new-lat'
lookup[osPS]= 'ps-1'
lookup[osPS+1]= 'ps-2'
lookup[osPS+2]= 'ps-3'
lookup[osPS+3]= 'ps-4'
lookup[osPS+4]= 'ps-5'
lookup[osPS+5]= 'ps-6'
lookup[osPS+6]= 'ps-7'
lookup[osPS+7]= 'ps-8'
lookup[osBNE]= 'bne-1'
lookup[osBNE+1]= 'bne-2'
lookup[osBNE+2]= 'bne-3'
lookup[osBNE+3]= 'bne-4'
lookup[osRBNE]= 'rbne-1'
lookup[osRBNE+1]= 'rbne-red'
lookup[osRBNE+2]= 'rbne-2'
lookup[osRBNE+3]= 'rbne-3'
lookup[osRBNE+4]= 'rbne-5'
lookup[fdVel] = 'fd-vel'


init = () ->
  $("#old-class-labels,
    #old-class-circles,
      #transition-1-fd,
      #transition-2-fd
      ").hide()
  $('#cross-link').hide()
  $('#flux-svg').hide()
  $('#xbar').hide()
  $('#algorithms').hide()
  $('#svg-fd-velocity').hide()



$ () ->
  init()
  ps = window.modes
  bne = window.bne
  rbne = window.rbne


  $(document).bind 'deck.change', (event, from, to) ->
    console.log to
    switch lookup[to]
      when 'old-class-1'
        $("#old-class-labels").show()
        $("#old-class-button").text('Show fluxes')
      when 'old-class-2'
        $("#old-class-circles").show()
      when 'cross-link'
        $("#cross-link").show()
      when 'fd-1'
        $('#transition-1-fd').show()
      when 'fd-2'
        $('#transition-2-fd').show()
      when 'new-lat'
        $('#density-svg').hide()
        $('#flux-svg').show()
      when 'ps-1'
        ps.firstPoint()
      when 'ps-2'
        ps.addDash()
      when 'ps-3'
        ps.putCongestedLink2()
      when 'ps-4'
        ps.moveCongestedLink2()
      when 'ps-5'
        ps.resetInBetween()
      when 'ps-6'
        ps.ff1()
      when 'ps-7'
        ps.ff2()
      when 'ps-8'
        ps.ff3()
      when 'bne-1'
        bne.start()
      when 'bne-2'
        bne.moveHor()
      when 'bne-3'
        bne.disappear()
      when 'bne-4'
        bne.moveHor2()
      when 'rbne-5'
        $('#bne-slide .svg').hide()
        $("#algorithms").show()
      when 'rbne-1'
        rbne.start()
      when 'rbne-2'
        rbne.showSecond()
      when 'rbne-3'
        rbne.move()
      when 'rbne-5'
        $('#bne-slide .svg').hide()
        $("#algorithms").show()
      when 'rbne-red'
        rbne.turnRed()
      when 'fd-vel'
        $('#svg-fd-velocity').show()







    # from going backwards
    if from > to
      switch lookup[from]
        when 'init'
          init()
        when 'old-class-1'
          $("#old-class-labels, #old-class-circles").hide()
        when 'old-class-2'
          $("#old-class-circles").hide()
        when 'fd-1'
          $('#transition-1-fd').hide()
        when 'fd-2'
          $('#transition-2-fd').hide()
        when 'cross-link'
          $('#cross-link').hide()
        when 'new-lat'
          $('#density-svg').show()
          $('#flux-svg').hide()
        when 'ps-1'
          ps.resetInBetween()
        when 'ps-2'
          ps.resetInBetween()
        when 'ps-3'
          ps.resetInBetween()
        when 'ps-4'
          ps.resetInBetween()
        when 'ps-5'
          ps.resetInBetween()
        when 'ps-6'
          ps.resetInBetween()
        when 'ps-7'
          ps.resetInBetween()
        when 'ps-8'
          ps.resetInBetween()
        when 'bne-1'
          bne.resetInBetween()
        when 'bne-2'
          bne.resetInBetween()
        when 'bne-3'
          bne.resetInBetween()
        when 'bne-4'
          bne.resetInBetween()
        when 'rbne-1'
          rbne.resetInBetween()
        when 'rbne-2'
          rbne.resetInBetween()
        when 'rbne-3'
          rbne.resetInBetween()
        when 'rbne-red'
          rbne.resetInBetween()
        when 'rbne-5'
          $('#bne-slide .svg').show()
          $("#algorithms").hide()
        when 'fd-vel'
          $('#svg-fd-velocity').hide()


    # from going forwards
    # if to > from
    #   switch lookup[from]
    #     else
    #       ''







