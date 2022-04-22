import GameState.RampDirection;
import GameState.Direction;
import GameState.Entity;
import GameState.Tile;
import h3d.prim.Cube;
import h3d.mat.BaseMaterial;
import h3d.mat.Material;
import format.abc.Data.Function;
import js.html.ObserverCallback;
import h3d.prim.Grid;
import h3d.mat.BlendMode;
import haxe.Json;
import h3d.mat.Texture;
import hxd.res.Any;
import haxe.io.Bytes;
import hxd.res.Model;
import hxd.fmt.hmd.Reader;
import haxe.io.Float32Array;
import h3d.Vector;
import h3d.scene.*;
import h3d.scene.fwd.*;

typedef ConfigDat = {
	var directional_light_direction:Array<Float>;
	var directional_light_colour:String;
	var directional_light_enable_specular:Bool;
	var ambient_light_colour:String;
	var shadow_power:Float;
	var shadow_color:String;
	var camera_offset:Array<Float>;
}

class Main extends SampleApp {
// 	var levelDat:String = "
//   ..###.###.
//   ###44444##
//   ###4I4JI##
//   ###4ii23##
//   1W11DjA111
//   DA111W11N1
//   1SP1111a00
//   .0w0e0000s
//   .0000d1a01
//   ";

	var levelDat:String = "cy9:GameStatey4:dirsazi1i2i3hy5:Tilesaau2cy4:Tiley14:ramp_directioni-1y6:heighti20y8:altitudezy1:yi1y1:xi2gcR3R4i-1R5i20R6zR7i1R8i3gcR3R4i-1R5i20R6zR7i1R8i4gncR3R4i-1R5i20R6zR7i1R8i6gcR3R4i-1R5i20R6zR7i1R8i7gcR3R4i-1R5i20R6zR7i1R8i8gnhacR3R4i-1R5i20R6zR7i2R8zgcR3R4i-1R5i20R6zR7i2R8i1gcR3R4i-1R5i20R6zR7i2R8i2gcR3R4i-1R5i12R6zR7i2R8i3gcR3R4i-1R5i12R6zR7i2R8i4gcR3R4i-1R5i12R6zR7i2R8i5gcR3R4i-1R5i12R6zR7i2R8i6gcR3R4i-1R5i12R6zR7i2R8i7gcR3R4i-1R5i20R6zR7i2R8i8gcR3R4i-1R5i20R6zR7i2R8i9ghacR3R4i-1R5i20R6zR7i3R8zgcR3R4i-1R5i20R6zR7i3R8i1gcR3R4i-1R5i20R6zR7i3R8i2gcR3R4i-1R5i12R6zR7i3R8i3gcR3R4zR5i12R6zR7i3R8i4gcR3R4i-1R5i12R6zR7i3R8i5gcR3R4i3R5i12R6zR7i3R8i6gcR3R4zR5i12R6zR7i3R8i7gcR3R4i-1R5i20R6zR7i3R8i8gcR3R4i-1R5i20R6zR7i3R8i9ghacR3R4i-1R5i20R6zR7i4R8zgcR3R4i-1R5i20R6zR7i4R8i1gcR3R4i-1R5i20R6zR7i4R8i2gcR3R4i-1R5i12R6zR7i4R8i3gcR3R4zR5i10R6zR7i4R8i4gcR3R4zR5i10R6zR7i4R8i5gcR3R4i-1R5i8R6zR7i4R8i6gcR3R4i-1R5i10R6zR7i4R8i7gcR3R4i-1R5i20R6zR7i4R8i8gcR3R4i-1R5i20R6zR7i4R8i9ghacR3R4i-1R5i6R6zR7i5R8zgcR3R4zR5i8R6zR7i5R8i1gcR3R4i-1R5i6R6zR7i5R8i2gcR3R4i-1R5i6R6zR7i5R8i3gcR3R4i1R5i8R6zR7i5R8i4gcR3R4i3R5i10R6zR7i5R8i5gcR3R4i3R5i8R6zR7i5R8i6gcR3R4i-1R5i6R6zR7i5R8i7gcR3R4i-1R5i6R6zR7i5R8i8gcR3R4i-1R5i6R6zR7i5R8i9ghacR3R4i1R5i8R6zR7i6R8zgcR3R4i3R5i8R6zR7i6R8i1gcR3R4i-1R5i6R6zR7i6R8i2gcR3R4i-1R5i6R6zR7i6R8i3gcR3R4i-1R5i6R6zR7i6R8i4gcR3R4zR5i8R6zR7i6R8i5gcR3R4i-1R5i6R6zR7i6R8i6gcR3R4i-1R5i6R6zR7i6R8i7gcR3R4i-1R5i6R6zR7i6R8i8gcR3R4i-1R5i6R6zR7i6R8i9ghacR3R4i-1R5i6R6zR7i7R8zgcR3R4i2R5i8R6zR7i7R8i1gcR3R4i-1R5i6R6zR7i7R8i2gcR3R4i-1R5i6R6zR7i7R8i3gcR3R4i-1R5i6R6zR7i7R8i4gcR3R4i-1R5i6R6zR7i7R8i5gcR3R4i-1R5i6R6zR7i7R8i6gcR3R4i3R5i6R6zR7i7R8i7gcR3R4i-1R5i4R6zR7i7R8i8gcR3R4i-1R5i4R6zR7i7R8i9ghancR3R4i-1R5i4R6zR7i8R8i1gcR3R4zR5i6R6zR7i8R8i2gcR3R4i-1R5i4R6zR7i8R8i3gcR3R4i-1R5i4R6zR7i8R8i4gcR3R4i-1R5i4R6zR7i8R8i5gcR3R4i-1R5i4R6zR7i8R8i6gcR3R4i-1R5i4R6zR7i8R8i7gcR3R4i-1R5i4R6zR7i8R8i8gcR3R4i2R5i6R6zR7i8R8i9ghancR3R4i-1R5i4R6zR7i9R8i1gcR3R4i-1R5i4R6zR7i9R8i2gcR3R4i-1R5i4R6zR7i9R8i3gcR3R4i-1R5i4R6zR7i9R8i4gcR3R4i1R5i6R6zR7i9R8i5gcR3R4i-1R5i6R6zR7i9R8i6gcR3R4i3R5i6R6zR7i9R8i7gcR3R4i-1R5i4R6zR7i9R8i8gcR3R4i-1R5i6R6zR7i9R8i9ghhy2:c2cy6:Entityy12:fromaltitudei6y5:fromyi6y5:fromxi8R5i4R6i6R7i6R8i8y3:diri2y7:fromdiri2gy1:pcR10R11i6R12i7R13i2R5i2R6i6R7i7R8i2R14i2R15i2gy2:c1cR10R11i4R12i8R13i4R5i4R6i4R7i8R8i4R14i2R15i2gy6:pillowcR10R11i4R12i7R13i3R5i1R6i4R7i7R8i3R14i2R15i2gg";

	var cache:h3d.prim.ModelCache;

	var prefabs:Map<String, Mesh>;
	var gamestate:GameState;

	var obs_static:h3d.scene.Object;
	var obs_static_grid:Array<Array<h3d.scene.Mesh>>;

	var obs_dynamic:h3d.scene.Object;
	
	var editor_gui:h3d.scene.Object;
	var editor_basegrid:h3d.scene.Object;

	var player_obj:h3d.scene.Object;
	var c1_obj:h3d.scene.Object;
	var c2_obj:h3d.scene.Object;
	var pillow_obj:h3d.scene.Object;
	var cameracontroller:CameraController;

	var config_dat:ConfigDat;
	var editormode:Bool = false;
	var editor_sel:Int = 0;


	var editor_toolbar_interacts : Array<h3d.scene.Interactive>;
	var editor_basegrid_interacts : Array<h3d.scene.Interactive> =[];

	public static function Rotation(rotInt:Int):Float {
		return (2 + rotInt) * Math.PI / 2.0;
	}

	function RenderLevel(rebuildstatic:Bool) {
		if (rebuildstatic) {
			//remove each static interact
			trace("rebuilding static");
			trace(editor_basegrid_interacts.length);
			for (i in 0...editor_basegrid_interacts.length){
				var interact = editor_basegrid_interacts[i];
				interact.remove();	
			}
			editor_basegrid_interacts=[];
			obs_static_grid=[];

			obs_static.removeChildren();
			editor_basegrid.removeChildren();
			for (j in 0...gamestate.Tiles.length) {
				var tileRow = gamestate.Tiles[j];
				var obs_static_grid_ROW:Array<h3d.scene.Mesh> = [];

				for (i in 0...tileRow.length) {
					//create little cube

					
					var obj:Mesh=null;
					
					var tile = tileRow[i];
					if (tile == null){						
						//add mesh cubes only when there's no tile.
						var cubey = new h3d.prim.Cube(1.8,1.8,0,true);
						cubey.addNormals();
						cubey.addUVs();
						obj = new Mesh(cubey, editor_grid_mat);
						obj.setPosition(i * 2, j * 2, 0);
						editor_basegrid.addChild(obj);
	
						obs_static_grid_ROW.push(null);			
					} else {
						switch (tile.ramp_direction) {
							case NONE:
								if (tile.height == 20) { // wall
									var floor:Int = Std.int((tile.height - 4) / 2);
									var dir:GameState.Direction = S;
									obj = cast(prefabs["Wall"].clone(),Mesh);
									obs_static.addChild(obj);
									obj.setPosition(i * 2, j * 2, 0);
									obs_static_grid_ROW.push(obj);
								} else {
									var floor:Int = Std.int((tile.height - 4) / 2);
									var dir:GameState.Direction = S;
									obj = cast(prefabs[Std.string(floor) + "_Floor"].clone(),Mesh);
									obs_static.addChild(obj);
									obj.setPosition(i * 2, j * 2, 0);
									obs_static_grid_ROW.push(obj);
								}
							default:
								var floor:Int = Std.int((tile.height - 6) / 2);
								var dir:GameState.Direction = S;
								// trace("height " + Std.string(tile.height));
								// trace(Std.string(floor) + "_Ramp");
								trace(Std.string(floor) + "_Ramp");
								obj = cast(prefabs[Std.string(floor) + "_Ramp"].clone(),Mesh);
								obs_static.addChild(obj);
								obj.setPosition(i * 2, j * 2, 0);
								obj.setRotation(0, 0, Rotation(tile.ramp_direction));
								obs_static_grid_ROW.push(obj);
						}
					}
					
					var interact : h3d.scene.Interactive = new h3d.scene.Interactive(obj.getCollider(), s3d);
					editor_basegrid_interacts.push(interact);
					if (editormode==false){
						interact.remove();
					}
					Editor_Basegrid_Interact(interact, obj, (function(int_i,int_j) {
						return function() {
							onBasegridButtonClick(int_i,int_j);
						}
					})(i,j), i, j);

				}				
				obs_static_grid.push(obs_static_grid_ROW);
			}
		}

		obs_dynamic.removeChildren();
		player_obj = null;
		c1_obj = null;
		c2_obj = null;
		pillow_obj = null;

		var model_player:h3d.scene.Object = prefabs["Player"].clone();
		var model_c1:h3d.scene.Object = prefabs["C1"].clone();
		var model_c2:h3d.scene.Object = prefabs["C2"].clone();
		var model_pillow:h3d.scene.Object = prefabs["Pillow"].clone();

		{
			var ent:GameState.Entity = gamestate.p;
			var obj = new h3d.scene.Object();
			obj.addChild(model_player);

			player_obj = obj;

			if (ent != null) {
				var i:Int = ent.x;
				var j:Int = ent.y;
				var z:Int = ent.altitude - 4;
				obs_dynamic.addChild(obj);
				obj.setPosition(i * 2, j * 2, z / 2);
				obj.setRotation(0, 0, Rotation(ent.dir));
			}
		}
		{
			var ent:GameState.Entity = gamestate.c1;
			var obj:h3d.scene.Object = model_c1;
			c1_obj = obj;
			if (ent != null) {
				var i:Int = ent.x;
				var j:Int = ent.y;
				var z:Int = ent.altitude - 4;

				obs_dynamic.addChild(obj);
				obj.setPosition(i * 2, j * 2, z / 2);
				obj.setRotation(0, 0, Rotation(ent.dir));
			}
		}
		{
			var ent:GameState.Entity = gamestate.c2;
			var obj:h3d.scene.Object = model_c2;
			c2_obj = obj;
			if (ent != null) {
				var i:Int = ent.x;
				var j:Int = ent.y;
				var z:Int = ent.altitude - 4;

				obs_dynamic.addChild(obj);
				obj.setPosition(i * 2, j * 2, z / 2);
				obj.setRotation(0, 0, Rotation(ent.dir));
			}
		}
		if (gamestate.pillow!=null)
		{
			var ent:GameState.Entity = gamestate.pillow;
			var obj:h3d.scene.Object = model_pillow;
			pillow_obj = obj;
			if (ent != null) {
				var i:Int = ent.x;
				var j:Int = ent.y;
				var z:Int = ent.altitude - 4;

				obs_dynamic.addChild(obj);
				obj.setPosition(i * 2, j * 2, z / 2);
				obj.setRotation(0, 0, Rotation(ent.dir));
			}
		}
	}


	function tryMove(entity, d:GameState.Direction, canChain:Bool, canTurn:Bool):Bool {
		if (!gamestate.canMove(entity, d))
			return false;
		var moved =  gamestate.tryMove(entity,d,true,true);
		if (!moved){
			return false;
		}

		moveTimer = MOVE_LENGTH;
		RenderLevel(false);
		return true;
	}

	public static inline var MOVE_LENGTH:Float = 0.15;

	var moveTimer:Float = -1;

	function DoLerp(obj:h3d.scene.Object, ent:GameState.Entity) {
		var progress = (MOVE_LENGTH - moveTimer) / MOVE_LENGTH;
		progress = Math.sin(progress * Math.PI / 2);
		var x:Float = ent.fromx * (1 - progress) + ent.x * progress;
		var y:Float = ent.fromy * (1 - progress) + ent.y * progress;
		var z:Float = ent.fromaltitude * (1 - progress) + ent.altitude * progress;
		z -= 4;

		var rotangle = hxd.Math.angleLerp(Math.PI + Rotation(ent.fromdir), Math.PI + Rotation(ent.dir), progress);

		obj.setPosition(x * 2, y * 2, z / 2);
		obj.setRotation(0, 0, rotangle);
	}

	function DoHop(obj:h3d.scene.Object, hopHeight:Float) {
		var progress = (MOVE_LENGTH - moveTimer) / MOVE_LENGTH;
		progress = Math.sin(progress * Math.PI / 2);

		var z:Float = Math.sin(progress * Math.PI) * hopHeight;

		obj.setPosition(0, 0, z / 2);
	}

	function AnimatePositions() {
		if (player_obj != null) {
			DoLerp(player_obj, gamestate.p);
			var hop_height = 0.3;
			if (gamestate.p.fromdir == gamestate.p.dir) {} else if (gamestate.p.fromdir == GameState.Tile.FlipDirection(gamestate.p.dir)) {
				hop_height = 2;
			} else {
				hop_height = 1;
			}
			DoHop(player_obj.getChildAt(0), hop_height);

			var off:Array<Float> = config_dat.camera_offset;
			s3d.camera.target.set(player_obj.x, player_obj.y, player_obj.z);
			s3d.camera.pos.set(player_obj.x + off[0], player_obj.y + off[1], player_obj.z + off[2]);
		}
		if (c1_obj != null) {
			DoLerp(c1_obj, gamestate.c1);
		}
		if (c2_obj != null) {
			DoLerp(c2_obj, gamestate.c2);
		}
		if (pillow_obj != null) {
			DoLerp(pillow_obj, gamestate.pillow);
		}
	}

	function TryPlace(e:Entity,x:Int,y:Int){
		if (
			(x==gamestate.p.x && y==gamestate.p.y) ||
			(x==gamestate.c1.x && y==gamestate.c1.y) ||
			(x==gamestate.c2.x && y==gamestate.c2.y))
		{
			return;
		}

		if (x!=-1 && y!=-1){
			//has to be a tile
			var floor:Tile = gamestate.Tiles[y][x];
			if (floor!=null){
				e.x = x;
				e.y = y;
				e.altitude = floor.heightCoord();
				e.fromx = e.x;
				e.fromy = e.y;
				e.fromaltitude = e.altitude;
				RenderLevel(false);
			}
		}

		var l_str = gamestate.ToString();
		trace(l_str);
		gamestate = GameState.FromString(l_str);
		var l_str2 = gamestate.ToString();
		trace(l_str2);
		trace("IDEMPOTENCE:",l_str==l_str2);
	}

	function AlterAltitude(x:Int,y:Int,alt:Int){
		var tile = gamestate.Tiles[y][x];
		if (alt==1){
			//if tile is null, create a new one
			if (tile==null){
				var t = new Tile(x,y,4,GameState.RampDirection.NONE);
				gamestate.Tiles[y][x]=t;				
			} else if (tile.isWall()){
				return;
			} else {
				tile.height+=2;
				//if too tall, turn to wall
				if (tile.height>12){
					tile.height=20;
					tile.ramp_direction = GameState.RampDirection.NONE;
				}
			}
		} else {
			if (tile==null){
				//do nothing
			} else if (tile.isWall()){
				tile.height=12;
			} else if (tile.height==4){
				gamestate.Tiles[y][x]=null;
			} else if (tile.ramp_direction!=NONE && tile.height==6) {
				tile.ramp_direction = NONE;
				tile.height-=2;
			}
			else {
				tile.height-=2;
			}
		}

		//if entity on tile, displace it upwards/downwards
		var ents = gamestate.CharactersAt(x,y);
		if (ents.length>0){
			var ent = ents[0];
			ent.altitude = tile.heightCoord();
		}

		RenderLevel(true);
	}

	function Rampify(x:Int,y:Int,d:RampDirection){
		var tile = gamestate.TileAt(x,y);
		if (tile==null){
			tile = new Tile(x,y,4,d);
			gamestate.Tiles[y][x]=tile;
		}
		if (tile.isWall()){
			return;
		}
		if (tile.ramp_direction !=d ){
			if (d!=NONE){
				if (tile.ramp_direction == NONE ){
					if (tile.height<12){
						tile.ramp_direction = d;
						tile.height+=2;
					}
				} else {
					tile.ramp_direction = d;			
				}
			} else {			
				if (tile.ramp_direction == NONE ){
					tile.ramp_direction = d;
				} else {
					tile.ramp_direction = d;	
					tile.height-=2;		
				}
			}
			tile.ramp_direction = d;
		}

		//if entity on tile, displace it upwards/downwards
		var ents = gamestate.CharactersAt(x,y);
		if (ents.length>0){
			var ent = ents[0];
			ent.altitude = tile.heightCoord();
		}
		
		RenderLevel(true);
	}

	function FitInBounds(e:Entity){
		if (e.x<0){
			e.x++;
		}
		if (e.y<0){
			e.y++;
		}
		
		if (e.x>=gamestate.Tiles[0].length){
			trace("reducingX");
			e.x--;
		}
		if (e.y>=gamestate.Tiles.length){
			trace("reducingY");
			e.y--;
		}
		e.fromx = e.x;
		e.fromy = e.y;
	}

	function RotateEntity(e:Entity){
		var oldX=e.x;
		var oldY=e.y;
		e.x = oldY;
		e.y = gamestate.Tiles.length-oldX-1;
		e.fromx=e.x;
		e.fromy=e.y;
	}

	function RotateTile(e:Tile){
		if (e==null){
			return;
		}
		var oldX=e.x;
		var oldY=e.y;
		e.x = oldY;
		if (e.ramp_direction!=NONE){
			e.ramp_direction =Tile.RotateCounterClockwise(e.ramp_direction);
		}
		e.y = gamestate.Tiles.length-oldX-1;
	}

	
	function FlipEntityH(e:Entity){
		if (e==null){
			return;
		}	
		e.x = gamestate.Tiles[0].length-1-e.x;
		e.fromx=e.x;
	}

	function FlipEntityV(e:Entity){
		e.y = gamestate.Tiles.length-1-e.y;
		e.fromy=e.y;
	}

	
	function FlipTileH(e:Tile){
		if (e==null){
			return;
		}
		e.x = gamestate.Tiles[0].length-1-e.x;
		if (e.ramp_direction == W || e.ramp_direction == E){
			e.ramp_direction = Tile.FlipDirection(e.ramp_direction);
		}
	}

	function FlipTileV(e:Tile){
		if (e==null){
			return;
		}
		e.y = gamestate.Tiles.length-1-e.y;
		if (e.ramp_direction == N || e.ramp_direction == S){
			e.ramp_direction = Tile.FlipDirection(e.ramp_direction);
		}
	}

	function RotateLevel(){
		trace("rotating level");
		//transpose gamestate.Tiles
		var newTiles = new Array();
		var old_W = gamestate.Tiles[0].length;
		var old_H = gamestate.Tiles.length;
		var new_W=old_H;
		var new_H = old_W;
		for (j in 0...new_H){
			var row_new = new Array();
			for (i in 0...new_W){
				var tile = gamestate.Tiles[i][old_W-1-j];
				RotateTile(tile);
				row_new.push(tile);
			}
			newTiles.push(row_new);
		}
		gamestate.Tiles=newTiles;

		RotateEntity(gamestate.p);
		RotateEntity(gamestate.c1);
		RotateEntity(gamestate.c2);
		RotateEntity(gamestate.pillow);

		RenderLevel(true);
	}

	function FlipLevelH(){
		trace("h-flipping level");
		//transpose gamestate.Tiles
		for (j in 0...gamestate.Tiles.length){
			var row = gamestate.Tiles[j];
			row.reverse();
			for (i in 0...row.length){
				FlipTileH(row[i]);
			}
		}
		FlipEntityH(gamestate.p);
		FlipEntityH(gamestate.c1);
		FlipEntityH(gamestate.c2);
		FlipEntityH(gamestate.pillow);

		RenderLevel(true);
	}

	function FlipLevelV(){
		trace("v-flipping level");
		gamestate.Tiles.reverse();
		for (j in 0...gamestate.Tiles.length){
			var row = gamestate.Tiles[j];
			for (i in 0...row.length){
				FlipTileV(row[i]);
			}
		}
		
		FlipEntityV(gamestate.p);
		FlipEntityV(gamestate.c1);
		FlipEntityV(gamestate.c2);
		FlipEntityV(gamestate.pillow);

		RenderLevel(true);
	}
	
	function ResizeLevel(dN:Int,dS:Int,dW:Int,dE:Int){
		
		
		//removing entities if dN/dW positive, or dS/dE negative

		//step 1, resize static arrays
		//North/South resize
		
		//if expanding
		if (dN<0 || dS>0){			
			var newRow:Array<Tile> = new Array<Tile>();
			for (i in 0...gamestate.Tiles[0].length){
				newRow.push(null);
			}
			if (dN<0){
				gamestate.Tiles.insert(0,newRow);
			} else {
				gamestate.Tiles.push(newRow);
			}
		} 
		if (dW<0 || dE>0) {
			for (j in 0...gamestate.Tiles.length){
				var row = gamestate.Tiles[j];
				if (dW<0){
					row.insert(0,null);
				} else {
					row.push(null);
				}
			}
		}

		//if contracting
		if (dN>0){
			if (gamestate.Tiles.length>1){
				gamestate.Tiles.splice(0,1);
			}
		}
		if (dS<0){
			if (gamestate.Tiles.length>1){
				gamestate.Tiles.splice(gamestate.Tiles.length-1,1);
			}
		}
		if (dW>0){
			if (gamestate.Tiles[0].length>1){
				for (j in 0...gamestate.Tiles.length){
					var row = gamestate.Tiles[j];
					row.splice(0,1);
				}
			}
		}
		if (dE<0){
			if (gamestate.Tiles[0].length>1){
				for (j in 0...gamestate.Tiles.length){
					var row = gamestate.Tiles[j];
					row.splice(row.length-1,1);
				}
			}
		}

		//only need to adjust coordinates if dN or dW non-negative
		var adjust_Y=0;
		var adjust_X=0;
		if (dN<0){
			adjust_Y=1;
		} 
		if (dN>0){
			adjust_Y=-1;
		}
		if (dW<0){
			adjust_X=1;
		}
		if (dW>0){
			adjust_X=-1;
		}
		for (j in 0...gamestate.Tiles.length){
			var row = gamestate.Tiles[j];
			for (i in 0...row.length){
				var tile = row[i];
				if (tile!=null){
					tile.x+=adjust_X;
					tile.y+=adjust_Y;
				}
			}
		}

		trace("adjust");
		trace(gamestate.p.x,gamestate.p.y);
		gamestate.p.x+=adjust_X;
		gamestate.p.y+=adjust_Y;
		gamestate.c1.x+=adjust_X;
		gamestate.c1.y+=adjust_Y;
		gamestate.c2.x+=adjust_X;
		gamestate.c2.y+=adjust_Y;
		gamestate.pillow.x+=adjust_X;
		gamestate.pillow.y+=adjust_Y;

		trace(gamestate.p.x,gamestate.p.y);
		FitInBounds(gamestate.p);
		FitInBounds(gamestate.c1);
		FitInBounds(gamestate.c2);
		FitInBounds(gamestate.pillow);

		trace(gamestate.p.x,gamestate.p.y);
		RenderLevel(true);
	}

	function EditorUpdate() {
		if (!editormode) {
			editor_gui.visible = false;
			editor_basegrid.visible = false;

			for (i in 0...editor_toolbar_interacts.length){
				var ei = editor_toolbar_interacts[i];
				ei.remove();
			}
			
			for (i in 0...editor_basegrid_interacts.length){
				var ei = editor_basegrid_interacts[i];
				ei.remove();				
			}
			return;
		}

		// editor_gui.visible = true;
		// for (i in 0...editor_toolbar_interacts.length){
		// 	var ei = editor_toolbar_interacts[i];
		// 	if (ei.parent==null){
		// 		s3d.addChild(ei);
		// 	}
		// }

		for (i in 0...editor_basegrid_interacts.length){
			var ei = editor_basegrid_interacts[i];
			if (ei.parent==null){
				s3d.addChild(ei);
			}
		}


		editor_basegrid.visible = true;

		if (hxd.Key.isPressed(hxd.Key.NUMBER_1)) {
			TryPlace(gamestate.p, editor_cursor_x, editor_cursor_y);
		}
		if (hxd.Key.isDown(hxd.Key.NUMBER_2)) {
			TryPlace(gamestate.c1, editor_cursor_x, editor_cursor_y);
		}
		if (hxd.Key.isDown(hxd.Key.NUMBER_3)) {
			TryPlace(gamestate.c2, editor_cursor_x, editor_cursor_y);
		}
		if (hxd.Key.isPressed(hxd.Key.NUMBER_4)) {
			if (gamestate.pillow!=null && gamestate.pillow.x == editor_cursor_x && gamestate.pillow.y == editor_cursor_y) {
				gamestate.pillow=null;
			} else {
				if (gamestate.pillow==null){
					gamestate.pillow = new Entity(0,0,0,1,Direction.S);
				}
				TryPlace(gamestate.pillow, editor_cursor_x, editor_cursor_y);
			}
		}
		if (hxd.Key.isPressed(hxd.Key.Q)){
			AlterAltitude(editor_cursor_x, editor_cursor_y, -1);
		}
		if (hxd.Key.isPressed(hxd.Key.E)){
			AlterAltitude(editor_cursor_x, editor_cursor_y, 1);
		}
		if (hxd.Key.isDown(hxd.Key.W)){
			Rampify(editor_cursor_x, editor_cursor_y, RampDirection.N);
		}
		if (hxd.Key.isDown(hxd.Key.S)){
			Rampify(editor_cursor_x, editor_cursor_y, RampDirection.S);
		}
		if (hxd.Key.isDown(hxd.Key.A)){
			Rampify(editor_cursor_x, editor_cursor_y, RampDirection.W);
		}
		if (hxd.Key.isDown(hxd.Key.D)){
			Rampify(editor_cursor_x, editor_cursor_y, RampDirection.E);
		}
		if (hxd.Key.isDown(hxd.Key.F)){
			Rampify(editor_cursor_x, editor_cursor_y, RampDirection.NONE);
		}
		var shiftDown:Bool = hxd.Key.isDown(hxd.Key.SHIFT);
		var delta = shiftDown?-1:1;
		if (hxd.Key.isPressed(hxd.Key.I)){
			ResizeLevel(-delta,0,0,0);
		}
		if (hxd.Key.isPressed(hxd.Key.K)){
			ResizeLevel(0,delta,0,0);
		}
		if (hxd.Key.isPressed(hxd.Key.J)){
			ResizeLevel(0,0,-delta,0);
		}
		if (hxd.Key.isPressed(hxd.Key.L)){
			ResizeLevel(0,0,0,delta);
		}
		if (hxd.Key.isPressed(hxd.Key.R)){
			if (shiftDown){
				RotateLevel();
				RotateLevel();
				RotateLevel();
			} else {
				RotateLevel();
			}
		}
		if (hxd.Key.isPressed(hxd.Key.H)){
			FlipLevelH();
		}
		if (hxd.Key.isPressed(hxd.Key.V)){
			FlipLevelV();
		}
		

		var buttonlist = editor_gui.getChildAt(0);
		for (i in 0...editor_buttons.length) {
			var mesh:Array<Mesh> = buttonlist.getChildAt(i).getMeshes();
			mesh[0].material = i == editor_sel ? noalphamat : alphamat;
		}

		var editor_list_pos:Vector = s3d.camera.pos.clone();
		var forward:Vector = s3d.camera.getViewDirection(0, 1, 0).toVector();
		forward = forward.multiply(10);

		editor_list_pos = editor_list_pos.add(forward);

		var down:Vector = s3d.camera.getViewDirection(0, 0, 1).toVector();
		down = down.multiply(1.8);
		editor_list_pos = editor_list_pos.add(down);

		editor_gui.setPosition(editor_list_pos.x, editor_list_pos.y, editor_list_pos.z);
	}

	override function update(dt:Float) {
		if (moveTimer >= 0) {
			AnimatePositions();
			EditorUpdate();
			moveTimer -= dt;
			if (moveTimer < 0) {
				// reset all lasts to set them to cur
				gamestate.p.fromx = gamestate.p.x;
				gamestate.p.fromy = gamestate.p.y;
				gamestate.p.fromaltitude = gamestate.p.altitude;
				gamestate.p.fromdir = gamestate.p.dir;
				gamestate.c1.fromx = gamestate.c1.x;
				gamestate.c1.fromy = gamestate.c1.y;
				gamestate.c1.fromaltitude = gamestate.c1.altitude;
				gamestate.c1.fromdir = gamestate.c1.dir;
				gamestate.c2.fromx = gamestate.c2.x;
				gamestate.c2.fromy = gamestate.c2.y;
				gamestate.c2.fromaltitude = gamestate.c2.altitude;
				gamestate.c2.fromdir = gamestate.c2.dir;
				gamestate.pillow.fromx = gamestate.pillow.x;
				gamestate.pillow.fromy = gamestate.pillow.y;
				gamestate.pillow.fromaltitude = gamestate.pillow.altitude;
				gamestate.pillow.fromdir = gamestate.pillow.dir;
			}
			return;
		}
		if (hxd.Key.isDown(hxd.Key.LEFT)) {
			tryMove(gamestate.p, W, true, true);
		} else if (hxd.Key.isDown(hxd.Key.RIGHT)) {
			tryMove(gamestate.p, E, true, true);
		} else if (hxd.Key.isDown(hxd.Key.UP)) {
			tryMove(gamestate.p, N, true, true);
		} else if (hxd.Key.isDown(hxd.Key.DOWN)) {
			tryMove(gamestate.p, S, true, true);
		}

		if (hxd.Key.isPressed(hxd.Key.TAB)) {
			editormode = !editormode;
			if (editormode==false){
				//remove all highlights
				for (j in 0...obs_static_grid.length){
					var row : Array<Mesh> = obs_static_grid[j];
					for (i in 0...row.length){
						var o : Mesh = row[i];
						if (o!=null){
							o.setScale(1);
							if (o!=null){
								o.material.blendMode = h3d.mat.BlendMode.None;
							}
						}
					}
				}
			}
		}
		AnimatePositions();
		EditorUpdate();
	}

	static var editor_buttons:Array<String> = [
		"Player", "C1", "C2", "0_Floor", "0_Ramp", "1_Floor", "1_Ramp", "2_Floor", "2_Ramp", "3_Floor", "3_Ramp", "4_Floor", "Wall"
	];
	var editor_cursor_x:Int=-1;
	var editor_cursor_y:Int=-1;

	function Editor_Basegrid_Interact(i:h3d.scene.Interactive, m:h3d.scene.Mesh, onclick:Void->Void, x:Int,y:Int){
		var beacon = null;
		var color = m.material.color.clone();
		i.bestMatch = true;
		var scale = m.scaleX;
		i.onClick = function(e:hxd.Event) {
			onclick();
		}
		i.onOver = function(e:hxd.Event) {
			// if (editor_sel != idx) {
				m.setScale(scale*1.1);
				var o : Mesh = cast(obs_static_grid[y][x], Mesh);
				if (o!=null){
					o.material.blendMode = h3d.mat.BlendMode.Add;
				}
				editor_cursor_x=x;
				editor_cursor_y=y;

			// };
			//   var s = new h3d.prim.Sphere(1, 32, 32);
			//   s.addNormals();
			//   beacon = new h3d.scene.Mesh(s, s3d);
			//   beacon.material.mainPass.enableLights = true;
			//   beacon.material.color.set(1, 0, 0);
			//   beacon.scale(0.01);
			//   beacon.x = e.relX;
			//   beacon.y = e.relY;
			//   beacon.z = e.relZ;
		};
		// i.onMove = i.onCheck = function(e:hxd.Event) {
			// if (beacon == null)
			// 	return;
			// beacon.x = e.relX;
			// beacon.y = e.relY;
			// beacon.z = e.relZ;
		// };
		i.onOut = function(e:hxd.Event) {
			m.setScale(scale);
			var o : Mesh = cast(obs_static_grid[y][x], Mesh);
			if (o!=null){
				o.material.blendMode = h3d.mat.BlendMode.None;
			}
			if ( editor_cursor_x == x && editor_cursor_y == y ) {
				editor_cursor_x = -1;
				editor_cursor_y = -1;
			}
		};
	}

	function Editor_Toolbar_Interact(i:h3d.scene.Interactive, m:h3d.scene.Mesh, onclick:Void->Void, idx:Int) {
		var beacon = null;
		var color = m.material.color.clone();
		i.bestMatch = true;
		var scale = m.scaleX;
		i.onClick = function(e:hxd.Event) {
			onclick();
		}
		i.onOver = function(e:hxd.Event) {
			// if (editor_sel != idx) {
				m.setScale(scale*1.1);
			// };
			//   var s = new h3d.prim.Sphere(1, 32, 32);
			//   s.addNormals();
			//   beacon = new h3d.scene.Mesh(s, s3d);
			//   beacon.material.mainPass.enableLights = true;
			//   beacon.material.color.set(1, 0, 0);
			//   beacon.scale(0.01);
			//   beacon.x = e.relX;
			//   beacon.y = e.relY;
			//   beacon.z = e.relZ;
		};
		// i.onMove = i.onCheck = function(e:hxd.Event) {
			// if (beacon == null)
			// 	return;
			// beacon.x = e.relX;
			// beacon.y = e.relY;
			// beacon.z = e.relZ;
		// };
		i.onOut = function(e:hxd.Event) {
			m.setScale(scale);
		};
	}

	function onBasegridButtonClick(i:Int,j:Int) {
		editor_sel = i;
		trace(i,j);
	}

	function onEditorToolbarButtonClick(i:Int) {
		editor_sel = i;
	}

	function create_editor_array() {
		editor_toolbar_interacts=[];

		
		var button_list = new Object();
		editor_gui.addChild(button_list);
		for (i in 0...editor_buttons.length) {
			var button_name = editor_buttons[i];

			trace("loading ", button_name);
			var obj = prefabs[button_name].clone();
			var meshes = obj.getMeshes();
			for (j in 0...meshes.length) {
				var mesh = meshes[j];
				mesh.material = alphamat;
			}
			obj.scale(0.2);
			button_list.addChild(obj);
			obj.setPosition((i - editor_buttons.length / 2) / 2, 0, 0);
			if (i <= 2) {
				obj.setRotation(0, 0, Math.PI);
				obj.setPosition((i - editor_buttons.length / 2) / 2, 0, -0.2);
			} else {
				obj.setRotation(0, 0, -Math.PI / 2);
			}
			obj.rotate(-15 * Math.PI * 2 / 360.0, 0, 0);

			var m:Mesh = meshes[0];
			var interact : h3d.scene.Interactive = new h3d.scene.Interactive(m.getCollider(), s3d);
			editor_toolbar_interacts.push(interact);
			interact.remove();
			Editor_Toolbar_Interact(interact, m, (function(idx) {
				return function() {
					onEditorToolbarButtonClick(idx);
				}
			})(i), i);
		}

		var grid_poly:h3d.prim.Polygon = new Grid(1, 1, 1, 1);
		grid_poly.addNormals();
		grid_poly.addUVs();
	}

	// stolen from https://github.com/Kha-Samples/heaps/blob/45babaddd41e38d16697adb35034f08a33193456/tools/fbx/Viewer.hx#L352
	// omg I would have never figured this out by myself.
	function fbxToHmd(data:haxe.io.Bytes, includeGeometry):Any {
		// already hmd
		if (data.get(0) == 'H'.code)
			return hxd.res.Any.fromBytes("model.hmd", data);

		var hmdOut = new hxd.fmt.fbx.HMDOut(null);
		hmdOut.absoluteTexturePath = true;
		hmdOut.loadFile(data);
		var hmd = hmdOut.toHMD(null, includeGeometry);
		var out = new haxe.io.BytesOutput();
		new hxd.fmt.hmd.Writer(out).write(hmd);
		var bytes = out.getBytes();
		return hxd.res.Any.fromBytes("model.hmd", bytes);
	}

	var alphamat:h3d.mat.Material;
	var noalphamat:h3d.mat.Material;
	var highlightmat:h3d.mat.Material;
	var editor_grid_mat:h3d.mat.Material;

	var editorgridmat:h3d.mat.Material;

	override function init() {
		cache = new h3d.prim.ModelCache();

		obs_static = new h3d.scene.Object();
		obs_dynamic = new h3d.scene.Object();
		editor_gui = new h3d.scene.Object();
		editor_basegrid = new h3d.scene.Object();
		s3d.addChild(obs_static);
		s3d.addChild(obs_dynamic);
		s3d.addChild(editor_gui);
		s3d.addChild(editor_basegrid);

		var config_bytes = VirtualResources["config.json"];
		var config_str = hxd.res.Any.fromBytes("config.json", config_bytes).toText();
		config_dat = Json.parse(config_str);
		trace(config_dat);
		var mesh_bytes_fbx = VirtualResources["blends/models.fbx"];

		var mesh_res:Any = fbxToHmd(mesh_bytes_fbx, true);
		var mesh_model:Model = mesh_res.toModel();
		var obj:h3d.scene.Object = cache.loadModel(mesh_model);

		var tex_res:Any = hxd.res.Any.fromBytes("blends/texture.png", VirtualResources["blends/texture.png"]);
		var tex:Texture = tex_res.toTexture();


		var materials:Array<h3d.mat.Material> = new Array<h3d.mat.Material>();
		obj.getMaterials(materials, true);

		trace("we have ", materials.length, " materials");
		for (i in 0...materials.length) {
			var m:h3d.mat.Material = materials[i];
			m.texture = tex;
		}
		alphamat = h3d.mat.Material.create(tex);
		alphamat.blendMode = BlendMode.Alpha;
		alphamat.color.a = 0.5;

		noalphamat = h3d.mat.Material.create(tex);
		noalphamat.blendMode = BlendMode.None;

		editor_grid_mat = h3d.mat.Material.create();
		// editor_grid_mat.blendMode = BlendMode.Add;
		// editor_grid_mat.color.setColor(0xffffff);
		editor_grid_mat.mainPass.depth(true,Always);
		editor_grid_mat.mainPass.layer = 100;
		editor_grid_mat.mainPass.setPassName("alpha");
		editor_grid_mat.blendMode = BlendMode.Alpha;
		editor_grid_mat.shadows=false;
		editor_grid_mat.castShadows=false;
		editor_grid_mat.color.a = 0.1;
		
		highlightmat = h3d.mat.Material.create(tex);
		highlightmat.blendMode = BlendMode.Add;
		highlightmat.color.a = 1.0;

		obj.applyAnimationTransform(true);

		s3d.camera.pos.set(-3, -5, 3);
		s3d.camera.target.z += -1;

		// print name of all children of obj
		var n = obj.numChildren;
		prefabs = new Map<String, Mesh>();
		for (i in 0...n) {
			var child:h3d.scene.Object = obj.getChildAt(i);
			var transform = child.getTransform();
			transform.setPosition(new Vector(0, 0, 0));
			// transform.rotate(Math.PI,0,0);
			child.setTransform(transform);
			child.scale(1);
			prefabs[child.name] = cast(child,Mesh);

			// var c = child.clone();

			// s3d.addChild(c);
			// c.x=0;
			// c.setPosition((i-3)*3,0,0);
		}

		gamestate = GameState.FromString(levelDat);

		

		RenderLevel(true);

		// obj.playAnimation(cache.loadAnimation(hxd.Res.models));

		var dirs:Array<Float> = config_dat.directional_light_direction;
		// add lights and setup materials
		var dir = new DirLight(new h3d.Vector(dirs[0], dirs[1], dirs[2]), s3d);
		dir.color = Vector.fromColor(Std.parseInt(config_dat.directional_light_colour));
		dir.enableSpecular = config_dat.directional_light_enable_specular;

		// for( m in obj.getMaterials() ) {
		//   var t = m.mainPass.getShader(h3d.shader.Texture);
		//   if( t != null ) t.killAlpha = true;
		//   m.mainPass.culling = None;
		//   m.getPass("shadow").culling = None;
		// }
		s3d.lightSystem.ambientLight.setColor(Std.parseInt(config_dat.ambient_light_colour));

		var shadow = s3d.renderer.getPass(h3d.pass.DefaultShadowMap);
		shadow.power = config_dat.shadow_power;
		shadow.color.setColor(Std.parseInt(config_dat.shadow_color));

		create_editor_array();
	}

	static var VirtualResources:Map<String, Bytes>;

	static function loadExternalResources() {
		VirtualResources = new Map<String, Bytes>();

		var toLoad = ["blends/models.fbx", "blends/texture.png", "config.json"];
		var loadedCount:Int = 0;

		for (i in 0...toLoad.length) {
			var path = toLoad[i];
			(function(p) {
				var cur = new hxd.net.BinaryLoader(p);
				cur.onLoaded = function(bytes) {
					try {
						trace("loaded " + p + " of size " + bytes.length);
						VirtualResources[p] = bytes;
						loadedCount++;
						if (loadedCount == toLoad.length) {
							trace("all resources loaded");

							new Main();
						}
					} catch (e:Dynamic) {
						cur.onError(e);
					}
				};

				cur.onProgress = function(cur, max) {
					trace(cur / max);
				};
				cur.onError = function(e) {
					trace(e);
				};
				cur.load();
			})(toLoad[i]);
		}
	}

	static function main() {
		hxd.Res.initEmbed();
		loadExternalResources();
	}
}
