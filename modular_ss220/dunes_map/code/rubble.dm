/obj/structure/rubble
	name = "pile of rubble"
	desc = "One man's garbage is another man's treasure."
	icon = 'modular_ss220/dunes_map/icons/loot_piles.dmi'
	icon_state = "randompile"
	opacity = 0
	density = FALSE
	anchored = TRUE
	max_integrity = 40
	layer = TURF_DECAL_LAYER

	var/list/loot
	var/list/trash_types
	var/lootleft = 0
	var/emptyprob = 45
	var/is_rummaging = 0

/obj/structure/rubble/New()
	if(prob(emptyprob))
		lootleft = 1
	..()

/obj/structure/rubble/Initialize(mapload)
	. = ..()
	icon_state = "[pick(trash_types)]"
	update_icon()


/obj/structure/rubble/attack_hand(mob/user)
	if(!is_rummaging)
		visible_message("[user] starts rummaging through \the [src].")
		is_rummaging = 1
		if(!do_after(user, 3 SECONDS, target = src))
			is_rummaging = 0
			return

		if(!lootleft)
			to_chat(user, "<span class='warning'> There's nothing left in this one but unusable garbage...")
			is_rummaging = 0
			return

		var/obj/item/booty = pickweight(loot)
		booty = new booty(loc)
		lootleft--
		update_icon()
		to_chat(user, "<span class='notice'> You find \a [booty] and pull it carefully out of \the [src].")
		is_rummaging = 0
	else
		to_chat(user, "<span class='warning'> Someone is already rummaging here!")


/obj/structure/rubble/tool_act(mob/living/user, obj/item/I, tool_type)
	. = ..()
	// Pickaxe - Clear rubble
	if(istype(tool_type, /obj/item/pickaxe))
		user.visible_message(
			"<span class='notice'> \The [user] starts clearing away \the [src] with \a [tool_type].",
			"<span class='notice'> You start clearing away \the [src] with \the [tool_type]."
		)
		if(lootleft && prob(1))
			var/booty = pickweight(loot)
			new booty(loc)
		user.visible_message(
			"<span class='notice'> \The [user] clears away \the [src] with \a [tool_type].",
			"<span class='notice'> You clear away \the [src] with \the [tool_type]."
		)
		qdel(src)
		return TRUE

	return ..()





/obj/structure/rubble/Destroy()
	. = ..()
	visible_message("<span class='warning'> \The [src] breaks apart!")
	qdel(src)

/obj/structure/rubble/outside
	trash_types = list("technical_pile1", "technical_pile2", "junk_pile5", "junk_pile1", "boxfort", "trash_pile2")
	loot = list(
		/obj/item/stock_parts/cell,
		/obj/item/stack/sheet/metal,
		/obj/item/stack/rods,
		/obj/item/coin,
		/obj/item/storage/bag/trash,
		/obj/item/reagent_containers/glass/bucket,
		/obj/item/clothing/glasses/eyepatch,
		/obj/item/clothing/glasses/hud/health,
		/obj/item/clothing/glasses/hud/hydroponic,
		/obj/item/clothing/glasses/hud/security,
		/obj/item/stack/sheet/metal,
		/obj/item/stack/sheet/rglass,
		/obj/item/stack/sheet/glass,
		/obj/item/mine_bot_upgrade,
		/obj/item/nails,
		/obj/item/newspaper,
		/obj/item/paicard,
		/obj/item/painter,
		/obj/item/poster/random_contraband,
		/obj/item/radio,
		/obj/item/rcd_ammo,
		/obj/item/relic,
		/obj/item/scalpel,
		/obj/item/shard,
		/obj/item/shovel/spade,
		/obj/item/stamp/denied,
		/obj/item/taperecorder,
		/obj/item/toner,
		/obj/item/voice_changer,
		/obj/item/whetstone,
		/obj/item/wrench/power,
		/obj/item/wirecutters/power,
		/obj/item/vending_refill/medical,
		/obj/item/stack/spacecash/c10,
		/obj/item/stack/spacecash/c100,
		/obj/item/FixOVein,
		/obj/item/beach_ball,
		/obj/item/bodybag,
		/obj/item/bodyanalyzer,
		/obj/item/bonegel,
		/obj/item/bonesetter/alien,
		/obj/item/book/random,
		/obj/item/cane,
		/obj/item/cautery/alien,
		/obj/item/circular_saw/alien,
		/obj/item/assembly/signaler/anomaly/random,
		/obj/item/flashlight/flare,
		/obj/item/flashlight/flare/torch,
		/obj/item/flashlight,
		/obj/item/reagent_containers/hypospray/autoinjector/survival
		)

/obj/structure/rubble/house
	trash_types = list("junk_pile2", "junk_pile4","trash_pile1", "trash_pile2")
	loot = list(
		/obj/item/kitchen/knife,
		/obj/item/reagent_containers/drinks/cans/starkist,
		/obj/item/reagent_containers/drinks/cans/space_up,
		/obj/item/stack/sheet/wood,
		/obj/item/reagent_containers/glass/beaker/large,
		/obj/item/reagent_containers/glass/beaker/waterbottle/large,
		/obj/item/reagent_containers/glass/beaker/waterbottle,
		/obj/item/lighter/zippo,
		/obj/item/storage/fancy/cigarettes/cigpack_robustgold,
		/obj/item/storage/fancy/cigarettes/cigpack_robust,
		/obj/item/cigbutt,
		/obj/item/reagent_containers/drinks/bottle/vodka,
		/obj/item/reagent_containers/drinks/bottle/gin,
		/obj/item/reagent_containers/drinks/bottle/absinthe/premium,
		/obj/item/reagent_containers/drinks/mug,
		/obj/item/reagent_containers/glass/rag,
		/obj/item/reagent_containers/patch/silver_sulf,
		/obj/item/reagent_containers/patch/styptic,
		/obj/item/reagent_containers/patch/synthflesh,
		/obj/item/reagent_containers/hypospray/autoinjector/epinephrine,
		/obj/item/reagent_containers/drinks/oilcan,
		/obj/item/melee/baseball_bat,
		/obj/item/melee/classic_baton
	)

/obj/structure/rubble/lab
	trash_types = list("junk_pile4", "technical_pile1", "technical_pile2", "technical_pile3")
	emptyprob = 30
	loot = list(
		/obj/item/stock_parts/cell,
		/obj/item/stock_parts/cell/hyper/empty,
		/obj/item/stock_parts/matter_bin/super,
		/obj/item/stock_parts/matter_bin/adv,
		/obj/item/stock_parts/matter_bin,
		/obj/item/stock_parts/scanning_module/adv,
		/obj/item/stock_parts/micro_laser/ultra,
		/obj/item/stock_parts/manipulator/nano,
		/obj/item/stock_parts/scanning_module,
		/obj/item/stock_parts/capacitor,
		/obj/item/t_scanner,
		/obj/item/t_scanner/mod/advanced,
		/obj/item/clothing/glasses/regular,
		/obj/item/clothing/glasses/science,
		/obj/item/clothing/glasses/hud/diagnostic,
		/obj/item/clothing/suit/storage/labcoat,
		/obj/item/clothing/suit/storage/labcoat/chemist,
		/obj/item/mod/core/standard,
		/obj/item/mecha_modkit/voice/nanotrasen,
		/obj/item/dnascrambler,
		/obj/item/flashlight/seclite
	)

/obj/structure/rubble/war
	trash_types = list("boxfort", "junk_pile3", "junk_pile5",  "junk_pile1")
	emptyprob = 30 //can't have piles upon piles of guns
	loot = list(
		/obj/item/spear,
		/obj/item/spear/bonespear,
		/obj/item/kitchen/knife/combat/survival,
		/obj/item/kitchen/knife/combat,
		/obj/item/gun/projectile/automatic/pistol,
		/obj/item/ammo_box/magazine/m10mm,
		/obj/item/pickaxe,
		/obj/item/melee/classic_baton,
		/obj/item/melee/baseball_bat/ablative,
		/obj/item/melee/knuckleduster,
		/obj/item/melee/stylet,
		/obj/item/melee/baseball_bat,
		/obj/item/gun/energy/laser/retro,
		/obj/item/gun/energy/laser/retro/old,
		/obj/item/gun/energy/laser,
		/obj/item/gun/projectile/automatic/laserrifle,
		/obj/item/ammo_box/magazine/laser,
		/obj/item/gun/energy/gun/nuclear,
		/obj/item/weaponcrafting/gunkit/immolator,
		/obj/item/weaponcrafting/gunkit/accelerator,
		/obj/item/weaponcrafting/gunkit/universal_gun_kit,
		/obj/item/weaponcrafting/gunkit/universal_gun_kit/sol_gov,
		/obj/item/ammo_box/shotgun/buck,
		/obj/item/weaponcrafting/ishotgunconstruction3,
		/obj/item/gun/projectile/shotgun/riot,
		/obj/item/gun/projectile/revolver/doublebarrel,
		/obj/item/gun/projectile/revolver/doublebarrel/improvised,
		/obj/item/gun/projectile/automatic/pistol/enforcer/lethal,
		/obj/item/ammo_box/magazine/enforcer/lethal,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack
	)
