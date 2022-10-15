package code {

  import flash.errors.IllegalOperationError;
	
  public class WaterData {
		
		private const INITIAL_RUNOFF:Number = 7000;
		
		// acre-feet;
    private var _runoff:Number;
		// minimum flow requirement value;
		private var _mfrValue:Number;
		// Build a dam check button (checked or unchecked);
		private var _damChecked:Boolean;
		// Trading check button (checked or unchecked);
		private var _tradingChecked:Boolean;
		private var _damCapacity:Number;
		private var _damReservoir:Number;
		private var _releaseWater:Number;
		private var _storeWater:Number;
		private var _year:int;
		private var _waterOperation:int;
		private var _isDamBuilt:Boolean;
		
		private var priorityItems:Vector.<WaterDataPriorityItem>;
		private var _positionItems:Vector.<WaterDataPositionItem>;
		private var _sortedPositionItems:Vector.<WaterDataPositionItem>;
		private var _tradeData:Vector.<WaterDataTrade>;
		private var _damData:Vector.<WaterDataDamPoints>;
		private var _scoreData:Vector.<WaterDataScore>;
		// The bench data does not have year info;
		private var _scoreBenchData:Vector.<WaterDataScore>;

    public function WaterData() {
			priorityItems = new Vector.<WaterDataPriorityItem>(30, true);
			_positionItems = new Vector.<WaterDataPositionItem>(30, true);
			newTradeData();
			newDamData();
			newScoreData();
			this.initSimpleVars();
			createPriorityItems();
			createPositionItems();
			createScoreBenchData();
//			trace(this.dumpPriorityItems());
//			trace("\n\n\n");
//			trace(this.dumpPositionItems(_positionItems));
//			trace("\n\n\n");
//			trace(this.dumpPositionItems(_sortedPositionItems));
		}
		
		private function initSimpleVars():void {
			_runoff = INITIAL_RUNOFF;
			_mfrValue = 0;
			_damChecked = false;
			_tradingChecked = false;
			_damCapacity = 0;
			_damReservoir = 0;
			_releaseWater = 0;
			_storeWater = 0;
			_year = 0;
			_waterOperation = WaterEnumOperation.INITIAL;
			_isDamBuilt = false;
		}
		
		public function get runoff():Number {
			return _runoff;
		}
		
		public function get year():int {
			return _year;
		}
		
		public function get positionItems():Vector.<WaterDataPositionItem> {
			return _positionItems;
		}
		// this list is sorted by the priority date ie player number;
		public function get sortedPositionItems():Vector.<WaterDataPositionItem> {
			return _sortedPositionItems;
		}
		
		public function get tradeData():Vector.<WaterDataTrade> {
			return _tradeData;
		}
		
		public function get damData():Vector.<WaterDataDamPoints> {
			return _damData;
		}
		
		public function get scoreData():Vector.<WaterDataScore> {
			return _scoreData;
		}
		
		public function get scoreBenchData():Vector.<WaterDataScore> {
			return _scoreBenchData;
		}
		
		public function minFlowRequirement():Number {
			return mfrValue;
		}
		
		public function get mfrValue():Number {
			return _mfrValue;
		}
		public function set mfrValue(value:Number):void {
			_mfrValue = value;
		}
		
		public function get tradingChecked():Boolean {
			return _tradingChecked;
		}
		public function set tradingChecked(value:Boolean):void {
			_tradingChecked = value;
		}
		
		public function get damChecked():Boolean {
			return _damChecked;
		}
		public function set damChecked(value:Boolean):void {
			_damChecked = value;
			if (value)
				tradingChecked = true;
		}
		
		public function get damCapacity():Number {
			return _damCapacity;
		}
		public function set damCapacity(value:Number):void {
			_damCapacity = value;
			_damReservoir = Math.min(_damReservoir, _damCapacity);
		}
		
		public function get damReservoir():Number {
			return _damReservoir;
		}
		
		public function storeWater(storeVolume:Number):void {
			_waterOperation = WaterEnumOperation.STORE;
			var oldReservoir:Number = _damReservoir;
			reserveWater(storeVolume);
			_storeWater = Math.min(storeVolume, _damReservoir - oldReservoir);
		}
		
		private function reserveWater(reserveVolume:Number):void {
			var reservoir:Number = _damReservoir + reserveVolume;
			_damReservoir = Math.max(0, Math.min(reservoir, _damCapacity));
		}
		
		public function releaseWater(value:Number):void {
			_waterOperation = WaterEnumOperation.RELEASE;
			_releaseWater = value;
			reserveWater(0 - value);
		}
		
		public function get waterOperation():int {
			return _waterOperation;
		}
		public function set waterOperation(value:int):void {
			_waterOperation = value;
		}
		
		public function set isDamBuilt(value:Boolean):void {
			this._isDamBuilt = value;
		}
		
		public function initializeRunoff(runoff:Number):void {
			_year++;
			cleanupTradeData();
			cleanupDamData(false);
			tradingChecked = false;
			if (isNaN(runoff))
				_runoff = WaterUtils.generateRandomNumber(5000, WaterConsts.MAX_RUNOFF);
			else
				_runoff = runoff;
			updateItems();
		}
		
		public function updateRunoff():void {
			if (waterOperation == WaterEnumOperation.RELEASE)
				_runoff += _releaseWater;
			else if (waterOperation == WaterEnumOperation.STORE)
				_runoff -= _storeWater;
			updateItems();
			var points:Number = this.totalPoints();
			if (_isDamBuilt && _year > 0 && points >= 0)
				this.addScoreData(new WaterDataScore(this._year, this._runoff, points));
		}
		
		public function updateItems():void {
			updatePriorityItems();
			updatePositionItems();
		}

		// sum of personal points of position items;
		// a.k.a Water Use Points;
		public function sumOfPersonalPoints():Number {
			var ret:Number = 0.0;
			for (var i:int = 0; i < WaterConsts.DATA_SIZE; i++) {
				ret += _positionItems[i].personalPoints;
			}
			return ret;
		}
		
		public function fishHabitatPoints():Number {
			return Math.min(10 * minRiverOutputFlow(), WaterConsts.MAX_RUNOFF);
		}
		
		public function totalPoints():Number {
			return sumOfPersonalPoints() + fishHabitatPoints();
		}

		public function findPositionItem(playerNumber:int):WaterDataPositionItem {
			for (var i:int = 0; i < WaterConsts.DATA_SIZE; i++) {
				if (_positionItems[i].playerNumber() == playerNumber)
					return _positionItems[i];
			}
			throw new IllegalOperationError("The WaterData class has internal data error with position items.");
		}
		
		public function addTradeData(trade:WaterDataTrade):void {
			this._tradeData.push(trade);
			trade.buyer.addTradeData(trade);
			trade.seller.addTradeData(trade);
		}
		
		public function addDamData(damPoints:WaterDataDamPoints):void {
			var player:WaterDataPositionItem;
			for (var i:uint = 0; i < _damData.length; i++) {
				player = _damData[i].player;
				if (player == damPoints.player) {
					player.damPoints += damPoints.points;
					_damData[i].points += damPoints.points;
					return;
				}
			}
			this._damData.push(damPoints);
			damPoints.player.damPoints = damPoints.points;
		}
		
		public function addScoreData(score:WaterDataScore):void {
			this._scoreData.push(score);
		}
		
		public function damPoints():Number {
			var ret:Number = 0;
			for (var i:uint = 0; i < _damData.length; i++) {
				ret += _damData[i].points;
			}
			return ret;
		}
		
		public function resetData():void {
			this.initSimpleVars();
			this.cleanupTradeData();
			this.cleanupDamData(true);
			this.newScoreData();
			this.updateItems();
		}
		
		private function createPriorityItems():void {
			var dataArr:Array = new Array();
			// [positionFromSource, priorityDate, useCategory, requestedWithdraw, percentConsumptive, name];
			dataArr[0]  = [16, "1-1803",  WaterConsts.USE_FARM_NAME,       100,  80, "Pueblo Farm"];
			dataArr[1]  = [23, "2-1810",  WaterConsts.USE_FARM_NAME,       200,  80, "Pueblo Farm"];
			dataArr[2]  = [15, "3-1817",  WaterConsts.USE_FARM_NAME,       100,  80, "Pueblo Farm"];
			dataArr[3]  = [9,  "4-1824",  WaterConsts.USE_MINING_NAME,     100,  10, "Spanish Gold Mine"];
			dataArr[4]  = [7,  "5-1831",  WaterConsts.USE_MINING_NAME,     300,  10, "Spanish Silver Mine"];
			dataArr[5]  = [24, "6-1838",  WaterConsts.USE_FARM_NAME,       100,  80, "Spanish Wheat Farm"];
			dataArr[6]  = [10, "7-1845",  WaterConsts.USE_FARM_NAME,       400,  80, "Spanish Cattle Ranch"];
			dataArr[7]  = [12, "8-1852",  WaterConsts.USE_FARM_NAME,       800,  80, "Spanish Bean Farm"];
			dataArr[8]  = [25, "9-1859",  WaterConsts.USE_FARM_NAME,       1400, 80, "Spanish Bean Farm"];
			dataArr[9]  = [28, "10-1866", WaterConsts.USE_FARM_NAME,       2000, 80, "Spanish Bean Farm"];
			dataArr[10] = [20, "11-1873", WaterConsts.USE_FARM_NAME,       500,  80, "Spanish Corn Farm"];
			dataArr[11] = [2,  "12-1881", WaterConsts.USE_MINING_NAME,     600,  10, "Spanish Copper Mine"];
			dataArr[12] = [8,  "13-1888", WaterConsts.USE_INDUSTRIAL_NAME, 200,  30, "Spanish Lumber Mill"];
			dataArr[13] = [19, "14-1895", WaterConsts.USE_FARM_NAME,       300,  80, "Spanish Cattle Ranch"];
			dataArr[14] = [4,  "15-1902", WaterConsts.USE_MINING_NAME,     400,  10, "Anglo Copper Mine"];
			dataArr[15] = [26, "16-1909", WaterConsts.USE_FARM_NAME,       500,  80, "Anglo Wheat Farm"];
			dataArr[16] = [29, "17-1916", WaterConsts.USE_URBAN_NAME,      500,  20, "Cuidad Juarez, MX"];
			dataArr[17] = [18, "18-1923", WaterConsts.USE_FARM_NAME,       800,  80, "Anglo Cotton Farm"];
			dataArr[18] = [22, "19-1930", WaterConsts.USE_FARM_NAME,       200,  80, "Anglo Cotton Farm"];
			dataArr[19] = [5,  "20-1937", WaterConsts.USE_FARM_NAME,       400,  80, "Anglo Wheat Farm"];
			dataArr[20] = [30, "21-1994", WaterConsts.USE_INDUSTRIAL_NAME, 1000, 30, "Microprocessor Plant"];
			dataArr[21] = [6,  "22-1951", WaterConsts.USE_FARM_NAME,       300,  80, "Anglo Orchard"];
			dataArr[22] = [1,  "23-1958", WaterConsts.USE_FARM_NAME,       1500, 80, "Anglo Cattle Ranch"];
			dataArr[23] = [27, "24-1965", WaterConsts.USE_URBAN_NAME,      2000, 20, "El Paso, TX"];
			dataArr[24] = [21, "25-1972", WaterConsts.USE_FARM_NAME,       400,  80, "Anglo Dairy Farm"];
			dataArr[25] = [3,  "26-1979", WaterConsts.USE_FARM_NAME,       3000, 80, "Anglo Dairy Farm"];
			dataArr[26] = [14, "27-1986", WaterConsts.USE_FARM_NAME,       300,  80, "Anglo Cotton Farm"];
			dataArr[27] = [11, "28-1993", WaterConsts.USE_URBAN_NAME,      4000, 20, "Albuquerque, NM"];
			dataArr[28] = [13, "29-2000", WaterConsts.USE_FARM_NAME,       100,  80, "Anglo Organic Farm"];
			dataArr[29] = [17, "30-2007", WaterConsts.USE_URBAN_NAME,      400,  20, "Las Cruces, NM"];
			
			var item:WaterDataPriorityItem = null;
			var prevItem:WaterDataPriorityItem;
			
			for (var i:int = 0; i < WaterConsts.DATA_SIZE; i++) {
				prevItem = item;
				item = new WaterDataPriorityItem(dataArr[i][0], dataArr[i][1], dataArr[i][2],
																				 dataArr[i][3], dataArr[i][4], dataArr[i][5],
																				 prevItem, this);
				priorityItems[i] = item;
			}
			updatePriorityItems();
		}
		
		private function createPositionItems():void {
			var dataArr:Array = new Array();
			// [position, usePoints]
			dataArr[0]  = [1,  1 ];
			dataArr[1]  = [2,  2 ];
			dataArr[2]  = [3,  1 ];
			dataArr[3]  = [4,  2 ];
			dataArr[4]  = [5,  1 ];
			dataArr[5]  = [6,  1 ];
			dataArr[6]  = [7,  2 ];
			dataArr[7]  = [8,  5 ];
			dataArr[8]  = [9,  2 ];
			dataArr[9]  = [10, 1 ];
			dataArr[10] = [11, 10];
			dataArr[11] = [12, 1 ];
			dataArr[12] = [13, 1 ];
			dataArr[13] = [14, 1 ];
			dataArr[14] = [15, 1 ];
			dataArr[15] = [16, 1 ];
			dataArr[16] = [17, 10];
			dataArr[17] = [18, 1 ];
			dataArr[18] = [19, 1 ];
			dataArr[19] = [20, 1 ];
			dataArr[20] = [21, 1 ];
			dataArr[21] = [22, 1 ];
			dataArr[22] = [23, 1 ];
			dataArr[23] = [24, 1 ];
			dataArr[24] = [25, 1 ];
			dataArr[25] = [26, 1 ];
			dataArr[26] = [27, 10];
			dataArr[27] = [28, 1 ];
			dataArr[28] = [29, 10];
			dataArr[29] = [30, 5 ];

			var item:WaterDataPositionItem = null;
			var prevItem:WaterDataPositionItem;
			
			for (var i:int = 0; i < WaterConsts.DATA_SIZE; i++) {
				prevItem = item;
				item = new WaterDataPositionItem(dataArr[i][0], dataArr[i][1],
																				 findPriorityItem(dataArr[i][0]),
																				 prevItem, this);
				_positionItems[i] = item;
			}
			updatePositionItems();
//			trace(this.dumpPositionItems(_positionItems));
			
			// sort the WaterDataPositionItems based on the player number
			this._sortedPositionItems = new Vector.<WaterDataPositionItem>();
			for (i = 0; i < WaterConsts.DATA_SIZE; i++) {
				this._sortedPositionItems.push(_positionItems[i]);
			}
			this._sortedPositionItems.sort(sortPositionItems);
		}
		
		private function createScoreBenchData():void {
			_scoreBenchData = new Vector.<WaterDataScore>();
			var dataArr:Array = new Array();
			// [runoff, max points]
			// grade A: 90%; grade B: 80%; grade C: 70%; grade D: 50%;
			dataArr[0]  = [1000,  22799 ];
			dataArr[1]  = [3000,  61288 ];
			dataArr[2]  = [5000,  91609 ];
			dataArr[3]  = [7000,  99080 ];
			dataArr[4]  = [9359,  103175];
			dataArr[5]  = [12000, 107368];
			dataArr[6]  = [15640, WaterConsts.MAX_TOTAL_POINTS];
			dataArr[7]  = [WaterConsts.MAX_RUNOFF, WaterConsts.MAX_TOTAL_POINTS];
			
			for (var i:int = 0; i < WaterConsts.SCORE_DATA_SIZE; i++) {
				_scoreBenchData.push(new WaterDataScore(-1, dataArr[i][0], dataArr[i][1]));
			}
		}
		
		private function sortPositionItems(a:WaterDataPositionItem, b:WaterDataPositionItem):int {
			if (a.playerNumber() < b.playerNumber())
				return -1;
			else if (a.playerNumber() > b.playerNumber())
				return 1;
			else
				return 0;
		}
		
		private function findPriorityItem(position:int):WaterDataPriorityItem {
			for (var i:int = 0; i < WaterConsts.DATA_SIZE; i++) {
				if (priorityItems[i].positionFromSource == position)
					return priorityItems[i];
			}
			throw new IllegalOperationError("The WaterData class has internal data error with priority items.");
		}
		
		private function minRiverOutputFlow():Number {
			var ret:Number = Number.MAX_VALUE;
			var riverOF:Number;
			for (var i:int = 0; i < WaterConsts.DATA_SIZE; i++) {
				riverOF = _positionItems[i].riverOutputFlow;
				if (riverOF < ret)
					ret = riverOF;
			}
			return ret;
		}

    private function updatePriorityItems():void {
			for (var i:int = 0; i < WaterConsts.DATA_SIZE; i++) {
				priorityItems[i].updateRemainingVars();
			}
		}
		
    public function updatePositionItems():void {
			for (var i:int = 0; i < WaterConsts.DATA_SIZE; i++) {
				_positionItems[i].updateRemainingVars();
			}
		}
		
		private function dumpPriorityItems():String {
			var ret:String = new String();
			for (var i:int = 0; i < WaterConsts.DATA_SIZE; i++) {
				ret += priorityItems[i].dump() + "\n";
			}
			return ret;
		}
		
		private function dumpPositionItems(items:Vector.<WaterDataPositionItem>):String {
			var ret:String = new String();
			for (var i:int = 0; i < WaterConsts.DATA_SIZE; i++) {
				ret += items[i].dump() + "\n";
			}
			return ret;
		}
		
		private function cleanupTradeData():void {
			var trade:WaterDataTrade;
			for (var i:uint = 0; i < _tradeData.length; i++) {
				trade = _tradeData[i];
				trade.buyer.resetTradeData();
				trade.seller.resetTradeData();
			}
			newTradeData();
		}
		
		private function newTradeData():void {
			this._tradeData = new Vector.<WaterDataTrade>();
		}
		
		private function newDamData():void {
			this._damData = new Vector.<WaterDataDamPoints>();
		}
		
    private function cleanupDamData(newDam:Boolean):void {
			for (var i:uint = 0; i < _damData.length; i++) {
				_damData[i].player.damPoints = 0;
			}
			if (newDam)
				newDamData();
		}
		
		private function newScoreData():void {
			this._scoreData = new Vector.<WaterDataScore>();
		}
		
  }
}