function getCommandAroundCells(sizeX,sizeY,isSharpMode,isLoopField){

	//渡された座標を判断して処理を実行する関数の定義
	var command = getCommand(sizeX, sizeY, isLoopField);

	//周囲24マスモード
	if(isSharpMode){
		return (function(x,y,func){
			command(x-1,y-1,func);
			command(x,y-1,func);
			command(x+1,y-1,func);
			command(x-1,y,func);
			command(x+1,y,func);
			command(x-1,y+1,func);
			command(x,y+1,func);
			command(x+1,y+1,func);
			command(x-2,y-2,func);
			command(x-1,y-2,func);
			command(x,y-2,func);
			command(x+1,y-2,func);
			command(x+2,y-2,func);
			command(x-2,y+2,func);
			command(x-1,y+2,func);
			command(x,y+2,func);
			command(x+1,y+2,func);
			command(x+2,y+2,func);
			command(x-2,y-1,func);
			command(x-2,y,func);
			command(x-2,y+1,func);
			command(x+2,y-1,func);
			command(x+2,y,func);
			command(x+2,y+1,func);

		});
		//周囲8マスモード
	} else {
		return (function(x,y,func){
			command(x-1,y-1,func);
			command(x,y-1,func);
			command(x+1,y-1,func);
			command(x-1,y,func);
			command(x+1,y,func);
			command(x-1,y+1,func);
			command(x,y+1,func);
			command(x+1,y+1,func);
		});
	}
}




//渡された座標を判断して処理を実行する関数を生成する
var getCommand = function(sizeX, sizeY, isLoopField){

	//上下左右ループモード
	if(isLoopField){
		return (function(x,y,func){
			if(x < 0) x += sizeX;
			if(x >= sizeX) x -= sizeX;
			if(y < 0) y += sizeY;
			if(y >= sizeY) y -= sizeY;
			return func(x, y);
		});
		//通常モード
	} else {
		return (function(x,y,func){
			if((0 <= x) && (x < sizeX) && (0 <= y) && (y < sizeY)) return func(x, y);
		});
	}
};