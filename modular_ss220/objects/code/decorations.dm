// Columns
/obj/structure/fluff/column
	name = "column"
	desc = "Очень старая, массивная колонна."
	icon = 'modular_ss220/objects/icons/columns.dmi'
	icon_state = "column1"
	layer = ABOVE_ALL_MOB_LAYER
	deconstructible = FALSE
	density = TRUE

/obj/structure/fluff/column/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/largetransparency)

// Large remains
/obj/structure/fluff/remains_large
	name = "large remains"
	desc = "Белеющие на солнце кости местной фауны."
	icon = 'modular_ss220/objects/icons/remains_large.dmi'
	icon_state = "rib"
	layer = ABOVE_ALL_MOB_LAYER
	deconstructible = FALSE
	density = TRUE

/obj/structure/fluff/remains_large/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/largetransparency)

// Carpets
/obj/structure/fluff/carpet
	name = "red carpet"
	desc = "Шерстяной ковер, украшенный различными узорами."
	icon = 'modular_ss220/objects/icons/carpets.dmi'
	icon_state = "carpet1"
	max_integrity = 50
	layer = LOW_OBJ_LAYER
	anchored = FALSE
	deconstructible = FALSE

/obj/structure/fluff/carpet/AltClick(mob/user)
	. = ..()
	if(user.incapacitated())
		to_chat(user, span_warning("You can't do that right now!"))
		return
	if(!Adjacent(user))
		return
	if(anchored)
		to_chat(user, span_warning("[src] is anchored to the floor!"))
		return
	setDir(turn(dir, 90))

/obj/structure/fluff/carpet/blue
	name = "blue carpet"
	icon_state = "carpet2"

/obj/structure/fluff/carpet/yellow
	name = "yellow carpet"
	icon_state = "carpet3"

/obj/structure/fluff/carpet/green
	name = "green carpet"
	icon_state = "carpet4"

// Carpets small
/obj/structure/fluff/carpet/small
	name = "small red carpet"
	desc = "Небольшой ковер, украшенный различными узорами."
	icon = 'modular_ss220/objects/icons/carpets_small.dmi'
	icon_state = "carpet_small1"

/obj/structure/fluff/carpet/small/yellow
	name = "small yellow carpet"
	icon_state = "carpet_small2"

/obj/structure/fluff/carpet/small/white
	name = "small white carpet"
	icon_state = "carpet_small3"
