extends Sprite


class_name InteractSprite

const INTERACT_ACTION = "interact"

var actionImagePathKey = {
	"a": "res://assets/actions/a_key.png",
	"b": "res://assets/actions/b_key.png",
	"c": "res://assets/actions/c_key.png",
	"d": "res://assets/actions/d_key.png",
	"e": "res://assets/actions/e_key.png",
	"f": "res://assets/actions/f_key.png",
	"g": "res://assets/actions/g_key.png",
	"h": "res://assets/actions/h_key.png",
	"i": "res://assets/actions/i_key.png",
	"j": "res://assets/actions/j_key.png",
	"k": "res://assets/actions/k_key.png",
	"l": "res://assets/actions/l_key.png",
	"m": "res://assets/actions/m_key.png",
	"n": "res://assets/actions/n_key.png",
	"o": "res://assets/actions/o_key.png",
	"p": "res://assets/actions/p_key.png",
	"q": "res://assets/actions/q_key.png",
	"r": "res://assets/actions/r_key.png",
	"s": "res://assets/actions/s_key.png",
	"t": "res://assets/actions/t_key.png",
	"u": "res://assets/actions/u_key.png",
	"v": "res://assets/actions/v_key.png",
	"w": "res://assets/actions/w_key.png",
	"x": "res://assets/actions/x_key.png",
	"y": "res://assets/actions/y_key.png",
	"z": "res://assets/actions/z_key.png"
}

var settings = Settings.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	settings.connectNodeToSettingsChangedSignal(self, "checkInteractActionButton")
	checkInteractActionButton()


func checkInteractActionButton():
	var list = InputMap.get_action_list(INTERACT_ACTION)
	for input in list:
		switchSpriteForInput(input)


func switchSpriteForInput(input: InputEvent):
	var command = input.as_text().to_lower()
	var correctImagePath = actionImagePathKey[command]
	var correctTexture = getTextureFromPath(correctImagePath)
	self.texture = correctTexture


func getTextureFromPath(path: String):
	return load(path)
	
