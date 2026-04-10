# LSM-Pico-Orizaba-Ensemble
Dynamic Assessment of Landslide Susceptibility at Pico de Orizaba Using Ensemble Classifiers and Multitemporal Analysis

This repository contains the dataset and MATLAB scripts used in the research paper: *"Dynamic Assessment of Landslide Susceptibility at Pico de Orizaba Using Ensemble Classifiers and Multitemporal Analysis"*, presented at the MCPR2026

## Project Overview

Landslide Susceptibility Modeling (LSM) in active volcanic regions is often hampered by a lack of comprehensive historical inventories. Traditional approaches generally treat susceptibility as a static property, ignoring the temporal variability of risk due to climatic or terrain factors.

This project proposes a dynamic supervised learning framework that integrates time series from Landsat-8 and ensemble classifiers to model mass movement risk on the Pico de Orizaba volcano (Mexico). We evaluate three architectures: Random Forest, k-Nearest Neighbors, and Boosted Trees (AdaBoost) using 10-fold cross-validation, demonstrating that susceptibility is a transient, environmentally-driven phenomenon.

## Repository Structure

* `data/`: Contains the pre-processed dataset used for training and validation (`training_dataset.mat`).
* `src/`: Contains the MATLAB scripts for data preprocessing, model training (AdaBoost, RF, k-NN), cross-validation, and performance evaluation.
* `results/`: Contains generated figures (ROC curves, susceptibility maps, and dynamism maps).

## Usage

1.  Clone this repository: `git clone https://github.com/tu-usuario/LSM-Pico-Orizaba-Ensemble.git`
2.  Open MATLAB and navigate to the repository folder.
3.  Run the main script located in `src/` to reproduce the results.

## Requirements

* MATLAB (Tested on version R2025b)
* Statistics and Machine Learning Toolbox

## Citation

If you find this code or dataset useful in your research, please consider citing our work:

```bibtex
@inproceedings{avendano2026dynamic,
  title={Dynamic Assessment of Landslide Susceptibility at Pico de Orizaba Using Ensemble Classifiers and Multitemporal Analysis},
  author={Avenda{\~n}o Barajas, Adhara Alejandra and Altamirano Robles, Leopoldo and D{\'i}az Hern{\'a}ndez, Raquel and Zapotecas Mart{\'i}nez, Sa{\'u}l},
  booktitle={Proceedings of the [MCPR2026]},
  year={2026},
  organization={Springer}
}
