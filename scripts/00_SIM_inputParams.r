# LJ 2021-06-28

# This is the central simulation script - here, we will set the parameters for the simulation run, then source the additional scripts (01-03) that carry out the simulations.


# the downstream scripts require the following packages:
# 01: ape, TreeSim
# 02: ape
# 03: ape, raster, landscapeR


# set parameters ---------------------------------------------------------

# generate unique date/time ID for this run

now <- gsub(" ", "_", Sys.time())


# set input parameters

params <- data.frame(
                "ID" = now,
                
                # phylogeny (01)
                "nTips" = 20, # number of extant taxa per phylogeny
                "nPhy" = 10, # number of phylogenies to simulate
                
                # character states (02)
                "trait_rate" = 0.1, # rate of change of discrete character
                "prop_missing" = 0.2, # proportion of taxa whose trait values should be considered "missing" to test phylogenetic prediction
                
                # geographic distributions (03)
                "land_dim_x" = 100, # dimensions of simulated landscape
                "land_dim_y" = 100,
                "min_nPatch" = 1, # number of habitat patches per taxon
                "max_nPatch" = 10,
                "min_patchSize" = 10, # size of habitat patches
                "max_patchSize" = 250,
                "cooccurrence_pat" = "random" # co-occurrence pattern across taxa - one of "clustered", "random" or "dispersed"
 )


# write parameters to file

write.csv(params,
          paste0("output/SIM_parameters/", now, "_params.csv"),
          row.names = FALSE)


# run simulations --------------------------------------------------------

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


# source component scripts in order (requires the ID and parameter objects present in the environment ('now' and 'params'))

source("scripts/01_SIM_phylo.r")

source("scripts/02_SIM_charEvol.r")

source("scripts/03_SIM_geoDistr.r")






# misc - for later ---------------------------------------------------------

# input_params <- expand.grid(trait_rate = c(0.05, 0.1, 0.2, 0.3),
#                             prop_missing = c(0.05, 0.1, 0.25, 0.5),
#                             coocurrence_pat = c("clustered",
#                                                 "random",
#                                                 "dispersed"))
