package code {

  import flash.display.*;
	import flash.events.*;
	import fl.controls.*;
	import flash.geom.*;
	import fl.data.*;
	import flash.text.*;

  public class WaterViewTrade extends WaterViewPopup {
		
		private const AMOUNT_WATER_WIDTH:Number = 180;
		private const SELLER_OFFSET_X:Number = 10;
		private const BUYER_OFFSET_X:Number = 110;
		private const AMOUNT_WATER_OFFSET_X:Number = 210;
		private const PRICE_OFFSET_X:Number = 410;
		
		private var data:WaterData;
		
		private var buyerCB:WaterComboBox;
		private var sellerCB:WaterComboBox;
		private var priceCB:WaterComboBox;
		private var amountTF:TextField;
		private var amountLimitTF:TextField;
		private var amountLimit:Number;
		private var buyer:WaterDataPositionItem;
		private var seller:WaterDataPositionItem;
		private var price:int;

    public function WaterViewTrade(data:WaterData,
																	 x:Number, y:Number,
																	 w:Number, h:Number) {
			super(x, y, w, h, WaterConsts.TRADING_NAME);
			this.data = data;
			amountLimit = 0;
			price = 0;
    }

    override protected function setupChildrenHandling():void {
			setupComboBoxes();
			setupAmountTFetc();
			setupTradeButton();
		}
		
		override protected function closeBtnClickedHandling():void {
			dispatchEvent(new WaterEvent(WaterEvent.REMOVE_VIEW_TRADE, true));
		}
		
		private function setupComboBoxes():void {
			buyerCB = new WaterComboBox();
			buyerCB.move(xPos + BUYER_OFFSET_X, yPos + COMBOBOX_OFFSET_Y);
			buyerCB.setSize(COMBOBOX_WIDTH, COMBOBOX_HEIGHT);
			buyerCB.prompt = "Buyer";
			var dp:DataProvider = new DataProvider();
			for (var i:uint = 0; i < data.sortedPositionItems.length; i++) {
				dp.addItem({label:data.sortedPositionItems[i].priorityDate(), data:this.data.sortedPositionItems[i]});
			}
			buyerCB.dataProvider = dp;
			buyerCB.rowCount = 10;
      buyerCB.addEventListener(Event.CHANGE, buyerChanged, false, 0, true);
			box.addChild(buyerCB);
			
			sellerCB = new WaterComboBox();
			sellerCB.move(xPos + SELLER_OFFSET_X, yPos + COMBOBOX_OFFSET_Y);
			sellerCB.setSize(COMBOBOX_WIDTH, COMBOBOX_HEIGHT);
			sellerCB.prompt = "Seller";
			sellerCB.dataProvider = dp;
			sellerCB.rowCount = 10;
      sellerCB.addEventListener(Event.CHANGE, sellerChanged, false, 0, true);
			box.addChild(sellerCB);
			
			priceCB = new WaterComboBox();
			priceCB.move(xPos + PRICE_OFFSET_X, yPos + COMBOBOX_OFFSET_Y);
			priceCB.setSize(COMBOBOX_WIDTH, COMBOBOX_HEIGHT);
			priceCB.prompt = "Price";
			var dpPrice:DataProvider = new DataProvider();
			for (var j:int = 1; j <= 10; j++) {
				dpPrice.addItem({label:String(j), data:j});
			}
			priceCB.dataProvider = dpPrice;
      priceCB.addEventListener(Event.CHANGE, priceChanged, false, 0, true);
			box.addChild(priceCB);
		}
		
		private function buyerChanged(e:Event):void {
			if (errorTF.visible == true && errorTF.text.search("Buyer") != -1)
				errorTF.visible = false;
			buyer = buyerCB.selectedItem.data;
			if (seller != null)
				showAmountLimit();
		}
		
		private function sellerChanged(e:Event):void {
			if (errorTF.visible == true && errorTF.text.search("Seller") != -1)
				errorTF.visible = false;
			seller = sellerCB.selectedItem.data;
			if (buyer != null)
				showAmountLimit();
		}
		
		private function showAmountLimit():void {
			//                                  buyer column U         -   buyer column X  ,  seller column X
			amountLimit = Math.round(Math.min(buyer.requestedWithdraw() - buyer.waterWithdrawn, seller.waterWithdrawn));
			amountLimitTF.text = "The limit is " + String(amountLimit);
		}
		
		private function priceChanged(e:Event):void {
			if (errorTF.visible == true && errorTF.text.search("Price") != -1)
				errorTF.visible = false;
			price = priceCB.selectedItem.data;
		}
		
		private function setupAmountTFetc():void {
			WaterUtils.setupTextFieldC2(box, "Seller",
																	xPos + SELLER_OFFSET_X, yPos + TEXT_OFFSET_Y,
																	COMBOBOX_WIDTH, COMBOBOX_HEIGHT,
																	12, true);
			WaterUtils.setupTextFieldC2(box, "Buyer",
																	xPos + BUYER_OFFSET_X, yPos + TEXT_OFFSET_Y,
																	COMBOBOX_WIDTH, COMBOBOX_HEIGHT,
																	12, true);
			WaterUtils.setupTextFieldC2(box, "Amount of water to trade (ac-ft)",
																	xPos + AMOUNT_WATER_OFFSET_X, yPos + TEXT_OFFSET_Y,
																	AMOUNT_WATER_WIDTH, COMBOBOX_HEIGHT,
																	12, true);
			amountTF = WaterUtils.setupTextFieldR3(box,
																	xPos + AMOUNT_WATER_OFFSET_X, yPos + COMBOBOX_OFFSET_Y,
																	AMOUNT_WATER_WIDTH, COMBOBOX_HEIGHT,
																	12, true);
			amountTF.type = TextFieldType.INPUT;
			amountTF.selectable = true;
			amountTF.restrict = "0-9";
			amountLimitTF = WaterUtils.setupTextFieldR4(box,
																	xPos + AMOUNT_WATER_OFFSET_X, yPos + COMBOBOX_OFFSET_Y + COMBOBOX_HEIGHT,
																	AMOUNT_WATER_WIDTH, COMBOBOX_HEIGHT,
																	12, false);
			WaterUtils.setupTextFieldC2(box, "Price",
																	xPos + PRICE_OFFSET_X, yPos + TEXT_OFFSET_Y,
																	COMBOBOX_WIDTH, COMBOBOX_HEIGHT,
																	12, true);
		}
		
		private function setupTradeButton():void {
			var trade:Button = new WaterButton();
			trade.label = WaterConsts.TRADE_NAME + "!";
			trade.move(xPos + rectW - 90, yPos + rectH - 40);
			trade.setSize(80, 22);
			trade.addEventListener(MouseEvent.CLICK, tradeBtnClicked, false, 0, true);
			box.addChild(trade);
		}
		
		private function tradeBtnClicked(e:MouseEvent):void {
			var amount:Number = Number(amountTF.text);
			if (seller == null) {
				errorTF.text = "Please select a Seller!";
				errorTF.visible = true;
				return;
			}
			if (buyer == null) {
				errorTF.text = "Please select a Buyer!";
				errorTF.visible = true;
				return;
			}
			if (buyer == seller) {
				errorTF.text = "The Buyer can not be the Seller!";
				errorTF.visible = true;
				return;
			}
			if (amount == 0) {
				errorTF.text = "Please type in the amount of water to trade!";
				errorTF.visible = true;
				return;
			}
			if (amount > amountLimit) {
				errorTF.text = "The amount of water to trade exceeds the limit of " + String(amountLimit) + ".";
				errorTF.visible = true;
				return;
			}
			if (price == 0) {
				errorTF.text = "Please select a Price!";
				errorTF.visible = true;
				return;
			}
			if (amount * price > buyer.pointsPossible()) {
				errorTF.text = "The buyer cannot afford this trade.\nPlease lower the amount of trade water or the Price.";
				errorTF.visible = true;
				return;
			}
			if (errorTF.visible) {
				errorTF.text = "";
				errorTF.visible = false;
			}
			this.data.addTradeData(new WaterDataTrade(seller, buyer, amount, price));
			data.updatePositionItems();
			dispatchEvent(new WaterEvent(WaterEvent.UPDATE_TRADING_INFO, true));
			// reset all the contents;
			buyerCB.selectedIndex = -1;
			buyer = null;
			sellerCB.selectedIndex = -1;
			seller = null;
			priceCB.selectedIndex = -1;
			price = 0;
			amountTF.text = "";
			amountLimitTF.text = "";
			amountLimit = 0;
		}
  }
}