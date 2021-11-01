# LJ started: 2021-06-25 last updated: 2021-10-10

# Use phylogeny/ancestral state reconstruction to predict character states of
# taxa with unknown host status.

## LOOPING STRUCTURE NOT COMPLETE

# requires object 'now' (unique date/time ID)

# requires package 'picante' to be installed


# load simulated data ---------------------------------------------------------

# read in all phylogenies associated with current ID

phy_lst <- ape::read.tree(paste0("output/", now, "/phylogenies_", now, ".nwk"))

# select one phylogeny to use for this round of ancestral state reconstruction

j = 1

phy <- phy_lst[[j]]


# read in incomplete character state data corresponding to the selected phylogeny

char_known <- read.csv(paste0("output/", now, "/character-states/known/",
                              "charKnown_", "phy", j, "_", now, ".csv"),
                       row.names = 1)


# phylogenetic prediction ------------------------------------------------

# use ancestral state reconstruction to estimate missing trait values

char_estim <- picante::phyEstimateDisc(phy = phy,
                              trait = factor(as.data.frame(t(
                                              na.omit(char_known)))),
                              best.state = TRUE,
                              cutoff = 0.5) # assign state with >50% support


# combine known and estimated trait information

char_all <- char_known

for(i in 1:nrow(char_all)){
    
    if(is.na(char_all$hostStatus[i])){
        
        char_all$hostStatus[i] <- char_estim$estimated.state[
                                        which(rownames(char_estim) %in%
                                                  rownames(char_known)[i])]
    }}


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

if(!dir.exists(paste0("output/", now, "/character-states/predicted"))){
    dir.create(paste0("output/", now, "/character-states/predicted"))
}


# write to file

write.csv(char_all,
          paste0("output/", now, "/character-states/predicted",
                 "charPredicted_", "phy", j, "_", now, ".csv"))
