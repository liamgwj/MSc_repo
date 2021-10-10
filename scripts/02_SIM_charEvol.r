# LJ started: 2021-06-25 last updated: 2021-10-10

# Simulate evolution of either a discrete binary character or a continuous
# character on a set of provided phylogenies, then sample a subset of this
# character information.

# requires objects 'params' (parameter master) and 'now' (unique date/time ID)

# requires package 'ape' to be installed


# read in phylogeny/ies -------------------------------------------------------

phy_tmp <- ape::read.tree(paste0("output/", now, "/",
                                 "phylogenies_", now, ".nwk"))


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


# discrete character ----------------------------------------------------------

if(params$trait_type == "discrete"){
    
    # single phylogeny --------------------------------------------------------
    
    if(exists("phy")){
        
        # simulate character evolution
        
        char_complete <- ape::rTraitDisc(phy = phy,
                                            model = params$disc_model,
                                            k = 2, # no. character states
                                            rate = params$trait_rate,
                                            states = c("NonHost", "Host"),
                                            freq = rep(1/2, 2), # equal
                                            # equilibrium relative frequencies
                                            # for each state
                                            ancestor = FALSE, #return only tips
                                            root.value = params$root_value)
        
        
        # simulate incomplete host data by randomly removing a subset of the
        # complete character information (proportion removed is set in
        # simulation parameters)
        
        char_known <- char_complete
        
        nTip <- length(phy$tip.label)
        
        missing_vals <- sample(1:nTip,
                               round(nTip * params$prop_missing, 0))
        
        char_known[missing_vals] <- NA
    }
    
    # multiple phylogenies ----------------------------------------------------
    
    if(exists("phy_lst")){
        
        # pre-allocate list for output
        
        char_lst_complete <- vector("list", length(phy_lst))
        
        # simulate character evolution
        
        for(i in 1:length(phy_lst)){
            char_lst_complete[[i]] <- ape::rTraitDisc(phy = phy_lst[[i]],
                                                     model = params$disc_model,
                                                     k = 2, # number of states
                                                     rate = params$trait_rate,
                                                 states = c("NonHost", "Host"),
                                                    freq = rep(1/2, 2), # equal
                                            # equilibrium relative frequencies
                                            # for each state
                                                     ancestor = FALSE, # return
                                            # only tips
                                                root.value = params$root_value)
        }
        
        
        # simulate incomplete host data
        
        char_lst_known <- char_lst_complete
        
        
        for(i in 1:length(char_lst_known)){
            
            nTip <- length(phy_lst[[i]]$tip.label)
            
            missing_vals <- sample(1:nTip,
                                   round(nTip * params$prop_missing, 0))
            
            char_lst_known[[i]][missing_vals] <- NA
        }
    }
}


# continuous character --------------------------------------------------------

if(params$trait_type == "continuous"){

    # single phylogeny --------------------------------------------------------
    
    if(exists("phy")){
        
        # simulate character evolution
        
        char_complete <- ape::rTraitCont(phy = phy,
                                         model = params$cont_model,
                                         sigma = params$sigma,
                                         alpha = params$alpha,
                                         theta = params$theta,
                                         ancestor = FALSE,
                                         root.value = params$root_value)
        
        
        # simulate incomplete host data
        
        char_known <- char_complete
        
        nTip <- length(phy$tip.label)
        
        missing_vals <- sample(1:nTip,
                               round(nTip * params$prop_missing, 0))
        
        char_known[missing_vals] <- NA
    }
    
    
    # multiple phylogenies ----------------------------------------------------
    
    if(exists("phy_lst")){
        
        # pre-allocate list for output
        
        char_lst_complete <- vector("list", length(phy_lst))
        
        # simulate character evolution
        
        for(i in 1:length(phy_lst)){
            char_lst_complete[[i]] <- ape::rTraitCont(phy = phy_lst[[i]],
                                                     model = params$cont_model,
                                                      sigma = params$sigma,
                                                      alpha = params$alpha,
                                                      theta = params$theta,
                                                      ancestor = FALSE,
                                                root.value = params$root_value)
        }
        
        
        # simulate incomplete host data
        
        char_lst_known <- char_lst_complete
        
        
        for(i in 1:length(char_lst_known)){
            
            nTip <- length(phy_lst[[i]]$tip.label)
            
            missing_vals <- sample(1:nTip,
                                   round(nTip * params$prop_missing, 0))
            
            char_lst_known[[i]][missing_vals] <- NA
        }
    }
    
}


# check for output directories, creating them if necessary --------------------

if(!dir.exists("output")){
    dir.create("output")
}

if(!dir.exists(paste0("output/", now))){
    dir.create(paste0("output/", now))
}

if(!dir.exists(paste0("output/", now, "/character-states"))){
    dir.create(paste0("output/", now, "/character-states"))
}

if(!dir.exists(paste0("output/", now, "/character-states/complete"))){
    dir.create(paste0("output/", now, "/character-states/complete"))
}

if(!dir.exists(paste0("output/", now, "/character-states/known"))){
    dir.create(paste0("output/", now, "/character-states/known"))
}


# write character states to file ----------------------------------------------

# single phylogeny

if(exists("phy")){
    
    write.csv(char_complete,
              paste0("output/", now, "character-states/complete/",
                     "charComplete_phy0_", now, ".csv"))
    
    write.csv(char_known,
              paste0("output/", now, "/character-states/known/",
                     "charKnown_phy0_", now, ".csv"))
}


# multiple phylogenies

if(exists("phy_lst")){
    
    for(i in 1:length(phy_lst)){
    
        write.csv(data.frame(hostStatus = char_lst_complete[[i]]),
                  paste0("output/", now, "/character-states/complete/",
                         "charComplete_", "phy", i, "_", now, ".csv"))
    
        write.csv(data.frame(hostStatus = char_lst_known[[i]]),
                  paste0("output/", now, "/character-states/known/",
                         "charKnown_", "phy", i, "_", now, ".csv"))
    }
}


# remove unneeded objects -----------------------------------------------------

rm(list = setdiff(ls(), c("now", "params")))
