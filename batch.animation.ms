-- Given a base path, a source, and a target, do this...
--    1) Iterate through every animation in the source
--    2) If that animation doesn't exist in the dest, create it, modifying the animation to fit the dest rig

fileIn "animation.duplicate.ms"
fileIn "animation.export.ms"

-- hardcoded base path. Bad programmer!
base_path = "C:\\stuff"

function batch_create source target = (
	
	local source_animation_dir = (base_path + source + "\\animations\\")
	local target_animation_dir = (base_path + target + "\\animations\\")
	
	print source_animation_dir
	files = getFiles (source_animation_dir + "*.max")
	for source_animation in files do (
		local parts = (filterString source_animation "\\")
		local animation_name = parts[parts.count]
		
		local dest_animation = (target_animation_dir + animation_name)
		local source_rig = (base_path + source + "\\" + source + ".max")
		local dest_rig = (base_path + target + "\\" + target + ".max")
		
		if getFileSize(dest_animation) == 0 then (
			print ("creating " + dest_animation)
			print ("   source_rig " + source_rig)
			print ("   dest_rig " + dest_rig)
			duplicate_animation source_animation source_rig dest_rig
			publish_animation()
			--loadMAXFile f; print objects
		)
	)
)

batch_create "civ" "goblin"
