% =========================================================================
% SCRIPT 02: CROSS-VALIDATION AND METRICS
% Description: Loads pre-trained ensemble models, performs 10-fold cross
% validation, and calculates Accuracy, Precision, Recall, and F1-Score.
% =========================================================================
clear all; clc;

% Define relative paths based on repository structure
dir_data = fullfile('..', 'data');
dir_models = fullfile('..', 'models');

% Load processed training data
archivo_datos = fullfile(dir_data, 'datos_entrenamiento_limpios.mat');
if exist(archivo_datos, 'file')
    load(archivo_datos, 'tabla_entrenamiento_precipitacion');
    fprintf('Data loaded successfully.\n');
else
    error('File datos_entrenamiento_limpios.mat not found in /data folder.');
end

% Define Ground Truth (Y_real)
Y_real = tabla_entrenamiento_precipitacion.clase;

% Define Models Array
modelos = struct();
modelos(1).archivo = 'entrenamiento_boostedtrees1.mat';
modelos(1).nombre_var = 'boostedtrees'; 
modelos(1).etiqueta = 'AdaBoost';

modelos(2).archivo = 'entrenamiento_RF.mat';
modelos(2).nombre_var = 'entrenamientoRF'; 
modelos(2).etiqueta = 'Random Forest';

modelos(3).archivo = 'entrenamiento_knn.mat'; 
modelos(3).nombre_var = 'entrenamiento_knn'; 
modelos(3).etiqueta = 'k-NN';

fprintf('\n==================================================\n');
fprintf('       10-FOLD CROSS VALIDATION RESULTS           \n');
fprintf('==================================================\n');

for i = 1:length(modelos)
    nombre_modelo = modelos(i).etiqueta;
    archivo_modelo = fullfile(dir_models, modelos(i).archivo);
    
    if ~exist(archivo_modelo, 'file')
        fprintf('Warning: File %s not found. Skipping.\n', modelos(i).archivo);
        continue;
    end
    
    datos_modelo = load(archivo_modelo);
    nombre_var = modelos(i).nombre_var;
    
    objeto_modelo = datos_modelo.(nombre_var);
    
    % Extract the trained model object
    if isstruct(objeto_modelo) && isfield(objeto_modelo, 'ClassificationEnsemble')
        Mdl = objeto_modelo.ClassificationEnsemble;
    elseif isstruct(objeto_modelo) && isfield(objeto_modelo, 'ClassificationKNN')
        Mdl = objeto_modelo.ClassificationKNN;
    else
        Mdl = objeto_modelo;
    end
    
    % --- CROSS-VALIDATION (k=10) ---
    CVMdl = crossval(Mdl, 'KFold', 10);
    
    % Calculate std deviation for Accuracy across folds
    error_por_fold = kfoldLoss(CVMdl, 'Mode', 'individual');
    exactitud_por_fold = 1 - error_por_fold;
    std_accuracy = std(exactitud_por_fold);
    
    % Global Predictions
    Y_pred = kfoldPredict(CVMdl);
    
    % --- METRICS CALCULATION ---
    C = confusionmat(Y_real, Y_pred);
    TN = C(1,1); FP = C(1,2); FN = C(2,1); TP = C(2,2);
    
    Accuracy = (TP + TN) / (TP + TN + FP + FN);
    Precision = TP / (TP + FP);
    Recall = TP / (TP + FN);
    F1_Score = 2 * (Precision * Recall) / (Precision + Recall);
    
    fprintf('\nMODEL: %s\n', nombre_modelo);
    fprintf('-----------------------------------\n');
    fprintf('Accuracy (Global):  %.4f (%.1f%% +/- %.1f%%)\n', Accuracy, Accuracy*100, std_accuracy*100);
    fprintf('Precision:          %.4f\n', Precision);
    fprintf('Recall (Sensib.):   %.4f\n', Recall);
    fprintf('F1-Score:           %.4f\n', F1_Score);
    fprintf('-----------------------------------\n');
end
