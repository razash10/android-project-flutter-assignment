# hello_me Exercise 3 - Dry part

## Question 1

The class used to implement the controller pattern in snapping_sheet library is 
SnappingSheetController. It allows the developer to control a specific SnappingSheet
by activating and disabling it, or setting its position. It also allows to extract
information from the sheet like positions, if it's active or if it's attached.

## Question 2

The parameter that controls the snapping positions behavior is snappingPositions,
which takes in a list of SnappingPosition.factor or SnappingPosition.pixels to 
specify the location, using a factor or pixels. There is also an option to specify 
the duration and curve of how the sheet should snap to that given position with 
snappingDuration and snappingCurve parameters.

## Question 3

The GestureDetector provides more controls over widgets compared to InkWell, 
like drag, pinch, swipe, etc. On the other hand, InkWell includes ripple 
effect tap, which GestureDetector doesn't.


