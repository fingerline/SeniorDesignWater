package code {

  import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.ui.*;

  public class WaterViewScoreBoard extends WaterResizeComponent {

		// column title + WaterConsts.DATA_SIZE / 2 (15)
		private const TOTAL_ROWS:int = 16;
		private const LEFT_MARGIN:Number = 7;
		private const RIGHT_MARGIN:Number = 7;
		private const TOP_MARGIN:Number = 7;
		private const BOTTOM_MARGIN:Number = 14;
		// title uses 20 height;
		private const TITLE_HEIGHT:Number = 20;

		private var data:WaterData;
		private var wTable:Number;
		private var hTable:Number;
		private var container:Sprite;
		private var initialW:Number;
		private var initialH:Number;
		// this players list is ordered by the player id;
		private var players:Array;
		private var pointTFs:Array;
		private var withdrawalRequestTFs:Array;

    public function WaterViewScoreBoard(x:Number,
																		y:Number,
																		w:Number,
																		h:Number,
																		data:WaterData,
																		view:WaterView) {
			super(x, y, w, h, view);
			this.initialW = w;
			this.initialH = h;
			this.data = data;
			this.updateCalculationData(w, h);
			addEventListener(Event.ADDED, setupChildren, false, 0, true);
    }

    private function setupChildren(e:Event):void {
			removeEventListener(Event.ADDED, setupChildren);
			
			handleContextMenu();
			drawContents();
			super.addResizeIconAndFrame();
		}
		
		override public function resizeDone():void {
			this.updateCalculationData(super.width, super.height);
			drawContents();
		}
		
		override public function bringToTop():void {
			dispatchEvent(new WaterEvent(WaterEvent.TOP_SCORE_BOARD, true));
		}
		
		public function updatePoints():void {
			for (var i:int = 0; i < WaterConsts.DATA_SIZE; i++) {
				pointTFs[i].text = String(Math.round(players[i].personalPoints));
				withdrawalRequestTFs[i].text = String(Math.round(players[i].requestedWithdraw()));
			}
		}

		private function updateCalculationData(wNew:Number, hNew:Number):void {
			this.wTable = wNew - LEFT_MARGIN - RIGHT_MARGIN;
			this.hTable = hNew > TOP_MARGIN + BOTTOM_MARGIN + TITLE_HEIGHT ?
			              hNew - TOP_MARGIN - BOTTOM_MARGIN - TITLE_HEIGHT : 0;
		}
		
		private function drawContents():void {
			var idx:int = this.numChildren;
			if (this.container && this.container.parent) {
			  idx = this.getChildIndex(this.container);
				removeChild(this.container);
			}
			this.container = new Sprite();
			setupTitle();
			setupTable();
			addChildAt(this.container, idx);
		}
		
    private function setupTitle():void {
 			WaterUtils.setupRoundBackground(this.container,
																 WaterConsts.SCOREBOARD_BG_COLOR, 1,
																 xPos, yTop,
																 wTable + LEFT_MARGIN + RIGHT_MARGIN,
																 TOP_MARGIN + TITLE_HEIGHT + 15, 15, 15);
			WaterUtils.setupTextFieldC2(this.container,
																	WaterConsts.SCORE_BOARD_NAME,
																	xPos + LEFT_MARGIN, yTop + TOP_MARGIN - 3,
																	wTable, TITLE_HEIGHT + 5,
																	12, true);
//			trace("wTable: ", wTable);
		}
		
		private function setupTable():void {
			// setup bg color;
			if (hTable <= 0)
				return;
			WaterUtils.setupBackground(this.container,
																 WaterConsts.SCOREBOARD_BG_COLOR, 1,
																 xPos, yTop + TOP_MARGIN + TITLE_HEIGHT,
																 wTable + LEFT_MARGIN + RIGHT_MARGIN,
																 hTable + BOTTOM_MARGIN);
			// calculate the x, y, w, h for the table cell;
			// trace result: cellW: 48.33
			// trace result: CellH: 21.25
			var xBase1:Number = xPos + LEFT_MARGIN;
			var cellW:Number = (wTable - 10) / 6;
			// trace("cellW:", cellW);
			var midSep:Number = wTable - cellW * 6;
			var xBase2:Number = xBase1 + cellW * 3 + midSep;
			var cellH:Number = hTable / TOTAL_ROWS;
			// trace("cellH:", cellH);
			var yBase:Number = yTop + TOP_MARGIN + TITLE_HEIGHT;
			var xx:Number;
			var yy:Number;
			var i:int;
			// draw the column title;
			for (i = 0; i < 2; i++) {
				if (i == 0)
					xx = xBase1;
				else
					xx = xBase2;
				WaterUtils.setupTextFieldC2(this.container,
											WaterConsts.PLAYER_NAME,
											xx, yBase, cellW, cellH,
											11, true);
				WaterUtils.setupTextFieldC2(this.container,
											WaterConsts.WITHDRAWAL_REQUEST_NAME,
											xx + cellW, yBase, cellW, cellH,
											8, true);
				WaterUtils.setupTextFieldC2(this.container,
											WaterConsts.POINTS_NAME,
											xx + cellW * 2, yBase, cellW, cellH,
											11, true);
			}
			// setup players and pointTFs;
			players = new Array(WaterConsts.DATA_SIZE);
			pointTFs = new Array(WaterConsts.DATA_SIZE);
			withdrawalRequestTFs = new Array(WaterConsts.DATA_SIZE);
			var item:WaterDataPositionItem;
			var pointTF:TextField;
			var withdrawalRequestTF:TextField;
			var color:uint;
			for (i = 1; i <= WaterConsts.DATA_SIZE; i++) {
				if (i <= 15)
					xx = xBase1;
				else
					xx = xBase2;
				if (i <= 15)
					yy = yBase + i * cellH;
				else
					yy = yBase + (i - 15) * cellH;
				item = data.findPositionItem(i);
				// draw the background based on the use category
				color = WaterUtils.getBgColor(item.useCategory());
				WaterUtils.setupBackground(this.container,
																	 color, 1,
																	 xx, yy, cellW * 3, cellH);
				WaterUtils.setupTextFieldR2(this.container,
																 String(i),
																 xx, yy, cellW - 2, cellH,
																 11, true);
				players[i - 1] = item;
				if (i <= 15)
					xx = xBase1 + cellW;
				else
					xx = xBase2 + cellW;
				withdrawalRequestTF = WaterUtils.setupTextFieldR4(this.container,
																 xx, yy, cellW - 2, cellH,
																 11, true);
			  withdrawalRequestTFs[i - 1] = withdrawalRequestTF;
				pointTF = WaterUtils.setupTextFieldR4(this.container,
																 xx + cellW, yy, cellW - 2, cellH,
																 11, true);
				pointTFs[i - 1] = pointTF;
			}
			this.updatePoints();
			
			// draw the table;
			var box:Shape = new Shape();
			box.graphics.lineStyle(2, WaterConsts.BLACK_COLOR, 1,
														 false, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.MITER, 1);
			box.graphics.drawRect(xBase1, yBase, wTable, hTable);
			box.graphics.lineStyle(1, WaterConsts.BLACK_COLOR, 1,
														 false, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.MITER, 1);
			// horizontal lines;
			for (i = 1; i <= WaterConsts.DATA_SIZE / 2; i++) {
				yy = yBase + i * cellH;
				box.graphics.moveTo(xBase1, yy);
				box.graphics.lineTo(xBase1 + wTable, yy);
			}
			// vertical lines;
			for (i = 1; i <= 3; i++) {
				xx = xBase1 + i * cellW;
				box.graphics.moveTo(xx, yBase);
				box.graphics.lineTo(xx, yBase + hTable);
				xx = xBase2 + (i - 1) * cellW;
				box.graphics.moveTo(xx, yBase);
				box.graphics.lineTo(xx, yBase + hTable);
			}
			this.container.addChild(box);
			
		}
		
 		private function handleContextMenu():void {
			var myCM:ContextMenu = new ContextMenu();
			myCM.hideBuiltInItems();
			var myCMI = new ContextMenuItem(WaterConsts.INITIAL_SIZE_NAME);
			myCM.customItems.push(myCMI);

			myCMI.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, restoreInitialSize);
			this.contextMenu = myCM;
		}
		
		private function restoreInitialSize(e:ContextMenuEvent):void {
			dispatchEvent(new WaterEvent(WaterEvent.ADD_SCORE_BOARD, true));
		}
		
 }
}