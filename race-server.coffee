class window.WSActor
  constructor: (@url, @onopen)->
    @handlersStack = []

  run: (handlers)->
    @become handlers
    @ws = new WebSocket(@url);

    @ws.onopen = @onopen if @onopen?

    @ws.onmessage = (event) =>
      console.log "OnMessage", event
      return if @handlersStack.length == 0

      _.find @handlersStack[0], (handler, regexStr)=>
        #console.log regexStr, event.data, event.data.match(new RegExp("^" + regexStr + "$"))
        if m = event.data.match(new RegExp("^" + regexStr + "$"))
          m[0] = event
          handler.apply null, m
          return true
        return false

    @ws.onclose = (event) => console.log "closed", event
    @ws.onerror = (event) => console.log "error", event

  become: (newHandlers) -> @handlersStack.unshift(newHandlers)
  unbecome: () -> @handlersStack.shift()

  send: (msg, newHandlers) ->
    @become newHandlers if newHandlers?
    @ws.send(msg)

class window.RaceServerActor extends window.WSActor
  constructor: (config)->
    @player = config.player
    super "ws://paper.local:8066/race", => @send "IDENTIFY #{@player.name}"
    @run
      "IDENTIFIED" : =>
        config.onReady(this)

