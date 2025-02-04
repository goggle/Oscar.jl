export graded_coordinate_ring

########################################################################
# Interface for abstract projective schemes                            #
########################################################################

function base_ring(P::AbsProjectiveScheme) 
  return base_ring(underlying_scheme(P))
end

@doc Markdown.doc"""
    ambient_coordinate_ring(P::AbsProjectiveScheme)

On a projective scheme ``P = Proj(S)`` with ``S = P/I`` 
for a standard graded polynomial ring ``P`` and a 
homogeneous ideal ``I`` this returns ``P``.
"""
function ambient_coordinate_ring(P::AbsProjectiveScheme)
  return ambient_coordinate_ring(underlying_scheme(P))
end

@doc Markdown.doc"""
    graded_coordinate_ring(P::AbsProjectiveScheme)

On a projective scheme ``P = Proj(S)`` for a standard 
graded finitely generated algebra ``S`` this returns ``S``.
"""
function graded_coordinate_ring(P::AbsProjectiveScheme)
  return graded_coordinate_ring(underlying_scheme(P))
end

@attr AbsSpec function base_scheme(P::AbsProjectiveScheme)
  return base_scheme(underlying_scheme(P))
end

@doc Markdown.doc"""
    affine_cone(X::ProjectiveScheme) 

On ``X = Proj(S) ⊂ ℙʳ_𝕜`` this returns a pair `(C, f)` where ``C = C(X) ⊂ 𝕜ʳ⁺¹`` 
is the affine cone of ``X`` and ``f : S → 𝒪(C)`` is the morphism of rings 
from the `graded_coordinate_ring` to the `coordinate_ring` of the affine cone.
"""
@attr function affine_cone(
    P::AbsProjectiveScheme{RT}
  ) where {RT<:Union{MPolyRing, MPolyQuoRing, MPolyQuoLocRing, MPolyLocRing}}
  S = graded_coordinate_ring(P)
  phi = RingFlattening(S)
  A = codomain(phi)
  C = Spec(A)
  B = base_scheme(P)
  P.projection_to_base = SpecMor(C, B, hom(OO(B), OO(C), gens(OO(C))[ngens(S)+1:end], check=false), check=false)
  return C, phi
end

@attr function affine_cone(
    P::AbsProjectiveScheme{RT, <:MPolyQuoRing}
  ) where {RT<:Field}
  S = graded_coordinate_ring(P)
  PS = base_ring(S)
  PP = forget_grading(PS) # the ungraded polynomial ring
  I = modulus(S)
  II = forget_grading(I)
  SS, _ = quo(PP, II)
  phi = hom(S, SS, gens(SS))
  C = Spec(SS)
  return C, phi
end

@attr function affine_cone(
    P::AbsProjectiveScheme{RT, <:MPolyDecRing}
  ) where {RT<:Field}
  S = graded_coordinate_ring(P)
  PP = forget_grading(S) # the ungraded polynomial ring
  phi = hom(S, PP, gens(PP))
  C = Spec(PP)
  return C, phi
end

########################################################################
# Methods for the concrete minimal instance                            #
########################################################################

@doc Markdown.doc"""
    base_ring(X::ProjectiveScheme)

On ``X ⊂ ℙʳ(A)`` this returns ``A``.
"""
base_ring(P::ProjectiveScheme) = P.A

@doc Markdown.doc"""
    base_scheme(X::ProjectiveScheme{CRT, CRET, RT, RET}) where {CRT<:MPolyQuoLocRing, CRET, RT, RET}

Return the base scheme ``Y`` for ``X ⊂ ℙʳ×ₖ Y → Y`` with ``Y`` defined over a field ``𝕜``.
"""
function base_scheme(X::ProjectiveScheme{CRT, CRET, RT, RET}) where {CRT<:Ring, CRET, RT, RET}
  if !isdefined(X, :Y)
    X.Y = Spec(base_ring(X))
  end
  return X.Y
end

function base_scheme(X::ProjectiveScheme{<:SpecOpenRing}) 
  return domain(base_ring(X))
end

function set_base_scheme!(
    P::ProjectiveScheme{CRT, CRET, RT, RET}, 
    X::Union{<:AbsSpec, <:SpecOpen}
  ) where {CRT<:Ring, CRET, RT, RET}
  OO(X) === base_ring(P) || error("schemes are not compatible")
  P.Y = X
  return P
end

function projection_to_base(X::ProjectiveScheme{CRT, CRET, RT, RET}) where {CRT<:Union{<:MPolyRing, <:MPolyQuoRing, <:MPolyLocRing, <:MPolyQuoLocRing, <:SpecOpenRing}, CRET, RT, RET}
  if !isdefined(X, :projection_to_base)
    affine_cone(X)
  end
  return X.projection_to_base
end


@doc Markdown.doc"""
    relative_ambient_dimension(X::ProjectiveScheme)

On ``X ⊂ ℙʳ(A)`` this returns ``r``.
"""
relative_ambient_dimension(P::ProjectiveScheme) = P.r

@doc Markdown.doc"""
    graded_coordinate_ring(X::ProjectiveScheme)

On ``X ⊂ ℙʳ(A)`` this returns ``A[s₀,…,sᵣ]``.
"""
graded_coordinate_ring(P::ProjectiveScheme) = P.S

ambient_coordinate_ring(P::ProjectiveScheme{<:Any, <:Any, <:MPolyQuoRing}) = base_ring(graded_coordinate_ring(P))
ambient_coordinate_ring(P::ProjectiveScheme{<:Any, <:Any, <:MPolyDecRing}) = graded_coordinate_ring(P)

### TODO: Replace by the map of generators.
@doc Markdown.doc"""
    homogeneous_coordinates(X::ProjectiveScheme)

On ``X ⊂ ℙʳ(A)`` this returns a vector with the homogeneous 
coordinates ``[s₀,…,sᵣ]`` as entries where each one of the 
``sᵢ`` is a function on the `affine cone` of ``X``.
"""
function homogeneous_coordinates(P::ProjectiveScheme)
  if !isdefined(P, :homog_coord)
    C, f = affine_cone(P)
    P.homog_coord = f.(gens(graded_coordinate_ring(P)))
  end
  return P.homog_coord
end

homogeneous_coordinate(P::ProjectiveScheme, i::Int) = homogeneous_coordinates(P)[i]

@doc Markdown.doc"""
    defining_ideal(X::AbsProjectiveScheme)

On ``X ⊂ ℙʳ(A)`` this returns the homogeneous 
ideal ``I ⊂ A[s₀,…,sᵣ]`` defining ``X``.
"""
defining_ideal(X::AbsProjectiveScheme{<:Any, <:MPolyDecRing}) = ideal(graded_coordinate_ring(X), Vector{elem_type(graded_coordinate_ring(X))}())
defining_ideal(X::AbsProjectiveScheme{<:Any, <:MPolyQuoRing}) = modulus(graded_coordinate_ring(X))

### type getters 
projective_scheme_type(A::T) where {T<:AbstractAlgebra.Ring} = projective_scheme_type(typeof(A))
projective_scheme_type(::Type{T}) where {T<:AbstractAlgebra.Ring} = 
ProjectiveScheme{T, elem_type(T), mpoly_dec_ring_type(mpoly_ring_type(T)), mpoly_dec_type(mpoly_ring_type(T))}

base_ring_type(P::ProjectiveScheme) = base_ring_type(typeof(P))
base_ring_type(::Type{ProjectiveScheme{S, T, U, V}}) where {S, T, U, V} = S

ring_type(P::ProjectiveScheme) = ring_type(typeof(P))
ring_type(::Type{ProjectiveScheme{S, T, U, V}}) where {S, T, U, V} = U

### type constructors 

# the type of a relative projective scheme over a given base scheme
projective_scheme_type(X::AbsSpec) = projective_scheme_type(typeof(X))
projective_scheme_type(::Type{T}) where {T<:AbsSpec} = projective_scheme_type(ring_type(T))

#function affine_cone(X::ProjectiveScheme{CRT, CRET, RT, RET}) where {CRT<:Union{MPolyRing, MPolyQuoRing, MPolyLocRing, MPolyQuoLocRing}, CRET, RT, RET}
#  if !isdefined(X, :C)
#    Y = base_scheme(X)
#    A = OO(Y)
#    kk = base_ring(A)
#    F = affine_space(kk, symbols(ambient_coordinate_ring(X)))
#    C, pr_fiber, pr_base = product(F, Y)
#    X.homog_coord = lift.([pullback(pr_fiber)(u) for u in gens(OO(F))])
#
#    S = ambient_coordinate_ring(X)
#    # use the new mapping types for polynomial rings.
#    inner_help_map = hom(A, OO(C), [pullback(pr_base)(x) for x in gens(OO(Y))])
#    help_map = hom(S, OO(C), inner_help_map, [pullback(pr_fiber)(y) for y in gens(OO(F))])
#
#    # use the map to convert ideals:
#    #I = ideal(OO(C), [help_map(g) for g in gens(defining_ideal(X))])
#    I = help_map(defining_ideal(X))
#    CX = subscheme(C, I)
#    set_attribute!(X, :affine_cone, CX) # TODO: Why this doubling?
#    X.C = get_attribute(X, :affine_cone)
#    pr_base_res = restrict(pr_base, CX, Y, check=false)
#    pr_fiber_res = restrict(pr_fiber, CX, F, check=false)
#
#    # store the various conversion maps
#    set_attribute!(X, :homog_to_frac, 
#                    hom(S, OO(CX), 
#                          hom(A, OO(CX), [pullback(pr_base_res)(x) for x in gens(OO(Y))]),
#                          [pullback(pr_fiber_res)(y) for y in gens(OO(F))]
#                       )
#                  )
#    pth = hom(ambient_coordinate_ring(CX), S, vcat(gens(S), S.(gens(A))))
#    set_attribute!(X, :poly_to_homog, pth)
##    set_attribute!(X, :frac_to_homog_pair, (f -> (pth(lifted_numerator(OO(CX)(f))), pth(lifted_denominator(OO(CX)(f))))))
#    X.projection_to_base = pr_base_res
#  end
#  return X.C
#end

#function affine_cone(X::ProjectiveScheme{CRT, CRET, RT, RET}) where {CRT<:AbstractAlgebra.Ring, CRET, RT, RET}
#  if !isdefined(X, :C)
#    kk = base_ring(X)
#    C = affine_space(kk, symbols(ambient_coordinate_ring(X)))
#    X.homog_coord = gens(OO(C))
#    S = ambient_coordinate_ring(X)
#    help_map = hom(S, OO(C), gens(OO(C)))
#    I = help_map(defining_ideal(X))
#    CX = subscheme(C, I)
#
#    # store the various conversion maps
#    set_attribute!(X, :homog_to_frac, hom(S, OO(CX), gens(OO(CX))))
#    pth = hom(base_ring(OO(CX)), S, gens(S))
#    set_attribute!(X, :poly_to_homog, pth)
#    set_attribute!(X, :frac_to_homog_pair, (f -> (pth(lift(f)), one(S))))
#    X.C = CX
#  end
#  return X.C
#end

@attr function affine_cone(
    X::AbsProjectiveScheme{CRT, RT}
  ) where {
           CRT<:SpecOpenRing, 
           RT<:MPolyRing 
          }
  S = ambient_coordinate_ring(X)
  B = coefficient_ring(S)
  Y = scheme(B)
  U = domain(B)
  R = base_ring(OO(Y))
  kk = base_ring(R)
  F = affine_space(kk, symbols(ambient_coordinate_ring(X)))
  C, pr_base, pr_fiber = product(U, F)
  X.homog_coord = [pullback(pr_fiber)(u) 
                   for u in OO(codomain(pr_fiber)).(gens(OO(F)))]
  phi = hom(S, OO(C), pullback(pr_base), X.homog_coord)
  g = phi.(gens(defining_ideal(X)))
  CX = subscheme(C, g)
  X.C = CX

  psi = compose(phi, restriction_map(C, CX))
  set_attribute!(X, :base_scheme, U)
  X.projection_to_base = restrict(pr_base, CX, U, check=false)
  return X.C, psi 
end

@attr function affine_cone(
    X::AbsProjectiveScheme{CRT, RT}
  ) where {
           CRT<:SpecOpenRing,
           RT<:MPolyQuoRing
          }
  P = ambient_coordinate_ring(X)
  S = graded_coordinate_ring(X)
  B = coefficient_ring(P)
  Y = scheme(B)
  U = domain(B)
  R = base_ring(OO(Y))
  kk = base_ring(R)
  F = affine_space(kk, symbols(ambient_coordinate_ring(X)))
  C, pr_base, pr_fiber = product(U, F)
  homog_coord = [pullback(pr_fiber)(u) 
                 for u in OO(codomain(pr_fiber)).(gens(OO(F)))]
  phi = hom(P, OO(C), pullback(pr_base), homog_coord)
  g = phi.(gens(modulus(S)))
  CX = subscheme(C, g)
  pr_base_res = restrict(pr_base, CX, codomain(pr_base), check=true)
  X.C = CX
  X.homog_coord = OO(CX).(homog_coord)

  #psi = hom(S, OO(CX), pullback(pr_base), OO(CX).(X.homog_coord), check=false)

  psi = compose(phi, restriction_map(C, CX))
  psi_res = hom(S, OO(CX), pullback(pr_base_res), X.homog_coord, check=false)
  set_attribute!(X, :base_scheme, U)
  X.projection_to_base = restrict(pr_base, CX, U, check=false)
  return X.C, psi_res 
end

# Basic functionality required for Warham
@attr Int function dim(P::AbsProjectiveScheme{<:Field})
  return dim(defining_ideal(P))-1
end

@attr QQPolyRingElem function hilbert_polynomial(P::AbsProjectiveScheme{<:Field})
  return hilbert_polynomial(graded_coordinate_ring(P))
end

@attr ZZRingElem function degree(P::AbsProjectiveScheme{<:Field})
  return degree(graded_coordinate_ring(P))
end

@attr QQFieldElem function arithmetic_genus(P::AbsProjectiveScheme{<:Field})
  h = hilbert_polynomial(P)
  return (-1)^dim(P) * (first(coefficients(h)) - 1)
end

@attr Bool function is_smooth(P::AbsProjectiveScheme)
  return is_smooth(covered_scheme(P))
end

@doc Markdown.doc"""
    covered_scheme(P::ProjectiveScheme)
    
Return a `CoveredScheme` ``X`` isomorphic to `P` with standard affine charts given by dehomogenization. 

Use `dehomogenize(P, U)` with `U` one of the `affine_charts` of ``X`` to 
obtain the dehomogenization map from the `graded_coordinate_ring` of `P` 
to the `coordinate_ring` of `U`.

# Examples
```jldoctest
julia> P = projective_space(QQ, 2);

julia> Pcov = covered_scheme(P)
covered scheme with 3 affine patches in its default covering
```
"""
@attr AbsCoveredScheme function covered_scheme(P::ProjectiveScheme)
    C = standard_covering(P) 
    X = CoveredScheme(C)
    return X
end

@attr function covered_projection_to_base(X::ProjectiveScheme{<:Union{<:MPolyQuoLocRing, <:MPolyLocRing, <:MPolyQuoRing, <:MPolyRing}})
  if !has_attribute(X, :covering_projection_to_base) 
    C = standard_covering(X)
  end
  covering_projection = get_attribute(X, :covering_projection_to_base)::CoveringMorphism
  projection = CoveredSchemeMorphism(covered_scheme(X), CoveredScheme(codomain(covering_projection)), covering_projection)
end

