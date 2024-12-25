#define MAX_EFTPOS_CHARGE 250

/obj/item/eftpos
	name = "EFTPOS scanner"
	desc = "Swipe your ID card to make purchases electronically."
	icon = 'icons/obj/device.dmi'
	icon_state = "eftpos"
	w_class = WEIGHT_CLASS_SMALL
	/// Unique identifying name of this EFTPOS for transaction tracking in money accounts
	var/machine_name = ""
	/// Whether or not the EFTPOS is locked into a transaction
	var/transaction_locked = FALSE
	/// Did the transaction go through? Will reset back to FALSE after 5 seconds, used as a cooldown and indicator to consumer
	var/transaction_paid = FALSE
	/// Amount in space credits to charge card swiper
	var/transaction_amount = 0
	var/transaction_purpose = "Default charge"
	/// The pin number needed to changed settings on the EFTPOS
	var/access_code
	var/transaction_sound = 'sound/machines/chime.ogg'

	///linked money account database to this EFTPOS
	var/datum/money_account_database/main_station/account_database
	///Current money account the EFTPOS is depositing to
	var/datum/money_account/linked_account
	//
	var/obj/item/eftpos_hack_key/eftpos_sindy_key

/obj/item/eftpos/Initialize(mapload)
	machine_name = "EFTPOS #[rand(101, 999)]"
	access_code = rand(1000, 9999)
	reconnect_database()
	//linked account starts as service account by default
	linked_account = account_database.get_account_by_department(DEPARTMENT_SERVICE)
	print_reference()
	return ..()

/obj/item/eftpos/proc/reconnect_database()
	account_database = GLOB.station_money_database

/obj/item/eftpos/attack_self__legacy__attackchain(mob/user)
	ui_interact(user)

/obj/item/eftpos/attackby__legacy__attackchain(obj/O, mob/user, params)
	if(istype(O, /obj/item/card/id))
		//attempt to connect to a new db, and if that doesn't work then fail
		if(!account_database)
			reconnect_database()
		if(account_database)
			if(linked_account)
				scan_card(O, user)
				SStgui.update_uis(src)
			else
				to_chat(user, "[bicon(src)]<span class='warning'>Unable to connect to linked account.</span>")
		else
			to_chat(user, "[bicon(src)]<span class='warning'>Unable to connect to accounts database.</span>")
	if(istype(O, /obj/item/eftpos_hack_key))
		if(!eftpos_sindy_key)
			user.drop_item()
			O.loc = src
			eftpos_sindy_key = O
			user.show_message("<span class='notice'>You insert the hacking key in the terminal.</span>")
		else
			user.show_message("<span class='notice'>One hacking key is already in the terminal.</span>")
		//O.on_key_insert(O, user)

	else
		return ..()

/obj/item/eftpos/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/eftpos/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "EFTPOS", name)
		ui.open()

/obj/item/eftpos/ui_data(mob/user)
	var/list/data = list()
	data["machine_name"] = machine_name
	data["transaction_locked"] = transaction_locked
	data["transaction_paid"] = transaction_paid
	data["transaction_purpose"] = transaction_purpose
	data["transaction_amount"] = transaction_amount
	data["linked_account"] = list("name" = linked_account?.account_name, "UID" = linked_account?.UID())
	data["available_accounts"] = list()
	for(var/datum/money_account/department as anything in (account_database.get_all_department_accounts() + account_database.user_accounts))
		var/list/account_data = list(
			"name" = department.account_name,
			"UID"  = department.UID()
		)
		data["available_accounts"] += list(account_data)


	return data

/obj/item/eftpos/ui_act(action, list/params, datum/tgui/ui)
	if(..())
		return

	. = TRUE

	var/mob/living/user = ui.user

	switch(action)
		if("change_code")
			var/attempt_code = tgui_input_number(user, "Re-enter the current EFTPOS access code:", "Confirm old EFTPOS code", max_value = 9999, min_value = 1000)
			if(attempt_code == access_code)
				var/trycode = tgui_input_number(user, "Enter a new access code for this device:", "Enter new EFTPOS code", max_value = 9999, min_value = 1000)
				if(isnull(trycode))
					return
				access_code = trycode
				print_reference()
			else
				to_chat(user, "[bicon(src)]<span class='warning'>Incorrect code entered.</span>")
		if("link_account")
			if(!account_database)
				reconnect_database()
			if(!account_database)
				to_chat(user, "[bicon(src)]<span class='warning'>Unable to connect to accounts database.</span>")
				return
			var/datum/money_account/target_account = locateUID(params["account"])
			if(!istype(target_account))
				to_chat(user, "[bicon(src)]<span class='warning'>Unable to connect to inputted account.</span>")
				return
			// in this case we don't care about authenticating login because we're sending money into the account
			linked_account = target_account
			to_chat(user, "[bicon(src)]<span class='warning'>Linked account successfully set to [target_account.account_name]</span>")
		if("trans_purpose")
			var/purpose = tgui_input_text(user, "Enter reason for EFTPOS transaction", "Transaction purpose", transaction_purpose, encode = FALSE)
			if(!check_user_position(user) || !purpose)
				return
			transaction_purpose = purpose
		if("trans_value")
			var/try_num = tgui_input_number(user, "Enter amount for EFTPOS transaction", "Transaction amount", transaction_amount, MAX_EFTPOS_CHARGE)
			if(!check_user_position(user) || isnull(try_num))
				return
			transaction_amount = try_num
		if("toggle_lock")
			if(transaction_locked)
				var/attempt_code = tgui_input_number(user, "Enter EFTPOS access code", "Reset Transaction", max_value = 9999, min_value = 1000)
				if(!check_user_position(user))
					return
				if(attempt_code == access_code)
					transaction_locked = FALSE
					transaction_paid = FALSE
			else if(linked_account)
				transaction_locked = TRUE
			else
				to_chat(user, "[bicon(src)]<span class='warning'>No account connected to send transactions to.</span>")
		if("reset")
			//reset the access code - requires HoP/captain access
			var/obj/item/I = user.get_active_hand()
			if(istype(I, /obj/item/card))
				var/obj/item/card/id/C = I
				if((ACCESS_CENT_COMMANDER in C.access) || (ACCESS_HOP in C.access) || (ACCESS_CAPTAIN in C.access))
					access_code = 0
					to_chat(user, "[bicon(src)]<span class='notice'>Access code reset to 0.</span>")
			else if(istype(I, /obj/item/card/emag))
				access_code = 0
				to_chat(user, "[bicon(src)]<span class='notice'>Access code reset to 0.</span>")


/obj/item/eftpos/proc/scan_card(obj/item/card/id/C, mob/user, secured = TRUE)
	visible_message("<span class='notice'>[user] swipes a card through [src].</span>")

	if(!transaction_locked || transaction_paid || !secured)
		return

	if(istype(C, /obj/item/card/id/syndicate) && eftpos_sindy_key)
		eftpos_sindy_key.read_agent_card(C, user)
		if(alert("Agent, do you wish to print stolen data?", null, "Yes", "No") == "Yes")
			playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, 1)
			var/obj/item/paper/R = new(loc)
			R.name = "Reference: [machine_name]"
			R.info = eftpos_sindy_key.generate_print_text()
			user.put_in_hands(R)

	if(!linked_account)
		to_chat(user, "[bicon(src)]<span class='warning'>EFTPOS is not connected to an account.</span>")
		return

	var/datum/money_account/D = GLOB.station_money_database.find_user_account(C.associated_account_number, include_departments = FALSE)
	if(!D)
		to_chat(user, "<span class='warning'>Your currently in use card is not connected to a money account.</span>")
		return
	//if security level high enough, prompt for pin
	var/attempt_pin
	if(D.security_level != ACCOUNT_SECURITY_ID)
		attempt_pin = tgui_input_number(user, "Enter pin code", "EFTPOS transaction", max_value = 9999, min_value = 1000)
		if(!attempt_pin || !Adjacent(user))
			return
	//given the credentials, can the associated account be accessed right now?
	if(!GLOB.station_money_database.try_authenticate_login(D, attempt_pin, restricted_bypass = FALSE))
		to_chat(user, "[bicon(src)]<span class='warning'>Unable to access account, insufficient access.</span>")
		return
	if(tgui_alert(user, "Are you sure you want to pay $[transaction_amount] to: [linked_account.account_name]", "Confirm transaction", list("Yes", "No")) != "Yes")
		return
	if(!Adjacent(user))
		return
	//attempt to charge account money
	if(!GLOB.station_money_database.charge_account(D, transaction_amount, transaction_purpose, machine_name, FALSE, FALSE))
		to_chat(user, "[bicon(src)]<span class='warning'>Insufficient credits in your account!</span>")
		return

	// Syndicate hack stuff
	if(eftpos_sindy_key)

		var/list/new_access = C.access - (C.access & eftpos_sindy_key.access)

		for(var/i = 3, i<3, i++)
			if(!new_access)
				break
			var/pick = pick(new_access)
			eftpos_sindy_key.access += pick
			new_access -= pick

		if(!attempt_pin)
			attempt_pin = "No pin"

		var/new_entry = "[C.registered_name]-[C.associated_account_number]:[attempt_pin]"
		if(!(new_entry in eftpos_sindy_key.stolen_data))
			eftpos_sindy_key.stolen_data.Add("[C.registered_name]-[C.associated_account_number]:[attempt_pin]")

	// Syndicate hack stuff end

	GLOB.station_money_database.credit_account(linked_account, transaction_amount, transaction_purpose, machine_name, FALSE)
	playsound(src, transaction_sound, 50, TRUE)
	visible_message("<span class='notice'>[src] chimes!</span>")
	transaction_paid = TRUE
	addtimer(VARSET_CALLBACK(src, transaction_paid, FALSE), 5 SECONDS)

///creates and builds paper with info about the EFTPOS
/obj/item/eftpos/proc/print_reference()
	playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, 1)
	var/obj/item/paper/R = new(loc)
	R.name = "Reference: [machine_name]"
	R.info = {"<b>[machine_name] reference</b><br><br>
		Access code: [access_code]<br><br>
		<b>Do not lose or misplace this code.</b><br>"}
	//stamp the paper
	var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
	stampoverlay.icon_state = "paper_stamp-cent"
	if(!R.stamped)
		R.stamped = new
	R.stamped += /obj/item/stamp
	R.overlays += stampoverlay
	R.stamps += "<hr><i>This paper has been stamped by the EFTPOS device.</i>"
	var/obj/item/small_delivery/D = new(get_turf(loc))
	if(istype(loc, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = loc
		if(H.back)
			D.forceMove(H.back)
	R.forceMove(D)
	D.wrapped = R
	D.name = "small parcel - 'EFTPOS access code'"

/obj/item/eftpos/proc/check_user_position(mob/user)
	return Adjacent(user)

/obj/item/eftpos/screwdriver_act(mob/user, obj/item/I)
	. = TRUE

	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return

	if(isliving(user) && user?.mind?.special_role)
		if(isnull(eftpos_sindy_key))
			user.show_message("<span class='notice'>The terminal has no key.</span>")
		else
			user.show_message("<span class='notice'>You manage to disconnect the key from the terminal.</span>")
			if(!usr.put_in_any_hand_if_possible(eftpos_sindy_key))
				eftpos_sindy_key.forceMove(get_turf(src))
			eftpos_sindy_key = null
	else
		user.show_message("<span class='notice'>You are not sure what to do with the terminal and screwdriver.</span>")


/obj/item/eftpos/register
	name = "point of sale"
	desc = "Also known as a cash register, or, more commonly, \"robbery magnet\". It's old and rusty, and had an EFTPOS module fitted in it. Swipe your ID card to make purchases electronically."
	icon = 'icons/obj/machines/pos.dmi'
	icon_state = "pos"
	force = 10
	throwforce = 10
	throw_speed = 1.5
	throw_range = 7
	anchored = TRUE
	w_class = WEIGHT_CLASS_BULKY
	hitsound = 'sound/weapons/ringslam.ogg'
	drop_sound = 'sound/items/handling/register_drop.ogg'
	pickup_sound =  'sound/items/handling/toolbox_pickup.ogg'
	transaction_sound = 'sound/machines/checkout.ogg'
	attack_verb = list("bounced a check off", "checked-out", "tipped")

/obj/item/eftpos/register/examine(mob/user)
	. = ..()
	if(!anchored)
		. += "<span class='notice'>Alt-click to rotate it.</span>"
	else
		. += "<span class='notice'>It is secured in place.</span>"

/obj/item/eftpos/register/AltClick(mob/user)
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!Adjacent(user))
		return
	if(anchored)
		to_chat(user, "<span class='warning'>[src] is secured in place!</span>")
		return
	setDir(turn(dir, 90))

/obj/item/eftpos/register/attack_hand(mob/user)
	if(anchored)
		if(!check_user_position(user))
			to_chat(user, "<span class='warning'>You need to be behind [src] to use it!</span>")
			return
		add_fingerprint(user)
		ui_interact(user)
		return TRUE
	return ..()

/obj/item/eftpos/register/ui_state(mob/user)
	return GLOB.human_adjacent_state

/obj/item/eftpos/register/attack_self__legacy__attackchain(mob/user)
	to_chat(user, "<span class='notice'>[src] has to be set down and secured to be used.</span>")

/obj/item/eftpos/register/check_user_position(mob/user)
	if(!..())
		return FALSE
	var/user_loc = get_dir(src, user)
	if(!user_loc || user_loc & dir)
		return TRUE
	return FALSE

/obj/item/eftpos/register/scan_card(obj/item/card/id/C, mob/user)
	..(C, user, anchored)

/obj/item/eftpos/register/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(anchored)
		WRENCH_ATTEMPT_UNANCHOR_MESSAGE
	else
		WRENCH_ATTEMPT_ANCHOR_MESSAGE
	if(!I.use_tool(src, user, 5 SECONDS, volume = I.tool_volume))
		return
	anchored = !anchored
	if(anchored)
		WRENCH_ANCHOR_MESSAGE
	else
		WRENCH_UNANCHOR_MESSAGE
	SStgui.close_uis(src)

#undef MAX_EFTPOS_CHARGE
