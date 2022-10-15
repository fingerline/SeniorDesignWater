package code {

	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import fl.controls.*;

  public class WaterViewTitleBar extends Sprite {

		private const RUNOFF_WIDTH:Number = 70;
		private const RUNOFF_TEXTFIELD_X:Number = RUNOFF_WIDTH;
		private const RUNOFF_TEXTFIELD_WIDTH:Number = 50;
		private const INITIALIZE_BTN_X:Number = RUNOFF_TEXTFIELD_X + RUNOFF_TEXTFIELD_WIDTH + 7;
		private const INITIALIZE_BTN_WIDTH:Number = 100;
		private const RESET_BTN_X:Number = INITIALIZE_BTN_X + INITIALIZE_BTN_WIDTH + 7;
		private const RESET_BTN_WIDTH:Number = 60;
		// represents WaterConsts.MAX_TOTAL_POINTS points;
		private const BAR_WIDTH:Number = 400;
		private const BAR_HEIGHT:Number = 36;
		private const BAR_X:Number = 460;
		private const BAR_Y:Number = 5;
		private const LEGEND_Y:Number = 40;
		private const LEGEND_HEIGHT:Number = 16;
		private const GAME_TITLE_X:Number = RESET_BTN_X + RESET_BTN_WIDTH + 7;
		private const GAME_TITLE_WIDTH:Number = BAR_X - 7 - GAME_TITLE_X;
		
    private var data:WaterData;
		private var runoffTF:TextField;
		private var container:Sprite;
		private var yearTF:TextField;

    public function WaterViewTitleBar(data:WaterData) {
			this.data = data;
			addEventListener(Event.ADDED, setupChildren, false, 0, true);
    }

    private function setupChildren(e:Event):void {
			removeEventListener(Event.ADDED, setupChildren);
			
			setupTitle();
			setupBirdsAndSun();
			setupTextFields();
			setupButtons();
		}
		
		public function updatePoints():void {
			runoffTF.text = String(Math.round(data.runoff));
			yearTF.text = getYearText();
			// draw the bars;
			var wWaterUse:Number = Math.round(BAR_WIDTH * data.sumOfPersonalPoints() / WaterConsts.MAX_TOTAL_POINTS);
			var wFish:Number = Math.round(BAR_WIDTH * data.fishHabitatPoints() / WaterConsts.MAX_TOTAL_POINTS);
			var wRest:Number = BAR_WIDTH - wWaterUse - wFish;
			if (container && container.parent)
				removeChild(container);
			container = new Sprite();
			var box:Shape = new Shape();
			box.graphics.lineStyle(1, WaterConsts.BLACK_COLOR, 1,
															false, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.MITER, 1);
			box.graphics.beginFill(WaterConsts.SUN_COLOR);
			box.graphics.drawRect(BAR_X, BAR_Y, wWaterUse, BAR_HEIGHT);
			box.graphics.endFill();
			box.graphics.beginFill(WaterConsts.ORANGE_COLOR);
			box.graphics.drawRect(BAR_X + wWaterUse, BAR_Y, wFish, BAR_HEIGHT);
			box.graphics.endFill();
			container.addChild(box);
			WaterUtils.setupTextFieldL3(container,
																	WaterConsts.TOTAL_WATER_USE_NAME,
																	BAR_X + 2, BAR_Y + 4, wWaterUse, BAR_HEIGHT,
																	12, false);
			WaterUtils.setupTextFieldL4(container,
																	WaterConsts.FISH_NAME,
																	BAR_X + wWaterUse + wFish - 16, BAR_Y + BAR_HEIGHT,
																	BAR_HEIGHT, wFish,
																	12, false);
      var pointsTF:TextField = WaterUtils.setupTextFieldC4(container,
																	String(Math.round(data.sumOfPersonalPoints())),
																	BAR_X + wWaterUse, LEGEND_Y, 10, LEGEND_HEIGHT,
																	12, true);
			if (pointsTF.getBounds(container).x > BAR_X + 4)
	     	WaterUtils.setupTextFieldC4(container,
																	WaterConsts.STRING_ZERO,
																	BAR_X, LEGEND_Y, 10, LEGEND_HEIGHT,
																	12, true);
      WaterUtils.setupTextFieldL2(container,
																	String(Math.round(data.sumOfPersonalPoints() + data.fishHabitatPoints())),
																	BAR_X + wWaterUse + wFish + 2, BAR_Y, 10, LEGEND_HEIGHT,
																	12, true);
			addChild(container);
		}
		
		private function setupTitle():void {
			WaterUtils.setupTextFieldC2(this,
														 WaterConsts.GAME_TITLE,
														 GAME_TITLE_X, 0, GAME_TITLE_WIDTH, 50,
														 21, true);
		}
		
		private function setupTextFields():void {
			WaterUtils.setupTextFieldC2(this, WaterConsts.ACRE_FEET_NAME,
																	0, 6, RUNOFF_WIDTH, 18,
																	12, true);
			yearTF = WaterUtils.setupTextFieldC2(this, getYearText(),
																	0, WaterConsts.TITLE_BG_HEIGHT / 2,
																	RUNOFF_WIDTH, 22,
																	14, true);
			var box:Shape = new Shape();
			box.graphics.lineStyle(2, WaterConsts.BLACK_COLOR, 1,
														 false, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.MITER, 1);
			box.graphics.drawRect(RUNOFF_TEXTFIELD_X, 6, RUNOFF_TEXTFIELD_WIDTH, WaterConsts.TITLE_BG_HEIGHT - 12);
			addChild(box);
			runoffTF = WaterUtils.setupTextFieldR4(this,
																	RUNOFF_TEXTFIELD_X, 6, RUNOFF_TEXTFIELD_WIDTH, 32,
																	14, true);
			runoffTF.type = TextFieldType.INPUT;
			runoffTF.selectable = true;
			runoffTF.restrict = "0-9";
			runoffTF.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		}
		
		private function keyDownHandler(e:KeyboardEvent):void {
			if (e.charCode == 13) {
				var runoff:Number = Number(runoffTF.text);
				if (runoff < 5000)
					dispatchEvent(new WaterErrorEvent("The annual river flow cannot be less than 5000 acre-feet.", WaterErrorEvent.ADD_VIEW_ERROR, true));
				else if (runoff > WaterConsts.MAX_RUNOFF)
					dispatchEvent(new WaterErrorEvent("The annual river flow cannot be greater than " + WaterConsts.MAX_RUNOFF + " acre-feet.", WaterErrorEvent.ADD_VIEW_ERROR, true));
				else
					initializeRunoff(runoff);
			}
		}

		private function setupBirdsAndSun():void {
			var birds:MovieClip = new BirdsMC();
			birds.x = WaterConsts.GAME_WIDTH - 67;
			birds.y = 5;
			addChild(birds);
			var sun:Shape = new Shape();
			sun.graphics.beginFill(WaterConsts.SUN_COLOR);
			sun.graphics.moveTo(WaterConsts.GAME_WIDTH - 30, 0);
			sun.graphics.curveTo(WaterConsts.GAME_WIDTH - 28, 22, WaterConsts.GAME_WIDTH, 25);
			sun.graphics.lineTo(WaterConsts.GAME_WIDTH, 0);
			sun.graphics.endFill();
			addChild(sun);
		}
		
		private function setupButtons():void {
			var btn:Button = this.createButton(WaterConsts.INITIALIZE_ANNUAL_RUNOFF_NAME,
																				 INITIALIZE_BTN_X,
																				 INITIALIZE_BTN_WIDTH);
			btn.addEventListener(MouseEvent.CLICK, initializeRunoffClicked, false, 0, true);
			addChild(btn);
			
			btn = this.createButton(WaterConsts.RESET_TO_YEAR_ZERO_NAME,
															RESET_BTN_X,
															RESET_BTN_WIDTH);
			btn.addEventListener(MouseEvent.CLICK, resetBtnClicked, false, 0, true);
			addChild(btn);
		}
		
		private function createButton(label:String, x:Number, w:Number):Button {
			var btn:Button = new WaterButton();
			btn.label = label;
			btn.opaqueBackground = WaterConsts.TITLE_BG_COLOR;
			btn.labelPlacement = ButtonLabelPlacement.TOP;
			btn.move(x, 4);
			btn.setSize(w, WaterConsts.TITLE_BG_HEIGHT - 8);
			return btn;
		}
		
		private function initializeRunoffClicked(e:MouseEvent):void {
			initializeRunoff(NaN);
		}
		
		private function resetBtnClicked(e:MouseEvent):void {
			dispatchEvent(new WaterEvent(WaterEvent.RESET_GAME, true));
		}
		
		private function initializeRunoff(runoff:Number):void {
			dispatchEvent(new WaterEvent(WaterEvent.CLOSE_TRADING_INFO, true));
			dispatchEvent(new WaterEvent(WaterEvent.CLOSE_DAM_INFO, true));
			dispatchEvent(new WaterEvent(WaterEvent.CLOSE_SCORE_INFO, true));
			data.initializeRunoff(runoff);
			dispatchEvent(new WaterEvent(WaterEvent.UPDATE_VIEWS, true));
			if (data.damCapacity > 0) {
				dispatchEvent(new WaterEvent(WaterEvent.ADD_VIEW_DAM_STORE, true));
			}
		}
		
		private function getYearText():String {
			return "Year " + String(data.year);
		}
  }
}