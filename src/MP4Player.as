package
{
	import com.alex.flexlite.components.VideoUI;
	import com.greensock.TweenLite;
	import com.hurlant.util.Base64;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import component.ControllBar;
	import component.TopBar;
	
	import events.PlayerEvent;
	
	import net.DefinedPlayer;
	
	import org.flexlite.domCore.Injector;
	import org.flexlite.domUI.components.Button;
	import org.flexlite.domUI.components.Group;
	import org.flexlite.domUI.components.Label;
	import org.flexlite.domUI.components.TextInput;
	import org.flexlite.domUI.core.Theme;
	import org.flexlite.domUI.managers.SystemManager;
	import org.flexlite.domUI.skins.themes.VectorTheme;
	
	import util.Crypti;
	
	[SWF(frameRate="25")]
	public class MP4Player extends SystemManager
	{
//		private const REQ_URL:String = "http://api.pan.tvmcloud.com/player/getvideo.php?content=oDW72xMgB67UdAAQNfDVpKaa09Ht/nzYTLc1lHVp52Ucz4KzqrVtyLgvxKben7Qu";
		private const REQ_URL:String = "http://api.pan.tvmcloud.com/player/getvideo.php?content=";
		
		private var videoScreen:VideoUI;
		private var controllBar:ControllBar;
		private var topBar:TopBar;
		
		private var playBtn:Button;
		
		private var definedPlayer:DefinedPlayer;
		
		private const PLAYER_KEY:String = "tvmining";
		private var IsPlayer:Boolean=true;//是否第一次播放
		private var playerParams:Object={
			content:null,//(mp4url, druation)
			auto_play:null,
			width:null,
			height:null
		}
		public function MP4Player()
		{
			super();
			
			Injector.mapClass(Theme,VectorTheme);
			
//			this.autoResize = false;
			
//			playerParams.content = parseContent(PLAYER_KEY, this.loaderInfo.parameters.content);
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			
			playerParams.auto_play = this.loaderInfo.parameters.auto_play;
			playerParams.width = this.loaderInfo.parameters.width;
			playerParams.height = this.loaderInfo.parameters.height;
			
//			log(this.loaderInfo.parameters);
			
		}
		
		private function initPlayer():void
		{
			playerParams.auto_play = true;
			
			if(playerParams.content)
			{
//				controllBar.updateProgressBarMaximum(playerParams.content.duration);
				
				definedPlayer = new DefinedPlayer(playerParams.content.mp4url, playerParams.content.duration);
				videoScreen.attatchNetStream(definedPlayer.netStream);
			}
			
			
			definedPlayer.addEventListener(PlayerEvent.PLAYER_UPDATE, playerUpdate);
			definedPlayer.addEventListener(PlayerEvent.MEDIA_DURATION_UPDATE, durationUpdate);
			
			controllBar.addEventListener(PlayerEvent.CONTROLLBAR_UPDATE, controllBarUpdate);
			controllBar.addEventListener(PlayerEvent.CONTROLLBAR_PLAY, controllBarPlay);
			controllBar.addEventListener(PlayerEvent.VOLUME_UPDATE, volumeUpdate);
			
			if(playerParams.auto_play)
			{
				definedPlayer.play();
				controllBar.playStatus = true;
			}
			else
			{
				controllBar.playStatus = false;
			}
			
			playerStatus = !playerParams.auto_play;
			controllBar.playStatus = true;
			
			videoScreenChange();
			if(ExternalInterface.available)
			{
				ExternalInterface.addCallback("seek", seekExternal);//秒
			}
		}
		
		private function durationUpdate(event:PlayerEvent):void
		{
			controllBar.updateProgressBarMaximum(Number(event.data));
			
			videoScreenChange();
		}
		
		private function seekExternal(data:Object):void
		{
//			log("AS CALL："+data);
			definedPlayer.seek(Number(data));
		}
		
		private var testUrl:String = "http://video.cloud.tvmining.com/TVM/MP4_MAIN/BTV3/2015/05/29/BTV3_512000_20150529_13297511_0.mp4";
		private function addedToStage(event:Event):void
		{
			stage.addEventListener(FullScreenEvent.FULL_SCREEN,fullScreenChangeHandler);
//			addEventListener(MouseEvent.MOUSE_MOVE,userActiveHandler);
			
			requestPlayer();
			
			var encryptStr:String = Crypti.encrypt(PLAYER_KEY, "aasssddd");
//			trace("encrypt"+encryptStr);
//			trace("decrypt"+Crypti.decrypt(PLAYER_KEY, encryptStr));
		}
		
		private function fullScreenChangeHandler(event:FullScreenEvent):void
		{
//			if(event.fullScreen)
//			{
//				controllBar.bottom = 0;
//			}
//			else
//			{
//				controllBar.bottom = -controllBar.height;
//			}
		}
		
		private function requestPlayer():void
		{
			var request:URLRequest = new URLRequest(REQ_URL);
			request.method = URLRequestMethod.GET;
//			var value:URLVariables = new URLVariables();
//			value.content = this.loaderInfo.parameters.content;
//			request.data = value;
			request.data = this.loaderInfo.parameters.content;
//			log("request.data"+request.data);
			
//			request.data = this.loaderInfo.parameters.content;
			var loader:URLLoader = new URLLoader();
//			loader.dataFormat = URLLoaderDataFormat.VARIABLES;
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, complete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioError);
			loader.load(request);
		}
		
		private function ioError(event:Event):void
		{
//			trace("请求视频源加载错误！！！");
		}
		
		private var accept:Boolean = false;
		private function complete(event:Event):void
		{
			var loader:URLLoader = event.target as URLLoader;
			playerParams.content = parseContent(PLAYER_KEY, loader.data);
			
			if(definedPlayer == null)
				initPlayer();
		}
		
		//parse url 		
		private function parseContent(keyStr:String, decryptStr:String):Object
		{
//			var decrypt:ByteArray = Base64.decodeToByteArray(decryptStr);
//			
//			var key:ByteArray = Hex.toArray(keyStr);
			//		第一套方案	
//			var pad:IPad = new NullPad();
//			var cipher:ICipher = Crypto.getCipher("des-cbc", key, pad);
//			pad.setBlockSize(cipher.getBlockSize());
//			
//			var iv:ByteArray = new ByteArray();
//			if(cipher is IVMode)
//			{
//				var ivm:IVMode = cipher as IVMode;
//				ivm.IV = iv;
//			}
//			cipher.decrypt(decrypt);
//			return Hex.fromArray(decrypt);
			
			//反转，解码
			var decryptArray:Array = decryptStr.split("");
			var rev:Array = decryptArray.reverse();
			var dec:String = rev.join("");
			return JSON.parse(Base64.decode(dec));
		}
		
		private function controllBarPlay(event:PlayerEvent):void
		{
			if(IsPlayer && !playerParams.auto_play)
			{
				IsPlayer = false;
				definedPlayer.play();
				playerStatus = false;
			}
			else
			{
				playerStatus = Boolean(event.data);
				definedPlayer.pause();
			}
		}
		
		private var rateCount:int=0;
		private function playerUpdate(event:PlayerEvent):void
		{
			rateCount++;
			//call2js
			if(ExternalInterface.available)
			{
				ExternalInterface.call('updateTime', Number(event.data)*1000);
			}
			
//			playLabel.text = "当前播放时间"+(Number(event.data));
			
			if(rateCount >= 10)
			{
				rateCount = 0;
				controllBar.updateProgressBarCur(Number(event.data));
			}
		}
		
		private function controllBarUpdate(event:PlayerEvent):void
		{
			definedPlayer.seek(Number(event.data));
		}
		
		private function volumeUpdate(event:PlayerEvent):void
		{
			definedPlayer.volume(Number(event.data));
		}
		
		private function set playerStatus(value:Boolean):void
		{
			playBtn.visible = value;
		}
		
		private function clickHandler(event:MouseEvent):void
		{
			playerStatus = false;
			controllBar.playStatus = true; 
			definedPlayer.pause();
		}
		
		private var _userActive:Boolean;
		public function get userActive():Boolean
		{
			return _userActive;
		}
		
		public function set userActive(value:Boolean):void
		{
			if(_userActive !== value)
			{
				_userActive = value;
				
				showControllBar(userActive);
			}
		}
		
		//Hide&ShowAnimation
		private function showControllBar(userActive:Boolean):void
		{
			if(controllBar)
			{
				TweenLite.killTweensOf(controllBar);
				
				TweenLite.to(controllBar, 1, {bottom:(userActive ? 0 : -controllBar.height)});
			}
		}
		
		//DeAcitvehandlerFun
		protected function userActiveHandler(event:MouseEvent):void
		{
			userActive = true;
			
			monitorDeactive();
		}
		
		//MonitorTiemoutID
		private var monitorId:int;
		
		//Monitor Controllbar Deative
		private function monitorDeactive():void
		{
			if(monitorId) clearTimeout(monitorId);
			
			monitorId = setTimeout(function():void
			{
				userActive = false;
			},2000);
		}
		
		private function log(...args):void
		{
			var logstr:String = JSON.stringify(args);
			
			if(ExternalInterface.available)
			{
				ExternalInterface.call('console.log','MP4PLAYER--->',logstr);
			}
		}
		
		private function videoScreenChange():void
		{
//			stage.displayState = StageDisplayState.NORMAL;
			if(definedPlayer == null)return;
			var mediaInfo:Object = definedPlayer.mediaInfo;
			if(mediaInfo == null || mediaInfo.height <= 0 || mediaInfo.width <= 0)return;
			
			controllBar.height = (stage.stageWidth> 700 ? 700 : stage.stageWidth)/395*25;
			
			var perw:Number = stage.stageWidth / mediaInfo.width;
			var perh:Number = (stage.stageHeight-controllBar.height) / mediaInfo.height;
			var scale:Number = perw <= perh ? perw : perh;
			
			var wid:Number = scale*mediaInfo.width;
			var hei:Number = scale*mediaInfo.height;
			
			groupContainer.width = wid;
			groupContainer.height = /*hei*/stage.stageHeight-controllBar.height;
			
			videoScreen.width = wid;
			videoScreen.height = hei;
			
//			log("media"+mediaInfo.width/mediaInfo.height+"video"+videoScreen.width/videoScreen.height);
//			log("stageWidth"+stage.stageWidth+"......."+"stageHeight"+stage.stageHeight);
//			log("width"+mediaInfo.width+"height"+mediaInfo.height);
//			
//			if(stage.stageWidth > mediaInfo.width || stage.stageHeight > mediaInfo.height)
//			{
//				var wid:Number = stage.stageWidth < mediaInfo.width ? stage.stageWidth : mediaInfo.width;
//				var hei:Number = stage.stageHeight < mediaInfo.height ? stage.stageHeight : mediaInfo.height;
//				groupContainer.width = wid;
//				groupContainer.height = hei;
//				
//				videoScreen.width = wid;
//				videoScreen.height = hei;
//				log("等比例缩放");
//			}
//			else
//			{
//				groupContainer.percentHeight = groupContainer.percentWidth = 100;
//				videoScreen.percentHeight = videoScreen.percentWidth = 100;
//				
//				log("100已执行");
//			}
			
			
//			log("groupContainer:"+groupContainer.width)
			TweenLite.delayedCall(0.5, function():void{
				controllBar.updatePosition(stage.stageWidth);
				if(!groupContainer.visible)
					groupContainer.visible = true;
			});
			
//			TweenLite.delayedCall(0.5, drawBackGround);
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			videoScreenChange();
		}
		
		private var lastWid:Number;
		private function drawBackGround():void
		{
			if(lastWid == controllBar.width)return;
			
			lastWid = controllBar.width;
			group && group.graphics.clear();
			
			group = new Group();
			group.graphics.beginFill(0x000000);
			group.graphics.drawRect(0, 0, controllBar.width, 50);
			group.graphics.endFill();
			group.bottom = -group.height;
			groupContainer.addElement(group);
		}
		
		//test
		private var playLabel:Label;
		
		private var group:Group;
		private var groupContainer:Group;
		//UI Comps
		override protected function createChildren():void
		{
			super.createChildren();
			
			groupContainer = new Group();
			groupContainer.horizontalCenter = 0;
//			groupContainer.verticalCenter = 0;
			addElement(groupContainer);
			groupContainer.visible = false;
			
			videoScreen = new VideoUI();
//			videoScreen.percentHeight = videoScreen.percentWidth = 100;
			videoScreen.horizontalCenter = 0;
			videoScreen.verticalCenter = 0;
			groupContainer.addElement(videoScreen);
//			videoScreen.visible = false;
			
			controllBar = new ControllBar();
			controllBar.percentWidth = 100;
			controllBar.height = 50;
			controllBar.bottom = 0;
			addElement(controllBar);
			controllBar.updatePosition(395);
			
			playBtn = new Button();
			playBtn.skinName = new Bitmap(new playBig);
			playBtn.horizontalCenter = 0;
			playBtn.verticalCenter = 0;
			groupContainer.addElement(playBtn);
			playBtn.addEventListener(MouseEvent.CLICK, clickHandler);
			
//			var textInput:TextInput = new TextInput();
//			addElement(textInput);
//			
//			playLabel = new Label();
//			playLabel.top = 15;
//			addElement(playLabel);
//			playLabel.text = "播放时间";
//			
//			
//			var btn:Button = new Button();
//			btn.top = 30;
//			addElement(btn);
//			btn.label = "跳 转";
//			btn.addEventListener(MouseEvent.CLICK, function():void
//			{
//				definedPlayer.seek(Number(textInput.text));
//			});
//			topBar = new TopBar();
//			topBar.percentWidth = 100;
//			topBar.height = 50;
//			topBar.top = 0;
//			addElement(topBar);
		}
	}
}