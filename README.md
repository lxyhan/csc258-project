#### Pre-Pseudocode
---
###### DATA REPRESENTATION
- store bottle width and height as constants in `.data`
- use a matrix to keep track of the entity at each position; an entity refers to static pills and viruses. the pill currently controlled by the player doesn't have to be maintained here as we are manually keeping track of its position for other processes anyways
- matrix is only necessary for the interior of the bottle
- want to leave room for expansion, so each entry in the matrix does not necessarily correspond to a pixel in a one-to-one manner
	- if we wanted fancier graphics so that pills are rendered more like the original game, each half-capsule could keep track of its other half in storage

###### INITIALIZATION
- generate capsule through random pair of colours from set {RYB}; throw horizontally
- maintain position, rotation (horizontal vs vertical), colours
- position should always refer to the bottom-left part of the capsule (this is the only invariant region on the grid that the capsule occupies)
- virus count can be determined by level difficulty: randomly spawned at the beginning of the game -- let's keep it at the bottom half of the bottle to avoid unplayable scenarios

###### PLAYER CONTROLS
- `a` and `s` -- simply modify the x-position of the capsule by -1 and 1, resp. this should not replace the current position until validated by collision detection 
- `s` -- modify the y-position of the capsule by 1; do not replace until validated
- `w` -- how do we deal with capsule rotations?
	- rotations occur counterclockwise
	- let the pivot be the part of the capsule represented by the position
	- horizontal -> vertical rotation: bring right component to the top of left component; the pivot stays the same, and is now the bottom component
	- vertical -> horizontal rotation: bring top component to the right of the bottom component, and swap left and right components; the pivot changes to the left component (that which was originally the top)

###### COLLISION DETECTION
- happens after processing a keyboard input
- main idea: you can only cause horizontal collisions through keyboard input that changes the horizontal position or the rotation of the capsule.
- if the user has provided keyboard input *that is not `s` (down)*: compute the next position of the capsule and store it elsewhere temporarily; call `validate_h` on the capsule information (specifically the rotation and position) to ensure the following:
	- check against the sides by checking that the pivot is $\geq 0$ and $\leq$ the width of the bottle - 1 (due to 0-indexing). If the capsule is horizontal, this should instead by a strict less than.
	- check that no entities within the matrix are at the entries now occupied by the capsule
	- if any of these checks fail, return 0; otherwise return 1
TODO: `validate_v`: we somehow need to account for the edge case where the capsule only just spawned, and is unable to move down because there is a capsule underneath it, but does not overlap with it so game over is not triggered. this might just need careful ordering of the game loop. we have the invariant that, prior to any changes made during this phase, the capsule was in a good spot, so can assume the capsule was able to move at least one unit down? in that case, we can always have gravity bring the capsule down one, and we just need to correct the position if the user tries to click `s`, so that the capsule does not end up overlapping with what's beneath it.
- call `is_touchdown` on the capsule information (specifically the rotation and position) to check whether the capsule has support underneath it (in particular, there exists an entity underneath the pivot, OR underneath the other capsule half in the case where the capsule is horizontal)

###### ELIMINATING CAPSULES AND VIRUSES (WIP)
- handled in the `touchdown` call after `is_touchdown` returns 1
- for each capsule half
	- go as far as you can with the same colour (irrespective of whether it is a virus or a capsule half) in each direction (left-right and up-down); if any direction let us walk 4 or more positions (including the new capsule half itself), we clear all those entities from the matrix
TODO: I've not yet determined how we can trigger the chain reaction, where any capsule halves that were supported by the removed squares fall until they land on a capsule, virus, or the bottom of the playing field, and themselves may trigger a clear, etc. this may require we maintain which capsule halves are connected to which other capsule halves in the matrix.

###### GAME OVER
- when placing the new capsule within the bottle, we check that it does not already collide with an entity in the matrix (ie call `validate`). if it does, we signal that the game is over. for now, this can simply halt the program

###### VISUALIZATION
- drawing the bottle takes data from the matrix and the current position, rotation, and colours of the player's capsule; we can either draw this one-to-one (so that each virus/capsule half corresponds to a pixel of a particular colour), or determine a nicer way to represent the matrix and player capsule using the same data 
- draw a border around the bottle; this, and the contents outside the bottle (eg if we choose to draw dr mario or caricatures of the viruses), can be extracted from a file to avoid hardcoding
- draw the next capsule to appear, right of the bottle
