/*マップ*/
Map = function(sizeX, sizeY, isSharpMode, isLoopField, observer){

	var me = this;

	//マス目の状態を監視するオブジェクト
	var cellObserver = {
			"Non"			:	function(cell){ observer.cellChangeState_Non(cell);},
			"Flg"			:	function(cell){ observer.cellChangeState_Flg(cell);},
			"Question"		:	function(cell){ observer.cellChangeState_Question(cell);},
			"Digged"		:	function(cell){ observer.cellChangeState_Digged(cell);},
			"MineDigged"	:	function(cell){ observer.cellChangeState_Mine(cell);},
			"FlgMiss"	:	function(cell){ observer.cellChangeState_FlgMiss(cell);}
	};

	//セルの生成
	me.cells = (
			function(sizeX, sizeY){
				var result = [];
				var CellCash = Cell;
				var cellObserverCash = cellObserver;
				for(var i = 0; i < sizeX; i++){
					result[i] = [];
					for(var j = 0; j < sizeY ; j++){
						result[i][j] = new CellCash(i,j,cellObserverCash);
					}
				}
				return result;
			})(sizeX, sizeY);

	//地雷の設置を行う
	me.setMines = function(num, index_x, index_y){
		var cellNum = sizeX * sizeY;
		commandAllCells(function(x,y){
			if(num == 0) return;
			if(x != index_x || y != index_y){
				if( Math.random() <= (num / cellNum)){
					me.cells[x][y].isMine = true;
					setAroundMineNum(x, y);
					num--;
				}
			}
			cellNum--;
		});
	};

	//自分の周りのセルに地雷数を加算する
	function setAroundMineNum(x, y){
		commandAroundCells(x,y,function(x,y){me.cells[x][y].aroundMineNum += 1;});
	};



	//渡された座標の周りを操作する関数
	var commandAroundCells = getCommandAroundCells(sizeX,sizeY,isSharpMode,isLoopField);

	//全てのマスを操作
	var commandAllCells = (function(sizeX,sizeY){
		return (function(func){
			for(var i = 0; i < sizeX; i++){
				for(var j = 0; j < sizeY ; j++){
					func(i,j);
				}
			}
		});
	})(sizeX,sizeY);

	//クリアしたかどうか判定する
	me.isCleared = function(){
		var cell;
		for(var i = 0; i < sizeX; i++){
			for(var j = 0; j < sizeY ; j++){
				cell = me.cells[i][j];
				if(cell.isMine) continue;
				if(cell.isMineDigged()) return false;
				if(!cell.isDigged()) return false;
			}
		}
		return true;
	};

	//左クリック時の処理
	me.cellClickedLeft = function(x, y){
		var cell = me.cells[x][y];
		if(cell.isNon()){
			cell.clicked_left();
			if(cell.isDigged()){
				me.autoDig(cell);
				if(me.isCleared()) {
					commandAllCells(function(x,y){
						var cell = me.cells[x][y];
						if(cell.isMine && cell.isNon()) cell.setStateFlg();
					});
					observer.cleared();
				}

			} else if(cell.isMineDigged()){
				observer.gameOver();
				commandAllCells(function(x,y){
					var cell = me.cells[x][y];
					if(cell.isMine){
						cell.setStateMineDigged();
					} else if(cell.isFlg()) {
						cell.setStateFlgMiss();
					}
				});
			}
		}
	};

	//右クリック時の処理
	me.cellClickedRight = function(x, y){
		var cell = me.cells[x][y];
		if(cell.isDigged()){
			if(cell.aroundMineNum != 0){
				var flgcount = 0;
				commandAroundCells(x,y,function(x,y){
					if(me.cells[x][y].isFlg()) flgcount++;
				});
				if(flgcount == cell.aroundMineNum){
					commandAroundCells(x,y,me.cellClickedLeft);
				}
			}
		} else {
			cell.clicked_right();
		}
	};

	//自動で掘る処理
	me.autoDig = function(cell){
		var nextCells = [];
		var newCells = [];
		var len = 1;
		var i;
		var getNextCellsCash = getNextCells;

		nextCells[0] = cell;
		cell.setStateDigged();

		while(len > 0){
			for(i = 0; i < len; i++){
				newCells = (getNextCellsCash(nextCells[i])).concat(newCells);
			}
			nextCells = newCells;
			newCells = [];
			len = nextCells.length;
		}
	};

	//自動で掘らせるセルの配列を返す
	function getNextCells(cell){
		var result =[];
		var count = 0;

		if(cell.aroundMineNum === 0){
			commandAroundCells(cell.x(),cell.y(), function(x,y){
				var cell = me.cells[x][y];
				if(cell.isNon()){
					cell.setStateDigged();
					result[count] = cell;
					count++;
				}
			});
		}
		return result;
	}
};
