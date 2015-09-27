
class Process
	constructor : (stepNum) ->
		@steps = []
		processNum = 0
		@steps = ( () ->
				steps = []
				for i in [0...stepNum]
					steps[i] = 0
				return steps
			)()

		@setNextProcess = (ngStepNum) ->
			for i in [ngStepNum+1...stepNum]
				@steps[i] = 0
			@inclimentSteps(ngStepNum)
			#console.log @steps
			#alert @steps
			return

		@modifyProcess = (movefailStepNum) ->
			for i in [movefailStepNum+1...stepNum]
				@steps[i] = 0
			if @steps[movefailStepNum] < 7
				@inclimentSteps(movefailStepNum)
				#console.log "modify" + @steps
				return true
			return false

		@ng = false

		@inclimentSteps = (stepNum) ->
			@steps[stepNum]++
			if(@steps[stepNum] >= 8)
				@steps[stepNum] = 0
				if stepNum > 0
					@inclimentSteps(stepNum-1)
				else
					@ng = true

trySteps = (stepNum) ->
	process = new Process(stepNum)
	connector = new TreeConnector()
	game = new Game(connector)

	command = []

	command.push game.movePlayerWalkLeft
	command.push game.movePlayerWalkUp
	command.push game.movePlayerWalkRight
	command.push game.movePlayerWalkDown

	command.push game.movePlayerDashLeft
	command.push game.movePlayerDashUp
	command.push game.movePlayerDashRight
	command.push game.movePlayerDashDown

	commandName = []
	commandName.push "←"
	commandName.push "↑"
	commandName.push "→"
	commandName.push "↓"
	commandName.push "C←"
	commandName.push "C↑"
	commandName.push "C→"
	commandName.push "C↓"

	moving = false
	clear = false
	gameover = false
	movefail = false
	arrow = false;
	connector.addEvent("wait", () -> moving = false)
	connector.addEvent("stage clear", () -> 
		clear = true
		moving = false
		)
	connector.addEvent("game over", () -> 
		gameover = true
		moving = false
		#console.log "game over"
		)
	connector.addEvent("player fail move", () ->
		movefail = true
		moving = false
		#console.log "player fail move"
		)

	tryProcess = (steps) ->
		game.startGame(StageData[17])
		moving = false
		clear = false
		gameover = false
		movefail = false
		index = 0

		i = 0
		while i < stepNum
			moving = true
			movefail = false
			index = i
			command[steps[i]]()
			while moving
				game.update()
			if movefail
				if not process.modifyProcess(index)
					break
			else if gameover or clear
				break
			else
				i++
		result = new Object()
		result.clear = clear
		result.index = index
		return result

	while true
		result = tryProcess(process.steps)
		if result.clear
			break
		process.setNextProcess(result.index)
		if process.ng
			break

	if clear
		console.log "solved!"
		len = process.steps.length
		answer = []
		for i in [0...len]
			answer.push commandName[process.steps[i]]
		console.log answer
		return true
	else
		console.log "・・・・・・・・・"
		return false
for i in [1...100]
	if trySteps(i)
		break