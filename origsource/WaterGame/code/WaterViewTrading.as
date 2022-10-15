package code {

  import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.ui.*;

  public class WaterViewTrading extends Sprite {

		private var data:WaterData;
		private var xPos:Number;
		private var yPos:Number;
		private var wTable:Number;
		private var wCell:Number;
		private var wMid:Number;
		private var titleBg:Boolean;

    public function WaterViewTrading(x:Number,
																		y:Number,
																		w:Number,
																		data:WaterData,
																		titleBg:Boolean) {
      this.xPos = x;
			this.yPos = y;
			this.wTable = w;
			this.data = data;
			this.titleBg = titleBg;
			this.wCell = w / 5 + 1;
			this.wMid = w - 4 * wCell;
			addEventListener(Event.ADDED, setupChildren, false, 0, true);
    }

    private function setupChildren(e:Event):void {
			removeEventListener(Event.ADDED, setupChildren);
			
			setupTitle();
			setupTable();
			handleContextMenu();
		}
		
    private function setupTitle():void {
			if (titleBg)
  			WaterUtils.setupBackground(this,
																 WaterConsts.WATERTRADING_BG_COLOR, 1,
																 xPos, yPos, wTable, 40);
			WaterUtils.setupTextFieldC2(this,
																	WaterConsts.WATER_TRADING_NAME,
																	xPos, yPos, wTable, 20,
																	12, true);
			WaterUtils.setupTextFieldC2(this,
																	WaterConsts.WATER_SOLD_NAME,
																	xPos, yPos + 20, wCell * 2, 20,
																	11, true);
			WaterUtils.setupTextFieldC2(this,
																	WaterConsts.WATER_BOUGHT_NAME,
																	xPos + wCell * 2 + wMid, yPos + 20, wCell * 2, 20,
																	11, true);
		}
		
		private function setupTable():void {
			// setup bg color;
			var yTop:Number = yPos + 40;
			var count:int = int(data.tradeData.length);
			if (count < 4)
			  count = 4;
			var hTable:Number = (count + 1) * WaterConsts.TABLE_CELL_HEIGHT;
			WaterUtils.setupBackground(this,
																 WaterConsts.WATERTRADING_BG_COLOR, 1,
																 xPos, yTop, wTable, hTable);
			// draw the table;
			var box:Shape = new Shape();
			box.graphics.lineStyle(2, WaterConsts.BLACK_COLOR, 1,
														 false, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.MITER, 1);
			box.graphics.drawRect(xPos, yTop, wTable, hTable);
			box.graphics.lineStyle(1, WaterConsts.BLACK_COLOR, 1,
														 false, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.MITER, 1);
			// horizontal lines;
			var yy:Number;
			for (var i:int = 1; i <= count; i++) {
				yy = yTop + i * WaterConsts.TABLE_CELL_HEIGHT;
				box.graphics.moveTo(xPos, yy);
				box.graphics.lineTo(xPos + wTable, yy);
			}
			// vertical lines;
			var xx:Number;
			var xBase2:Number = xPos + wCell * 2 + wMid;
			for (i = 1; i <= 2; i++) {
				xx = xPos + i * wCell;
				box.graphics.moveTo(xx, yTop);
				box.graphics.lineTo(xx, yTop + hTable);
				xx = xBase2 + (i - 1) * wCell;
				box.graphics.moveTo(xx, yTop);
				box.graphics.lineTo(xx, yTop + hTable);
			}
			addChild(box);
			// draw the column title;
			for (i = 0; i < 2; i++) {
				if (i == 0)
					xx = xPos;
				else
					xx = xBase2;
				WaterUtils.setupTextFieldC2(this,
											WaterConsts.PLAYER_NAME,
											xx, yTop, wCell, WaterConsts.TABLE_CELL_HEIGHT,
											10, true);
				WaterUtils.setupTextFieldC2(this,
											WaterConsts.ACRE_FEET_NAME,
											xx + wCell, yTop, wCell, WaterConsts.TABLE_CELL_HEIGHT,
											10, true);
			}
			WaterUtils.setupTextFieldC2(this,
											WaterConsts.PRICE_NAME,
											xPos + wCell * 2, yTop, wMid, WaterConsts.TABLE_CELL_HEIGHT,
											10, true);
			// setup players, amount of water to trade and price;
			var trade:WaterDataTrade;
			var pointTF:TextField;
			for (var j:uint = 0; j < data.tradeData.length; j++) {
				trade = data.tradeData[j];
				yy = yTop + (j + 1) * WaterConsts.TABLE_CELL_HEIGHT;
				WaterUtils.setupTextFieldR2(this,
																 String(trade.seller.playerNumber()),
																 xPos, yy,
																 wCell - 2, WaterConsts.TABLE_CELL_HEIGHT,
																 11, true);
				WaterUtils.setupTextFieldR2(this,
																 String(trade.amount(trade.seller)),
																 xPos + wCell, yy,
																 wCell - 2, WaterConsts.TABLE_CELL_HEIGHT,
																 11, true);
				WaterUtils.setupTextFieldR2(this,
																 String(trade.price),
																 xPos + wCell * 2, yy,
																 wMid - 2, WaterConsts.TABLE_CELL_HEIGHT,
																 11, true);
				WaterUtils.setupTextFieldR2(this,
																 String(trade.buyer.playerNumber()),
																 xPos + wCell * 2 + wMid, yy,
																 wCell - 2, WaterConsts.TABLE_CELL_HEIGHT,
																 11, true);
				WaterUtils.setupTextFieldR2(this,
																 String(trade.amount(trade.buyer)),
																 xPos + wCell * 3 + wMid, yy,
																 wCell - 2, WaterConsts.TABLE_CELL_HEIGHT,
																 11, true);
			}
		}
		
		private function handleContextMenu():void {
			var myCM:ContextMenu = new ContextMenu();
			myCM.hideBuiltInItems();
			var myCMI = new ContextMenuItem(WaterConsts.CLOSE_WATER_TRADING_NAME);
			myCM.customItems.push(myCMI);

			myCMI.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, closeWaterTrading);
			this.contextMenu = myCM;
		}
		
		private function closeWaterTrading(e:ContextMenuEvent) {
			dispatchEvent(new WaterEvent(WaterEvent.CLOSE_TRADING, true));
		}
		
  }
}