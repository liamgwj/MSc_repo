# LJ 2021-06-25

library(picante)

# read in phylogeny

i = 1

phy_lst <- read.tree(paste0("output/sim_phylogenies/", now, ".nwk"))

phy <- phy_lst[[i]]

# read in incomplete character data

char_known <- read.csv(paste0("output/sim_hostStatus/", now, "/known",
                              "/phy", i, "_charKnown.csv"),
                       row.names = 1)


# phylogenetic prediction
# Use ancestral state reconstruction to estimate missing trait values

char_estim <- phyEstimateDisc(phy = phy,
                              trait = factor(as.data.frame(t(
                                              na.omit(char_known)))),
                              best.state = TRUE,
                              cutoff = 0.5)


# compile list of all known and predicted hosts

char_all <- char_known

for(i in 1:nrow(char_all)){
    
    if(is.na(char_all$hostStatus[i])){
        
        char_all$hostStatus[i] <- char_estim$estimated.state[
                                        which(rownames(char_estim) %in%
                                                  rownames(char_known)[i])]
    }}