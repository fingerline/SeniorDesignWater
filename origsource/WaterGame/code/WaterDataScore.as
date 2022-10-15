package code {
	
  public class WaterDataScore {

		private var _year:int;
		private var _runoff:Number;
		private var _points:Number;
		
		public function WaterDataScore(year:int,
																	 runoff:Number,
																	 points:Number) {
			this._year = year;
			this._runoff = runoff;
			this._points = points;
		}
		
		public function get year():int {
			return this._year;
		}
		
		public function get runoff():Number {
			return this._runoff;
		}
		
		public function get points():Number {
			return this._points;
		}
	}
}