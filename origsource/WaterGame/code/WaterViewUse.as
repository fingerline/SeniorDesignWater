package code {

  import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.geom.*;
	import flash.ui.*;

  public class WaterViewUse extends Sprite {

		private var data:WaterDataPositionItem;
		private var isLeftRiverSide:Boolean;
		private var xPos:Number;
		private var yPos:Number;
		private var aliasTF:TextField;
		private var aliasView:WaterViewAlias;
		
    public function WaterViewUse(data:WaterDataPositionItem,
																 isLeftRiverSide:Boolean,
																 xPos:Number,
																 yPos:Number) {
			this.data = data;
			this.isLeftRiverSide = isLeftRiverSide;
			this.xPos = xPos;
			this.yPos = yPos;
			addEventListener(Event.ADDED, setupChildren, false, 0, true);
    }

    private function setupChildren(e:Event):void {
			removeEventListener(Event.ADDED, setupChildren);
			
			addEventListener(WaterEvent.REMOVE_VIEW_ALIAS, removeViewAlias, false, 0, true);
			addEventListener(WaterEvent.UPDATE_ALIAS, updateAlias, false, 0, true);
			handleContextMenu();
			drawUse();
		}
		
		public function withdrawGlobalPoint():Point {
			if (isLeftRiverSide)
				return new Point(xPos + WaterConsts.USE_WIDTH,
												 yPos + WaterConsts.USE_POINT_DELTA_Y);
			else
				return new Point(xPos,
												 yPos + WaterConsts.USE_POINT_DELTA_Y);
		}
		
		public function returnGlobalPoint():Point {
			if (isLeftRiverSide)
				return new Point(xPos + WaterConsts.USE_WIDTH,
												 yPos + WaterConsts.USE_HEIGHT - WaterConsts.USE_POINT_DELTA_Y);
			else
				return new Point(xPos,
												 yPos + WaterConsts.USE_HEIGHT - WaterConsts.USE_POINT_DELTA_Y);
		}
		
    private function drawUse():void {
			// get the correct bg color;
			var color:uint = WaterUtils.getBgColor(data.useCategory());
			var box:Shape = new Shape();
			box.graphics.lineStyle(1, WaterConsts.USE_BORDER_COLOR, 1,
														 false, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.MITER, 1);
			box.graphics.beginFill(color);
			box.graphics.drawRect(xPos, yPos, WaterConsts.USE_WIDTH, WaterConsts.USE_HEIGHT);
			box.graphics.endFill();
			addChild(box);
			// draw name;
			WaterUtils.setupTextFieldC2(this,
																	data.name(),
																	xPos, yPos + 11, WaterConsts.USE_WIDTH, WaterConsts.USE_HEIGHT,
																	11, true);
			updateAlias(null);
		}
		
		private function handleContextMenu():void {
			var myCM:ContextMenu = new ContextMenu();
			myCM.hideBuiltInItems();
			var menuName:String = WaterConsts.ADD_OR_CHANGE_ALIAS_NAME;
			var myCMI = new ContextMenuItem(menuName);
			myCM.customItems.push(myCMI);

			myCMI.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, aliasHandler);
			this.contextMenu = myCM;
		}
		
		private function aliasHandler(e:ContextMenuEvent):void {
			var point:Point = this.localToGlobal(new Point(this.mouseX, this.mouseY));
			if (point.x + 200 > stage.stageWidth)
				point.x -= 200;
			if (point.y + 100 > stage.stageHeight)
			  point.y -= 100;
			aliasView = new WaterViewAlias(data, point.x, point.y, 200, 120, getName());
			addChild(aliasView);
		}
		
		private function removeViewAlias(e:WaterEvent):void {
			removeChild(aliasView);
		}
		
		private function updateAlias(e:WaterEvent):void {
			if (aliasTF && aliasTF.parent)
				removeChild(aliasTF);
			var name:String = data.priorityDate();
			if (!data.emptyAlias())
				name += " " + data.alias;

			aliasTF = WaterUtils.setupTextFieldC2(this,
																		name,
																		xPos, yPos - 1, WaterConsts.USE_WIDTH, WaterConsts.USE_HEIGHT,
																		11, true);
		}
		
		private function getName():String {
			return data.emptyAlias() ? WaterConsts.ADD_NAME + " " + WaterConsts.ALIAS_NAME :
																 WaterConsts.CHANGE_NAME + " " + WaterConsts.ALIAS_NAME;
		}
  }
}
