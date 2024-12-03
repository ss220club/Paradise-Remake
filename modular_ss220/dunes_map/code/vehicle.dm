/obj/vehicle/motorcycle/desert
	name = "пустынный байк"
	desc = "Быстрый и высокоманевренный транспорт для передвижения по пустыне."
	vehicle_move_delay = 0.4
	icon = 'modular_ss220/dunes_map/icons/vehicle.dmi'
	icon_state = "desertbike2_4dir"
	auto_door_open = FALSE
	max_integrity = 200
	var/engine_sound = 'modular_ss220/dunes_map/sound/vehicle/carrev.ogg'
	var/engine_sound_length = 2 SECONDS
	COOLDOWN_DECLARE(enginesound_cooldown)

/obj/vehicle/motorcycle/desert/Initialize(mapload)
	. = ..()
	bikecover = mutable_appearance(icon, "desertbike2_4dir_overlay", ABOVE_MOB_LAYER)

/obj/vehicle/motorcycle/desert/raider
	name = "пустынный байк"
	desc = "Быстрый и высокоманевренный транспорт для передвижения по пустыне."
	vehicle_move_delay = 0.2
	icon = 'modular_ss220/dunes_map/icons/vehicle.dmi'
	icon_state = "desertbike_4dir"
	auto_door_open = FALSE
	max_integrity = 200

/obj/vehicle/motorcycle/desert/Initialize(mapload)
	. = ..()
	bikecover = mutable_appearance(icon, "desertbike_4dir_overlay", ABOVE_MOB_LAYER)

/obj/vehicle/motorcycle/desert/relaymove(mob/user, direction)
	..()

	if(COOLDOWN_FINISHED(src, enginesound_cooldown))
		COOLDOWN_START(src, enginesound_cooldown, engine_sound_length)
		playsound(get_turf(src), engine_sound, 200, TRUE)

/obj/vehicle/motorcycle/desert/user_buckle_mob(mob/living/M, mob/user)
	..()
	ADD_TRAIT(M, TRAIT_CANNOT_PULL, TRAIT_HANDS_BLOCKED)

/obj/vehicle/motorcycle/desert/unbuckle_mob(mob/living/buckled_mob, force = FALSE)
	..()
	REMOVE_TRAIT(buckled_mob, TRAIT_CANNOT_PULL, TRAIT_HANDS_BLOCKED)
