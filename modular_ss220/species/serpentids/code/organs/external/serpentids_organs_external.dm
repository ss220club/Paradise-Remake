///Хитиновые конечности
/obj/item/organ/external/replaced()
	.=..()
	for(var/X in actions)
		var/datum/action/A = X
		A.Grant(owner)

/obj/item/organ/external/droplimb()
	.=..()
	for(var/X in actions)
		var/datum/action/A = X
		A.Remove(owner)

/obj/item/organ/external/head/carapace
	encased = "chitin"
	min_broken_damage = 30
	actions_types = 		list(/datum/action/item_action/organ_action/toggle)
	action_icon = 			list(/datum/action/item_action/organ_action/toggle = 'modular_ss220/species/serpentids/icons/organs.dmi')
	action_icon_state = 	list(/datum/action/item_action/organ_action/toggle = "gas_eyes_0")
	var/eye_shielded = FALSE

/obj/item/organ/external/head/carapace/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/carapace, src, FALSE, min_broken_damage)

/obj/item/organ/external/head/carapace/ui_action_click()
	var/obj/item/organ/internal/eyes/E = owner.get_int_organ(/obj/item/organ/internal/eyes)
	if(eye_shielded)
		E.flash_protect = initial(E.flash_protect)
		E.tint = initial(E.tint)
		owner.update_sight()
		eye_shielded = FALSE
	else
		E.flash_protect = FLASH_PROTECTION_WELDER //Adjust the user's eyes' flash protection
		E.tint = FLASH_PROTECTION_WELDER
		owner.update_sight()
		eye_shielded = TRUE

	for(var/datum/action/item_action/T in actions)
		T.button_overlay_icon_state ="gas_eyes_[eye_shielded]"
		T.UpdateButtons()

/obj/item/organ/external/chest/carapace
	encased = "chitin"
	min_broken_damage = 40

/obj/item/organ/external/chest/carapace/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/carapace, src, FALSE, min_broken_damage)

/obj/item/organ/external/groin/carapace
	encased = "chitin"
	min_broken_damage = 40

/obj/item/organ/external/groin/carapace/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/carapace, src, FALSE, min_broken_damage)

/obj/item/organ/external/arm/carapace
	encased = "chitin"
	min_broken_damage = 20

/obj/item/organ/external/arm/carapace/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/carapace, src, TRUE, min_broken_damage)

/obj/item/organ/external/arm/right/carapace
	encased = "chitin"
	min_broken_damage = 20

/obj/item/organ/external/arm/right/carapace/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/carapace, src, TRUE, min_broken_damage)

/obj/item/organ/external/leg/carapace
	encased = "chitin"
	min_broken_damage = 20

/obj/item/organ/external/leg/carapace/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/carapace, src, TRUE, min_broken_damage)

/obj/item/organ/external/leg/right/carapace
	encased = "chitin"
	min_broken_damage = 20

/obj/item/organ/external/leg/right/carapace/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/carapace, src, TRUE, min_broken_damage)

/obj/item/organ/external/hand/carapace
	encased = "chitin"
	min_broken_damage = 20

/obj/item/organ/external/hand/carapace/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/carapace, src, TRUE, min_broken_damage)

/obj/item/organ/external/hand/right/carapace
	encased = "chitin"
	min_broken_damage = 20

/obj/item/organ/external/hand/right/carapace/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/carapace, src, TRUE, min_broken_damage)

/obj/item/organ/external/foot/carapace
	encased = "chitin"
	min_broken_damage = 20

/obj/item/organ/external/foot/carapace/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/carapace, src, TRUE, min_broken_damage)

/obj/item/organ/external/foot/right/carapace
	encased = "chitin"
	min_broken_damage = 20

/obj/item/organ/external/foot/right/carapace/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/carapace, src, TRUE, min_broken_damage)
