import EuclideanGeometry.Foundation.Axiom.Triangle.Basic
import EuclideanGeometry.Foundation.Axiom.Triangle.Basic_ex
import EuclideanGeometry.Foundation.Axiom.Position.Angle_ex2
import EuclideanGeometry.Foundation.Axiom.Triangle.Trigonometric
import EuclideanGeometry.Foundation.Tactic.Congruence.Attr
import EuclideanGeometry.Foundation.Axiom.Triangle.Basic_trash

namespace EuclidGeom

/- definition of congruence of triangles-/

/- congruences of triangles, separate definitions for reversing orientation or not, (requiring all sides and angles being the same)-/

variable {P : Type _} [EuclideanPlane P] {tr tr₁ tr₂ tr₃ : Triangle P} {tr_nd tr_nd₁ tr_nd₂ : Triangle_nd P}

open Classical

-- Do not change `IsCongr, IsACongr` notation into `≅, ≅ₐ` in any theorem with name  `IsCongr.some_theorem, IsACongr.some_theorem`, to use `h.some_theorem` when h is of shape `tr₁ ≅ tr₂`.
namespace Triangle

structure IsCongr (tr₁ tr₂ : Triangle P) : Prop where intro ::
  edge₁ : tr₁.edge₁.length = tr₂.edge₁.length
  edge₂ : tr₁.edge₂.length = tr₂.edge₂.length
  edge₃ : tr₁.edge₃.length = tr₂.edge₃.length
  angle₁ : if h : tr₁.is_nd ∧ tr₂.is_nd then
    (Triangle_nd.angle₁ ⟨tr₁, h.1⟩).value = (Triangle_nd.angle₁ ⟨tr₂, h.2⟩).value
    else True
  angle₂ : if h : tr₁.is_nd ∧ tr₂.is_nd then
    (Triangle_nd.angle₂ ⟨tr₁, h.1⟩).value = (Triangle_nd.angle₂ ⟨tr₂, h.2⟩).value
    else True
  angle₃ : if h : tr₁.is_nd ∧ tr₂.is_nd then
    (Triangle_nd.angle₃ ⟨tr₁, h.1⟩).value = (Triangle_nd.angle₃ ⟨tr₂, h.2⟩).value
    else True

namespace IsCongr

theorem nd_of_nd (h : tr₁.IsCongr tr₂) (nd : tr₁.is_nd) : tr₂.is_nd := by
  by_contra col
  unfold is_nd at col
  push_neg at col
  rw [Triangle.edge_sum_eq_edge_iff_colinear] at col
  rcases col with l₁ | l₂ | l₃
  . simp only [<-h.1, <-h.2, <-h.3] at l₁
    have col' : colinear tr₁.point₁ tr₁.point₂ tr₁.point₃ := by
      rw [Triangle.edge_sum_eq_edge_iff_colinear]
      exact .inl l₁
    exact nd col'
  . simp only [<-h.1, <-h.2, <-h.3] at l₂
    have col' : colinear tr₁.point₁ tr₁.point₂ tr₁.point₃ := by
      rw [Triangle.edge_sum_eq_edge_iff_colinear]
      exact .inr (.inl l₂)
    exact nd col'
  . simp only [<-h.1, <-h.2, <-h.3] at l₃
    have col' : colinear tr₁.point₁ tr₁.point₂ tr₁.point₃ := by
      rw [Triangle.edge_sum_eq_edge_iff_colinear]
      exact .inr (.inr l₃)
    exact nd col'

protected theorem refl (tr : Triangle P) : tr.IsCongr tr where
  edge₁ := rfl
  edge₂ := rfl
  edge₃ := rfl
  angle₁ := (dite_prop_iff_and _).mpr ⟨fun _ ↦ rfl, fun _ ↦ trivial⟩
  angle₂ := (dite_prop_iff_and _).mpr ⟨fun _ ↦ rfl, fun _ ↦ trivial⟩
  angle₃ := (dite_prop_iff_and _).mpr ⟨fun _ ↦ rfl, fun _ ↦ trivial⟩

protected theorem symm (h : tr₁.IsCongr tr₂) : tr₂.IsCongr tr₁ where
  edge₁ := h.1.symm
  edge₂ := h.2.symm
  edge₃ := h.3.symm
  angle₁ := (dite_prop_iff_and _).mpr ⟨fun c ↦ (((dite_prop_iff_and _).mp h.4).1 c.symm).symm, fun _ ↦ trivial⟩
  angle₂ := (dite_prop_iff_and _).mpr ⟨fun c ↦ (((dite_prop_iff_and _).mp h.5).1 c.symm).symm, fun _ ↦ trivial⟩
  angle₃ := (dite_prop_iff_and _).mpr ⟨fun c ↦ (((dite_prop_iff_and _).mp h.6).1 c.symm).symm, fun _ ↦ trivial⟩

protected theorem trans (h₁ : tr₁.IsCongr tr₂) (h₂ : tr₂.IsCongr tr₃) : tr₁.IsCongr tr₃ := by
  constructor
  simp only [h₁.1,h₂.1]
  simp only [h₁.2,h₂.2]
  simp only [h₁.3,h₂.3]
  apply (dite_prop_iff_and _).mpr
  constructor
  rintro ⟨nd₁,nd₃⟩
  have nd₂ := IsCongr.nd_of_nd h₁ nd₁
  rw [((dite_prop_iff_and _).mp h₁.4).1 ⟨nd₁,nd₂⟩]
  rw [((dite_prop_iff_and _).mp h₂.4).1 ⟨nd₂,nd₃⟩]
  simp only [not_and, implies_true]
  apply (dite_prop_iff_and _).mpr
  constructor
  rintro ⟨nd₁,nd₃⟩
  have nd₂ := nd_of_nd h₁ nd₁
  rw [((dite_prop_iff_and _).mp h₁.5).1 ⟨nd₁,nd₂⟩]
  rw [((dite_prop_iff_and _).mp h₂.5).1 ⟨nd₂,nd₃⟩]
  simp only [not_and, implies_true]
  apply (dite_prop_iff_and _).mpr
  constructor
  rintro ⟨nd₁,nd₃⟩
  have nd₂ := nd_of_nd h₁ nd₁
  rw [((dite_prop_iff_and _).mp h₁.6).1 ⟨nd₁,nd₂⟩]
  rw [((dite_prop_iff_and _).mp h₂.6).1 ⟨nd₂,nd₃⟩]
  simp only [not_and, implies_true]

instance instHasCongr : HasCongr (Triangle P) where
  congr := IsCongr
  refl := IsCongr.refl
  symm := IsCongr.symm
  trans := IsCongr.trans

theorem congr_iff_perm_congr (tr₁ tr₂ : Triangle P) : tr₁.IsCongr tr₂ ↔ (perm_vertices tr₁).IsCongr (perm_vertices tr₂) := by sorry

-- The proof of this theorem will need to wait until the definition of area is completed.
theorem area (h : tr₁.IsCongr tr₂) : tr₁.area = tr₂.area := sorry

end IsCongr

structure IsACongr (tr₁ tr₂ : Triangle P) : Prop where intro ::
  edge₁ : tr₁.edge₁.length = tr₂.edge₁.length
  edge₂ : tr₁.edge₂.length = tr₂.edge₂.length
  edge₃ : tr₁.edge₃.length = tr₂.edge₃.length
  angle₁ : if h : tr₁.is_nd ∧ tr₂.is_nd then
    (Triangle_nd.angle₁ ⟨tr₁, h.1⟩).value = - (Triangle_nd.angle₁ ⟨tr₂, h.2⟩).value
    else True
  angle₂ : if h : tr₁.is_nd ∧ tr₂.is_nd then
    (Triangle_nd.angle₂ ⟨tr₁, h.1⟩).value = - (Triangle_nd.angle₂ ⟨tr₂, h.2⟩).value
    else True
  angle₃ : if h : tr₁.is_nd ∧ tr₂.is_nd then
    (Triangle_nd.angle₃ ⟨tr₁, h.1⟩).value = - (Triangle_nd.angle₃ ⟨tr₂, h.2⟩).value
    else True

namespace IsACongr


theorem nd_of_nd (h : tr₁.IsACongr tr₂) (nd : tr₁.is_nd) : tr₂.is_nd := by
  by_contra col
  unfold is_nd at col
  push_neg at col
  rw [Triangle.edge_sum_eq_edge_iff_colinear] at col
  rcases col with l₁ | l₂ | l₃
  . simp only [<-h.1, <-h.2, <-h.3] at l₁
    have col' : colinear tr₁.point₁ tr₁.point₂ tr₁.point₃ := by
      rw [Triangle.edge_sum_eq_edge_iff_colinear]
      exact .inl l₁
    exact nd col'
  . simp only [<-h.1, <-h.2, <-h.3] at l₂
    have col' : colinear tr₁.point₁ tr₁.point₂ tr₁.point₃ := by
      rw [Triangle.edge_sum_eq_edge_iff_colinear]
      exact .inr (.inl l₂)
    exact nd col'
  . simp only [<-h.1, <-h.2, <-h.3] at l₃
    have col' : colinear tr₁.point₁ tr₁.point₂ tr₁.point₃ := by
      rw [Triangle.edge_sum_eq_edge_iff_colinear]
      exact .inr (.inr l₃)
    exact nd col'

protected theorem symm (h : tr₁.IsACongr tr₂) : tr₂.IsACongr tr₁ := by
  constructor
  exact h.1.symm
  exact h.2.symm
  exact h.3.symm
  apply (dite_prop_iff_and _).mpr
  constructor
  intro nd
  simp only [((dite_prop_iff_and _).mp h.4).1 nd.symm, neg_neg]
  simp only [not_and, implies_true]
  apply (dite_prop_iff_and _).mpr
  constructor
  intro nd
  simp only [((dite_prop_iff_and _).mp h.5).1 nd.symm, neg_neg]
  simp only [not_and, implies_true]
  apply (dite_prop_iff_and _).mpr
  constructor
  intro nd
  simp only [((dite_prop_iff_and _).mp h.6).1 nd.symm, neg_neg]
  simp only [not_and, implies_true]

theorem congr_of_trans_acongr (h₁ : tr₁.IsACongr tr₂) (h₂ : tr₂.IsACongr tr₃) : tr₁.IsCongr tr₃ := by
  constructor
  simp only [h₁.1,h₂.1]
  simp only [h₁.2,h₂.2]
  simp only [h₁.3,h₂.3]
  apply (dite_prop_iff_and _).mpr
  constructor
  rintro ⟨nd₁,nd₃⟩
  have nd₂ := nd_of_nd h₁ nd₁
  simp only [((dite_prop_iff_and _).mp h₁.4).1 ⟨nd₁,nd₂⟩, ((dite_prop_iff_and _).mp h₂.4).1 ⟨nd₂,nd₃⟩, neg_neg]
  simp only [not_and, implies_true]
  apply (dite_prop_iff_and _).mpr
  constructor
  rintro ⟨nd₁,nd₃⟩
  have nd₂ := nd_of_nd h₁ nd₁
  simp only [((dite_prop_iff_and _).mp h₁.5).1 ⟨nd₁,nd₂⟩, ((dite_prop_iff_and _).mp h₂.5).1 ⟨nd₂,nd₃⟩, neg_neg]
  simp only [not_and, implies_true]
  apply (dite_prop_iff_and _).mpr
  constructor
  rintro ⟨nd₁,nd₃⟩
  have nd₂ := nd_of_nd h₁ nd₁
  simp only [((dite_prop_iff_and _).mp h₁.6).1 ⟨nd₁,nd₂⟩, ((dite_prop_iff_and _).mp h₂.6).1 ⟨nd₂,nd₃⟩, neg_neg]
  simp only [not_and, implies_true]

instance instHasACongr : HasACongr (Triangle P) where
  acongr := IsACongr
  symm := IsACongr.symm

theorem acongr_iff_perm_acongr (tr₁ tr₂ : Triangle P) : tr₁ ≅ₐ tr₂ ↔ perm_vertices tr₁ ≅ₐ perm_vertices tr₂ := by sorry

end IsACongr

end Triangle

namespace Triangle_nd

structure IsCongr (tr_nd₁ tr_nd₂ : Triangle_nd P) : Prop where intro ::
  edge₁ : tr_nd₁.edge₁.length = tr_nd₂.edge₁.length
  edge₂ : tr_nd₁.edge₂.length = tr_nd₂.edge₂.length
  edge₃ : tr_nd₁.edge₃.length = tr_nd₂.edge₃.length
  angle₁ : tr_nd₁.angle₁.value = tr_nd₂.angle₁.value
  angle₂ : tr_nd₁.angle₂.value = tr_nd₂.angle₂.value
  angle₃ : tr_nd₁.angle₃.value = tr_nd₂.angle₃.value

namespace IsCongr

protected theorem refl (tr_nd : Triangle_nd P) : tr_nd.IsCongr tr_nd where
  edge₁ := rfl
  edge₂ := rfl
  edge₃ := rfl
  angle₁ := rfl
  angle₂ := rfl
  angle₃ := rfl

protected theorem symm (h : tr_nd₁.IsCongr tr_nd₂) : tr_nd₂.IsCongr tr_nd₁ where
  edge₁ := h.1.symm
  edge₂ := h.2.symm
  edge₃ := h.3.symm
  angle₁ := h.4.symm
  angle₂ := h.5.symm
  angle₃ := h.6.symm

protected theorem trans (h₁ : tr_nd₁.IsCongr tr_nd₂) (h₂ : tr_nd₂.IsCongr tr_nd₃) : tr_nd₁.IsCongr tr_nd₃ := by
  constructor
  simp only [h₁.1,h₂.1]
  simp only [h₁.2,h₂.2]
  simp only [h₁.3,h₂.3]
  simp only [h₁.4,h₂.4]
  simp only [h₁.5,h₂.5]
  simp only [h₁.6,h₂.6]

instance instHasCongr : HasCongr (Triangle_nd P) where
  congr := IsCongr
  refl := IsCongr.refl
  symm := IsCongr.symm
  trans := IsCongr.trans

theorem is_cclock_of_cclock (h : tr_nd₁.IsCongr tr_nd₂) (cc : tr_nd₁.is_cclock) : tr_nd₂.is_cclock := by
  apply Triangle_nd.cclock_of_pos_angle
  left
  rw [<-h.4]
  exact (Triangle_nd.angle_pos_of_cclock tr_nd₁ cc).1

theorem area (h : tr_nd₁.IsCongr tr_nd₂) : tr_nd₁.area = tr_nd₂.area := sorry

theorem congr_iff_perm_congr (tr_nd₁ tr_nd₂ : Triangle_nd P) : tr_nd₁ ≅ tr_nd₂ ↔ perm_vertices tr_nd₁ ≅ perm_vertices tr_nd₂ := by sorry

end IsCongr

structure IsACongr (tr_nd₁ tr_nd₂: Triangle_nd P) : Prop where intro ::
  edge₁ : tr_nd₁.edge₁.length = tr_nd₂.edge₁.length
  edge₂ : tr_nd₁.edge₂.length = tr_nd₂.edge₂.length
  edge₃ : tr_nd₁.edge₃.length = tr_nd₂.edge₃.length
  angle₁ : tr_nd₁.angle₁.value = - tr_nd₂.angle₁.value
  angle₂ : tr_nd₁.angle₂.value = - tr_nd₂.angle₂.value
  angle₃ : tr_nd₁.angle₃.value = - tr_nd₂.angle₃.value

namespace IsACongr

theorem not_cclock_of_cclock (h : tr_nd₁.IsACongr tr_nd₂) (cc : tr_nd₁.is_cclock) : ¬ tr_nd₂.is_cclock := by
  apply Triangle_nd.clock_of_neg_angle
  left
  have : - tr_nd₁.angle₁.value = tr_nd₂.angle₁.value := by simp only [h.4, neg_neg]
  simp only [<-this,Left.neg_neg_iff, (tr_nd₁.angle_pos_of_cclock cc).1]

protected theorem symm (h : tr_nd₁.IsACongr tr_nd₂) : tr_nd₂.IsACongr tr_nd₁ where
  edge₁ := h.1.symm
  edge₂ := h.2.symm
  edge₃ := h.3.symm
  angle₁ := (neg_eq_iff_eq_neg.mpr h.4).symm
  angle₂ := (neg_eq_iff_eq_neg.mpr h.5).symm
  angle₃ := (neg_eq_iff_eq_neg.mpr h.6).symm

theorem congr_of_trans_acongr (h₁ : tr_nd₁.IsACongr tr_nd₂) (h₂ : tr_nd₂.IsACongr tr_nd₃) : tr_nd₁.IsCongr tr_nd₃ := by
  constructor
  simp only [h₁.1, h₂.1]
  simp only [h₁.2, h₂.2]
  simp only [h₁.3, h₂.3]
  simp only [h₁.4, h₂.4, neg_neg]
  simp only [h₁.5, h₂.5, neg_neg]
  simp only [h₁.6, h₂.6, neg_neg]

instance instHasACongr : HasACongr (Triangle_nd P) where
  acongr := IsACongr
  symm := IsACongr.symm

end IsACongr

theorem congr_of_acongr_acongr (h₁ : tr_nd₁.IsACongr tr_nd₂) (h₂ : tr_nd₂.IsACongr tr_nd₃) : tr_nd₁ ≅ tr_nd₃ := by
  exact IsACongr.congr_of_trans_acongr h₁ h₂

theorem acongr_of_congr_acongr (h₁ : tr_nd₁.IsCongr tr_nd₂) (h₂ : tr_nd₂.IsACongr tr_nd₃) : tr_nd₁ ≅ₐ tr_nd₃ := by
  constructor
  simp only [h₁.1, h₂.1]
  simp only [h₁.2, h₂.2]
  simp only [h₁.3, h₂.3]
  simp only [h₁.4, h₂.4, neg_neg]
  simp only [h₁.5, h₂.5, neg_neg]
  simp only [h₁.6, h₂.6, neg_neg]

theorem acongr_of_acongr_congr (h₁ : tr_nd₁.IsACongr tr_nd₂) (h₂ : tr_nd₂.IsCongr tr_nd₃) : tr_nd₁ ≅ₐ tr_nd₃ := by
  constructor
  simp only [h₁.1, h₂.1]
  simp only [h₁.2, h₂.2]
  simp only [h₁.3, h₂.3]
  simp only [h₁.4, h₂.4, neg_neg]
  simp only [h₁.5, h₂.5, neg_neg]
  simp only [h₁.6, h₂.6, neg_neg]

theorem acongr_iff_perm_acongr (tr_nd₁ tr_nd₂ : Triangle_nd P) : tr_nd₁ ≅ₐ tr_nd₂ ↔ perm_vertices tr_nd₁ ≅ₐ perm_vertices tr_nd₂ := by sorry
end Triangle_nd

section compatibility

theorem Triangle.congr_of_congr (h : tr_nd₁ ≅ tr_nd₂) : tr_nd₁.1 ≅ tr_nd₂.1 where
  edge₁ := h.1
  edge₂ := h.2
  edge₃ := h.3
  angle₁ := (dite_prop_iff_and _).mpr ⟨fun _ ↦ h.4 , fun _ ↦ trivial⟩
  angle₂ := (dite_prop_iff_and _).mpr ⟨fun _ ↦ h.5 , fun _ ↦ trivial⟩
  angle₃ := (dite_prop_iff_and _).mpr ⟨fun _ ↦ h.6 , fun _ ↦ trivial⟩

theorem Triangle.acongr_of_acongr (h : tr_nd₁ ≅ₐ tr_nd₂) : tr_nd₁.1 ≅ₐ tr_nd₂.1 where
  edge₁ := h.1
  edge₂ := h.2
  edge₃ := h.3
  angle₁ := (dite_prop_iff_and _).mpr ⟨fun _ ↦ h.4 , fun _ ↦ trivial⟩
  angle₂ := (dite_prop_iff_and _).mpr ⟨fun _ ↦ h.5 , fun _ ↦ trivial⟩
  angle₃ := (dite_prop_iff_and _).mpr ⟨fun _ ↦ h.6 , fun _ ↦ trivial⟩

theorem Triangle.nd_of_congr (h : tr_nd.1 ≅ tr) : tr.is_nd := by
  exact IsCongr.nd_of_nd h tr_nd.2

theorem Triangle_nd.congr_of_congr (h : tr_nd.1 ≅ tr) : tr_nd ≅ ⟨tr, tr.nd_of_congr h⟩ where
  edge₁ := h.1
  edge₂ := h.2
  edge₃ := h.3
  angle₁ := ((dite_prop_iff_and _).mp h.4).1 ⟨tr_nd.2,Triangle.nd_of_congr h⟩
  angle₂ := ((dite_prop_iff_and _).mp h.5).1 ⟨tr_nd.2,Triangle.nd_of_congr h⟩
  angle₃ := ((dite_prop_iff_and _).mp h.6).1 ⟨tr_nd.2,Triangle.nd_of_congr h⟩

end compatibility

namespace Triangle

section degenerate

theorem IsCongr.not_nd_of_not_nd (h : tr₁ ≅ tr₂) (nnd : ¬ tr₁.is_nd) : ¬ tr₂.is_nd :=
  fun nd ↦ nnd (h.symm.nd_of_nd nd)

theorem IsACongr.not_nd_of_not_nd (h : tr₁.IsACongr tr₂) (nnd : ¬ tr₁.is_nd) : ¬ tr₂.is_nd :=
  fun nd ↦ nnd (h.symm.nd_of_nd nd)

theorem triv_of_acongr_self (h : tr.IsACongr tr) : ¬ tr.is_nd := by
  by_contra nd
  let tr_nd : Triangle_nd P := ⟨tr, nd⟩
  have temp := ((dite_prop_iff_and _).mp h.4).1 ⟨nd,nd⟩
  have eq_zero : Angle.value tr_nd.angle₁ = 0 := by linarith
  exact nd (colinear_of_zero_angle eq_zero)

theorem acongr_self_of_triv (nnd : ¬ tr.is_nd) : tr.IsACongr tr where
  edge₁ := rfl
  edge₂ := rfl
  edge₃ := rfl
  angle₁ := (dite_prop_iff_and _).mpr ⟨fun nd ↦ (nnd nd.1).elim, fun _ ↦ trivial⟩
  angle₂ := (dite_prop_iff_and _).mpr ⟨fun nd ↦ (nnd nd.1).elim, fun _ ↦ trivial⟩
  angle₃ := (dite_prop_iff_and _).mpr ⟨fun nd ↦ (nnd nd.1).elim, fun _ ↦ trivial⟩

theorem IsCongr.acongr_of_left_triv (h : tr₁.IsCongr tr₂) (nnd : ¬ tr₁.is_nd) : tr₁.IsACongr tr₂ where
  edge₁ := h.1
  edge₂ := h.2
  edge₃ := h.3
  angle₁ := (dite_prop_iff_and _).mpr ⟨fun nd ↦ (nnd nd.1).elim,fun _ ↦ trivial⟩
  angle₂ := (dite_prop_iff_and _).mpr ⟨fun nd ↦ (nnd nd.1).elim,fun _ ↦ trivial⟩
  angle₃ := (dite_prop_iff_and _).mpr ⟨fun nd ↦ (nnd nd.1).elim,fun _ ↦ trivial⟩

theorem IsCongr.acongr_of_right_triv (h : tr₁.IsCongr tr₂) (nnd : ¬ tr₂.is_nd) : tr₁.IsACongr tr₂ where
  edge₁ := h.1
  edge₂ := h.2
  edge₃ := h.3
  angle₁ := (dite_prop_iff_and _).mpr ⟨fun nd ↦ (nnd nd.2).elim,fun _ ↦ trivial⟩
  angle₂ := (dite_prop_iff_and _).mpr ⟨fun nd ↦ (nnd nd.2).elim,fun _ ↦ trivial⟩
  angle₃ := (dite_prop_iff_and _).mpr ⟨fun nd ↦ (nnd nd.2).elim,fun _ ↦ trivial⟩

theorem IsACongr.congr_of_left_triv (h : tr₁.IsACongr tr₂) (nnd : ¬ tr₁.is_nd) : tr₁.IsCongr tr₂ where
  edge₁ := h.1
  edge₂ := h.2
  edge₃ := h.3
  angle₁ := (dite_prop_iff_and _).mpr ⟨fun nd ↦ (nnd nd.1).elim,fun _ ↦ trivial⟩
  angle₂ := (dite_prop_iff_and _).mpr ⟨fun nd ↦ (nnd nd.1).elim,fun _ ↦ trivial⟩
  angle₃ := (dite_prop_iff_and _).mpr ⟨fun nd ↦ (nnd nd.1).elim,fun _ ↦ trivial⟩

theorem IsACongr.congr_of_right_triv (h : tr₁.IsACongr tr₂) (nnd : ¬ tr₂.is_nd) : tr₁.IsCongr tr₂ where
  edge₁ := h.1
  edge₂ := h.2
  edge₃ := h.3
  angle₁ := (dite_prop_iff_and _).mpr ⟨fun nd ↦ (nnd nd.2).elim,fun _ ↦ trivial⟩
  angle₂ := (dite_prop_iff_and _).mpr ⟨fun nd ↦ (nnd nd.2).elim,fun _ ↦ trivial⟩
  angle₃ := (dite_prop_iff_and _).mpr ⟨fun nd ↦ (nnd nd.2).elim,fun _ ↦ trivial⟩

end degenerate

end Triangle

section criteria
/- criteria of congruence of triangles. each SAS ASA AAS SSS involves congr and anti congr. SSS is special.
Need a tactic `Congrence` to consider filp and permutation. -/

namespace Triangle_nd
/- SSS -/
/- cannot decide orientation -/
theorem cosine_eq_of_SSS (e₁ : tr_nd₁.1.edge₁.length = tr_nd₂.1.edge₁.length) (e₂ : tr_nd₁.1.edge₂.length = tr_nd₂.1.edge₂.length) (e₃ : tr_nd₁.1.edge₃.length = tr_nd₂.1.edge₃.length) : Real.cos tr_nd₁.angle₁.value = Real.cos tr_nd₂.angle₁.value:= by
  have cos₁ : 2 * (tr_nd₁.1.edge₃.length * tr_nd₁.1.edge₂.length * Real.cos tr_nd₁.angle₁.value) = tr_nd₁.1.edge₃.length ^ 2 + tr_nd₁.1.edge₂.length ^ 2 - tr_nd₁.1.edge₁.length^2 := Triangle.cosine_rule tr_nd₁
  have cos₂ : 2 * (tr_nd₂.1.edge₃.length * tr_nd₂.1.edge₂.length * Real.cos tr_nd₂.angle₁.value) = tr_nd₂.1.edge₃.length ^ 2 + tr_nd₂.1.edge₂.length ^ 2 - tr_nd₂.1.edge₁.length^2 := Triangle.cosine_rule tr_nd₂
  rw [e₁,e₂,e₃,←cos₂] at cos₁
  field_simp at cos₁
  have u₁ : 0 < tr_nd₂.1.edge₃.length := by
    exact length_pos_iff_nd.mpr tr_nd₂.edge_nd₃.2
  have u₂ : 0 < tr_nd₂.1.edge₂.length := by
    exact length_pos_iff_nd.mpr tr_nd₂.edge_nd₂.2
  have h0 : (tr_nd₂.1.edge₃.length * tr_nd₂.1.edge₂.length) > 0 := by
    field_simp [u₁,u₂]
  rcases cos₁ with x | y
  ·apply x
  ·have h1 : ¬((tr_nd₂.1.edge₃.length * tr_nd₂.1.edge₂.length)) = 0 := ne_of_gt h0
   absurd h1 y
   exact False.elim (h1 y)

theorem congr_of_SSS_of_eq_orientation (e₁ : tr_nd₁.edge₁.length = tr_nd₂.edge₁.length) (e₂ : tr_nd₁.edge₂.length = tr_nd₂.edge₂.length) (e₃ : tr_nd₁.edge₃.length = tr_nd₂.edge₃.length) (c : tr_nd₁.is_cclock ↔  tr_nd₂.is_cclock) : tr_nd₁ ≅ tr_nd₂ := by
  have a₁ : tr_nd₁.angle₁.value = tr_nd₂.angle₁.value := by
    exact angle_eq_of_cosine_eq_of_cclock c (cosine_eq_of_SSS e₁ e₂ e₃)
  have a₂ : tr_nd₁.angle₂.value = tr_nd₂.angle₂.value := by
    let pptr_nd₁ := tr_nd₁.perm_vertices.perm_vertices
    let pptr_nd₂ := tr_nd₂.perm_vertices.perm_vertices
    have ppe₁ : pptr_nd₁.1.edge₁.length = pptr_nd₂.1.edge₁.length := by
      rw [←(Triangle_nd.edge_eq_edge_of_perm_vertices_two_times tr_nd₁).2.1,←(Triangle_nd.edge_eq_edge_of_perm_vertices_two_times tr_nd₂).2.1]
      exact e₂
    have ppe₂ : pptr_nd₁.1.edge₂.length = pptr_nd₂.1.edge₂.length := by
      rw [←(Triangle_nd.edge_eq_edge_of_perm_vertices_two_times tr_nd₁).2.2,←(Triangle_nd.edge_eq_edge_of_perm_vertices_two_times tr_nd₂).2.2]
      exact e₃
    have ppe₃ : pptr_nd₁.1.edge₃.length = pptr_nd₂.1.edge₃.length := by
      rw [←(Triangle_nd.edge_eq_edge_of_perm_vertices_two_times tr_nd₁).1,←(Triangle_nd.edge_eq_edge_of_perm_vertices_two_times tr_nd₂).1]
      exact e₁
    have ppc : pptr_nd₁.is_cclock ↔ pptr_nd₂.is_cclock := by
      rw [←same_orient_of_perm_vertices,←same_orient_of_perm_vertices,←same_orient_of_perm_vertices,←same_orient_of_perm_vertices]
      exact c
    have ppa₁ : pptr_nd₁.angle₁.value = pptr_nd₂.angle₁.value := by
      exact angle_eq_of_cosine_eq_of_cclock ppc (cosine_eq_of_SSS ppe₁ ppe₂ ppe₃)
    rw [←(Triangle_nd.angle_eq_angle_of_perm_vertices_two_times tr_nd₁).2.1,←(Triangle_nd.angle_eq_angle_of_perm_vertices_two_times tr_nd₂).2.1] at ppa₁
    exact ppa₁
  have a₃ : tr_nd₁.angle₃.value = tr_nd₂.angle₃.value := by
    let ptr_nd₁ := tr_nd₁.perm_vertices
    let ptr_nd₂ := tr_nd₂.perm_vertices
    have pe₁ : ptr_nd₁.edge₁.length = ptr_nd₂.edge₁.length := by
      rw [←(Triangle_nd.edge_eq_edge_of_perm_vertices tr_nd₁).2.2,←(Triangle_nd.edge_eq_edge_of_perm_vertices tr_nd₂).2.2]
      exact e₃
    have pe₂ : ptr_nd₁.edge₂.length = ptr_nd₂.edge₂.length := by
      rw [←(Triangle_nd.edge_eq_edge_of_perm_vertices tr_nd₁).1,←(Triangle_nd.edge_eq_edge_of_perm_vertices tr_nd₂).1]
      exact e₁
    have pe₃ : ptr_nd₁.edge₃.length = ptr_nd₂.edge₃.length := by
      rw [←(Triangle_nd.edge_eq_edge_of_perm_vertices tr_nd₁).2.1,←(Triangle_nd.edge_eq_edge_of_perm_vertices tr_nd₂).2.1]
      exact e₂
    have pc : ptr_nd₁.is_cclock ↔ ptr_nd₂.is_cclock := by
      rw [←same_orient_of_perm_vertices,←same_orient_of_perm_vertices]
      exact c
    have pa₁ : ptr_nd₁.angle₁.value = ptr_nd₂.angle₁.value := by
      exact angle_eq_of_cosine_eq_of_cclock pc (cosine_eq_of_SSS pe₁ pe₂ pe₃)
    rw [←(Triangle_nd.angle_eq_angle_of_perm_vertices tr_nd₁).2.2,←(Triangle_nd.angle_eq_angle_of_perm_vertices tr_nd₂).2.2] at pa₁
    exact pa₁
  exact ⟨e₁, e₂, e₃, a₁, a₂, a₃⟩

theorem acongr_of_SSS_of_ne_orientation (e₁ : tr_nd₁.edge₁.length = tr_nd₂.edge₁.length) (e₂ : tr_nd₁.edge₂.length = tr_nd₂.edge₂.length) (e₃ : tr_nd₁.edge₃.length = tr_nd₂.edge₃.length) (c : tr_nd₁.is_cclock = ¬ tr_nd₂.is_cclock) : tr_nd₁ ≅ₐ tr_nd₂ := by
  simp only [eq_iff_iff] at c
  have a₁ : tr_nd₁.angle₁.value = - tr_nd₂.angle₁.value := by
    exact angle_eq_neg_of_cosine_eq_of_clock c (cosine_eq_of_SSS e₁ e₂ e₃)
  have a₂ : tr_nd₁.angle₂.value = - tr_nd₂.angle₂.value := by
    let pptr_nd₁ := tr_nd₁.perm_vertices.perm_vertices
    let pptr_nd₂ := tr_nd₂.perm_vertices.perm_vertices
    have ppe₁ : pptr_nd₁.1.edge₁.length = pptr_nd₂.1.edge₁.length := by
      simp
      rw [←(Triangle_nd.edge_eq_edge_of_perm_vertices_two_times tr_nd₁).2.1,←(Triangle_nd.edge_eq_edge_of_perm_vertices_two_times tr_nd₂).2.1]
      exact e₂
    have ppe₂ : pptr_nd₁.1.edge₂.length = pptr_nd₂.1.edge₂.length := by
      simp
      rw [←(Triangle_nd.edge_eq_edge_of_perm_vertices_two_times tr_nd₁).2.2,←(Triangle_nd.edge_eq_edge_of_perm_vertices_two_times tr_nd₂).2.2]
      exact e₃
    have ppe₃ : pptr_nd₁.1.edge₃.length = pptr_nd₂.1.edge₃.length := by
      simp
      rw [←(Triangle_nd.edge_eq_edge_of_perm_vertices_two_times tr_nd₁).1,←(Triangle_nd.edge_eq_edge_of_perm_vertices_two_times tr_nd₂).1]
      exact e₁
    have ppc : pptr_nd₁.is_cclock ↔ ¬ pptr_nd₂.is_cclock := by
      rw [←same_orient_of_perm_vertices,←same_orient_of_perm_vertices,←same_orient_of_perm_vertices,←same_orient_of_perm_vertices]
      exact c
    have ppa₁ : pptr_nd₁.angle₁.value = - pptr_nd₂.angle₁.value := by
      exact angle_eq_neg_of_cosine_eq_of_clock ppc (cosine_eq_of_SSS ppe₁ ppe₂ ppe₃)
    rw [←(Triangle_nd.angle_eq_angle_of_perm_vertices_two_times tr_nd₁).2.1,←(Triangle_nd.angle_eq_angle_of_perm_vertices_two_times tr_nd₂).2.1] at ppa₁
    exact ppa₁
  have a₃ : tr_nd₁.angle₃.value = - tr_nd₂.angle₃.value := by
    let ptr_nd₁ := tr_nd₁.perm_vertices
    let ptr_nd₂ := tr_nd₂.perm_vertices
    have pe₁ : ptr_nd₁.edge₁.length = ptr_nd₂.edge₁.length := by
      simp
      rw [←(Triangle_nd.edge_eq_edge_of_perm_vertices tr_nd₁).2.2,←(Triangle_nd.edge_eq_edge_of_perm_vertices tr_nd₂).2.2]
      exact e₃
    have pe₂ : ptr_nd₁.edge₂.length = ptr_nd₂.edge₂.length := by
      simp
      rw [←(Triangle_nd.edge_eq_edge_of_perm_vertices tr_nd₁).1,←(Triangle_nd.edge_eq_edge_of_perm_vertices tr_nd₂).1]
      exact e₁
    have pe₃ : ptr_nd₁.edge₃.length = ptr_nd₂.edge₃.length := by
      simp
      rw [←(Triangle_nd.edge_eq_edge_of_perm_vertices tr_nd₁).2.1,←(Triangle_nd.edge_eq_edge_of_perm_vertices tr_nd₂).2.1]
      exact e₂
    have pc : ptr_nd₁.is_cclock ↔ ¬ ptr_nd₂.is_cclock := by
      rw [←same_orient_of_perm_vertices,←same_orient_of_perm_vertices]
      exact c
    have pa₁ : ptr_nd₁.angle₁.value = - ptr_nd₂.angle₁.value := by
      exact angle_eq_neg_of_cosine_eq_of_clock pc (cosine_eq_of_SSS pe₁ pe₂ pe₃)
    rw [←(Triangle_nd.angle_eq_angle_of_perm_vertices tr_nd₁).2.2,←(Triangle_nd.angle_eq_angle_of_perm_vertices tr_nd₂).2.2] at pa₁
    exact pa₁
  exact ⟨e₁, e₂, e₃, a₁, a₂, a₃⟩

theorem congr_or_acongr_of_SSS (e₁ : tr_nd₁.edge₁.length = tr_nd₂.edge₁.length) (e₂ : tr_nd₁.edge₂.length = tr_nd₂.edge₂.length) (e₃ : tr_nd₁.edge₃.length = tr_nd₂.edge₃.length) : tr_nd₁ ≅ tr_nd₂ ∨ tr_nd₁ ≅ₐ tr_nd₂ := by
  by_cases c : tr_nd₁.is_cclock ↔  tr_nd₂.is_cclock
  .left
   exact congr_of_SSS_of_eq_orientation e₁ e₂ e₃ c
  right
  have c' : tr_nd₁.is_cclock = ¬ tr_nd₂.is_cclock := by
    push_neg at c
    rcases c with x|y
    . simp only [x.1, x.2, not_false_eq_true]
    . simp only [y.1, y.2, not_false_eq_true]
  exact acongr_of_SSS_of_ne_orientation e₁ e₂ e₃ c'

/- SAS -/
theorem congr_of_SAS (e₂ : tr_nd₁.edge₂.length = tr_nd₂.edge₂.length) (a₁ : tr_nd₁.angle₁.value = tr_nd₂.angle₁.value) (e₃ : tr_nd₁.edge₃.length = tr_nd₂.edge₃.length) : tr_nd₁ ≅ tr_nd₂ := by
  have cosn₁ := Triangle.cosine_rule'' tr_nd₁
  have cosn₂ := Triangle.cosine_rule'' tr_nd₂
  rw [e₂,e₃,a₁,<-cosn₂] at cosn₁
  have c : tr_nd₁.is_cclock ↔ tr_nd₂.is_cclock := by
    apply Triangle_nd.pos_pos_or_neg_neg_of_iff_cclock.mpr
    by_cases cc: tr_nd₁.is_cclock
    . have pos : 0 < Angle.value (angle₁ tr_nd₁) := (tr_nd₁.angle_pos_of_cclock cc).1
      have pos' : 0 < Angle.value (angle₁ tr_nd₂) := by rw [<-a₁] ; exact pos
      exact .inl ⟨pos, pos'⟩
    . have neg : Angle.value (angle₁ tr_nd₁) < 0 := (tr_nd₁.angle_neg_of_clock cc).1
      have neg' : Angle.value (angle₁ tr_nd₂) < 0 := by rw [<-a₁] ; exact neg
      exact .inr ⟨neg, neg'⟩
  exact congr_of_SSS_of_eq_orientation cosn₁ e₂ e₃ c

theorem acongr_of_SAS (e₂ : tr_nd₁.edge₂.length = tr_nd₂.edge₂.length) (a₁ : tr_nd₁.angle₁.value = - tr_nd₂.angle₁.value) (e₃ : tr_nd₁.edge₃.length = tr_nd₂.edge₃.length) : tr_nd₁ ≅ₐ tr_nd₂ := by
  have cosn₁ := Triangle.cosine_rule'' tr_nd₁
  have cosn₂ := Triangle.cosine_rule'' tr_nd₂
  rw [e₂,e₃,a₁] at cosn₁
  simp only [Real.cos_neg, <-cosn₂] at cosn₁
  have c : tr_nd₁.is_cclock = ¬ tr_nd₂.is_cclock := by
    simp only [eq_iff_iff]
    constructor
    . intro cc
      have pos : 0 < Angle.value (angle₁ tr_nd₁) := (tr_nd₁.angle_pos_of_cclock cc).1
      have pos' : Angle.value (angle₁ tr_nd₂) < 0 := by rw [a₁] at pos ; exact neg_pos.mp pos
      exact tr_nd₂.clock_of_neg_angle (.inl pos')
    intro c
    have neg : Angle.value (angle₁ tr_nd₂) < 0 := (tr_nd₂.angle_neg_of_clock c).1
    have neg' : 0 < Angle.value (angle₁ tr_nd₁) := by rw [a₁] ; exact neg_pos.mpr neg
    exact tr_nd₁.cclock_of_pos_angle (.inl neg')
  exact acongr_of_SSS_of_ne_orientation cosn₁ e₂ e₃ c

/- ASA -/
theorem congr_of_ASA (a₂ : tr_nd₁.angle₂.value = tr_nd₂.angle₂.value) (e₁ : tr_nd₁.edge₁.length = tr_nd₂.edge₁.length) (a₃ : tr_nd₁.angle₃.value = tr_nd₂.angle₃.value) : tr_nd₁ ≅ tr_nd₂ := by
  have a₁ : tr_nd₁.angle₁.value = tr_nd₂.angle₁.value := by
    by_cases c : tr_nd₁.is_cclock
    . have a := tr_nd₁.angle_sum_eq_pi_of_cclock c
      have c₂ : tr_nd₂.is_cclock := by
        apply Triangle_nd.cclock_of_pos_angle
        right ; left
        rw [<-a₂]
        exact (tr_nd₁.angle_pos_of_cclock c).2.1
      simp only [a₂, a₃, <- tr_nd₂.angle_sum_eq_pi_of_cclock c₂, add_left_inj] at a
      exact a
    . have a := tr_nd₁.angle_sum_eq_neg_pi_of_clock c
      have c₂ : ¬  tr_nd₂.is_cclock := by
        apply Triangle_nd.clock_of_neg_angle
        right ; left
        rw [<-a₂]
        exact (tr_nd₁.angle_neg_of_clock c).2.1
      simp only [a₂, a₃, <- tr_nd₂.angle_sum_eq_neg_pi_of_clock c₂, add_left_inj] at a
      exact a
  have e₃ : tr_nd₁.edge₃.length = tr_nd₂.edge₃.length := by
    have sin := Triangle.sine_rule₂ tr_nd₁
    rw [e₁,a₃,a₁,Triangle.sine_rule₂ tr_nd₂] at sin
    simp only [mul_eq_mul_right_iff] at sin
    rcases sin with eq|triv
    . exact eq.symm
    have ne := sine_ne_zero_of_nd tr_nd₂
    exact (ne triv).elim
  apply (IsCongr.congr_iff_perm_congr tr_nd₁ tr_nd₂).mpr
  apply (IsCongr.congr_iff_perm_congr (perm_vertices tr_nd₁) (perm_vertices tr_nd₂)).mpr
  apply congr_of_SAS
  rw [<-(edge_eq_edge_of_perm_vertices (perm_vertices tr_nd₁)).1,<-(edge_eq_edge_of_perm_vertices tr_nd₁).2.2,<-(edge_eq_edge_of_perm_vertices (perm_vertices tr_nd₂)).1,<-(edge_eq_edge_of_perm_vertices tr_nd₂).2.2]
  exact e₃
  rw [<-(angle_eq_angle_of_perm_vertices (perm_vertices tr_nd₁)).2.2,<-(angle_eq_angle_of_perm_vertices tr_nd₁).2.1,<-(angle_eq_angle_of_perm_vertices (perm_vertices tr_nd₂)).2.2,<-(angle_eq_angle_of_perm_vertices tr_nd₂).2.1]
  exact a₂
  rw [<-(edge_eq_edge_of_perm_vertices (perm_vertices tr_nd₁)).2.1,<-(edge_eq_edge_of_perm_vertices tr_nd₁).1,<-(edge_eq_edge_of_perm_vertices (perm_vertices tr_nd₂)).2.1,<-(edge_eq_edge_of_perm_vertices tr_nd₂).1]
  exact e₁

theorem acongr_of_ASA (a₂ : tr_nd₁.angle₂.value = - tr_nd₂.angle₂.value) (e₁ : tr_nd₁.edge₁.length = tr_nd₂.edge₁.length) (a₃ : tr_nd₁.angle₃.value = - tr_nd₂.angle₃.value) : tr_nd₁ ≅ₐ tr_nd₂ := by
  have a₁ : tr_nd₁.angle₁.value = - tr_nd₂.angle₁.value := by
    by_cases c : tr_nd₁.is_cclock
    . have a := tr_nd₁.angle_sum_eq_pi_of_cclock c
      have c₂ : ¬ tr_nd₂.is_cclock := by
        have temp := (tr_nd₁.angle_pos_of_cclock c).2.1
        simp only [a₂, Left.neg_pos_iff] at temp
        exact Triangle_nd.clock_of_neg_angle _ (.inr (.inl temp))
      simp only [a₂, a₃] at a
      have b := tr_nd₂.angle_sum_eq_neg_pi_of_clock c₂
      linarith
    . have a := tr_nd₁.angle_sum_eq_neg_pi_of_clock c
      have c₂ : tr_nd₂.is_cclock := by
        have temp := (tr_nd₁.angle_neg_of_clock c).2.1
        simp only [a₂, Left.neg_neg_iff] at temp
        exact Triangle_nd.cclock_of_pos_angle _ (.inr (.inl temp))
      simp only [a₂, a₃] at a
      have b := tr_nd₂.angle_sum_eq_pi_of_cclock c₂
      linarith
  have e₃ : tr_nd₁.edge₃.length = tr_nd₂.edge₃.length := by
    have sin := Triangle.sine_rule₂ tr_nd₁
    rw [e₁,a₃,a₁] at sin
    simp only [Real.sin_neg, mul_neg, neg_inj, Triangle.sine_rule₂ tr_nd₂,mul_eq_mul_right_iff] at sin
    rcases sin with eq|triv
    . exact eq.symm
    have ne := sine_ne_zero_of_nd tr_nd₂
    exact (ne triv).elim
  apply (acongr_iff_perm_acongr tr_nd₁ tr_nd₂).mpr
  apply (acongr_iff_perm_acongr (perm_vertices tr_nd₁) (perm_vertices tr_nd₂)).mpr
  apply acongr_of_SAS
  rw [<-(edge_eq_edge_of_perm_vertices (perm_vertices tr_nd₁)).1,<-(edge_eq_edge_of_perm_vertices tr_nd₁).2.2,<-(edge_eq_edge_of_perm_vertices (perm_vertices tr_nd₂)).1,<-(edge_eq_edge_of_perm_vertices tr_nd₂).2.2]
  exact e₃
  rw [<-(angle_eq_angle_of_perm_vertices (perm_vertices tr_nd₁)).2.2,<-(angle_eq_angle_of_perm_vertices tr_nd₁).2.1,<-(angle_eq_angle_of_perm_vertices (perm_vertices tr_nd₂)).2.2,<-(angle_eq_angle_of_perm_vertices tr_nd₂).2.1]
  exact a₂
  rw [<-(edge_eq_edge_of_perm_vertices (perm_vertices tr_nd₁)).2.1,<-(edge_eq_edge_of_perm_vertices tr_nd₁).1,<-(edge_eq_edge_of_perm_vertices (perm_vertices tr_nd₂)).2.1,<-(edge_eq_edge_of_perm_vertices tr_nd₂).1]
  exact e₁

/- AAS -/
theorem congr_of_AAS (a₁ : tr_nd₁.angle₁.value = tr_nd₂.angle₁.value) (a₂ : tr_nd₁.angle₂.value = tr_nd₂.angle₂.value) (e₃ : tr_nd₁.edge₃.length = tr_nd₂.edge₃.length) : tr_nd₁ ≅ tr_nd₂ := by
  apply (IsCongr.congr_iff_perm_congr tr_nd₁ tr_nd₂).mpr
  apply congr_of_ASA
  rw [<-(angle_eq_angle_of_perm_vertices tr_nd₁).1,<-(angle_eq_angle_of_perm_vertices tr_nd₂).1]
  exact a₁
  rw [<-(edge_eq_edge_of_perm_vertices tr_nd₁).2.2,<-(edge_eq_edge_of_perm_vertices tr_nd₂).2.2]
  exact e₃
  rw [<-(angle_eq_angle_of_perm_vertices tr_nd₁).2.1,<-(angle_eq_angle_of_perm_vertices tr_nd₂).2.1]
  exact a₂

theorem acongr_of_AAS (a₁ : tr_nd₁.angle₁.value = - tr_nd₂.angle₁.value) (a₂ : tr_nd₁.angle₂.value = - tr_nd₂.angle₂.value) (e₃ : tr_nd₁.edge₃.length = tr_nd₂.edge₃.length) : tr_nd₁ ≅ₐ tr_nd₂ := by
  apply (acongr_iff_perm_acongr tr_nd₁ tr_nd₂).mpr
  apply acongr_of_ASA
  rw [<-(angle_eq_angle_of_perm_vertices tr_nd₁).1,<-(angle_eq_angle_of_perm_vertices tr_nd₂).1]
  exact a₁
  rw [<-(edge_eq_edge_of_perm_vertices tr_nd₁).2.2,<-(edge_eq_edge_of_perm_vertices tr_nd₂).2.2]
  exact e₃
  rw [<-(angle_eq_angle_of_perm_vertices tr_nd₁).2.1,<-(angle_eq_angle_of_perm_vertices tr_nd₂).2.1]
  exact a₂

/- HL -/
theorem congr_of_HL (h₁ : tr_nd₁.angle₁.value = π / 2) (h₂ : tr_nd₂.angle₁.value = π / 2) (e₁ : tr_nd₁.edge₁.length = tr_nd₂.edge₁.length) (e₂ : tr_nd₁.edge₂.length = tr_nd₂.edge₂.length) : tr_nd₁ ≅ tr_nd₂ := by
  have pyth := Pythagoras_of_tr_nd tr_nd₁ (Or.inl h₁)
  have pyth₂ := Pythagoras_of_tr_nd tr_nd₂ (Or.inl h₂)
  simp only [<- e₂, <- e₁, <- pyth, add_right_inj, ge_iff_le] at pyth₂
  have : Seg.length (edge₃ tr_nd₁) * Seg.length (edge₃ tr_nd₁) = Seg.length (edge₃ tr_nd₂) * Seg.length (edge₃ tr_nd₂) := by
    rw [<-sq ,<-sq]
    exact pyth₂.symm
  have pos : 0 ≤ Seg.length (edge₃ tr_nd₁) := Vec.norm_nonnegative tr_nd₁.edge₃.toVec
  have pos' : 0 ≤ Seg.length (edge₃ tr_nd₂) := Vec.norm_nonnegative tr_nd₂.edge₃.toVec
  have : Seg.length (edge₃ tr_nd₁) = Seg.length (edge₃ tr_nd₂) := (mul_self_inj pos pos').mp this
  rw [<-h₂] at h₁
  exact  congr_of_SAS e₂ h₁ this

theorem acongr_of_HL (h₁ : tr_nd₁.angle₁.value = π / 2) (h₂ : tr_nd₂.angle₁.value = - π / 2) (e₁ : tr_nd₁.edge₁.length = tr_nd₂.edge₁.length) (e₂ : tr_nd₁.edge₂.length = tr_nd₂.edge₂.length) : tr_nd₁ ≅ₐ tr_nd₂ := by
  have pyth := Pythagoras_of_tr_nd tr_nd₁ (Or.inl h₁)
  have pyth₂ := Pythagoras_of_tr_nd tr_nd₂ (Or.inr h₂)
  simp only [<- e₂, <- e₁, <- pyth, add_right_inj, ge_iff_le] at pyth₂
  have : Seg.length (edge₃ tr_nd₁) * Seg.length (edge₃ tr_nd₁) = Seg.length (edge₃ tr_nd₂) * Seg.length (edge₃ tr_nd₂) := by
    rw [<-sq ,<-sq]
    exact pyth₂.symm
  have pos : 0 ≤ Seg.length (edge₃ tr_nd₁) := Vec.norm_nonnegative tr_nd₁.edge₃.toVec
  have pos' : 0 ≤ Seg.length (edge₃ tr_nd₂) := Vec.norm_nonnegative tr_nd₂.edge₃.toVec
  have : Seg.length (edge₃ tr_nd₁) = Seg.length (edge₃ tr_nd₂) := by
    exact (mul_self_inj pos pos').mp this
  have eq_neg : tr_nd₁.angle₁.value = - tr_nd₂.angle₁.value := by
    simp only [h₁, h₂]
    linarith
  exact acongr_of_SAS e₂ eq_neg this

end Triangle_nd

namespace Triangle

theorem congr_of_SSS_of_left_triv (e₁ : tr₁.edge₁.length = tr₂.edge₁.length) (e₂ : tr₁.edge₂.length = tr₂.edge₂.length) (e₃ : tr₁.edge₃.length = tr₂.edge₃.length) (nnd : ¬ tr₁.is_nd) : tr₁ ≅ tr₂ where
  edge₁ := e₁
  edge₂ := e₂
  edge₃ := e₃
  angle₁ := (dite_prop_iff_and _).mpr ⟨fun nd ↦ (nnd nd.1).elim,fun _ ↦ trivial⟩
  angle₂ := (dite_prop_iff_and _).mpr ⟨fun nd ↦ (nnd nd.1).elim,fun _ ↦ trivial⟩
  angle₃ := (dite_prop_iff_and _).mpr ⟨fun nd ↦ (nnd nd.1).elim,fun _ ↦ trivial⟩

theorem congr_of_SSS_of_right_triv (e₁ : tr₁.edge₁.length = tr₂.edge₁.length) (e₂ : tr₁.edge₂.length = tr₂.edge₂.length) (e₃ : tr₁.edge₃.length = tr₂.edge₃.length) (nnd : ¬ tr₂.is_nd) : tr₁ ≅ tr₂ where
  edge₁ := e₁
  edge₂ := e₂
  edge₃ := e₃
  angle₁ := (dite_prop_iff_and _).mpr ⟨fun nd ↦ (nnd nd.2).elim,fun _ ↦ trivial⟩
  angle₂ := (dite_prop_iff_and _).mpr ⟨fun nd ↦ (nnd nd.2).elim,fun _ ↦ trivial⟩
  angle₃ := (dite_prop_iff_and _).mpr ⟨fun nd ↦ (nnd nd.2).elim,fun _ ↦ trivial⟩

theorem acongr_of_SSS_of_left_triv (e₁ : tr₁.edge₁.length = tr₂.edge₁.length) (e₂ : tr₁.edge₂.length = tr₂.edge₂.length) (e₃ : tr₁.edge₃.length = tr₂.edge₃.length) (nnd : ¬ tr₁.is_nd) : tr₁ ≅ₐ tr₂ :=
  (congr_of_SSS_of_left_triv e₁ e₂ e₃ nnd).acongr_of_left_triv nnd

theorem acongr_of_SSS_of_right_triv (e₁ : tr₁.edge₁.length = tr₂.edge₁.length) (e₂ : tr₁.edge₂.length = tr₂.edge₂.length) (e₃ : tr₁.edge₃.length = tr₂.edge₃.length) (nnd : ¬ tr₂.is_nd) : tr₁ ≅ₐ tr₂ :=
  (congr_of_SSS_of_right_triv e₁ e₂ e₃ nnd).acongr_of_right_triv nnd

theorem congr_or_acongr_of_SSS (e₁ : tr₁.edge₁.length = tr₂.edge₁.length) (e₂ : tr₁.edge₂.length = tr₂.edge₂.length) (e₃ : tr₁.edge₃.length = tr₂.edge₃.length) : tr₁ ≅ tr₂ ∨ tr₁ ≅ₐ tr₂ := by
  by_cases nd₁ : tr₁.is_nd
  . let tr_nd₁ : Triangle_nd P := ⟨tr₁,nd₁⟩
    by_cases nd₂ : tr₂.is_nd
    . let tr_nd₂ : Triangle_nd P := ⟨tr₂,nd₂⟩
      rcases Triangle_nd.congr_or_acongr_of_SSS (tr_nd₁ := tr_nd₁) (tr_nd₂ := tr_nd₂) e₁ e₂ e₃ with h | h'
      . exact .inl (Triangle.congr_of_congr h)
      . exact .inr (Triangle.acongr_of_acongr h')
    . by_contra
      unfold is_nd at nd₂
      push_neg at nd₂
      rw [Triangle.edge_sum_eq_edge_iff_colinear] at nd₂
      rcases nd₂ with l₁ | l₂ | l₃
      . simp only [<-e₁, <-e₂, <-e₃] at l₁
        have col' : colinear tr₁.point₁ tr₁.point₂ tr₁.point₃ := by
          rw [Triangle.edge_sum_eq_edge_iff_colinear]
          exact .inl l₁
        exact nd₁ col'
      . simp only [<-e₁, <-e₂, <-e₃] at l₂
        have col' : colinear tr₁.point₁ tr₁.point₂ tr₁.point₃ := by
          rw [Triangle.edge_sum_eq_edge_iff_colinear]
          exact .inr (.inl l₂)
        exact nd₁ col'
      . simp only [<-e₁, <-e₂, <-e₃] at l₃
        have col' : colinear tr₁.point₁ tr₁.point₂ tr₁.point₃ := by
          rw [Triangle.edge_sum_eq_edge_iff_colinear]
          exact .inr (.inr l₃)
        exact nd₁ col'
  exact .inl (congr_of_SSS_of_left_triv e₁ e₂ e₃ nd₁)

end Triangle

end criteria

end EuclidGeom
