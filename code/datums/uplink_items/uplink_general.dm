GLOBAL_LIST_INIT(uplink_items, subtypesof(/datum/uplink_item))
// This define is used when we have to spawn in an uplink item in a weird way, like a Surplus crate spawning an actual crate.
// Use this define by setting `uses_special_spawn` to TRUE on the item, and then checking if the parent proc of `spawn_item` returns this define. If it does, implement your special spawn after that.

/proc/get_uplink_items(obj/item/uplink/U)
	var/list/uplink_items = list()
	var/list/sales_items = list()
	var/newreference = 1
	if(!uplink_items.len)

		var/list/last = list()
		for(var/path in GLOB.uplink_items)

			var/datum/uplink_item/I = new path
			if(!I.item)
				continue
			if(length(I.uplinktypes) && !(U.uplink_type in I.uplinktypes) && U.uplink_type != UPLINK_TYPE_ADMIN)
				continue
			if(length(I.excludefrom) && (U.uplink_type in I.excludefrom))
				continue
			if(I.last)
				last += I
				continue

			if(!uplink_items[I.category])
				uplink_items[I.category] = list()

			uplink_items[I.category] += I
			if(I.limited_stock < 0 && !I.cant_discount && I.item && I.cost > 5)
				sales_items += I

		for(var/datum/uplink_item/I in last)
			if(!uplink_items[I.category])
				uplink_items[I.category] = list()

			uplink_items[I.category] += I

	for(var/i in 1 to 3)
		var/datum/uplink_item/I = pick_n_take(sales_items)
		var/datum/uplink_item/A = new I.type
		var/discount = 0.5
		A.limited_stock = 1
		I.refundable = FALSE
		A.refundable = FALSE
		if(A.cost >= 100)
			discount *= 0.5 // If the item costs 100TC or more, it's only 25% off.
		A.cost = max(round(A.cost * (1-discount)),1)
		A.category = "Discounted Gear"
		A.name += " ([round(((initial(A.cost)-A.cost)/initial(A.cost))*100)]% off!)"
		A.job = null // If you get a job specific item selected, actually lets you buy it in the discount section
		A.species = null //same as above for species speific items
		A.reference = "DIS[newreference]"
		A.desc += " Limit of [A.limited_stock] per uplink. Normally costs [initial(A.cost)] TC."
		A.surplus = 0 // stops the surplus crate potentially giving out a bit too much
		A.item = I.item
		newreference++
		if(!uplink_items[A.category])
			uplink_items[A.category] = list()

		uplink_items[A.category] += A

	return uplink_items

// You can change the order of the list by putting datums before/after one another OR
// you can use the last variable to make sure it appears last, well have the category appear last.

/datum/uplink_item
	var/name = "item name"
	var/category = "item category"
	var/desc = "Item Description"
	var/reference = null
	var/item = null
	var/cost = 0
	var/last = 0 // Appear last
	var/abstract = 0
	var/list/uplinktypes = list() // Empty list means it is in all the uplink types. Otherwise place the uplink type here.
	var/list/excludefrom = list() // Empty list does nothing. Place the name of uplink type you don't want this item to be available in here.
	var/list/job = null
	/// This makes an item on the uplink only show up to the specified species
	var/list/species = null
	var/surplus = 100 //Chance of being included in the surplus crate (when pick() selects it)
	var/cant_discount = FALSE
	var/limited_stock = -1 // Can you only buy so many? -1 allows for infinite purchases
	var/hijack_only = FALSE //can this item be purchased only during hijackings?
	var/refundable = FALSE
	var/refund_path = null // Alternative path for refunds, in case the item purchased isn't what is actually refunded (ie: holoparasites).
	var/refund_amount // specified refund amount in case there needs to be a TC penalty for refunds.
	/// Our special little snowflakes that have to be spawned in a different way than normal, like a surplus crate spawning a crate or contractor kits
	var/uses_special_spawn = FALSE

/datum/uplink_item/proc/spawn_item(turf/loc, obj/item/uplink/U)

	if(hijack_only && !(usr.mind.special_role == SPECIAL_ROLE_NUKEOPS))//nukies get items that regular traitors only get with hijack. If a hijack-only item is not for nukies, then exclude it via the gamemode list.
		if(!(locate(/datum/objective/hijack) in usr.mind.get_all_objectives()) && U.uplink_type != UPLINK_TYPE_ADMIN)
			to_chat(usr, "<span class='warning'>The Syndicate will only issue this extremely dangerous item to agents assigned the Hijack objective.</span>")
			return

	U.uses -= max(cost, 0)
	U.used_TC += cost
	SSblackbox.record_feedback("nested tally", "traitor_uplink_items_bought", 1, list("[initial(name)]", "[cost]"))
	if(item && !uses_special_spawn)
		return new item(loc)

	return UPLINK_SPECIAL_SPAWNING

/datum/uplink_item/proc/description()
	if(!desc)
		// Fallback description
		var/obj/temp = src.item
		desc = replacetext(initial(temp.desc), "\n", "<br>")
	return desc

/datum/uplink_item/proc/buy_uplink_item(obj/item/uplink/hidden/U, mob/user, put_in_hands = TRUE)
	if(!istype(U))
		return

	if(user.stat || user.restrained())
		return

	if(!ishuman(user))
		return

	// If the uplink's holder is in the user's contents
	if((U.loc in user.contents || (in_range(U.loc, user) && isturf(U.loc.loc))))
		if(cost > U.uses)
			return


		var/obj/I = spawn_item(get_turf(user), U)

		if(!I || I == UPLINK_SPECIAL_SPAWNING)
			return // Failed to spawn, or we handled it with special spawning
		if(limited_stock > 0)
			limited_stock--
			log_game("[key_name(user)] purchased [name]. [name] was discounted to [cost].")
			if(!user.mind.special_role)
				message_admins("[key_name_admin(user)] purchased [name] (discounted to [cost]), as a non antagonist.")

		else
			log_game("[key_name(user)] purchased [name].")
			if(!user.mind.special_role)
				message_admins("[key_name_admin(user)] purchased [name], as a non antagonist.")

		if(istype(I, /obj/item/storage/box) && length(I.contents))
			for(var/atom/o in I)
				U.purchase_log += "<big>[bicon(o)]</big>"

		else
			U.purchase_log += "<big>[bicon(I)]</big>"

		if(put_in_hands)
			user.put_in_any_hand_if_possible(I)
		return I

/*
//
//	UPLINK ITEMS
//
*/
//Work in Progress, job specific antag tools

//Discounts (dynamically filled above)

/datum/uplink_item/discounts
	category = "Discounted Gear"

// DANGEROUS WEAPONS

/datum/uplink_item/dangerous
	category = "Highly Visible and Dangerous Weapons"

/datum/uplink_item/dangerous/pistol
	name = "FK-69 Stechkin Pistol"
	reference = "SPI"
	desc = "Маленький, легкоскрываемый пистолет, использующий патроны 10мм в магазине ёмкостью 8 пуль. Совместим с глушителями."
	item = /obj/item/gun/projectile/automatic/pistol
	cost = 20

/datum/uplink_item/dangerous/revolver
	name = "Syndicate .357 Revolver"
	reference = "SR"
	desc = "Брутально простой револьвер Синдиката, стреляющий пулятми калибра .357 Magnum, имеющий барабан на 7 пуль. Поставляется со спидлоадером."
	item = /obj/item/storage/box/syndie_kit/revolver
	cost = 65
	surplus = 50

/datum/uplink_item/dangerous/rapid
	name = "Gloves of the North Star"
	desc = "Эти перчатки позволяют очень быстро помогать, толкать, хватать и бить людей. Может быть совмещено с боевыми искусствами как смертоносное оружие"
	reference = "RPGD"
	item = /obj/item/clothing/gloves/fingerless/rapid
	cost = 40

/datum/uplink_item/dangerous/sword
	name = "Energy Sword"
	desc = "Энергетический меч - это меч с клинком из чистой энергии. В неактивном состоянии меч можно спрятать в кармане. Активация производит характерный громкий звук."
	reference = "ES"
	item = /obj/item/melee/energy/sword/saber
	cost = 40

/datum/uplink_item/dangerous/powerfist
	name = "Power Fist"
	desc = "Силовая перчатка - металическая перчатся со встроенной системой поршнево-таранной системой, используящая в качестве источника баллоны с газом. \
		При ударе цели, поршнево-таранная система выдвинется вперед, увеличивая урон от контакта. \
		Использование ключа на клапане поршня позволяет регулировать использование газа в баллоне для \
		нанесения увеличенного урона и отталкивания целей на большие расстояния. Использование отвёртки снимает баллон."
	reference = "PF"
	item = /obj/item/melee/powerfist
	cost = 50

/datum/uplink_item/dangerous/chainsaw
	name = "Chainsaw"
	desc = "Высокомощая бензопила для разрезания... ну вы понимаете чего..."
	reference = "CH"
	item = /obj/item/butcher_chainsaw
	cost = 65
	surplus = 0 // This has caused major problems with un-needed chainsaw massacres. Bwoink bait.

/datum/uplink_item/dangerous/universal_gun_kit
	name = "Universal Self Assembling Gun Kit"
	desc = "Универсальный оружейный набор, который можно совместить с любым оружейным набором, получая таким образом функционирующее оружие из РнД. Использует встроенные шестигранники для сборки, просто совместите наборы, ударив один об другой."
	reference = "IKEA"
	item = /obj/item/weaponcrafting/gunkit/universal_gun_kit
	cost = 25

/datum/uplink_item/dangerous/batterer
	name = "Mind Batterer"
	desc = "Опасное оружие синдиката, фокусирущееся на контроле толпы и побеге. Наносит урон мозгу, головокружение, а также другие неприятные эффекты на всех, кто находится рядом. Имеет пять зарядов."
	reference = "BTR"
	item = /obj/item/batterer
	cost = 25

/datum/uplink_item/dangerous/porta_turret
	name = "Portable Turret"
	desc = "Турель Синдиката, которая атакует любого, кто не взвёл гранату. Турель нельзя передвинуть после установки."
	reference = "MIS"
	item = /obj/item/grenade/turret
	cost = 20

// Ammunition

/datum/uplink_item/ammo
	category = "Ammunition"
	surplus = 40

/datum/uplink_item/ammo/pistol
	name = "Stechkin - 10mm Magazine"
	desc = "Дополнительный 8-зарядный 10мм магазин для пистолета Синдиката, заряженный дешевыми пулями, в половину уступающими пулям .357 калибра"
	reference = "10MM"
	item = /obj/item/ammo_box/magazine/m10mm
	cost = 3
	surplus = 0 // Miserable

/datum/uplink_item/ammo/pistolap
	name = "Stechkin - 10mm Armour Piercing Magazine"
	desc = "Дополнительный 8-зарядный 10мм магазин для пистолета Синдиката, заряженный пулями, которые менее эффективны в ранении жертвы, но пробивающие защитное снаряжение."
	reference = "10MMAP"
	item = /obj/item/ammo_box/magazine/m10mm/ap
	cost = 6
	surplus = 0 // Miserable

/datum/uplink_item/ammo/pistolfire
	name = "Stechkin - 10mm Incendiary Magazine"
	desc = "Дополнительный 8-зарядный 10мм магазин для пистолета Синдиката, заряженный зажигательными пулями, поджигающие цель."
	reference = "10MMFIRE"
	item = /obj/item/ammo_box/magazine/m10mm/fire
	cost = 9
	surplus = 0 // Miserable

/datum/uplink_item/ammo/pistolhp
	name = "Stechkin - 10mm Hollow Point Magazine"
	desc = "Дополнительный 8-зарядный 10мм магазин для пистолета Синдиката, заряженный пулями, которые наносят больше урона, но бесполезны против брони."
	reference = "10MMHP"
	item = /obj/item/ammo_box/magazine/m10mm/hp
	cost = 7
	surplus = 0 // Miserable

/datum/uplink_item/ammo/revolver
	name = ".357 Revolver - Speedloader"
	desc = "Спидлоадер, содержащий 7 пуль для револьвера .357 Синдиката. Когда вам нужно положить очень много вещей."
	reference = "357"
	item = /obj/item/ammo_box/a357
	cost = 15
	surplus = 0 // Miserable

// STEALTHY WEAPONS

/datum/uplink_item/stealthy_weapons
	category = "Stealthy and Inconspicuous Weapons"

/datum/uplink_item/stealthy_weapons/garrote
	name = "Fiber Wire Garrote"
	desc = "Длинное волокно с вдумя деревянными рукоятками, идеальна для тихого убийцы. Это оружие, будучи использовано на жертве со спины \
			моментально захватит обезмолвит её, вызывая быстрое удушье. Не сработает на тех, кому не требуется дыхание."
	item = /obj/item/garrote
	reference = "GAR"
	cost = 30

/datum/uplink_item/stealthy_weapons/cameraflash
	name = "Camera Flash"
	desc = "Флэш, замаскированный под камеру с самозарядной системой защиты от перегара. \
			Из-за дизайна, данный флэш не может быть перегружен как обычные флэши. \
			Полезна для оглушения киборгов, а также индивидов без защиты глаз или толпы для побега."
	reference = "CF"
	item = /obj/item/flash/cameraflash
	cost = 5

/datum/uplink_item/stealthy_weapons/throwingweapons
	name = "Box of Throwing Weapons"
	desc = "Коробка сюрикенов и усиленных бол из древнего Земного боевого искусства. Это очень эффективное \
			метательное оружие. Болы могут сбить человека с ног, а сюрикены гарантированно застревают в конечностях."
	reference = "STK"
	item = /obj/item/storage/box/syndie_kit/throwing_weapons
	cost = 15

/datum/uplink_item/stealthy_weapons/edagger
	name = "Energy Dagger"
	desc = "Клинок из энергии, функционирующий и выглядящий как ручка в выключенном состоянии."
	reference = "EDP"
	item = /obj/item/pen/edagger
	cost = 10

/datum/uplink_item/stealthy_weapons/foampistol
	name = "Toy Gun (with Stun Darts)"
	desc = "Безобидно выглядящий игрушечный пистолет, предназначенный для стрельбы вспененными зарядами. Поставляется заряженным с высококачественными дротиками для оглушения цели."
	reference = "FSPI"
	item = /obj/item/gun/projectile/automatic/toy/pistol/riot
	cost = 15
	surplus = 10

/datum/uplink_item/stealthy_weapons/false_briefcase
	name = "False Bottomed Briefcase"
	desc = "Модифицированный чемодан, способный хранить и стрелять оружием под ложным дном. Используйте отвёртку для открытия дна и модификации. Отличим при ближайшем рассмотрении из-за дополнительного веса."
	reference = "FBBC"
	item = /obj/item/storage/briefcase/false_bottomed
	cost = 10

/datum/uplink_item/stealthy_weapons/soap
	name = "Syndicate Soap"
	desc = "Зловеще выглядящий очиститель, используемый для очистки кровавых следов на месте убийства и предотвращения ДНК-тестов. Вы также можете бросать его под ноги людям."
	reference = "SOAP"
	item = /obj/item/soap/syndie
	cost = 5
	surplus = 50

/datum/uplink_item/stealthy_weapons/RSG
	name = "Rapid Syringe Gun"
	desc = "Быстрый шприцемёт Синдиката, способный стрелять шприцами автоматически из внутреннего хранилища реагентов. Поставляется с 7 заряженными пустыми шприцами, максимальная ёмкость в 14 шприцов и 300u реагентов"
	reference = "RSG"
	item = /obj/item/gun/syringe/rapidsyringe/preloaded/half
	cost = 60

/datum/uplink_item/stealthy_weapons/poisonbottle
	name = "Poison Bottle"
	desc = "Синдикат поставит вам один пузырёк с 40u случайного яда. Яд варьируется от очень раздражающего до невероятно смертельного."
	reference = "TPB"
	item = /obj/item/reagent_containers/glass/bottle/traitor
	cost = 10
	surplus = 0 // Requires another item to function.

/datum/uplink_item/stealthy_weapons/silencer
	name = "Universal Suppressor"
	desc = "Подходящий для любого оружия малого калибра с нарезным стволом, этот глушитель способен заглушить выстрелы для улучшенного стелса и преимущества в засадах."
	reference = "US"
	item = /obj/item/suppressor
	cost = 5
	surplus = 10

/datum/uplink_item/stealthy_weapons/dehy_carp
	name = "Dehydrated Space Carp"
	desc = "Просто добавьте воды для создания ручного карпа, враждебного ко всему. Выглядит как плюшевая игрушка. Первый человек, сжавший игрушку, будет считаться владельцем, на которого она не будет нападать. Если владельца нет, Оно будет атаковать вообще всех."
	reference = "DSC"
	item = /obj/item/toy/plushie/carpplushie/dehy_carp
	cost = 4

/datum/uplink_item/stealthy_weapons/knuckleduster
	name = "Syndicate Knuckleduster"
	desc = "Прямолинейный и достаточно легкоскрываемое оружие ближнего боя для избиения кого-либо в брутальном стиле. Конкретно это оружие по дизайну наносит сильный урон внутренним органам жерты."
	reference = "SKD"
	item = /obj/item/melee/knuckleduster/syndie
	cost = 10
	cant_discount = TRUE

// GRENADES AND EXPLOSIVES

/datum/uplink_item/explosives
	category = "Grenades and Explosives"

/datum/uplink_item/explosives/plastic_explosives
	name = "Composition C-4"
	desc = "С-4 это пластиковая взрывчатся, распространённая вариация композита С. Надёжно уничтожает объект на который установлен, за исключением взрывоустойчивыйх. Не липнет к членам экипажа. Уничтожит только напольные покрытия в случае установки на них. Есть настраиваемый таймер с минимумом в 10 секунд."
	reference = "C4"
	item = /obj/item/grenade/plastic/c4
	cost = 5

/datum/uplink_item/explosives/plastic_explosives_pack
	name = "Pack of 5 C-4 Explosives"
	desc = "Посылка, содержащая 5 взрывчаток С-4 по скидочной цене. Для тех случаев, когда для ваших саботажей требуется слегка больше."
	reference = "C4P"
	item = /obj/item/storage/box/syndie_kit/c4
	cost = 20

/datum/uplink_item/explosives/syndicate_minibomb
	name = "Syndicate Minibomb"
	desc = "Минибомба это граната с пятисекундным таймером"
	reference = "SMB"
	item = /obj/item/grenade/syndieminibomb
	cost = 30

/datum/uplink_item/explosives/frag_grenade
	name = "Fragmentation Grenade"
	desc = "Осколочная граната. При детонации выпускает шрапнель, втыкающуюся в ближайших жертв."
	reference = "FG"
	item = /obj/item/grenade/frag
	cost = 10

/datum/uplink_item/explosives/frag_grenade_pack
	name = "Набор из 5 осколочных гранат"
	desc = "Коробка с пятью осколочными гранатами.  При детонации выпускает шрапнель, втыкающуюся в ближайших жертв. И кажется вам требуется МНОГО жертв."
	reference = "FGP"
	item = /obj/item/storage/box/syndie_kit/frag_grenades
	cost = 40

/datum/uplink_item/explosives/pizza_bomb
	name = "Pizza Bomb"
	desc = "Коробка из под пиццы с бомбой, приклееной внутри. Сначала таймер надо настроить, открыв коробку; повторное открытие провоцирует детонацию."
	reference = "PB"
	item = /obj/item/pizzabox/pizza_bomb
	cost = 30
	surplus = 80

/datum/uplink_item/explosives/atmosn2ogrenades
	name = "Knockout Gas Grenades"
	desc = "Коробка с двумя (2) гранатами, распространяющими усыпляющий газ на большой территории. Включите внутренний баллон с воздухом перед их использованием."
	reference = "ANG"
	item = /obj/item/storage/box/syndie_kit/atmosn2ogrenades
	cost = 40

/datum/uplink_item/explosives/emp
	name = "EMP Grenades and bio-chip implanter Kit"
	desc = "Коробка, содержащая две ЭМИ гранаты и ЭМИ имплант на два использования. Полезно для отключения коммуникаций, \
			энергетического оружия СБ и синтетических форм жизни когда вас прижмут."
	reference = "EMPK"
	item = /obj/item/storage/box/syndie_kit/emp
	cost = 10

/datum/uplink_item/explosives/emp/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		cost *= 3

// STEALTHY TOOLS

/datum/uplink_item/stealthy_tools
	category = "Stealth and Camouflage Items"

/datum/uplink_item/stealthy_tools/chameleon_stamp
	name = "Chameleon Stamp"
	desc = "Штамп, который может быть использован для имитации оффициального штампа НаноТрэйзен. Замаскированный штамп будет работать точно также как настоящий, позволяя вам подделывать документы для получения дополнительных доступов и оборудования; \
	Также может быть использовано в стиральной машине для подделывания одежды."
	reference = "CHST"
	item = /obj/item/stamp/chameleon
	cost = 1
	surplus = 35

/datum/uplink_item/stealthy_tools/chameleonflag
	name = "Chameleon Flag"
	desc = "Флаг, который может быть замаскирован под любой известный флаг. Есть скрытое место в флагштоке для минирования гранатой или минибомбой, которая подорвётся через некоторое время после поджига флага."
	reference = "CHFLAG"
	item = /obj/item/flag/chameleon
	cost = 1
	surplus = 35

/datum/uplink_item/stealthy_tools/chamsechud
	name = "Chameleon Security HUD"
	desc = "Сворованный ХУД Службы Безопасности СБ с имплиментированной хамелеон технологией Синдиката. Сходно комбинезону хамелеон, ХУД может превратиться в любые очки, сохраняя свой функционал когда они надеты."
	reference = "CHHUD"
	item = /obj/item/clothing/glasses/hud/security/chameleon
	cost = 10

/datum/uplink_item/stealthy_tools/thermal
	name = "Thermal Chameleon Glasses"
	desc = "These glasses are thermals with Syndicate chameleon technology built into them. They allow you to see organisms through walls by capturing the upper portion of the infra-red light spectrum, emitted as heat and light by objects. Hotter objects, such as warm bodies, cybernetic organisms and artificial intelligence cores emit more of this light than cooler objects like walls and airlocks."
	reference = "THIG"
	item = /obj/item/clothing/glasses/chameleon/thermal
	cost = 15

/datum/uplink_item/stealthy_tools/agent_card
	name = "Agent ID Card"
	desc = "Карта агента предотвращает отслеживание носителя искусственным интеллектом, а также копировать доступы с других карт. Эффект суммируется, поэтому сканирование следующих карт не сбрасывает доступы с предыдущих."
	reference = "AIDC"
	item = /obj/item/card/id/syndicate
	cost = 10

/datum/uplink_item/stealthy_tools/chameleon_proj
	name = "Chameleon-Projector"
	desc = "Проецирует картинку на пользователя, маскируя их как просканированный объект пока проектор находится в руке. Замаскированный пользователь не может бегать и снаряды пролетают над ним."
	reference = "CP"
	item = /obj/item/chameleon
	cost = 25

/datum/uplink_item/stealthy_tools/chameleon_counter
	name = "Chameleon Counterfeiter"
	desc = "This device disguises itself as any object scanned by it. The disguise is not a perfect replica and can be noticed when examined by an observer."
	reference = "CC"
	item = /obj/item/chameleon_counterfeiter
	cost = 10

/datum/uplink_item/stealthy_tools/camera_bug
	name = "Camera Bug"
	desc = "Позволяет вам просматривать все камеры в сети для отслеживания цели. Также даёт 5 скрытых камер, позволяя вам удалённо смотреть за объектом, на который вы прицепили камеру."
	reference = "CB"
	item = /obj/item/storage/box/syndie_kit/camera_bug
	cost = 5
	surplus = 90

/datum/uplink_item/stealthy_tools/dnascrambler
	name = "DNA Scrambler"
	desc = "Сприц с одной инъекцией, меняющая имя и внешность на случайные. Более дешевая, но менее универсальная альтернатива карте агента и изменителю воздуха."
	reference = "DNAS"
	item = /obj/item/dnascrambler
	cost = 7

/datum/uplink_item/stealthy_tools/smugglersatchel
	name = "Smuggler's Satchel"
	desc = "Эта сумка достаточно тонкая для укладки между обшивкой и полом, отличная вещь для сокрытия ваших вещей. Поставляется с ломом и тайлом пола внутри."
	reference = "SMSA"
	item = /obj/item/storage/backpack/satchel_flat
	cost = 10
	surplus = 30

/datum/uplink_item/stealthy_tools/emplight
	name = "EMP Flashlight"
	desc = "Маленькое, самозарядное устройство ЭМИ, замаскированное под фонарик. Работает на короткой дистанции. \
		Полезно за счёт отключения наушников, камер,."
	reference = "EMPL"
	item = /obj/item/flashlight/emp
	cost = 20
	surplus = 30

/datum/uplink_item/stealthy_tools/emplight/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		cost *= 2.5

/datum/uplink_item/stealthy_tools/cutouts
	name = "Adaptive Cardboard Cutouts"
	desc = "Эти картонные аппликации покрыты тонким материалом, предотвращающее выветание и делает изображения более похожими на реальными. В наборе их 3, а также \
	баллончик с краской для смены облика."
	reference = "ADCC"
	item = /obj/item/storage/box/syndie_kit/cutouts
	cost = 1
	surplus = 20

/datum/uplink_item/stealthy_tools/safecracking
	name = "Safe-cracking Kit"
	desc = "Всё что вам требуется для открытия механического сейфа."
	reference = "SCK"
	item = /obj/item/storage/box/syndie_kit/safecracking
	cost = 5
	surplus = 0 // Far too objective specific.

/datum/uplink_item/stealthy_tools/handheld_mirror
	name = "Hand Held Mirror"
	desc = "Карманное зеркало. Позволяет вам меня причёску и особенности лица, от цвета до стиля, моментально, пока зеркало находится в руках."
	reference = "HM"
	item = /obj/item/handheld_mirror
	cost = 5

// DEVICE AND TOOLS

/datum/uplink_item/device_tools
	category = "Устройства и инструменты"
	abstract = 1

/datum/uplink_item/device_tools/emag
	name = "Cryptographic Sequencer"
	desc = "Криптографический секвенсор, также известный как емаг, это маленькая карта, открывающая скрытые возможности элнетронных устройств, искажает изначальные функции и характерно ломает системы безопасности."
	reference = "EMAG"
	item = /obj/item/card/emag
	cost = 30

/datum/uplink_item/device_tools/access_tuner
	name = "Access Tuner"
	desc = "Настройщик доступа - это  маленькое устройство, взаимодействующее со шлюзами на расстоянии. Этот процесс занимает несколько секунд и позволяет болтировать, открывать или переключать экстренный доступ."
	reference = "HACK"
	item = /obj/item/door_remote/omni/access_tuner
	cost = 30

/datum/uplink_item/device_tools/toolbox
	name = "Fully Loaded Toolbox"
	desc = "Подозрительный красно-чёрный ящик с инструментами Синдиката. Помимо инструментов, поставляется с изолированными перчатками и мультитулом."
	reference = "FLTB"
	item = /obj/item/storage/toolbox/syndicate
	cost = 5

/datum/uplink_item/device_tools/surgerybag
	name = "Syndicate Surgery Duffelbag"
	desc = "Хирургическая сумка Синдиката поставляется с полным набором хирургических инструментов, смирительной рубашкой и намордником. Сама сумка сделана из очень лёгких материалов, поэтому не будет замедлять вас, пока сумка на спине."
	reference = "SSDB"
	item = /obj/item/storage/backpack/duffel/syndie/med/surgery
	cost = 10

/datum/uplink_item/device_tools/bonerepair
	name = "Prototype Nanite Autoinjector"
	desc = "Украденный прототип с нанитами, лечащими всё тело. При инъекции выключает системы в теле, пока они оживляют органы и конечности."
	reference = "NCAI"
	item = /obj/item/reagent_containers/hypospray/autoinjector/nanocalcium
	cost = 10

/datum/uplink_item/device_tools/syndicate_teleporter
	name = "Experimental Syndicate Teleporter"
	desc = "Телепортатор Синдиката это переносное устройство, переносящее пользователя на 4-8 метров вперед. \
			Осторожно, телепортация в стену заставит телепортатор сделать экстренный параллельный телепорт, \
			но если экстренны телепорт даст сбой, он вас убьет. \
			Имеет четыре заряда, перезаряжается, гарантия истекает при воздействии ЭМИ. \
			Поставляется с хамелеон мезонами, чтобы вы оставались стильным, имея возможность видеть сквозь стены."
	reference = "TELE"
	item = /obj/item/storage/box/syndie_kit/teleporter
	cost = 40



//Space Suits and Hardsuits
/datum/uplink_item/suits
	category = "Space Suits and MODsuits"
	surplus = 10 //I am setting this to 10 as there are a bunch of modsuit parts in here that should be weighted to 10. Suits and modsuits adjusted below.

/datum/uplink_item/suits/space_suit
	name = "Syndicate Space Suit"
	desc = "Этот красно-черный скафандр Синдиката менее загруженный, чем варианты Нанотрэйзен, \
	помещается в рюкзак, а также имеет оружейный слот. Поставляется с баллоном воздуха. Но всё же, члены команды Нанотрейзен научены докладывать о \
	красно-черных скафандрах."
	reference = "SS"
	item = /obj/item/storage/box/syndie_kit/space
	cost = 20

/datum/uplink_item/suits/thermal
	name = "MODsuit Thermal Visor Module"
	desc = "Визор для МОДСьюта. Позволяет вам видеть живых существ через стены. Также даёт ночное зрение."
	reference = "MSTV"
	item = /obj/item/mod/module/visor/thermal
	cost = 15 // Don't forget, you need to get a modsuit to go with this
	surplus = 10 //You don't need more than

/datum/uplink_item/suits/night
	name = "MODsuit Night Visor Module"
	desc = "Визор для МОДСьюта. Позволяет вам лучше видеть в темноте."
	reference = "MSNV"
	item = /obj/item/mod/module/visor/night
	cost = 5 // It's night vision, rnd pumps out those goggles for anyone man.
	surplus = 10 //You don't need more than one

/datum/uplink_item/suits/plate_compression
	name = "MODsuit Plate Compression Module"
	desc = "A MODsuit module that lets the suit compress into a smaller size. Not compatible with storage modules, \
	you will have to take that module out first."
	reference = "MSPC"
	item = /obj/item/mod/module/plate_compression
	cost = 10

/datum/uplink_item/suits/chameleon_module
	name = "MODsuit Chameleon Module"
	desc = "A module using chameleon technology to disguise an undeployed modsuit as another object. Note: the disguise will not work once the modsuit is deployed, but can be toggled again when retracted."
	reference = "MSCM"
	item = /obj/item/mod/module/chameleon
	cost = 10

/datum/uplink_item/suits/noslip
	name = "MODsuit Anti-Slip Module"
	desc = "A MODsuit module preventing the user from slipping on water. Already installed in the uplink modsuits."
	reference = "MSNS"
	item = /obj/item/mod/module/noslip
	cost = 5

/datum/uplink_item/suits/springlock_module
	name = "Heavily Modified Springlock MODsuit Module"
	desc = "A module that spans the entire size of the MOD unit, sitting under the outer shell. \
		This mechanical exoskeleton pushes out of the way when the user enters and it helps in booting \
		up, but was taken out of modern suits because of the springlock's tendency to \"snap\" back \
		into place when exposed to humidity. You know what it's like to have an entire exoskeleton enter you? \
		This version of the module has been modified to allow for near instant activation of the MODsuit. \
		Useful for quickly getting your MODsuit on/off, or for taking care of a target via a tragic accident. \
		It is hidden as a DNA lock module. It will block retraction for 10 seconds by default to allow you to follow \
		up with smoke, but you can multitool the module to disable that."
	reference = "FNAF"
	item = /obj/item/mod/module/springlock/bite_of_87
	cost = 5
	surplus = 10

/datum/uplink_item/suits/hidden_holster
	name = "Hidden Holster Module"
	desc = "A holster module disguised to look like a tether module. Requires a modsuit to put it in of course. Gun not included."
	reference = "HHM"
	item = /obj/item/mod/module/holster/hidden
	cost = 5
	surplus = 10

/datum/uplink_item/suits/smoke_grenade
	name = "Smoke Grenade Module"
	desc = "A module that dispenses primed smoke grenades to disperse crowds."
	reference = "SGM"
	item = /obj/item/mod/module/dispenser/smoke
	cost = 10
	surplus = 10

/datum/uplink_item/device_tools/binary
	name = "Binary Translator Key"
	desc = "A key, that when inserted into a radio headset, allows you to listen to and talk with artificial intelligences and cybernetic organisms in binary. To talk on the binary channel, type :+ before your radio message."
	reference = "BITK"
	item = /obj/item/encryptionkey/binary
	cost = 25
	surplus = 75

/datum/uplink_item/device_tools/cipherkey
	name = "Syndicate Encryption Key"
	desc = "A key, that when inserted into a radio headset, allows you to listen to all station department channels as well as talk on an encrypted Syndicate channel."
	reference = "SEK"
	item = /obj/item/encryptionkey/syndicate
	cost = 10 //Nowhere near as useful as the Binary Key!
	surplus = 75

/datum/uplink_item/device_tools/hacked_module
	name = "Hacked AI Upload Module"
	desc = "When used with an upload console, this module allows you to upload priority laws to an artificial intelligence. Be careful with their wording, as artificial intelligences may look for loopholes to exploit."
	reference = "HAI"
	item = /obj/item/aiModule/syndicate
	cost = 15

/datum/uplink_item/device_tools/powersink
	name = "Power Sink"
	desc = "When screwed to wiring attached to an electric grid, then activated, this large device places excessive load on the grid, causing a stationwide blackout. The sink cannot be carried because of its excessive size. Ordering this sends you a small beacon that will teleport the power sink to your location on activation."
	reference = "PS"
	item = /obj/item/radio/beacon/syndicate/power_sink
	cost = 50

/datum/uplink_item/device_tools/singularity_beacon
	name = "Power Beacon"
	desc = "When screwed to wiring attached to an electric grid and activated, this large device pulls any \
			active gravitational singularities. This will not work when the engine is still \
			in containment. Because of its size, it cannot be carried. Ordering this \
			sends you a small beacon that will teleport the larger beacon to your location upon activation."
	reference = "SNGB"
	item = /obj/item/radio/beacon/syndicate
	cost = 10
	surplus = 0
	hijack_only = TRUE //This is an item only useful for a hijack traitor, as such, it should only be available in those scenarios.
	cant_discount = TRUE

/datum/uplink_item/device_tools/advpinpointer
	name = "Advanced Pinpointer"
	desc = "A pinpointer that tracks any specified coordinates, DNA string, high value item or the nuclear authentication disk."
	reference = "ADVP"
	item = /obj/item/pinpointer/advpinpointer
	cost = 20

/datum/uplink_item/device_tools/ai_detector
	name = "Artificial Intelligence Detector" // changed name in case newfriends thought it detected disguised ai's
	desc = "A functional multitool that turns red when it detects an artificial intelligence watching it or its holder. Knowing when an artificial intelligence is watching you is useful for knowing when to maintain cover."
	reference = "AID"
	item = /obj/item/multitool/ai_detect
	cost = 5

/datum/uplink_item/device_tools/jammer
	name = "Radio Jammer"
	desc = "When turned on this device will scramble any outgoing radio communications near you, making them hard to understand."
	reference = "RJ"
	item = /obj/item/jammer
	cost = 20


// IMPLANTS

/datum/uplink_item/bio_chips
	category = "Bio-chips"

/datum/uplink_item/bio_chips/freedom
	name = "Freedom Bio-chip"
	desc = "A bio-chip injected into the body and later activated manually to break out of any restraints or grabs. Can be activated up to 4 times."
	reference = "FI"
	item = /obj/item/bio_chip_implanter/freedom
	cost = 25

/datum/uplink_item/bio_chips/protofreedom
	name = "Prototype Freedom Bio-chip"
	desc = "A prototype bio-chip injected into the body and later activated manually to break out of any restraints or grabs. Can only be activated a singular time."
	reference = "PFI"
	item = /obj/item/bio_chip_implanter/freedom/prototype
	cost = 10

/datum/uplink_item/bio_chips/storage
	name = "Storage Bio-chip"
	desc = "A bio-chip injected into the body, and later activated at the user's will. It will open a small subspace pocket capable of storing two items."
	reference = "ESI"
	item = /obj/item/bio_chip_implanter/storage
	cost = 40

/datum/uplink_item/bio_chips/mindslave
	name = "Mindslave Bio-chip"
	desc = "A box containing a bio-chip implanter filled with a mindslave bio-chip that when injected into another person makes them loyal to you and your cause, unless of course they're already implanted by someone else. Loyalty ends if the implant is no longer in their system."
	reference = "MI"
	item = /obj/item/bio_chip_implanter/traitor
	cost = 50

/datum/uplink_item/bio_chips/adrenal
	name = "Adrenal Bio-chip"
	desc = "A bio-chip injected into the body, and later activated manually to inject a chemical cocktail, which has a mild healing effect along with removing and reducing the time of all stuns and increasing movement speed. Can be activated up to 3 times."
	reference = "AI"
	item = /obj/item/bio_chip_implanter/adrenalin
	cost = 40

/datum/uplink_item/bio_chips/stealthimplant
	name = "Stealth Bio-chip"
	desc = "This one-of-a-kind implant will make you almost invisible if you play your cards right. \
			On activation, it will conceal you inside a chameleon cardboard box that is only revealed once someone bumps into it."
	reference = "SI"
	item = /obj/item/bio_chip_implanter/stealth
	cost = 45

// CYBERNETICS

/datum/uplink_item/cyber_implants
	category = "Cybernetic Implants"

/datum/uplink_item/cyber_implants/hackerman_deck
	name = "Binyat Wireless Hacking System Autoimplanter"
	desc = "This implant will allow you to wirelessly emag from a distance. However, it will slightly burn you \
	on use, and will be quite visual as you are emaging the object. \
	Will not show on unupgraded body scanners. Incompatible with the Qani-Laaca Sensory Computer."
	reference = "HKR"
	item = /obj/item/autosurgeon/organ/syndicate/hackerman_deck
	cost = 30 // Probably slightly less useful than an emag with heat / cooldown, but I am not going to make it cheaper or everyone picks it over emag

/datum/uplink_item/cyber_implants/razorwire
	name = "Razorwire Spool Arm Implant Autoimplanter"
	desc = "A long length of monomolecular filament, built into the back of your hand. \
		Impossibly thin and flawlessly sharp, it should slice through organic materials with no trouble; \
		even from a few steps away. However, results against anything more durable will heavily vary."
	reference = "RZR"
	item = /obj/item/autosurgeon/organ/syndicate/razorwire
	cost = 20

// POINTLESS BADASSERY

/datum/uplink_item/badass
	category = "(Pointless) Badassery"
	surplus = 0

/datum/uplink_item/badass/syndiecigs
	name = "Syndicate Smokes"
	desc = "Strong flavor, dense smoke, infused with omnizine."
	reference = "SYSM"
	item = /obj/item/storage/fancy/cigarettes/cigpack_syndicate
	cost = 7

/datum/uplink_item/badass/syndiecash
	name = "Syndicate Briefcase Full of Cash"
	desc = "A secure briefcase containing 600 space credits. Useful for bribing personnel, or purchasing goods and services at lucrative prices. \
	The briefcase also feels a little heavier to hold; it has been manufactured to pack a little bit more of a punch if your client needs some convincing."
	reference = "CASH"
	item = /obj/item/storage/secure/briefcase/syndie
	cost = 5

/datum/uplink_item/badass/balloon
	name = "For showing that you are The Boss"
	desc = "A useless red balloon with the syndicate logo on it, which can blow the deepest of covers."
	reference = "BABA"
	item = /obj/item/toy/syndicateballoon
	cost = 100
	cant_discount = TRUE

/datum/uplink_item/badass/bomber
	name = "Syndicate Bomber Jacket"
	desc = "An awesome jacket to help you style on Nanotrasen with. The lining is made of a thin polymer to provide a small amount of armor. Does not provide any extra storage space."
	reference = "JCKT"
	item = /obj/item/clothing/suit/jacket/syndicatebomber
	cost = 3

/datum/uplink_item/badass/tpsuit
	name = "Syndicate Two-Piece Suit"
	desc = "A snappy two-piece suit that any self-respecting Syndicate agent should wear. Perfect for professionals trying to go undetected, but moderately armored with experimental nanoweave in case things do get loud. Comes with two cashmere-lined pockets for maximum style and comfort."
	reference = "SUIT"
	item = /obj/item/clothing/suit/storage/iaa/blackjacket/armored
	cost = 3

/datum/uplink_item/bundles_TC
	category = "Наборы и телекристаллы"
	surplus = 0
	cant_discount = TRUE

/datum/uplink_item/bundles_TC/telecrystal
	name = "Один Телекристалл"
	desc = "Telecrystal in its rawest and purest form; can be utilized on active uplinks to increase their telecrystal count."
	reference = "RTC"
	item = /obj/item/stack/telecrystal
	cost = 1

/datum/uplink_item/bundles_TC/telecrystal/five
	name = "5Телекристаллов"
	desc = "Five telecrystals in their rawest and purest form; can be utilized on active uplinks to increase their telecrystal count."
	reference = "RTCF"
	item = /obj/item/stack/telecrystal/five
	cost = 5

/datum/uplink_item/bundles_TC/telecrystal/twenty
	name = "20 Телекристалов"
	desc = "Twenty telecrystals in their rawest and purest form; can be utilized on active uplinks to increase their telecrystal count."
	reference = "RTCT"
	item = /obj/item/stack/telecrystal/twenty
	cost = 20

/datum/uplink_item/bundles_TC/telecrystal/fifty
	name = "50 Телекристаллов"
	desc = "Fifty telecrystals in their rawest and purest form; can be utilized on active uplinks to increase their telecrystal count."
	reference = "RTCB"
	item = /obj/item/stack/telecrystal/fifty
	cost = 50

/datum/uplink_item/bundles_TC/telecrystal/hundred
	name = "100 Телекристаллов"
	desc = "One-hundred telecrystals in their rawest and purest form; can be utilized on active uplinks to increase their telecrystal count."
	reference = "RTCH"
	item = /obj/item/stack/telecrystal/hundred
	cost = 100
