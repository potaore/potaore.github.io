
#define utility
each = _.each
map = _.map
random = _.random
sum = _.reduce
indexOf = _.indexOf
filter = _.filter

swap = (array, i, j) -> [ array[i], array[j] ] = [ array[j], array[i] ]
mix = (ary, num) ->
	each([1..num], -> swap(ary, random(ary.length - 1), random(ary.length - 1)))
	ary
distance = (p1, p2) -> Math.sqrt(Math.pow(p1.x - p2.x, 2) + Math.pow(p1.y - p2.y, 2))

#define const
cons = 
	min : 0
	max : 299

class GeneManager
	constructor: (num, generator) ->
		@genes = map( [1..num], -> { gene: generator(), evaluation: 0} )
		@survivors = @genes

	evaluate : (evaluator) ->
		each(@genes, (gene) -> gene.evaluation = evaluator(gene.gene))

	next : (num, match, nextNum) ->
		@genes = _.sortBy(@genes, (gene) -> gene.evaluation)
		@survivors = @genes[0...num]
		rnd = => @survivors[random(0, @survivors.length - 1)].gene
		main = => @survivors[random(0, parseInt(@survivors.length / 3))].gene
		newgenes = map([0...nextNum], -> { gene: match(main(), rnd()), evaluation: 0} )
		@genes = newgenes

	getBestGene : => @survivors[0].gene
	getBestEval : => @survivors[0].evaluation

evaluator = (order) ->
	func = (memo, i) ->
		p1 = points[order[i]]
		p2 = points[order[(i + 1) % order.length]]
		memo + distance(p1, p2)
	sum( [0...order.length], func , 0)

mng = null

points = null 
 
newMng = (tNum, geneNum) ->
	points = map [1..tNum], -> { x: random(cons.min, cons.max), y: random(cons.min, cons.max) }
	gen = -> temp = mix [0...tNum], tNum*5
	mng = new GeneManager geneNum, gen
	
	draw mng.getBestGene()

calc = (generationNum, mutation, svNum, nextNum) ->
	match = (gene1, gene2) ->
		newGen = gene1[..]
		len = gene1.length
		index = random(parseInt(len / 2), len - 1)
		swapRoute = (gene, x, y) ->
			return gene if x is y
			[x, y] = [y, x] if x > y
			[a1, a2, a3, a4] = [gene[0...(x+1)], gene[(x+1)...y], [gene[y]], gene[y+1...len]]
			return a1.concat(a3).concat(a2).concat(a4)
		revRoute = (gene, x, y) ->
			return gene if x is y
			[x, y] = [y, x] if x > y
			[a1, a2, a3] = [gene[0...x], gene[x...y], gene[y...len]]
			return a1.concat(a2.reverse()).concat(a3)
		while index < len - 1
			x = indexOf gene1, gene2[random(len - 2)] 
			y = indexOf gene1, gene2[random(len - 2)] 
			newGen = swapRoute newGen, x, y
			index++
		newGen = newGen[1...len].concat([newGen[0]]) if random(0, 10) is 0
		while random(1, 1000) <= mutation
			if random(0, 2) is 0	
				newGen = swapRoute(newGen, random(len - 1), random(len - 1))
			else if random(0, 1) is 0
				swap(newGen, random(len - 1), random(len - 1))
			else
				newGen = revRoute(newGen, random(len - 1), random(len - 1))
		newGen

	next = (left) ->
		->
			if left <= 0  
				console.log mng.getBestEval()
				disable(false)
				return 
			mng.evaluate(evaluator)
			mng.next(svNum, match, nextNum)
			draw mng.getBestGene()
			setTimeout(next(left - 1), 1)

	setTimeout(next(generationNum), 1)