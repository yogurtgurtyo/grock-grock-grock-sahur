extends RichTextLabel

var score: int = 0

func _ready() -> void:
	update_display()

func add_score(amount: int) -> void:
	score += amount
	update_display()

func update_display() -> void:
	text = "Fish: " + str(score) + " out of 12"
