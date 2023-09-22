/* Coastline */
/turf/simulated/floor/beach/away/coastline/beachcorner
	name = "beachcorner"
	icon = 'modular_ss220/maps220/icons/floors.dmi'
	icon_state = "beachcorner"
	base_icon_state = "beachcorner"
	footstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	clawfootstep = FOOTSTEP_WATER
	heavyfootstep = FOOTSTEP_WATER
	baseturf = /turf/simulated/floor/beach/away/coastline/beachcorner

/* Indestructible */
/turf/simulated/floor/indestructible/grass
	name = "grass patch"
	icon = 'icons/turf/floors/grass.dmi'
	icon_state = "grass"
	base_icon_state = "grass"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_TURF, SMOOTH_GROUP_GRASS)
	canSmoothWith = list(SMOOTH_GROUP_GRASS, SMOOTH_GROUP_JUNGLE_GRASS)
	layer = ABOVE_OPEN_TURF_LAYER
	mouse_opacity = MOUSE_OPACITY_ICON
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	clawfootstep = FOOTSTEP_GRASS
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	transform = matrix(1, 0, -9, 0, 1, -9) 

/turf/simulated/floor/indestructible/grass/jungle
	name = "jungle grass"
	icon = 'icons/turf/floors/junglegrass.dmi'
	icon_state = "junglegrass"
	base_icon_state = "junglegrass"
	smoothing_groups = list(SMOOTH_GROUP_TURF, SMOOTH_GROUP_GRASS, SMOOTH_GROUP_JUNGLE_GRASS)

/turf/simulated/floor/indestructible/grass/no_creep 
	smoothing_flags = null
	smoothing_groups = null
	canSmoothWith = null
	layer = GRASS_UNDER_LAYER
	transform = null
