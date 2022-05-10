package;

import haxe.Unserializer;
import haxe.Serializer;
import js.lib.Set;
import haxe.Int64;
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

//direction of increase
enum abstract RampDirection(Int) to Int from Int {
	var NONE=-1;
	var N=0;
	var E=1;
	var S=2;
	var W=3;
}
	
enum abstract Direction(Int) to Int from Int {
	var N=0;
	var E=1;
	var S=2;
	var W=3;   
}

class Interval {
	public var min:Int;
	public var max:Int;
	public function new(min:Int,max:Int){
		this.min = min;
		this.max = max;
	}
	public function Overlaps(other:Interval):Bool {
		if (other.min >= this.max || other.max <= this.min){
			return false;
		} else {
			return true;
		}
	}
}

class EdgeSilhouette {
	public var x:Int;
	public var y:Int;
	public var faceDir:Direction;
	public var left:Interval;
	public var right:Interval;
	public function new(e:Entity,dir:Direction,baseDir:RampDirection){
		var _dir:Int =  Std.int(dir);
		var _baseDir:Int = Std.int(baseDir);

		this.x = e.x;
		this.y = e.y;
		this.faceDir = dir;
		this.left = new Interval(e.altitude,e.altitude+e.height);
		this.right = new Interval(e.altitude,e.altitude+e.height);
		if (baseDir == RampDirection.NONE){
			//leave as is
		} else if (_dir == _baseDir ){
			//raise left and right by 1
			this.left.min += 1;
			this.left.max += 1;
			this.right.min += 1;
			this.right.max += 1;
		} else if (_dir == Tile.FlipDirection(_baseDir)){
			this.left.min += -1;
			this.left.max += -1;
			this.right.min += -1;
			this.right.max += -1;
		} else if (_dir == Tile.RotateCounterClockwise(_baseDir)){
			//lower left, raise right
			this.left.min += -1;
			this.left.max += -1;
			this.right.min += 1;
			this.right.max += 1;
		} else {
			//raise left, lower right
			this.left.min += 1;
			this.left.max += 1;
			this.right.min += -1;
			this.right.max += -1;
		}
	}

	public static function DirX(d:Direction):Int {
		if (d == Direction.E) {
			return 1;
		} else if (d == Direction.W) {
			return -1;
		} else {
			return 0;
		}
	}
	public static function DirY(d:Direction):Int {
		if (d == Direction.N) {
			return -1;
		} else if (d == Direction.S) {
			return 1;
		} else {
			return 0;
		}
	}

	public function Overlaps(other:Entity,other_rampDir:RampDirection):Bool {
		var targetX = this.x + DirX(this.faceDir);
		var targetY = this.y + DirY(this.faceDir);
		if (targetX != other.x || targetY != other.y) {
			return false;
		} 
		
		var other_fromDir:Direction = Tile.FlipDirection(Std.int(faceDir));
		var other_silhouette:EdgeSilhouette = new EdgeSilhouette(other, other_fromDir, other_rampDir);
		if (left.Overlaps(other_silhouette.right) || right.Overlaps(other_silhouette.left)) {
			return true;
		}
		return false;
	}
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
        return height + altitude + (ramp_direction==NONE ? 0 : -1);
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

	public static function RotateCounterClockwise(d:RampDirection):RampDirection{
		switch(d){
			case N: return W;
			case E: return N;
			case S: return E;
			case W: return S;
			default:return NONE;
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
    public var fromdir:Direction;

	public function new(x:Int, y:Int, altitude:Int, height:Int, dir:Direction) {
		// trace("creating new entity of height " + height);
		this.x = x;
		this.y = y;
        this.fromx = x;
        this.fromy = y;
		this.altitude = altitude;
        this.fromaltitude = altitude;
		this.height = height;
		this.dir = dir;
        this.fromdir=dir;
	}
}


class FromData {
	public var hash:Int64;
	public var wert:Float;
	public function new(_hash:Int64,_wert:Float){
		hash=_hash;
		wert=_wert;
	}
}

class GameState {
	public var Tiles:Array<Array<Tile>>;
	public var p:Entity;
	public var c1:Entity;
	public var c2:Entity;
	public var pillow:Entity;

	//accessors for w/h
	public var w(default, null):Int;
	public var h(default, null):Int;

	public function get_h():Int{
		return Tiles.length;
	}
	public function get_w():Int{
		return Tiles[0].length;
	}

	public function ToString():String{
		var serializer:Serializer = new Serializer();
		serializer.serialize(this);
		return serializer.toString();
	}

	public function ToStringTrace():String{
		var result:StringBuf=new StringBuf();
		result.add(p.x+","+p.y+","+p.altitude+","
				+c1.x+","+c1.y+","+c1.altitude+","
				+c2.x+","+c2.y+","+c2.altitude);
		return result.toString();
	}
	
	public static function FromString(s:String):GameState{
		var unserializer:Unserializer = new Unserializer(s);
		return unserializer.unserialize();
	}
	//14-bits per entity = 42 for a full state
	//x:0-32 (5)
	//y:0-32 (5)
	//z:0-32 (5)
	
	public function Heuristic():Float{
		//minimum of taxicab distance between possibel target points around c1
		var targetpoints = [[c1.x+2,c1.y], [c1.x-2,c1.y], [c1.x,c1.y+2], [c1.x,c1.y-2]];
		var curdist:Float=1000000;
		var dh = Math.abs(c1.height-c2.height);
		for(i in 0...targetpoints.length){
			var targetpoint = targetpoints[i];
			var dist=Math.abs(targetpoint[0]-c2.x)+Math.abs(targetpoint[1]-c2.y)-2;
			if (dist<0){
				dist*=-2;
			}
			dist+=dh;
			if(dist<curdist){
				curdist=dist;
			}
		}
		curdist*=5;

		//want height of floor between players to be 1 (penalize otherwise)
		var mpx:Int = Math.floor((c1.x+c2.x)/2);
		var mpy:Int = Math.floor((c1.y+c2.y)/2);
		var tile = TileAt(mpx,mpy);
		if (tile==null){
			curdist+=1;
		}
		else {
			var dh_middle = Math.abs(tile.heightCoord()-c1.height-1);
			curdist += dh_middle;
		}

		//want player to be close to midpoint
		
		//distance between c1 and c2
		var dx = c1.x-c2.x;
		var dy = c1.y-c2.y;
		var dist2 = 2-(Math.abs(dx)+Math.abs(dy));
		if (!(dx==0||dy==0)){
			dist2+=0.5;
		}

		var mx = (c1.x+c2.x)/2;
		var my = (c1.y+c2.y)/2;
		var ddx = mx-p.x;
		var ddy = my-p.y;
		var ddist2 =  Math.abs(ddx)+Math.abs(ddy);
		return dist2*1024 + ddist2;		
	}

	//pure entity-level collision detection
	public function canMove(entity:GameState.Entity, d:GameState.Direction):Bool {
		var dx = 0;
		var dy = 0;
		switch (d) {
			case W:
				dx = -1;
			case E:
				dx = 1;
			case N:
				dy = -1;
			case S:
				dy = 1;
		}
		var tx:Int = entity.x + dx;
		var ty:Int = entity.y + dy;
		var curtile = TileAt(entity.x, entity.y);//needs to return structure with height and ramp-direction

		//create virtual tile if entity is standing another entity
		var tile = TileAt(tx, ty);
		var curents = CharactersAt(entity.x, entity.y);
		for (i in 0...curents.length) {
			var ent = curents[i];
			if (ent.altitude<entity.altitude) {
				tile = new Tile(tx,ty, entity.altitude+tile.altitude, tile.ramp_direction);
			}
		}

		if (tile == null)
			return false;
		if (tile.isWall())
			return false;

		// if moving uphill
		if (entity.altitude < tile.heightCoord()) {
			if (tile.ramp_direction != NONE && Std.int(tile.ramp_direction) != Std.int(d))
				return false;
			// if you're on a ramp, can only move uphill in the ramp direction
			if (curtile.ramp_direction != NONE) {
				if (Std.int(curtile.ramp_direction) != Std.int(d))
					return false;
			}
			// if source and target are not ramps, can't move
			if (curtile.ramp_direction == NONE && tile.ramp_direction == NONE)
				return false;
			// you can never ascend by more than 2 units
			if (entity.altitude + 2 < tile.heightCoord())
				return false;
		}
		// if both are ramps
		if (curtile.ramp_direction != NONE && tile.ramp_direction != NONE) {
			//if both are same altitude layer && if your ramp is downhill, and the next one isn't directly uphill, cancel
			if (entity.height==tile.heightCoord() && curtile.ramp_direction == GameState.Tile.FlipDirection(d) && curtile.ramp_direction != GameState.Tile.FlipDirection(tile.ramp_direction) ) {
				return false;
			//if both are same altitude layer && if the source is going (uphill) in your direction, it's good 
			} else if (entity.altitude==tile.heightCoord() && Std.int(curtile.ramp_direction) == Std.int(d)){
		
			// if the target is going in your direction, it's always good
			} else if (Std.int(tile.ramp_direction) == Std.int(d)) {

			} else if (entity.altitude > tile.heightCoord()) {
				// if we're going downhill, it's good
			} else {
				// check both in the same direction or both in the opposite direction
				if (Std.int(curtile.ramp_direction) == Std.int(tile.ramp_direction)) {
					// both in the same direction, ok
				} else if (Std.int(curtile.ramp_direction) == GameState.Tile.FlipDirection(Std.int(tile.ramp_direction))) {
					if (Std.int(d) == Std.int(curtile.ramp_direction)) {
						// both in opposite direction and player moving in same direction as current ramp, ok
					} else {
						return false;
					}
				} else {
					return false;
				}
			}
		}

		return true;
	}

	public function tryMove(entity, d:GameState.Direction, canChain:Bool, canTurn:Bool):Bool {
		if (!canMove(entity, d))
			return false;

		var dx = 0;
		var dy = 0;
		switch (d) {
			case W:
				dx = -1;
			case E:
				dx = 1;
			case N:
				dy = -1;
			case S:
				dy = 1;
		}
		var tx:Int = entity.x + dx;
		var ty:Int = entity.y + dy;

		// check if entity at target location
		var ents = CharactersAt(tx, ty);

		var target_floorTile : Tile = TileAt(tx, ty);
		var target_ramp = target_floorTile.ramp_direction;
		var forwardSilhouette = new EdgeSilhouette(entity,d,target_ramp);
		var movedY:Int=-1;
		for (i in 0...ents.length) {
			var ent:Entity = ents[i];
			if (forwardSilhouette.Overlaps(ent,target_ramp)) {
				if (canChain==false) {
					return false;
				} else {
					var sy:Int = ent.y;
					if (tryMove(ent, d, true, false) == false) {						
						return false;
					}
					if (movedY<0 || movedY>sy){
						movedY=sy;
					}
				}
			}
		}
		if (movedY>=0){
			for (i in 0...ents.length-1) {
				var ent:Entity = ents[i];
				if (ent.x==tx && ent.y==ty && ent.altitude>movedY){
					tryMove(ent, d, true, false);
				}
			}
		}
		

		entity.fromx = entity.x;
		entity.fromy = entity.y;
		entity.fromaltitude = entity.altitude;
		entity.fromdir = entity.dir;

		entity.x = tx;
		entity.y = ty;
		entity.altitude = target_floorTile.altitude + target_floorTile.height;

		if (canTurn) {
			if (entity.dir == d || entity.dir == GameState.Tile.FlipDirection(d)) {
				// do nothing
			} else {
				// turn only 90 degrees
				entity.dir = d;
			}
		}

		if (target_floorTile.ramp_direction != NONE) {
			entity.altitude -= 1;
		}

		for (i in 0...ents.length) {
			var ent:Entity = ents[i];
			if (ent.x==tx && ent.y==ty && ent.altitude+ent.height>entity.altitude){
				entity.altitude = ent.altitude+ent.height;
			}
		}

		return true;
	}

	public function Transform(zustand:Int64,direction:Direction):Bool{
		FromHash(zustand);
		var moved = tryMove(p,direction,true,true);
		return moved;
	}
	var dirs:Array<Direction> = [N,E,S,W];

	public function ConstructSolution(hash:Int64,paths:Map<Int64,Int64>):Array<Direction>{
		return [];
	}

	public function TrySolve():Array<Direction>{


		//key = wo, value = wovon
		var Besucht:Map<Int64,Int64> = new Map<Int64,Int64>();
		var ZuVersuchen:Array<FromData> = [new FromData(ToHash(),Heuristic() ) ];

		while (ZuVersuchen.length>0){
			var zuVersuchen = ZuVersuchen.pop();
			var hash = zuVersuchen.hash;
			var wert = zuVersuchen.wert;
			if (Besucht.exists(hash)){
				continue;
			}

			for (i in 0...dirs.length){
				var dir = dirs[i];
				var moved = Transform(hash,dir);
				if (moved){
					var hash2 = ToHash();
					Besucht[hash2] = hash;

					var wert2 = Heuristic();
					var fromData = new FromData(hash2,wert2);
					
					if (wert2==0){
						return ConstructSolution(hash2,Besucht);
					}
					var inserted = false;
					for (j in 0...ZuVersuchen.length){
						var zuVersuchen2 = ZuVersuchen[j];
						if (zuVersuchen2.wert > wert2){
							ZuVersuchen.insert(j,fromData);
							inserted = true;
							break;
						}
					}
					if (!inserted){
						ZuVersuchen.push(fromData);
					}
					
				}
			}
			var ToInsert:Array<FromData> = [];
			if (Transform(hash,N)){
				ToInsert.push(new FromData(ToHash(),Heuristic()));
			}
			ZuVersuchen.sort( function(a:FromData,b:FromData){ return (a.wert==b.wert)?0:(a.wert<b.wert?-1:1);} );			
		}

		return [];
	}

	public function ToHash():Int64{

		// trace("serializing:");
		// trace(p.x,p.y,p.height);
		// trace(c1.x,c1.y,c1.height);
		// trace(c2.x,c2.y,c2.height);
		// if (pillow!=null){
		// 	trace(pillow.x,pillow.y,pillow.height);
		// }

		var low : haxe.Int32 = 
			p.x * (1<<0)
		+	p.y 			* (1<<5)
		+	p.height 		* (1<<10)
		+  c1.x 			* (1<<15)
		+  c1.y 			* (1<<20)
		+  c1.height 		* (1<<25);

		var high : haxe.Int32 = 
			c2.x * (1<<0)
		+	c2.y 			* (1<<5)
		+	c2.height 		* (1<<10);
		
		if(pillow!=null){
			high+=
				pillow.x 		* (1<<15)
			+ 	pillow.y 		* (1<<20)
			+ 	pillow.height	* (1<<25);
		}

		return Int64.make(high,low);
		//insert crate here?
	}

	public function FromHash(h:Int64){
		var low = h.low;
		var high = h.high;

		p.x = 0x1F & (low >> 0);
		p.y = 0x1F & (low >> 5);
		p.height = 0x1F & (low >> 10);

		c1.x = 0x1F & (low >> 15);
		c1.y = 0x1F & (low >> 20);
		c1.height = 0x1F & (low >> 25);

		c2.x = 0x1F & (high >> 0);
		c2.y = 0x1F & (high >> 5);
		c2.height = 0x1F & (high >> 10);

		if (pillow!=null){
			pillow.x = 0x1F & (high >> 15);
			pillow.y = 0x1F & (high >> 20);
			pillow.height = 0x1F & (high >> 25);
		}

		// trace("deserialized:");
		// trace(p.x,p.y,p.height);
		// trace(c1.x,c1.y,c1.height);
		// trace(c2.x,c2.y,c2.height);
	}

    public function TileAt(i:Int,j:Int):Tile{
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
		if (pillow!=null && i==pillow.x && j==pillow.y){
			result.push(pillow);
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
		if (pillow!=null && i==pillow.x && j==pillow.y && altitude==pillow.altitude){
			return pillow;
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
        
		result.Tiles = new Array<Array<Tile>>();
		for (i in 0...lines.length) {
			var line = lines[i];
			var row:Array<Tile> = [];
			for (j in 0...line.length) {
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
						result.p = new Entity(j, i, 4, 2, S);
					case "P":
						row.push(new Tile(j, i, 6, NONE));
						result.p = new Entity(j, i, 6, 2, S);
					case "q":
						row.push(new Tile(j, i, 8, NONE));
						result.p = new Entity(j, i, 8, 2, S);
					case "Q":
						row.push(new Tile(j, i, 10, NONE));
						result.p = new Entity(j, i, 10, 2, S);
					case "r":
						row.push(new Tile(j, i, 12, NONE));
						result.p = new Entity(j, i, 12, 2, S);

					case "e":
						row.push(new Tile(j, i, 4, NONE));
						result.c1 = new Entity(j, i, 4, 4, S);
					case "E":
                        row.push(new Tile(j, i, 6, NONE));
						result.c1 = new Entity(j, i, 6, 4, S);
					case "f":
                        row.push(new Tile(j, i, 8, NONE));
						result.c1 = new Entity(j, i, 8, 4, S);
					case "F":
                        row.push(new Tile(j, i, 10, NONE));
						result.c1 = new Entity(j, i, 10, 4, S);
					case "g":
                        row.push(new Tile(j, i, 12, NONE));
						result.c1 = new Entity(j, i, 12, 4, S);

					case "n":
                        row.push(new Tile(j, i, 4, NONE));
						result.c2 = new Entity(j, i, 4, 4, S);
					case "N":
                        row.push(new Tile(j, i, 6, NONE));
						result.c2 = new Entity(j, i, 6, 4, S);
					case "m":
                        row.push(new Tile(j, i, 8, NONE));
						result.c2 = new Entity(j, i, 8, 4, S);
					case "M":
                        row.push(new Tile(j, i, 10, NONE));
						result.c2 = new Entity(j, i, 10, 4, S);
					case "o":
                        row.push(new Tile(j, i, 12, NONE));
						result.c2 = new Entity(j, i, 12, 4, S);

					case "b":
						row.push(new Tile(j, i, 4, NONE));
						result.pillow = new Entity(j, i, 4, 2, S);
					case "B":
						row.push(new Tile(j, i, 6, NONE));
						result.pillow = new Entity(j, i, 6, 2, S);
					case "c":
						row.push(new Tile(j, i, 8, NONE));
						result.pillow = new Entity(j, i, 8, 2, S);
					case "C":
						row.push(new Tile(j, i, 10, NONE));
						result.pillow = new Entity(j, i, 10, 2, S);
					case "x":
						row.push(new Tile(j, i, 12, NONE));
						result.pillow = new Entity(j, i, 12, 2, S);
				}
			}
			if (row.length>0){
				result.Tiles.push(row);
			}			
		}

		return result;
	}

	public function clone():GameState {
		return this;
	}

	private function new() {}
}
