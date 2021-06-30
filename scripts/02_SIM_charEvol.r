# LJ 2021-06-25

# Simulate evolution of a discrete binary character on a set of provided phylogenies, then sample a subset of this character information.

# requires package 'ape'

# optional setup ---------------------------------------------------------

# if desired, specify the date/time ID to use and read in the corresponding parameter file - when sourcing this script from '00_SIM_params_source.r' the ID and parameter objects present in the environment will be used

# set ID

# now <- "2021-06-29_13:41:48"


# read in input parameters

# params <- read.csv(paste0("output/SIM_parameters/", now, "_params.csv"))


# simulation -------------------------------------------------------------

# read in phylogenies

phy_lst <- ape::read.tree(paste0("output/sim_phylogenies/", now, ".nwk"))


# simulate character evolution for all tips

char_lst_complete <- vector("list", length(phy_lst))


for(i in 1:length(phy_lst)){
     char_lst_complete[[i]] <- ape::rTraitDisc(phy = phy_lst[[i]],
                                      model = "ER", # equal-rates model
                                      k = 2, # number of character states
                                      rate = params$trait_rate,
                                      states = c("NonHost", "Host"),
                                      freq = rep(1/2, 2), # equal equilibrium relative frequencies for each state
                                      ancestor = FALSE, # return only tips
                                      root.value = 1) # initially non-host
}


# simulate incomplete host data by randomly removing a subset of the complete character information (proportion removed is set in simulation parameters)

char_lst_known <- char_lst_complete


for(i in 1:length(char_lst_known)){

    nTip <- length(phy_lst[[i]]$tip.label)

    missing_vals <- sample(1:nTip,
                           round(nTip * params$prop_missing, 0))

    char_lst_known[[i]][missing_vals] <- NA
}


# write character states to file

dir.create(paste0("output/sim_hostStatus/", now))
dir.create(paste0("output/sim_hostStatus/", now, "/complete"))
dir.create(paste0("output/sim_hostStatus/", now, "/known"))


for(i in 1:length(phy_lst)){

    write.csv(data.frame(hostStatus = char_lst_complete[[i]]),
              paste0("output/sim_hostStatus/", now, "/complete",
                     "/phy", i, "_charComplete.csv"))

    write.csv(data.frame(hostStatus = char_lst_known[[i]]),
              paste0("output/sim_hostStatus/", now, "/known",
                     "/phy", i, "_charKnown.csv"))
}


# remove unneeded objects

rm(list = setdiff(ls(), c("now", "params")))
