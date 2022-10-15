package code {

	import flash.display.*;
	import flash.events.*;
	import fl.controls.*;
	import flash.text.*;
	import flash.geom.Point;

  public class WaterView extends Sprite {

		private const MANAGE_OPTIONS_Y:Number = WaterConsts.TITLE_BG_HEIGHT + 10;
		private const MANAGE_OPTIONS_X:Number = 5;
		private const SCORE_BOARD_X:Number = 5;
		private const SCORE_BOARD_Y:Number = MANAGE_OPTIONS_Y + WaterConsts.MENU_HEIGHT + 10;
		private const SCORE_BOARD_WIDTH:Number = 314;
		private const SCORE_BOARD_HEIGHT:Number = 381.25;
		private const VIEW_OPTIONS_Y:Number = SCORE_BOARD_Y + SCORE_BOARD_HEIGHT + 10;
		private const VIEW_OPTIONS_X:Number = 5;
		private const TRADE_VIEW_WIDTH:Number = 500;
		private const TRADE_VIEW_HEIGHT:Number = 150;
		private const TRADING_TABLE_WIDTH:Number = 210;
		private const DAM_VIEW_WIDTH:Number = 500;
		private const DAM_VIEW_HEIGHT:Number = 150;
		private const DAM_VIEW_STORE_WIDTH:Number = 500;
		private const DAM_VIEW_STORE_HEIGHT:Number = 150;
		private const MFR_VIEW_WIDTH:Number = 500;
		private const MFR_VIEW_HEIGHT:Number = 150;
		private const USE_POINTS_X:Number = 5;
		private const USE_POINTS_Y_BOTTOM:Number = WaterConsts.GAME_HEIGHT - 10;
		private const USE_POINTS_WIDTH:Number = 210;
		private const USE_POINTS_HEIGHT:Number = 150;
		private const ERROR_VIEW_WIDTH:Number = 500;
		private const ERROR_VIEW_HEIGHT:Number = 90;

    private var data:WaterData;
		private var titleBar:WaterViewTitleBar;
		private var scoreBoard:WaterViewScoreBoard;
		private var mountain:WaterViewMountain;
		private var river:WaterViewRiver;
		private var tradeView:WaterViewTrade;
		private var tradingInfo:WaterViewTradingInfo;
		private var damView:WaterViewDam;
		private var damInfo:WaterViewDamInfo;
		private var damStoreView:WaterViewDamStore;
		private var errorView:WaterViewError;
		// Minimum Flow Requirement;
		private var mfrView:WaterViewMfr;
		private var usePoints:WaterViewUsePoints;
		private var manageOptions:WaterManageOptions;
		private var viewingOptions:WaterViewingOptions;
		private var scoreInfo:WaterViewScoreInfo;
		// These two variables are used to fix the arrow issue when the scrollpane scrolled.
		// involved classes:
		//   WaterViewRiver, WaterViewRiverItem (used by WaterViewPipe);
		//   WaterViewScoreInfo (used by its parent class WaterResizeComponent);
		private var _scrollPaneDx:Number;
		private var _scrollPaneDy:Number;

    public function WaterView() {
			data = new WaterData();
			_scrollPaneDx = 0;
			_scrollPaneDy = 0;
			addEventListener(Event.ADDED, setupChildren, false, 0, true);
    }
		
    private function setupChildren(e:Event):void {
			removeEventListener(Event.ADDED, setupChildren);
			
			// UPDATE_VIEWS won't touch Dam and Dam reservioir (WaterViewMountain.buildDam() and WaterViewMountain.updateUsage())
			// UPDATE_DAM_STORE handles WaterViewMountain.updateUsage() 
			addEventListener(WaterEvent.UPDATE_VIEWS, updateViews, false, 0, true);
			addEventListener(WaterEvent.ADD_VIEW_TRADE, addViewTrade, false, 0, true);
			addEventListener(WaterEvent.REMOVE_VIEW_TRADE, removeViewTrade, false, 0, true);
			addEventListener(WaterEvent.UPDATE_TRADING_INFO, updateTradingInfo, false, 0, true);
			addEventListener(WaterEvent.CLOSE_TRADING_INFO, closeTradingInfo, false, 0, true);
			addEventListener(WaterEvent.ADD_VIEW_DAM, addViewDam, false, 0, true);
			addEventListener(WaterEvent.REMOVE_VIEW_DAM, removeViewDam, false, 0, true);
			addEventListener(WaterEvent.UPDATE_DAM_INFO, updateDamInfo, false, 0, true);
			addEventListener(WaterEvent.CLOSE_DAM_INFO, closeDamInfo, false, 0, true);
			addEventListener(WaterEvent.ADD_VIEW_MFR, addViewMfr, false, 0, true);
			addEventListener(WaterEvent.REMOVE_VIEW_MFR, removeViewMfr, false, 0, true);
			addEventListener(WaterEvent.BUILD_DAM, buildDam, false, 0, true);
			addEventListener(WaterEvent.ADD_VIEW_DAM_STORE, addViewDamStore, false, 0, true);
			addEventListener(WaterEvent.REMOVE_VIEW_DAM_STORE, removeViewDamStore, false, 0, true);
			addEventListener(WaterEvent.UPDATE_DAM_STORE, updateDamStore, false, 0, true);
			addEventListener(WaterErrorEvent.ADD_VIEW_ERROR, addViewError, false, 0, true);
			addEventListener(WaterErrorEvent.REMOVE_VIEW_ERROR, removeViewError, false, 0, true);
			addEventListener(WaterEvent.RESET_GAME, resetGame, false, 0, true);
			addEventListener(WaterEvent.ADD_TRADING_INFO, addTradingInfo, false, 0, true);
			addEventListener(WaterEvent.ADD_DAM_INFO, addDamInfo, false, 0, true);
			addEventListener(WaterEvent.ADD_SCORE_INFO, addScoreInfo, false, 0, true);
			addEventListener(WaterEvent.CLOSE_SCORE_INFO, closeScoreInfo, false, 0, true);
			addEventListener(WaterEvent.TOP_SCORE_INFO, topScoreInfo, false, 0, true);
			addEventListener(WaterEvent.TOP_SCORE_BOARD, topScoreBoard, false, 0, true);
			addEventListener(WaterEvent.ADD_SCORE_BOARD, setupScoreBoard, false, 0, true);
			
			setupBackground();
			setupMountain();
			setupTitleBar();
			setupRiver();
			setupUsePoints();
			setupScoreBoard(null);
			setupManageOptions();
			setupViewingOptions();
			
			manageOptions.addEventListener(MouseEvent.CLICK, manageOptionsMenuClicked, false, 0, true);
			viewingOptions.addEventListener(MouseEvent.CLICK, viewingOptionsMenuClicked, false, 0, true);
			
			updatePoints();
		}

		public function get scrollPaneDx():Number {
			return _scrollPaneDx;
		}
		public function set scrollPaneDx(value:Number):void {
			_scrollPaneDx = value;
		}
		
		public function get scrollPaneDy():Number {
			return _scrollPaneDy;
		}
		public function set scrollPaneDy(value:Number):void {
			_scrollPaneDy = value;
		}
		
		private function setupBackground():void {
			// this background is added as a workaround of the small edge area being cut off by the scroll pane
			// when the scroll bars appear.
			WaterUtils.setupBackground(this,
																 WaterConsts.GAME_BG_COLOR, 0,
																 0, 0, WaterConsts.GAME_WIDTH, WaterConsts.GAME_HEIGHT);
			WaterUtils.setupBackground(this,
																 WaterConsts.TITLE_BG_COLOR, 0.6,
																 0, 0, WaterConsts.GAME_WIDTH, WaterConsts.TITLE_BG_HEIGHT);
			WaterUtils.setupBackground(this,
																 WaterConsts.GAME_BG_COLOR, 0.5,
																 0, WaterConsts.TITLE_BG_HEIGHT,
																 WaterConsts.GAME_WIDTH, WaterConsts.GAME_HEIGHT - WaterConsts.TITLE_BG_HEIGHT);
		}
		
		private function setupTitleBar():void {
			titleBar = new WaterViewTitleBar(data);
			addChild(titleBar);
		}
		
		private function setupScoreBoard(e:WaterEvent):void {
			var idx:int = this.numChildren;
			if (scoreBoard && scoreBoard.parent) {
			  idx = this.getChildIndex(scoreBoard);
				removeChild(scoreBoard);
			}
			scoreBoard = new WaterViewScoreBoard(SCORE_BOARD_X,
																					 SCORE_BOARD_Y,
																					 SCORE_BOARD_WIDTH,
																					 SCORE_BOARD_HEIGHT,
																					 data,
																					 this);
			addChildAt(scoreBoard, idx);
		}
		
		private function setupMountain():void {
			mountain = new WaterViewMountain(data);
			addChild(mountain);
		}
		
		private function setupRiver():void {
			river = new WaterViewRiver(data, this);
			addChild(river);
		}
		
		private function setupUsePoints():void {
			usePoints = new WaterViewUsePoints(this.USE_POINTS_X, this.USE_POINTS_Y_BOTTOM,
																				 this.USE_POINTS_WIDTH, this.USE_POINTS_HEIGHT);
			addChild(usePoints);
		}
		
		private function setupManageOptions():void {
			manageOptions = new WaterManageOptions(data, MANAGE_OPTIONS_X, MANAGE_OPTIONS_Y);
			addChild(manageOptions);
		}
		
		private function setupViewingOptions():void {
			viewingOptions = new WaterViewingOptions(data, VIEW_OPTIONS_X, VIEW_OPTIONS_Y);
			addChild(viewingOptions);
		}
		
		private function updateViews(e:Event):void {
			updatePoints();
		}
		
		private function updatePoints():void {
			updateBarBoardPoints();
			river.updatePoints();
		}
		
		private function updateBarBoardPoints():void {
			titleBar.updatePoints();
			scoreBoard.updatePoints();
		}
		
		private function addViewTrade(e:WaterEvent):void {
			this.addTradingInfo(null);
			
			var x:Number = getPosition(0, TRADE_VIEW_WIDTH, 2);
			var y:Number = getPosition(0, TRADE_VIEW_HEIGHT, 3);
			var w:Number = TRADE_VIEW_WIDTH;
			var h:Number = TRADE_VIEW_HEIGHT;
			tradeView = new WaterViewTrade(data, x, y, w, h);
			addChild(tradeView);
		}
		
		private function removeViewTrade(e:WaterEvent):void {
			if (tradeView && tradeView.parent)
				removeChild(tradeView);
		}
		
		private function addTradingInfo(e:WaterEvent):void {
			this.viewingOptions.setViewTradeFlag(true);
			var idx:int = this.numChildren;
			if (tradingInfo && tradingInfo.parent) {
			  idx = this.getChildIndex(tradingInfo);
				removeChild(tradingInfo);
			}
			// always new the Water Trading;
			tradingInfo = new WaterViewTradingInfo(5, USE_POINTS_Y_BOTTOM, TRADING_TABLE_WIDTH, data);
			addChildAt(tradingInfo, idx);
		}
		
		private function updateTradingInfo(e:WaterEvent):void {
			addTradingInfo(null);
			updatePoints();
		}
		
		private function closeTradingInfo(e:WaterEvent):void {
			this.viewingOptions.setViewTradeFlag(false);
			if (tradingInfo && tradingInfo.parent)
				removeChild(tradingInfo);
		}
		
		private function addViewDam(e:WaterEvent):void {
			this.addDamInfo(null);
			
			var x:Number = getPosition(0, DAM_VIEW_WIDTH, 2);
			var y:Number = getPosition(0, DAM_VIEW_HEIGHT, 3);
			var w:Number = DAM_VIEW_WIDTH;
			var h:Number = DAM_VIEW_HEIGHT;
			damView = new WaterViewDam(data, this, x, y, w, h);
			addChild(damView);
		}
		
		private function removeViewDam(e:WaterEvent):void {
			removeChild(damView);
		}

		private function addDamInfo(e:WaterEvent):void {
			this.viewingOptions.setViewDamFlag(true);
			var idx:int = this.numChildren;
			if (damInfo && damInfo.parent) {
				idx = this.getChildIndex(damInfo);
				removeChild(damInfo);
			}
			// always new the Water Dam Info;
			damInfo = new WaterViewDamInfo(5, USE_POINTS_Y_BOTTOM, TRADING_TABLE_WIDTH, data);
			addChildAt(damInfo, idx);
		}
		
		private function updateDamInfo(e:WaterEvent):void {
			addDamInfo(null);
			updateBarBoardPoints();
		}

		private function closeDamInfo(e:WaterEvent):void {
			this.viewingOptions.setViewDamFlag(false);
			if (damInfo && damInfo.parent)
				removeChild(damInfo);
		}

		private function addViewMfr(e:WaterEvent):void {
			var x:Number = getPosition(0, MFR_VIEW_WIDTH, 2);
			var y:Number = getPosition(0, MFR_VIEW_HEIGHT, 3);
			var w:Number = MFR_VIEW_WIDTH;
			var h:Number = MFR_VIEW_HEIGHT;
			mfrView = new WaterViewMfr(data, x, y, w, h);
			addChild(mfrView);
		}
		
		private function removeViewMfr(e:WaterEvent):void {
			if (mfrView && mfrView.parent)
				removeChild(mfrView);
		}

		private function buildDam(e:WaterEvent):void {
			data.damCapacity = data.damPoints();
			this.mountain.buildDam();
			updateDamStore(null);

			this.updatePoints();
		}
		
		private function addViewDamStore(e:WaterEvent):void {
			
			var x:Number = getPosition(0, DAM_VIEW_STORE_WIDTH, 2);
			var y:Number = getPosition(0, DAM_VIEW_STORE_HEIGHT, 3);
			var w:Number = DAM_VIEW_STORE_WIDTH;
			var h:Number = DAM_VIEW_STORE_HEIGHT;
			damStoreView = new WaterViewDamStore(data, x, y, w, h);
			addChild(damStoreView);
		}
		
		private function removeViewDamStore(e:WaterEvent):void {
			if (damStoreView && damStoreView.parent)
				removeChild(damStoreView);
		}
		
		private function updateDamStore(e:WaterEvent):void {
			mountain.updateUsage();
		}
		
		private function addViewError(e:WaterErrorEvent):void {
			var x:Number = getPosition(0, ERROR_VIEW_WIDTH, 2);
			var y:Number = getPosition(0, ERROR_VIEW_HEIGHT, 3);
			var w:Number = ERROR_VIEW_WIDTH;
			var h:Number = ERROR_VIEW_HEIGHT;
			errorView = new WaterViewError(x, y, w, h, e.error);
			addChild(errorView);
		}
		
		private function removeViewError(e:WaterErrorEvent):void {
			if (errorView && errorView.parent)
				removeChild(errorView);
		}
		
		private function addScoreInfo(e:WaterEvent):void {
			this.viewingOptions.setViewScoreFlag(true);
			scoreInfo = new WaterViewScoreInfo(SCORE_BOARD_X - 2, SCORE_BOARD_Y - 2,
																				 SCORE_BOARD_WIDTH + 4, SCORE_BOARD_HEIGHT + 4,
																				 data, this);
			addChild(scoreInfo);
		}
		
		private function closeScoreInfo(e:WaterEvent):void {
			this.viewingOptions.setViewScoreFlag(false);
			if (scoreInfo && scoreInfo.parent)
				removeChild(scoreInfo);
		}
		
		private function topScoreInfo(e:WaterEvent):void {
			addChild(scoreInfo);
		}

		private function getPosition(initial:Number, compare:Number, denom:Number):Number {
			var ret:Number = initial;
			if (stage.stageWidth > compare)
				ret = (stage.stageWidth - compare) / denom;
			return ret;
		}
		
		private function resetGame(e:WaterEvent):void {
			data.resetData();
			closeTradingInfo(null);
			closeDamInfo(null);
			closeScoreInfo(null);
			buildDam(null);
		}
		
		private function manageOptionsMenuClicked(e:MouseEvent):void {
			if (viewingOptions)
				viewingOptions.closeMenuItems();
			addChild(this.manageOptions);
		}
		
		private function viewingOptionsMenuClicked(e:MouseEvent):void {
			if (manageOptions)
				manageOptions.closeMenuItems();
			addChild(this.viewingOptions);
		}
		
		private function topScoreBoard(e:WaterEvent):void {
			addChild(scoreBoard);
		}

  }
}