import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Analysis.SpecialFunctions.Complex.Arg
/-!
# Standard Vector Space

This file defines the standard inner product real vector space of dimension two, but we will build this on the complex numbers. 

## Important definitions

* `Vec` : The class of "2d vectors", `ℂ`, with a typical inner product space structure which is NOT instancialized. 
* `Vec_nd` : The class of nonzero vectors, `nd` for nondegenerate. 
* `Dir` : The class of `Vec_nd` quotient by `ℝ⁺`. 
* `Proj` : the class of `Dir` quotient by `±1`, in other words, `ℝP¹` . 

## Notation

## Implementation Notes

Then we define the class `Dir` of vectors of unit length. We equip it with the structure of commutative group. The quotient `Proj` of `Dir` by `±1` is automatically a commutative group.

## Further Works

-/

noncomputable section
namespace EuclidGeom

scoped notation "π" => Real.pi

-- #synth InnerProductSpace ℝ ℂ 
-- InnerProductSpace.complexToReal


/- the notation for the class of vectors -/
scoped notation "Vec" => ℂ 

/- the class of non-degenerate vectors -/
def Vec_nd := {z : ℂ // z ≠ 0}

instance : Coe Vec_nd Vec where
  coe := fun z => z.1

namespace Vec_nd

instance : Mul Vec_nd where
  mul z w := ⟨z * w, mul_ne_zero_iff.2 ⟨z.2, w.2⟩⟩

instance : Semigroup Vec_nd where
  mul_assoc := fun _ _ _ => Subtype.ext (mul_assoc _ _ _)

instance : Monoid Vec_nd where
  one := ⟨1, one_ne_zero⟩
  one_mul := fun _ => Subtype.ext (one_mul _)
  mul_one := fun _ => Subtype.ext (mul_one _)

instance : CommGroup Vec_nd where
  inv := fun z => ⟨z⁻¹, inv_ne_zero z.2⟩
  mul_left_inv := fun z => Subtype.ext (inv_mul_cancel z.2)
  mul_comm := fun z w => Subtype.ext (mul_comm z.1 w.1)

instance : HasDistribNeg Vec_nd where
  neg := fun z => ⟨-z, neg_ne_zero.2 z.2⟩
  neg_neg := fun _ => Subtype.ext (neg_neg _)
  neg_mul := fun _ _ => Subtype.ext (neg_mul _ _)
  mul_neg := fun _ _ => Subtype.ext (mul_neg _ _)

end Vec_nd

def Vec.norm (x : Vec) := Complex.abs x

def Vec_nd.norm (x : Vec_nd) := Complex.abs x

theorem Vec_nd.norm_ne_zero (z : Vec_nd) : Vec_nd.norm z ≠ 0 := norm_ne_zero_iff.2 z.2

theorem Vec_nd.ne_zero_of_ne_zero_smul (z : Vec_nd) {t : ℝ} (h : t ≠ 0) : t • z.1 ≠ 0 := by
  simp only [ne_eq, smul_eq_zero, h, z.2, or_self, not_false_eq_true]

theorem Vec_nd.ne_zero_of_neg (z : Vec_nd) : - z.1 ≠ 0 := by 
  simp only [ne_eq, neg_eq_zero, z.2, not_false_eq_true]

@[simp]
theorem fst_of_one_toVec_eq_one : (1 : Vec_nd).1 = 1 := rfl

@[simp]
theorem fst_neg_Vec_nd_is_neg_fst_Vec_nd (z : Vec_nd) : (-z).1 = -(z.1) := rfl

@[simp]
theorem ne_zero_of_Vec_nd (z : Vec_nd) : z.1 ≠ 0 := z.2

@[simp]
theorem real_smul_Vec_eq_mul_of (z : Vec) (r : ℝ) : r • z = r * z := rfl

@[simp]
theorem fst_of_mul_eq_fst_mul_fst (z w : Vec_nd) : (z * w).1 = z.1 * w.1 := by rfl

@[simp]
theorem norm_of_Vec_nd_eq_norm_of_Vec_nd_fst (z : Vec_nd) : Vec_nd.norm z = Vec.norm z := rfl

def Vec_nd.normalize_toVec_nd (z : Vec_nd) : Vec_nd := ⟨(Vec_nd.norm z)⁻¹ • z.1, Vec_nd.ne_zero_of_ne_zero_smul z (inv_ne_zero (Vec_nd.norm_ne_zero z))⟩

def Vec_nd.normalize_toVec_nd' : Vec_nd →* Vec_nd where
  toFun := Vec_nd.normalize_toVec_nd
  map_one' := by
    apply Subtype.ext
    unfold normalize_toVec_nd norm
    simp only [ne_eq, fst_of_one_toVec_eq_one, map_one, inv_one, one_smul]
  map_mul' x y := by
    apply Subtype.ext
    unfold normalize_toVec_nd norm
    simp only [ne_eq, fst_of_mul_eq_fst_mul_fst, map_mul, mul_inv_rev, Complex.real_smul, Complex.ofReal_mul,
      Complex.ofReal_inv]
    ring


@[ext]
class Dir where
  toVec : Vec
  unit : @inner ℝ _ _ toVec toVec = 1

@[simp]
theorem dir_toVec_fst_mul_fst_plus_snd_mul_snd_eq_one (x : Dir) : x.1.1 * x.1.1 + x.1.2 * x.1.2 = 1 := by
  rw [← x.2]
  unfold inner InnerProductSpace.toInner InnerProductSpace.complexToReal InnerProductSpace.isROrCToReal
  simp only [Complex.inner, Complex.mul_re, Complex.conj_re, Complex.conj_im, neg_mul, sub_neg_eq_add]

def Vec_nd.normalize (z : Vec_nd) : Dir where
  toVec := (Vec.norm z.1)⁻¹ • z.1
  unit := by
    rw [inner_smul_left _ _, inner_smul_right _ _]
    simp only [map_inv₀, IsROrC.conj_to_real]
    rw [inv_mul_eq_iff_eq_mul₀, inv_mul_eq_iff_eq_mul₀, ← mul_assoc, ← pow_two, real_inner_self_eq_norm_sq, mul_one]
    rfl
    exact norm_ne_zero_iff.2 z.2
    exact norm_ne_zero_iff.2 z.2

-- Basic facts about Dir, the group structure, neg, and the fact that we can make angle using Dir. There are a lot of relevant (probably easy) theorems under the following namespace. 

namespace Dir

/- the CommGroup instance on `Dir` -/

instance : Neg Dir where
  neg := fun z => {
      toVec := -z.toVec
      unit := by 
        rw [← unit]
        exact inner_neg_neg _ _
    }

instance : Mul Dir where
  mul := fun z w => {
    toVec := z.1 * w.1
    unit := by
      nth_rw 1 [← one_mul 1, ← z.unit, ← w.unit]
      unfold Inner.inner InnerProductSpace.toInner InnerProductSpace.complexToReal InnerProductSpace.isROrCToReal
      simp only [Complex.inner, map_mul, Complex.mul_re, Complex.conj_re, Complex.conj_im, mul_neg, neg_mul, neg_neg,
        Complex.mul_im, sub_neg_eq_add]
      ring
  }

instance : One Dir where
  one := {
    toVec := 1
    unit := by 
      simp only [Complex.inner, map_one, mul_one, Complex.one_re]
  }

/- Put tautological theorems into simp -/
@[simp]
theorem fst_of_one_eq_one : (1 : Dir).1.1 = 1 := rfl

@[simp]
theorem snd_of_one_eq_zero : (1 : Dir).1.2 = 0 := rfl

@[simp]
theorem one_eq_one_toComplex : (1 : Dir).1 = 1 := rfl

@[simp]
theorem toVec_sq_add_sq_eq_one (x : Dir) : x.1.1 ^ 2 + x.1.2 ^ 2 = 1 := by
  rw [pow_two, pow_two]
  simp only [dir_toVec_fst_mul_fst_plus_snd_mul_snd_eq_one]

-- Give a CommGroup structure to Dir by the mul structure of ℂ

instance : Semigroup Dir where
  mul_assoc _ _ _ := by
    ext : 1
    unfold toVec HMul.hMul instHMul Mul.mul instMulDir
    simp
    ring_nf

instance : Monoid Dir where
  one_mul := fun _ => by
    ext : 1
    unfold toVec HMul.hMul instHMul Mul.mul Semigroup.toMul instSemigroupDir instMulDir
    simp only [Dir.one_eq_one_toComplex, one_mul]
    rfl
  mul_one := fun _ => by
    ext : 1
    unfold toVec HMul.hMul instHMul Mul.mul Semigroup.toMul instSemigroupDir instMulDir
    simp only [Dir.one_eq_one_toComplex, mul_one]
    rfl

instance : CommGroup Dir where
  inv := fun x => {
    toVec := ⟨x.1.1, -x.1.2⟩
    unit := by
      unfold inner InnerProductSpace.toInner InnerProductSpace.complexToReal InnerProductSpace.isROrCToReal
      simp only [Complex.inner, Complex.mul_re, Complex.conj_re, Complex.conj_im, neg_neg, mul_neg, sub_neg_eq_add,
        dir_toVec_fst_mul_fst_plus_snd_mul_snd_eq_one]
  }
  mul_left_inv x := by
    ext : 1
    unfold Inv.inv HMul.hMul instHMul Mul.mul Semigroup.toMul Monoid.toSemigroup instMonoidDir instSemigroupDir instMulDir HMul.hMul instHMul Mul.mul Complex.instMulComplex
    ext
    simp only [neg_mul, sub_neg_eq_add, dir_toVec_fst_mul_fst_plus_snd_mul_snd_eq_one, one_eq_one_toComplex,
      Complex.one_re]
    simp only [neg_mul, sub_neg_eq_add, dir_toVec_fst_mul_fst_plus_snd_mul_snd_eq_one, one_eq_one_toComplex,
      Complex.one_im]
    ring
  mul_comm _ _ := by
    ext : 1
    unfold toVec HMul.hMul instHMul Mul.mul Semigroup.toMul Monoid.toSemigroup instMonoidDir instSemigroupDir instMulDir
    dsimp
    ring_nf

instance : HasDistribNeg Dir where
  neg := Neg.neg
  neg_neg _ := by
    unfold Neg.neg instNegDir
    simp only [neg_neg]
  neg_mul _ _ := by
    ext : 1
    unfold Neg.neg instNegDir toVec HMul.hMul instHMul Mul.mul instMulDir toVec
    simp only [neg_mul]
  mul_neg _ _ := by
    ext : 1
    unfold Neg.neg instNegDir toVec HMul.hMul instHMul Mul.mul instMulDir toVec
    simp only [mul_neg]

@[simp]
theorem toVec_neg_eq_neg_toVec (x : Dir) : (-x).toVec = -(x.toVec) := rfl

@[simp]
theorem fst_of_neg_one_eq_neg_one : (-1 : Dir).toVec.1 = -1 := rfl

@[simp]
theorem snd_of_neg_one_eq_zero : (-1 : Dir).toVec.2 = 0 := by
  rw [← neg_zero]
  rfl

def angle (x y : Dir) := Complex.arg ( (y * (x⁻¹)).1)

theorem fst_of_angle_toVec (x y : Dir) : (y * (x⁻¹)).1.1 = x.1.1 * y.1.1 + x.1.2 * y.1.2 := by
  have h : x.1.1 * y.1.1 + x.1.2 * y.1.2 = y.1.1 * x.1.1 - y.1.2 * (-x.1.2) := by ring
  rw [h]
  rfl

def mk_angle (θ : ℝ) : Dir where
  toVec := ⟨Real.cos θ, Real.sin θ⟩
  unit := by
    unfold inner InnerProductSpace.toInner InnerProductSpace.complexToReal InnerProductSpace.isROrCToReal
    rw [← Real.cos_sq_add_sin_sq θ]
    rw [pow_two, pow_two]
    simp only [Complex.inner, Complex.mul_re, Complex.conj_re, Complex.conj_im, neg_mul, sub_neg_eq_add]
    

theorem toVec_ne_zero (x : Dir) : x.toVec ≠ 0 := by
  by_contra h
  have h' : @inner ℝ _ _ x.toVec x.toVec = 0 := by
    rw [h]
    unfold inner InnerProductSpace.toInner InnerProductSpace.complexToReal InnerProductSpace.isROrCToReal
    simp only [inner_zero_right]
  let g := x.unit
  rw [h'] at g
  exact zero_ne_one g

def toVec_nd (x : Dir) : Vec_nd := ⟨x.toVec, toVec_ne_zero x⟩

@[simp]
theorem norm_of_dir_toVec_eq_one (x : Dir) : Vec.norm x.toVec = 1 := by
  sorry

@[simp]
theorem dir_toVec_nd_normalize_eq_self (x : Dir) : Vec_nd.normalize (⟨x.toVec, toVec_ne_zero x⟩ : Vec_nd) = x := by
  ext : 1
  unfold Vec_nd.normalize
  simp only [norm_of_dir_toVec_eq_one, inv_one, one_smul]

/- The direction `Dir.I`, defined as `Complex.I`, the direction of y-axis. It will be used in section perpendicular. -/
def I : Dir where
  toVec := Complex.I
  unit := by
    unfold inner InnerProductSpace.toInner InnerProductSpace.complexToReal InnerProductSpace.isROrCToReal
    simp only [Complex.inner, Complex.conj_I, neg_mul, Complex.I_mul_I, neg_neg, Complex.one_re]

@[simp]
theorem fst_of_I_eq_zero : I.1.1 = 0 := rfl

@[simp]
theorem snd_of_I_eq_one : I.1.2 = 1 := rfl

@[simp]
theorem I_toComplex_eq_I : I.1 = Complex.I := rfl

@[simp]
theorem neg_I_toComplex_eq_neg_I : (-I).1 = -Complex.I := rfl

@[simp]
theorem I_mul_I_eq_neg_one : I * I = -(1 : Dir) := by
  ext : 1
  unfold HMul.hMul instHMul Mul.mul instMulDir
  simp only [I_toComplex_eq_I, Complex.I_mul_I, toVec_neg_eq_neg_toVec]
  ext
  rfl
  rfl

@[simp]
theorem inv_of_I_eq_neg_I : I⁻¹ = - I := by
  apply @mul_right_cancel _ _ _ _ I _
  simp only [mul_left_inv, neg_mul, I_mul_I_eq_neg_one, neg_neg]

section Make_angle_theorems

@[simp]
theorem mk_angle_arg_toComplex_of_nonzero_eq_normalize (x : Vec_nd) : mk_angle (Complex.arg x.1) = Vec_nd.normalize x := by
  ext : 1
  unfold Vec_nd.normalize mk_angle HSMul.hSMul instHSMul SMul.smul Complex.instSMulRealComplex Vec.norm
  ext
  dsimp
  rw [Complex.cos_arg, zero_mul, sub_zero]
  ring
  exact ne_zero_of_Vec_nd x
  dsimp
  rw [Complex.sin_arg, mul_comm]
  ring

@[simp]
theorem mk_angle_arg_toComplex_of_Dir_eq_self (x: Dir) : mk_angle (Complex.arg (x.1)) = x := by
  have w : Complex.abs (x.1) = 1 := norm_of_dir_toVec_eq_one x
  ext : 1
  unfold mk_angle
  simp
  rw [Complex.cos_arg, Complex.sin_arg, w]
  unfold toVec
  ext : 1
  simp only [div_one]
  simp only [div_one]
  by_contra h
  rw [h] at w
  simp only [map_zero, zero_ne_one] at w  

@[simp]
theorem mk_angle_zero_eq_one : mk_angle 0 = 1 := by
  unfold mk_angle
  ext
  simp only [Real.cos_zero, Real.sin_zero, Dir.fst_of_one_eq_one]
  simp only [Real.cos_zero, Real.sin_zero, Dir.snd_of_one_eq_zero]

@[simp]
theorem mk_angle_pi_eq_neg_one : mk_angle π = -1 := by
  unfold mk_angle
  ext
  simp only [Real.cos_pi, Real.sin_pi, toVec_neg_eq_neg_toVec, one_eq_one_toComplex, Complex.neg_re, Complex.one_re]
  simp only [Real.cos_pi, Real.sin_pi, toVec_neg_eq_neg_toVec, one_eq_one_toComplex, Complex.neg_im, Complex.one_im, neg_zero]

@[simp]
theorem mk_angle_neg_pi_eq_neg_one : mk_angle (-π) = -1 := by
  unfold mk_angle
  ext
  simp only [Real.cos_neg, Real.cos_pi, Real.sin_neg, Real.sin_pi, neg_zero, toVec_neg_eq_neg_toVec, one_eq_one_toComplex, Complex.neg_re, Complex.one_re]
  simp only [Real.cos_neg, Real.cos_pi, Real.sin_neg, Real.sin_pi, neg_zero, toVec_neg_eq_neg_toVec, one_eq_one_toComplex, Complex.neg_im, Complex.one_im]

theorem mk_angle_neg_mul_mk_angle_eq_one (x : ℝ) : mk_angle (-x) * mk_angle x = 1 := by
  ext
  unfold toVec mk_angle HMul.hMul instHMul Mul.mul instMulDir
  simp only [Real.cos_neg, Real.sin_neg, Complex.mul_re, neg_mul, sub_neg_eq_add]
  rw [← pow_two, ← pow_two, Real.cos_sq_add_sin_sq x]
  rfl
  unfold toVec mk_angle HMul.hMul instHMul Mul.mul instMulDir
  simp only [Real.cos_neg, Real.sin_neg, Complex.mul_im, neg_mul]
  rw [mul_comm, add_right_neg]
  rfl

@[simp]
theorem mk_angle_neg_eq_mk_angle_inv (x : ℝ) : mk_angle (-x) = (mk_angle x)⁻¹ := by
  rw [← one_mul (mk_angle x)⁻¹, ← mk_angle_neg_mul_mk_angle_eq_one x, mul_assoc, mul_right_inv, mul_one]

@[simp]
theorem mk_angle_pi_div_two_eq_I : mk_angle (π / 2) = I := by
  unfold mk_angle
  ext
  simp only [Real.cos_pi_div_two, Real.sin_pi_div_two, fst_of_I_eq_zero]
  simp only [Real.cos_pi_div_two, Real.sin_pi_div_two, snd_of_I_eq_one]

@[simp]
theorem mk_angle_neg_pi_div_two_eq_neg_I : mk_angle (-(π / 2)) = -I := by
  unfold mk_angle
  ext
  simp only [Real.cos_neg, Real.cos_pi_div_two, Real.sin_neg, Real.sin_pi_div_two, toVec_neg_eq_neg_toVec, I_toComplex_eq_I, Complex.neg_re, Complex.I_re, neg_zero]
  simp only [Real.cos_neg, Real.cos_pi_div_two, Real.sin_neg, Real.sin_pi_div_two, toVec_neg_eq_neg_toVec, I_toComplex_eq_I, Complex.neg_im, Complex.I_im]

@[simp]
theorem mk_angle_neg_pi_div_two_eq_neg_I' : mk_angle ((-π) / 2) = -I := by
  rw [neg_div]
  simp only [mk_angle_neg_pi_div_two_eq_neg_I]

end Make_angle_theorems

end Dir

def PM : Dir → Dir → Prop :=
fun x y => x = y ∨ x = -y

-- Now define the equivalence PM. 

namespace PM

def equivalence : Equivalence PM where
  refl _ := by simp [PM]
  symm := fun h => 
    match h with
      | Or.inl h₁ => Or.inl (Eq.symm h₁)
      | Or.inr h₂ => Or.inr (Iff.mp neg_eq_iff_eq_neg (id (Eq.symm h₂)))
  trans := by
    intro _ _ _ g h
    unfold PM
    match g with
      | Or.inl g₁ => 
          rw [← g₁] at h
          exact h
      | Or.inr g₂ => 
          match h with
            | Or.inl h₁ =>
              right
              rw [← h₁, g₂]
            | Or.inr h₂ =>
              left
              rw [g₂, h₂, ← Iff.mp neg_eq_iff_eq_neg rfl]

instance con : Con Dir where
  r := PM
  iseqv := PM.equivalence
  mul' := by
    unfold Setoid.r PM
    intro _ x _ z g h
    match g with
      | Or.inl g₁ => 
        match h with
          | Or.inl h₁ =>
            left
            rw [g₁, h₁]
          | Or.inr h₂ =>
            right
            rw [g₁, h₂, ← mul_neg _ _]
      | Or.inr g₂ => 
        match h with
          | Or.inl h₁ =>
            right
            rw [g₂, h₁, ← neg_mul _ _]
          | Or.inr h₂ =>
            left
            rw[g₂, h₂, ← neg_mul_neg x z]

end PM

def Proj := Con.Quotient PM.con

-- We can take quotient from Dir to get Proj. 

namespace Proj

instance : MulOneClass Proj := Con.mulOneClass PM.con

instance : Group Proj := Con.group PM.con

instance : CommMonoid Proj := Con.commMonoid PM.con

instance : CommGroup Proj where
  mul_comm := instCommMonoidProj.mul_comm

end Proj

def Dir.toProj (v : Dir) : Proj := ⟦v⟧

instance : Coe Dir Proj where
  coe v := v.toProj

def Vec_nd.toProj (v : Vec_nd) : Proj := (Vec_nd.normalize v : Proj) 

-- Coincidence of toProj gives rise to important results, especially that two Vec_nd-s have the same toProj iff they are equal by taking a real (nonzero) scaler. We will prove this statement in the following section. 

theorem normalize_eq_normalize_smul_pos (u v : Vec_nd) {t : ℝ} (h : v.1 = t • u.1) (ht : 0 < t) : Vec_nd.normalize u = Vec_nd.normalize v := by
  unfold Vec_nd.normalize
  ext : 1
  have g : (Vec.norm v) • u.1 = (Vec.norm u) • v.1 := by
    have w₁ : (Vec.norm (t • u.1)) = ‖t‖ * (Vec.norm u.1) := norm_smul t u.1
    have w₂ : ‖t‖ = t := abs_of_pos ht
    rw [h, w₁, w₂, mul_comm]
    exact mul_smul (Vec.norm u.1) t u.1
  have g' : Vec.norm v * u.1 = Vec.norm u * v.1 := g
  have hu : (Vec.norm u : ℂ) ≠ 0 := by
    rw [← norm_of_Vec_nd_eq_norm_of_Vec_nd_fst u]
    exact Iff.mpr Complex.ofReal_ne_zero (Vec_nd.norm_ne_zero u)
  have hv : (Vec.norm v : ℂ) ≠ 0 := by
    rw [← norm_of_Vec_nd_eq_norm_of_Vec_nd_fst v]
    exact Iff.mpr Complex.ofReal_ne_zero (Vec_nd.norm_ne_zero v)
  let w := (inv_mul_eq_iff_eq_mul₀ hu).2 g'
  rw [mul_left_comm] at w
  simp only [ne_eq, norm_of_Vec_nd_eq_norm_of_Vec_nd_fst, Complex.real_smul, Complex.ofReal_inv, MonoidHom.coe_mk,
    OneHom.coe_mk]
  exact Eq.symm ((inv_mul_eq_iff_eq_mul₀ hv).2 (Eq.symm w))

theorem neg_normalize_eq_normalize_smul_neg (u v : Vec_nd) {t : ℝ} (h : v.1 = t • u.1) (ht : t < 0) : -Vec_nd.normalize u = Vec_nd.normalize v := by
  unfold Vec_nd.normalize
  ext : 1
  simp only [ne_eq, MonoidHom.coe_mk, OneHom.coe_mk, fst_neg_Vec_nd_is_neg_fst_Vec_nd]
  have g : (-Vec.norm v) • u.1 = (Vec.norm u) • v.1 := by
    have w₁ : (Vec.norm (t • u.1)) = ‖t‖ * (Vec.norm u.1) := norm_smul t u.1
    have w₂ : ‖t‖ = -t := abs_of_neg ht
    rw [h, w₁, w₂, neg_mul, neg_neg, mul_comm]
    exact mul_smul (Vec.norm u.1) t u.1
  have g' : (-(Vec.norm v : ℂ)) * u.1 = Vec.norm u * v.1 := by
    rw [Eq.symm (Complex.ofReal_neg (Vec.norm v))]
    exact g
  have hu : (Vec.norm u : ℂ) ≠ 0 := by
    rw [← norm_of_Vec_nd_eq_norm_of_Vec_nd_fst u]
    exact Iff.mpr Complex.ofReal_ne_zero (Vec_nd.norm_ne_zero u)
  have hv : -(Vec.norm v : ℂ) ≠ 0 := by
    rw [← norm_of_Vec_nd_eq_norm_of_Vec_nd_fst v]
    exact neg_ne_zero.2 (Iff.mpr Complex.ofReal_ne_zero (Vec_nd.norm_ne_zero v))
  let w := (inv_mul_eq_iff_eq_mul₀ hu).2 g'
  rw [mul_left_comm] at w
  simp only [ne_eq, norm_of_Vec_nd_eq_norm_of_Vec_nd_fst, Complex.real_smul, Complex.ofReal_inv, MonoidHom.coe_mk,
    OneHom.coe_mk]
  let w' := Eq.symm ((inv_mul_eq_iff_eq_mul₀ hv).2 (Eq.symm w))
  rw [← neg_inv, neg_mul] at w'
  exact Iff.mpr neg_eq_iff_eq_neg w'

@[simp]
theorem neg_normalize_eq_normalize_eq (z : Vec_nd) : Vec_nd.normalize (-z) = - Vec_nd.normalize z := by
  symm
  apply neg_normalize_eq_normalize_smul_neg z (-z) (t := -1) 
  simp only [ne_eq, fst_neg_Vec_nd_is_neg_fst_Vec_nd, neg_smul, one_smul]
  linarith




section Linear_Algebra

theorem det_eq_zero_iff_eq_smul (u v : Vec) (hu : u ≠ 0) : u.1 * v.2 - u.2 * v.1 = 0 ↔ (∃ (t : ℝ), v = t • u) := by
  have h : (u.1 ≠ 0) ∨ (u.2 ≠ 0) := by
    by_contra _
    have h₁ : u.1 = 0 := by tauto
    have h₂ : u.2 = 0 := by tauto
    have hu' : u = ⟨0, 0⟩ := by exact Complex.ext h₁ h₂
    tauto
  constructor
  · intro e
    match h with 
    | Or.inl h₁ =>
      use v.1 * (u.1⁻¹)
      unfold HSMul.hSMul instHSMul SMul.smul Complex.instSMulRealComplex
      simp only [smul_eq_mul, zero_mul, sub_zero, add_zero, ne_eq]
      ext
      simp only [smul_eq_mul, ne_eq]
      exact Iff.mp (div_eq_iff h₁) rfl
      simp only [smul_eq_mul]
      rw [mul_comm v.1 u.1⁻¹, mul_assoc, mul_comm v.1 u.2]
      rw [sub_eq_zero] at e
      exact Iff.mpr (eq_inv_mul_iff_mul_eq₀ h₁) e
    | Or.inr h₂ =>
      use v.2 * (u.2⁻¹)
      unfold HSMul.hSMul instHSMul SMul.smul Complex.instSMulRealComplex
      simp only [smul_eq_mul, zero_mul, sub_zero, add_zero, ne_eq]
      ext
      simp only [smul_eq_mul]
      rw [mul_comm v.2 u.2⁻¹, mul_assoc]
      rw [sub_eq_zero, mul_comm u.1 v.2] at e
      exact Iff.mpr (eq_inv_mul_iff_mul_eq₀ h₂) (id (Eq.symm e))
      simp only [smul_eq_mul, ne_eq]
      exact Iff.mp (div_eq_iff h₂) rfl
  · intro e'
    rcases e' with ⟨t, e⟩
    unfold HSMul.hSMul instHSMul SMul.smul Complex.instSMulRealComplex at e
    simp only [smul_eq_mul] at e 
    rcases e
    ring

theorem linear_combination_of_not_colinear {u v w : Vec} (hu : u ≠ 0) (h' : ¬(∃ (t : ℝ), v = t • u)) : ∃ (cu cv : ℝ), w = cu • u + cv • v := by
  have h₁ : (¬ (∃ (t : ℝ), v = t • u)) → (¬ (u.1 * v.2 - u.2 * v.1 = 0)) := by
    intro _
    by_contra h₂
    let _ := (det_eq_zero_iff_eq_smul u v hu).1 h₂
    tauto
  let d := u.1 * v.2 - u.2 * v.1
  have h₃ : d ≠ 0 := h₁ h'
  use d⁻¹ * (w.1 * v.2 - v.1 * w.2) 
  use d⁻¹ * (u.1 * w.2 - w.1 * u.2)
  symm
  rw [mul_smul, mul_smul, ← smul_add]
  apply ((inv_smul_eq_iff₀ h₃).2)
  unfold HSMul.hSMul instHSMul SMul.smul MulAction.toSMul Complex.mulAction Complex.instSMulRealComplex
  simp only [smul_eq_mul, zero_mul, sub_zero]
  apply Complex.ext
  simp only [add_zero, Complex.add_re]
  ring
  simp only [add_zero, Complex.add_im]
  ring

/-
theorem linear_combination_of_not_colinear {u v : Vec_nd} (w : Vec) (h' : Vec_nd.toProj u ≠ Vec_nd.toProj v) : ∃ (cᵤ cᵥ : ℝ), w = cᵤ • u.1 + cᵥ • v.1 := by
  have h₁ : (Vec_nd.toProj u ≠ Vec_nd.toProj v) → ¬(∃ (t : ℝ), v.1 = t • u.1) := by
    intro _
    by_contra h₂
    let _ := (Vec_nd.eq_toProj_iff u v).2 h₂
    tauto
  exact linear_combination_of_not_colinear u.2 (h₁ h')
-/

end Linear_Algebra

end EuclidGeom