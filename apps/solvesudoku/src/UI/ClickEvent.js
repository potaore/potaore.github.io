
//「問題を解く」ボタンがクリックされたときのイベント
function SolveButtonClickEvent(senderTextArea, listnerTextArea){
	var reader;
	var solver;

	reader = new Reader();

	reader.setMondai(senderTextArea.value);
	if(!reader.check()){
		listnerTextArea.value = "入力された問題が正しくありません。";
		return ;
	}

	solver = new Solver(reader.getMondai());

	if(!solver.checkMondai()){
		listnerTextArea.value =  "入力された問題が数独のルールに違反しています。";
		return ;
	}

	solver.solve(function(answer){
		listnerTextArea.value = reader.convertToStr(answer);
	});
}



