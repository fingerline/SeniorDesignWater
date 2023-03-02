const MIN_RUNOFF = 5000;
const MAX_RUNOFF = 20000; 

//converting water withdrawn to points
const SCORETYPE = {
  'Farm': 1,
  'Mining': 2,
  'Industrial': 5,
  'Urban': 10
}

// Global state table, containing important information for all of the game.
let state = {
  year: null,
  score: 0,
  scorehistory: {},
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
    
  }
  // These are static so they can probably be stored in a .json file somewhere and
  // Restored if push comes to shove, though I'd like to avoid doing so considering
  // graphics need to be done down the line.
}

// This class contains the information necessary to keep track of trades in the 
// trades table.
class Trade{
  constructor(player1, player2, volume, priceperunit){
    this.player1 = player1;
    this.player2 = player2;
    this.volume = volume;
    this.priceperunit = priceperunit;
    this.price = volume * priceperunit;
  }
}

locations = [];

// Gross but necessary initial setup of locations.
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

// holy moly just trust this

// Two independent shallow copy list of these locations into state
// the changes to the locations will be synced, but they're ordered
// differently. 'locationsbypriority' is used for initial allocation
// and 'locationsbyposition' is used for physical withdrawals.
state.locationsbypriority = [...locations];
state.locationsbyposition = [...locations];
state.locationsbypriority.sort((a,b) => (a.priority > b.priority) ? 1 : -1);
state.locationsbyposition.sort((a,b) => (a.position > b.position) ? 1 : -1);

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
  if(volume > Math.min((buyer.requested - buyer.withdrawn), seller.withdrawn)){
    console.log(`Trade of ${amount} above max of buyer defecit 
      ${buyer.requested - buyer.withdrawn} or above seller withdrawable ${seller.withdrawn}.`);
  }
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
    if(funder.points < amt){
      console.log(`Error: Points allocated (${amt}) greater than points at
        location ${funder.name} (${funder.priority}) which owns ${funder.points}.`);
      return;
    }
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
  if(state.damfund == 0){
    console.log("Dam fund is empty! Fund the dam before trying to build it");
    return false;
  }
  if(state.damactive == true){
    console.log("Already have a dam active! You're not supposed to get here!");
    return false;
  }
  state.damactive = true;
  state.damcap = state.damfund;
  return true;
}

// Fills the dam with some of the runoff for the year.
function fillDam(amt){
  if(amt > state.runoff - state.minflowreq){
    console.log(`Error: Can't fill dam with ${amt} from runoff of ${state.runoff}.`);
    return;
  }
  if(state.damheldvol + amt > state.damcap){
    console.log(`Error: Can't fill dam with ${amt} as dam only has ${state.damcap - state.damheldvol}
      space remaining.`);
    return;
  }
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
  if(amt > state.damheldvol){
    console.log(`Error: Can't release ${amt} water from reserve of ${state.damheldvol}.`);
    return;
  }
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

    // console.log(`Loc ${location.priority}@${location.position}:`)
    // console.log(`\tInflow:${state.currentwaterflow.toFixed(2)}`)
    // console.log(`\tRequested:${location.requested.toFixed(2)}`)
    //theoretical inflow
    loc.allotted = Math.max(0, Math.min(loc.requested,
     state.currentwaterflow - state.minflowreq));
    // console.log(`\tAllottment:${location.allotted.toFixed(2)}`);
    state.currentwaterflow -= loc.allotted;
    
    //calculate t.consumption into outflow
    state.currentwaterflow += (loc.allotted * (1 - loc.percentconsumed));
    // console.log(`\tOutflow:${state.currentwaterflow.toFixed(2)}`);
  }

  //ending physical cycle
  state.currentwaterflow = state.runoff;

  for(loc of state.locationsbyposition){
    // console.log(`Loc ${location.priority}@${location.position}:`);
    // console.log(`\tInflow: ${state.currentwaterflow.toFixed(2)}`);
    // console.log(`\tAlotted: ${location.allotted.toFixed(2)}`);
    // console.log(`\tTradeflow: ${location.tradevol.toFixed(2)}`);
    loc.withdrawn = Math.min(state.currentwaterflow,
     loc.allotted + loc.tradevol);
    // console.log(`\t!!Withdrawn: ${location.withdrawn.toFixed(2)}`);
    state.currentwaterflow -= (loc.withdrawn * (loc.percentconsumed));
    // console.log(`\tOutflow: ${state.currentwaterflow.toFixed(2)}`);
  }
  updateScore(state.currentwaterflow);
}

// Calculate scores.
function updateScore(remainingflow){

  globalpoints = 0;
  usagepoints = 0;
  fishpoints = Math.min(10*remainingflow, 20000);
  for(loc of state.locationsbypriority){
    if(loc.priority == 23){
      console.log(`Location 23: withdrawn: ${loc.withdrawn} trade volume: ${loc.tradevol}`);
    }
    loc.points = loc.withdrawn * SCORETYPE[loc.type] + loc.tradepoints;
    usagepoints += loc.points;
  }
  globalpoints = Math.round(usagepoints + fishpoints)
  console.log(`Usage Points: ${usagepoints.toFixed(0)}\nFish ` +
   `Points: ${fishpoints.toFixed(0)}\nTotal Points: ${globalpoints}`);
  state.score = globalpoints;

}

// Add score and runoff to score history and card.
function submitScore(score){
  if(state.year != 0){
    state.scorehistory[state.year] = (state.initrunoff, score);
  }
  return;
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

function updateVisible() {
  let table = document.getElementById("scoretable");
  for(let i = 1; i < 16; i++){
    firstloc = state.locationsbypriority[i-1];
    secondloc = state.locationsbypriority[i+14];
    table.rows[i].innerHTML = `
        <td class="normalcol ${firstloc.type}">${firstloc.priority}</td>
        <td class="normalcol ${firstloc.type}">${firstloc.requested}</td>
        <td class="normalcol ${firstloc.type}">${Math.round(firstloc.points)}</td>
        <td class="nullcol"></td>
        <td class="normalcol ${secondloc.type}">${secondloc.priority}</td>
        <td class="normalcol ${secondloc.type}">${secondloc.requested}</td>
        <td class="normalcol ${secondloc.type}">${Math.round(secondloc.points)}</td>
    `;
  }
  document.getElementById("points-display").innerHTML = state.score;
  document.getElementById("year-display").innerHTML = `Year ${state.year}`;
  document.getElementById("acrefeet-display").innerHTML = state.initrunoff;
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
  setNewRunoff(5740);
  calculateFlows();
  updateVisible();
  if(state.damactive){
    console.log("dam is active! updating");
    $("#use-dam-form").dialog("open");
  }
}

function resetGame() {
  state.year = 0;
  state.trades = [];
  state.scorehistory = {};
  state.damfund = 0;
  state.damdonos = {};
  state.damactive = false;
  state.damheldvol = 0;
  state.damcap = 0;
  state.minflowreq = 0;
  setNewRunoff(7000);
  calculateFlows();
  updateVisible();
  cleanupUI();
}

//HTML/CSS FUNCTIONS FROM HERE OUT
function unfoldManagementOptions(){
  document.getElementById("management-options").classList.toggle("showDrop");
}

function unfoldDataOptions(){
  document.getElementById("data-options").classList.toggle("showDrop");
}

function minFlowReqPrompt(){
  console.log('opening minflow prompt');
  $("#minflow-form").dialog("open");
}

function tradePrompt(){
  console.log('opening trade prompt');
  $("#trade-form").dialog("open");
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

function contributeDam(){
  console.log("Attempting to contribute.");
  const response = $("#build-dam-form-info").serializeArray();
  let player = response[0].value;
  let points = response[1].value
  if(!/^[0-9]*$/.test(points) || points == ""){
    $("#build-dam-warning").text("Contribution amount must be an integer!");
    return
  }
  points = parseInt(points);
  playerpoints = state.locationsbypriority[player-1].points;
  console.log(`Player ${player} has ${playerpoints} and attempts to contribute ${points}.`);
  if(points > playerpoints){
    $("#build-dam-warning").text(`Player ${player} can only contribute up to ${playerpoints} points!`);
    return
  }
  else{
    console.log("Legal contribution.");
    fundDam(player,points);
    updateVisible();
  }

}

function damPrompt(){
  console.log('opening dam prompt');
  $("#build-dam-form").dialog("open");
}

function viewTradingData(){
  alert("This functionality coming soon!")
}

function viewDamData(){
  alert("This functionality coming soon!")
}

function viewScoringData(){
  alert("This functionality coming soon!")
}

function saveGame(){
  alert("This functionality coming soon! Saves will use a .json file.")
}

function loadGame(){
  alert("This functionality coming soon! Saves will use a .json file.")
}



//BASE GAME SETUP

initializeGame();
setNewRunoff(7000);
calculateFlows();

window.onload = function() {
  updateVisible();

  function trade(){
    const answers = $("#trade-form-info").serializeArray();
    console.log(answers);
    const seller = answers[0].value;
    const buyer = answers[1].value;
    let volume = answers[2].value;
    let price = answers[3].value;
    const sellerloc = state.locationsbypriority[seller-1];
    const buyerloc = state.locationsbypriority[buyer-1]
    console.log(`seller: ${seller}, buyer: ${buyer}, volume: ${volume}, price: ${price}`);
    console.log(`Seller has ${sellerloc.withdrawn} to sell, Buyer has ${buyerloc.requested-buyerloc.withdrawn} to buy max with ${buyerloc.points} points.`);
    if(!/^[0-9]*$/.test(volume) || volume == ""){
      $("#trade-warning").text("Volume must be an integer!");
      return
    }
    if(!/^[0-9]*$/.test(price) || price == ""){
      $("#trade-warning").text("Price must be an integer!");
      return
    }
    volume = parseInt(volume);
    price = parseInt(price);
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
    if(buyerloc.points < (volume*price)){
      $("#trade-warning").text(`Transaction comes to ${volume*price} points, and buyer ${buyer} only has ${Math.round(buyerloc.points)} points!`)
      return
    }
    else{
      $("#trade-warning").text("");
      console.log("valid trade");
      makeTrade(seller, buyer, volume, price);
      updateVisible();
      tradeform.dialog("close");
    }
  }

  function updateMinFlowReq(){
    let answer = $( "#minflow-form-info" ).serializeArray()[0].value;
    console.log(answer);
    if(/^[0-9]*$/.test(answer)){
      console.log(`Setting MinFlowReq to ${answer}`)
      $("#minflow-warning").text("");
      state.minflowreq = parseInt(answer);
      calculateFlows();
      updateVisible();
      minflowform.dialog("close");
    }
    else{
      console.log(`Bad minflow input: ${answer}`);
      $( "#minflow-warning" ).text("Minimum flow must be a non-negative integer.");
      return
    }
  }

  function damBuildButton(){
    console.log("Building Dam. Dam Donos:");
    console.log(state.damdonos);
    console.log(`Before build dam state: 
      Active ? ${state.damactive}
      Capacity ? ${state.damcap}
      Damfund ? ${state.damfund}`);
    if(buildDam()){
      console.log(`After build dam state: 
        Active ? ${state.damactive}
        Capacity ? ${state.damcap}
        Damfund ? ${state.damfund}`);
      console.log(`Disabling Dam Build Button.`);
      $("#dam-checkmark").show();
      $("#dam-option").css({
        'pointer-events':'none',
        'color'    :'#919191'
      });
      builddamform.dialog('close');
    }
  }

  function useDam(){
    let answers = $("#use-dam-form-info").serializeArray();
    console.log(answers);

    if(answers[0].value == 'store'){
      fillDam(Number(answers[1].value));
    }
    if(answers[0].value == 'withdraw'){
      releaseDam(Number(answers[1].value))
    }

    usedamform.dialog('close');
    $("#use-dam-form-info")[0].reset();
  }

  $( "#scoreboard-container" ).resizable({
    minHeight: 477,
    minWidth: 390
  });

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
  })

  
}
