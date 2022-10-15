package code {

  import flash.display.*;
	import flash.text.*;
	import flash.geom.*;

  // we redraw WaterViewPipe each time the runoff is updated.
  public class WaterViewPipe extends Sprite {

		private var isReturnFlow:Boolean;
		private var data:WaterDataPositionItem;
		private var view:WaterView;
		private var isLeftRiverSide:Boolean;
		private var _pipeHeight:Number;
		private var pipeCurveW:Number;
		private var fontSize:Object;
		// withdraw or return flow;
		private var waterVolumeTF:TextField;
		private var waterVolume:Number;
		private var yOffset:Number;
		
    public function WaterViewPipe(isReturnFlow:Boolean,
																	data:WaterDataPositionItem,
																	view:WaterView,
																	isLeftRiverSide:Boolean) {
			this.isReturnFlow = isReturnFlow;
			this.data = data;
			this.view = view;
			this.isLeftRiverSide = isLeftRiverSide;
			this.waterVolume = isReturnFlow ? data.returnFlow
			                              : data.waterWithdrawn;
			if (this.waterVolume <= 1000.0) {
				_pipeHeight = 12;
				pipeCurveW = 2;
				fontSize = 11;
				yOffset = -2;
			}
			else if (this.waterVolume <= 2000.0) {
				_pipeHeight = 18;
				pipeCurveW = 4;
				fontSize = 12;
				yOffset = 0;
			}
			else {
				_pipeHeight = 24;
				pipeCurveW = 6;
				fontSize = 14;
				yOffset = 2;
			}

			drawPipe();
			drawWaterVolumeTF();
		}
		
		public function flowGlobalPoint():Point {
			var ret:Point;
			if (isLeftRiverSide)
				ret = localToGlobal(new Point(0, _pipeHeight / 2));
			else
				ret = localToGlobal(new Point(pipeCurveW * 2 + WaterConsts.PIPE_WIDTH, _pipeHeight / 2));
			ret.offset(view.scrollPaneDx, view.scrollPaneDy);
			return ret;
		}
		
		public function get pipeHeight():Number {
			return _pipeHeight;
		}
		
    private function drawPipe() {
			var color:uint;
			if (data.requestedWithdraw() > data.waterWithdrawn )
				color = WaterConsts.RED_COLOR;
			else
				color = isReturnFlow ? WaterConsts.PIPE_RETURNFLOW_COLOR
			                       : WaterConsts.PIPE_WITHDRAW_COLOR;
			var pipe:Shape = new Shape();
			pipe.graphics.lineStyle(1, WaterConsts.BLACK_COLOR, 1,
														 false, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.MITER, 1);
			pipe.graphics.beginFill(color);
			pipe.graphics.moveTo(pipeCurveW, 0);
			pipe.graphics.lineTo(pipeCurveW + WaterConsts.PIPE_WIDTH, 0);
			pipe.graphics.curveTo(pipeCurveW * 3 + WaterConsts.PIPE_WIDTH, _pipeHeight / 2,
															pipeCurveW + WaterConsts.PIPE_WIDTH, _pipeHeight);
			pipe.graphics.lineTo(pipeCurveW, _pipeHeight);
			pipe.graphics.curveTo(-pipeCurveW, _pipeHeight / 2,
															pipeCurveW, 0);
			pipe.graphics.endFill();
			if (this.isLeftRiverSide) {
				pipe.graphics.moveTo(pipeCurveW + WaterConsts.PIPE_WIDTH, 0);
				pipe.graphics.curveTo(WaterConsts.PIPE_WIDTH - pipeCurveW, _pipeHeight / 2,
																pipeCurveW + WaterConsts.PIPE_WIDTH, _pipeHeight);
			}
			else {
				pipe.graphics.moveTo(pipeCurveW, 0);
				pipe.graphics.curveTo(pipeCurveW * 3, _pipeHeight / 2,
																pipeCurveW, _pipeHeight);
			}
			addChild(pipe);
		}
		
		private function drawWaterVolumeTF() {
			var color:uint;
			if (data.requestedWithdraw() > data.waterWithdrawn )
				color = WaterConsts.WHITE_COLOR;
			else
				color = WaterConsts.BLACK_COLOR;
			WaterUtils.setupTextFieldC3(this,
																	String(Math.round(waterVolume)),
																	pipeCurveW, yOffset,
																	WaterConsts.PIPE_WIDTH, _pipeHeight,
																	fontSize, color);
		}
  }
}
