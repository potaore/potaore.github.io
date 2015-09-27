/*タイマー*/
var Timer = function(){

	var me = this;
	var loopflg = true;
	me.elem = $('<span></span>');
	var startTime;

	//タイマーをスタート
	me.start = function(){
		startTime = new Date();
		setTimeout(function(){
			if(loopflg){
				setTimeout(arguments.callee, 100);
				me.elem.empty();
				var time = (new Date()) - startTime;
				me.elem.append(parseInt(time/1000)
						+ "."
						+ (parseInt(time/100))%10);
			}
		},2);
	};

	//タイマーをストップ
	me.stop = function(){
		loopflg = false;
		return ((new Date()) - startTime);
	};

};