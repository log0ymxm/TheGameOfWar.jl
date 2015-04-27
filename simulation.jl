using Base.time
require("War.jl")

parallel_chunks = 100
n = 10000
println("# Simulations: $(n * parallel_chunks)")
println("# Procs: $(nprocs())")

start_time = time()

results = pmap((x)-> simulate(10000), 1:parallel_chunks)

end_time = time() - start_time
println("time: ", end_time)

#println(results)

stats_columns = [
    "no_war_counter",
    "num_wars_0",
    "num_wars_1",
    "num_wars_2",
    "num_wars_3",
    "num_wars_4",
    "num_wars_5",
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
    "total_times_between_war",
]

stats = Dict{String,Float64}()
for col=stats_columns
    stats[col] = mean([row[col] for row=results])
end
#println(stats)

println("Avg depth 0 wars: $(stats["num_wars_0"] / n)")
println("Avg depth 1 wars: $(stats["num_wars_1"] / n)")
println("Avg depth 2 wars: $(stats["num_wars_2"] / n)")
println("Avg depth 3 wars: $(stats["num_wars_3"] / n)")
println("Avg depth 4 wars: $(stats["num_wars_4"] / n)")
println("Avg depth 5 wars: $(stats["num_wars_5"] / n)")
println("Avg time between wars: $(stats["total_times_between_war"] / stats["rounds"])")
println("Avg # rounds: $(stats["rounds"] / n)")

println("Avg p1 wins: $(stats["p1_wins"] / n)")
println("Avg p1 war wins: $(stats["p1_war_wins"] / n)")
println("Avg p1 game wins: $(stats["p1_game_wins"] / n)")
println("Avg p1 war defaults: $(stats["p1_war_defaults"] / n)")
println("Avg p1 deck weight: $(stats["p1_deck_weight"] / n)")

println("Avg p2 wins: $(stats["p2_wins"] / n)")
println("Avg p2 war wins: $(stats["p2_war_wins"] / n)")
println("Avg p2 game wins: $(stats["p2_game_wins"] / n)")
println("Avg p2 war defaults: $(stats["p2_war_defaults"] / n)")
println("Avg p2 deck weight: $(stats["p2_deck_weight"] / n)")

# Garibaldi ➜  war-game-simulation git:(master) ✗ julia -p 7 simulation.jl
# # Simulations: 1000000
# time: 169.642746925354
# Avg depth 0 wars: 13.832435999999998
# Avg depth 1 wars: 0.8019890000000001
# Avg depth 2 wars: 0.044785000000000005
# Avg depth 3 wars: 0.0023710000000000003
# Avg depth 4 wars: 0.00010700000000000001
# Avg depth 5 wars: 6.0e-6
# Avg time between wars: 10.685712366606559
# Avg # rounds: 234.230877
# Avg p1 wins: 117.11701200000002
# Avg p1 war wins: 6.660788
# Avg p1 game wins: 0.49996199999999996
# Avg p1 war defaults: 0.254423
# Avg p1 deck weight: -0.023059
# Avg p2 wins: 117.11386499999999
# Avg p2 war wins: 6.662747
# Avg p2 game wins: 0.500038
# Avg p2 war defaults: 0.25447800000000004
# Avg p2 deck weight: 0.023059
