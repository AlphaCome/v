import math
import rand.util
import wyrand

const (
	range_limit = 40
	value_count = 1000
	seeds       = [[u32(42), 0], [u32(256), 0]]
)

const (
	sample_size   = 1000
	stats_epsilon = 0.05
	inv_sqrt_12   = 1.0 / math.sqrt(12)
)

fn gen_randoms(seed_data []u32, bound int) []u64 {
	bound_u64 := u64(bound)
	mut randoms := [u64(0)].repeat(20)
	mut rnd := wyrand.WyRandRNG{}
	rnd.seed(seed_data)
	for i in 0 .. 20 {
		randoms[i] = rnd.u64n(bound_u64)
	}
	return randoms
}

fn test_wyrand_reproducibility() {
	seed_data := util.time_seed_array(2)
	randoms1 := gen_randoms(seed_data, 1000)
	randoms2 := gen_randoms(seed_data, 1000)
	assert randoms1.len == randoms2.len
	len := randoms1.len
	for i in 0 .. len {
		assert randoms1[i] == randoms2[i]
	}
}

// TODO: use the `in` syntax and remove this function
// after generics has been completely implemented
fn found(value u64, arr []u64) bool {
	for item in arr {
		if value == item {
			return true
		}
	}
	return false
}

fn test_wyrand_variability() {
	// If this test fails and if it is certainly not the implementation
	// at fault, try changing the seed values. Repeated values are
	// improbable but not impossible.
	for seed in seeds {
		mut rng := wyrand.WyRandRNG{}
		rng.seed(seed)
		mut values := []u64{cap: value_count}
		for i in 0 .. value_count {
			value := rng.u64()
			assert !found(value, values)
			assert values.len == i
			values << value
		}
	}
}

fn check_uniformity_u64(mut rng wyrand.WyRandRNG, range u64) {
	range_f64 := f64(range)
	expected_mean := range_f64 / 2.0
	mut variance := 0.0
	for _ in 0 .. sample_size {
		diff := f64(rng.u64n(range)) - expected_mean
		variance += diff * diff
	}
	variance /= sample_size - 1
	sigma := math.sqrt(variance)
	expected_sigma := range_f64 * inv_sqrt_12
	error := (sigma - expected_sigma) / expected_sigma
	assert math.abs(error) < stats_epsilon
}

fn test_wyrand_uniformity_u64() {
	ranges := [14019545, 80240, 130]
	for seed in seeds {
		mut rng := wyrand.WyRandRNG{}
		rng.seed(seed)
		for range in ranges {
			check_uniformity_u64(mut rng, u64(range))
		}
	}
}

fn check_uniformity_f64(mut rng wyrand.WyRandRNG) {
	expected_mean := 0.5
	mut variance := 0.0
	for _ in 0 .. sample_size {
		diff := rng.f64() - expected_mean
		variance += diff * diff
	}
	variance /= sample_size - 1
	sigma := math.sqrt(variance)
	expected_sigma := inv_sqrt_12
	error := (sigma - expected_sigma) / expected_sigma
	assert math.abs(error) < stats_epsilon
}

fn test_wyrand_uniformity_f64() {
	// The f64 version
	for seed in seeds {
		mut rng := wyrand.WyRandRNG{}
		rng.seed(seed)
		check_uniformity_f64(mut rng)
	}
}

fn test_wyrand_u32n() {
	max := u32(16384)
	for seed in seeds {
		mut rng := wyrand.WyRandRNG{}
		rng.seed(seed)
		for _ in 0 .. range_limit {
			value := rng.u32n(max)
			assert value >= 0
			assert value < max
		}
	}
}

fn test_wyrand_u64n() {
	max := u64(379091181005)
	for seed in seeds {
		mut rng := wyrand.WyRandRNG{}
		rng.seed(seed)
		for _ in 0 .. range_limit {
			value := rng.u64n(max)
			assert value >= 0
			assert value < max
		}
	}
}

fn test_wyrand_u32_in_range() {
	max := u32(484468466)
	min := u32(316846)
	for seed in seeds {
		mut rng := wyrand.WyRandRNG{}
		rng.seed(seed)
		for _ in 0 .. range_limit {
			value := rng.u32_in_range(min, max)
			assert value >= min
			assert value < max
		}
	}
}

fn test_wyrand_u64_in_range() {
	max := u64(216468454685163)
	min := u64(6848646868)
	for seed in seeds {
		mut rng := wyrand.WyRandRNG{}
		rng.seed(seed)
		for _ in 0 .. range_limit {
			value := rng.u64_in_range(min, max)
			assert value >= min
			assert value < max
		}
	}
}

fn test_wyrand_int31() {
	max_u31 := 0x7FFFFFFF
	sign_mask := 0x80000000
	for seed in seeds {
		mut rng := wyrand.WyRandRNG{}
		rng.seed(seed)
		for _ in 0 .. range_limit {
			value := rng.int31()
			assert value >= 0
			assert value <= max_u31
			// This statement ensures that the sign bit is zero
			assert (value & sign_mask) == 0
		}
	}
}

fn test_wyrand_int63() {
	max_u63 := i64(0x7FFFFFFFFFFFFFFF)
	sign_mask := i64(0x8000000000000000)
	for seed in seeds {
		mut rng := wyrand.WyRandRNG{}
		rng.seed(seed)
		for _ in 0 .. range_limit {
			value := rng.int63()
			assert value >= 0
			assert value <= max_u63
			assert (value & sign_mask) == 0
		}
	}
}

fn test_wyrand_intn() {
	max := 2525642
	for seed in seeds {
		mut rng := wyrand.WyRandRNG{}
		rng.seed(seed)
		for _ in 0 .. range_limit {
			value := rng.intn(max)
			assert value >= 0
			assert value < max
		}
	}
}

fn test_wyrand_i64n() {
	max := i64(3246727724653636)
	for seed in seeds {
		mut rng := wyrand.WyRandRNG{}
		rng.seed(seed)
		for _ in 0 .. range_limit {
			value := rng.i64n(max)
			assert value >= 0
			assert value < max
		}
	}
}

fn test_wyrand_int_in_range() {
	min := -4252
	max := 1034
	for seed in seeds {
		mut rng := wyrand.WyRandRNG{}
		rng.seed(seed)
		for _ in 0 .. range_limit {
			value := rng.int_in_range(min, max)
			assert value >= min
			assert value < max
		}
	}
}

fn test_wyrand_i64_in_range() {
	min := i64(-24095)
	max := i64(324058)
	for seed in seeds {
		mut rng := wyrand.WyRandRNG{}
		rng.seed(seed)
		for _ in 0 .. range_limit {
			value := rng.i64_in_range(min, max)
			assert value >= min
			assert value < max
		}
	}
}

fn test_wyrand_f32() {
	for seed in seeds {
		mut rng := wyrand.WyRandRNG{}
		rng.seed(seed)
		for _ in 0 .. range_limit {
			value := rng.f32()
			assert value >= 0.0
			assert value < 1.0
		}
	}
}

fn test_wyrand_f64() {
	for seed in seeds {
		mut rng := wyrand.WyRandRNG{}
		rng.seed(seed)
		for _ in 0 .. range_limit {
			value := rng.f64()
			assert value >= 0.0
			assert value < 1.0
		}
	}
}

fn test_wyrand_f32n() {
	max := f32(357.0)
	for seed in seeds {
		mut rng := wyrand.WyRandRNG{}
		rng.seed(seed)
		for _ in 0 .. range_limit {
			value := rng.f32n(max)
			assert value >= 0.0
			assert value < max
		}
	}
}

fn test_wyrand_f64n() {
	max := 1.52e6
	for seed in seeds {
		mut rng := wyrand.WyRandRNG{}
		rng.seed(seed)
		for _ in 0 .. range_limit {
			value := rng.f64n(max)
			assert value >= 0.0
			assert value < max
		}
	}
}

fn test_wyrand_f32_in_range() {
	min := f32(-24.0)
	max := f32(125.0)
	for seed in seeds {
		mut rng := wyrand.WyRandRNG{}
		rng.seed(seed)
		for _ in 0 .. range_limit {
			value := rng.f32_in_range(min, max)
			assert value >= min
			assert value < max
		}
	}
}

fn test_wyrand_f64_in_range() {
	min := -548.7
	max := 5015.2
	for seed in seeds {
		mut rng := wyrand.WyRandRNG{}
		rng.seed(seed)
		for _ in 0 .. range_limit {
			value := rng.f64_in_range(min, max)
			assert value >= min
			assert value < max
		}
	}
}
