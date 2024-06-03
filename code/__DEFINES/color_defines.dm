
#define COLOR_INPUT_DISABLED "#F0F0F0"
#define COLOR_INPUT_ENABLED "#D3B5B5"
#define COLOR_RED 			   "#FF0000"
#define COLOR_GREEN 		   "#00FF00"
#define COLOR_BLUE 			   "#0000FF"
#define COLOR_CYAN 			   "#00FFFF"
#define COLOR_PINK 			   "#FF00FF"
#define COLOR_YELLOW 		   "#FFFF00"
#define COLOR_ORANGE 		   "#FF9900"
#define COLOR_WHITE 		   "#FFFFFF"
#define COLOR_GRAY      	   "#808080"
#define COLOR_BLACK            "#000000"
#define COLOR_HALF_TRANSPARENT_BLACK    "#0000007A"
#define COLOR_NAVY_BLUE        "#000080"
#define COLOR_LIGHT_GREEN      "#008000"
#define COLOR_DARK_GRAY        "#404040"
#define COLOR_MAROON           "#800000"
#define COLOR_PURPLE           "#800080"
#define COLOR_VIOLET           "#9933ff"
#define COLOR_OLIVE            "#808000"
#define COLOR_BROWN_ORANGE     "#824b28"
#define COLOR_DARK_ORANGE      "#b95a00"
#define COLOR_GRAY40           "#666666"
#define COLOR_GRAY20           "#333333"
#define COLOR_GRAY15           "#151515"
#define COLOR_SEDONA           "#cc6600"
#define COLOR_DARK_BROWN       "#917448"
#define COLOR_DEEP_SKY_BLUE    "#00e1ff"
#define COLOR_LIME             "#00ff00"
#define COLOR_TEAL             "#33cccc"
#define COLOR_PALE_PINK        "#bf89ba"
#define COLOR_YELLOW_GRAY      "#c9a344"
#define COLOR_PALE_YELLOW      "#c1bb7a"
#define COLOR_WARM_YELLOW      "#b3863c"
#define COLOR_RED_GRAY         "#aa5f61"
#define COLOR_BROWN            "#b19664"
#define COLOR_GREEN_GRAY       "#8daf6a"
#define COLOR_DARK_GREEN_GRAY  "#54654c"
#define COLOR_BLUE_GRAY        "#6a97b0"
#define COLOR_DARK_BLUE_GRAY   "#3e4855"
#define COLOR_SUN              "#ec8b2f"
#define COLOR_PURPLE_GRAY      "#a2819e"
#define COLOR_BLUE_LIGHT       "#33ccff"
#define COLOR_RED_LIGHT        "#ff3333"
#define COLOR_BEIGE            "#ceb689"
#define COLOR_BABY_BLUE        "#89cff0"
#define COLOR_PALE_GREEN_GRAY  "#aed18b"
#define COLOR_PALE_RED_GRAY    "#cc9090"
#define COLOR_PALE_PURPLE_GRAY "#bda2ba"
#define COLOR_PALE_BLUE_GRAY   "#8bbbd5"
#define COLOR_LUMINOL          "#66ffff"
#define COLOR_SILVER           "#c0c0c0"
#define COLOR_GRAY80           "#cccccc"
#define COLOR_OFF_WHITE        "#eeeeee"
#define COLOR_GOLD             "#6d6133"
#define COLOR_NT_RED           "#9d2300"
#define COLOR_BOTTLE_GREEN     "#1f6b4f"
#define COLOR_PALE_BTL_GREEN   "#57967f"
#define COLOR_GUNMETAL         "#545c68"
#define COLOR_WALL_GUNMETAL    "#353a42"
#define COLOR_STEEL            "#a8b0b2"
#define COLOR_MUZZLE_FLASH     "#ffffb2"
#define COLOR_CHESTNUT         "#996633"
#define COLOR_BEASTY_BROWN     "#663300"
#define COLOR_WHEAT            "#ffff99"
#define COLOR_CYAN_BLUE        "#3366cc"
#define COLOR_LIGHT_CYAN       "#66ccff"
#define COLOR_PAKISTAN_GREEN   "#006600"
#define COLOR_HULL             "#436b8e"
#define COLOR_AMBER            "#ffbf00"
#define COLOR_COMMAND_BLUE     "#46698c"
#define COLOR_SKY_BLUE         "#5ca1cc"
#define COLOR_PALE_ORANGE      "#b88a3b"
#define COLOR_CIVIE_GREEN      "#b7f27d"
#define COLOR_TITANIUM         "#d1e6e3"
#define COLOR_DARK_GUNMETAL    "#4c535b"
#define COLOR_BRONZE           "#8c7853"
#define COLOR_BRASS            "#b99d71"
#define COLOR_INDIGO           "#4b0082"
#define COLOR_ALUMINIUM        "#bbbbbb"
#define COLOR_CRYSTAL          "#00c8a5"
#define COLOR_ASTEROID_ROCK    "#735555"
#define COLOR_ROCK             "#464646"
#define COLOR_NULLGLASS        "#ff6088"
#define COLOR_DIAMOND          "#d8d4ea"
#define COLOR_ANCIENT_ROCK     "#575757"
#define COLOR_COLD_ANCIENT_ROCK "#575764"
#define COLOR_HARD_ROCK    "#363636"
#define COLOR_FLOOR_HARD_ROCK    "#bdbdbd"
#define COLOR_HEALING_GREEN    "#375637"

//Color defines used by the assembly detailer.
#define COLOR_ASSEMBLY_BLACK   "#545454"
#define COLOR_ASSEMBLY_BGRAY   "#9497AB"
#define COLOR_ASSEMBLY_WHITE   "#E2E2E2"
#define COLOR_ASSEMBLY_RED     "#CC4242"
#define COLOR_ASSEMBLY_ORANGE  "#E39751"
#define COLOR_ASSEMBLY_BEIGE   "#AF9366"
#define COLOR_ASSEMBLY_BROWN   "#97670E"
#define COLOR_ASSEMBLY_GOLD    "#AA9100"
#define COLOR_ASSEMBLY_YELLOW  "#CECA2B"
#define COLOR_ASSEMBLY_GURKHA  "#999875"
#define COLOR_ASSEMBLY_LGREEN  "#789876"
#define COLOR_ASSEMBLY_GREEN   "#44843C"
#define COLOR_ASSEMBLY_LBLUE   "#5D99BE"
#define COLOR_ASSEMBLY_BLUE    "#38559E"
#define COLOR_ASSEMBLY_PURPLE  "#6F6192"

//blood colors

#define COLOR_BLOOD_BASE "#A10808"
#define COLOR_BLOOD_MACHINE "#1F181F"

// Pipe colours
#define	PIPE_COLOR_GREY		"#ffffff"	//yes white is grey
#define	PIPE_COLOR_RED		"#ff0000"
#define	PIPE_COLOR_BLUE		"#0000ff"
#define	PIPE_COLOR_CYAN		"#00ffff"
#define	PIPE_COLOR_GREEN	"#00ff00"
#define	PIPE_COLOR_YELLOW	"#ffcc00"
#define	PIPE_COLOR_PURPLE	"#5c1ec0"

///Main colors for UI themes
#define COLOR_THEME_MIDNIGHT "#6086A0"
#define COLOR_THEME_PLASMAFIRE "#FFB200"
#define COLOR_THEME_RETRO "#24CA00"
#define COLOR_THEME_SLIMECORE "#4FB259"
#define COLOR_THEME_OPERATIVE "#B8221F"
#define COLOR_THEME_GLASS "#75A4C4"
#define COLOR_THEME_CLOCKWORK "#CFBA47"
// SS220 ADDITION - START
#define COLOR_THEME_VAPORWAVE "#bc3ce3"
#define COLOR_THEME_DETECTIVE "#c7b08b"
#define COLOR_THEME_TRASENKNOX "#3ce375"
// SS220 ADDITION - END

// Color matrix utilities
#define COLOR_MATRIX_ADD(C) list(COLOR_RED, COLOR_GREEN, COLOR_BLUE, C)
#define COLOR_MATRIX_OVERLAY(C) list(COLOR_BLACK, COLOR_BLACK, COLOR_BLACK, C)

// Blob primary colours
#define COLOR_RIPPING_TENDRILS "#7F0000"
#define COLOR_BOILING_OIL "#B68D00"
#define COLOR_ENVENOMED_FILAMENTS "#9ACD32"
#define COLOR_LEXORIN_JELLY "#00FFC5"
#define COLOR_KINETIC_GELATIN "#FFA500"
#define COLOR_CRYOGENIC_LIQUID "#8BA6E9"
#define COLOR_SORIUM "#808000"
#define COLOR_TESLIUM_PASTE "#20324D"

// Blob complementary colours
#define COMPLEMENTARY_COLOR_RIPPING_TENDRILS "#a15656"
#define COMPLEMENTARY_COLOR_BOILING_OIL "#c0a856"
#define COMPLEMENTARY_COLOR_ENVENOMED_FILAMENTS "#b0cd73"
#define COMPLEMENTARY_COLOR_LEXORIN_JELLY "#56ebc9"
#define COMPLEMENTARY_COLOR_KINETIC_GELATIN "#ebb756"
#define COMPLEMENTARY_COLOR_CRYOGENIC_LIQUID "#a8b7df"
#define COMPLEMENTARY_COLOR_SORIUM "#a2a256"
#define COMPLEMENTARY_COLOR_TESLIUM_PASTE "#412968"

/// Color for dead external organs/zombies
#define	COLORTONE_DEAD_EXT_ORGAN "#0A3200"
