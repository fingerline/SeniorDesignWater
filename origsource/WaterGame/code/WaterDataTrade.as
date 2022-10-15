package code {
	
  public class WaterDataTrade {

		private var _seller:WaterDataPositionItem;
		private var _buyer:WaterDataPositionItem;
		private var _amount:Number;
		private var _price:int;
		
		public function WaterDataTrade(seller:WaterDataPositionItem,
																	 buyer:WaterDataPositionItem,
																	 amount:Number,
																	 price:int) {
			this._seller = seller;
			this._buyer = buyer;
			this._amount = amount;
			this._price = price;
		}
		
		public function get seller():WaterDataPositionItem {
			return _seller;
		}
		
		public function get buyer():WaterDataPositionItem {
			return _buyer;
		}
		
		public function amount(trader:WaterDataPositionItem):Number {
			if (trader == seller)
				return 0 - _amount;
			else if (trader == buyer)
			  return _amount;
			else
				return 0;
		}
		
		public function get price():int {
			return _price;
		}
	}
}