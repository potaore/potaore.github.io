class TreeConnector
	constructor : (parent) ->
		events = []
		@owner
		@addEvent = (eventName,func) -> 
			events[eventName] = func

		@notice = (eventName) ->
			events[eventName]?.apply(null,[].slice.call(arguments, 1, arguments.length))
			parent?.notice.apply(parent, [].slice.call(arguments, 0, arguments.length))
			return

		@createChild = -> new TreeConnector @
