package examples.support {
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Scene3D;
	import alternativa.engine3d.display.View;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.primitives.Box;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.types.Matrix3D;
	
	import com.transmote.flar.marker.FLARMarker;
	import com.transmote.flar.utils.geom.FLARAlternativaGeomUtils;
	
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import org.libspark.flartoolkit.core.param.FLARParam;
	import org.libspark.flartoolkit.core.types.matrix.FLARDoubleMatrix34;
	import org.libspark.flartoolkit.support.alternativa3d.FLARCamera3D;
	
	
	/**
	 * standard FLARToolkit Alternativa3D example, with our friends the Cubes.
	 * code is borrowed heavily from Makc the Great:
	 * http://makc3d.wordpress.com/2009/04/16/flartoolkit-and-alternativa3d-anyone/
	 * 
	 * the Alternativa3D platform can be found here:
	 * http://alternativaplatform.com/en/alternativa3d/
	 * please note, usage of the Alternativa3D platform is subject to Alternativa3D's licensing.
	 * 
	 * @author	Eric Socolofsky
	 * @url		http://transmote.com/flar
	 */
	public class SimpleCubes_Alternativa3D extends Sprite {
		private static const CUBE_SIZE:Number = 40;
		
		private var view:View;
		private var camera3D:FLARCamera3D;
		private var scene3D:Scene3D;
		
		private var bMirrorDisplay:Boolean;
		private var markersByPatternId:Vector.<Vector.<FLARMarker>>;	// FLARMarkers, arranged by patternId
		private var containersByMarker:Dictionary;						// Cube containers, hashed by corresponding FLARMarker
		
		
		public function SimpleCubes_Alternativa3D (numPatterns:uint, cameraParams:FLARParam, mirrorDisplay:Boolean, viewportWidth:Number, viewportHeight:Number) {
			this.bMirrorDisplay = mirrorDisplay;
			
			this.init(numPatterns);
			this.initAlternativa3DEnvironment(cameraParams, viewportWidth, viewportHeight);
		}

		public function addMarker (marker:FLARMarker) :void {
			// store marker
			var markerList:Vector.<FLARMarker> = this.markersByPatternId[marker.patternId];
			markerList.push(marker);
			
			// create a new Cube, and place it inside a container (Object3D) for manipulation
			var container:Object3D = new Object3D();
			var cube:Box = new Box(CUBE_SIZE, CUBE_SIZE, CUBE_SIZE);
			cube.z = 0.5 * CUBE_SIZE;
			cube.cloneMaterialToAllSurfaces(this.getMaterialByPatternId(marker.patternId));
			container.addChild(cube);
			this.scene3D.root.addChild(container);
			
			// associate container with corresponding marker
			this.containersByMarker[marker] = container;
		}
		
		public function removeMarker (marker:FLARMarker) :void {
			// find and remove marker
			var markerList:Vector.<FLARMarker> = this.markersByPatternId[marker.patternId];
			var markerIndex:uint = markerList.indexOf(marker);
			if (markerIndex != -1) {
				markerList.splice(markerIndex, 1);
			}
			
			// find and remove corresponding container
			var container:Object3D = this.containersByMarker[marker];
			if (container) {
				this.scene3D.root.removeChild(container);
			}
			
			delete this.containersByMarker[marker]
		}
		
		private function init (numPatterns:uint) :void {
			// set up lists (Vectors) of FLARMarkers, arranged by patternId
			this.markersByPatternId = new Vector.<Vector.<FLARMarker>>(numPatterns, true);
			while (numPatterns--) {
				this.markersByPatternId[numPatterns] = new Vector.<FLARMarker>();
			}
			
			// prepare hashtable for associating Cube containers with FLARMarkers
			this.containersByMarker = new Dictionary(true);
		}
		
		private function initAlternativa3DEnvironment (cameraParams:FLARParam, viewportWidth:Number, viewportHeight:Number) :void {
			this.scene3D = new Scene3D();
			this.scene3D.root = new Object3D();
			this.camera3D = new FLARCamera3D();
			this.camera3D.setParam(cameraParams);
			this.scene3D.root.addChild(this.camera3D);
			
			this.view = new View();
			this.view.width = viewportWidth;
			this.view.height = viewportHeight;
			this.view.camera = this.camera3D;
			
			this.addChild(this.view);
			
			this.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
		}
		
		private function onEnterFrame (evt:Event) :void {
			this.updateCubes();
			this.scene3D.calculate();
		}
		
		private function updateCubes () :void {
			// update all Cube containers according to the transformation matrix in their associated FLARMarkers
			var i:int = this.markersByPatternId.length;
			var markerList:Vector.<FLARMarker>;
			var marker:FLARMarker;
			var container:Object3D;
			var j:int;
			while (i--) {
				markerList = this.markersByPatternId[i];
				j = markerList.length;
				while (j--) {
					marker = markerList[j];
					container = this.containersByMarker[marker];
					this.applyTransform(container, marker.transformMatrix);
				}
			}
		}
		
		private function applyTransform (obj:Object3D, transmat:FLARDoubleMatrix34) :void {
			// Object3D transformation matrix is read-only in Alternativa3D,
			// so we must calculate and apply transformations manually.
			var m:Matrix3D = FLARAlternativaGeomUtils.convertFLARMatrixToAlternativaMatrix(transmat, this.bMirrorDisplay);
			
			// m is not scaled, but we shall calculate scales any way, just to be NaN-safe
			var sx:Number = Math.sqrt (m.a * m.a + m.e * m.e + m.i * m.i);
			var sy:Number = Math.sqrt (m.b * m.b + m.f * m.f + m.j * m.j);
			var sz:Number = Math.sqrt (m.c * m.c + m.g * m.g + m.k * m.k);
			
			var sinY:Number = m.i / sx;
			if (-1 < sinY && sinY < 1) {
				obj.rotationY = -Math.asin(sinY);
				obj.rotationX = Math.atan2(m.j * sz, m.k * sy);
				obj.rotationZ = Math.atan2(m.e, m.a);
			} else {
				obj.rotationY = (sinY > 0) ? -Math.PI / 2 : Math.PI / 2;
				obj.rotationX = 0;
				obj.rotationZ = Math.atan2 (-m.b, m.f);
			}
			
			obj.x = m.d;
			obj.y = m.h;
			obj.z = m.l;
		}
		
		private function getMaterialByPatternId (patternId:int) :FillMaterial {
			switch (patternId) {
				case 0:
					return new FillMaterial(0xFF1919, 1, BlendMode.NORMAL, 1, 0x730000);
				case 1:
					return new FillMaterial(0xFF19E8, 1, BlendMode.NORMAL, 1, 0x730067);
				case 2:
					return new FillMaterial(0x9E19FF, 1, BlendMode.NORMAL, 1, 0x420073);
				case 3:
					return new FillMaterial(0x192EFF, 1, BlendMode.NORMAL, 1, 0x000A73);
				case 4:
					return new FillMaterial(0x1996FF, 1, BlendMode.NORMAL, 1, 0x003E73);
				case 5:
					return new FillMaterial(0x19FDFF, 1, BlendMode.NORMAL, 1, 0x007273);
				case 6:
					return new FillMaterial(0x19FF5A, 1, BlendMode.NORMAL, 1, 0x007320);
				case 7:
					return new FillMaterial(0x19FFAA, 1, BlendMode.NORMAL, 1, 0x007348);
				case 8:
					return new FillMaterial(0x6CFF19, 1, BlendMode.NORMAL, 1, 0x297300);
				case 9:
					return new FillMaterial(0xF9FF19, 1, BlendMode.NORMAL, 1, 0x707300);
				case 10:
					return new FillMaterial(0xFFCE19, 1, BlendMode.NORMAL, 1, 0x735A00);
				case 11:
					return new FillMaterial(0xFF9A19, 1, BlendMode.NORMAL, 1, 0x734000);
				case 12:
					return new FillMaterial(0xFF6119, 1, BlendMode.NORMAL, 1, 0x732400);
				default:
					return new FillMaterial(0xCCCCCC, 1, BlendMode.NORMAL, 1, 0x666666);
			}
		}
	}
}