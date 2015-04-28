using Base.Test
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

function war(d1, d2, stats, P; i=nothing, pot=Int32[], verbose=false, war_depth=0)

    stats["comparisons"] += 1

    # if i == nothing
    #     i = length(d1) + 1 # Index in P of the next transition
    # end

    # Shuffle & split the cards again. This doesn't model
    # how the game actually plays, but simulates values closer
    # to what we estimate with the transition matrix.
    l1 = length(d1)
    l2 = length(d2)
    deck = shuffle!([1:52])
    d1, d2, pot = deck[1:l1], deck[l1+1:l1+l2], deck[l1+l2+1:52]
    @test l1 == length(d1)
    @test l2 == length(d2)

    card1, card2 = pop!(d1), pop!(d2)
    v1, v2 = rank(card1), rank(card2)
    pot = append!(pot, [card1,card2])

    if v1 == 13; stats["p_ace"] += 1 end
    if v1 == 12; stats["p_k"] += 1 end
    if v1 == 11; stats["p_q"] += 1 end
    if v1 == 10; stats["p_j"] += 1 end
    if v1 == 9; stats["p_10"] += 1 end
    if v1 == 8; stats["p_9"] += 1 end
    if v1 == 7; stats["p_8"] += 1 end
    if v1 == 6; stats["p_7"] += 1 end
    if v1 == 5; stats["p_6"] += 1 end
    if v1 == 4; stats["p_5"] += 1 end
    if v1 == 3; stats["p_4"] += 1 end
    if v1 == 2; stats["p_3"] += 1 end
    if v1 == 1; stats["p_2"] += 1 end

    if v2 == 13; stats["p_ace"] += 1 end
    if v2 == 12; stats["p_k"] += 1 end
    if v2 == 11; stats["p_q"] += 1 end
    if v2 == 10; stats["p_j"] += 1 end
    if v2 == 9; stats["p_10"] += 1 end
    if v2 == 8; stats["p_9"] += 1 end
    if v2 == 7; stats["p_8"] += 1 end
    if v2 == 6; stats["p_7"] += 1 end
    if v2 == 5; stats["p_6"] += 1 end
    if v2 == 4; stats["p_5"] += 1 end
    if v2 == 3; stats["p_4"] += 1 end
    if v2 == 2; stats["p_3"] += 1 end
    if v2 == 1; stats["p_2"] += 1 end

    if verbose; println("$(disp(card1)) vs. $(disp(card2))") end
    if v1 > v2
        stats["p1_wins"] += 1
        if war_depth > 0
            stats["p1_war_wins"] += 1
        else
            stats["no_war_counter"] += 1
        end
        if length(pot)==2;
            #P[i,i+1] += 1
            stats["p_delta_p_1"] += 1
        elseif length(pot)==10;
            #P[i,i+5] += 1
            stats["p_delta_p_5"] += 1
        elseif length(pot)==18;
            #P[i,i+9] += 1
            stats["p_delta_p_9"] += 1
        elseif length(pot)==26;
            #P[i,i+13] += 1
            stats["p_delta_p_13"] += 1
        elseif length(pot)==34;
            #P[i,i+17] += 1
            stats["p_delta_p_17"] += 1
        elseif length(pot)==42;
            #P[i,i+21] += 1
            stats["p_delta_p_21"] += 1
        elseif length(pot)==50;
            #P[i,i+25] += 1
            stats["p_delta_p_25"] += 1
        end
        #shuffle!(pot)
        append!(d1, pot)
        #shuffle!(d1)
    elseif v1 < v2
        stats["p2_wins"] += 1
        if war_depth > 0
            stats["p2_war_wins"] += 1
        else
            stats["no_war_counter"] += 1
        end
        if length(pot)==2;
            #P[i,i-1] += 1
            stats["p_delta_m_1"] += 1
        elseif length(pot)==10;
            #P[i,i-5] += 1
            stats["p_delta_m_5"] += 1
        elseif length(pot)==18;
            #P[i,i-9] += 1
            stats["p_delta_m_9"] += 1
        elseif length(pot)==26;
            #P[i,i-13] += 1
            stats["p_delta_m_13"] += 1
        elseif length(pot)==34;
            #P[i,i-17] += 1
            stats["p_delta_m_17"] += 1
        elseif length(pot)==42;
            #P[i,i-21] += 1
            stats["p_delta_m_21"] += 1
        elseif length(pot)==50;
            #P[i,i-25] += 1
            stats["p_delta_m_25"] += 1
        end
        #shuffle!(pot)
        append!(d2, pot)
        #shuffle!(d2)
    else
        stats["num_wars"] += 1
        stats["num_wars_$(war_depth)"] += 1
        stats["total_times_between_war"] += stats["no_war_counter"]
        stats["no_war_counter"] == 0

        if verbose; println("War!") end
        if length(d1)>3 && length(d2)>3
            l1 = length(d1)
            l2 = length(d2)
            append!(pot, splice!(d1,l1-2:l1))
            append!(pot, splice!(d2,l2-2:l2))

            shuffle!(pot)
            war(d1, d2, stats, P, i=i, pot=pot, verbose=verbose, war_depth=war_depth+1)
        elseif length(d1)>3 # end of game conditions
            #P[i,53] += 1
            stats["p1_wins"] += 1
            stats["p1_war_wins"] += 1
            stats["p1_war_defaults"] += 1
            append!(pot, splice!(d2, 1:length(d2)))
            append!(d1, pot)
        elseif length(d2)>3
            #P[i,1] += 1
            stats["p2_wins"] += 1
            stats["p2_war_wins"] += 1
            stats["p2_war_defaults"] += 1
            append!(pot, splice!(d1, 1:length(d1)))
            append!(d2, pot)
        end
    end
    d1, d2
end

function game(stats, P)
    stats["no_war_counter"] = 0

    # Setup the initial states
    deck = shuffle!([1:52])
    d1, d2 = deck[1:26], deck[27:52]

    stats["p1_deck_weight"] += deck_weight(d1)
    stats["p2_deck_weight"] += deck_weight(d2)

    # Play till someone runs out of cards
    while length(d1)>0 && length(d2)>0
        d1,d2 = war(d1,d2,stats,P)
        stats["rounds"] += 1
    end

    winner = length(d1)>length(d2) ? "p1" : "p2"
    stats["$(winner)_game_wins"] += 1

    d1,d2
end

function simulate(n)
    stats = {
        "num_wars" => 0,
        "num_wars_0" => 0,
        "num_wars_1" => 0,
        "num_wars_2" => 0,
        "num_wars_3" => 0,
        "num_wars_4" => 0,
        "num_wars_5" => 0,
        "num_wars_6" => 0,
        "num_wars_7" => 0,

        "no_war_counter" => 0,
        "total_times_between_war" => 0,
        "rounds" => 0,
        "comparisons" => 0,

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

        "p_delta_p_1" => 0,
        "p_delta_m_1" => 0,
        "p_delta_p_5" => 0,
        "p_delta_m_5" => 0,
        "p_delta_p_9" => 0,
        "p_delta_m_9" => 0,
        "p_delta_p_13" => 0,
        "p_delta_m_13" => 0,
        "p_delta_p_17" => 0,
        "p_delta_m_17" => 0,
        "p_delta_p_21" => 0,
        "p_delta_m_21" => 0,
        "p_delta_p_25" => 0,
        "p_delta_m_25" => 0,

        "p_ace" => 0,
        "p_k" => 0,
        "p_q" => 0,
        "p_j" => 0,
        "p_10" => 0,
        "p_9" => 0,
        "p_8" => 0,
        "p_7" => 0,
        "p_6" => 0,
        "p_5" => 0,
        "p_4" => 0,
        "p_3" => 0,
        "p_2" => 0,

    }

    P = zeros(53,53)

    [game(stats, P) for i = 1:n]

    #println("- completed chunk")
    stats, P
end
