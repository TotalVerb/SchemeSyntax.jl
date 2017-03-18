using SExpressions
using SExpressions.Lists
using SchemeSyntax.RacketExtensions
using SchemeSyntax.R5RS

evaluate(α) = eval(SchemeSyntax.tojulia(α))

@testset "Errors" begin
    @test_throws ErrorException SchemeSyntax.tojulia(sx"#:keyword")
    @test_throws ErrorException SchemeSyntax.tojulia(sx"(quote x y)")
    @test_throws ErrorException SchemeSyntax.tojulia(sx"(define x y z)")
    @test_throws ErrorException SchemeSyntax.tojulia(sx"(let ([x y]))")
    @test_throws ErrorException SchemeSyntax.tojulia(sx"(lambda (x))")
end

@testset "Calls" begin
    @test SchemeSyntax.tojulia(sx"(+ 1 1)") == :(1 + 1)
    @test evaluate(sx"(+ 1 1)") == 2
    @test evaluate(sx"(- 1 1)") == 0
    @test evaluate(sx"(void)") === nothing
    @test evaluate(sx"(void 1 2)") === nothing
    @test evaluate(sx"(void (* 1 3))") === nothing
end

@testset "if" begin
    @test SchemeSyntax.tojulia(sx"""
      (if x y z)
    """) == :(x ? y : z)
    @test evaluate(sx"(if #t 1 2)") == 1
    @test evaluate(sx"(if #f 1 2)") == 2
end

@testset "quote" begin
    @test evaluate(sx"'x") == :x
    @test evaluate(sx"`(+ 1 1)") == List(:+, 1, 1)
end

@testset "set!" begin
    @test evaluate(sx"""
    (begin
      (define x 1)
      (set! x 2)
      `(+ ,x x))
    """) == List(:+, 2, :x)
end

@testset "Dispatch" begin
    @test evaluate(sx"""
    (begin
      (define (foo (:: x Integer)) 1)
      (define (foo (:: x String)) 2)
      (string (foo 1) (foo "x")))
    """) == "12"
end

@testset "Field access" begin
    @test evaluate(sx"((.+ Base) 1 2)") == 3
    @test evaluate(sx"(.Markdown Base)") === Base.Markdown
    @test evaluate(sx"(.MD (.Markdown Base))") === Base.Markdown.MD
end

for (sym, fn) in [[:and, &], [:or, |]]
    @testset "$sym" begin
        for a in [false, true]
            for b in [false, true]
                @test evaluate(list(sym, a, b)) == fn(a, b)
            end
        end
    end
end

@testset "not" begin
    @test evaluate(sx"(not #f)")
    @test !evaluate(sx"(not #t)")
    @test !evaluate(sx"(not 1)")
end

@testset "boolean?" begin
    @test evaluate(sx"(boolean? #t)")
    @test evaluate(sx"(boolean? #f)")
    @test !evaluate(sx"(boolean? 10)")
end

@testset "Indexing" begin
    @test evaluate(sx"(ref (List 1 2 3) 2)") == 2
end

@testset "λ" begin
    @test evaluate(sx"((λ (x) (* x x)) 10)") == 100
    @test evaluate(sx"((λ (x y) (* x y)) 10 20)") == 200
    @test evaluate(sx"""
    ((λ (x)
        (define (f y) (+ x y))
        (+ (f 1) 2)) 10)
    """) == 13
end

@testset "let" begin
    @test evaluate(sx"(let ([x 1]) x)") == 1
    @test evaluate(sx"(let ([x 1]) (define y x) (+ y x))") == 2
    @test evaluate(sx"(let ([x 1] [y 2]) (+ x y))") == 3
    @test evaluate(sx"(let ([x 1] [y (+ 1 1)]) (+ x y))") == 3
end

@testset "define" begin
    @test evaluate(sx"(begin (define x 1) x)") == 1
    @test evaluate(sx"(begin (define x 1) (+ x x))") == 2
    @test evaluate(sx"""
(begin
  (define x 1)
  (define y 2)
  (+ x y))
""") == 3

    @test evaluate(sx"(define x 1)") == nothing
    @test evaluate(sx"(define (f x) 1)") == nothing
    @test evaluate(sx"(begin (define (f x) 1) (f 0))") == 1
    @test evaluate(sx"(begin (define (f x) x) (f 0))") == 0
end

@testset "when" begin
    @test evaluate(sx"(when #t (+ 1 1))") == 2
    @test evaluate(sx"(when #f (+ 1 1))") == nothing
    @test evaluate(sx"(when #t (cons 'x nil))") == cons(:x, nil)
    @test evaluate(sx"(when #f (cons 'x nil))") == nothing
    @test evaluate(sx"(when (= 1 2) (+ 1 1))") == nothing
    @test evaluate(sx"(when (< 1 2) (+ 1 1))") == 2
end
@testset "unless" begin
    @test evaluate(sx"(let ([x #f]) (unless x 1))") == 1
    @test evaluate(sx"(let ([x #t]) (unless x 1))") == nothing
end

@testset "module" begin
    @test evaluate(sx"(module Foo0 (define x 10))").x == 10
    @test Set(names(evaluate(sx"""
        (module Foo1
          (export x)
          (define x 10))
          """))) == Set([:Foo1, :x])
end
