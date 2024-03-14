extends Node

var day := 0

var unique_customers := 0
var vip_chance := 6
var money := 100

var reputation := 0
var reputation_level := 0
@onready var reputation_objective := Utils.get_level_needed_xp(reputation_level)

var warned := false
var game_over := false

const REWARDS_CYCLE := [
	"bag",
	"customers",
	"vip",
	"money",
	#"gift"
]

var rewards_to_apply := []
