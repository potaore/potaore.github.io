Reader = function(){
	var me = this;
	var _mondaiStr;
	var _mondai;

	me.setMondai = function(mondai){ _mondaiStr = mondai; };
	me.getMondai = function(){return _mondai;};
	me.check = function(){
		_mondai = splitStr(_mondaiStr);
		return checkFormat(_mondai);
	};
	me.convertToStr = function(answer){

		var result = '';
		var i;
		for(i = 0; i < 9 ; i++){
			result += answer[i] + "\r\n";
		}
		return result;
	};

	function splitStr(Str){
		var tmparr = new Array();
		var result = new Array();
		var count = 0;
		var i;

		tmparr = Str.split(/\r\n|\r|\n/);
		for(i = 0 ; i < tmparr.length ; i++){
			if(tmparr[i] != ''){
				result[count] = tmparr[i].split(',');
				count++;
			}
		}
		return result;
	}

	function checkFormat(mondai){
		var i,j;
		if(mondai.length !== 9) return false;
		for(i = 0; i < 9; i++){
			if(mondai[i].length !== 9) return false;
			for(j = 0; j < 9; j++){
				mondai[i][j] = parseInt(mondai[i][j]);
				if(isNaN(mondai[i][j])) mondai[i][j] = 0;
				if(_mondai[i][j] < 0 || 9 < _mondai[i][j]) return false;
			}
		}
		return true;
	}
};