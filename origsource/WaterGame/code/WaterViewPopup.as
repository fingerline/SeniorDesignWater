package code {

  import flash.display.*;
	import flash.events.*;
	import fl.controls.*;
	import flash.geom.*;
	import flash.text.*;

  public class WaterViewPopup extends Sprite {
		
		protected const COMBOBOX_OFFSET_Y:Number = 70;
		protected const COMBOBOX_WIDTH:Number = 80;
		protected const COMBOBOX_HEIGHT:Number = 20;
		protected const TEXT_OFFSET_Y:Number = 50;
		
		protected var xPos:Number;
		protected var yPos:Number;
		protected var rectW:Number;
		protected var rectH:Number;
		protected var title:String;
		
		protected var box:WaterDragSprite;
		protected var closeBtn:Button;
		protected var errorTF:TextField;

    public function WaterViewPopup(x:Number, y:Number,
																	 w:Number, h:Number,
																	 title:String) {
			this.xPos = x;
			this.yPos = y;
			this.rectW = w;
			this.rectH = h;
			this.title = title;
			
			addEventListener(Event.ADDED, setupChildren, false, 0, true);
    }

    private function setupChildren(e:Event):void {
			removeEventListener(Event.ADDED, setupChildren);

			setupBox();
			setupChildrenHandling();
		}
		
		protected function setupBox():void {
			dispatchEvent(new WaterEvent(WaterEvent.ADD_GRAY_BKGD, true));
			
			box = new WaterDragSprite();
			
			var colors:Array = new Array(WaterConsts.WHITE_COLOR, WaterConsts.POPUP_BG_COLOR);
			var alphas:Array = new Array(1, 1);
			var ratios:Array = new Array(0, 255);
			var mat:Matrix = new Matrix();
			
			mat.createGradientBox(rectW, rectH, (Math.PI/2), xPos, yPos);
			box.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, mat);
			box.graphics.drawRoundRect(xPos, yPos, rectW, rectH, 25, 25);
			box.graphics.endFill();
			
			WaterUtils.setupTextFieldL2(box, title,
																	xPos + 8, yPos + 8, 100, 30,
																	12, true);
																	
			var line:Sprite = new Sprite();
			line.graphics.lineStyle(1, WaterConsts.BLACK_COLOR, 1,
														 false, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.MITER, 1);
			line.graphics.moveTo(xPos + 5, yPos + 32);
			line.graphics.lineTo(xPos + this.rectW - 5, yPos + 32);
			box.addChild(line);
			
			this.closeBtn = new Button();
			closeBtn.label = "X";
			closeBtn.setSize(20, 20);
			closeBtn.move(xPos + rectW - 25, yPos + 5);
			closeBtn.addEventListener(MouseEvent.CLICK, closeBtnClicked, false, 0, true);
			box.addChild(closeBtn);
			
			errorTF = WaterUtils.setupTextFieldL1(box,
																	xPos + 5, yPos + rectH - 40,
																	400, 20,
																	12, true);
			errorTF.visible = false;
			errorTF.textColor = WaterConsts.RED_COLOR;
			
			stage.addChild(box);
		}
		
		protected function closeBtnClicked(e:MouseEvent):void {
			stage.removeChild(box);
			dispatchEvent(new WaterEvent(WaterEvent.REMOVE_GRAY_BKGD, true));
			closeBtnClickedHandling();
		}
		
		// The child classes will implement the following functions if necessary;
    protected function setupChildrenHandling():void {
		}
		
		protected function closeBtnClickedHandling():void {
		}
		
  }
}