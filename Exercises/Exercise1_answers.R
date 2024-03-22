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
# There are four objects loaded: the genetic data (as a vcfR object), (2) a pairwise genetic
# distance matrix, (3) coordinates, and (4) a rasterstack of environmental layers

###### *Q1b*: Is the genetic data object provided as a dosage matrix? How do you know?
# No; it's a vcfR object. We can take a look at the first five sites for five individuals
# like so:
liz_vcf@gt[2:6,2:6] # this genotype coding is standard for a vcf file.


# (2) Process genetic data ------------------------------------------------

# Convert the loaded vcf to a dosage matrix using `vcf_to_dosage()`.
gen <- vcf_to_dosage(liz_vcf)

###### *Q2a*: Do your genetic data have missing values? How do you know?
sum(is.na(gen)) # yes, there are 17,840 missing values

# Impute missing values using structure-based imputation (with `str_impute()`)
# using a K value of 3 and 5 repetitions of sNMF:
gen <- str_impute(gen, K = 3, repetitions = 5)

# Check that the missing values are gone now.
sum(is.na(gen)) # value is 0 so imputation worked!

# Your genetic data are now ready for GEA!


# (3) Process environmental data ------------------------------------------

# You've already been provided the top three PCs after running a rasterPCA with 18 bioclimatic
# variables. To run GEA, we'll need to extract PC loadings for each of our sampling coordinates.
# To do so, you can use the `raster::extract()` function.
env <- raster::extract(CA_env, liz_coords) # there are the same number of rows as individuals (53)

# Scale your environmental variables and turn into dataframe like so:
env <- raster::scale(env, center = TRUE, scale = TRUE)
env <- data.frame(env)


# (4) Run simple RDA ------------------------------------------------------

# Run a simple RDA with model selection (i.e., `model = "best"`). Use a Pin = 0.05
# and do 1000 R2 permutations.
sRDA <- rda_run(gen, env,
                model = "best",
                Pin = 0.05,
                R2permutations = 1000)

# Which environmental variables are significant from your simple RDA? (HINT: look at
# the anova object within your results)
sRDA$anova # only PCs 2 and 3 are sig


# (5) Run partial RDA -----------------------------------------------------

# Let's now run a partial RDA with model seletion (`model = "best"`), controlling 
# for geographic distance (`"correctGEO"`).
pRDA <- rda_run(gen, env, liz_coords, 
                model = "best",
                correctGEO = TRUE, 
                nPC = 3)

# Which environmental variables are significant from your simple RDA? (HINT: look at
# the anova object within your results)
pRDA$anova # only PC 3 is significant now

# What do your results tell you about the influence of geographic distance on outliers?
# CA_rPCA2 and geographic distance are likely collinear with one another, which is
# why the partial RDA did not result in this environmental PC being significant.


# (6) Get outliers --------------------------------------------------------

# Let's use the p-value method to pull out outliers from your simple RDA results. Do so
# using the `rda_getoutliers()` function, specifying `"p"` for `outlier_method`.
rda_p <- rda_getoutliers(sRDA, outlier_method = "p")

# Now do the same, but do the Z-scores outlier method (by specifying `"z"` for `outlier_method`).
rda_z <- rda_getoutliers(sRDA, outlier_method = "z")

# What do you notice about the number of outliers found for each method?
length(rda_p$rda_snps) # 167 outliers
length(rda_z$loading) # 16 outliers
# There are far fewer outliers when using the Z-scores method than the p-value method.

# Get outliers using the Z-scores outlier method for your partial RDA:
rda_z_part <- rda_getoutliers(pRDA, outlier_method = "z")


# (6) Visualize RDA results -----------------------------------------------

# Make a Manhattan plot for your simple RDA results with p-value outlier method
# using the `rda_plot()` function with `manhattan = TRUE` and `rdaplot = FALSE`:
rda_plot(mod = sRDA, rda_snps = rda_p$rda_snps, pvalues = rda_p$pvalues,
        manhattan = TRUE, rdaplot = FALSE)

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
tidy_list <- rda_ggtidy(sRDA, rda_p$rda_snps, axes = c(1, 2))
TAB_snps <- tidy_list[["TAB_snps"]]
TAB_var <- tidy_list[["TAB_var"]]

# Finally, we can build our RDA biplot like so:
rda_biplot(TAB_snps, TAB_var, biplot_axes = c(1, 2))

