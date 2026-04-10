% =========================================================================
% SCRIPT 03: ROC CURVES GENERATION
% Description: Calculates probabilities via 10-fold CV, computes ROC-AUC
% for each model, and exports a high-quality EPS figure for publication.
% =========================================================================
clear all; clc;

% Define relative paths
dir_data = fullfile('..', 'data');
dir_models = fullfile('..', 'models');
dir_results = fullfile('..', 'results');

% Create results directory if it doesn't exist
if ~exist(dir_results, 'dir')
    mkdir(dir_results);
end

% 1. LOAD DATA
archivo_datos = fullfile(dir_data, 'datos_entrenamiento_limpios.mat');
load(archivo_datos, 'tabla_entrenamiento_precipitacion');
Y_real = tabla_entrenamiento_precipitacion.clase;
clase_positiva = max(unique(Y_real)); 

% 2. MODEL CONFIGURATION
modelos = struct();
modelos(1).archivo = 'entrenamiento_boostedtrees1.mat';
modelos(1).nombre_var = 'boostedtrees'; 
modelos(1).etiqueta = 'AdaBoost';
modelos(1).estilo = 'k-';  

modelos(2).archivo = 'entrenamiento_RF.mat';
modelos(2).nombre_var = 'entrenamientoRF'; 
modelos(2).etiqueta = 'Random Forest';
modelos(2).estilo = 'k--'; 

modelos(3).archivo = 'entrenamiento_knn.mat'; 
modelos(3).nombre_var = 'entrenamiento_knn'; 
modelos(3).etiqueta = 'k-NN';
modelos(3).estilo = 'k:';  

% 3. FIGURE SETUP
figure('Color', 'w', 'Position', [100, 100, 600, 500]);
hold on; grid on;
textos_leyenda = {};

fprintf('Generating ROC curves. Please wait (this takes a couple of minutes)...\n');

% 4. CALCULATION LOOP
for i = 1:length(modelos)
    fprintf('Processing %s...\n', modelos(i).etiqueta);
    
    datos_modelo = load(fullfile(dir_models, modelos(i).archivo));
    objeto_modelo = datos_modelo.(modelos(i).nombre_var);
    
    if isstruct(objeto_modelo) && isfield(objeto_modelo, 'ClassificationEnsemble')
        Mdl = objeto_modelo.ClassificationEnsemble;
    elseif isstruct(objeto_modelo) && isfield(objeto_modelo, 'ClassificationKNN')
        Mdl = objeto_modelo.ClassificationKNN;
    else
        Mdl = objeto_modelo;
    end
    
    CVMdl = crossval(Mdl, 'KFold', 10);
    [~, scores] = kfoldPredict(CVMdl);
    [X, Y, ~, AUC] = perfcurve(Y_real, scores(:,2), clase_positiva);
    
    plot(X, Y, modelos(i).estilo, 'LineWidth', 2);
    textos_leyenda{end+1} = sprintf('%s (AUC = %.3f)', modelos(i).etiqueta, AUC);
end

% 5. PLOT AESTHETICS (Paper Style)
plot([0 1], [0 1], 'k-.', 'LineWidth', 1); 
textos_leyenda{end+1} = 'Random Guess';

legend(textos_leyenda, 'Location', 'southeast', 'FontSize', 10);
xlabel('False Positive Rate (1 - Specificity)', 'FontWeight', 'bold');
ylabel('True Positive Rate (Sensitivity)', 'FontWeight', 'bold');
title('ROC Curve Comparison (10-fold CV)', 'FontWeight', 'bold');

ax = gca;
ax.FontSize = 10;
ax.Box = 'on';

% 6. AUTOMATIC EXPORT TO EPS
nombre_salida = fullfile(dir_results, 'roc_curve.eps');
exportgraphics(gcf, nombre_salida, 'ContentType', 'vector');

fprintf('\nDone! Graph successfully saved as EPS in:\n%s\n', nombre_salida);
