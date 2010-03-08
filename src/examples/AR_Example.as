package examples {
	import com.transmote.flar.FLARManager;
	import com.transmote.flar.marker.FLARMarker;
	import com.transmote.flar.marker.FLARMarkerEvent;
	import com.transmote.flar.utils.geom.FLARPVGeomUtils;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.libspark.flartoolkit.support.pv3d.FLARCamera3D;
	import org.papervision3d.lights.PointLight3D;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.parsers.DAE;
	import org.papervision3d.render.LazyRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.Viewport3D;
	
	/**
	 * FLARManager_Tutorial3D demonstrates how to display a Collada-formatted model
	 * using FLARManager, FLARToolkit, and Papervision3D. 
	 * see the accompanying tutorial writeup here:
	 * http://words.transmote.com/wp/flarmanager/inside-flarmanager/loading-collada-models/
	 * 
	 * the collada model used for this example, scout.dae, was produced by Tom Tallian:
	 * http://tomtallian.com
	 * 
	 * @author	Eric Socolofsky
	 * @url		http://transmote.com/flar
	 */
	public class AR_Example extends Sprite {
		private const NUM_MARKERS:Number = 12; 
		
		private var flarManager:FLARManager;
		
		private var scene3D:Scene3D;
		private var camera3D:FLARCamera3D;
		private var viewport3D:Viewport3D;
		private var renderEngine:LazyRenderEngine;
		private var pointLight3D:PointLight3D;
		
		private var activeMarker:FLARMarker;
		private var activeMarkers:Array = new Array();
		private var modelContainer:DisplayObject3D;
		private var modelContainers:Array = new Array();
		private var models:Array = new Array();
		private var modelNames:Array = new Array("scout.dae", "scout.dae", "scout.dae", "scout.dae",
												 "scout.dae", "scout.dae", "scout.dae", "scout.dae",
												 "scout.dae", "scout.dae", "scout.dae", "scout.dae",
												 "scout.dae", "scout.dae", "scout.dae", "scout.dae",
												 "scout.dae", "scout.dae"); 
		
		
		public function AR_Example() {
			// pass the path to the FLARManager xml config file into the FLARManager constructor.
			// FLARManager creates and uses a FLARCameraSource by default.
			// the image from the first detected camera will be used for marker detection.
			this.flarManager = new FLARManager("../resources/flar/flarConfig.xml");
			
			// add FLARManager.flarSource to the display list to display the video capture.
			this.addChild(Sprite(this.flarManager.flarSource));
			
			// begin listening for FLARMarkerEvents.
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_ADDED, this.onMarkerAdded);
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_UPDATED, this.onMarkerUpdated);
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_REMOVED, this.onMarkerRemoved);
			
			// wait for FLARManager to initialize before setting up Papervision3D environment.
			this.flarManager.addEventListener(Event.INIT, this.onFlarManagerInited);
		}
		
		private function onFlarManagerInited (evt:Event) :void {
			this.flarManager.removeEventListener(Event.INIT, this.onFlarManagerInited);
			
			this.scene3D = new Scene3D();
			
			// initialize FLARCamera3D with parsed camera parameters.
			this.camera3D = new FLARCamera3D(this.flarManager.cameraParams);
			
			this.viewport3D = new Viewport3D(this.stage.stageWidth, this.stage.stageHeight);
			this.addChild(this.viewport3D);
			
			this.renderEngine = new LazyRenderEngine(this.scene3D, this.camera3D, this.viewport3D);
			
			this.pointLight3D = new PointLight3D();
			this.pointLight3D.x = 1000;
			this.pointLight3D.y = 1000;
			this.pointLight3D.z = -1000;
			
			//load all DAE models
			this.loadModels();			
			this.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
		}
		
		private function onMarkerAdded (evt:FLARMarkerEvent) :void {
			trace("["+evt.marker.patternId+"] added");
			var container:DisplayObject3D = new DisplayObject3D();
			for (var i:Number = 0; i<modelNames.length; i++){
				container = this.modelContainers[i];
				//trace('Pattern', evt.marker.patternId);
				//trace('ID', container.id, 'patternId', evt.marker.patternId);
				if(container.id == evt.marker.patternId){
					if(container.visible != true){
						container.visible = true;
						this.modelContainers[i] = container;
						this.activeMarkers[i] = evt.marker;
					}
				}
			}	
		}
		
		private function loadModels(): void {
			// load the model.
			// (this model has to be scaled and rotated to fit the marker; every model is different.)
			for (var i:Number = 0; i<modelNames.length; i++){
				var model:DAE = new DAE(true, "model"+i, true);	
				model.load("../resources/assets/" + this.modelNames[i].toString());
				model.rotationX = 90;
				model.rotationZ = 90;
				model.scale = 0.5;
				this.models.push(model);
				
				// create a container for the model, that will accept matrix transformations.
				var container:DisplayObject3D = new DisplayObject3D();
				container.id = i;
				container.addChild(model);
				container.visible = false;
				this.scene3D.addChild(container);
				this.modelContainers.push(container);
			}
		}
		
		private function onMarkerUpdated (evt:FLARMarkerEvent) :void {
			//trace("["+evt.marker.patternId+"] updated");
			var container:DisplayObject3D = new DisplayObject3D();
			for (var i:Number = 0; i<modelNames.length; i++){
				container = this.modelContainers[i];
				if(container.id == evt.marker.patternId){
					container.visible = true;
					this.modelContainers[i] = container;
					this.activeMarkers[i] = evt.marker;
				}
			}
		}
		
		private function onMarkerRemoved (evt:FLARMarkerEvent) :void {
			trace("["+evt.marker.patternId+"] removed");
			var container:DisplayObject3D = new DisplayObject3D();
			for (var i:Number = 0; i<modelNames.length; i++){
				container = this.modelContainers[i];
				if(container.id == evt.marker.patternId){
					//trace('IN removed!!!');
					container.visible = false;
					this.modelContainers[i] = container;
					this.activeMarkers[i] = null;
				}
			}
		}
		
		private function onEnterFrame (evt:Event) :void {
			// apply the FLARToolkit transformation matrix to the Cube.
			var container:DisplayObject3D = new DisplayObject3D();
			var actMarker:FLARMarker;
			for (var i:Number = 0; i<modelNames.length; i++){
				actMarker = this.activeMarkers[i];
				if (actMarker){
					container = this.modelContainers[i];
					container.transform = FLARPVGeomUtils.convertFLARMatrixToPVMatrix(actMarker.transformMatrix);
					modelContainers[i] = container;
				}
			}
			
			/*if (this.activeMarker) {
				this.modelContainer.transform = FLARPVGeomUtils.convertFLARMatrixToPVMatrix(this.activeMarker.transformMatrix);
			}*/
			
			// update the Papervision3D view.
			this.renderEngine.render();
		}
	}
}