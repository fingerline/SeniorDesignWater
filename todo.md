# To Do

- [X] Initialize runoff per year
- [X] Calculate alotted water by runoff using priority
- [X] Calculate actual water flows by runoff using position
- [X] Calculate score based on water use
- [X] Implement the option to trade
- [X] Incorporate trading into scoring
- [X] Resolve trading beyond limits
- [X] Move from year to year
- [X] Build a dam
- [X] Release and store damwater in flow manipulation
- [ ] "Grade" based on defined grade curves

## Enhancements

- [X] Allow user to see minflow at all times
- [X] Save/Load using .json.
- [X] Remove redundant checks in backend for trade, minflow, dam contribution, etc.
- [X] Round at earlier steps, keeping relative accuracy (ONLY ROUNDS ON DISPLAY)
- [X] Reset forms after submission
- [X] Allow user to see maximums more clearly in dialogs
- [X] Dam can be funded beyond reason on reload
- [ ] Check if all of the updateVisible() calls are actually useful

## Fixes

- [X] Dam can be funded after the game is reloaded, even if dam already exists
- [X] MINREQ label does not update on load
- [X] Investigate: loading does not give you prompt for dam. Is this a bad thing? (CAN'T ACCESS SAVE BUTTONS BEFORE TURN END. THIS IS FINE)
- [X] Fix minflowreq, maybe more, getting appended to URL.

## Core

- [X] Trading Table Draggable
- [ ] Grade Table Draggable
- [X] Points Use Graph
- [ ] River Visualizer
- [ ] Re-add decorators
- [X] Two-segment point display  
- [X] Allow trades to pay for themselves (Required second look at trading functionality!)
- [ ] no form redirect on enter!
