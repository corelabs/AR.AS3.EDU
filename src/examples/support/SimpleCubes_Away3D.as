package examples.support {
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.lights.DirectionalLight3D;
	import away3d.materials.ShadingColorMaterial;
	import away3d.primitives.Cube;
	import away3d.primitives.Plane;
	
	import com.transmote.flar.marker.FLARMarker;
	import com.transmote.flar.utils.geom.FLARAwayGeomUtils;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import org.libspark.flartoolkit.core.param.FLARParam;
	import org.libspark.flartoolkit.core.types.FLARIntSize;
	import org.libspark.flartoolkit.support.away3d.FLARCamera3D;
	
	
	/**
	 * standard FLARToolkit Away3D example, with our friends the Cubes.
	 * code is borrowed heavily from Rob Bateman:
	 * http://www.infiniteturtles.co.uk/blog/away3d-the-flartoolkit
	 * 
	 * the Away3D platform can be found here:
	 * http://away3d.com/
	 * please note, usage of the Away3D platform is subject to Away3D's licensing.
	 * 
	 * @author	Eric Socolofsky
	 * @url		http://transmote.com/flar
	 */
	public class SimpleCubes_Away3D extends Sprite {
		private static const CUBE_SIZE:Number = 40;
		
		private var view:View3D;
		private var camera3D:FLARCamera3D;
		private var scene3D:Scene3D;
		private var light:DirectionalLight3D;
		
		private var bMirrorDisplay:Boolean;
		private var markersByPatternId:Vector.<Vector.<FLARMarker>>;	// FLARMarkers, arranged by patternId
		private var containersByMarker:Dictionary;						// Cube containers, hashed by corresponding FLARMarker
		
		
		public function SimpleCubes_Away3D (numPatterns:uint, cameraParams:FLARParam, mirrorDisplay:Boolean, viewportWidth:Number, viewportHeight:Number) {
			this.bMirrorDisplay = mirrorDisplay;
			
			this.init(numPatterns);
			this.initAway3DEnvironment(cameraParams, viewportWidth, viewportHeight);
		}

		public function addMarker (marker:FLARMarker) :void {
			// store marker
			var markerList:Vector.<FLARMarker> = this.markersByPatternId[marker.patternId];
			markerList.push(marker);
			
			// create a new Cube, and place it inside a container (ObjectContainer3D) for manipulation
			var container:ObjectContainer3D = new ObjectContainer3D();
			var mat:ShadingColorMaterial = this.getMaterialByPatternId(marker.patternId);
			var cube:Cube = new Cube({material:mat, width:CUBE_SIZE, height:CUBE_SIZE, depth:CUBE_SIZE});
			cube.y = 0.5 * CUBE_SIZE;
			container.addChild(cube);
			this.scene3D.addChild(container);
			
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
			var container:ObjectContainer3D = this.containersByMarker[marker];
			if (container) {
				this.scene3D.removeChild(container);
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
		
		private function initAway3DEnvironment (cameraParams:FLARParam, viewportWidth:Number, viewportHeight:Number) :void {
			this.scene3D = new Scene3D();
			this.camera3D = new FLARCamera3D();
			this.camera3D.setParam(cameraParams);
			
			// adjust camera to match sample and viewport sizes
			var sourceSize:FLARIntSize = cameraParams.getScreenSize();
			this.camera3D.zoom *= (0.25 * ((viewportWidth / sourceSize.w) + (viewportHeight / sourceSize.h)));
			
			this.view = new View3D({x:0.5*viewportWidth, y:0.5*viewportHeight, scene:this.scene3D, camera:this.camera3D});
			this.addChild(this.view);
			
			// thanks to holde from the FLARToolkit forums for help with Away3D lighting!
			this.light = new DirectionalLight3D({x:-1000, y:1000, z:-1000, brightness:1});
			this.scene3D.addChild(light);
			
			this.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
		}
		
		private function onEnterFrame (evt:Event) :void {
			this.updateCubes();
			this.view.render();
		}
		
		private function updateCubes () :void {
			// update all Cube containers according to the transformation matrix in their associated FLARMarkers
			var i:int = this.markersByPatternId.length;
			var markerList:Vector.<FLARMarker>;
			var marker:FLARMarker;
			var container:ObjectContainer3D;
			var j:int;
			while (i--) {
				markerList = this.markersByPatternId[i];
				j = markerList.length;
				while (j--) {
					marker = markerList[j];
					container = this.containersByMarker[marker];
					container.transform = FLARAwayGeomUtils.convertFLARMatrixToAwayMatrix(marker.transformMatrix, this.bMirrorDisplay);
				}
			}
		}
		
		private function getMaterialByPatternId (patternId:int) :ShadingColorMaterial {
			switch (patternId) {
				case 0:
					return new ShadingColorMaterial(null, {ambient:0xFF1919, diffuse:0x730000, specular: 0xFFFFFF});
				case 1:
					return new ShadingColorMaterial(null, {ambient:0xFF19E8, diffuse:0x730067, specular: 0xFFFFFF});
				case 2:
					return new ShadingColorMaterial(null, {ambient:0x9E19FF, diffuse:0x420073, specular: 0xFFFFFF});
				case 3:
					return new ShadingColorMaterial(null, {ambient:0x192EFF, diffuse:0x000A73, specular: 0xFFFFFF});
				case 4:
					return new ShadingColorMaterial(null, {ambient:0x1996FF, diffuse:0x003E73, specular: 0xFFFFFF});
				case 5:
					return new ShadingColorMaterial(null, {ambient:0x19FDFF, diffuse:0x007273, specular: 0xFFFFFF});
				case 6:
					return new ShadingColorMaterial(null, {ambient:0x19FF5A, diffuse:0x007320, specular: 0xFFFFFF});
				case 7:
					return new ShadingColorMaterial(null, {ambient:0x19FFAA, diffuse:0x007348, specular: 0xFFFFFF});
				case 8:
					return new ShadingColorMaterial(null, {ambient:0x6CFF19, diffuse:0x297300, specular: 0xFFFFFF});
				case 9:
					return new ShadingColorMaterial(null, {ambient:0xF9FF19, diffuse:0x707300, specular: 0xFFFFFF});
				case 10:
					return new ShadingColorMaterial(null, {ambient:0xFFCE19, diffuse:0x735A00, specular: 0xFFFFFF});
				case 11:
					return new ShadingColorMaterial(null, {ambient:0xFF9A19, diffuse:0x734000, specular: 0xFFFFFF});
				case 12:
					return new ShadingColorMaterial(null, {ambient:0xFF6119, diffuse:0x732400, specular: 0xFFFFFF});
				default:
					return new ShadingColorMaterial(null, {ambient:0xCCCCCC, diffuse:0x666666, specular: 0xFFFFFF});
			}
		}
	}
}