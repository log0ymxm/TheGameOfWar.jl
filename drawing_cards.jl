using Base.Test
using StatsBase

# Counting the number of aces (or any rank card) in a hand of size x.
#
# This follows a hypergeometric distribution, and can
# be modeled exactly.
# P(# Aces in d1) = Hypergeom(52, x, 4)
#
# https://en.wikipedia.org/wiki/Hypergeometric_distribution

function number_of_aces(x)
    deck = shuffle!([1:52])
    d1, d2 = deck[1:x], deck[x+1:52]
    aces = [13, 26, 39, 52]
    sum([in(i, d1) for i = aces])
end

# x = 26
num_aces = [number_of_aces(26) for i=1:1000000];

expected_num_aces = mean(num_aces)
ace_probabilities = counts(num_aces, 0:4) / length(num_aces)

@test_approx_eq_eps expected_num_aces 2 1e-2
@test_approx_eq_eps ace_probabilities[1] (46/833) 1e-2
@test_approx_eq_eps ace_probabilities[2] (208/833) 1e-2
@test_approx_eq_eps ace_probabilities[3] (325/833) 1e-2
@test_approx_eq_eps ace_probabilities[4] (208/833) 1e-2
@test_approx_eq_eps ace_probabilities[5] (46/833) 1e-2

println("E[# aces | X_t = 26] = $(expected_num_aces)")
println("p(0 aces | X_t = 26) = $(ace_probabilities[1])")
println("p(1 ace | X_t = 26)  = $(ace_probabilities[2])")
println("p(2 aces | X_t = 26) = $(ace_probabilities[3])")
println("p(3 aces | X_t = 26) = $(ace_probabilities[4])")
println("p(4 aces | X_t = 26) = $(ace_probabilities[5])")

# Now we can check for x = 10, it also follows the hypergeometric
num_aces_x_10 = [number_of_aces(10) for i=1:1000000];
expected_num_aces_x_10 = mean(num_aces_x_10)
ace_probabilities_x_10 = counts(num_aces_x_10, 0:4) / length(num_aces_x_10)

@test_approx_eq_eps expected_num_aces_x_10 0.769 1e-2
@test_approx_eq_eps ace_probabilities_x_10[1] (246/595) 1e-2
@test_approx_eq_eps ace_probabilities_x_10[2] (656/1547) 1e-2
@test_approx_eq_eps ace_probabilities_x_10[3] (1107/7735) 1e-2
@test_approx_eq_eps ace_probabilities_x_10[4] (144/7735) 1e-2
@test_approx_eq_eps ace_probabilities_x_10[5] (6/7735) 1e-2

println("E[# aces | X_t = 10] = $(expected_num_aces_x_10)")
println("P of aces given X_t = 10: $(ace_probabilities_x_10)")
