# Adding new projects to experimental

## Purpose
The folder `experimental` is for code that is candidate for being added to
Oscar. In particular, this includes the following cases:
- Code from an external package that should be moved to Oscar
- Implementing a new feature from scratch
- In general: code whose API has not stabilized yet

The code in `experimental` is supposed to be mathematically correct,
`experimental` is a staging area for new features whose interface is still to
be stabilized. Also code is allowed to reside in `experimental` while it is
brought up to Oscar standard.

!!! danger "Dependencies"
    - Code from `src` must never use code from `experimental`
    - Say there are two packages `A` and `B` in `experimental`, and `B` depends
      on `A`. That means that `B` cannot be moved to `src` before `A`. Worse:
      If `A` gets abandoned, `B` might share that fate. So please consider
      carefully in such situations.

## Structure
To look at a sample for the structure for a new project in `experimental` have
a look at `experimental/PlaneCurve`. The general structure is
```
experimental/PACKAGE_NAME/
├── docs
│   ├── doc.main
│   └── src
│       └── DOCUMENTATION.md
├── src
│   └── PACKAGE_NAME.jl
└── test
    └── runtests.jl
```
The files `src/PACKAGE_NAME.jl`, `test/runtests.jl`, and `docs/doc.main` are
mandatory, as they are used by Oscar.jl to find your code, tests, and
documentation.

## Procedure for adding a new feature
Ideally we envision the procedure to follow along the following lines.

1. The new feature is implemented in the `experimental` folder.
2. For external authors, a maintainer is assigned to guide the authors such
   that the implementation adheres to the [Developer Style Guide](@ref) and the
   [Design Decisions](@ref).
   Please get in touch with us as soon as possible, preferably on the [OSCAR
   Slack](https://oscar.computeralgebra.de/community/#slack).
3. The new feature is tested thoroughly, other people are invited to test the
   new feature.
4. In the end there are three possibilities:
   1. The feature is considered done and moved into `src` as is.
   2. The feature is discarded, e.g., because it cannot be maintained.
   3. Parts of the feature are moved into `src`, others are discarded.

## Criteria for acceptance

The main criteria for acceptance are:
1. The code adheres to the [Developer Style Guide](@ref) and the [Design
   Decisions](@ref).
2. The new code is well tested.
3. It is clear who maintains the new code, i.e. the original authors commit to
   maintaining the code in the future.

