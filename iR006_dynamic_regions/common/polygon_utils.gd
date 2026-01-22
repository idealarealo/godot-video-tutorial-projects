class_name PolygonUtils
extends Object

## A set of polygon-related utilities.


## Computes intersection between a Camera3D frustum and the horizontal plane (y=0),
## and returns the visible polygon.
## [br]
## [br]Inputs:
## [br][param camera] : the camera on whose 3D frustum it is obtained
## [br]
## [br]Outputs:
## [br][param polygon] : a list of counterclockwise ordered vertices
## [br][i][b]Return[/b][/i] : [code]true[/code] if [param polygon] is valid, [code]false[/code] otherwise
static func update_visible_polygon(camera: Camera3D, polygon: PackedVector3Array) -> bool:
	var frustum_planes := camera.get_frustum()
	var ground_plane := Plane(Vector3.UP)
	var w1
	var w2
	var vbl: Vector3
	var vbr: Vector3
	var vtl: Vector3
	var vtr: Vector3
	var vtf := Vector3.INF

	# find bottom left point
	w1 = ground_plane.intersect_3(frustum_planes[Projection.Planes.PLANE_LEFT], frustum_planes[Projection.Planes.PLANE_BOTTOM])
	w2 = ground_plane.intersect_3(frustum_planes[Projection.Planes.PLANE_LEFT], frustum_planes[Projection.Planes.PLANE_NEAR])
	if (w1 == null) || (frustum_planes[Projection.Planes.PLANE_NEAR].distance_to(w1) > 0.0) || (frustum_planes[Projection.Planes.PLANE_FAR].distance_to(w1) > 0.0):
		if w2 == null: return false
		vbl = w2
	else:
		if (w2 != null) && (frustum_planes[Projection.Planes.PLANE_BOTTOM].distance_to(w2) < 0.0):
			# under the ground
			return false
		vbl = w1

	# find bottom right point
	w1 = ground_plane.intersect_3(frustum_planes[Projection.Planes.PLANE_RIGHT], frustum_planes[Projection.Planes.PLANE_BOTTOM])
	w2 = ground_plane.intersect_3(frustum_planes[Projection.Planes.PLANE_RIGHT], frustum_planes[Projection.Planes.PLANE_NEAR])
	if (w1 == null) || (frustum_planes[Projection.Planes.PLANE_NEAR].distance_to(w1) > 0.0) || (frustum_planes[Projection.Planes.PLANE_FAR].distance_to(w1) > 0.0):
		if w2 == null: return false
		vbr = w2
	else:
		if (w2 != null) && (frustum_planes[Projection.Planes.PLANE_BOTTOM].distance_to(w2) < 0.0):
			# under the ground
			return false
		vbr = w1

	# find top left point
	w1 = ground_plane.intersect_3(frustum_planes[Projection.Planes.PLANE_LEFT], frustum_planes[Projection.Planes.PLANE_TOP])
	w2 = ground_plane.intersect_3(frustum_planes[Projection.Planes.PLANE_LEFT], frustum_planes[Projection.Planes.PLANE_FAR])
	if (w1 == null) || (frustum_planes[Projection.Planes.PLANE_NEAR].distance_to(w1) > 0.0) || (frustum_planes[Projection.Planes.PLANE_FAR].distance_to(w1) > 0.0):
		if w2 == null: return false
		vtl = w2
	else:
		if (w2 != null) && (frustum_planes[Projection.Planes.PLANE_TOP].distance_to(w2) < 0.0):
			# under the ground
			return false
		vtl = w1
		w1 = ground_plane.intersect_3(frustum_planes[Projection.Planes.PLANE_TOP], frustum_planes[Projection.Planes.PLANE_FAR])
		if (w1 != null) && (frustum_planes[Projection.Planes.PLANE_LEFT].distance_to(w1) < 0.0) && (frustum_planes[Projection.Planes.PLANE_RIGHT].distance_to(w1) < 0.0):
			vtf = w1
	
	# find top right point
	w1 = ground_plane.intersect_3(frustum_planes[Projection.Planes.PLANE_RIGHT], frustum_planes[Projection.Planes.PLANE_TOP])
	w2 = ground_plane.intersect_3(frustum_planes[Projection.Planes.PLANE_RIGHT], frustum_planes[Projection.Planes.PLANE_FAR])
	if (w1 == null) || (frustum_planes[Projection.Planes.PLANE_NEAR].distance_to(w1) > 0.0) || (frustum_planes[Projection.Planes.PLANE_FAR].distance_to(w1) > 0.0):
		if w2 == null: return false
		vtr = w2
	else:
		if (w2 != null) && (frustum_planes[Projection.Planes.PLANE_TOP].distance_to(w2) < 0.0):
			# under the ground
			return false
		vtr = w1
		if not vtf.is_finite():
			w1 = ground_plane.intersect_3(frustum_planes[Projection.Planes.PLANE_TOP], frustum_planes[Projection.Planes.PLANE_FAR])
			if (w1 != null) && (frustum_planes[Projection.Planes.PLANE_LEFT].distance_to(w1) < 0.0) && (frustum_planes[Projection.Planes.PLANE_RIGHT].distance_to(w1) < 0.0):
				vtf = w1
	
	polygon.resize(5 if vtf.is_finite() else 4)
	polygon.set(0, vtl)
	polygon.set(1, vbl)
	polygon.set(2, vbr)
	polygon.set(3, vtr)
	if vtf.is_finite():
		polygon.set(4, vtf)
	return true


## Simplified scanline-fill algorithm class.
## [br][br][code] Thread unsafe [/code]
##
## Computes fill scanlines for a convex polygon.
## [br]The polygon vertices must be ordered counterclockwise.
##
## @experimental: Customised implementation, might not work in all cases
class ScanlineFill:
	# constants
	static var _d := PackedInt32Array([1, -1])
	# variables
	var _r := Rect2i()
	var _p: Array[Vector2i]
	var _p_size: int
	var _s := PackedInt32Array([0,0])
	var _e := PackedInt32Array([0,0])
	var _v: Vector3i
	var _idy := PackedFloat32Array([0,0])
	var _w := PackedFloat32Array([0,0])

	func _init(bounds: Rect2i) -> void:
		_r = bounds
	
	## Compute horizontal fill scanlines for a convex polygon within a rectangular bounds.
	## [br]
	## [br][code] Thread unsafe [/code][br]
	## [br]
	## [br]Inputs:
	## [br][param p] : convex polygon (counterclockwise ordered vertices)
	## [br][param r] : scan bounds
	## [br]
	## [br]Outputs: (side effects)
	## [br][i][b]Return[/b][/i] : y-ordered dictionary of (point: true)
	func scan(p: Array[Vector2i]) -> Dictionary[Vector2i, bool]:
		# reset
		var res: Dictionary[Vector2i, bool] = {}
		_p = p
		if (p == null) || p.is_empty():
			return res
		_p_size = p.size()
		
		var ymn: int = p[0].y
		var i_ymn: int = 0
		for i in range(1, _p_size):
			if p[i].y < ymn:
				ymn = p[i].y
				i_ymn = i
		if ymn >= _r.end.y:
			return res

		_s.fill(i_ymn)
		_e[0] = posmod(i_ymn+1, _p_size)
		_e[1] = posmod(i_ymn-1, _p_size)
		_v.y = maxi(_r.position.y, ymn)
		
		_span(0)
		_span(1)
		
		var cc: bool = true
		var nc: bool
		while cc:
			nc = _and(_check(0), _check(1))
			_v.x = max(_r.position.x, roundi(lerpf(p[_s[0]].x, p[_e[0]].x, _w[0])))
			_v.z = min(_r.end.x, roundi(lerpf(p[_s[1]].x, p[_e[1]].x, _w[1])) + 1)
			for x in range(_v.x, _v.z):
				res.set(Vector2i(x, _v.y), true)
			_v.y += 1
			if _v.y >= _r.end.y:
				break
			_w[0] += _idy[0]
			_w[1] += _idy[1]
			cc = nc
		return res
	
	## logical-AND function: like && operator, but requires both operands to be evaluated first
	static func _and(b1, b2):
		return b1 && b2
	
	## Compute y increment and weight for a side.
	## [br]
	## [br]Inputs:
	## [br][param i] : side ([code]0[/code] = left , [code]1[/code] = right)
	## [br]
	## [br]Outputs: (side effects)
	func _span(i: int) -> void:
		var dy: int = _p[_e[i]].y - _p[_s[i]].y
		_idy[i] = 1.0 / float(dy + 1)
		_w[i] = float(_v.y - _p[_s[i]].y) * _idy[i]

	## Check y bounds on a side.
	## [br]
	## [br]Inputs:
	## [br][param i] : side ([code]0[/code] = left , [code]1[/code] = right)
	## [br]
	## [br]Outputs: (side effects)
	## [br][i][b]Return[/b][/i] : [code]true[/code] if [u]next[/u] scan is still in bounds, [code]false[/code] otherwise
	func _check(i: int) -> bool:
		while _p[_e[i]].y <= _v.y:
			if _e[i] == _e[i ^ 1]:
				return false
			_s[i] = _e[i]
			_e[i] = posmod(_e[i] + _d[i], _p_size)
			_span(i)
		return true
