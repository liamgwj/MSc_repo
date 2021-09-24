# LJ started: 2021-06-28 last updated: 2021-09-24

## SUPPORT FOR CONTINUOUS CHARACTERS NOT COMPLETE ##

# This is the central simulation script - here, we will set the parameters for
# the simulation run, then source the additional scripts (01-03) that carry out
# the simulations.


# the downstream scripts require the following packages:
# 01: ape, TreeSim
# 02: ape
# 03: ape, raster, landscapeR


# set parameters --------------------------------------------------------------

# generate unique date/time ID for this run

now <- gsub(" ", "T", Sys.time())


# set input parameters

params <- data.frame(
                "ID" = now,
                
                # phylogeny (01) ----------------------------------------------
                "nTips" = 12, # number of extant taxa per phylogeny
                "nPhy" = 3, # number of phylogenies to simulate
                "lambda" = 0.2, # speciation rate
                "mu" = 0.1, # extinction rate
                
                # character states (02) ---------------------------------------
                "trait_type" = "discrete", # "discrete" or "continuous"
                "prop_missing" = 0.2, # proportion of taxa whose trait values
                # should be removed to test phylogenetic prediction
                "root_value" = 1, # initially non-host
                
                # discrete trait parameters:
                "disc_model" = "ER", # equal-rates model
                "trait_rate" = 0.1,
                
                # continuous trait parameters:
                "cont_model" = "BM",
                "sigma" = 0.1,
                "alpha" = 1,
                "theta" = 0,
                
                # geographic distributions (03) -------------------------------
                "land_dim_x" = 1000, # dimensions of simulated landscape
                "land_dim_y" = 1000,
                "min_nPatch" = 2, # number of habitat patches per taxon
                "max_nPatch" = 20,
                "min_patchSize" = 4, # size of habitat patches
                "max_patchSize" = 12,
                "cooccurrence_pat" = "random" # co-occurrence pattern across
                # taxa - one of "clustered", "random" or "dispersed"
 )


# check for output directories, creating them if necessary --------------------

if(!dir.exists("output")){
    dir.create("output")
}

if(!dir.exists("output/simulations")){
    dir.create("output/simulations")
}

if(!dir.exists(paste0("output/simulations/", now))){
    dir.create(paste0("output/simulations/", now))
}


# write parameters to file ----------------------------------------------------

write.csv(params,
          paste0("output/simulations/", now, "/",
                 "parameters_", now, ".csv"),
          row.names = FALSE)


# source simulation scripts ---------------------------------------------------

source("scripts/01_SIM_phylo.r")

source("scripts/02_SIM_charEvol.r")

source("scripts/03_SIM_geoDistr.r")

