setPlayodeControl = (game) ->
	keyEventArray = []

	keyEventArray[13] = game.killPlayer
	keyEventArray[37] = game.movePlayerWalkLeft
	keyEventArray[38] = game.movePlayerWalkUp
	keyEventArray[39] = game.movePlayerWalkRight
	keyEventArray[40] = game.movePlayerWalkDown

	keyEventArray_withCtrl = []

	keyEventArray[13] = game.killPlayer
	keyEventArray_withCtrl[37] = game.movePlayerDashLeft
	keyEventArray_withCtrl[38] = game.movePlayerDashUp
	keyEventArray_withCtrl[39] = game.movePlayerDashRight
	keyEventArray_withCtrl[40] = game.movePlayerDashDown

	document.onkeydown = (e) ->
		e = window.event if typeof e is undefined or not e?
		if e.ctrlKey or e.shiftKey
			keyEventArray_withCtrl[e.keyCode]?()
		else
			keyEventArray[e.keyCode]?()
		e.returnValue = false

setEditModeControl = (game, dao) ->
	keyEventArray = []
	keyEventArray[32] = game.changeFloor
	keyEventArray[13] = game.changeItem
	keyEventArray[37] = game.moveCursorLeft
	keyEventArray[38] = game.moveCursorUp
	keyEventArray[39] = game.moveCursorRight
	keyEventArray[40] = game.moveCursorDown
	keyEventArray[71] = game.setGhost
	keyEventArray[76] = ->
		stageData = dao.getStageData()
		game.loadStageData(stageData)
	keyEventArray[79] = game.outputStageData
	keyEventArray[85] = game.outputStageUrl
	keyEventArray[80] = ->
		stageData = dao.getStageData()
		game.startGame(stageData)
		setPlayodeControl(game)
	keyEventArray[83] = game.changeStartPoint
	energydisp = document.getElementById('energydisp').onchange = -> 
		game.setPlayerEnergy(this.value)


	document.onkeydown = (e) ->
		e = window.event if typeof e is undefined or not e?
		keyEventArray[e.keyCode]?()

setMenuModeControl = (game, dao, connector) ->
	menu = document.getElementById('menu')
	setTimeout( (() ->
		game.update()
		setTimeout(arguments.callee, 50)), 50)
	connector.addEvent("already stage cleared", () ->
			menu.value++
			startGame()
		)
	document.getElementById('startbutton').onclick = -> startGame()

	startGame = ->
		if(menu.value is "edit")
			dao.displayTextArea()
			setEditModeControl(game, dao)
			game.startEdit()
		else
			dao.hydeTextArea()
			setPlayodeControl(game)
			menu.value = 1 if(menu.value is "")
			game.startGame(StageData[parseInt(menu.value)]) 

	document.getElementById('soundbutton').onclick = -> dao.switchSoundVolume()
	document.getElementById('musicbutton').onclick = -> dao.switchMusicVolume()
