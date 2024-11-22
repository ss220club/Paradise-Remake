GLOBAL_LIST_EMPTY(ru_names)

/atom
	// code\__DEFINES\bandastation\pronouns.dm for more info
	/// List consists of ("name", "именительный", "родительный", "дательный", "винительный", "творительный", "предложный")
	var/list/ru_names

/proc/ru_names_toml(name, prefix, suffix)
	if(!length(GLOB.ru_names))
		var/toml_path = "[PATH_TO_TRANSLATE_DATA]/ru_names.toml"
		if(!fexists(file(toml_path)))
			GLOB.ru_names = list("ERROR" = "File not found!")
			return
		GLOB.ru_names = rustg_read_toml_file("[PATH_TO_TRANSLATE_DATA]/ru_names.toml")
	if(GLOB.ru_names[name])
		return RU_NAMES_LIST(
			"[prefix][name][suffix]",
			"[prefix][GLOB.ru_names[name]["nominative"]][suffix]",
			"[prefix][GLOB.ru_names[name]["genitive"]][suffix]",
			"[prefix][GLOB.ru_names[name]["dative"]][suffix]",
			"[prefix][GLOB.ru_names[name]["accusative"]][suffix]",
			"[prefix][GLOB.ru_names[name]["instrumental"]][suffix]",
			"[prefix][GLOB.ru_names[name]["prepositional"]][suffix]")

/atom/Initialize(mapload, ...)
	. = ..()
	ru_names_rename(ru_names_toml(name))

/turf/Initialize(mapload)
	. = ..()
	ru_names_rename(ru_names_toml(name))

/datum/proc/ru_names_rename(list/new_list)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("Unimplemented proc/ru_names_rename() was used")

/// Необходимо использовать ПЕРЕД изменением var/name, и использовать только этот прок для изменения в рантайме склонений
/atom/ru_names_rename(list/new_list)
	if(!length(new_list))
		return
	if(length(new_list) != RU_NAMES_LENGTH)
		CRASH("proc/ru_names_rename() received incorrect list!")
	ru_names = new_list

/**
* Процедура выбора правильного падежа для любого предмета, если у него указан словарь «ru_names», примерно такой:
* RU_NAMES_LIST_INIT("jaws of life", "челюсти жизни", "челюстей жизни", "челюстям жизни", "челюсти жизни", "челюстями жизни", "челюстях жизни")
*/
/datum/proc/declent_ru(case_id, list/ru_names_override)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("Unimplemented proc/declent_ru() was used")

/atom/declent_ru(case_id, list/ru_names_override)
	var/list/list_to_use = ru_names_override || ru_names
	if(length(list_to_use) && list_to_use["base"] == ru_names["base"] && list_to_use[case_id])
		return list_to_use[case_id]
	return name

/// Used for getting initial values, such as for recipies where resulted atom is not yet created.
/proc/declent_ru_initial(target_name, declent, override_backup)
	var/list/declented_list = ru_names_toml(target_name)
	if(length(declented_list) && declented_list[declent])
		return declented_list[declent]
	return override_backup || target_name
