# LJ 2021-06-25

# Use phylogeny/ancestral state reconstruction to predict character states of taxa with unknown host status.

# requires package 'picante'


# load simulated data ----------------------------------------------------

# choose simulation ID

# now <- "2021-06-30_11:22:13"


# read in all phylogenies associated with chosen ID

phy_lst <- ape::read.tree(paste0("output/sim_phylogenies/", now, ".nwk"))

# select one phylogeny to use for this round of ancestral state reconstruction

j = 1

phy <- phy_lst[[j]]


# read in incomplete character state data corresponding to the selected phylogeny

char_known <- read.csv(paste0("output/sim_hostStatus/", now, "/known",
                              "/phy", j, "_charKnown.csv"),
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


# write to file

if(!dir.exists("output/CALC_charStates")){
    dir.create("output/CALC_charStates")
}

dir.create(paste0("output/CALC_charStates/", now))

write.csv(char_all,
          paste0("output/CALC_charStates/", now,
                 "/phy", j, "_charEst.csv"))
