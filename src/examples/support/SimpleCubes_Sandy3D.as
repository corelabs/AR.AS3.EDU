package examples.support {
	import com.transmote.flar.marker.FLARMarker;
	import com.transmote.flar.utils.geom.FLARSandyGeomUtils;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import org.libspark.flartoolkit.core.param.FLARParam;
	import org.libspark.flartoolkit.core.types.FLARIntSize;
	import org.libspark.flartoolkit.support.sandy3d.FLARCamera3D;
	
	import sandy.core.Scene3D;
	import sandy.core.scenegraph.Group;
	import sandy.core.scenegraph.TransformGroup;
	import sandy.materials.Appearance;
	import sandy.materials.ColorMaterial;
	import sandy.materials.attributes.LightAttributes;
	import sandy.materials.attributes.MaterialAttributes;
	import sandy.primitive.Box;
	
	
	/**
	 * standard FLARToolkit Sandy3D example, with our friends the Cubes.
	 * code is borrowed heavily from Makc the Great:
	 * http://makc3d.wordpress.com/2009/03/17/sandy-augmented-reality/
	 * 
	 * the Sandy3D platform can be found here:
	 * http://www.flashsandy.org/
	 * please note, usage of the Sandy3D platform is subject to Sandy3D's licensing.
	 * 
	 * @author	Eric Socolofsky
	 * @url		http://transmote.com/flar
	 */
	public class SimpleCubes_Sandy3D extends Sprite {
		private static const CUBE_SIZE:Number = 40;
		
		private var viewport:Sprite;
		private var camera3D:FLARCamera3D;
		private var scene3D:Scene3D;
		
		private var bMirrorDisplay:Boolean;
		private var markersByPatternId:Vector.<Vector.<FLARMarker>>;	// FLARMarkers, arranged by patternId
		private var containersByMarker:Dictionary;						// Cube containers, hashed by corresponding FLARMarker
		
		
		public function SimpleCubes_Sandy3D (numPatterns:uint, cameraParams:FLARParam, mirrorDisplay:Boolean, viewportWidth:Number, viewportHeight:Number) {
			this.bMirrorDisplay = mirrorDisplay;
			
			this.init(numPatterns);
			this.initSandy3DEnvironment(cameraParams, viewportWidth, viewportHeight);
		}

		public function addMarker (marker:FLARMarker) :void {
			// store marker
			var markerList:Vector.<FLARMarker> = this.markersByPatternId[marker.patternId];
			markerList.push(marker);
			
			// create a new Cube, and place it inside a container (TransformGroup) for manipulation
			var container:TransformGroup = new TransformGroup();
			var cube:Box = new Box("cube", CUBE_SIZE, CUBE_SIZE, CUBE_SIZE);
			cube.z = 0.5 * CUBE_SIZE;
			cube.appearance = new Appearance(this.getMaterialByPatternId(marker.patternId));
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
			var container:TransformGroup = this.containersByMarker[marker];
			if (container) {
				container.remove();
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
		
		private function initSandy3DEnvironment (cameraParams:FLARParam, viewportWidth:Number, viewportHeight:Number) :void {
			this.viewport = new Sprite();
			var screenSize:FLARIntSize = cameraParams.getScreenSize();
			this.viewport.scaleX = viewportWidth / screenSize.w;
			this.viewport.scaleY = viewportHeight / screenSize.h;

			this.camera3D = new FLARCamera3D(cameraParams);
			
			this.scene3D = new Scene3D("scene3D", this.viewport, this.camera3D, new Group());
			
			this.addChild(this.viewport);
			
			this.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
		}
		
		private function onEnterFrame (evt:Event) :void {
			this.updateCubes();
			this.scene3D.render();
		}
		
		private function updateCubes () :void {
			// update all Cube containers according to the transformation matrix in their associated FLARMarkers
			var i:int = this.markersByPatternId.length;
			var markerList:Vector.<FLARMarker>;
			var marker:FLARMarker;
			var container:TransformGroup;
			var j:int;
			while (i--) {
				markerList = this.markersByPatternId[i];
				j = markerList.length;
				while (j--) {
					marker = markerList[j];
					container = this.containersByMarker[marker];
					container.resetCoords();
					container.matrix = FLARSandyGeomUtils.convertFLARMatrixToSandyMatrix(marker.transformMatrix, this.bMirrorDisplay);
				}
			}
		}
		
		private function getMaterialByPatternId (patternId:int) :ColorMaterial {
			var attr:MaterialAttributes = new MaterialAttributes(new LightAttributes(true, 0.1));
			var material:ColorMaterial = new ColorMaterial(0xFFFFFF, 1.0, attr);
			material.lightingEnable = true;
			
			switch (patternId) {
				case 0:
					material.color = 0xFF1919;
					break;
				case 1:
					material.color = 0xFF19E8;
					break;
				case 2:
					material.color = 0x9E19FF;
					break;
				case 3:
					material.color = 0x192EFF;
					break;
				case 4:
					material.color = 0x1996FF;
					break;
				case 5:
					material.color = 0x19FDFF;
					break;
				case 6:
					material.color = 0x19FF5A;
					break;
				case 7:
					material.color = 0x19FFAA;
					break;
				case 8:
					material.color = 0x6CFF19;
					break;
				case 9:
					material.color = 0xF9FF19;
					break;
				case 10:
					material.color = 0xFFCE19;
					break;
				case 11:
					material.color = 0xFF9A19;
					break;
				case 12:
					material.color = 0xFF6119;
					break;
				default:
					material.color = 0x00CCCC;
			}
			
			return material;
		}
	}
}