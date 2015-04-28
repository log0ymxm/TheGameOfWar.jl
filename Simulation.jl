using Base.Test
require("War.jl")

parallel_chunks = 1000
n = 1000
n_sims = n * parallel_chunks
println("# Simulations: $(n_sims)")
println("# Procs: $(nprocs())")

start_time = time()

results = pmap((x)-> simulate(1000), 1:parallel_chunks)

end_time = time() - start_time
println("time: ", end_time)
println()

#println(results)

stats_columns = [
    "no_war_counter",
    "num_wars",
    "num_wars_0",
    "num_wars_1",
    "num_wars_2",
    "num_wars_3",
    "num_wars_4",
    "num_wars_5",
    "num_wars_6",
    "num_wars_7",
    "p1_deck_weight",
    "p1_game_wins",
    "p1_war_defaults",
    "p1_war_wins",
    "p1_wins",
    "p2_deck_weight",
    "p2_game_wins",
    "p2_war_defaults",
    "p2_war_wins",
    "p2_wins",
    "rounds",
    "comparisons",
    "total_times_between_war",
    "p_delta_p_1",
    "p_delta_m_1",

    "p_delta_p_5",
    "p_delta_m_5",

    "p_delta_p_9",
    "p_delta_m_9",

    "p_delta_p_13",
    "p_delta_m_13",

    "p_delta_p_17",
    "p_delta_m_17",

    "p_delta_p_21",
    "p_delta_m_21",

    "p_delta_p_25",
    "p_delta_m_25",

    "p_ace",
    "p_k",
    "p_q",
    "p_j",
    "p_10",
    "p_9",
    "p_8",
    "p_7",
    "p_6",
    "p_5",
    "p_4",
    "p_3",
    "p_2",

]

P = zeros(Float32, 53,53)
stats = Dict{String,Float64}()
[stats[col] = 0 for col = stats_columns]

for row=results
    P += row[2]
    stats_row = row[1]
    for col=stats_columns
        stats[col] += mean(stats_row[col])
    end
end
[stats[col] /= parallel_chunks for col=stats_columns]

P /= stats["comparisons"]
P[1,1] = 1
P[53,53] = 1
println(stats)
#println(P)
println()

println("Avg # rounds: $(stats["rounds"] / n)")
println("Avg # comparisons: $(stats["comparisons"] / n)")
println("Avg time between wars: $(stats["total_times_between_war"] / stats["rounds"])")

println("# rounds: $(stats["rounds"])")
println("# comparisons: $(stats["comparisons"])")

println("Avg # wars: $(stats["num_wars"] / n)")
println("Avg # depth 0 wars: $(stats["num_wars_0"] / n)")
println("Avg # depth 1 wars: $(stats["num_wars_1"] / n)")
println("Avg # depth 2 wars: $(stats["num_wars_2"] / n)")
println("Avg # depth 3 wars: $(stats["num_wars_3"] / n)")
println("Avg # depth 4 wars: $(stats["num_wars_4"] / n)")
println("Avg # depth 5 wars: $(stats["num_wars_5"] / n)")
println("Avg # depth 6 wars: $(stats["num_wars_6"] / n)")
println("Avg # depth 7 wars: $(stats["num_wars_7"] / n)")

println()

println("Avg p1 wins: $(stats["p1_wins"] / n)")
println("Avg p1 war wins: $(stats["p1_war_wins"] / n)")
println("Avg p1 game wins: $(stats["p1_game_wins"] / n)")
println("Avg p1 war defaults: $(stats["p1_war_defaults"] / n)")
println("Avg p1 deck weight: $(stats["p1_deck_weight"] / n)")

println()

println("Avg p2 wins: $(stats["p2_wins"] / n)")
println("Avg p2 war wins: $(stats["p2_war_wins"] / n)")
println("Avg p2 game wins: $(stats["p2_game_wins"] / n)")
println("Avg p2 war defaults: $(stats["p2_war_defaults"] / n)")
println("Avg p2 deck weight: $(stats["p2_deck_weight"] / n)")

println()

p_card_gt = 0.4706251
p_cards_eq = 0.0587498

println("P(C_1 == C_2): $(p_cards_eq)")
println("P(n,n +- 1) = $(p_card_gt)")
println("P(n,n +- 5) = $(p_cards_eq * p_card_gt)")
println("P(n,n +- 9) = $((p_cards_eq)^2 * p_card_gt)")
println("P(n,n +- 13) = $((p_cards_eq)^3 * p_card_gt)")
println("P(n,n +- 17) = $((p_cards_eq)^4 * p_card_gt)")
println("P(n,n +- 21) = $((p_cards_eq)^5 * p_card_gt)")
println("P(n,n +- 25) = $((p_cards_eq)^6 * p_card_gt)")

println()

delta_counts =
    (
     stats["p_delta_p_1"] + stats["p_delta_m_1"] +
     stats["p_delta_p_5"] + stats["p_delta_m_5"] +
     stats["p_delta_p_9"] + stats["p_delta_m_9"] +
     stats["p_delta_p_13"] + stats["p_delta_m_13"] +
     stats["p_delta_p_17"] + stats["p_delta_m_17"] +
     stats["p_delta_p_21"] + stats["p_delta_m_21"] +
     stats["p_delta_p_25"] + stats["p_delta_m_25"]
     )

println("Delta counts: $(delta_counts)")

println("P(n,n + 1): $(stats["p_delta_p_1"] / stats["rounds"])")
println("P(n,n - 1): $(stats["p_delta_m_1"] / stats["rounds"])")

println("P(n,n + 5): $(stats["p_delta_p_5"] / stats["rounds"])")
println("P(n,n - 5): $(stats["p_delta_m_5"] / stats["rounds"])")

println("P(n,n + 9): $(stats["p_delta_p_9"] / stats["rounds"])")
println("P(n,n - 9): $(stats["p_delta_m_9"] / stats["rounds"])")

println("P(n,n + 13): $(stats["p_delta_p_13"] / stats["rounds"])")
println("P(n,n - 13): $(stats["p_delta_m_13"] / stats["rounds"])")

println("P(n,n + 17): $(stats["p_delta_p_17"] / stats["rounds"])")
println("P(n,n - 17): $(stats["p_delta_m_17"] / stats["rounds"])")

println("P(n,n + 21): $(stats["p_delta_p_21"] / stats["rounds"])")
println("P(n,n - 21): $(stats["p_delta_m_21"] / stats["rounds"])")

println("P(n,n + 25): $(stats["p_delta_p_25"] / stats["rounds"])")
println("P(n,n - 25): $(stats["p_delta_m_25"] / stats["rounds"])")

# println()

# println("P(Ace): $(stats["p_ace"] / (stats["comparisons"]*2))")
# println("P(K): $(stats["p_k"] / (stats["comparisons"]*2))")
# println("P(Q): $(stats["p_q"] / (stats["comparisons"]*2))")
# println("P(J): $(stats["p_j"] / (stats["comparisons"]*2))")
# println("P(10): $(stats["p_10"] / (stats["comparisons"]*2))")
# println("P(9): $(stats["p_9"] / (stats["comparisons"]*2))")
# println("P(8): $(stats["p_8"] / (stats["comparisons"]*2))")
# println("P(7): $(stats["p_7"] / (stats["comparisons"]*2))")
# println("P(6): $(stats["p_6"] / (stats["comparisons"]*2))")
# println("P(5): $(stats["p_5"] / (stats["comparisons"]*2))")
# println("P(4): $(stats["p_4"] / (stats["comparisons"]*2))")
# println("P(3): $(stats["p_3"] / (stats["comparisons"]*2))")
# println("P(2): $(stats["p_2"] / (stats["comparisons"]*2))")

# println("P(drawing any card) = 1")
p_any = (stats["p_ace"] + stats["p_k"] + stats["p_q"] + stats["p_j"] +
        stats["p_10"] + stats["p_9"] + stats["p_8"] + stats["p_7"] +
        stats["p_6"] + stats["p_5"] + stats["p_4"] + stats["p_3"] +
        stats["p_2"]) / (stats["comparisons"] * 2)
# println(p_any)
# println(p_any / 13)
@test_approx_eq_eps p_any 1 1e-2
