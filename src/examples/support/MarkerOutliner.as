package examples.support {
	import com.transmote.flar.marker.FLARMarker;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * simple class to draw outlines around detected markers.
	 * 
	 * @author	Eric Socolofsky
	 * @url		http://transmote.com/flar
	 */
	public class MarkerOutliner extends Sprite {
		private var slate_corners:Shape;
		private var slate_shape2D:Shape;
		private var container_shape2D:Sprite;
		
		public function MarkerOutliner () {
			this.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
			this.slate_corners = new Shape();
			this.addChild(this.slate_corners);
			
			this.container_shape2D = new Sprite();
			this.addChild(this.container_shape2D);
			this.slate_shape2D = new Shape();
			this.container_shape2D.addChild(this.slate_shape2D);
		}
		
		public function drawOutlines (marker:FLARMarker, thickness:Number, color:Number) :void {
			this.drawCornersOutline(marker, thickness, color);
			this.draw2DShape(marker, thickness, color);
		}
		
		/**
		 * draw a circle at each of the four corners of the detected marker.
		 */
		public function drawCornersOutline (marker:FLARMarker, thickness:Number, color:Number) :void {
			this.slate_corners.graphics.lineStyle(thickness, color);
			var corners:Vector.<Point> = marker.corners;
			var vertex:Point = corners[0];
			for (var i:uint=0; i<corners.length; i++) {
				vertex = corners[i];
				this.slate_corners.graphics.drawCircle(vertex.x, vertex.y, 10);
			}
		}
		
		/**
		 * draw a square, and apply a 2D transformation to align it on-screen with the detected marker.
		 */
		public function draw2DShape (marker:FLARMarker, thickness:Number, color:Number) :void {
			this.slate_shape2D.graphics.lineStyle(thickness, color);
			this.slate_shape2D.graphics.drawRect(0, 0, 80, 80);
			
			// set any DisplayObject.transform.matrix to a FLARMarker.matrix2D 
			// to apply a 2D transformation to the DisplayObject.
			this.container_shape2D.transform.matrix = marker.matrix2D;
			
			/*
			// alternatively, pick and choose the properties to manipulate,
			// including x, y, rotation, and scale.
			this.container_shape2D.x = marker.x;
			this.container_shape2D.y = marker.y;
			this.container_shape2D.rotation = marker.rotation2D;
			this.container_shape2D.scaleX = this.container_shape2D.scaleY = marker.scale2D;
			*/
		}
		
		private function onEnterFrame (evt:Event) :void {
			this.slate_corners.graphics.clear();
			this.slate_shape2D.graphics.clear();
		}
	}
}