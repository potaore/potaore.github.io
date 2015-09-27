/*テーブルのセル*/
function TableCell(x,y,clickevent,rightclickevent){
	var me = this;
	var el = $('<td class="cell" unselectable = "on">　</td>');

	me.getX = function(){return x;};
	me.getY = function(){return y;};

	//左右クリックの検知＆通達
	el.click(function(){clickevent(x,y);});
	el.bind('contextmenu', function(){rightclickevent(x,y);});

	//状態変更時の表示処理
	me.Non = function(){
		el.empty();
		el.append('　');
	};
	me.Flg = function(){
		el.empty();
		el.append('#');
	};
	me.Question = function(){
		el.empty();
		el.append('?');
	};
	me.Digged = function(num){

		if(num === 0){
			el.css({"background-color":"#334466"});
		} else {
			el.empty();
			el.attr({"class":"diggedcell"});
			el.append(num);
		}
	};
	me.Mine = function(){
		el.attr({"class":"mine"});
		el.empty();
		el.append('*');
	};
	me.FlgMiss = function(num){
		el.attr({"class":"flgmiss"});
		el.empty();
		if(num == 0){
			el.append("　");
		} else {
			el.append(num);
		}
	};

	me.elem = el;
};