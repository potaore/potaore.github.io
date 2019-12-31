//フィールドの大きさ定義
SizeX = 6;
SizeY = 14;

//グラフィック定義
ItemGraphic = [];
ItemGraphic[0] = "□";
ItemGraphic[1] = "■";
ItemGraphic[2] = "●";
ItemGraphic[3] = "▲";
ItemGraphic[4] = "★";

//方向の定義
Left = 0;
Up = 1;
Right = 2;
Down = 3;
Rotate = 9;

//方向に対応した相対座標
directionConv = [];
directionConv[Left] = [-1, 0];
directionConv[Up] = [0, -1];
directionConv[Right] = [1, 0];
directionConv[Down] = [0, 1];

//キー入力情報格納場所
Key = null;

//現在の局面
var field;

//落下中のぷよ
var puyo;

//キー入力から方向へ変換
keyDirectionConv = [];
keyDirectionConv[37] =Left;
keyDirectionConv[38] =Up;
keyDirectionConv[39] =Right;
keyDirectionConv[40] =Down;
keyDirectionConv[90] = Rotate;

//ゲームの状態定義
GameState = [];
//落下中のぷよを操作できる状態
GameState.Wait = 0;
//配置が確定して落下しているとき
GameState.Fall = 1;
//消す処理を行っているとき
GameState.Vanish = 2;
//ポーズ
GameState.Pause = 3;
//現在のゲームの状態
var gamestate = GameState.Wait;
var gamestateLog = 0;

var Field = function(){
	
	var me = this;
	me.map = (function(sizeX, sizeY){
		var result, i, j;
		result = [];
		for(i = 0; i < sizeX; i++){
			result[i] = [];
			for(j = 0; j < sizeY; j++){
				result[i][j] = 0;
			}
		}
		return result;
	})(SizeX, SizeY);
	
	me.draw = function(){
		var i, j, str, drawMap;
		
		drawMap = duplicateMap();
		
		if(gamestate === GameState.Wait){
			drawMap[puyo.x][puyo.y] = puyo.color;
			drawMap[puyo.getPartnerX()][puyo.getPartnerY()] = puyo.partnerColor;
		}
		
		str = "";
		for(i = 0; i < SizeY; i++){
			for(j = 0; j < SizeX; j++){
				str += ItemGraphic[drawMap[j][i]];
			}
			str += "<br/>";
		}
		document.body.innerHTML = str;
	};
	
	function duplicateMap(){
		var result, i, j;
		result = [];
		for(i = 0; i < SizeX; i++){
			result[i] = [];
			for(j = 0; j < SizeY; j++){
				result[i][j] = me.map[i][j];
			}
		}
		return result;
	}
	
	
	me.setPuyo = function(){
		me.map[puyo.x][puyo.y] = puyo.color;
		me.map[puyo.getPartnerX()][puyo.getPartnerY()] = puyo.partnerColor;
		gamestate = GameState.Fall;
	}
	
	me.fall = function(){
		var x, y, k, temp;
		for(x = 0; x < SizeX; x++){
			for(y = SizeY - 1; y >= 0; y--){
				if(isVacant(x, y)){
					for(k = y - 1; k >= 0; k--){
						if(!isVacant(x, k)){
							temp = me.map[x][k];
							me.map[x][k] = me.map[x][y];
							me.map[x][y] = temp;
							break;
						}
					}
				}
			}
		}
	}
	
	me.vanish = function(){
		var x, y, num, i, result;
		var checkMap = [];
		var vanishList = [];
		for(x = 0; x < SizeX; x++){
			checkMap[x] = [];
			for(y = 0; y < SizeY; y++){
				checkMap[x][y] = false;
			}
		}

		for(x = 0; x < SizeX; x++){
			for(y = 0; y < SizeY; y++){
				checkMap[x][y] = true;
				vanishList = [];
				if(!isVacant(x, y)){
					colorCount(x, y, checkMap, vanishList);
					if(vanishList.length >= 4){
						result = true;
						for(i = 0; i < vanishList.length; i++){
							me.map[vanishList[i][0]][vanishList[i][1]] = 0;
						}
					}
				} else{
				}
			}
		}
		return result;
	}
	
	function colorCount(x, y, checkMap, vanishList){
		var i, nextX, nextY, num;
		checkMap[x][y] = true;
		vanishList[vanishList.length] = [x, y];
		for(i = 0; i < 4; i++){
			nextX = x + directionConv[i][0];
			nextY = y + directionConv[i][1];
			if(isInRange(nextX, nextY) && !checkMap[nextX][nextY]){
				if(me.map[x][y] == me.map[nextX][nextY]){
					colorCount(nextX, nextY, checkMap, vanishList);
				}
			}
		}
	}
}

field = new Field();

var Puyo = function(){
	var me = this;
	me.x = 3;
	me.y = 0;
	me.color = getRandomColor();
	me.partnerColor = getRandomColor();
	me.direction = Down;
	
	var fallcount = 0;
	me.tryFall = function(){
		var result;
		result = true;
		fallcount++;
		if(fallcount >= 5){
			fallcount = 0;
			if(checkFallable()){
				me.y++;
			} else {
				
				result = false;
			}
		}
		return result;
	}
	
	function checkFallable(){
		var px, py;
		px = me.getPartnerX();
		py = me.getPartnerY();
		if( checkMovable(me.x, me.y + 1) && checkMovable(px, py + 1) ){
			return true;
		} else {
			return false;
		}
	}
	
	function getRandomColor(){
		var result;
		result =  Math.floor(Math.random() * 4) + 1;
		return result;
	}
	
	me.getPartnerX = function(){
		return me.x + directionConv[me.direction][0];
	}
	me.getPartnerY = function(){
		return me.y + directionConv[me.direction][1];
	}
	
	me.rotate = function(){
		var dc = (me.direction + 1) % 4;
		if(checkMovable(me.x + directionConv[dc][0], me.y + directionConv[dc][1])){
			me.direction = dc;
		}
	};
	
	me.tryMove = function(direction){
		var px, py;
		if(direction == Down){
			fallcount = 6;
		} else if(direction == Left){
			px = me.getPartnerX();
			py = me.getPartnerY();
			if( checkMovable(me.x - 1, me.y) && checkMovable(px - 1, py) ){
				me.x--;
			}
		} else if(direction == Right){
			px = me.getPartnerX();
			py = me.getPartnerY();
			if( checkMovable(me.x + 1, me.y) && checkMovable(px + 1, py) ){
				me.x++;
			}
		} else if(direction == Rotate) {
			me.rotate();
		}
	}
}
puyo = new Puyo();

function isInRange(x, y){
	return 0 <= x && x < SizeX && 0 <= y && y < SizeY;
}

function checkMovable(x, y){
	return isInRange(x, y) && isVacant(x, y);
}

function isVacant(x, y){
	return field.map[x][y] == 0;
}

function loopProcess(){
	if(Key != null && Key.keyCode == 80){
		if(gamestate != GameState.Pause){
			gamestateLog = gamestate;
			gamestate =  GameState.Pause;
		} else {
			gamestate = gamestateLog;
		}

	}
	if(gamestate === GameState.Wait){
		if(Key != null){
			puyo.tryMove(keyDirectionConv[Key.keyCode]);
		}
		if(!puyo.tryFall()){
			field.setPuyo();
			gamestate = GameState.Fall;
		}
	} else if(gamestate === GameState.Fall){
		field.fall();
		gamestate = GameState.Vanish;
	} else if(gamestate === GameState.Vanish){
		if(field.vanish()){
			gamestate = GameState.Fall;
		} else {
			gamestate = GameState.Wait;
			puyo = new Puyo();
		}
		
	}
	Key = null
	field.draw();
	setTimeout(loopProcess, 100);
}


window.onload = function(){
	window.onkeydown = function(key){
		Key = key;
		if (typeof Key === void 0 || !(Key != null)) {
			Key = window.event;
		}
	};
	loopProcess();
}
