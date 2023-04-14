// Universal water value constants
const MIN_RUNOFF = 5000;
const MAX_RUNOFF = 20000; 
const DAM_MAX_CAP = 40000;

// for converting water withdrawn to points
const SCORETYPE = {
  'Farm': 1,
  'Mining': 2,
  'Industrial': 5,
  'Urban': 10
}

// for referencing commonly used original ui colors
const TYPECOLOR = {
  'Farm': '#8DC63F',
  'Mining': '#DB9B3E',
  'Industrial': '#99FFFF',
  'Urban': '#E78AB9'
}

// Locations and properties of blue water blocks from original game
// in a ~700x700 area. These have been converted from original co-
// ordinates which included the rest of the game in the play space
// X and Y values indicate location of name label, centerx and 
// centery refer to the center location of the blue block itself.
const BLOCKDATA = [
  {isLeft:true,  x:100, y:40,   centerX:385, centerY:130, angle:45},
  {isLeft:false, x:548, y:200,  centerX:390, centerY:150, angle:40},
  {isLeft:true,  x:70,  y:75,   centerX:355, centerY:150, angle:40},
  {isLeft:false, x:528, y:235,  centerX:340, centerY:170, angle:35},
  {isLeft:true,  x:40,  y:110,  centerX:340, centerY:170, angle:25},
  {isLeft:true,  x:40,  y:140,  centerX:320, centerY:190, angle:20},
  {isLeft:true,  x:40,  y:170,  centerX:300, centerY:210, angle:15},
  {isLeft:true,  x:40,  y:200,  centerX:300, centerY:240, angle:10},
  {isLeft:false, x:508, y:270,  centerX:310, centerY:250, angle:10},
  {isLeft:true,  x:40,  y:235,  centerX:300, centerY:270, angle:5},
  {isLeft:false, x:508, y:305,  centerX:310, centerY:290, angle:5},
  {isLeft:true,  x:40,  y:270,  centerX:310, centerY:310, angle:0},
  {isLeft:true,  x:40,  y:300,  centerX:310, centerY:340, angle:0},
  {isLeft:false, x:528, y:340,  centerX:340, centerY:350, angle:0},
  {isLeft:true,  x:40,  y:335,  centerX:340, centerY:370, angle:0},
  {isLeft:false, x:528, y:375,  centerX:360, centerY:390, angle:-5},
  {isLeft:true,  x:40,  y:370,  centerX:360, centerY:400, angle:0},
  {isLeft:false, x:548, y:410,  centerX:390, centerY:417, angle:-5},
  {isLeft:false, x:548, y:440,  centerX:390, centerY:440, angle:0},
  {isLeft:false, x:548, y:470,  centerX:390, centerY:460, angle:15},
  {isLeft:true,  x:50,  y:405,  centerX:360, centerY:470, angle:20}, //suspect for top
  {isLeft:false, x:538, y:505,  centerX:380, centerY:480, angle:30},
  {isLeft:false, x:528, y:535,  centerX:355, centerY:490, angle:45},
  {isLeft:false, x:528, y:565,  centerX:340, centerY:510, angle:50},
  {isLeft:true,  x:50,  y:440,  centerX:330, centerY:490, angle:15},
  {isLeft:true,  x:50,  y:470,  centerX:320, centerY:525, angle:15},
  {isLeft:true,  x:50,  y:500,  centerX:310, centerY:550, angle:10},
  {isLeft:false, x:528, y:600,  centerX:316, centerY:570, angle:20},
  {isLeft:true,  x:50,  y:535,  centerX:310, centerY:590, angle:5},
  {isLeft:true,  x:50,  y:565,  centerX:310, centerY:620, angle:0},
];

// Global state table, containing important information for all of the game.
// under the impression that this is usually bad practice, but it is exceedingly
// useful in this specific case.
// both locations arrays should at all times refer to the same Location objects,
// just in different orders.

let state = {
  year: null,
  score: 0,
  fishscore: 0,
  usescore: 0,
  scorehistory: [],
  locationsbypriority: [],
  locationsbyposition: [],
  runoff: null,
  initrunoff: 0,
  minflowreq: 0,
  trades: [],
  damfund: 0,
  damdonos: {},
  damactive: false,
  damheldvol: 0,
  damcap: 0,
}

// Class of each location, which contains the state of the location and 
// the river surrounding it.
class Location{
  constructor(name,position,priority,year,type,percentconsumed,requested){
    this.name = name;
    this.position = position;
    this.priority = priority;
    this.year = year;
    this.type = type;
    this.percentconsumed = percentconsumed;
    this.requested = requested
    this.allotted = 0;
    this.withdrawn = 0;
    this.points = 0;
    this.tradevol = 0;
    this.tradepoints = 0;
    this.waterafterposition = 0;    
  }
}

// For use in the Trades array in state.
class Trade{
  constructor(player1, player2, volume, priceperunit){
    this.player1 = player1;
    this.player2 = player2;
    this.volume = volume;
    this.priceperunit = priceperunit;
    this.price = volume * priceperunit;
  }
}

// Gross but necessary initial setup of locations.
function setupLocationData(){
  let locations = [];
  locations.push(new Location("Pueblo Farm", 16, 1, "1803", "Farm", .80, 100))
  locations.push(new Location("Pueblo Farm", 23, 2, "1810", "Farm", .80, 200))
  locations.push(new Location("Pueblo Farm", 15, 3, "1817", "Farm", .80, 100))
  locations.push(new Location("Spanish Gold Mine", 9, 4, "1824", "Mining", .10, 100))
  locations.push(new Location("Spanish Silver Mine", 7, 5, "1831", "Mining", .10, 300))
  locations.push(new Location("Spanish Wheat Farm", 24, 6, "1838", "Farm", .80, 100))
  locations.push(new Location("Spanish Cattle Ranch", 10, 7, "1845", "Farm", .80, 400))
  locations.push(new Location("Spanish Bean Farm", 12, 8, "1852", "Farm", .80, 800))
  locations.push(new Location("Spanish Bean Farm", 25, 9, "1859", "Farm", .80, 1400))
  locations.push(new Location("Spanish Bean Farm", 28, 10, "1866", "Farm", .80, 2000))
  locations.push(new Location("Spanish Corn Farm", 20, 11, "1873", "Farm", .80, 500))
  locations.push(new Location("Spanish Copper Mine", 2, 12, "1881", "Mining", .10, 600))
  locations.push(new Location("Spanish Lumber Mill", 8, 13, "1888", "Industrial", .30, 200))
  locations.push(new Location("Spanish Cattle Ranch", 19, 14, "1895", "Farm", .80, 300))
  locations.push(new Location("Anglo Copper Mine", 4, 15, "1902", "Mining", .10, 400))
  locations.push(new Location("Anglo Wheat Farm", 26, 16, "1909", "Farm", .80, 500))
  locations.push(new Location("Cuidad Juarez, MX", 29, 17, "1916", "Urban", .20, 500))
  locations.push(new Location("Anglo Cotton Farm", 18, 18, "1923", "Farm", .80, 800))
  locations.push(new Location("Anglo Cotton Farm", 22, 19, "1930", "Farm", .80, 200))
  locations.push(new Location("Anglo Wheat Farm", 5, 20, "1937", "Farm", .80, 400))
  locations.push(new Location("Microprocessor Plant", 30, 21, "1994", "Industrial", .30, 1000))
  locations.push(new Location("Anglo Orchard", 6, 22, "1951", "Farm", .80, 300))
  locations.push(new Location("Anglo Cattle Ranch", 1, 23, "1958", "Farm", .80, 1500))
  locations.push(new Location("El Paso, TX", 27, 24, "1965", "Urban", .20, 2000))
  locations.push(new Location("Anglo Dairy Farm", 21, 25, "1972", "Farm", .80, 400))
  locations.push(new Location("Anglo Dairy Farm", 3, 26, "1979", "Farm", .80, 3000))
  locations.push(new Location("Anglo Cotton Farm", 14, 27, "1986", "Farm", .80, 300))
  locations.push(new Location("Albequerque, NM", 11, 28, "1993", "Urban", .20, 4000))
  locations.push(new Location("Anglo Organic Farm", 13, 29, "2000", "Farm", .80, 100))
  locations.push(new Location("Las Cruces, NM", 17, 30, "2007", "Urban", .20, 400))

  // Two independent shallow copy list of these locations into state
  // the changes to the locations will be synced, but they're ordered
  // differently. 'locationsbypriority' is used for initial allocation
  // and 'locationsbyposition' is used for physical withdrawals.
  state.locationsbypriority = [...locations];
  state.locationsbyposition = [...locations];
  state.locationsbypriority.sort((a,b) => (a.priority > b.priority) ? 1 : -1);
  state.locationsbyposition.sort((a,b) => (a.position > b.position) ? 1 : -1);
}

// Generate new runoff.
function setNewRunoff(setval = -1){
  // This setting is the default functionality, which generates a random runoff
  if(setval == -1){
    state.runoff = Math.floor(Math.random() * (MAX_RUNOFF - MIN_RUNOFF + 1)) + MIN_RUNOFF;
    state.initrunoff = state.runoff;
  }
  // This case is for debug and testing purposes, where a specific runoff is desired.
  else{
    state.runoff = setval;
    state.initrunoff = state.runoff;
  }
  calculateFlows();
}

// Make and register a trade.
function makeTrade(sellerprio, buyerprio, volume, priceperunit){
  seller = state.locationsbypriority[sellerprio-1];
  buyer = state.locationsbypriority[buyerprio-1];
  console.log(`${seller.name} (${seller.priority}) sells 
    ${volume} ac-ft of water to ${buyer.name} (${buyer.priority})
    at ${priceperunit} per ac-ft, for a total of ${volume * priceperunit}.`);
  state.trades.push(new Trade(seller.priority, buyer.priority, volume, priceperunit));
  seller.tradevol -= volume;
  seller.tradepoints += priceperunit * volume;
  console.log(`typeof buyer.tradevol: ${typeof buyer.tradevol} typeof volume = ${typeof volume}`);
  buyer.tradevol += volume;
  buyer.tradepoints -= priceperunit * volume;
  calculateFlows();
}

// A single player puts points forth towards the construction of a dam.
// This updates their contribution in what will become the "dam chart" in the game.
function fundDam(funderprio, amt){
  if(state.damactive == 1){
    console.log("Error: Cannot fund dam that already exists.");
    return;
  }
  else{
    funder = state.locationsbypriority[funderprio-1];
    funder.points -= amt;
    state.damdonos[funderprio] ??= 0;
    state.damdonos[funderprio] = state.damdonos[funderprio] + amt;
    state.damfund += amt;
    console.log(`Location ${funder.name} (${funder.priority}) successfully added
      ${amt} to dam fund, bringing their contribution to ${state.damdonos[funderprio]}
      of a total of ${state.damfund}.`);
    return;
  }
}

// Activates dam, allowing it to be used to store and release water at the beginning
// of each year.
function buildDam(){
  state.damactive = true;
  state.damcap = state.damfund;
  return true;
}

// Fills the dam with some of the runoff for the year.
function fillDam(amt){
  state.damheldvol += amt;
  state.runoff -= amt;
  console.log(`Dam filled with ${amt} units of water.
    Current Dam Holdings: ${state.damheldvol}
    Dam Capacity: ${state.damcap}`);
    calculateFlows();
    updateVisible();
  return;
}

// Releases some of the stored water from the dam to add to the effective
// runoff for the year.
function releaseDam(amt){
  console.log(`Withdrew ${amt} of water from dam.
    Current Dam Holdings: ${state.damheldvol}
    Dam Capacity: ${state.damcap}`);
  state.runoff += amt;
  state.damheldvol -= amt;
  calculateFlows();
  updateVisible();
  return;
}

// This function takes the rules and trades that the players have
// set forth in their interaction with the game and calculates the
// throughput and usage of every location in the game based on the
// proceedings found in the original flash game: First a theoretical
// priority-based flow model to determine each location's "lot" of
// the water, and then a physical model that relies on position to
// actually dole out the water.
function calculateFlows(){

  state.currentwaterflow = state.runoff;

  //initial theoretical cycle
  for(loc of state.locationsbypriority){
    //theoretical inflow
    loc.allotted = Math.max(0, Math.min(loc.requested,
     state.currentwaterflow - state.minflowreq));
    state.currentwaterflow -= loc.allotted;
    //calculate t.consumption into outflow
    state.currentwaterflow += (loc.allotted * (1 - loc.percentconsumed));
  }

  //ending theoretical cycle, resetting river flow
  state.currentwaterflow = state.runoff;

  for(loc of state.locationsbyposition){
    loc.withdrawn = Math.min(state.currentwaterflow,
     loc.allotted + loc.tradevol);
    state.currentwaterflow -= (loc.withdrawn * (loc.percentconsumed));
    loc.waterafterposition = Math.round(state.currentwaterflow);  
  }
  updateScore(state.currentwaterflow);
}

// Calculate scores.
function updateScore(remainingflow){

  globalpoints = 0;
  usagepoints = 0;
  fishpoints = Math.min(10*remainingflow, 20000);
  for(loc of state.locationsbypriority){
    loc.points = loc.withdrawn * SCORETYPE[loc.type] + loc.tradepoints;
    usagepoints += loc.points;
  }
  
  globalpoints = Math.round(usagepoints + fishpoints)
  // console.log(`Usage Points: ${usagepoints.toFixed(0)}\nFish ` +
  //  `Points: ${fishpoints.toFixed(0)}\nTotal Points: ${globalpoints}`);
  state.score = globalpoints;
  state.fishscore = fishpoints;
  state.usescore = Math.round(usagepoints);

}

// Add score and runoff to score history and card.
// Uses NEWSCORE type, where each year is catalogued as soon as the next year is started.
function submitScore(score){
  state.scorehistory.push(
    {
      year: state.year,
      initrunoff: state.initrunoff,
      finalscore: state.score
    }
  );
  updateScoreHistoryGraph();
}

// Set the game to play from the first year. This resets all state values
// and destroys the scoring history.
function initializeGame(){
  state.year = 0;
  state.score = 0;
  state.scorehistory = [];
  state.runoff = 0;
  state.initrunoff = 0;
  state.minflowreq = 0;
  state.trades = [];
  state.damfund = 0;
  state.damactive = false;
  state.damheldvol = 0;
  state.damcap = 0;
}

// Handles updating visible HTML elements according to the state.
// Also rescales the Paper.js visualizer.
function updateVisible() {
  let scoreboardtable = document.getElementById("scoretable");
  for(let i = 1; i < 16; i++){
    firstloc = state.locationsbypriority[i-1];
    secondloc = state.locationsbypriority[i+14];
    scoreboardtable.rows[i].innerHTML = `
        <td class="normalcol ${firstloc.type}">${firstloc.priority}</td>
        <td class="normalcol ${firstloc.type}">${firstloc.requested}</td>
        <td class="normalcol ${firstloc.type}">${Math.round(firstloc.points)}</td>
        <td class="nullcol"></td>
        <td class="normalcol ${secondloc.type}">${secondloc.priority}</td>
        <td class="normalcol ${secondloc.type}">${secondloc.requested}</td>
        <td class="normalcol ${secondloc.type}">${Math.round(secondloc.points)}</td>
    `;
  }
  let damdatatable = $("#dam-data-table")[0];
  htmlstring = '';
  for(entry of Object.entries(state.damdonos)){
    player = entry[0];
    value = entry[1];
    htmlstring = htmlstring + `<tr><td>${player}</td><td>${value}</td></tr>`;
  }
  $("#dam-table-body").html(htmlstring);
  $("#dam-total-contribution").text(state.damfund);
  htmlstring = '';
  for(entry of state.trades){
    htmlstring = htmlstring + `<tr><td>${entry.player1}</td><td>-${entry.volume}</td>
    <td>${entry.priceperunit}</td><td>${entry.player2}</td><td>${entry.volume}</td>`;
  }
  $("#trading-table-body").html(htmlstring)
  document.getElementById("year-display").innerHTML = `Year ${state.year}`;
  document.getElementById("acrefeet-display").innerHTML = state.runoff;
  $("#minflow-label").text(`Minimum Required Flow: ${state.minflowreq}`);
  if(typeof charts[0] != 'undefined'){
    charts[0].data.datasets[0].data = [state.usescore];
    charts[0].data.datasets[1].data = [state.fishscore];
    charts[0].update();
  }
  if(typeof riverconstructs != 'undefined' && riverconstructs.length > 0){
    
    project.activeLayer.bounds = (
      new Rectangle({
        x:0,
        y:0,
        width: 628,
        height: 620,
      })
    );
    constructVis();

    project.activeLayer.fitBounds(
      new Rectangle({
        x:0,
        y:0,
        width: paper.view.bounds.width - 40,
        height: paper.view.bounds.height - 40,
      })
    );

  } 
}

// Dedicated update of Score History graph. Seperated
// from updateVisible to allow for resetting graph in
// a way Chart.js appreciates.
function updateScoreHistoryGraph(reset = false){
  scoreplotpoints = [];
  if(reset === true){
    charts[1].data.datasets[0].data = [];
  }
  for(score of state.scorehistory){
    scoreplotpoints.push(
      {
        x: score.initrunoff,
        y: score.finalscore
      }
    );
    charts[1].data.datasets[0].data = scoreplotpoints;
  }
  charts[1].update();
}

// This function handles the state information changes that
// occur when a year passes from one to the other.
// The original game has this step entail several things: 
// - Initialize new runoff.
// - Prompt users to interact with the dam (if a dam exists)
// - Record the previous year's final scoring output in history
// - Clear previous year information (other than score and
//      dam info
function passYear() {
  submitScore(state.score);
  state.year += 1;
  state.trades = [];
  for(loc of state.locationsbypriority){
    loc.allotted = 0;
    loc.withdrawn = 0;
    loc.points = 0;
    loc.tradevol = 0;
    loc.tradepoints = 0;
  }
  setNewRunoff();
  calculateFlows();
  updateVisible();
  if(state.damactive){
    $("#use-dam-form").dialog("open");
  }
}

// For use in the Reset button in HTML file. Cleans up any 
// UI changes, Sets new runoff, clears state.
function resetGame() {
  state.year = 0;
  state.trades = [];
  state.scorehistory = [];
  state.damfund = 0;
  state.damdonos = {};
  state.damactive = false;
  state.damheldvol = 0;
  state.damcap = 0;
  state.minflowreq = 0;
  for(loc in state.locationsbypriority){
    loc.allotted = 0;
    loc.withdrawn = 0;
    loc.points = 0;
    loc.tradevol = 0;
    loc.tradepoints = 0;
  } 
  setNewRunoff(7000);
  calculateFlows();
  updateVisible();
  cleanupUI();
  updateScoreHistoryGraph(true);
}

// HTML/CSS FUNCTIONS FROM HERE OUT

//global variable that will keep track of chart objects that need to be refreshed
let charts = [];

function unfoldManagementOptions(){
  document.getElementById("management-options").classList.toggle("showDrop");
}

function unfoldDataOptions(){
  document.getElementById("data-options").classList.toggle("showDrop");
}

function minFlowReqPrompt(){
  $("#minflow-form").dialog("open");
}

function tradePrompt(){
  $("#trade-form").dialog("open");
}

function damPrompt(){
  $("#build-dam-form").dialog("open");
}

// Everything that changes the UI's form from the beginning of the game
// needs to be cleaned up after a game reset. 
function cleanupUI(){
  $("#dam-checkmark").hide();
  $("#dam-option").css({
    'pointer-events':'auto',
    'color'    :'black'
  });
}

// Used when player clicks "contribute" in dam building dialog.
function contributeDam(){
  const response = $("#build-dam-form-info").serializeArray();
  let player = response[0].value;
  let points = response[1].value;
  let maxallowedpoints = DAM_MAX_CAP - state.damfund;
  if(!/^[0-9]*$/.test(points) || points == "" || parseInt(points) <= 0){
    $("#build-dam-warning").text("Contribution amount must be a positive integer!");
    return
  }
  points = parseInt(points);
  playerpoints = Math.floor(state.locationsbypriority[player-1].points);
  if(points > playerpoints){
    $("#build-dam-warning").text(`Player ${player} can only contribute up to ${playerpoints} points!`);
    return
  }
  if(points > maxallowedpoints){
    $("#build-dam-warning").text(`The dam can only have ${DAM_MAX_CAP} donated total.
    You can donate ${maxallowedpoints} more.`);
  }
  else{
    fundDam(player,points);
    $("#build-dam-warning").text("Contribution accepted.");
    $("#build-dam-form-info")[0].reset();
    updateVisible();
  }

}

// Toggles visibility of trading data window, making sure that when it's not visible,
// doesn't eat any click events for objects that ARE visible by using z-indexes.
function viewTradingData(){
  $( "#trading-data-container" ).toggleClass("invisible");

  isDisabled = $( "#trading-data-container" ).draggable( "option", "disabled" );
  if(isDisabled){
    $( "#trading-data-container" ).draggable("enable").css("z-index", "51");
  } else {
    $( "#trading-data-container" ).draggable("disable").css("z-index","-29");
  }

}

// Same as above, but for the Dam contribution data, which should be under 
// the trading table. 
function viewDamData(){
  $( "#dam-data-container" ).toggleClass("invisible");

  isDisabled = $( "#dam-data-container" ).draggable( "option", "disabled" );
  if(isDisabled){
    $( "#dam-data-container" ).draggable("enable").css("z-index", "50");
  } else {
    $( "#dam-data-container" ).draggable("disable").css("z-index","-30");
  }
}

// Scoring data graph shoudl be above every other togglable table.
function viewScoringData(){
  $( "#scoring-history-container").toggleClass("invisible");

  isDisabled = $( "#scoring-history-container" ).draggable( "option", "disabled" );
  if(isDisabled){
    $( "#scoring-history-container" ).draggable("enable").css("z-index", "52");
  } else {
    $( "#scoring-history-container" ).draggable("disable").css("z-index","-28");
  }
}

// Downloads state as JSON Data. Needs to use URI w/ data: prefix because Firefox, chromium browsers like
// opening these outright if they're marked as blob: instead of downloading them
function saveGame(){
  var stateURI = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(state, function(key, val){
    if(key == "locationsbyposition"){
      // We will reconsitute this list later to avoid making two actual different lists. Remember, the sorted lists
      // consist of the pointers to shared objects.
      return undefined
    } else { return val }
  }));
  var elem = document.createElement('a');
  elem.setAttribute("href", stateURI);
  elem.setAttribute("download", "gamesave.json");
  elem.click();
}

// Loading game from user's file selection.
function loadGame(){
  var input = document.createElement('input');
  input.type = 'file';

  input.onchange = (e) => { 

    var file = e.target.files[0]; 
 
    var reader = new FileReader();
    reader.readAsText(file,'UTF-8');
 
    reader.onload = readerEvent => {
      var content = readerEvent.target.result; 
      state = JSON.parse(content);

      //reconstitute the second list
      state.locationsbyposition = [...state.locationsbypriority];
      state.locationsbyposition.sort((a,b) => (a.position > b.position) ? 1 : -1);

      calculateFlows();
      updateVisible();

       //reload non-automatic UI elements
      if(state.damactive == true){
        $("#dam-checkmark").show();
        $("#dam-option").css({
          'pointer-events':'none',
          'color'         :'#919191'
        });
      }
      updateScoreHistoryGraph();
    }
 
  }

  // Would be very interested in seeing if there is any other, better version of
  // this functionality that causes the same file explorer behavior without having
  // to use this hacky method of making a fake button and clicking it
  input.click();
}


// This is a list of every paper.js object or Path that is instantiated during
// the river visualization process, which is then to be used to remove all of them
// from the project upon a new visualization being requested. This is necessary
// to prevent a gigantic memory leak
let riverconstructs = [];

// Placing every river object according to the state.
function constructVis() {

  // Remove all paths, drawn or not, from the canvas
  for(construct of riverconstructs){
    construct.remove();
  }
  // Reset riverconstructs to let contents be garbage collected
  riverconstructs = []

  // Each location is represented by:
  //  - A river block (blue water)
  //  - Two pipes (one return, one withdraw)
  //  - A Location label
  //  - lines connecting the label to the pipes
  // The block and pipes are turned together based on the block's
  // position and angle, while the label is static.
  for(let i = 0; i < 30; i++){
    // River block and label position and angle information for this location
    block = BLOCKDATA[i];
    // State information for this location
    let blocksloc = state.locationsbyposition[i];
    let newblock = new Path.Rectangle({
      point: [block.centerX, block.centerY],
      size: [1, 40],
      fillColor: '#00B0F0',
      name: `bg${i}block`
    });

    // Should contain blocks and all parts of both pipes 
    let blockpipegroup = new Group({
      name: `bg${i}`
    });
    riverconstructs.push(blockpipegroup);
    
    // Stretch block horizontally according to the river's volume after
    newblock.scale((blocksloc.waterafterposition)/100, 1);

    riverconstructs.push(newblock);
    blockpipegroup.addChild(newblock);
    
    // Determining offsets and curve locations to change on
    // the pipe, which is normally a rectangle without these
    // changes
    let posX;
    let capside;
    if(block.isLeft === true){
      // Offset so pipe's end rests in the water
      posX = newblock.segments[0].point.x - 20;
      // corners that will be rounded, other covered with circle
      smoothend = [0, 1]
      // Which side the aforementioned circle will cover
      capside = 3;
      // How far vertically up the attaching line should start on the
      // pipe.
      pointattachoffset = -5;
    } else {
      posX = newblock.segments[2].point.x + 20;
      smoothend = [2, 3]
      capside = 0;
      pointattachoffset = 5;
    }

    //This determines whether pipe is red or not
    let notenoughwater = false;
    if(blocksloc.withdrawn != blocksloc.requested){
      notenoughwater = true
    }

    // Withdraw pipe base rectangle
    let withdrawpipebase = new Path.Rectangle({
      point: [posX-20,newblock.position.y-15],
      size: [40,12],
      fillColor: (notenoughwater ? '#FF0000' : '#DDF2FB'),
      strokeColor: 'black',
      name: `pg${i}wdpipebase`
    });
    // smooth smooth end to make the edge furthest away from the 
    // river round
    withdrawpipebase.smooth({
      type: 'continuous',
      from: smoothend[0],
      to: smoothend[1],
    });
    blockpipegroup.addChild(withdrawpipebase);

    // Label for withdraw pipe, content is how much water was withdrawn
    // from location
    let wtext = new PointText({
      point: [withdrawpipebase.position.x, withdrawpipebase.position.y+4],
      fontSize: 10,
      fontWeight: 'bold',
      fillColor: (notenoughwater ? '#FFFFFF' : '#000000'),
      content: Math.round(blocksloc.withdrawn),
      justification: 'center',
      name: `pg${i}wdtext`
    });
    blockpipegroup.addChild(wtext);

    // Circle for edge of pipe nearest river to give cylindrical appearance
    let wdcapline = new Path.Ellipse({
      center: [withdrawpipebase.segments[capside].point.x, withdrawpipebase.segments[capside].point.y - 6],
      radius: [6, 6],
      fillColor: (notenoughwater ? '#FF0000' : '#DDF2FB'),
      strokeColor: "black",
      name: `pg${i}wdcap`
    });
    blockpipegroup.addChild(wdcapline);

    // Guide point for circle below
    let wpointforline = new Point({
      x: withdrawpipebase.segments[smoothend[0]].point.x + pointattachoffset,
      y: withdrawpipebase.segments[smoothend[0]].point.y + pointattachoffset,
      name: 'wpointforline',
    });

    // Invisible circle path that stores a location that can be rotated 
    // for the line connection
    let wguidecircle = new Path.Circle({
      center: wpointforline,
      name: 'wguidecircle',
    });
    blockpipegroup.addChild(wguidecircle);

    // Base rectangle for pipe
    let returnpipebase = new Path.Rectangle({
      point: [posX-20,newblock.position.y],
      size: [40,12],
      fillColor: (notenoughwater ? '#FF0000' : '#BBB9CD'),
      strokeColor: 'black',
      name: `pg${i}rtpipebase`
    });
    // Smooth pipe on furthest side for circular edge
    returnpipebase.smooth({
      type: 'continuous',
      from: smoothend[0],
      to: smoothend[1],
    });
    blockpipegroup.addChild(returnpipebase);

    // Text on pipe
    let rtext = new PointText({
      point: [returnpipebase.position.x, returnpipebase.position.y+4],
      fontSize: 10,
      fontWeight: 'bold',
      fillColor: (notenoughwater ? '#FFFFFF' : '#000000'),
      content: Math.round((blocksloc.withdrawn * (1 - blocksloc.percentconsumed))),
      justification: 'center',
      name: `pg${i}rttext`
    })
    blockpipegroup.addChild(rtext);

    // Circle to give cylindrical appearance
    let rtcapline = new Path.Ellipse({
      center: [returnpipebase.segments[capside].point.x, returnpipebase.segments[capside].point.y - 6],
      radius: [6, 6],
      fillColor: (notenoughwater ? '#FF0000' : '#BBB9CD'),
      strokeColor: "black",
      name: `pg${i}rtcap`
    });
    blockpipegroup.addChild(rtcapline);

    // Guide for guide circle
    let rpointforline = new Point({
      x: returnpipebase.segments[smoothend[0]].point.x + pointattachoffset,
      y: returnpipebase.segments[smoothend[0]].point.y + pointattachoffset,
      name: 'rpointforline'
    });
    // Invisible circle to store a point that will be referenced after block
    // is rotated for connecting line
    let rguidecircle = new Path.Circle({
      center: rpointforline,
      name: 'rguidecircle'
    });
    blockpipegroup.addChild(rguidecircle);
    riverconstructs.push(rguidecircle);
    
    //Rotate everything up to this point to give the same visual
    // that is present in the original game
    blockpipegroup.rotate(block.angle);

    // DAM CREATION;
    if(i == 1 && state.damactive == true){
      let capoffset = 100 * (state.damcap / DAM_MAX_CAP);
      let volheldoffset = capoffset * (state.damheldvol / state.damcap);
      let curvelength = newblock.curves[1].length;
      let midpoint = newblock.curves[1].getPointAt(curvelength/2);
      let tanvec = newblock.curves[1].getTangentAt(curvelength/2).multiply(100);
      let normvec = newblock.curves[1].getNormalAt(curvelength/2).multiply(80);
      let startpoint = midpoint.subtract(tanvec);
      let endpoint = midpoint.add(tanvec);
      
      //Big gray wall for dam
      let wallpath = new Path({
        strokeColor: 'black',
        closed: true,
        fillColor: '#DDDDDD',
        name: 'wallpath',
      });
      wallpath.add(startpoint, endpoint,[endpoint.x, (endpoint.y - capoffset)] ,[startpoint.x, (startpoint.y - capoffset)]);
      
      // These are the invisible points along the base of the backside of the wall
      // that the confines of the dam are based off of
      let targetline = wallpath.curves[0];
      let targetpoint1 = targetline.getPointAt(targetline.length*.8);
      let targetpoint2 = targetline.getPointAt(targetline.length*.2);
      let targetpoint3 = targetpoint2.add(normvec).add(tanvec.divide(2));
      let targetpoint4 = targetpoint1.add(normvec).add(tanvec.divide(2));

      // Bottommost water-containing dam line.
      let baseloop = new Path({
        strokeColor: 'black',
        closed: true,
        name: 'baseloop'
      });
      baseloop.add(targetpoint1, targetpoint2, targetpoint3, targetpoint4);

      // Topmost dam line defining how much water the dam can hold
      let toploop = new Path({
        strokeColor: 'black',
        closed: true,
        name: 'toploop',
      });
      toploop.add(
        [targetpoint1.x, (targetpoint1.y-capoffset)],
        [targetpoint2.x, (targetpoint2.y-capoffset)],
        [targetpoint3.x, (targetpoint3.y-capoffset)],
        [targetpoint4.x, (targetpoint4.y-capoffset)],
      );
      // vertical line at rightmost of dam to define shape of dam
      let backwall = new Path.Line({
        from: [targetpoint4.x, targetpoint4.y-capoffset],
        to: targetpoint4,
        strokeColor: 'black',
        name: 'backwall'
      });

      // Dam lines that define the surface of the dam's contents
      let heldloop = new Path({
        strokeColor: 'black',
        closed: true,
        name: 'heldloop',
      });
      heldloop.add(
        [targetpoint1.x, (targetpoint1.y-volheldoffset)],
        [targetpoint2.x, (targetpoint2.y-volheldoffset)],
        [targetpoint3.x, (targetpoint3.y-volheldoffset)],
        [targetpoint4.x, (targetpoint4.y-volheldoffset)],
      );
      
      // The "side" of the dam's contents.
      let waterwall = new Path({
        closed: true,
        name: 'waterwall',
      });
      waterwall.add(
        targetpoint1,
        [targetpoint1.x, (targetpoint1.y-volheldoffset)],
        [targetpoint4.x, (targetpoint4.y-volheldoffset)],
        targetpoint4,
      );
      // Don't make the dam blue if there's nothing in it
      if(volheldoffset != 0){
        heldloop.fillColor = '#00B0F0'
        waterwall.fillColor = '#00B0F0'
      }
      riverconstructs.push(waterwall, heldloop, backwall, toploop, baseloop, wallpath);

      //Making sure lines are covered up correctly by other paths
      baseloop.bringToFront();
      toploop.bringToFront();
      wallpath.bringToFront();
    }
    
    // The location "user" of the water's label.
    let newuse = new Path.Rectangle({
      point: [block.x, block.y],
      size: [120,25],
      strokeColor: "black",
      fillColor: TYPECOLOR[blocksloc.type],
      name: 'newuse'
    });
    
    riverconstructs.push(newuse);

    // Circle whose center that defines the other side of the line that connects
    // The withdrawal pipe to the label
    let wguidecircle2 = new Path.Circle({
      center: [newuse.segments[capside].point.x, newuse.segments[capside].point.y - 22],
      name: 'wguidecircle2',
    });
    riverconstructs.push(wguidecircle2);

    // Line that connects the withdrawal pipe to the label
    let withdrawconnector = new Path.Line({
      from: wguidecircle.position,
      to: wguidecircle2.position,
      strokeColor: 'black',
      name: 'withdrawconnector'
    });
    riverconstructs.push(withdrawconnector);

    // Circle whose center that defines the other side of the line that connects
    // The return pipe to the label
    let rguidecircle2 = new Path.Circle({
      center: [newuse.segments[capside].point.x, newuse.segments[capside].point.y - 3],
      name: 'rguidecircle2'
    });
    riverconstructs.push(rguidecircle2);

    // Line that connects the return pipe to the label
    let returnconnector = new Path.Line({
      from: rguidecircle.position,
      to: rguidecircle2.position,
      strokeColor: 'black',
      name: 'returnconnector'
    })
    riverconstructs.push(returnconnector);

    // The text on the label
    let usetext = new PointText({
      point: [block.x + 60, block.y + 10],
      fontSize: 10,
      fontWeight: 'bold',
      content: `${blocksloc.priority}-${blocksloc.year}\n ${blocksloc.name}`,
      justification: "center",
      name: 'usetext',
    });
    riverconstructs.push(usetext);

  }

  // This block and loop puts the items who've been marked as pipes or
  // pipe components on top of everything else. This is necessary because
  // each block and use label are added one at a time, so later blocks will
  // cover up pipes. This cannot use a paper.js Group because objects have
  // difficulties being in multiple groups at the same time, and these cannot
  // be put on a different layer because of their relationship to the other, 
  // non-pipe objects in the scene (allegedly).
  let objs = project.getItems({
    name: /^pg/
  });
  for(obj of objs){
    riverconstructs.push(obj);
    if(obj.parent.name === "visprojlayer"){
      continue;
    } else {
      obj.addTo(obj.parent.parent);
    }
    obj.bringToFront();
  }
}

//BASE GAME SETUP

paper.install(window);
setupLocationData();
initializeGame();
setNewRunoff(7000);
calculateFlows();

window.onload = function() {
  paper.setup("myCanvas");
  paper.project.activeLayer.name = "visprojlayer"
  constructVis(); //Constructs first here so that the constructVis in updateVisible has
                  //riverconstructs to work with and bounds to stretch the visualizer to
  updateVisible();


  $("#myCanvas").height('100%');
  $("#myCanvas").width($("#myCanvas").height())

  // This line ensures that the height is static and that resizing the window
  // doesn't stretch the aspect ratio of the canvas
  $("#myCanvas").height( $("#myCanvas").height());

  // function for binding to the trading dialog
  function trade(){
    const answers = $("#trade-form-info").serializeArray();
    console.log(answers);
    const seller = answers[0].value;
    const buyer = answers[1].value;
    let volume = answers[2].value;
    let price = answers[3].value;
    const sellerloc = state.locationsbypriority[seller-1];
    const buyerloc = state.locationsbypriority[buyer-1];
    console.log(`seller: ${seller}, buyer: ${buyer}, volume: ${volume}, price: ${price}`);
    console.log(`Seller has ${sellerloc.withdrawn} to sell, Buyer has ${buyerloc.requested-buyerloc.withdrawn} to buy max with ${buyerloc.points} points.`);
    if(!/^[0-9]*$/.test(volume) || volume == "" || parseInt(volume) <= 0){
      $("#trade-warning").text("Volume must be a positive integer!");
      return
    }
    if(!/^[0-9]*$/.test(price) || price == ""){
      $("#trade-warning").text("Price must be an integer!");
      return
    }
    volume = parseInt(volume);
    price = parseInt(price);
    amountlimit = Math.round(Math.min(buyerloc.requested - buyerloc.withdrawn),sellerloc.withdrawn);
    if(seller == buyer){
      $("#trade-warning").text("Buyer must be different from seller!");
      return
    }
    if(volume > (buyerloc.requested - buyerloc.withdrawn)){
      $("#trade-warning").text(`Player ${buyer} can only withdraw ${Math.round(buyerloc.requested - buyerloc.withdrawn)} ac-ft more!`);
      return
    }
    if(volume > sellerloc.withdrawn){
      $("#trade-warning").text(`Player ${seller} can only sell ${Math.round(sellerloc.withdrawn)} ac-ft!`)
      return
    }
    //If the trade would cost more than the buyer could possibly make, allowing negatives in score.
    if(volume * price > (buyerloc.requested * SCORETYPE[buyerloc.type])){
      $("#trade-warning").text(`Transaction comes to ${volume*price} points, and max is ${(buyerloc.requested * SCORETYPE[buyerloc.type])}`);
      return
    }
    else{
      $("#trade-warning").text("");
      makeTrade(seller, buyer, volume, price);
      updateVisible();
      tradeform.dialog("close");
    }
  }

  // bound function for minflow dialog
  function updateMinFlowReq(){
    let answer = $( "#minflow-form-info" ).serializeArray()[0].value;
    console.log(answer);
    if(/^[0-9]*$/.test(answer) && parseInt(answer) > 0){
      console.log(`Setting MinFlowReq to ${answer}`)
      $("#minflow-warning").text("");
      state.minflowreq = parseInt(answer);
      $("#minflow-label").text(`Minimum Required Flow: ${state.minflowreq}`);
      calculateFlows();
      updateVisible();
      minflowform.dialog("close");
    }
    else{
      $( "#minflow-warning" ).text("Minimum flow must be a positive integer.");
      return
    }
  }

  // bound function for dam dialog
  function damBuildButton(){
    if(state.damfund == 0){
      $( "#build-dam-warning" ).text("Dam fund is empty! You need to contribute points first.");
      return
    }
    if(state.damactive == true){
      $( "#build-dam-warning" ).text("You already have a dam! How did you get here?");
    }
    if(buildDam()){
      //Disable dam build management option
      $("#dam-checkmark").show();
      $("#dam-option").css({
        'pointer-events':'none',
        'color'         :'#919191'
      });
      $( "#build-dam-warning" ).text("");
      $("#build-dam-form-info")[0].reset();
      builddamform.dialog('close');
      updateVisible();  
    }
  }

  // Bound function for dialogue that opens when you start a new year
  // and have a dam built
  function useDam(){
    let answers = $("#use-dam-form-info").serializeArray();
    amount = Number(answers[1].value);
    if(answers[0].value == 'store'){
      if(amount > state.runoff - state.minflowreq){
        $("#use-dam-warning").text(`Error: Can't fill dam with ${amount} from runoff of ${state.runoff}.`);
        return;
      }
      if(state.damheldvol + amount > state.damcap){
        $("#use-dam-warning").text(`Error: Can't fill dam with ${amount} as dam has ${state.damcap - state.damheldvol}
          space remaining.`);
        return;
      }
      fillDam(amount);
    }
    if(answers[0].value == 'withdraw'){
      if(amount > state.damheldvol){
        $("#use-dam-warning").text(`Error: Can't release ${amount} water from reserve of ${state.damheldvol}.`);
        return;
      } 
      releaseDam(amount);
    }

    usedamform.dialog('close');
    $("#use-dam-form-info")[0].reset();
  }

  // Making dropdowns close if they're not clicked on
  $(document).on('click', function(event) {
    if (!$(event.target).closest('#management-button').length) {
      $('#management-options').removeClass('showDrop');
    }
    if (!$(event.target).closest('#data-button').length) {
      $('#data-options').removeClass('showDrop');
    }
    
  });

  // Preventing "enter" from reloading the page.
  $(document).keypress(
    function(event){
      if (event.which == "13") {
        event.preventDefault();
      }
  });

  // make scoreboard div a JQueryUI resizable object
  $( "#scoreboard-container" ).resizable({
    minHeight: 477,
    minWidth: 390
  });

  // make score history div a JQueryUI resizable and draggable object
  $("#scoring-history-container").resizable({
    minHeight: 290,
    minWidth: 280
  }).draggable({
    disabled: true,
  });

  // Make sure dam data container is draggable and under everything else
  // to prevent it eating clicks while invisible
  $( "#dam-data-container" ).draggable({
    disabled: true,
  }).css("z-index", "-30");

  // Trading data is only above dam data, similarly to prevent eating clicks
  // when invisible
  $( "#trading-data-container" ).draggable({
    disabled: true,
  }).css("z-index", "-29");

  tradeform = $( "#trade-form" ).dialog({
    autoOpen: false,
    modal: true,
    width: 'auto',
    buttons: {
      "Trade!": trade,  
    },

  });

  minflowform = $( "#minflow-form" ).dialog({
    autoOpen: false,
    modal: true,
    width: 'auto',
    buttons: {
      "Submit": updateMinFlowReq,  
    },

  });

  builddamform = $( "#build-dam-form" ).dialog({
    autoOpen: false,
    modal: true,
    width: 'auto',
    buttons: {
      "Build A Dam": damBuildButton,  
    },

  });

  usedamform = $( "#use-dam-form" ).dialog({
    autoOpen: false,
    modal: true,
    width: 'auto',
    buttons: {
      "Store or Release": useDam,
    }
  });
  
  // Clean up forms when the dialogue is closed to prevent errors and
  // form values from persisting past a close
  $( "#build-dam-form" ).on( "dialogbeforeclose", function( event, ui ) {
    $( "#maxdamcontribution").hide();
    $( "#build-dam-warning").text("");
    $( "#build-dam-form-info")[0].reset();
    $( "#damvolumeinput").val('');
  });

  $( "#use-dam-form" ).on( "dialogbeforeclose", function( event, ui ) {
    $( "#maxdamuseaction").hide();
    $( "#use-dam-warning").text("");
    $( "#use-dam-form-info" )[0].reset();
  });

  tradeform.on("dialogbeforeclose", function( event, ui ){
    $( "#trade-form-info" )[0].reset();
    $( "#trade-warning" ).text("");
    $( "#trademax" ).hide();
  });

  minflowform.on("dialogbeforeclose", function( event, ui){
    $( "#minflow-warning" ).text("");
    $( "#minflow-form-info" )[0].reset();
  });

  // Next three functions update maximum values for different
  // forms when their options are changed
  $( "#operationselect" ).on("change", function() {
    const operation = $( "#operationselect" ).val();
    if(operation == "store"){
      $( "#maxdamuseaction" ).text(`Maximum: ${Math.min(state.runoff, state.damcap - state.damheldvol)}`).show();
    }
    else if(operation == "withdraw"){
      $( "#maxdamuseaction" ).text(`Maximum: ${state.damheldvol}`).show();
    }

  });

  $( "#sellerselect, #buyerselect" ).on("change", function() {
    console.log(`select change in trade detected, vals ${ $("#sellerselect").val()}, ${ $("#buyerselect").val()}`);
    if( $("#sellerselect").val() != null && $("#buyerselect").val() != null){
      console.log("both not default.");
      const answers = $("#trade-form-info").serializeArray();
      const seller = answers[0].value;
      const buyer = answers[1].value;
      const sellerloc = state.locationsbypriority[seller-1];
      const buyerloc = state.locationsbypriority[buyer-1];
      console.log(`Sellerloc withdrawn : ${sellerloc.withdrawn}, buyer defecit ${buyerloc.requested - buyerloc.withdrawn}`);
      amountlimit = Math.floor(Math.min(buyerloc.requested - buyerloc.withdrawn, sellerloc.withdrawn));
      $("#trademax").text(`The limit is ${Math.floor(amountlimit)}.`).show();
    }
  });

  $( "#playerselect" ).on("change", function(){
    const playerno = $( "#playerselect" ).val()
    console.log(`select change in dam detected. vals playerselect ${ playerno }`);
    if( playerno != null){
      playerloc = state.locationsbypriority[playerno-1];
      $("#maxdamcontribution").text(`The limit is ${Math.floor(playerloc.points)}.`).show();
    }
  });

  // CHART.JS STUFF
  var xValues = ["Urban", "Industrial", "Mining", "Farm"];
  var yValues = [10, 5, 2, 1];
  var barColors = ["#E78AB9", "#99FFFF","#DB9B3E","#8DC63F"];

  // This is the chart at the bottom left of the page
  // that shows point values for locations.
  new Chart("use-points-chart", {
    type: "bar", 
    data: {
      labels: xValues,
      datasets: [{
        backgroundColor: barColors,
        borderSkipped: false,
        data: yValues,
        borderColor: "black",
        borderWidth: 1, 
        barPercentage: 1,
        categoryPercentage: 1
      }]
    },
    options: {
      maintainAspectRatio: false,
      plugins: {
        legend:{
          display: false,
        }
      },
      responsive: true,
      title: {
        display: true,
        text: "USE POINTS / ACRE-FOOT"
      },
      scales: {
        y: {
          display: true,  
          max: 10,
        },
        x: {
          ticks: {
            color: "#000000",
            z: 1,
            mirror: true,
            crossAlign: 'near',
            font: {
              weight: 'bolder',
            },
          },
          grid: {display: false}
        }
      }
    },

  });

  // Score bar at the top of the page, in the header
  let scorechart = new Chart("score-graph", {
    type: "bar",
    plugins: [ChartDataLabels],
    data: {
      labels: ["Use Flow Chart"], 
      datasets: [
        {
        backgroundColor: "#FFFF00",
        label: "Use Flow",
        data: [state.usescore],
        borderColor: "black",
        borderWidth: 2, 
        barPercentage: 1,
        categoryPercentage: 1,
        borderSkipped: false,
        datalabels: {
          labels: {
            tag: {
              font: {
                size: 10
              },
              anchor: "start",
              align: "end",
              display: 'auto',
              rotation: 270,
              formatter: function(value, context) {
                return "USE"
              }
            },
            value: {
              anchor: "end",
              align: "start",
              font: {
                weight: "bold",
                size: 12
              },
              formatter: function(value, context){
                return String(state.usescore);
              }
            }
          }
        }
        }, {
        backgroundColor: "#FFA500",
        borderColor: "black",
        borderWidth: 2, 
        barPercentage: 1,
        categoryPercentage: 1,
        borderSkipped: "start",
        label: "Fish Flow",
        data: [state.fishscore],
        datalabels: {
          labels: {
            tag: {
              anchor: "end",
              align: "start",
              display:"auto",
              rotation: 270,
              font: {size: 10},
              formatter: function(value, context){
                return "FISH"
              }
            },
            total: {
              color: "#000000",
              anchor: "end",
              align: "end",
              font: {
                size: 16,
                weight: "bold"
              },
              formatter: function(value,context){
                return state.score;
              }
            }
          }
        }
      }],
    },
    options: {
      maintainAspectRatio: false,
      responsive: true,
      plugins: {
        legend:{
          display: false,
        }
      },
      indexAxis: 'y', 
      responsive: true,
      scales: {
        x: {
          display: false,
          stacked: true,
          grid: {display: false},
          max: 130000,

        },
        y: {
          display: false,
          stacked: true,
          grid: {display: false},
        }
      }
    },

    
  });
  charts.push(scorechart);

  // Next block is for the score history chart
  gradelabels = ["A", "B", "C", "D"];
  // Points for the line representing max score
  compressMaxData = [
    {x:1000,y:22799},
    {x:3000,y:61288},
    {x:5000,y:91609},
    {x:7000,y:99080},
    {x:9359,y:103175},
    {x:12000,y:107368},
    {x:15640,y:111200},
    {x:20000,y:111200},
  ];
  // Points for the line representing minimum score for A grade
  compressAData = [
    {x:1000,y:20519.1},
    {x:3000,y:55159.2},
    {x:5000,y:82448.1},
    {x:7000,y:89172},
    {x:9359,y:92857.5},
    {x:12000,y:96631.2},
    {x:15640,y:100080},
    {x:20000,y:100080},
  ];
  // Points for the line representing minimum score for B grade
  compressBData = [
    {x:1000,y:18239.2},
    {x:3000,y:49030.40},
    {x:5000,y:73287.2},
    {x:7000,y:79264},
    {x:9359,y:82540},
    {x:12000,y:85894.4},
    {x:15640,y:88960},
    {x:20000,y:88960},
  ];
  // Points for the line representing minimum score for C grade
  compressCData = [
    {x:1000,y:15959.3},
    {x:3000,y:42901.6},
    {x:5000,y:64126.3},
    {x:7000,y:69356},
    {x:9359,y:72222.5},
    {x:12000,y:75157.6},
    {x:15640,y:77840},
    {x:20000,y:77840},
  ];
  // Points for the line representing minimum score for D grade
  compressDData = [
    {x:1000,y:11399.5},
    {x:3000,y:30644},
    {x:5000,y:45804.5},
    {x:7000,y:49540},
    {x:9359,y:51587.5},
    {x:12000,y:53684},
    {x:15640,y:55600},
    {x:20000,y:55600},
  ];
  
  // available under view data options, "Scoring data"
  historychart = new Chart("scoring-history-graph", {
    type: "scatter",
    plugins: [ChartDataLabels],
    data: {
      datasets: [
        {
          data: [],
          backgroundColor:"#000000",
          datalabels: {
            labels: {
              year: {
                display: true,
                anchor: "center",
                align: "right",
                color: "#000000",
                formatter: function(value, context){
                  if(state.scorehistory.length != 0){
                    return state.scorehistory[context.dataIndex].year;
                  } else {
                    return;
                  }
                }
              }
            }
          }
        },
        {
          data: compressMaxData,
          showLine: true,
          fill: "+1",
          backgroundColor: "#F47A6C",
          pointStyle:false,
          borderColor: "#000000",
          borderWidth: 1,
          datalabels: {
            labels: {
              letter : {
                display: false,
              }
            }
          }
        },
        {
          data: compressAData,
          showLine: true,
          fill: "+1",
          backgroundColor: "#F4CC6C",
          pointStyle:false,
          borderColor: "#000000",
          borderWidth: 1,
          datalabels: {
            labels: {
              letter : {
                color: "#000000",
                anchor: "end",
                align: 200,
                offset: 0,
                display: true,
                formatter: function(value, context){
                  if (context.dataIndex === 7){
                    return "A"
                  }
                  return ""
                }
              }
            }
          }
        },
        {
          data: compressBData,
          showLine: true,
          fill: "+1",
          backgroundColor: "#F4F96C",
          pointStyle:false,
          borderColor: "#000000",
          borderWidth: 1,
          datalabels: {
            labels: {
              letter : {
                color: "#000000",
                anchor: "end",
                align: 200,
                offset: 0,
                display: true,
                
                formatter: function(value, context){
                  if (context.dataIndex === 7){
                    return "B"
                  }
                  return ""
                }
              }
            }
          }
        },
        {
          data: compressCData,
          showLine: true,
          fill:"+1",
          backgroundColor: "#75F96C",
          pointStyle:false,
          borderColor: "#000000",
          borderWidth: 1,
          datalabels: {
            labels: {
              letter : {
                color: "#000000",
                anchor: "end",
                align: 200,
                offset: 0,
                display: true,
                
                formatter: function(value, context){
                  if (context.dataIndex === 7){
                    return "C"
                  }
                  return ""
                }
              }
            }
          }
        },
        {
          data: compressDData,
          showLine: true,
          fill:'origin',
          backgroundColor: "#757AEB",
          pointStyle:false,
          borderColor: "#000000",
          borderWidth: 1,
          datalabels: {
            labels: {
              letter : {
                color: "#000000",
                anchor: "end",
                align: 200,
                offset: 0,
                display: true,
                
                formatter: function(value, context){
                  if (context.dataIndex === 7){
                    return "D"
                  }
                  return ""
                }
              }
            }
          }
        },
        
      ],
    },
    options: {
      
      maintainAspectRatio: false,
      responsive: true,
      plugins: {
        legend:{
          display: false,
        },

      },
      scales: {
        x: {
          title: {
            display: true,
            text: "RIVER FLOW (ACRE-FEET)"
          },
          max: 22000,
          min: 0,
        },
        y: {
          title: {
            display: true,
            text: "POINTS"
          },
          min: 0,
          max: 120000,
        }
      }
    }

  });
  charts.push(historychart);  
}
