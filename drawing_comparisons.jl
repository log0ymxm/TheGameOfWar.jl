using Base.Test

require("War.jl")

function comparing_cards_unif()
    # assuming cards of any size are drawn from a uniform(1,13) dist
    c1 = rand(1:13)
    c2 = rand(1:13)
    v1, v2 = rank(c1), rank(c2)

    v1 > v2
end

p_p1_wins = mean([comparing_cards_unif() for i=1:1000000])

println("P(C_1 > C_2 | C_1, C_2 ~ DiscUnif(1,13)) = $(p_p1_wins)")

@test_approx_eq_eps p_p1_wins (6/13) 1e-3

# However, this doesn't model the actual card comparison probabilities
# in the game of war. Instead we have,

function comparing_cards_from_deck(x)
    deck = shuffle!([1:52])
    d1, d2 = deck[1:x], deck[x+1:52]
    card1, card2 = pop!(d1), pop!(d2)
    v1, v2 = rank(card1), rank(card2)

    v1 > v2
end

p_p1_wins = mean([comparing_cards_from_deck(26) for i=1:1000000])
println("P(C_1 > C_2 | X_t = 26) = $(p_p1_wins)")

p_p1_wins = mean([comparing_cards_from_deck(1) for i=1:1000000])
println("P(C_1 > C_2 | X_t = 1) = $(p_p1_wins)")
#@test_approx_eq_eps p_p1_wins (6/13) 1e-3

probs = [mean([comparing_cards_from_deck(x) for i=1:1000000]) for x=1:51]
println(probs)
println(mean(probs))
println(std(probs))

function comparing_cards_from_deck_eq()
    deck = shuffle!([1:52])
    d1, d2 = deck[1:26], deck[27:52]
    card1, card2 = pop!(d1), pop!(d2)
    v1, v2 = rank(card1), rank(card2)

    v1 == v2
end

p_eq = mean([comparing_cards_from_deck_eq() for i=1:10000000])
println(p_eq)

println("total: $(2*mean(probs) + p_eq)")

println((1 - p_eq))
