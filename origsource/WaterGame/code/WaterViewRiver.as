package code {

  import flash.display.*;
	import flash.events.*;

  public class WaterViewRiver extends Sprite {

		private var L_BASE_X:Number = 130;
		private var R_BASE_X:Number = 150;
		private var BASE_X:Number = 150;
		private var BASE_Y:Number = 70;

		private var data:WaterData;
		private var view:WaterView;
		private var riverItems:Vector.<WaterViewRiverItem>;
		
    public function WaterViewRiver(data:WaterData,
																	 view:WaterView) {
			this.data = data;
			this.view = view;
			addEventListener(Event.ADDED, setupChildren, false, 0, true);
    }

    private function setupChildren(e:Event):void {
			removeEventListener(Event.ADDED, setupChildren);
			
			var dataArr:Array = new Array();
			// [isLeftRiverSide, useX, useY, itemCenterX, itemCenterY, angle];
			// test data - don't delete;
//			dataArr[0]  = [true,  220, 26,  550, 30,  45];
//			dataArr[1]  = [false, 690, 170, 550, 50,  45];
//			dataArr[2]  = [true,  220, 60,  550, 70,  45];
//			dataArr[3]  = [false, 690, 204, 550, 90,  45];
//			dataArr[4]  = [true,  220, 94,  550, 110, 45];
//			dataArr[5]  = [true,  220, 128, 550, 130, 45];
//			dataArr[6]  = [true,  220, 162, 550, 150, 45];
//			dataArr[7]  = [true,  220, 196, 550, 170, 45];
//			dataArr[8]  = [true,  220, 230, 550, 190, 45];
//			dataArr[9]  = [false, 690, 238, 550, 210, 45];
//			dataArr[10] = [true,  220, 264, 550, 230, 45];
//			dataArr[11] = [false, 690, 272, 550, 250, 45];
//			dataArr[12] = [true,  220, 298, 550, 270, 45];
//			dataArr[13] = [false, 690, 306, 550, 290, 45];
//			dataArr[14] = [true,  220, 310, 550, 310, 45];
//			dataArr[15] = [false, 690, 340, 550, 330, 45];
//			dataArr[16] = [true,  220, 350, 550, 350, 45];
//			dataArr[17] = [false, 690, 374, 550, 370, 45];
//			dataArr[18] = [true,  220, 390, 550, 390, 45];
//			dataArr[19] = [false, 690, 408, 550, 410, 45];
//			dataArr[20] = [true,  220, 430, 550, 430, 45];
//			dataArr[21] = [false, 690, 442, 550, 450, 45];
//			dataArr[22] = [true,  220, 470, 550, 470, 45];
//			dataArr[23] = [false, 690, 476, 550, 490, 45];
//			dataArr[24] = [true,  220, 510, 550, 510, 45];
//			dataArr[25] = [false, 690, 510, 550, 530, 45];
//			dataArr[26] = [true,  220, 550, 550, 550, 45];
//			dataArr[27] = [false, 690, 544, 550, 570, 45];
//			dataArr[28] = [true,  220, 590, 550, 590, 45];
//			dataArr[29] = [false, 690, 578, 550, 610, 45];
			// [isLeftRiverSide, useX, useY, itemCenterX, itemCenterY, angle];
			// the data before being wider - don't delete;
//			dataArr[0]  = [true,  280, 50,  550, 150, 45];
//			dataArr[1]  = [false, 670, 200, 550, 160, 40];
//			dataArr[2]  = [true,  250, 85,  515, 160, 40];
//			dataArr[3]  = [false, 670, 235, 500, 180, 35];
//			dataArr[4]  = [true,  220, 120, 500, 180, 25];
//			dataArr[5]  = [true,  220, 150, 480, 200, 20];
//			dataArr[6]  = [true,  220, 180, 460, 220, 15];
//			dataArr[7]  = [true,  220, 210, 460, 250, 10];
//			dataArr[8]  = [false, 650, 270, 470, 260, 10];
//			dataArr[9]  = [true,  220, 245, 460, 280, 5];
//			dataArr[10] = [false, 650, 305, 470, 300, 5];
//			dataArr[11] = [true,  220, 280, 470, 320, 0];
//			dataArr[12] = [true,  220, 310, 470, 350, 0];
//			dataArr[13] = [false, 670, 340, 500, 360, 0];
//			dataArr[14] = [true,  220, 345, 500, 380, 0];
//			dataArr[15] = [false, 670, 375, 520, 400, -5];
//			dataArr[16] = [true,  220, 380, 520, 410, 0];
//			dataArr[17] = [false, 690, 410, 550, 427, -5];
//			dataArr[18] = [false, 690, 440, 550, 450, 0];
//			dataArr[19] = [false, 690, 470, 550, 470, 15];
//			dataArr[20] = [true,  230, 415, 520, 480, 20];
//			dataArr[21] = [false, 680, 505, 540, 490, 30];
//			dataArr[22] = [false, 670, 535, 515, 500, 45];
//			dataArr[23] = [false, 670, 565, 500, 520, 50];
//			dataArr[24] = [true,  230, 450, 490, 500, 15];
//			dataArr[25] = [true,  230, 480, 480, 535, 15];
//			dataArr[26] = [true,  230, 510, 470, 560, 10];
//			dataArr[27] = [false, 670, 600, 480, 580, 30];
//			dataArr[28] = [true,  230, 545, 470, 600, 5];
//			dataArr[29] = [true,  230, 575, 470, 630, 0];
			// [isLeftRiverSide, useX, useY, itemCenterX, itemCenterY, angle];
			dataArr[0]  = [true,  L_BASE_X+250, BASE_Y,     BASE_X+540, BASE_Y+100, 45];
			dataArr[1]  = [false, R_BASE_X+698, BASE_Y+160, BASE_X+540, BASE_Y+110, 40];
			dataArr[2]  = [true,  L_BASE_X+220, BASE_Y+35,  BASE_X+505, BASE_Y+110, 40];
			dataArr[3]  = [false, R_BASE_X+678, BASE_Y+195, BASE_X+490, BASE_Y+130, 35];
			dataArr[4]  = [true,  L_BASE_X+190, BASE_Y+70,  BASE_X+490, BASE_Y+130, 25];
			dataArr[5]  = [true,  L_BASE_X+190, BASE_Y+100, BASE_X+470, BASE_Y+150, 20];
			dataArr[6]  = [true,  L_BASE_X+190, BASE_Y+130, BASE_X+450, BASE_Y+170, 15];
			dataArr[7]  = [true,  L_BASE_X+190, BASE_Y+160, BASE_X+450, BASE_Y+200, 10];
			dataArr[8]  = [false, R_BASE_X+658, BASE_Y+230, BASE_X+460, BASE_Y+210, 10];
			dataArr[9]  = [true,  L_BASE_X+190, BASE_Y+195, BASE_X+450, BASE_Y+230, 5];
			dataArr[10] = [false, R_BASE_X+658, BASE_Y+265, BASE_X+460, BASE_Y+250, 5];
			dataArr[11] = [true,  L_BASE_X+190, BASE_Y+230, BASE_X+460, BASE_Y+270, 0];
			dataArr[12] = [true,  L_BASE_X+190, BASE_Y+260, BASE_X+460, BASE_Y+300, 0];
			dataArr[13] = [false, R_BASE_X+678, BASE_Y+300, BASE_X+490, BASE_Y+310, 0];
			dataArr[14] = [true,  L_BASE_X+190, BASE_Y+295, BASE_X+490, BASE_Y+330, 0];
			dataArr[15] = [false, R_BASE_X+678, BASE_Y+335, BASE_X+510, BASE_Y+350, -5];
			dataArr[16] = [true,  L_BASE_X+190, BASE_Y+330, BASE_X+510, BASE_Y+360, 0];
			dataArr[17] = [false, R_BASE_X+698, BASE_Y+370, BASE_X+540, BASE_Y+377, -5];
			dataArr[18] = [false, R_BASE_X+698, BASE_Y+400, BASE_X+540, BASE_Y+400, 0];
			dataArr[19] = [false, R_BASE_X+698, BASE_Y+430, BASE_X+540, BASE_Y+420, 15];
			dataArr[20] = [true,  L_BASE_X+200, BASE_Y+365, BASE_X+510, BASE_Y+430, 20];
			dataArr[21] = [false, R_BASE_X+688, BASE_Y+465, BASE_X+530, BASE_Y+440, 30];
			dataArr[22] = [false, R_BASE_X+678, BASE_Y+495, BASE_X+505, BASE_Y+450, 45];
			dataArr[23] = [false, R_BASE_X+678, BASE_Y+525, BASE_X+490, BASE_Y+470, 50];
			dataArr[24] = [true,  L_BASE_X+200, BASE_Y+400, BASE_X+480, BASE_Y+450, 15];
			dataArr[25] = [true,  L_BASE_X+200, BASE_Y+430, BASE_X+470, BASE_Y+485, 15];
			dataArr[26] = [true,  L_BASE_X+200, BASE_Y+460, BASE_X+460, BASE_Y+510, 10];
			dataArr[27] = [false, R_BASE_X+678, BASE_Y+560, BASE_X+470, BASE_Y+530, 30];
			dataArr[28] = [true,  L_BASE_X+200, BASE_Y+495, BASE_X+460, BASE_Y+550, 5];
			dataArr[29] = [true,  L_BASE_X+200, BASE_Y+525, BASE_X+460, BASE_Y+580, 0];
			
			riverItems = new Vector.<WaterViewRiverItem>();
			var item:WaterViewRiverItem;
			var dataItems:Vector.<WaterDataPositionItem> = data.positionItems;
			for (var i:uint = 0; i < dataItems.length; i++) {
				item = new WaterViewRiverItem(dataItems[i], view,
																			dataArr[i][0], dataArr[i][1],
																			dataArr[i][2], dataArr[i][3],
																			dataArr[i][4], dataArr[i][5]);
				riverItems.push(item);
				addChild(item);
			}
		}
		
		public function updatePoints():void {
			for (var i:uint = 0; i < riverItems.length; i++) {
				riverItems[i].updatePoints();
			}
		}
  }
}