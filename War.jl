using Match

compare(x,y) = @match x,y begin
    _,if x < y end => -1
    _,if x > y end => 1
    _ => 0
end

rank(card) = (card%13)+1
rank_str(card) = [2, 3, 4, 5, 6, 7, 8, 9, 10, "J", "Q", "K", "A"][rank(card)]

suit(card) = floor((card%52)/13)+1
suit_str(card) = ["♠","♥","♦","♣"][suit(card)]

disp(card) = "$(rank_str(card))$(suit_str(card))"

# See Predictability in the Game of War - SCQ, Haqq-Misra 2006
deck_weight(d) = sum([rank(i)-7 for i=d])

function war(d1, d2, stats; pot=Int32[], verbose=false, war_depth=0)
    card1, card2 = pop!(d1), pop!(d2)
    v1, v2 = rank(card1), rank(card2)
    pot = append!(pot, [card1,card2])

    if verbose; println("$(disp(card1)) vs. $(disp(card2))") end
    if v1 > v2
        stats["p1_wins"] += 1
        if war_depth > 0
            stats["p1_war_wins"] += 1
        else
            stats["no_war_counter"] += 1
        end
        append!(d1, pot); shuffle!(d1)
    elseif v1 < v2
        stats["p2_wins"] += 1
        if war_depth > 0
            stats["p2_war_wins"] += 1
        else
            stats["no_war_counter"] += 1
        end
        append!(d2, pot); shuffle!(d2)
    else
        stats["num_wars_$(war_depth)"] += 1
        if war_depth==0
            stats["total_times_between_war"] += stats["no_war_counter"]
            stats["no_war_counter"] == 0
        end

        if verbose; println("War!") end
        if length(d1)>3 && length(d2)>3
            append!(pot, splice!(d1,1:3))
            append!(pot, splice!(d2,1:3))
            war(d1, d2, stats, pot=pot, verbose=verbose, war_depth=war_depth+1)
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
    d1, d2
end

function game(stats)
    stats["no_war_counter"] = 0

    # Setup the initial states
    deck = shuffle!([1:52])
    d1, d2 = deck[1:26], deck[27:52]

    stats["p1_deck_weight"] += deck_weight(d1)
    stats["p2_deck_weight"] += deck_weight(d2)

    # Play till someone runs out of cards
    while length(d1)>0 && length(d2)>0
        stats["rounds"] += 1
        d1,d2 = war(d1,d2,stats)
    end

    if length(d1)>length(d2)
        stats["p1_game_wins"] += 1
    else
        stats["p2_game_wins"] += 1
    end

    d1,d2
end

function simulate(n)
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

    [game(stats) for i = 1:n]

    println("- completed chunk")
    stats
end
