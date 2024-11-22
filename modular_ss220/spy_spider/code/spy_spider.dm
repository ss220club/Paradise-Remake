/datum/controller/subsystem/radio/frequency_span_class(frequency)
	if(frequency == SPY_SPIDER_FREQ)
		return "spyradio"
	return ..()

/obj/item/radio/spy_spider
	name = "шпионский жучок"
	desc = "Кажется, ты видел такого в фильмах про шпионов."
	icon = 'modular_ss220/spy_spider/icons/spy_spider.dmi'
	icon_state = "spy_spider"
	frequency = SPY_SPIDER_FREQ
	freqlock = SPY_SPIDER_FREQ
	listening = FALSE
	broadcasting = FALSE
	canhear_range = 3

/obj/item/radio/spy_spider/examine(mob/user)
	. = ..()
	. += span_info("Сейчас он [broadcasting ? "включён" : "выключен"].")

/obj/item/radio/spy_spider/attack_self(mob/user)
	broadcasting = !broadcasting
	if(broadcasting)
		to_chat(user, span_info("Ты включаешь жучок."))
	else
		to_chat(user, span_info("Ты выключил жучок."))
	return TRUE

/obj/item/encryptionkey/spy_spider
	name = "Spy Encryption Key"
	icon = 'modular_ss220/spy_spider/icons/spy_spider.dmi'
	icon_state = "spy_cypherkey"
	channels = list("Spy Spider" = TRUE)

/obj/item/storage/lockbox/spy_kit
	name = "набор жучков"
	desc = "Не самый легальный из способов достать информацию, но какая разница, если никто не узнает?"
	storage_slots = 5
	req_access = list(ACCESS_FORENSICS_LOCKERS)

/obj/item/storage/lockbox/spy_kit/Initialize(mapload)
	. = ..()
	new /obj/item/radio/spy_spider(src)
	new /obj/item/radio/spy_spider(src)
	new /obj/item/radio/spy_spider(src)
	new /obj/item/encryptionkey/spy_spider(src)
	new /obj/item/encryptionkey/spy_spider(src)

/**
 * CLOTHING PART
 */
/obj/item/clothing
	var/obj/item/radio/spy_spider/spy_spider_attached

/obj/item/clothing/Destroy()
	QDEL_NULL(spy_spider_attached)
	return ..()

/obj/item/clothing/emp_act(severity)
	. = ..()
	spy_spider_attached?.emp_act(severity)

/obj/item/clothing/hear_talk(mob/M, list/message_pieces)
	. = ..()
	spy_spider_attached?.hear_talk(M, message_pieces)

/obj/item/clothing/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/radio/spy_spider))
		return ..()
	if(spy_spider_attached || !((slot_flags & ITEM_SLOT_OUTER_SUIT) || (slot_flags & ITEM_SLOT_JUMPSUIT)))
		to_chat(user, span_warning("Ты не находишь места для жучка!"))
		return TRUE
	var/obj/item/radio/spy_spider/spy_spider = I

	if(!spy_spider.broadcasting)
		to_chat(user, span_warning("Жучок выключен!"))
		return TRUE

	user.unEquip(spy_spider)
	spy_spider.forceMove(src)
	spy_spider_attached = spy_spider
	to_chat(user, span_info("Ты незаметно прикрепляешь жучок к [src]."))
	return TRUE

/obj/item/clothing/Topic(href, href_list)
	if(!usr.stat && !HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED) && !usr.restrained())
		if(isnull(src.spy_spider_attached))
			to_chat(usr, span_info("Ты уже снял жучок с [src]."))
			return
		if(!in_range(src, usr))
			to_chat(usr, span_info("Тебе нужно подойти ближе, чтобы снять жучок с [src]."))
			return
		if(href_list["remove_spy_spider"])
			var/obj/item/I = locate(href_list["remove_spy_spider"])
			if(do_after(usr, 3 SECONDS, needhand = 1, target = src))
				I.forceMove(get_turf(src))
				usr.put_in_hands(I)
				usr.visible_message("[usr] Что-то снимает с [src] !","<span class='notice'>Вы успешно снимаете жучок с [src].</span>")
				src.spy_spider_attached = null
	. = ..()


/**
 * HUMAN PART
 */
/mob/living/carbon/human/attackby(obj/item/I, mob/living/user, def_zone)
	if(!istype(I, /obj/item/radio/spy_spider))
		return ..()

	if(!(w_uniform || wear_suit))
		to_chat(user, span_warning("У тебя нет желания лезть к [src] в трусы. Жучок надо крепить на одежду!"))
		return TRUE

	var/obj/item/radio/spy_spider/spy_spider = I
	var/obj/item/clothing/clothing_for_attach = wear_suit || w_uniform
	if(clothing_for_attach.spy_spider_attached)
		to_chat(user, span_warning("Ты не находишь места для жучка!"))
		return TRUE

	if(!spy_spider.broadcasting)
		to_chat(user, span_warning("Жучок выключен!"))
		return TRUE

	var/attempt_cancel_message = span_warning("Ты не успеваешь установить жучок.")
	if(!do_after_once(user, 3 SECONDS, TRUE, src, TRUE, attempt_cancel_message))
		return TRUE

	user.unEquip(spy_spider)
	spy_spider.forceMove(clothing_for_attach)
	clothing_for_attach.spy_spider_attached = spy_spider
	to_chat(user, span_info("Ты незаметно прикрепляешь жучок к одежде [src]."))
	return TRUE

/obj/item/clothing/suit/storage/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/radio/spy_spider))
		return
	. = ..()

// Spy spider detection
/obj/item/detective_scanner/scan(atom/A, mob/user)
	. = ..()

	if(!scanning)
		scanning = TRUE

	if(istype(A, /obj/item/clothing))
		var/obj/item/clothing/scanned_clothing = A
		if(scanned_clothing.spy_spider_attached)
			sleep(1 SECONDS)
			// Triger /obj/item/clothing/Topic
			add_log(span_info("<a href='byond://?src=[scanned_clothing.UID()];remove_spy_spider=[scanned_clothing.spy_spider_attached.UID()];' class='warning'><b>Найдено шпионское устройство!</b></a>"))
	scanning = FALSE
