class_name HealthBar
extends PanelContainer

@onready var progress_bar: ProgressBar = %ProgressBar
@onready var progress_text: Label = %ProgressText


func set_health(current: int, maximum: int) -> void:
	progress_bar.max_value = maximum
	progress_bar.value = current
	progress_text.text = "%d/%d" % [progress_bar.value, progress_bar.max_value]
