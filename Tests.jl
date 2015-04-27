using Base.Test
require("War.jl")

@test compare(1,2) == -1
@test compare(1,1) == 0
@test compare(2,1) == 1

@test deck_weight(1:52) == 0

stats = {
    "num_wars_0" => 0,
    "num_wars_1" => 0,
    "num_wars_2" => 0,
    "num_wars_3" => 0,
    "num_wars_4" => 0,
    "num_wars_5" => 0,

    "no_war_counter" => 0,
    "total_times_between_war" => 0,
    "rounds" => 0,

    "p1_wins" => 0,
    "p1_war_wins" => 0,
    "p1_game_wins" => 0,
    "p1_war_defaults" => 0,
    "p1_deck_weight" => 0,

    "p2_wins" => 0,
    "p2_war_wins" => 0,
    "p2_game_wins" => 0,
    "p2_war_defaults" => 0,
    "p2_deck_weight" => 0,
}

d1, d2 = war([2,2,2,7,1], [2,2,2,6,1], stats)

@test length(d1) == 10
@test length(d2) == 0

d1,d2 = game(stats)

@test (length(d1)==0 && length(d2)==52) || (length(d1)==52 && length(d2)==0)
