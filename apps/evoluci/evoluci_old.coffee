#define utility
each = _.each
map = _.map
random = _.random
sum = _.reduce
indexOf = _.indexOf
filter = _.filter
rnd = (num) -> Math.floor(Math.random() * num)
rndPL = -> 1 - 2 * rnd(2)
getDistance = (pt1, pt2) -> 
	Math.sqrt(Math.pow(pt1.x-pt2.x,2)+Math.pow(pt1.y-pt2.y,2))
getDirection = (pt1, pt2) -> Math.atan2(pt2.y - pt1.y, pt2.x - pt1.x)
movePt = (pt, drct, dist) ->
	pt.x += dist * Math.cos(drct)
	pt.y += dist * Math.sin(drct)
getSumnOfParents = (obj, getValue, getParent) ->
	sum = 0
	while obj
		sum += getValue(obj)
		obj = getParent(obj)
	return sum

#define classes

class Infanino
	constructor :(@point, @flag) ->
		@arg		= 0
		@dArg		= 0
		@energy 	= 800
		@life 		= 1000
		@happyNess  = 0
		@parent 	= null
		@child		= null

class ContextWrapper
	constructor : (@offset) ->
	setCtx		: (@ctx) ->
	moveTo 		: (pt) -> 
		@ctx.moveTo(pt.x + @offset.x, pt.y + @offset.y)
	circle		: (pt) -> 
		@ctx.moveTo(pt.x + @offset.x + 3, pt.y + @offset.y)
		@ctx.arc(pt.x + @offset.x, pt.y + @offset.y, 3, 0, Math.PI*2, false)
	rect		: (left, right, top, floor) ->
		@ctx.rect(left + @offset.x, top + @offset.y, right + @offset.x, floor + @offset.y)
	drawInmage	:(img) ->
		@ctx.drawInmage(img, pt.x, pt.y)
#define params
params =
	screanWidth		: 640
	screanHeight	: 480
	infaninos_max 	: 1000
	interval		: 30

	marginLeft		: 0
	marginTop		: 0
	marginRight		: 0
	marginBottom	: 50

#define global obj
__ = 
	info:
		time		: 0
		parent 		: 0
	canvas 			: null
	infaninos 		: null
	livingInfaninos	: null
	effects			: []
	objects			: []
	ctxWrap 		: null
	mouse:
		clicked		: false
		pt:
			x		: 0
			y		: 0
		gPt:
			x 		: 0
			y		: 0

gene = 
	paramGene :
		life		: 0
		energy		: 0


	moveGene :
		straight	: 0
		speed		: 0
		up			: 0
		right		: 0
		down		: 0
		left		: 0

images = null



init = (canvas)->
	__.canvas 		= initCanvas(canvas)
	__.infaninos 	= createNewInfaninos()
	__.ctxWrap		= new ContextWrapper({x:params.marginLeft , y:params.marginTop})
	__.images		= loadImages

	generator =
		update	: ->
			if __.info.time % 3 is 0
				for infanino in __.infaninos
					if not infanino.flag
						infanino.flag = true
						break
			return true
		draw	: -> __.ctxWrap.rect(100, 100, 100, 100)
	__.objects .push(generator)


initCanvas = (canvas)->
	canvas.width = params.screanWidth
	canvas.height = params.screanHeight
	canvas.onclick = (e) -> 
		__.mouse.clicked = true
		console.log __.mouse

	mouseOffsetX = getSumnOfParents(canvas, 
											(obj) -> obj.offsetLeft, 
											(obj) -> obj.offsetParent)
	mouseOffsetY = getSumnOfParents(canvas, 
											(obj) -> obj.offsetTop, 
											(obj) -> obj.offsetParent)
	canvas.onmousemove  = (e) ->
		__.mouse.pt.x = e.x - mouseOffsetX
		__.mouse.pt.y = e.y - mouseOffsetY
		__.mouse.gPt.x = e.x - mouseOffsetX - params.marginLeft
		__.mouse.gPt.y = e.y - mouseOffsetY - params.marginTop
	return canvas

createNewInfaninos = -> 
	for i in [0...params.infaninos_max] 
		new Infanino({x:110, y:110}, false)

loadImages = ->
	loadImg = (filename) ->
	    result = new Image()
	    result.src = filename
	    return result
	images = 
		nb 		: loadImg("images/nb.png");

draw = ->
	ctx = __.canvas.getContext('2d')
	ctx.clearRect(0, 0, params.screanWidth, params.screanHeight)
	ctx.strokeStyle = 'rgb(150, 240, 240)'
	ctx.lineWidth = 3
	ctx.beginPath()
	ctx.rect(
		0, 
		0,
		params.screanWidth,
		params.screanHeight)
	ctx.closePath()
	ctx.stroke()

	ctx.lineWidth = 1
	__.ctxWrap.setCtx(ctx)	
	ctx.beginPath()
	drawImpl()
	ctx.closePath()
	ctx.stroke()

	drawInfo(ctx)

drawInfo = (ctx) ->
	ctx.font = "15px 'ＭＳ ゴシック'";
	ctx.fillStyle = "rgb(150, 240, 240)";
	ctx.fillText("count  = #{__.livingInfaninos.length}", 
		10, params.screanHeight-params.marginBottom+20)
	ctx.fillText("time   = #{__.info.time}", 
		10, params.screanHeight-params.marginBottom+35)
	ctx.fillText("parent = #{__.info.parent}", 
		150, params.screanHeight-params.marginBottom+20)

update = ->
	scrLeft 	= params.marginLeft
	scrRight 	= params.screanWidth - params.marginLeft - params.marginRight
	scrTop		= params.marginTop
	scrFloor	= params.screanHeight - params.marginTop - params.marginBottom

	__.livingInfaninos = []
	__.info.parent = 0
	for inf in __.infaninos
		__.livingInfaninos.push(inf) if inf.flag
		__.info.parent++ if inf.parent is null

	for inf in __.livingInfaninos
		pt = inf.point

		if inf.parent is null
			inf.dArg 	= rnd(8) * rndPL() / 200 + inf.dArg * 29 / 30
			inf.arg 	+= inf.dArg
			inf.arg - Math.PI if inf.arg >  Math.PI
			inf.arg + Math.PI if inf.arg < -Math.PI
			movePt(pt, inf.arg, 1.3)
			child = inf.child
			while child
				child.dArg 	= rnd(8)*rndPL()/200 + child.dArg*29/30
				child.arg 	= child.parent.arg*1/10 + child.arg*9/10 + child.dArg
				child.point.x = child.point.x*3/5 + (child.parent.point.x+5*Math.cos(child.arg))*2/5
				child.point.y = child.point.y*3/5 + (child.parent.point.y+5*Math.sin(child.arg))*2/5
				child = child.child

		if rnd(10) is 1
			for inf2 in __.livingInfaninos
				if inf isnt inf2
					if inf.child is null and inf2.parent is null
						if getDistance(pt, inf2.point) < 5
							flag = true
							child = inf2.child
							while child
								if inf is child
									flag = false
									break
								child = child.child

							parent = inf.parent
							while parent
								if inf2 is parent
									flag = false
									break
								parent = parent.parent
							if flag
								inf.child 	= inf2
								inf2.parent = inf
								break

		pt.x = scrLeft if pt.x < scrLeft
		pt.x = scrRight if pt.x > scrRight
		pt.y = scrTop if pt.y < scrTop
		pt.y = scrFloor if pt.y > scrFloor
		if getDistance(pt, __.mouse.gPt) < 30
			movePt(pt, getDirection(pt, __.mouse.gPt), -4)

	nextObjects = []
	for obj in __.objects
		nextObjects.push(obj) if obj.update()
	__.objects = nextObjects 

	nextEffects = []
	for eff in __.effects
		nextEffects.push(eff) if eff.update()
	__.effects = nextEffects 

drawImpl = ->
	ctxWrap = __.ctxWrap

	for infanino in __.livingInfaninos
		ctxWrap.moveTo(infanino.point)
		ctxWrap.circle(infanino.point)

	obj.draw() for obj in __.objects
	eff.draw() for eff in __.effects

	ctxWrap.circle(__.mouse.gPt)


gameLoop = ->
	__.info.time++
	update()
	draw()
