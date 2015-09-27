Cursor = function(xSize,ySize){
	var me = this;
	var _xSize = xSize;
	var _ySize = ySize;
	var index = 0;

	me.getX = function(){return index % _xSize;};

	me.getY = function(){return parseInt(index / _ySize);};

	me.incliment = function(){ index++; };
	me.decliment = function(){ index--; };
	me.initialize = function(){ index = 0;};

	me.isInRange = function(){
		return (0 <= index) && (index < (_xSize * _ySize));
	};
};