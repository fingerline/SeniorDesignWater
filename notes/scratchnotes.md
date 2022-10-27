#Scratch Notes

## Overview of main menu items:

Both Scores and Grades excel files seem to define a curve for the scoring output

Remaining Excel file appears to be a snapshot of one year of the game with specific settings set in excel rather than the game. Testing?

There's also a concept UI PDF

## Code

Waterconsts.as declares and modifies constants for later, window properties, object titles, colors...

WaterData.as and excel file hints at a priorty value for each intake location.

WaterData.as Seems to serve as a gamestate class and general controller.

intialize annual river flow (intializeRunoff(runoff)) gives a random number between 5000 and MAX_RUNOFF in Constants (set to 20,000) and 
sets to the "global" runoff. If runoff arg is set, sets to that number.

Would love to see the gameloop in this file somewhere

Score is only plotted during years with Dam activity because score plotting happens in the updateRunoff() call, which I believe should be
only invoked at the end of a successful dam operation. This can be circumvented by not having a dam, or by clicking out of the dam operation
window through the 'x' at the top right. Should probably be moved.

updateItems() seems to be main "trickle update" function.

fishHabitatPoints() is given by Math.min(10 * minRiverOutputFlow(), WaterConsts.MAX_RUNOFF); which is.... I believe the amount of water 
that hits the end of the river.

**Priority date refers to the earliest sources of intake for the river. Older sites have a higher priority (lower number) in the priorty queue.** 
It is unknown how this impacts withdrawal as it relates to the physical position on the river.

PriorityItems is an array, in this order, of sites. It is populated using arrays in the form:

`[positionFromSource, priorityDate, useCategory, requestedWithdraw, percentConsumptive, name]`.

and then these WaterDataPriorityItem objects are populated into priorityItems array.

This MAY be easier to track once I know how to read it.

## EXCEL SHEET (WATER SEPETEMBER)

This is an excel sheet that should be what the game is based off of mechanics wise. I will attempt to interpret it in order to learn what the flow of the game actually is.

First, an initial flow of water for the year is posed. In this case, 10100.

Then, a row of each data point intercepts the water. The list is sorted based on their "priority", or in order of establishment. Location 1) Gets first pass.

We determine what the location desires, and how much of that is actually consumed by the location. Postion 1 requests 100 acft of water, and consumes 80%, giving
80 water consumed.

"Priority withdraw" occurrs, which appears to be the actual withdrawing step based on the amount of the remaining water. The formula for this is:
`MAX(0, MIN(AMOUNT REQUESTED, AVAILABLE FLOW - SOME STATIC (set at zero, probably Minimum Flow Requirement)))`
which determines the amount of water the location is allowed to actually withdraw from the river.

After withdrawing the actual water, it then calculates again the "Priority Consumed" based on the percentage consumption of the location.

A "remaining flow" is then provided, which is MAX(0, AVAILABLE FLOW - PRIORITY WITHDRAW).

RETURN FLOW occurs, which adds PRIORITY WITHDRAW - PRIORITY CONSUMED back to the river, giving a TOTAL REMAINING column.

Each row continues this trend, taking the previous row's "TOTAL REMAINING" as AVAILABLE FLOW.

There appears to be a SECOND calculation on the sheet, labeled NEW TABLE. This uses the priority system's results to construct the "actual vision" of what's happening.

Each row starts with the literal amount of water that is flowing to that position. It then attempts to withdraw the amount that the priority system determined it should take in the PRIORITY WITHDRAW column.

The amount of actual water withdrawn is the *lower* number between these two values: The **INPUT FLOW**, or the **PRIORITY WITHDRAW** + any **TRADE VOLUME** associated with it.
This, I suppose, represents the option to trade where any water that is "bought" from another source is ""reserved"" for the purchaser, which cannot exceed the input flow physically
present at the location.

It then CONSUMES the water at the agreed-upon RATE that it consumes water at the previous table. It does NOT appear to use the PRIORITY CONSUMED datapoint in this situation.

Then, it determines the return flow by subtracting the Water Withdrawn with the Water Consumed. This number is then added to (Input flow - withdrawn + return flow) to give Output Flow.

Points are then awarded by Dam Points + river points (water WITHDRAWN times the use point for that type of location) minus whatever trade costs they incurred. (or plus earn!)

