package code {

  import flash.display.*;
  import flash.text.*;
	
  public final class WaterUtils {

		static function setupTextFieldC0(tf:TextField, x:Number, w:Number,
																		 fontSize:Object, bold:Object=false):void {
			tf.x = x;
			tf.width = w;
			tf.autoSize = TextFieldAutoSize.CENTER;
			tf.selectable = false;
			var format:TextFormat = new TextFormat();
			format.align = TextFormatAlign.CENTER;
			format.size = fontSize;
			format.bold = bold;
			format.font = "Arial";
			tf.setTextFormat(format);
			tf.defaultTextFormat = format;
		}

		public static function setupTextFieldC1(container:Sprite, tf:TextField,
																						x:Number, y:Number, w:Number, h:Number,
																						fontSize:Object, bold:Object=false):void {
			setupTextFieldC0(tf, x, w, fontSize, bold);
			tf.y = y;
			tf.height = h;
			container.addChild(tf);
		}
		
		public static function setupTextFieldC2(container:Sprite, name:String,
																						x:Number, y:Number, w:Number, h:Number,
																						fontSize:Object, bold:Object=false):TextField {
			var tf:TextField = new TextField();
			tf.text = name;
			setupTextFieldC1(container, tf, x, y, w, h, fontSize, bold);
			return tf;
		}
		
		// embedded font;
		public static function setupTextFieldC3(container:Sprite, name:String,
																						x:Number, y:Number, w:Number, h:Number,
																						fontSize:Object, color:Object):TextField {
			var myFont:Font = new ArialBoldFont();
			var format:TextFormat = new TextFormat();
			format.align = TextFormatAlign.CENTER;
			format.font = myFont.fontName;
			format.size = fontSize;
			format.color = color;
			format.bold = true;
			
			var tf:TextField = new TextField();
			tf.text = name;
			tf.x = x;
			tf.y = y;
			tf.width = w;
			tf.height = h;
			tf.autoSize = TextFieldAutoSize.NONE;
			tf.selectable = false;
			tf.embedFonts = true;
			tf.antiAliasType = AntiAliasType.ADVANCED;
			tf.defaultTextFormat = format;
			tf.setTextFormat(format);
			container.addChild(tf);
			return tf;
		}

		public static function setupTextFieldC4(container:Sprite, name:String,
																						xMid:Number, y:Number, w:Number, h:Number,
																						fontSize:Object, bold:Object=false):TextField {
			var tf:TextField = new TextField();
			tf.text = name;
			setupTextFieldC1(container, tf, xMid - w / 2, y, w, h, fontSize, bold);
			// move to the left to align with the mid point;
			tf.x = xMid - tf.getBounds(container).width / 2;
			return tf;
		}
		
		public static function setupTextFieldR1(container:Sprite, tf:TextField,
																						x:Number, y:Number, w:Number, h:Number,
																						fontSize:Object, bold:Object=false):void {
			tf.x = x;
			tf.y = y;
			tf.width = w;
			tf.height = h;
			tf.selectable = false;
			var format:TextFormat = new TextFormat();
			format.align = TextFormatAlign.RIGHT;
			format.size = fontSize;
			format.bold = bold;
			format.font = "Arial";
			tf.setTextFormat(format);
			tf.defaultTextFormat = format;
			container.addChild(tf);
		}
		
		public static function setupTextFieldR2(container:Sprite, name:String,
																						x:Number, y:Number, w:Number, h:Number,
																						fontSize:Object, bold:Object=false):TextField {
			var tf:TextField = new TextField();
			tf.autoSize = TextFieldAutoSize.RIGHT;
			tf.text = name;
			setupTextFieldR1(container, tf, x, y, w, h, fontSize, bold);
			return tf;
		}
		
		public static function setupTextFieldR3(container:Sprite,
																						x:Number, y:Number, w:Number, h:Number,
																						fontSize:Object, bold:Object=false):TextField {
			var tf:TextField = setupTextFieldR4(container, x, y, w, h, fontSize, bold);
			tf.border = true;
			return tf;
		}
		
		public static function setupTextFieldR4(container:Sprite,
																						x:Number, y:Number, w:Number, h:Number,
																						fontSize:Object, bold:Object=false):TextField {
			var tf:TextField = new TextField();
			setupTextFieldR1(container, tf, x, y, w, h, fontSize, bold);
			return tf;
		}
		
		public static function setupTextFieldL1(container:Sprite,
																						x:Number, y:Number, w:Number, h:Number,
																						fontSize:Object, bold:Object=false):TextField {
			var tf:TextField = new TextField();
			tf.x = x;
			tf.y = y;
			tf.width = w;
			tf.height = h;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.selectable = false;
			var format:TextFormat = new TextFormat();
			format.align = TextFormatAlign.LEFT;
			format.size = fontSize;
			format.bold = bold;
			format.font = "Arial";
			tf.setTextFormat(format);
			tf.defaultTextFormat = format;
			container.addChild(tf);
			return tf;
		}
		
		public static function setupTextFieldL2(container:Sprite, name:String,
																						x:Number, y:Number, w:Number, h:Number,
																						fontSize:Object, bold:Object=false):TextField {
			var tf:TextField = setupTextFieldL1(container, x, y, w, h, fontSize, bold);
			tf.text = name;
			return tf;
		}
		
		public static function setupTextFieldL34Help(myFont:Font,
																						container:Sprite, name:String,
																						x:Number, y:Number, w:Number, h:Number,
																						fontSize:Object, bold:Object=false):TextField {
			var format:TextFormat = new TextFormat();
			format.align = TextFormatAlign.LEFT;
			format.font = myFont.fontName;
			format.size = fontSize;
			format.bold = bold;
			
			var tf:TextField = new TextField();
			tf.text = name;
			tf.x = x;
			tf.y = y;
			tf.width = w;
			tf.height = h;
			tf.autoSize = TextFieldAutoSize.NONE;
			tf.selectable = false;
			tf.embedFonts = true;
			tf.antiAliasType = AntiAliasType.ADVANCED;
			tf.defaultTextFormat = format;
			tf.setTextFormat(format);
			container.addChild(tf);
			
			return tf;
		}

		public static function setupTextFieldL3(container:Sprite, name:String,
																						x:Number, yTop:Number, w:Number, hFrame:Number,
																						fontSize:Object, bold:Object=false):TextField {
			var myFont:Font = new ArialRegularFont();
			return setupTextFieldL34Help(myFont, container, name, x, yTop, w, hFrame, fontSize, bold);
		}
		
		public static function setupTextFieldL4(container:Sprite, name:String,
																						x:Number, yTop:Number, w:Number, hFrame:Number,
																						fontSize:Object, bold:Object=false):TextField {
			var myFont:Font = new ArialBoldFont();
			var ret:TextField = setupTextFieldL34Help(myFont, container, name, x, yTop, w, hFrame, fontSize, bold);
			ret.rotation = -90;
			return ret;
		}

		public static function generateRandomNumber(minNum:Number, maxNum:Number):Number {
			return (Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum);
		}
		
		public static function setupBackground(container:Sprite,
																					 color:uint, alpha:Number,
																					 x:Number, y:Number, w:Number, h:Number):void {
			var bg:Shape = new Shape();
			bg.graphics.beginFill(color, alpha);
			bg.graphics.drawRect(x, y, w, h);
			bg.graphics.endFill();
			container.addChild(bg);
		}
		
		public static function setupRoundBackground(container:Sprite,
																					 color:uint, alpha:Number,
																					 x:Number, y:Number, w:Number, h:Number,
																					 eW:Number, eH:Number):void {
			var bg:Shape = new Shape();
			bg.graphics.beginFill(color, alpha);
			bg.graphics.drawRoundRect(x, y, w, h, eW, eH);
			bg.graphics.endFill();
			container.addChild(bg);
		}
		
		public static function boldFormat():TextFormat {
			var boldFormat:TextFormat = new TextFormat();
			boldFormat.bold = true;
			return boldFormat;
		}
		
		public static function boldCenterFormat():TextFormat {
			var ret = boldFormat()
			ret.align = TextFormatAlign.CENTER;
			return ret;
		}
		
		public static function getBgColor(useCategory:String):uint {
			var color:uint;
			switch (useCategory) {
				case WaterConsts.USE_FARM_NAME:
					color = WaterConsts.FARM_BG_COLOR;
					break;
				case WaterConsts.USE_MINING_NAME:
					color = WaterConsts.MINING_BG_COLOR;
					break;
				case WaterConsts.USE_INDUSTRIAL_NAME:
					color = WaterConsts.INDUSTRIAL_BG_COLOR;
					break;
				case WaterConsts.USE_URBAN_NAME:
					color = WaterConsts.URBAN_BG_COLOR;
					break;
				default:
					color = WaterConsts.FARM_BG_COLOR;
					break;
			}
			return color;
		}
	}
}
