package code {

  public final class WaterConsts {

		## Basically a big enum file i think

		public static const DATA_SIZE:int = 30;
		// remember to change the stage Size (plus 1) too if these two numbers are to be changed;
		public static const GAME_WIDTH:Number = 970;
		public static const GAME_HEIGHT:Number = 670;
		public static const TITLE_BG_HEIGHT:Number = 51;
		public static const USE_WIDTH:Number = 120;
		public static const USE_HEIGHT:Number = 26;
		public static const USE_POINT_DELTA_Y:Number = 2;
   		public static const PIPE_WIDTH:Number = 40;
		public static const TABLE_CELL_HEIGHT:Number = 18.75;
		// the manageMenu in the LIBRARY needs to be changed too if we change these two values;
		public static const MENU_HEIGHT:Number = 22;
		public static const MENU_WIDTH:Number = 200;
		public static const SCORE_DATA_SIZE:int = 8;
		public static const MAX_TOTAL_POINTS:int = 111200;
		public static const MAX_RUNOFF:int = 20000;
		
		public static const STRING_ZERO:String = "0";
		## Game Title
		public static const GAME_TITLE:String = "WATER\nGAME";
		public static const ACRE_FEET_NAME:String = "ACRE-FEET";
		public static const TOTAL_WATER_USE_NAME:String = "WATER USE\nPOINTS";
		public static const FISH_NAME:String = "FISH";
		public static const GRAND_TOTAL_NAME:String = "GRAND TOTAL";
		public static const SCORE_BOARD_NAME:String = "SCORE BOARD";
		public static const INITIALIZE_ANNUAL_RUNOFF_NAME:String = "Initialize Annual\nRiver Flow";
		public static const RESET_TO_YEAR_ZERO_NAME:String = "Reset to\nYear 0";
		public static const PLAYER_NAME:String = "PLAYER";
		public static const POINTS_NAME:String = "POINTS";
		public static const WITHDRAWAL_REQUEST_NAME:String = "WITHDRAW\nREQUEST";
		public static const USE_FARM_NAME:String = "Farm";
		public static const USE_MINING_NAME:String = "Mining";
		public static const USE_URBAN_NAME:String = "Urban";
		public static const USE_INDUSTRIAL_NAME:String = "Industrial";
		public static const TRADE_NAME:String = "Trade";
		public static const TRADING_NAME:String = "Trading";
		public static const WATER_TRADING_NAME:String = "WATER TRADING";
		public static const WATER_SOLD_NAME:String = "WATER SOLD";
		public static const WATER_BOUGHT_NAME:String = "WATER BOUGHT";
		public static const PRICE_NAME:String = "PRICE";
		public static const AC_FT_NAME:String = "AC-FT";
		public static const CLOSE_WATER_TRADING_NAME:String = "Close Water Trading";
		public static const POINTS_TO_CONTRIBUTE_NAME:String = "Points to contribute";
		public static const CONTRIBUTE_NAME:String = "Contribute";
		public static const POINTS_CONTRIBUTED_NAME:String = "POINTS CONTRIBUTED";
		public static const BUILDING_A_DAM_NAME:String = "Building A Dam";
		public static const BUILD_A_DAM_NAME:String = "Build A Dam";
		public static const USE_POINTS_PER_ACRE_FOOT_NAME:String = "USE POINTS / ACRE-FOOT";
		public static const CLOSE_BUILD_A_DAM_NAME:String = "Close Build A Dam";
		public static const TOTAL_NAME:String = "TOTAL";
		public static const ADD_NAME:String = "Add";
		public static const CHANGE_NAME:String = "Change";
		public static const ALIAS_NAME:String = "Alias";
		public static const ADD_OR_CHANGE_ALIAS_NAME:String = "Add Or Change Alias";
		public static const MINIMUM_FLOW_REQUIREMENT_NAME:String = "Minimum Flow Requirement";
		public static const MINIMUM_FLOW_REQUIREMENT_ACFT_NAME:String = "Minimum Flow Requirement (ac-ft)";
		public static const WATER_MANAGEMENT_OPTIONS_NAME:String = "WATER MANAGEMENT OPTIONS";
		public static const SUBMIT_NAME:String = "Submit";
		public static const STORE_OR_RELEASE_WATER_NAME:String = "Store or release water from dam";
		public static const STORE_WATER_NAME:String = "Store water";
		public static const RELEASE_WATER_NAME:String = "Release water";
		public static const WATER_AMOUNT_NAME:String = "Water amount";
		public static const ERROR_NAME:String = "Error";
		public static const VIEW_DATA_OPTIONS_NAME:String = "VIEW DATA OPTIONS";
		public static const VIEW_TRADING_DATA_NAME:String = "VIEW TRADING DATA";
		public static const VIEW_DAM_DATA_NAME:String = "VIEW DAM DATA";
		public static const VIEW_SCORING_DATA_NAME:String = "VIEW SCORING DATA";
		public static const CLOSE_SCORING_DATA_NAME:String = "Close Scoring Data";
		public static const A_NAME:String = "A";
		public static const B_NAME:String = "B";
		public static const C_NAME:String = "C";
		public static const D_NAME:String = "D";
		public static const F_NAME:String = "F";
		public static const RIVER_FLOW_ACRE_FEET_NAME:String = "RIVER FLOW(ACRE-FEET)";
		public static const INITIAL_SIZE_NAME:String = "Initial Size";
		public static const NONE_AT_THIS_TIME_NAME:String = "None at this time";
		
		public static const BLACK_COLOR:uint = 0x000000;
		public static const RED_COLOR:uint = 0xFF0000;
		public static const ORANGE_COLOR:uint = 0xFFA500;
		public static const TITLE_BG_COLOR:uint = 0x607CBC;
		public static const GAME_BG_COLOR:uint = 0xE4C3A8;
		public static const SUN_COLOR:uint = 0xFFFF00;
		public static const SCOREBOARD_BG_COLOR:uint = 0xFBF49A;
		public static const BUILDADAM_BG_COLOR:uint = 0xECC7DF;
		public static const POPUP_BG_COLOR:uint = 0xD1B8D9;
		public static const WATERTRADING_BG_COLOR:uint = 0xD1B8D9;
		public static const FARM_BG_COLOR:uint = 0x8DC63F;
		public static const MINING_BG_COLOR:uint = 0xDB9B3E;
		public static const INDUSTRIAL_BG_COLOR:uint = 0x99FFFF;
		public static const URBAN_BG_COLOR:uint = 0xE78AB9;
		public static const PIPE_WITHDRAW_COLOR:uint = 0xDDF2FB;
		public static const PIPE_RETURNFLOW_COLOR:uint = 0xBBB9CD;
		public static const USE_BORDER_COLOR:uint = 0x696969;
		public static const RIVER_COLOR:uint = 0x00B0F0;
		public static const GRAY_COLOR:uint = 0x929292;
		public static const WHITE_COLOR:uint = 0xFFFFFF;
		public static const LIGHT_GRAY_COLOR:uint = 0xE1E1E1;
		public static const DAM_COLOR:uint = 0xDDDDDD;
		public static const YELLOW_COLOR:uint = 0xFFFF00;
		public static const GREEN_COLOR:uint = 0x00FF00;
		public static const BLUE_COLOR:uint = 0x0000FF;
		public static const LIGHT_GREEN_COLOR:uint = 0xEAF3D7;
  }
}