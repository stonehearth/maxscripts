/*
fn mirrorOne a srcFrame destFrame = (
	try (
		at time srcFrame ( ap = a.pos )
		with animate on at time destFrame ( a.pos = ap	)
	) catch (
	)

	try (
		at time srcFrame (
			arx = a.rotation.x_rotation
			ary = a.rotation.y_rotation
			arz = a.rotation.z_rotation
		)
		with animate on at time destFrame ( 
			a.rotation.x_rotation = arx
			a.rotation.y_rotation = -1 * ary
			a.rotation.z_rotation = -1 * arz
		)
	) catch (
		print "skipping rot for "
		print a
	)
	
)


fn mirrorTwo a b srcFrame destFrame = (
	try (
		at time srcFrame (
			ap = a.pos
			bp = b.pos
			
			arx = a.rotation.x_rotation
			ary = a.rotation.y_rotation
			arz = a.rotation.z_rotation

			brx = b.rotation.x_rotation
			bry = b.rotation.y_rotation
			brz = b.rotation.z_rotation
		)

		with animate on at time destFrame (
			a.pos.x = bp.x * -1
			a.pos.y = bp.y
			a.pos.z = bp.z

			b.pos.x = ap.x * -1
			b.pos.y = ap.y
			b.pos.z = ap.z

			a.rotation.x_rotation = brx
			b.rotation.x_rotation = arx

			a.rotation.y_rotation = bry * -1
			b.rotation.y_rotation = ary * -1

			a.rotation.z_rotation = brz * -1
			b.rotation.z_rotation = arz * -1
		)
	) catch (
	)
)

fn r2l a b = (

	ap = a.pos
	
	arx = a.rotation.x_rotation
	ary = a.rotation.y_rotation
	arz = a.rotation.z_rotation

	b.pos.x = ap.x * -1
	b.pos.y = ap.y
	b.pos.z = ap.z

	b.rotation.x_rotation = arx
	b.rotation.y_rotation = ary * -1
	b.rotation.z_rotation = arz * -1
)

fn r2lhands = (
		r2l $bone_body_r_shoulder $bone_body_l_shoulder
		r2l $bone_body_r_cuff $bone_body_l_cuff

		
		--r2l $bone_body_r_hand $bone_body_l_hand

		r2l $bone_body_r_f11 $bone_body_l_f11
		r2l $bone_body_r_f21 $bone_body_l_f21
		r2l $bone_body_r_f31 $bone_body_l_f31
		r2l $bone_body_r_f12 $bone_body_l_f12
		r2l $bone_body_r_f22 $bone_body_l_f22
		r2l $bone_body_r_f32 $bone_body_l_f32
		r2l $bone_body_r_t1 $bone_body_l_t1
		r2l $bone_body_r_t2 $bone_body_l_t2
)

fn mirrorPose srcFrame destFrame = (
		-- NOTE, this must be done in order, from the root down to the leaves.
		mirrorOne $bone_root srcFrame destFrame
		mirrorOne $bone_pos srcFrame destFrame
		mirrorOne $bone_body_head srcFrame destFrame
		mirrorOne $bone_body_torso srcFrame destFrame
		mirrorOne $bone_body_pelvis srcFrame destFrame
		
		mirrorTwo $bone_body_r_shoulder $bone_body_l_shoulder srcFrame destFrame		
		mirrorTwo $bone_body_r_cuff $bone_body_l_cuff srcFrame destFrame

		
		mirrorTwo $bone_body_r_hand $bone_body_l_hand srcFrame destFrame

		mirrorTwo $bone_body_r_f11 $bone_body_l_f11 srcFrame destFrame
		mirrorTwo $bone_body_r_f21 $bone_body_l_f21 srcFrame destFrame
		mirrorTwo $bone_body_r_f31 $bone_body_l_f31 srcFrame destFrame
		mirrorTwo $bone_body_r_f12 $bone_body_l_f12 srcFrame destFrame
		mirrorTwo $bone_body_r_f22 $bone_body_l_f22 srcFrame destFrame
		mirrorTwo $bone_body_r_f32 $bone_body_l_f32 srcFrame destFrame
		mirrorTwo $bone_body_r_t1 $bone_body_l_t1 srcFrame destFrame
		mirrorTwo $bone_body_r_t2 $bone_body_l_t2 srcFrame destFrame

		mirrorTwo $bone_body_r_foot $bone_body_l_foot srcFrame destFrame

)
*/

-- ------------------------------------------------------------------------------------------------------------------------------------------

fn mirror_selection = (
	for b in selection do (
		local mirror_name = b.name
		local part
		
		if((substring b.name 1 4) == "left") then (
			mirror_name = replace b.name 1 4 "right"
		) else (
			mirror_name = replace b.name 1 5 "left"
		)
		
		mirror_bones b (getNodeByName(mirror_name))
	)
)

fn mirror_bones b b_dest = (
	b_dest.rotation.x =  b.rotation.x
	b_dest.rotation.y = b.rotation.y * -1
	b_dest.rotation.z = b.rotation.z * -1
	
	b_dest.pos = b.pos
	b_dest.pos.x = b.pos.x * -1
)

fn mirror_keys b src_frame dest_frame = (
	
	local mirror_name = b.name
 
	if((substring b.name 1 4) == "left") then (
		mirror_name = replace b.name 1 4 "right"
	) else if ((substring b.name 1 5) == "right") then (
		mirror_name = replace b.name 1 5 "left"
	) else (
		mirror_name = b.name
	)
	
	local b_dest = getNodeByName mirror_name

	if (b_dest != undefined) then (
		--print("  " + b.name as string + " to " + mirror_name as string)
		-- rotation
		object_keys = b.rotation.controller.keys
		for i = 1 to object_keys.count do (
			t = object_keys[i].time.frame as integer
			
			if (t == src_frame) then (
				--print ("    mirroring rot key from " + src_frame as string  + " to " + dest_frame as string)
				with animate on at time dest_frame (
					b_dest.rotation.x = at time src_frame b.rotation.x
					b_dest.rotation.y = (at time src_frame b.rotation.y) * -1
					b_dest.rotation.z = (at time src_frame b.rotation.z) * -1
					
					selectKeys b_dest.pos.controller (dest_frame as Time) (dest_frame as Time)
					deleteKeys b_dest.pos.controller #selection	

				)
				break
				--selectKeys b.pos.controller (src_frame as Time) (src_frame as Time)
				--deleteKeys b.pos.controller #selection
			)
		)

		-- position
		local object_keys = b.pos.controller.keys
		for i = 1 to object_keys.count do (
			t = object_keys[i].time.frame as integer
			
			if (t == src_frame) then (
				--print ("    mirroring pos key from " + src_frame as string  + " to " + dest_frame as string)
				with animate on at time dest_frame (
					b_dest.pos = at time src_frame b.pos
					b_dest.pos.x = (at time src_frame b.pos.x) * -1
				)
				break
			)
		)
	)

)

fn clear_keys_in_range start end = (
	for b in $bone_* do (
		selectKeys b.pos.controller (start as Time) (end as Time)
		deleteKeys b.pos.controller #selection	
		
		selectKeys b.rotation.controller (start as Time) (end as Time)
		deleteKeys b.rotation.controller #selection
	)
)

fn mirror_animation = (
	mid = (animationRange.end - animationRange.start) / 2
	--mirrorFrame $bone_body_r_foot $bone_body_l_foot 0 12
	
	clear_keys_in_range mid animationRange.end
	
	for frame_num = animationRange.start to mid  do (
		src_frame = frame_num
		dest_frame = frame_num + mid 
		
		--print("frame " + src_frame as string + " to " + dest_frame as string)
		for b in $* do (
			mirror_keys b src_frame dest_frame
		)
		
		--for b in $left* do (
			--mirror_keys b src_frame dest_frame
		--)
		
		--for b in $right* do (
			--mirror_keys b src_frame dest_frame
		--)
	)
)

--mirror_animation()
