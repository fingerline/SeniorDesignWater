package code {
	
  public class WaterDataDamPoints {

		private var _player:WaterDataPositionItem;
		private var _points:int;
		
		public function WaterDataDamPoints(player:WaterDataPositionItem,
																			 points:int) {
			this._player = player;
			this._points = points;
		}
		
		public function get player():WaterDataPositionItem {
			return _player;
		}
		
		public function get points():int {
			return _points;
		}
		public function set points(value:int):void {
			_points = value;
		}
	}
}