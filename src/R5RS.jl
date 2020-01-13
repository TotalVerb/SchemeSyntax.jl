module R5RS

# set!
# http://docs.racket-lang.org/r5rs/r5rs-std/r5rs-Z-H-7.html?q=set!#%25_idx_104
macro set!(lhs, rhs)
    :($(esc(lhs)) = $(esc(rhs)))
end

export @set!

# number?
# complex?
# rational?
# (real?, integer? already defined)
# https://docs.racket-lang.org/r5rs/r5rs-std/r5rs-Z-H-9.html#%_sec_6.2.5
isnumber(::Number) = true
isnumber(::Any) = false
iscomplex(::Complex) = true
iscomplex(::Any) = false
isrational(::Union{Rational, AbstractFloat, Integer}) = true
isrational(::Irrational) = false
isrational(z::Complex) = isreal(z) && isrational(real(z))

export isnumber, iscomplex, isrational

# not
# http://docs.racket-lang.org/r5rs/r5rs-std/r5rs-Z-H-9.html#%_sec_6.3.1
not(x::Bool) = !x
not(::Any) = false

export not

# boolean?
# http://docs.racket-lang.org/r5rs/r5rs-std/r5rs-Z-H-9.html#%_sec_6.3.1
isboolean(x::Bool) = true
isboolean(::Any) = false

export isboolean

end
