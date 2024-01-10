/obj/structure/AIcore
	density = TRUE
	anchored = FALSE
	name = "Ядро ИИ"
	icon = 'icons/mob/AI.dmi'
	icon_state = "0"
	max_integrity = 500
	var/state = 0
	var/datum/ai_laws/laws = new /datum/ai_laws/crewsimov()
	var/obj/item/circuitboard/aicore/circuit = null
	var/obj/item/mmi/brain = null

/obj/structure/AIcore/Destroy()
	QDEL_NULL(laws)
	QDEL_NULL(circuit)
	QDEL_NULL(brain)
	return ..()

/obj/structure/AIcore/attackby(obj/item/P, mob/user, params)
	switch(state)
		if(EMPTY_CORE)
			if(istype(P, /obj/item/circuitboard/aicore))
				if(!user.drop_item())
					return
				playsound(loc, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>Вы вставляете плату в раму.</span>")
				update_icon(UPDATE_ICON_STATE)
				state = CIRCUIT_CORE
				P.forceMove(src)
				circuit = P
				return
		if(SCREWED_CORE)
			if(istype(P, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = P
				if(C.get_amount() >= 5)
					playsound(loc, 'sound/items/deconstruct.ogg', 50, 1)
					to_chat(user, "<span class='notice'>Вы добавляете кабелей к раме...</span>")
					if(do_after(user, 20, target = src) && state == SCREWED_CORE && C.use(5))
						to_chat(user, "<span class='notice'>Вы добавили кабелей к раме.</span>")
						state = CABLED_CORE
						update_icon(UPDATE_ICON_STATE)
				else
					to_chat(user, "<span class='warning'>Вам нужно 5 кабелей для вставки проводки в ядро ИИ!</span>")
				return
		if(CABLED_CORE)
			if(istype(P, /obj/item/stack/sheet/rglass))
				var/obj/item/stack/sheet/rglass/G = P
				if(G.get_amount() >= 2)
					playsound(loc, 'sound/items/deconstruct.ogg', 50, 1)
					to_chat(user, "<span class='notice'>Вы ставите стеклянную панель...</span>")
					if(do_after(user, 20, target = src) && state == CABLED_CORE && G.use(2))
						to_chat(user, "<span class='notice'>Вы вставили стеклянную панель.</span>")
						state = GLASS_CORE
						update_icon(UPDATE_ICON_STATE)
				else
					to_chat(user, "<span class='warning'>Вам нужно два листа укрепленного стекла для вставки в ядро ИИ!</span>")
				return

			if(istype(P, /obj/item/aiModule/purge))
				laws.clear_inherent_laws()
				to_chat(usr, "<span class='notice'>Применён модуль Purge.</span>")
				return

			if(istype(P, /obj/item/aiModule/freeform))
				var/obj/item/aiModule/freeform/M = P
				if(!M.newFreeFormLaw)
					to_chat(usr, "На модуле не обнаружено закона. Пожалуйста, напишите его.")
					return
				laws.add_supplied_law(M.lawpos, M.newFreeFormLaw)
				to_chat(usr, "<span class='notice'>Добавлен закон Freeform.</span>")
				return

			if(istype(P, /obj/item/aiModule/syndicate))
				var/obj/item/aiModule/syndicate/M = P
				if(!M.newFreeFormLaw)
					to_chat(usr, "На модуле не обнаружено закона. Пожалуйста, напишите его.")
					return
				laws.add_ion_law(M.newFreeFormLaw)
				to_chat(usr, "<span class='notice'>Добавлен взломанный закон.</span>")
				return

			if(istype(P, /obj/item/aiModule))
				var/obj/item/aiModule/M = P
				if(!M.laws)
					to_chat(usr, "<span class='warning'>Этот модуль ИИ нельзя применить напрямую к ядру.</span>")
					return
				laws = M.laws
				to_chat(usr, "<span class='notice'>Добавлены [M.laws.name] законы.</span>")
				return

			if(istype(P, /obj/item/mmi) && !brain)
				var/obj/item/mmi/M = P
				if(!M.brainmob)
					to_chat(user, "<span class='warning'>Вставка пустого [P] в раму своего рода противоречить цели.</span>")
					return
				if(M.brainmob.stat == DEAD)
					to_chat(user, "<span class='warning'>Вставка мёртвого [P] в раму своего рода противоречить цели.</span>")
					return

				if(!M.brainmob.client)
					to_chat(user, "<span class='warning'>Вставка неактивного [M.name] в раму своего рода противоречить цели.</span>")
					return

				if(jobban_isbanned(M.brainmob, "AI") || jobban_isbanned(M.brainmob, "nonhumandept"))
					to_chat(user, "<span class='warning'>Видимо, [P] не подходит.</span>")
					return

				if(!M.brainmob.mind)
					to_chat(user, "<span class='warning'>[M.name] сейчас без разума!</span>")
					return

				if(istype(P, /obj/item/mmi/syndie))
					to_chat(user, "<span class='warning'>Этот MMI, видимо, не подходит!</span>")
					return

				if(!user.drop_item())
					return

				M.forceMove(src)
				brain = M
				to_chat(user, "<span class='notice'>Вы вставляете [M.name] в раму.</span>")
				update_icon(UPDATE_ICON_STATE)
				return

	return ..()

/obj/structure/AIcore/crowbar_act(mob/living/user, obj/item/I)
	if(state !=CIRCUIT_CORE && state != GLASS_CORE && !(state == CABLED_CORE && brain))
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	switch(state)
		if(CIRCUIT_CORE)
			to_chat(user, "<span class='notice'>Вы вытаскиваете плату.</span>")
			state = EMPTY_CORE
			circuit.forceMove(loc)
			circuit = null
			return
		if(GLASS_CORE)
			to_chat(user, "<span class='notice'>Вы убираете стеклянную панель.</span>")
			state = CABLED_CORE
			new /obj/item/stack/sheet/rglass(loc, 2)
			return
		if(CABLED_CORE)
			if(brain)
				to_chat(user, "<span class='notice'>Вы удаляете мозг.</span>")
				brain.forceMove(loc)
				brain = null
	update_icon(UPDATE_ICON_STATE)

/obj/structure/AIcore/screwdriver_act(mob/living/user, obj/item/I)
	if(!(state in list(SCREWED_CORE, CIRCUIT_CORE, GLASS_CORE, AI_READY_CORE)))
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	switch(state)
		if(SCREWED_CORE)
			to_chat(user, "<span class='notice'>Вы откручиваете плату.</span>")
			state = CIRCUIT_CORE
		if(CIRCUIT_CORE)
			to_chat(user, "<span class='notice'>Вы закручиваете плату в слот.</span>")
			state = SCREWED_CORE
		if(GLASS_CORE)
			var/area/R = get_area(src)
			message_admins("[key_name_admin(usr)] has completed an AI core in [R]: [ADMIN_COORDJMP(loc)].")
			log_game("[key_name(usr)] has completed an AI core in [R]: [COORD(loc)].")
			to_chat(user, "<span class='notice'>Вы подключаете монитор.</span>")
			if(!brain)
				var/open_for_latejoin = alert(user, "Вы хотите, чтобы это ядро было доступно из лобби игры?", "Latejoin", "Да", "Да", "Нет") == "Да"
				var/obj/structure/AIcore/deactivated/D = new(loc)
				if(open_for_latejoin)
					GLOB.empty_playable_ai_cores += D
			else
				if(brain.brainmob.mind)
					SSticker.mode.remove_cultist(brain.brainmob.mind, 1)
					SSticker.mode.remove_revolutionary(brain.brainmob.mind, 1)

				var/mob/living/silicon/ai/A = new /mob/living/silicon/ai(loc, laws, brain)
				if(A) //if there's no brain, the mob is deleted and a structure/AIcore is created
					A.rename_self("ИИ", 1)
			SSblackbox.record_feedback("amount", "ais_created", 1)
			qdel(src)
		if(AI_READY_CORE)
			to_chat(user, "<span class='notice'>Вы отключаете монитор.</span>")
			state = GLASS_CORE
	update_icon(UPDATE_ICON_STATE)


/obj/structure/AIcore/wirecutter_act(mob/living/user, obj/item/I)
	if(state != CABLED_CORE)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(brain)
		to_chat(user, "<span class='warning'> Сначала вытащите [brain.name] !</span>")
	else
		to_chat(user, "<span class='notice'>Вы убираете проводку.</span>")
		state = SCREWED_CORE
		update_icon(UPDATE_ICON_STATE)
		var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil( loc )
		A.amount = 5

/obj/structure/AIcore/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I, 20)

/obj/structure/AIcore/update_icon_state()
	switch(state)
		if(EMPTY_CORE)
			icon_state = "0"
		if(CIRCUIT_CORE)
			icon_state = "1"
		if(SCREWED_CORE)
			icon_state = "2"
		if(CABLED_CORE)
			if(brain)
				icon_state = "3b"
			else
				icon_state = "3"
		if(GLASS_CORE)
			icon_state = "4"
		if(AI_READY_CORE)
			icon_state = "ai-empty"

/obj/structure/AIcore/deconstruct(disassembled = TRUE)
	if(state == GLASS_CORE)
		new /obj/item/stack/sheet/rglass(loc, 2)
	if(state >= CABLED_CORE)
		new /obj/item/stack/cable_coil(loc, 5)
	if(circuit)
		circuit.forceMove(loc)
		circuit = null
	new /obj/item/stack/sheet/plasteel(loc, 4)
	qdel(src)

/obj/structure/AIcore/welder_act(mob/user, obj/item/I)
	if(state)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_WELD_MESSAGE
	if(I.use_tool(src, user, 20, volume = I.tool_volume))
		to_chat(user, "<span class='notice'>Вы разбираете раму.</span>")
		new /obj/item/stack/sheet/plasteel(drop_location(), 4)
		qdel(src)

/obj/structure/AIcore/deactivated
	name = "Неактивный ИИ"
	icon_state = "ai-empty"
	anchored = TRUE
	state = AI_READY_CORE

/obj/structure/AIcore/deactivated/Initialize(mapload)
	. = ..()
	circuit = new(src)

/obj/structure/AIcore/deactivated/Destroy()
	if(src in GLOB.empty_playable_ai_cores)
		GLOB.empty_playable_ai_cores -= src
	return ..()

/client/proc/empty_ai_core_toggle_latejoin()
	set name = "Toggle AI Core Latejoin"
	set category = "Admin"

	var/list/cores = list()
	for(var/obj/structure/AIcore/deactivated/D in world)
		cores["[D] ([D.loc.loc])"] = D

	if(!cores.len)
		to_chat(src, "No deactivated AI cores were found.")

	var/id = input("Which core?", "Toggle AI Core Latejoin", null) as null|anything in cores
	if(!id) return

	var/obj/structure/AIcore/deactivated/D = cores[id]
	if(!D) return

	if(D in GLOB.empty_playable_ai_cores)
		GLOB.empty_playable_ai_cores -= D
		to_chat(src, "\The [id] is now <font color=\"#ff0000\">not available</font> for latejoining AIs.")
	else
		GLOB.empty_playable_ai_cores += D
		to_chat(src, "\The [id] is now <font color=\"#008000\">available</font> for latejoining AIs.")


/*
This is a good place for AI-related object verbs so I'm sticking it here.
If adding stuff to this, don't forget that an AI need to cancel_camera() whenever it physically moves to a different location.
That prevents a few funky behaviors.
*/
//The type of interaction, the player performing the operation, the AI itself, and the card object, if any.


/atom/proc/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(istype(card))
		if(card.flush)
			to_chat(user, "<span class='boldannounce'>ERROR</span>: AI flush is in progress, cannot execute transfer protocol.")
			return 0
	return 1


/obj/structure/AIcore/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(state != AI_READY_CORE || !..())
		return
 //Transferring a carded AI to a core.
	if(interaction == AI_TRANS_FROM_CARD)
		AI.control_disabled = FALSE
		AI.aiRadio.disabledAi = FALSE
		AI.forceMove(loc)//To replace the terminal.
		to_chat(AI, "You have been uploaded to a stationary terminal. Remote device connection restored.")
		to_chat(user, "<span class='boldnotice'>Transfer successful</span>: [AI.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed.</span>")
		if(!AI.builtInCamera && GetComponent(/datum/component/ducttape))
			AI.builtInCamera = new /obj/machinery/camera/portable(AI)
			AI.builtInCamera.c_tag = AI.name
			AI.builtInCamera.network = list("SS13")
		qdel(src)
	else //If for some reason you use an empty card on an empty AI terminal.
		to_chat(user, "There is no AI loaded on this terminal!")

