/obj/item/clothing/under/shadowling
	name = "почерневшая плоть"
	desc = "Чёрная хитинистая кожа с выступающими красными венами."
	icon = 'modular_ss220/antagonists/icons/shadowlings/shadowlings_clothes.dmi'
	icon_state = "shadowling_uniform"
	origin_tech = null
	flags = NODROP | DROPDEL
	has_sensor = FALSE
	displays_id = FALSE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF


/obj/item/clothing/suit/space/shadowling
	name = "теневой панцирь"
	desc = "Тёмный полупросрачный панцирь, защищающий тенелинга от урона и немного от космоса." //Still takes damage from spacewalking but is immune to space itself
	icon = 'modular_ss220/antagonists/icons/shadowlings/shadowlings_clothes.dmi'
	icon_state = "shadowling_suit"
	icon_override = 'icons/mob/clothing/underwear.dmi' // It's required to avoid 'suit' test icon
	body_parts_covered = FULL_BODY //Shadowlings are immune to space
	cold_protection = FULL_BODY
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEGLOVES | HIDESHOES | HIDEJUMPSUIT
	flags = NODROP | DROPDEL
	slowdown = 0
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	heat_protection = null //You didn't expect a light-sensitive creature to have heat resistance, did you?
	max_heat_protection_temperature = null
	armor = list(melee = 25, bullet = 25, laser = 0, energy = 10, bomb = 25, bio = 100, rad = 100, fire = 100, acid = 100)


/obj/item/clothing/shoes/shadowling
	name = "теневые крюки"
	desc = "Угольно-чёрные крюки, расположенные на ногах тенелингов."
	icon = 'modular_ss220/antagonists/icons/shadowlings/shadowlings_clothes.dmi'
	icon_state = "shadowling_shoes"
	resistance_flags = LAVA_PROOF|FIRE_PROOF|ACID_PROOF
	flags = NODROP | DROPDEL
	no_slip = TRUE

/obj/item/clothing/mask/gas/shadowling
	name = "теневая маска"
	desc = "Тёмная хитиновая маска, располагающаяся на лицах тенелингов."
	icon = 'modular_ss220/antagonists/icons/shadowlings/shadowlings_clothes.dmi'
	icon_state = "shadowling_mask"
	siemens_coefficient = 0
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	flags_cover = MASKCOVERSEYES
	flags = NODROP | DROPDEL

/obj/item/clothing/gloves/shadowling
	name = "теневые наручи"
	desc = "Плотной слой теневой материи, защищающий руки тенелинга от  и электричества."
	icon = 'modular_ss220/antagonists/icons/shadowlings/shadowlings_clothes.dmi'
	icon_state = "shadowling_gloves"
	siemens_coefficient = 0
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	flags = NODROP | DROPDEL

/obj/item/clothing/head/shadowling
	name = "теневой шлем"
	desc = "Шлемообразный защитный панцирь, расположенный на голове тенелинга."
	icon = 'modular_ss220/antagonists/icons/shadowlings/shadowlings_clothes.dmi'
	icon_state = "shadowling_helmet"
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	flags_cover = HEADCOVERSEYES	//We don't need to cover mouth
	flags = NODROP | DROPDEL | BLOCKHAIR

/obj/item/clothing/glasses/shadowling
	name = "багровые линзы"
	desc = "Небольшие красные мембраны, защищающие уязвимые глаза тенелингов."
	icon = 'modular_ss220/antagonists/icons/shadowlings/shadowlings_clothes.dmi'
	icon_state = "shadowling_glasses"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	flash_protect = FLASH_PROTECTION_SENSITIVE
	vision_flags = SEE_MOBS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	flags = NODROP | DROPDEL
