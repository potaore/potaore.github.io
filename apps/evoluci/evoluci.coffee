#define utility
each = _.each
random = _.random
filter = _.filter
find = _.find
every = _.every
rnd = (num) -> Math.floor(Math.random() * num)
rndPL = -> 1 - 2 * rnd(2)
getDistance = (pt1, pt2) -> Math.sqrt(Math.pow(pt1.x-pt2.x,2)+Math.pow(pt1.y-pt2.y,2))
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
hittestRectangle = (pt1, pt2, distance) -> 
	return Math.abs(pt1.x - pt2.x) < distance and Math.abs(pt1.y - pt2.y) < distance 

#define classes

class Infanino
	constructor :(@point, @flag) ->
		@type       = "tt"
		@life 		= 100
		@energy 	= 1
		@arg		= Math.random(2*Math.PI)
		@dArg		= 0

class InfHistory
	constructor : (@id) ->
		@birth			= 0
		@hungryDeath 	= 0
		@eatenDeath 	= 0
		@bombDeath		= 0

class ContextWrapper
	constructor : (@offset) ->
	setCtx		: (@ctx) ->
	moveTo 		: (pt) -> 
		@ctx.moveTo(pt.x + @offset.x, pt.y + @offset.y)
	circle		: (pt, r) -> 
		@ctx.moveTo(pt.x + r, pt.y)
		@ctx.arc(pt.x, pt.y, r, 0, Math.PI*2, false)
	rect		: (left, right, top, floor) ->
		@ctx.rect(left + @offset.x, top + @offset.y, right + @offset.x, floor + @offset.y)
	drawImage	:(img, pt) ->
		if img isnt null
			@ctx.drawImage(img, pt.x - img.width / 2, pt.y - img.height / 2) 

class MenuItem
	constructor :(index, @checked, @id) ->
		@point =
			x 		: params.screanWidth - params.menuTileSize * (index * 2 + 1) / 2
			y 		: params.screanHeight - params.menuTileSize / 2 - 30

#define params
params =
	screanWidth		: 640
	screanHeight	: 480
	infaninos_max 	: 1800
	interval		: 30
	stop 			: false
	clickType 		: "bomb"
	pick 			: null
	marginLeft		: 5
	marginTop		: 5
	marginRight		: 150
	marginBottom	: 65

	menuTileSize	: 40

params.scrLeft	 	= params.marginLeft
params.scrRight  	= params.screanWidth - params.marginLeft - params.marginRight
params.scrTop		= params.marginTop
params.scrFloor		= params.screanHeight - params.marginTop - params.marginBottom

#define global obj
__ = 
	info:
		time		: 0
		bombNum		: 0
	infaninos 		: null
	infHistory 		: {}
	missionFlag		: {}
	canvas 			: null
	ctxWrap 		: null
	mouse:
		clicked		: false
		pt:
			x		: 0
			y		: 0
	message			: []
	currentMessage	: null
	livingInfaninos	: null
	livingInfLists	: null
	deadInfs		: null
	effects			: []
	objects			: []
	energy			: 0

_menu = 
	save 		: new MenuItem(1, false, "save")
	load		: new MenuItem(0, false, "load")

	watch 		: new MenuItem(5, true, "watch")
	data 		: new MenuItem(4, false, "data")
	mission 	: new MenuItem(3, false, "mission")

	stop 		: new MenuItem(9, false, "stop")
	play 		: new MenuItem(8, true, "play")
	hispeed		: new MenuItem(7, false, "hispeed")
	pincettes	: new MenuItem(12, false, "pincettes")
	bomb 		: new MenuItem(11, true, "bomb")
_menu.data.index = -1


_missions = [
		{ name : "生物博士", getCondition : -> "全ての生き物を発生させる" }
		{ name : "爆撃魔神", getCondition : -> "爆撃で1000体生物を殺す" }
		{ name : "ベテラン", getCondition : -> "時間が100000に達する" }
		{ name : "森林浴", getCondition : -> "#{getInfName("ki")} を50体以上にする" }
		{ name : "サバンナ", getCondition : -> "#{getInfName("ks")} を200体以上, #{getInfName("on")} を5体以上にする" }
		{ name : "お花畑", getCondition : -> "#{getInfName("hn")} を100体以上にする" }
		{ name : "鳥天国", getCondition : -> "#{getInfName("tr")} を20体以上, #{getInfName("kt")} を10体以上にする" }
		{ name : "毒の大地", getCondition : -> "#{getInfName("db")}を300体以上にする" }
		{ name : "奈良", getCondition : -> "#{getInfName("sd")}を30体以上にする" }
		{ name : "吸血地獄", getCondition : -> "#{getInfName("ka")}を50体以上にする" }
		{ name : "海辺の生物", getCondition : -> "#{getInfName("yk")}, #{getInfName("hd")}, #{getInfName("km")} を同時に出現させる" }
		{ name : "緑一色", getCondition : -> "フィールドの生物を #{getInfName("sb")}, #{getInfName("sm")}, #{getInfName("ks")}, #{getInfName("km")}, #{getInfName("hb")} だけにする" }
		{ name : "多様性", getCondition : -> "同時に10種類以上の生物を存在させる" }
		{ name : "虫イーター", getCondition : -> "#{getInfName("nm")}, #{getInfName("sm")}を200体以上捕食する" }
		{ name : "殻割名人", getCondition : -> "#{getInfName("yk")}を1000体以上捕食する" }
		{ name : "森林伐採", getCondition : -> "#{getInfName("ki")}を500体以上捕食する" }
		{ name : "プロポリス", getCondition : -> "#{getInfName("ht")}を10体以上捕食する" }
		{ name : "高級食材", getCondition : -> "#{getInfName("kk")}を捕食する" }
		{ name : "大好物", getCondition : -> "#{getInfName("sa")}を捕食する" }
		{ name : "命の源", getCondition : -> "#{getInfName("nb")}の出生数を500000以上にする" }
	]

getInfName = (type) ->
	if __.infHistory[type].birth > 0
		typeDef[type].name
	else
		"？？？"

#define creatures
typeDef =
	tt :
		index 			: 0
		id 				: "tt"
		name			: "土"
		lifeTime		: 100
		energy			: 1
		limit			: 1
		moveDef :
			speed : 0
			dArg  : 0
		breed			: { type : "lifeEnd", range : 10 }
		evolution		: [ { id : "nb", probability : 1500, num : 6 } ]
		eatDef :
			range 		: 0
			hungry		: 0
		eat 			: []
		decompose		: []

	nb :
		index 			: 1
		id 				: "nb"
		name			: "動物性微生物"
		lifeTime		: 500
		energy			: 1
		limit			: 1
		moveDef :
			speed : 0.7
			dArg  : 1
		breed			: { type : "split", time : 120, range : 5 }
		evolution		: [ 
							{ id : "nm", probability : 50}
							{ id : "hd", probability : 30000 }
							{ id : "sb", type : "eaten", probability : 100 }
							{ id : "db", type : "eaten", probability : 30000 }
							]
		eatDef :
			range 		: 5
			hungry		: 2
		eat 			: [{ id : "tt", probability : 4 }]
		decompose		: []

	nm :
		index 			: 2
		id 				: "nm"
		name			: "肉食虫"
		lifeTime		: 350
		energy			: 2
		limit			: 0.05
		moveDef :
			speed : 2.5
			dArg  : 2.5
		breed			: { type : "lifeEnd", range : 5 }
		evolution		: [ 
							{ id : "sm", type : "hungry", probability : 20, key : "sb"  }
							{ id : "kn", probability : 100 }
							{ id : "ht", type : "eaten", probability : 3000 }
							]
		eatDef :
			range 		: 6
			hungry		: 4
		eat 			: [
							{ id : "nb", probability : 3 }
							{ id : "sa", probability : 80 }
							{ id : "sm", probability : 100 }
							{ id : "ka", probability : 100 }
							]
		decompose		: []

	kn :
		index 			: 3
		id 				: "kn"
		name			: "小型肉食動物"
		lifeTime		: 550
		energy			: 3
		limit			: 0.03
		moveDef :
			speed : 2
			dArg  : 2
		breed			: { type : "lifeEnd", range : 5 }
		evolution		: [ 
							{ id : "on", probability : 350 }
							{ id : "sd", probability : 2000, key : "ki" }
							{ id : "hb", type : "hungry", probability : 20 }
							]
		eatDef :
			range 		: 6
			hungry		: 6
		eat 			: [
							{ id : "nm", probability : 3, life : 70 }
							{ id : "sm", probability : 3, life : 70 }
							{ id : "tr", probability : 200, life : 70 }
							{ id : "yk", probability : 200, life : 70 }
							{ id : "nb", probability : 300, life : 70 }
							]
		decompose		: ["nb", "tt"]

	sb :
		index 			: 4
		id 				: "sb"
		name			: "植物性微生物"
		lifeTime		: 500
		energy			: 1
		limit			: 1
		moveDef :
			speed : 0.7
			dArg  : 1
		eatDef :
			range 		: 5
			hungry		: 2
		breed			: { type : "split", time : 120, range : 5 }
		evolution		: [ 
							{ id : "sm", probability : 20}
							{ id : "ks", probability : 200}
							{ id : "sa", type : "eaten", probability : 8000 }
							]
		eat 			: [{ id : "tt", probability : 4 }]
		decompose		: []

	sm :
		index 			: 5
		id 				: "sm"
		name			: "草食虫"
		lifeTime		: 350
		energy			: 2
		limit			: 0.05
		moveDef :
			speed : 2.5
			dArg  : 2.5
		breed			: { type : "lifeEnd", range : 5 }
		evolution		: [ 
							{ id : "nm", type : "hungry", probability : 20 }
							{ id : "tr", probability : 400, key : "ki" }
							{ id : "ka", probability : 2000, key : "kn" }
							{ id : "yk", type : "hungry", probability : 3000 }
							{ id : "yk", type : "eaten", probability : 2500 }
							]
		eatDef :
			range 		: 6
			hungry		: 4
		eat 			: [
							{ id : "sb", probability : 3 }
							{ id : "ks", probability : 3 }
							{ id : "hn", probability : 3 }
							{ id : "ki", type : "mos",  probability : 100 }
							]
		decompose		: ["sb", "tt"]

	ki :
		index 			: 6
		id 				: "ki"
		name			: "木"
		lifeTime		: 900
		energy			: 2
		limit			: 1
		moveDef :
			speed : 0
			dArg  : 0
		breed			: { type : "split", time : 400, range : 50 }
		evolution		: [ 
							{ id : "kb", probability : 100 }
							{ id : "kk", type : "eaten", probability : 1000 }
							]
		eatDef :
			range 		: 8
			hungry		: 4
		eat 			: [
							{ id : "tt", probability : 3, life : 150 }
							{ id : "sb", probability : 3, life : 150 }
							]
		decompose		: ["sb", "tt"]

	tr :
		index 			: 7
		id 				: "tr"
		name			: "鳥"
		lifeTime		: 600
		energy			: 3
		limit			: 0.015
		moveDef :
			speed : 2
			dArg  : 0.7
		breed			: { type : "lifeEnd", range : 5 }
		evolution		: [ 
							{ id : "kt", probability : 1000 }
							]
		eatDef :
			range 		: 6
			hungry		: 6
		eat 			: [
							{ id : "nm", probability : 15, life : 80 }
							{ id : "sm", probability : 20, life : 80 }
							{ id : "sa", probability : 20, life : 80 }
							{ id : "ht", probability : 20, life : 80 }
							{ id : "ka", probability : 50, life : 80 }
							]
		decompose		: ["sb", "nb", "tt"]

	kb :
		index 			: 8
		id 				: "kb"
		name			: "巨木"
		lifeTime		: 5000
		energy			: 10
		limit			: 1
		moveDef :
			speed : 0
			dArg  : 0
		breed			: { type : "non", range : 50 }
		evolution		: []
		eatDef :
			range 		: 20
			hungry		: 20
		eat 			: [ 
							{ id : "tt", probability : 10, life : 100 }
							{ id : "sb", probability : 50, life : 100 }
							]
		decompose		: ["sb", "tt"]

	on :
		index 			: 9
		id 				: "on"
		name			: "大型肉食動物"
		lifeTime		: 850
		energy			: 7
		limit			: 0.007
		moveDef :
			speed : 2
			dArg  : 1
		breed			: { type : "lifeEnd", range : 5 }
		evolution		: []
		eatDef :
			range 		: 8
			hungry		: 14
		eat 			: [ 
							{ id : "kn", probability : 4, life : 80 }
							{ id : "sd", probability : 4, life : 80 }
							{ id : "ak", probability : 4, life : 80 }
							{ id : "yk", probability : 8, life : 80 }
							{ id : "tr", probability : 10, life : 80 }
							{ id : "kt", probability : 50, life : 80 }
							]
		decompose		: ["nb", "tt"]

	ka :
		index 			: 10
		id 				: "ka"
		name			: "蚊"
		lifeTime		: 500
		energy			: 1
		limit			: 0.1
		moveDef :
			speed : 2
			dArg  : 2
		breed			: { type : "split" , time : 120, range : 5 }
		evolution		: []
		eatDef :
			range 		: 5
			hungry		: 2
		eat 			: [ 
							{ id : "kn", probability : 4, type : "mos" }
							{ id : "sd", probability : 4, type : "mos" }
							{ id : "ak", probability : 4, type : "mos" }
							{ id : "on", probability : 4, type : "mos" }
							{ id : "tr", probability : 4, type : "mos" }
							{ id : "kt", probability : 4, type : "mos" }
							]
		decompose		: ["tt"]

	yk :
		index 			: 11
		id 				: "yk"
		name			: "ヤドカリ"
		lifeTime		: 500
		energy			: 2
		limit			: 0.03
		moveDef :
			speed : 1.2
			dArg  : 2
		breed			: { type : "lifeEnd", range : 5 }
		evolution		: [ 
							{ id : "km", probability : 9000 }
							{ id : "sm", probability : 200 }
							{ id : "nm", probability : 200 }
							]
		eatDef :
			range 		: 8
			hungry		: 4
		eat 			: [ 
							{ id : "sb", probability : 15 }
							{ id : "ks", probability : 100, type : "mos" }
							{ id : "hn", probability : 100 }
							{ id : "db", probability : 150 }
							]
		decompose		: ["sb", "nb", "tt"]

	hd :
		index 			: 12
		id 				: "hd"
		name			: "ヒトデ"
		lifeTime		: 800
		energy			: 2
		limit			: 0.03
		moveDef :
			speed : 1
			dArg  : 1
		breed			: { type : "split" , time : 300, range : 5 }
		evolution		: []
		eatDef :
			range 		: 6
			hungry		: 4
		eat 			: [ 
							{ id : "nb", probability : 3 }
							{ id : "db", probability : 3 }
							{ id : "sb", probability : 3 }
							]
		decompose		: ["nb", "tt"]

	hn :
		index 			: 13
		id 				: "hn"
		name			: "花"
		lifeTime		: 500
		energy			: 1
		limit			: 1
		moveDef :
			speed : 0
			dArg  : 0
		breed			: { type : "split" , time : 200, range : 15 }
		evolution		: []
		eatDef :
			range 		: 8
			hungry		: 2
		eat 			: [ 
							{ id : "tt", probability : 3 }
							{ id : "sb", probability : 10 }
							]
		decompose		: ["sb", "tt"]

	km :
		index 			: 14
		id 				: "km"
		name			: "亀"
		lifeTime		: 2500
		energy			: 4
		limit			: 0.008
		moveDef :
			speed : 0.5
			dArg  : 0.5
		breed			: { type : "lifeEnd" , range : 5 }
		evolution		: []
		eatDef :
			range 		: 6
			hungry		: 8
		eat 			: [ 
							{ id : "hd", probability : 3, life : 100 }
							{ id : "hb", probability : 3, life : 100 }
							{ id : "yk", probability : 50, life : 100 }
							{ id : "ks", probability : 5, type : "mos" }
							{ id : "ki", probability : 5, type : "mos" }
							{ id : "kk", probability : 100, type : "mos" }
							]
		decompose		: ["nb", "sb", "tt"]

	kt :
		index 			: 15
		id 				: "kt"
		name			: "巨鳥"
		lifeTime		: 800
		energy			: 4
		limit			: 0.005
		moveDef :
			speed : 3
			dArg  : 0.6
		breed			: { type : "lifeEnd", range : 5 }
		evolution		: []
		eatDef :
			range 		: 6
			hungry		: 9
		eat 			: [ 
							{ id : "nm", probability : 10, life : 80 }
							{ id : "sm", probability : 10, life : 80 }
							{ id : "hb", probability : 50, life : 70 }
							{ id : "tr", probability : 100, life : 150 }
							{ id : "yk", probability : 100, life : 150 }
							]
		decompose		: ["nb", "sb", "tt"]

	db :
		index 			: 16
		id 				: "db"
		name			: "毒性微生物"
		lifeTime		: 2000
		energy			: 1
		limit			: 0.15
		moveDef :
			speed : 0.4
			dArg  : 1
		eatDef :
			range 		: 4
			hungry		: 2
		breed			: { type : "split", time : 1200, range : 2 }
		evolution		: []
		eat 			: [{ id : "tt", probability : 4 }]
		decompose		: []

	ks :
		index 			: 17
		id 				: "ks"
		name			: "草"
		lifeTime		: 500
		energy			: 1
		limit			: 1
		moveDef :
			speed : 0
			dArg  : 0
		breed			: { type : "split", time : 110, range : 45 }
		evolution		: [ 
							{ id : "ki", probability : 100 }
							{ id : "hn", probability : 10000 }
							{ id : "ss", type : "eaten", probability : 1000 }
							]
		eatDef :
			range 		: 7
			hungry		: 2
		eat 			: [
							{ id : "tt", probability : 3 }
							{ id : "sb", probability : 10 }
							]
		decompose		: ["sb"]

	sd :
		index 			: 18
		id 				: "sd"
		name			: "草食動物"
		lifeTime		: 600
		energy			: 4
		limit			: 0.03
		moveDef :
			speed : 3
			dArg  : 2.5
		breed			: { type : "lifeEnd", range : 5 }
		evolution		: [ 
							{ id : "on", probability : 300 }
							]
		eatDef :
			range 		: 6
			hungry		: 8
		eat 			: [
							{ id : "ks", probability : 3, life : 30 }
							{ id : "ss", probability : 5, life : 30 }
							{ id : "ki", probability : 50, life : 30 }
							{ id : "sm", probability : 100, life : 30 }
							{ id : "kk", probability : 100, life : 30 }
							]
		decompose		: ["nb", "sb", "tt"]

	ak :
		index 			: 19
		id 				: "ak"
		name			: "アリクイ"
		lifeTime		: 500
		energy			: 3
		limit			: 0.03
		moveDef :
			speed : 2
			dArg  : 1.5
		breed			: { type : "lifeEnd", range : 5 }
		evolution		: [ 
							{ id : "sd", probability : 200, key : "ki" }
							{ id : "ma", probability : 2000 }
							]
		eatDef :
			range 		: 6
			hungry		: 6
		eat 			: [
							{ id : "sa", probability : 3, life : 10 }
							{ id : "nb", probability : 30, life : 10 }
							{ id : "nm", probability : 100, life : 10 }
							]
		decompose		: ["tt", "nb", "sb"]

	sa :
		index 			: 20
		id 				: "sa"
		name			: "シロアリ"
		lifeTime		: 500
		energy			: 1
		limit			: 1
		moveDef :
			speed : 0.9
			dArg  : 1
		breed			: { type : "split", time : 200, range : 5 }
		evolution		: [ 
							{ id : "ak", probability : 2000 }
							]
		eatDef :
			range 		: 5
			hungry		: 2
		eat 			: [
							{ id : "ks", probability : 3 }
							{ id : "hn", probability : 3 }
							{ id : "sb", probability : 10 }
							{ id : "ki", probability : 50, type : "mos" }
							{ id : "nb", probability : 100 }
							]
		decompose		: []

	kk :
		index 			: 21
		id 				: "kk"
		name			: "キノコ"
		lifeTime		: 650
		energy			: 2
		limit			: 0.1
		moveDef :
			speed : 0
			dArg  : 0
		breed			: { type : "split", time : 200, range : 50 }
		evolution		: [ { id : "ki", probability : 100 } ]
		eatDef :
			range 		: 10
			hungry		: 4
		eat 			: [
							{ id : "tt", probability : 3 }
							{ id : "db", probability : 3 }
							{ id : "sb", probability : 100 }
							{ id : "ki", probability : 200, type : "mos" }
							]
		decompose		: ["sb", "nb"]


	ma :
		index 			: 22
		id 				: "ma"
		name			: "クマ"
		lifeTime		: 850
		energy			: 5
		limit			: 0.005
		moveDef :
			speed : 1.5
			dArg  : 1.5
		breed			: { type : "lifeEnd", range : 5 }
		evolution		: [ { id : "sd", probability : 1000 } ]
		eatDef :
			range 		: 5
			hungry		: 10
		eat 			: [
							{ id : "hb", probability : 3, life : 70 }
							{ id : "ht", probability : 3, life : 70 }
							{ id : "yk", probability : 3, life : 70 }
							{ id : "kn", probability : 30, life : 70 }
							{ id : "kk", probability : 50, life : 70 }
							{ id : "ss", probability : 100, life : 70 }
							{ id : "tt", probability : 100, life : 70 }
							{ id : "ak", probability : 200, life : 70 }
							]
		decompose		: ["sb", "nb"]

	hb :
		index 			: 23
		id 				: "hb"
		name			: "ヘビ"
		lifeTime		: 500
		energy			: 3
		limit			: 0.03
		moveDef :
			speed : 1.5
			dArg  : 1.5
		breed			: { type : "lifeEnd", range : 5 }
		evolution		: [ { id : "kn", probability : 100 } ]
		eatDef :
			range 		: 5
			hungry		: 6
		eat 			: [
							{ id : "nm", probability : 3, life : 20 }
							{ id : "sm", probability : 3, life : 20 }
							{ id : "kn", probability : 100, life : 20 }
							{ id : "hd", probability : 100, life : 20 }
							]
		decompose		: []

	ht :
		index 			: 24
		id 				: "ht"
		name			: "ハチ"
		lifeTime		: 350
		energy			: 3
		limit			: 0.03
		moveDef :
			speed : 3
			dArg  : 3
		breed			: { type : "lifeEnd", range : 5 }
		evolution		: []
		eatDef :
			range 		: 5
			hungry		: 6
		eat 			: [
							{ id : "nb", probability : 5 }
							{ id : "sa", probability : 30 }
							{ id : "ka", probability : 100, life : 20 }
							{ id : "nm", probability : 100, life : 20 }
							{ id : "sm", probability : 100, life : 20 }
							]
		decompose		: ["nb"]

	ss :
		index 			: 25
		id 				: "ss"
		name			: "食虫植物"
		lifeTime		: 600
		energy			: 2
		limit			: 0.03
		moveDef :
			speed : 0
			dArg  : 0
		breed			: { type : "lifeEnd", range : 50 }
		evolution		: []
		eatDef :
			range 		: 9
			hungry		: 4
		eat 			: [
							{ id : "sa", probability : 5 }
							{ id : "nm", probability : 5 }
							{ id : "sm", probability : 5 }
							{ id : "ht", probability : 5 }
							{ id : "tt", probability : 5 }
							]
		decompose		: []

images = null

_drawOrder = ["tt", "sb", "nb", "db", "sa", "ks", "hn", "ss", "kk", "hd", "sm", "nm", "yk", "kn", "hb", "km", "ak", "sd", "ma", "on", "ki", "kb", "ka", "ht", "tr", "kt"]

init = (canvas)->
	__.canvas 		= initCanvas(canvas)
	__.ctxWrap		= new ContextWrapper({x:params.marginLeft , y:params.marginTop})
	each(typeDef, (typeParams) -> __.infHistory[typeParams.id] = new InfHistory(typeParams.id))
	__.infaninos 	= createNewInfaninos()
	__.message = []	
	loadImages()
	livingInfLists	= {}
	return

initCanvas = (canvas)->
	canvas.width = params.screanWidth
	canvas.height = params.screanHeight
	window.onclick = (e) -> 
		__.mouse.clicked = true
		__.mouse.pt.x = e.pageX - mouseOffsetX
		__.mouse.pt.y = e.pageY - mouseOffsetY
	mouseOffsetX = getSumnOfParents(canvas, 
											(obj) -> obj.offsetLeft, 
											(obj) -> obj.offsetParent)
	mouseOffsetY = getSumnOfParents(canvas, 
											(obj) -> obj.offsetTop, 
											(obj) -> obj.offsetParent)
	window.onmousemove = (e) ->
		__.mouse.pt.x = e.pageX - mouseOffsetX
		__.mouse.pt.y = e.pageY - mouseOffsetY
	return canvas

createNewInfaninos = -> 
	for i in [0...params.infaninos_max] 
		pt =
			x	: params.marginLeft + rnd(params.screanWidth - 2 * params.marginLeft - params.marginRight)
			y	: params.marginTop + rnd(params.screanHeight - 2 * params.marginTop - params.marginBottom)
		
		inf = new Infanino(pt, true)
		setInfType(inf, "tt")
		inf

loadImages = ->
	loadImg = (id) ->
	    result = new Image()
	    result.src = "images/#{id}.png"
	    images[id] = result
	    return
	images = []

	each(typeDef, (typeParams) -> loadImg(typeParams.id))
	each(_menu, (menuitem) -> loadImg(menuitem.id))

draw = ->
	return if __.livingInfLists is null
	ctx = __.canvas.getContext('2d')
	ctx.clearRect(0, 0, params.screanWidth, params.screanHeight)
	ctx.strokeStyle = 'rgb(150, 240, 240)'
	ctx.lineWidth = 3


	ctxDrawProcess = (predicate) ->
		ctx.beginPath()
		predicate()
		ctx.closePath()
		ctx.stroke()

	ctxDrawProcess(->ctx.rect(0, 0,params.screanWidth,params.screanHeight))

	ctx.lineWidth = 1
	__.ctxWrap.setCtx(ctx)

	if(_menu.mission.checked)
		drawMissions()
	else
		ctxDrawProcess(drawImpl)

	ctxDrawProcess(->
		drawInfo(ctx)
		drawMenu())

	ctxDrawProcess(drawMessage)
	return

drawInfo = (ctx) ->
	ctx.font = "12px 'ＭＳ ゴシック'"
	ctx.fillStyle = "rgb(150, 240, 240)"
	startX = params.screanWidth - params.marginRight
	write = (str) -> ctx.fillText(str, startX, 14*lineCount + params.marginTop)
	writeline = (str) -> ctx.fillText(str, startX, 14*lineCount++ + params.marginTop)
	writeheading = (str) -> 
		ctx.fillText(str, startX, 14*lineCount + params.marginTop)
		lineCount += 1.5
	indent = (str) -> "               " + str
	lineCount = 1

	if _menu.watch.checked
		
		write("  時間")
		writeline(indent(" #{__.info.time}"))
		startX += 10
		lineCount++	
		each(typeDef, (typeParams) -> 
			write("  #{getInfName(typeParams.id)}")
			if __.infHistory[typeParams.id].birth
				__.ctxWrap.drawImage(images[typeParams.id], { x : startX, y : 14*lineCount})
			writeline(indent("#{__.livingInfLists[typeParams.id].length}")))

	else if _menu.data.checked	
		typeParams = find(typeDef, (typeParams) -> typeParams.index is _menu.data.index)
		if(typeParams)
			hist = __.infHistory[typeParams.id]
			writeline(" □ #{getInfName(typeParams.id)} □")

			lineCount++	
			writeheading(" ●主食")
			for eatMenu in filter(typeParams.eat, (eatMenu) -> eatMenu.probability < 100)
				writeline("  #{getInfName(eatMenu.id)}")

			lineCount++	
			temp = 0
			writeheading(" ●たまに食べる")
			for eatMenu in filter(typeParams.eat, (eatMenu) -> eatMenu.probability >= 100)
				writeline("  #{getInfName(eatMenu.id)}")
				temp++
			writeline("  なし") if temp is 0


			lineCount++	
			temp = 0
			writeheading(" ●捕食生物")
			each(typeDef, (anotherTypeParams)->
				if find(anotherTypeParams.eat, (eatMenu) -> eatMenu.id is typeParams.id)
					writeline("  #{getInfName(anotherTypeParams.id)}")
					temp++
				return)
			writeline("  なし") if temp is 0


			lineCount++
			writeheading(" ★ 記録 ★")
			write("  出生回数")
			writeline(indent("#{hist.birth}"))
			write("  餓死回数")
			writeline(indent("#{hist.hungryDeath}"))
			write("  捕食死回数")
			writeline(indent("#{hist.eatenDeath}"))
			write("  爆撃死回数")
			writeline(indent("#{hist.bombDeath}"))
		else
			writeheading(" ★ 色々な記録 ★")
			_menu.data.index 	= -1
			birthTotal			= 0
			eatTotal			= 0
			hungryDeath			= 0
			bombDeath			= 0
			each(__.infHistory, (hist) ->
					birthTotal	+= hist.birth
					eatTotal 	+= hist.eatenDeath
					hungryDeath += hist.hungryDeath
					bombDeath 	+= hist.bombDeath)
			write("  総出生回数")
			writeline(indent("#{birthTotal}"))
			write("  総捕食回数")
			writeline(indent("#{eatTotal}"))
			write("  総餓死回数")
			writeline(indent("#{hungryDeath}"))
			write("  総爆撃回数")
			writeline(indent("#{__.info.bombNum}"))
			write("  総爆撃死回数")
			writeline(indent("#{bombDeath}"))

drawMenu = ->
	drawMenuItem = (menuitem) ->
		pt = menuitem.point
		sz = params.menuTileSize
		if menuitem.checked
			__.ctxWrap.ctx.fillRect(pt.x - sz / 2 + 3, pt.y - sz / 2 + 3, sz - 6 , sz - 6)
		__.ctxWrap.drawImage(images[menuitem.id], menuitem.point)
	each(_menu, drawMenuItem)

drawMissions = ->
	__.ctxWrap.ctx.font = "13px 'ＭＳ ゴシック'"
	indent = (str) -> "                " + str
	ctx = __.ctxWrap.ctx
	startX = params.scrLeft + 10
	lineCount = 1
	writeline = (str) -> ctx.fillText(str, startX, 19*lineCount++ + params.marginTop)
	write = (str) -> ctx.fillText(str, startX, 19*lineCount + params.marginTop)
	writeline("ミッション")
	drawmission = (mission) ->
		if __.missionFlag[mission.name]
			write("■")
		else
			write("□")
		write("   #{mission.name}")
		writeline(indent("#{mission.getCondition()}"))

	each(_missions, (mission) -> drawmission(mission))

drawMessage = ->
	__.ctxWrap.ctx.font = "21px 'ＭＳ ゴシック'"
	if(__.currentMessage)
		__.currentMessage.time++
		__.ctxWrap.ctx.fillText(__.currentMessage.str, 
			params.screanWidth - 6 * __.currentMessage.time,
			params.screanHeight - 11)
		if __.currentMessage.time > 250
			__.currentMessage = null
	else if (__.message.length > 0)
		__.currentMessage = __.message[0]
		__.message = __.message[1...__.message.length]

pushMessage = (str) ->
	message =
		str : str
		time : 0
	__.message.push(message)

drawImpl = ->
	ctxWrap = __.ctxWrap

	for id in _drawOrder
		for inf in __.livingInfLists[id]
			ctxWrap.drawImage(images[inf.type], inf.point)

	if params.pick
		ctxWrap.drawImage(images[params.pick.type], params.pick.point)

	obj.draw() for obj in __.objects
	eff.draw() for eff in __.effects


update = ->
	checkFlag()
	if not params.stop
		__.info.time++
		moveInfs() 

	nextObjects = []
	for obj in __.objects
		nextObjects.push(obj) if obj.update()
	__.objects = nextObjects 

	nextEffects = []
	for eff in __.effects
		nextEffects.push(eff) if eff.update()
	__.effects = nextEffects 

	updateClickEvent()

	if __.livingInfLists
		checkMission()


updateClickEvent = ->
	if __.mouse.clicked
		updateMenu()
		__.mouse.clicked = false
		return if __.mouse.pt.y > params.scrFloor or __.mouse.pt.x > params.scrRight
		if params.clickType is "bomb"
			__.info.bombNum++
			if params.pick
				params.pick.picked = false
				params.pick = null
			__.effects.push(createEffect(__.mouse.pt)) for i in [1..4]
			for inf in __.livingInfaninos
				if getDistance(inf.point, __.mouse.pt) < 30
					if inf.type isnt "tt"
						killInf(inf, "bomb")
						inf.type = "tt"
						inf.flag = true
						inf.life = 0
		else if params.clickType is "pincettes"
			if params.pick
				params.pick.picked = false
				params.pick = null
			else
				for inf in __.livingInfaninos
					if getDistance(inf.point, __.mouse.pt) < 3
						inf.picked = true
						params.pick = inf	
						break
				if not inf.picked
					for inf in __.livingInfaninos
						if getDistance(inf.point, __.mouse.pt) < 10
							inf.picked = true
							params.pick = inf	
							break
	return

checkFlag = ->
	__.livingInfaninos = []
	__.livingInfLists  = {} if __.livingInfLists is null
	__.deadInfs		   = []
	nums 			   = {}

	each(typeDef, (typeParams) -> 
		if __.livingInfLists[typeParams.id]
			nums[typeParams.id] = __.livingInfLists[typeParams.id].length
		else
			nums[typeParams.id] = -1
		__.livingInfLists[typeParams.id] = [])

	__.energy = 0
	for inf in __.infaninos
		__.energy += inf.energy
		if inf.picked
			inf.point.x = __.mouse.pt.x
			inf.point.y = __.mouse.pt.y
		else if inf.flag
			__.livingInfaninos.push(inf) 
			__.livingInfLists[inf.type].push(inf)
		else
			__.deadInfs.push(inf)
	if __.energy < params.infaninos_max
		__.livingInfaninos[0].energy++

	each(typeDef, (typeParams) -> 
		if nums[typeParams.id] is 0 and __.livingInfLists[typeParams.id].length > 0
			pushMessage("#{typeParams.name}が発生しました！")
		else if nums[typeParams.id] > 0 and __.livingInfLists[typeParams.id].length is 0
			pushMessage("#{typeParams.name}が全滅しました・・・")
		return)
	return

moveInfs = ->
	moveInf(inf) for inf in __.livingInfaninos
	return

moveInf = (inf) ->
	typeParams = typeDef[inf.type]
	pt = inf.point

	#move creatures
	moveParam 		= typeParams.moveDef
	inf.dArg 		= rnd(23) * rndPL() / 200 * moveParam.dArg + inf.dArg * 9 / 10
	inf.arg 	   += inf.dArg
	inf.arg - Math.PI if inf.arg >  Math.PI
	inf.arg + Math.PI if inf.arg < -Math.PI
	movePt(pt, inf.arg, 0.4 * moveParam.speed)

	pt.x = params.scrLeft if pt.x < params.scrLeft
	pt.x = params.scrRight if pt.x > params.scrRight
	pt.y = params.scrTop if pt.y < params.scrTop
	pt.y = params.scrFloor if pt.y > params.scrFloor

	#eat another creatures
	eatParam = typeParams.eatDef
	eatList = typeParams.eat
	eated = false

	if inf.energy < eatParam.hungry
		for eatMenu in eatList
			continue if inf.life % eatMenu.probability isnt 0
			break if eated
			for target in __.livingInfLists[eatMenu.id]
				break if eated
				if getDistance(inf.point, target.point) < eatParam.range
					if eatMenu.type is "mos"
						inf.energy 		+= 1
						target.energy 	-= 1
						eated 			 = true
						if target.energy <= 0
							killInf(target, "eaten")

					else
						killInf(target, "eaten")
						inf.energy 		+= target.energy
						target.energy 	= 0
						eated = true
						for evol in typeDef[target.type].evolution
							continue if evol.type isnt "eaten"
							if rnd(evol.probability) is 1
								target.flag 	= true
								target.type   	= evol.id
								target.energy	+= typeDef[evol.id].energy
								inf.energy		-= typeDef[evol.id].energy
								target.life 	= 0
	else
		if typeParams.breed.type is "split"
			if inf.life > 5 and inf.life % typeParams.breed.time is 0
				bearInf(inf)

	#death judge
	inf.life++
	if inf.life > typeParams.lifeTime
		if eatParam.hungry is 0
			inf.life = 0
			evoluated = false
			for evol in typeParams.evolution
				break if evolInf(inf, evol)
		else if inf.energy >= eatParam.hungry and typeParams.breed.type isnt "non"
			inf.life = 0
			evoluated = false
			for evol in typeParams.evolution
				if evolInf(inf, evol)
					evoluated = true
					break 
			if not evoluated
				bearInf(inf) 
		else
			killInf(inf, "hungry")
			inf.flag = true
			inf.type = "tt"
			index = 0
			while inf.energy > 1
				if typeParams.decompose.length > 0
					inf.type = typeParams.decompose[index]
					index = (index + 1) % typeParams.decompose.length
				bearInf(inf)
			setInfType(inf, inf.type)
	return

updateMenu = ->

	resetplayer = ->
		_menu.play.checked = false
		_menu.hispeed.checked = false
		_menu.stop.checked = false

	checkPlayer = (item, predicade) ->
		if hittestRectangle(__.mouse.pt, _menu[item].point, params.menuTileSize / 2)
			_menu[item].index++ if _menu[item].checked
			resetplayer()
			_menu[item].checked = true
			params.stop = false
			predicade()

	checkPlayer("play", -> params.interval = 30)
	checkPlayer("hispeed", -> params.interval = 3)
	checkPlayer("stop", -> params.stop = true)

	resetclickevent = ->
		_menu.bomb.checked = false
		_menu.pincettes.checked = false

	if hittestRectangle(__.mouse.pt, _menu.pincettes.point, params.menuTileSize / 2)
		params.clickType = "pincettes"
		resetclickevent()
		_menu.pincettes.checked = true

	if hittestRectangle(__.mouse.pt, _menu.bomb.point, params.menuTileSize / 2)
		params.clickType = "bomb"
		resetclickevent()
		_menu.bomb.checked = true

	if hittestRectangle(__.mouse.pt, _menu.save.point, params.menuTileSize / 2)
		if checkWebstorage()
			if confirm("SAVEしますか？")
				storage = localStorage
				storage.setItem("bombNum", __.info.bombNum)
				storage.setItem("time", __.info.time)
				each(__.infHistory, (hst) -> storage.setItem("hst#{hst.id}", JSON.stringify(hst)))
				storage.setItem("time", __.info.time)
				storage.setItem("missionFlag", JSON.stringify(__.missionFlag))
				for i in [0...params.infaninos_max]
					storage.setItem("inf#{i}", JSON.stringify(__.infaninos[i]))
				alert("SAVEしました！")

	if hittestRectangle(__.mouse.pt, _menu.load.point, params.menuTileSize / 2)
		if checkWebstorage()
			if confirm("LOADしますか？")
				storage = localStorage
				time = storage.getItem("time")
				if time?
					__.info.time 			= storage.getItem("time")
					__.info.bombNum 		= storage.getItem("bombNum")
					__.missionFlag 	= storage.getItem("missionFlag")
					if(__.missionFlag)
						__.missionFlag = JSON.parse(__.missionFlag)
					else
						__.info.missionFlag = {} 
					each(__.infHistory, (hst) -> 
						__.infHistory[hst.id] = JSON.parse(storage.getItem("hst#{hst.id}")))
					for i in [0...params.infaninos_max]
						__.infaninos[i] = JSON.parse(storage.getItem("inf#{i}"))
					alert("LOADしました！")
					__.livingInfLists = null
				else
					alert("SAVEデータがありません")

	resetview = ->
		_menu.data.checked = false
		_menu.watch.checked = false
		_menu.mission.checked = false

	checkView = (item) ->
		if hittestRectangle(__.mouse.pt, _menu[item].point, params.menuTileSize / 2)
			_menu[item].index++ if _menu[item].checked
			resetview()
			_menu[item].checked = true

	checkView("data")
	checkView("watch")
	checkView("mission")

checkWebstorage = ->
	if typeof sessionStorage isnt 'undefined'
		return true
	else 
  		alert("ご利用のブラウザではセーブ・ロード機能は使えません")
  		return false

checkMission = ->
	lists = __.livingInfLists
	histrory = __.infHistory

	checkMissionOf("生物博士", -> every(histrory, (hst) -> hst.birth > 0 ))
	checkMissionOf("爆撃魔神", -> 
		bombDeath = 0
		each(histrory, (hist) -> bombDeath += hist.bombDeath)
		return bombDeath >= 1000)
	checkMissionOf("ベテラン", -> __.info.time > 100000)
	checkMissionOf("森林浴", -> lists["ki"].length >= 50)
	checkMissionOf("サバンナ", -> lists["ks"].length >= 200 and lists["on"].length >= 5)
	checkMissionOf("お花畑", -> lists["hn"].length >= 100)
	checkMissionOf("鳥天国", -> lists["tr"].length >= 20 and lists["kt"].length >= 10)
	checkMissionOf("毒の大地", -> lists["db"].length >= 300)
	checkMissionOf("奈良", -> lists["sd"].length >= 30)
	checkMissionOf("吸血地獄", -> lists["ka"].length >= 50)
	checkMissionOf("海辺の生物", -> lists["yk"].length > 0 and lists["km"].length > 0 and lists["hd"].length > 0)
	checkMissionOf("緑一色", -> 
		existInfList = filter(lists, (list) -> list.lenght > 0)
		if existInfList.lenght is 5
			checkExist = (id) -> lists[id].length > 0
			return every(["sb", "sm", "ks", "km", "hb"] , checkExist)
		return false)
	checkMissionOf("多様性", -> 
		existInfList = filter(lists, (list) -> list.lenght > 0)
		return existInfList.length >= 10)
	checkMissionOf("虫イーター", -> histrory["nm"].eatenDeath + histrory["sm"].eatenDeath > 200)
	checkMissionOf("殻割名人", -> histrory["yk"].eatenDeath >= 1000)
	checkMissionOf("森林伐採", -> histrory["ki"].eatenDeath >= 500)
	checkMissionOf("プロポリス", -> histrory["ht"].eatenDeath >= 10)
	checkMissionOf("高級食材", -> histrory["kk"].eatenDeath >= 1)
	checkMissionOf("大好物", -> histrory["sa"].eatenDeath >= 1)
	checkMissionOf("命の源", -> histrory["nb"].birth >= 5000000)

checkMissionOf = (id, chekPredicade) ->
	if not __.missionFlag[id]
		if chekPredicade()
			pushMessage("ミッション【#{id}】を達成しました")
			__.missionFlag[id] = true

createEffect = (pt) ->
	timer = 8
	result = {}
	newPt = {x : pt.x, y : pt.y }
	result.update 	= -> 
		newPt.x += rnd(5) - rnd(5)
		newPt.y += rnd(5) - rnd(5)
		timer--
	result.draw 	= -> __.ctxWrap.circle(newPt, 5 + rnd(25))
	return result

bearInf = (inf) ->
	typeParams = typeDef[inf.type]
	if __.deadInfs.length > 0
		if __.livingInfLists[inf.type].length < 2 * rnd(params.infaninos_max * typeParams.limit)
			createInf(inf.type, inf.point, inf)
		else
			createInfRnd("tt", inf)

createInf = (type, pt, parent) ->
	if __.deadInfs.length > 0
		typeParams = typeDef[type]
		newInf = __.deadInfs.pop()
		setInfType(newInf, type)
		parent.energy -= typeParams.energy
		newInf.energy += typeParams.energy
		newInf.point.x = pt.x + rnd(typeParams.breed.range) - rnd(typeParams.breed.range)
		newInf.point.y = pt.y + rnd(typeParams.breed.range) - rnd(typeParams.breed.range)

createInfRnd = (type, parent) ->
	if __.deadInfs.length > 0
		newInf = __.deadInfs.pop()
		createInf(type, newInf.point, parent)

evolInf = (inf, evol) ->
	num = 1
	num = evol.num if evol.num 
	if evol.key and __.livingInfLists[evol.key].length is 0
		return false
	if num > __.livingInfLists[evol.id].length
		if rnd(evol.probability) is 1
			setInfType(inf, evol.id)
	return false

setInfType = (inf, type) ->
	inclimentBirth(type)
	inf.flag = true
	inf.type = type
	inf.life = rnd(50) - rnd(50)

inclimentBirth = (type) ->
	__.infHistory[type].birth++
	if __.infHistory[type].birth is 100
		pushMessage("#{typeDef[type].name}の総出生数が100に達しました")
	else if  __.infHistory[type].birth is 1000
		pushMessage("#{typeDef[type].name}の総出生数が1000に達しました")
	else if  __.infHistory[type].birth is 10000
		pushMessage("#{typeDef[type].name}の総出生数が10000に達しました")
	else if  __.infHistory[type].birth is 100000
		pushMessage("#{typeDef[type].name}の総出生数が100000に達しました")

killInf = (inf, deathType) ->
	inf.flag = false
	hst = __.infHistory[inf.type]
	if deathType is "hungry" 
		hst.hungryDeath++
	else if deathType is "eaten" 
		hst.eatenDeath++
	else if deathType is "bomb" 
		hst.bombDeath++

gameLoop = ->
	update()
	draw()
