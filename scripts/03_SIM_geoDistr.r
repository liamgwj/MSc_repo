# LJ 2021-06-25

library(sp)
library(raster)
library(landscapeR)

# read in input parameters

params <- read.csv(paste0("output/SIM_parameters/", now, "_params.csv"))

# read in phylogenies

phy_lst <- read.tree(paste0("output/sim_phylogenies/", now, ".nwk"))


# Simulate geographic distributions for each tip

occurrence <- vector("list", length(phy_lst))


for(i in 1:length(occurrence)){

    occurrence[[i]] <- vector("list", length(phy_lst[[i]]$tip.label))

    names(occurrence[[i]]) <- phy_lst[[i]]$tip.label
    }


empty_raster <- raster(matrix(0, params$landscape_dim, params$landscape_dim),
                       xmn = 0, xmx = 10,
                       ymn = 0, ymx = 10)


for(i in 1:length(occurrence)){
    seed_locations <- sample(1:length(empty_raster[]),
                             params$max_nPatch*length(phy_lst[[i]]$tip.label))

    for(j in 1:length(occurrence[[i]])){
        np <- sample(1:params$max_nPatch, 1) # number of patches
        sz <- sample(10:params$max_patchSize, 1) # size of each patch

        if(params$cooccurrence_pat == "clustered"){
        seed_loc_subset <- sample(seed_locations[1:10], np)}

        if(params$cooccurrence_pat == "random"){
        seed_loc_subset <- sample(1:length(empty_raster[]), np)}

        if(params$cooccurrence_pat == "dispersed"){
        if(j==1){ seed_loc_subset <- seed_locations[j:np]
        }else{ seed_loc_subset <-
            seed_locations[(((j-1)*10)+1):(((j-1)*10)+np)]}}

        occurrence[[i]][[j]] <- makeClass(empty_raster,
                                          npatch = np,
                                          size = sz,
                                          pts = seed_loc_subset)
    }}


# write rasters to file

dir.create(paste0("output/sim_occurrence/", now))


for(i in 1:length(phy_lst)){

    dir.create(paste0("output/sim_occurrence/", now, "/phy", i))

    for(j in 1:length(phy_lst[[i]]$tip.label)){

        writeRaster(occurrence[[i]][[j]],
                    paste0("output/sim_occurrence/", now, "/phy", i, "/",
                           phy_lst[[i]]$tip.label[j], "_occurrence"),
                    format = "GTiff")
    }}
