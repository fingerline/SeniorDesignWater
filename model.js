const MIN_RUNOFF = 5000;
const MAX_RUNOFF = 20000; 
const DAM_MAX_CAP = 40000;

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
    console.log(`At position ${loc.position}, location ${loc.priority} is recieving a water flow of ${state.currentwaterflow}, and has been allotted ${loc.allotted}.`);
    loc.withdrawn = Math.min(state.currentwaterflow,
     loc.allotted + loc.tradevol);
    state.currentwaterflow -= (loc.withdrawn * (loc.percentconsumed));
    console.log(`   As a result, locaiton ${loc.priority} has withdrawn ${loc.withdrawn} ac-ft of water.`);
  }
  console.log(`After calculateFlows(), location 23 claims to have withdrawn ${state.locationsbyposition[0].withdrawn} in position, and in priority it reflects that it has ${state.locationsbypriority[22].withdrawn}.`);
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
  document.getElementById("points-display").innerHTML = state.score;
  document.getElementById("year-display").innerHTML = `Year ${state.year}`;
  document.getElementById("acrefeet-display").innerHTML = state.runoff;
  $("#minflow-label").text(`Minimum Required Flow: ${state.minflowreq}`);
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
  let points = response[1].value;
  let maxallowedpoints = DAM_MAX_CAP - state.damfund;
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
  if(points > maxallowedpoints){
    $("#build-dam-warning").text(`The dam can only have ${DAM_MAX_CAP} donated total.
    You can donate ${maxallowedpoints} more.`);
  }
  else{
    console.log("Legal contribution.");
    fundDam(player,points);
    $("#build-dam-warning").text("Contribution accepted.");
    $("#build-dam-form-info")[0].reset();
    updateVisible();
  }

}

function damPrompt(){
  console.log('opening dam prompt');
  $("#build-dam-form").dialog("open");
}

function viewTradingData(){
  $( "#trading-data-container" ).toggleClass("invisible");

  isDisabled = $( "#trading-data-container" ).draggable( "option", "disabled" );
  if(isDisabled){
    $( "#trading-data-container" ).draggable("enable").css("z-index", "51");

    console.log("enabling trading data draggable");
  } else {
    $( "#trading-data-container" ).draggable("disable").css("z-index","-29");
    console.log("disabling trading data draggable"); 
  }

}

function viewDamData(){
  $( "#dam-data-container" ).toggleClass("invisible");

  isDisabled = $( "#dam-data-container" ).draggable( "option", "disabled" );
  if(isDisabled){
    $( "#dam-data-container" ).draggable("enable").css("z-index", "50");
    console.log("enabling dam data draggable");
  } else {
    $( "#dam-data-container" ).draggable("disable").css("z-index","-30");
    console.log("disabling dam data draggable"); 
  }
}

function viewScoringData(){
  alert("This functionality coming soon!")
}


// Downloads function as JSON Data. Needs to use URI w/ data: prefix because Firefox, chromium browsers like
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

      console.log(state);
      console.log("Loaded state!");
      calculateFlows();
      updateVisible();

       //reload non-automatic UI elements
      if(state.damactive == true){
        console.log(`Disabling Dam Build Button.`);
        $("#dam-checkmark").show();
        $("#dam-option").css({
          'pointer-events':'none',
          'color'         :'#919191'
        });
      }
    }
 
 }

  input.click();
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
    const buyerloc = state.locationsbypriority[buyer-1];
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
      $("#minflow-label").text(`Minimum Required Flow: ${state.minflowreq}`);
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
    if(state.damfund == 0){
      $( "#build-dam-warning" ).text("Dam fund is empty! You need to contribute points first.");
      return
    }
    if(state.damactive == true){
      $( "#build-dam-warning" ).text("You already have a dam! How did you get here?");
    }
    if(buildDam()){
      console.log(`After build dam state: 
        Active ? ${state.damactive}
        Capacity ? ${state.damcap}
        Damfund ? ${state.damfund}`);
      console.log(`Disabling Dam Build Button.`);
      $("#dam-checkmark").show();
      $("#dam-option").css({
        'pointer-events':'none',
        'color'         :'#919191'
      });
      $( "#build-dam-warning" ).text("");
      $("#build-dam-form-info")[0].reset();
      builddamform.dialog('close');
    }
  }

  function useDam(){
    let answers = $("#use-dam-form-info").serializeArray();
    console.log(answers);
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

  $(document).on('click', function(event) {
    if (!$(event.target).closest('#management-button').length) {
      $('#management-options').removeClass('showDrop');
    }
    if (!$(event.target).closest('#data-button').length) {
      $('#data-options').removeClass('showDrop');
    }
    
  });

  $( "#scoreboard-container" ).resizable({
    minHeight: 477,
    minWidth: 390
  });

  $( "#dam-data-container" ).draggable({
    disabled: true,
  }).css("z-index", "-30");
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
  
  $( "#build-dam-form" ).on( "dialogbeforeclose", function( event, ui ) {
    $( "#maxdamcontribution").hide();
    $( "#build-dam-warning").text("");
    $( "#build-dam-form-info")[0].reset();
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
      amountlimit = Math.round(Math.min(buyerloc.requested - buyerloc.withdrawn, sellerloc.withdrawn));
      $("#trademax").text(`The limit is ${Math.round(amountlimit)}.`).show();
    }
  });

  $( "#playerselect" ).on("change", function(){
    const playerno = $( "#playerselect" ).val()
    console.log(`select change in dam detected. vals playerselect ${ playerno }`);
    if( playerno != null){
      console.log("not default");
      playerloc = state.locationsbypriority[playerno-1];
      console.log(`Playerloc points: ${playerloc.points}`);
      $("#maxdamcontribution").text(`The limit is ${Math.round(playerloc.points)}.`).show();
    }
  });

  var xValues = ["Urban", "Industrial", "Mining", "Farm"];
  var yValues = [10, 5, 2, 1];
  var barColors = ["#E78AB9", "#99FFFF","#DB9B3E","#8DC63F"];

  new Chart("use-points-chart", {
    type: "bar", 
    data: {
      labels: xValues,
      datasets: [{
        backgroundColor: barColors,
        data: yValues,
        borderColor: "black",
        borderWidth: 1, 
        barPercentage: 1,
        categoryPercentage: 1
      }]
    },
    options: {
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
            z: 1,
            mirror: true,
            crossAlign: 'near',
            font: {
              weight: 'bolder',
            }
          }
        }
      }
    },

  });


  
}
