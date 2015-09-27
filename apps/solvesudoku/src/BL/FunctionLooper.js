/*
* 渡したメソッドをループさせるクラス
*/
FunctionLooper = function(func){

	var me = this;

	me.start = function(){
		setTimeout(function(){
			if(func()){
				setTimeout(arguments.callee, 2);
			}
		},2);
	};

};