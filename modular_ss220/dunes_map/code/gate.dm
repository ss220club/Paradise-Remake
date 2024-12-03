//Арка

/obj/structure/necropolis_arch/boss_arch
	name = "арка пирамиды"
	desc = "Циклопическая арка над вратами пирамиды, высеченная из черного камня."
	icon = 'modular_ss220/dunes_map/icons/arch.dmi'
	icon_state = "bossarch_full"
	pixel_x = -64
	pixel_y = -42

/obj/structure/necropolis_arch/boss_arch/Initialize(mapload)
	. = ..()
	icon_state = "bossarch_bottom"
	top_overlay = mutable_appearance('modular_ss220/dunes_map/icons/arch.dmi', "bossarch_top")
	top_overlay.layer = EDGED_TURF_LAYER
	add_overlay(top_overlay)
