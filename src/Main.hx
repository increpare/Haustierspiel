import h3d.Vector;
import h3d.scene.*;
import h3d.scene.fwd.*;

class Main extends SampleApp {

  var cache : h3d.prim.ModelCache;

  override function init() {
    cache = new h3d.prim.ModelCache();

    var obj:h3d.scene.Object = cache.loadModel(hxd.Res.models);
    obj.applyAnimationTransform(true);
    s3d.camera.pos.set( -3, -5, 3);
    s3d.camera.target.z += 1;

    trace("child count",obj.numChildren);
    trace("name",obj.name);
    //print name of all children of obj
    var n = obj.numChildren;
    for (i in 0...n) {
        var child:h3d.scene.Object = obj.getChildAt(i);
        var transform = child.getTransform();
        transform.setPosition(new Vector(0,0,0));
        // transform.rotate(Math.PI,0,0);
        child.setTransform(transform);
        var c = child.clone();
        c.scale(0.01);        
        s3d.addChild(c);
        c.x=0;
        c.setPosition((i-3)*3,0,0);
        trace("B",c.getAbsPos().getPosition());
    }

    // obj.playAnimation(cache.loadAnimation(hxd.Res.models));

    // add lights and setup materials
    var dir = new DirLight(new h3d.Vector( -1, 3, -10), s3d);
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

    new h3d.scene.CameraController(s3d).loadFromCamera();
  }

  static function main() {
    hxd.Res.initEmbed();
    new Main();
  }

}