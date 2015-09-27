
images = []
sounds = []
initialize = (stagedata) ->

	loadImg = (filename)->
		result = new Image()
		result.src = filename
		return result

	
	images.hasami = loadImg "img/hasami.png"
	images.hasami_die = loadImg "img/hasami_die.png"
	images.cursor = loadImg "img/editor_cursor.png"
	images.startPoint = loadImg "img/editor_startpoint.png"

	images.floor = []
	images.floor.push(loadImg "img/floor_plain.png")
	images.floor.push(loadImg "img/floor_Ice.png")
	images.floor.push(loadImg "img/floor_net.png")
	images.floor.push(loadImg "img/floor_step.png")
	images.floor.push(loadImg "img/floor_arrow_left.png")
	images.floor.push(loadImg "img/floor_arrow_up.png")
	images.floor.push(loadImg "img/floor_arrow_right.png")
	images.floor.push(loadImg "img/floor_arrow_down.png")

	images.item = []
	images.item.push(loadImg "img/item_non.png")
	images.item.push(loadImg "img/item_block.png")
	images.item.push(loadImg "img/item_energy.png")
	images.item.push(loadImg "img/item_key.png")
	images.item.push(loadImg "img/item_gate.png")
	images.item.push(loadImg "img/item_goal.png")
	images.item.push(loadImg "img/item_damage.png")
	

	images.item_ghost = []
	images.item_ghost.push(loadImg "img/item_non_ghost.png")
	images.item_ghost.push(loadImg "img/item_block_ghost.png")
	images.item_ghost.push(loadImg "img/item_energy_ghost.png")
	images.item_ghost.push(loadImg "img/item_key_ghost.png")
	images.item_ghost.push(loadImg "img/item_gate_ghost.png")
	images.item_ghost.push(loadImg "img/item_goal_ghost.png")
	images.item_ghost.push(loadImg "img/item_damage_ghost.png")

	
	
	
	ext = (() ->
			audio = new Audio()
			if (audio.canPlayType("audio/mp3") == 'maybe') 
				"mp3"
			else if (audio.canPlayType("audio/wav") == 'maybe') 
				"wav"
			else
				"none"
			)()
	try
		sounds.effect = []
		sounds.effect.push new Audio('sounds/01Walk.' + ext)
		sounds.effect.push new Audio('sounds/02Dash.' + ext)
		sounds.effect.push new Audio('sounds/03Ice.' + ext)
		sounds.effect.push new Audio('sounds/04Charge.' + ext)
		sounds.effect.push new Audio('sounds/05Key.' + ext)
		sounds.effect.push new Audio('sounds/06Gate.' + ext)
		sounds.effect.push new Audio('sounds/07Miss.' + ext)
		sounds.effect.push new Audio('sounds/08Arrow.' + ext)
		sounds.music = []
		sounds.music.push new Audio('sounds/01.' + ext)
		sounds.music.push new Audio('sounds/02Clear.' + ext)
		sounds.music[0].loop = true
	catch error

	canvas = document.getElementById('canvassample');
	context = canvas.getContext('2d');

	connector = new TreeConnector()
	canvasMap = new CanvasMap(connector, context)
	game = new Game(connector.createChild())
	dao =[]
	dao.hydeTextArea = -> document.getElementById('stgdatatextarea').style.display = "none"
	dao.displayTextArea = -> document.getElementById('stgdatatextarea').style.display = "block"
	dao.getStageData = -> document.getElementById('stgdatatextarea').value

	soundvol = 1
	dao.switchMusicVolume = ->
		soundvol = 1 - soundvol
		changevolume =  (value) -> value.volume = soundvol
		map(sounds.effect, changevolume)

	musicvol = 1
	dao.switchSoundVolume = ->
		musicvol = 1 - musicvol
		changevolume =  (value) -> value.volume = musicvol
		map(sounds.music, changevolume)

	map = (arr ,func) ->
		for i in [0...arr.length]
			func(arr[i])

	setMenuModeControl(game, dao, connector)
	connector.addEvent("output stagedata", (str)->
		document.getElementById('stgdatatextarea').value = str
		)
	connector.addEvent("output stageurl", (str)->
		url = location.href.split('?')[0] + '?' + compressStageData(str)
		document.getElementById('stgdatatextarea').value = url
		)

	if(stagedata isnt '')
			dao.hydeTextArea()
			setPlayodeControl(game)
			menu.value = 1 if(menu.value is "")
			game.startGame(restoreStageData(stagedata)) 




class CanvasMap
	constructor : (connector, context) ->
		energydisp = document.getElementById('energydisp')
		draw = (img, pt) ->
			context.drawImage(img, Const.CellSize*pt.x, Const.CellSize*pt.y)

		drawPlayer = (player) ->
			index = getPlayerImageIndex(player)
			context.drawImage(images.hasami, index.x * Const.CellSize, index.y * Const.CellSize, Const.CellSize, Const.CellSize, 
				Const.CellSize*player.point.x, Const.CellSize*player.point.y, Const.CellSize, Const.CellSize)

		f_count = 0
		direction = 0
		getPlayerImageIndex  = (player) ->
			f_count++
			index = []
			if player.energy <= 0 and not player.clear
				index.y = 1
			else if player.clear
				index.y = 2
			else
				index.y = 0
			index.x = parseInt(f_count / 10 ) % 2
			if player.direction is Const.Direction.Right
				direction = 0
			if player.direction is Const.Direction.Left
				direction = 3
			index.y += direction

			return index

		play = (audio) ->
			try
				stop(audio)
				audio.play()
			catch error

		stop = (audio) ->
			try
				if not audio.ended
					audio.pause()
					audio.currentTime = 0
			catch error

		getItemImage = (cell) ->
			if cell.item.ghost
				images.item_ghost[cell.item.itemType]
			else
				images.item[cell.item.itemType]

		connector.addEvent("create cell", (cell) ->
			draw(images.floor[cell.floor.floorType], cell.point)
			draw(getItemImage(cell), cell.point)
			)
		connector.addEvent("update cell", (cell, startpoint) ->
			draw(images.floor[cell.floor.floorType], cell.point)
			draw(getItemImage(cell), cell.point)
			draw(images.startPoint, startpoint)
			draw(images.cursor, cell.point)
			)
		connector.addEvent("cursor move", (cellfrom, cellto, startpoint) ->
			draw(images.floor[cellfrom.floor.floorType], cellfrom.point)
			draw(getItemImage(cellfrom), cellfrom.point)
			draw(images.startPoint, startpoint)
			draw(images.cursor, cellto.point)
			)
		connector.addEvent("change startpoint", (cellfrom, cellto) ->
			draw(images.floor[cellfrom.floor.floorType], cellfrom.point)
			draw(getItemImage(cellfrom), cellfrom.point)
			draw(images.startPoint, cellto.point)
			draw(images.cursor, cellto.point)
			)

		connector.addEvent("set startpoint", (startpoint, energy) ->
			draw(images.startPoint, startpoint)
			energydisp.value = energy
			)

		connector.addEvent("player move", (cellfrom, cellto, player) ->
			draw(images.floor[cellfrom.floor.floorType], cellfrom.point)
			draw(getItemImage(cellfrom), cellfrom.point)
			drawPlayer(player)
			energydisp.value = player.energy
			)

		connector.addEvent("stage clear", () ->
			stop(sounds.music[Const.Sounds.Music.Stage])
			play(sounds.music[Const.Sounds.Music.Clear])
			)

		connector.addEvent("game over", (cell, player) ->
			draw(images.floor[cell.floor.floorType], cell.point)
			draw(getItemImage(cell), cell.point)
			drawPlayer(player)
			sounds.effect[Const.Sounds.Effect.Miss].play();
			)

		connector.addEvent("wait", (cell, player) ->
			draw(images.floor[cell.floor.floorType], cell.point)
			draw(getItemImage(cell), cell.point)
			drawPlayer(player)
			)

		connector.addEvent("player walk", () -> play(sounds.effect[Const.Sounds.Effect.Walk]))
		connector.addEvent("player dash", () -> play(sounds.effect[Const.Sounds.Effect.Dash]))
		connector.addEvent("player slip", () -> play(sounds.effect[Const.Sounds.Effect.Ice]))
		connector.addEvent("arrow", () -> play(sounds.effect[Const.Sounds.Effect.Arrow]))
		connector.addEvent("key", () -> play(sounds.effect[Const.Sounds.Effect.Key]))
		connector.addEvent("gate", () -> play(sounds.effect[Const.Sounds.Effect.Gate]))
		connector.addEvent("energy", () -> play(sounds.effect[Const.Sounds.Effect.Charge]))
		connector.addEvent("start stage", () -> play(sounds.music[Const.Sounds.Music.Stage]))

window.onload = -> 
    if ((navigator.userAgent.indexOf('iPhone') > 0 && navigator.userAgent.indexOf('iPad') == -1) || navigator.userAgent.indexOf('iPod') > 0 || navigator.userAgent.indexOf('Android') > 0)
        #タブレット用の操作方法を設定
    else 
        #ＰＣ用の操作方法を設定
    initialize(location.search.replace('?',''))


#storage = localStorage
#storage.setItem("gamedata", value)

