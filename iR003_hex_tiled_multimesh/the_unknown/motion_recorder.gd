class_name MotionRecorder
extends Object

enum ModeType {IDLE, REC, PLAY}

var _target: Node3D
var _mode: ModeType = ModeType.IDLE
var _file: FileAccess = null
var _original_sampling_time := (1/24.0)/2.0
var _sampling_time := _original_sampling_time
var _sampling_count := 0.0
var _sampling_total := 0.0
var _cur_position: Vector3
var _cur_rotation: Vector3
var _next_position: Vector3
var _next_rotation: Vector3


func _init(target: Node3D):
	self._target = target


func set_mode(mode: ModeType, filename: String = "", sampling_time: float = 0.0):
	if _file != null:
		_file.close()
		_file = null
	if _target:
		_mode = mode
		_sampling_count = 0.0
		match _mode:
			ModeType.REC:
				assert(not filename.is_empty())
				_file = FileAccess.open(filename, FileAccess.WRITE)
				if sampling_time != 0.0:
					_original_sampling_time = sampling_time
					_sampling_time = sampling_time
				_file.store_var(_sampling_time)
				_file.store_var(_target.position)
				_file.store_var(_target.rotation)
			ModeType.PLAY:
				assert(not filename.is_empty())
				assert(FileAccess.file_exists(filename))
				_file = FileAccess.open(filename, FileAccess.READ)
				_original_sampling_time = _file.get_var()
				_cur_position = _file.get_var()
				_cur_rotation = _file.get_var()
				_next_position = _file.get_var()
				_next_rotation = _file.get_var()
				_target.position = _cur_position
				_target.rotation = _cur_rotation
				_sampling_time = sampling_time if sampling_time != 0.0 else _original_sampling_time
				_process_play(0.0)
	

func process(delta):
	if _target:
		match _mode:
			ModeType.REC:
				_process_rec(delta)
			ModeType.PLAY:
				_process_play(delta)


func _process_rec(delta):
	if _file != null:
		_sampling_count += delta
		_sampling_total += delta
		while _sampling_count > _sampling_time:
			_file.store_var(_target.position)
			_file.store_var(_target.rotation)
			_file.flush()
			_sampling_count -= _sampling_time
	

func _process_play(delta):
	if _file != null:
		_sampling_count += delta
		_sampling_total += delta
		while _sampling_count > _sampling_time:
			_cur_position = _next_position
			_cur_rotation = _next_rotation
			_sampling_count -= _sampling_time
			if not _file.eof_reached():
				var v: Variant = _file.get_var()
				if typeof(v) != TYPE_NIL:
					_next_position = v
					_next_rotation = _file.get_var()
				else:
					set_mode(ModeType.IDLE)
			else:
				set_mode(ModeType.IDLE)
		var lerpw := _sampling_count / _sampling_time
		_target.position = _cur_position.lerp(_next_position, lerpw)
		_target.rotation.x = lerp_angle(_cur_rotation.x, _next_rotation.x, lerpw)
		_target.rotation.y = lerp_angle(_cur_rotation.y, _next_rotation.y, lerpw)
		_target.rotation.z = lerp_angle(_cur_rotation.z, _next_rotation.z, lerpw)
