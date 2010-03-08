package examples {
	import com.transmote.flar.FLARManager;
	import com.transmote.flar.marker.FLARMarkerEvent;
	import com.transmote.utils.time.FramerateDisplay;
	
	import examples.support.SimpleCubes_Sandy3D;
	
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;

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
	public class FLARManagerExample_Sandy3D extends Sprite {
		private var flarManager:FLARManager;
		private var simpleCubes:SimpleCubes_Sandy3D;
		
		public function FLARManagerExample_Sandy3D () {
			this.init();
		}
		
		private function init () :void {
			// pass the path to the FLARManager xml config file into the FLARManager constructor.
			// FLARManager creates and uses a FLARCameraSource by default.
			// the image from the first detected camera will be used for marker detection.
			this.flarManager = new FLARManager("../resources/flar/flarConfig.xml");
			
			// handle any errors generated during FLARManager initialization.
			this.flarManager.addEventListener(ErrorEvent.ERROR, this.onFlarManagerError);
			
			// add FLARManager.flarSource to the display list to display the video capture.
			this.addChild(Sprite(this.flarManager.flarSource));
			
			// begin listening for FLARMarkerEvents.
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_ADDED, this.onMarkerAdded);
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_UPDATED, this.onMarkerUpdated);
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_REMOVED, this.onMarkerRemoved);
			
			// framerate display helps to keep an eye on performance.
			var framerateDisplay:FramerateDisplay = new FramerateDisplay();
			this.addChild(framerateDisplay);
			
			this.flarManager.addEventListener(Event.INIT, this.onFlarManagerInited);
		}
		
		private function onFlarManagerError (evt:ErrorEvent) :void {
			this.flarManager.removeEventListener(ErrorEvent.ERROR, this.onFlarManagerError);
			this.flarManager.removeEventListener(Event.INIT, this.onFlarManagerInited);
			
			trace(evt.text);
			// NOTE: developers can include better feedback to the end user here if desired.
		}
		
		private function onFlarManagerInited (evt:Event) :void {
			this.flarManager.removeEventListener(ErrorEvent.ERROR, this.onFlarManagerError);
			this.flarManager.removeEventListener(Event.INIT, this.onFlarManagerInited);
			this.simpleCubes = new SimpleCubes_Sandy3D(this.flarManager.numLoadedPatterns, this.flarManager.cameraParams,
												this.flarManager.mirrorDisplay, this.stage.stageWidth, this.stage.stageHeight);
			this.addChild(this.simpleCubes);
			
			// turn off interactivity in simpleCubes
			this.simpleCubes.mouseChildren = false;
		}
		
		private function onMarkerAdded (evt:FLARMarkerEvent) :void {
			//trace("["+evt.marker.patternId+"] added");
			this.simpleCubes.addMarker(evt.marker);
		}
		
		private function onMarkerUpdated (evt:FLARMarkerEvent) :void {
			//trace("["+evt.marker.patternId+"] updated");
		}
		
		private function onMarkerRemoved (evt:FLARMarkerEvent) :void {
			//trace("["+evt.marker.patternId+"] removed");
			this.simpleCubes.removeMarker(evt.marker);
		}
	}
}