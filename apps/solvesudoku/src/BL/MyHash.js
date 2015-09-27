MyHash = function(){

	var me = this;
	me.hash = new Array();
	me.tryAdd = function(value){
		var result = !(value in me.hash);
		me.hash[value] = true;
		return result;
	};
};