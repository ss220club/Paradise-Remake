/datum/spell/shadowling/self/shadow_walk
	name = "Шаг в тень"
	desc = "Вы просачиваетесь в пространство меж миров, получая способность быстро перемещаться сквозь стены на 4 секунды. Свет по-прежнему опасен для вас."
	base_cooldown = 60 SECONDS
	stat_allowed = UNCONSCIOUS
	action_icon_state = "shadowling_crawl"

/datum/spell/shadowling/self/shadow_walk/cast(list/targets, mob/living/user = usr)
	playsound(user.loc, 'sound/effects/bamf.ogg', 50, 1)
	user.visible_message(span_warning("[user] исчезает в облаке тёмного тумана!"), span_purple("Вы просачиваетесь в пространство меж миров на 4 секунды."))
	user.SetStunned(0)
	user.SetWeakened(0)
	user.SetKnockDown(0)
	user.incorporeal_move = INCORPOREAL_MOVE_NORMAL
	user.alpha = 0
	user.ExtinguishMob()
	user.forceMove(get_turf(user)) //to properly move the mob out of a potential container
	user.pulledby?.stop_pulling()
	user.stop_pulling()

	sleep(4 SECONDS)
	if(QDELETED(user))
		return

	user.visible_message(span_warning("[user] внезапно появляется из ниоткуда!"), span_purple("Давление реальности становится невыносимым. Вы вынуждены вернуться в материальный мир"))
	user.incorporeal_move = NO_INCORPOREAL_MOVE
	user.alpha = 255
	user.forceMove(get_turf(user))
