module SchemeSyntax

export tojulia

using Base.Iterators
using SExpressions.Lists
using SExpressions.Keywords

include("expanders.jl")

tojulia(x) = x
tojulia(x::Keyword) = error("keyword used as an expression")
function tojulia(x::Symbol)
    if x == :(=)
        :(==)
    elseif x == :(-)
        :(-)
    elseif x == :(/)
        :(/)
    else
        xstr = replace(string(x), r"[-/]", '_')
        Symbol(xstr[end] == '?' ? "is" * xstr[1:end-1] : xstr)
    end
end

const _IMPLICIT_KEYWORDS = Dict(
    :if => :if,
    :while => :while,
    :begin => :block,
    :(::) => :(::),
    :and => :(&&),
    :or => :(||),
    :ref => :ref)
const _IMPLICIT_MACROS = Dict(
    # racket
    :when => Symbol("@when"),
    :unless => Symbol("@unless"),
    # r5rs
    :set! => Symbol("@set!"),
    # julia extensions
    :isdefined => Symbol("@isdefined"))

const _SYNTAX_EXPANDERS = Dict(
    :provide => expandprovide,
    :module => expandmodule,
    :require => expandrequire
)

quasiquote(x, _=1) = x
quasiquote(x::Symbol, _=1) = Meta.quot(x)
function quasiquote(α::List, level=1)
    if car(α) == :unquote
        if level == 1
            return tojulia(cadr(α))
        else
            level -= 1
        end
    elseif car(α) == :quasiquote
        level += 1
    end
    Expr(:call, :List, (quasiquote(x, level) for x in α)...)
end

isfieldaccess(x::Symbol) = let s = string(x)
    length(s) > 1 && s[1] == '.'
end
isfieldaccess(::Any) = false
asfield(x::Symbol) = tojulia(Symbol(string(x)[2:end]))

function tojulia(α::List)
    if isfieldaccess(car(α))
        if length(α) == 2
            Expr(:., tojulia(α[2]), QuoteNode(asfield(α[1])))
        else
            error(".field notation accepts only a single argument")
        end
    elseif car(α) isa Symbol
        head = tojulia(car(α))
        args = cdr(α)
        if head ∈ [:λ, :lambda]
            if length(args) ≥ 2
                Expr(:->, Expr(:tuple, args[1]...),
                     tojulia(cons(:begin, cdr(args))))
            else
                error(string("incorrect λ syntax; must be ",
                             "(λ (args) body)"))
            end
        elseif head == :define
            if length(args) == 2
                :($(tojulia(args[1])) = $(tojulia(args[2])); nothing)
            else
                error(string("incorrect define syntax; must be ",
                             "(define x y)"))
            end
        elseif head == :let
            if length(args) ≥ 2
                Expr(:let,
                     Expr(:block,
                          (Expr(:(=), map(tojulia, γ)...)
                           for γ in args[1])...),
                     tojulia(cons(:begin, cdr(args))))
            else
                error(string("incorrect let syntax; must be ",
                             "(let ([x y]) body)"))
            end
        elseif head == :jl_expr
            if args[1] isa Symbol
                Expr(args[1], map(tojulia, cdr(args))...)
            else
                error(string("incorrect jl/expr syntax; must be ",
                             "(jl/expr head args)"))
            end
        elseif head == :quote
            if length(args) == 1
                Meta.quot(args[1])
            else
                error(string("incorrect quote syntax; must be ",
                             "(quote ...)"))
            end
        elseif head == :quasiquote
            if length(args) == 1
                quasiquote(args[1])
            else
                error(string("incorrect quasiquote syntax; must be ",
                             "(quasiquote ...)"))
            end
        elseif haskey(_IMPLICIT_KEYWORDS, head)
            Expr(_IMPLICIT_KEYWORDS[head], (tojulia ⊚ args)...)
        elseif haskey(_IMPLICIT_MACROS, head)
            Expr(:macrocall,
                 _IMPLICIT_MACROS[head],
                 LineNumberNode(1, "unknown"),
                 (tojulia ⊚ args)...)
        elseif haskey(_SYNTAX_EXPANDERS, head)
            _SYNTAX_EXPANDERS[head]((tojulia ⊚ args)...)
        else
            Expr(:call, (tojulia ⊚ α)...)
        end
    else
        Expr(:call, (tojulia ⊚ α)...)
    end
end

include("R5RS.jl")
include("RacketExtensions.jl")

end
