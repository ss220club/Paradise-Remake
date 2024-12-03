#define MAX_SHADOWLING_TRAPS 6

/obj/structure/shadow_trap
	name = "тёмное пятно"
	desc = "Большое тёмное пятно на полу, стенах и потолке. Вы не уверены что это такое, но лучше держаться подальше."
	var/trap_adjective = "сломанная"
	var/hud_icon_state = "broken"
	icon = 'modular_ss220/antagonists/icons/shadowlings/shadowlings_traps.dmi'
	icon_state = "trap"
	anchored = TRUE
	opacity = FALSE
	layer = ABOVE_OBJ_LAYER
	max_integrity = 50
	hud_possible = list(SPECIALROLE_HUD)

	var/created_by

/obj/structure/shadow_trap/Initialize(mapload)
	. = ..()
	prepare_huds()

/// This one is used to change path to special role hud icon file for modular behavior
/obj/structure/shadow_trap/prepare_huds()
	..()
	// Changing path to special_role HUD
	var/image/I = image('modular_ss220/antagonists/icons/shadowlings/shadowlings_traps.dmi', src, "")
	I.appearance_flags = RESET_COLOR | RESET_TRANSFORM
	hud_list[SPECIALROLE_HUD] = I
	// Toggle visibility
	var/datum/atom_hud/hud = GLOB.huds[ANTAG_HUD_SHADOW]
	hud.add_to_hud(src)
	// Changing icon_state of holder
	I.icon_state = hud_icon_state


/obj/structure/shadow_trap/Crossed(atom/movable/AM, oldloc)
	. = ..()
	if(is_shadow_or_thrall(AM))
		return
	if(!trap_activate(AM))	// Returns false if trap isn't triggered by this type
		return
	if(created_by)
		to_chat(created_by, span_purple("Ваша [trap_adjective] ловушка сработала на [AM] в [get_turf(AM.loc)]"))
	else
		created_by = "Admin spawn"
	add_attack_logs(AM, AM, "activated shadowling trap placed by [created_by]", ATKLOG_ALL)
	Destroy()

/obj/structure/shadow_trap/proc/trap_activate(mob/living/target)
	return

/obj/structure/shadow_trap/examine(mob/user)
	. = ..()
	if(is_shadow_or_thrall(user))
		. += "Это [trap_adjective] ловушка."

/obj/structure/shadow_trap/Destroy()
	if(!istype(created_by, /mob/living/simple_animal/demon/shadow_father))
		return ..()
	var/mob/living/simple_animal/demon/shadow_father/father = created_by
	father.placed_traps.Remove(src)
	. = ..()

// Spell

/datum/spell/shadowling/self/place_trap
	name = "Установить ловушку"
	action_icon_state = "vampire_glare"
	base_cooldown = 30 SECONDS
	stat_allowed = UNCONSCIOUS
	var/trap_type = /obj/structure/shadow_trap

/datum/spell/shadowling/self/place_trap/can_cast(mob/user, charge_check, show_message)
	. = ..()
	if(!istype(user, /mob/living/simple_animal/demon/shadow_father))
		to_chat(user, span_warning("Вы должны быть отцом тьмы для установки ловушек."))
		return FALSE
	var/mob/living/simple_animal/demon/shadow_father/father = user
	if(ismob(father.pulling))
		to_chat(user, span_warning("Вы не можете устанавливать ловушки, пока тащите кого-то."))
		return FALSE
	if(father.placed_traps.len >= MAX_SHADOWLING_TRAPS)
		to_chat(user, span_warning("Вы построили уже построили максимум ([MAX_SHADOWLING_TRAPS]) ловушек. Разрушьте старые для установки новых."))
		return FALSE
	return

/datum/spell/shadowling/self/place_trap/cast(list/targets, mob/user)
	var/mob/living/simple_animal/demon/shadow_father/father = user
	var/obj/structure/shadow_trap/trap = new trap_type(get_turf(father))
	father.placed_traps.Add(trap)
	trap.created_by = father

	for(var/datum/spell/shadowling/self/place_trap/spell in user.mob_spell_list)
		if(spell != src)
			spell.cooldown_handler.start_recharge()

// Stun Trap
// Disable headset, stun for 6 seconds and disable light

/obj/structure/shadow_trap/stun
	trap_adjective = "оглущающая"
	hud_icon_state = "stun"

/obj/structure/shadow_trap/stun/trap_activate(mob/living/target)
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		to_chat(human_target, span_boldwarning("Вас что-то схватило за ногу!"))
		human_target.emote("scream")
		human_target.KnockDown(6 SECONDS)
		human_target.Confused(7 SECONDS)
		human_target.extinguish_light()
		for(var/obj/item/headset in human_target.contents)
			if(istype(headset, /obj/item/radio))
				headset.emp_act()
		return TRUE
	if(isrobot(target))
		var/mob/living/silicon/robot/robot_target = target
		to_chat(robot_target, span_boldwarning("ОШИБКА: Неизвестное проникновение в п$о%#@*&..."))
		robot_target << 'sound/misc/interference.ogg'
		playsound(robot_target, 'sound/machines/warning-buzzer.ogg', 50, TRUE)
		do_sparks(5, 1, robot_target)
		robot_target.extinguish_light()
		robot_target.Weaken(6 SECONDS)
		return TRUE
	return FALSE

/datum/spell/shadowling/self/place_trap/stun
	name = "Установить оглущающую ловушку"
	trap_type = /obj/structure/shadow_trap/stun
	action_icon_state = "stun_trap"

// Poison Trap
// Deal burn + toxin damage to target and force them to sleep

/obj/structure/shadow_trap/poison
	trap_adjective = "отравляющая"
	hud_icon_state = "poison"

/obj/structure/shadow_trap/poison/trap_activate(mob/living/target)
	if(!ishuman(target))
		return FALSE
	if(ismachineperson(target))
		return FALSE
	if(target.reagents)
		to_chat(target, span_boldwarning("Вас что-то ужалило за ногу!"))
		target.reagents.add_reagent("frostoil", 30)
		target.reagents.add_reagent("neurotoxin", 30)
		return TRUE
	return FALSE

/datum/spell/shadowling/self/place_trap/poison
	name = "Установить ядовитую ловушку"
	trap_type = /obj/structure/shadow_trap/poison
	action_icon_state = "poison_trap"

// Blindness Trap
// Deal damage to eyes and create blindsmoke cloud

/obj/structure/shadow_trap/blindness
	trap_adjective = "ослепляющая"
	hud_icon_state = "blindness"

/obj/structure/shadow_trap/blindness/trap_activate(mob/living/target)
	if(!ishuman(target))
		return FALSE
	to_chat(target, span_boldwarning("С потолка на вас капает чёрная вязкая слизь. Она начинает выделять огромное колличество чёрного дыма!"))
	playsound(src, 'sound/effects/bamf.ogg', 50, TRUE)
	var/datum/reagents/reagents_list = new (1000)
	reagents_list.add_reagent("blindness_smoke", 810)
	var/datum/effect_system/smoke_spread/chem/chem_smoke = new
	chem_smoke.set_up(reagents_list, loc, TRUE)
	chem_smoke.start(4)
	if(target.reagents)
		target.reagents.add_reagent("blindness_smoke", 30)
	var/obj/item/organ/internal/eyes/eyes = target.get_int_organ(/obj/item/organ/internal/eyes)
	eyes.receive_damage(15, 1)
	return TRUE

/datum/spell/shadowling/self/place_trap/blindness
	name = "Установить ослепляющую ловушку"
	trap_type = /obj/structure/shadow_trap/blindness
	action_icon_state = "blindness_trap"

