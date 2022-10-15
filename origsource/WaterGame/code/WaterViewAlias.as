package code {

  import flash.display.*;
	import flash.events.*;
	import fl.controls.*;
	import flash.geom.*;
	import fl.data.*;
	import flash.text.*;

  public class WaterViewAlias extends WaterViewPopup {
		
		private const ALIAS_LABEL_X:Number = 0;
		private const ALIAS_TEXTFIELD_X:Number = 40;
		private const ALIAS_TEXTFIELD_WIDTH:Number = 150;
		private const ALIAS_Y:Number = 45;
		
		private var data:WaterDataPositionItem;
		
		private var aliasTF:TextField;

    public function WaterViewAlias(data:WaterDataPositionItem,
																	 x:Number, y:Number,
																	 w:Number, h:Number,
																	 title:String) {
			this.data = data;
			super(x, y, w, h, title);
    }

    override protected function setupChildrenHandling():void {
			setupPointsTF();
			setupButtons();
		}
		
		override protected function closeBtnClickedHandling():void {
			dispatchEvent(new WaterEvent(WaterEvent.REMOVE_VIEW_ALIAS, true));
		}
		
		private function setupPointsTF():void {
			WaterUtils.setupTextFieldR2(box, WaterConsts.ALIAS_NAME,
																	xPos + ALIAS_LABEL_X, yPos + ALIAS_Y,
																	ALIAS_TEXTFIELD_X - ALIAS_LABEL_X, COMBOBOX_HEIGHT,
																	12, true);
			aliasTF = WaterUtils.setupTextFieldL1(box,
																	xPos + ALIAS_TEXTFIELD_X, yPos + ALIAS_Y,
																	ALIAS_TEXTFIELD_WIDTH, COMBOBOX_HEIGHT,
																	12, true);
			if (!data.emptyAlias())
				aliasTF.text = data.alias;
			aliasTF.autoSize = TextFieldAutoSize.NONE;
			aliasTF.border = true;
			aliasTF.type = TextFieldType.INPUT;
			aliasTF.selectable = true;
			aliasTF.maxChars = 10;
			stage.focus = aliasTF;
			aliasTF.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, false, 0, true);
			
			WaterUtils.setupTextFieldL1(box,
																	xPos + ALIAS_TEXTFIELD_X, yPos + ALIAS_Y + COMBOBOX_HEIGHT + 2,
																	ALIAS_TEXTFIELD_WIDTH, COMBOBOX_HEIGHT,
																	11, false).text = "Maximum 10 characters.";
		}
		
		private function keyDownHandler(e:KeyboardEvent):void {
			if (e.keyCode == 13)
				opBtnClicked(null);
    }

		private function setupButtons():void {
			var opBtn:Button = new WaterButton();
			opBtn.label = data.emptyAlias() ? WaterConsts.ADD_NAME : WaterConsts.CHANGE_NAME;
			opBtn.move(xPos + rectW - 67, yPos + rectH - 29);
			opBtn.setSize(60, 22);
			opBtn.addEventListener(MouseEvent.CLICK, opBtnClicked, false, 0, true);
			box.addChild(opBtn);
		}
		
		private function opBtnClicked(e:MouseEvent):void {
			data.alias = aliasTF.text;
			dispatchEvent(new WaterEvent(WaterEvent.UPDATE_ALIAS, true));
			super.closeBtnClicked(null);
		}
  }
}