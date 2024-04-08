/******************** Requests Console ********************/
/** Originally written by errorage, updated by: Carn, needs more work though. I just added some security fixes */

//Request Console Department Types.
//For one console to be under multiple categories, you need to add the numbers with each other. For example, value of 6 will allow you to request supplies and relay info to that specific console.
#define RC_ASSIST (1<<0)		//Request Assistance
#define RC_SUPPLY (1<<1)		//Request Supplies
#define RC_INFO   (1<<2)		//Relay Info

//Request Console Screens
#define RCS_MAINMENU	0	// Main menu
#define RCS_RQSUPPLY	1	// Request supplies
#define RCS_RQASSIST	2	// Request assistance
#define RCS_SENDINFO	3	// Relay information
#define RCS_SENTPASS	4	// Message sent successfully
#define RCS_SENTFAIL	5	// Message sent unsuccessfully
#define RCS_VIEWMSGS	6	// View messages
#define RCS_MESSAUTH	7	// Authentication before sending
#define RCS_ANNOUNCE	8	// Send announcement
#define RCS_SHIPPING	9	// Print Shipping Labels/Packages
#define RCS_SHIP_LOG	10	// View Shipping Label Log
#define RCS_SECONDARY	11	// Request secodary goal

//Radio list. For a console to announce messages on a specific radio, it's "department" variable must be in the list below.
#define ENGI_ROLES list("Atmospherics", "Engineering", "Chief Engineer's Desk")
#define SEC_ROLES list("Warden", "Security", "Detective", "Head of Security's Desk")
#define MISC_ROLES list("Bar", "Chapel", "Kitchen", "Hydroponics", "Janitorial")
#define MED_ROLES list("Virology", "Chief Medical Officer's Desk", "Medbay")
#define COM_ROLES list("Blueshield", "NT Representative", "Head of Personnel's Desk", "Captain's Desk", "Bridge")
#define SCI_ROLES list("Robotics", "Science", "Research Director's Desk")
#define SUPPLY_ROLES list("Cargo Bay", "Mining Dock", "Mining Outpost", "Quartermaster's Desk")

GLOBAL_LIST_EMPTY(req_console_assistance)
GLOBAL_LIST_EMPTY(req_console_supplies)
GLOBAL_LIST_EMPTY(req_console_information)
GLOBAL_LIST_EMPTY(allRequestConsoles)

/obj/machinery/requests_console
	name = "Requests Console"
	desc = "Консоль, предназначанная для отправки запросов в другие отделы станции."
	anchored = TRUE
	icon = 'icons/obj/terminals.dmi'
	icon_state = "req_comp_off"
	max_integrity = 300
	armor = list(MELEE = 70, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 0, RAD = 0, FIRE = 90, ACID = 90)
	var/department = "Unknown" //The list of all departments on the station (Determined from this variable on each unit) Set this to the same thing if you want several consoles in one department
	var/list/message_log = list() //List of all messages
	var/departmentType = 0 		//Bitflag. Zero is reply-only. Map currently uses raw numbers instead of defines.
	var/newmessagepriority = RQ_NONEW_MESSAGES
	var/screen = RCS_MAINMENU
	var/silent = FALSE // set to TRUE for it not to beep all the time
	var/announcementConsole = FALSE
		// FALSE = This console cannot be used to send department announcements
		// TRUE = This console can send department announcementsf
	/// Will be set to TRUE when you authenticate yourself for announcements
	var/announceAuth = FALSE
	/// Will be set to TRUE when you authenticate yourself for requesting a secondary goal
	var/secondaryGoalAuth = FALSE
	/// Will contain the name of the person who verified it
	var/msgVerified = "Not verified"
	/// If a message is stamped, this will contain the stamp name
	var/msgStamped = "Not stamped"
	var/message = ""
	var/recipient = ""; //the department which will be receiving the message
	var/priority = -1 ; //Priority of the message being sent
	light_range = 0
	var/datum/announcer/announcer = new(config_type = /datum/announcement_configuration/requests_console)
	/// The ID card of the person requesting a secondary goal.
	var/goalRequester
	var/list/shipping_log = list()
	var/ship_tag_name = ""
	var/ship_tag_index = 0
	var/print_cooldown = 0	//cooldown on shipping label printer, stores the  in-game time of when the printer will next be ready
	var/obj/item/radio/Radio
	var/reminder_timer_id = TIMER_ID_NULL
	var/has_active_secondary_goal = FALSE

/obj/machinery/requests_console/power_change()
	if(!..())
		return
	if(stat & NOPOWER)
		set_light(0)
	else
		set_light(1, LIGHTING_MINIMUM_POWER)
	update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)

/obj/machinery/requests_console/update_overlays()
	. = ..()
	underlays.Cut()

	if(stat & NOPOWER)
		return

	. += "req_comp[newmessagepriority]"

	underlays += emissive_appearance(icon, "req_comp_lightmask")

/obj/machinery/requests_console/Initialize(mapload)
	Radio = new /obj/item/radio(src)
	Radio.listening = TRUE
	Radio.config(list("Engineering", "Medical", "Supply", "Command", "Science", "Service", "Security", "AI Private" = FALSE))
	Radio.follow_target = src
	. = ..()

	announcer.config.default_title = "Оповещение от [department]"

	name = "[department] Requests console"
	GLOB.allRequestConsoles += src
	if(departmentType & RC_ASSIST)
		GLOB.req_console_assistance |= department
	if(departmentType & RC_SUPPLY)
		GLOB.req_console_supplies |= department
	if(departmentType & RC_INFO)
		GLOB.req_console_information |= department

	update_icon()
	// NOT BOOLEAN. DO NOT CONVERT.
	set_light(1)

/obj/machinery/requests_console/Destroy()
	GLOB.allRequestConsoles -= src
	var/lastDeptRC = TRUE
	for(var/obj/machinery/requests_console/Console in GLOB.allRequestConsoles)
		if(Console.department == department)
			lastDeptRC = FALSE
			break
	if(lastDeptRC)
		if(departmentType & RC_ASSIST)
			GLOB.req_console_assistance -= department
		if(departmentType & RC_SUPPLY)
			GLOB.req_console_supplies -= department
		if(departmentType & RC_INFO)
			GLOB.req_console_information -= department
	QDEL_NULL(Radio)
	return ..()

/obj/machinery/requests_console/attack_ghost(user as mob)
	if(stat & NOPOWER)
		return

	ui_interact(user)

/obj/machinery/requests_console/attack_hand(user as mob)
	if(..(user))
		return

	ui_interact(user)

/obj/machinery/requests_console/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/requests_console/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RequestConsole", "Консоль запросов [department]")
		ui.open()

/obj/machinery/requests_console/ui_data(mob/user)
	var/list/data = list()

	data["department"] = department
	data["screen"] = screen
	data["message_log"] = message_log
	data["newmessagepriority"] = newmessagepriority
	data["silent"] = silent
	data["announcementConsole"] = announcementConsole

	data["assist_dept"] = GLOB.req_console_assistance
	data["supply_dept"] = GLOB.req_console_supplies
	data["info_dept"]   = GLOB.req_console_information
	data["ship_dept"]	= GLOB.TAGGERLOCATIONS

	data["message"] = message
	data["recipient"] = recipient
	data["priortiy"] = priority
	data["msgStamped"] = msgStamped
	data["msgVerified"] = msgVerified
	data["announceAuth"] = announceAuth
	data["secondaryGoalAuth"] = secondaryGoalAuth
	data["secondaryGoalEnabled"] = !has_active_secondary_goal
	data["shipDest"] = ship_tag_name
	data["shipping_log"] = shipping_log

	return data

/obj/machinery/requests_console/ui_act(action, list/params)
	if(..())
		return

	add_fingerprint(usr)

	. = TRUE

	switch(action)
		if("writeInput")
			if(reject_bad_text(params["write"]))
				recipient = params["write"] //write contains the string of the receiving department's name

				var/new_message = tgui_input_text(usr, "Напишите своё сообщение:", "Ожидание ввода", encode = FALSE)
				if(new_message)
					message = new_message
					screen = RCS_MESSAUTH
					switch(params["priority"])
						if("1")
							priority = RQ_NORMALPRIORITY
						if("2")
							priority = RQ_HIGHPRIORITY
						else
							priority = RQ_NONEW_MESSAGES
				else
					reset_message(TRUE)

		if("writeAnnouncement")
			var/new_message = tgui_input_text(usr, "Напишите своё оповещение:", "Ожидание ввода", message, multiline = TRUE, encode = FALSE)
			if(new_message)
				message = new_message
			else
				reset_message(TRUE)

		if("sendAnnouncement")
			if(!announcementConsole)
				return
			announcer.Announce(message)
			reset_message(TRUE)

		if("requestSecondaryGoal")
			has_active_secondary_goal = check_for_active_secondary_goal(goalRequester)
			if(has_active_secondary_goal || !secondaryGoalAuth)
				return
			generate_secondary_goal(department, goalRequester, usr)
			reset_message(FALSE)
			view_messages()
			screen = RCS_VIEWMSGS

		if("department")
			if(send_requests_console_message(message, department, recipient, msgStamped, msgVerified, priority, Radio))
				screen = RCS_SENTPASS
			else
				screen = RCS_SENTFAIL
				atom_say("No server detected!")

		//Handle screen switching
		if("setScreen")
			// Ensures screen cant be set higher or lower than it should be
			var/tempScreen = round(clamp(text2num(params["setScreen"]), 0, 11), 1)
			if(tempScreen == RCS_ANNOUNCE && !announcementConsole)
				return
			if(tempScreen == RCS_VIEWMSGS)
				view_messages()
			if(tempScreen == RCS_MAINMENU)
				reset_message()
			if(tempScreen == RCS_SECONDARY)
				has_active_secondary_goal = check_for_active_secondary_goal(goalRequester)
			screen = tempScreen

		if("shipSelect")
			ship_tag_name = params["shipSelect"]
			ship_tag_index = GLOB.TAGGERLOCATIONS.Find(ship_tag_name)

		//Handle Shipping Label Printing
		if("printLabel")
			var/error_message
			if(!ship_tag_index)
				error_message = "Пожалуйста, выберите пункт назначения."
			else if(!msgVerified)
				error_message = "Пожалуйста, проверьте ID отправителя."
			else if(world.time < print_cooldown)
				error_message = "Пожалуйста, дайте принтеру время на подготовку следующей транспортировочной маркировки."
			if(error_message)
				atom_say("[error_message]")
				return
			print_label(ship_tag_name, ship_tag_index)
			shipping_log.Add(list(list("Этикетка напечатана для [ship_tag_name]", "[msgVerified]"))) // List in a list for passing into TGUI
			reset_message(TRUE)

		//Handle silencing the console
		if("toggleSilent")
			silent = !silent


/obj/machinery/requests_console/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/card/id))
		if(inoperable(MAINT))
			return
		if(screen == RCS_MESSAUTH)
			var/obj/item/card/id/T = I
			msgVerified = "Подтверждено [T.registered_name] ([T.assignment])"
			SStgui.update_uis(src)
		if(screen == RCS_ANNOUNCE)
			var/obj/item/card/id/ID = I
			if(ACCESS_RC_ANNOUNCE in ID.GetAccess())
				announceAuth = TRUE
				announcer.author = ID.assignment ? "[ID.assignment] [ID.registered_name]" : ID.registered_name
			else
				reset_message()
				to_chat(user, "<span class='warning'>У вас нет допуска на отправку оповещений.</span>")
			SStgui.update_uis(src)
		if(screen == RCS_SECONDARY)
			var/obj/item/card/id/ID = I
			if(ID)
				secondaryGoalAuth = TRUE
				goalRequester = ID
				has_active_secondary_goal = check_for_active_secondary_goal(goalRequester)
		if(screen == RCS_SHIPPING)
			var/obj/item/card/id/T = I
			msgVerified = "Отправитель подтверждён как [T.registered_name] ([T.assignment])"
			SStgui.update_uis(src)
	if(istype(I, /obj/item/stamp))
		if(inoperable(MAINT))
			return
		if(screen == RCS_MESSAUTH)
			var/obj/item/stamp/T = I
			msgStamped = "Проштамповано [T.name]"
			SStgui.update_uis(src)
	else
		return ..()

/obj/machinery/requests_console/proc/reset_message(mainmenu = FALSE)
	message = ""
	recipient = ""
	priority = RQ_NONEW_MESSAGES
	msgVerified = "Not verified"
	msgStamped = "Not stamped"
	announceAuth = FALSE
	secondaryGoalAuth = FALSE
	announcer.author = ""
	goalRequester = ""
	ship_tag_name = ""
	ship_tag_index = FALSE
	if(mainmenu)
		screen = RCS_MAINMENU

/obj/machinery/requests_console/proc/createMessage(source, title, message, priority, forced = FALSE, verified = "", stamped = "")
	var/linkedSender
	if(inoperable() && !forced)
		message_log.Add(list(list("Message lost due to console failure. Please contact [station_name()]'s system administrator or AI for technical assistance.")))
		return
	if(istype(source, /obj/machinery/requests_console))
		var/obj/machinery/requests_console/sender = source
		linkedSender = sender.department
	else
		linkedSender = source
	if(newmessagepriority < priority)
		newmessagepriority = priority
		update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)
	if(!silent)
		playsound(loc, 'sound/machines/twobeep.ogg', 50, TRUE)
		atom_say(title)
		if(reminder_timer_id == TIMER_ID_NULL)
			reminder_timer_id = addtimer(CALLBACK(src, PROC_REF(remind_unread_messages)), 5 MINUTES, TIMER_STOPPABLE | TIMER_LOOP)

	switch(priority)
		if(RQ_HIGHPRIORITY) // High
			message_log.Add(list(list("High Priority - From: [linkedSender]") + message + list(verified, stamped))) // List in a list for passing into TGUI
		else // Normal
			message_log.Add(list(list("From: [linkedSender]") + message + list(verified, stamped))) // List in a list for passing into TGUI
	set_light(2)

/obj/machinery/requests_console/proc/remind_unread_messages()
	if(reminder_timer_id == TIMER_ID_NULL)
		return

	if(newmessagepriority == RQ_NONEW_MESSAGES)
		deltimer(reminder_timer_id)
		reminder_timer_id = TIMER_ID_NULL
		return

	atom_say("Есть непрочитанные сообщения.")

/obj/machinery/requests_console/proc/print_label(tag_name, tag_index)
	var/obj/item/shippingPackage/sp = new /obj/item/shippingPackage(get_turf(src))
	sp.sortTag = tag_index
	sp.update_desc()
	print_cooldown = world.time + 600	//1 minute cooldown before you can print another label, but you can still configure the next one during this time

/obj/machinery/requests_console/proc/view_messages()
	for(var/obj/machinery/requests_console/Console in GLOB.allRequestConsoles)
		if(Console.department == department)
			Console.newmessagepriority = RQ_NONEW_MESSAGES
			Console.update_icon(UPDATE_OVERLAYS)
			Console.set_light(1)
			if(reminder_timer_id != TIMER_ID_NULL)
				deltimer(reminder_timer_id)
				reminder_timer_id = TIMER_ID_NULL

/obj/machinery/requests_console/proc/check_for_active_secondary_goal(obj/item/card/id/id)
	if(!istype(id))
		return FALSE
	for(var/datum/station_goal/secondary/goal in SSticker.mode.secondary_goals)
		if(goal.requester_name == id.registered_name && !goal.completed)
			return TRUE
	return FALSE

/proc/send_requests_console_message(message, sender, recipient, stamped, verified, priority, obj/item/radio/radio)
	if(!message)
		return
	var/found_message_server = FALSE
	for(var/M in GLOB.message_servers)
		var/obj/machinery/message_server/MS = M
		if(!MS.active)
			continue
		MS.send_rc_message(ckey(recipient), sender, message, stamped, verified, priority)
		found_message_server = TRUE

	if(!found_message_server)
		return FALSE

	if(!radio)
		return TRUE

	var/radiochannel = ""
	if(recipient in ENGI_ROLES)
		radiochannel = "Engineering"
	else if(recipient in SEC_ROLES)
		radiochannel = "Security"
	else if(recipient in MISC_ROLES)
		radiochannel = "Service"
	else if(recipient in MED_ROLES)
		radiochannel = "Medical"
	else if(recipient in COM_ROLES)
		radiochannel = "Command"
	else if(recipient in SCI_ROLES)
		radiochannel = "Science"
	else if(recipient == "AI")
		radiochannel = "AI Private"
	else if(recipient in SUPPLY_ROLES)
		radiochannel = "Supply"
	radio.autosay("Alert; a new message has been received from [sender]", "[recipient] Requests Console", "[radiochannel]")

	return TRUE

#undef RC_ASSIST
#undef RC_SUPPLY
#undef RC_INFO
#undef RCS_MAINMENU
#undef RCS_RQSUPPLY
#undef RCS_RQASSIST
#undef RCS_SENDINFO
#undef RCS_SENTPASS
#undef RCS_SENTFAIL
#undef RCS_VIEWMSGS
#undef RCS_MESSAUTH
#undef RCS_ANNOUNCE
#undef RCS_SHIPPING
#undef RCS_SHIP_LOG
#undef RCS_SECONDARY
#undef ENGI_ROLES
#undef SEC_ROLES
#undef MISC_ROLES
#undef MED_ROLES
#undef COM_ROLES
#undef SCI_ROLES
#undef SUPPLY_ROLES
