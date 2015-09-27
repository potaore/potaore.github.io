/*ゲームの状態を通知するフィールド*/
function MessageArea(){

	var me = this;
	me.elem = $('<span></span>');
	setElem("Click any cell");
	me.start = function(){setElem("Playing...");};
	me.gameOver = function(){setElem("Game Over!");};
	me.cleared = function(score){
		setElem("Game Clear! 　" + " 　score：" + score);
	};

	function setElem(str){
		me.elem.empty();
		me.elem.append(str);
	};
}