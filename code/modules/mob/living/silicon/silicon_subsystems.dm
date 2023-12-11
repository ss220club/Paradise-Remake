/mob/living/silicon
	var/register_alarms = TRUE
	var/datum/ui_module/atmos_control/atmos_control
	var/datum/ui_module/crew_monitor/crew_monitor
	var/datum/ui_module/law_manager/law_manager
	var/datum/ui_module/power_monitor/digital/power_monitor

/mob/living/silicon
	var/list/silicon_subsystems = list(
		/mob/living/silicon/proc/subsystem_law_manager
	)

/mob/living/silicon/ai
	silicon_subsystems = list(
		/mob/living/silicon/proc/subsystem_atmos_control,
		/mob/living/silicon/proc/subsystem_crew_monitor,
		/mob/living/silicon/proc/subsystem_law_manager,
		/mob/living/silicon/proc/subsystem_power_monitor
	)

/mob/living/silicon/robot
	var/datum/ui_module/robot_self_diagnosis/self_diagnosis
	var/datum/ui_module/destination_tagger/mail_setter
	silicon_subsystems = list(
		/mob/living/silicon/robot/proc/self_diagnosis,
		/mob/living/silicon/proc/subsystem_law_manager
	)

/mob/living/silicon/robot/drone
	silicon_subsystems = list(
		/mob/living/silicon/robot/proc/set_mail_tag,
		/mob/living/silicon/robot/proc/self_diagnosis,
		/mob/living/silicon/proc/subsystem_law_manager,
		/mob/living/silicon/proc/subsystem_power_monitor
	)

/mob/living/silicon/robot/syndicate
	register_alarms = 0

/mob/living/silicon/robot/syndicate/saboteur
	silicon_subsystems = list(
		/mob/living/silicon/robot/proc/set_mail_tag,
		/mob/living/silicon/robot/proc/self_diagnosis,
		/mob/living/silicon/proc/subsystem_law_manager
	)

/mob/living/silicon/proc/init_subsystems()
	atmos_control 	= new(src)
	crew_monitor 	= new(src)
	law_manager		= new(src)
	power_monitor	= new(src)

/mob/living/silicon/robot/init_subsystems()
	. = ..()
	self_diagnosis  = new(src)
	mail_setter	= new(src)

/********************
*	Atmos Control	*
********************/
/mob/living/silicon/proc/subsystem_atmos_control()
	set category = "Подсистемы"
	set name = "Контроль атмосферы"

	atmos_control.ui_interact(usr, state = GLOB.self_state)

/********************
*	Crew Monitor	*
********************/
/mob/living/silicon/proc/subsystem_crew_monitor()
	set category = "Подсистемы"
	set name = "Монитор экипажа"
	crew_monitor.ui_interact(usr, state = GLOB.self_state)

/****************
*	Law Manager	*
****************/
/mob/living/silicon/proc/subsystem_law_manager()
	set name = "Управление законами"
	set category = "Подсистемы"

	law_manager.ui_interact(usr, state = GLOB.conscious_state)

/********************
*	Power Monitor	*
********************/
/mob/living/silicon/proc/subsystem_power_monitor()
	set category = "Подсистемы"
	set name = "Монитор энергии"

	power_monitor.ui_interact(usr, state = GLOB.self_state)

/mob/living/silicon/robot/proc/self_diagnosis()
	set category = "Robot Commands"
	set name = "Self Diagnosis"

	if(!is_component_functioning("diagnosis unit"))
		to_chat(src, "<span class='warning'>Your self-diagnosis component isn't functioning.</span>")
		return

	self_diagnosis.ui_interact(src)

/********************
*	Set Mail Tag	*
********************/
/mob/living/silicon/robot/proc/set_mail_tag()
	set name = "Set Mail Tag"
	set desc = "Tag yourself for delivery through the disposals system."
	set category = "Robot Commands"

	mail_setter.ui_interact(src)
