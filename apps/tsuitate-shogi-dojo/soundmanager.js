var playSound, loadSounds;


function loadSounds() {
  var sounds  = {};
  var context = null,
      audio   = null;
  var soundsDefs = [
    { name : "koma"                , system : true  , source : "./sound/japanese-chess-piece1.mp3" },
    { name : "foul"                , system : true  , source : "./sound/cancel2.mp3" },
    { name : "start"               , system : true  , source : "./sound/drum-japanese1.mp3" },
    { name : "拍手1"               , system : false , source : "./sound/clapping-hands1.mp3" },
    { name : "拍手2"               , system : false , source : "./sound/clapping-hands2.mp3" },
    { name : "ドンドンパフパフ"    , system : false , source : "./sound/dondonpafupafu1.mp3" },
    { name : "ゴング"              , system : false , source : "./sound/gong-played2.mp3" }
  ];

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


  window.AudioContext = window.AudioContext || window.webkitAudioContext;
  
  if ( window.AudioContext ) {
    context = new AudioContext();
    _( soundsDefs ).each( function (soundDef) {
      loadSound( soundDef.source, function(buffer) { sounds[soundDef.name] = buffer; } );
    });
    playSound = function(name) {
      var buffer = sounds[name];
      if (buffer) {  
        var source = context.createBufferSource();
        source.buffer = buffer;
        source.connect(context.destination);
        source.start(0);
      }
    }
  } else if( Audio ) {
    audio = new Audio();
    if (audio.canPlayType("audio/mp3") == 'maybe') {
      _( soundsDefs ).each( function (soundDef) {
        sounds[soundDef.name] = new Audio(soundDef.source);
      });
      playSound = function(name) {
        var _audio = sounds[name];
        if (_audio) _audio.play();
      }
    } else {
      alert("ご利用のブラウザは、音声出力に対応していません。");
    }
  } else {
    alert("ご利用のブラウザは、音声出力に対応していません。");
  }
}
