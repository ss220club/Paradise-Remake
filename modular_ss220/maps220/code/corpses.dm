/* For Black Market Packers gateway */
/obj/effect/mob_spawn/human/corpse/tacticool
	mob_type = /mob/living/carbon/human
	name = "Tacticool corpse"
	icon = 'icons/obj/clothing/under/syndicate.dmi'
	icon_state = "tactifool"
	mob_name = "Unknown"
	random = TRUE
	death = TRUE
	disable_sensors = TRUE
	outfit = /datum/outfit/packercorpse

/datum/outfit/packercorpse
	name = "Packer Corpse"
	uniform = /obj/item/clothing/under/syndicate/tacticool
	shoes = /obj/item/clothing/shoes/combat
	back = /obj/item/storage/backpack
	l_ear = /obj/item/radio/headset
	gloves = /obj/item/clothing/gloves/color/black

/obj/effect/mob_spawn/human/corpse/tacticool/Initialize(mapload)
	brute_damage = rand(0, 400)
	burn_damage = rand(0, 400)
	return ..()

/obj/effect/mob_spawn/human/corpse/syndicatesoldier/trader
	name = "Syndi trader corpse"
	icon = 'icons/obj/clothing/under/syndicate.dmi'
	icon_state = "tactifool"
	random = TRUE
	disable_sensors = TRUE
	outfit = /datum/outfit/syndicatetrader

/datum/outfit/syndicatetrader
	uniform = /obj/item/clothing/under/syndicate/tacticool
	shoes = /obj/item/clothing/shoes/combat
	back = /obj/item/storage/backpack
	gloves = /obj/item/clothing/gloves/color/black/forensics
	belt = /obj/item/gun/projectile/automatic/pistol
	mask = /obj/item/clothing/mask/balaclava
	suit = /obj/item/clothing/suit/armor/vest/combat

/obj/effect/mob_spawn/human/corpse/syndicatesoldier/trader/Initialize(mapload)
	brute_damage = rand(150, 500)
	burn_damage = rand(100, 300)
	return ..()

/* Snowdwin */

/datum/outfit/dead_skrell
	name = "SDTF dead crew"
	uniform = /obj/item/clothing/under/solgov/srt
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/combat
	id = /obj/item/card/id

/datum/outfit/dead_skrell/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	H.add_language("Skrellian")
	H.set_default_language(GLOB.all_languages["Skrellian"])

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(ACCESS_MAINT_TUNNELS), "SDTF Raskinta Katish")
	I.rank = "SDTF Raskinta Warrior"
	I.assignment = "SDTF Raskinta Katish"
	H.sec_hud_set_ID()

/datum/outfit/dead_skrell/warrior
	name = "SDTF dead warrior"
	back = /obj/item/mod/control/pre_equipped/exclusive/skrell_raskinta
	l_pocket = /obj/item/tank/internals/emergency_oxygen/double
	mask = /obj/item/clothing/mask/gas/swat
	backpack_contents = list(
		/obj/item/storage/box/skrell,
		/obj/item/gun/energy/gun/skrell_pistol
	)

/obj/effect/mob_spawn/human/corpse/skrell
	mob_type = /mob/living/carbon/human
	name = "SDTF crew corpse"
	mob_species = /datum/species/skrell
	random = TRUE
	death = TRUE
	disable_sensors = TRUE
	outfit = /datum/outfit/dead_skrell

/obj/effect/mob_spawn/human/corpse/skrell/Initialize(mapload)
	brute_damage = rand(0, 400)
	return ..()

/obj/effect/mob_spawn/human/corpse/skrell/warrior
	name = "SDTF warrior corpse"
	outfit = /datum/outfit/dead_skrell/warrior
