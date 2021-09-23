# LJ started: 2021-06-28 last updated: 2021-09-22

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
                "nTips" = 16, # number of extant taxa per phylogeny
                "nPhy" = 1, # number of phylogenies to simulate
                "lambda" = 0.2, # speciation rate
                "mu" = 0.1, # extinction rate
                
                # character states (02) ---------------------------------------
                "trait_type" = "continuous", # "discrete" or "continuous"
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
                "land_dim_x" = 20, # dimensions of simulated landscape
                "land_dim_y" = 20,
                "min_nPatch" = 1, # number of habitat patches per taxon
                "max_nPatch" = 1,
                "min_patchSize" = 1, # size of habitat patches
                "max_patchSize" = 1,
                "cooccurrence_pat" = "clustered" # co-occurrence pattern across
                # taxa - one of "clustered", "random" or "dispersed"
 )


# write parameters to file ----------------------------------------------------

write.csv(params,
          paste0("output/SIM_parameters/", now, "_params.csv"),
          row.names = FALSE)


# run simulations -------------------------------------------------------------

# check that output directories exist, creating them if necessary

if(!dir.exists("output")){
    dir.create("output")
}

if(!dir.exists("output/sim_phylogenies")){
    dir.create("output/sim_phylogenies")
}

if(!dir.exists("output/sim_hostStatus")){
    dir.create("output/sim_hostStatus")
}

if(!dir.exists("output/sim_occurrence")){
    dir.create("output/sim_occurrence")
}


# source component scripts in order (requires the ID and parameter objects
# present in the environment ('now' and 'params'))

source("scripts/01_SIM_phylo.r")

source("scripts/02_SIM_charEvol.r")

source("scripts/03_SIM_geoDistr.r")

