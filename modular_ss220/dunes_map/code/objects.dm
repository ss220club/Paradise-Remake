#define TRAIT_CUBE_IMPACTED "cubeimpacted"
#define MACHINERY_TRAIT "machinery"

/obj/item/reagent_containers/food/condiment/milk/empty
	list_reagents = null

/obj/item/reagent_containers/food/condiment/flour/empty
	list_reagents = null

/obj/item/reagent_containers/food/condiment/soymilk/empty
	list_reagents = null

/obj/item/reagent_containers/food/condiment/rice/empty
	list_reagents = null

/obj/item/reagent_containers/glass/bottle/nutrient/fuel
	name = "\improper канистра с топливом"
	desc = "Содержит в себе топливо. Пить не рекомендуется."
	possible_transfer_amounts = list(1,2,5,10,20,40,80,100)
	list_reagents = list("fuel" = 100)

/obj/structure/decorative_structures/corpse
	name = "\improper кровавое тело"
	icon = 'modular_ss220/dunes_map/icons/dead.dmi'
	icon_state = "deadbody"
	density = 0
	max_integrity = 5
	var/bloodtiles = 8  // number of tiles with blood while pulling

/obj/structure/decorative_structures/corpse/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/decorative_structures/corpse/Destroy()
	playsound(src, 'sound/goonstation/effects/gib.ogg', 30, 0)
	var/turf/T = get_turf(src)
	new /obj/effect/decal/cleanable/blood/gibs(T)
	new /obj/effect/decal/cleanable/blood(T)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/decorative_structures/corpse/attack_hand(mob/living/user)
	take_damage(pick(2,3), BRUTE, "melee")
	playsound(src, (pick('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg')), 20, 0)

/obj/structure/decorative_structures/corpse/play_attack_sound()
	return

/obj/structure/decorative_structures/corpse/do_climb()
	return

/obj/structure/decorative_structures/corpse/Move()
	. = ..()
	bloodtiles -= 1
	if(bloodtiles >= 0 && prob(40))
		new /obj/effect/decal/cleanable/blood(get_turf(src))

/obj/structure/decorative_structures/corpse/process()
	for(var/mob/living/carbon/human/H in range(4, src))
		if(prob(15))
			var/obj/item/clothing/mask/M = H.wear_mask
			if(M && (M.flags_cover & MASKCOVERSMOUTH))
				continue
			if(TRAIT_NOBREATH in H.dna.species.species_traits)
				continue
			to_chat(H, "<span class='warning'>Как же воняет...</span>")
			H.fakevomit()

/obj/structure/decorative_structures/corpse/dead1
	name = "\improper гниющий труп"
	icon_state = "deadbody3"
	desc = "Полуразложившийся труп. Ну и вонь."

/obj/structure/decorative_structures/corpse/dead2
	name = "\improper скелетированный труп"
	icon_state = "deadbody2"
	desc = "Его кости уже давно белеют на солнце..."
	bloodtiles = 0

/obj/structure/decorative_structures/corpse/dead2/Destroy()
	playsound(src, 'sound/effects/bone_break_4.ogg', 30, 0)
	var/turf/T = get_turf(src)
	new /obj/effect/decal/remains/human(T)
	STOP_PROCESSING(SSobj, src)
	..()

/obj/structure/decorative_structures/corpse/dead_on_cross
	name = "\improper шматок плоти"
	icon_state = "deadbody1"
	density = 1
	anchored = 1

/obj/structure/decorative_structures/corpse/dead_on_cross/dead2
	name = "\improper скелет на столбе"
	desc = "Он висит здесь уже очень давно. Бедолага."
	icon_state = "deadbody4"

/obj/structure/sink/kolodec
	name = "\improper колодец"
	desc = "Дна не видно. К тому же тут склизко... Главное не упасть..."
	icon = 'modular_ss220/dunes_map/icons/kolodec.dmi'
	icon_state = "kolodec"
	density = TRUE
	layer = ABOVE_MOB_LAYER
	var/drop_x = 1
	var/drop_y = 1
	var/drop_z = -1
	var/drop_chance = 0
	var/scorpion_chance = 8

/obj/structure/sink/kolodec/examine_more(mob/user)
	. = ..()
	. += "<span class='userdanger'>Если туда упасть - верная смерть.</span>"

/obj/structure/sink/kolodec/attack_hand(mob/user)
	if(!check_event(user))
		return
	. = ..()

/obj/structure/sink/kolodec/attackby(obj/item/O, mob/user, params)
	if(!check_event(user))
		return
	. = ..()

/obj/structure/sink/kolodec/proc/check_event(mob/user)
	to_chat(user, "<span class='userdanger'>Вы подходите вплотную к колодцу. Выглядит КРАЙНЕ небезопасно. Может, не стоит?</span>")
	if(!do_after_once(user, 3 SECONDS, target = src, attempt_cancel_message = "Вы передумали пользоваться колодцем."))
		return FALSE
	if(prob(drop_chance))
		drop(user)
		return FALSE
	else if(prob(scorpion_chance))
		var/scorpio = pick(typesof(/mob/living/simple_animal/hostile/poison/giant_scorpio))
		new scorpio(src.loc)
		visible_message("<span class='sinister'>Из колодца выполз скорпион. </span>")
		return FALSE
	else
		to_chat(user, "<span class='userdanger'>Вы едва не сорвались в колодец. А дна ведь даже и не видно...</span>")
		return TRUE

/obj/structure/sink/kolodec/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/largetransparency)

/obj/structure/sink/kolodec/MouseDrop_T(atom/movable/AM, mob/user)
	. = 0
	if(isliving(AM))
		visible_message("<span class='userdanger'>[user] начинает скидывать [AM] в колодец!!! </span>")
	if(!do_after(user, 3 SECONDS, target = src))
		return
	AM.forceMove(src.loc)
	var/thing_to_check = src
	if(AM)
		thing_to_check = list(AM)
	for(var/thing in thing_to_check)
		. = 1
		INVOKE_ASYNC(src, PROC_REF(drop), thing)

/obj/structure/sink/kolodec/proc/drop(atom/movable/AM)
	if(iscarbon(AM))
		playsound(AM.loc, 'modular_ss220/aesthetics_sounds/sound/wilhelm_scream.ogg', 50)

	if(!AM || QDELETED(AM))
		return
	AM.visible_message("<span class='boldwarning'>[AM] falls into [src]!</span>", "<span class='userdanger'>You stumble and stare into an abyss before you. It stares back, and you fall \
	into the enveloping dark.</span>")
	if(isliving(AM))
		var/mob/living/L = AM
		L.notransform = TRUE
		L.Weaken(20 SECONDS)
	animate(AM, transform = matrix() - matrix(), alpha = 0, color = rgb(0, 0, 0), time = 10)
	for(var/i in 1 to 5)
		//Make sure the item is still there after our sleep
		if(!AM || QDELETED(AM))
			return
		AM.pixel_y--
		sleep(2)

	//Make sure the item is still there after our sleep
	if(!AM || QDELETED(AM))
		return

	if(isliving(AM))
		var/mob/living/fallen_mob = AM
		fallen_mob.notransform = FALSE
		if(fallen_mob.stat != DEAD)
			fallen_mob.adjustBruteLoss(500) //crunch from long fall, want it to be like legion in damage
			log_admin("[key_name(fallen_mob)] упал в колодец! Руку приложил: [key_name(usr)]")
			message_admins("[key_name_admin(fallen_mob)] упал в колодец! Руку приложил: [key_name_admin(usr)]")
		return
	for(var/mob/M in AM.contents)
		M.forceMove(src)
	qdel(AM)

/obj/machinery/power/port_gen/pacman/wood
	sheet_path = /obj/item/stack/sheet/wood
	sheet_name = "Wooden Planks"
	time_per_sheet = 25 // same power output, but a 50 sheet stack will last 2 hours at max safe power
	max_sheets = 50
	power_gen = 5000
	max_power_output = 1
	max_safe_output = 1

//car wreck

/obj/structure/decorative_structures/car_wreck
	name = "\improper остов машины"
	desc = "Заржавевший и выпотрошенный наземный транспорт, который активно использовался несколько веков назад."
	icon = 'modular_ss220/dunes_map/icons/wrecks_1.dmi'
	icon_state = "helper"
	anchored = TRUE
	layer = ABOVE_ALL_MOB_LAYER
	max_integrity = 50

/obj/structure/decorative_structures/car_wreck/Initialize(mapload)
	. = ..()
	var/list/car_types = list("coupe", "muscle", "sport", "van")
	icon_state = "[pick(car_types)]-[rand(1,5)]"
	AddComponent(/datum/component/largetransparency, 0, 1, 2, 0)
	bound_width = 96
	bound_height = 32

//statues and stuff

/obj/structure/fluff/desert_construction
	name = "окаменелые останки"
	desc = "Останки какой-то огромной допотопной твари."
	icon = 'modular_ss220/dunes_map/icons/statuelarge.dmi'
	icon_state = "rib"
	density = TRUE
	deconstructible = FALSE
	max_integrity = 500
	layer = ABOVE_MOB_LAYER

/obj/structure/fluff/desert_construction/depred_boss
	name = "маяк депредаторов"
	desc = "Ваше приключение оканчивается здесь. Его исход зависит только от Вас."
	icon = 'modular_ss220/dunes_map/icons/marker_giant.dmi'
	icon_state = "marker_giant_active_anim"
	pixel_x = -32
	max_integrity = 2000
	light_power = 2
	light_range = 20
	light_color = COLOR_MAROON

/obj/structure/fluff/desert_construction/holomap
	name = "Голокарта Хирки"
	desc = "Актуальная карта планеты с подробностями региона Убежища."
	icon = 'modular_ss220/dunes_map/icons/statuelarge.dmi'
	icon_state = "holo_map"

/obj/structure/fluff/desert_construction/skull1
	name = "окаменелый череп"
	desc = "Череп какой-то огромной допотопной твари."
	icon_state = "skull"

/obj/structure/fluff/desert_construction/skull2
	name = "окаменелые череп"
	desc = "Череп какой-то огромной допотопной твари."
	icon_state = "skull-half"

/obj/structure/fluff/desert_construction/ribs
	name = "останки"
	desc = "Белеющие на солнце кости местной фауны."
	icon_state = "rib_white"

/obj/structure/fluff/desert_construction/stone1
	name = "скала"
	desc = "Массивный каменный обломок."
	icon_state = "stone1"

/obj/structure/fluff/desert_construction/stone2
	name = "скала"
	desc = "Массивный каменный обломок."
	icon_state = "stone2"

/obj/structure/fluff/desert_construction/obelisk1
	name = "обелиск"
	desc = "Древний обелиск из песчанника, обтесанный и расписаный неизвестными иероглифами."
	icon_state = "obelisk"

/obj/structure/fluff/desert_construction/altar
	name = "кубический алтарь"
	desc = "Геометрически правильное сооружение из черного камня, испускающее тусклый красный свет."
	icon_state = "cube"

/obj/structure/fluff/desert_construction/head1
	name = "массивный каменный бюст"
	desc = "Голова отвратительной твари, выбитая в камне."
	icon_state = "head1"

/obj/structure/fluff/desert_construction/head1/black
	icon_state = "head1_black"

/obj/structure/fluff/desert_construction/crushedhead
	name = "разрушенный бюст"
	desc = "Останки некогда массивной статуи, поддашвейся неумолимой стихии."
	icon_state = "crushedhead"

/obj/structure/fluff/desert_construction/column1
	name = "колонна"
	desc = "Колонна из песчаника."
	icon_state = "column4"

/obj/structure/fluff/desert_construction/column2
	name = "обломок колонны"
	desc = "Разрушенная колонна из песчаника."
	icon_state = "column5"

/obj/structure/fluff/desert_construction/red_rocks
	name = "камень"
	desc = "Небольшой обломок красного песчаника."
	icon_state = "rock"
	density = FALSE
	layer = BELOW_MOB_LAYER

/obj/structure/fluff/desert_construction/red_rocks/Initialize(mapload)
	. = ..()
	icon_state = "[pick("rock")]-[rand(1,4)]"

/obj/structure/fluff/desert_construction/black_obelisk1
	name = "поврежденный чёрный обелиск"
	desc = "Разрушенный ужасающий черный обелиск, несущий запретные знания в своих письменах"
	icon_state = "black_obelisk"

/obj/structure/fluff/desert_construction/huge_columns
	name = "колонна"
	desc = "Колонна из песчаника."
	icon = 'modular_ss220/dunes_map/icons/columns.dmi'
	icon_state = "column1"

/obj/structure/fluff/desert_construction/huge_columns/column3
	name = "колонна"
	desc = "Полуразрушенная колонна из песчаника."
	icon_state = "column3"

/obj/structure/fluff/desert_construction/huge_columns/column4
	name = "колонна"
	desc = "Каменная колонна."
	icon_state = "column2"

/obj/structure/fluff/desert_construction/huge_columns/black_obelisk2
	name = "чёрный обелиск"
	desc = "Ужасающий черный обелиск, несущий запретные знания в своих письменах"
	icon_state = "black_obelisk2"

/obj/structure/fluff/desert_construction/huge_columns/statue1
	name = "монструозная статуя"
	desc = "Статуя отвратительной твари выполненная из черного камня."
	icon_state = "ugly_statue1"

/obj/structure/fluff/desert_construction/huge_head
	name = "огромный каменный бюст"
	desc = "Вы никогда не видели чего-то более устрашающего и омерзительного."
	icon = 'modular_ss220/dunes_map/icons/hugehead.dmi'
	icon_state = "head2"
	max_integrity = 1000
	pixel_x = -16

/obj/structure/fluff/desert_construction/huge_head/black
	icon_state = "head2_black"

/obj/structure/fluff/desert_construction/huge_head/statue2
	name = "монструозная статуя"
	desc = "Статуя отвратительной твари выполненная из черного камня."
	icon_state = "ugly_statue2"

/obj/structure/statue/sandstone/assistant/village
	name = "Статуя молодого Грейхма Сайлмана"
	desc = "Легендарная личность для каждого выходца с Хирки."
	icon = 'modular_ss220/dunes_map/icons/statuelarge.dmi'
	icon_state = "statue_village"
	pixel_y = 10

//barricade
/obj/structure/barricade/beton
	name = "бетонный фундаментный блок"
	desc = "Здоровое бетонное ограждение. Поможет в качестве укрытия."
	icon = 'modular_ss220/dunes_map/icons/barricade.dmi'
	icon_state = "concrete_block"
	base_icon_state = "concrete_block"
	max_integrity = 300
	proj_pass_rate = 10
	pass_flags = LETPASSTHROW
	climbable = TRUE
	stacktype = null

//bars
/obj/structure/bars
	name = "решетка"
	desc = "Решетка камеры из пластали. Вряд ли её получится сломать."
	icon = 'modular_ss220/dunes_map/icons/bars.dmi'
	icon_state = "bars_wall"
	opacity = FALSE
	anchored = TRUE
	can_be_unanchored = FALSE
	density = TRUE
	max_integrity = INFINITY
	obj_integrity = INFINITY

// надо сделать или блок для вида (открыть могут только киданы) или по направлению (открыть только с dir 2)
/obj/structure/mineral_door/bars_door
	name = "решетчатая дверь"
	desc = "Вряд ли её получится сломать."
	icon = 'modular_ss220/dunes_map/icons/bars.dmi'
	icon_state = "bars"
	sheetType = /obj/item/stack/rods
	max_integrity = INFINITY
	obj_integrity = INFINITY

//flask
/obj/item/reagent_containers/drinks/flask/desert
	name = "кожаная фляжка"
	desc = "Кожаная походная фляжка кочевых народов пустыни."
	icon = 'modular_ss220/dunes_map/icons/flask.dmi'
	icon_state = "flask_leather"
	materials = list()
	volume = 80

/obj/item/reagent_containers/drinks/flask/desert/chai
	name = "медный чайник"
	desc = "Медный чайник для кипячения воды и приготовления горячих напитков."
	icon = 'modular_ss220/dunes_map/icons/flask.dmi'
	icon_state = "chai"
	volume = 50
	resistance_flags = FIRE_PROOF

/obj/item/reagent_containers/drinks/flask/ntpremium
	name = "подарочная фляжка"
	desc = "Фляжка с небольшой гравировкой ''NT'', так удачно подаренная компанией неделю назад."
	icon_state = "flask"
	volume = 50
	resistance_flags = FIRE_PROOF

//torch
/obj/structure/wall_torch
	name = "настенный факел"
	desc = "Древний и ненадежный способ освещения помещений."
	icon = 'modular_ss220/dunes_map/icons/walltorch.dmi'
	icon_state = "torchwall"
	anchored = TRUE
	max_integrity = 50
	obj_integrity = 50
	density = FALSE
	light_power = 1
	light_range = 5
	light_color = COLOR_DARK_ORANGE

/obj/structure/wall_torch/Destroy()
	var/turf/T = get_turf(src)
	new /obj/item/flashlight/flare/torch(T)
	STOP_PROCESSING(SSobj, src)
	..()

//mine
/obj/effect/mine/explosive/desert
	icon = 'modular_ss220/dunes_map/icons/mine.dmi'
	icon_state = "desertminearmed"
	faction = list("raider")
	range_heavy = 1
	range_light = 3
	range_flash = 4
	layer = LOW_OBJ_LAYER

//ID card's
/obj/item/card/id/away/kidan
	name = "самодельная идентификационная карта"
	desc = "Грубо припаянный микрочип и пара магнитных полос на пластиковой карточке."
	icon_state = "data"

/obj/item/card/id/away/kidan/Initialize(mapload)
	. = ..()
	var/kidan_name = list (
		"Лопух", "Локатор", "Костыль", "Горбун", "Кубышка", "Мотыль", "Котелок", "Бацилла", "Жаба", "Ворона", "Крыса", "Амеба", "Глиста", "Аскарида",  "Гвоздь", "Робинзон", "Курортник", "Фунт", "Гульден", "Тугрик", "Махно", "Бугор", "Змей", "Лютый", "Шайба", "Мазай", "Абу",
		)
	registered_name = "[pick (kidan_name)]"
	access = list(ACCESS_AWAY01)

/obj/item/card/id/centcom/tanya
	name = "Дельта 8-1-7's ID card (Normandy Special Forces)"
	desc = "An ID straight from Normandy Special Forces."
	icon_state = "centcom"
	registered_name = "Дельта 8-1-7"
	assignment = "Normandy Special Forces"
	rank = "Normandy Special Forces"

/obj/item/card/id/midnight
	name = "Миднайт Блэк's ID card (Syndicate Special Agent)"
	desc = "An ID straight from Syndicate."
	registered_name = "Миднайт Блэк"
	assignment = "Syndicate Special Agent"
	rank = "Syndicate Special Agent"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER, ACCESS_SYNDICATE_COMMAND, ACCESS_EXTERNAL_AIRLOCKS)

//sign
/obj/structure/warn_sign
	name = "предупреждающий знак"
	desc = "Ничего хорошего он не говорит..."
	icon = 'modular_ss220/dunes_map/icons/warn.dmi'
	icon_state = "warn"
	density = FALSE
	max_integrity = 5
	anchored = TRUE
	layer = ABOVE_MOB_LAYER

//telecrystal
/obj/structure/telecrystal_deposit
	name = "отложение телекристаллов"
	desc = "Естественные наросты телекристаллов."
	icon = 'modular_ss220/dunes_map/icons/crystal.dmi'
	icon_state = "crystal1"
	anchored = TRUE
	layer = LOW_OBJ_LAYER
	density = FALSE
	max_integrity = 30
	light_power = 2
	light_range = 5
	light_color = COLOR_MAROON

/obj/structure/telecrystal_deposit/Destroy()
	playsound(src, 'sound/effects/pylon_shatter.ogg', 30, 0)
	var/turf/T = get_turf(src)
	new /obj/item/stack/telecrystal/five/native(T)
	..()

/obj/structure/telecrystal_deposit/mini
	icon_state = "crystal3"
	max_integrity = 10
	light_power = 5
	light_range = 1.5

/obj/structure/telecrystal_deposit/medium
	icon = 'icons/effects/vampire_effects.dmi'
	icon_state = "blood_barrier"
	max_integrity = 20
	layer = ABOVE_MOB_LAYER
	density = TRUE

/obj/structure/telecrystal_deposit/huge
	icon_state = "crystal2"
	max_integrity = 50
	light_power = 3
	light_range = 4
	layer = ABOVE_MOB_LAYER
	density = TRUE

/obj/item/stack/telecrystal/five/native
	name = "телекристалл"
	desc = "Его пульсация одновременно приманивает и настораживает."
	icon = 'modular_ss220/dunes_map/icons/crystal.dmi'
	icon_state = "native"
	dynamic_icon_state = FALSE

/obj/item/storage/box/survival/redneck
	icon = 'modular_ss220/aesthetics/boxes/icons/boxes.dmi'
	icon_state = "dnakit"

/obj/item/storage/box/survival/redneck/populate_contents()
	new /obj/item/tank/internals/emergency_oxygen/double(src)
	new /obj/item/reagent_containers/drinks/flask/desert(src)
	new /obj/item/kitchen/knife/combat/survival(src)
	new /obj/item/flashlight/flare(src)
	new /obj/item/stack/medical/bruise_pack/comfrey(src)
	new /obj/item/stack/medical/ointment/aloe(src)

//sarcophagus

/obj/structure/closet/coffin/sarcophagus/full

/obj/structure/closet/coffin/sarcophagus/full/populate_contents()
	new /obj/effect/mob_spawn/human/corpse/skeleton(src)

//Midniht suit storage

// Tanya camera
/obj/structure/tanya_camera
	name = "Колба с Дельта 8-1-7"
	desc = "Этот юнит еще не готов..."
	icon = 'modular_ss220/dunes_map/icons/tanya.dmi'
	icon_state = "clone"
	density = TRUE
	max_integrity = 20
	layer = HITSCAN_LAYER
	var/breaksound = "shatter"
	anchored = TRUE

/obj/structure/tanya_camera/main
	name = "Колба с оригинальной Таней"
	desc = "Безобидное создание стало оружием уничтожения. Как иронично."
	icon_state = "tanya"
	max_integrity = 50

/obj/structure/tanya_broken
	name = "Разбитая колба"
	desc = "Все еще не идеальна."
	icon = 'modular_ss220/dunes_map/icons/tanya.dmi'
	icon_state = "tanya_broken"
	density = TRUE
	max_integrity = 200
	layer = HITSCAN_LAYER
	anchored = TRUE

/obj/structure/tanya_camera/Destroy()
	playsound(src, breaksound, 30, 0)
	var/turf/T = get_turf(src)
	new /obj/effect/decal/cleanable/glass(T)
	new /obj/effect/gibspawner/robot(T)
	new /obj/effect/decal/cleanable/blood/gibs/body(T)
	new /obj/structure/tanya_broken(T)
	..()

// kidan radio
/obj/item/radio/kidan
	name = "suspecious handheld radio"
	desc = "A suspecious shortwave radio. This model is painted in reddish colors, there is some numbers and letters on back of it."
	icon = 'modular_ss220/devices/icons/radio.dmi'
	icon_state = "walkietalkie_syndie"
	frequency = RADIO_LOW_FREQ

//cube and VSA

/obj/item/stock_parts/cell/cube
	name = "Куб"
	desc = "Легендарный артефакт, Куб. Пожалуй, самый ценный в обитаемой Галактике. Его гладкая поверхность холодно поблёскивает чернотой."
	maxcharge = 500000
	chargerate = 100
	icon = 'modular_ss220/dunes_map/icons/cube.dmi'
	icon_state = "empty"
	item_state = "empty"
	lefthand_file = 'modular_ss220/dunes_map/icons/cube_left.dmi'
	righthand_file = 'modular_ss220/dunes_map/icons/cube_right.dmi'
	var/charged_type = "charged"
	var/list/mob_name_to_charged_type = list("Миднайт Блэк" = "midn", "Мунивёрс Нормандия" = "norm")

/obj/item/stock_parts/cell/cube/process()
	if(percent() == 100)
		icon_state = charged_type
		item_state = charged_type
	else
		icon_state = "empty"
		item_state = "empty"

/obj/item/stock_parts/cell/cube/New()
	. = ..()
	charge = 0

/obj/item/stock_parts/cell/cube/pickup(mob/user)
	. = ..()
	var/charge_level = percent()
	if(charge_level < 100)
		return

	charged_type = mob_name_to_charged_type[user.name] || initial(charged_type)
	icon_state = charged_type
	item_state = charged_type

	user.regenerate_icons()

/obj/item/stock_parts/cell/cube/dropped(mob/user, silent)
	. = ..()
	charged_type = initial(charged_type)

/obj/item/stock_parts/cell/cube/Destroy()
	empulse(get_turf(loc), 4, 10, 1)
	explosion(get_turf(loc), 0, 0, 20, 0)
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(H.name == "Миднайт Блэк")
			qdel(H)
			return
	return ..()

/obj/structure/shipping_container
	name = "грузовой контейнер"
	desc = "Стандартный контейнер для транспортировки грузов. Этот без маркировки, поэтому информации о его содержимом нет."
	icon = 'modular_ss220/dunes_map/icons/containers.dmi'
	icon_state = "container_blank"
	max_integrity = 1000
	density = TRUE
	anchored = TRUE
	layer = 4.6

/obj/structure/shipping_container/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/largetransparency, 0, 1, 2, 0)
	bound_width = 96
	bound_height = 32

/obj/structure/shipping_container/conarex
	name = "\improper грузовой контейнер Космического Бюро Контарекс"
	desc = "Стандартный контейнер для транспортировки грузов. Этот принадлежит Космическому Бюро Контарекс и, скорее всего, используется для перевозки частей космических кораблей (или очередных коррупционных скандалов)."
	icon_state = "conarex"

/obj/structure/shipping_container/conarex/corrosion
	icon_state = "conarex_corrosion"
	desc = "Стандартный контейнер для транспортировки грузов. Этот принадлежит Космическому Бюро Контарекс и, скорее всего, используется для перевозки частей космических кораблей (или очередных коррупционных скандалов). Ни первого, ни второго вы в этом старье не найдете."

/obj/structure/shipping_container/kosmologistika
	name = "\improper грузовой контейнер Космологистики"
	desc = "Стандартный контейнер для транспортировки грузов. Этот принадлежит Космологистике - грузотранспортной компании СССП, используемой в пространствах других космических государств."
	icon_state = "kosmologistika"

/obj/structure/shipping_container/kosmologistika/corrosion
	icon_state = "kosmologistika_corrosion"
	desc = "Стандартный контейнер для транспортировки грузов. Этот принадлежит Космологистике - грузотранспортной компании СССП, используемой в пространствах других космических государств. Сейчас это старье может разве что послужить временным убежищем."

/obj/structure/shipping_container/nanotrasen
	name = "\improper грузовой контейнер корпорации Нанотрейзен"
	desc = "Стандартный контейнер для транспортировки грузов. Этот промаркирован логотипом Нанотрейзен, поэтому внутри может быть что угодно."
	icon_state = "nanotrasen"

/obj/structure/shipping_container/nanotrasen/corrosion
	icon_state = "nanotrasen_corrosion"
	desc = "Стандартный контейнер для транспортировки грузов. Этот промаркирован логотипом Нанотрейзен, поэтому внутри может быть что угодно. Учитывая его состояние, вы вряд ли найдете что-то стоящее."

/obj/structure/shipping_container/deforest
	name = "\improper грузовой контейнер медицинской корпорации ДеФорест"
	desc = "Стандартный контейнер для транспортировки грузов. Этот принадлежит ДеФорест, внутри него - медицинское оборудование."
	icon_state = "deforest"

/obj/structure/shipping_container/deforest/corrosion
	icon_state = "deforest_corrosion"
	desc = "Стандартный контейнер для транспортировки грузов. Этот принадлежит ДеФорест, внутри него - медицинское оборудование. Во всяком случае, было раньше."

/obj/structure/shipping_container/interdyne
	name = "\improper грузовой контейнер компании Интердайн"
	desc = "Стандартный контейнер для транспортировки грузов. Этот принадлежит фармкомпании Интердайн и используется для перевозки исключительно лицензированных препаратов."
	icon_state = "interdyne"

/obj/structure/shipping_container/interdyne/corrosion
	icon_state = "interdyne_corrosion"
	desc = "Стандартный контейнер для транспортировки грузов. Этот принадлежит фармкомпании Интердайн и используется для перевозки исключительно лицензированных препаратов. Сейчас в нем ничего нет."

/obj/structure/shipping_container/nakamura
	name = "\improper грузовой контейнер бюро Накимура"
	desc = "Стандартный контейнер для транспортировки грузов. Такие используются инженерным бюро Накимура и перевозят оборудование для тяжелой промышленности."
	icon_state = "nakamura"

/obj/structure/shipping_container/nakamura/corrosion
	icon_state = "nakamura_corrosion"
	desc = "Стандартный контейнер для транспортировки грузов. Такие используются инженерным бюро Накимура и перевозят оборудование для тяжелой промышленности. Сейчас это лишь проржавевший остов."

/obj/structure/shipping_container/nthi
	name = "\improper грузовой контейнер ГДпНТ"
	desc = "Стандартный контейнер для транспортировки грузов. Этот принадлежит Горнодобывающему подразделению Нанотрейзен, которое специализируется на разработке и добыче полезных ископаемых."
	icon_state = "nthi"

/obj/structure/shipping_container/nthi/corrosion
	icon_state = "nthi_corrosion"
	desc = "Стандартный контейнер для транспортировки грузов. Этот принадлежит Горнодобывающему подразделению Нанотрейзен, которое специализируется на разработке и добыче полезных ископаемых. Сейчас в нем ничего нет."

//Syndies
/obj/structure/shipping_container/cybersun
	name = "\improper грузовой контейнер корпорации Киберсана"
	desc = "Стандартный контейнер для транспортировки грузов. На нем виден логотип Киберсана, поэтому внутри него может находится все что угодно."
	icon_state = "cybersun"

/obj/structure/shipping_container/cybersun/corrosion
	icon_state = "cybersun_corrosion"
	desc = "Стандартный контейнер для транспортировки грузов. На нем виден логотип Киберсана, поэтому внутри него может находится все что угодно. Не стоит даже пытаться его вскрывать."

/obj/structure/shipping_container/donk_co
	name = "\improper грузовой контейнер Донк&Софт"
	desc = "Стандартный контейнер для транспортировки грузов. В подобных перевозят всю продукцию Донк&Софт, чаще всего - Donk Pockets."
	icon_state = "donk"

/obj/structure/shipping_container/donk_co/corrosion
	icon_state = "donk_corrosion"
	desc = "Стандартный контейнер для транспортировки грузов. В подобных перевозят всю продукцию Донк&Софт, чаще всего - Donk Pockets. В этом ржавом контейнере ничего не осталось."

/obj/structure/shipping_container/gorlex
	name = "\improper грузовой контейнер корпорации Горлекс"
	desc = "Стандартный контейнер для транспортировки грузов. Этот промаркирован логотипом корпорации Горлекс, а значит внутри может быть только одно - военные преступления."
	icon_state = "gorlex"

/obj/structure/shipping_container/gorlex/corrosion
	icon_state = "gorlex_corrosion"
	desc = "Стандартный контейнер для транспортировки грузов. Этот промаркирован логотипом корпорации Горлекс, а значит внутри может быть только одно - военные преступления. Но даже их вам не удастся найти в этом древнем контейнере."

/obj/structure/shipping_container/desert_nt
	icon_state = "nanotrasen_corrosion_1"

/obj/structure/shipping_container/desert_other
	icon_state = "gorlex_corrosion_1"

/obj/structure/shipping_container/desert_nt/Initialize(mapload)
	. = ..()
	icon_state = "nanotrasen_corrosion_[rand(1,3)]"
	AddComponent(/datum/component/largetransparency, 0, 1, 2, 0)
	bound_width = 96
	bound_height = 32
	desc = "Стандартный контейнер для транспортировки грузов. Истертый логотип Нанотрейзен все еще узнаваем, а это значит, что внутри может быть все что угодно. Хотя, учитывая его состояние, вы вряд ли найдете что-то стоящее."

/obj/structure/shipping_container/desert_other/Initialize(mapload)
	. = ..()
	var/list/container_type = list("gorlex_corrosion", "donk_corrosion", "kosmologistika_corrosion", "conarex_corrosion", "cybersun_corrosion", "deforest_corrosion", "interdyne_corrosion", "nakamura_corrosion", "nthi_corrosion")
	icon_state = "[pick(container_type)]_[rand(1,3)]"
	AddComponent(/datum/component/largetransparency, 0, 1, 2, 0)
	bound_width = 96
	bound_height = 32
	desc = "Стандартный контейнер для транспортировки грузов. Маркировочный логотип давно стерся и о его бывших владельцах остается лишь гадать. В любом случае, в этом проржавевшем контейнере не осталось ничего полезного."

/obj/structure/nt_ship
	name = "Десантный корабль Нанотрейзен"
	desc = "Многофункциональный десантный корабль, разработанный Департаментом Защиты Активов для проведения быстрых штурмовых операций. На этом судне опознавательные знаки Отдела Специальных Операций системы Эпсилон Эридана."
	icon = 'modular_ss220/dunes_map/icons/nt_shuttle.dmi'
	icon_state = "nt_ship_down"
	max_integrity = INFINITY
	density = TRUE
	anchored = TRUE
	layer = ABOVE_ALL_MOB_LAYER

/obj/structure/nt_ship/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/largetransparency, 0, 1, 3, 0)
	bound_width = 128
	bound_height = 64

/obj/structure/nt_ship/open
	icon_state = "nt_ship_down_open"

/obj/structure/nt_ship/fly
	icon_state = "nt_ship"

/obj/structure/nt_ship/fly/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/largetransparency, 0, 1, 3, 0)
	bound_width = 128
	bound_height = 64
	animate(src, pixel_y = 10, time = 40, loop = -1, easing = SINE_EASING)
	animate(pixel_y = 0, time = 40, loop = -1, easing = SINE_EASING)

/obj/structure/nt_ship/fly/fly_open
	icon_state = "nt_ship_open"

/obj/item/organ/internal/cyberimp/chest/hydration/hardened
	name = "Hardened Hydration pump implant"
	desc = "A military-grade version of the standard implant, for more elite forces."
	emp_proof = TRUE

/obj/structure/closet/syndicate/nuclear/duna
	name = "armoury closet"
	desc = "It's a storage unit for a Syndicate boarding party."

/obj/structure/closet/syndicate/nuclear/populate_contents()
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/smgm45(src)
	new /obj/item/ammo_box/magazine/smgm45(src)
	new /obj/item/ammo_box/magazine/uzim9mm(src)
	new /obj/item/storage/box/teargas(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/storage/backpack/duffel/syndie/med(src)
	new /obj/item/tank/jetpack/oxygen/harness(src)
	new /obj/item/gun/projectile/automatic/shotgun/bulldog(src)
	new /obj/item/gun/projectile/automatic/shotgun/bulldog(src)
	new /obj/item/gun/projectile/automatic/c20r(src)
	new /obj/item/gun/projectile/automatic/c20r(src)
	new /obj/item/gun/projectile/automatic/mini_uzi(src)

/obj/effect/portal/to_boss
	icon_state = "portal-syndicate"
	var/target_x = 202
	var/target_y = 324
	var/target_z = 3

/obj/effect/portal/to_boss/New(loc, turf/_target, obj/creation_object, lifespan = 900, mob/creation_mob, create_sparks = TRUE)
	. = ..()
	target = locate(target_x, target_y, target_z)

/obj/item/paper/crumpled/bloody/hirka/caves
	info = "<p> <large> <i> <b> СРАНЫЙ БОББИ!!! </large> </b> <br> Этот идиот Бобби, после смерти своего <b> сраного </b> \
		папаши Билли Сайлмана все таки потащил нас в пещеры на зимовку!!! <br> И если его <b> сраный </b> батя \
		знал, где можно встать поближе к теплым источникам так что бы было безопасно... <br> ТО <b> СРАНЫЙ </b> БОББИ \
		ПОНЯТИЯ НЕ ИМЕЛ, КУДА ТАЩИЛ НАС!!! <br> Мы заплутали уже на третий день, и, сука, надо ж было догадаться раньше \
		, что <b> сраный </b> Бобби просто идет наугад...<br> Если б не авторитет его батька, я сожрал бы его первым. \
		<br> ... <br> ... <br> Первого мы съели Барти, потому что он был самым жирным. <br> ... <br> ... <br> \
		Вся живность Хирки устремилась глубоко в пещеры, нам вроде удалось найти больё-ли-меньё безопасный уголок... <br> \
		Но эта <b> чертова статуя... </b> Мне кажется, она смотрит за каждым из нас... Как? Черт его знает, но как-то смотрит. \
		<br> ... <br> ... <br> Сегодня я прикончу <b> сраного </b> Бобби, что бы он передал своему <b> сраному </b> папаше привет. \
		А так же самому <b> сраному </b> Сайлману. <br> ... <br> ... <br> Немогутерпетьэтустатуюнемогутерпетьэтустатуюнемогутерпетьэтустатуюне м оуг стеьв дю </i></p>"

/obj/item/stack/ore/strange
	name = "strange ore"
	desc = "Кусок странной породы, не отображающийся на датчиках сканирования полезных ископаемых. Скорее всего бесполезен."
	singular_name = "strange ore chunk"

/obj/structure/closet/grave // не спрашивайте
	name = "могилка"
	desc = "Выкопанная на скорую руку могилка."
	icon = 'modular_ss220/maps220/icons/crates.dmi'
	icon_state = "grave"
	icon_opened = "graveopen"
	icon_closed = "grave"
	open_sound = 'sound/effects/shovel_dig.ogg'
	close_sound = 'sound/effects/shovel_dig.ogg'

/obj/structure/closet/grave/gravelead
	name = "ухоженная могилка"
	icon_state = "Выкопанная на скорую руку могилка, украшенная надгробный камнем."
	icon_opened = "grave_leadopen"
	icon_closed = "grave_lead"
