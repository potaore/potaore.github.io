'use strict'
$get = (self) -> (cont) ->
	cont(self)
	self
$if = (obj) -> (cont) -> cont(obj) if obj isnt null and obj isnt undefined

gConst =
	"screen" :
		"width"  : 400
		"height" : 400
	"interval" : 16

window.onload = ->
	game = createGame(
		"gapi"       : createGraphicApi(document.getElementById("putishooCanvas"))
		"keyWatcher" : createKeyWatcher([
			{ "keyCode"  : 38 , "name" : "up" }
			{ "keyCode"  : 40 , "name" : "down" }
			{ "keyCode"  : 37 , "name" : "left" }
			{ "keyCode"  : 39 , "name" : "right" }
			{ "keyCode"  : 90 , "name" : "shoot1" }
			{ "keyCode"  : 88 , "name" : "shoot2" }
			{ "keyCode"  : 90 , "name" : "ok" }
		]))
	createLoop(
		"interval"  : gConst.interval
		"predicate" : -> 
			game.updater.update()
			game.drawer.draw())()

createLoop = (arg) ->
	resultLoop = () -> 
		t1 = (new Date()).getTime()
		arg.predicate()
		t2 = (new Date()).getTime()
		waitTime = arg.interval - (t2 - t1)
		setTimeout(resultLoop, waitTime)


createGraphicApi = (canvas) ->
	images = []
	_(["player", "bullet1", "bullet2", "enemy1", "enemy2", "enemy3", "enemy4", "enemy5", "boss", "enemybullet", "chain1", "chain2", "bullet2stock"]).each(
		(id) -> images[id] = $get(new Image())((img) -> img.src = "images/#{id}.png"))

	canvas.width  = gConst.screen.width
	canvas.height = gConst.screen.height
	ctx = canvas.getContext("2d")
	self = {}

	effects = []
	self.clear         = -> 
		ctx.fillStyle = "rgb(10,10,30)"
		ctx.strokeStyle = "rgb(140, 200, 220)"
		ctx.lineWidth = 2
		ctx.clearRect(0, 0, canvas.width, canvas.height)
		ctx.fillRect(0, 0, canvas.width, canvas.height)
		ctx.rect(0, 0, canvas.width, canvas.height)

	self.drawTitle     = (info) ->
		ctx.lineWidth = 3
		ctx.strokeStyle = "rgb(140, 240, 220)"
		ctx.font = "italic bold 48px 'Arial'"
		ctx.textAlign = 'center'
		ctx.strokeText("putishoo", gConst.screen.width / 2, gConst.screen.height * 3 / 7)

		ctx.lineWidth = 1
		ctx.fillStyle = "rgb(140, 240, 220)"
		ctx.font = "italic 16px 'Arial'"
		ctx.textAlign = 'center'
		ctx.fillText("press z to start", gConst.screen.width / 2, gConst.screen.height * 3 / 4)
		ctx.fillText("hi score : #{info.hiScore}      last score : #{info.lastScore} ", gConst.screen.width / 2, gConst.screen.height - 10)


	self.drawInfo     = (info)     -> 
		ctx.textAlign = 'left'
		ctx.font = "italic bold 14px 'Arial'"
		ctx.fillStyle = "rgb(150,220,220)"
		ctx.lineWidth = 1
		ctx.fillText("level : #{info.level}", 20, 20)
		ctx.fillText("score : #{info.score}", 120, 20)
		ctx.fillText("time  : #{info.time}" , 220, 20)
	self.drawCharacter = (ch) -> $if(images[ch.type2])((img) -> ctx.drawImage(img, ch.pt.x - img.width / 2, ch.pt.y - img.height / 2))

	self.drawChainCount = (chainCount) ->
		_(5).times((n) -> 
			$if(images[if n >= chainCount then "chain1" else "chain2"])((img) -> ctx.drawImage(img, getChainCountX(n) - img.width / 2, getChainCountY(n) - img.height / 2)))
	self.drawBullet2Stock = (count) ->
		_(count).times((n) -> $if(images["bullet2stock"])((img) -> ctx.drawImage(img, getBullet2StockX(n) - img.width / 2, getBullet2StockY(n) - img.height / 2)))
	self.resetEffects = -> effects = []
	self.createEffects = (info) ->
		if info.type is "score"
			effect =
				"pt" : 
					"x"  : info.pt.x
					"y"  : info.pt.y
				"dy"     : 4
				"time"   : 20
				"score"  : info.score
				"draw"   : ->
					effect.dy -= 0.2
					effect.pt.y -= effect.dy
					if effect.time % 3 isnt 0
						ctx.fillStyle = "rgb(240, 240, 100)"
						ctx.font = "italic 16px 'Arial'"
						ctx.textAlign = 'center' 
						ctx.fillText("#{effect.score}", effect.pt.x, effect.pt.y) 
			effects.push(effect)
		else if info.type is "playerDying"
			effect =
				"pt" : 
					"x"  : info.pt.x
					"y"  : info.pt.y
				"ve" : info.ve
				"time"   : 180
				"draw"   : ->
					ctx.lineWidth = 2
					ctx.strokeStyle = "rgb(30, 140, 250)"
					ctx.beginPath()
					ctx.arc(effect.pt.x, effect.pt.y, 10 + _.random(-3, 3), 0, Math.PI*2, false)
					ctx.stroke()
			effects.push(effect)
		else if info.type is "enemyDying"
			effect =
				"pt" : 
					"x"  : info.pt.x
					"y"  : info.pt.y
				"ve" : info.ve
				"time"   : 25
				"draw"   : ->
					if effect.time % 3 isnt 0
						ctx.lineWidth = 2
						ctx.strokeStyle = "rgb(250, 200, 100)"
						ctx.beginPath()
						ctx.arc(effect.pt.x, effect.pt.y, 1 + _.random(0, 3), 0, Math.PI*2, false)
						ctx.stroke()
			effects.push(effect)
		else if info.type is "bossDying"
			effect =
				"pt" : 
					"x"  : info.pt.x
					"y"  : info.pt.y
				"ve" : info.ve
				"time"   : 600
				"draw"   : ->
					ctx.lineWidth = 2
					ctx.strokeStyle = "rgb(250, 200, 100)"
					ctx.beginPath()
					ctx.arc(effect.pt.x, effect.pt.y, 15 + _.random(-6, 6), 0, Math.PI*2, false)
					ctx.stroke()
			effects.push(effect)
		else if info.type is "gameClear"
			effect =
				"time"   : 400
				"draw"   : ->
					ctx.strokeStyle = "rgb(140, 240, 220)"
					ctx.font = "italic 18px 'Arial'"
					ctx.textAlign = 'center' 
					ctx.fillText("Congraturations!", gConst.screen.width / 2, gConst.screen.height * 3 / 7) 
					ctx.fillText("Game is cleared!", gConst.screen.width / 2, gConst.screen.height * 3 / 7 + 25) 
					ctx.fillText("Try to get higher score nex time!", gConst.screen.width / 2, gConst.screen.height * 3 / 7 + 50) 
			effects.push(effect)

	self.createChainScoreEffects = (chainCount, bonus) ->
		_(chainCount).times((n) ->
			self.createEffects(
				"type"  : "score"
				"pt" :
					"x" :getChainCountX(n)
					"y" :getChainCountY(n)
				"score" : bonus
			))
	self.createBullet2StockScoreEffects = (stockCount, bonus) ->
		_(stockCount).times((n) ->
			self.createEffects(
				"type"  : "score"
				"pt" :
					"x" :getBullet2StockX(n)
					"y" :getBullet2StockY(n)
				"score" : bonus
			))
	self.createPlayerDyingEffect = (pt) ->
		_(32).times((n)->
			direction = _.random(0, 120) * Math.PI / 60
			speed     = 0.5 + _.random(0, 10) * 0.1
			self.createEffects(
				"type"  : "playerDying"
				"pt"    : pt
				"ve" :
					"x" : speed * Math.cos(direction)
					"y" : speed * Math.sin(direction)
		))
	self.createEnemyDyingEffect = (pt) ->
		_(5).times((n)->
			direction = _.random(0, 120) * Math.PI / 60
			speed     = 0.5 + _.random(0, 10) * 0.1
			self.createEffects(
				"type"  : "enemyDying"
				"pt"    : pt
				"ve" :
					"x" : speed * Math.cos(direction)
					"y" : speed * Math.sin(direction)
		))
	self.createBossDyingEffect = (pt) ->
		_(96).times((n)->
			direction = _.random(0, 120) * Math.PI / 60
			speed     = 0.5 + _.random(0, 20) * 0.1
			self.createEffects(
				"type"  : "bossDying"
				"pt"    : pt
				"ve" :
					"x" : speed * Math.cos(direction)
					"y" : speed * Math.sin(direction)
		))

	self.drawEffects = () ->
		effects = effects.filter((effect) -> effect.time > 0)
		_(effects).each((effect) ->
			effect.time--
			if effect.pt and effect.ve
				effect.pt.x += effect.ve.x
				effect.pt.y += effect.ve.y
			effect.draw())
	getChainCountX   = (n) -> 50 + n * 25
	getChainCountY   = (n) -> gConst.screen.height - 15
	getBullet2StockX = (n) -> 250 + n * 25
	getBullet2StockY = (n) -> gConst.screen.height - 15
	self


createKeyWatcher = (keydefs) ->
	keyStates = (() ->
		_keyStates = {}
		_.each(keydefs, (keydef) -> 
			_keyStates[keydef.name] = { "name" : keydef.name, "keyCode" :keydef.keyCode , "pressed" : false, "pressedNow" : false, "pressedUpdate" : false, "update" : false })
		return _keyStates)()

	document.onkeydown = (e) -> 
		e = window.event if (!e)
		e.preventDefault()
		_(_(keydefs).filter((ks) -> ks.keyCode is e.keyCode)).each((ks) -> 
			[keyStates[ks.name].update, keyStates[ks.name].pressedUpdate] = [true, true] )

	document.onkeyup = (e) ->
		e = window.event if (!e)
		_(_(keydefs).filter((ks) -> ks.keyCode is e.keyCode)).each((ks) -> [keyStates[ks.name].update, keyStates[ks.name].pressedUpdate] = [true, false])

	updateKeyStates = ->
		_(keyStates).each(
			(ks) -> 
				ks.pressedNow = (not ks.pressed) and ks.update and ks.pressedUpdate
				ks.pressed = ks.pressedUpdate if ks.update
				ks.update = false )
		keyStates

	"updateKeyStates" : updateKeyStates
	"getKeyStates"    : -> keyStates




createGame = (ui) ->
	hittestGroups = (gp1, gp2, cont) ->
		_.each(gp1, (ch1) -> _.each(gp2, (ch2) -> 
			cont(ch1, ch2) if hittest(ch1, ch2)))
	hittest = (ch1, ch2) -> Math.pow(ch1.pt.x - ch2.pt.x, 2) + Math.pow(ch1.pt.y - ch2.pt.y, 2) < Math.pow(ch1.size, 2) + Math.pow(ch2.size, 2)
	getPlayingInit = ->
		score      : 0
		level      : 1
		time       : 0
		characters : 
			events          : []
			players         : []
			playersBulletes : []
			enemies         : []
			enemiesBulletes : []
		chainCount   : 0
		bullet2Stock : 0
	everyCharactersGroup = _(["events", "players", "enemies", "playersBulletes", "enemiesBulletes"])
	hittestCharacterGroupsTuples = _([["players", "enemies"], ["players", "enemiesBulletes"], ["enemies", "playersBulletes"]])
	drawingCharacterGroups = _(["players", "enemies", "playersBulletes", "enemiesBulletes"])

	self =
		params :
			schene       : "title"
			hiScore      : 0
			lastScore    : 0
		playing : getPlayingInit()

		updater :
			startGame : ->
				self.params.schene = "playing"
				self.playing = getPlayingInit()
				ui.gapi.resetEffects()
				self.updater.addCharacter(self.factory.createGameStartEvent())

			endGame : ->
				self.params.lastScore = self.playing.score
				self.params.hiScore = if self.params.hiScore < self.playing.score then self.playing.score else self.params.hiScore
				self.params.schene = "title"
				self.playing = getPlayingInit()
			addCharacter : (ch) -> 
				self.playing.characters[ch.type]?.push(ch)
				ch
			update : () ->
				self.playing.time++
				keyStates = ui.keyWatcher.updateKeyStates()
				if self.params.schene is "title"
					self.updater.startGame() if keyStates["ok"].pressedNow
				else if self.params.schene is "playing"
					everyCharactersGroup.each(
						(gp) -> self.playing.characters[gp] = _(self.playing.characters[gp]).filter((ch) -> ch.living))
					hittestCharacterGroupsTuples.each(
						(def) -> hittestGroups(self.playing.characters[def[0]], self.playing.characters[def[1]], 
							(ch1, ch2) -> 
								ch1.hitted(ch1, ch2)
								ch2.hitted(ch2, ch1)
							))
					everyCharactersGroup.each(
						(gp) -> _(self.playing.characters[gp]).each((ch) -> ch.action?(ch, {"keyStates" : keyStates})))
		drawer :
			draw : () ->
				if self.params.schene is "title"
					ui.gapi.clear() 
					ui.gapi.drawTitle(self.params) 
				else if self.params.schene is "playing"
					ui.gapi.clear() 
					drawingCharacterGroups.each((gp) -> _(self.playing.characters[gp]).each(ui.gapi.drawCharacter))
					ui.gapi.drawInfo(self.playing)
					ui.gapi.drawChainCount(self.playing.chainCount)
					ui.gapi.drawBullet2Stock(self.playing.bullet2Stock)
					ui.gapi.drawEffects()


		factory :
			createCharacterBase : (info) ->
				chSelf = 
					life   : if info?.life?   then info.life   else 1
					attack : if info?.attack? then info.attack else 1
					size   : if info?.size?   then info.size   else 1
					type   : if info?.type?   then info.type   else ""
					type2  : if info?.type2?  then info.type2  else ""
					time   : if info?.time?   then info.time   else 0
					score  : if info?.score?  then info.score  else 0
					pt :
						x : if info?.pt?.x? then info.pt.x else 0
						y : if info?.pt?.y? then info.pt.y else 0
					ve :
						x : if info?.ve?.x? then info.ve.x else 0
						y : if info?.ve?.y? then info.ve.y else 0
					living : true
					dyingEvent : (me, ch) -> info?.dyingEvent?(me, ch)
					action : (ch, command) ->
						ch.time++
						ch.pt.x += ch.ve.x
						ch.pt.y += ch.ve.y
						info?.action?(ch, command)
						ch.living = false if ch.pt.y < -150 or ch.pt.y > gConst.screen.height + 150 
						
					hitted : (me, ch) ->
						info?.hitted?(me, ch)
						chSelf.life -= ch.attack
						if chSelf.life <= 0 and chSelf.living
							chSelf.living = false
							chSelf.dyingEvent?(me, ch)

			createGameStartEvent : ->
				self.factory.createCharacterBase({
					"type"   : "events"
					"type2"  : "GameStartEvent"
					"action" : (me) ->
						self.updater.addCharacter(self.factory.createPlayer({ "pt" : { "x" : gConst.screen.width  / 2, "y" : gConst.screen.height - 70}}))
						self.updater.addCharacter(self.factory.createEnemyCreateEvent())
						me.living = false
					})

			createEnemyCreateEvent : ->
				createEnemy = (info) -> $get(self.factory.createCharacterBase(info))((enemy)->enemy.dyingEvent = (me) -> ui.gapi.createEnemyDyingEffect(me.pt))
				createBullet = (info) ->
					self.updater.addCharacter(self.factory.createCharacterBase(
						"pt"     : info.pt
						"ve"     : info.ve
						"type"   : "enemiesBulletes"
						"type2"  : "enemybullet"
						"size"   : 5
						"life"   : 1
						"attack" : 1
						"score"  : 0
						"action" : info.action
					))
				createEnemy1 = (speed, pt) ->
					self.updater.addCharacter(createEnemy(
						"pt"     : if pt? then pt else { "x" : _.random(30, gConst.screen.width), "y" : -30 } 
						"ve"     : { "x" : 0                                , "y" : speed } 
						"type"   : "enemies"
						"type2"  : "enemy1"
						"size"   : 10
						"life"   : 1
						"attack" : 1
						"score"  : 1
						"action" : (me) ->
						"hitted" : (ch) -> 
					))
				createEnemy2 = ()->
					self.updater.addCharacter(createEnemy(
						"pt"     : { "x" : _.random(30, gConst.screen.width), "y" : - 70 } 
						"ve"     : { "x" : 0                                , "y" : 2   }
						"type"   : "enemies"
						"type2"  : "enemy2"
						"size"   : 15
						"life"   : 1
						"attack" : 1
						"score"  : 10
						"action" : (me) -> 
							me.ve.y -= 0.015
							if me.time is 200
								_([{ "x": 0 , "y" : 2 }, { "x" : 1 , "y" : 1.7 }, { "x" : -1 , "y" : 1.7 }]).each((ve) ->
									createBullet(
										"pt"     : { "x" : me.pt.x, "y" : me.pt.y } 
										"ve"     : ve
									)
								)

						"hitted" : (ch) -> 
					))
				createEnemy3 = (speed, pt, a) ->
					self.updater.addCharacter(createEnemy(
						"pt"     : if pt? then pt else { "x" : _.random(30, gConst.screen.width), "y" : -30 } 
						"ve"     :                     { "x" : 0                                , "y" : speed } 
						"type"   : "enemies"
						"type2"  : "enemy3"
						"size"   : 10
						"life"   : 1
						"attack" : 1
						"score"  : 1
						"action" : (me) -> me.ve.y += a if a
						"hitted" : (ch) -> 
					))
				createEnemy3Many = (speed, count, a) ->
					startX = _.random(30, gConst.screen.width)
					self.updater.addCharacter(createEnemy(
						"type"  : "events"
						"type2" : "CreateEnemy1ManyEvent"
						"action" : (ch) ->
							if ch.time % 10 is 0
								count--
								createEnemy3(speed, { "x" : startX, "y" : -30 }, a)
							ch.living = false if count <= 0
						))
				createEnemy4 = (speed, pt) ->
					enemy = self.updater.addCharacter(createEnemy(
						"pt"     : if pt? then pt else { "x" : _.random(30, gConst.screen.width), "y" : -30 } 
						"ve"     : 					   { "x" : 0                                , "y" : speed } 
						"type"   : "enemies"
						"type2"  : "enemy4"
						"size"   : 10
						"life"   : 1
						"attack" : 1
						"score"  : 10
						"action" : (me) -> 
						"hitted" : (me, ch) -> 
							_([{ "x": 0 , "y" : 2 }, { "x" : 1 , "y" : 1.7 }, { "x" : -1 , "y" : 1.7 }]).each((ve) ->
								createBullet(
									"pt"     : { "x" : me.pt.x, "y" : me.pt.y } 
									"ve"     : ve
								)
							)
					))

				createEnemy5 = (speed, pt) ->
					enemy = self.updater.addCharacter(createEnemy(
						"pt"     : if pt? then pt else { "x" : _.random(30, gConst.screen.width), "y" : -30 } 
						"ve"     : 					   { "x" : 0                                , "y" : speed } 
						"type"   : "enemies"
						"type2"  : "enemy5"
						"size"   : 10
						"life"   : 3
						"attack" : 1
						"score"  : 2
						"action" : (me) ->
						"hitted" : (me, ch) ->
							me.ve.y /= 1.3
					))

				createBoss = () ->
					nextAction = cAction = cMove = () ->
					cDirection = 1
					cTime = 0
					setNextAction = ->
						if cTime > 350
							cTime = 0
							cAction = bossActions.wait
							nextAction = _.sample([bossActions.attack1, bossActions.attack2, bossActions.attack3])

					bossActions = 
						arrival  : (me) ->
							if me.pt.y > 100
								me.ve.y = 0
								me.ve.x = 0.8
								cAction = _.sample([bossActions.attack1, bossActions.attack2, bossActions.attack3])
								cMove   = bossActions.move1
						move1   : (me) ->
							me.ve.x = 0.8  if me.ve.x is 0 or me.pt.x < 100
							me.ve.x = -0.8 if me.pt.x > gConst.screen.width - 100
							cTime++
							cDirection += 0.018
							setNextAction()

						attack1 : (me) ->
							if cTime % 30 < 22
								_([0, Math.PI/2, Math.PI, 3*Math.PI/2]).each((addDir) -> createBullet(
									"pt" : me.pt
									"ve" : 
										"x" : Math.cos(cDirection + addDir) * 6
										"y" : Math.sin(cDirection + addDir) * 6
									)
								)

						attack2 : (me) ->
							if cTime % 30 is 0 
								_([0, Math.PI/2, Math.PI, 3*Math.PI/2]).each((addDir) -> 
									_(13).times((n)->
											ve = 
												"x" : Math.cos(cDirection + addDir + n*0.03) * 3
												"y" : Math.sin(cDirection + addDir + n*0.03) * 3
											createBullet(
												"pt" : me.pt
												"ve" : 
													"x" : ve.x
													"y" : ve.y
												"action" : (me) ->
													me.ve.x = ve.x * (1 - ( 1 - Math.cos(me.time*0.06)) / 2 )
													me.ve.y = ve.y * (1 - ( 1 - Math.cos(me.time*0.06)) / 2 )
											)
									)
								)
						attack3 : (me) ->
							if cTime % 30 is 0 
								_([0, Math.PI/2, Math.PI, 3*Math.PI/2]).each((addDir) -> 
									_(17).times((n)->
											ve = 
												"x" : Math.cos(cDirection + addDir + n*0.03) * 2
												"y" : Math.sin(cDirection + addDir + n*0.03) * 2
											createBullet(
												"pt" : me.pt
												"ve" : 
													"x" : ve.x
													"y" : ve.y
												"action" : (me) -> me.ve.y += 0.04
										)
									)
								)
						wait   : (me) ->
							if cTime > 200
								cTime = 0
								cAction = nextAction

					cAction = bossActions.arrival
					enemy = self.updater.addCharacter(self.factory.createCharacterBase(
						"pt"         : if pt? then pt else { "x" : gConst.screen.width / 2, "y" : -64 } 
						"ve"         : 					   { "x" : 0  , "y" : 1 } 
						"type"       : "enemies"
						"type2"      : "boss"
						"size"       : 64
						"life"       : 100
						"attack"     : 2
						"score"      : 2
						"action"     : (me) ->
							cAction(me)
							cMove(me)
						"hitted"     : (me, ch) ->
						"dyingEvent" : (me, ch) -> 
							self.playing.score += 100
							ui.gapi.createEffects({"type":"score", "pt":me.pt, "score":200})
							ui.gapi.createBossDyingEffect(me.pt)
							self.updater.addCharacter(self.factory.createCharacterBase({
								"type"     : "events"
								"type2"    : "EndClearEvent"
								"action"   : (chSelf) -> 
									ui.gapi.createEffects("type":"gameClear") if chSelf.time is 60
									self.updater.endGame() if chSelf.time is 420
							}))
					))

				self.factory.createCharacterBase(
					"type"  : "events"
					"type2" : "EnemyCreateEvent"
					"action" : (ch) ->
						self.playing.level = (() ->
							level = 1 + parseInt(self.playing.time / 800) 
							level = 15 if level > 15
							level)()
						
						if self.playing.level is 1
							createEnemy1(1.5) if ch.time % 90 is 0
						if self.playing.level is 2
							createEnemy2() if ch.time % 120 is 10
							createEnemy1(1.5) if ch.time % 90 is 0
						if self.playing.level is 3
							createEnemy2() if ch.time % 120 is 10
							createEnemy3Many(0, 6, 0.025) if ch.time % 180 is 15
						if self.playing.level is 4
							createEnemy2() if ch.time % 180 is 10
							createEnemy3Many(0, 6, 0.025) if ch.time % 160 is 15
							createEnemy1(1.7) if ch.time % 40 is 0
						if self.playing.level is 5
							createEnemy1(1.5) if ch.time % 90 is 0
							createEnemy4(1) if ch.time % 90 is 40
						if self.playing.level is 6
							createEnemy2() if ch.time % 45 is 30
							createEnemy5(2.5) if ch.time % 90 is 0
						if self.playing.level is 7
							createEnemy3Many(0, 6, 0.025) if ch.time % 180 is 15
							createEnemy4(1.1) if ch.time % 30 is 10
						if self.playing.level is 8
							createEnemy1(2.5) if ch.time % 20 is 0
						if self.playing.level is 9
							createEnemy2() if ch.time % 50 is 10
							createEnemy4(1.2) if ch.time % 40 is 10
							createEnemy5(2.5) if ch.time % 90 is 0
						if self.playing.level is 10
							createEnemy1(2.5) if ch.time % 20 is 0
							createEnemy2() if ch.time % 80 is 10
							createEnemy3Many(0, 12, 0.025) if ch.time % 180 is 15
							createEnemy5(2.5) if ch.time % 120 is 0
						if self.playing.level is 11
							createEnemy4(1.2) if ch.time % 120 is 10
							createEnemy2() if ch.time % 15 is 5
						if self.playing.level is 12
							createEnemy3Many(0, 3, 0.025) if ch.time % 40 is 15
							createEnemy5(3.5) if ch.time % 20 is 0
						if self.playing.level is 13
							createEnemy1(3.5) if ch.time % 10 is 0
							createEnemy4(0.8) if ch.time % 40 is 10
							createEnemy4(3.8) if ch.time % 40 is 10
						if self.playing.level is 14
							createEnemy1(2.5) if ch.time % 20 is 0
							createEnemy2() if ch.time % 80 is 10
							createEnemy3Many(0, 8, 0.025) if ch.time % 180 is 15
							createEnemy4(1.2) if ch.time % 40 is 10
						if self.playing.level is 15
							if ch.time % 1000 is 240
								createBoss()
								ch.living = false
				)

			createPlayer : (info) ->
				info.type  = "players"
				info.type2 = "player"
				info.hitted = () -> 
				info.action = (_self, _command) ->
					speed = 5
					speed = 3.5 if _(["up", "down", "left", "right"]).filter((dir) -> _command.keyStates[dir].pressed).length >=2
					_self.pt.y -= speed if _command.keyStates["up"   ].pressed and _self.pt.y > 0
					_self.pt.y += speed if _command.keyStates["down" ].pressed and _self.pt.y < gConst.screen.width
					_self.pt.x -= speed if _command.keyStates["left" ].pressed and _self.pt.x > 0
					_self.pt.x += speed if _command.keyStates["right"].pressed and _self.pt.x < gConst.screen.height


					if _command.keyStates["shoot1"].pressedNow
						self.updater.addCharacter(self.factory.createCharacterBase({ 
							"pt"     : { "x" : _self.pt.x, "y" : _self.pt.y} 
							"ve"     : { "x" : 0         , "y" : -10       } 
							"type"   : "playersBulletes"
							"type2"  : "bullet1"
							"size"   : 25
							"life"   : 1
							"attack" : 1
							"action" : (me) -> 
								if me.time >= 8 and me.living
									self.playing.chainCount = 0 
									me.living = false
							"hitted" : (me, ch) -> 
								player.addScore(ch, 1)
								countUpChain() if me.living
							}))

					if _command.keyStates["shoot2"].pressedNow and self.playing.bullet2Stock > 0
						self.playing.bullet2Stock--
						self.updater.addCharacter(self.factory.createCharacterBase({ 
							"pt"     : { "x" : _self.pt.x, "y" : _self.pt.y}
							"ve"     : { "x" : 0         , "y" : -15       } 
							"type"   : "playersBulletes"
							"type2"  : "bullet2"
							"size"   : 35
							"life"   : 30
							"attack" : 1
							"action" : (me) -> 
								if me.time >= 180
									me.living = false
							"hitted" : (me, ch) -> 
								player.addScore(ch, 2)
							}))

				player = self.factory.createCharacterBase(info)
				self.playing.chainCount    = 0
				self.playing.bullet2Stock  = 0

				player.dyingEvent = -> 	
					ui.gapi.createPlayerDyingEffect(player.pt)
					self.updater.addCharacter(self.factory.createCharacterBase({
						"type"     : "events"
						"type2"    : "EndGameEvent"
						"action"   : (chSelf) -> 
							self.updater.endGame() if chSelf.time is 180
					}))
				player.addScore = (enemy, bonus) ->
					if enemy.type2 isnt "boss"
						self.playing.score += enemy.score
						ui.gapi.createEffects({"type":"score", "pt":enemy.pt, "score":enemy.score})
					if bonus is 1 and enemy.type2 isnt "boss"
						self.playing.score += self.playing.chainCount * bonus
						ui.gapi.createChainScoreEffects(self.playing.chainCount, bonus)
					else if bonus is 2
						self.playing.score += self.playing.bullet2Stock * bonus
						ui.gapi.createBullet2StockScoreEffects(self.playing.bullet2Stock, bonus)

				countUpChain = -> 
					self.playing.chainCount++
					if self.playing.chainCount >= 6
						if self.playing.bullet2Stock < 5
							self.playing.chainCount = 0
							self.playing.bullet2Stock++
						else
							self.playing.chainCount = 5
				player