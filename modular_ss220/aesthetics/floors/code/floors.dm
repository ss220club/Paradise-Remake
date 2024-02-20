/// Floor icon_states for floor painter
/datum/painter/floor/New()
	allowed_states |= list("darkneutralcorner", "darkneutral", "darkneutralfull", "navybluecorners", "navyblue", "navybluefull",
		"navybluealt", "navybluealtstrip", "navybluecornersalt", "darkbluealt", "darkbluealtstrip", "darkbluecornersalt",
		"darkredalt", "darkredaltstrip", "darkredcornersalt", "darkyellowalt", "darkyellowaltstrip", "darkyellowcornersalt",
		"whitebrowncorner", "whitebrown"
		)
	. = ..()

/turf/simulated/floor
	icon = 'modular_ss220/aesthetics/floors/icons/floors.dmi'

/turf/simulated/floor/plasteel/dark
	icon_state = "dark"

/turf/simulated/floor/mech_bay_recharge_floor
	icon = 'modular_ss220/aesthetics/floors/icons/floors.dmi'

// WOODEN FLOORS
/turf/simulated/floor/wood
	icon = 'modular_ss220/aesthetics/floors/icons/wooden.dmi'

/turf/simulated/floor/wood/oak
	icon_state = "wood-oak"
	floor_tile = /obj/item/stack/tile/wood/oak
	broken_states = list("wood-oak-broken", "wood-oak-broken2", "wood-oak-broken3", "wood-oak-broken4", "wood-oak-broken5", "wood-oak-broken6", "wood-oak-broken7")

/turf/simulated/floor/wood/birch
	icon_state = "wood-birch"
	floor_tile = /obj/item/stack/tile/wood/birch
	broken_states = list("wood-birch-broken", "wood-birch-broken2", "wood-birch-broken3", "wood-birch-broken4", "wood-birch-broken5", "wood-birch-broken6", "wood-birch-broken7")

/turf/simulated/floor/wood/cherry
	icon_state = "wood-cherry"
	floor_tile = /obj/item/stack/tile/wood/cherry
	broken_states = list("wood-cherry-broken", "wood-cherry-broken2", "wood-cherry-broken3", "wood-cherry-broken4", "wood-cherry-broken5", "wood-cherry-broken6", "wood-cherry-broken7")

/turf/simulated/floor/wood/fancy
	icon_state = "fancy-wood"
	floor_tile = /obj/item/stack/tile/wood/fancy
	broken_states = list("fancy-wood-broken", "fancy-wood-broken2", "fancy-wood-broken3")

/turf/simulated/floor/wood/fancy/oak
	icon_state = "fancy-wood-oak"
	floor_tile = /obj/item/stack/tile/wood/fancy/oak
	broken_states = list("fancy-wood-oak-broken", "fancy-wood-oak-broken2", "fancy-wood-oak-broken3")

/turf/simulated/floor/wood/fancy/birch
	icon_state = "fancy-wood-birch"
	floor_tile = /obj/item/stack/tile/wood/fancy/birch
	broken_states = list("fancy-wood-birch-broken", "fancy-wood-birch-broken2", "fancy-wood-birch-broken3")

/turf/simulated/floor/wood/fancy/cherry
	icon_state = "fancy-wood-cherry"
	floor_tile = /obj/item/stack/tile/wood/fancy/cherry
	broken_states = list("fancy-wood-cherry-broken", "fancy-wood-cherry-broken2", "fancy-wood-cherry-broken3")

/turf/simulated/floor/wood/parquet
	icon_state = "wood_parquet"
	floor_tile = /obj/item/stack/tile/wood/parquet
	broken_states = list("wood_parquet-broken", "wood_parquet-broken2", "wood_parquet-broken3", "wood_parquet-broken4", "wood_parquet-broken5", "wood_parquet-broken6", "wood_parquet-broken7")

/turf/simulated/floor/wood/parquet/tile
	icon_state = "wood_tile"
	floor_tile = /obj/item/stack/tile/wood/parquet/tile
	broken_states = list("wood_tile-broken", "wood_tile-broken2", "wood_tile-broken3")

/turf/simulated/floor/plasteel/smooth
	icon_state = "smooth"

// LIGHT FLOORS
/turf/simulated/floor/light
	icon = 'icons/turf/floors.dmi'

/turf/simulated/floor/light/red
	color = "#f23030"
	light_color = "#f23030"

/turf/simulated/floor/light/green
	color = "#30f230"
	light_color = "#30f230"

/turf/simulated/floor/light/blue
	color = "#3030f2"
	light_color = "#3030f2"

/turf/simulated/floor/light/purple
	color = "#d493ff"
	light_color = "#d493ff"
