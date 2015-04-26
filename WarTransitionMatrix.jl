function get_transition_matrix()
    P = zeros(Float32, 53, 53)
    for i=1:53
        if i==1 || i==53
            P[i,i] = 1
        else
            for t=0:13
                delta = (4*t + 1)
                if i+delta <= 53
                    P[i,i+delta] = (1/13)^t * (6/13)
                end
                if i-delta >= 1
                    P[i,i-delta] = (1/13)^t * (6/13)
                end
            end

            left_sum = sum(P[i,1:i])
            if left_sum < 0.5
                P[i,1] = 0.5 - sum(P[i,2:i])
            end

            right_sum = sum(P[i,i:end])
            if right_sum < 0.5
                P[i,53] = 0.5 - sum(P[i,i:52])
            end
        end
    end

    P
end

P = get_transition_matrix()

# Verify that all rows sum to 1
@test_approx_eq sum(P,2) ones(Float32, 53, 1)
