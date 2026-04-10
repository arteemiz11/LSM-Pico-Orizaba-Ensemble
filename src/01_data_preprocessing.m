% =========================================================================
% SCRIPT 01: DATA PREPROCESSING AND LABELING
% Description: Loads raw landslide and control data, filters predictors, 
% and generates the final labeled dataset for training.
% =========================================================================

% Define relative paths (assuming the script runs from the src/ folder)
ruta_deslizamientos = fullfile('..', 'data', 'deslizamientos_2013_2022.csv'); 
ruta_no_deslizamientos = fullfile('..', 'data', 'no_deslizamientos_precipitacion.csv');

% Load data tables
tabla_deslizamientos_original = readtable(ruta_deslizamientos);
tabla_no_deslizamientos_original = readtable(ruta_no_deslizamientos);

% Extract predictive columns (features)
match_columnas = {'slope', 'NDVI', 'NDWI', 'DEM', 'Moisture', 'NBR', 'SWIR', 'LAT', 'LON', 'PRE_ANUAL'}; 

tabla_deslizamientos_filtrada = tabla_deslizamientos_original(:, match_columnas);
tabla_no_deslizamientos_filtrada = tabla_no_deslizamientos_original(:, match_columnas);

% Labeling (1 = Landslide, 0 = Control)
tabla_deslizamientos_filtrada.clase = ones(height(tabla_deslizamientos_filtrada), 1);
tabla_no_deslizamientos_filtrada.clase = zeros(height(tabla_no_deslizamientos_filtrada), 1);

% Concatenate final dataset
tabla_entrenamiento_precipitacion = [tabla_deslizamientos_filtrada; tabla_no_deslizamientos_filtrada];

% Save the processed table for training
save(fullfile('..', 'data', 'datos_entrenamiento_limpios.mat'), 'tabla_entrenamiento_precipitacion');

fprintf('============================================================\n');
fprintf('DATOS CARGADOS Y PROCESADOS CORRECTAMENTE\n');
fprintf('============================================================\n');
fprintf('Total de puntos: %d\n', height(tabla_entrenamiento_precipitacion));
fprintf('Deslizamientos (Clase 1): %d\n', sum(tabla_entrenamiento_precipitacion.clase == 1));
fprintf('Estables (Clase 0): %d\n', sum(tabla_entrenamiento_precipitacion.clase == 0));
fprintf('============================================================\n');

disp('Vista previa de los datos:');
disp(head(tabla_entrenamiento_precipitacion));
