var CHARACTER_WIDTH = 40 * 2;
var CHARACTER_HEIGHT = 60 / 2;
var SCREEN_WIDTH = 640;
var SCREEN_HEIGHT = 480;

var ASSETS = {
  image: {
    'wan'       : './wan.png',
    'neko'      : './neko.png',
    'apple'     : './apple.png',
    'background' : './gahag-0041168898-1.jpg'
  },
  sound: {},
  spritesheet: {},
};


// phina.js をグローバル領域に展開
phina.globalize();

phina.main(function() {
  var app = oreo.Application();
  app.fps = 60;
  app.backgroundColor ='#444444';
  app.run();
});

phina.namespace(function() {

  phina.define("oreo.Application", {
    superClass: "phina.display.CanvasApp",

    init: function() {
      var self = this;
      self.superInit({
        width: SCREEN_WIDTH,
        height: SCREEN_HEIGHT
      });
      self.fps = 60;
      self.backgroundColor ='#444444';
      
      var loading = oreo.loading({
        width: SCREEN_WIDTH,
        height: SCREEN_HEIGHT,
        exitType: "",
        assets: ASSETS
      });
      self.replaceScene(loading);
      
      loading.onloaded = function(){
        self.replaceScene(oreo.title());
      };
    }

  });

});


phina.define('oreo.MainScene', {
  superClass: 'phina.display.DisplayScene',
    init: function() {
      var self = this;
      this.superInit({
        width: SCREEN_WIDTH,
        height: SCREEN_HEIGHT,
      });

      self.parameters = {
        "time"  : 0,
        "score" : 0,
        "life"  : 3
      };

      Sprite('background', SCREEN_WIDTH, SCREEN_HEIGHT)
        .addChildTo(self)
        .setOrigin(0, 0);

      self.apples = DisplayElement().addChildTo(self);

      (self.parameters.life).times(function(index){
        Sprite('apple', 29, 31)
          .addChildTo(self.apples)
          .setPosition(400 + index * 35, 20);
      });
      self.dogs = DisplayElement().addChildTo(self);
      self.cats = DisplayElement().addChildTo(self);

    },

    update: function(app) {
      var self = this;
      this.parameters.time++;

      
      var removeList = [];
      self.cats.children.each(function(cat){
        self.dogs.children.each(function(dog){
          if(    cat._delete !== true
             &&  dog._delete !== true 
             &&  cat.hitTestElement(dog) ) {
            cat._delete = true;
            dog._delete = true;
            removeList.push(dog);
            removeList.push(cat);
            self.parameters.score++;
          }
        });
      });
      removeList.each(function(catOrDog){
          catOrDog.remove();
          var x = catOrDog.position.x;
          var y = catOrDog.position.y;
          (5).times(function(i){
            var p = phina.display.StarShape({
              radius: 8,
              stroke: null,
              fill: "hsl({0}, 80%, 50%)".format(Math.randint(0, 360)),
            })
              .setPosition(x, y)
              .setRotation(Math.randint(180, 480))
              .addChildTo(self);

            p.blendMode = "lighter";
            p.tweener
              .by({
                x: Math.randint(-100, 100),
                y: Math.randint(-100, 100),
                scaleX: 1.5,
                scaleY: 1.5,
                rotation: Math.randint(-360, 360),
                alpha: -1
              }, 300, "easeInQuad")
              .call(function() {
                p.remove();
              });
          });
      });
      

      level = parseInt(this.parameters.time / 600);

      self.apples.children.each(function(apple, index){
        if(index >= self.parameters.life){
          apple.remove();
        }
      });

      if( Math.randint(0, 360) < 3 + level){
        var x = SCREEN_WIDTH + 100;
        var y = Math.randint(0, SCREEN_HEIGHT);
        Dog().addChildTo(self.dogs)
          .setPosition(x, y);
      }

      if (app.pointer.getPointingStart()) {
        var x = 30;
        //app.pointer.x;
        var y = app.pointer.y;

        if(y < SCREEN_HEIGHT && y >= 0){
          Cat().addChildTo(self.cats)
            .setPosition(x, y);
        }
      }

      if(this.parameters.life < 0){
        app.replaceScene(oreo.title(self.parameters.score));
      }
    }
});


phina.define('Dog', {
  superClass: 'phina.display.Sprite',
  init: function() {
    this.superInit('wan', 50, 50);
  },
  update: function(app) {
    this.setPosition(this.position.x - (2 + level/2), this.position.y);
    if(this.position.x < 0) {
      if(app.currentScene.parameters) {      
        app.currentScene.parameters.life--;
        this.remove();
      }
    }
  }
});

phina.define('Cat', {
  superClass: 'phina.display.Sprite',
  init: function() {
    this.superInit('neko', 50, 50);
  },
  update: function(app) {
    this.setPosition(this.position.x + (2 + level), this.position.y);
    if(this.position.x > SCREEN_WIDTH + 50) {
      if(app.currentScene.parameters) {      
        app.currentScene.parameters.life--;
        this.remove();
      }
    }
  }
});

phina.define("oreo.title", {
  superClass: "phina.display.DisplayScene",
  
  init: function(score) {
    this.superInit();
    if(score) {
      var score_label = phina.display.Label("SCORE : " + score)
        .setPosition(320, 340)
        .addChildTo(this);
    }

    var label = phina.display.Label("WAN NEKO WAR")
      .setPosition(320, 240)
      .addChildTo(this);
    
    label.tweener
      .to({
        scaleX: 1.3,
        scaleY: 1.3
      }, 1000, "easeInOutQuad")
      .to({
        scaleX: 1,
        scaleY: 1
      }, 1000, "easeInOutQuad")
      .setLoop(true);
  },

  update: function(app) {
    if (app.pointer.getPointingStart()) {
      app.replaceScene(oreo.MainScene());
    }
  }
});


phina.namespace(function() {

  phina.define("oreo.loading", {
    superClass: "phina.game.LoadingScene",
    init: function(options) {
      this.superInit(options);
    }
  });
});