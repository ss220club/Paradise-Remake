/datum/robolimb/etaminindustry
	company = "Etamin Industry Gold On Black"
	desc = "Модель протезированной конечности от Этамин Индастрис."
	icon = 'modular_ss220/robolimbs/icons/etaminindustry_main.dmi'
	has_subtypes = 1

/datum/robolimb/etaminindustry/etaminindustry_alt1
	company = "Etamin Industry Elite Series"
	icon = 'modular_ss220/robolimbs/icons/etaminindustry_alt1.dmi'
	parts = list("head")
	selectable = 0
	has_subtypes = null

/datum/robolimb/etaminindustry/etaminindustry_alt2
	company = "Etamin Industry SharpShooter Series"
	icon = 'modular_ss220/robolimbs/icons/etaminindustry_alt2.dmi'
	parts = list("head")
	selectable = 0
	has_subtypes = null

/datum/robolimb/etaminindustry/etaminindustry_alt3
	company = "Etamin Industry King Series"
	icon = 'modular_ss220/robolimbs/icons/etaminindustry_alt3.dmi'
	parts = list("head")
	selectable = 0
	has_subtypes = null

/datum/sprite_accessory/body_markings/head/optics
	icon = 'icons/mob/sprite_accessories/ipc/ei_optic.dmi'
	name = "EI Optics"
	species_allowed = list("Machine")
	icon_state = "ei_standart"
	models_allowed = list("Etamin Industry King Series")

/datum/sprite_accessory/body_markings/head/optics/altoptic2
	icon = 'icons/mob/sprite_accessories/ipc/ei_optic_alt.dmi'
	name = "EI Optics Alt"
	icon_state = "altoptics1"
	models_allowed = list("Etamin Industry King Series")

/datum/sprite_accessory/body_markings/head/optics/altoptic3
	icon = 'icons/mob/sprite_accessories/ipc/ei_optic_alt2.dmi'
	name = "EI Optics Alt 2"
	icon_state = "altoptics2"
	models_allowed = list("Etamin Industry King Series") 