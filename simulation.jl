require("War.jl")

n = 1000000

start_time = time()

results = pmap((x)-> game()[3], 1:n)

end_time = time() - start_time
println("time: ", end_time)

println(length(results))
println(results[1])

numeric_cols = [
    "wars",
    "time_between_war",
    "rounds",

    "p1_wins",
    "p1_war_wins",
    "p1_game_wins",
    "p1_war_defaults",
    "p1_deck_weight",

    "p2_wins",
    "p2_war_wins",
    "p2_game_wins",
    "p2_war_defaults",
    "p2_deck_weight",
]

df = [[row[col] for col=numeric_cols] for row=results]

avgs = mean(df)
n = length(avgs)

[println("$(numeric_cols[i]): $(avgs[i])") for i=1:n];
