package examples.support {
	import com.transmote.flar.marker.FLARMarker;
	
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.net.URLRequest;
	
	/**
	 * simple class to align a plane with the plane of a detected marker.
	 * MarkerPlane loads a jpg and maps that to the marker.
	 * 
	 * @author	Eric Socolofsky
	 * @url		http://transmote.com/flar
	 */
	public class MarkerPlane extends Sprite {
		private var loaderContainer:Sprite;
		
		public function MarkerPlane (path:String="") {
			this.init();
			
			if (path != "") {
				this.load(path);
			}
		}
		
		public function load (path:String) :void {
			var loader:Loader = new Loader();
			loader.load(new URLRequest(path));
			loader.contentLoaderInfo.addEventListener(ErrorEvent.ERROR, this.onLoadError);
			loader.contentLoaderInfo.addEventListener(Event.INIT, this.onLoaded);
		}
		
		public function setTransform (transmat:Matrix3D) :void {
			this.loaderContainer.transform.matrix3D = transmat;
		}
		
		private function init () :void {
			this.loaderContainer = new Sprite();
			this.addChild(this.loaderContainer);
		}
		
		private function onLoadError (evt:ErrorEvent) :void {
			trace("error loading image...");
			var loaderInfo:LoaderInfo = evt.target as LoaderInfo;
			if (!loaderInfo) { return; }
			
			loaderInfo.removeEventListener(ErrorEvent.ERROR, this.onLoadError);
			loaderInfo.removeEventListener(Event.INIT, this.onLoaded);
		}
		
		private function onLoaded (evt:Event) :void {
			var loaderInfo:LoaderInfo = evt.target as LoaderInfo;
			if (!loaderInfo) { return; }
			
			loaderInfo.removeEventListener(ErrorEvent.ERROR, this.onLoadError);
			loaderInfo.removeEventListener(Event.INIT, this.onLoaded);
			
			var loader:Loader = loaderInfo.loader;
			
			// set loader width/height to match pattern size on-screen (FLARPattern.DEFAULT_UNSCALED_MARKER_WIDTH).
			// alternatively, match pattern size to loader size by setting size in flarConfig.xml:
			// <pattern path="..." size="300" />
			loader.width = 80;
			loader.height = 80;
			
			this.loaderContainer.addChild(loader);
		}
		
	}
}