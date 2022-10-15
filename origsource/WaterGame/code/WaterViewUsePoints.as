package code {
	
	import flash.display.*;
	import fl.controls.*;
	import flash.text.*;
	import flash.events.*;

  public class WaterViewUsePoints extends WaterDragSprite {

		private const MAX_POINTS:int = 10;
		private const BAR_RULER_UNIT:Number = 1;
		private const BAR_TICK_WIDTH:Number = 8;
		private const BAR_RULER_WIDTH:Number = 20;

		private var xPos:Number;
		private var yBottom:Number;
		private var w:Number;
		private var hTotal:Number;
		
		public function WaterViewUsePoints(x:Number, yBottom:Number,
																			 w:Number, h:Number) {
			this.xPos = x;
			this.yBottom = yBottom;
			this.w = w;
			this.hTotal = h;
			addEventListener(Event.ADDED, setupChildren, false, 0, true);
    }

    private function setupChildren(e:Event):void {
			removeEventListener(Event.ADDED, setupChildren);
			
			drawUsePoints();
		}
		
		private function drawUsePoints():void {
			// draw the title - 20 height;
			WaterUtils.setupTextFieldC2(this, WaterConsts.USE_POINTS_PER_ACRE_FOOT_NAME,
																	xPos, yBottom - hTotal, w, 20,
																	12, true);
			// draw the ticks;
			// draw the rulers;
			var box:Shape = new Shape();
			box.graphics.lineStyle(2, WaterConsts.BLACK_COLOR, 1,
															false, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.MITER, 1);
			var h:Number = hTotal - 20;
			var dist:int = 0;
			var yDelta:Number;
			while (dist <= MAX_POINTS) {
				yDelta = Math.round(h * dist / MAX_POINTS);
				box.graphics.moveTo(xPos + BAR_RULER_WIDTH, yBottom - yDelta);
				box.graphics.lineTo(xPos + BAR_RULER_WIDTH + BAR_TICK_WIDTH, yBottom - yDelta);
				WaterUtils.setupTextFieldR2(this,
															 String(dist),
															 xPos,
															 yBottom - yDelta - 10,
															 BAR_RULER_WIDTH,
															 20,
															 12,
															 true);
				dist += BAR_RULER_UNIT;
			}
			var xBase:Number = xPos + BAR_RULER_WIDTH + BAR_TICK_WIDTH;
			box.graphics.moveTo(xBase, yBottom - h);
			box.graphics.lineTo(xBase, yBottom);
			addChild(box);
			// draw the bar;
			box.graphics.lineStyle(1, WaterConsts.BLACK_COLOR, 1,
															false, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.MITER, 1);
			var wBar:Number = (w - BAR_RULER_WIDTH - BAR_TICK_WIDTH) / 4;
			// urban = 10;
			var hh:Number = h;
			drawRectangle(box, WaterConsts.URBAN_BG_COLOR,
										xBase, yBottom - hh - 1,
										wBar, hh + 1);
			var tf:TextField = WaterUtils.setupTextFieldL4(this, WaterConsts.USE_URBAN_NAME,
																	xBase + (wBar - 16 ) / 2,
																	yBottom, h, wBar,
																	12, true);
			// industrial = 5;
			hh = h * 5 / 10;
			drawRectangle(box, WaterConsts.INDUSTRIAL_BG_COLOR,
										xBase + wBar, yBottom - hh,
										wBar, hh);
			WaterUtils.setupTextFieldL4(this, WaterConsts.USE_INDUSTRIAL_NAME,
																	xBase + wBar + (wBar - 16 ) / 2,
																	yBottom, h, wBar,
																	12, true);
			// mining = 2;
			hh = h * 2 / 10;
			drawRectangle(box, WaterConsts.MINING_BG_COLOR,
										xBase + wBar * 2, yBottom - hh,
										wBar, hh);
			WaterUtils.setupTextFieldL4(this, WaterConsts.USE_MINING_NAME,
																	xBase + wBar * 2 + (wBar - 16 ) / 2,
																	yBottom, h, wBar,
																	12, true);
			// farm = 1;
			hh = h * 1 / 10;
			drawRectangle(box, WaterConsts.FARM_BG_COLOR,
										xBase + wBar * 3, yBottom - hh,
										wBar, hh);
			WaterUtils.setupTextFieldL4(this, WaterConsts.USE_FARM_NAME,
																	xBase + wBar * 3 + (wBar - 16 ) / 2,
																	yBottom, h, wBar,
																	12, true);

		}
		
		private function drawRectangle(box:Shape, color:uint,
																	 x:Number, y:Number, w:Number, h:Number):void {
			box.graphics.beginFill(color);
			box.graphics.drawRect(x, y, w, h);
			box.graphics.endFill();
		}
	}
}