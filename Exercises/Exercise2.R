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
###### * YOUR CODE HERE * ######

# You'll notice our envdata only has one row for each population (which makes sense,
# as these would be duplicated). For any GEA analysis, we need all rows to be consistent;
# there is no check for sample IDs. I find the easiest way to do this is with a `left_join()`.
# Do a left join with the coordinates and the envdata. Ensure that the number of rows in 
# your new envdata object are consistent with the number of individuals in your genetic data.
###### * YOUR CODE HERE * ######

# Remove any columns that aren't environmental data (this includes sample IDs!) from your
# environmental data object.
###### * YOUR CODE HERE * ######

# Now, make the sample column within the genetic data object into rownames (you could
# use the `rownames_to_column()` function). Now it is really a dosage matrix.
###### * YOUR CODE HERE * ######

# For any landscape genomics analysis, we want to ensure that individuals are ordered
# in the exact same way across all our input datasets. An easy way to do this is using
# the `all.equal()` function which has the syntax `all.equal(df1$col, df2$col)`.
# Check that the samples in the genetic data are in the same order as the samples in
# the coordinate data.
###### * YOUR CODE HERE * ######


# (2) Impute missing values in genetic data -------------------------------

# Are there missing values in our genetic dataset? How do you know?
###### * YOUR CODE HERE * ######

# Impute missing values using the `simple_impute()` function. This will impute
# to the median dosage value.
###### * YOUR CODE HERE * ######


# (3) Perform K selection -------------------------------------------------

# The last step before running LFMM is to decide how many latent factors we're 
# going to account for in our model. We can do so using the `select_K()` function.
# The `"K_selection"` argument within this function specifies the type of K selection
# you'd like to do. Run this function with both `"quick_elbow"` and `"find_clusters"`
# K selection methods. Do they differ?
###### * YOUR CODE HERE * ######


# (4) Run LFMM ------------------------------------------------------------

# Run LFMM using the `lfmm_run()` function and specifying either of your K values
# as the number of latent factors. We'll stick with running the LFMM "ridge" method
# as I've found it performs best. Set the significance threshold to 0.01.
###### * YOUR CODE HERE * ######


# (5) LFMM summary statistics ---------------------------------------------

# What are each of the objects within your LFMM results?
###### * YOUR ANSWER HERE * ######

# How many candidate outliers were detected as being associated with your
# environmental variables?
###### * YOUR CODE/ANSWER HERE * ######

# *BONUS*: which environmental variable shows the strongest association
# in your LFMM model, i.e., has the largest B value? (HINT: you could use 
# the `lfmm_table()` function for this and specify `top = TRUE` and 
# `order = TRUE`)
###### * YOUR CODE HERE * ######


# (6) LFMM data visualization ---------------------------------------------

# Build a Manhattan plot for your LFMM results using `lfmm_manhattanplot()` 
# with a significance threshold of 0.01.
###### * YOUR CODE HERE * ######

# *BONUS*: Because the above is a little difficult to make out due to having
# many environmental variables, let's now only make Manhattan plots for 
# airtemp_mean, airtemp_range, and snowfall_max. Use the same sig threshold.
###### * YOUR CODE HERE * ######

