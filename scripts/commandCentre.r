
# generate unique date/time ID for this run

now <- gsub(" ", "T", Sys.time())


# set dispersal level

disp_level <- 5

# source all scripts

source("scripts/00_SIM_inputParams.r")
source("scripts/01_SIM_phylo.r")
source("scripts/02_SIM_charEvol.r")
source("scripts/03_SIM_geoDistr.r")
source("scripts/05_CALC_connectivity.r")

# increase dispersal

disp_level <- 10
source("scripts/00_SIM_inputParams.r")
source("scripts/05_CALC_connectivity.r")


disp_level <- 15
source("scripts/00_SIM_inputParams.r")
source("scripts/05_CALC_connectivity.r")
