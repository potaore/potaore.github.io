/*ゲームの初期条件を設定するフィールド*/
function StartMenu(){

	var startMenu = $('#startMenu');
	var StartButton = $('#startButton');
	var textbox1 = $('#widthTextBox');
	var textbox2 = $('#heigjtTextBox');
	var textbox3 = $('#mineTextBox');
	var message = $('#message');
	var menus = new Menus();



	//スタートボタンクリック時の処理
	StartButton.click(function(){

		//テーブルの状態を監視するオブジェクト
		var tableObserver ={
				"gameOver"	:	function(){enable();},
				"cleared"	:	function(){enable();}
		};

		message.empty();
		var gameSetting = {
				"sizeX":parseInt(textbox1.val()),
				"sizeY":parseInt(textbox2.val()),
				"mineNum":textbox3.val(),
				"isSharpMode":menus.isSharpMode(),
				"isLoopField":menus.isLoopField()
		};
		var result = createTable(gameSetting,tableObserver);
		if(result){
			disable();
		} else {
			message.append("invalid condition");
		}
	});

	function disable(){
		textbox1.attr("disabled","true");
		textbox2.attr("disabled","true");
		textbox3.attr("disabled","true");
		StartButton.attr("disabled","true");
		menus.disable();
	}
	function enable(){
		textbox1.removeAttr("disabled");
		textbox2.removeAttr("disabled");
		textbox3.removeAttr("disabled");
		StartButton.removeAttr("disabled");
		menus.enable();
	}
}