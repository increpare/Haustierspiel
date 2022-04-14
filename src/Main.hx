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
	var obs_editor:h3d.scene.Object;
	var player_obj:h3d.scene.Object;
	var c1_obj:h3d.scene.Object;
	var c2_obj:h3d.scene.Object;
	var cameracontroller:CameraController;

	var config_dat:ConfigDat;
	var editormode:Bool = false;
	var editor_sel:Int = 0;
	var editor_grid:Object;

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
							// trace("height " + Std.string(tile.height));
							// trace(Std.string(floor) + "_Ramp");
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
			if (Std.int(tile.ramp_direction) == Std.int(d)) {} else if (curtile.heightCoord() > tile.heightCoord()) {
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
					if (tryMove(ent_under, d, false, false) == false) {
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
		if (canTurn) {
			if (entity.dir == d || entity.dir == GameState.Tile.FlipDirection(d)) {
				// do nothing
			} else {
				// turnn only 90 degrees
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
	}

	function EditorUpdate() {
		if (!editormode) {
			obs_editor.visible = false;
			editor_grid.visible = false;
			return;
		}

		obs_editor.visible = true;
		editor_grid.visible = true;

		if (hxd.Key.isDown(hxd.Key.NUMBER_1)) {
			editor_sel = 0;
		} else if (hxd.Key.isDown(hxd.Key.NUMBER_2)) {
			editor_sel = 1;
		} else if (hxd.Key.isDown(hxd.Key.NUMBER_3)) {
			editor_sel = 2;
		} else if (hxd.Key.isDown(hxd.Key.NUMBER_4)) {
			editor_sel = 3;
		} else if (hxd.Key.isDown(hxd.Key.NUMBER_5)) {
			editor_sel = 4;
		} else if (hxd.Key.isDown(hxd.Key.NUMBER_6)) {
			editor_sel = 5;
		} else if (hxd.Key.isDown(hxd.Key.NUMBER_7)) {
			editor_sel = 6;
		} else if (hxd.Key.isDown(hxd.Key.NUMBER_8)) {
			editor_sel = 7;
		} else if (hxd.Key.isDown(hxd.Key.NUMBER_9)) {
			editor_sel = 8;
		} else if (hxd.Key.isDown(hxd.Key.NUMBER_0)) {
			editor_sel = 9;
		} else if (hxd.Key.isDown(hxd.Key.I)) {
			editor_sel = 10;
		} else if (hxd.Key.isDown(hxd.Key.O)) {
			editor_sel = 11;
		} else if (hxd.Key.isDown(hxd.Key.P)) {
			editor_sel = 12;
		}

		var buttonlist = obs_editor.getChildAt(0);
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

		obs_editor.setPosition(editor_list_pos.x, editor_list_pos.y, editor_list_pos.z);
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
			trace(editormode);
		}
		AnimatePositions();
		EditorUpdate();
	}

	static var editor_buttons:Array<String> = [
		"Player", "C1", "C2", "0_Floor", "0_Ramp", "1_Floor", "1_Ramp", "2_Floor", "2_Ramp", "3_Floor", "3_Ramp", "4_Floor", "Wall"
	];

	function create_editor_array() {
		// obs_dynamic.visible=false;
		// obs_static.visible=false;
		var button_list = new Object();
		obs_editor.addChild(button_list);
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
		}

		var grid_poly:h3d.prim.Polygon = new Grid(1, 1, 1, 1);
		grid_poly.addNormals();
		grid_poly.addUVs();
		
		var editor_grid_mesh:Mesh = new Mesh(grid_poly, editorgridmat);

		editor_grid = editor_grid_mesh;
		s3d.addChild(editor_grid);
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
	var editorgridmat:h3d.mat.Material;

	override function init() {
		cache = new h3d.prim.ModelCache();

		obs_static = new h3d.scene.Object();
		obs_dynamic = new h3d.scene.Object();
		obs_editor = new h3d.scene.Object();
		s3d.addChild(obs_static);
		s3d.addChild(obs_dynamic);
		s3d.addChild(obs_editor);
		obs_static.visible = false;
		obs_dynamic.visible = false;
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

		var tex_grid = hxd.Res.gridtex.toTexture();

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

		editorgridmat = h3d.mat.Material.create(tex_grid);
		editorgridmat.blendMode = BlendMode.Add;

		obj.applyAnimationTransform(true);

		s3d.camera.pos.set(-3, -5, 3);
		s3d.camera.target.z += -1;

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

			// var c = child.clone();

			// s3d.addChild(c);
			// c.x=0;
			// c.setPosition((i-3)*3,0,0);
		}

		gamestate = GameState.LoadFromString(levelDat);

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
