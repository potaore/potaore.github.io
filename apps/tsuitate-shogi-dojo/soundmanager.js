
var komaOto = null;
var soundsDefs = [
  { name : "koma"                , system : true  , source : "./sound/japanese-chess-piece1.mp3" },
  { name : "foul"                , system : true  , source : "./sound/cancel2.mp3" },
  { name : "start"               , system : true  , source : "./sound/drum-japanese1.mp3" },
  { name : "拍手1"               , system : false , source : "./sound/clapping-hands1.mp3" },
  { name : "拍手2"               , system : false , source : "./sound/clapping-hands2.mp3" },
  { name : "ドンドンパフパフ"    , system : false , source : "./sound/dondonpafupafu1.mp3" },
  { name : "ゴング"              , system : false , source : "./sound/gong-played2.mp3" }
];

var sounds = {};

window.AudioContext = window.AudioContext || window.webkitAudioContext;
var context = new AudioContext();

function loadSound(url, cont) {
  var request = new XMLHttpRequest();
  request.open('GET', url, true);
  request.responseType = 'arraybuffer';

  request.onload = function() {
    context.decodeAudioData(request.response, function(buffer) {
      cont(buffer);
    }, function(err) {
      console.log(err);
    });
  }
  request.send();
}

function playSound(name) {
  var buffer = sounds[name];
  if (buffer) {  
    var source = context.createBufferSource();
    source.buffer = buffer;
    source.connect(context.destination);
    source.start(0);
  }
}

function loadSounds() {
  _( soundsDefs ).each( function (soundDef) {
    loadSound( soundDef.source, function(buffer) { 
      sounds[soundDef.name] = buffer;
    } );
  });
}