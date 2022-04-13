package;

import StringTools;

class Coordinate {
	public var x:Int;
	public var y:Int;
	public var altitude:Int;

	public function new(x:Int, y:Int, altitude:Int) {
		this.x = x;
		this.y = y;
		this.altitude = altitude;
	}
}

interface Positional {
	public var x:Int;
	public var y:Int;
	public var altitude:Int;
	public var height:Int;
}

enum abstract RampDirection(Int) to Int {
	var NONE=-1;
	var N=0;
	var E=1;
	var S=2;
	var W=3;
}

enum abstract Direction(Int) to Int {
	var N=0;
	var E=1;
	var S=2;
	var W=3;
    
}

class Tile implements Positional {
	public var x:Int = 0;
	public var y:Int = 0;
	public var altitude:Int = 0;
	public var height:Int = 4;
	public var ramp_direction:RampDirection = NONE;

	public function new(x:Int, y:Int, height:Int, ramp_direction:RampDirection) {
		this.x = x;
		this.y = y;
		this.altitude = 0;
		this.height = height;
		this.ramp_direction = ramp_direction;
	}

    public function isWall():Bool{
        return height==20;
    }

    public function heightCoord():Int{
        return height-altitude + (ramp_direction==NONE ? 0 : -1);
    }

    public static function FlipDirection(d:Int):Int{
        switch(d){
            case N: return S;
            case E: return W;
            case S: return N;
            case W: return E;
            default:return -1;
        }
    }
}

class Entity implements Positional {
	public var x:Int = 0;
	public var y:Int = 0;
	public var altitude:Int = 0; // 0-6 - altitude coordinate is doubled because of half-altitude ramps
	public var height:Int = 2;
	public var dir:Direction;

    public var fromx:Int=0;
    public var fromy:Int=0;
    public var fromaltitude:Int=0;

	public function new(x:Int, y:Int, altitude:Int, height:Int, dir:Direction) {
		this.x = x;
		this.y = y;
        this.fromx = x;
        this.fromy = y;
		this.altitude = altitude;
        this.fromaltitude = altitude;
		this.height = height;
		this.dir = dir;
	}
}

class GameState {
	public var w:Int;
	public var h:Int;
	public var Tiles:Array<Array<Tile>>;
	public var p:Entity;
	public var c1:Entity;
	public var c2:Entity;

    public function TileAt(i:Int,j:Int):Tile{
        trace(i,j,w,h);
        if (i<0 || j<0 || i>=w || j>=h) {
            return null;
        }
        return Tiles[j][i];
    }

    //sorted from lowest to highest
	public function CharactersAt(i:Int, j:Int):Array<Entity> {
		var result:Array<Entity> = [];
		if (i == p.x && j == p.y) {
			result.push(p);
		}
		if (i == c1.x && j == c1.y) {
			result.push(c1);
		}
		if (i == c2.x && j == c2.y) {
			result.push(c2);
		}
        if (result.length>1){
            if (result[0].altitude>result[1].altitude){
                var tmp = result[0];
                result[0] = result[1];
                result[1] = tmp;
            }
        }
		return result;
	}

	public function CharacterBasedAt(i:Int, j:Int, altitude:Int):Entity {
		var result:Array<Entity> = [];
		if (i == p.x && j == p.y && altitude == p.altitude) {
			return p;
		}
		if (i == c1.x && j == c1.y && altitude == c1.altitude) {
			return c1;
		}
		if (i == c2.x && j == c2.y && altitude == c2.altitude) {
			return c2;
		}
		return null;
	}

	public function CharactersInBox(i:Int, j:Int, altitude:Int, height:Int):Array<Entity> {
		var result:Array<Entity> = [];
		for (offset in 0...height) {
			var c = CharacterBasedAt(i, j, altitude + offset);
			if (c != null) {
				result.push(c);
			}
		}
		return result;
	}

	public function CanPushCharacter(c:Entity, d:Direction) {
		var targetCoord = new Coordinate(c.x, c.y, c.altitude);
		// no multiban, so if there's another character in the direction, block movement
	}

	public static function LoadFromString(s:String):GameState {
		var result:GameState = new GameState();
		var lines = s.split("\n").map(StringTools.trim);
		result.h = lines.length;
        
		result.Tiles = new Array<Array<Tile>>();
		for (i in 0...lines.length) {
			var line = lines[i];
			var row:Array<Tile> = [];
			for (j in 0...line.length) {
                result.w = line.length;
				var c = line.charAt(j);
				switch (c) {
                    case ".":                        
                        //nothing
                        row.push(null);

                    case "#":
						row.push(new Tile(j, i, 20, NONE));
                    
					case "0":
						row.push(new Tile(j, i, 4, NONE));
					case "1":
						row.push(new Tile(j, i, 6, NONE));
					case "2":
						row.push(new Tile(j, i, 8, NONE));
					case "3":
						row.push(new Tile(j, i, 10, NONE));
					case "4":
						row.push(new Tile(j, i, 12, NONE));
                        
					case "w":
						row.push(new Tile(j, i, 6, N));
					case "s":
						row.push(new Tile(j, i, 6, S));
					case "a":
						row.push(new Tile(j, i, 6, W));
					case "d":
						row.push(new Tile(j, i, 6, E));

					case "W":
						row.push(new Tile(j, i, 8, N));
					case "S":
						row.push(new Tile(j, i, 8, S));
					case "A":
						row.push(new Tile(j, i, 8, W));
					case "D":
						row.push(new Tile(j, i, 8, E));

					case "i":
						row.push(new Tile(j, i, 10, N));
					case "k":
						row.push(new Tile(j, i, 10, S));
					case "j":
						row.push(new Tile(j, i, 10, W));
					case "l":
						row.push(new Tile(j, i, 10, E));

					case "I":
						row.push(new Tile(j, i, 12, N));
					case "K":
						row.push(new Tile(j, i, 12, S));
					case "J":
						row.push(new Tile(j, i, 12, W));
					case "L":
						row.push(new Tile(j, i, 12, E));

					case "p":
						row.push(new Tile(j, i, 4, NONE));
						result.p = new Entity(j, i, 4, 2, N);
					case "P":
						row.push(new Tile(j, i, 6, NONE));
						result.p = new Entity(j, i, 6, 2, N);
					case "q":
						row.push(new Tile(j, i, 8, NONE));
						result.p = new Entity(j, i, 8, 2, N);
					case "Q":
						row.push(new Tile(j, i, 10, NONE));
						result.p = new Entity(j, i, 10, 2, N);
					case "r":
						row.push(new Tile(j, i, 12, NONE));
						result.p = new Entity(j, i, 12, 2, N);

					case "e":
						row.push(new Tile(j, i, 4, NONE));
						result.c1 = new Entity(j, i, 4, 4, N);
					case "E":
                        row.push(new Tile(j, i, 6, NONE));
						result.c1 = new Entity(j, i, 6, 4, N);
					case "f":
                        row.push(new Tile(j, i, 8, NONE));
						result.c1 = new Entity(j, i, 8, 4, N);
					case "F":
                        row.push(new Tile(j, i, 10, NONE));
						result.c1 = new Entity(j, i, 10, 4, N);
					case "g":
                        row.push(new Tile(j, i, 12, NONE));
						result.c1 = new Entity(j, i, 12, 4, N);

					case "n":
                        row.push(new Tile(j, i, 4, NONE));
						result.c2 = new Entity(j, i, 4, 4, N);
					case "N":
                        row.push(new Tile(j, i, 6, NONE));
						result.c2 = new Entity(j, i, 6, 4, N);
					case "m":
                        row.push(new Tile(j, i, 8, NONE));
						result.c2 = new Entity(j, i, 8, 4, N);
					case "M":
                        row.push(new Tile(j, i, 10, NONE));
						result.c2 = new Entity(j, i, 10, 4, N);
					case "o":
                        row.push(new Tile(j, i, 12, NONE));
						result.c2 = new Entity(j, i, 12, 4, N);
				}
			}
			result.Tiles.push(row);
		}

		return result;
	}

	public function clone():GameState {
		return this;
	}

	private function new() {}
}
