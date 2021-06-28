# LJ 2021-06-25

library(ape)
library(geiger)
library(TreeSim)

# read in input parameters

params <- read.csv(paste0("output/SIM_parameters/", now, "_params.csv"))

# Simulate host phylogenies

phy_lst <- sim.bd.taxa(n = params$nTips, # number of tips on each phylogeny
                       numbsim = params$nPhy, # number of phylogenies
                       lambda = 0.2, # speciation rate
                       mu = 0.1, # extinction rate
                       complete = FALSE) #,
                       # stochsampling = FALSE,
                       # frac = 0.8)

# write phylogenies to file

for(i in 1:length(phy_lst)){

    write.tree(phy_lst[[i]],
               paste0("output/sim_phylogenies/", now, ".nwk"),
               append = TRUE)
}
