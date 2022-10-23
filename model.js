const MIN_RUNOFF = 5000;
const MAX_RUNOFF = 20000; 

//converting water withdrawn to points
const SCORETYPE = {
  'Farm': 1,
  'Mining': 2,
  'Industrial': 5,
  'Urban': 10
}

let state = {
  year: null,
  locationsbypriority: [],
  locationsbyposition: [],
  runoff: null,
  minflowreq: 0
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
  }
  // These are static so they can probably be stored in a .json file somewhere and
  // Restored if push comes to shove, though I'd like to avoid doing so considering
  // graphics need to be done down the line.
}

function getNewRunoff(){
  return Math.floor(Math.random() * (MAX_RUNOFF - MIN_RUNOFF + 1)) + MIN_RUNOFF;
}

function initializeGame(){
  //Set up base state
  state.year = 0;
  locations = []
  //this is going to be ugly

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

  // 'runoff' is not to change DURING a year. This will be useful for
  // UI and scoring. currentWaterFlow is goign to be used for both
  // calculation cycles.

  state.runoff = getNewRunoff();
  // !!!DEBUG CODE!!!
  state.runoff = 10100;

  state.currentwaterflow = state.runoff;


  //initial theoretical cycle
  for(location of state.locationsbypriority){

    console.log(`Loc ${location.priority}@${location.position}:`)
    console.log(`\tInflow:${state.currentwaterflow.toFixed(2)}`)
    console.log(`\tRequested:${location.requested.toFixed(2)}`)
    //theoretical inflow
    location.allotted = Math.max(0, Math.min(location.requested,
     state.currentwaterflow - state.minflowreq));
    console.log(`\tAllottment:${location.allotted.toFixed(2)}`);
    state.currentwaterflow -= location.allotted;
    
    //calculate t.consumption into outflow
    state.currentwaterflow += (location.allotted * (1 - location.percentconsumed));
    console.log(`\tOutflow:${state.currentwaterflow.toFixed(2)}`);
  }

  //ending physical cycle
  state.currentwaterflow = state.runoff;

  for(location of state.locationsbypriority){
    location.withdrawn = Math.min(state.currentwaterflow,
     location.allotted + location.tradevol);
    state.currentwaterflow -= (location.withdrawn * (1-location.percentconsumed)); 
  }
  updateScore();



}

// This will need to be updated for trading when that comes.
function updateScore(){

  // for(location of state.locationsbyposition){
  //   console.log(`Loc ${location.priority}@${location.position}:`);
  //   console.log(`\tWithdrew ${location.withdrawn.toFixed(2)} of target ${location.allotted.toFixed(2)}`)
  //   console.log(`\t\tDesired ${location.requested}`)
  //   console.log(`\tScores ${(location.withdrawn * SCORETYPE[location.type]).toFixed(2)} for` +
  //         ` ${(location.withdrawn).toFixed(2)}@${location.type}\n\n`);
  // }

  globalpoints = 0;
  for(location of state.locationsbypriority){
    location.points = location.withdrawn * SCORETYPE[location.type];
    globalpoints += location.points;
  }
  console.log(globalpoints)

}

function initializeYear() {
  year += 1;
  waterflow = getNewRunoff();
}

initializeGame();