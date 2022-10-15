package code {

  import flash.display.*;
	import flash.events.*;
	import fl.controls.*;
	import flash.text.*;

  public class WaterViewError extends WaterViewPopup {

		private var error:String;

    public function WaterViewError(x:Number, y:Number,
																 w:Number, h:Number,
																 error:String) {
			super(x, y, w, h, WaterConsts.ERROR_NAME);
			this.error = error;
    }

    override protected function setupChildrenHandling():void {
			setupErrorTF();
		}
		
		override protected function closeBtnClickedHandling():void {
			dispatchEvent(new WaterErrorEvent(error, WaterErrorEvent.REMOVE_VIEW_ERROR, true));
		}
		
		private function setupErrorTF():void {
			errorTF.text = error;
			errorTF.visible = true;
		}
		
  }
}