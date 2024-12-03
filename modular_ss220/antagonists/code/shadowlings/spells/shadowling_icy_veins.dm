/datum/spell/shadowling/icy_veins
	name = "Стынущие жилы"
	desc = "Вы замораживаете кровь в венах окружающих вас врагов в радиусе 4-х клеток, замедляя их и нанося им урон от холода."
	base_cooldown = 35 SECONDS
	stat_allowed = UNCONSCIOUS
	action_icon_state = "icy_veins"

/datum/spell/shadowling/icy_veins/create_new_targeting()
	var/datum/spell_targeting/aoe/T = new
	T.allowed_type = /mob/living
	T.range = 4
	return T

/datum/spell/shadowling/icy_veins/cast(list/targets, mob/living/user = usr)
	to_chat(user, span_purple("Вы посылаете волну холода."))
	playsound(user.loc, 'sound/effects/ghost2.ogg', 50, TRUE)

	for(var/mob/living/carbon/target in targets)
		if(shadowling_check(target))
			to_chat(target, span_warning("Вы чувствуете волну холода, но для вас она безвредна"))
			continue
		to_chat(target, span_danger("Вас пронзает волна холода! У вас буквально стынет кровь в жилах!"))
		target.Stun(2 SECONDS)
		target.apply_damage(10, BURN)
		target.adjust_bodytemperature(-200) //Extreme amount of initial cold
		if(target.reagents)
			target.reagents.add_reagent("frostoil", 15) //Half of a cryosting

