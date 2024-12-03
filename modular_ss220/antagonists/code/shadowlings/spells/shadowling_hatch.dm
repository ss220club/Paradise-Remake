/obj/structure/alien/resin/wall/shadowling
	name = "Теневая стена"
	desc = "Стена из дымящейся чёрной материи, напоминающей смолу. Выглядит неразрушимой."
	max_integrity = INFINITY

/datum/spell/shadowling/self/hatch
	name = "Вылупиться"
	desc = "Вы окружаете себя теневым коконом и разрываете оболочку, обнажая свою истинную форму. Лучше использовать в укромном месте"
	stat_allowed = CONSCIOUS
	base_cooldown = 5 MINUTES
	action_icon_state = "ascend"

/datum/spell/shadowling/self/hatch/can_cast(mob/user, charge_check, show_message)
	if(!ishuman(user))
		return FALSE
	if(!isturf(user.loc))
		return FALSE
	if(istype(user.loc, /turf/space))
		return FALSE
	. = ..()

/datum/spell/shadowling/self/hatch/cast(list/targets, mob/user)
	. = ..()
	var/mob/living/carbon/human/shadowling = user
	if(!istype(shadowling))
		return FALSE
	var/result = tgui_alert(shadowling, "Вы уверены что хотите скинуть оболочку? Это займёт некоторое время и после этого всем станет ясна ваша сущность.", "Вылупиться?", list("Да", "Нет"))
	if(result != "Да")
		return FALSE

	for(var/obj/item/item in shadowling.get_equipped_items(include_pockets = TRUE))
		shadowling.unEquip(item, TRUE)

	sleep(5 SECONDS)

	// Creating cocoon
	var/turf/simulated/floor/F
	var/turf/shadowturf = get_turf(shadowling)
	for(F in orange(1, shadowling))
		new /obj/structure/alien/resin/wall/shadowling(F)

	for(var/obj/structure/alien/resin/wall/shadowling/R in shadowturf)
		qdel(R)

	// Temporal godmode and stun for shadowling

	shadowling.dna.species.brute_mod = 0;
	shadowling.dna.species.burn_mod = 0;
	shadowling.dna.species.tox_mod = 0;
	shadowling.dna.species.oxy_mod = 0;
	shadowling.dna.species.clone_mod = 0;
	shadowling.dna.species.brain_mod = 0;
	shadowling.Stun(INFINITY)	// Until hatching complete

	shadowling.visible_message(
		span_warning("Тёмная мембрана образуется вокруг [shadowling]. Изнутри начинают доноситься странные булькающие звуки.."),
		span_notice("Вы начинаете свою метаморфозу. Внутри этого кокона вы вскоре избавитесь от ограничевающей вас оболочки.")
	)
	sleep(10 SECONDS)

	shadowling.visible_message(
		span_warning("Кожа [shadowling] пузырится и неествественно извивается, постепенно отваливаясь целыми лоскутами. За ней виднеется чёрная плоть."),
		span_notice("Кожа начинает постепенно сползать с вас. Вы чувствуете как ваша истинная сила возвращается к вам.")
	)
	sleep(10 SECONDS)

	sleep(8 SECONDS)
	playsound(shadowling.loc, 'sound/weapons/slash.ogg', 25, TRUE)
	to_chat(shadowling, span_purple("Вы начинаете вырываться из кокона."))

	sleep(1 SECONDS)
	playsound(shadowling.loc, 'sound/weapons/slashmiss.ogg', 25, TRUE)
	to_chat(shadowling, span_purple("Кокон рушится под вашими ударами."))

	sleep(1 SECONDS)
	playsound(shadowling.loc, 'sound/weapons/slice.ogg', 25, TRUE)
	to_chat(shadowling, span_purple("ВЫ СВОБОДНЫ!"))

	sleep(1 SECONDS)
	playsound(shadowling.loc, 'sound/effects/ghost.ogg', 50, TRUE)

	// Removing cocoon
	for(var/obj/structure/alien/resin/wall/shadowling/resin in orange(shadowling, 1))
		playsound(resin, 'sound/effects/splat.ogg', 50, TRUE)
		qdel(resin)

	for(var/obj/structure/alien/weeds/node/node in shadowturf)
		qdel(node)

	// Transformation
	shadowling.set_species(/datum/species/shadow/ling)

	shadowling.equip_to_slot_or_del(new /obj/item/clothing/under/shadowling(user), SLOT_HUD_JUMPSUIT)
	shadowling.equip_to_slot_or_del(new /obj/item/clothing/shoes/shadowling(user), SLOT_HUD_SHOES)
	shadowling.equip_to_slot_or_del(new /obj/item/clothing/suit/space/shadowling(user), SLOT_HUD_OUTER_SUIT)
	shadowling.equip_to_slot_or_del(new /obj/item/clothing/head/shadowling(user), SLOT_HUD_HEAD)
	shadowling.equip_to_slot_or_del(new /obj/item/clothing/gloves/shadowling(user), SLOT_HUD_GLOVES)
	shadowling.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/shadowling(user), SLOT_HUD_WEAR_MASK)
	shadowling.equip_to_slot_or_del(new /obj/item/clothing/glasses/shadowling(user), SLOT_HUD_GLASSES)

	shadowling.name = random_name(MALE, "Shadowling")
	shadowling.real_name = shadowling.name
	shadowling.SetStunned(0)
	shadowling.underwear = "Nude"
	shadowling.undershirt = "Nude"
	shadowling.socks = "Nude"

	shadowling.ExtinguishMob()
	shadowling.set_nutrition(NUTRITION_LEVEL_FED + 50)

	// Granting spells
	var/list/datum/spell/spells_to_grant = list(
		new /datum/spell/shadowling/glare,
		new /datum/spell/shadowling/veil,
		new /datum/spell/shadowling/screech,
		new /datum/spell/shadowling/icy_veins,
		// TODO
		// new /datum/spell/shadowling/entrall,
		new /datum/spell/shadowling/self/blindness_smoke,
		new /datum/spell/shadowling/self/shadow_walk
	)
	for(var/datum/spell/spell in spells_to_grant)
		shadowling.AddSpell(spell)

	shadowling.RemoveSpell(src)
