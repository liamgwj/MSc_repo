# LJ 2021-06-28

# central script from which to source subsequent script files

# generate unique date/time ID for this run

now <- gsub(" ", "_", Sys.time())


# set up input parameters and write them to file

params <- data.frame("nTips" = 20,
                     "nPhy" = 10,

                     "trait_rate" = 0.1,
                     "prop_missing" = 0.2,

                     "landscape_dim" = 1000,
                     "max_nPatch" = 10,
                     "max_patchSize" = 250,
                     "cooccurrence_pat" = "clustered") #one of "clustered", "random", "dispersed"


write.csv(params,
          paste0("output/SIM_parameters/", now, "_params.csv"),
          row.names = FALSE)


# source component scripts in order

# data simulation
source("scripts/01_SIM_phylo.r")
source("scripts/02_SIM_charEvol.r")
source("scripts/03_SIM_geoDistr.r")

# analysis calculations



# input_params <- expand.grid(trait_rate = c(0.05, 0.1, 0.2, 0.3),
#                             prop_missing = c(0.05, 0.1, 0.25, 0.5),
#                             coocurrence_pat = c("clustered",
#                                                 "random",
#                                                 "dispersed"))
