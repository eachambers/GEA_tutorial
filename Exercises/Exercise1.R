### EXERCISE 1: RDA on Sceloporus lizards

# Load libraries
library(algatr)
algatr::rda_packages() # install necessary packages
library(tidyverse)
library(raster)
library(vegan)


# (1) Load the data -------------------------------------------------------

# Load the built-in example dataset within algatr:
load_algatr_example()

###### *Q1a*: How many objects are loaded with this function? What is each object?
###### * YOUR ANSWER HERE * ######

###### *Q1b*: Is the genetic data object provided as a dosage matrix? How do you know?
###### * YOUR ANSWER HERE * ######


# (2) Process genetic data ------------------------------------------------

# Convert the loaded vcf to a dosage matrix using `vcf_to_dosage()`.
###### * YOUR CODE HERE * ######

###### *Q2a*: Do your genetic data have missing values? How do you know?
###### * YOUR ANSWER/CODE HERE * ######

# Impute missing values using structure-based imputation (with `str_impute()`)
# using a K value of 3 and 5 repetitions of sNMF:
###### * YOUR CODE HERE * ######

# Check that the missing values are gone now.
###### * YOUR CODE HERE * ######

# Your genetic data are now ready for GEA!


# (3) Process environmental data ------------------------------------------

# You've already been provided the top three PCs after running a rasterPCA with 18 bioclimatic
# variables. To run GEA, we'll need to extract PC loadings for each of our sampling coordinates.
# To do so, you can use the `raster::extract()` function.
###### * YOUR CODE HERE * ######

# Scale your environmental variables and turn into dataframe like so:
env <- raster::scale(env, center = TRUE, scale = TRUE)
env <- data.frame(env)


# (4) Run simple RDA ------------------------------------------------------

# Run a simple RDA with model selection (i.e., `model = "best"`). Use a Pin = 0.05
# and do 1000 R2 permutations.
###### * YOUR CODE HERE * ######

# Which environmental variables are significant from your simple RDA? (HINT: look at
# the anova object within your results)
###### * YOUR ANSWER HERE * ######


# (5) Run partial RDA -----------------------------------------------------

# Let's now run a partial RDA with model seletion (`model = "best"`), controlling 
# for geographic distance (`"correctGEO"`).
###### * YOUR CODE HERE * ######

# Which environmental variables are significant from your simple RDA? (HINT: look at
# the anova object within your results)
###### * YOUR CODE/ANSWER HERE * ######

# What do your results tell you about the influence of geographic distance on outliers?
###### * YOUR ANSWER HERE * ######


# (6) Get outliers --------------------------------------------------------

# Let's use the p-value method to pull out outliers from your simple RDA results. Do so
# using the `rda_getoutliers()` function, specifying `"p"` for `outlier_method`.
###### * YOUR CODE HERE * ######

# Now do the same, but do the Z-scores outlier method (by specifying `"z"` for `outlier_method`).
###### * YOUR CODE HERE * ######

# What do you notice about the number of outliers found for each method?
###### * YOUR ANSWER HERE * ######

# Get outliers using the Z-scores outlier method for your partial RDA:
###### * YOUR CODE HERE * ######


# (6) Visualize RDA results -----------------------------------------------

# Make a Manhattan plot for your simple RDA results with p-value outlier method
# using the `rda_plot()` function with `manhattan = TRUE` and `rdaplot = FALSE`:
###### * YOUR CODE HERE * ######

# There are some updates that need to be made to algatr; because of this,
# we're not actually able to see the RDA biplot using the `rda_plot()` function
# as we would normally. To get around this, run the following to load this function 
# into your environment:
rda_ggtidy <- function(mod, rda_snps, axes) {
  snp_scores <- vegan::scores(mod, choices = axes, display = "species", scaling = "none") # vegan references "species", here these are the snps
  TAB_snps <- data.frame(names = row.names(snp_scores), snp_scores)
  
  TAB_snps$type <- "Neutral"
  TAB_snps$type[TAB_snps$names %in% rda_snps] <- "Outliers"
  TAB_snps$type <- factor(TAB_snps$type, levels = c("Neutral", "Outliers"))
  TAB_var <- as.data.frame(vegan::scores(mod, choices = axes, display = "bp")) # pull the biplot scores
  
  tidy_list <- list(TAB_snps = TAB_snps, TAB_var = TAB_var)
  return(tidy_list)
}

# Now, run this (assuming `simplerda` is your simple RDA results object and
# rda_sig_p is the object produced by getting p-value outliers for your simple RDA:
tidy_list <- rda_ggtidy(simplerda, rda_sig_p$rda_snps, axes = c(1, 2))
TAB_snps <- tidy_list[["TAB_snps"]]
TAB_var <- tidy_list[["TAB_var"]]

# Finally, we can build our RDA biplot like so:
rda_biplot(TAB_snps, TAB_var, biplot_axes = c(1, 2))

