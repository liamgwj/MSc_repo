# LJ started: 2021-06-28 last updated: 2021-10-10 ## SUPPORT FOR CONTINUOUS CHARACTERS NOT COMPLETE ##

### ToDo:
# looop thru:
# - dispersal distances (5,10,15?)
# - number of hosts  - keep patch size constant for now
# - host qualities?

# This is the central simulation script - here, we will set the parameters for
# the simulation run, then source the additional scripts (01-03) that carry out
# the simulations.


# the downstream scripts require the following packages:
# 01: ape, TreeSim
# 02: ape
# 03: ape, raster, landscapeR


# set parameters --------------------------------------------------------------


# set input parameters

params <- data.frame(
                "ID" = now,
                
                # phylogeny (01) ----------------------------------------------
                "nTips" = 30, # number of extant taxa per phylogeny
                "nPhy" = 1, # number of phylogenies to simulate
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
                "land_dim_x" = 100, # dimensions of simulated landscape
                "land_dim_y" = 100,
                "min_nPatch" = 1, # number of habitat patches per taxon
                "max_nPatch" = 10,
                "min_patchSize" = 10, # size of habitat patches
                "max_patchSize" = 100,
                "cooccurrence_pat" = "random", # co-occurrence pattern across
                # taxa - one of "clustered", "random" or "dispersed"
                "hostQuality_min" = 1,
                "hostQuality_max" = 9,
                "dispMax" = disp_level
 )


# check for output directories, creating them if necessary --------------------

if(!dir.exists("output")){
    dir.create("output")
}

if(!dir.exists(paste0("output/", now))){
    dir.create(paste0("output/", now))
}


# write parameters to file ----------------------------------------------------

write.csv(params,
          paste0("output/", now, "/",
                 "parameters_", now, "_d", disp_level, ".csv"),
          row.names = FALSE)
