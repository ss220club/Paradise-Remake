#define LIGHT_DAM_THRESHOLD 4
#define LIGHT_HEAL_THRESHOLD 2
#define LIGHT_DAMAGE_TAKEN 6

/datum/species/shadow/ling
	//Normal shadowpeople but with enhanced effects
	name = "Shadowling"
	name_plural = "Shadowlings"

	default_language = "Шёпот из тени"
	language = "Шёпот из тени"
	icobase = 'modular_ss220/antagonists/icons/shadowlings/r_shadowling.dmi'
	blacklisted = TRUE

	blood_color = "#555555"
	flesh_color = "#222222"

	species_traits = list(NO_BLOOD, NO_HAIR, NOT_SELECTABLE)
	inherent_traits = list(TRAIT_RESISTHEAT, TRAIT_NOBREATH, TRAIT_RESISTCOLD, TRAIT_RESISTHIGHPRESSURE, TRAIT_RESISTLOWPRESSURE, TRAIT_CHUNKYFINGERS, TRAIT_NOPAIN, TRAIT_NO_BONES, TRAIT_STURDY_LIMBS, TRAIT_XENO_IMMUNE, TRAIT_NOHUNGER)

	burn_mod = 1.25
	heatmod = 1.5

/datum/species/shadow/ling/proc/handle_light(mob/living/carbon/human/H)
	var/light_amount = 0
	if(isturf(H.loc))
		var/turf/T = H.loc
		light_amount = T.get_lumcount() * 10
		if(light_amount > LIGHT_DAM_THRESHOLD && !H.incorporeal_move) //Can survive in very small light levels. Also doesn't take damage while incorporeal, for shadow walk purposes
			H.throw_alert("lightexposure", /atom/movable/screen/alert/lightexposure)
			if(is_species(H, /datum/species/shadow/ling/lesser))
				H.take_overall_damage(0, LIGHT_DAMAGE_TAKEN/2)
			else
				H.take_overall_damage(0, LIGHT_DAMAGE_TAKEN)
			if(H.stat != DEAD)
				to_chat(H, span_userdanger("Свет жжёт вас!"))
				H << 'sound/weapons/sear.ogg'
		else if(light_amount < LIGHT_HEAL_THRESHOLD)
			H.clear_alert("lightexposure")
			var/obj/item/organ/internal/eyes/E = H.get_int_organ(/obj/item/organ/internal/eyes)
			if(istype(E))
				E.receive_damage(-1)
			if(is_species(H, /datum/species/shadow/ling/lesser))
				H.heal_overall_damage(2, 3)
			else
				H.heal_overall_damage(5, 7)
			H.adjustToxLoss(-5)
			H.adjustBrainLoss(-25)
			H.AdjustEyeBlurry(-2 SECONDS)
			H.adjustCloneLoss(-1)
			H.SetWeakened(0)
			H.SetStunned(0)

		else
			if(H.health <= HEALTH_THRESHOLD_CRIT) // to finish shadowlings in rare occations
				H.adjustBruteLoss(1)

/datum/species/shadow/ling/handle_life(mob/living/carbon/human/H)
	..(H)
	handle_light(H)

/datum/species/shadow/ling/lesser //Empowered thralls. Obvious, but powerful
	name = "Lesser Shadowling"

	icobase = 'modular_ss220/antagonists/icons/shadowlings/r_lshadowling.dmi'
	blood_color = "#CCCCCC"
	flesh_color = "#AAAAAA"

	burn_mod = 1.1
	heatmod = 1.2

#undef LIGHT_DAM_THRESHOLD
#undef LIGHT_HEAL_THRESHOLD
#undef LIGHT_DAMAGE_TAKEN
