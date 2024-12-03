/datum/spell/shadowling/self/tear_the_reality
	name = "Прорвать реальность"
	desc = "Вы используете накопленную от поглощённых смертных силу, чтобы создать разрыв в реальности и призвать в этот мир своих детей. Летально для вас, но гарантирует то, что ваш дух возродится в одном из детей."
	base_cooldown = 0 SECONDS
	stat_allowed = UNCONSCIOUS
	action_icon_state = "ascend"

/datum/spell/shadowling/self/tear_the_reality/can_cast(mob/user, charge_check, show_message)
	. = ..()
	if(!istype(user, /mob/living/simple_animal/demon/shadow_father))
		return FALSE
	var/mob/living/simple_animal/demon/shadow_father/father = user
	if(father.consumed < 1)
		to_chat(father, span_warning("Вам нужно поглотить как минимум одного смертного, чтобы прорвать реальность."))
		return FALSE

/datum/spell/shadowling/self/tear_the_reality/cast(list/targets, mob/user)
	var/mob/living/simple_animal/demon/shadow_father/father = user
	var/confirm = tgui_alert(father, "Вы уверены что хотите закончить свою охоту и прорвать реальность? Вы призовёте [father.consumed + 1] тенелингов и гарантированно станите одним из них.", "Закончить охоту?", list("Да", "Я ещё поохочусь"))
	if(confirm != "Да")
		return
	INVOKE_ASYNC(SSticker.mode, TYPE_PROC_REF(/datum/game_mode, begin_shadowling_invasion), src, TRUE)
	qdel(user)

