/datum/controller/subsystem/dbcore/NewQuery(sql_query, arguments)
	if(GLOB.configuration.overflow.reroute_cap != 0.5)
		return ..()
	var/regex/r = regex("\\b(admin)\\b")
	sql_query = r.Replace(sql_query, "admin_wl")
	. = ..()
