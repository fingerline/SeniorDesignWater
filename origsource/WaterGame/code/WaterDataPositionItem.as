package code {

  public class WaterDataPositionItem {

    private var _position:int;
		// _usePoints depends on the useCategory;
		private var _usePoints:Number;
		private var _damPoints:Number;
		private var _agreedPrice:Number;
		private var priorityItem:WaterDataPriorityItem;
		private var _riverInputFlow:Number;
		private var _waterWithdrawn:Number;
		private var _riverRemaining:Number;
		private var _waterConsumed:Number;
		private var _returnFlow:Number;
		private var _riverOutputFlow:Number;
		private var _riverPointsAfterTrade:Number;
		private var _riverPointsAfterTradeAndDam:Number;
		private var _personalPoints:Number;

		private var previousItem:WaterDataPositionItem;
		private var waterData:WaterData;
		private var tradeData:Vector.<WaterDataTrade>;
		
		private var _alias:String;

    public function WaterDataPositionItem(position:int,
																					usePoints:Number,
																					priorityItem:WaterDataPriorityItem,
																					previousItem:WaterDataPositionItem,
																					waterData:WaterData) {
			this._position = position;
			this._usePoints = usePoints;
			this._damPoints = 0;
			this._agreedPrice = 0;
			this.priorityItem = priorityItem;
			this.previousItem = previousItem;
			this.waterData = waterData;
			resetTradeData();
		}
		
		public function name():String {
			return priorityItem.name;
		}
		
		public function playerNumber():int {
			return priorityItem.playerNumber;
		}
		
		// column R;
		public function get position():int {
			return _position;
		}
		
		// column S;
		public function priorityDate():String {
			return priorityItem.priorityDate;
		}
		
		// column T;
		public function useCategory():String {
			return priorityItem.useCategory;
		}
		
		// column U;
		public function requestedWithdraw():Number {
			return priorityItem.requestedWithdraw;
		}

		// column V; - calculated in updateRemainingVars();
		public function get riverInputFlow():Number {
			return _riverInputFlow;
		}

		// column W;
		public function priorityWithdraw():Number {
			return priorityItem.priorityWithdraw;
		}
		
		// based on water in river;
		// column X; - calculated in updateRemainingVars();
		public function get waterWithdrawn():Number {
			return _waterWithdrawn;
		}
		
		// column Y; - calculated in updateRemainingVars();
		public function get riverRemaining():Number {
			return _riverRemaining;
		}
		
		// column Z;
		public function priorityConsumed():Number {
			return priorityItem.priorityConsumed;
		}
		
		// based on water in river;
		// column AA; - calculated in updateRemainingVars();
		public function get waterConsumed():Number {
			return _waterConsumed;
		}
		
		// based on water in river;
		// column AC; - calculated in updateRemainingVars();
		public function get returnFlow():Number {
			return _returnFlow;
		}
		
		// column AD; - calculated in updateRemainingVars();
		public function get riverOutputFlow():Number {
			return _riverOutputFlow;
		}
		
		// column AE;
		public function get usePoints():Number {
			return _usePoints;
		}
		
		// column AF;
		public function pointsPossible():Number {
			//      column U           * column AE
			return requestedWithdraw() * usePoints;
		}
		
		// column AG; - calculated in updateRemainingVars();
		public function get riverPointsAfterTrade():Number {
			return _riverPointsAfterTrade;
		}
		
		// column AH;
		public function get damPoints():Number {
			return _damPoints;
		}
		public function set damPoints(value:Number):void {
			_damPoints = value;
		}
		
		// column AI; - calculated in updateRemainingVars();
		public function get riverPointsAfterTradeAndDam():Number {
			return _riverPointsAfterTradeAndDam;
		}
		
		// column AJ;
		public function waterTrade():Number {
			var ret:Number = 0;
			for (var i:uint = 0; i < this.tradeData.length; i++)
			  ret += this.tradeData[i].amount(this);
			return ret;
		}
		
		// column AK;
//		public function get agreedPrice():Number {
//			return _agreedPrice;
//		}
		
		// column AL; - calculated in updateRemainingVars();
		public function get personalPoints():Number {
			return _personalPoints;
		}

		public function addTradeData(trade:WaterDataTrade):void {
			this.tradeData.push(trade);
		}
		
		public function resetTradeData():void {
			this.tradeData = new Vector.<WaterDataTrade>();
		}
		
		public function updateRemainingVars():void {
			// the order of execution is important;
			//     column V                               T1               column AD
			_riverInputFlow = (previousItem == null) ? waterData.runoff :	previousItem.riverOutputFlow;
			//     column X                             column V  ,    column W        + column AJ
			_waterWithdrawn = Math.max(0, Math.min(_riverInputFlow, priorityWithdraw() + waterTrade()));
			//     column Y                 column V      -   column X
			_riverRemaining = Math.max(0, _riverInputFlow - _waterWithdrawn);
			//     column AA                                 * column X  
			_waterConsumed = priorityItem.percentConsumptive * _waterWithdrawn / 100.0;
			//  column AC       column X  -  column AA
			_returnFlow = _waterWithdrawn - _waterConsumed;
			//  column AD       column Y       +  column AC
			_riverOutputFlow = _riverRemaining + _returnFlow;
			//  column AG             column X        * column AE
			_riverPointsAfterTrade = _waterWithdrawn * usePoints;
			//  column AI                    column AG            -  column AH
			_riverPointsAfterTradeAndDam = _riverPointsAfterTrade - damPoints;
			var tradePoints:Number = 0;
			for (var i:uint = 0; i < this.tradeData.length; i++) {
				//                        pseudo column AJ    *  pseudo column AK
			  tradePoints += this.tradeData[i].amount(this) * this.tradeData[i].price;
			}
			//  column AL        column AI
			_personalPoints = _riverPointsAfterTradeAndDam - tradePoints;
		}
		
		public function dump():String {
			var ret:String = new String();
			ret +=  _position + " " + priorityDate() + " " + useCategory() + " " + requestedWithdraw() + " " +
			        _riverInputFlow + " " + priorityWithdraw() + " " + _waterWithdrawn + " " +
							_riverRemaining + " " + priorityConsumed() + " " + _waterConsumed + " " +
							_returnFlow + " " + _riverOutputFlow + " " + _usePoints + " " +
							_riverPointsAfterTrade + " " + _damPoints + " " + _riverPointsAfterTradeAndDam + " " +
							waterTrade() + " " + _agreedPrice + " " + _personalPoints;
      return ret;
		}
		
		public function get alias():String {
			return _alias;
		}
		public function set alias(value:String):void {
			_alias = value;
		}
		
		public function emptyAlias():Boolean {
			if (_alias != null && alias.length > 0)
				return false;
			else
				return true;
		}
  }
}