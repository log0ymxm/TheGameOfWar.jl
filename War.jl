using Match
using Base.Test

compare(x,y) = @match x,y begin
    _,if x < y end => -1
    _,if x > y end => 1
    _ => 0
end

@test compare(1,2) == -1
@test compare(1,1) == 0
@test compare(2,1) == 1

rank(card) = (card%13)+1
suit(card) = floor((card%52)/13)+1

suit_str(card) = ["♠","♥","♦","♣"][suit(card)]
rank_str(card) = [2, 3, 4, 5, 6, 7, 8, 9, 10, "J", "Q", "K", "A"][rank(card)]

disp(card) = "$(rank_str(card))$(suit_str(card))"

# See Predictability in the Game of War - SCQ, Haqq-Misra 2006
deck_weight(d) = sum([rank(i)-7 for i=d])

@test deck_weight(1:52) == 0

function war(d1, d2; pot=Int32[], verbose=false, stats=Dict{String,Any}(), war_state=false, no_war_counter=0)
    card1, card2 = pop!(d1), pop!(d2)
    v1, v2 = rank(card1), rank(card2)
    pot = append!(pot, [card1,card2])

    if verbose; println("$(disp(card1)) vs. $(disp(card2))") end
    @match compare(v1, v2) begin
        1  => begin
            stats["p1_wins"] += 1
            if war_state
                stats["p1_war_wins"] += 1
            else
                no_war_counter += 1
            end
            append!(d1, pot); shuffle!(d1)
        end
        -1 => begin
            stats["p2_wins"] += 1
            if war_state
                stats["p2_war_wins"] += 1
            else
                no_war_counter += 1
            end
            append!(d2, pot); shuffle!(d2)
        end
        0  => begin
            stats["wars"] += 1
            push!(stats["times_between_war"], no_war_counter)
            no_war_counter = 0

            if verbose; println("War!") end
            if length(d1)>3 && length(d2)>3
                append!(pot, splice!(d1,1:3))
                append!(pot, splice!(d2,1:3))
                war(d1, d2, pot=pot, verbose=verbose, stats=stats, war_state=true, no_war_counter=no_war_counter)
            elseif length(d1)>3 # end of game conditions
                stats["p1_wins"] += 1
                stats["p1_war_defaults"] += 1
                append!(pot, splice!(d2, 1:length(d2)))
                append!(d1, pot)
            elseif length(d2)>3
                stats["p2_wins"] += 1
                stats["p2_war_defaults"] += 1
                append!(pot, splice!(d1, 1:length(d1)))
                append!(d2, pot)
            end
        end
    end
    d1, d2, no_war_counter
end

stats = {
    "rounds"=> 0,

    "wars"=> 0,
    "times_between_war"=> Int32[],

    "p1_wins"=> 0,
    "p1_war_wins"=> 0,
    "p1_war_defaults"=> 0,
    "p1_game_wins"=> 0,

    "p2_wins"=> 0,
    "p2_war_wins"=> 0,
    "p2_war_defaults"=> 0,
    "p2_game_wins"=> 0
}

d1, d2 = war([2,2,2,7,1], [2,2,2,6,1], stats=stats)

@test length(d1) == 10
@test length(d2) == 0

function game()
    stats = {
        "rounds"=> 0,

        "wars"=> 0,
        "times_between_war"=> Int32[],

        "p1_wins"=> 0,
        "p1_war_wins"=> 0,
        "p1_war_defaults"=> 0,
        "p1_game_wins"=> 0,

        "p2_wins"=> 0,
        "p2_war_wins"=> 0,
        "p2_war_defaults"=> 0,
        "p2_game_wins"=> 0
    }
    no_war_counter = 0

    # Setup the initial states
    deck = shuffle!([1:52])
    d1, d2 = deck[1:26], deck[27:52]

    stats["p1_deck_weight"] = deck_weight(d1)
    stats["p2_deck_weight"] = deck_weight(d2)

    # Play till someone runs out of cards
    while length(d1)>0 && length(d2)>0
        stats["rounds"] += 1

        d1, d2, no_war_counter = war(d1,d2, stats=stats, no_war_counter=no_war_counter)

    end

    if length(d1)>length(d2)
        stats["p1_game_wins"] += 1
    else
        stats["p2_game_wins"] += 1
    end

    if stats["wars"] > 0
        stats["time_between_war"] = float(sum(stats["times_between_war"])) / stats["wars"]
    else
        stats["time_between_war"] = float(sum(stats["times_between_war"]))
    end

    d1,d2,stats
end

d1,d2,stats = game()

@test (length(d1)==0 && length(d2)==52) || (length(d1)==52 && length(d2)==0)
