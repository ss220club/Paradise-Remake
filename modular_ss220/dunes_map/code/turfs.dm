#define DESERT_WINTER 180

/turf/simulated/floor/brick
	name = "brick floor"
	icon = 'modular_ss220/dunes_map/icons/desert.dmi'
	icon_state = "brick"
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_COLD
	temperature = DESERT_WINTER

/turf/simulated/floor/plating/ice

/turf/simulated/floor/vault/lavaland_air

/turf/simulated/floor/brick/cold
	atmos_environment = ENVIRONMENT_TEMPERATE
	temperature = T20C

/turf/simulated/floor/indestructible/dune_sand
	name = "dune sand"
	icon = 'modular_ss220/dunes_map/icons/desert.dmi'
	icon_state = "sand"
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_COLD
	temperature = DESERT_WINTER
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	smoothing_groups = list(SMOOTH_GROUP_FLOOR)
	var/environment_type = "sand"
	var/obj/item/stack/digResult = /obj/item/stack/ore/glass
	var/floor_variance = 10
	var/dug

/turf/simulated/floor/indestructible/dune_sand/Initialize(mapload)
	var/proper_name = name
	. = ..()
	name = proper_name
	if(prob(floor_variance))
		icon_state = "[environment_type][rand(1,4)]"

/turf/simulated/floor/indestructible/dune_sand/proc/getDug()
	new digResult(src, 5)
	icon_plating = "[environment_type]_dug"
	icon_state = "[environment_type]_dug"
	dug = TRUE

/turf/simulated/floor/indestructible/dune_sand/proc/can_dig(mob/user)
	if(!dug)
		return TRUE
	if(user)
		to_chat(user, "<span class='notice'>Выглядит так, будто тут уже кто-то копал.</span>")

/turf/simulated/floor/indestructible/dune_sand/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/simulated/floor/indestructible/dune_sand/burn_tile()
	return

/turf/simulated/floor/indestructible/dune_sand/MakeSlippery(wet_setting)
	return

/turf/simulated/floor/indestructible/dune_sand/MakeDry(wet_setting)
	return

/turf/simulated/floor/indestructible/dune_sand/remove_plating()
	return

/turf/simulated/floor/indestructible/dune_sand/crowbar_act(mob/user, obj/item/I)
	return

/turf/simulated/floor/indestructible/dune_sand/ex_act(severity)
	if(!can_dig())
		return
	switch(severity)
		if(3)
			return
		if(2)
			if(prob(20))
				getDug()
		if(1)
			getDug()

/turf/simulated/floor/indestructible/dune_sand/attackby(obj/item/I, mob/user, params)
	if(!I|| !user)
		return FALSE

	if((istype(I, /obj/item/shovel) || istype(I, /obj/item/pickaxe)))
		if(!can_dig(user))
			return TRUE

		var/turf/T = get_turf(user)
		if(!istype(T))
			return

		to_chat(user, "<span class='notice'>Вы начинаете копать...</span>")

		playsound(src, I.usesound, 50, TRUE)
		if(do_after(user, 40 * I.toolspeed, target = src))
			if(!can_dig(user))
				return TRUE
			to_chat(user, "<span class='notice'>Вы выкопали яму.</span>")
			getDug()
			return TRUE

	else if(istype(I, /obj/item/storage/bag/ore))
		var/obj/item/storage/bag/ore/S = I
		if(S.pickup_all_on_tile)
			for(var/obj/item/stack/ore/O in contents)
				O.attackby(I, user)
				return

	else if(istype(I, /obj/item/stack/tile))
		var/obj/item/stack/tile/Z = I
		if(!Z.use(1))
			return
		if(istype(Z, /obj/item/stack/tile/plasteel)) // Turn asteroid floors into plating by default
			ChangeTurf(/turf/simulated/floor/plating, keep_icon = FALSE)
		else
			ChangeTurf(Z.turf_type, keep_icon = FALSE)
		playsound(src, 'sound/weapons/Genhit.ogg', 50, TRUE)

/turf/simulated/floor/indestructible/dune_sand/dark
	color = "gray"
	smoothing_groups = null

/turf/simulated/floor/indestructible/dune_sand/dark/cold
	atmos_environment = ENVIRONMENT_TEMPERATE
	temperature = T20C

/turf/simulated/floor/indestructible/dune_sand/cold
	color = "#E6E6E6"
	baseturf = /turf/simulated/floor/indestructible/dune_sand/dug/cold
	atmos_environment = ENVIRONMENT_TEMPERATE
	temperature = T20C

/turf/simulated/floor/indestructible/dune_sand/smooth
	icon = 'modular_ss220/dunes_map/icons/sand_smooth.dmi'
	icon_state = "sand-0"
	base_icon_state = "sand"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_FLOOR)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR)

/turf/simulated/floor/indestructible/dune_sand/smooth/cold
	color = "#E6E6E6"
	baseturf = /turf/simulated/floor/indestructible/dune_sand/dug/cold
	atmos_environment = ENVIRONMENT_TEMPERATE
	temperature = T20C

/turf/simulated/floor/indestructible/dune_sand/dug
	name = "sand dug"
	icon_state = "sand_dug"

/turf/simulated/floor/indestructible/dune_sand/dug/cold
	color = "#E6E6E6"
	baseturf = /turf/simulated/floor/indestructible/dune_sand/dug/cold
	atmos_environment = ENVIRONMENT_TEMPERATE
	temperature = T20C

/turf/simulated/floor/beach/away/water/desert_water
	icon = 'modular_ss220/dunes_map/icons/desert.dmi'
	icon_state = "water"
	baseturf = /turf/simulated/floor/beach/away/water/desert_water
	water_overlay_image = null
	temperature = DESERT_WINTER
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_COLD

/turf/simulated/wall/indestructible/rock/mineral/dune_rock
	name = "dune rock"
	color = "#D9742B"

/turf/simulated/wall/indestructible/rock/mineral/dune_rock/deep_rock
	name = "dune deep rock"
	color = "#603516"

/turf/simulated/floor/chasm/straight_down/lava_land_surface/dune
	icon = 'modular_ss220/dunes_map/icons/chasm.dmi'
	oxygen = 21.8366
	nitrogen = 82.1472
	atmos_environment = ENVIRONMENT_COLD
	temperature = DESERT_WINTER

/turf/simulated/floor/lava/dune
	icon = 'modular_ss220/dunes_map/icons/lava.dmi'
	atmos_mode = ATMOS_MODE_SEALED

//cave turfs

/turf/simulated/floor/indestructible/dune_sand/cave
	name = "cave floor"
	icon = 'modular_ss220/dunes_map/icons/cave_floor.dmi'
	icon_state = "caverock0"
	environment_type = "caverock"
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_TEMPERATE
	temperature = T20C
	digResult = /obj/item/stack/ore/slag
	floor_variance = 10

/turf/simulated/floor/indestructible/dune_sand/cave/dark
	color = "#e0ac7b"

/turf/simulated/floor/indestructible/dune_sand/cave/Initialize(mapload)
	var/proper_name = name
	. = ..()
	name = proper_name
	if(prob(floor_variance))
		icon_state = "[environment_type][rand(1,10)]"

/turf/simulated/floor/indestructible/dune_sand/cave/dug
	name = "cave floor dug"
	icon_state = "caverock_dug"

/turf/simulated/floor/indestructible/dune_sand/cave/dug/dark
	color = "#e0ac7b"

/turf/simulated/floor/indestructible/dune_sand/cave/cold_rock
	color = "#E6E6E6"
	baseturf = /turf/simulated/floor/indestructible/dune_sand/cave/dug/cold

/turf/simulated/floor/indestructible/dune_sand/cave/cold_rock/dark
	color = "#e0ac7b"
	baseturf = /turf/simulated/floor/indestructible/dune_sand/cave/dug/cold/dark

/turf/simulated/floor/indestructible/dune_sand/cave/dug/cold
	color = "#E6E6E6"
	baseturf = /turf/simulated/floor/indestructible/dune_sand/cave/dug/cold

/turf/simulated/floor/indestructible/dune_sand/cave/dug/cold/dark
	color = "#e0ac7b"
	baseturf = /turf/simulated/floor/indestructible/dune_sand/cave/dug/cold/dark

/turf/simulated/floor/indestructible/dune_sand/cave/cavedeep
	icon_state = "caverockdeep0"
	environment_type = "caverockdeep"
	digResult = /obj/item/stack/sheet/mineral/sandstone

/turf/simulated/floor/indestructible/dune_sand/cave/cavedeep/dark
	color = "#e0ac7b"

/turf/simulated/floor/indestructible/dune_sand/cave/cavedeep/dark/dark_basalt
	color = "#4d4742"

/turf/simulated/floor/indestructible/dune_sand/cave/cavedeep/dug
	name = "cave floor dug"
	icon_state = "caverockdeep_dug"

/turf/simulated/floor/indestructible/dune_sand/cave/cavedeep/dug/dark
	color = "#e0ac7b"

/turf/simulated/floor/indestructible/dune_sand/cave/cavedeep/dug/dark/dark_basalt
	color = "#4d4742"

/turf/simulated/floor/indestructible/dune_sand/cave/cavedeep/cold_rock
	color = "#E6E6E6"
	baseturf = /turf/simulated/floor/indestructible/dune_sand/cave/cavedeep/dug/cold

/turf/simulated/floor/indestructible/dune_sand/cave/cavedeep/cold_rock/dark
	color = "#e0ac7b"
	baseturf = /turf/simulated/floor/indestructible/dune_sand/cave/cavedeep/dug/cold/dark

/turf/simulated/floor/indestructible/dune_sand/cave/cavedeep/dug/cold
	color = "#E6E6E6"
	baseturf = /turf/simulated/floor/indestructible/dune_sand/cave/cavedeep/dug/cold

/turf/simulated/floor/indestructible/dune_sand/cave/cavedeep/dug/cold/dark
	color = "#e0ac7b"
	baseturf = /turf/simulated/floor/indestructible/dune_sand/cave/cavedeep/dug/cold/dark

//boss
/turf/simulated/floor/bossroom
	name = "floor"
	icon = 'modular_ss220/dunes_map/icons/cave_floor.dmi'
	icon_state = "boss0"
	footstep = FOOTSTEP_CARPET
	barefootstep = FOOTSTEP_CARPET
	clawfootstep = FOOTSTEP_CARPET
	atmos_environment = ENVIRONMENT_TEMPERATE
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	smoothing_groups = list(SMOOTH_GROUP_FLOOR)
	var/environment_type = "boss"
	var/floor_variance = 15

/turf/simulated/floor/bossroom/cold

/turf/simulated/floor/bossroom/Initialize(mapload)
	var/proper_name = name
	. = ..()
	name = proper_name
	if(prob(floor_variance))
		icon_state = "[environment_type][rand(1,15)]"

/turf/simulated/floor/bossroom/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/simulated/floor/bossroom/burn_tile()
	return

/turf/simulated/floor/bossroom/MakeSlippery(wet_setting)
	return

/turf/simulated/floor/bossroom/MakeDry(wet_setting)
	return

/turf/simulated/floor/bossroom/remove_plating()
	return

/turf/simulated/floor/bossroom/crowbar_act(mob/user, obj/item/I)
	return

/turf/simulated/floor/plating/asteroid/basalt/dune
	atmos_environment = ENVIRONMENT_TEMPERATE
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT

/turf/simulated/floor/lava/dune_basalt
	atmos_environment = ENVIRONMENT_TEMPERATE
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT

/turf/simulated/floor/chasm/straight_down/lava_land_surface/dune_basalt
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_TEMPERATE
	temperature = T20C
	light_power = 0
	light_range = 0

/turf/simulated/mineral/bscrystal/hirka
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_TEMPERATE
	temperature = T20C
	baseturf = /turf/simulated/floor/plating/asteroid/basalt/dune

/turf/simulated/mineral/diamond/hirka
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_TEMPERATE
	temperature = T20C
	baseturf = /turf/simulated/floor/plating/asteroid/basalt/dune

/turf/simulated/mineral/random/high_chance/hirka
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_TEMPERATE
	temperature = T20C
	baseturf = /turf/simulated/floor/plating/asteroid/basalt/dune

/turf/simulated/mineral/random/low_chance/hirka
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_TEMPERATE
	temperature = T20C
	baseturf = /turf/simulated/floor/plating/asteroid/basalt/dune

/turf/simulated/mineral/volcanic/hirka
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_TEMPERATE
	temperature = T20C
	baseturf = /turf/simulated/floor/plating/asteroid/basalt/dune


#undef DESERT_WINTER
