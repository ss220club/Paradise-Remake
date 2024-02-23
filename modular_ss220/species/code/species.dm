/datum/species
	var/required_playtimes_minutes = -1

/datum/species/proc/is_available(mob/M)
	if(!M.client)
		return TRUE
	var/list/play_records = params2list(M.client.prefs.exp)
	var/record = text2num(play_records[EXP_TYPE_LIVING])
	if(record < required_playtimes_minutes)
		return FALSE
	return TRUE

/datum/species/nucleation
	required_playtimes_minutes = 6000 // 100 часов
