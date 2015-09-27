//数独を解くクラス
Solver = function(mondai){

	var me = this;

	//コンストラクタの引数で渡された問題が、数独のルールに違反していないかどうか返すメソッド
	me.checkMondai = function() { return checkMap(mondai) ;};

	//渡されたマップが数独のルールに違反していないかどうか返すメソッド
	var checkMap = function(map){

		var rowHash,colHash,bckHash;
		var bar;

		for(var i = 0;i < 9;i++){
			rowHash = new MyHash();
			colHash = new MyHash();
			bckHash = new MyHash();
			for(var j = 0;j < 9;j++){

				if(map[i][j] !== 0)
					if(!rowHash.tryAdd(map[i][j])) return false;

				if(map[j][i] != 0)
					if(!colHash.tryAdd(map[j][i])) return false;

				bar = map[parseInt(i / 3) * 3 + parseInt(j / 3)][(i % 3) * 3 + j % 3];
				if(bar != 0)
					if(!bckHash.tryAdd(bar)) return false;
			}
		}
		return true;
	};

	//コンストラクタで渡された問題を解くメソッド
	me.solve = function(listner){

		var mainProcess = getMainProcess(listner);
		var fl = new FunctionLooper(mainProcess);
		fl.start();
	};

	//ループさせる処理を生成する
	function getMainProcess(listner){
		var answer = getCopyArray();
		var cs = new Cursor(9,9);
		var next = forwardCheck;

		mainProcess = function(){
			var i = 0;
			for(i = 0 ; i < 500; i++){
				if(cs.isInRange()){
					next = next(mondai,answer,cs);
				}else{
					listner(answer);
					return false;
				}
			}
			listner(answer);
			return true;
		};
		return mainProcess;
	}



	//カーソルの位置が問題ではじめから埋まっているマスか判断する
	function forwardCheck(mondai,answer,cs){
		if(mondai[cs.getX()][cs.getY()] !== 0){
			return incliment;
		} else { return fill; }
	};

	//カーソルをひとつすすめる
	function incliment(mondai,answer,cs){
		cs.incliment();
		return forwardCheck;
	};

	//カーソル位置の値をひとつ増やす
	function fill(mondai,answer,cs){
		answer[cs.getX()][cs.getY()] = answer[cs.getX()][cs.getY()] + 1;
		return fillcheck;
	};

	//数値を埋めてみた後のチェック処理
	function fillcheck(mondai,answer,cs){
		if(answer[cs.getX()][cs.getY()] > 9){
			//全ての数値が駄目だった場合、カーソルをもどす
			return back;

		} else if(checkMap(answer)) {
			//違反していない場合、カーソルを次の位置へ進める
			return incliment;

		} else{
			//違反している場合、次の数値を試す
			return fill;
		}
	};

	//カーソル位置を戻す処理
	function back(mondai,answer,cs){
		if(answer[cs.getX()][cs.getY()] > 9){
			answer[cs.getX()][cs.getY()] = 0;
			cs.decliment();
			return back;
		} else if(mondai[cs.getX()][cs.getY()] != 0){
			cs.decliment();
			return back;
		} else{
			return fill;
		}
	};

	//コピーを返す
	function getCopyArray(){
		var answer = [];
		for(var i = 0; i <9; i++){
			answer[i] = mondai[i].concat();
		}
		return answer;
	}

};


