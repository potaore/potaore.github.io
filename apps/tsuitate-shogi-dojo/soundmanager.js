
var komaOto = null;
var soundsDefs = [
  { name : "koma", source : "./sound/japanese-chess-piece1.mp3" },
  { name : "foul", source : "./sound/cancel2.mp3" }
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