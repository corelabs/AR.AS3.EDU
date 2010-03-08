package examples {
	import com.transmote.flar.FLARManager;
	import com.transmote.flar.marker.FLARMarkerEvent;
	import com.transmote.utils.time.FramerateDisplay;
	
	import examples.support.MarkerOutliner;
	
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	
	/**
	 * FLARManagerExample_2D demonstrates how to access 2D information about detected markers,
	 * including x, y, rotation, and scale, and the (x,y) position of the four corners of the marker's outline.
	 * 
	 * @author	Eric Socolofsky
	 * @url		http://transmote.com/flar
	 */
	public class FLARManagerExample_2D extends Sprite {
		private var flarManager:FLARManager;
		private var markerOutliner:MarkerOutliner;
		
		public function FLARManagerExample_2D () {
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
			
			// MarkerOutliner is a simple class that draws an outline
			// around the edge of detected markers.
			this.markerOutliner = new MarkerOutliner();
			this.addChild(this.markerOutliner);
			
			// turn off interactivity in markerOutliner
			this.markerOutliner.mouseChildren = false;
		}
		
		private function onFlarManagerError (evt:ErrorEvent) :void {
			this.flarManager.removeEventListener(ErrorEvent.ERROR, this.onFlarManagerError);
			this.flarManager.removeEventListener(FLARMarkerEvent.MARKER_ADDED, this.onMarkerAdded);
			this.flarManager.removeEventListener(FLARMarkerEvent.MARKER_UPDATED, this.onMarkerUpdated);
			this.flarManager.removeEventListener(FLARMarkerEvent.MARKER_REMOVED, this.onMarkerRemoved);
			
			trace(evt.text);
			// NOTE: developers can include better feedback to the end user here if desired.
		}
		
		private function onMarkerAdded (evt:FLARMarkerEvent) :void {
			//trace("["+evt.marker.patternId+"] added");
			this.markerOutliner.drawOutlines(evt.marker, 8, this.getColorByPatternId(evt.marker.patternId));
		}
		
		private function onMarkerUpdated (evt:FLARMarkerEvent) :void {
			//trace("["+evt.marker.patternId+"] updated");
			this.markerOutliner.drawOutlines(evt.marker, 1, this.getColorByPatternId(evt.marker.patternId));
		}
		
		private function onMarkerRemoved (evt:FLARMarkerEvent) :void {
			//trace("["+evt.marker.patternId+"] removed");
			this.markerOutliner.drawOutlines(evt.marker, 4, this.getColorByPatternId(evt.marker.patternId));
		}
		
		private function getColorByPatternId (patternId:int) :Number {
			switch (patternId) {
				case 0:
					return 0xFF1919;
				case 1:
					return 0xFF19E8;
				case 2:
					return 0x9E19FF;
				case 3:
					return 0x192EFF;
				case 4:
					return 0x1996FF;
				case 5:
					return 0x19FDFF;
				case 6:
					return 0x19FF5A;
				case 7:
					return 0x19FFAA;
				case 8:
					return 0x6CFF19;
				case 9:
					return 0xF9FF19;
				case 10:
					return 0xFFCE19;
				case 11:
					return 0xFF9A19;
				case 12:
					return 0xFF6119;
				default:
					return 0xCCCCCC;
			}
		}
	}
}