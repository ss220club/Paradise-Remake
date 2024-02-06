//YOGSTATION SPECEPODS + ITS ORIGINAL COMMENT
/* ------------------------------------------------------------
This is like paradise spacepods but with a few differences:
- no spacepod fabricator, parts are made in techfabs and frames are made using metal rods.
- not tile based, instead has velocity and acceleration. why? so I can put all this math to use.
- damages shit if you run into it too fast instead of just stopping. You have to have a huge running start to do that though and damages the spacepod as well.
- doesn't explode
------------------------------------------------------------ */

// MrRomainzZ Comment:
// I decided to split the code like mechs do because I find it very similar in some ways
// Mostly untouched, but adapted for paradise and addition of new pods

GLOBAL_LIST_INIT(spacepods_list, list())

/obj/spacepod
	name = "space pod"
	desc = "A frame for a spacepod."
	icon = 'goon/icons/obj/spacepods/construction_2x2.dmi'
	icon_state = "pod_1"
	density = TRUE
	opacity = FALSE
	anchored = TRUE
	dir = NORTH // always points north because why not
	layer = SPACEPOD_LAYER
	bound_width = 64
	bound_height = 64
	animate_movement = NO_STEPS // we do our own gliding here

	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF // it floats above lava or something, I dunno

	max_integrity = 50
	integrity_failure = 50

	var/list/equipment = list()
	var/list/equipment_slot_limits = list(
		SPACEPOD_SLOT_MISC = 1,
		SPACEPOD_SLOT_CARGO = 2,
		SPACEPOD_SLOT_WEAPON = 1,
		SPACEPOD_SLOT_LOCK = 1)
	var/obj/item/spacepod_equipment/lock/lock
	var/obj/item/spacepod_equipment/weaponry/weapon
	var/next_firetime = 0
	var/locked = FALSE
	var/hatch_open = FALSE
	var/construction_state = SPACEPOD_EMPTY
	var/obj/item/pod_parts/armor/pod_armor = null
	var/obj/item/stock_parts/cell/cell = null

	//inner atmos
	var/datum/gas_mixture/cabin_air
	var/obj/machinery/atmospherics/portable/canister/internal_tank
	var/last_slowprocess = 0

	var/mob/living/pilot = null
	var/list/passengers = list()
	var/max_passengers = 0

	var/velocity_x = 0 // tiles per second.
	var/velocity_y = 0
	var/offset_x = 0 // like pixel_x/y but in tiles
	var/offset_y = 0
	var/angle = 0 // degrees, clockwise
	var/desired_angle = null // set by pilot moving his mouse
	var/angular_velocity = 0 // degrees per second
	var/max_angular_acceleration = 360 // in degrees per second per second
	var/last_thrust_forward = 0
	var/last_thrust_right = 0
	var/last_rotate = 0

	var/brakes = TRUE
	var/user_thrust_dir = 0
	// Spacepod speed
	var/forward_maxthrust = 2
	var/backward_maxthrust = 1
	var/side_maxthrust = 1

	var/lights = 0
	var/lights_power = 6
	var/static/list/icon_light_color = list("pod_civ" = LIGHT_COLOR_WHITE, \
									"pod_mil" = "#BBF093", \
									"pod_synd" = LIGHT_COLOR_RED, \
									"pod_gold" = LIGHT_COLOR_WHITE, \
									"pod_black" = "#3B8FE5", \
									"pod_industrial" = "#CCCC00")

	var/bump_impulse = 0.6
	var/bounce_factor = 0.2 // how much of our velocity to keep on collision
	var/lateral_bounce_factor = 0.95 // mostly there to slow you down when you drive (pilot?) down a 2x2 corridor

/obj/spacepod/Initialize(mapload)
	. = ..()
	GLOB.spacepods_list += src
	START_PROCESSING(SSspacepod, src)
	cabin_air = new
	cabin_air.temperature = T20C
	cabin_air.volume = 200

	/* Paradise variant
	cabin_air.oxygen = O2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
	cabin_air.nitrogen = N2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
	*/

	/* Yogstation variant
	cabin_air.assert_gas(GAS_O2)
	cabin_air.assert_gas(GAS_N2)
	cabin_air.gases[GAS_O2][MOLES] = ONE_ATMOSPHERE*O2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
	cabin_air.gases[GAS_N2][MOLES] = ONE_ATMOSPHERE*N2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
	*/

///////////////////////
//////  Helpers  //////
///////////////////////

/obj/spacepod/Entered()
	. = ..()

/obj/spacepod/Exited()
	. = ..()

/obj/spacepod/proc/InterceptClickOn(mob/user, params, atom/target)
	var/list/params_list = params2list(params)
	if(target == src || istype(target, /atom/movable/screen) || (target && (target in user.get_contents())) || user != pilot || params_list["shift"] || params_list["alt"] || params_list["ctrl"])
		return FALSE
	// if(weapon) // RMNZ: As i said, weapons don't work for now
	// 	weapon.fire_weapons(target)
	return TRUE

/obj/spacepod/proc/enter_pod(mob/living/user)
	if(user.stat != CONSCIOUS)
		return FALSE

	if(locked) // RMNZ: You also show health of your mob in chat
		to_chat(user, "<span class='warning'>[src]'s doors are locked!</span>")
		return FALSE

	if(!istype(user))
		return FALSE

	if(user.incapacitated())
		return FALSE
	if(!ishuman(user))
		return FALSE

	if(passengers.len <= max_passengers || !pilot)
		visible_message("<span class='notice'>[user] starts to climb into [src].</span>")
		if(do_after(user, 4 SECONDS, target = src) && construction_state == SPACEPOD_ARMOR_WELDED)  // RMNZ: No check for free passenger seats
			var/success = add_rider(user)
			if(!success)
				to_chat(user, "<span class='notice'>You were too slow. Try better next time, loser.</span>")
			return success
		else
			to_chat(user, "<span class='notice'>You stop entering [src].</span>")
	else
		to_chat(user, "<span class='danger'>You can't fit in [src], it's full!</span>")
	return FALSE

/obj/spacepod/proc/go_out(forced, atom/newloc = loc)
	if(!pilot)
		return
	if(!isliving(usr) || usr.stat > CONSCIOUS)
		return

	if(usr.restrained())
		to_chat(usr, "<span class='notice'>You attempt to stumble out of [src]. This will take two minutes.</span>")
		if(pilot)
			to_chat(pilot, "<span class='warning'>[usr] is trying to escape [src].</span>")
		if(!do_after(usr, 2 MINUTES, target = src))
			return

	if(remove_rider(usr))
		to_chat(usr, "<span class='notice'>You climb out of [src].</span>")

/obj/spacepod/proc/add_rider(mob/living/M, allow_pilot = TRUE)
	if(M == pilot || (M in passengers))
		return FALSE
	if(!pilot && allow_pilot)
		pilot = M
		LAZYOR(M.mousemove_intercept_objects, src)
		M.click_intercept = src
		GrantActions(M)
		// addverbs(M)
	else if(passengers.len < max_passengers)
		passengers += M
		GrantActions(M)
	else
		return FALSE
	GrantActions(M) // Passengers have buttons now
	M.stop_pulling()
	M.forceMove(src)
	playsound(src, 'sound/machines/windowdoor.ogg', 50, 1)
	return TRUE

/obj/spacepod/proc/remove_rider(mob/living/M)
	if(!M)
		return

	RemoveActions(M)

	if(M == pilot)
		pilot = null
		// removeverbs(M)
		LAZYREMOVE(M.mousemove_intercept_objects, src)
		if(M.click_intercept == src)
			M.click_intercept = null
		desired_angle = null // since there's no pilot there's no one aiming it.
	else if(M in passengers)
		passengers -= M
	else
		return FALSE
	if(M.loc == src)
		M.forceMove(loc)
	if(M.client)
		M.client.pixel_x = 0
		M.client.pixel_y = 0
	return TRUE

/obj/spacepod/proc/lock_pod()
	if(!lock) // RMNZ: Passengers see this instead of "You can't reach controls"
		to_chat(usr, "<span class='warning'>[src] has no locking mechanism.</span>")
		locked = FALSE //Should never be false without a lock, but if it somehow happens, that will force an unlock.
	else
		locked = !locked
		to_chat(usr, "<span class='warning'>You [locked ? "lock" : "unlock"] the doors.</span>") // RMNZ: You "tap" on the pod with your key. Also action button doesn't update

/obj/spacepod/proc/verb_check(require_pilot = TRUE, mob/user = null)
	if(!user)
		user = usr
	if(require_pilot && user != pilot)
		to_chat(user, "<span class='notice'>You can't reach the controls from your chair</span>")
		return FALSE
	return !user.incapacitated() && isliving(user)

/obj/spacepod/AltClick(user)
	if(!verb_check(user = user))
		return
	brakes = !brakes
	to_chat(usr, "<span class='notice'>You toggle the brakes [brakes ? "on" : "off"].</span>")

////////////////////////
//////  AttackBy  //////
////////////////////////

/obj/spacepod/attackby(obj/item/W, mob/living/user)
	if(user.a_intent == INTENT_HARM)
		return ..()
	else if(construction_state != SPACEPOD_ARMOR_WELDED)
		. = handle_spacepod_construction(W, user)
		if(.)
			return
		else
			return ..()
	// and now for the real stuff
	else
		if(W.tool_behaviour == TOOL_CROWBAR)
			if(hatch_open || !locked)
				hatch_open = !hatch_open
				W.play_tool_sound(src)
				to_chat(user, "<span class='notice'>You [hatch_open ? "open" : "close"] the maintenance hatch.</span>")
			else
				to_chat(user, "<span class='warning'>The hatch is locked shut!</span>")
			return TRUE
		if(istype(W, /obj/item/stock_parts/cell))
			if(!hatch_open)
				to_chat(user, "<span class='warning'>The maintenance hatch is closed!</span>")
				return TRUE
			if(cell)
				to_chat(user, "<span class='notice'>The pod already has a battery.</span>")
				return TRUE
			if(user.drop_item())
				to_chat(user, "<span class='notice'>You insert [W] into the pod.</span>")
				W.forceMove(src)
				cell = W
			return TRUE
		if(istype(W, /obj/item/spacepod_equipment))
			if(!hatch_open)
				to_chat(user, "<span class='warning'>The maintenance hatch is closed!</span>")
				return TRUE
			var/obj/item/spacepod_equipment/SE = W
			if(SE.can_install(src, user))
				if(user.drop_item())
					SE.forceMove(src)
					SE.on_install(src)
			return TRUE
		if(lock && istype(W, /obj/item/device/lock_buster))
			var/obj/item/device/lock_buster/L = W
			if(L.on)
				user.visible_message("<span class='warning'>[user] is drilling through [src]'s lock!</span>",
					"<span class='notice'>You start drilling through [src]'s lock!</span>")
				if(do_after(user, 10 SECONDS * W.toolspeed, target = src))
					if(lock)
						var/obj/O = lock
						lock.on_uninstall()
						qdel(O)
						user.visible_message("<span class='warning'>[user] has destroyed [src]'s lock!</span>",
							"<span class='notice'>You destroy [src]'s lock!</span>")
				else
					user.visible_message("<span class='warning'>[user] fails to break through [src]'s lock!</span>",
					"<span class='notice'>You were unable to break through [src]'s lock!</span>")
				return TRUE
			to_chat(user, "<span class='notice'>Turn the [L] on first.</span>")
			return TRUE
		if(W.tool_behaviour == TOOL_WELDER)
			var/repairing = cell || internal_tank || equipment.len || (obj_integrity < max_integrity) || pilot || passengers.len
			if(!hatch_open)
				to_chat(user, "<span class='warning'>You must open the maintenance hatch before [repairing ? "attempting repairs" : "unwelding the armor"].</span>")
				return TRUE
			if(repairing && obj_integrity >= max_integrity)
				to_chat(user, "<span class='warning'>[src] is fully repaired!</span>")
				return TRUE
			to_chat(user, "<span class='notice'>You start [repairing ? "repairing [src]" : "slicing off [src]'s armor'"]</span>")
			if(W.use_tool(src, user, 50, amount=3, volume = 50))
				if(repairing)
					obj_integrity = min(max_integrity, obj_integrity + 10)
					update_appearance(UPDATE_ICON)
					to_chat(user, "<span class='notice'>You mend some [pick("dents","bumps","damage")] with [W]</span>")
				else if(!cell && !internal_tank && !equipment.len && !pilot && !passengers.len && construction_state == SPACEPOD_ARMOR_WELDED)
					user.visible_message("[user] slices off [src]'s armor.", "<span class='notice'>You slice off [src]'s armor.</span>")
					construction_state = SPACEPOD_ARMOR_SECURED
					update_appearance(UPDATE_ICON)
			return TRUE
	return ..()

////////////////////////////////////
//////  Health related procs  //////
////////////////////////////////////

/obj/spacepod/Destroy()
	GLOB.spacepods_list -= src
	QDEL_NULL(pilot)
	QDEL_LIST_CONTENTS(passengers)
	QDEL_LIST_CONTENTS(equipment)
	QDEL_NULL(cabin_air)
	QDEL_NULL(cell)
	return ..()

/obj/spacepod/attack_hand(mob/user as mob)
	if(user.a_intent == INTENT_GRAB && !locked)
		var/mob/living/target
		if(pilot)
			target = pilot
		else if(passengers.len > 0)
			target = passengers[1]

		if(target && istype(target)) // RMNZ: You can rip yourself out the pod
			src.visible_message("<span class='warning'>[user] is trying to rip the door open and pull [target] out of [src]!</span>",
				"<span class='warning'>You see [user] outside the door trying to rip it open!</span>")
			if(do_after(user, 5 SECONDS, target = src) && construction_state == SPACEPOD_ARMOR_WELDED)
				if(remove_rider(target))
					target.Stun(20)
					target.visible_message("<span class='warning'>[user] flings the door open and tears [target] out of [src]</span>",
						"<span class='warning'>The door flies open and you are thrown out of [src] and to the ground!</span>")
				return
			target.visible_message("<span class='warning'>[user] was unable to get the door open!</span>",
					"<span class='warning'>You manage to keep [user] out of [src]!</span>")

	if(!hatch_open)
		//if(cargo_hold.storage_slots > 0)
		//	if(!locked)
		//		cargo_hold.open(user)
		//	else
		//		to_chat(user, "<span class='notice'>The storage compartment is locked</span>")
		return ..()

	if(user == pilot)
		return ..()

	var/list/items = list(cell, internal_tank)
	items += equipment
	var/list/item_map = list()
	//var/list/used_key_list = list()
	for(var/obj/I in items)
		item_map[I.name] = I
	var/selection = input(user, "Remove which equipment?", null, null) as null|anything in item_map
	var/obj/O = item_map[selection]
	if(O && istype(O) && (O in contents) && user != pilot)
		// alrightey now to figure out what it is
		if(O == cell)
			cell = null
		else if(O == internal_tank)
			internal_tank = null
		else if(O in equipment)
			var/obj/item/spacepod_equipment/SE = O
			if(!SE.can_uninstall(user))
				return
			SE.on_uninstall()
		else
			return
		O.forceMove(loc)
		if(isitem(O))
			user.put_in_hands(O)

/obj/spacepod/ex_act(severity)
	switch(severity)
		if(1)
			for(var/mob/living/M in contents)
				M.ex_act(severity+1)
			deconstruct()
		if(2)
			take_damage(100, BRUTE, BOMB, 0)
		if(3)
			if(prob(40))
				take_damage(40, BRUTE, BOMB, 0)

/obj/spacepod/obj_break()
	if(obj_integrity <= 0)
		return // nah we'll let the other boy handle it
	if(construction_state < SPACEPOD_ARMOR_LOOSE)
		return
	if(pod_armor)
		var/obj/A = pod_armor
		remove_armor()
		qdel(A)
		if(prob(40))
			new /obj/item/stack/sheet/metal(loc, 5)
	if(prob(40))
		new /obj/item/stack/sheet/metal(loc, 5)
	construction_state = SPACEPOD_CORE_SECURED
	if(cabin_air)
		var/datum/gas_mixture/GM = cabin_air.remove_ratio(1)
		var/turf/T = get_turf(src)
		if(GM && T)
			T.assume_air(GM)
	cell = null
	internal_tank = null
	for(var/atom/movable/AM in contents)
		if(AM in equipment)
			var/obj/item/spacepod_equipment/SE = AM
			if(istype(SE))
				SE.on_uninstall(src)
		if(ismob(AM))
			forceMove(AM, loc)
			remove_rider(AM)
		else if(prob(60))
			AM.forceMove(loc)
		else if(isitem(AM) || !isobj(AM))
			qdel(AM)
		else
			var/obj/O = AM
			O.forceMove(loc)
			O.deconstruct()

/obj/spacepod/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = TRUE, attack_dir, armour_penetration = 0)
	..()
	update_appearance(UPDATE_ICON)

/obj/spacepod/deconstruct(disassembled = FALSE)
	if(!get_turf(src))
		qdel(src)
		return
	remove_rider(pilot)
	while(passengers.len)
		remove_rider(passengers[1])
	passengers.Cut()
	if(disassembled)
		// AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
		// alright fine fine you can have the frame pieces back
		var/clamped_angle = (round(angle, 90) % 360 + 360) % 360
		var/target_dir = NORTH
		switch(clamped_angle)
			if(0)
				target_dir = NORTH
			if(90)
				target_dir = EAST
			if(180)
				target_dir = SOUTH
			if(270)
				target_dir = WEST
		//RMNZ: Count this for addition of new pods (?)
		var/list/frame_piece_types = list(/obj/item/pod_parts/pod_frame/aft_port, /obj/item/pod_parts/pod_frame/aft_starboard, /obj/item/pod_parts/pod_frame/fore_port, /obj/item/pod_parts/pod_frame/fore_starboard)
		var/obj/item/pod_parts/pod_frame/current_piece = null
		var/turf/CT = get_turf(src)
		var/list/frame_pieces = list()
		for(var/frame_type in frame_piece_types)
			var/obj/item/pod_parts/pod_frame/F = new frame_type
			F.dir = target_dir
			F.anchored = TRUE
			if(1 == turn(F.dir, -F.link_angle))
				current_piece = F
			frame_pieces += F
		while(current_piece && !current_piece.loc)
			if(!CT)
				break
			current_piece.forceMove(CT)
			CT = get_step(CT, turn(current_piece.dir, -current_piece.link_angle))
			current_piece = locate(current_piece.link_to) in frame_pieces
		// there here's your frame pieces back, happy?
	qdel(src)

/////////////////////////////////
//////  Atmospheric stuff  //////
/////////////////////////////////

/obj/spacepod/return_air()
	return cabin_air

/obj/spacepod/remove_air(amount)
	return cabin_air.remove(amount)

/obj/spacepod/proc/return_temperature()
	var/datum/gas_mixture/t_air = return_air()
	if(t_air)
		. = t_air.return_temperature()

/obj/spacepod/proc/slowprocess()
	// Temp Regulation
	if(cabin_air && cabin_air.return_volume() > 0)
		var/delta = cabin_air.temperature - T20C
		cabin_air.temperature -= max(-10, min(10, round(delta / 4, 0.1)))

	// Air Regulation
	if(internal_tank && cabin_air)
		var/datum/gas_mixture/tank_air = internal_tank.return_air()

		var/release_pressure = ONE_ATMOSPHERE
		var/cabin_pressure = cabin_air.return_pressure()
		var/pressure_delta = min(release_pressure - cabin_pressure, (tank_air.return_pressure() - cabin_pressure)/2)
		var/transfer_moles = 0
		if(pressure_delta > 0) //cabin pressure lower than release pressure
			if(tank_air.return_temperature() > 0)
				transfer_moles = pressure_delta*cabin_air.return_volume()/(cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
				var/datum/gas_mixture/removed = tank_air.remove(transfer_moles)
				cabin_air.merge(removed)
		else if(pressure_delta < 0) //cabin pressure higher than release pressure
			var/datum/gas_mixture/t_air = return_air()
			pressure_delta = cabin_pressure - release_pressure
			if(t_air)
				pressure_delta = min(cabin_pressure - t_air.return_pressure(), pressure_delta)
			if(pressure_delta > 0) //if location pressure is lower than cabin pressure
				transfer_moles = pressure_delta*cabin_air.return_volume()/(cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
				var/datum/gas_mixture/removed = cabin_air.remove(transfer_moles)
				if(t_air)
					t_air.merge(removed)
				else //just delete the cabin gas, we're in space or some shit
					qdel(removed)

	//Power Related
	if(!cell || cell.charge < 1) // RMNZ: How to update action button from here?
		lights = 0
		set_light(0)

//////////////////////////////
//////  Movement procs  //////
//////////////////////////////

/obj/spacepod/onMouseMove(object, location, control, params)
	if(!pilot || !pilot.client || pilot.incapacitated() || params == null)
		return // I don't know what's going on.
	var/list/params_list = params2list(params) // icon-x, icon-y, screen-loc
	var/sl_list = splittext(params_list["screen-loc"],",") // get only screen-loc
	var/sl_x_list = splittext(sl_list[1], ":") // sl-x[1] = tile, sl-x[2] = pixel on tile
	var/sl_y_list = splittext(sl_list[2], ":") // sl-y[1] = tile, sl-y[2] = pixel on tile
	var/view_list = isnum(pilot.client.view) ? list("[pilot.client.view*2+1]","[pilot.client.view*2+1]") : splittext(pilot.client.view, "x")
	var/dx = text2num(sl_x_list[1]) + (text2num(sl_x_list[2]) / world.icon_size) - 1 - text2num(view_list[1]) / 2
	var/dy = text2num(sl_y_list[1]) + (text2num(sl_y_list[2]) / world.icon_size) - 1 - text2num(view_list[2]) / 2
	if(sqrt(dx*dx+dy*dy) > 1)
		desired_angle = 90 - ATAN2(dx, dy)
	else
		desired_angle = null

/obj/spacepod/relaymove(mob/user, direction)
	if(user != pilot || pilot.incapacitated())
		return
	user_thrust_dir = direction

//////////////////////////////////
//////  Construction procs  //////
//////////////////////////////////

/obj/spacepod/proc/add_armor(obj/item/pod_parts/armor/armor)
	desc = armor.pod_desc
	max_integrity = armor.pod_integrity
	obj_integrity = max_integrity - integrity_failure + obj_integrity
	pod_armor = armor
	update_appearance(UPDATE_ICON)

/obj/spacepod/proc/remove_armor()
	if(!pod_armor)
		obj_integrity = min(integrity_failure, obj_integrity)
		max_integrity = integrity_failure
		desc = initial(desc)
		pod_armor = null
		update_appearance(UPDATE_ICON)

/obj/spacepod/update_icon_state()
	. = ..()
	if(construction_state != SPACEPOD_ARMOR_WELDED)
		icon = 'goon/icons/obj/spacepods/construction_2x2.dmi'
		icon_state = "pod_[construction_state]"
		return

	if(pod_armor)
		icon = pod_armor.pod_icon
		icon_state = pod_armor.pod_icon_state
	else
		icon = 'goon/icons/obj/spacepods/2x2.dmi'
		icon_state = initial(icon_state)

/obj/spacepod/update_overlays()
	. = ..()
	if(construction_state != SPACEPOD_ARMOR_WELDED)
		if(pod_armor && construction_state >= SPACEPOD_ARMOR_LOOSE)
			var/mutable_appearance/masked_armor = mutable_appearance(icon = 'goon/icons/obj/spacepods/construction_2x2.dmi', icon_state = "armor_mask")
			var/mutable_appearance/armor = mutable_appearance(pod_armor.pod_icon, pod_armor.pod_icon_state)
			armor.blend_mode = BLEND_MULTIPLY
			masked_armor.overlays = list(armor)
			masked_armor.appearance_flags = KEEP_TOGETHER
			. += masked_armor
		return

	if(obj_integrity <= max_integrity / 2)
		. += image(icon='goon/icons/obj/spacepods/2x2.dmi', icon_state="pod_damage")
		if(obj_integrity <= max_integrity / 4)
			. += image(icon='goon/icons/obj/spacepods/2x2.dmi', icon_state="pod_fire")

	// if(weapon && weapon.overlay_icon_state) // RMNZ: Weapons don't work for now!
	// 	. += image(icon=weapon.overlay_icon,icon_state=weapon.overlay_icon_state)

	light_color = icon_light_color[icon_state] || LIGHT_COLOR_WHITE

	// Thrust!
	var/list/left_thrusts = list()
	left_thrusts.len = 8
	var/list/right_thrusts = list()
	right_thrusts.len = 8
	for(var/cdir in GLOB.cardinal)
		left_thrusts[cdir] = 0
		right_thrusts[cdir] = 0
	var/back_thrust = 0
	if(last_thrust_right != 0)
		var/tdir = last_thrust_right > 0 ? WEST : EAST
		left_thrusts[tdir] = abs(last_thrust_right) / side_maxthrust
		right_thrusts[tdir] = abs(last_thrust_right) / side_maxthrust
	if(last_thrust_forward > 0)
		back_thrust = last_thrust_forward / forward_maxthrust
	if(last_thrust_forward < 0)
		left_thrusts[NORTH] = -last_thrust_forward / backward_maxthrust
		right_thrusts[NORTH] = -last_thrust_forward / backward_maxthrust
	if(last_rotate != 0)
		var/frac = abs(last_rotate) / max_angular_acceleration
		for(var/cdir in GLOB.cardinal)
			if(last_rotate > 0)
				right_thrusts[cdir] += frac
			else
				left_thrusts[cdir] += frac
	for(var/cdir in GLOB.cardinal)
		var/left_thrust = left_thrusts[cdir]
		var/right_thrust = right_thrusts[cdir]
		if(left_thrust)
			. += image(icon = 'code/modules/spacepods/icons/2x2.dmi', icon_state = "rcs_left", dir = cdir)
		if(right_thrust)
			. += image(icon = 'code/modules/spacepods/icons/2x2.dmi', icon_state = "rcs_right", dir = cdir)
	if(back_thrust)
		var/image/I = image(icon = 'code/modules/spacepods/icons/2x2.dmi', icon_state = "thrust")
		I.transform = matrix(1, 0, 0, 0, 1, -32)
		. += I

/obj/spacepod/MouseDrop_T(atom/movable/A, mob/living/user)
	if(user == pilot || (user in passengers) || construction_state != SPACEPOD_ARMOR_WELDED)
		return

	if(istype(A, /obj/machinery/atmospherics/portable/canister))
		if(internal_tank)
			to_chat(user, "<span class='warning'>[src] already has an internaltank!</span>")
			return
		if(!A.Adjacent(src))
			to_chat(user, "<span class='warning'>The canister is not close enough!</span>")
			return
		if(hatch_open)
			to_chat(user, "<span class='warning'>The hatch is shut!</span>")
		to_chat(user, "<span class='notice'>You begin inserting the canister into [src]</span>")
		if(do_after(user, 5 SECONDS, target = A) && construction_state == SPACEPOD_ARMOR_WELDED)
			to_chat(user, "<span class='notice'>You insert the canister into [src]</span>")
			A.forceMove(src)
			internal_tank = A
		return

	if(isliving(A))
		var/mob/living/M = A
		if(M != user && !locked)
			if(passengers.len >= max_passengers && !pilot)
				to_chat(user, "<span class='danger'><b>[A.p_they()] can't fly the pod!</b></span>")
				return
			if(passengers.len < max_passengers)
				visible_message("<span class='danger'>[user] starts loading [M] into [src]!</span>")
				if(do_after(user, 5 SECONDS, target = M) && construction_state == SPACEPOD_ARMOR_WELDED)
					add_rider(M, FALSE)
			return
		if(M == user)
			enter_pod(user)
			return

	return ..()
