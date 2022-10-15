package code {

  import flash.display.*;
  import fl.containers.ScrollPane;
  import flash.events.Event;
	import fl.events.ScrollEvent;
	import fl.controls.ScrollBar;

  public class WaterGame extends Sprite {

		// made it public to temporarily fix the resizing scoreinfo issue with the scroll bars appearing
		public var sp:ScrollPane;
    private var myStage:Stage;
		private var view:WaterView;
		private var bgLayer:Sprite;

    public function WaterGame() {
			addEventListener(Event.ADDED, setupChildren, false, 0, true);
			addEventListener(WaterEvent.ADD_GRAY_BKGD, addGrayBkgd, false, 0, true);
			addEventListener(WaterEvent.REMOVE_GRAY_BKGD, removeGrayBkgd, false, 0, true);
    }

    private function setupChildren(e:Event):void {
			removeEventListener(Event.ADDED, setupChildren);
			
			view = new WaterView();
			addChild(view);
			
			myStage = this.stage;
			myStage.scaleMode = StageScaleMode.NO_SCALE;
			myStage.align = StageAlign.TOP_LEFT;
			myStage.addEventListener(Event.RESIZE, onSWFResized);
			
			sp = new ScrollPane();
			sp.move(0, 0);
			onSWFResized(null);
			sp.source = view;
			sp.addEventListener(ScrollEvent.SCROLL, scrollHandler);
			addChild(sp);
			
//			myStage.showDefaultContextMenu = false;
    }

		private function addGrayBkgd(e:WaterEvent):void {
			drawGrayBkdg();
		}
		
		private function removeGrayBkgd(e:WaterEvent):void {
			stage.removeChild(bgLayer);
		}
		
		private function onSWFResized(e:Event):void {
			if (stage.stageWidth >= WaterConsts.GAME_WIDTH && stage.stageHeight >= WaterConsts.GAME_HEIGHT) {
				view.scrollPaneDx = 0;
				view.scrollPaneDy = 0;
			}
			else if (stage.stageHeight >= WaterConsts.GAME_HEIGHT + ScrollBar.WIDTH) {
				view.scrollPaneDy = 0;
			}
			else if (stage.stageWidth >= WaterConsts.GAME_WIDTH + ScrollBar.WIDTH) {
				view.scrollPaneDx = 0;
			}
			sp.setSize(stage.stageWidth, stage.stageHeight);
//			trace("onSWFResized", WaterConsts.GAME_WIDTH, WaterConsts.GAME_HEIGHT);
//			trace("\t" + "stage.stageWidth:", stage.stageWidth);
//			trace("\t" + "stage.width:", stage.width);
//			trace("\t" + "stage.stageHeight:", stage.stageHeight);
//			trace("\t" + "stage.height:", stage.height);
//			trace("\t" + "h scroll bar visible", sp.horizontalScrollBar.visible);
//			trace("\t" + "v scroll bar visible", sp.verticalScrollBar.visible);
			if (bgLayer && bgLayer.parent) {
				drawGrayBkdg();
			}
		}

		private function scrollHandler(event:ScrollEvent):void {
			var mySP:ScrollPane = event.currentTarget as ScrollPane;
			view.scrollPaneDx = mySP.horizontalScrollPosition;
			view.scrollPaneDy = mySP.verticalScrollPosition;
//			trace("scrolling");
//			trace("\t" + "direction:", event.direction);
//			trace("\t" + "position:", event.position);
//			trace("\t" + "horizontalScrollPosition:", mySP.horizontalScrollPosition, "of", mySP.maxHorizontalScrollPosition);
//			trace("\t" + "verticalScrollPosition:", mySP.verticalScrollPosition, "of", mySP.maxVerticalScrollPosition);
//			trace("\t" + "scrollRect:", mySP.scrollRect);
//			trace("\t" + "content:", mySP.content);
//			trace("stage.stageWidth:", stage.stageWidth);
//			trace("stage.width:", stage.width);
//			trace("stage.stageHeight:", stage.stageHeight);
//			trace("stage.height:", stage.height);
//			trace("WaterView.width:", view.width);
//			trace("WaterView.height:", view.height);
//			trace("WaterView.scrollRect:", view.scrollRect);
		}

		private function drawGrayBkdg():void {
			var index:int = stage.numChildren;
			if (bgLayer && bgLayer.parent) {
				index = stage.getChildIndex(bgLayer);
				stage.removeChildAt(index);
			}
			bgLayer = new Sprite();
			bgLayer.graphics.beginFill(WaterConsts.GRAY_COLOR, 0.6);
			bgLayer.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
			bgLayer.graphics.endFill();
			stage.addChildAt(bgLayer, index);
		}
  }
}