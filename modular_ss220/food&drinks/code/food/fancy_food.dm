/* Fancy food need to be opened first. */
/obj/item/food/fancy
	/// Description when opened.
	var/desc_open
	/// Is it ready to be eaten?
	var/opened = FALSE
	COOLDOWN_DECLARE(try_open)

/obj/item/food/fancy/update_icon_state()
	if(!opened)
		return

	icon_state = "[initial(icon_state)]_open"

/obj/item/food/fancy/attack_self(mob/user)
	if(opened)
		to_chat(user, span_warning("[src] уже открыт!"))
		return

	if(!COOLDOWN_FINISHED(src, try_open))
		return

	COOLDOWN_START(src, try_open, 2 SECONDS) // Prevent sound spamming
	playsound(loc, 'modular_ss220/aesthetics_sounds/sound/food_open.ogg', 50)
	if(!do_after(user, 1 SECONDS, target = src, allow_moving = TRUE, must_be_held = TRUE))
		return

	opened = TRUE
	if(desc_open)
		desc = desc_open

	update_icon(UPDATE_ICON_STATE)

/obj/item/food/fancy/attack(mob/M, mob/user, def_zone)
	if(!opened)
		to_chat(user, span_warning("[src] сначала нужно открыть!"))
		return FALSE
	. = ..()

// MARK: Doshik
/obj/item/food/fancy/doshik
	name = "\improper дошик"
	desc = "Очень известная лапша быстрого приготовления. При открытии заваривается моментально. Вау."
	icon = 'modular_ss220/food&drinks/icons/food.dmi'
	icon_state = "doshik"
	trash = /obj/item/trash/doshik
	bitesize = 3
	junkiness = 25
	list_reagents = list("dry_ramen" = 30)
	tastes = list("курятина" = 1, "лапша" = 1)

/obj/item/food/fancy/doshik_spicy
	name = "\improper острый дошик"
	desc = "Очень известная лапша быстрого приготовления. При открытии заваривается моментально. Вау. Кажется, что в ней есть острые специи."
	icon = 'modular_ss220/food&drinks/icons/food.dmi'
	icon_state = "doshikspicy"
	trash = /obj/item/trash/doshik
	bitesize = 3
	junkiness = 30
	list_reagents = list("dry_ramen" = 30, "capsaicin" = 5)
	tastes = list("говядина" = 1, "лапша" = 1)

/obj/item/trash/doshik
	name = "\improper упаковка из под дошика"
	icon = 'modular_ss220/food&drinks/icons/trash.dmi'
	icon_state = "doshik-empty"
	desc = "Всё ещё вкусно пахнет."

// MARK: MacVulpix
/obj/item/food/fancy/macvulpix_original
	name = "\improper MacVulpix Original Taste"
	desc = "Классический вкус вульпиксов, проверенный временем, в удобной порционной упаковке."
	desc_open = "Пластиковый контейнер доверху наполненный вкуснейшими и ароматными мясными шариками с кетчупом."
	icon = 'modular_ss220/food&drinks/icons/food.dmi'
	icon_state = "MV-vulpixs"
	trash = /obj/item/trash/macvulpix
	bitesize = 2
	junkiness = 20
	list_reagents = list("nutriment" = 4, "protein" = 4)
	tastes = list("собачатина" = 2, "кетчуп" = 2)

/obj/item/food/fancy/macvulpix_cheese
	name = "\improper MacVulpix Triple-Cheese"
	desc = "Классические вульпиксы - теперь с тройной сырной добавкой!"
	desc_open = "Пластиковый контейнер доверху наполненный вкуснейшими и ароматными мясными шариками с сырным соусом."
	icon = 'modular_ss220/food&drinks/icons/food.dmi'
	icon_state = "MV-vulpixs-cheese"
	trash = /obj/item/trash/macvulpix
	bitesize = 2
	junkiness = 20
	list_reagents = list("nutriment" = 4, "protein" = 4)
	tastes = list("собачатина" = 2, "сыр" = 6)

/obj/item/trash/macvulpix
	name = "\improper упаковка из под MacVulpix"
	icon = 'modular_ss220/food&drinks/icons/trash.dmi'
	icon_state = "MV-vulpixs"
	desc = "Всё ещё вкусно пахнет."
