### EXERCISE 2: LFMM on willow leaf beetles

# Load libraries
library(algatr)
algatr::lfmm_packages() # install necessary packages
library(tidyverse)
library(raster)
library(vegan)


# (1) Import and process data ---------------------------------------------

# Prior to class, you should have downloaded the three data files that are here: 
# https://github.com/eachambers/GEA_tutorial/tree/main/Data

# Set your working directory to where you'll be working. This is also where you'll want 
# to add the three data files (contained within a folder named "Data"). Read in the 
# three data files. I like to do this with `read_tsv(`). Be sure that you specify that
# there are column names in these datasets.
setwd("~/Documents/GitHub/GEA_tutorial")
coords <- read_tsv("Data/Keller_coords.txt", col_names = TRUE)
gen <- read_tsv("Data/Keller_gendata.txt", col_names = TRUE)
env <- read_tsv("Data/Keller_envdata.txt", col_names = TRUE)

# You'll notice our envdata only has one row for each population (which makes sense,
# as these would be duplicated). For any GEA analysis, we need all rows to be consistent;
# there is no check for sample IDs. I find the easiest way to do this is with a `left_join()`.
# Do a left join with the coordinates and the envdata. Ensure that the number of rows in 
# your new envdata object are consistent with the number of individuals in your genetic data.
newenv <- left_join(coords, env)

# Remove any columns that aren't environmental data (this includes sample IDs!) from your
# environmental data object.
newenv <- newenv %>% 
  dplyr::select(-c(sample, population, mid_latitude, mid_longitude))

# Now, make the sample column within the genetic data object into rownames (you could
# use the `rownames_to_column()` function). Now it is really a dosage matrix.
gen <- gen %>% column_to_rownames(var = "sample")

# For any landscape genomics analysis, we want to ensure that individuals are ordered
# in the exact same way across all our input datasets. An easy way to do this is using
# the `all.equal()` function which has the syntax `all.equal(df1$col, df2$col)`.
# Check that the samples in the genetic data are in the same order as the samples in
# the coordinate data.
all.equal(rownames(gen), coords$sample) # TRUE so it's in correct order


# (2) Impute missing values in genetic data -------------------------------

# Are there missing values in our genetic dataset? How do you know?
sum(is.na(gen))n # yes, there are 136 sites missing

# Impute missing values using the `simple_impute()` function. This will impute
# to the median dosage value.
gen <- simple_impute(gen)
sum(is.na(gen)) # no more missing values


# (3) Perform K selection -------------------------------------------------

# The last step before running LFMM is to decide how many latent factors we're 
# going to account for in our model. We can do so using the `select_K()` function.
# The `"K_selection"` argument within this function specifies the type of K selection
# you'd like to do. Run this function with both `"quick_elbow"` and `"find_clusters"`
# K selection methods. Do they differ?
select_K(gen, K_selection = "find_clusters", perc.pca = 90, max.n.clust = 10) # best K=2
select_K(gen, K_selection = "quick_elbow") # best K=4
# Yes, they do differ.


# (4) Run LFMM ------------------------------------------------------------

# Run LFMM using the `lfmm_run()` function and specifying either of your K values
# as the number of latent factors. We'll stick with running the LFMM "ridge" method
# as I've found it performs best. Set the significance threshold to 0.01.
results_K4 <- lfmm_run(gen, newenv, K = 4, lfmm_method = "ridge", sig = 0.01)
results_K2 <- lfmm_run(gen, newenv, K = 2, lfmm_method = "ridge", sig = 0.01)


# (5) LFMM summary statistics ---------------------------------------------

# What are each of the objects within your LFMM results?
# A list of 5 objects: candidate snps, the results for all the data, 
# the LFMM model (model), the test result, and the K value used for latent 
# factors

# How many candidate outliers were detected as being associated with your
# environmental variables?
nrow(results_K4$lfmm_snps) # 16064
nrow(results_K2$lfmm_snps) # 16169

# *BONUS*: which environmental variable shows the strongest association
# in your LFMM model, i.e., has the largest B value? (HINT: you could use 
# the `lfmm_table()` function for this and specify `top = TRUE` and 
# `order = TRUE`)
lfmm_table(results_K4$df, order = TRUE, top = TRUE) # airtemp_mean
lfmm_table(results_K2$df, order = TRUE, top = TRUE) # airtemp_mean


# (6) LFMM data visualization ---------------------------------------------

# Build a Manhattan plot for your LFMM results using `lfmm_manhattanplot()` 
# with a significance threshold of 0.01.
lfmm_manhattanplot(results_K4$df, sig = 0.01)

# *BONUS*: Because the above is a little difficult to make out due to having
# many environmental variables, let's now only make Manhattan plots for 
# airtemp_mean, airtemp_range, and snowfall_max. Use the same sig threshold.
lfmm_manhattanplot(results_K4$df %>% 
                     filter(var == "airtemp_range" |
                              var == "airtemp_mean" |
                              var == "snowfall_max"), sig = 0.01)

