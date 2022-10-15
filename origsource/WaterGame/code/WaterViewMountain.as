package code {

  import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.text.TextField;

  public class WaterViewMountain extends Sprite {

		private const MAX_DAM_CAPACITY:Number = WaterConsts.MAX_RUNOFF;
		private const MAX_DAM_HEIGHT:Number = 50;
    private const MOUNTAIN_X:Number = WaterConsts.GAME_WIDTH - 202;
		private const MOUNTAIN_Y:Number = 50;
		private const DAM_X:Number = WaterConsts.GAME_WIDTH - 340;
		private const DAM_Y_BOTTOM:Number = 81;
		private const DAM_WATER_X:Number = WaterConsts.GAME_WIDTH - 307;
		private const DAM_WATER_Y_BOTTOM:Number = 103;
		
		private var data:WaterData;
		private var damHeight:Number;
		private var capacityB:Sprite;
		private var capacityT:Sprite;
		private var usageB:Sprite;
		private var usageT:Sprite;

    public function WaterViewMountain(data:WaterData) {
			this.data = data;
			
			addEventListener(Event.ADDED, setupChildren, false, 0, true);
    }

    private function setupChildren(e:Event):void {
			removeEventListener(Event.ADDED, setupChildren);
			
			setupMountain();
		}

		public function buildDam():void {
			drawDamStorage();
		}
		
		public function updateUsage():void {
			if (usageB && usageB.parent)
				removeChild(usageB);
			if (usageT && usageT.parent)
				removeChild(usageT);
			if (data.damCapacity <= 0)
				return;
			var ratio:Number = data.damReservoir / data.damCapacity;
			var vHeight:Number = damHeight * ratio;
			if (Math.round(data.damReservoir) > 0) {
				usageB = new Sprite();
				var damWater:Shape = new Shape();
				damWater.graphics.lineStyle(1, WaterConsts.BLACK_COLOR, 1,
															 false, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.MITER, 1);
				damWater.graphics.beginFill(WaterConsts.RIVER_COLOR);
				var commands:Vector.<int> = new Vector.<int>(); 
				commands.push(1,2,2,2,2,2,2,2,2,2,2,2,2,2,2);
				var coord:Vector.<Number> = new Vector.<Number>();
				coord.push(0,11, 11,2, 26,0, 44,1, 61,4, 77,7, 96,18,
									 120,32, 160,72, 160,72+vHeight, 148,86+vHeight,
									 130,96+vHeight, 97,108+vHeight, 0,11+vHeight, 0,11);
				damWater.graphics.drawPath(commands, coord);
				damWater.graphics.endFill();
				damWater.x = DAM_WATER_X;
				damWater.y = DAM_WATER_Y_BOTTOM - vHeight;
				usageB.addChild(damWater);
				var lines:Shape = new Shape()
				lines.graphics.lineStyle(1, WaterConsts.BLACK_COLOR, 1,
															 false, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.MITER, 1);
				// front left curve : straight line from left-most point (0, 11) to bottom point (97, 108);
				lines.graphics.moveTo(0, 11);
				lines.graphics.lineTo(97, 108);
				// front right curve (97,108, 130,96, 148,86, 160,72);
				commands = new Vector.<int>();
				commands.push(1,2,2,2);
				coord = new Vector.<Number>();
				coord.push(97,108, 130,96, 148,86, 160,72);
				lines.graphics.drawPath(commands, coord);
				lines.x = DAM_WATER_X;
				lines.y = DAM_WATER_Y_BOTTOM - vHeight;
				usageB.addChild(lines);
				addChildAt(usageB, 1);
			}
			usageT = new Sprite();
			var reservoir:String = "Stored water: " + String(Math.round(data.damReservoir));
			// right-most point (160, 72);
			WaterUtils.setupTextFieldL2(usageT, reservoir,
																	DAM_WATER_X + 160, DAM_WATER_Y_BOTTOM - vHeight + 72 - 10, 100, 20,
																	12, true);
			addChild(usageT);
		}
		
		private function drawDamStorage():void {
			if (capacityB && capacityB.parent)
				removeChild(capacityB);
			if (capacityT && capacityT.parent)
				removeChild(capacityT);
			if (data.damCapacity <= 0)
				return;
			capacityB = new Sprite();
			var ratio:Number = data.damCapacity / this.MAX_DAM_CAPACITY;
			damHeight = this.MAX_DAM_HEIGHT * ratio;
			var damWater:Shape = new Shape();
			damWater.graphics.lineStyle(1, WaterConsts.BLACK_COLOR, 1,
														 false, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.MITER, 1);
			var commands:Vector.<int> = new Vector.<int>(); 
			commands.push(1,2,2,2,2,2,2,2,2,2,2,2,2);
			var coord:Vector.<Number> = new Vector.<Number>();
			coord.push(0,11, 11,2, 26,0, 44,1, 61,4, 77,7, 96,18,
								 120,32, 160,72, 148,86, 130,96, 97,108, 0,11);
			damWater.graphics.drawPath(commands, coord);
			damWater.x = DAM_WATER_X;
			damWater.y = DAM_WATER_Y_BOTTOM;
			capacityB.addChild(damWater);
			var waterCopy:Shape = new Shape();
			waterCopy.graphics.copyFrom(damWater.graphics);
			waterCopy.x = DAM_WATER_X;
			waterCopy.y = DAM_WATER_Y_BOTTOM - damHeight;
			capacityB.addChild(waterCopy);
			var lines:Shape = new Shape();
			lines.graphics.lineStyle(1, WaterConsts.BLACK_COLOR, 1,
														 false, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.MITER, 1);
			// left-most point (0, 11);
			lines.graphics.moveTo(0, 11);
			lines.graphics.lineTo(0, 11 + damHeight);
			// right-most point (160, 72);
			lines.graphics.moveTo(160, 72);
			lines.graphics.lineTo(160, 72 + damHeight);
			// bottom point (67, 78);
			lines.graphics.moveTo(67, 78);
			lines.graphics.lineTo(67, 78 + damHeight);
			lines.x = DAM_WATER_X;
			lines.y = DAM_WATER_Y_BOTTOM - damHeight;
			capacityB.addChild(lines);
			// draw the dam; y = -x
			// (0, 0) -> (150, 150)
			var dam:Shape = new Shape();
			dam.graphics.lineStyle(1, WaterConsts.BLACK_COLOR, 1,
														 false, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.MITER, 1);
			dam.graphics.beginFill(WaterConsts.DAM_COLOR);
			commands = new Vector.<int>();
			commands.push(1,2,2,2,2);
			coord = new Vector.<Number>();
			coord.push(0,0, 150,150, 150,150+damHeight, 0,0+damHeight, 0,0);
			dam.graphics.drawPath(commands, coord);
			dam.x = DAM_X;
			dam.y = DAM_Y_BOTTOM - damHeight;
			capacityB.addChild(dam);
			addChildAt(capacityB, 1);
			capacityT = new Sprite();
			var capacity:String = "Capacity: " + String(Math.round(data.damCapacity));
			// right-most point (130, 72);
			WaterUtils.setupTextFieldL2(capacityT, capacity,
																	DAM_WATER_X + 160, DAM_WATER_Y_BOTTOM - damHeight + 50, 100, 20,
																	12, true);
			addChild(capacityT);
		}
		
    private function setupMountain() {
			var mountain:MovieClip = new MountainMC();
			mountain.x = MOUNTAIN_X;
			mountain.y = MOUNTAIN_Y;
			mountain.cacheAsBitmap = true;
			mountain.alpha = 0.5;
			addChildAt(mountain, 0);
		}
		
  }
}