### EXERCISE 1: RDA on Sceloporus lizards

# Load libraries
library(algatr)
algatr::rda_packages() # install necessary packages
library(tidyverse)
library(raster)
library(vegan)


# Relevant algatr vignettes:


# (1) Load the data -------------------------------------------------------

# Load the built-in example dataset within algatr:
load_algatr_example()

###### *Q1a*: How many objects are loaded with this function? What is each object?
###### * YOUR ANSWER HERE * ######

###### *Q1b*: Is the genetic data object provided as a dosage matrix? How do you know?
###### * YOUR ANSWER HERE * ######


# (2) Process genetic data ------------------------------------------------

# Convert the loaded vcf to a dosage matrix using `algatr::vcf_to_dosage()`.
###### * YOUR CODE HERE * ######

###### *Q2a*: Do your genetic data have missing values? How do you know?
###### * YOUR ANSWER/CODE HERE * ######

# Impute missing values using structure-based imputation (with algatr::TODO)
###### * YOUR CODE HERE * ######

# Check that the missing values are gone now.
###### * YOUR CODE HERE * ######

# Your genetic data are now ready for GEA!


# (3) Process environmental data ------------------------------------------

# You've already been provided the top three PCs after running a rasterPCA with 18 bioclimatic
# variables. To run GEA, we'll need to extract PC loadings for each of our sampling coordinates.
# To do so, you can use the `raster::extract()` function.
###### * YOUR CODE HERE * ######

# TODO scaling?


# (4) Run simple RDA ------------------------------------------------------


# (5) Run partial RDA -----------------------------------------------------



# (6) Visualize RDA results -----------------------------------------------


