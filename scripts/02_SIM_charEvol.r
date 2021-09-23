# LJ started: 2021-06-25 last updated: 2021-09-22

# Simulate evolution of a discrete binary character on a set of provided
# phylogenies, then sample a subset of this character information.

# requires package 'ape'

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


# discrete trait --------------------------------------------------------------

if(params$trait_type == "discrete"){
    
    # single phylogeny --------------------------------------------------------
    
    if(exists("phy")){
        
        char_complete <- vector(length(phy$tip.label))
        
        char_complete[i] <- ape::rTraitDisc(phy = phy,
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
        
        char_lst_complete <- vector("list", length(phy_lst))
        
        
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
        
        
        # simulate incomplete host data by randomly removing a subset of the
        # complete character information (proportion removed is set in
        # simulation parameters)
        
        char_lst_known <- char_lst_complete
        
        
        for(i in 1:length(char_lst_known)){
            
            nTip <- length(phy_lst[[i]]$tip.label)
            
            missing_vals <- sample(1:nTip,
                                   round(nTip * params$prop_missing, 0))
            
            char_lst_known[[i]][missing_vals] <- NA
        }
    }
}


# continuous trait ------------------------------------------------------------

if(params$trait_type == "continuous"){

# single phylogeny ------------------------------------------------------------
    
    if(exists("phy")){
        
        char_complete <- ape::rTraitCont(phy = phy,
                                         model = params$cont_model,
                                         sigma = params$sigma,
                                         alpha = params$alpha,
                                         theta = params$theta,
                                         ancestor = FALSE,
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
    
    
# multiple phylogenies --------------------------------------------------------
    
    if(exists("phy_lst")){
        
        char_lst_complete <- vector("list", length(phy_lst))
        
        
        for(i in 1:length(phy_lst)){
            char_lst_complete[[i]] <- ape::rTraitCont(phy = phy_lst[[i]],
                                                     model = params$cont_model,
                                                      sigma = params$sigma,
                                                      alpha = params$alpha,
                                                      theta = params$theta,
                                                      ancestor = FALSE,
                                                root.value = params$root_value)
        }
        
        
        # simulate incomplete host data by randomly removing a subset of the
        # complete character information (proportion removed is set in
        # simulation parameters)
        
        char_lst_known <- char_lst_complete
        
        
        for(i in 1:length(char_lst_known)){
            
            nTip <- length(phy_lst[[i]]$tip.label)
            
            missing_vals <- sample(1:nTip,
                                   round(nTip * params$prop_missing, 0))
            
            char_lst_known[[i]][missing_vals] <- NA
        }
    }
    
}


# write character states to file ----------------------------------------------

dir.create(paste0("output/sim_hostStatus/", now))
dir.create(paste0("output/sim_hostStatus/", now, "/complete"))
dir.create(paste0("output/sim_hostStatus/", now, "/known"))


if(exists("phy_lst")){
    
    for(i in 1:length(phy_lst)){
    
        write.csv(data.frame(hostStatus = char_lst_complete[[i]]),
                  paste0("output/sim_hostStatus/", now, "/complete",
                         "/phy", i, "_charComplete.csv"))
    
        write.csv(data.frame(hostStatus = char_lst_known[[i]]),
                  paste0("output/sim_hostStatus/", now, "/known",
                         "/phy", i, "_charKnown.csv"))
    }
}


if(exists("phy")){
    
    write.csv(char_complete,
              paste0("output/sim_hostStatus/", now,
                     "/complete/phy_charComplete.csv"))
    
    write.csv(char_known,
              paste0("output/sim_hostStatus/", now,
                     "/known/phy_charKnown.csv"))
}


# remove unneeded objects -----------------------------------------------------

rm(list = setdiff(ls(), c("now", "params")))
