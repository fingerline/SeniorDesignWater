package code {

  import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.ui.*;

  // 
  public class WaterViewScoreInfo extends WaterResizeComponent {

		// y axis: points;
		private const UNIT_Y:Number = 10000;
		// x axis: runoff;
		private const UNIT_X:Number = 1000;
		private const MAX_NUM_X:Number = Math.round(WaterConsts.MAX_RUNOFF / UNIT_X);
		private const MAX_NUM_Y:Number = Math.round(WaterConsts.MAX_TOTAL_POINTS / UNIT_Y);
		private const LEFT_MARGIN:Number = 60;
		private const RIGHT_MARGIN:Number = 24;
		private const BOTTOM_MARGIN:Number = 40;
		private const TOP_MARGIN:Number = 17;
		private const DOT_RADIUS:Number = 3;
		private const LEGEND_WIDTH_Y_AXIS:Number = 50;
		private const LEGEND_WIDTH_X_AXIS:Number = 60;

		private var data:WaterData;
		private var w:Number;
		private var h:Number;
		private var unitX:Number;
		private var unitY:Number;
		private var container:Sprite;

    public function WaterViewScoreInfo(x:Number,
																		yTop:Number,
																		w:Number,
																		h:Number,
																		data:WaterData,
																		view:WaterView) {
			super(x, yTop, w, h, view);
			this.data = data;
			this.updateCalculationData(w, h);
			addEventListener(Event.ADDED, setupChildren, false, 0, true);
    }

    private function setupChildren(e:Event):void {
			removeEventListener(Event.ADDED, setupChildren);

			handleContextMenu();
			drawScoreInfo();
			super.addResizeIconAndFrame();
		}
		
		override public function resizeDone():void {
			this.updateCalculationData(super.width, super.height);
			drawScoreInfo();
		}
		
		override public function bringToTop():void {
			dispatchEvent(new WaterEvent(WaterEvent.TOP_SCORE_INFO, true));
		}
		
		private function drawScoreInfo():void {
			var idx:int = this.numChildren;
			if (container && container.parent) {
			  idx = this.getChildIndex(container);
				removeChild(container);
			}
			container = new Sprite();
			drawBenchData();
			drawDots();
			addChildAt(container, idx);
		}
		
		private function updateCalculationData(wNew:Number, hNew:Number):void {
			this.w = wNew;
			this.h = hNew;
			this.unitX = (this.w - LEFT_MARGIN - RIGHT_MARGIN) / MAX_NUM_X;
			this.unitY = (this.h - BOTTOM_MARGIN - TOP_MARGIN) / MAX_NUM_Y;
		}
		
    private function drawDots():void {
			var box:Shape = new Shape();
			box.graphics.lineStyle(1, WaterConsts.BLACK_COLOR, 1,
														 false, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.MITER, 1);
			box.graphics.beginFill(WaterConsts.BLACK_COLOR);
			var x:Number, y:Number;
			for (var i:uint = 0; i < data.scoreData.length; i++) {
				x = xPos + LEFT_MARGIN + data.scoreData[i].runoff * unitX / UNIT_X;
				y = yTop + h - BOTTOM_MARGIN - data.scoreData[i].points * unitY / UNIT_Y;
				box.graphics.drawCircle(x, y, DOT_RADIUS);
				WaterUtils.setupTextFieldL2(container,
																		String(data.scoreData[i].year),
																		x + DOT_RADIUS, y - 8,
																		8, 16,
																		12, true);
			}
			box.graphics.endFill();
			container.addChild(box);
		}
		
		private function drawBenchData():void {
			WaterUtils.setupBackground(container,
																 WaterConsts.LIGHT_GREEN_COLOR, 1,
																 xPos, yTop, w, h);
			// draw the vertical line;
			var line:Shape = new Shape();
			line.graphics.lineStyle(2, WaterConsts.BLACK_COLOR, 1,
															false, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.MITER, 1);
			line.graphics.moveTo(LEFT_MARGIN, yTop);
			line.graphics.lineTo(LEFT_MARGIN, yTop + h);
			// draw the horizontal line;
			line.graphics.moveTo(xPos, yTop + h - BOTTOM_MARGIN);
			line.graphics.lineTo(xPos + w, yTop + h - BOTTOM_MARGIN);
			container.addChild(line);
			// setup bg color;
			var box:Shape = new Shape();
			box.graphics.lineStyle(1, WaterConsts.BLACK_COLOR, 1,
														 false, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.MITER, 1);
			drawScoreSection(box, WaterConsts.RED_COLOR, 1, 0.9, WaterConsts.A_NAME);
			drawScoreSection(box, WaterConsts.ORANGE_COLOR, 0.9, 0.8, WaterConsts.B_NAME);
			drawScoreSection(box, WaterConsts.YELLOW_COLOR, 0.8, 0.7, WaterConsts.C_NAME);
			drawScoreSection(box, WaterConsts.GREEN_COLOR, 0.7, 0.5, WaterConsts.D_NAME);
			drawScoreSection(box, WaterConsts.BLUE_COLOR, 0.5, 0, WaterConsts.F_NAME);
			container.addChild(box);
			// draw legends on x axis and its ruler lines
			// the width of 20000 is about 40;
			// total number of items to display is 10:
			var displayArray:Array = new Array(1000, 3000, 5000, 7000, 9000, 11000,
																				 13000, 15000, 17000, 20000);
			// original trace(numOfDisplay) = 5.5;
			var numOfDisplay:Number = (this.w - LEFT_MARGIN - RIGHT_MARGIN) / 40;
			var increment:int = 1;
			if (numOfDisplay < 6)
				increment = 5;
			else if (numOfDisplay < 11)
			  increment = 2;
			var xBase:Number = xPos + LEFT_MARGIN;
			var yBase:Number = yTop + h - BOTTOM_MARGIN;
			line.graphics.lineStyle(1, WaterConsts.BLACK_COLOR, 0.4,
															false, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.MITER, 1);
			var xx:Number;
			for (var i:int = 0; i < 10; i += increment) {
				xx = xBase + displayArray[i] * unitX / UNIT_X;
				WaterUtils.setupTextFieldC4(container,
																		String(displayArray[i]),
																		xx,
																		yBase,
																		LEGEND_WIDTH_X_AXIS, 16,
																		12, true);
				line.graphics.moveTo(xx, yTop);
				line.graphics.lineTo(xx, yBase);
			}
			if (increment > 1) {
				xx = xBase + displayArray[9] * unitX / UNIT_X;
				WaterUtils.setupTextFieldC4(container,
																		String(displayArray[9]),
																		xx,
																		yBase,
																		LEGEND_WIDTH_X_AXIS, 16,
																		12, true);
				line.graphics.moveTo(xx, yTop);
				line.graphics.lineTo(xx, yBase);
			}
			WaterUtils.setupTextFieldR2(container,
																	WaterConsts.RIVER_FLOW_ACRE_FEET_NAME,
																	xPos + this.w - RIGHT_MARGIN - 200,
																	yBase + 20,
																	200, 16,
																	12, true);
			// draw legends on y axis and its ruler lines
			var yy:Number;
			for (var points:int = 20000; points < 120000; points += 20000) {
				yy = yBase - points * unitY / UNIT_Y;
				WaterUtils.setupTextFieldR2(container,
																		String(points),
																		xBase - LEGEND_WIDTH_Y_AXIS - 7,
																		yy - 8,
																		LEGEND_WIDTH_Y_AXIS, 16,
																		12, true);
				line.graphics.moveTo(xBase, yy);
				line.graphics.lineTo(xPos + this.w, yy);
			}
			WaterUtils.setupTextFieldR2(container,
																	WaterConsts.POINTS_NAME,
																	xBase - LEGEND_WIDTH_Y_AXIS - 7, yTop,
																	LEGEND_WIDTH_Y_AXIS, 16,
																	12, true);
		}
		
		private function handleContextMenu():void {
			var myCM:ContextMenu = new ContextMenu();
			myCM.hideBuiltInItems();
			var myCMI = new ContextMenuItem(WaterConsts.CLOSE_SCORING_DATA_NAME);
			myCM.customItems.push(myCMI);

			myCMI.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, closeScoringData);
			this.contextMenu = myCM;
		}
		
		private function closeScoringData(e:ContextMenuEvent):void {
			dispatchEvent(new WaterEvent(WaterEvent.CLOSE_SCORE_INFO, true));
		}
		
		private function drawScoreSection(box:Shape, color:uint,
																			tPercentY:Number, bPercentY:Number,
																			grade:String):void {
			var xBase:Number = xPos + LEFT_MARGIN;
			var yBase:Number = yTop + h - BOTTOM_MARGIN;
			var commands:Vector.<int> = new Vector.<int>();
			var coord:Vector.<Number> = new Vector.<Number>();
			var x0:Number, y0:Number;
			for (var i:int = 0; i < WaterConsts.SCORE_DATA_SIZE; i++) {
				if (i == 0) {
					commands.push(1);
					x0 = xBase + data.scoreBenchData[i].runoff * unitX / UNIT_X;
					y0 = yBase - data.scoreBenchData[i].points * unitY * tPercentY / UNIT_Y;
				}
				else {
					commands.push(2);
				}
				coord.push(xBase + data.scoreBenchData[i].runoff * unitX / UNIT_X,
									 yBase - data.scoreBenchData[i].points * unitY * tPercentY / UNIT_Y);
			}
			for (var j:int = WaterConsts.SCORE_DATA_SIZE - 1; j >= 0; j--) {
				commands.push(2);
				coord.push(xBase + data.scoreBenchData[j].runoff * unitX / UNIT_X,
									 yBase - data.scoreBenchData[j].points * unitY * bPercentY / UNIT_Y);
			}
			commands.push(2);
			coord.push(x0, y0);
			box.graphics.beginFill(color, 0.5);
			box.graphics.drawPath(commands, coord);
			box.graphics.endFill();
			// draw grade character;
			if (grade.length > 0) {
				var lastPoints:Number = data.scoreBenchData[WaterConsts.SCORE_DATA_SIZE - 1].points;
				WaterUtils.setupTextFieldR2(container,
																		grade,
																		xPos + this.w - RIGHT_MARGIN - 10 - 7,
																		yBase - lastPoints * unitY * bPercentY / UNIT_Y - 16,
																		10, 16,
																		12, true);
			}
		}
  }
}
