% ***********************************************************************
% *         Potential and Pitfalls of Multi-Armed Bandits for           *
% *               Decentralized Spatial Reuse in WLANs                  *
% *                                                                     *
% * Submission to Journal on Network and Computer Applications          *
% * Authors:                                                            *
% *   - Francesc Wilhelmi (francisco.wilhelmi@upf.edu)                  *
% *   - Sergio Barrachina-Muñoz  (sergio.barrachina@upf.edu)            *
% *   - Boris Bellalta (boris.bellalta@upf.edu)                         *
% *   - Cristina Cano (ccanobs@uoc.edu)                                 *
% *   - Anders Jonsson (anders.jonsson@upf.edu)                         *
% *   - Gergely Neu (gergely.neu@upf.edu)                               *
% * Copyright (C) 2017-2022, and GNU GPLd, by Francesc Wilhelmi         *
% * Repository:                                                         *
% *  https://github.com/fwilhelmi/potential_pitfalls_mabs_spatial_reuse *
% ***********************************************************************


function wlans = generate_wlan_from_file(filename, draw_map, ...
    random_initial_conf, actions_channel, actions_cca, actions_tpc)
% GenerateNetwork3D - Generates a 3D network 
%   OUTPUT: 
%       * wlan - contains information of each WLAN in the map. For instance,
%       wlan(1) corresponds to the first one, so that it has unique
%       parameters (x,y,z,BW,CCA,etc.)
%   INPUT: 
%       * N_WLANs: number of WLANs on the studied environment
%       * NumChannels: number of available channels
%       * topology: topology of the network ('ring', 'line' or 'grid')
%       * stas_position: way STAs are placed (1 - "random", 2 - "safe" or 3 - "exposed")
%       * printMap: flag for calling DrawNetwork3D at the end

    load('constants_sfctmn_framework.mat');  % Load constants into workspace
    load('configuration_system.mat');  % Load constants into workspace

    disp('Processing input CSV...')
    input_data = load(filename);            
    
    % Generate wlan structures
    wlans = [];                                      % Array of structures containning wlans info
    num_wlans = length(input_data(:,1));            % Number of WLANs (APs)

    for w = 1 : num_wlans

        wlans(w).code = input_data(w, INPUT_FIELD_IX_CODE);          % Pick WLAN code
        if random_initial_conf
            wlans(w).primary = datasample(actions_channel, 1);    % Pick primary channel
            wlans(w).tx_power = datasample(actions_tpc, 1);       % Pick transmission power
            wlans(w).cca = datasample(actions_cca, 1);            % Pick CCA level
        else
            wlans(w).primary = input_data(w,INPUT_FIELD_PRIMARY_CH);    % Pick primary channel
            wlans(w).tx_power = input_data(w,INPUT_FIELD_TX_POWER);     % Pick transmission power
            wlans(w).cca = input_data(w,INPUT_FIELD_CCA);               % Pick CCA level
        end
        wlans(w).range = [input_data(w,INPUT_FIELD_LEFT_CH) input_data(w,INPUT_FIELD_RIGHT_CH)];  % pick range
       % wlans(w).range = [wlans(w).primary wlans(w).primary];  % pick range

        % Position AP
        wlans(w).x = input_data(w,INPUT_FIELD_POS_AP_X);
        wlans(w).y = input_data(w,INPUT_FIELD_POS_AP_Y);
        wlans(w).z = input_data(w,INPUT_FIELD_POS_AP_Z);
        wlans(w).position_ap = [wlans(w).x  wlans(w).y  wlans(w).z];
        % Position STA
        wlans(w).xn = input_data(w,INPUT_FIELD_POS_STA_X);
        wlans(w).yn = input_data(w,INPUT_FIELD_POS_STA_Y);
        wlans(w).zn = input_data(w,INPUT_FIELD_POS_STA_Z);
        wlans(w).position_sta = [wlans(w).xn  wlans(w).yn  wlans(w).zn];

        wlans(w).lambda = input_data(w,INPUT_FIELD_LAMBDA);         % Pick lambda
        wlans(w).bandwidth = BANDWITDH_PER_CHANNEL;

        wlans(w).states = [];   % Instantiate states for later use          
        wlans(w).widths = [];   % Instantiate acceptable widhts item for later use
                
        wlans(w).legacy = input_data(w,INPUT_FIELD_LEGACY);
        
        if length(input_data(1,:)) == 16
            wlans(w).activation_iteration = input_data(w, INPUT_FIELD_ACTIVATION_ITERATION);
        else
            wlans(w).activation_iteration = 0;
        end
        
        wlans(w).activated = false;

    end
  
    % COMPUTE THE UPPER BOUND THROUGHPUT PER WLAN
%     upper_bound_tpt = compute_throughput_isolation(wlans);    
%     for w = 1 : num_wlans
%         wlans(w).upper_bound = upper_bound_tpt(w);
%     end

    if draw_map, draw_network_3D(wlans); end

end