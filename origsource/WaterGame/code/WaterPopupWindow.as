package code {

  import flash.display.*;
	import flash.events.*;
	import fl.controls.Button;
	import flash.geom.*;

  public class WaterPopupWindow extends Sprite {
		
		private var xPos:Number;
		private var yPos:Number;
		private var rectW:Number;
		private var rectH:Number;
		
		private var box:Sprite;
		private var closeBtn:Button;

    public function WaterPopupWindow(x:Number, y:Number,
																		 w:Number, h:Number) {
			xPos = x;
			yPos = y;
			rectW = w;
			rectH = h;
			addEventListener(Event.ADDED, setupChildren, false, 0, true);
    }

    private function setupChildren(e:Event):void {
			removeEventListener(Event.ADDED, setupChildren);

			setupBox();
		}
		
		private function setupBox():void {
			dispatchEvent(new WaterEvent(WaterEvent.ADD_GRAY_BKGD, true));
			
			box = new Sprite();
			var colors:Array = new Array(WaterConsts.WHITE_COLOR, WaterConsts.LIGHT_GRAY_COLOR);
			var alphas:Array = new Array(1, 1);
			var ratios:Array = new Array(0, 125);
			var mat:Matrix = new Matrix();
			
			mat.createGradientBox(rectW, rectH, (Math.PI/2), xPos, yPos);
			box.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, mat);
			box.graphics.drawRoundRect(xPos, yPos, rectW, rectH, 25, 25);
			box.graphics.endFill();
			
			this.closeBtn = new Button();
			closeBtn.label = "X";
			closeBtn.setSize(20, 20);
			closeBtn.move(xPos + rectW - 25, yPos + 5);
			closeBtn.addEventListener(MouseEvent.CLICK, buttonClicked, false, 0, true);
			box.addChild(closeBtn);
			
			stage.addChild(box);
		}
		
		private function buttonClicked(e:MouseEvent):void {
			stage.removeChild(box);
			dispatchEvent(new WaterEvent(WaterEvent.REMOVE_GRAY_BKGD, true));
		}
  }
}