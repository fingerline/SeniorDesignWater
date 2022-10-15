package code {

  import flash.display.*;
	import flash.events.*;

  public class WaterDragSprite extends Sprite {

    public function WaterDragSprite() {
			this.addEventListener(MouseEvent.MOUSE_DOWN, startDragMouseDown, false, 0, true);
			this.addEventListener(MouseEvent.MOUSE_UP, stopDragMouseUp, false, 0, true);
    }

		protected function startDragMouseDown(e:MouseEvent):void {
			this.startDrag();
		}
		
		protected function stopDragMouseUp(e:MouseEvent):void {
			this.stopDrag();
		}
		
  }
}