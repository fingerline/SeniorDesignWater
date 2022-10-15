package code {

  import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.ui.*;

  public class WaterViewDamInfo extends WaterDragSprite {

		private var data:WaterData;
		private var xPos:Number;
		private var yBottom:Number;
		private var wTable:Number;
		private var wFirstCell:Number;
		private var wSecondCell:Number;
		private var hTable:Number;

    public function WaterViewDamInfo(x:Number,
																		yBottom:Number,
																		w:Number,
																		data:WaterData) {
      this.xPos = x;
			this.yBottom = yBottom;
			this.wTable = w;
			this.data = data;
			this.wFirstCell = w / 3;
			this.wSecondCell = w - wFirstCell;
			addEventListener(Event.ADDED, setupChildren, false, 0, true);
    }

    private function setupChildren(e:Event):void {
			removeEventListener(Event.ADDED, setupChildren);

			// 2: table header and total line;
			hTable = (getCount() + 2) * WaterConsts.TABLE_CELL_HEIGHT;

			setupTitle();
			setupTable();
			handleContextMenu();
		}
		
    private function setupTitle():void {
			// 20: title;
			var yPos:Number = yBottom - hTable - 20;
 			WaterUtils.setupRoundBackground(this,
																 WaterConsts.BUILDADAM_BG_COLOR, 1,
																 xPos, yPos, wTable, 40, 15, 15);
			WaterUtils.setupTextFieldC2(this,
																	WaterConsts.BUILD_A_DAM_NAME.toUpperCase(),
																	xPos, yPos, wTable, 20,
																	12, true);
		}
		
		private function setupTable():void {
			// setup bg color;
			var count:int = getCount();
			var yTop = yBottom - hTable;
			WaterUtils.setupBackground(this,
																 WaterConsts.BUILDADAM_BG_COLOR, 1,
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
			for (var i:int = 1; i <= count + 1; i++) {
				yy = yTop + i * WaterConsts.TABLE_CELL_HEIGHT;
				box.graphics.moveTo(xPos, yy);
				box.graphics.lineTo(xPos + wTable, yy);
			}
			// vertical lines;
			box.graphics.moveTo(xPos + wFirstCell, yTop);
			box.graphics.lineTo(xPos + wFirstCell, yTop + hTable);
			addChild(box);
			// draw the column title;
			WaterUtils.setupTextFieldC2(this,
										WaterConsts.PLAYER_NAME,
										xPos, yTop, wFirstCell, WaterConsts.TABLE_CELL_HEIGHT,
										10, true);
			WaterUtils.setupTextFieldC2(this,
										WaterConsts.POINTS_CONTRIBUTED_NAME,
										xPos + wFirstCell, yTop, wSecondCell, WaterConsts.TABLE_CELL_HEIGHT,
										10, true);
			// setup players and points contributed;
			var damPoints:WaterDataDamPoints;
			var totalPoints:Number = 0;
			for (var j:uint = 0; j < data.damData.length; j++) {
				damPoints = data.damData[j];
				totalPoints += damPoints.points;
				yy = yTop + (j + 1) * WaterConsts.TABLE_CELL_HEIGHT;
				WaterUtils.setupTextFieldR2(this,
																 String(damPoints.player.playerNumber()),
																 xPos, yy,
																 wFirstCell - 2, WaterConsts.TABLE_CELL_HEIGHT,
																 11, true);
				WaterUtils.setupTextFieldR2(this,
																 String(Math.round(damPoints.points)),
																 xPos + wFirstCell, yy,
																 wSecondCell - 2, WaterConsts.TABLE_CELL_HEIGHT,
																 11, true);
			}
			// draw the TOTAL line;
			if (data.damData.length == 0)
				return;
			yy = yTop + (j + 1) * WaterConsts.TABLE_CELL_HEIGHT;
			WaterUtils.setupTextFieldR2(this,
																	WaterConsts.TOTAL_NAME,
																	xPos, yy,
																	wFirstCell - 2, WaterConsts.TABLE_CELL_HEIGHT,
																	11, true);
			WaterUtils.setupTextFieldR2(this,
																	String(Math.round(totalPoints)),
																	xPos + wFirstCell, yy,
																	wSecondCell - 2, WaterConsts.TABLE_CELL_HEIGHT,
																	11, true);
		}
		
		private function handleContextMenu():void {
			var myCM:ContextMenu = new ContextMenu();
			myCM.hideBuiltInItems();
			var myCMI = new ContextMenuItem(WaterConsts.CLOSE_BUILD_A_DAM_NAME);
			myCM.customItems.push(myCMI);

			myCMI.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, closeBuildADam);
			this.contextMenu = myCM;
		}
		
		private function closeBuildADam(e:ContextMenuEvent):void {
			dispatchEvent(new WaterEvent(WaterEvent.CLOSE_DAM_INFO, true));
		}
		
		private function getCount():int {
			var count:int = int(data.damData.length);
			if (count < 4)
			  count = 4;
			return count;
		}
  }
}