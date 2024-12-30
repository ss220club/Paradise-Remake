/obj/item/eftpos_hack_key
	name = "EFTPOS Hacking Key"
	desc = "A small key insetred in EFTPOS diveses for hacing them. Allows to steal cleints personal information"
	icon = 'icons/obj/radio.dmi'
	icon_state = "cypherkey"
	item_state = ""
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "engineering=2;bluespace=1" // TODO

	// trucks who was the higest target for print output
	var/highest_stolen_rank
	var/list/access = list()
	var/list/stolen_data = list()

	// Acceses that must be copied if present
	var/static/list/comand_access = list(ACCESS_CENT_COMMANDER, ACCESS_CENT_SPECOPS, ACCESS_CAPTAIN,
	ACCESS_BLUESHIELD,  ACCESS_HOS, ACCESS_MAGISTRATE, ACCESS_NTREP, ACCESS_QM, ACCESS_CE,
	ACCESS_HOP, ACCESS_CMO, ACCESS_RD)

	// Acceses that must not be copied, but have a comment in print output
	var/static/list/not_important_jobs = list(ACCESS_MIME, ACCESS_MIME,ACCESS_BAR, ACCESS_LIBRARY,
	ACCESS_KITCHEN, ACCESS_HYDROPONICS, ACCESS_VIROLOGY, ACCESS_ENGINE_EQUIP, ACCESS_ATMOSPHERICS,
	ACCESS_MEDICAL, ACCESS_RESEARCH, ACCESS_SECURITY, ACCESS_CARGO )

// interaction called on using agent card with Hacked EFTPOS terminal. Uppdates acsesses
/obj/item/eftpos_hack_key/proc/read_agent_card(card, mob/living/user)
	if(istype(card, /obj/item/card/id/syndicate))
		var/obj/item/card/id/syndicate/agent_card = card
		if(isliving(user) && user?.mind?.special_role)
			to_chat(usr, "<span class='notice'>The card's microscanners activate as you pass it throw terminal, adding access.</span>")
			agent_card.access |= access

// Called when we readt to make a report. Contains all slolen data and fun coments
/obj/item/eftpos_hack_key/proc/generate_print_text()

	var/victim_number = length(stolen_data)
	var/victim_text

	switch(victim_number)
		if(0)       	victim_text = "GO WORK AGENT!"
		if(1 to 3)      victim_text = "Ok, it's working, now you can start doing your job!"
		if(4 to 9)    	victim_text = "Good start, agent"
		if(10 to 20) 	victim_text = "Keep up the good work"
		if(21 to 50) 	victim_text = "Maybe...maybe you are usfull after all"
		if(50 to 100) 	victim_text = "You did not forget, you have actial job to do?"
		if(101 to 150) 	victim_text = "At this point, i just don't beleave you"
		else       		victim_text = "AGENT, STOP BRAKING MY STUF!!!"

	var/text_to_print = {"
		<b>N@m3 Er0r r3f3r3nc3</b><br>
		<b>4cc3ss c0d3: @#_#@ </b><br>
		<b>Do n0t l0s3 or m1spl@ce this c0d3.</b><br>
		<center>Glory to syndicate! Here is your report agent</center>
		<center>Agent, you have stolen data [victim_number] times </center>
		<center>[victim_text]</center>
		<br>
		<center>Your most important target was: [highest_stolen_rank]</center>
		<center>[get_rank_text(highest_stolen_rank)]</center>
		<br>
		<center>Here is your victims accounts details:</center><br>
		"}

	for(var/i = 1, length(stolen_data) >= i, i++)
		text_to_print += "[stolen_data[i]]<BR>"

	text_to_print+="Do not forget to tell you agent friends how useful my gadget is!"

	return text_to_print

// Not used curently
/obj/item/eftpos_hack_key/proc/on_key_insert()
	return null

// Get a funny comment for print
/obj/item/eftpos_hack_key/proc/get_rank_text(access)
	switch(access)
		if(ACCESS_CENT_COMMANDER)
			return  "Ehh, do they even have bank accounts?"

		if(ACCESS_CENT_SPECOPS)
			return  "Where do they find the free time for you."

		if(ACCESS_CAPTAIN)
			return  "A big catch, not bad."

		if(ACCESS_BLUESHIELD)
			return  "Another fearless mountain of muscle."

		if(ACCESS_MAGISTRATE)
			return  "Treyzon's watch dog"

		if(ACCESS_NTREP)
			return  "Looks like he's here to watch over their slaves."

		if(ACCESS_QM)
			return  "Old good, working class."

		if(ACCESS_CE)
			return  "Does he even take breaks from working?"

		if(ACCESS_HOP)
			return  "We both know – he was easy prey."

		if(ACCESS_CMO)
			return  "Sorry, doc, today we’re going to cause some serious harm."

		if(ACCESS_RD)
			return  "Judging by the database... His doctoral is boring as hell."

		if(ACCESS_HOS)
			return  "If only he knew what you just did to him."

		if(ACCESS_CLOWN)
			return  "Mission has been failed successfully."

		if(ACCESS_MIME)
			return  "..."

		if(ACCESS_BAR)
			return  "You were my brother, Anakin! I loved you!"

		if(ACCESS_LIBRARY)
			return  "You were my brother, Anakin! I loved you!"

		if(ACCESS_KITCHEN)
			return  "You were my brother, Anakin! I loved you!"

		if(ACCESS_HYDROPONICS)
			return  "You were my brother, Anakin! I loved you!"

		if(ACCESS_VIROLOGY)
			return  "Oh yes! Oh yes! I think I know what you're up to!"

		if(ACCESS_ENGINE_EQUIP)
			return  "In our time it is so hard to find crafty guys."

		if(ACCESS_MEDICAL)
			return  "You know? I have nothing against these guys."

		if(ACCESS_RESEARCH)
			return  "Not smart enough to notice the trick, haha!"

		if(ACCESS_SECURITY)
			return  "Now it’s not so safe, thanks to you."

		if(ACCESS_CARGO)
			return  "Looks like you have a lot in common! For example, it’s time for both of you to get to work!"

		else
			return  "Not sure how this will help you"


// Logic of access theft
/obj/item/eftpos_hack_key/proc/update_access(C)

	if(!istype(C, /obj/item/card/id))
		return
	var/obj/item/card/id/card = C
	var/list/new_access = card.access - (card.access & access)

	if(comand_access & card.access)
		for(var/temp_access in comand_access)
			if(temp_access in card.access)
				highest_stolen_rank = card.rank
				access |= temp_access
				break
	else if(not_important_jobs & card.access)
		for(var/temp_access in not_important_jobs)
			if(temp_access in card.access)
				highest_stolen_rank = card.rank
				break

	for(var/i in 1 to 3)
		if(!new_access)
			break
		var/pick = pick(new_access)
		access += pick
		new_access -= pick

// Instructions hacking an EFTPOS terminal
/obj/item/paper/eftpos_hack_key
	name = "EFTPOS Hack Key Guide"
	icon_state = "paper"
	info = {"<b>Hello, agent! You made a great purchase, I already like you!</b><br>
	<br>
	First, find a working EFTPOS terminal, then insert the hacking key into it.<br>
	<br>
	Now, whenever someone makes a transaction with their card, my device will steal their account information and provide access to up to three areas.<br>
	<br>
	<b>To copy all the accesses, just use your agent card and swipe it. Yep, those are sold separately!</b><br>
	<br>
	You can also use a screwdriver to remove the key if that wasn't obvious.<br>
	<br><hr>
"}
