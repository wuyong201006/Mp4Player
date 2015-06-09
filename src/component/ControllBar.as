package component
{
	import com.greensock.TweenLite;
	import com.hurlant.crypto.symmetric.NullPad;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	
	import date.DateString;
	
	import events.PlayerEvent;
	
	import org.flexlite.domUI.components.Button;
	import org.flexlite.domUI.components.Group;
	import org.flexlite.domUI.components.HSlider;
	import org.flexlite.domUI.components.Label;
	import org.flexlite.domUI.components.Rect;
	import org.flexlite.domUI.components.UIAsset;
	import org.flexlite.domUI.components.VSlider;
	
	public class ControllBar extends Group
	{
		private var tvmPng:UIAsset;
		private var progressBar:HSlider;
		private var volumeBar:VSlider;
		//UI PlayButton
		private var playBtn:Button;
		
		//UI StopButton
		private var pauseBtn:Button;
		
		private var curProLabel:Label;
		private var talProLabel:Label;
		
		private var zoomInBtn:Button;
		private var zoomOutBtn:Button;
		
		private var volumeContainer:Group;
		private var volumeOpenBtn:Button;
		private var volumeCloseBtn:Button;
		
		private var frameList:Array = [];
		private var frameBtnList:Vector.<Button>;
		public function ControllBar()
		{
			super();
			frameBtnList = new Vector.<Button>();
			this.addEventListener(Event.ADDED_TO_STAGE,addToStageHandler);
		}
		
		protected function addToStageHandler(event:Event):void
		{
			stage.addEventListener(FullScreenEvent.FULL_SCREEN,fullScreenChangeHandler);
//			stage.addEventListener(ResizeEvent.RESIZE, updatePosition);
		}
		
		public function updateProgressBarMaximum(value:Number):void
		{
			progressBar.maximum = value;
			talProLabel.text = int(progressBar.maximum/3600)+":"+DateString.dateToString(progressBar.maximum%3600);
		}
		
		public function updateProgressBarCur(value:Number):void
		{
			progressBar.value = value;
			curProLabel.text = int(value/3600)+":"+DateString.dateToString(value%3600);
		}
		
		public function set playStatus(value:Boolean):void
		{
			playBtn.visible = !(pauseBtn.visible = value);
		}
		
		private function set volumeStatus(value:Boolean):void
		{
			volumeOpenBtn.visible = !(volumeCloseBtn.visible = value);
		}
		
		private function clickHandler(event:MouseEvent):void
		{
			var data:int=0;
			if(event.target == playBtn)
			{
				data = 0;
				playStatus = true;
			}
			else
			{
				data = 1;
				playStatus = false;
			}
			
			dispatchEvent( new PlayerEvent(PlayerEvent.CONTROLLBAR_PLAY, data));
		}
		
		private function progressBarChange(event:Event):void
		{
			dispatchEvent( new PlayerEvent(PlayerEvent.CONTROLLBAR_UPDATE, progressBar.value));
			var value:Number = progressBar.value;
			curProLabel.text = int(value/3600)+":"+DateString.dateToString(value%3600);
		}
		
		protected function fullScreenChangeHandler(event:FullScreenEvent):void
		{
			zoomInBtn.visible = Boolean(event.fullScreen);
			zoomOutBtn.visible = !zoomInBtn.visible;
		}
		
		private var lastVolumeValue:Number;
		private function volumeSwitch(event:MouseEvent):void
		{
			if(volumeBar.value > 0)
				lastVolumeValue = volumeBar.value;
			
			var volume:Number;
			if(event.target == volumeCloseBtn)
			{
				volumeStatus = false;
				volume = lastVolumeValue;
			}
			else
			{
				volumeStatus = true;
				volume = 0;
			}
			
			volumeBar.value = volume;
			dispatchEvent( new PlayerEvent(PlayerEvent.VOLUME_UPDATE, volume));
		}
		
		private function zoomInOutSwitch(event:MouseEvent):void
		{
			if(stage.displayState == StageDisplayState.FULL_SCREEN)
			{
				stage.displayState = StageDisplayState.NORMAL;
			}else
			{
				stage.displayState = StageDisplayState.FULL_SCREEN;
			}
		}
		
		private function volumeBarChanged(event:Event):void
		{
			if(volumeBar.value == 0)
				volumeStatus = true;
			else
				volumeStatus = false;
			
			dispatchEvent( new PlayerEvent(PlayerEvent.VOLUME_UPDATE, volumeBar.value));
		}
		
		private function rollOver(event:MouseEvent):void
		{
			volumeBar.visible = true;
		}
		
		private function rollOut(event:MouseEvent):void
		{
			volumeBar.visible = false;
		}
		
		private function frameClick(event:MouseEvent):void
		{
			
		}
		
		public function addFrame(list:Array):void
		{
			frameList = list;
			for(var i:int=0;i<frameList.length;i++)
			{
				var frameBtn:Button = new Button();
				frameBtn.skinName = "assest/playSmall.png";
				//			playBtn.horizontalCenter = 0;
				frameBtn.left = 80;
				frameBtn.verticalCenter = 0;
//				volumeBar.addElement(frameBtn);
				frameBtn.addEventListener(MouseEvent.CLICK, frameClick);
			}
		}
		
		private var scale:Number = 395/950;
		private var lastWidth:Number;
		public function updatePosition(wid:Number):void
		{
//			if(stage.stageWidth < 395 || stage.stageWidth > 950)return;
//			if(wid == lastWidth)return;
			
			lastWidth = wid;
			
			var  scaleWidth:Number=lastWidth;
			scale = scaleWidth/395;
			progressBar.width = scale*145;
			
			if(wid < 395)
			{
				scaleWidth = 395;
			}
			else if(wid > 950)
			{
				scaleWidth = 950;
			}
			else
			{
				scaleWidth = wid;
			}
			
			scale = scaleWidth/395;
			
			tvmPng.left = 2*scale;
			playBtn.left = pauseBtn.left = 50*scale;
			curProLabel.left = 75*scale;
//			talProLabel.left = 290*scale;
			progressBar.left = 133*scale;
//			progressBar.width = 145*scale;
			talProLabel.left = Number((progressBar.width+progressBar.left).toFixed(2))+12*scale;
			zoomInBtn.right = zoomOutBtn.right = 5*scale;
			volumeContainer.right = 28*scale;
			var volumeValue:Number = 50*scale;
			if(volumeValue > 100)
				volumeValue = 100;
			volumeBar.height = volumeValue;
			volumeBar.top = -volumeValue;
			
			var tvmScale:Number = tvmPng.width/tvmPng.height;
			var tvmScaleValue:Number = scale*.8;
			if(tvmScaleValue > 1)
				tvmScaleValue = 1;
			tvmPng.scaleX = tvmScaleValue;
//			tvm.scaleY = tvmScaleValue/tvmScale;
			tvmPng.scaleY = tvmScaleValue;
			
			var ppScale:Number = playBtn.width/playBtn.height;
			var ppScaleValue:Number = scale*.5;
			if(ppScaleValue > 1)
				ppScaleValue = 1;
			playBtn.scaleX = pauseBtn.scaleX = Number(ppScaleValue.toFixed(2));
			playBtn.scaleY = pauseBtn.scaleY = Number(ppScaleValue.toFixed(2));
			
//			var ctScale:Number = curProLabel.width/curProLabel.height;
//			curProLabel.scaleX = talProLabel.scaleX = .5;
//			curProLabel.scaleY = talProLabel.scaleY = .5/ctScale;
			var fontSize:Number = scale*12;
			if(fontSize > 18)
				fontSize = 18;
			curProLabel.size = talProLabel.size = fontSize;
			
			var ioScale:Number = zoomInBtn.width/zoomInBtn.height;
			var ioScaleValue:Number = scale*.5;
			if(ioScaleValue > 1)
				ioScaleValue = 1;
			zoomInBtn.scaleX = zoomOutBtn.scaleX = Number(ioScaleValue.toFixed(2));
			zoomInBtn.scaleY = zoomOutBtn.scaleY = Number(ioScaleValue.toFixed(2));
			
			var ocScale:Number = volumeOpenBtn.width/volumeOpenBtn.height;
			var ocScaleValue:Number = scale*.5;
			if(ocScaleValue > 1)
				ocScaleValue = 1;
			volumeOpenBtn.scaleX = volumeCloseBtn.scaleX = Number(ocScaleValue.toFixed(2));
			volumeOpenBtn.scaleY = volumeCloseBtn.scaleY = Number(ocScaleValue.toFixed(2));
			
			
			
		}
		
		override protected function measure():void
		{
			super.measure();
//			updatePosition(null);
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
//			updatePosition(null);
		}
		//UI Bg
		override protected function createChildren():void
		{
			super.createChildren();
			
			var bg:Rect = new Rect();
			bg.fillColor = 0x000000;
			bg.percentHeight = bg.percentWidth = 100;
			bg.alpha = 0.6;
			addElement(bg);
			
			tvmPng = new UIAsset();
			tvmPng.skinName = new Bitmap(new tvm);
			tvmPng.left = 10;
			tvmPng.verticalCenter = 0;
			addElement(tvmPng);
			
			playBtn = new Button();
			playBtn.skinName = new Bitmap(new playSmall);
//			playBtn.horizontalCenter = 0;
			playBtn.left = 80;
			playBtn.verticalCenter = 0;
			addElement(playBtn);
			playBtn.addEventListener(MouseEvent.CLICK, clickHandler);
			
			
			pauseBtn = new Button();
			pauseBtn.visible = false;
			pauseBtn.skinName = new Bitmap(new pauseSmall);
			pauseBtn.left = 80;
			pauseBtn.verticalCenter = 0;
			addElement(pauseBtn);
			pauseBtn.addEventListener(MouseEvent.CLICK, clickHandler);
			
			curProLabel = new Label();
			curProLabel.left = 140;
			curProLabel.verticalCenter = 0;
			addElement(curProLabel);
			curProLabel.bold = true;
			curProLabel.size = 18;
			curProLabel.textColor = 0xffffff;
			curProLabel.text = "0:00:00";
			
			talProLabel = new Label();
			talProLabel.left = 700;
			talProLabel.verticalCenter = 0;
			addElement(talProLabel);
			talProLabel.bold = true;
			talProLabel.size = 18;
			talProLabel.textColor = 0xffffff;
			talProLabel.text = "0:00:00";
			
			progressBar = new HSlider();
			//			progressBar.percentWidth = 100;
//			progressBar.percentWidth = (145/395)*100;
			progressBar.width = 460;
			progressBar.left = 230;
			progressBar.verticalCenter = 0;
			addElement(progressBar);
			progressBar.minimum = 0;
			progressBar.maximum = 0;
			progressBar.stepSize = 1;
			progressBar.addEventListener(Event.CHANGE, progressBarChange);
			
			zoomInBtn = new Button()
			zoomInBtn.visible = false;
			zoomInBtn.verticalCenter = 0;
			zoomInBtn.right = 20;
			zoomInBtn.skinName = new Bitmap(new zooms);
			addElement(zoomInBtn);
			zoomInBtn.addEventListener(MouseEvent.CLICK,zoomInOutSwitch)
			
			zoomOutBtn = new Button()
			zoomOutBtn.verticalCenter = 0;
			zoomOutBtn.right = 20;
			zoomOutBtn.skinName = new Bitmap(new zoomb);
			addElement(zoomOutBtn);
			zoomOutBtn.addEventListener(MouseEvent.CLICK,zoomInOutSwitch);
			
			volumeContainer = new Group();
			volumeContainer.verticalCenter = 0;
			volumeContainer.right = 80;
			addElement(volumeContainer);
			volumeContainer.addEventListener(MouseEvent.ROLL_OVER, rollOver);
			volumeContainer.addEventListener(MouseEvent.ROLL_OUT, rollOut);
			
			volumeOpenBtn = new Button()
//			volumeOpenBtn.verticalCenter = 0;
//			volumeOpenBtn.bottom = 0;
			volumeOpenBtn.horizontalCenter = 0;
//			volumeOpenBtn.right = 60;
			volumeOpenBtn.skinName = new Bitmap(new volumeopen);
			volumeContainer.addElement(volumeOpenBtn);
			volumeOpenBtn.addEventListener(MouseEvent.CLICK, volumeSwitch);
			
			volumeCloseBtn = new Button()
//			volumeCloseBtn.horizontalCenter = 0;
//			volumeCloseBtn.verticalCenter = 0;
//			volumeCloseBtn.right = 60;
			volumeCloseBtn.skinName = new Bitmap(new volumeclose);
			volumeContainer.addElement(volumeCloseBtn);
			volumeCloseBtn.addEventListener(MouseEvent.CLICK, volumeSwitch);
			volumeCloseBtn.visible = false;
			
			volumeBar = new VSlider();
			volumeBar.minimum = 0;
			volumeBar.maximum = 1;
			//			volumeBar.right = 70;
			//			volumeBar.bottom = 42;
			volumeBar.stepSize = 0.1;
			//			volumeBar.verticalCenter = 0;
			volumeBar.horizontalCenter = 0;
			volumeBar.top = -100;
			volumeBar.addEventListener(MouseEvent.ROLL_OUT, rollOut);
			volumeBar.addEventListener(Event.CHANGE,volumeBarChanged);
			volumeContainer.addElement(volumeBar);
			volumeBar.visible = false;
			TweenLite.delayedCall(0.5, function():void{
				volumeBar.value = 0.5;
				dispatchEvent( new PlayerEvent(PlayerEvent.VOLUME_UPDATE, volumeBar.value));
			})
		}
		
		private function destory():void
		{
			for each(var frameBtn:Button in frameBtnList)
			{
				frameBtn.parent && frameBtn.parent.removeChild(frameBtn);
			}
			
			frameBtnList.length = 0;
		}
	}
}