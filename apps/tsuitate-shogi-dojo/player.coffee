util =
  isVacant : (val) -> val is null or val is undefined or val is "" or val is 0
  isntVacant : (val) -> val isnt null and val isnt undefined and val isnt "" and val isnt 0
  reverseVector : (position, playerNumber) ->
    return position if playerNumber is 1 
    return x : position.x * -1, y : position.y * -1, length : position.length
  posEq  : (p1, p2) -> p1.x is p2.x and p1.y is p2.y
  posAdd : (p, v) -> {x : p.x + v.x, y : p.y + v.y, length : v.length}
  posMul : (p, times) -> { x : p.x * times, y : p.y * times, length : times }
  posDup : (p) -> { x : p.x , y : p.y, length : p.length}
  posAdd1 : (p) -> { x : p.x + 1 , y : p.y + 1, length : p.length}
  posToStr : (p) -> p.x+":"+p.y
  isInRange : (pos) -> 0 <= pos.x and pos.x < 9 and 0 <= pos.y and pos.y < 9
  allPos : (predicate) ->
    for y in [0...9]
      for x in [0...9]
        predicate(x, y)


computeDuration = (ms) ->
  ms = 0 if ms < 0
  h = String(Math.floor(ms / 3600000) + 100).substring(1)
  m = String(Math.floor((ms - h * 3600000)/60000)+ 100).substring(1)
  s = String(Math.round((ms - h * 3600000 - m * 60000)/1000)+ 100).substring(1)
  return m+':'+s

class KomaType
  constructor : (@id, @name, @nari, @resourceId, @nariId, @moveDef, @value) ->

komaTypes = ( ->
  _komaTypes = {}
  setResource = (id, name, nari, resourceId, nariId, moveDef, value) ->
    _komaTypes[id] = new KomaType(id, name, nari, resourceId, nariId, moveDef, value)

  setResource("ou", "玉"  , false, "ou", ""  , { str : "12346789"     , moves : ["1","2","3","4","6","7","8","9"]}    , 9)
  setResource("ki", "金"  , false, "ki", ""  , { str : "123468"       , moves : ["1","2","3","4","6","8"]}            , 5)
  setResource("gi", "銀"  , true , "gi", "ng", { str : "12379"        , moves : ["1","2","3","7","9"]}                , 4)
  setResource("ng", "成銀", false, "gi", ""  , { str : "123468"       , moves : ["1","2","3","4","6","8"]}            , 4)
  setResource("ke", "桂"  , true , "ke", "nk", { str : "ab"           , moves : ["a","b"]}                           , 3)
  setResource("nk", "成桂", false, "ke", ""  , { str : "123468"       , moves : ["1","2","3","4","6","8"]}            , 3)
  setResource("ky", "香"  , true , "ky", "ny", { str : "2_"           , moves : ["2_"]}                               , 2)
  setResource("ny", "成香", false, "ky", ""  , { str : "123468"       , moves : ["1","2","3","4","6","8"]}            , 2)
  setResource("hi", "飛"  , true , "hi", "ry", { str : "2_4_6_8_"     , moves : ["2_","4_","6_","8_"]}                , 7)
  setResource("ry", "竜"  , false, "hi", ""  , { str : "12_34_6_78_9" , moves : ["1","2_","3","4_","6_","7","8_","9"]}, 7)
  setResource("ka", "角"  , true , "ka", "um", { str : "1_3_7_9_"     , moves : ["1_","3_","7_","9_"]}                , 6)
  setResource("um", "馬"  , false, "ka", ""  , { str : "1_23_467_89_" , moves : ["1_","2","3_","4","6","7_","8","9_"]}, 6)
  setResource("hu", "歩"  , true , "hu", "to", { str : "2"            , moves : ["2"]}                                , 1)
  setResource("to", "と"  , false, "hu", ""  , { str : "123468"       , moves : ["1","2","3","4","6","8"]}            , 1)
  _komaTypes)()

images =  
  koma1 : 
    "ou" : "sgl01.png"
    "hi" : "sgl02.png"
    "ka" : "sgl03.png"  
    "ki" : "sgl04.png"
    "gi" : "sgl05.png"
    "ke" : "sgl06.png"
    "ky" : "sgl07.png"
    "hu" : "sgl08.png"
    "ry" : "sgl12.png"
    "um" : "sgl13.png"
    "ng" : "sgl15.png"
    "nk" : "sgl16.png"
    "ny" : "sgl17.png"
    "to" : "sgl18.png"  
  koma2 :
    "ou" : "sgl31.png"
    "hi" : "sgl32.png"
    "ka" : "sgl33.png"  
    "ki" : "sgl34.png"
    "gi" : "sgl35.png"
    "ke" : "sgl36.png"
    "ky" : "sgl37.png"
    "hu" : "sgl38.png"
    "ry" : "sgl42.png"
    "um" : "sgl43.png"
    "ng" : "sgl45.png"
    "nk" : "sgl46.png"
    "ny" : "sgl47.png"
    "to" : "sgl48.png" 

class MoveConvertor
  constructor : ->
    create8Aray = (v) -> 
      _([1..8]).map((i) -> util.posMul(v, i) )
    @moveDef = [
      ["1" , [{ x :  1, y : -1, length : 1}]]
      ["2" , [{ x :  0, y : -1, length : 1}]]
      ["3" , [{ x : -1, y : -1, length : 1}]]
      ["4" , [{ x :  1, y :  0, length : 1}]]
      ["6" , [{ x : -1, y :  0, length : 1}]]
      ["7" , [{ x :  1, y :  1, length : 1}]]
      ["8" , [{ x :  0, y :  1, length : 1}]]
      ["9" , [{ x : -1, y :  1, length : 1}]]
      ["a" , [{ x :  1, y : -2, length : 1}]]
      ["b" , [{ x : -1, y : -2, length : 1}]]
      ["1_", create8Aray({ x :  1, y : -1})]
      ["2_", create8Aray({ x :  0, y : -1})]
      ["3_", create8Aray({ x : -1, y : -1})]
      ["4_", create8Aray({ x :  1, y :  0})]
      ["6_", create8Aray({ x : -1, y :  0})]
      ["7_", create8Aray({ x :  1, y :  1})]
      ["8_", create8Aray({ x :  0, y :  1})]
      ["9_", create8Aray({ x : -1, y :  1})]
    ]
    @moveDef1 = {}
    @moveDef2 = {}
    _(@moveDef).each((pair) =>
      @moveDef1[pair[0]] = pair[1]
      @moveDef2[pair[0]] = _(pair[1]).map((v)->util.reverseVector(v, 2))
      )
    @moveKeysShort = {"1":true, "2":true, "3":true, "4":true, "6":true, "7":true, "8":true, "9":true, "a":true, "b":true}
    @moveKeysLong = {"1_":true, "2_":true, "3_":true, "4_":true, "6_":true, "7_":true, "8_":true, "9_":true}

    cutLength = (playerNumber, positions, gameBoard) ->
      ngLength = 0
      ngPos = _(positions).find((pos) -> util.isntVacant(gameBoard.getKoma pos))
      if ngPos
        toKoma = gameBoard.getKoma(ngPos)
        ngLength = if toKoma.playerNumber is playerNumber then ngPos.length else ngPos.length + 1
      return if ngLength isnt 0  then _(positions).filter((pos) -> pos.length < ngLength) else positions

    @getMovablePos = (playerNumber, komaType, position, gameBoard) ->
      moves = komaTypes[komaType].moveDef.moves
      _moveDef = if playerNumber is 1 then @moveDef1 else @moveDef2
      result = []
      _(moves).each((move)-> 
        positions = _(_moveDef[move]).map((v) -> util.posAdd(position, v))
        positions = _(positions).filter((pos)->util.isInRange(pos))
        positions = cutLength(playerNumber, positions, gameBoard)
        result = result.concat(positions)
      )
      result

    @getPutableCell = (playerNumber, komaType, gameBoard) ->
      positions = []
      util.allPos( (x, y) -> 
        if util.isVacant( gameBoard.getKoma({x:x, y:y}) ) 
          positions.push( {x:x,y:y} )
      )
      if komaType is "hu" or komaType is "ky"
        filter = if playerNumber is 1 then (p) -> p.y isnt 0 else (p) -> p.y isnt 8
      if komaType is "ke"
        filter = if playerNumber is 1 then (p) -> p.y > 1 else (p) -> p.y < 7
      if filter then _(positions).filter(filter) else positions

    @getNari = (playerNumber, komaType, fromPos, toPos) ->
      return "none" if komaTypes[komaType].nari is false
      if playerNumber is 1
        if fromPos.y < 3 or toPos.y < 3
          return "force" if ( komaType is "hu" or komaType is "ky" ) and toPos.y is 0
          return "force" if komaType is "ke" and toPos.y < 2
          return "possible"
        else
          return "none"
      else
        if fromPos.y > 5 or toPos.y > 5
          return "force" if ( komaType is "hu" or komaType is "ky" ) and toPos.y is 8
          return "force" if komaType is "ke" and toPos.y > 6
          return "possible"
        else
          return "none"


moveConvertor = new MoveConvertor()

class Koma
  constructor : (@playerNumber, @komaType) ->
km1 = (komaType) -> new Koma(1, komaType)
km2 = (komaType) -> new Koma(2, komaType)

class Board
  constructor : () ->
    @player1 = { life: 9, time : 600000 }
    @player2 = { life: 9, time : 600000 }
    @komaDai = [[], []]
    @board = [[], [], [], [], [], [], [], [], []]
    @life = [9, 9]

  clearBoard : -> @board = [[], [], [], [], [], [], [], [], []]
  initBoard : (playerNumber) ->
    if playerNumber is 1
      @board = [
        ['','','','','','','','','']
        ['','','','','','','','','']
        ['','','','','','','','','']
        ['','','','','','','','','']
        ['','','','','','','','','']
        ['','','','','','','','','']
        [km1('hu'),km1('hu'),km1('hu'),km1('hu'),km1('hu'),km1('hu'),km1('hu'),km1('hu'),km1('hu')]
        ['',km1('hi'),'','','','','',km1('ka'),'']
        [km1('ky'),km1('ke'),km1('gi'),km1('ki'),km1('ou'),km1('ki'),km1('gi'),km1('ke'),km1('ky')]
      ]
    else if playerNumber is 2
      @board = [
          [km2('ky'),km2('ke'),km2('gi'),km2('ki'),km2('ou'),km2('ki'),km2('gi'),km2('ke'),km2('ky')] 
          ['',km2('ka'),'','','','','',km2('hi'),'']
          [km2('hu'),km2('hu'),km2('hu'),km2('hu'),km2('hu'),km2('hu'),km2('hu'),km2('hu'),km2('hu')]
          ['','','','','','','','','']
          ['','','','','','','','','']
          ['','','','','','','','','']
          ['','','','','','','','','']
          ['','','','','','','','','']
          ['','','','','','','','',''] 
        ]
    else 
      @board = [
        [km2('ky'),km2('ke'),km2('gi'),km2('ki'),km2('ou'),km2('ki'),km2('gi'),km2('ke'),km2('ky')] 
        ['',km2('ka'),'','','','','',km2('hi'),'']
        [km2('hu'),km2('hu'),km2('hu'),km2('hu'),km2('hu'),km2('hu'),km2('hu'),km2('hu'),km2('hu')]
        ['','','','','','','','','']
        ['','','','','','','','','']
        ['','','','','','','','','']
        [km1('hu'),km1('hu'),km1('hu'),km1('hu'),km1('hu'),km1('hu'),km1('hu'),km1('hu'),km1('hu')]
        ['',km1('hi'),'','','','','',km1('ka'),'']
        [km1('ky'),km1('ke'),km1('gi'),km1('ki'),km1('ou'),km1('ki'),km1('gi'),km1('ke'),km1('ky')]       
      ]

  duplicate : =>
    board = new Board()
    for y in [0...9]
      for x in [0...9]
        if @board[x][y]
          board.board[x][y] = new Koma(@board[x][y].playerNumber, @board[x][y].komaType)
        else
          board.board[x][y] = ''
    board.komaDai[0] = board.komaDai[0].concat(@komaDai[0])
    board.komaDai[1] = board.komaDai[1].concat(@komaDai[1])
    board.life[0] = @life[0]
    board.life[1] = @life[1]
    return board

  getKoma : (position) -> 
    try
      @board[position.y][position.x]
    catch e
      console.log("get:#{position.x}, #{position.y}")
      throw e

  getExistsHuColumn : (playerNumber) ->
    result = {}
    for y in [0...9]
      for x in [0...9]
        koma = @board[y][x]
        if koma and koma.playerNumber is playerNumber and koma.komaType is "hu"
          result[x] = true
    console.log result
    return result



  putKoma : (koma, position) =>
    @board[position.y][position.x] = koma

  removeKoma : (position) =>
    @board[position.y][position.x] = undefined

  getKomaFromKomadai : (playerNumber, komaType) ->
    find = false
    console.log komaType
    index = if playerNumber is 1 then 0 else 1
    koma = _(@komaDai[index]).find((koma) -> koma.komaType is komaType)
    @komaDai[index] = _(@komaDai[index]).filter((koma) -> 
      return true if find
      return !(find = true) if koma.komaType is komaType
      return true)
    return koma

  putKomaToKomadai : (playerNumber, koma) ->
    console.log "putKomaToKomadai"
    koma = new Koma(koma.playerNumber, koma.komaType)
    koma.playerNumber = playerNumber
    type = komaTypes[koma.komaType]
    console.log type
    koma.komaType = komaTypes[koma.komaType].resourceId
    if playerNumber is 1
      @komaDai[0].push koma
      @komaDai[0] = _(@komaDai[0]).sortBy((koma)->komaTypes[koma.komaType].value)
    else
      @komaDai[1].push koma
      @komaDai[1] = _(@komaDai[1]).sortBy((koma)->komaTypes[koma.komaType].value)

  removeKomaFromKomadai : (playerNumber, komaType) =>
    console.log("removeKomaFromKomadai : " + playerNumber + " : " + komaType)
    find = false
    index = if playerNumber is 1 then 0 else 1
    koma = _(@komaDai[index]).find((koma) -> koma.komaType is komaType)
    @komaDai[index] = _(@komaDai[index]).filter((koma) -> 
      return true if find
      return !(find = true) if koma.komaType is komaType
      return true)
    return koma


  getKomaWithPosition : (predicate) =>
    result = []
    for y in [0...9]
      for x in [0...9]
        koma = @board[y][x]
        if koma and predicate(koma) 
          result.push({koma : koma, position : {x:x,y:y} })
    result

  getPlayerKoma : (playerNumber) =>
    @getKomaWithPosition( (koma) -> koma.playerNumber is playerNumber )

  getOu : (playerNumber) =>
    ou = @getKomaWithPosition( (koma) -> koma.playerNumber is playerNumber and koma.komaType is "ou" )
    console.log "ouNum:" +ou.length
    return if ou[0] then ou[0] else null

class Game
  constructor : (@playerNumber) ->
    @board = new Board()
    @board.initBoard(@playerNumber)
    @judge = new SyogiJudgement()
    @updateGameInfo = ->

  getPlayerInfoCommand : =>
    return {
      method : "adjustTime"
      player1 : @board.player1
      player2 : @board.player2
    }

  start : () =>
    @turn  = 1
    @state = "playing"
    @currentTime = Date.now()

    updateTimer = () =>
      return if @state isnt "playing"
      oldTime = @currentTime
      @currentTime = Date.now()
      player = @getCurrentPlayer()
      player.time -= @currentTime - oldTime
      graphicApi.updateGameInfo(@getPlayerInfoCommand())
      if player.time < 0
        socket.emit('game', 
          method  : "timeout"
          playerNumber : 2-@turn%2
        )
      window.setTimeout(updateTimer, 500)
    updateTimer()

  isPlayerTurn : () -> 2-@turn%2 is @playerNumber

  nextTurn : () -> @turn++

  setGameInfoUpdater : (updater) -> @updateGameInfo = updater

  end : ->
    console.log "end game"
    @state = "end"

  moveKoma : (moveInfo, check) =>
    bkBoard = @board.duplicate()
    @board.getKoma moveInfo.to.position
    fromKoma = @board.getKoma moveInfo.from.position
    toKoma = @board.getKoma moveInfo.to.position
    if util.isntVacant toKoma
      @board.putKomaToKomadai(2-@turn%2, toKoma)
    @board.removeKoma moveInfo.from.position
    
    putKoma = new Koma(fromKoma.playerNumber, fromKoma.komaType)
    putKoma.komaType = moveInfo.to.komaType
    @board.putKoma(putKoma, moveInfo.to.position)
    
    if @judge.isOute(@, 2-@turn%2)
      console.log "王手無視"
      @board = bkBoard
      return false
    if @judge.isOute(@, 2-@turn%2)
      console.log "oute"
    if check
      @board = bkBoard
    else
      @turn++
    return true

  canMoveKoma : (moveInfo) => @moveKoma(moveInfo, true)

  putKoma : (moveInfo, check) =>
    bkBoard = @board.duplicate()
    fromKoma = @board.getKomaFromKomadai( 2-@turn%2, moveInfo.to.komaType )
    @board.putKoma(fromKoma, moveInfo.to.position)
    if @judge.isOute(@, 2-@turn%2)
      console.log "王手無視"
      @board = bkBoard
      return false
    if check
      @board = bkBoard
    else
      @turn++
    return true

  canPutKoma : (moveInfo) => @putKoma(moveInfo, true)

  isTsumi : -> @judge.isTsumi(@, 2-@turn%2)
  getCurrentPlayer : => if @turn%2 is 1 then @board.player1 else @board.player2

class KifuPlayer
  constructor : (@kifu, @playerNumber, @refresh) ->
    @index = 0
    @currentTime = Date.now()
    @board = new Board()
    @board.initBoard()
    @boards = []
    @elapsedTime = 0
    currentBoard = @board
    @boards.push( @board )
    _( @kifu ).each( (te) => @readTe te )

  getPlayerInfo : =>
    board = @boards[@boards.length-1]
    if @currentPlayerNumber is 1
      player1 = { life : board.player1.life, time : board.player1.time + @currentTime - Date.now() - @elapsedTime }
      player2 = board.player2
    else
      player1 = board.player1
      player2 = { life : board.player2.life, time : board.player2.time + @currentTime - Date.now() - @elapsedTime }
    return { player1 : player1, player2 : player2 }

  getCurrentBoard : -> @boards[@index]

  addKifu : (te) -> @readTe te

  readTe : (te) ->
    currentBoard = @boards[@boards.length-1]
    currentBoard = currentBoard.duplicate()
    currentPlayerNumber = 2-te.turn%2
    currentBoard.player1 = te.playerInfo.player1
    currentBoard.player2 = te.playerInfo.player2

    @currentTime = Date.now()
    currentBoard.turn = te.turn
    if te.info.type is "moveKoma"
      if not te.foul
        if te.info.from.x isnt -1
          currentBoard.removeKoma te.info.from
          toKoma = currentBoard.getKoma( te.info.to )
        else
          currentBoard.removeKomaFromKomadai(currentPlayerNumber, te.info.koma)

        if toKoma
          currentBoard.removeKoma( te.info.to )
          currentBoard.putKomaToKomadai(currentPlayerNumber, new Koma(currentPlayerNumber, toKoma.komaType ) )
        currentBoard.putKoma( new Koma( currentPlayerNumber, te.info.koma), te.info.to )
        currentBoard.emphasisPosition = te.info.to
        @currentPlayerNumber = 2-(te.turn+1)%2
      else 
        currentBoard.life[currentPlayerNumber] = currentBoard.life[currentPlayerNumber] - 1
        @currentPlayerNumber = 2-te.turn%2
    else if te.info.type is "endGame"
      currentBoard.endGame = true

    @boards.push( currentBoard )

  toStart : ->
    if @index isnt 0
      @index = 0
      @refresh( @index, @boards[@index] )
  next : ->
    @index++
    @refresh( @index, @boards[@index] )
    @activateUpdateTimer()
  back : -> 
    @index--
    @refresh( @index, @boards[@index] )
  toEnd : ->
    if @index isnt @boards.length - 1
      @index = @boards.length - 1
      @refresh( @index, @boards[@index] )
      @activateUpdateTimer()
  toIndex : (index) ->
    if @index isnt index
      @index = index
      @boards[index]
      @refresh( @index, @boards[@index] )
      if @index is @boards.length - 1
        @activateUpdateTimer()

  activateUpdateTimer : ()->
    updateTimer = () =>
      return if @index isnt @boards.length-1
      return if @boards[@boards.length-1].endGame
      return if kifuApi.state isnt "replay"
      graphicApi.updateGameInfo(@getPlayerInfo())
      window.setTimeout(updateTimer, 500)
    updateTimer()
    
class SyogiJudgement
  constructor : () ->

  canMove = (game, playerNumber, moveInfo) ->
    return false if game.state isnt "playing"
    return false if game.turn % 2 isnt playerNumber % 2
    fromKoma = game.board.getKoma(moveInfo.from.position)
    toKomaType = komaTypes[moveInfo.to.komaType]
    return false if util.isInRange(moveInfo.from.position) or util.isInRange(moveInfo.to.position)
    return false if !fromKoma
    return false if fromKoma.komaType.name isnt moveInfo.from.komaType
    return false if toKomaType.name isnt fromKoma.komaType.name and toKomaType.resourceId isnt fromKoma.komaType.name
    toKoma   = game.board.getKoma(moveInfo.to.position)
    return false if toKoma and toKoma.playerNumber is playerNumber
    pos = _(moveConvertor.getMovablePos(playerNumber, moveInfo.from.komaType, moveInfo.from.position)).find((pos)->util.posEq(pos, moveInfo.to.position))
    return true if pos 
    return false

  isOute : (game, playerNumber) =>
    kikiMap = {}
    enemyPlayerNumber = if playerNumber is 1 then 2 else 1
    _( game.board.getPlayerKoma( enemyPlayerNumber ) ).each( (komaInfo) ->
      postions = _(moveConvertor.getMovablePos(enemyPlayerNumber, komaInfo.koma.komaType, komaInfo.position, game.board))
      postions = _(postions).map((pos)-> util.posToStr(pos))
      _( postions ).each( (p) -> kikiMap[p] = true )
    )
    ou = game.board.getOu playerNumber
    ouPos = util.posToStr ou.position
    console.log "playerNumber:"+playerNumber
    console.log "ouPos:"+ouPos
    console.log kikiMap
    return if kikiMap[ouPos] then true else false

  isTsumi : (game, playerNumber) =>
    return _( game.board.getPlayerKoma( playerNumber ) ).some( (komaInfo) ->
      positions = moveConvertor.getMovablePos(playerNumber, komaInfo.koma.komaType, komaInfo.position, game.board)
      return _(positions).some( (pos) -> 
        moveInfo = 
          from : 
            position : komaInfo.position
            komaType : komaInfo.koma.komaType
          to   :
            position : pos
            komaType : komaInfo.koma.komaType
        return game.canMoveKoma moveInfo
      )
    )

game = null
gameApi.startGame = ( playerNumber ) ->
  graphicApi.clearTable()
  game = new Game(playerNumber)
  game.start()
  gameApi.game = game
  graphicApi.redrawKoma( game.board, game.state, game.turn )

gameApi.endGame = ( info ) ->
  game.end()
  graphicApi.redrawKoma( game.board, game.state, game.turn )

gameApi.tryMoveKoma = (moveInfo) -> 
  socket.emit('game', 
    method  : "moveKoma"
    args    : moveInfo
  )

gameApi.moveKoma = (moveInfo) -> 
  game.moveKoma moveInfo
  graphicApi.redrawKoma( game.board, game.state, game.turn )


gameApi.tryPutKoma = (moveInfo) -> 
  socket.emit('game', 
    method  : "putKoma"
    args    : moveInfo
  )

gameApi.doCommand = (commands) -> 
  console.log "do command"
  isFoul = false
  bkInvated = graphicApi.invatedPosition
  graphicApi.invatedPosition = null
  _(commands).each((command) ->
    console.log command
    if command.method is "removeKomaFromKomadai"
      game.board.removeKomaFromKomadai(command.playerNumber, command.koma.komaType)
    else if command.method is "putKomaToKomadai"
      game.board.putKomaToKomadai(command.playerNumber, command.koma)
    else if command.method is "removeKoma"
      game.board.removeKoma(command.position)
      graphicApi.invatedPosition = command.position
    else if command.method is "putKoma"
      game.board.putKoma(command.koma, command.position)
      graphicApi.invatedPosition = command.position
    else if command.method is "adjustTime"
      game.board.player1.time = command.player1.time
      game.board.player2.time = command.player2.time
      graphicApi.updateGameInfo(command)
    else if command.method is "foul"
      game.getCurrentPlayer().life--
      graphicApi.updateGameInfo(game.getPlayerInfoCommand())
      isFoul = true
  )
  if isFoul
    graphicApi.initializeTableState()
    graphicApi.invatedPosition = bkInvated
  else
    game.nextTurn()
  graphicApi.redrawKoma( game.board, game.state, game.turn )

gameApi.putKoma = (moveInfo) ->
  console.log "put koma"
  game.putKoma moveInfo
  graphicApi.redrawKoma( game.board, game.state, game.turn )

graphicApi.updateGameInfo = (command) ->
  $("#gameInfo1").html("")
  $("#gameInfo2").html("")
  graphicApi.getGameInfoDiv(1).html( "▲ 時間："+computeDuration(command.player1.time) + " &nbsp;&nbsp;&nbsp;反則：" + command.player1.life )
  graphicApi.getGameInfoDiv(2).html( "△ 時間："+computeDuration(command.player2.time) + " &nbsp;&nbsp;&nbsp;反則：" + command.player2.life )

graphicApi.redrawKoma = (board, state, turn) ->
  $board = $('#board')
  komadai1 = graphicApi.getKomaDai(1)
  komadai2 = graphicApi.getKomaDai(2)
  graphicApi.initializeTableState()
  graphicApi.clearKoma()
  tmp = ""
  _(board.komaDai[0]).each( (koma) ->
    image = graphicApi.getKomaImage(koma)
    if tmp is koma.komaType
      image.css({"margin-left" : "-50px"})
    tmp = koma.komaType
    if turn % 2 is koma.playerNumber % 2 and state is "playing"
      ( (komaType)-> image.bind("click", -> graphicApi.showPutableCell(1, komaType, board)))(tmp)
    komadai1.append(image)
  )
  tmp = ""
  _(board.komaDai[1]).each( (koma) ->
    image = graphicApi.getKomaImage(koma)
    if tmp is koma.komaType
      image.css({"margin-left" : "-50px"})
    tmp = koma.komaType
    if turn % 2 is koma.playerNumber % 2 and state is "playing"
      ( (komaType)-> image.bind("click", -> graphicApi.showPutableCell(2, komaType, board)))(tmp)
    komadai2.append(image)
  )

  for y in [0...9]
    for x in [0...9]
      xx = ""+(9-x)
      yy = ""+(y+1)
      td = graphicApi.getCell(xx, yy)
      koma = board.getKoma({ x : xx - 1 , y : yy - 1 })
      if koma
        image = graphicApi.getKomaImage(koma)
        if turn % 2 is koma.playerNumber % 2 and state is "playing"
          ( (pos) -> image.bind("click", -> graphicApi.showMovableCell(pos, board))
          )( {x : xx-1, y:yy-1} )
        td.append(image)

graphicApi.drawKomaDaiKoma = (playerNumber, komaList) ->
  komadai = graphicApi.getKomaDai(playerNumber)
  tmp = ""
  _( komaList ).each( (koma) ->
    image = graphicApi.getKomaImage(koma)
    if tmp is koma.komaType
      image.css({"margin-left" : "-50px"})
    tmp = koma.komaType
    if game.turn % 2 is koma.playerNumber % 2
      ( (komaType) -> image.bind("click", -> graphicApi.showPutableCell(1, komaType, game.board)))(tmp)
    komadai.append(image)
  )

graphicApi.showMovableCell = (fromPos, gameBoard) ->
  console.log "show movable"
  graphicApi.initializeTableState()
  koma = gameBoard.getKoma(fromPos)
  td = graphicApi.getCell(fromPos.x+1, fromPos.y+1)
  td.css({"background-color" : "rgba(256,150,150,0.5)"})
  console.log "get movable"
  positions = moveConvertor.getMovablePos(koma.playerNumber, koma.komaType, fromPos, gameBoard)
  _(positions).each((pos) ->
    td = graphicApi.getCell(pos.x+1, pos.y+1)
    td.css({"background-color" : "rgba(256,150,150,0.5)"})
    (->
      fromPos = util.posDup fromPos
      toPos   = util.posDup pos
      fromKoma = gameBoard.getKoma fromPos
      moveInfo = 
        from : 
          position : fromPos
          komaType : fromKoma.komaType
        to   :
          position : toPos
          komaType : fromKoma.komaType
      td.bind("click", ->
        nari = moveConvertor.getNari(koma.playerNumber, koma.komaType, moveInfo.from.position, moveInfo.to.position)
        if nari is "force"
          moveInfo.to.komaType = komaTypes[moveInfo.to.komaType].nariId
        else if nari is "possible"
          $("#nariDiv").show()
          $("#modal-overlay").show()
          $("#nariDiv").css( { "background-color": "#FFFFFF", "opacity" : 0 } )
          $("#modal-overlay").css( { "background-color": "#000000", "opacity" : 0 } )
          $("#nariDiv").animate( { "background-color": "#FFFFFF", "opacity" : 0.95 }, 120 )
          $("#modal-overlay").animate( { "background-color": "#000000", "opacity" : 0.3 }, 120 )
          graphicApi.nari = (nari) ->
            $("#modal-overlay").hide()
            $("#nariDiv").hide()
            moveInfo.to.komaType = komaTypes[moveInfo.to.komaType].nariId if nari
            gameApi.tryMoveKoma(moveInfo)
          return
        gameApi.tryMoveKoma(moveInfo)
      )
    )()
  )

graphicApi.showPutableCell = (playerNumber, komaType, gameBoard) ->
  console.log "showPutableCell"
  graphicApi.initializeTableState()
  positions = moveConvertor.getPutableCell(playerNumber, komaType, gameBoard)
  if komaType is "hu"
    columns = gameBoard.getExistsHuColumn(playerNumber)
    positions = _(positions).filter( (p) -> if columns[p.x] then false else true )

  _(positions).each((pos) ->
    td = graphicApi.getCell(pos.x+1, pos.y+1)
    td.css({"background-color" : "rgba(256,150,150,0.5)"})
    (->
      moveInfo = 
        to   :
          position : pos
          komaType : komaType
      td.bind("click", ->gameApi.tryPutKoma(moveInfo))
    )()
  )

graphicApi.clearTable = ->
  graphicApi.invatedPosition = null
  board = $('#board')
  board.html("")
  for y in [0...9]
    yy = ""+(y+1)
    row = $("<div id='row_#{yy}'></div>")
    board.append(row)
    for x in [0...9]
      xx = ""+(9-x)
      cell = $("<div id='cell_#{xx}_#{yy}' class='cell'></div>").offset({ top : y*64, left : x*60 })
      row.append(cell)

graphicApi.clearKoma = ->
  allKoma = $(".koma")
  allKoma.unbind("click")
  allKoma.remove()

graphicApi.initializeTableState = ->
  console.log "init cellstate"
  allTd = $(".cell")
  allTd.css("background-color", "transparent")
  allTd.unbind("click")
  if graphicApi.invatedPosition
    console.log "mark invated cell"
    td = graphicApi.getCell(graphicApi.invatedPosition.x+1, graphicApi.invatedPosition.y+1)
    td.css({"background-color" : "rgba(100,256,256,0.5)"})

graphicApi.flipBord = (flip) -> 
  if flip
    $("#boardImg").css( { "transform" : "rotate3d(0, 0, 1, 180deg)"} )
  else
    $("#boardImg").css( { "transform" : "rotate3d(0, 0, 1, 0deg)"} )
  graphicApi.flip = flip
  graphicApi.redrawKoma( gameApi.game.board, gameApi.game.state, gameApi.game.turn )

graphicApi.getKomaImage = (koma) ->
  if graphicApi.flip
    if koma.playerNumber is 2
      $("<img class='koma' src='./images/koma/60x64/#{images.koma1[koma.komaType]}'>")
    else 
      $("<img class='koma' src='./images/koma/60x64/#{images.koma2[koma.komaType]}'>")
  else 
    if koma.playerNumber is 1
      $("<img class='koma' src='./images/koma/60x64/#{images.koma1[koma.komaType]}'>")
    else 
      $("<img class='koma' src='./images/koma/60x64/#{images.koma2[koma.komaType]}'>")

graphicApi.getKomaDai = (playerNumber) -> 
  if graphicApi.flip
    return $('#komadai'+( if playerNumber is 1 then "2" else "1"))
  else
    return $('#komadai'+( if playerNumber is 1 then "1" else "2"))

graphicApi.getGameInfoDiv = (playerNumber) -> 
  if graphicApi.flip
    return $('#gameInfo'+( if playerNumber is 1 then "2" else "1"))
  else
    return $('#gameInfo'+( if playerNumber is 1 then "1" else "2"))

graphicApi.getPos = (pos) ->
  if graphicApi.flip 
    return 9 - pos
  else
    return pos - 1

graphicApi.getCell = (x, y) -> 
  if graphicApi.flip 
    $("#cell_#{(10-x)}_#{(10-y)}")
  else
    $("#cell_#{x}_#{y}")

graphicApi.hideModal = ->
  $("#modal-window").hide()
  $("#modal-overlay").hide()
  if graphicApi.afterHideModal
    graphicApi.afterHideModal()
    graphicApi.afterHideModal = undefined


kifuApi.replayKifu = (kifu) ->
  kifuApi.state = "replay"
  $('#kifuSelectBox').html("")
  $("#kifuInfoDiv").show()
  $("#kifuReplayDiv").show()
  refresh = (index, board) ->
    graphicApi.updateGameInfo( { player1 : board.player1, player2 : board.player2 } )
    $('#kifuSelectBox').val(index)
    kifuLength = $("#kifuSelectBox").children().length - 1
    if board.emphasisPosition
      graphicApi.invatedPosition = board.emphasisPosition
    else
      graphicApi.invatedPosition = null
    graphicApi.redrawKoma( board, 1 , "replay" )
    $('#toStartButton').prop('disabled', index is 0)
    $('#backButton').prop('disabled', index is 0)
    $('#nextButton').prop('disabled', kifuLength is index )
    $('#toEndButton').prop('disabled', kifuLength is index )

  kifuApi.kifuPlayer = new KifuPlayer( kifu, 1, refresh )
  kifuApi.kifuPlayer.activateUpdateTimer()
  graphicApi.redrawKoma( kifuApi.kifuPlayer.getCurrentBoard(), 1 , "replay" )
  index = 0

  $('#kifuSelectBox').unbind("change")
  $('#kifuSelectBox').bind("change", () ->
    index = $('#kifuSelectBox option:selected').val()
    kifuApi.kifuPlayer.toIndex( parseInt(index) )
  )
  option = $("<option value='#{index}'>対局開始</option>")
  index++
  $("#kifuSelectBox").append(option)
  _( kifu ).each( (te) ->
    if te.info.type is "moveKoma"
      if not te.foul
        value = "#{te.turn} : " + (te.info.from.x+1) + (te.info.from.y+1) + (te.info.to.x+1) + (te.info.to.y+1) + te.info.koma
      else
        value = "#{te.turn} : [反則] " + (te.info.from.x+1) + (te.info.from.y+1) + (te.info.to.x+1) + (te.info.to.y+1) + te.info.koma
      option = $("<option value='#{index}'>#{value}</option>")
    else if te.info.type is "endGame"
      value = "player#{te.info.winPlayerNumber} win. (#{te.info.reason})"
      option = $("<option value='#{index}'>#{value}</option>")
    index++
    $("#kifuSelectBox").append(option)
  )

kifuApi.addKifu = (te) -> 
  kifuApi.kifuPlayer.addKifu te
  i = $("#kifuSelectBox").children().length
  if te.info.type is "moveKoma"
    if not te.foul
      value = "#{te.turn} : " + (te.info.from.x+1) + (te.info.from.y+1) + (te.info.to.x+1) + (te.info.to.y+1) + te.info.koma
    else
      value = "#{te.turn} : [反則] " + (te.info.from.x+1) + (te.info.from.y+1) + (te.info.to.x+1) + (te.info.to.y+1) + te.info.koma
    option = $("<option value='#{i}'>#{value}</option>")
  else if te.info.type is "endGame"
    value = "player#{te.info.winPlayerNumber} win. (#{te.info.reason})"
    option = $("<option value='#{i}'>#{value}</option>")
  $("#kifuSelectBox").append(option)

kifuApi.toStart         = -> kifuApi.kifuPlayer.toStart()
kifuApi.next            = -> kifuApi.kifuPlayer.next()
kifuApi.back            = -> kifuApi.kifuPlayer.back()
kifuApi.toEnd           = -> kifuApi.kifuPlayer.toEnd()

kifuApi.setElapsedTime  = (time) -> kifuApi.kifuPlayer.elapsedTime = time
kifuApi.stop            = -> kifuApi.state = "stop"
