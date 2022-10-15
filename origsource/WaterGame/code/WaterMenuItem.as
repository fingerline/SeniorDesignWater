package code {
	import flash.text.*;
	import flash.display.*;
	
	// size 200x22
	public class WaterMenuItem extends Sprite {

		protected var xPos:Number;
		protected var yPos:Number;
		protected var menuName:String;
		protected var menuItem:MenuButton;
		protected var nameTF:TextField;
		protected var checkMC:MovieClip;

		public function WaterMenuItem(name:String, x:Number, y:Number) {
			// constructor code
			xPos = x;
			yPos = y;
			menuName = name;
			
			setupMenuItem();
		}
		
		protected function setupMenuItem():void {
			menuItem = new MenuButton();
			menuItem.x = xPos;
			menuItem.y = yPos;
			addChild(menuItem);
			
			nameTF = WaterUtils.setupTextFieldL2(this, menuName,
																					 xPos + 24, yPos + 3, WaterConsts.MENU_WIDTH - 24, WaterConsts.MENU_HEIGHT,
																					 11, true);
			nameTF.mouseEnabled = false;
			nameTF.selectable = false;
			
			checkMC = new CheckMarkMC();
			checkMC.x = xPos + 7;
			checkMC.y = yPos + (WaterConsts.MENU_HEIGHT - 10) / 2;
			checkMC.enabled = false;
		}
		
		public function disable(disable:Boolean):void {
			if (disable) {
				// add check mark;
				if (!checkMC.parent)
					addChild(checkMC);
				
				nameTF.alpha = 0.5;
				this.mouseEnabled = false;
			}
			else {
				if (checkMC.parent)
					removeChild(checkMC);
				nameTF.alpha = 1;
				this.mouseEnabled = true;
			}
		}
		
		public function displayCheckMark(display:Boolean):void {
			if (display) {
				if (!checkMC.parent)
					addChild(checkMC);
			}
			else {
				if (checkMC.parent)
					removeChild(checkMC);
			}
		}
		
	}
}
