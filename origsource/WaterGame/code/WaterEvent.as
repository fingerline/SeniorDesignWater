package code {

	import flash.events.Event;

  public class WaterEvent extends Event {

		public static const UPDATE_VIEWS:String = "updateViews";
		public static const ADD_GRAY_BKGD:String = "addGrayBkgd";
		public static const REMOVE_GRAY_BKGD:String = "removeGrayBkgd";
		public static const ADD_VIEW_TRADE:String = "addViewTrade";
		public static const REMOVE_VIEW_TRADE:String = "removeViewTrade";
		public static const UPDATE_TRADING_INFO:String = "updateTradingInfo";
		public static const CLOSE_TRADING_INFO:String = "closeTradingInfo";
		public static const ADD_VIEW_DAM:String = "addViewDam";
		public static const REMOVE_VIEW_DAM:String = "removeViewDam";
		public static const UPDATE_DAM_INFO:String = "updateDamInfo";
		public static const CLOSE_DAM_INFO:String = "closeDamInfo";
		public static const BUILD_DAM:String = "buildDam";
		public static const REMOVE_VIEW_ALIAS:String = "removeViewAlias";
		public static const UPDATE_ALIAS:String = "updateAlias";
		public static const ADD_VIEW_MFR:String = "addViewMfr";
		public static const REMOVE_VIEW_MFR:String = "removeViewMfr";
		public static const ADD_VIEW_DAM_STORE:String = "addViewDamStore";
		public static const REMOVE_VIEW_DAM_STORE:String = "removeViewDamStore";
		public static const UPDATE_DAM_STORE:String = "updateDamStore";
		public static const RESET_GAME:String = "resetGame";
		public static const ADD_TRADING_INFO:String = "addTradingInfo";
		public static const ADD_DAM_INFO:String = "addDamInfo";
		public static const ADD_SCORE_INFO:String = "addScoreInfo";
		public static const CLOSE_SCORE_INFO:String = "closeScoreInfo";
		public static const TOP_SCORE_INFO:String = "topScoreInfo";
		public static const TOP_SCORE_BOARD:String = "topScoreBoard";
		public static const ADD_SCORE_BOARD:String = "addScoreBoard";

    public function WaterEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
    }

		override public function toString():String {
			return formatToString("WaterEvent", "type", "bubbles", "cancelable");
		}
		
		override public function clone():Event {
			return new WaterEvent(type, bubbles, cancelable);
		}
  }
}