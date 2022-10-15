package code {

  import flash.display.*;
	import flash.events.*;
	import flash.geom.*;

  public class WaterViewRiverItem extends Sprite {

    private const DENOMENATOR:Number = 100;
		private const RIVER_HEIGHT:Number = 40;

		private var data:WaterDataPositionItem;
		private var view:WaterView;
		private var isLeftRiverSide:Boolean;
		private var useX:Number;
		private var useY:Number;
		private var itemCenterX:Number;
		private var itemCenterY:Number;
		private var angle:Number;
		private var pipeWithdraw:WaterViewPipe;
		private var pipeReturn:WaterViewPipe;
		private var waterUse:WaterViewUse;
		private var riverSegment:Shape;
		private var container:Sprite;
		private var withdrawArrow:Shape;
		private var returnArrow:Shape;
		
    public function WaterViewRiverItem(data:WaterDataPositionItem,
																			 view:WaterView,
																			 isLeftRiverSide:Boolean,
																			 useX:Number,
																			 useY:Number,
																			 itemCenterX:Number,
																			 itemCenterY:Number,
																			 angle:Number) {
			this.data = data;
			this.view = view;
			this.isLeftRiverSide = isLeftRiverSide;
			this.useX = useX;
			this.useY = useY;
			this.itemCenterX = itemCenterX;
			this.itemCenterY = itemCenterY;
			this.angle = angle;
			addEventListener(Event.ADDED, setupChildren, false, 0, true);
    }

    private function setupChildren(e:Event):void {
			removeEventListener(Event.ADDED, setupChildren);
			
			setupUse();
		}
		
		public function updatePoints():void {
			if (container && container.parent)
				removeChild(container);
			container = new Sprite();
			var w:Number = data.riverInputFlow / DENOMENATOR;
			var h:Number = RIVER_HEIGHT;
			var xx:Number;
			var yy:Number;
			pipeWithdraw = new WaterViewPipe(false, data, view, isLeftRiverSide);
			pipeReturn = new WaterViewPipe(true, data, view, isLeftRiverSide);
			if (this.isLeftRiverSide) {
				xx = itemCenterX - w / 2 - WaterConsts.PIPE_WIDTH;
				drawRiverSegment(WaterConsts.PIPE_WIDTH, 0, w, h);
				pipeWithdraw.x = 0;
				pipeReturn.x = 0;
			}
			else {
				xx = itemCenterX - w / 2;
				drawRiverSegment(0, 0, w, h);
				pipeWithdraw.x = w;
				pipeReturn.x = w;
			}
			pipeWithdraw.y = 0;
			pipeReturn.y = pipeWithdraw.pipeHeight + 2;
			container.addChild(pipeWithdraw);
			container.addChild(pipeReturn);
			yy = itemCenterY - RIVER_HEIGHT / 2;
			container.x = xx;
			container.y = yy;
			addChild(container);
			// rotate based on itemCenter point;
			var offsetX:Number = itemCenterX - xx;
			var offsetY:Number = itemCenterY - yy;
			var matrix:Matrix = new Matrix();
			matrix.translate(-offsetX, -offsetY);
			matrix.rotate(angle * Math.PI / 180.0);
			matrix.translate(offsetX, offsetY);
			matrix.concat(container.transform.matrix);
			container.transform.matrix = matrix;

			drawArrows();
		}

    private function setupUse():void {
			waterUse = new WaterViewUse(data, isLeftRiverSide, useX, useY);
			addChild(waterUse);
		}
		
    private function drawRiverSegment(x:Number, y:Number, w:Number, h:Number):void {
			riverSegment = new Shape();
			riverSegment.graphics.beginFill(WaterConsts.RIVER_COLOR, 1);
			riverSegment.graphics.drawRect(x, y , w, h);
			riverSegment.graphics.endFill();
			container.addChild(riverSegment);
		}
		
		private function drawArrows():void {
			if (withdrawArrow && withdrawArrow.parent)
				removeChild(withdrawArrow);
			withdrawArrow = getArrow(pipeWithdraw.flowGlobalPoint(), waterUse.withdrawGlobalPoint());
			addChild(withdrawArrow);
			if (returnArrow && returnArrow.parent)
				removeChild(returnArrow);
			returnArrow = getArrow(waterUse.returnGlobalPoint(), pipeReturn.flowGlobalPoint());
			addChild(returnArrow);
		}
		
		private function getArrow(arrowTail:Point, arrowHead:Point):Shape {
			var slope:Number = 30;
			var headLength:Number = 10;
			var vector:Point = new Point(-(arrowHead.x - arrowTail.x), -(arrowHead.y - arrowTail.y));
			
			var matrix1:Matrix = new Matrix();
			matrix1.rotate(slope * Math.PI / 180);
			var vec1:Point = matrix1.transformPoint(vector);
			vec1.normalize(headLength);
			var edge1:Point = new Point();
			edge1.x = arrowHead.x + vec1.x;
			edge1.y = arrowHead.y + vec1.y;

			var matrix2:Matrix = new Matrix();
			matrix2.rotate((0 - slope) * Math.PI / 180);
			var vec2:Point = matrix2.transformPoint(vector);
			vec2.normalize(headLength);
			var edge2:Point = new Point();
			edge2.x = arrowHead.x + vec2.x;
			edge2.y = arrowHead.y + vec2.y;
			
			var arrow:Shape = new Shape();
			arrow.graphics.lineStyle(1, WaterConsts.BLACK_COLOR, 1,
														 false, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.MITER, 1);
			arrow.graphics.moveTo(arrowTail.x, arrowTail.y);
			arrow.graphics.lineTo(arrowHead.x, arrowHead.y);
			arrow.graphics.lineTo(edge1.x, edge1.y);
			arrow.graphics.moveTo(arrowHead.x, arrowHead.y);
			arrow.graphics.lineTo(edge2.x, edge2.y);
			return arrow;
		}
  }
}