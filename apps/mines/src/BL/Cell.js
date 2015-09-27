/*マス目を意味するクラス*/
Cell = function(index_x, index_y, observer){

	var me = this;
	var _state = Const.CellState_Non();
	me.isMine = false;
	me.aroundMineNum = 0;

	//自分の座標を返すメソッド
	me.x = function(){return index_x;};
	me.y = function(){return index_y;};

	/*状態の判定をするメソッド群*/
	me.isNon = function(){return _state === Const.CellState_Non();};
	me.isFlg = function(){return _state === Const.CellState_Flg();};
	me.isQuestion = function(){return _state === Const.CellState_Question();};
	me.isDigged = function(){return _state === Const.CellState_Digged();};
	me.isMineDigged = function(){return _state === Const.CellState_Digged_Mine();};
	me.isFlgMiss = function(){return _state === Const.CellState_Flg_Miss();};

	/*状態を変更するメソッド群*/
	me.setStateNon = function(){
		_state = Const.CellState_Non();
		observer.Non(me);
	};
	me.setStateFlg = function(){
		_state = Const.CellState_Flg();
		observer.Flg(me);
	};
	me.setStateQuestion = function(){
		_state = Const.CellState_Question();
		observer.Question(me);
	};
	me.setStateDigged = function(){
		_state = Const.CellState_Digged();
		observer.Digged(me);
	};
	me.setStateMineDigged = function(){
		_state = Const.CellState_Digged_Mine();
		observer.MineDigged(me);
	};
	me.setStateFlgMiss = function(){
		_state = Const.CellState_Flg_Miss();
		observer.FlgMiss(me);
	};

	//左クリックされたときの処理
	me.clicked_left = function(){
		if(me.isNon()){
			if(me.isMine){
				me.setStateMineDigged();

			} else{
				me.setStateDigged();
			}
		}
	};

	//右クリックされたときの処理
	me.clicked_right = function(){
		if(me.isNon()){
			me.setStateFlg();

		} else if(me.isFlg()){
			me.setStateQuestion();

		} else if(me.isQuestion()){
			me.setStateNon();
		}
	};
};
