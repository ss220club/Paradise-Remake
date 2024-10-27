//Добавление новых алертов
/atom/movable/screen/alert/carapace/
	icon = 'modular_ss220/species/serpentids/icons/screen_alert.dmi'

/atom/movable/screen/alert/carapace/break_armor
	name = "Слабые повреждения панциря."
	desc = "Ваш панцирь поврежден. Нарушение целостности снизило сопротивление урону."
	icon_state = "carapace_break_armor"

/atom/movable/screen/alert/carapace/break_cloak
	name = "Средние повреждения панциря"
	desc = "Ваш панцирь поврежден. Нарушения целостности лишило вас возможность скрывать себя."
	icon_state = "carapace_break_cloak"

/atom/movable/screen/alert/carapace/break_rig
	name = "Сильные повреждения панциря"
	desc = "Ваш панцирь поврежден. Нарушения целостности лишило вас сопротивлению окружающей среде."
	icon_state = "carapace_break_rig"

/atom/movable/screen/alert/carapace/break_armor/Click()
	if(isliving(usr) && ..())
		to_chat(usr, span_notice("Вы понесли значительный урон. Обратитесь в мед, чтобы восстановить свою защиту тела."))

/atom/movable/screen/alert/carapace/break_cloak/Click()
	if(isliving(usr) && ..())
		to_chat(usr, span_notice("Вы понесли крупный урон. Обратитесь в мед, чтобы восстановить свою возможность маскировки."))

/atom/movable/screen/alert/carapace/break_rig/Click()
	if(isliving(usr) && ..())
		to_chat(usr, span_notice("Вы понесли критический урон. Обратитесь в мед, чтобы восстановить герметичность панциря."))

/atom/movable/screen/alert/carrying
	name = "Перенос"
	desc = "Ваш хвост обвязал случайного зеваку или ящик. Нажмите, что бы отгрузить."
	icon = 'modular_ss220/species/serpentids/icons/screen_alert.dmi'
	icon_state = "holding"

