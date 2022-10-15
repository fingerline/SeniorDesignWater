package code {

  import flash.display.*;
	import flash.events.*;
	import fl.controls.*;
	import flash.text.*;

	// Minimum Flow Requirement (mfr)
  public class WaterViewMfr extends WaterViewPopup {
		
		private const MFR_LABEL_X:Number = 10;
		private const MFR_TEXTFIELD_X:Number = 250;
		private const MFR_TEXTFIELD_WIDTH:Number = 150;
		private const MFR_Y:Number = 65;
		
		private var data:WaterData;
		
		private var mfrTF:TextField;

    public function WaterViewMfr(data:WaterData,
																 x:Number, y:Number,
																 w:Number, h:Number) {
			super(x, y, w, h, WaterConsts.MINIMUM_FLOW_REQUIREMENT_NAME);
			this.data = data;
    }

    override protected function setupChildrenHandling():void {
			setupMfrTF();
			setupButtons();
		}
		
		override protected function closeBtnClickedHandling():void {
			dispatchEvent(new WaterEvent(WaterEvent.REMOVE_VIEW_MFR, true));
		}
		
		private function setupMfrTF():void {
			WaterUtils.setupTextFieldR2(box,
																	WaterConsts.MINIMUM_FLOW_REQUIREMENT_ACFT_NAME,
																	xPos + MFR_LABEL_X, yPos + MFR_Y,
																	MFR_TEXTFIELD_X - MFR_LABEL_X, COMBOBOX_HEIGHT,
																	12, true);
			mfrTF = WaterUtils.setupTextFieldR3(box,
																	xPos + MFR_TEXTFIELD_X + 20, yPos + MFR_Y,
																	MFR_TEXTFIELD_WIDTH, COMBOBOX_HEIGHT,
																	12, true);
			mfrTF.type = TextFieldType.INPUT;
			mfrTF.selectable = true;
			mfrTF.restrict = "0-9";
			mfrTF.text = String(data.mfrValue);
			stage.focus = mfrTF;
			mfrTF.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		}
		
		private function keyDownHandler(e:KeyboardEvent):void {
			if (e.keyCode == 13)
				submitBtnClicked(null);
    }

		private function setupButtons():void {
			var submit:Button = new WaterButton();
			submit.label = WaterConsts.SUBMIT_NAME;
			submit.move(xPos + rectW - 110, yPos + rectH - 40);
			submit.setSize(80, 22);
			submit.addEventListener(MouseEvent.CLICK, submitBtnClicked, false, 0, true);
			box.addChild(submit);
		}
		
		private function submitBtnClicked(e:MouseEvent):void {
			data.mfrValue = Number(mfrTF.text);
			data.updateItems();
			dispatchEvent(new WaterEvent(WaterEvent.UPDATE_VIEWS, true));
			super.closeBtnClicked(null);
		}
		
  }
}