/obj/structure/flora/tree/cactus
	icon = 'modular_ss220/dunes_map/icons/cactus.dmi'
	icon_state = "cactus1"
	pixel_x = 0

/obj/structure/flora/tree/cactus/Initialize(mapload)
	. = ..()
	icon_state = pick("cactus1","cactus2","cactus3")
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

/obj/structure/flora/tree/cactus/little
	icon_state = "little_cactus1"
	density = FALSE
	layer = BELOW_OBJ_LAYER

/obj/structure/flora/tree/cactus/little/Initialize(mapload)
	. = ..()
	icon_state = pick("little_cactus1","little_cactus2","little_cactus3")

/obj/structure/flora/tree/cactus/circle
	icon_state = "circle_cactus1"
	density = FALSE
	layer = BELOW_OBJ_LAYER

/obj/structure/flora/tree/cactus/circle/Initialize(mapload)
	. = ..()
	icon_state = pick("circle_cactus1","circle_cactus2","circle_cactus3","circle_cactus4","circle_cactus5","circle_cactus6")

/obj/structure/flora/tree/cactus/flat
	icon_state = "flat_cactus1"
	density = FALSE
	layer = BELOW_OBJ_LAYER

/obj/structure/flora/tree/cactus/flat/Initialize(mapload)
	. = ..()
	icon_state = pick("flat_cactus1","flat_cactus2","flat_cactus3")

/obj/structure/flora/tree/desert/joshua
	icon = 'modular_ss220/dunes_map/icons/desert_tree.dmi'
	icon_state = "joshua_1"

/obj/structure/flora/tree/desert/joshua/Initialize(mapload)
	. = ..()
	icon_state = pick("joshua_1","joshua_2","joshua_3","joshua_4")

/obj/structure/flora/tree/desert/dead
	icon = 'modular_ss220/dunes_map/icons/desert_tree.dmi'
	icon_state = "dead_1"

/obj/structure/flora/tree/desert/dead/Initialize(mapload)
	. = ..()
	icon_state = pick("dead_1","dead_2","dead_3")
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

/obj/structure/flora/tree/desert/medpine
	icon = 'modular_ss220/dunes_map/icons/desert_tree.dmi'
	icon_state = "medpine"

/obj/structure/flora/tree/desert/african
	icon = 'modular_ss220/dunes_map/icons/desert_tree.dmi'
	icon_state = "african"

/obj/structure/flora/tree/desert/big
	icon = 'modular_ss220/dunes_map/icons/desert_tree_big.dmi'
	icon_state = "dead_tree_1"

/obj/structure/flora/tree/desert/big/Initialize(mapload)
	. = ..()
	icon_state = pick("dead_tree_1","dead_tree_2","dead_tree_3","dead_tree_4")
