{exec} = require 'child_process'

jsDir = 'js/'
csDir = 'src/'
libDir = 'lib/'
indexPath = 'index.html'

runCommand = (cmd) ->
  exec cmd, (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr

build = () ->
  runCommand('coffee --compile --output ' + jsDir + ' ' + csDir)


open = () ->
  runCommand('open ' + indexPath)

clean = () ->
  runCommand('rm -rf ' + jsDir + '*')

task 'build', 'Build project from src/*.coffee to js/*.js', ->
  build()

task 'open', 'Open index.html in browser', ->
  open()

task 'bo', 'build then open', ->
  build()
  open()

task 'clean', 'clean lib files', ->
  clean()
