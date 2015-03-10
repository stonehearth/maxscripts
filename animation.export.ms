-- Functions for exporting Stonehearth animation and skeleton files

function format_rot rot = (
	return "[" + rot.w as string + "," + rot.x as string + "," + rot.y as string + "," + rot.z as string +"]"
)

function format_rot_y_up rot = (
	return "[" + rot.w as string + "," + rot.x as string + "," + rot.z as string + "," + (-1 * rot.y) as string +"]"
)

--function z_to_y_up2 q = (
--	local q2 = quat q.axis q.angle
--	q2.z = -q.y
--	q2.y = q.z
--	return formatRot q2
--)


function bone_info b = (
	yupPos = b.pos
	 
	yupRot = format_rot(b.rotation)
	
	bone_str = "\t\t\t\t" + "\"" + b.name + "\": {\n"
	
	-- pos
	bone_str += "\t\t\t\t\t" + "\"pos\": " + yupPos as string
	
	-- rot
	bone_str +=  ",\n"
	bone_str += "\t\t\t\t\t" + "\"rot\": " + yupRot + "\n"
	
	bone_str += "\t\t\t\t" + "}"
	return bone_str
)

function frame_info  = (

	frame = "\t\t\t{\n"
	for b in $* do (
		if (substring b.name 1 1) != "_" do (
			frame += bone_info b
			frame += ",\n"
		)
	)
	
	-- nip off the last comma
	frame = substring frame 1 (frame.count - 2)
	frame += "\n\t\t\t}"

	return frame
)

function publish_animation startFrame:animationRange.start endFrame:animationRange.end = (
	local fileName = (filterString maxFileName ".")[1]
	local output_path = maxFilePath + "export\\" + fileName + ".json"
	local out = "{\n"
	out += "\t\"type\": \"animation\",\n"
	out += "\t\"frames\": [\n"

	for frameNum = startFrame to endFrame do (
		-- each frame
		sliderTime = frameNum
		out += frame_info()
		if frameNum < animationRange.end do (
			out += ","
		) 
		out += "\n"
	)

	out += "\t]\n"
	out += "}\n"

	makeDir (maxFilePath + "export")
	outFile = createFile output_path
	format "%" out to:outFile
	close outFile
	
	print output_path
	--print out
)

function publish_skeleton = (
	local fileName = (filterString maxFileName ".")[1]
	local output_path = maxFilePath + "export\\" + fileName + ".json"
	--local output_path = "C:\\Users\\tom\\radiant\\stonehearth\\source\\stonehearth_data\\mods\\stonehearth\\data\\rigs\\humans\\skeletons\\female.json"
	local out = "{\n"
	out += "   \"skeleton\" : {\n"

	for b in $* do (
		local pos = b.pos
	
		--pos.x = b.pos.x * -1
		--pos.y = b.pos.z
		--pos.z = b.pos.y * -1
		
		--local y_up_pos = b.pos
		--y_up_pos.x = b.pos.x
		--y_up_pos.y = b.pos.z
		--y_up_pos.z = b.pos.y
		
		out += "      \"" + b.name + "\": " + pos as string + ",\n"
	)
	
	-- nip off the last comma
	-- XXX, this is a bunch of hardcoded stuff that goes at the end of the file. It's utterly stupid
	-- that this stuff is defined here, and if you're generating a skeleton for anything other than
	-- the human female character (which is probably very likely for you, right?) you will need to hand-edit
	-- the generated file.
	--
	-- Ideally maybe this stuff should be passed into the publish_skeleton function...or something
	out = substring out 1 (out.count - 2)
	out += "\n    },\n";
	out += "   \"animation_root\" : \"file(../animations/female)\",\n"
	out += "   \"effects_root\" : \"file(../effects)\",\n"
	out += "   \"postures\" : \"file(../postures.json)\",\n"
	out += "   \"collision_shape\" : {\n"
	out += "      \"type\" : \"cylinder_collision_shape\",\n"
	out += "      \"radius\" : 5,\n"
	out += "      \"height\" : 35\n"
	out += "   }\n"
	out += "}"

	outFile = createFile output_path
	format "%" out to:outFile
	close outFile
	
	print output_path;
	print out;
)
