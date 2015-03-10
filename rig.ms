-- Create a humanoid shaped Stonehearth rig file from an OBJ exported voxel file.
-- This script makes many assumptions about the voxel matricies and their names

fileIn  "hashtable.ms"
fileIn  "util.ms"

function rig_tweak_pivots side = (
	local b, i, j
	
	b = rig_bone side "Hand"
	if(b != undefined) then (
		b.pivot.z = b.max.z
	)
	
	for  i = 1 to 3 do (
		for  j = 1 to 2 do (
			b = rig_bone side ("Finger" + i as string + j as string)
			
			if(b != undefined) then (
				b.pivot.z = b.max.z
			
				if (side == "left") then (
					b.pivot.x = b.max.x
				) else (
					b.pivot.x = b.min.x
				)
			)
		)
	)
	
	b = rig_bone side "Thumb2"
	if(b != undefined) then (
		b.pivot.z = b.max.z
		b.pivot.y = b.min.y
	)
	
	b = rig_bone side "Thumb1"
	if(b != undefined) then (
		b.pivot.z = b.max.z
	)
	
	b = rig_bone side "Foot"
	if(b != undefined) then (
		b.pivot.z = b.max.z
		--b.pivot.y = 0
	)
)

function rig_bone side part = (
	return getNodeByName (side + part);
)

function rig_link_bones child parent = (w
	if(parent != undefined and child != undefined) then (
		child.parent = parent
	)
)

function rig_link = (
	rig_link_bones $bodyPosition $root
	
	rig_link_bones $pelvis $bodyPosition
	rig_link_bones $leftFoot $bodyPosition
	rig_link_bones $rightFoot $bodyPosition
	
	rig_link_bones $head $torso
	rig_link_bones $torso $pelvis
	rig_link_bones $pelvis $bodyPosition
	
	rig_link_bones $leftShoulder $torso
	rig_link_bones $rightShoulder $torso
	
	rig_link_bones $leftArm $leftShoulder
	rig_link_bones $leftHand $leftArm
	
	rig_link_bones $rightArm $rightShoulder
	rig_link_bones $rightHand $rightArm
	
	rig_link_bones $leftFoot $bodyPosition
	rig_link_bones $rightFoot $bodyPosition
	
	linkFinger "leftThumb" "leftHand"
	linkFinger "leftFinger1" "leftHand"
	linkFinger "leftFinger2" "leftHand"
	linkFinger "leftFinger3" "leftHand"

	linkFinger "rightThumb" "rightHand"
	linkFinger "rightFinger1" "rightHand"
	linkFinger "rightFinger2" "rightHand"
	linkFinger "rightFinger3" "rightHand"	
)

function linkFinger base_name parent_name = (
	local n1 = getNodeByName (base_name + "1")
	local n2 = getNodeByName (base_name + "2")
	local p = getNodeByName parent_name
	
	rig_link_bones n1 p
	rig_link_bones n2 n1
)

fn rig_create_generic file_name = (
	-- root helper
	Point pos:[0,0,0] isSelected:on
	$.name = "root"
	$.Box = on
	$.size = 10
	$.wirecolor = color 0 0 0
	$.pos = [15.5, 15.5, 0]
	
	-- the bones
	importFile file_name
	--move $ [15.5, 15.5, 0]
	ResetXForm $
	--$.boxmode = on

	for b in selection do (
		b.name = (filterstring b.name "_")[1]
		--b.name = "bone" + (toupper(substring b.name 1 1)) + (substring b.name 2 100) 
		b.pivot = b.center
	)
	
	$.wirecolor = color 225 198 87
	$right*.wirecolor = color 27 177 27
	$left*.wirecolor = color 28 89 177

	-- root pos
	local body_pos = box name:"bodyPosition" length:(2 + $pelvis.max.y - $pelvis.min.y) width:5 height:5
	body_pos.boxmode = on
	body_pos.pivot = body_pos.center
	body_pos.pos = $pelvis.pos
	body_pos.wirecolor = color 88 199 225
	body_pos.boxmode = on

)

fn rig_create_from_file file_name = (
	
	rig_create_generic file_name
	
	-- tweak the pivots
	$head.pivot.z = $head.min.z
	$torso.pivot.z = $torso.min.z
	
	rig_tweak_pivots "left"
	rig_tweak_pivots "right"
	
	rig_link()
	
	-- main hand and off hand
	local mainHand = box name:"mainHand" length:20 width:2 height:2
	mainHand.boxmode = on
	mainHand.pivot = mainHand.center
	mainHand.pivot.y = 6
	mainHand.pos = $rightHand.center
	mainHand.center.z = $rightHand.min.z - 1
	mainHand.parent = $rightHand
	mainHand.wirecolor = color 153 228 153
	
	local offHand = box name:"offHand" length: 20 width:2 height:2
	offHand.boxmode = on
	offHand.pivot = offHand.center
	offHand.pivot.y = 6
	offHand.pos = $leftHand.center
	offHand.center.z = $leftHand.min.z - 1
	offHand.parent = $leftHand
	offHand.wirecolor = color 154 215 229

)

-- apply a rig to an existing file, moving all the existing pivots
function rig_apply rig = (
	for b in $* do (
		try (
			local rig_bone = hash_get rig b.name
			local pos = in coordsys parent rig_bone[1]
			local offset = rig_bone[2]
			
			b.pos = pos
		) catch (
		)
	)
)

-- create a rig in memory from the currently loaded max file
--
-- format
--
-- {
--    boneName: [ pos, offset ],
--    boneName: [ pos, offset ]
-- }

function rig_create = (
	local rig_data = hash_create()
	
	for b in $* do (
		local bone_name = b.name
		if ((substring b.name 1 1) != "_") then (
			local pos = in coordsys parent b.pos
			local offset = (b.pivot - b.center)
			hash_add rig_data bone_name #(pos, offset)
			--print bone_name
		)
	)

	return rig_data

)

-- create the keyframes structure from the currently loaded max file.
-- the keyframes store bone rotations and offsets compared to a rig
-- 
-- structure
--
-- {
--   boneName : {
--      "pos" : [
--            [ keyframe, value]
--            [ keyframe, value]
--      ],
--      "rot" : [
--            [ keyframe, value]
--            [ keyframe, value]
--      ]
--   }
--
function keyframes_create rig = (
	local keyframe_data = hash_create()
	
	for b in $* do (
		local bone_data = hash_create()
		
		-- rotation keyframes
		local rotKeys = #()
		
		for i = 1 to b.rotation.controller.keys.count do (
			t = b.rotation.controller.keys[i].time.frame as integer
			
			at time t (
				local rot
				if (b.parent != undefined) then (
					rot = in coordsys b.parent b.rotation
				) else (
					rot = b.rotation
				)
				append rotKeys #(t, rot)
			)
		)
		
		hash_add bone_data "rot" rotKeys

		-- position keyframes
		local posKeys = #()
		--print b.name
		for i = 1 to b.pos.controller.keys.count do (
			t = b.pos.controller.keys[i].time.frame as integer
			
			at time t  (
				local pos
				if (b.parent != undefined) then (
					pos = in coordsys parent b.pos
				) else (
					pos = b.pos
				)
				
				-- subtract the rig's position
				local rig_bone = hash_get rig b.name
				if (rig_bone != 0) then (
					local rig_pos = rig_bone[1]
					pos = pos - rig_pos
				)
				
				--print ("pos " + (t as string) + " " + (pos as string))
				append posKeys #(t, pos)
			)
		)
		
		hash_add bone_data "pos" posKeys
		
		-- add this bone data to the keyframe data
		--print (b.name + ": adding to keyframe_data")
		--print bone_data
		hash_add keyframe_data b.name bone_data
	)
	
	return keyframe_data
)

function keyframes_apply keyframes = (
	local rig = rig_create()
	local t
	local maxT = 0
	
	for b in $* do (
		local bone_data = hash_get keyframes b.name
		
		if (bone_data != undefined and bone_data != 0) then (
			-- rot
			local rotKeys = hash_get bone_data "rot"
			if (rotKeys != undefined) then (
				for key in rotKeys do (
					t = key[1]
					local rot = key[2]
					with animate on at time (t as Time) (
						in coordsys parent b.rotation = rot
						deleteKeys b.pos.controller
					)
					maxT = amax t maxT
				)
			)
			
			
		
			-- pos
			local posKeys = hash_get bone_data "pos"
			if (posKeys != undefined) then (
				for key in posKeys do (
					t = key[1]
					local pos = key[2]
					local rig_bone = hash_get rig b.name
					
					with animate on at time (t as Time) (
						in coordsys parent b.pos = pos

						if(rig_bone != 0) then (
							in coordsys parent b.pos +=  rig_bone[1]
						)						
					)
					maxT = amax t maxT
				)
			)
		)		
	)
	animationRange = interval 0 (maxT as Time)	
)