/*Htmlのテーブルのマップ*/
function MapTable(gameSetting, observer){
	var me = this;
	var gameObserver = new Object();
	var game = new Game(gameObserver);
	var messageArea = new MessageArea();

	//表示する内容
	me.elem = $('<div></div>');

	//ゲーム開始のメソッド
	me.start = function(){return game.start(gameSetting);};

	//ゲームオーバー時の処理
	gameObserver.gameOver = function(){
		timer.stop();
		messageArea.gameOver();
		observer.gameOver();
	};
	//クリア時の処理
	gameObserver.cleared = function(){
		var time = timer.stop() + 50000;
		var sharpModePoint = gameSetting.isSharpMode ? 8000 : 0;
		var loopFieldPoint = gameSetting.isLoopField ? 2000 : 0;
		var score = parseInt(
				((gameSetting.sizeX * gameSetting.sizeY - game.mineNum) * game.mineNum * game.mineNum)
				/ ((time / 1000) * (gameSetting.sizeX * gameSetting.sizeY * gameSetting.sizeX * gameSetting.sizeY - game.mineNum * game.mineNum))
				* (10000 + sharpModePoint + loopFieldPoint));

		messageArea.cleared(score);
		observer.cleared();
	};
	//ゲーム開始時（初クリック）の処理
	gameObserver.start = function(){
		messageArea.start();
		timer.start();
	};

	//残り地雷数表示フィールド生成
	var leftmine =(
			function createLeftMine(){
				var result = new Object();
				result.elem = $('<span></span>');
				return result;
			})();

	//タイマー表示フィールド生成
	var timer = new Timer();

	//親テーブル生成
	var table = (
			function createTable(){
				var result = new Object();
				result.elem =  $('<table cellspacing="0" unselectable = "on"></table>');
				return result;
			})();

	//マップ生成
	var cells = (
			function createCells(sizeX,sizeY,clickevent,rightclickevent){
				var i,j;
				var result = [];
				var TableCellCash = TableCell;
				var elemCash = table.elem;
				var row;
				for(j = 0; j < sizeX ; j++){
					result[j] = [];
				}
				for(i = 0; i < sizeY ; i++){
					row = $('<tr></tr>');
					elemCash.append(row);
					for(j = 0; j < sizeX ; j++){
						result[j][i] = new TableCellCash(j,i,clickevent,rightclickevent);
						row.append(result[j][i].elem);
					}
				}
				return result;
			})(gameSetting.sizeX, gameSetting.sizeY, clickevnt, rightclickevent);


	//作成した要素をdivに格納
	(function setElem(elem){
		elem.append(messageArea.elem);
		elem.append("<br/>LeftMines ： ");
		elem.append(leftmine.elem);
		elem.append("　 　time ： ");
		elem.append(timer.elem);
		elem.append(table.elem);
	})(me.elem);

	//受け取るイベントの定義
	function clickevnt(x,y){game.clickLeft(x,y);}
	function rightclickevent(x,y){game.clickRight(x,y);}
	gameObserver.mineNumChanged = function(num){
		leftmine.elem.empty();
		leftmine.elem.append(num);
	};
	gameObserver.cellChangeState_Non = function(x,y){cells[x][y].Non();};
	gameObserver.cellChangeState_Flg = function(x,y){cells[x][y].Flg();};
	gameObserver.cellChangeState_Question = function(x,y){cells[x][y].Question();};
	gameObserver.cellChangeState_Digged = function(x,y,num){cells[x][y].Digged(num);};
	gameObserver.cellChangeState_Mine = function(x,y){cells[x][y].Mine();};
	gameObserver.cellChangeState_FlgMiss = function(x,y,num){cells[x][y].FlgMiss(num);};

	//sharpモードの場合、周囲2マスに枠を表示するようにする
	(function(){
		var i,j;
		var cell;
		if(gameSetting.isSharpMode){
			for(i = 0; i < gameSetting.sizeY; i++){
				for(j = 0; j < gameSetting.sizeX; j++){
					cell = cells[j][i];
					cell.elem.mouseover(createBorderChangeEvent(j,i,cells, "#00aaaa"));
					cell.elem.mouseout(createBorderChangeEvent(j,i,cells, ""));
				}
			}
		}
	})();


	//周囲2マスに枠の色切り替イベントを生成
	function createBorderChangeEvent(x, y, cells, col){

		var command = getCommand(gameSetting.sizeX, gameSetting.sizeY, gameSetting.isLoopField);
		var c00 = getCell(x-2,y-2);
		var c10 = getCell(x-1,y-2);
		var c20 = getCell(x,y-2);
		var c30 = getCell(x+1,y-2);
		var c40 = getCell(x+2,y-2);
		var c41 = getCell(x+2,y-1);
		var c42 = getCell(x+2,y);
		var c43 = getCell(x+2,y+1);
		var c44 = getCell(x+2,y+2);
		var c34 = getCell(x+1,y+2);
		var c24 = getCell(x,y+2);
		var c14 = getCell(x-1,y+2);
		var c04 = getCell(x-2,y+2);
		var c03 = getCell(x-2,y+1);
		var c02 = getCell(x-2,y);
		var c01 = getCell(x-2,y-1);

		//指定座標のセルのelem要素を取得、範囲外の場合はダミーオブジェクトを返す
		function getCell(x,y){
			//取得
			var result = command(x,y,function(x,y){ return cells[x][y].elem;});
			//ダミーオブジェクト
			if(result == undefined) result ={css:function(){}};
			return result;
		}

		//
		return (function(){
			c00.css("border-left-color",col);
			c00.css("border-top-color",col);
			c10.css("border-top-color",col);
			c20.css("border-top-color",col);
			c30.css("border-top-color",col);
			c40.css("border-top-color",col);
			c40.css("border-right-color",col);
			c41.css("border-right-color",col);
			c42.css("border-right-color",col);
			c43.css("border-right-color",col);
			c44.css("border-right-color",col);
			c44.css("border-bottom-color",col);
			c34.css("border-bottom-color",col);
			c24.css("border-bottom-color",col);
			c14.css("border-bottom-color",col);
			c04.css("border-bottom-color",col);
			c04.css("border-left-color",col);
			c03.css("border-left-color",col);
			c02.css("border-left-color",col);
			c01.css("border-left-color",col);
		});
	}

};


















