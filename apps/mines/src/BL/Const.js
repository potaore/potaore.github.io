/*定数の定義*/
var Const = {

        /* ゲームの状態定義 */
		//初期状態
		GameState_Initial : function(){return 0;},
		//ゲーム開始後、一マスもあけていない状態
		GameState_Start : function(){return 1;},
		//ゲームプレイ中の状態
		GameState_Play : function(){return 2;},
		//ゲームオーバー
		GameState_GameOver : function(){return 3;},
		//クリアの状態
		GameState_Clear : function(){return 4;},

        /* セルの状態定義 */
        //何もしていない状態
        CellState_Non : function(){return 0;},
        //旗をたてている状態
        CellState_Flg : function(){return 1;},
        //？の状態
        CellState_Question : function(){return 2;},
        //掘ってある状態
        CellState_Digged : function(){return 3;},
        //掘ってある状態、地雷
        CellState_Digged_Mine : function(){return 4;},
        //（答えあわせ時）旗ミス
        CellState_Flg_Miss : function(){return 5;}
};