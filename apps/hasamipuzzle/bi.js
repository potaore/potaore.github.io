// Generated by CoffeeScript 1.4.0
(function() {
  var Cell, Const, Edit, Field, Floor, Floor_Arrow, Floor_Ice, Floor_Net, Floor_Plain, Floor_Step, Game, Item, Item_Block, Item_Energy, Item_Gate, Item_Goal, Item_Key, Item_Non, Menu, Player, Point, Stage,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Const = {
    GameMode: {
      Menu: 0,
      Play: 1,
      Edit: 2
    },
    GameState: {
      Wait: 0,
      Moving: 1,
      Cleared: 2,
      GameOver_EnergyEmpty: 3,
      GameOver_CannotMove: 4,
      GameOver_Suicide: 5
    },
    FloorType: {
      Plain: 0,
      Ice: 1,
      Net: 2,
      Step: 3,
      ArrowLeft: 4,
      ArrowUp: 5,
      ArrowRight: 6,
      ArrowDown: 7
    },
    ItemType: {
      Non: 0,
      Block: 1,
      Energy: 2,
      Key: 3,
      Gate: 4,
      Goal: 9
    },
    MoveType: {
      Stop: 0,
      Walk: 1,
      Dash: 2,
      Slip: 3
    },
    Direction: {
      Left: 0,
      Up: 1,
      Right: 2,
      Down: 3
    }
  };

  Point = (function() {

    function Point(x, y) {
      this.x = x;
      this.y = y;
    }

    Point.prototype.move = function(direction) {
      if (direction === Const.Direction.Up) {
        this.y--;
      }
      if (direction === Const.Direction.Right) {
        this.x++;
      }
      if (direction === Const.Direction.Down) {
        this.y++;
      }
      if (direction === Const.Direction.Left) {
        this.x--;
      }
      return this;
    };

    Point.prototype.duplicate = function() {
      return new Point(this.x, this.y);
    };

    return Point;

  })();

  Player = (function() {

    function Player(x, y, energy) {
      this.point = new Point(x(y));
      this.energy = energy;
      this.direction;
      this.keys = 0;
      this.moveType = Const.MoveType.Stop;
    }

    Player.prototype.duplicate = function() {
      return new Player(this.x, this.y, this.energy);
    };

    Player.prototype.isStop = function() {
      return this.moveType === Const.MoveType.Stop;
    };

    Player.prototype.isMove = function() {
      return this.moveType === Const.MoveType.Stop;
    };

    Player.prototype.isWalk = function() {
      return this.moveType === Const.MoveType.Walk;
    };

    Player.prototype.isDash = function() {
      return this.moveType === Const.MoveType.Dash;
    };

    Player.prototype.isSlip = function() {
      return this.moveType === Const.MoveType.Slip;
    };

    Player.prototype.setMoveTypeStop = function() {
      return this.moveType = Const.MoveType.Stop;
    };

    Player.prototype.setMoveTypeWalk = function() {
      return this.moveType = Const.MoveType.Walk;
    };

    Player.prototype.setMoveTypeDash = function() {
      return this.moveType = Const.MoveType.Dash;
    };

    Player.prototype.setMoveTypeSlip = function() {
      return this.moveType = Const.MoveType.Slip;
    };

    Player.prototype.move = function() {
      return this.point.move(this.direction);
    };

    return Player;

  })();

  Cell = (function() {

    function Cell(floor, item, point) {
      this.floor = floor;
      this.item = item;
      this.point = point;
    }

    Cell.prototype.duplicate = function() {
      return new Cell(this.floor.duplicate(), this.item.duplicate(), this.point);
    };

    Cell.prototype.playerTryOut = function(player) {
      this.floor.playerTryOut(player);
      return this.item.playerTryOut(player);
    };

    Cell.prototype.playerTryMove = function(player) {
      this.floor.playerTryMove(player);
      return this.item.playerTryMove(player);
    };

    Cell.prototype.playerOut = function(player) {
      this.floor.playerOut(player);
      return this.item.playerOut(player);
    };

    Cell.prototype.playerOn = function(player) {
      this.floor.playerOn(player);
      return this.item.playerOn(player);
    };

    Cell.prototype.playerStop = function(player) {
      this.floor.playerStop(player);
      return this.item.playerStop(player);
    };

    return Cell;

  })();

  Floor = (function() {

    function Floor(param) {
      this.param = param;
    }

    Floor.prototype.duplicate = function() {
      return this.constructor(this.param);
    };

    Floor.prototype.playerTryOut = function(player) {};

    Floor.prototype.playerTryMove = function(player) {};

    Floor.prototype.playerOut = function(player) {};

    Floor.prototype.playerOn = function(player) {};

    Floor.prototype.playerStop = function(player) {};

    Floor.createFloor = function(floorType) {
      switch (floorType) {
        case Const.FloorType.Plain:
          return new Floor_Plain();
        case Const.FloorType.Ice:
          return new Floor_Ice();
        case Const.FloorType.Net:
          return new Floor_Net();
        case Const.FloorType.Step:
          return new Floor_Step();
        case Const.FloorType.ArrowLeft:
          return new Floor_Arrow(Const.Direction.Left);
        case Const.FloorType.ArrowUp:
          return new Floor_Arrow(Const.Direction.Up);
        case Const.FloorType.ArrowRight:
          return new Floor_Arrow(Const.Direction.Right);
        case Const.FloorType.ArrowDown:
          return new Floor_Arrow(Const.Direction.Down);
        default:
          return new Floor_Plain();
      }
    };

    return Floor;

  })();

  Item = (function() {

    function Item(param, ghost) {
      this.param = param;
      this.ghost = ghost;
    }

    Item.prototype.duplicate = function() {
      return new Item(this.param(this.ghost));
    };

    Item.prototype.playerTryOut = function(player) {};

    Item.prototype.playerTryMove = function(player) {};

    Item.prototype.playerOut = function(player) {
      if (this.ghost) {
        return this.ghost = false;
      }
    };

    Item.prototype.playerOn = function(player) {};

    Item.prototype.playerStop = function(player) {};

    Item.createItem = function(itemType, param, ghost) {
      switch (itemType) {
        case Const.ItemType.Non:
          return new Item_Non(param(ghost));
        case Const.ItemType.Block:
          return new Item_Block(param(ghost));
        case Const.ItemType.Energy:
          return new Item_Energy(param(ghost));
        case Const.ItemType.Key:
          return new Item_Key(param(ghost));
        case Const.ItemType.Gate:
          return new Item_Gate(param(ghost));
        case Const.ItemType.Goal:
          return new Item_Goal(param(ghost));
        default:
          return new Item_Non(param(ghost));
      }
    };

    return Item;

  })();

  Floor_Plain = (function(_super) {

    __extends(Floor_Plain, _super);

    function Floor_Plain() {
      return Floor_Plain.__super__.constructor.apply(this, arguments);
    }

    return Floor_Plain;

  })(Floor);

  Floor_Ice = (function(_super) {

    __extends(Floor_Ice, _super);

    function Floor_Ice() {
      return Floor_Ice.__super__.constructor.apply(this, arguments);
    }

    Floor_Ice.prototype.playerOn = function(player) {
      if (player.isWalk()) {
        return player.setMoveTypeSlip();
      }
    };

    return Floor_Ice;

  })(Florr);

  Floor_Net = (function(_super) {

    __extends(Floor_Net, _super);

    function Floor_Net() {
      return Floor_Net.__super__.constructor.apply(this, arguments);
    }

    Floor_Net.prototype.playerOn = function(player) {
      return player.setMoveTypeStop();
    };

    return Floor_Net;

  })(Florr);

  Floor_Step = (function(_super) {

    __extends(Floor_Step, _super);

    function Floor_Step() {
      return Floor_Step.__super__.constructor.apply(this, arguments);
    }

    Floor_Step.prototype.playerTryMove = function(player) {
      if (player.isWalk()) {
        return player.setMoveTypeStop();
      }
    };

    return Floor_Step;

  })(Floor);

  Floor_Arrow = (function(_super) {

    __extends(Floor_Arrow, _super);

    function Floor_Arrow() {
      return Floor_Arrow.__super__.constructor.apply(this, arguments);
    }

    Floor_Arrow.prototype.playerTryOut = function(player) {
      return player.direction = this.param;
    };

    return Floor_Arrow;

  })(Florr);

  Item_Non = (function(_super) {

    __extends(Item_Non, _super);

    function Item_Non() {
      return Item_Non.__super__.constructor.apply(this, arguments);
    }

    return Item_Non;

  })(Item);

  Item_Block = (function(_super) {

    __extends(Item_Block, _super);

    function Item_Block() {
      return Item_Block.__super__.constructor.apply(this, arguments);
    }

    Item_Block.prototype.playerTryMove = function(player) {
      if (!this.ghost) {
        return player.setMoveTypeStop();
      }
    };

    return Item_Block;

  })(Item);

  Item_Energy = (function(_super) {

    __extends(Item_Energy, _super);

    function Item_Energy() {
      return Item_Energy.__super__.constructor.apply(this, arguments);
    }

    Item_Energy.prototype.playerOn = function(player) {
      if (!this.ghost) {
        return player.energy += this.param;
      }
    };

    return Item_Energy;

  })(Item);

  Item_Key = (function(_super) {

    __extends(Item_Key, _super);

    function Item_Key() {
      return Item_Key.__super__.constructor.apply(this, arguments);
    }

    Item_Key.prototype.playerOn = function(player) {
      if (!this.ghost) {
        return player.keys++;
      }
    };

    return Item_Key;

  })(Item);

  Item_Gate = (function(_super) {

    __extends(Item_Gate, _super);

    function Item_Gate() {
      return Item_Gate.__super__.constructor.apply(this, arguments);
    }

    Item_Gate.prototype.playerTryMove = function(player) {
      if (!this.ghost) {
        if (this.param > player.keys) {
          return player.setMoveTypeStop();
        } else {
          return player.keys -= this.param;
        }
      }
    };

    return Item_Gate;

  })(Item);

  Item_Goal = (function(_super) {

    __extends(Item_Goal, _super);

    function Item_Goal() {
      return Item_Goal.__super__.constructor.apply(this, arguments);
    }

    Item_Goal.prototype.playerStop = function(player) {};

    return Item_Goal;

  })(Item);

  Game = (function() {

    function Game(connector) {
      this.stage;
      this.gameState = Const.GameState.Wait;
      this.gameMode = Const.GameMode.Edit;
      this.connector = connector;
      this.mode = Const.GameMode.Menu;
    }

    Game.prototype.loadStage = function(stageNo) {
      var player;
      return player = new Player();
    };

    Game.prototype.movePlayerWalkLeft = function() {
      return this.stage.movePlayerWalk(Const.Direction.Left);
    };

    Game.prototype.movePlayerWalkUp = function() {
      return this.stage.movePlayerWalk(Const.Direction.Up);
    };

    Game.prototype.movePlayerWalkRight = function() {
      return this.stage.movePlayerWalk(Const.Direction.Right);
    };

    Game.prototype.movePlayerWalkDown = function() {
      return this.stage.movePlayerWalk(Const.Direction.Down);
    };

    Game.prototype.movePlayerDashLeft = function() {
      return this.stage.movePlayerDash(Const.Direction.Left);
    };

    Game.prototype.movePlayerDashUp = function() {
      return this.stage.movePlayerDash(Const.Direction.Up);
    };

    Game.prototype.movePlayerDashRight = function() {
      return this.stage.movePlayerDash(Const.Direction.Right);
    };

    Game.prototype.movePlayerDashDown = function() {
      return this.stage.movePlayerDash(Const.Direction.Down);
    };

    return Game;

  })();

  Edit = (function() {

    function Edit(connector) {
      this.connector = connector;
      this.field = [];
    }

    return Edit;

  })();

  Field = (function() {

    function Field(connector) {
      var i, j;
      this.connector = connector;
      connector.notice("create field", 10, 14);
      this.map = ((function() {
        var _i, _results;
        (function() {});
        _results = [];
        for (i = _i = 0; _i < 10; i = ++_i) {
          field[i] = [];
          _results.push((function() {
            var _j, _results1;
            _results1 = [];
            for (j = _j = 0; _j < 14; j = ++_j) {
              this.map[i][j] = new Cell(createFloor(Const.FloorType.Plain), Item.createItem(Const.ItemType.Non));
              _results1.push(connector.notice("update cell", i, j));
            }
            return _results1;
          }).call(this));
        }
        return _results;
      }).call(this))();
    }

    return Field;

  })();

  Menu = (function() {

    function Menu(connector) {
      this.cursor = 0;
      this.connector = connector;
    }

    return Menu;

  })();

  Stage = (function() {

    function Stage(player, field, connector) {
      this.player;
      this.field;
      this.connector = connector;
      this.initialize = function() {
        return copyCondition(player, field);
      };
      this.initialize();
    }

    Stage.prototype.copyCondition = function(player, field) {
      var i, j, _i, _j, _ref, _ref1;
      this.player = player.duplicate();
      this.field = [];
      for (i = _i = 0, _ref = field.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        this.field[i] = [];
        for (j = _j = 0, _ref1 = field[i].length(-1); 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; j = 0 <= _ref1 ? ++_j : --_j) {
          this.field[i][j] = field[i][j].duplicate();
        }
      }
    };

    Stage.prototype.getCell = function(pt) {
      return this.field[pt.x][pt.y];
    };

    Stage.prototype.getCurrentCell = function() {
      return this.getCell(this.player.point);
    };

    Stage.prototype.getNextCell = function() {
      var pt;
      pt = this.player.point.duplicate().move(this.player.direction);
      return getCurrentCell(pt);
    };

    Stage.prototype.movePlayerWalk = function(direction) {
      this.player.setMoveTypeWalk();
      return this.movePlayerRepeat(direction);
    };

    Stage.prototype.movePlayerDash = function(direction) {
      this.player.setMoveTypeDash();
      return this.movePlayerRepeat(direction);
    };

    Stage.prototype.movePlayerRepeat = function(direction) {
      this.firstCheckMovable(direction);
      while (true) {
        this.movePlayer();
        if (this.player.isStop()) {
          break;
        }
        this.checkMovable();
        if (this.player.isStop()) {
          break;
        }
      }
      this.getCurrentCell().playerStop(this.player);
    };

    Stage.prototype.movePlayer = function() {
      this.getCurrentCell().playerOut(this.player);
      this.player.move();
      this.getCurrentCell().playerOn(this.player);
    };

    Stage.prototype.firstCheckMovable = function(direction) {
      this.player.direction = direction;
      if (this.checkMovable()) {
        this.player.energy--;
      }
    };

    Stage.prototype.checkMovable = function() {
      this.getCurrentCell().playerTryOut(this.player);
      this.getNextCell().playerTryMove(this.player);
      return this.player.isMove();
    };

    return Stage;

  })();

}).call(this);
