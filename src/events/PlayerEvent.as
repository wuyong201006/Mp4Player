package events
{
	import flash.events.Event;
	
	public class PlayerEvent extends Event
	{
		private var _data:Object;
		
		public static var NET_STATUS:String = "net_status";
		
		public static var PLAYER_UPDATE:String = "player_update";
		public static var VOLUME_UPDATE:String = "volume_update";
		public static var MEDIA_DURATION_UPDATE:String = "media_duration_update";
		public static var CONTROLLBAR_UPDATE:String = "controllBar_update";
		public static var CONTROLLBAR_PLAY:String = "controllbar_play";
		
		public function PlayerEvent(type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			_data = data;
			
			super(type, bubbles, cancelable);
		}

		public function get data():Object
		{
			return _data;
		}

		public function set data(value:Object):void
		{
			_data = value;
		}

	}
}