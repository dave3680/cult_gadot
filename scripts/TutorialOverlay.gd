extends CanvasLayer
class_name TutorialOverlay

signal callout_closed

var _dimmer: ColorRect
var _highlight: PanelContainer
var _tooltip: PanelContainer
var _title_label: Label
var _body_label: Label
var _next_button: Button
var _active_target: Control
var _dismiss_mode: String = "next"
var _auto_timer: SceneTreeTimer

func _ready() -> void:
	layer = 120
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()

func _build_ui() -> void:
	_dimmer = ColorRect.new()
	_dimmer.anchor_right = 1.0
	_dimmer.anchor_bottom = 1.0
	_dimmer.color = Color(0.0, 0.0, 0.0, 0.55)
	_dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	_dimmer.gui_input.connect(_on_dimmer_input)
	add_child(_dimmer)

	_highlight = PanelContainer.new()
	_highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var hb: StyleBoxFlat = StyleBoxFlat.new()
	hb.bg_color = Color(0, 0, 0, 0)
	hb.border_color = Color(1.0, 0.86, 0.4, 0.98)
	hb.border_width_left = 2
	hb.border_width_right = 2
	hb.border_width_top = 2
	hb.border_width_bottom = 2
	hb.corner_radius_top_left = 8
	hb.corner_radius_top_right = 8
	hb.corner_radius_bottom_left = 8
	hb.corner_radius_bottom_right = 8
	_highlight.add_theme_stylebox_override("panel", hb)
	add_child(_highlight)

	_tooltip = PanelContainer.new()
	_tooltip.custom_minimum_size = Vector2(360, 170)
	_tooltip.mouse_filter = Control.MOUSE_FILTER_STOP
	var tb: StyleBoxFlat = StyleBoxFlat.new()
	tb.bg_color = Color(0.12, 0.11, 0.15, 0.98)
	tb.border_color = Color(0.3, 0.28, 0.36, 0.95)
	tb.border_width_left = 1
	tb.border_width_right = 1
	tb.border_width_top = 1
	tb.border_width_bottom = 1
	tb.corner_radius_top_left = 10
	tb.corner_radius_top_right = 10
	tb.corner_radius_bottom_left = 10
	tb.corner_radius_bottom_right = 10
	_tooltip.add_theme_stylebox_override("panel", tb)
	add_child(_tooltip)

	var margin: MarginContainer = MarginContainer.new()
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.offset_left = 12
	margin.offset_top = 12
	margin.offset_right = -12
	margin.offset_bottom = -12
	_tooltip.add_child(margin)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	_title_label = Label.new()
	_title_label.text = "Tutorial"
	_title_label.add_theme_font_size_override("font_size", 18)
	_title_label.add_theme_color_override("font_color", Color(0.95, 0.9, 0.75))
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	vbox.add_child(_title_label)

	_body_label = Label.new()
	_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body_label.add_theme_font_size_override("font_size", 14)
	_body_label.add_theme_color_override("font_color", Color(0.92, 0.92, 0.96))
	_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_body_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_body_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(_body_label)

	_next_button = Button.new()
	_next_button.text = "Next"
	_next_button.custom_minimum_size = Vector2(110, 36)
	_next_button.pressed.connect(_close_callout)
	vbox.add_child(_next_button)

func show_callout(target: Control, text: String, title: String = "Tutorial", dismiss_mode: String = "next", auto_seconds: float = 0.0) -> void:
	_cancel_timer()
	_active_target = target
	_dismiss_mode = dismiss_mode
	_title_label.text = title
	_body_label.text = text
	visible = true
	_highlight.visible = target != null and is_instance_valid(target)
	_next_button.visible = dismiss_mode == "next"
	_reposition()
	if dismiss_mode == "auto" and auto_seconds > 0.0:
		_auto_timer = get_tree().create_timer(auto_seconds)
		_auto_timer.timeout.connect(_close_callout)

func _process(_delta: float) -> void:
	if not visible:
		return
	_reposition()

func _on_dimmer_input(event: InputEvent) -> void:
	if not visible:
		return
	if _dismiss_mode != "click":
		return
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			_close_callout()

func _reposition() -> void:
	var viewport_rect: Rect2 = get_viewport().get_visible_rect()
	var highlight_rect: Rect2 = Rect2(viewport_rect.position + Vector2(24, 24), Vector2(240, 64))
	if _active_target != null and is_instance_valid(_active_target):
		highlight_rect = (_active_target as Control).get_global_rect().grow(6.0)
	_highlight.position = highlight_rect.position
	_highlight.size = highlight_rect.size
	var tooltip_size: Vector2 = _tooltip.custom_minimum_size
	if tooltip_size.y < 160:
		tooltip_size.y = 160
	_tooltip.size = tooltip_size
	var pos: Vector2 = highlight_rect.position + Vector2(highlight_rect.size.x + 12, 0)
	if pos.x + tooltip_size.x > viewport_rect.size.x - 16:
		pos.x = max(16.0, highlight_rect.position.x - tooltip_size.x - 12.0)
	if pos.y + tooltip_size.y > viewport_rect.size.y - 16:
		pos.y = max(16.0, viewport_rect.size.y - tooltip_size.y - 16.0)
	_tooltip.position = pos

func _close_callout() -> void:
	if not visible:
		return
	_cancel_timer()
	visible = false
	emit_signal("callout_closed")

func _cancel_timer() -> void:
	if _auto_timer != null and is_instance_valid(_auto_timer):
		if _auto_timer.timeout.is_connected(_close_callout):
			_auto_timer.timeout.disconnect(_close_callout)
	_auto_timer = null
