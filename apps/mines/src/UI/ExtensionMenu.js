/*詳細メニュー*/
function Menus(){

	var me = this;
	var settingItems = [];

	//メニュー機能を利用不可にする
	me.disable = function(){
		var i;
		for(i = 0; i < settingItems.length; i++){
			settingItems[i].attr("disabled","true");
		}
	};
	//メニュー機能を利用可能にする
	me.enable = function(){
		var i;
		for(i = 0; i < settingItems.length; i++){
			settingItems[i].removeAttr("disabled");
		}
	};

	var sharpModeCheckBox = $('#sharpModeCheckBox');
	var loopFieldModeCheckBox = $('#loopFieldModeCheckBox');

	var beginnerButton = $('#beginnerButton');
	var intermediateButton = $('#intermediateButton');
	var expertButton = $('#expertButton');
	var maniacButton = $('#maniacButton');

	settingItems.push(sharpModeCheckBox);
	settingItems.push(loopFieldModeCheckBox);
	settingItems.push(beginnerButton);
	settingItems.push(intermediateButton);
	settingItems.push(expertButton);
	settingItems.push(maniacButton);

	me.isSharpMode = function(){return sharpModeCheckBox.is(':checked');};
	me.isLoopField = function(){return loopFieldModeCheckBox.is(':checked');};

	sharpModeCheckBox.click(changeGameTitle);
	loopFieldModeCheckBox.click(changeGameTitle);

	beginnerButton.click(createSetGameSetting(9,9,10));
	intermediateButton.click(createSetGameSetting(16,16,40));
	expertButton.click(createSetGameSetting(30,16,99));
	maniacButton.click(createSetGameSetting(62,48,777));

	function changeGameTitle(){
		var str = "MINES";
		if(sharpModeCheckBox.is(':checked')) str +="#";
		if(loopFieldModeCheckBox.is(':checked')) str +="!";
		$('#gametitle').empty();
		$('#gametitle').append(str);
	};


	function createSetGameSetting(sizeX,sizeY,mineNum){
		return(function(){
			$('#widthTextBox').val(sizeX);
			$('#heigjtTextBox').val(sizeY);
			$('#mineTextBox').val(mineNum);
		});
	}



	var exMenuSwitch = $('#exMenuSwitch');
	var dfMenuSwitch = $('#dfMenuSwitch');
	var hpMenuSwitch = $('#hpMenuSwitch');
	var srMenuSwitch = $('#srMenuSwitch');

	var exMenuArea = $('#exMenuArea');
	var dfMenuArea = $('#dfMenuArea');
	var hpMenuArea = $('#hpMenuArea');
	var srMenuArea = $('#srMenuArea');

	var exDisplay = false;
	var dfDisplay = false;
	var hpDisplay = false;
	var srDisplay = false;


	exMenuSwitch.click(function(){
		exDisplay = !exDisplay;
		if(exDisplay){
			dfDisplay = false;
			hpDisplay = false;
			srDisplay = false;
		}
		menuReDraw();
	});

	dfMenuSwitch.click(function(){
		dfDisplay = !dfDisplay;
		if(dfDisplay){
			exDisplay = false;
			hpDisplay = false;
			srDisplay = false;
		}
		menuReDraw();
	});

	hpMenuSwitch.click(function(){
		hpDisplay = !hpDisplay;
		if(hpDisplay){
			dfDisplay = false;
			exDisplay = false;
			srDisplay = false;
		}
		menuReDraw();
	});

	srMenuSwitch.click(function(){
		srDisplay = !srDisplay;
		if(srDisplay){
			exDisplay = false;
			dfDisplay = false;
			hpDisplay = false;
		}
		menuReDraw();
	});


	function menuReDraw(){
		exMenuSwitch.empty();
		dfMenuSwitch.empty();
		hpMenuSwitch.empty();
		srMenuSwitch.empty();
		if(exDisplay){
			exMenuSwitch.append('－RuleExtension　');
			exMenuArea.css("display","block");
		} else {
			exMenuSwitch.append('＋RuleExtension　');
			exMenuArea.css("display","none");
		}
		if(dfDisplay){
			dfMenuSwitch.append('－Difficulty　');
			dfMenuArea.css("display","block");
		} else {
			dfMenuSwitch.append('＋Difficulty　');
			dfMenuArea.css("display","none");
		}
		if(hpDisplay){
			hpMenuSwitch.append('－Help　');
			hpMenuArea.css("display","block");
		} else {
			hpMenuSwitch.append('＋Help　');
			hpMenuArea.css("display","none");
		}
		if(srDisplay){
			srMenuSwitch.append('－SystemRequirements　');
			srMenuArea.css("display","block");
		} else {
			srMenuSwitch.append('＋SystemRequirements　');
			srMenuArea.css("display","none");
		}
	}




};
