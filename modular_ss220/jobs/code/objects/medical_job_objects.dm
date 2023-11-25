/obj/machinery/economy/vending/medidrobe/Initialize(mapload)
	. = ..()
	products |= list(
		/obj/item/clothing/under/rank/medical/doctor/intern = 5,
		/obj/item/clothing/under/rank/medical/doctor/intern/skirt = 5,
		/obj/item/clothing/under/rank/medical/doctor/intern/assistant = 5,
		/obj/item/clothing/under/rank/medical/doctor/intern/assistant/skirt = 5,
		/obj/item/clothing/head/surgery/green/light = 5,
		/obj/item/clothing/under/rank/medical/scrubs/green/light = 5,
	)

// Others
/datum/uplink_item/jobspecific/viral_injector/New()
	. = ..()
	job |= GLOB.medical_positions_ss220

/obj/item/envelope/medical/Initialize(mapload)
	. = ..()
	job_list |= GLOB.medical_positions_ss220

// loadout
/datum/gear/accessory/stethoscope/New()
	. = ..()
	allowed_roles |= GLOB.medical_positions_ss220

/datum/gear/accessory/armband_job/medical/New()
	. = ..()
	allowed_roles |= GLOB.medical_positions_ss220

/datum/gear/medhudgoggles/New()
	. = ..()
	allowed_roles |= GLOB.medical_positions_ss220

/datum/gear/mug/department/med/New()
	. = ..()
	allowed_roles |= GLOB.medical_positions_ss220

/datum/gear/hat/beret_job/med/New()
	. = ..()
	allowed_roles |= GLOB.medical_positions_ss220

/datum/gear/hat/surgicalcap_purple/New()
	. = ..()
	allowed_roles |= GLOB.medical_positions_ss220

/datum/gear/hat/surgicalcap_green/New()
	. = ..()
	allowed_roles |= GLOB.medical_positions_ss220

/datum/gear/racial/taj/med/New()
	. = ..()
	allowed_roles |= GLOB.medical_positions_ss220

/datum/gear/suit/coat/job/med/New()
	. = ..()
	allowed_roles |= GLOB.medical_positions_ss220

/datum/gear/uniform/skirt/job/med/New()
	. = ..()
	allowed_roles |= GLOB.medical_positions_ss220

/datum/gear/uniform/medical/pscrubs/New()
	. = ..()
	allowed_roles |= GLOB.medical_positions_ss220

/datum/gear/uniform/medical/gscrubs/New()
	. = ..()
	allowed_roles |= GLOB.medical_positions_ss220
