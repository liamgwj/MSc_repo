# LJ started: 2021-06-25 last updated: 2021-10-10

# Calculate habitat suitability and connectivity based on available hosts.

# requires object 'now' (date/time ID for the run)

# requires packages...

# set up file paths -----------------------------------------------------------

dir.create(paste0("output/", now, "/rangeshiftr"), showWarnings = TRUE)
dirpath = paste0("output/", now, "/rangeshiftr/")

dir.create(paste0(dirpath,"Inputs"), showWarnings = TRUE)
dir.create(paste0(dirpath,"Outputs"), showWarnings = TRUE)
dir.create(paste0(dirpath,"Output_Maps"), showWarnings = TRUE)


# load simulated data ---------------------------------------------------------

# choose a phylogeny [TBR with looping structure]

j = 0


# read in character state data associated with phylogeny

# complete data

char <- read.csv(paste0("output/", now, "/character-states/complete/",
                        "charComplete_phy", j, "_", now, ".csv"))

colnames(char) <- c("tip", "hostStatus")

## [when looping - add known and estimated data]


# subset to only host taxa

hosts <- subset(char, hostStatus == "Host")


# read in host occurrence rasters

host_occurrence <- vector("list", nrow(hosts))

for(i in 1:nrow(hosts)){
    
    host_occurrence[[i]] <- raster::raster(paste0("output/", now, 
                                                  "/occurrence/phy", j, "/",
                                                  "occurrence_phy", j, "-",
                                             hosts$tip[i], "_", now, ".asc"))
}


# combine host rasters into one suitability landscape

suitability_map <- host_occurrence[[1]]

for(i in 2:length(host_occurrence)){
  suitability_map <- suitability_map + host_occurrence[[i]]
}

# check landscape
table(raster::values(suitability_map))
raster::plot(suitability_map)

# temporary hack to rescale landscape values:
# multiply all cell values by 10 and set those >100 to 100

suitability_map <- suitability_map * 10
suitability_map[which(suitability_map[]>100)] <- 100

# write landscape to file
raster::writeRaster(suitability_map,
                    paste0(dirpath, "Inputs",
                           "/phy", j, "_suitability"),
                    format = "ascii",
                    # datatype = "INT2S",
                    overwrite = TRUE)


# specify initial cells where the organism is present

init_cells <- raster::raster(matrix(0,
                                    nrow(host_occurrence[[1]]),
                                    ncol(host_occurrence[[1]])),
                             xmn = 0, xmx = nrow(host_occurrence[[1]]),
                             ymn = 0, ymx = ncol(host_occurrence[[1]]))

init_cells[1:nrow(host_occurrence[[1]]), 1:4] <- 1 # line along left margin

# check
raster::plot(init_cells)

# write to file
raster::writeRaster(init_cells,
                    paste0(dirpath, "Inputs",
                           "/initial_occurrence"),
                    format = "ascii",
                    datatype = "INT2S",
                    overwrite = TRUE)


# we're now ready to assemble the input modules for RangeShiftR

library(RangeShiftR)

# landscape

land_mod <- ImportedLandscape(LandscapeFile = "phy0_suitability.asc",
                              Resolution = 1,
                              HabPercent = TRUE,
                              # Nhabitats = length(unique(suitability_map[])),
                              K_or_DensDep = 100,
                              PatchFile = "NULL",
                              CostsFile = "NULL",
                              DynamicLandYears = 0,
                              SpDistFile = "initial_occurrence.asc",
                              SpDistResolution = 1)


# demography

demog_mod <- Demography(StageStruct = StageStructure(Stages = 3, 
                                                     TransMatrix = matrix(c(0, 1, 0, 0, 0.1, 0.4, 100, 0, 0.8), nrow = 3, byrow = F),
                                                     MaxAge = 100,
                                                     SurvSched = 1),
                        ReproductionType = 0)   # female-only model


# dispersal

disp_mod <-  Dispersal(Emigration = Emigration(DensDep = FALSE,
                                               StageDep = TRUE,
                                               EmigProb = cbind(0:2,
                                                                c(0.9, 0, 0))),
                       Transfer = DispersalKernel(Distances = cbind(0:2,
                                                                c(100, 1, 1)),
                                                  DoubleKernel = FALSE,
                                                  SexDep = FALSE,
                                                  StageDep = TRUE,
                                                  IndVar = FALSE,
                                                  # TraitScaleFactor = ,
                                                  DistMort = FALSE,
                                                  MortProb = 0.0),
                       Settlement = Settlement()
)


# initial population

init_mod <- Initialise(InitType = 1,       # from loaded species dist. map
                       SpType = 0,         # all suitable cells
                       InitDens = 1,       # at 1/2 k
                       # IndsHaCell = 10,
                       PropStages = c(0, 0.5, 0.5),
                       InitAge = 0)


# simulation [many additional arguments to go through here]

sim_mod <- Simulation(Simulation = 1,
                      Replicates = 5, 
                      Years = 50,
                      OutIntPop = 1,
                      OutIntOcc = 1,
                      OutIntRange = 1)


# combine modules into parameter master

sim_params <- RSsim(batchnum = 1,
                    simul = sim_mod,
                    land = land_mod,
                    demog = demog_mod,
                    dispersal = disp_mod,
                    # gene = ,
                    init = init_mod,
                    seed = 2021)


# run RangeShiftR simulation

RunRS(sim_params, dirpath)


# read in simulation output

col_stats <- ColonisationStats(sim_params, dirpath,
                               years = 20,
                               maps = TRUE)

# check

raster::plot(col_stats$map_occ_prob)

raster::plot(col_stats$map_col_time)



# plotting functions etc. from tutorial - unreformed and ugly atm

# Store underlying landscape map display for later:
bg <- function(main=NULL){
  levelplot(suitability_map, margin=F, scales=list(draw=FALSE),at=seq(.5,7.5,by=1), colorkey=F,
            col.regions = rev(brewer.pal(n = 7, name = "Greys") ), main=main)
}

# map occupancy probability on landscape background. For this, we first define a colorkey function
col.key <- function(mycol, at, space='bottom',pos=0.05, height=0.6, width=1) {
  key <- draw.colorkey(
    list(space=space, at=at, height=height, width=width,
         col=mycol)
  )
  key$framevp$y <- unit(pos, "npc")
  return(key)
}

# map occupancy probability
mycol_occprob <- colorRampPalette(c('blue','orangered','gold'))

mycol_coltime <- colorRampPalette(c('orangered','gold','yellow','PowderBlue','LightSeaGreen'))

# Map occupancy probabilities:
bg() + levelplot(col_stats_c$map_occ_prob, margin=F, scales=list(draw=FALSE), at=seq(0,1,length=11), col.regions=mycol_occprob(11))
grid.draw(col.key(mycol_occprob(11),at=seq(0,1,length=11)))

# Map colonisation time + background
bg() + levelplot(col_stats_c$map_col_time, margin=F, scales=list(draw=FALSE), at=c(-9,seq(-.001,100,length=11)), col.regions=c('blue',mycol_coltime(11)))
grid.draw(col.key(c('blue',mycol_coltime(11)), c(-9,seq(-.001,100,length=11))))

