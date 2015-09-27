/*ゲームロジック本体*/
Game = function(observer){
	var me = this;
	var _state = Const.GameState_Initial();
	var _map;
	me.mineNum = 0;
	var _currentMineNum = 0;

	//状態を判定する関数
	var isInitial = function(){return _state == Const.GameState_Initial();};
	var isStart = function(){return _state == Const.GameState_Start();};
	var isPlay = function(){return _state == Const.GameState_Play();};
	var isGameOver = function(){return _state == Const.GameState_GameOver();};
	var isClear = function(){return _state == Const.GameState_Clear();};

	var setStateStart = function(){
		_state = Const.GameState_Start();
		observer.start();
	};
	var setStateGameOver = function(){
		_state = Const.GameState_GameOver();
		observer.gameOver();
	};
	var setStateClear = function(){
		_state = Const.GameState_Clear();
		observer.cleared();
	};

	//マップの状態を監視するオブジェクト
	var mapObserver = {
			"gameOver" 				:function(){setStateGameOver();},
			"cleared" 				:function(){setStateClear();},
			"cellChangeState_Non" 	:function(cell){observer.cellChangeState_Non(cell.x(),cell.y());},
			"cellChangeState_Flg" 	:function(cell){
				observer.cellChangeState_Flg(cell.x(),cell.y());
				_currentMineNum--;
				observer.mineNumChanged(_currentMineNum);
			},
			"cellChangeState_Question":function(cell){
				observer.cellChangeState_Question(cell.x(),cell.y());
				_currentMineNum++;
				observer.mineNumChanged(_currentMineNum);
			},
			"cellChangeState_Digged":function(cell){observer.cellChangeState_Digged(cell.x(),cell.y(),cell.aroundMineNum);},
			"cellChangeState_Mine"	:function(cell){observer.cellChangeState_Mine(cell.x(),cell.y());},
			"cellChangeState_FlgMiss":function(cell){observer.cellChangeState_FlgMiss(cell.x(),cell.y(),cell.aroundMineNum);}
	};

	//ゲームを開始する
	me.start = function(gameSetting){

		var sizeX = parseInt(gameSetting.sizeX);
		var sizeY = parseInt(gameSetting.sizeY);
		_currentMineNum = gameSetting.mineNum;
		if(!conditionCheck(gameSetting.mineNum, 0, sizeX * sizeY - 2)) return false;;
		me.mineNum = _currentMineNum;
		observer.mineNumChanged(_currentMineNum);
		if(2 < sizeX && 2 < sizeY){
			_map = new Map(sizeX, sizeY ,gameSetting.isSharpMode,gameSetting.isLoopField ,mapObserver);
			_state = Const.GameState_Initial();
			return true;
		} else {
			return false;
		}
	};

	//左クリック機能呼び出し
	me.clickLeft = function(index_x,index_y){

		if(isInitial()){
			setStateStart();
			_map.setMines(_currentMineNum ,index_x ,index_y);
			_state = Const.GameState_Play();
		}
		if(!isGameOver() && !isClear()){
			_map.cellClickedLeft(index_x,index_y);
		}
	};

	//右クリック機能呼び出し
	me.clickRight = function(index_x,index_y){
		if(!isGameOver() && !isClear()){
			_map.cellClickedRight(index_x,index_y);
		}
	};

	//数値をのチェック
	function conditionCheck(num, min, max){
		if(min > max) return false;
		var num = parseInt(num);
		if(isNaN(num)) return false;
		if(num < min) return false;
		if(num > max) return false;
		return true;
	}


};