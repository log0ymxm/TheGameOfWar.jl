using Base.Test
using StatsBase

require("War.jl")

function drawing_an_ace(x)
    deck = shuffle!([1:52])
    d1, d2 = deck[1:x], deck[x+1:52]
    aces = [13, 26, 39, 52]
    sum([i == d1[1] for i = aces])
end

# Assert that drawing any rank from a hand given X_t = 26 is uniform 1/13
p_drawing_an_ace_sample = [drawing_an_ace(26) for i=1:100000]
p_drawing_an_ace = mean(p_drawing_an_ace_sample)

@test_approx_eq_eps p_drawing_an_ace (1/13) 1e-2

println(p_drawing_an_ace)

sample_drawing_an_ace(x) = mean([drawing_an_ace(x) for i=1:100000])

drawing_an_ace_for_all_x = [sample_drawing_an_ace(i) for i = 1:52]

# Assert that all estimations are 1/13 for any value of X_t
for i=1:52
    @test_approx_eq_eps drawing_an_ace_for_all_x[i] (1/13) 1e-2
end

# We can define a function that calculates this exactly since
# it's based off the hypergeometric distribution.
function p_c(x)
    sum([(i/x)*(binomial(x,i)*binomial(52-x,4-i)/binomial(52,4)) for i=0:4])
end

println(p_c(26))

for x=1:52
    @test_approx_eq_eps p_c(x) (1/13) 1e-2
end

function draw_from_deck(x)
    deck = shuffle!([1:52])
    d1 = deck[1:x]
    c1 = pop!(d1)
    rank(c1)
end

println([draw_from_deck(26) for i = 1:100000])

sample_drawing_an_ace(x) = mean([draw_from_deck(x) for i=1:100000])
