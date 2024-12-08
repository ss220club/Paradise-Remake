/obj/item/reagent_containers/drinks/cans
	container_type = NONE
	var/can_opened = FALSE
	var/is_glass = FALSE
	var/is_plastic = FALSE
	var/times_shaken = FALSE
	var/can_shake = TRUE
	var/can_burst = FALSE
	var/burst_chance = 0

/obj/item/reagent_containers/drinks/cans/examine(mob/user)
	. = ..()
	if(can_opened)
		. += "<span class='notice'>Напиток открыт.</span>"
	else
		. += "<span class='notice'>Ctrl-click чтобы взболтать!</span>"

/obj/item/reagent_containers/drinks/cans/attack_self(mob/user)
	if(can_opened)
		return ..()
	if(times_shaken)
		fizzy_open(user)
		return ..()
	playsound(loc, 'sound/effects/canopen.ogg', rand(10, 50), 1)
	can_opened = TRUE
	container_type |= OPENCONTAINER
	to_chat(user, "<span class='notice'>Вы открываете напиток с громким щелчком!</span>")
	return ..()

/obj/item/reagent_containers/drinks/cans/proc/crush(mob/user)
	var/obj/item/trash/can/crushed_can = new /obj/item/trash/can(user.loc)
	crushed_can.icon_state = icon_state
	//inherit material vars for recycling purposes
	crushed_can.is_glass = is_glass
	crushed_can.is_plastic = is_plastic
	if(is_glass)
		playsound(user.loc, 'sound/effects/glassbr3.ogg', rand(10, 50), 1)
		crushed_can.name = "broken bottle"
	else
		playsound(user.loc, 'sound/weapons/pierce.ogg', rand(10, 50), 1)
	qdel(src)
	return crushed_can

/obj/item/reagent_containers/drinks/cans/CtrlClick(mob/user)
	var/mob/living/carbon/human/H
	if(!can_shake || !ishuman(user))
		return ..()
	H = user
	if(can_opened)
		to_chat(H, "<span class='warning'>Вы не можете взболтать уже открытый напиток!")
		return
	if(H.is_holding(src))
		can_shake = FALSE
		addtimer(CALLBACK(src, PROC_REF(reset_shakable)), 1 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)
		to_chat(H, "<span class='notice'>Вы начинаете взбалтывать [declent_ru(ACCUSATIVE)].</span>")
		if(do_after(H, 1 SECONDS, target = H))
			visible_message("<span class='warning'>[user.declent_ru(NOMINATIVE)] взбалтывает [declent_ru(ACCUSATIVE)]!</span>")
			if(times_shaken == 0)
				times_shaken++
				addtimer(CALLBACK(src, PROC_REF(reset_shaken)), 1 MINUTES, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_NO_HASH_WAIT)
			else if(times_shaken < 5)
				times_shaken++
				addtimer(CALLBACK(src, PROC_REF(reset_shaken)), (70 - (times_shaken * 10)) SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_NO_HASH_WAIT)
			else
				addtimer(CALLBACK(src, PROC_REF(reset_shaken)), 20 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_NO_HASH_WAIT)
				handle_bursting(user)
	else
		return ..()

/obj/item/reagent_containers/drinks/cans/attack(mob/M, mob/user, proximity)
	if(!can_opened)
		to_chat(user, "<span class='notice'>Вам нужно открыть напиток!</span>")
		return
	else if(M == user && !reagents.total_volume && user.a_intent == INTENT_HARM && user.zone_selected == "head")
		user.visible_message("<span class='warning'>[user] crushes [src] on [user.p_their()] forehead!</span>", "<span class='notice'>You crush [src] on your forehead.</span>")
		crush(user)
		return
	return ..()

/obj/item/reagent_containers/drinks/cans/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/storage/bag/trash/cyborg))
		user.visible_message("<span class='notice'>[user] crushes [src] in [user.p_their()] trash compactor.</span>", "<span class='notice'>You crush [src] in your trash compactor.</span>")
		var/obj/can = crush(user)
		can.attackby(I, user, params)
		return TRUE
	..()

/obj/item/reagent_containers/drinks/cans/afterattack(obj/target, mob/user, proximity)
	if(!proximity)
		return
	if(istype(target, /obj/structure/reagent_dispensers) && !can_opened)
		to_chat(user, "<span class='notice'>Вам нужно открыть напиток!</span>")
		return
	else if(target.is_open_container() && !can_opened)
		to_chat(user, "<span class='notice'>Вам нужно открыть напиток!</span>")
		return
	else
		return ..(target, user, proximity)

/obj/item/reagent_containers/drinks/cans/throw_impact(atom/A)
	. = ..()
	if(times_shaken < 5)
		times_shaken++
	else
		handle_bursting()

/obj/item/reagent_containers/drinks/cans/proc/fizzy_open(mob/user, burstopen = FALSE)
	playsound(loc, 'sound/effects/canopenfizz.ogg', rand(10, 50), 1)
	can_opened = TRUE
	container_type |= OPENCONTAINER

	if(!burstopen && user)
		to_chat(user, "<span class='notice'>Вы открываете напиток с громким щелчком!</span>")
	else
		visible_message("<span class='warning'>Банка с [declent_ru(INSTRUMENTAL)] лопается!</span>")

	if(times_shaken < 5)
		visible_message("<span class='warning'>[capitalize(declent_ru(NOMINATIVE))] сильно шипит!</span>")
	else
		visible_message("<span class='boldwarning'>[capitalize(declent_ru(NOMINATIVE))] вспенивается и вырывается наружу!</span>")
		if(reagents.total_volume)
			var/datum/effect_system/foam_spread/sodafizz = new
			sodafizz.set_up(1, get_turf(src), reagents)
			sodafizz.start()

	for(var/mob/living/carbon/C in range(1, get_turf(src)))
		to_chat(C, "<span class='warning'>Вас забрызгал [declent_ru(NOMINATIVE)]!</span>")
		reagents.reaction(C, REAGENT_TOUCH)
		C.wetlevel = max(C.wetlevel + 1, times_shaken)

	reagents.remove_any(times_shaken / 5 * reagents.total_volume)

/obj/item/reagent_containers/drinks/cans/proc/handle_bursting(mob/user)
	if(times_shaken != 5 || can_opened)
		return

	if(!can_burst)
		can_burst = TRUE
		burst_chance = 5
		return

	if(burst_chance < 50)
		burst_chance += 5

	if(prob((burst_chance)))
		if(user)
			fizzy_open(user, burstopen = TRUE)
		else
			fizzy_open(burstopen = TRUE)

/obj/item/reagent_containers/drinks/cans/proc/reset_shakable()
	can_shake = TRUE

/obj/item/reagent_containers/drinks/cans/proc/reset_shaken()
	times_shaken--
	if(can_burst)
		can_burst = FALSE
		burst_chance = 0
	if(times_shaken)
		addtimer(CALLBACK(src, PROC_REF(reset_shaken)), (70 - (times_shaken * 10)) SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_NO_HASH_WAIT)

/obj/item/reagent_containers/drinks/cans/cola
	name = "space cola"
	desc = "Кола. В космосе."
	icon_state = "cola"
	list_reagents = list("cola" = 30)

/obj/item/reagent_containers/drinks/cans/beer
	name = "space beer"
	desc = "Содержит только воду, солод и хмель."
	icon_state = "beer"
	is_glass = TRUE
	list_reagents = list("beer" = 30)

/obj/item/reagent_containers/drinks/cans/adminbooze
	name = "admin booze"
	desc = "Слёзы забаненных игроков 10-летней выдержки, для услаждения работы админов."
	icon_state = "adminbooze"
	is_glass = TRUE
	list_reagents = list("adminordrazine" = 5, "capsaicin" = 5, "methamphetamine"= 20, "thirteenloko" = 20)

/obj/item/reagent_containers/drinks/cans/madminmalt
	name = "madmin malt"
	desc = "Бутылка с эссенцией разгневанных админов. Пить с <i>ОСОБОЙ</i> осторожностью."
	icon_state = "madminmalt"
	is_glass = TRUE
	list_reagents = list("hell_water" = 20, "neurotoxin" = 15, "thirteenloko" = 15)

/obj/item/reagent_containers/drinks/cans/badminbrew
	name = "badmin brew"
	desc = "Бутылка обмана и ужасной работы админов. Наверное, не стоит это пить."
	icon_state = "badminbrew"
	is_glass = TRUE
	list_reagents = list("mutagen" = 25, "charcoal" = 10, "thirteenloko" = 15)

/obj/item/reagent_containers/drinks/cans/ale
	name = "Magm-Ale"
	desc = "Напиток для истинных дворфов."
	icon_state = "alebottle"
	item_state = "beer"
	is_glass = TRUE
	list_reagents = list("ale" = 30)

/obj/item/reagent_containers/drinks/cans/space_mountain_wind
	name = "Space Mountain Wind"
	desc = "Проходит через тебя, словно космический ветер."
	icon_state = "space_mountain_wind"
	list_reagents = list("spacemountainwind" = 30)

/obj/item/reagent_containers/drinks/cans/thirteenloko
	name = "Thirteen Loko"
	desc = "СМО предупреждает членов экипажа, что употребление Thirteen Loko может привести к судорогам, слепоте, опьянению или даже смерти. Пейте ответственно."
	icon_state = "thirteen_loko"
	list_reagents = list("thirteenloko" = 25, "psilocybin" = 5)

/obj/item/reagent_containers/drinks/cans/dr_gibb
	name = "Dr. Gibb"
	desc = "Вкусная смесь из 42 различных вкусов."
	icon_state = "dr_gibb"
	list_reagents = list("dr_gibb" = 30)


/obj/item/reagent_containers/drinks/cans/starkist
	name = "Star-kist"
	desc = "Вкус звезды в жидкой форме. С привкусом тунца...?"
	icon_state = "starkist"
	list_reagents = list("brownstar" = 30)

/obj/item/reagent_containers/drinks/cans/space_up
	name = "Space-Up"
	desc = "Вкус, как если бы в вашем рту произошла разгерметизация."
	icon_state = "space-up"
	list_reagents = list("space_up" = 30)

/obj/item/reagent_containers/drinks/cans/lemon_lime
	name = "Lemon-Lime"
	desc = "Вы хотели АПЕЛЬСИН. Жизнь подарила вам Лимон-Лайм."
	icon_state = "lemon-lime"
	list_reagents = list("lemon_lime" = 30)

/obj/item/reagent_containers/drinks/cans/iced_tea
	name = "Vrisk Serket Iced Tea"
	desc = "О этот сладкий, освежающий вкус Земного чая. Он ведь точно оттуда? С Земли?"
	icon_state = "ice_tea_can"
	list_reagents = list("icetea" = 30)

/obj/item/reagent_containers/drinks/cans/grape_juice
	name = "Grapel Juice"
	desc = "500 страниц правил, как правильно вступить в бой с этим соком!"
	icon_state = "purple_can"
	list_reagents = list("grapejuice" = 30)

/obj/item/reagent_containers/drinks/cans/tonic
	name = "T-Borg's Tonic Water"
	desc = "Хинин имеет странный вкус, но, по крайней мере, он защитит от космической малярии."
	icon_state = "tonic"
	list_reagents = list("tonic" = 50)

/obj/item/reagent_containers/drinks/cans/sodawater
	name = "soda water"
	desc = "Банка газированной воды. Более освежающая двоюродная сестра обычной воды."
	icon_state = "sodawater"
	list_reagents = list("sodawater" = 50)

/obj/item/reagent_containers/drinks/cans/synthanol
	name = "Beep's Classic Synthanol"
	desc = "Банка алкоголя для КПБ, как бы это ни работало."
	icon_state = "synthanolcan"
	list_reagents = list("synthanol" = 50)

/obj/item/reagent_containers/drinks/cans/bottler
	name = "generic beverage container"
	desc = "Это не должно было быть создано. Позор тебе."
	icon_state = "glass_bottle"

/obj/item/reagent_containers/drinks/cans/bottler/on_reagent_change()
	update_icon(UPDATE_OVERLAYS)

/obj/item/reagent_containers/drinks/cans/bottler/update_overlays()
	. = ..()
	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]10")

		switch(round(reagents.total_volume))
			if(0 to 9)
				filling.icon_state = "[icon_state]-10"
			if(10 to 19)
				filling.icon_state = "[icon_state]10"
			if(20 to 29)
				filling.icon_state = "[icon_state]20"
			if(30 to 39)
				filling.icon_state = "[icon_state]30"
			if(40 to 49)
				filling.icon_state = "[icon_state]40"
			if(50 to INFINITY)
				filling.icon_state = "[icon_state]50"

		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		. += filling

/obj/item/reagent_containers/drinks/cans/bottler/glass_bottle
	name = "glass bottle"
	desc = "Стеклянная бутылка, подходящая для напитков."
	icon_state = "glass_bottle"
	is_glass = TRUE

/obj/item/reagent_containers/drinks/cans/bottler/plastic_bottle
	name = "plastic bottle"
	desc = "Пластиковая бутылка, подходящая для напитков."
	icon_state = "plastic_bottle"
	is_plastic = TRUE

/obj/item/reagent_containers/drinks/cans/bottler/metal_can
	name = "metal can"
	desc = "Металлическая банка, подходящая для напитков."
	icon_state = "metal_can"
