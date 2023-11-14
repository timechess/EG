import EuclideanGeometry.Foundation.Axiom.Triangle.Basic
import EuclideanGeometry.Foundation.Axiom.Linear.Perpendicular

noncomputable section
namespace EuclidGeom
variable {P : Type _} [EuclideanPlane P]

namespace Triangle

-- Cosine rule : for a nontrivial triangle ABC, BC^2 = AB^2 + AC^2 - 2 * AB * AC * cos ANG BAC.

theorem cosine_rule' (A B C : P) (hab : B ≠ A) (hac : C ≠ A) : 2 * (Vec.norm (⟨VEC A B, (ne_iff_vec_ne_zero A B).mp hab⟩ : Vec_nd) * Vec.norm (⟨VEC A C, (ne_iff_vec_ne_zero A C).mp hac⟩ : Vec_nd) * Real.cos (Vec_nd.angle ⟨VEC A B, (ne_iff_vec_ne_zero A B).mp hab⟩ ⟨VEC A C, (ne_iff_vec_ne_zero A C).mp hac⟩)) = Seg.length (SEG A B) ^ 2 + Seg.length (SEG A C) ^ 2 - Seg.length (SEG B C) ^ 2 := by
  rw [norm_mul_norm_mul_cos_angle_eq_inner_of_Vec_nd, length_sq_eq_inner_tovec_tovec, length_sq_eq_inner_tovec_tovec, length_sq_eq_inner_tovec_tovec, seg_tovec_eq_vec, seg_tovec_eq_vec, seg_tovec_eq_vec, ← vec_sub_vec A B C, inner_sub_sub_self, ← InnerProductSpace.Core.conj_symm (@InnerProductSpace.toCore _ _ _ _ InnerProductSpace.complexToReal) (VEC A B) (VEC A C), IsROrC.conj_to_real]
  ring

theorem cosine_rule (tr_nd : Triangle_nd P) : 2 * (tr_nd.edge₃.length * tr_nd.edge₂.length * Real.cos tr_nd.angle₁.value) = tr_nd.edge₃.length ^ 2 + tr_nd.edge₂.length ^ 2 - tr_nd.edge₁.length ^ 2 := by
  let A := tr_nd.1.point₁
  let B := tr_nd.1.point₂
  let C := tr_nd.1.point₃
  dsimp only [Seg.length]
  simp
  have h : ¬colinear A B C := (tr_nd).2
  have h0 : B ≠ A := by
    intro k
    rw [←k] at h
    exact h (triv_colinear B C)
  have h1 : C ≠ A := by
    intro k
    rw [←k] at h
    have p : ¬colinear C C B := by
     intro k
     exact h (flip_colinear_snd_trd k)
    exact p (triv_colinear C B)
  have h2 : A ≠ C := Ne.symm h1
  have h3 : 2 * (Vec.norm (⟨VEC A B,(ne_iff_vec_ne_zero A B).mp h0⟩ : Vec_nd) * Vec.norm (⟨VEC A C,(ne_iff_vec_ne_zero A C).mp h1⟩ : Vec_nd) * Real.cos (Vec_nd.angle ⟨VEC A B,(ne_iff_vec_ne_zero A B).mp h0⟩ ⟨VEC A C,(ne_iff_vec_ne_zero A C).mp h1⟩)) = Seg.length (SEG A B) ^ 2 + Seg.length (SEG A C) ^ 2 - Seg.length (SEG B C) ^ 2 := cosine_rule' A B C h0 h1
  have h4 : Vec.norm (⟨VEC A C,(ne_iff_vec_ne_zero A C).mp h1⟩ : Vec_nd) = Vec.norm (⟨VEC C A,(ne_iff_vec_ne_zero C A).mp h2⟩ : Vec_nd) := by
    unfold Vec.norm; simp; unfold Vec.mk_pt_pt
    have l0 : A -ᵥ C = -1 * (C -ᵥ A) := by
      rw [neg_one_mul]
      simp
    rw [l0,map_mul Complex.abs (-1) (C -ᵥ A)]
    have l1: Complex.abs (-1)=1 := by simp
    rw [l1,one_mul]
  have h5 : Seg.length (SEG A C)=Seg.length (SEG C A) := by
    unfold Seg.length
    simp; unfold Vec.mk_pt_pt
    have l0 : A -ᵥ C = -1 * (C -ᵥ A) := by
      rw [neg_one_mul]
      simp
    rw [l0,map_mul Complex.abs (-1) (C -ᵥ A)]
    have l1 : Complex.abs (-1) = 1 := by simp
    rw [l1,one_mul]
  rw [h4] at h3
  unfold Vec.norm at h3;
  rw [h5] at h3; unfold Seg.length at h3; simp at h3
  exact h3

theorem cosine_rule'' (tr_nd : Triangle_nd P) : tr_nd.edge₁.length = (tr_nd.edge₃.length ^ 2 + tr_nd.edge₂.length ^ 2 -  2 * (tr_nd.edge₃.length * tr_nd.edge₂.length * Real.cos tr_nd.angle₁.value)) ^ (1/2) := by sorry

-- Sine rule (but only for counterclockwise triangle here, or we need some absolute values)
-- Should we reformulate it without circle?
-- theorem side_eq_cradius_times_sine_angle (tr_nd : Triangle_nd P) (cclock : tr_nd.is_cclock) : tr_nd.1.edge₁.length = 2 * (tr_nd.toCir).radius * Real.sin (tr_nd.angle₁.value) ∧ tr_nd.1.edge₂.length = 2 * (tr_nd.toCir).radius * Real.sin (tr_nd.angle₂.value) ∧ tr_nd.1.edge₃.length = 2 * (tr_nd.toCir).radius * Real.sin (tr_nd.angle₃.value):= sorry

theorem sine_rule₁ (tr_nd : Triangle_nd P) : tr_nd.edge₂.length * Real.sin tr_nd.angle₃.value = tr_nd.edge₃.length * Real.sin tr_nd.angle₂.value := sorry

theorem sine_rule₂ (tr_nd : Triangle_nd P) : tr_nd.edge₁.length * Real.sin tr_nd.angle₃.value = tr_nd.edge₃.length * Real.sin tr_nd.angle₁.value := sorry

theorem sine_rule₃ (tr_nd : Triangle_nd P) : tr_nd.edge₂.length * Real.sin tr_nd.angle₁.value = tr_nd.edge₁.length * Real.sin tr_nd.angle₂.value := sorry
end Triangle

section Pythagoras

theorem Pythagoras_of_ne_ne_perp {A B C : P} (hab : B ≠ A) (hac : C ≠ A) (h : (Seg_nd.toProj ⟨SEG A B, hab⟩).perp = (Seg_nd.toProj ⟨SEG A C, hac⟩)) : (SEG A B).length ^ 2 + (SEG A C).length ^ 2 = (SEG B C).length ^ 2 := by

  sorry

theorem Pythagoras_of_perp_foot (A B : P) {l : Line P} (h : B LiesOn l) : (SEG A (perp_foot A l)).length ^ 2 + (SEG B (perp_foot A l)).length ^ 2 = (SEG A B).length ^ 2 := by
  sorry

--(tr_nd : Triangle_nd P) : 2 * (tr_nd.1.edge₃.length * tr_nd.1.edge₂.length * Real.cos tr_nd.angle₁.value) = tr_nd.1.edge₃.length ^ 2 + tr_nd.1.edge₂.length ^ 2 - tr_nd.1.edge₁.length ^ 2 := by
  --let A := tr_nd.1.point₁
  --let B := tr_nd.1.point₂
  --let C := tr_nd.1.point₃

/-- Given ▵ A B C with ∠ B A C = π / 2, A B ^ 2 + A C ^ 2 = B C ^ 2, namely (SEG A B).length ^ 2 + (SEG A C).length ^ 2 = (SEG B C).length ^ 2. -/
theorem Pythagoras_of_right_triangle_non_trivial (A B C : P) {hnd : ¬ colinear A B C} (right_triangle: ∠ B A C (ne_of_not_colinear hnd).2.2 (ne_of_not_colinear hnd).2.1.symm = π / 2 ) : (SEG A B).length ^ 2 + (SEG A C).length ^ 2 = (SEG B C).length ^ 2 := by
  have h : Real.cos (∠ B A C (ne_of_not_colinear hnd).2.2 (ne_of_not_colinear hnd).2.1.symm) = 0 := by
    rw [right_triangle]
    simp only [Real.cos_pi_div_two]
  have eq : 2 * ((SEG A B).length * (SEG A C).length * Real.cos (∠ B A C (ne_of_not_colinear hnd).2.2 (ne_of_not_colinear hnd).2.1.symm)) = (SEG A B).length ^ 2 + (SEG A C).length ^ 2 - (SEG B C).length ^ 2 := by
    --cos rule
    sorry
  rw [h] at eq
  linarith

end Pythagoras

end EuclidGeom
