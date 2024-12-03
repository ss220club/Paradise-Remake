// Vampire glare with some additions

/// No deviation at all. Flashed from the front or front-left/front-right. Alternatively, flashed in direct view.
#define DEVIATION_NONE 3
/// Partial deviation. Flashed from the side. Alternatively, flashed out the corner of your eyes.
#define DEVIATION_PARTIAL 2
/// Full deviation. Flashed from directly behind or behind-left/behind-rack. Not flashed at all.
#define DEVIATION_FULL 1

/// Light level, required to apply additional effects
#define GLARE_REQUIRED_DARKNESS 4

/datum/spell/shadowling/glare
	name = "Блик"
	desc = "Ваши красные глаза сверкают, завораживая и очаровывая смертных перед вами. Для лучшего эффекта необходим близкий зрительный контакт и тёмное окружение."
	base_cooldown = 40 SECONDS
	stat_allowed = UNCONSCIOUS
	action_icon_state = "glare"

/datum/spell/shadowling/glare/can_cast(mob/user, charge_check, show_message)
	. = ..()
	// Veil shouldn't work in shadow crawl
	if(istype(user.loc, /obj/effect/dummy/slaughter))
		return FALSE

/datum/spell/shadowling/glare/create_new_targeting()
	var/datum/spell_targeting/aoe/T = new
	T.allowed_type = /mob/living
	T.range = 1
	return T

/datum/spell/shadowling/glare/create_new_cooldown()
	var/datum/spell_cooldown/charges/C = new
	C.max_charges = 2
	C.recharge_duration = base_cooldown
	C.charge_duration = 2 SECONDS
	return C

/datum/spell/shadowling/glare/proc/calculate_deviation(mob/victim, mob/attacker)

	// If the victim was looking at the attacker, this is the direction they'd have to be facing.
	var/attacker_to_victim = get_dir(attacker, victim)
	// The victim's dir is necessarily a cardinal value.
	var/attacker_dir = attacker.dir

	// - - -
	// - V - Attacker facing south
	// # # #
	// Attacker within 45 degrees of where the victim is facing.
	if(attacker_dir & attacker_to_victim)
		return DEVIATION_NONE
	// Are they on the same tile? This is probably the victim crawling under the vampire, and looking down shouldn't be too tough.
	if(victim.loc == attacker.loc)
		return DEVIATION_NONE
	// # # #
	// - V - Attacker facing south
	// - - -
	// Victim at 135 or more degrees of where the victim is facing.
	if(attacker_dir & REVERSE_DIR(attacker_to_victim))
		return DEVIATION_FULL
	// - - -
	// # V # Attacker facing south
	// - - -
	// Victim lateral to the victim.
	return DEVIATION_PARTIAL

/datum/spell/shadowling/glare/cast(list/targets, mob/living/user = usr)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(istype(H.glasses, /obj/item/clothing/glasses/sunglasses/blindfold))
			var/obj/item/clothing/glasses/sunglasses/blindfold/B = H.glasses
			if(B.tint)
				to_chat(user, span_warning("Ваши глаза закрыты! Взгляд не работает!"))
				return
	user.mob_light(LIGHT_COLOR_BLOOD_MAGIC, 3, _duration = 2)
	user.visible_message(span_warning("Вы используйете очарование своих глаз, вводя в замешательство окружающих"))

	for(var/mob/living/target in targets)
		if(shadowling_check(target))
			continue

		var/deviation
		if(IS_HORIZONTAL(user))
			deviation = DEVIATION_PARTIAL
		else
			deviation = calculate_deviation(target, user)
		if(deviation == DEVIATION_FULL)
			target.Confused(6 SECONDS)
			target.apply_damage(20, STAMINA)
		else if((deviation == DEVIATION_PARTIAL) || (get_light_level(target) > GLARE_REQUIRED_DARKNESS))
			target.KnockDown(5 SECONDS)
			target.Confused(6 SECONDS)
			target.apply_damage(40, STAMINA)
		else
			target.Confused(10 SECONDS)
			target.apply_damage(70, STAMINA)
			target.KnockDown(12 SECONDS)
			target.AdjustSilence(8 SECONDS)
			target.flash_eyes(1, TRUE, TRUE)
		to_chat(target, span_warning("Глаза [user] источают чарующую красную ауру. Ваше тело слабеет..."))
		add_attack_logs(user, target, "(Shadowling) Glared at")

#undef DEVIATION_NONE
#undef DEVIATION_PARTIAL
#undef DEVIATION_FULL
#undef GLARE_REQUIRED_DARKNESS
