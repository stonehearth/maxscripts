fileIn  "rig.ms"

fn duplicate_animation animation source dest = (
	--print "Duplicating animation...from...to..."
	--print animation
	--print source
	--print dest	
	
	-- calculate the rig from the source
	loadMaxFile source
	local source_rig = rig_create()
	
	-- calculate the keyframes from the animation and the rig
	loadMaxFile animation
	local keyframes = keyframes_create source_rig
	
	-- apply the keyframes to the dest
	loadMaxFile dest
	keyframes_apply keyframes
	
	-- save the new file
	local animationParts = filterstring animation "\\"
	local outFileName = maxFilePath + "animations\\" + animationParts[animationParts.count]
	saveMaxFile outFileName
	set animate on
	return outFileName
)
