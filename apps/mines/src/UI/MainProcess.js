$(function(){

	StartMenu();

	$("#contents").bind("contextmenu",function(e){
		return false;
	});
	$("#contents").ready(function(){
		$(document).bind("wheelClick",function(e){
			return false;
		});
	});
	$("#contents").append("<br />");
});

var table;

//テーブルの生成を行い、ゲームを開始する
function createTable(gameSetting,observer){

	//テーブル生成
	if(table != null && table.elem != null) clearTable();
	table = new MapTable(gameSetting,observer);

	//ゲームスタート
	if(table.start()){
		 $("#contents").append(table.elem);
		return true;
	} else {
		clearTable();
		return false;
	}

	//テーブルのメモリ開放を行う関数
	function clearTable(){
		table.elem.remove();
		delete table;
	}
};