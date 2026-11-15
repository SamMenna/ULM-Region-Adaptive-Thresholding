# Region-Adaptive Thresholding for Microbubble Detection

**Region-Adaptive Thresholding for Microbubble Detection in Ultrasound Localization Microscopy (ULM)**

This project extends the [ULM Threshold Analysis](https://github.com/IMPACT-L/ULMThresholdAnalysis) repository to investigate whether **adapting microbubble detection thresholds to local bubble density** can improve detection accuracy and super-resolution ultrasound image quality.

The original repository evaluates how false positives and false negatives affect reconstructed images by introducing simulated detection errors into ground-truth microbubble positions.

Our proposed extension introduces a *frame-based detection method*, comparing two approaches:

- **Global Thresholding:** A single detection threshold applied uniformly across each ultrasound frame.
- **Region-Adaptive Thresholding:** A spatially varying threshold based on local microbubble density, estimated using *Kernel Density Estimation (KDE)*.

The project will be implemented entirely in **MATLAB**, with the intention of introducing minimal modifications to the original repository and reusing its existing image reconstruction and evaluation code.

> **Project Status:** Planning / Initial Development
>
> This repository is currently a fork of the original implementation. No modifications have been made yet. The methods and experiments described below represent our proposed work.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Proposed Modifications](#proposed-modifications)
3. [Data Availability](#data-availability)
4. [Installation and Dependencies](#installation-and-dependencies)
5. [Reproducing the Experiments](#reproducing-the-experiments)
6. [Experimental Results](#experimental-results)
7. [Google Colab Notebook](#google-colab-notebook)
8. [References and Acknowledgments](#references-and-acknowledgments)
9. [License](#license)

---

## Project Overview

### Original Repository

The baseline repository studies the influence of microbubble detection errors on **Super-Resolution Ultrasound (SR-US)** and **Ultrasound Localization Microscopy (ULM)** image quality.

Its existing functionality includes:

- Simulating **false positives** by introducing additional microbubble detections.
- Simulating **false negatives** by removing ground-truth detections.
- Generating super-resolution microbubble density maps.
- Evaluating reconstruction quality using:
  - Structural Similarity Index (**SSIM**)
  - Dice coefficient (**Dice**)
  - Peak Signal-to-Noise Ratio (**PSNR**)
- Comparing image quality in **dense and sparse regions**.

**Limitation:** The baseline evaluation simulates detection errors using ground-truth microbubble positions rather than detecting microbubbles directly from ultrasound frames.

### Our Approach

We propose implementing a MATLAB-based microbubble detector and investigating whether **region-adaptive thresholding** improves detection and reconstruction performance compared with a global threshold.

| Component | Global Baseline | Proposed Approach |
|---|---|---|
| Detection input | Ultrasound frames | Ultrasound frames |
| Detection threshold | Fixed global threshold | Spatially adaptive threshold |
| Density estimation | Not required | Kernel Density Estimation (KDE) |
| Evaluation | Existing MATLAB evaluation code | Existing MATLAB evaluation code |

*Our primary objective is to evaluate the effectiveness of spatially adaptive detection, particularly in regions with different microbubble densities.*

---

## Proposed Modifications

We aim to minimize changes to the original repository by implementing the detection algorithms in **one or two additional MATLAB files**, while reusing the existing reconstruction and evaluation framework.

### 1. Global Thresholding Baseline

Implement a frame-based detector that identifies microbubble locations directly from ultrasound simulation data using a **single global detection threshold**.

This will provide a reference against which to evaluate the region-adaptive approach.

**Implementation details:** *To be added.*

### 2. Region-Adaptive Thresholding

Implement a two-pass detection method:

1. Perform an initial microbubble detection pass.
2. Estimate local microbubble density using **Kernel Density Estimation (KDE)**.
3. Adjust detection thresholds according to the estimated local density.
4. Perform a second detection pass using the adapted threshold map.

**Implementation details:** *To be added.*

*The relationship between estimated density and the detection threshold will be defined and evaluated during development.*

### 3. Experimental Evaluation

Reuse the original repository's MATLAB evaluation code to compare the global and region-adaptive detectors.

The comparison will investigate:

- **Detection accuracy:** False positive and false negative rates.
- **Reconstruction quality:** SSIM, Dice coefficient, and PSNR.
- **Spatial performance:** Detection and reconstruction quality in dense versus sparse regions.

The objective is to determine whether adaptive thresholding provides measurable improvements and to identify potential trade-offs.

---

## Data Availability

The datasets used in the original repository come from the **UltraSR Challenge** and are publicly available through Zenodo:

**[UltraSR Dataset — Zenodo](https://zenodo.org/records/7271766)**

The dataset must be downloaded separately and organized according to the scripts' expected directory structure.

**TODO:**
- [ ] Identify the required ultrasound simulation files.
- [ ] Document the dataset directory structure.
- [ ] Add data preparation instructions.

---

## Installation and Dependencies

This project is developed entirely in **MATLAB** and builds on the existing code provided by the original repository.

### Requirements

- MATLAB (version to be confirmed).
- Any MATLAB toolboxes required by the original code or new detection algorithms.
- UltraSR simulation dataset.

**TODO:**
- [ ] Confirm the required MATLAB version.
- [ ] Identify any required MATLAB toolboxes.
- [ ] Document any additional setup requirements.

---

## Reproducing the Experiments

The planned experimental workflow is outlined below.

1. **Data Preparation:** Download and prepare the ultrasound simulation dataset.
2. **Global Detection:** Run the MATLAB detector using a global threshold.
3. **Density Estimation:** Estimate local microbubble density using KDE.
4. **Adaptive Detection:** Apply the region-adaptive thresholding method.
5. **Image Reconstruction:** Use the original MATLAB code to generate super-resolution density maps.
6. **Evaluation:** Use the existing evaluation scripts to compare detection accuracy and reconstructed image quality.

**TODO:** Add the MATLAB script names, required parameters, and execution instructions once implemented.

---

## Experimental Results

*Results will be added following implementation and experimental evaluation.*

### Quantitative Comparison

| Evaluation Metric | Global Threshold | Adaptive Threshold |
|---|:---:|:---:|
| False Positive Rate | TBD | TBD |
| False Negative Rate | TBD | TBD |
| SSIM | TBD | TBD |
| Dice Coefficient | TBD | TBD |
| PSNR | TBD | TBD |

### Dense vs. Sparse Region Analysis

**TODO:**
- [ ] Compare detection performance across regions of different bubble densities.
- [ ] Compare reconstructed super-resolution images.
- [ ] Include relevant figures and visualizations.
- [ ] Analyze the impact of threshold adaptation on image quality.

### Discussion

*To be completed following experimental evaluation.*

This section will discuss observed improvements, limitations, trade-offs, and potential explanations for the results.

---

## Google Colab Notebook

A **Google Colab notebook** will accompany the repository as part of the project submission.

**Notebook:** *Link to be added.*

The project implementation and experiments will be performed in MATLAB. The notebook's role in presenting or reproducing these results will be established in accordance with the submission requirements.

The notebook is expected to include:

| Section | Description |
|---|---|
| **Abstract** | Summary of the project, proposed modifications, and main findings. |
| **Proposed Modifications** | Explanation and justification of the MATLAB detection algorithms. |
| **Experimental Results** | Quantitative comparisons and visualizations. |
| **Discussion** | Interpretation of findings, limitations, and possible improvements. |

---

## References and Acknowledgments

This project is based on the original repository:

**[IMPACT-L/ULMThresholdAnalysis](https://github.com/IMPACT-L/ULMThresholdAnalysis)**

We acknowledge the original authors for providing the baseline analysis and evaluation framework.

### Original Publication

[arXiv:2411.07426](https://arxiv.org/abs/2411.07426)

The original repository states that this work was accepted to **SPIE Medical Imaging 2026**. Please refer to the original repository for updated citation information.

---

## Contact

For questions, suggestions, or issues related to this project, please open an issue on GitHub.

---

## License

This project is based on the original ULMThresholdAnalysis repository.

Please consult the original repository for applicable code licensing terms and the Zenodo dataset record for data-specific licensing information.

*License details will be updated as needed.*
