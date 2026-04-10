% =========================================================================
% SCRIPT 04: FREQUENCY RATIO (FR) ANALYSIS
% Description: Calculates the Frequency Ratio for all conditioning factors,
% plots the FR bar charts, and automatically generates the LaTeX code for
% Table 3 of the manuscript.
% =========================================================================
clear; clc; close all;

% Define paths
dir_data = fullfile('..', 'data');
load(fullfile(dir_data, 'datos_entrenamiento_limpios.mat'), 'tabla_entrenamiento_precipitacion');
T = tabla_entrenamiento_precipitacion;

% Define Variables and Titles
variables = {'slope', 'PRE_ANUAL', 'NDVI','NDWI', 'Moisture', 'NBR', 'SWIR'};
titulos = {'Slope (Degrees)', 'Annual Precipitation (mm)', 'Vegetation Index (NDVI)', ...
           'Water (NDWI)', 'Moisture Index', 'Burn Index (NBR)', 'Short Wave InfraRed (SWIR)'};
num_bins = 5; 

figure('Name', 'Frequency Ratio Analysis', 'Color', 'w', 'Position', [50, 50, 1400, 800]);

for i = 1:length(variables)
    var_name = variables{i};
    datos_col = T.(var_name);
    etiquetas = T.clase;
    
    % Discretize data
    edges = linspace(min(datos_col), max(datos_col), num_bins+1);
    bins = discretize(datos_col, edges);
    
    fr_values = zeros(1, num_bins);
    bin_labels = strings(1, num_bins);
    
    total_desl = sum(etiquetas == 1);
    total_pixels = length(etiquetas);
    
    % Calculate frequency
    for b = 1:num_bins
        idx_in_bin = (bins == b);
        pixels_in_bin = sum(idx_in_bin);
        
        if pixels_in_bin > 0
            desl_in_bin = sum(etiquetas(idx_in_bin) == 1);
            percent_area = pixels_in_bin / total_pixels;
            percent_desl = desl_in_bin / total_desl;
            fr_values(b) = percent_desl / percent_area;
        else
            fr_values(b) = 0;
        end
        
        bin_labels(b) = sprintf('%.2f', edges(b)); 
    end
    
    % Plot
    subplot(2, 4, i); 
    bar(fr_values, 'FaceColor', [0.2, 0.6, 0.8]);
    hold on; yline(1, 'r--', 'LineWidth', 2); hold off;
    
    title(titulos{i}, 'FontSize', 10);
    ylabel('FR');
    xticklabels(bin_labels);
    xtickangle(45);
    grid on;
    
    if max(fr_values) > 0
        text(1, max(fr_values)*0.9, 'FR > 1: High Propensity', 'Color', 'r', 'FontSize', 7);
    end
end
sgtitle('Conditioning Factors Analysis (Frequency Ratio)');

% --- AUTOMATIC LATEX TABLE GENERATOR ---
fprintf('\n\n%% --- COPY FROM HERE FOR LATEX TABLE --- %%\n');
fprintf('\\begin{table}[htbp]\n\\centering\n\\small\n');
fprintf('\\caption{Frequency Ratio (FR) of Conditioning Factors.}\n\\label{tab:frequency_ratio}\n');
fprintf('\\begin{tabular}{llccc}\n\\hline\n');
fprintf('\\textbf{Factor} & \\textbf{Class} & \\textbf{Pixels} & \\textbf{LS (\\%%)} & \\textbf{FR} \\\\ \\hline\n');

for i = 1:length(variables)
    var_name = variables{i};
    titulo_var = titulos{i}; 
    datos_col = T.(var_name);
    etiquetas = T.clase;
    
    edges = linspace(min(datos_col), max(datos_col), num_bins+1);
    bins = discretize(datos_col, edges);
    total_desl_global = sum(etiquetas == 1);
    
    fprintf('\\multirow{%d}{*}{\\textbf{%s}} ', num_bins, titulo_var);
    
    for b = 1:num_bins
        idx = (bins == b);
        pixels_in_bin = sum(idx);
        desl_in_bin = sum(etiquetas(idx) == 1);
        
        if pixels_in_bin > 0
            percent_area = pixels_in_bin / length(etiquetas);
            percent_desl_in_class = desl_in_bin / total_desl_global;
            fr_val = percent_desl_in_class / percent_area;
        else
            fr_val = 0; percent_desl_in_class = 0;
        end
        
        rango = sprintf('%.2f -- %.2f', edges(b), edges(b+1));
        fprintf('& %s & %d & %.2f\\%% & %.2f \\\\\n', rango, pixels_in_bin, percent_desl_in_class*100, fr_val);
    end
    fprintf('\\hline \n'); 
end
fprintf('\\end{tabular}\n\\end{table}\n');
fprintf('%% --- END OF LATEX CODE --- %%\n');
