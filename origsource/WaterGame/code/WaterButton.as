package code {
	##### Custom button?
	
	import fl.controls.Button;
	import flash.text.TextFormat;

  public class WaterButton extends Button {
		
		public function WaterButton() {
			super();

			setStyle("textFormat", WaterUtils.boldCenterFormat());
		}
	}
}