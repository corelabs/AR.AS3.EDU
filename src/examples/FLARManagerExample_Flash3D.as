package examples {
	import com.transmote.flar.FLARManager;
	import com.transmote.flar.marker.FLARMarkerEvent;
	import com.transmote.flar.utils.geom.FLARGeomUtils;
	import com.transmote.utils.time.FramerateDisplay;
	
	import examples.support.MarkerPlane;
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	/**
	 * FLARManagerExample_Flash3D maps a Loader object (a loaded image or animation)
	 * to a detected marker, using Flash Player 10's 3D capabilities.
	 * 
	 * NOTE: this is still not working correctly;
	 * there seems to be some discrepancy between FLARToolkit's coordinate system
	 * and Flash's 3D coordinate system that i can't resolve.
	 * i imagine the fix for this could be implemented in FLARGeomUtils.convertFLARMatrixToFlashMatrix3D,
	 * but i've had no luck so far....
	 * if you can figure this out, please contact me and i'll implement it.  thanks!
	 * 
	 * @author	Eric Socolofsky
	 * @url		http://transmote.com/flar
	 */
	public class FLARManagerExample_Flash3D extends Sprite {
		private var flarManager:FLARManager;
		private var markerPlane:MarkerPlane;
		
		
		public function FLARManagerExample_Flash3D () {
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
			// load an image to display on top of the marker.
			// note, this could be any content loaded with a Loader, still or animated.
			this.markerPlane = new MarkerPlane("../resources/assets/saqoosha.jpg");
			this.markerPlane.visible = false;
			this.addChild(this.markerPlane);
		}
		
		private function onMarkerAdded (evt:FLARMarkerEvent) :void {
			//trace("["+evt.marker.patternId+"] added");
			
			if (this.markerPlane) {
				this.markerPlane.visible = true;
				this.markerPlane.setTransform(evt.marker.matrix3D);
			}
		}
		
		private function onMarkerUpdated (evt:FLARMarkerEvent) :void {
			//trace("["+evt.marker.patternId+"] updated");
			
			if (this.markerPlane) {
				this.markerPlane.visible = true;
				this.markerPlane.setTransform(evt.marker.matrix3D);
			}
		}
		
		private function onMarkerRemoved (evt:FLARMarkerEvent) :void {
			//trace("["+evt.marker.patternId+"] removed");
			
			if (this.markerPlane) {
				this.markerPlane.visible = false;
			}
		}
	}
}