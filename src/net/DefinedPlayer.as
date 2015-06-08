package net
{
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.media.SoundTransform;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.Timer;
	
	import events.PlayerEvent;

	public class DefinedPlayer extends EventDispatcher
	{
		private var _url:String="";
		private var _mediaInfo:Object;
		private var _druation:Number = 0;
		private var _netStream:NetStream;
		
		private var heartbeat:Timer = new Timer(100);
		public function DefinedPlayer(url:String, druation:Number)
		{
			_url = url;
//			_druation = druation;
			
			var netConnection:NetConnection = new NetConnection();
			netConnection.connect(null);
			
			_netStream = new NetStream(netConnection);
			_netStream.client = {onMetaData:this.onMetaData, onCuePoint:this.onCuePoint};
			_netStream.addEventListener(NetStatusEvent.NET_STATUS, netStreamStatus);
			
			heartbeat.addEventListener(TimerEvent.TIMER, onHeartbear);
		}
		
		
		public function get netStream():NetStream
		{
			return _netStream;
		}

		public function set netStream(value:NetStream):void
		{
			_netStream = value;
		}
		
		public function get mediaInfo():Object
		{
			return _mediaInfo;
		}
		
		public function play():void
		{
			_netStream.play(_url);
		}
		
		public function pause():void
		{
			_netStream.togglePause();
		}
		
		public function seek(offset:Number):void
		{
			_netStream.seek(offset);
			if(!heartbeat.running)
				heartbeat.start();
		}
		
		/**
		 * 	@param value 声音大小
		 **/
		public function volume(value:Number):void
		{
			var soundTransform:SoundTransform = netStream.soundTransform;
			soundTransform.volume = value;
			netStream.soundTransform = soundTransform;
		}
		
		private function netStreamStatus(event:NetStatusEvent):void
		{
			switch(event.info.code)
			{
				case "NetStream.Connect.Failed":
					break;
				case "NetStream.Connect.Success":
					break;
				case "NetStream.Buffer.Empty":
					break;
				case "NetStream.Buffer.Full":
					break;
				case "NetStream.Play.Start":
					heartbeat.start();
					break;
				case "NetStream.Play.Stop":
					heartbeat.stop();
					break;
				case "NetStream.Seek.Failed":
					break;
			}
		}
		
		private function onHeartbear(event:TimerEvent):void
		{
			dispatchEvent( new PlayerEvent(PlayerEvent.PLAYER_UPDATE, _netStream.time));
		}
		
		private function onMetaData(info:Object) : void
		{
			_mediaInfo = info;
			_druation = info.duration;
			dispatchEvent( new PlayerEvent(PlayerEvent.MEDIA_DURATION_UPDATE, info.duration));
		}
		
		private function onCuePoint(info:Object) : void
		{
		}
	}
}