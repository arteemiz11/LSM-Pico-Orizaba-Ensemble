% =========================================================================
% SCRIPT 05: SPATIAL INFERENCE & MAP GENERATION
% Description: Applies the trained AdaBoost model to multi-temporal TIFF 
% stacks to generate probability maps for the 2022-2025 period.
% NOTE: Requires raw Landsat/SRTM TIFFs (not included due to size limits).
% =========================================================================
clear; clc;

% Directories
dir_models = fullfile('..', 'models');
dir_raw_tiffs = fullfile('..', 'data', 'raw_tiffs'); % Path for external raw data
output_folder = fullfile('..', 'results', 'predicted_maps');

if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% 1. Load Trained Model
load(fullfile(dir_models, 'entrenamiento_boostedtrees1.mat'), 'boostedtrees');

% 2. Static Files (Topography)
dem_file = fullfile(dir_raw_tiffs, 'static', 'DEM_UTM.tif');
slope_file = fullfile(dir_raw_tiffs, 'static', 'Slope_UTM.tif');

% [NOTE FOR GITHUB USERS] 
% The 'manifest' cell array contains the file paths for the spectral and 
% precipitation TIFFs. To reproduce this locally, download the required 
% TIFFs from Google Earth Engine and update the paths below.

manifest = {
    % Example entry format: { 'path_to_spectral_indices.tif', 'path_to_precipitation.tif' }
    fullfile(dir_raw_tiffs, '2023', 'Indices_RGB_2023-03-06.tif'), fullfile(dir_raw_tiffs, 'precip', 'PRE_ANUAL_2023.tif');
    % ... (All 49-51 image pairs are sequentially loaded here) ...
};

num_imagenes = size(manifest, 1);
fprintf('Loading %d images for spatial inference...\n', num_imagenes);

% Proceed only if files exist locally (Safety check for GitHub repo)
if ~exist(dem_file, 'file') || ~exist(slope_file, 'file')
    error('Raw TIFF files not found. Please read the README to obtain the spatial data.');
end

% 3. Load Topographic Variables
[dem_data, R_maestra] = readgeoraster(dem_file);
[slope_data] = readgeoraster(slope_file);
[alto, ancho] = size(dem_data);

% 4. Processing Loop
for i = 1:num_imagenes
    spectral_file_path = manifest{i, 1};
    precip_file_path = manifest{i, 2};
    
    [~, spectral_name, ~] = fileparts(spectral_file_path);
    fprintf('\n--- Processing image %d/%d: %s ---\n', i, num_imagenes, spectral_name);

    % Load dynamic data
    [A_spectral] = readgeoraster(spectral_file_path);
    [precip_data] = readgeoraster(precip_file_path);

    % Stack predictors (8 bands)
    A_completo = NaN(alto, ancho, 8); 
    A_completo(:,:,1) = slope_data;         
    A_completo(:,:,2) = A_spectral(:,:,1);  % NDVI
    A_completo(:,:,3) = A_spectral(:,:,3);  % NDWI
    A_completo(:,:,4) = dem_data;           
    A_completo(:,:,5) = A_spectral(:,:,5);  % Moisture
    A_completo(:,:,6) = A_spectral(:,:,2);  % NBR
    A_completo(:,:,7) = A_spectral(:,:,4);  % SWIR
    A_completo(:,:,8) = precip_data;        

    % Mask NaNs
    mask_nan = any(isnan(A_completo), 3);
    mask_valid = ~mask_nan;
    num_valid_pixels = sum(mask_valid, 'all');
    
    if num_valid_pixels == 0
        continue;
    end

    % Prepare data for prediction
    A_flat = reshape(A_completo, [alto * ancho, 8]);
    X_map_valid = A_flat(mask_valid(:), :);
    
    predictor_names = {'slope', 'NDVI', 'NDWI', 'DEM', 'Moisture', 'NBR', 'SWIR', 'PRE_ANUAL'};
    X_map_table = array2table(X_map_valid, 'VariableNames', predictor_names);

    % Predict
    [~, scores_validos] = boostedtrees.predictFcn(X_map_table);
    
    % Calculate Probability (Sigmoid if scores are raw, otherwise extract col 2)
    scores_deslizamiento = scores_validos(:, 2); 
    probabilidades_deslizamiento = 1 ./ (1 + exp(-scores_deslizamiento));

    % Reconstruct Spatial Map
    mapa_probabilidad = NaN(alto, ancho);
    mapa_probabilidad(mask_valid) = probabilidades_deslizamiento;
    
    % Export GeoTIFF
    output_filename = fullfile(output_folder, sprintf('Susceptibility_Prob_%s.tif', spectral_name)); 
    epsg_code = 32614; % UTM Zone 14N
    
    geotiffwrite(output_filename, mapa_probabilidad, R_maestra, 'CoordRefSysCode', epsg_code);
    fprintf('Map saved: %s\n', output_filename);
end
fprintf('\n--- Dynamic Inference Process Completed ---\n');
