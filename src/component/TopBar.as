package component
{
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	
	import org.flexlite.domUI.components.Button;
	import org.flexlite.domUI.components.Group;
	import org.flexlite.domUI.components.Rect;
	
	public class TopBar extends Group
	{
		private var zoomInBtn:Button;
		private var zoomOutBtn:Button;
		public function TopBar()
		{
			super();
			
			this.addEventListener(Event.ADDED_TO_STAGE,addToStageHandler);
		}
		
		protected function addToStageHandler(event:Event):void
		{
			stage.addEventListener(FullScreenEvent.FULL_SCREEN,fullScreenChangeHandler);
		}
		
		protected function fullScreenChangeHandler(event:FullScreenEvent):void
		{
			zoomInBtn.visible = event.fullScreen;
			zoomOutBtn.visible = ! zoomInBtn.visible;
		}
		
		private function zoomInOutSwitch(evt:MouseEvent):void
		{
			if(stage.displayState == StageDisplayState.FULL_SCREEN)
			{
				stage.displayState = StageDisplayState.NORMAL;
			}else
			{
				stage.displayState = StageDisplayState.FULL_SCREEN
			}
		}
		
		//UI Bg
		override protected function createChildren():void
		{
			super.createChildren();
			
			var bg:Rect = new Rect();
			bg.fillColor = 0x0;
			bg.alpha = 0.6;
			bg.percentHeight = bg.percentWidth = 100;
			
			addElement(bg);
			
			
			zoomInBtn = new Button()
			zoomInBtn.visible = false;
			zoomInBtn.width = zoomInBtn.height = 22;
			zoomInBtn.verticalCenter = 0;
			zoomInBtn.right = 10;
//			zoomInBtn.skinName = new Bitmap(new zoomin.png);
			zoomInBtn.addEventListener(MouseEvent.CLICK,zoomInOutSwitch)
			
			addElement(zoomInBtn);
			
			
			zoomOutBtn = new Button()
			zoomOutBtn.verticalCenter = 0;
			zoomOutBtn.width = zoomOutBtn.height = 22;
			zoomOutBtn.right = 10;
//			zoomOutBtn.skinName = new Bitmap(new zoomout.png);
			zoomOutBtn.addEventListener(MouseEvent.CLICK,zoomInOutSwitch)
			
			addElement(zoomOutBtn);
		}
	}
}