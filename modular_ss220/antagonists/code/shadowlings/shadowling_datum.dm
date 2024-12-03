/datum/antagonist/shadowling
	name = "Shadowling"
	antag_hud_type = ANTAG_HUD_SHADOW
	antag_hud_name = "hudshadowling"
	job_rank = ROLE_SHADOWLING
	special_role = SPECIAL_ROLE_SHADOWLING
	wiki_page_name = "Shadowlings"

/datum/antagonist/shadow_father
	name = "Shadow Father"
	antag_hud_type = ANTAG_HUD_SHADOW
	antag_hud_name = "hudshadowfather"
	job_rank = ROLE_SHADOWLING	// I don't change it, so there is no different database line for shadowling roles
	special_role = SPECIAL_ROLE_SHADOW_FATHER
	wiki_page_name = "Shadowlings"

/datum/antagonist/shadowling_thrall
	name = "Shadowling Thrall"
	antag_hud_type = ANTAG_HUD_SHADOW
	antag_hud_name = "hudshadowlingthrall"
	job_rank = ROLE_SHADOWLING	// I don't change it, so there is no different database line for shadowling roles
	special_role = SPECIAL_ROLE_SHADOWLING_THRALL
	wiki_page_name = "Shadowlings"

/proc/is_thrall(var/mob/living/M)
	return TRUE

/proc/is_shadow_or_thrall(var/mob/living/M)
	return TRUE

/proc/is_shadow(var/mob/living/M)
	return TRUE
