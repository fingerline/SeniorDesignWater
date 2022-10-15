package code {
	
	import flash.display.*;
	import fl.controls.*;
	import flash.text.*;
	import flash.events.*;

  public class WaterManageOptions extends Sprite {

		private var data:WaterData;
		private var xPos:Number;
		private var yPos:Number;
		private var menu:MenuButton;
		private var menuNameTF:TextField;
		private var mfrMenuItem:WaterMenuItem;
		private var tradeMenuItem:WaterMenuItem;
		private var damMenuItem:WaterMenuItem;
		
		public function WaterManageOptions(data:WaterData, x:Number, y:Number) {
			this.data = data;
			this.xPos = x;
			this.yPos = y;
			addEventListener(Event.ADDED, setupChildren, false, 0, true);
    }

    private function setupChildren(e:Event):void {
			removeEventListener(Event.ADDED, setupChildren);
			
			setupMenus();
		}
		
		public function closeMenuItems():void {
			if (mfrMenuItem && mfrMenuItem.parent)
				this.showMenuItems(false);
		}
		
		private function setupMenus():void {
			menu = new MenuButton();
			menu.x = xPos;
			menu.y = yPos;
			menu.addEventListener(MouseEvent.CLICK, menuMouseClicked, false, 0, true);
			menu.addEventListener(MouseEvent.MOUSE_OVER, menuMouseOver, false, 0, true);
			addChild(menu);
			menuNameTF = WaterUtils.setupTextFieldC2(this, WaterConsts.WATER_MANAGEMENT_OPTIONS_NAME,
																						 xPos, yPos + 3, WaterConsts.MENU_WIDTH, WaterConsts.MENU_HEIGHT,
																						 12, true);
			menuNameTF.mouseEnabled = false;
			menuNameTF.selectable = false;
			//setup menu items;
			mfrMenuItem = new WaterMenuItem(WaterConsts.MINIMUM_FLOW_REQUIREMENT_NAME,
																			xPos + 7, yPos + WaterConsts.MENU_HEIGHT);
			mfrMenuItem.addEventListener(MouseEvent.CLICK, mfrMouseClicked, false, 0, true);
			mfrMenuItem.addEventListener(MouseEvent.MOUSE_OVER, mfrMouseOver, false, 0, true);
			tradeMenuItem = new WaterMenuItem(WaterConsts.TRADE_NAME,
																			xPos + 7, yPos + WaterConsts.MENU_HEIGHT * 2);
			tradeMenuItem.addEventListener(MouseEvent.CLICK, tradeMouseClicked, false, 0, true);
			tradeMenuItem.addEventListener(MouseEvent.MOUSE_OVER, tradeMouseOver, false, 0, true);
			damMenuItem = new WaterMenuItem(WaterConsts.BUILD_A_DAM_NAME,
																			xPos + 7, yPos + WaterConsts.MENU_HEIGHT * 3);
			damMenuItem.addEventListener(MouseEvent.CLICK, damMouseClicked, false, 0, true);
			damMenuItem.addEventListener(MouseEvent.MOUSE_OVER, damMouseOver, false, 0, true);
		}
		
		private function menuMouseClicked(e:MouseEvent):void {
			if (mfrMenuItem.parent) {
				showMenuItems(false);
			}
			else {
				showMenuItems(true, data.tradingChecked, data.damChecked);
				stage.addEventListener(MouseEvent.MOUSE_DOWN, stageMouseDownHandler, false, 0, true);
			}
		}
		
		private function stageMouseDownHandler(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, stageMouseDownHandler);
			if (e.target is MenuButton)
				return;
			if (mfrMenuItem.parent)
			  showMenuItems(false);
		}
		
		private function mfrMouseClicked(e:MouseEvent):void {
			showMenuItems(false);
			dispatchEvent(new WaterEvent(WaterEvent.ADD_VIEW_MFR, true));
		}
		
		private function tradeMouseClicked(e:MouseEvent):void {
			if (data.tradingChecked)
				return;
			showMenuItems(false);
			dispatchEvent(new WaterEvent(WaterEvent.ADD_VIEW_TRADE, true));
		}
		
		private function damMouseClicked(e:MouseEvent):void {
			if (data.damChecked)
				return;
			showMenuItems(false);
			dispatchEvent(new WaterEvent(WaterEvent.ADD_VIEW_DAM, true));
		}
		
		private function showMenuItems(show:Boolean,
																	 disableTrade:Boolean = false,
																	 disableDam:Boolean = false):void {
			if (show) {
				addChild(mfrMenuItem);
				tradeMenuItem.disable(disableTrade);
				addChild(tradeMenuItem);
				damMenuItem.disable(disableDam);
				addChild(damMenuItem);
			}
			else {
				removeChild(mfrMenuItem);
				removeChild(tradeMenuItem);
				removeChild(damMenuItem);
			}
		}
		
		private function menuMouseOver(e:MouseEvent):void {
			addChild(menu);
			addChild(menuNameTF);
		}
		
		private function mfrMouseOver(e:MouseEvent):void {
			addChild(mfrMenuItem);
		}
		private function tradeMouseOver(e:MouseEvent):void {
			addChild(tradeMenuItem);
		}
		private function damMouseOver(e:MouseEvent):void {
			addChild(damMenuItem);
		}
	}
}