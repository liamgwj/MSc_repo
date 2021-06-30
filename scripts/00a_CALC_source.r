#LJ 2021-06-29

# analysis calculations

# requires packages 'ape', 'raster'

# the two scripts sourced from this one are designed to be pointable at any combination of a phylogeny and occurrence maps for the tips. The paths to these input files are set here, and this script could be modified to loop through a large number of phylogenies/rasters (i.e. from simulations), or used as it is on a single phylogeny and set of rasters (as for real data).


now <- "2021-06-29_13:41:48"

phy_lst <- ape::read.tree(paste0("output/sim_phylogenies/", now, ".nwk"))

phy <- phy_lst[[1]]




char_known <- read.csv(paste0("output/sim_hostStatus/", now, "/known",
                              "/phy", 1, "_charKnown.csv"),
                       row.names = 1)




source("scripts/04_CALC_phyloPred.r")




char <- read.csv(paste0("output/CALC_charStates/", now, "_charEst.csv"),
         row.names = 1)


# read in species occurrence rasters

occurrence <- vector("list", nrow(char))

for(i in 1:nrow(char)){
    
    occurrence[[i]] <- raster::raster(paste0("output/sim_occurrence/", now,
                                     "/phy", 1, "/",
                                     rownames(char)[i],
                                     "_occurrence.tif"))
}



source("scripts/05_CALC_connectivity.r")

