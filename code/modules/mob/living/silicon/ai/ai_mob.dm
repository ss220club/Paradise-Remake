GLOBAL_LIST_EMPTY(ai_list)
GLOBAL_LIST_INIT(ai_verbs_default, list(
	/mob/living/silicon/ai/proc/announcement,
	/mob/living/silicon/ai/proc/ai_announcement_text,
	/mob/living/silicon/ai/proc/ai_call_shuttle,
	/mob/living/silicon/ai/proc/ai_camera_track,
	/mob/living/silicon/ai/proc/ai_camera_list,
	/mob/living/silicon/ai/proc/ai_hologram_change,
	/mob/living/silicon/ai/proc/ai_network_change,
	/mob/living/silicon/ai/proc/ai_roster,
	/mob/living/silicon/ai/proc/ai_statuschange,
	/mob/living/silicon/ai/proc/control_integrated_radio,
	/mob/living/silicon/ai/proc/core,
	/mob/living/silicon/ai/proc/pick_icon,
	/mob/living/silicon/ai/proc/sensor_mode,
	/mob/living/silicon/ai/proc/show_laws_verb,
	/mob/living/silicon/ai/proc/toggle_acceleration,
	/mob/living/silicon/ai/proc/toggle_camera_light,
	/mob/living/silicon/ai/proc/botcall,
	/mob/living/silicon/ai/proc/change_arrival_message,
	/mob/living/silicon/ai/proc/arrivals_announcement
))

//Not sure why this is necessary...
/proc/AutoUpdateAI(obj/subject)
	var/is_in_use = 0
	if(subject!=null)
		for(var/A in GLOB.ai_list)
			var/mob/living/silicon/ai/M = A
			if((M.client && M.machine == subject))
				is_in_use = 1
				subject.attack_ai(M)
	return is_in_use

#define TEXT_ANNOUNCEMENT_COOLDOWN 1 MINUTES

/mob/living/silicon/ai
	name = "AI"
	icon = 'icons/mob/ai.dmi'//
	icon_state = "ai"
	move_resist = MOVE_FORCE_NORMAL
	density = TRUE
	status_flags = CANSTUN|CANPARALYSE|CANPUSH
	d_hud = DATA_HUD_DIAGNOSTIC_ADVANCED
	mob_size = MOB_SIZE_LARGE
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS
	see_invisible = SEE_INVISIBLE_LIVING_AI
	see_in_dark = 8
	can_strip = FALSE
	var/list/network = list("SS13","Telecomms","Research Outpost","Mining Outpost")
	var/obj/machinery/camera/current = null
	var/list/connected_robots = list()
	var/aiRestorePowerRoutine = 0
	//var/list/laws = list()
	alarms_listend_for = list("Motion", "Fire", "Atmosphere", "Power", "Burglar")
	var/viewalerts = FALSE
	var/icon/holo_icon //Default is assigned when AI is created.
	var/obj/mecha/controlled_mech //For controlled_mech a mech, to determine whether to relaymove or use the AI eye.
	var/obj/item/pda/silicon/ai/aiPDA = null
	var/obj/item/multitool/aiMulti = null
	var/custom_sprite = FALSE //For our custom sprites
	var/custom_hologram = FALSE //For our custom holograms

	var/obj/item/radio/headset/heads/ai_integrated/aiRadio = null

	//MALFUNCTION
	var/datum/module_picker/malf_picker
	var/datum/action/innate/ai/choose_modules/modules_action
	var/list/datum/AI_Module/current_modules = list()
	var/can_dominate_mechs = FALSE
	var/shunted = FALSE // TRUE if the AI is currently shunted. Used to differentiate between shunted and ghosted/braindead

	var/control_disabled = FALSE // Set to TRUE to stop AI from interacting via Click() -- TLE
	var/malfhacking = null // A timer for when malf AIs can hack and get new cyborgs
	var/malf_cooldown = 0 //Cooldown var for malf modules, stores a worldtime + cooldown

	var/obj/machinery/power/apc/malfhack = null
	var/explosive = 0 //does the AI explode when it dies?

	/// List of modules the AI has purchased malf upgrades for.
	var/list/purchased_modules = list()

	var/mob/living/silicon/ai/parent = null
	var/camera_light_on = FALSE
	var/list/obj/machinery/camera/lit_cameras = list()

	var/datum/trackable/track = new()

	var/last_paper_seen = null
	var/can_shunt = TRUE
	var/last_announcement = ""
	var/datum/announcer/announcer
	var/mob/living/simple_animal/bot/Bot
	var/turf/waypoint //Holds the turf of the currently selected waypoint.
	var/waypoint_mode = FALSE //Waypoint mode is for selecting a turf via clicking.
	var/apc_override = FALSE	//hack for letting the AI use its APC even when visionless
	var/nuking = FALSE
	var/obj/machinery/doomsday_device/doomsday_device

	var/obj/machinery/hologram/holopad/holo = null
	var/mob/camera/aiEye/eyeobj
	var/sprint = 10
	var/cooldown = 0
	var/acceleration = 1
	var/tracking = FALSE //this is 1 if the AI is currently tracking somebody, but the track has not yet been completed.

	/// If true, this AI core can use the teleporter.
	var/allow_teleporter = FALSE

	var/obj/machinery/camera/portable/builtInCamera

	var/obj/structure/AIcore/deactivated/linked_core //For exosuit control

	/// If our AI doesn't want to be the arrivals announcer, this gets set to FALSE.
	var/announce_arrivals = TRUE
	var/arrivalmsg = "$name, $rank, прибывает на станцию."

	var/list/all_eyes = list()
	var/next_text_announcement

	//Used with the hotkeys on 2-5 to store locations.
	var/list/stored_locations = list()

/mob/living/silicon/ai/proc/add_ai_verbs()
	verbs |= GLOB.ai_verbs_default
	verbs |= silicon_subsystems

/mob/living/silicon/ai/proc/remove_ai_verbs()
	verbs -= GLOB.ai_verbs_default
	verbs -= silicon_subsystems

/mob/living/silicon/ai/New(loc, datum/ai_laws/L, obj/item/mmi/B, safety = 0)
	announcer = new(config_type = /datum/announcement_configuration/ai)
	announcer.author = name

	var/list/possibleNames = GLOB.ai_names

	var/pickedName = null
	while(!pickedName)
		pickedName = pick(GLOB.ai_names)
		for(var/mob/living/silicon/ai/A in GLOB.mob_list)
			if(A.real_name == pickedName && possibleNames.len > 1) //fixing the theoretically possible infinite loop
				possibleNames -= pickedName
				pickedName = null

	aiPDA = new/obj/item/pda/silicon/ai(src)
	rename_character(null, pickedName)
	anchored = TRUE
	density = TRUE
	loc = loc

	holo_icon = getHologramIcon(icon('icons/mob/ai.dmi',"holo1"))

	proc_holder_list = new()

	if(L)
		if(istype(L, /datum/ai_laws))
			laws = L
	else
		make_laws()

	verbs += /mob/living/silicon/ai/proc/show_laws_verb

	aiMulti = new(src)
	aiRadio = new(src)
	aiRadio.myAi = src
	additional_law_channels["Binary"] = ":b "
	additional_law_channels["Holopad"] = ":h"

	aiCamera = new/obj/item/camera/siliconcam/ai_camera(src)

	if(isturf(loc))
		add_ai_verbs(src)

	// Remove inherited verbs that effectively do nothing for AIs, or lead to unintended behaviour.
	verbs -= /mob/living/verb/rest
	verbs -= /mob/living/verb/mob_sleep
	verbs -= /mob/living/verb/stop_pulling1
	verbs -= /mob/living/silicon/verb/pose
	verbs -= /mob/living/silicon/verb/set_flavor

	//Languages
	add_language("Robot Talk", 1)
	add_language("Galactic Common", 1)
	add_language("Sol Common", 1)
	add_language("Tradeband", 1)
	add_language("Neo-Russkiya", 1)
	add_language("Gutter", 1)
	add_language("Sinta'unathi", 1)
	add_language("Siik'tajr", 1)
	add_language("Canilunzt", 1)
	add_language("Skrellian", 1)
	add_language("Vox-pidgin", 1)
	add_language("Orluum", 1)
	add_language("Rootspeak", 1)
	add_language("Trinary", 1)
	add_language("Chittin", 1)
	add_language("Bubblish", 1)
	add_language("Clownish", 1)
	add_language("Tkachi", 1)

	if(!safety)//Only used by AIize() to successfully spawn an AI.
		if(!B)//If there is no player/brain inside.
			new/obj/structure/AIcore/deactivated(loc)//New empty terminal.
			qdel(src)//Delete AI.
			return
		else
			if(B.brainmob.mind)
				B.brainmob.mind.transfer_to(src)

			on_mob_init()

	spawn(5)
		new /obj/machinery/ai_powersupply(src)

	create_eye()

	builtInCamera = new /obj/machinery/camera/portable(src)
	builtInCamera.c_tag = name
	builtInCamera.network = list("SS13")

	GLOB.ai_list += src
	GLOB.shuttle_caller_list += src

	for(var/I in 1 to 4)
		stored_locations += "unset" //This is checked in ai_keybinds.dm.

	..()

/mob/living/silicon/ai/Destroy()
	GLOB.ai_list -= src
	GLOB.shuttle_caller_list -= src
	SSshuttle.autoEvac()
	if(malfhacking)
		deltimer(malfhacking)
		malfhacking = null
	QDEL_NULL(eyeobj) // No AI, no Eye
	QDEL_NULL(aiPDA)
	QDEL_NULL(aiMulti)
	QDEL_NULL(aiRadio)
	QDEL_NULL(builtInCamera)
	return ..()

/mob/living/silicon/ai/get_radio()
	return aiRadio

/mob/living/silicon/ai/proc/on_mob_init()
	to_chat(src, "<B>Вы играете за станционный ИИ. ИИ не может передвигаться, но может взаимодействовать с большим количеством объектов просто смотря на них (через камеры).</B>")
	to_chat(src, "<B>Чтобы осматривать другие части станции, кликните на 'Переключение сети'.</B>")
	to_chat(src, "<B>Пока вы смотрите через камеры, вы можете взаимодействовать с большинством (подключённых) видимых устройств по типу компьютеров, ЛКП, интеркомов, дверей и так далее.</B>")
	to_chat(src, "Чтобы использовать что-то, просто кликните по предмету.")
	to_chat(src, "Используйте :b для общения с киборгами. Используйте :h для общения через активный голопад.")
	to_chat(src, "Для каналов отделов используйте:")

	var/radio_text = ""
	for(var/i = 1 to aiRadio.channels.len)
		var/channel = aiRadio.channels[i]
		var/key = get_radio_key_from_channel(channel)
		radio_text += "[key] - [channel]"
		if(i != aiRadio.channels.len)
			radio_text += ", "

	to_chat(src, radio_text)

	show_laws()
	to_chat(src, "<b>Эти законы могут быть изменены другими игроками или вами при игре за предателя.</b>")

	job = "AI"

/mob/living/silicon/ai/Stat()
	..()
	if(statpanel("Status"))
		if(stat)
			stat(null, "Systems nonfunctional")
			return
		show_borg_info()

/mob/living/silicon/ai/proc/ai_alerts()
	var/list/dat = list("<HEAD><TITLE>Текущие тревоги на станции</TITLE><META HTTP-EQUIV='Обновить' CONTENT='10'></HEAD><BODY>\n")
	dat += "<A HREF='?src=[UID()];mach_close=aialerts'>Закрыть</A><BR><BR>"
	var/list/list/temp_alarm_list = GLOB.alarm_manager.alarms.Copy()
	for(var/cat in temp_alarm_list)
		if(!(cat in alarms_listend_for))
			continue
		dat += "<B>[cat]</B><BR>\n"
		var/list/list/L = temp_alarm_list[cat].Copy()
		for(var/alarm in L)
			var/list/list/alm = L[alarm].Copy()
			var/area_name = alm[1]
			var/C = alm[2]
			var/list/list/sources = alm[3].Copy()
			for(var/thing in sources)
				var/atom/A = locateUID(thing)
				if(A && A.z != z)
					L -= alarm
					continue
				dat += "<NOBR>"
				if(C && islist(C))
					var/dat2 = ""
					for(var/cam in C)
						var/obj/machinery/camera/I = locateUID(cam)
						if(!QDELETED(I))
							dat2 += "[(dat2 == "") ? "" : " | "]<A HREF=?src=[UID()];switchcamera=[cam]>[I.c_tag]</A>"
					dat += "-- [area_name] ([(dat2 != "") ? dat2 : "Нет камеры"])"
				else
					dat += "-- [area_name] (Нет камеры)"
				if(sources.len > 1)
					dat += "- [length(sources)] источников"
				dat += "</NOBR><BR>\n"
		if(!L.len)
			dat += "-- Все системы в норме<BR>\n"
		dat += "<BR>\n"

	viewalerts = TRUE
	var/dat_text = dat.Join("")
	src << browse(dat_text, "window=aialerts&can_close=0")

/mob/living/silicon/ai/proc/show_borg_info()
	stat(null, "Подключённые киборги: [connected_robots.len]")
	for(var/thing in connected_robots)
		var/mob/living/silicon/robot/R = thing
		var/robot_status = "Исправен"
		if(R.stat || !R.client)
			robot_status = "СЛОМАН"
		else if(!R.cell || R.cell.charge <= 0)
			robot_status = "ОТКЛЮЧЁН"
		// Name, Health, Battery, Module, Area, and Status! Everything an AI wants to know about its borgies!
		var/area/A = get_area(R)
		var/area_name = A ? sanitize(A.name) : "Unknown"
		stat(null, "[R.name] | Целостность: [R.health]% | Заряд: [R.cell ? "[R.cell.charge] / [R.cell.maxcharge]" : "N/A"] | \
		Модуль: [R.designation] | Место: [area_name] | Статус: [robot_status]")

/mob/living/silicon/ai/rename_character(oldname, newname)
	if(!..(oldname, newname))
		return FALSE

	if(oldname != real_name)
		announcer.author = name

		if(eyeobj)
			eyeobj.name = "[newname] (Глаз ИИ)"

		// Set ai pda name
		if(aiPDA)
			aiPDA.set_name_and_job(newname, "AI")

	return TRUE


/*
	The AI Power supply is a dummy object used for powering the AI since only machinery should be using power.
	The alternative was to rewrite a bunch of AI code instead here we are.
*/
/obj/machinery/ai_powersupply
	name="\improper AI power supply"
	active_power_consumption = 1000
	power_state = ACTIVE_POWER_USE
	var/mob/living/silicon/ai/powered_ai = null
	invisibility = 100

/obj/machinery/ai_powersupply/New(mob/living/silicon/ai/ai=null)
	powered_ai = ai
	if(isnull(powered_ai))
		qdel(src)
		return

	loc = powered_ai.loc
	use_power(1) // Just incase we need to wake up the power system.

	..()

/obj/machinery/ai_powersupply/process()
	if(!powered_ai || powered_ai.stat & DEAD)
		qdel(src)
		return
	if(!powered_ai.anchored)
		loc = powered_ai.loc
		change_power_mode(NO_POWER_USE)
	if(powered_ai.anchored)
		change_power_mode(ACTIVE_POWER_USE)

/mob/living/silicon/ai/proc/pick_icon()
	set category = "Команды ИИ"
	set name = "Поставить дисплей ядра ИИ"
	if(stat || aiRestorePowerRoutine)
		return
	if(!custom_sprite) //Check to see if custom sprite time, checking the appopriate file to change a var
		if(ckey in GLOB.configuration.custom_sprites.ai_core_ckeys)
			custom_sprite = TRUE

	var/display_choices = list(
		"Monochrome",
		"Blue",
		"Clown",
		"Inverted",
		"Text",
		"Smiley",
		"Angry",
		"Dorf",
		"Matrix",
		"Bliss",
		"Firewall",
		"Green",
		"Red",
		"Static",
		"Triumvirate",
		"Triumvirate Static",
		"Red October",
		"Sparkles",
		"ANIMA",
		"President",
		"NT",
		"NT2",
		"Rainbow",
		"Angel",
		"Heartline",
		"Hades",
		"Helios",
		"Syndicat Meow",
		"Too Deep",
		"Goon",
		"Murica",
		"Fuzzy",
		"Glitchman",
		"House",
		"Database",
		"Alien",
		"Tiger",
		"Fox",
		"Vox",
		"Lizard",
		"Dark Matter",
		"Cheese",
		"Rainbow Slime",
		"Void Donut",
		"NAD Burn",
		"Borb",
		"Bee",
		"Catamari"
		)
	if(custom_sprite)
		display_choices += "Custom"

		//if(icon_state == initial(icon_state))
	var/icontype = ""
	icontype = input("Выберите иконку!", "ИИ", null, null) in display_choices
	icon = 'icons/mob/ai.dmi'	//reset this in case we were on a custom sprite and want to change to a standard one
	switch(icontype)
		if("Custom")
			icon = 'icons/mob/custom_synthetic/custom-synthetic.dmi'	//set this here so we can use the custom_sprite
			icon_state = "[ckey]-ai"
		if("Clown")
			icon_state = "ai-clown"
		if("Monochrome")
			icon_state = "ai-mono"
		if("Inverted")
			icon_state = "ai-u"
		if("Firewall")
			icon_state = "ai-magma"
		if("Green")
			icon_state = "ai-weird"
		if("Red")
			icon_state = "ai-red"
		if("Static")
			icon_state = "ai-static"
		if("Text")
			icon_state = "ai-text"
		if("Smiley")
			icon_state = "ai-smiley"
		if("Matrix")
			icon_state = "ai-matrix"
		if("Angry")
			icon_state = "ai-angryface"
		if("Dorf")
			icon_state = "ai-dorf"
		if("Bliss")
			icon_state = "ai-bliss"
		if("Triumvirate")
			icon_state = "ai-triumvirate"
		if("Triumvirate Static")
			icon_state = "ai-triumvirate-malf"
		if("Red October")
			icon_state = "ai-redoctober"
		if("Sparkles")
			icon_state = "ai-sparkles"
		if("ANIMA")
			icon_state = "ai-anima"
		if("President")
			icon_state = "ai-president"
		if("NT")
			icon_state = "ai-nt"
		if("NT2")
			icon_state = "ai-nanotrasen"
		if("Rainbow")
			icon_state = "ai-rainbow"
		if("Angel")
			icon_state = "ai-angel"
		if("Heartline")
			icon_state = "ai-heartline"
		if("Hades")
			icon_state = "ai-hades"
		if("Helios")
			icon_state = "ai-helios"
		if("Syndicat Meow")
			icon_state = "ai-syndicatmeow"
		if("Too Deep")
			icon_state = "ai-toodeep"
		if("Goon")
			icon_state = "ai-goon"
		if("Murica")
			icon_state = "ai-murica"
		if("Fuzzy")
			icon_state = "ai-fuzz"
		if("Glitchman")
			icon_state = "ai-glitchman"
		if("House")
			icon_state = "ai-house"
		if("Database")
			icon_state = "ai-database"
		if("Alien")
			icon_state = "ai-alien"
		if("Tiger")
			icon_state = "ai-tiger"
		if("Fox")
			icon_state = "ai-fox"
		if("Vox")
			icon_state = "ai-vox"
		if("Lizard")
			icon_state = "ai-liz"
		if("Dark Matter")
			icon_state = "ai-darkmatter"
		if("Cheese")
			icon_state = "ai-cheese"
		if("Rainbow Slime")
			icon_state = "ai-rainbowslime"
		if("Void Donut")
			icon_state = "ai-voiddonut"
		if("NAD Burn")
			icon_state = "ai-nadburn"
		if("Borb")
			icon_state = "ai-borb"
		if("Bee")
			icon_state = "ai-bee"
		if("Catamari")
			icon_state = "ai-catamari"
		else
			icon_state = "ai"

	if(istype(loc, /obj/item/aicard/))
		var/obj/item/aicard/AIC = loc
		AIC.update_icon(UPDATE_OVERLAYS)

// this verb lets the ai see the stations manifest
/mob/living/silicon/ai/proc/ai_roster()
	set name = "Показать манифест"
	set category = "Команды ИИ"
	show_station_manifest()

/mob/living/silicon/ai/proc/ai_announcement_text()
	set category = "Команды ИИ"
	set name = "Сделать станционное оповещение"

	if(check_unable(AI_CHECK_WIRELESS | AI_CHECK_RADIO))
		return

	if(world.time < next_text_announcement)
		to_chat(src, "<span class='warning'>Please allow one minute to pass between announcements.</span>")
		return

	var/input = input(usr, "Напишите сообщение для экипажа.", "Оповещение ИИ") as message|null
	if(!input)
		return

	if(check_unable(AI_CHECK_WIRELESS | AI_CHECK_RADIO))
		return

	announcer.Announce(input)
	next_text_announcement = world.time + TEXT_ANNOUNCEMENT_COOLDOWN

/mob/living/silicon/ai/proc/ai_call_shuttle()
	set name = "Вызов эвакуационного шаттла"
	set category = "Команды ИИ"

	if(check_unable(AI_CHECK_WIRELESS))
		return

	var/input = input("Пожалуйста, напишите причину для вызова шаттла.", "Причина вызова Шаттла.") as null|message
	if(!input || stat)
		return

	if(check_unable(AI_CHECK_WIRELESS))
		return

	call_shuttle_proc(src, input)

	return

/mob/living/silicon/ai/proc/ai_cancel_call()
	set name = "Отзыв эвакуационного шаттла"
	set category = "Команды ИИ"

	if(check_unable(AI_CHECK_WIRELESS))
		return

	var/confirm = alert("Вы уверены, что хотите отозвать шаттл?", "Потверждение отзыва шаттла", "Да", "Нет")

	if(check_unable(AI_CHECK_WIRELESS))
		return

	if(confirm == "Да")
		cancel_call_proc(src)

/mob/living/silicon/ai/cancel_camera()
	view_core()

/mob/living/silicon/ai/verb/toggle_anchor()
	set category = "Команды ИИ"
	set name = "Переключить прикручивание к полу"

	if(!isturf(loc)) // if their location isn't a turf
		return // stop

	if(anchored)
		anchored = FALSE
	else
		anchored = TRUE

	to_chat(src, "[anchored ? "<b>Вы теперь прикручены.</b>" : "<b> Вы теперь откручены.</b>"]")


/mob/living/silicon/ai/proc/announcement()
	set name = "Оповещение"
	set desc = "Сделайте звуковое оповещение посредством слияния слов в предложения."
	set category = "Команды ИИ"

	if(check_unable(AI_CHECK_WIRELESS | AI_CHECK_RADIO))
		return

	ai_announcement()

/mob/living/silicon/ai/check_eye(mob/user)
	if(!current)
		return null
	user.reset_perspective(current)
	return TRUE

/mob/living/silicon/ai/blob_act(obj/structure/blob/B)
	if(stat != DEAD)
		adjustBruteLoss(60)
		updatehealth()
		return 1
	return 0

/mob/living/silicon/ai/restrained()
	return FALSE

/mob/living/silicon/ai/emp_act(severity)
	..()
	if(prob(30))
		switch(pick(1,2))
			if(1)
				view_core()
			if(2)
				ai_call_shuttle()

/mob/living/silicon/ai/ex_act(severity)
	..()

	switch(severity)
		if(1.0)
			gib()
		if(2.0)
			if(stat != 2)
				adjustBruteLoss(60)
				adjustFireLoss(60)
		if(3.0)
			if(stat != 2)
				adjustBruteLoss(30)

	return


/mob/living/silicon/ai/Topic(href, href_list)
	if(usr != src)
		return
	..()
	if(href_list["mach_close"])
		if(href_list["mach_close"] == "aialerts")
			viewalerts = FALSE
		var/t1 = "window=[href_list["mach_close"]]"
		unset_machine()
		src << browse(null, t1)
	if(href_list["switchcamera"])
		switchCamera(locate(href_list["switchcamera"]) in GLOB.cameranet.cameras)
	if(href_list["showalerts"])
		ai_alerts()
	if(href_list["show_paper"])
		if(last_paper_seen)
			src << browse(last_paper_seen, "window=show_paper")
	//Carn: holopad requests
	if(href_list["jumptoholopad"])
		var/obj/machinery/hologram/holopad/H = locate(href_list["jumptoholopad"])
		if(stat == CONSCIOUS)
			if(H)
				H.attack_ai(src) //may as well recycle
			else
				to_chat(src, "<span class='notice'>Невозможно обнаружить голопад.</span>")

	if(href_list["say_word"])
		play_vox_word(href_list["say_word"], null, src)
		return

	if(href_list["track"])
		var/mob/living/target = locate(href_list["track"]) in GLOB.mob_list
		if(istype(target) && target.can_track())
			ai_actual_track(target)
		else
			to_chat(src, "<span class='warning'>Цель находится вне зоны камер.</span>")
		return

	if(href_list["trackbot"])
		var/mob/living/simple_animal/bot/target = locate(href_list["trackbot"]) in GLOB.bots_list
		if(istype(target))
			ai_actual_track(target)
		else
			to_chat(src, "<span class='warning'>Цель находится вне зоны камер.</span>")
		return

	if(href_list["callbot"]) //Command a bot to move to a selected location.
		Bot = locate(href_list["callbot"]) in GLOB.bots_list
		if(!Bot || Bot.remote_disabled || control_disabled)
			return //True if there is no bot found, the bot is manually emagged, or the AI is carded with wireless off.
		waypoint_mode = TRUE
		to_chat(src, "<span class='notice'>Поставьте беспрепятственную точку назначения.</span>")
		return

	if(href_list["interface"]) //Remotely connect to a bot!
		Bot = locate(href_list["interface"]) in GLOB.bots_list
		if(!Bot || Bot.remote_disabled || control_disabled)
			return
		Bot.attack_ai(src)

	if(href_list["botrefresh"]) //Refreshes the bot control panel.
		botcall()
		return

	if(href_list["ai_take_control"]) //Mech domination

		var/obj/mecha/M = locate(href_list["ai_take_control"])

		if(!M)
			return

		var/mech_has_controlbeacon = FALSE
		for(var/obj/item/mecha_parts/mecha_tracking/ai_control/A in M.trackers)
			mech_has_controlbeacon = TRUE
			break
		if(!can_dominate_mechs && !mech_has_controlbeacon)
			message_admins("Warning: possible href exploit by [key_name(usr)] - attempted control of a mecha without can_dominate_mechs or a control beacon in the mech.")
			log_debug("Warning: possible href exploit by [key_name(usr)] - attempted control of a mecha without can_dominate_mechs or a control beacon in the mech.")
			return

		if(controlled_mech)
			to_chat(src, "<span class='warning'>Вы уже загружены в портативный компьютер!</span>")
			return
		if(!GLOB.cameranet.checkCameraVis(M))
			to_chat(src, "<span class='warning'>Экзокостюм больше не в зоне покрытия камер.</span>")
			return
		if(lacks_power())
			to_chat(src, "<span class='warning'>Вы разряжены!</span>")
			return
		if(!isturf(loc))
			to_chat(src, "<span class='warning'>Вы не в ядре!</span>")
			return
		if(M)
			M.transfer_ai(AI_MECH_HACK, src, usr) //Called om the mech itself.

	else if(href_list["open"])
		var/mob/target = locate(href_list["open"]) in GLOB.mob_list
		if(target)
			open_nearest_door(target)

/mob/living/silicon/ai/bullet_act(obj/item/projectile/Proj)
	..(Proj)
	return 2

/mob/living/silicon/ai/reset_perspective(atom/A)
	if(camera_light_on)
		light_cameras()
	if(istype(A, /obj/machinery/camera))
		current = A

	. = ..()
	if(.)
		if(!A && isturf(loc) && eyeobj)
			client.eye = eyeobj
			client.perspective = MOB_PERSPECTIVE
			eyeobj.get_remote_view_fullscreens(src)

/mob/living/silicon/ai/proc/botcall()
	set category = "Команды ИИ"
	set name = "Управление роботами"
	set desc = "Удалённый контроль роботов."
	if(stat == 2)
		to_chat(src, "<span class='danger'>Критическая ошибка. Система не работает.</span>")
		return

	if(check_unable(AI_CHECK_WIRELESS | AI_CHECK_RADIO))
		return

	var/d
	var/area/bot_area
	d += "<A HREF=?src=[UID()];botrefresh=\ref[Bot]>Query network status</A><br>"
	d += "<table width='100%'><tr><td width='40%'><h3>Имя</h3></td><td width='20%'><h3>Статус</h3></td><td width='30%'><h3>Место</h3></td><td width='10%'><h3>Control</h3></td></tr>"

	for(var/mob/living/simple_animal/bot/Bot in GLOB.bots_list)
		if(is_ai_allowed(Bot.z) && !Bot.remote_disabled) //Only non-emagged bots on the allowed Z-level are detected!
			bot_area = get_area(Bot)
			d += "<tr><td width='30%'>[Bot.hacked ? "<span class='bad'>(!) </span>[Bot.name]" : Bot.name] ([Bot.model])</td>"
			//If the bot is on, it will display the bot's current mode status. If the bot is not mode, it will just report "Idle". "Inactive if it is not on at all.
			d += "<td width='20%'>[Bot.on ? "[Bot.mode ? "<span class='average'>[ Bot.mode_name[Bot.mode] ]</span>": "<span class='good'>Idle</span>"]" : "<span class='bad'>Неактивен</span>"]</td>"
			d += "<td width='30%'>[bot_area.name]</td>"
			d += "<td width='10%'><A HREF=?src=[UID()];interface=\ref[Bot]>Interface</A></td>"
			d += "<td width='10%'><A HREF=?src=[UID()];callbot=\ref[Bot]>Call</A></td>"
			d += "</tr>"
			d = format_text(d)

	var/datum/browser/popup = new(src, "botcall", "Удалённое управление роботами", 700, 400)
	popup.set_content(d)
	popup.open()

/mob/living/silicon/ai/proc/set_waypoint(atom/A)
	var/turf/turf_check = get_turf(A)
		//The target must be in view of a camera or near the core.
	if(turf_check in range(get_turf(src)))
		call_bot(turf_check)
	else if(GLOB.cameranet && GLOB.cameranet.checkTurfVis(turf_check))
		call_bot(turf_check)
	else
		to_chat(src, "<span class='danger'>Выбранное место нельзя увидеть.</span>")

/mob/living/silicon/ai/proc/call_bot(turf/waypoint)

	if(!Bot)
		return

	if(Bot.calling_ai && Bot.calling_ai != src) //Prevents an override if another AI is controlling this bot.
		to_chat(src, "<span class='danger'>Ошибка интерфейса. Бот уже используется.</span>")
		return

	Bot.call_bot(src, waypoint)

/mob/living/silicon/ai/alarm_triggered(src, class, area/A, list/O, obj/alarmsource)
	if(!(class in alarms_listend_for))
		return
	if(alarmsource.z != z)
		return
	if(stat == DEAD)
		return TRUE
	if(O)
		var/obj/machinery/camera/C = locateUID(O[1])
		if(O.len == 1 && !QDELETED(C) && C.can_use())
			queueAlarm("--- Тревога типа [class] обнаружена в [A.name]! (<A HREF=?src=[UID()];switchcamera=[O[1]]>[C.c_tag]</A>)", class)
		else if(O && O.len)
			var/foo = 0
			var/dat2 = ""
			for(var/thing in O)
				var/obj/machinery/camera/I = locateUID(thing)
				if(!QDELETED(I))
					dat2 += "[(!foo) ? "" : " | "]<A HREF=?src=[UID()];switchcamera=[thing]>[I.c_tag]</A>" //I'm not fixing this shit...
					foo = 1
			queueAlarm(text ("--- Тревога типа [] обнаружена в []! ([])", class, A.name, dat2), class)
		else
			queueAlarm(text("--- Тревога типа [] обнаружена в []! (Нет камеры)", class, A.name), class)
	else
		queueAlarm(text("--- Тревога типа [] обнаружена в []! (Нет камеры)", class, A.name), class)
	if(viewalerts)
		ai_alerts()

/mob/living/silicon/ai/alarm_cancelled(src, class, area/A, obj/origin, cleared)
	if(cleared)
		if(!(class in alarms_listend_for))
			return
		if(origin.z != z)
			return
		queueAlarm("--- Тревога типа [class] в [A.name] была устранена.", class, 0)
		if(viewalerts)
			ai_alerts()

/mob/living/silicon/ai/proc/switchCamera(obj/machinery/camera/C)

	if(!tracking)
		cameraFollow = null

	if(QDELETED(C) || stat == DEAD) //C.can_use())
		return FALSE

	if(!eyeobj)
		view_core()
		return
	// ok, we're alive, camera is good and in our network...
	eyeobj.setLoc(get_turf(C))
	//machine = src

	return TRUE

//Replaces /mob/living/silicon/ai/verb/change_network() in ai.dm & camera.dm
//Adds in /mob/living/silicon/ai/proc/ai_network_change() instead
//Addition by Mord_Sith to define AI's network change ability
/mob/living/silicon/ai/proc/ai_network_change()
	set category = "Команды ИИ"
	set name = "Переключение сети"
	unset_machine()
	var/cameralist[0]

	if(check_unable())
		return

	if(usr.stat == 2)
		to_chat(usr, "Мы не можете сменить сеть камер поскольку вы мертвы!")
		return

	var/mob/living/silicon/ai/U = usr

	for(var/obj/machinery/camera/C in GLOB.cameranet.cameras)
		if(!C.can_use())
			continue

		var/list/tempnetwork = difflist(C.network,GLOB.restricted_camera_networks,1)
		if(tempnetwork.len)
			for(var/i in tempnetwork)
				cameralist[i] = i
	var/old_network = network
	network = tgui_input_list(U, "На какую сеть камер вы бы хотели переключиться?", "Переключение сети", cameralist)

	if(check_unable())
		return

	if(!U.eyeobj)
		U.view_core()
		return

	if(isnull(network))
		network = old_network // If nothing is selected
	else
		for(var/obj/machinery/camera/C in GLOB.cameranet.cameras)
			if(!C.can_use())
				continue
			if(network in C.network)
				U.eyeobj.setLoc(get_turf(C))
				break
	to_chat(src, "<span class='notice'>Переключились на сеть камер [network].</span>")
//End of code by Mord_Sith

/mob/living/silicon/ai/proc/ai_statuschange()
	set category = "Команды ИИ"
	set name = "Эмоция ИИ"

	if(usr.stat == 2)
		to_chat(usr, "Вы не можете сменить эмоцию поскольку вы мертвы!")
		return

	if(check_unable())
		return

	var/list/ai_emotions = list("Very Happy", "Happy", "Neutral", "Unsure", "Confused", "Sad", "BSOD", "Blank", "Problems?", "Awesome", "Facepalm", "Friend Computer")
	var/emote = input("Пожалуйста, выберите эмоцию!", "Эмоция ИИ", null, null) in ai_emotions

	if(check_unable())
		return

	for(var/obj/machinery/ai_status_display/AISD as anything in GLOB.ai_displays) //change status
		AISD.emotion = emote
		AISD.update_icon()

// I would love to scope this locally to the AI class, however its used by holopads as well
// I wish we had nice OOP -aa07
/proc/getHologramIcon(icon/A, safety = TRUE) // If safety is on, a new icon is not created.
	var/icon/flat_icon = safety ? A : new(A) // Has to be a new icon to not constantly change the same icon.
	var/icon/alpha_mask
	flat_icon.ColorTone(rgb(125,180,225)) // Let's make it bluish.
	flat_icon.ChangeOpacity(0.5) // Make it half transparent.

	if(A.Height() == 64)
		alpha_mask = new('icons/mob/ancient_machine.dmi', "scanline2") //Scaline for tall icons.
	else
		alpha_mask = new('icons/effects/effects.dmi', "scanline") //Scanline effect.
	flat_icon.AddAlphaMask(alpha_mask) //Finally, let's mix in a distortion effect.

	return flat_icon


//I am the icon meister. Bow fefore me.	//>fefore
/mob/living/silicon/ai/proc/ai_hologram_change()
	set name = "Смена голограммы"
	set desc = "Меняет стандартную голограмму ИИ на что-то другое."
	set category = "Команды ИИ"

	if(check_unable())
		return
	if(!custom_hologram)
		if(ckey in GLOB.configuration.custom_sprites.ai_hologram_ckeys)
			custom_hologram = TRUE

	var/input
	switch(alert("Хотите выбрать голограмму на основе члена экипажа, животного или переключиться на уникальный аватар?",,"Crew Member","Unique","Animal"))
		if("Crew Member")
			var/personnel_list[] = list()

			for(var/datum/data/record/t in GLOB.data_core.general)//Look in data core general.
				personnel_list["[t.fields["name"]]: [t.fields["rank"]]"] = t.fields["photo"]//Pull names, rank, and id photo.

			if(personnel_list.len)
				input = tgui_input_list(usr, "Выберите члена экипажа", "Смена голограммы", personnel_list)
				var/icon/character_icon = personnel_list[input]
				if(character_icon)
					qdel(holo_icon)//Clear old icon so we're not storing it in memory.
					holo_icon = getHologramIcon(icon(character_icon))
			else
				alert("Подходящих записей не обнаружено. Отменяем.")

		if("Animal")
			var/icon_list[] = list(
			"Bear",
			"Carp",
			"Chicken",
			"Corgi",
			"Cow",
			"Crab",
			"Deer",
			"Fox",
			"Goat",
			"Goose",
			"Kitten",
			"Kitten2",
			"Pig",
			"Poly",
			"Pug",
			"Seal",
			"Spider",
			"Turkey",
			"Shantak",
			"Bunny",
			"Hellhound",
			"Lightgeist",
			"Cockroach",
			"Mecha-Cat",
			"Mecha-Fairy",
			"Mecha-Fox",
			"Mecha-Monkey",
			"Mecha-Mouse",
			"Mecha-Snake",
			"Roller-Mouse",
			"Roller-Monkey"
			)

			input = tgui_input_list(usr, "Пожалуйста выберите голограмму", "Смена голограммы", icon_list)
			if(input)
				qdel(holo_icon)
				switch(input)
					if("Bear")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi',"bear"))
					if("Carp")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi',"carp"))
					if("Chicken")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi',"chicken_brown"))
					if("Corgi")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi',"corgi"))
					if("Cow")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi',"cow"))
					if("Crab")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi',"crab"))
					if("Deer")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi',"deer"))
					if("Fox")
						holo_icon = getHologramIcon(icon('icons/mob/pets.dmi',"fox"))
					if("Goat")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi',"goat"))
					if("Goose")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi',"goose"))
					if("Kitten")
						holo_icon = getHologramIcon(icon('icons/mob/pets.dmi',"cat"))
					if("Kitten2")
						holo_icon = getHologramIcon(icon('icons/mob/pets.dmi',"cat2"))
					if("Pig")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi',"pig"))
					if("Poly")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi',"parrot_fly"))
					if("Pug")
						holo_icon = getHologramIcon(icon('icons/mob/pets.dmi',"pug"))
					if("Seal")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi',"seal"))
					if("Spider")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi',"guard"))
					if("Turkey")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi',"turkey"))
					if("Shantak")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi',"shantak"))
					if("Bunny")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi',"m_bunny"))
					if("Hellhound")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi',"hellhound"))
					if("Lightgeist")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi',"lightgeist"))
					if("Cockroach")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi',"cockroach"))
					if("Mecha-Cat")
						holo_icon = getHologramIcon(icon('icons/mob/pai.dmi',"cat"))
					if("Mecha-Fairy")
						holo_icon = getHologramIcon(icon('icons/mob/pai.dmi',"fairy"))
					if("Mecha-Fox")
						holo_icon = getHologramIcon(icon('icons/mob/pai.dmi',"fox"))
					if("Mecha-Monkey")
						holo_icon = getHologramIcon(icon('icons/mob/pai.dmi',"monkey"))
					if("Mecha-Mouse")
						holo_icon = getHologramIcon(icon('icons/mob/pai.dmi',"mouse"))
					if("Mecha-Snake")
						holo_icon = getHologramIcon(icon('icons/mob/pai.dmi',"snake"))
					if("Roller-Mouse")
						holo_icon = getHologramIcon(icon('icons/mob/robots.dmi',"mk2"))
					if("Roller-Monkey")
						holo_icon = getHologramIcon(icon('icons/mob/robots.dmi',"mk3"))

		else
			var/icon_list[] = list(
			"default",
			"floating face",
			"xeno queen",
			"eldritch",
			"ancient machine",
			"angel",
			"borb",
			"biggest fan",
			"cloudkat",
			"donut",
			"frost phoenix",
			"engi bot",
			"drone",
			"boxbot"
			)
			if(custom_hologram) //insert custom hologram
				icon_list.Add("custom")

			input = tgui_input_list(usr, "Пожалуйста, выберите голограмму", "Смена голограммы", icon_list)
			if(input)
				qdel(holo_icon)
				switch(input)
					if("default")
						holo_icon = getHologramIcon(icon('icons/mob/ai.dmi',"holo1"))
					if("floating face")
						holo_icon = getHologramIcon(icon('icons/mob/ai.dmi',"holo2"))
					if("xeno queen")
						holo_icon = getHologramIcon(icon('icons/mob/ai.dmi',"holo3"))
					if("eldritch")
						holo_icon = getHologramIcon(icon('icons/mob/ai.dmi',"holo4"))
					if("angel")
						holo_icon = getHologramIcon(icon('icons/mob/ai.dmi',"holo-angel"))
					if("borb")
						holo_icon = getHologramIcon(icon('icons/mob/ai.dmi',"holo-borb"))
					if("biggest fan")
						holo_icon = getHologramIcon(icon('icons/mob/ai.dmi',"holo-biggestfan"))
					if("cloudkat")
						holo_icon = getHologramIcon(icon('icons/mob/ai.dmi',"holo-cloudkat"))
					if("donut")
						holo_icon = getHologramIcon(icon('icons/mob/ai.dmi',"holo-donut"))
					if("frost phoenix")
						holo_icon = getHologramIcon(icon('icons/mob/ai.dmi',"holo-frostphoenix"))
					if("engi bot")
						holo_icon = getHologramIcon(icon('icons/mob/hivebot.dmi',"EngBot"))
					if("drone")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi',"drone0"))
					if("boxbot")
						holo_icon = getHologramIcon(icon('icons/mob/pai.dmi',"boxbot"))
					if("ancient machine")
						holo_icon = getHologramIcon(icon('icons/mob/ancient_machine.dmi', "ancient_machine"))
					if("custom")
						if("[ckey]-ai-holo" in icon_states('icons/mob/custom_synthetic/custom-synthetic.dmi'))
							holo_icon = getHologramIcon(icon('icons/mob/custom_synthetic/custom-synthetic.dmi', "[ckey]-ai-holo"))
						else if("[ckey]-ai-holo" in icon_states('icons/mob/custom_synthetic/custom-synthetic64.dmi'))
							holo_icon = getHologramIcon(icon('icons/mob/custom_synthetic/custom-synthetic64.dmi', "[ckey]-ai-holo"))
						else
							holo_icon = getHologramIcon(icon('icons/mob/ai.dmi',"holo1"))

	return


//Toggles the luminosity and applies it by re-entereing the camera.
/mob/living/silicon/ai/proc/toggle_camera_light()
	set name = "Переключение света в камерах"
	set desc = "Переключает свет в камерах на станции."
	set category = "Команды ИИ"

	if(stat != CONSCIOUS)
		return

	camera_light_on = !camera_light_on

	if(!camera_light_on)
		to_chat(src, "Свет в камерах отключён.")

		for(var/obj/machinery/camera/C in lit_cameras)
			C.set_light(0)
			lit_cameras = list()

		return

	light_cameras()

	to_chat(src, "Свет в камерах включён.")

/mob/living/silicon/ai/proc/set_syndie_radio()
	if(aiRadio)
		aiRadio.make_syndie()

/mob/living/silicon/ai/proc/sensor_mode()
	set name = "Поставить аугментацию сенсоров"
	set desc = "Аугрментируйте визуальную информацию с помощью сенсоров."
	set category = "Команды ИИ"
	toggle_sensor_mode()

/mob/living/silicon/ai/proc/arrivals_announcement()
	set name = "Переключить оповещение о прибытии"
	set desc = "Включает или выключает оповещение о новых членах экипажа."
	set category = "Команды ИИ"
	announce_arrivals = !announce_arrivals
	to_chat(usr, "Система оповещения о прибытии [announce_arrivals ? "включена" : "отключена"]")

/mob/living/silicon/ai/proc/change_arrival_message()
	set name = "Поставить сообщение прибытия"
	set desc = "Меняет передоваемое сообщение при прибытии нового члена экипажа на станцию."
	set category = "Команды ИИ"

	var/newmsg = clean_input("Какое сообщение вы хотите поставить? Список переменных: $name, $rank, $species, $gender, $age", "Смена сообщения прибытия", arrivalmsg)
	if(!newmsg)
		return
	newmsg = html_decode(newmsg) // This feels a bit redundant, but sanitisation is (probably) important.
	if(newmsg != arrivalmsg)
		arrivalmsg = newmsg
		to_chat(usr, "Сообщение о прибытии было успешно изменено.")

// Handled camera lighting, when toggled.
// It will get the nearest camera from the eyeobj, lighting it.

/mob/living/silicon/ai/proc/light_cameras()
	var/list/obj/machinery/camera/add = list()
	var/list/obj/machinery/camera/remove = list()
	var/list/obj/machinery/camera/visible = list()
	for(var/datum/camerachunk/CC in eyeobj.visibleCameraChunks)
		for(var/obj/machinery/camera/C in CC.active_cameras)
			if(!C.can_use() || get_dist(C, eyeobj) > 7)
				continue
			visible |= C

	add = visible - lit_cameras
	remove = lit_cameras - visible

	for(var/obj/machinery/camera/C in remove)
		lit_cameras -= C //Removed from list before turning off the light so that it doesn't check the AI looking away.
		C.Togglelight(0)
	for(var/obj/machinery/camera/C in add)
		C.Togglelight(1)
		lit_cameras |= C


/mob/living/silicon/ai/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/wrench))
		if(anchored)
			user.visible_message("<span class='notice'>[user] начинает откручивать [src] от пола...</span>")
			if(!do_after(user, 40 * W.toolspeed, target = src))
				user.visible_message("<span class='notice'>[user] решает не откручивать [src].</span>")
				return
			user.visible_message("<span class='notice'> [user] закончил открутку [src]!</span>")
			anchored = FALSE
			return
		else
			user.visible_message("<span class='notice'>[user] начинает прикручивть [src] к полу...</span>")
			if(!do_after(user, 40 * W.toolspeed, target = src))
				user.visible_message("<span class='notice'>[user] решает не закручивать [src].</span>")
				return
			user.visible_message("<span class='notice'>[user] закончил закручивать [src]!</span>")
			anchored = TRUE
			return
	else
		return ..()

/mob/living/silicon/ai/welder_act()
	return

/mob/living/silicon/ai/proc/control_integrated_radio()
	set name = "Настройки гарнитуры"
	set desc = "Позволяет изменять настройки вашей гарнитуры."
	set category = "Команды ИИ"

	if(check_unable(AI_CHECK_RADIO))
		return

	to_chat(src, "Получаем доступ к настройкам передатчика...")
	if(aiRadio)
		aiRadio.interact(src)


/mob/living/silicon/ai/proc/check_unable(flags = 0)
	if(stat == DEAD)
		to_chat(src, "<span class='warning'>Вы мертвы!</span>")
		return TRUE

	if(lacks_power())
		to_chat(src, "<span class='warning'>Отказ систем питания!</span>")
		return TRUE

	if((flags & AI_CHECK_WIRELESS) && control_disabled)
		to_chat(src, "<span class='warning'>Удалённое управление отключено!</span>")
		return TRUE
	if((flags & AI_CHECK_RADIO) && aiRadio.disabledAi)
		to_chat(src, "<span class='warning'>Системная ошибка: Передатчик отключён!</span>")
		return TRUE
	return FALSE

/mob/living/silicon/ai/proc/is_in_chassis()
	return isturf(loc)

/mob/living/silicon/ai/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(!..())
		return
	if(interaction == AI_TRANS_TO_CARD)//The only possible interaction. Upload AI mob to a card.
		if(!mind)
			to_chat(user, "<span class='warning'>Искусственный интеллект не обнаружен.</span>")//No more magical carding of empty cores, AI RETURN TO BODY!!!11
			return

		if(stat != DEAD)
			to_chat(user, "<span class='notice'>Начинается загрузка активного разума: пожалуйста, ожидайте.</span>")

			if(!do_after_once(user, 5 SECONDS, target = src) || !Adjacent(user))
				to_chat(user, "<span class='warning'>Перенос сознания отменён.</span>")
				return

		new /obj/structure/AIcore/deactivated(loc)//Spawns a deactivated terminal at AI location.
		aiRestorePowerRoutine = 0//So the AI initially has power.
		control_disabled = TRUE //Can't control things remotely if you're stuck in a card!
		aiRadio.disabledAi = TRUE //No talking on the built-in radio for you either!
		if(GetComponent(/datum/component/ducttape))
			QDEL_NULL(builtInCamera)
		forceMove(card) //Throw AI into the card.
		to_chat(src, "Вас загрузили на портативное устройство. Удалённое соединение с устройствами разорвано.")
		to_chat(user, "<span class='boldnotice'>Загрузка успешна</span>: [name] ([rand(1000,9999)].exe) удалён из терминала и перенесён в память устройства.")

/mob/living/silicon/ai/can_buckle()
	return FALSE

/mob/living/silicon/ai/switch_to_camera(obj/machinery/camera/C)
	if(!C.can_use() || !is_in_chassis())
		return FALSE

	eyeobj.setLoc(get_turf(C))
	client.eye = eyeobj
	return TRUE


/mob/living/silicon/ai/proc/can_see(atom/A)
	if(isturf(loc)) //AI in core, check if on cameras
		//get_turf_pixel() is because APCs in maint aren't actually in view of the inner camera
		//apc_override is needed here because AIs use their own APC when depowered
		var/turf/T = isturf(A) ? A : get_turf_pixel(A)
		return (GLOB.cameranet && GLOB.cameranet.checkTurfVis(T)) || apc_override
	//AI is carded/shunted
	//view(src) returns nothing for carded/shunted AIs and they have x-ray vision so just use get_dist
	var/list/viewscale = getviewsize(client.view)
	return get_dist(src, A) <= max(viewscale[1]*0.5,viewscale[2]*0.5)

/mob/living/silicon/ai/proc/relay_speech(mob/living/M, list/message_pieces, verb)
	var/message = combine_message(message_pieces, verb, M)
	var/name_used = M.GetVoice()
	//This communication is imperfect because the holopad "filters" voices and is only designed to connect to the master only.
	var/rendered = "<i><span class='game say'>Переданная речь: <span class='name'>[name_used]</span> [message]</span></i>"
	if(client?.prefs.toggles2 & PREFTOGGLE_2_RUNECHAT)
		var/message_clean = combine_message(message_pieces, null, M)
		create_chat_message(locateUID(M.runechat_msg_location), message_clean)
	show_message(rendered, 2)

/mob/living/silicon/ai/proc/malfhacked(obj/machinery/power/apc/apc)
	malfhack = null
	malfhacking = null
	clear_alert("hackingapc")

	if(!istype(apc) || QDELETED(apc) || apc.stat & BROKEN)
		to_chat(src, "<span class='danger'>Взлом отменён. Указанный ЛКП больше не отмечен в энергосети станции.</span>")
		SEND_SOUND(src, sound('sound/machines/buzz-two.ogg'))
	else if(apc.aidisabled)
		to_chat(src, "<span class='danger'>Взлом отменён. [apc] больше не отвечает нашим системам.</span>")
		SEND_SOUND(src, sound('sound/machines/buzz-sigh.ogg'))
	else
		malf_picker.processing_time += 15

		apc.malfai = parent || src
		apc.malfhack = TRUE
		apc.locked = TRUE

		SEND_SOUND(src, sound('sound/machines/ding.ogg'))
		to_chat(src, "Взлом завершён. [apc] теперь под вашим контролем.")
		apc.update_icon()

/mob/living/silicon/ai/proc/add_malf_picker()
	to_chat(src, "В правом верхнем углу вы можете найти панель Сбойных модулей, в которой вы можете покупать различные способности, от улучшенной слежки до Устройства судного Дня, уничтожающего станцию.")
	to_chat(src, "Вы также способны взламывать ЛКП. Это даёт вам дополнительные очки на открытие способностей.  Минус в том, что взломанный ЛКП бросается в глаза экипажу при обнаружении. Взлом ЛКП занимает 1 минуту.")
	view_core() //A BYOND bug requires you to be viewing your core before your verbs update
	malf_picker = new /datum/module_picker
	modules_action = new(malf_picker)
	modules_action.Grant(src)

///Removes all malfunction-related /datum/action's from the target AI.
/mob/living/silicon/ai/proc/remove_malf_abilities()
	QDEL_NULL(modules_action)
	for(var/datum/AI_Module/AM in current_modules)
		for(var/datum/action/A in actions)
			if(istype(A, initial(AM.power_type)))
				qdel(A)

/mob/living/silicon/ai/proc/open_nearest_door(mob/living/target)
	if(!istype(target))
		return

	if(check_unable(AI_CHECK_WIRELESS))
		return

	if(target && target.can_track())
		var/obj/machinery/door/airlock/A = null

		var/dist = -1
		for(var/obj/machinery/door/airlock/D in range(3, target))
			if(!D.density)
				continue

			var/curr_dist = get_dist(D, target)

			if(dist < 0)
				dist = curr_dist
				A = D
			else if(dist > curr_dist)
				dist = curr_dist
				A = D

		if(istype(A))
			switch(alert(src, "Вы хотите открыть \ [A] для [target]?", "Doorknob_v2a.exe", "Да", "Нет"))
				if("Да")
					if(!A.density)
						to_chat(src, "<span class='notice'>Шлюз в [A] уже был открыт .</span>")
					else if(A.open_close(src))
						to_chat(src, "<span class='notice'>Вы открываете \ [A] для [target].</span>")
				else
					to_chat(src, "<span class='warning'>вы отклоняете запрос</span>")
		else
			to_chat(src, "<span class='warning'>Невозможно найти шлюз рядом [target].</span>")

	else
		to_chat(src, "<span class='warning'>Цель находится вне зоны покрытия камер.</span>")

/mob/living/silicon/ai/proc/camera_visibility(mob/camera/aiEye/moved_eye)
	GLOB.cameranet.visibility(moved_eye, client, all_eyes)

/mob/living/silicon/ai/handle_fire()
	return

/mob/living/silicon/ai/update_fire()
	return

/mob/living/silicon/ai/IgniteMob()
	return FALSE

/mob/living/silicon/ai/ExtinguishMob()
	return


/mob/living/silicon/ai/update_sight()
	if(!client)
		return

	if(stat == DEAD)
		grant_death_vision()
		return

	see_invisible = initial(see_invisible)
	see_in_dark = initial(see_in_dark)
	sight = initial(sight)
	lighting_alpha = initial(lighting_alpha)

	if(aiRestorePowerRoutine)
		sight = sight &~ SEE_TURFS
		sight = sight &~ SEE_MOBS
		sight = sight &~ SEE_OBJS
		see_in_dark = 0

	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_SIGHT)
	sync_lighting_plane_alpha()

/mob/living/silicon/ai/update_runechat_msg_location()
	if(istype(loc, /obj/item/aicard) || ismecha(loc))
		runechat_msg_location = loc.UID()
	else
		return ..()

/mob/living/silicon/ai/run_resist()
	if(!istype(loc, /obj/item/aicard))
		return..()

	var/obj/item/aicard/card = loc
	var/datum/component/ducttape/ducttapecomponent = card.GetComponent(/datum/component/ducttape)
	if(!ducttapecomponent)
		return
	to_chat(src, "<span class='notice'>The tiny fan that could begins to work against the tape to remove it.</span>") //Пока требуется пояснение, чё это такое. Карта с ИИ?
	if(!do_after(src, 2 MINUTES, target = card))
		return
	to_chat(src, "<span class='notice'>The tiny in built fan finally removes the tape!</span>") //
	ducttapecomponent.remove_tape(card, src)

//Stores the location of the AI to the value of stored_locations associated with location_number.
/mob/living/silicon/ai/proc/store_location(location_number)
	if(!isturf(eyeobj.loc)) //i.e., inside a mech or other shenanigans
		to_chat(src, "<span class='warning'>Вы не можете сохранить тут камеру!</span>")
		return FALSE

	stored_locations[location_number] = eyeobj.loc
	return TRUE

/mob/living/silicon/ai/ghostize(can_reenter_corpse)
	var/old_turf = get_turf(eyeobj)
	. = ..()
	if(isobserver(.))
		var/mob/dead/observer/ghost = .
		ghost.forceMove(old_turf)

#undef TEXT_ANNOUNCEMENT_COOLDOWN
