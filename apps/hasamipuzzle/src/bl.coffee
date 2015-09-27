Const = 
	GameMode:
		Menu     : 0
		Play     : 1
		Edit     : 2

	GameState:
		Wait     : 0
		Moving   : 1
		Cleared  : 2
		GameOver_EnergyEmpty : 3
		GameOver_CannotMove  : 4
		GameOver_Suicide     : 5

	FloorTypeLength : 8
	FloorType:
		Plain      : 0
		Ice        : 1
		Net        : 2
		Step       : 3
		ArrowLeft  : 4
		ArrowUp    : 5
		ArrowRight : 6
		ArrowDown  : 7

	ItemTypeLength : 7
	ItemType:
		Non    : 0
		Block  : 1
		Energy : 2
		Key    : 3
		Gate   : 4
		Goal   : 5
		Damage : 6

	MoveType:
		Stop    : 0
		Walk    : 1
		Dash    : 2
		Slip    : 3
		Clear   : 4

	Direction:
		Left   : 0
		Up     : 1
		Right  : 2
		Down   : 3

	FieldSize:
		x : 15
		y : 10

	Sounds:
		Music:
			Stage : 0
			Clear : 1
		Effect:
			Walk   : 0
			Dash   : 1
			Ice    : 2
			Charge : 3
			Key    : 4
			Gate   : 5
			Miss   : 6
			Arrow  : 7

	CellSize : 32


class Point
	constructor : (x, y) ->
		@x = x
		@y = y

	move : (direction) ->
		@y-- if direction is Const.Direction.Up
		@x++ if direction is Const.Direction.Right
		@y++ if direction is Const.Direction.Down
		@x-- if direction is Const.Direction.Left
		@fixPoint()
		return @

	tryMove : (direction) ->
		x = @x
		y = @y
		y-- if direction is Const.Direction.Up
		x++ if direction is Const.Direction.Right
		y++ if direction is Const.Direction.Down
		x-- if direction is Const.Direction.Left
		return @checkRange(x, y)

	duplicate : -> new Point(@x, @y)

	fixPoint : ->
		@x = @fix(@x, 0, Const.FieldSize.x - 1)
		@y = @fix(@y, 0, Const.FieldSize.y - 1)

	checkRange : (x, y) ->
		0 <= x and x < Const.FieldSize.x and 0 <= y and y <Const.FieldSize.y


	fix : (value, min, max) ->
		if(value < min) 
			value = min
		if(value > max) 
			value = max
		return value

class Player
	constructor : (point, energy, direction, clear, connector) ->
		@point = point
		@energy = energy
		@direction = direction
		@keys = 0
		@moveType = Const.MoveType.Stop
		@clear = clear
		@connector = connector

	duplicate : -> new Player @point, @energy, @direction, @clear, @connector

	isStop : -> @moveType is Const.MoveType.Stop
	isMove : -> @moveType isnt Const.MoveType.Stop
	isWalk : -> @moveType is Const.MoveType.Walk
	isDash : -> @moveType is Const.MoveType.Dash
	isSlip : -> @moveType is Const.MoveType.Slip
	isClear: -> @moveType is Const.MoveType.Clear

	setMoveTypeStop : -> 
		@moveType = Const.MoveType.Stop
	setMoveTypeWalk : -> 
		@moveType = Const.MoveType.Walk
		@connector.notice "player walk"
	setMoveTypeDash : -> 
		@moveType = Const.MoveType.Dash
		@connector.notice "player dash"
	setMoveTypeSlip : -> 
		@moveType = Const.MoveType.Slip
		@connector.notice "player slip"
	setMoveTypeClear : -> 
		@moveType = Const.MoveType.Clear

	move : -> @point.move(@direction)

class Cell
	constructor : (floor, item, point) ->
		@floor = floor
		@item = item
		@point = point

	duplicate : -> new Cell(@floor.duplicate(), @item.duplicate(), @point.duplicate())

	playerTryOut : (player) ->
		@floor.playerTryOut player
		@item.playerTryOut player

	playerTryMove : (player) ->
		@floor.playerTryMove player
		@item.playerTryMove player

	playerOut : (player) ->
		@floor.playerOut player
		@item.playerOut player

	playerOn : (player) ->
		@floor.playerOn player
		@item.playerOn player

	playerStop : (player) ->
		@floor.playerStop player
		@item.playerStop player

	changeFloor : -> 
		floorType = @getNextValue(@floor.floorType, Const.FloorTypeLength)
		@floor = Floor.createFloor(floorType)

	changeItem : -> 
		itemType = @getNextValue(@item.itemType, Const.ItemTypeLength)
		@item = Item.createItem(itemType)

	getNextValue : (currentValue, length) -> (currentValue + 1) % length

class Floor
	constructor : (param) -> @param = param
	duplicate : -> Floor.createFloor(@floorType, @param)
	playerTryOut : (player) ->
	playerTryMove : (player) ->
	playerOut : (player) -> player.setMoveTypeStop() if player.isWalk() or player.isSlip() 
	playerOn : (player) ->
	playerStop : (player) ->
	@createFloor : (floorType) ->
		floorType = parseInt(floorType)
		result = do ->
			switch floorType
				when Const.FloorType.Plain then new Floor_Plain()
				when Const.FloorType.Ice then new Floor_Ice()
				when Const.FloorType.Net then new Floor_Net()
				when Const.FloorType.Step then new Floor_Step()
				when Const.FloorType.ArrowLeft then new Floor_Arrow Const.Direction.Left
				when Const.FloorType.ArrowUp then new Floor_Arrow Const.Direction.Up
				when Const.FloorType.ArrowRight then new Floor_Arrow Const.Direction.Right
				when Const.FloorType.ArrowDown then new Floor_Arrow Const.Direction.Down
				else new Floor_Plain()

		result.floorType = floorType
		return result

class Item
	constructor : (ghost) -> 
		@ghost = ghost
		@getted = false

	duplicate : -> Item.createItem(@itemType, @ghost)
	playerTryOut : (player) ->
	playerTryMove : (player) ->
	playerOut : (player) ->
		if @ghost
			@ghost = 0
	playerOn : (player) ->
	playerStop : (player) ->
	setGhost : -> @ghost = not @ghost
	getGhostValue : ->
		if @ghost
			1
		else
			0
	@createItem : (itemType, ghost) ->
		itemType = parseInt(itemType)
		result = do ->
			switch itemType
				when Const.ItemType.Non then new Item_Non(ghost)
				when Const.ItemType.Block then new Item_Block(ghost)
				when Const.ItemType.Energy then new Item_Energy(ghost)
				when Const.ItemType.Key then new Item_Key(ghost)
				when Const.ItemType.Gate then new Item_Gate(ghost)
				when Const.ItemType.Goal then new Item_Goal(ghost)
				when Const.ItemType.Damage then new Item_Damage(ghost)
				else new Item_Non(ghost)

		result.itemType = itemType
		return result

class Floor_Plain extends Floor

class Floor_Ice extends Floor
	playerOn : (player) ->
		player.setMoveTypeSlip() if player.isWalk() or player.isSlip() or player.isStop()

class Floor_Net extends Floor
	playerOn : (player) -> player.setMoveTypeStop()

class Floor_Step extends Floor
	playerTryMove : (player) -> 
		player.setMoveTypeStop() if player.isWalk() or player.isSlip()

class Floor_Arrow extends Floor
	playerTryOut : (player) -> 
		player.direction = @param
	playerOut : (player) ->
		player.connector.notice "arrow"
		super player



class Item_Non extends Item

class Item_Block extends Item
	playerTryMove : (player) -> 
		player.setMoveTypeStop() if not @ghost

class Item_Energy extends Item
	playerOn : (player) -> 
		if not @ghost and not @getted
			player.energy += 5 
			@itemType = Const.ItemType.Non
			@getted = true
			player.connector.notice "energy"

class Item_Key  extends Item
	playerOn : (player) -> 
		if not @ghost and not @getted
			player.keys++
			@itemType = Const.ItemType.Non
			@getted = true
			player.connector.notice "key"

class Item_Gate extends Item
	playerTryMove : (player) -> 
		if not @ghost and not @getted
			if player.keys <= 0
				player.setMoveTypeStop()
			else
				player.keys--
				@itemType = Const.ItemType.Non
				@getted = true
				player.connector.notice "gate"

class Item_Goal extends Item
	playerStop : (player) -> player.setMoveTypeClear() if not @ghost and not @getted

class Item_Damage extends Item
	playerOn : (player) -> 
		if not @ghost and not @getted
			player.energy-- 
			if player.energy <= 0
				player.setMoveTypeStop()


class Game
	constructor : (connector) ->
		@gameState = Const.GameState.Wait
		@connector = connector

		@startGame = (stageData) ->
			@stageData = stageData
			@gameMode = Const.GameMode.Play
			@gameState = Const.GameState.Wait
			@stage = new Stage(stageData ,connector.createChild())
			@connector.notice "start stage"

		@retry = (stageData) ->
			@stageData = stageData
			@gameMode = Const.GameMode.Play
			@gameState = Const.GameState.Wait
			@stage = new Stage(stageData ,connector.createChild())

		@startEdit = ->
			@gameMode = Const.GameMode.Edit
			@editor = new Editor(connector.createChild())

		isMenu = => @gameMode is Const.GameMode.Menu
		isPlay = => @gameMode is Const.GameMode.Play
		isEdit = => @gameMode is Const.GameMode.Edit

		@movePlayerWalkLeft = => @stage.movePlayerWalk(Const.Direction.Left) if @checkPlayModeInputState()
		@movePlayerWalkUp = => @stage.movePlayerWalk(Const.Direction.Up) if @checkPlayModeInputState()
		@movePlayerWalkRight = => @stage.movePlayerWalk(Const.Direction.Right) if @checkPlayModeInputState()
		@movePlayerWalkDown = =>  @stage.movePlayerWalk(Const.Direction.Down) if @checkPlayModeInputState()
		@movePlayerDashLeft = => @stage.movePlayerDash(Const.Direction.Left)if @checkPlayModeInputState()
		@movePlayerDashUp = => @stage.movePlayerDash(Const.Direction.Up)if @checkPlayModeInputState()
		@movePlayerDashRight = => @stage.movePlayerDash(Const.Direction.Right)if @checkPlayModeInputState()
		@movePlayerDashDown = => @stage.movePlayerDash(Const.Direction.Down)if @checkPlayModeInputState()
		@killPlayer = => @stage.killPlayer()
		@checkPlayModeInputState = => 
			if @gameState is Const.GameState.Cleared
				@connector.notice "already stage cleared"
				return false
			if not isPlay()
				return false
			if @gameState is Const.GameState.GameOver_EnergyEmpty and @stageData?
				@retry(@stageData)
				return false
			if @gameState is Const.GameState.Wait
				@gameState = Const.GameState.Moving
				return true
			return false
		@update = => 
			if isPlay() and @gameState is Const.GameState.Moving
				@stage.update()
			else if isPlay()
				connector.notice "wait", @stage.getCurrentCell().duplicate(), @stage.field.player.duplicate()

		@changeFloor = => @editor.changeFloor() if isEdit()
		@changeItem = => @editor.changeItem() if isEdit()
		@moveCursorLeft = => @editor.moveCursor(Const.Direction.Left) if isEdit()
		@moveCursorUp = => @editor.moveCursor(Const.Direction.Up) if isEdit()
		@moveCursorRight = => @editor.moveCursor(Const.Direction.Right) if isEdit()
		@moveCursorDown = => @editor.moveCursor(Const.Direction.Down) if isEdit()
		@outputStageData = => @editor.outputStageData() if isEdit()
		@outputStageUrl = => @editor.outputStageUrl() if isEdit()
		@loadStageData = (stageData) => @editor.loadStageData(stageData) if isEdit()
		@changeStartPoint = => @editor.changeStartPoint() if isEdit()
		@setGhost = => @editor.setGhost() if isEdit()
		@setPlayerEnergy = (energy) => @editor.setPlayerEnergy(energy) if isEdit()

		@connector.addEvent("stage clear", () => @gameState = Const.GameState.Cleared)
		@connector.addEvent("game over", () => @gameState = Const.GameState.GameOver_EnergyEmpty)
		@connector.addEvent("player stop", () => 
			@gameState = Const.GameState.Wait if @gameState isnt Const.GameState.Cleared)

	loadStage : (stageNo) -> 
		player = new Player()

class Editor
	constructor : (connector) ->
		@connector = connector
		@field = new Field(connector.createChild())
		cursor = new Point(0,0)
		@changeItem = -> @field.changeItem(cursor.duplicate())
		@changeFloor = -> @field.changeFloor(cursor.duplicate())

		@changeStartPoint = -> @field.changeStartPoint(cursor.duplicate())
		@moveCursor = (direction) -> 
			pt1 = cursor.duplicate()
			@field.getCell(cursor.move(direction))
			pt2 = cursor.duplicate()
			@noticeCursorMove(@field.getCell(pt1), @field.getCell(pt2))

		@outputStageData = ->
			stageData = @field.toString()
			@connector.notice "output stagedata", stageData

		@outputStageUrl = ->
			stageData = @field.toString()
			@connector.notice "output stageurl", stageData

		@loadStageData = (stageData) ->
			@field.loadStageData stageData
			@noticeCursorMove(@field.getCell(cursor).duplicate(), @field.getCell(cursor).duplicate())

		@setGhost = -> @field.setGhost(cursor.duplicate())

		@setPlayerEnergy = (energy) -> 
			energy = parseInt(energy)
			energy = 0 if energy is NaN
			@field.player.energy = energy

		@noticeCursorMove = (cellfrom, cellto) -> 
			@connector.notice("cursor move", cellfrom, cellto, @field.player.point.duplicate())

		@noticeCursorMove(@field.getCell(cursor).duplicate(), @field.getCell(cursor).duplicate())
		
class Field
	constructor : (connector) ->
		@connector = connector
		connector.notice "create field", 10, 14
		@player = new Player(new Point(0, 0), 15, Const.Direction.Right, false, connector.createChild())
		@map = []
		for i in [0...Const.FieldSize.x]
			@map[i] = []
			for j in [0...Const.FieldSize.y]
				floor = Floor.createFloor(Const.FloorType.Plain)
				item = Item.createItem(Const.ItemType.Non)
				pt = new Point(i, j)
				@map[i][j] = new Cell(floor, item, pt, connector.createChild())
				@connector.notice "create cell", @map[i][j].duplicate()
		return

	changeFloor : (pt) -> 
		@getCell(pt).changeFloor()
		@connector.notice("update cell", @getCell(pt).duplicate(), @player.point.duplicate())

	changeItem : (pt) -> 
		@getCell(pt).changeItem()
		@connector.notice("update cell", @getCell(pt).duplicate(), @player.point.duplicate())

	changeStartPoint : (pt) ->
		@connector.notice "change startpoint", @getCell(@player.point).duplicate(), @getCell(pt).duplicate()
		@player.point = pt.duplicate()

	setGhost : (pt) ->
		@getCell(pt).item.setGhost()
		@connector.notice("update cell", @getCell(pt).duplicate(), @player.point.duplicate())

	getCell : (pt) -> @map[pt.x][pt.y]
	toString : ->
		floorStr = ""
		itemStr = ""
		for x in [0...Const.FieldSize.x]
			for y in [0...Const.FieldSize.y]
				floorStr += @map[x][y].floor.floorType + ","
				itemStr += @map[x][y].item.itemType + ":" + @map[x][y].item.getGhostValue() + ","
			floorStr = floorStr.slice(0,-1)
			itemStr = itemStr.slice(0,-1)
			floorStr += ";"
			itemStr += ";"
		floorStr = floorStr.slice(0,-1)
		itemStr = itemStr.slice(0,-1)
		startPointStr = @player.point.x + "," + @player.point.y + "," + @player.energy
		return floorStr + "\n" + itemStr + "\n" + startPointStr

	loadStageData : (stageData) ->
		arr = stageData.split(/\r\n|\r|\n/)
		floorColumnData = arr[0].split(";")
		itemColumnData = arr[1].split(";")
		floorMap = []
		itemMap = []
		for x in [0...Const.FieldSize.x]
			floorMap[x] = floorColumnData[x].split(",")
			itemMap[x] = itemColumnData[x].split(",")
			for y in [0...Const.FieldSize.y]
				floor = Floor.createFloor(floorMap[x][y])
				itemInfo = itemMap[x][y].split(":")
				item = Item.createItem(itemInfo[0], parseInt(itemInfo[1]))
				pt = new Point(x, y)
				@map[x][y] = new Cell(floor, item, pt, @connector.createChild())
				@connector.notice "create cell", @map[x][y].duplicate()
		startPointData = arr[2].split(",")
		@player.point = new Point(startPointData[0], startPointData[1])
		@player.energy = parseInt(startPointData[2])
		@connector.notice "set startpoint", @player.point.duplicate(), @player.energy
		return
	
class Menu
	constructor : (connector) ->
		@cursor = 0
		@connector = connector

class Stage
	constructor : (stageData, connector) ->
		@field = new Field(connector.createChild())
		@field.loadStageData(stageData)
		@connector = connector
		@connector.notice("player move", 
			@getCurrentCell(@field.player.point).duplicate(), 
			@getCurrentCell(@field.player.point).duplicate(),
			@field.player.duplicate())
		@initialize = -> @field.loadStageData(stageData)

	getCell : (pt) -> @field.getCell(pt)

	getCurrentCell : -> @getCell(@field.player.point)

	getNextCell : -> 
		pt = @field.player.point.duplicate().move(@field.player.direction)
		return @getCell(pt)

	movePlayerWalk : (direction) -> 
		@field.player.setMoveTypeWalk()
		@movePlayerCommon(direction)

	movePlayerDash : (direction) -> 
		@field.player.setMoveTypeDash()
		@movePlayerCommon(direction)

	movePlayerCommon : (direction) ->
		@movePlayerRepeat(direction)

	movePlayerRepeat : (direction) ->
		@firstCheckMovable(direction)
		if (@field.player.isMove())
			@update()
		else 
			@connector.notice "player fail move"
			@connector.notice "player stop"

	playerMoveEnd : ->
		@getCurrentCell().playerStop(@field.player)
		@field.player.energy-- 	
		if @field.player.isClear()
			@field.player.clear = true
			@connector.notice "stage clear"
		else if @field.player.energy <= 0
			@connector.notice "game over", @getCell(@field.player.point).duplicate(), @field.player.duplicate()
			return
		@connector.notice "player stop"
		return

	update : ->
		if (not @field.player.isMove())
			cell = @getCurrentCell().duplicate()
			@playerMoveEnd()
			@connector.notice("player move", cell, cell, @field.player.duplicate())
			return
		pt = @field.player.point.duplicate()
		@movePlayer() 
		cellfrom = @getCell(pt).duplicate()
		cellto = @getCurrentCell().duplicate()
		
		if @field.player.isStop()
			@playerMoveEnd()
		@connector.notice("player move", cellfrom, cellto, @field.player.duplicate())
		@checkMovable()
		

	killPlayer : -> 
		@field.player.energy = 0
		@connector.notice "game over", @getCell(@field.player.point).duplicate(), @field.player.duplicate()

	movePlayer : ->
		@getCurrentCell().playerOut(@field.player)
		@field.player.move()
		@getCurrentCell().playerOn(@field.player)
		return

	firstCheckMovable : (direction) ->
		@field.player.direction = direction
		@checkMovable() 
		return	

	checkMovable : ->
		@getCurrentCell().playerTryOut(@field.player)
		if @field.player.point.tryMove(@field.player.direction)
			@getNextCell().playerTryMove(@field.player)
		else
			@field.player.setMoveTypeStop()
		return @field.player.isMove()

