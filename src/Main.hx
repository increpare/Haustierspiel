import h3d.mat.Texture;
import hxd.res.Any;
import haxe.io.Bytes;
import hxd.res.Model;
import hxd.fmt.hmd.Reader;
import haxe.io.Float32Array;
import hxd.fmt.hmd.Data.Material;
import h3d.Vector;
import h3d.scene.*;
import h3d.scene.fwd.*;

class Main extends SampleApp {
	var levelDat:String = "
  ..###.###.
  ###44444##
  ###4I4JI##
  ###4ii23##
  1W11DjA111
  DA111W11N1
  1SP1111a00
  .0w0e0000s
  .0000d1a01
  ";

	var cache:h3d.prim.ModelCache;

	var prefabs:Map<String, h3d.scene.Object>;
	var gamestate:GameState;

	var obs_static:h3d.scene.Object;
	var obs_dynamic:h3d.scene.Object;
	var player_obj:h3d.scene.Object;
	var c1_obj:h3d.scene.Object;
	var c2_obj:h3d.scene.Object;
	var cameracontroller:CameraController;

	public static function Rotation(rotInt:Int):Float {
		return (2 + rotInt) * Math.PI / 2.0;
	}

	function RenderLevel(rebuildstatic:Bool) {
		if (rebuildstatic) {
			obs_static.removeChildren();
			for (j in 0...gamestate.Tiles.length) {
				var tileRow = gamestate.Tiles[j];
				for (i in 0...tileRow.length) {
					var tile = tileRow[i];
					if (tile == null)
						continue;
					switch (tile.ramp_direction) {
						case NONE:
							if (tile.height == 20) { // wall
								var floor:Int = Std.int((tile.height - 4) / 2);
								var dir:GameState.Direction = S;
								var obj = prefabs["Wall"].clone();
								obs_static.addChild(obj);
								obj.setPosition(i * 2, j * 2, 0);
							} else {
								var floor:Int = Std.int((tile.height - 4) / 2);
								var dir:GameState.Direction = S;
								var obj = prefabs[Std.string(floor) + "_Floor"].clone();
								obs_static.addChild(obj);
								obj.setPosition(i * 2, j * 2, 0);
							}
						default:
							var floor:Int = Std.int((tile.height - 6) / 2);
							var dir:GameState.Direction = S;
							trace("height " + Std.string(tile.height));
							trace(Std.string(floor) + "_Ramp");
							var obj = prefabs[Std.string(floor) + "_Ramp"].clone();
							obs_static.addChild(obj);
							obj.setPosition(i * 2, j * 2, 0);
							obj.setRotation(0, 0, Rotation(tile.ramp_direction));
					}
				}
			}
		}

		obs_dynamic.removeChildren();
		player_obj = null;
		c1_obj = null;
		c2_obj = null;

		var model_player:h3d.scene.Object = prefabs["Player"].clone();
		var model_c1:h3d.scene.Object = prefabs["C1"].clone();
		var model_c2:h3d.scene.Object = prefabs["C2"].clone();
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
	}

	function canMove(entity:GameState.Entity, d:GameState.Direction):Bool {
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
		var curtile = gamestate.TileAt(entity.x, entity.y);
		var tile = gamestate.TileAt(tx, ty);
		if (tile == null)
			return false;
		if (tile.isWall())
			return false;

		// if moving uphill
		if (curtile.heightCoord() < tile.heightCoord()) {
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
			if (curtile.heightCoord() + 2 < tile.heightCoord())
				return false;
		}
		// if both are ramps
		if (curtile.ramp_direction != NONE && tile.ramp_direction != NONE) {
			// if the target is going in your direction, it's always good
			if (Std.int(tile.ramp_direction) == Std.int(d)) {

      } else if (curtile.heightCoord() > tile.heightCoord()){
        //if we're going downhill, it's good
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

	function tryMove(entity, d:GameState.Direction, canChain:Bool, canTurn:Bool):Bool {
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
		var ents = gamestate.CharactersAt(tx, ty);
		if (ents.length > 0) {
			if (canChain == false) {
				return false;
			} else {
				var ent_under:GameState.Entity = ents[0];
				// if ent_under below you, you can step on it
				if (ent_under.altitude + ent_under.height < entity.altitude) {
					// nothing to do
				} else {
					// otherwise, try push
					if (tryMove(ent_under, d, false,false) == false) {
						return false;
					}
					// move upper in parallel, if any
					if (ents.length > 1) {
						var ent_above:GameState.Entity = ents[1];

						ent_above.fromx = ent_above.x;
						ent_above.fromy = ent_above.y;
						ent_above.fromaltitude = ent_above.altitude;

						ent_above.x = ent_under.x;
						ent_above.y = ent_under.y;
						ent_above.altitude = ent_under.altitude + ent_under.height;
					}
				}
			}
		}

		var tile = gamestate.TileAt(tx, ty);

		entity.fromx = entity.x;
		entity.fromy = entity.y;
		entity.fromaltitude = entity.altitude;
    entity.fromdir = entity.dir;

		entity.x = tx;
		entity.y = ty;
		entity.altitude = tile.altitude + tile.height;
    if (canTurn){
      if (entity.dir == d || entity.dir == GameState.Tile.FlipDirection(d)) {
        //do nothing

      } else {
        //turnn only 90 degrees
        entity.dir = d;
      }
    }

		if (tile.ramp_direction != NONE) {
			entity.altitude -= 1;
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

    var rotangle = hxd.Math.angleLerp( Math.PI+ Rotation(ent.fromdir), Math.PI+ Rotation(ent.dir), progress);

		obj.setPosition(x * 2, y * 2, z / 2);
		obj.setRotation(0, 0,rotangle);
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
      var hop_height =  0.3;
      if (gamestate.p.fromdir==gamestate.p.dir){
      } else if (gamestate.p.fromdir==GameState.Tile.FlipDirection(gamestate.p.dir)) {
        hop_height = 2;
      } else {
        hop_height = 1;
      }
			DoHop(player_obj.getChildAt(0), hop_height);

			s3d.camera.target.set(player_obj.x, player_obj.y, player_obj.z);
			s3d.camera.pos.set(player_obj.x, player_obj.y + 20, player_obj.z + 20);
		}
		if (c1_obj != null) {
			DoLerp(c1_obj, gamestate.c1);
		}
		if (c2_obj != null) {
			DoLerp(c2_obj, gamestate.c2);
		}
	}

	override function update(dt:Float) {
		if (moveTimer >= 0) {
			AnimatePositions();

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

		AnimatePositions();
	}

  function fbxToHmd( data : haxe.io.Bytes, includeGeometry ):Any {

		// already hmd
		if( data.get(0) == 'H'.code )
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

	override function init() {
		cache = new h3d.prim.ModelCache();

		obs_static = new h3d.scene.Object();
		obs_dynamic = new h3d.scene.Object();
		s3d.addChild(obs_static);
		s3d.addChild(obs_dynamic);

    var mesh_bytes_fbx = VirtualResources["blends/models.fbx"];

    
    var mesh_res:Any = fbxToHmd(mesh_bytes_fbx,true);
    var mesh_model:Model = mesh_res.toModel();
    var obj:h3d.scene.Object = cache.loadModel(mesh_model);

    

    var tex_res:Any =  hxd.res.Any.fromBytes("blends/texture.png",VirtualResources["blends/texture.png"]);
		var tex:Texture = tex_res.toTexture();

		var materials:Array<h3d.mat.Material> = new Array<h3d.mat.Material>();
		obj.getMaterials(materials, true);

		for (i in 0...materials.length) {
			var m:h3d.mat.Material = materials[i];
			m.texture = tex;
		}

		obj.applyAnimationTransform(true);
		s3d.camera.pos.set(-3, -5, 3);
		s3d.camera.target.z += -1;

		trace("child count", obj.numChildren);
		trace("name", obj.name);
		// print name of all children of obj
		var n = obj.numChildren;
		prefabs = new Map<String, h3d.scene.Object>();
		for (i in 0...n) {
			var child:h3d.scene.Object = obj.getChildAt(i);
			var transform = child.getTransform();
			transform.setPosition(new Vector(0, 0, 0));
			// transform.rotate(Math.PI,0,0);
			child.setTransform(transform);
			child.scale(1);
			prefabs[child.name] = child;
			trace("child", child.name);

			// var c = child.clone();

			// s3d.addChild(c);
			// c.x=0;
			// c.setPosition((i-3)*3,0,0);
		}

		gamestate = GameState.LoadFromString(levelDat);

		RenderLevel(true);

		// obj.playAnimation(cache.loadAnimation(hxd.Res.models));

		// add lights and setup materials
		var dir = new DirLight(new h3d.Vector(-3, -5, -10), s3d);
		// for( m in obj.getMaterials() ) {
		//   var t = m.mainPass.getShader(h3d.shader.Texture);
		//   if( t != null ) t.killAlpha = true;
		//   m.mainPass.culling = None;
		//   m.getPass("shadow").culling = None;
		// }
		s3d.lightSystem.ambientLight.set(0.4, 0.4, 0.4);

		var shadow = s3d.renderer.getPass(h3d.pass.DefaultShadowMap);
		shadow.power = 20;
		shadow.color.setColor(0x301030);
		dir.enableSpecular = true;
	}

	static var VirtualResources:Map<String, Bytes>;

	static function loadExternalResources() {
		VirtualResources = new Map<String, Bytes>();

		var toLoad = ["blends/models.fbx", "blends/texture.png"];
		var loadedCount:Int = 0;

		for (i in 0...toLoad.length) {
			var path = toLoad[i];
			(function(p) {
				var cur = new hxd.net.BinaryLoader(p);
				cur.onLoaded = function(bytes) {
					try {
						trace("loaded "+ p+" of size "+ bytes.length);
            VirtualResources[p] = bytes;
            loadedCount++;
            if (loadedCount==toLoad.length){
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
