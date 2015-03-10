-- Stonehearth animation utility
-------------------------------------------
-- To use, do this in MAX
-- 1) Run this script
-- 2) Pick the Utilities Rollout
-- 3) Click MAXScript
-- 4) Select "Stonehearth animation utility"
--
-- For sure the "publish skeleton" and "publish animation" buttons work. Everything else is legacy. Use at your own risk. ;)

fileIn "animation.export.ms"
fileIn "animation.helpers.ms"
fileIn  "rig.ms"

-- hardcoded paths. Bad programmer!
BASE_PATH = "C:/stuff"
VOXEL_EXPORT_PATH = BASE_PATH + "/voxels"

utility stonehearthAnimationUtility "Stonehearth Animation Utilities" ( 
	rollout rigging "Rigging" (
		button newBipedRig "New Biped Rig" width: 140
		
		on newRig pressed do (
			local f = getOpenFileName caption: "Voxel OBJ File" filename:VOXEL_EXPORT_PATH types:"OBJ(*.obj)"
			if(f != null) then (
				rig_create_generic f
			)
		)

		on newBipedRig pressed do (
			local f = getOpenFileName caption: "Voxel OBJ File" filename:VOXEL_EXPORT_PATH types:"OBJ(*.obj)"
			print f
			if(f != null) then (
				rig_create_from_file f
			)
		)
	)
	
	rollout keyframes "Keyframes" (
		button duplicateAnimation  "duplicate animation" width: 140
		
		on duplicateAnimation pressed do (
			local sourceAnimation = getOpenFileName caption:"Animation to copy" \
				filename:"c:/users/tom/dropbox/radiant/assets/models/" \
				types:"Max(*.max)"
			
			local destRig = getOpenFileName caption:"Apply animation to" \
				filename:"c:/users/tom/dropbox/radiant/assets/models/" \
				types:"Max(*.max)"			
		)
	)
	
	rollout animation "Animation" (
		button mirrorSelection "mirror selection" width:140
		button mirrorRun "mirror run/walk" width:140
		
		on mirrorSelection pressed do (
			mirror_selection()
		)
		
		on mirrorRun pressed do (
			mirror_animation()
		)
	)
	
	rollout publish "Publish" (
		button publishSkeleton "publish skeleton" width: 140
		button publishAnimation "publish animation" width: 140
		
		on publishSkeleton pressed do (
			publish_skeleton()
		)
		
		on publishAnimation pressed do (
			publish_animation()
		)
	)
	
	on stonehearthAnimationUtility open do	(
		addRollout rigging
		addRollout keyframes
		addRollout animation
		addRollout publish
	) 
)

