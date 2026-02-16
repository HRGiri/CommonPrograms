function y = applySALPA(signal, timeVals, N)
%APPLYSALPA Summary of this function goes here
%   Detailed explanation goes here
    
    % Window parameters
    if isempty(N) 
        N = 100;    % Default value if not provided, (2N + 1) = 201
    end
    window_len = 2*N + 1;
    nc = N + 1; % central point index in chunk
    
    % Constants
    n_mat = zeros(7, window_len);
    for k = 0:6
        n_mat(k+1, :) = (-N:N).^k;
    end
    
    T = n_mat * ones(window_len,1);

    S = zeros(4,4);
    for k = 0:3
        for l = 0:3
            S(k+1, l+1) = T(k+l+1);
        end
    end
    S_inv = inv(S);

    n_mat = n_mat(1:4, :);
        
    STIM_START = -0.03;
    STIM_END = 0.07;    
    
    % Subtract the fitted line from the first signal in x
    signal_indices = timeVals > STIM_END;
    baseline_indices = timeVals < STIM_START;
    
    signal(timeVals >= STIM_START & timeVals <= STIM_END) = 0;    
    
    y = signal;
    
    % Baseline
    i = find(baseline_indices, 1);
    idx = i:(i + N);
    time_window = timeVals(idx);
    signal_window = signal(idx);
    % Fit 3rd degree polynomial to the chunk
    p = polyfit(time_window, signal_window, 3);
    % Evaluate at the central point
    fitted_chunk = polyval(p, time_window);
    % Subtract fitted value at central point
    y(idx) = signal(idx) - fitted_chunk;
    
    for i = 1:(find(baseline_indices, 1, "last") - window_len + 1)
        % Naive approach
        % idx = i:(i + window_len - 1);
        % time_window = timeVals(idx);
        % signal_window = signal(idx);
        % % Fit 3rd degree polynomial to the chunk
        % p = polyfit(time_window, signal_window, 3);
        % % Evaluate at the central point
        % fitted_val = polyval(p, time_window(nc));
        % % Subtract fitted value at central point
        % y(idx(nc)) = signal(idx(nc)) - fitted_val;

        % Close form approach
        idx = i:(i + window_len - 1);
        W = n_mat * signal(idx)';
        alpha_0 = S_inv(1,:) * W;
        % Cleaned signal value
        y(idx(nc)) = signal(idx(nc)) - alpha_0;
    end
    
    % Baseline end
    i = find(baseline_indices, 1, "last") - window_len + 1;
    idx = i:(i + window_len - 1);
    time_window = timeVals(idx);
    signal_window = signal(idx);
    % Fit 3rd degree polynomial to the chunk
    p = polyfit(time_window, signal_window, 3);
    % Evaluate at the central point
    fitted_chunk = polyval(p, time_window);
    % Subtract fitted value at central point
    y(idx) = signal(idx) - fitted_chunk;
    
    
    % Signal right after depegging
    i = find(signal_indices, 1);
    idx = i:(i + N);
    time_window = timeVals(idx);
    signal_window = signal(idx);
    % Fit 3rd degree polynomial to the chunk
    p = polyfit(time_window, signal_window, 3);
    % Evaluate at the central point
    fitted_chunk = polyval(p, time_window);
    % Subtract fitted value at central point
    y(idx) = signal(idx) - fitted_chunk;
    
    for i = find(signal_indices, 1):(length(signal) - window_len + 1)
        % idx = i:(i + window_len - 1);
        % time_window = timeVals(idx);
        % signal_window = signal(idx);
        % % Fit 3rd degree polynomial to the chunk
        % p = polyfit(time_window, signal_window, 3);
        % % Evaluate at the central point
        % fitted_val = polyval(p, time_window(nc));
        % % Subtract fitted value at central point
        % y(idx(nc)) = signal(idx(nc)) - fitted_val;

        % Close form approach
        idx = i:(i + window_len - 1);
        W = n_mat * signal(idx)';
        alpha_0 = S_inv(1,:) * W;
        % Cleaned signal value
        y(idx(nc)) = signal(idx(nc)) - alpha_0;
    end
    
    % Signal at the end
    i = length(signal) - window_len + 1;
    idx = i:(i + window_len - 1);
    time_window = timeVals(idx);
    signal_window = signal(idx);
    % Fit 3rd degree polynomial to the chunk
    p = polyfit(time_window, signal_window, 3);
    % Evaluate at the central point
    fitted_chunk = polyval(p, time_window);
    % Subtract fitted value at central point
    y(idx) = signal(idx) - fitted_chunk;
   
end

