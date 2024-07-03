/datum/vox_pack/consumables
	name = "DEBUG Consumables Vox Pack"
	category = VOX_PACK_CONSUMABLES


// MISC

/datum/vox_pack/consumables/food
	name = "Варево"
	desc = "Лучше чем ничего."
	reference = "CO_FOOD"
	cost = 5
	contains = list(/obj/item/food/snacks/soup/stew)

/datum/vox_pack/consumables/blood
	name = "Кровь"
	desc = "Кровь предназначенная для переливания Воксам."
	reference = "CO_BLOOD"
	cost = 200
	contains = list(/obj/item/reagent_containers/iv_bag/blood/vox)

/datum/vox_pack/consumables/flare
	name = "Фальшфейер"
	desc = "Пиротехнический огонь."
	reference = "CO_FLARE"
	cost = 15
	contains = list(/obj/item/flashlight/flare)


// EXPLOSIVES

/datum/vox_pack/consumables/c4
	name = "C4"
	desc = "Взрывчатка для создания аккуратных дыр."
	reference = "CO_C4"
	cost = 100
	contains = list(/obj/item/grenade/plastic/c4)

/datum/vox_pack/consumables/x4
	name = "X4"
	desc = "Осколочно-фугасный заряд. Безопасен для подрывника."
	reference = "CO_X4"
	cost = 200
	contains = list(/obj/item/grenade/plastic/c4/x4)

/datum/vox_pack/consumables/t4
	name = "T4"
	desc = "Заряд термита, пробивающий стены. Неэффективен против шлюзов."
	reference = "CO_T4"
	cost = 300
	contains = list(/obj/item/grenade/plastic/c4/thermite)

