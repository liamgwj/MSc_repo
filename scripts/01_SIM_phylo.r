# LJ started: 2021-06-25 last updated: 2021-09-22

# Simulate the specified number of phylogenies, each with the specified number
# of tips.

# requires packages 'ape', 'TreeSim'

# optional setup --------------------------------------------------------------

# if desired, specify the date/time ID to use and read in the corresponding
# parameter file - when sourcing this script from '00_SIM_params_source.r' the
# ID and parameter objects present in the environment will be used

# set ID

# now <- "YYYY-MM-DDThh:mm:ss"


# read in input parameters

# params <- read.csv(paste0("output/SIM_parameters/", now, "_params.csv"))


# simulation ------------------------------------------------------------------

# simulate phylogenies

phy_all <- TreeSim::sim.bd.taxa(n = params$nTips,
                       numbsim = params$nPhy,
                       lambda = params$lambda,
                       mu = params$mu,
                       complete = FALSE # don't include extinct tips
                       )


# write phylogenies to file
# all phylogenies are appended to a single file in Newick format

for(i in 1:length(phy_all)){
    
    ape::write.tree(phy_all[[i]],
                    paste0("output/sim_phylogenies/", now, ".nwk"),
                    append = TRUE)
}



# remove unneeded objects -----------------------------------------------------

rm(list = setdiff(ls(), c("now", "params")))
