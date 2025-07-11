extends Control

const ProjectData = preload("./project_data.gd")
const Outliner = preload("./outliner.gd")
const CursorDialog = preload("./cursor_dialog.gd")

const _predefined_cursor_names = [
	"a", "b", "c", "d", "e"
]

@onready var _outliner := $VB/HSplit/Outliner as Outliner
@onready var _graph_view = $VB/HSplit/VBRight/Graph
@onready var _formula_edit = $VB/HSplit/VBRight/FormulaEdit
@onready var _cursor_dialog := $CursorDialog as CursorDialog


var _project : ProjectData = null


func _ready():
	_project = ProjectData.new()
	_outliner.set_project(_project)
	_graph_view.set_project(_project)
	_formula_edit.set_project(_project)


func _on_FormulaEdit_formula_entered(new_text):
	if _project.get_function_count() == 0:
		_create_function(new_text)
		return
	
	var fname := _outliner.get_selected_function_name()
	if fname == "":
		_create_function(new_text)
		return
	
	var f = _project.get_function_by_name(fname)
	f.formula = new_text
	_outliner.update_list()
	_graph_view.queue_redraw()


func _on_AddFunctionButton_pressed():
	_create_function("")


func _create_function(formula : String):
	var fsettings = null
	for it in ProjectData.predefined_func_settings:
		if not _project.has_function(it[0]):
			fsettings = it
			break
	if fsettings == null:
		# TODO Ask for function name?
		print("No function name available")
		return
	
	var fname = fsettings[0]
	var color = fsettings[1]
	
	var f = _project.create_function(fname)
	f.color = color
	f.formula = formula

	_outliner.update_list()
	_outliner.select_function(fname, true)
	_graph_view.queue_redraw()


func _on_Outliner_function_selected(fname):
	var f = _project.get_function_by_name(fname)
	_formula_edit.set_function_name(fname)
	_formula_edit.set_text(f.formula)
	_graph_view.queue_redraw()


func _on_AddCursorButton_pressed():
	_add_cursor()


func _add_cursor():
	var cname := ""
	for it in _predefined_cursor_names:
		if not _project.has_cursor(it):
			cname = it
			break
	if cname == "":
		# TODO Ask for cursor name?
		print("No cursor name available")
		return
	
	_project.create_cursor(cname)

	_outliner.update_list()
	_outliner.select_cursor(cname)
	_graph_view.queue_redraw()


func _on_Outliner_cursor_changed():
	_graph_view.queue_redraw()


func _on_Outliner_cursor_settings_requested(cname):
	var c = _project.get_cursor_by_name(cname)
	_cursor_dialog.set_cursor(c)
	_cursor_dialog.popup_centered_clamped()


func _on_CursorDialog_confirmed():
	_outliner.call_deferred("update_list")
	_graph_view.queue_redraw()
