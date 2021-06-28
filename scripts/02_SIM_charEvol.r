# LJ 2021-06-25

library(ape)

# read in input parameters

params <- read.csv(paste0("output/SIM_parameters/", now, "_params.csv"))

# read in phylogenies

phy_lst <- read.tree(paste0("output/sim_phylogenies/", now, ".nwk"))


# Simulate character evolution

char_lst_true <- vector("list", length(phy_lst))

for(i in 1:length(phy_lst)){
     char_lst_true[[i]] <- rTraitDisc(phy = phy_lst[[i]],
                                      model = "ER",
                                      k = 2,
                                      rate = params$trait_rate,
                                      states = c("NonHost", "Host"),
                                      #freq = rep(1/k, k),
                                      ancestor = FALSE,
                                      root.value = 1)
}


# Simulate incomplete host information

char_lst_known <- char_lst_true

for(i in 1:length(char_lst_known)){

    nTip <- length(phy_lst[[i]]$tip.label)

    missing_vals <- sample(1:nTip,
                           round(nTip * params$prop_missing, 0))

    char_lst_known[[i]][missing_vals] <- NA
}


# write character states to file

dir.create(paste0("output/sim_hostStatus/", now))
dir.create(paste0("output/sim_hostStatus/", now, "/true"))
dir.create(paste0("output/sim_hostStatus/", now, "/known"))

for(i in 1:length(phy_lst)){

    write.csv(data.frame(hostStatus = char_lst_true[[i]]),
              paste0("output/sim_hostStatus/", now, "/true",
                     "/phy", i, "_charTrue.csv"))

    write.csv(data.frame(hostStatus = char_lst_known[[i]]),
              paste0("output/sim_hostStatus/", now, "/known",
                     "/phy", i, "_charKnown.csv"))
}
