class_name Hex
extends Object

const SQRT3 := sqrt(3.0)
const SQRT3_2 := SQRT3 / 2.0
const ISQRT3 := 1.0 / SQRT3
const ISQRT3_2 := 2.0 * ISQRT3

const TILE_RADIUS := ISQRT3

static var CUBE_TO_WORLD_BASIS := Basis(
		# q in (x, y, z)
		Vector3( SQRT3, 0.0, 0.0),
		# r in (x, y, z)
		Vector3(-SQRT3_2, 0.0, 1.5),
		# s in (x, y, z)
		Vector3(0.0, 0.0, 0.0),
	) * TILE_RADIUS

static var WORLD_TO_CUBE_BASIS := Basis(
		# x in (q, r, s)
		Vector3( ISQRT3, 0.0, -ISQRT3),
		# y in (q, r, s)
		Vector3(0.0, 0.0, 0.0),
		# z in (q, r, s)
		Vector3(1.0/3.0, 2.0/3.0, 1.0/3.0),
	) / TILE_RADIUS

static var CUBE_TO_AXIAL_BASIS := Basis(
		Vector3( 1.0, 0.0, 0.0),
		Vector3( 0.0, 1.0, 0.0),
		Vector3( 0.0, 0.0, 0.0),
	)

static var AXIAL_TO_CUBE_BASIS := Basis(
		Vector3( 1.0, 0.0, 0.0),
		Vector3( 0.0, 1.0, 0.0),
		Vector3(-1.0, 1.0, 0.0),
	)


class CubeVeci:
	# (x,y,z,w) -> (q,r,s,t) -> (\,|,/,^)
	# var vi: Vector4i
	var vi: Vector3i
	var wi: int
	
	static func from_vec4xi(vi: Vector3i, wi: int) -> CubeVeci:
		return CubeVeci.new().set_from_vec4xi(vi, wi)
	
	static func from_vec4x(v: Vector3, w: float) -> CubeVeci:
		return CubeVeci.new().set_from_vec4x(v, w)

	func set_from_vec4xi(vi: Vector3i, wi: int) -> CubeVeci:
		self.vi = vi
		self.wi = wi
		return self
		
	func set_from_vec4x(v: Vector3, w: float) -> CubeVeci:
		vi = v
		wi = w
		return self

	func adjust_z() -> CubeVeci:
		vi.z = vi.y - vi.x
		return self

	func set_from_cube_veci(cvi: CubeVeci) -> CubeVeci:
		self.vi = cvi.vi
		return self
	
	func to_world()	-> Vector3:
		var wv := Hex.CUBE_TO_WORLD_BASIS * Vector3(vi)
		wv.y = wi
		return wv
	
	func distance(cvi: CubeVeci) -> int:
		var advi := (vi - cvi.vi).abs()
		return max(advi.x, advi.y, advi.z)
	

class CubeVec:
	# (x,y,z,w) -> (q,r,s,t) -> (\,|,/,^)
	# var v: Vector4
	var v: Vector3
	var w: float
	
	static func from_vec4x(v: Vector3, w: float) -> CubeVec:
		return CubeVec.new().set_from_vec4x(v, w)

	static func from_world(wv: Vector3) -> CubeVec:
		return CubeVec.new().set_from_world(wv)

	func set_from_vec4x(v: Vector3, w: float) -> CubeVec:
		self.v = v
		self.w = w
		return self
		
	func set_from_cube_vec(cv: CubeVec) -> CubeVec:
		self.v = cv.v
		return self
	
	func set_from_cube_veci(cvi: CubeVeci) -> CubeVec:
		self.v = cvi.vi
		return self

	func set_from_world(wv: Vector3) -> CubeVec:
		self.v = Hex.WORLD_TO_CUBE_BASIS * wv
		self.w = wv.y
		return self

	func to_cube_veci(cvi: CubeVeci = null) -> CubeVeci:
		if cvi == null:
			cvi = CubeVeci.new()
		var rcv = to_rounded()
		return cvi.set_from_vec4x(rcv.v, rcv.w)

	func to_world()	-> Vector3:
		var wv := Hex.CUBE_TO_WORLD_BASIS * v
		wv.y = w
		return wv

	func to_rounded(rcv: CubeVec = null) -> CubeVec:
		if rcv == null:
			rcv = CubeVec.new()
		var vi = v.round()
		rcv.v = vi
		var vd = (vi - v).abs()
		if (vd.x > vd.y) && (vd.x > vd.z):
			# vd.x greatest, so vd.x is minority
			rcv.v.x = rcv.v.y - rcv.v.z
		elif (vd.y > vd.z):
			# vd.y greatest, so vd.y is minority
			rcv.v.y = rcv.v.x + rcv.v.z
		else:
			# vd.z greatest, so vd.z is minority
			rcv.v.z = rcv.v.y - rcv.v.x
		return rcv


class AxialVeci:
	# (x,y,z) -> (-,/,^)
	var vi: Vector3i

	static func from_cube_veci(cvi: CubeVeci) -> AxialVeci:
		return AxialVeci.new().set_from_cube_veci(cvi)
		
	static func from_vec3i(vi: Vector3i) -> AxialVeci:
		return AxialVeci.new().set_from_vec3i(vi)
	
	static func from_vec3(v: Vector3) -> AxialVeci:
		return AxialVeci.new().set_from_vec3(v)
	
	func set_from_cube_veci(cvi: CubeVeci) -> AxialVeci:
		self.vi = Vector3i(cvi.vi.x, cvi.vi.y, cvi.wi)
		return self
		
	func set_from_vec3i(vi: Vector3i) -> AxialVeci:
		self.vi = vi
		return self
		
	func set_from_vec3(v: Vector3) -> AxialVeci:
		vi = v
		return self

	func to_cube_veci(cvi: CubeVeci = null) -> CubeVeci:
		if cvi == null:
			cvi = CubeVeci.new()
		return cvi.set_from_vec4xi(Vector3(vi.x, vi.y, vi.y-vi.z), vi.z)


class AxialVec:
	# (x,y,z) -> (-,/,^)
	var v: Vector3
	
	static func from_cube_vec(cv: CubeVec) -> AxialVec:
		return AxialVec.new().set_from_cube_vec(cv)
		
	static func from_vec3(v: Vector3) -> AxialVec:
		return AxialVec.new().set_from_vec3(v)
		
	func set_from_cube_vec(cv: CubeVec) -> AxialVec:
		v = Hex.CUBE_TO_AXIAL_BASIS * cv.v
		return self
		
	func set_from_vec3(v: Vector3) -> AxialVec:
		self.v = v
		return self

	func to_cube_vec(cv: CubeVec = null) -> CubeVec:
		if cv == null:
			cv = CubeVec.new()
		return cv.set_from_vec4x(Hex.AXIAL_TO_CUBE_BASIS * v, v.z)
