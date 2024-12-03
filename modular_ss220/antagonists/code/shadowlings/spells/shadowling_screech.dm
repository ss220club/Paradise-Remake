/datum/spell/shadowling/screech
	name = "Вопль"
	desc = "Вы громко вопите, дизориентируя врагов, отключая боргов и повреждая стёкла в радиусе 5-и клеток."
	base_cooldown = 40 SECONDS
	stat_allowed = UNCONSCIOUS
	create_attack_logs = FALSE	// Required to stop turf spam to logs
	action_icon_state = "screech"

/datum/spell/shadowling/screech/create_new_targeting()
	var/datum/spell_targeting/aoe/turf/T = new
	T.range = 5
	return T

/datum/spell/shadowling/screech/cast(list/targets, mob/user)
	user.audible_message(span_boldwarning("[user] издаёт ужасающий крик!"))
	playsound(user.loc, 'sound/effects/screech.ogg', 100, TRUE)

	for(var/turf/turf in targets)
		for(var/mob/target in turf.contents)
			if(shadowling_check(target))
				continue

			if(iscarbon(target))
				var/mob/living/carbon/c_mob = target
				to_chat(c_mob, span_boldwarning("Боль пронзает вашу голову! Этот звук НЕВЫНОСИМ!"))
				c_mob.AdjustConfused(20 SECONDS)
				c_mob.AdjustDeaf(6 SECONDS)

			else if(issilicon(target))
				var/mob/living/silicon/robot = target
				to_chat(robot, span_boldwarning("ОШИБКА: Внешние сенсоры пе&рег?3%8@_#..."))
				robot << 'sound/misc/interference.ogg'
				playsound(robot, 'sound/machines/warning-buzzer.ogg', 50, TRUE)
				do_sparks(5, 1, robot)
				robot.Weaken(12 SECONDS)

			add_attack_logs(user, target, "cast the spell [name]", ATKLOG_ALL)

		for(var/obj/structure/window/window in turf.contents)
			window.take_damage(rand(80, 100))
