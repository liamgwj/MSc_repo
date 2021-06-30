# LJ 2021-06-25

# Use phylogeny/ancestral state reconstruction to predict character states of taxa with unknown host status.

# requires package 'picante'

# environment must contain 'phy', 'char_known', 'now'


# phylogenetic prediction
# Use ancestral state reconstruction to estimate missing trait values

char_estim <- picante::phyEstimateDisc(phy = phy,
                              trait = factor(as.data.frame(t(
                                              na.omit(char_known)))),
                              best.state = TRUE,
                              cutoff = 0.5) # assign state with >50% support


# compile list of all known and predicted hosts

char_all <- char_known

for(i in 1:nrow(char_all)){
    
    if(is.na(char_all$hostStatus[i])){
        
        char_all$hostStatus[i] <- char_estim$estimated.state[
                                        which(rownames(char_estim) %in%
                                                  rownames(char_known)[i])]
    }}


# write to file

write.csv(char_all,
          paste0("output/CALC_charStates/", now,
                 "_charEst.csv"))
