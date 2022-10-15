package code {

  import flash.display.*;
	import flash.events.*;
	import fl.controls.*;
	import flash.geom.*;
	import fl.data.*;
	import flash.text.*;

  public class WaterViewDam extends WaterViewPopup {
		
		private const POINTS_WIDTH:Number = 150;
		private const POINTS_X:Number = 170;
		private const PLAYER_X:Number = 40;
		private const BUTTON_X:Number = 383;
		private const BUTTON_WIDTH:Number = 90;
		
		private var data:WaterData;
		// this is introduced to popup WaterViewDamStore ui after WaterViewDam is gone;
		private var view:WaterView;
		
		private var playerCB:WaterComboBox;
		private var pointsTF:TextField;
		private var limitTF:TextField;
		private var limit:Number;
		private var player:WaterDataPositionItem;

    public function WaterViewDam(data:WaterData,
																 view:WaterView,
																	 x:Number, y:Number,
																	 w:Number, h:Number) {
			super(x, y, w, h, WaterConsts.BUILDING_A_DAM_NAME);
			this.data = data;
			this.view = view;
			this.limit = 0;
    }

    override protected function setupChildrenHandling():void {
			setupComboBox();
			setupPointsTF();
			setupButtons();
		}
		
		override protected function closeBtnClickedHandling():void {
			dispatchEvent(new WaterEvent(WaterEvent.REMOVE_VIEW_DAM, true));
		}
		
		private function setupComboBox():void {
			// combobox title;
			WaterUtils.setupTextFieldC2(box, "Player",
																	xPos + PLAYER_X, yPos + TEXT_OFFSET_Y,
																	COMBOBOX_WIDTH, COMBOBOX_HEIGHT,
																	12, true);
			// combobox itself;
			playerCB = new WaterComboBox();
			playerCB.move(xPos + PLAYER_X, yPos + COMBOBOX_OFFSET_Y);
			playerCB.setSize(COMBOBOX_WIDTH, COMBOBOX_HEIGHT);
			playerCB.prompt = "Player";
			var dp:DataProvider = new DataProvider();
			for (var i:uint = 0; i < data.sortedPositionItems.length; i++) {
				dp.addItem({label:data.sortedPositionItems[i].priorityDate(), data:this.data.sortedPositionItems[i]});
			}
			playerCB.dataProvider = dp;
			playerCB.rowCount = 10;
      playerCB.addEventListener(Event.CHANGE, playerChanged, false, 0, true);
			box.addChild(playerCB);
			
		}
		
		private function playerChanged(e:Event):void {
			if (errorTF.visible == true)
				errorTF.visible = false;
			player = playerCB.selectedItem.data;
			if (player != null) {
				stage.focus = pointsTF;
				showLimit();
			}
		}
		
		private function showLimit():void {
			//                   Min( player column AG - AH, 40000 - data.damPoints())
			limit = Math.round(Math.min(player.riverPointsAfterTrade - player.damPoints, 40000 - data.damPoints()));
			limitTF.text = "The limit is " + String(limit);
		}
		
		private function setupPointsTF():void {
			WaterUtils.setupTextFieldC2(box, WaterConsts.POINTS_TO_CONTRIBUTE_NAME,
																	xPos + POINTS_X, yPos + TEXT_OFFSET_Y,
																	POINTS_WIDTH, COMBOBOX_HEIGHT,
																	12, true);
			pointsTF = WaterUtils.setupTextFieldR3(box,
																	xPos + POINTS_X, yPos + COMBOBOX_OFFSET_Y,
																	POINTS_WIDTH, COMBOBOX_HEIGHT,
																	12, true);
			pointsTF.type = TextFieldType.INPUT;
			pointsTF.selectable = true;
			pointsTF.restrict = "0-9";
			limitTF = WaterUtils.setupTextFieldR4(box,
																	xPos + POINTS_X, yPos + COMBOBOX_OFFSET_Y + COMBOBOX_HEIGHT,
																	POINTS_WIDTH, COMBOBOX_HEIGHT,
																	12, false);
		}
		
		private function setupButtons():void {
			var contribute:Button = new WaterButton();
			contribute.label = WaterConsts.CONTRIBUTE_NAME;
			contribute.move(xPos + BUTTON_X, yPos + COMBOBOX_OFFSET_Y);
			contribute.setSize(BUTTON_WIDTH, 22);
			contribute.addEventListener(MouseEvent.CLICK, contributeBtnClicked, false, 0, true);
			box.addChild(contribute);
			
			var build:Button = new WaterButton();
			build.label = WaterConsts.BUILD_A_DAM_NAME;
			build.move(xPos + BUTTON_X, yPos + rectH - 40);
			build.setSize(BUTTON_WIDTH, 22);
			build.addEventListener(MouseEvent.CLICK, buildBtnClicked, false, 0, true);
			box.addChild(build);
		}
		
		private function contributeBtnClicked(e:MouseEvent):void {
			if (player == null) {
				errorTF.text = "Please select a Player!";
				errorTF.visible = true;
				return;
			}
			var points:Number = Number(pointsTF.text);
			if (points == 0) {
				errorTF.text = "Please type in the points to contribute!";
				errorTF.visible = true;
				return;
			}
			if (points > limit) {
				errorTF.text = "The points to contribute exceed the limit of " + String(limit) + ".";
				errorTF.visible = true;
				return;
			}
			if (errorTF.visible) {
				errorTF.text = "";
				errorTF.visible = false;
			}
			data.addDamData(new WaterDataDamPoints(player, points));
			data.updatePositionItems();
			dispatchEvent(new WaterEvent(WaterEvent.UPDATE_DAM_INFO, true));
			// reset all the contents;
			playerCB.selectedIndex = -1;
			player = null;
			pointsTF.text = "";
			limitTF.text = "";
			limit = 0;
		}
		
		private function buildBtnClicked(e:MouseEvent):void {
			if (data.damData.length <= 0) {
				errorTF.text = "Please contribute some points first.";
				errorTF.visible = true;
				return;
			}
			if (!data.tradingChecked)
				data.tradingChecked = true;
			data.damChecked = true;
			data.isDamBuilt = true;
			dispatchEvent(new WaterEvent(WaterEvent.BUILD_DAM, true));
			super.closeBtnClicked(null);
			view.dispatchEvent(new WaterEvent(WaterEvent.ADD_VIEW_DAM_STORE, true));
		}
  }
}