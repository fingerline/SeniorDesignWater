package code {
	
	import flash.display.*;
	import fl.controls.*;
	import flash.text.*;
	import flash.events.*;

	// future work: extract WaterViewingOptions and WaterManageOptions into a common parent class
  public class WaterViewingOptions extends Sprite {

		private var data:WaterData;
		private var xPos:Number;
		private var yPos:Number;
		private var menu:MenuButton;
		private var menuNameTF:TextField;
		private var viewTradeMI:WaterMenuItem;
		private var viewDamMI:WaterMenuItem;
		private var viewScoreMI:WaterMenuItem;
		private var bViewTrade:Boolean;
		private var bViewDam:Boolean;
		private var bViewScore:Boolean;
		
		public function WaterViewingOptions(data:WaterData, x:Number, y:Number) {
			this.data = data;
			this.xPos = x;
			this.yPos = y;
			this.bViewTrade = false;
			this.bViewDam = false;
			this.bViewScore = false;
			addEventListener(Event.ADDED, setupChildren, false, 0, true);
    }

    private function setupChildren(e:Event):void {
			removeEventListener(Event.ADDED, setupChildren);
			
			setupMenus();
		}
		
		public function setViewTradeFlag(flag:Boolean):void {
			bViewTrade = flag;
		}
		
		public function setViewDamFlag(flag:Boolean):void {
			bViewDam = flag;
		}
		
		public function setViewScoreFlag(flag:Boolean):void {
			bViewScore = flag;
		}
		
		public function closeMenuItems():void {
			if (viewTradeMI && viewTradeMI.parent)
				this.showMenuItems(false);
		}
		
		private function setupMenus():void {
			menu = new MenuButton();
			menu.x = xPos;
			menu.y = yPos;
			menu.addEventListener(MouseEvent.CLICK, menuMouseClicked, false, 0, true);
			menu.addEventListener(MouseEvent.MOUSE_OVER, menuMouseOver, false, 0, true);
			addChild(menu);
			menuNameTF = WaterUtils.setupTextFieldC2(this, WaterConsts.VIEW_DATA_OPTIONS_NAME,
																						 xPos, yPos + 3, WaterConsts.MENU_WIDTH, WaterConsts.MENU_HEIGHT,
																						 12, true);
			menuNameTF.mouseEnabled = false;
			menuNameTF.selectable = false;
			//setup menu items;
			viewTradeMI = new WaterMenuItem(WaterConsts.VIEW_TRADING_DATA_NAME,
																			xPos + 7, yPos + WaterConsts.MENU_HEIGHT);
			viewTradeMI.addEventListener(MouseEvent.CLICK, viewTradeMouseClicked, false, 0, true);
			viewTradeMI.addEventListener(MouseEvent.MOUSE_OVER, viewTradeMouseOver, false, 0, true);
			viewDamMI = new WaterMenuItem(WaterConsts.VIEW_DAM_DATA_NAME,
																			xPos + 7, yPos + WaterConsts.MENU_HEIGHT * 2);
			viewDamMI.addEventListener(MouseEvent.CLICK, viewDamMouseClicked, false, 0, true);
			viewDamMI.addEventListener(MouseEvent.MOUSE_OVER, viewDamMouseOver, false, 0, true);
			viewScoreMI = new WaterMenuItem(WaterConsts.VIEW_SCORING_DATA_NAME,
																			xPos + 7, yPos + WaterConsts.MENU_HEIGHT * 3);
			viewScoreMI.addEventListener(MouseEvent.CLICK, viewScoreMouseClicked, false, 0, true);
			viewScoreMI.addEventListener(MouseEvent.MOUSE_OVER, viewScoreMouseOver, false, 0, true);
		}
		
		private function menuMouseClicked(e:MouseEvent):void {
			if (viewTradeMI.parent) {
				showMenuItems(false);
			}
			else {
				showMenuItems(true);
				stage.addEventListener(MouseEvent.MOUSE_DOWN, stageMouseDownHandler, false, 0, true);
			}
		}
		
		private function stageMouseDownHandler(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, stageMouseDownHandler);
			if (e.target is MenuButton)
				return;
			if (viewTradeMI.parent)
			  showMenuItems(false);
		}
		
		private function viewTradeMouseClicked(e:MouseEvent):void {
			showMenuItems(false);
			bViewTrade = !bViewTrade;
			if (bViewTrade)
				dispatchEvent(new WaterEvent(WaterEvent.ADD_TRADING_INFO, true));
			else
				dispatchEvent(new WaterEvent(WaterEvent.CLOSE_TRADING_INFO, true));
		}
		
		private function viewDamMouseClicked(e:MouseEvent):void {
			showMenuItems(false);
			bViewDam = !bViewDam;
			if (bViewDam)
				dispatchEvent(new WaterEvent(WaterEvent.ADD_DAM_INFO, true));
			else
				dispatchEvent(new WaterEvent(WaterEvent.CLOSE_DAM_INFO, true));
		}
		
		private function viewScoreMouseClicked(e:MouseEvent):void {
			showMenuItems(false);
			bViewScore = !bViewScore;
			if (bViewScore)
				dispatchEvent(new WaterEvent(WaterEvent.ADD_SCORE_INFO, true));
			else
				dispatchEvent(new WaterEvent(WaterEvent.CLOSE_SCORE_INFO, true));
		}
		
		private function showMenuItems(show:Boolean):void {
			if (show) {
				viewTradeMI.displayCheckMark(bViewTrade);
				addChild(viewTradeMI);
				viewDamMI.displayCheckMark(bViewDam);
				addChild(viewDamMI);
				viewScoreMI.displayCheckMark(bViewScore);
				addChild(viewScoreMI);
			}
			else {
				removeChild(viewTradeMI);
				removeChild(viewDamMI);
				removeChild(viewScoreMI);
			}
		}
		
		private function menuMouseOver(e:MouseEvent):void {
			addChild(menu);
			addChild(menuNameTF);
		}
		
		private function viewTradeMouseOver(e:MouseEvent):void {
			addChild(viewTradeMI);
		}
		private function viewDamMouseOver(e:MouseEvent):void {
			addChild(viewDamMI);
		}
		private function viewScoreMouseOver(e:MouseEvent):void {
			addChild(viewScoreMI);
		}
	}
}