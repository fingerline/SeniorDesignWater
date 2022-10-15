package code {

	import flash.events.Event;

  public class WaterErrorEvent extends Event {

		public static const ADD_VIEW_ERROR:String = "addViewError";
		public static const REMOVE_VIEW_ERROR:String = "removeViewError";
		
		private var _error:String = "";

    public function WaterErrorEvent(error:String, type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			_error = error;
    }
		
		public function get error():String {
			return _error;
		}

		override public function toString():String {
			return formatToString("error", "WaterErrorEvent", "type", "bubbles", "cancelable");
		}
		
		override public function clone():Event {
			return new WaterErrorEvent(error, type, bubbles, cancelable);
		}
  }
}