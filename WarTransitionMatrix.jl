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

function augmented_matrix(X)
    # Note: this function is not general enough for any
    # stochastic matrix. It assumes the locations of the
    # absorbing states, and the size of the matrix.

    # Move the absorbing states to top left
    P = hcat(X[:,1], X[:,53], X[:,2:52])
    P = vcat(P[1,:], P[53,:], P[2:52,:])

    P_tilde = P[1:2,1:2]
    S = P[3:53,1:2]
    Q = P[3:53,3:53]
    P, P_tilde, S, Q
end

P_aug, P_tilde, S, Q = augmented_matrix(P)

# Assert \tilde{P} has both absorbing states
@test_approx_eq P_tilde eye(Float32, 2)
