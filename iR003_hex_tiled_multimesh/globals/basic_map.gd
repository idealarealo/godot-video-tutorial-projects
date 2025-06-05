class_name BasicMap
extends Object
## Basic image-backed square map implementation
##
## - data is taken from a single RGBA image (CompressedTexture2D)
## - size is aligned to a power of 2 
## - coordinates are wrapped
## - fast?

# mcc = map-limited cell coordinates
# mac = map-limited area coordinates
# acc = area-limited cell coordinates
# aai = area-limited area index
# ai = area-limited index

const AREA_SIZE_2POW: int = 3
const AREA_SIZE: int = 1<<AREA_SIZE_2POW
const AREA_SIZE_MASK: int = AREA_SIZE-1
const AREA_SIZE_SQR: int = AREA_SIZE*AREA_SIZE

var _image: Image = null

# map size in cell coordinates
var _size_cc_2pow: int = 0
var _size_cc: int = 0
var _size_cc_mask: int = 0
var _size_cc_sqr: int = 0

# map size in area coordinates
var _size_ac_2pow: int = 0
var _size_ac: int = 0
var _size_ac_mask: int = 0
var _size_ac_sqr: int = 0


var size: int:
	get: return _size_cc
	set(i): null

var size_ac: int:
	get: return _size_ac
	set(i): null


func from_image_resource(res: Resource) -> BasicMap:
	_image = res.get_image()
	if _image != null:
		# use square image region with size aligned to a power of 2
		_size_cc = nearest_po2(mini(_image.get_width(), _image.get_height()))
		# the power of 2
		_size_cc_2pow = floori(log(_size_cc)/log(2.0))
		if _size_cc_2pow >= AREA_SIZE_2POW:
			# so, it is a multiple of AREA_SIZE
			_size_cc_mask = _size_cc-1
			_size_cc_sqr = _size_cc*_size_cc
			_size_ac_2pow = _size_cc_2pow-AREA_SIZE_2POW
			_size_ac = 1<<_size_ac_2pow
			_size_ac_mask = _size_ac-1
			_size_ac_sqr = _size_ac*_size_ac
		else:
			# invalidate map
			_image = null
	return self


func from_image_path(image_path: String) -> BasicMap:
	return from_image_resource(load(image_path))


func is_valid() -> bool:
	return _image != null


func get_color_v2(vmcc: Vector2i) -> Color:
	return _image.get_pixel(
			vmcc.x & _size_cc_mask,
			vmcc.y & _size_cc_mask
		)


func get_color_v3(vmcc: Vector3i) -> Color:
	return _image.get_pixel(
			vmcc.x & _size_cc_mask,
			vmcc.y & _size_cc_mask
		)


func mcc_is_in(vmcc: Vector3i) -> bool:
	return vmcc.x >= 0 and vmcc.x < _size_cc \
		and vmcc.y >= 0 and vmcc.y < _size_cc
