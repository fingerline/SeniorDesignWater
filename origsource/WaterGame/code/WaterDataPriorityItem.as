package code {

  public class WaterDataPriorityItem {

		// these variables are defined to match the first table of excel data file;
    private var _positionFromSource:int;
		private var _priorityDate:String;
		private var _useCategory:String;
		private var _requestedWithdraw:Number;
		private var _percentConsumptive:Number;
		private var _priorityWithdraw:Number;
		private var _priorityConsumed:Number;
		private var _partialRemaining:Number;
		private var _returnFlow:Number;
		private var _totalRemaining:Number;
		// for display purpose, not involved in calculation;
		private var _playerNumber:int;
		private var _name:String;
		
		private var previousItem:WaterDataPriorityItem;
		private var waterData:WaterData;

    public function WaterDataPriorityItem(positionFromSource:int,
																					priorityDate:String,
																					useCategory:String,
																					requestedWithdraw:Number,
																					percentConsumptive:Number,
																					name:String,
																					previousItem:WaterDataPriorityItem,
																					waterData:WaterData) {
			this._positionFromSource = positionFromSource;
			this._priorityDate = priorityDate;
			this._useCategory = useCategory;
			this._requestedWithdraw = requestedWithdraw;
			this._percentConsumptive = percentConsumptive;
			this._name = name;
			this._playerNumber = int(priorityDate.substring(0, priorityDate.indexOf("-")));
			this.previousItem = previousItem;
			this.waterData = waterData;
		}

		public function get name():String {
			return _name;
		}
		
		// column A;
    public function get positionFromSource():int {
			return _positionFromSource;
		}
		
		// column B;
		public function get priorityDate():String {
			return _priorityDate;
		}
		
		// column C;
		public function get useCategory():String {
			return _useCategory;
		}
		
		// column D;
		public function get requestedWithdraw():Number {
			return _requestedWithdraw;
		}
		
		// column E;
		public function get percentConsumptive():Number {
			return _percentConsumptive;
		}

		// column G; - calculated in updateRemainingVars();
		public function get priorityWithdraw():Number {
			return _priorityWithdraw;
		}

		// column H; - calculated in updateRemainingVars();
		public function get priorityConsumed():Number {
			return _priorityConsumed;
		}

		// column I; - calculated in updateRemainingVars();
		public function get partialRemaining():Number {
			return _partialRemaining;
		}
		
		// column J; - calculated in updateRemainingVars();
		public function get returnFlow():Number {
			return _returnFlow;
		}

		// column K; - calculated in updateRemainingVars();
		public function get totalRemaining():Number {
			return _totalRemaining;
		}

    public function get playerNumber():Number {
			return _playerNumber;
		}
		
		public function updateRemainingVars():void {
			// the order of execution is important;
			_priorityWithdraw = (previousItem == null) ? 
				Math.max(0, Math.min(_requestedWithdraw, waterData.runoff - waterData.minFlowRequirement())) :
				Math.max(0, Math.min(_requestedWithdraw, previousItem.totalRemaining - waterData.minFlowRequirement()));
			//                     column E        *  column G
			_priorityConsumed = _percentConsumptive * _priorityWithdraw / 100.0;
			_partialRemaining = (previousItem == null) ?
				Math.max(0, waterData.runoff - _priorityWithdraw) :
				Math.max(0, previousItem.totalRemaining - _priorityWithdraw);
			_returnFlow = Math.max(0, _priorityWithdraw - _priorityConsumed);
			//                     column I     +  column J
			_totalRemaining = _partialRemaining + _returnFlow;
		}
		
		public function dump():String {
			var ret:String = new String();
			ret +=  _positionFromSource + " " + _priorityDate + " " + _useCategory + " " +
			        _requestedWithdraw + " " + _percentConsumptive + " " + _priorityWithdraw + " " +
							_priorityConsumed + " " + _partialRemaining + " " + _returnFlow + " " +
							_totalRemaining;
			return ret;
		}
  }
}