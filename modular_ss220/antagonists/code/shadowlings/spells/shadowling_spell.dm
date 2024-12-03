// Basic

/datum/spell/shadowling
	school = "shadowling"
	action_background_icon_state = "shadow_demon_bg"
	action_icon = 'modular_ss220/antagonists/icons/shadowlings/shadowlings_actions.dmi'
	clothes_req = FALSE

	/// If true, can be casted while using shadowstep and other incorporeal abilities
	var/cast_incorporeal = FALSE

/datum/spell/shadowling/can_cast(mob/user, charge_check, show_message)
	if(isliving(user))
		var/mob/living/living_user = user
		if(living_user.incorporeal_move != NO_INCORPOREAL_MOVE)
			to_chat(user, span_warning("Вы не можете использовать эту способность не в физической форме!"))
			return
	return ..()

/datum/spell/shadowling/proc/get_light_level(mob/living/target)
	var/light_amount = 0
	if(isturf(target.loc))
		var/turf/T = target.loc
		light_amount = T.get_lumcount() * 10
	return light_amount

/datum/spell/shadowling/proc/shadowling_check(mob/living/carbon/human/user)
	if(!istype(user))
		return FALSE

	if(isshadowling(user) && is_shadow(user))
		return TRUE

	if(isshadowlinglesser(user) && is_thrall(user))
		return TRUE

	return FALSE

// Self

/datum/spell/shadowling/self/create_new_targeting()
	return new /datum/spell_targeting/self
