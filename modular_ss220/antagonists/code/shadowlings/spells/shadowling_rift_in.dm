/datum/spell/shadowling/self/rift_in
	name = "Проникнуть через разлом"
	desc = "Вы проникаете через разрыв из мира теней в материальную реальность"
	stat_allowed = UNCONSCIOUS
	action_icon_state = "ascend"

/datum/spell/shadowling/self/rift_in/cast(list/targets, mob/user = usr)
	var/obj/effect/dummy/slaughter/holder = user.loc
	if(istype(holder))
		user.forceMove(holder.loc)
		qdel(holder)
	user.RemoveSpell(src)
	return

