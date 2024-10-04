//Глаза - включают режим щитков, но очень уязвивым к вспышкам (в 2 раза сильнее молиных глаз)
/obj/item/organ/internal/eyes/serpentid
	name = "serpentid eyes"
	icon = 'modular_ss220/species/icons/obj/surgery.dmi'
	icon_state = "crystal-eyes"
	light_color = "#1C1C00"
	see_in_dark = 2
	flash_protect = FLASH_PROTECTION_EXTRA_SENSITIVE
	tint = FLASH_PROTECTION_NONE
	actions_types = 		list(/datum/action/item_action/organ_action/use)
	action_icon = 			list(/datum/action/item_action/organ_action/use = 'modular_ss220/species/icons/mob/human_races/organs.dmi')
	action_icon_state = 	list(/datum/action/item_action/organ_action/use = "gas_abilities")
	chemical_id = SERPENTID_CHEM_REAGENT_ID
	radial_additive_state = "gas_eyes_0"
	var/eye_shielded = FALSE
	var/decay_rate = 1
	var/decay_recovery = BASIC_RECOVER_VALUE
	var/organ_process_toxins = 0.35


/obj/item/organ/internal/eyes/serpentid/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/organ_decay, decay_rate, decay_recovery)
	AddComponent(/datum/component/organ_toxin_damage, organ_process_toxins)

/obj/item/organ/internal/eyes/serpentid/generate_icon(mob/living/carbon/human/HA)
	var/mob/living/carbon/human/H = HA
	if(!istype(H))
		H = owner
	var/icon/eyes_icon = new /icon('modular_ss220/species/icons/mob/human_races/serpentid_eyes.dmi', H.dna.species.eyes)
	eyes_icon.Blend(eye_color, ICON_ADD)

	return eyes_icon

/obj/item/organ/internal/eyes/serpentid/insert(mob/living/carbon/M, special = 0, dont_remove_slot = 0)
	. = .. ()
	buttons_resort()

/obj/item/organ/internal/eyes/serpentid/remove(mob/living/carbon/M, special = 0)
	. = .. ()
	buttons_resort()

/obj/item/organ/internal/eyes/serpentid/ui_action_click()
	open_actions(owner)

/obj/item/organ/internal/eyes/serpentid/switch_mode(var/force_off = FALSE)
	if(eye_shielded)
		flash_protect = initial(flash_protect)
		tint = initial(tint)
		owner.update_sight()
		eye_shielded = FALSE
	else
		flash_protect = FLASH_PROTECTION_WELDER //Adjust the user's eyes' flash protection
		tint = FLASH_PROTECTION_FLASH
		owner.update_sight()
		eye_shielded = TRUE
	radial_additive_state = "gas_eyes_[eye_shielded]"

/obj/item/organ/internal/eyes/serpentid/on_life()
	. = ..()
	if(!isnull(owner))
		var/mob/mob = owner
		mob.update_client_colour(time = 10)

/obj/item/organ/internal/eyes/serpentid/get_colourmatrix() //Returns a special colour matrix
	var/chem_value = (owner.get_chemical_value(chemical_id) + GAS_ORGAN_CHEMISTRY_MAX/2)/GAS_ORGAN_CHEMISTRY_MAX
	var/vision_chem = clamp(chem_value, SERPENTID_EYES_LOW_VISIBLE_VALUE, SERPENTID_EYES_MAX_VISIBLE_VALUE)
	var/vision_concentration = (1 - vision_chem/SERPENTID_EYES_MAX_VISIBLE_VALUE)*SERPENTID_EYES_LOW_VISIBLE_VALUE

	var/k = 0.4
	vision_concentration = SERPENTID_EYES_LOW_VISIBLE_VALUE * (1 - chem_value**k)
	var/vision_adjust = clamp(vision_concentration, 0, SERPENTID_EYES_LOW_VISIBLE_VALUE/2)

	var/vision_matrix = list(vision_chem, vision_adjust, vision_adjust,\
		vision_adjust, vision_chem, vision_adjust,\
		vision_adjust, vision_adjust, vision_chem)
	return vision_matrix
