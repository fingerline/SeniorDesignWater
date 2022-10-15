package code {

  import flash.display.*;
	import flash.events.*;
	import fl.controls.*;
	import flash.geom.*;
	import fl.data.*;
	import flash.text.*;

  public class WaterViewDamStore extends WaterViewPopup {
		
		private const AMOUNT_WIDTH:Number = 150;
		private const AMOUNT_X:Number = 180;
		private const STORE_X:Number = 20;
		private const STORE_WIDTH:Number = 120;
		private const BUTTON_X:Number = 370;
		private const BUTTON_WIDTH:Number = 110;
		
		private var data:WaterData;
		
		private var storeCB:WaterComboBox;
		private var amountTF:TextField;
		private var limitTF:TextField;
		private var limit:Number;
		private var storeBtn:WaterButton;

    public function WaterViewDamStore(data:WaterData,
																	 x:Number, y:Number,
																	 w:Number, h:Number) {
			super(x, y, w, h, WaterConsts.STORE_OR_RELEASE_WATER_NAME);
			this.data = data;
			this.data.waterOperation = WaterEnumOperation.INITIAL;
			this.limit = 0;
    }

    override protected function setupChildrenHandling():void {
			setupComboBox();
			setupAmountTF();
			setupButtons();
		}
		
		override protected function closeBtnClickedHandling():void {
			dispatchEvent(new WaterEvent(WaterEvent.REMOVE_VIEW_DAM_STORE, true));
		}
		
		private function setupComboBox():void {
			// combobox title;
			var prompt:String = "Operation";
			WaterUtils.setupTextFieldC2(box, prompt,
																	xPos + STORE_X, yPos + TEXT_OFFSET_Y,
																	STORE_WIDTH, COMBOBOX_HEIGHT,
																	12, true);
			// combobox itself;
			storeCB = new WaterComboBox();
			storeCB.move(xPos + STORE_X, yPos + COMBOBOX_OFFSET_Y);
			storeCB.setSize(STORE_WIDTH, COMBOBOX_HEIGHT);
			storeCB.prompt = prompt;
			storeCB.addItem({ label:WaterConsts.STORE_WATER_NAME });
			storeCB.addItem({ label:WaterConsts.RELEASE_WATER_NAME });
			storeCB.addItem({ label:WaterConsts.NONE_AT_THIS_TIME_NAME });
      storeCB.addEventListener(Event.CHANGE, selectionChanged, false, 0, true);
			box.addChild(storeCB);
			
		}
		
		private function selectionChanged(e:Event):void {
			if (errorTF.visible == true)
				errorTF.visible = false;
			var selectItem:String = storeCB.selectedLabel;
			if (selectItem == WaterConsts.STORE_WATER_NAME) {
				showLimit(true);
				storeBtn.label = "Store";
			}
			else if (selectItem == WaterConsts.RELEASE_WATER_NAME) {
				showLimit(false);
				storeBtn.label = "Release";
			}
			else if (selectItem == WaterConsts.NONE_AT_THIS_TIME_NAME) {
				this.operateAndUpdateView(false, Number.NaN);
				return;
			}
			stage.focus = amountTF;
		}
		
		private function showLimit(storeWater:Boolean):void {
			if (storeWater)
				limit = Math.round(Math.min(data.damCapacity - data.damReservoir, data.runoff));
			else
				limit = Math.round(Math.min(data.damReservoir, Math.max(WaterConsts.MAX_RUNOFF - data.runoff, 0)));
			limitTF.text = "The limit is " + String(limit);
		}
		
		private function setupAmountTF():void {
			WaterUtils.setupTextFieldC2(box, WaterConsts.WATER_AMOUNT_NAME,
																	xPos + AMOUNT_X, yPos + TEXT_OFFSET_Y,
																	AMOUNT_WIDTH, COMBOBOX_HEIGHT,
																	12, true);
			amountTF = WaterUtils.setupTextFieldR3(box,
																	xPos + AMOUNT_X, yPos + COMBOBOX_OFFSET_Y,
																	AMOUNT_WIDTH, COMBOBOX_HEIGHT,
																	12, true);
			amountTF.type = TextFieldType.INPUT;
			amountTF.selectable = true;
			amountTF.restrict = "0-9";
			limitTF = WaterUtils.setupTextFieldR4(box,
																	xPos + AMOUNT_X, yPos + COMBOBOX_OFFSET_Y + COMBOBOX_HEIGHT,
																	AMOUNT_WIDTH, COMBOBOX_HEIGHT,
																	12, false);
		}
		
		private function setupButtons():void {
			storeBtn = new WaterButton();
			storeBtn.label = "Store or release";
			storeBtn.move(xPos + BUTTON_X, yPos + COMBOBOX_OFFSET_Y);
			storeBtn.setSize(BUTTON_WIDTH, 22);
			storeBtn.addEventListener(MouseEvent.CLICK, storeBtnClicked, false, 0, true);
			box.addChild(storeBtn);
		}
		
		private function storeBtnClicked(e:MouseEvent):void {
			if (storeCB.selectedIndex < 0) {
				errorTF.text = "Please select an operation!";
				errorTF.visible = true;
				return;
			}
			var amount:Number = Number(amountTF.text);
			if (amount > limit) {
				errorTF.text = "The amount exceeds the limit of " + String(limit) + ".";
				errorTF.visible = true;
				return;
			}
			if (errorTF.visible) {
				errorTF.text = "";
				errorTF.visible = false;
			}
			this.operateAndUpdateView(true, amount);
		}
		
		private function operateAndUpdateView(updateDamStore:Boolean, amount:Number):void {
			if (storeCB.selectedLabel == WaterConsts.STORE_WATER_NAME)
				data.storeWater(amount);
			else if (storeCB.selectedLabel == WaterConsts.RELEASE_WATER_NAME)
				data.releaseWater(amount);
			else if (storeCB.selectedLabel == WaterConsts.NONE_AT_THIS_TIME_NAME)
				data.waterOperation = WaterEnumOperation.NONE_AT_THIS_TIME;
			if (updateDamStore) {
				dispatchEvent(new WaterEvent(WaterEvent.UPDATE_DAM_STORE, true));
			}
			data.updateRunoff();
			dispatchEvent(new WaterEvent(WaterEvent.UPDATE_VIEWS, true));
			super.closeBtnClicked(null);
		}
		
  }
}