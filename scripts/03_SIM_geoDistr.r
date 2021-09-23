# LJ started: 2021-06-25 last updated: 2021-09-22

# Simulate a presence/absence occurrence raster for each tip on the provided
# phylogenies.

# requires packages 'ape', 'raster', 'landscapeR'

# optional setup --------------------------------------------------------------

# if desired, specify the date/time ID to use and read in the corresponding
# parameter file - when sourcing this script from '00_SIM_params_source.r' the
# ID and parameter objects present in the environment will be used

# set ID

# now <- "YYYY-MM-DDThh:mm:ss"


# read in input parameters

# params <- read.csv(paste0("output/SIM_parameters/", now, "_params.csv"))


# simulation ------------------------------------------------------------------

# read in phylogeny/ies

phy_tmp <- ape::read.tree(paste0("output/sim_phylogenies/", now, ".nwk"))


# check if single phylogeny or multiple

if(class(phy_tmp) == "phylo"){
    phy <- phy_tmp
    rm(phy_tmp)
}else{
    
    if(class(phy_tmp) == "multiPhylo"){
        phy_lst <- phy_tmp
        rm(phy_tmp)
    }else{
        
        print("Error: not a phylo or multiPhylo object")
    }}


# create empty raster with specified dimensions

empty_raster <- raster::raster(matrix(0, params$land_dim_x,
                                      params$land_dim_y),
                               xmn = 0, xmx = 10,
                               ymn = 0, ymx = 10)


# single phylogeny ------------------------------------------------------------

if(exists("phy")){

    # simulate geographic distributions for each tip
    
    # pre-allocate list to hold rasters
    
    occurrence <- vector("list", length(phy$tip.label))
    
    names(occurrence) <- phy$tip.label
    
    
    # simulate distributions --------------------------------------------------
    
    
    # set seed locations for habitat patches - total of (max no. patches per
    # taxon) * (total no. taxa) patches, allowing patches to be completely
    # dispersed if desired
    
    # gridded locations
    seed_locations <- seq(from = 1,
                          to = length(empty_raster[]),
                          by = length(empty_raster[])/(params$max_nPatch *
                                                        length(phy$tip.label))
                              )
    
    # random locations
    #seed_locations <- sample(1:length(empty_raster[]),
    #                         params$max_nPatch * 
    #                             length(phy$tip.label))
    
    
    # sample seed locations for each taxon according to specified pattern
    
    for(i in 1:length(occurrence)){
        np <- sample(params$min_nPatch:params$max_nPatch, 1) # no. patches
        sz <- sample(params$min_patchSize:params$max_patchSize, 1) # patch size
        
        
        # if the specified co-occurrence pattern is "clustered", the seed
        # locations are sampled from a set of max_nPatch locations
        
        if(params$cooccurrence_pat == "clustered"){
            seed_loc_subset <- sample(seed_locations[1:params$max_nPatch], np)}
        
        
        # if "random", the seed locations for each taxon are randomly sampled
        # from the full extent of the raster
        
        if(params$cooccurrence_pat == "random"){
            seed_loc_subset <- sample(1:length(empty_raster[]), np)}
        
        
        # if "dispersed", the seed locations are selected sequentially from the
        # full set of max_nPatch*nTaxa locations, ensuring no overlap
        
        if(params$cooccurrence_pat == "dispersed"){
            if(i==1){ seed_loc_subset <- seed_locations[1:np]
            }else{seed_loc_subset <-
                seed_locations[(((i-1) * params$max_nPatch) + 1):
                                   (((i-1) * params$max_nPatch) + np)]}}
        
        
        # assign presence/absence
        
        occurrence[[i]] <- landscapeR::makeClass(empty_raster,
                                                 npatch = np,
                                                 size = sz,
                                                 pts = seed_loc_subset)
    }
}


# multiple phylogenies --------------------------------------------------------

if(exists("phy_lst")){
    
    # simulate geographic distributions for each tip
    
    # pre-allocate lists to hold rasters
    
    occurrence <- vector("list", length(phy_lst))
    
    
    for(i in 1:length(occurrence)){
        
        occurrence[[i]] <- vector("list", length(phy_lst[[i]]$tip.label))
        
        names(occurrence[[i]]) <- phy_lst[[i]]$tip.label
    }
    
    
    # create empty raster with specified dimensions
    
    empty_raster <- raster::raster(matrix(0, params$land_dim_x,
                                          params$land_dim_y),
                                   xmn = 0, xmx = 10,
                                   ymn = 0, ymx = 10)
    
    
    # simulate distributions --------------------------------------------------
    
    for(i in 1:length(occurrence)){
        
        # set seed locations for habitat patches - total of (max no. patches
        # per taxon) * (total no. taxa) patches, allowing patches to be
        # completely dispersed if desired
        
        seed_locations <- sample(1:length(empty_raster[]),
                                 params$max_nPatch * 
                                     length(phy_lst[[i]]$tip.label))
        
        
        # sample seed locations for each taxon according to specified pattern
        
        for(j in 1:length(occurrence[[i]])){
            np <- sample(params$min_nPatch:params$max_nPatch,
                         1) # set number of patches
            sz <- sample(params$min_patchSize:params$max_patchSize,
                         1) # set patch size
            
            
            # if the specified co-occurrence pattern is "clustered", the seed
            # locations are sampled from a set of max_nPatch locations
            
            if(params$cooccurrence_pat == "clustered"){
                seed_loc_subset <- sample(seed_locations[1:params$max_nPatch],
                                          np)}
            
            
            # if "random", the seed locations for each taxon are randomly
            # sampled from the full extent of the raster
            
            if(params$cooccurrence_pat == "random"){
                seed_loc_subset <- sample(1:length(empty_raster[]), np)}
            
            
            # if "dispersed", the seed locations are selected sequentially from
            # the full set of max_nPatch*nTaxa locations, ensuring no overlap
            
            if(params$cooccurrence_pat == "dispersed"){
                if(j==1){ seed_loc_subset <- seed_locations[1:np]
                }else{ seed_loc_subset <-
                    seed_locations[(((j-1) * params$max_nPatch) + 1):
                                       (((j-1) * params$max_nPatch) + np)]}}
            
            
            # assign presence/absence
            
            occurrence[[i]][[j]] <- landscapeR::makeClass(empty_raster,
                                                          npatch = np,
                                                          size = sz,
                                                         pts = seed_loc_subset)
        }
    }
}

# write rasters to file -------------------------------------------------------

dir.create(paste0("output/sim_occurrence/", now))


if(exists("phy")){
    
    dir.create(paste0("output/sim_occurrence/", now, "/phy1"))
    
    for(i in 1:length(phy$tip.label)){
    
    raster::writeRaster(occurrence[[i]],
                        paste0("output/sim_occurrence/", now, "/phy1/",
                               phy$tip.label[i], "_occurrence"),
                        format = "GTiff")
    }
}


if(exists("phy_lst")){
    
    for(i in 1:length(phy_lst)){
        
        dir.create(paste0("output/sim_occurrence/", now, "/phy", i))
    }
    
    for(i in 1:length(phy_lst)){
        
        for(j in 1:length(phy_lst[[i]]$tip.label)){
            
            raster::writeRaster(occurrence[[i]][[j]],
                                paste0("output/sim_occurrence/", now, "/phy",
                                       i, "/", phy_lst[[i]]$tip.label[j],
                                       "_occurrence"),
                                format = "GTiff")
        }
    }
}


# remove unneeded objects -----------------------------------------------------

rm(list = setdiff(ls(), c("now", "params")))
