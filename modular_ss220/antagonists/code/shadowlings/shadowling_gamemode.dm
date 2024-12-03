/datum/game_mode
	var/list/datum/mind/shadowlings = list()
	var/list/datum/mind/shadowling_thralls = list()
	var/list/datum/mind/shadow_fathers = list()
	var/victory_warning_announced = FALSE

/// Called when shadow father is killed or when special spell is used
/datum/game_mode/proc/begin_shadowling_invasion(mob/living/simple_animal/demon/shadow_father/father, spell_used)
	// Spawning father as shadowling
	if(spell_used)
		var/obj/effect/dummy/slaughter/holder = new /obj/effect/dummy/slaughter(father.loc)
		var/mob/living/carbon/human/shadowling/ling = new /mob/living/carbon/human/shadowling(holder)
		ling.AddSpell(new /datum/spell/shadowling/self/rift_in)
		ling.key = father.key
	else
		father.consumed++	//At least one shadowling
	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Вы хотите поиграть за тенелинга?", ROLE_SHADOWLING, TRUE, 25 SECONDS, source = /mob/living/simple_animal/demon/shadow_father, role_cleanname = "Shadowling")
	while(father.consumed > 0)
		if(candidates.len < 1)
			break
		var/player_to_spawn
		var/mob/dead/observer/ghost = pick(candidates)
		candidates.Remove(ghost)
		player_to_spawn = ghost.key
		var/obj/effect/dummy/slaughter/holder = new /obj/effect/dummy/slaughter(father.loc)
		var/mob/living/carbon/human/shadowling/ling = new /mob/living/carbon/human/shadowling(holder)
		ling.AddSpell(new /datum/spell/shadowling/self/rift_in)
		dust_if_respawnable(ghost)
		ling.key = player_to_spawn
		father.consumed--

