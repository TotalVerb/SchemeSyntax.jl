@testset "R⁵RS" begin

@testset "6.2.5. Numerical operations" begin
    @test_skip evaluate(sx"(number? 10)")
    @test_skip !evaluate(sx"(number? \"x\")")
    @test_broken evaluate(sx"(complex? 3+4i)")
    @test_broken evaluate(sx"(complex? 3)")
    @test evaluate(sx"(real? 3)")
    @test_broken evaluate(sx"(real? -2.5+0.0i)")
    @test_broken evaluate(sx"(rational? 6/10)")
    @test_broken evaluate(sx"(rational? 6/3)")
    @test_broken evaluate(sx"(rational? -6/3)")
    @test_broken evaluate(sx"(rational? 97)")
    @test evaluate(sx"(integer? 10)")
    @test_broken evaluate(sx"(integer? 3.0)")
    @test_broken evaluate(sx"(integer? 3+0i)")
    @test evaluate(sx"(integer? 8/4)")

    @test_broken evaluate(sx"(exact? 1)")
    @test_broken !evaluate(sx"(inexact? 1)")

    @test evaluate(sx"(= 1 1)")
    @test_broken evaluate(sx"(= 1 1 1/1 1+0i)")
    @test evaluate(sx"(< 1 2)")
    @test_broken !evaluate(sx"(< 1 1+0i)")
    @test_broken evaluate(sx"(<= 1 2 3)")
    @test_broken evaluate(sx"(<= 1 1+0i)")
    @test_broken !evaluate(sx"(> 3 2 2)")
    @test_broken !evaluate(sx"(> 1 1+0i)")
    @test_broken evaluate(sx"(>= 1 1/1 1)")
    @test_broken !evaluate(sx"(>= 1 1/1 0 1)")

    @test !evaluate(sx"(zero? 10)")
    @test evaluate(sx"(zero? 0)")
    @test evaluate(sx"(zero? 0/1)")
    @test_broken evaluate(sx"(zero? -0)")
    @test_broken evaluate(sx"(zero? 0+0i)")
    @test_broken evaluate(sx"(positive? 1)")
    @test_broken evaluate(sx"(positive? 1+0i)")
    @test_broken !evaluate(sx"(positive? 0+0i)")
    @test_broken !evaluate(sx"(negative? 1)")
    @test_broken evaluate(sx"(negative? -1)")
    @test evaluate(sx"(odd? 1)")
    @test !evaluate(sx"(odd? 2)")
    @test !evaluate(sx"(even? 1)")
    @test evaluate(sx"(even? 2)")

    @test evaluate(sx"(max 1 2)") == 2
    @test evaluate(sx"(max 1 2 10)") == 10
    @test evaluate(sx"(min 1 2)") == 1
    @test evaluate(sx"(min 1 2 10)") == 1

    # no more tests, up to page 22/50 of
    # http://www.schemers.org/Documents/Standards/R5RS/r5rs.pdf
end

end
