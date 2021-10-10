# LJ started: 2021-06-25 last updated: 2021-10-10

# Simulate phylogenies according to the specified parameters

# requires objects 'params' (parameter master) and 'now' (unique date/time ID)

# requires packages 'ape', 'TreeSim' to be installed


# simulate phylogenies --------------------------------------------------------

phy_all <- TreeSim::sim.bd.taxa(n = params$nTips,
                                numbsim = params$nPhy,
                                lambda = params$lambda,
                                mu = params$mu,
                                complete = FALSE # don't include extinct tips
)


# check for output directories, creating them if necessary --------------------

if(!dir.exists("output")){
    dir.create("output")
}

if(!dir.exists("output/", now)){
    dir.create("output/", now)
}


# write phylogenies to file ---------------------------------------------------
# all phylogenies are appended to a single file in Newick format

for(i in 1:length(phy_all)){
    
    ape::write.tree(phy_all[[i]],
                    paste0("output/", now, "/",
                           "phylogenies_", now, ".nwk"),
                    append = TRUE)
}


# remove unneeded objects -----------------------------------------------------

rm(list = setdiff(ls(), c("now", "params")))
