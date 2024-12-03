/datum/spell/shadowling/self/blindness_smoke
	name = "Ослепляющий дым"
	desc = "Вы выдыхаете облако густого ослепляющего врагов дыма, однако лечащего лояльных тьме слуг."
	base_cooldown = 30 SECONDS
	stat_allowed = UNCONSCIOUS
	action_icon_state = "blindness_smoke"


/datum/spell/shadowling/self/blindness_smoke/cast(list/targets, mob/user)
	user.visible_message(span_warning("[user] внезапно выдыхает облако чёрного дыма, который начинает быстро распространяться!"))
	playsound(user, 'sound/effects/bamf.ogg', 50, TRUE)
	var/datum/reagents/reagents_list = new (1000)
	reagents_list.add_reagent("blindness_smoke", 810)
	var/datum/effect_system/smoke_spread/chem/chem_smoke = new
	chem_smoke.set_up(reagents_list, user.loc, TRUE)
	chem_smoke.start(4)

/datum/reagent/shadowling_blindness_smoke //Blinds non-shadowlings, heals shadowlings/thralls
	name = "odd black liquid"
	id = "blindness_smoke"
	description = "<::ОШИБКА::> НЕВОЗМОЖНО ПРОАНАЛИЗИРОВАТЬ РЕАГЕНТ <::ОШИБКА::>"
	color = "#000000" //Complete black (RGB: 0, 0, 0)
	metabolization_rate = 250 * REAGENTS_METABOLISM //still lel


/datum/reagent/shadowling_blindness_smoke/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(!is_shadow_or_thrall(M))
		to_chat(M, span_boldwarning("Вы вдыхаете чёрный дым и ваши глаза начинают ужасно болеть!"))
		M.EyeBlind(10 SECONDS)
		if(prob(25))
			M.visible_message(span_warning("[M] трёт свои глаза."))
			M.Stun(4 SECONDS)
	else
		to_chat(M, span_notice("Вы вдыхаете чёрный дым и чувствуете облегчение!"))
		update_flags |= M.heal_organ_damage(10, 10, updating_health = FALSE)
		update_flags |= M.adjustOxyLoss(-10, FALSE)
		update_flags |= M.adjustToxLoss(-10, FALSE)
	return ..() | update_flags
