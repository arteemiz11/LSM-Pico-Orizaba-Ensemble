% =========================================================================
% SCRIPT 06: DYNAMISM & MAXIMUM ANNUAL MAPS
% Description: Aggregates the predicted probability TIFFs to calculate 
% maximum annual susceptibility and the temporal standard deviation (dynamism).
% =========================================================================
clear; clc;

% Directories
input_folder = fullfile('..', 'results', 'predicted_maps'); 
output_folder = fullfile('..', 'results', 'final_temporal_maps');

if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Get all predicted TIFFs
files = dir(fullfile(input_folder, '*.tif'));
if isempty(files)
    error('No predicted maps found. Please run Script 05 first.');
end

% Get spatial reference
first_file = fullfile(input_folder, files(1).name);
[~, R_maestra] = readgeoraster(first_file);
[alto, ancho] = size(readgeoraster(first_file));
epsg_code = 32614; 

fprintf('Analyzing %d multi-temporal maps...\n', length(files));
years = [2022, 2023, 2024, 2025];
all_maps_stack = []; 

for y = years
    fprintf('\n--- Processing Year %d ---\n', y);
    year_str = num2str(y);
    files_in_year = {};
    
    % Filter files by year
    for k = 1:length(files)
        if contains(files(k).name, year_str)
            files_in_year{end+1} = fullfile(input_folder, files(k).name);
        end
    end
    
    if isempty(files_in_year)
        continue;
    end
    
    % Build temporal stack for the year
    stack_year = NaN(alto, ancho, length(files_in_year));
    for k = 1:length(files_in_year)
        stack_year(:,:,k) = readgeoraster(files_in_year{k});
    end
    
    % Calculate Maximum Annual Susceptibility
    mapa_maximo_anual = max(stack_year, [], 3);
    
    % Save Annual Map
    out_name = sprintf('Susceptibility_MAX_%d.tif', y);
    geotiffwrite(fullfile(output_folder, out_name), mapa_maximo_anual, R_maestra, 'CoordRefSysCode', epsg_code);
    fprintf('Saved: %s\n', out_name);
    
    % Append to global stack
    if isempty(all_maps_stack)
        all_maps_stack = stack_year;
    else
        all_maps_stack = cat(3, all_maps_stack, stack_year);
    end
end

% --- CALCULATE DYNAMISM MAP ---
fprintf('\nGenerating Temporal Dynamism Map...\n');

if ~isempty(all_maps_stack)
    % Calculate standard deviation across time
    mapa_std = std(all_maps_stack, 0, 3, 'omitnan');
    
    out_name_std = 'Susceptibility_DYNAMISM_StdDev.tif';
    geotiffwrite(fullfile(output_folder, out_name_std), mapa_std, R_maestra, 'CoordRefSysCode', epsg_code);
    fprintf('Saved: %s\n', out_name_std);
    
    % Calculate overall mean
    mapa_mean = mean(all_maps_stack, 3, 'omitnan');
    geotiffwrite(fullfile(output_folder, 'Susceptibility_OVERALL_Mean.tif'), mapa_mean, R_maestra, 'CoordRefSysCode', epsg_code);
else
    fprintf('Could not generate global stack.\n');
end

fprintf('\nAnalysis completed successfully.\n');
