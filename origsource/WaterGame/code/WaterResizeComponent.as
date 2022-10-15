package code {
	
	import flash.events.*;
	import flash.display.*;
	import fl.managers.IFocusManagerComponent;
	import fl.core.UIComponent;
	import fl.events.*;
	import flash.ui.*;
	import flash.geom.Point;
	import fl.controls.ScrollBar;

  public class WaterResizeComponent extends UIComponent implements IFocusManagerComponent {
		
		protected const RESIZE_CURSOR:String = "resizeArrow";
		
		protected var xPos:Number;
		protected var yTop:Number;
		protected var iconWidth:Number;
		protected var iconHeight:Number;
		protected var minWidth:Number;
		protected var minHeight:Number;
		protected var resizeIcon:MovieClip;
		protected var frame:Shape;
		protected var view:WaterView;
		
		public function WaterResizeComponent(x:Number, y:Number, minWidth:Number, minHeight:Number,
																				 view:WaterView) {
			super();
			this.xPos = x;
			this.yTop = y;
			this.minWidth = minWidth;
			this.minHeight = minHeight;
			this.view = view;
			
			this.resizeIcon = new ResizeIconMC();
			this.resizeIcon.alpha = 0.5;
			iconWidth = resizeIcon.width;
			iconHeight = resizeIcon.height;
			this.resizeIcon.x = xPos + minWidth - iconWidth;
			this.resizeIcon.y = yTop + minHeight - iconHeight;
			this.resizeIcon.addEventListener(MouseEvent.MOUSE_DOWN, resizeIconMouseDownHandler, false, 0, true);
			this.resizeIcon.addEventListener(MouseEvent.MOUSE_OVER, resizeIconMouseOverHandler, false, 0, true);
			this.resizeIcon.addEventListener(MouseEvent.MOUSE_OUT, resizeIconMouseOutHandler, false, 0, true);
			
			frame = new Shape();
			
			createResizeCursor();
		}
		
		public function addResizeIconAndFrame():void {
			addChild(resizeIcon);
			addChild(frame);
		}
		
		public function resizeDone():void {
		}
		
		public function bringToTop():void {
		}

		protected function resizeIconMouseOverHandler(e:MouseEvent):void {
			Mouse.cursor = RESIZE_CURSOR;
		}

		protected function resizeIconMouseOutHandler(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.AUTO;
		}

		protected function resizeIconMouseDownHandler(e:MouseEvent):void {
			bringToTop();
			var myForm:DisplayObjectContainer = focusManager.form;
			myForm.addEventListener(MouseEvent.MOUSE_MOVE, doDrag, false, 0, true);
			myForm.addEventListener(MouseEvent.MOUSE_UP, resizeIconReleaseHandler, false, 0, true);
			Mouse.cursor = RESIZE_CURSOR;
		}
		
		protected function resizeIconReleaseHandler(e:MouseEvent):void {
			var myForm:DisplayObjectContainer = focusManager.form;
			myForm.removeEventListener(MouseEvent.MOUSE_MOVE, doDrag);
			myForm.removeEventListener(MouseEvent.MOUSE_UP, resizeIconReleaseHandler);
			Mouse.cursor = MouseCursor.AUTO;
			frame.graphics.clear();
			var xRight:Number = clipX(e.stageX + view.scrollPaneDx);
			var xBottom:Number = clipY(e.stageY + view.scrollPaneDy);
			super.setSize(xRight - xPos + iconWidth, xBottom - yTop + iconHeight);
			resizeDone();
		}

		protected function doDrag(e:MouseEvent):void {
			Mouse.cursor = RESIZE_CURSOR;
			var xRight:Number = clipX(e.stageX + view.scrollPaneDx);
			var xBottom:Number = clipY(e.stageY + view.scrollPaneDy);
			drawHelperFrame(xRight, xBottom);
			resizeIcon.x = xRight;
			resizeIcon.y = xBottom;
		}

		protected function drawHelperFrame(xRight:Number, yBottom:Number):void {
			frame.graphics.clear();
			frame.graphics.lineStyle(1, WaterConsts.BLUE_COLOR, 1,
															 false, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.MITER, 1);
			frame.graphics.drawRect(xPos, yTop, xRight - xPos + iconWidth, yBottom - yTop + iconHeight);
		}
		
		protected function clipValue(value:Number, min:Number, max:Number):Number {
			var ret:Number = value;
			if (ret < min)
				ret = min;
			else if (ret > max)
			  ret = max;
			return ret;
		}
		
		protected function clipX(x:Number):Number {
			var game:WaterGame = root as WaterGame;
			var sbWidth:Number = 0;
			if (game && game.sp.verticalScrollBar.visible)
				sbWidth = ScrollBar.WIDTH;
			return clipValue(x, xPos + this.minWidth - iconWidth, stage.stageWidth + view.scrollPaneDx - sbWidth - iconWidth - 1);
		}
	
		protected function clipY(y:Number):Number {
			var game:WaterGame = root as WaterGame;
			var sbWidth:Number = 0;
			if (game && game.sp.horizontalScrollBar.visible)
				sbWidth = ScrollBar.WIDTH;
			return clipValue(y, yTop + this.minHeight - iconHeight, stage.stageHeight + view.scrollPaneDy - sbWidth - iconHeight - 1);
		}
	
		protected function createResizeCursor():void {
			//Graphics path data for a resize arrow
      var cursorPoints:Vector.<Number> = new <Number>[0,0, 5.5,0, 4,1.5, 14,11.5, 15.5,9.5, 15.5,15.5, 9.5,15.5, 11.5,14, 1.5,4, 0,5.5, 0,0];
      var cursorDrawCommands:Vector.<int> = new <int>[1,2,2,2,2,2,2,2,2,2,2];
        
      var mouseCursorData:MouseCursorData = new MouseCursorData();
      var cursorData:Vector.<BitmapData> = new Vector.<BitmapData>();
      var cursorShape:Shape = new Shape();
      cursorShape.graphics.lineStyle(1);
			cursorShape.graphics.beginFill(WaterConsts.WHITE_COLOR);
      cursorShape.graphics.drawPath(cursorDrawCommands, cursorPoints);
			cursorShape.graphics.endFill();
      var cursorFrame:BitmapData = new BitmapData(16, 16, true, 0);
      cursorFrame.draw(cursorShape);
			cursorData.push(cursorFrame);
			mouseCursorData.data = cursorData;
			mouseCursorData.frameRate = 1;
			mouseCursorData.hotSpot = new Point(7, 7);
            
      Mouse.registerCursor(RESIZE_CURSOR, mouseCursorData);
		}
	}
}