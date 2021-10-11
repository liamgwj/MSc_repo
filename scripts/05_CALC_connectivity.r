# LJ started: 2021-06-25 last updated: 2021-10-10

## was having persistent circuitscape error - moved circuitscape back to older version and seems to have fixed it. maps are still bland but I think this is because the landscapes are too uniform - and boosting the background resistance leads to unsolvable landscapes. solution that i can think of is to expand patches by a mid-cost buffer the width of the dispersal distance (i think landscapeR can do this). probably want to test on a small, manually constructed landscape first.

# Calculate habitat suitability and connectivity based on available hosts.

# requires object 'now' (date/time ID for the run)

# requires packages 'raster', 'XRJulia'


# load simulated data ---------------------------------------------------------

# TEMPORARY: choose a phylogeny [TBR with looping structure]

j = 0


# read in character state data associated with phylogeny

# complete data

char <- read.csv(paste0("output/", now, "/character-states/complete/",
                        "charComplete_phy", j, "_", now, ".csv"))

colnames(char) <- c("tip", "hostStatus")

# MISSING: known and estimated data


# subset to only host taxa

hosts <- subset(char, hostStatus == "Host")


# read in host occurrence rasters

occurrence <- vector("list", nrow(hosts))


for(i in 1:nrow(hosts)){
    
    occurrence[[i]] <- raster::raster(paste0("output/", now, "/occurrence/phy",
                                             j, "/", "occurrence_phy", j, "-",
                                             hosts$tip[i], "_", now, ".asc"))
}


# calculate habitat area and connectivity -------------------------------------

# generate base raster

suitability <- raster::raster(matrix(20,
                                     nrow(occurrence[[1]]),
                                     ncol(occurrence[[1]])),
                              xmn = 0, xmx = 10,
                              ymn = 0, ymx = 10)


suitability[250, 1:500] <- 1

suitability[,1] <- 1
suitability[,500] <- 1

# combine with host rasters

for(i in 1:length(occurrence)){
    
    suitability <- suitability - occurrence[[i]]
}

raster::plot(suitability)

suitability@file@nodatavalue <- -9999

# check for output directories, creating them if necessary --------------------

if(!dir.exists("output")){
    dir.create("output")
}

if(!dir.exists(paste0("output/", now))){
    dir.create(paste0("output/", now))
}

if(!dir.exists(paste0("output/", now, "/input-maps"))){
    dir.create(paste0("output/", now, "/input-maps"))
}


# write suitability map to file

raster::writeRaster(suitability,
                    paste0("output/", now, "/input-maps/phy",
                           j, "_suitability"),
                    format = "ascii",
                    overwrite = TRUE)


# calculate habitat connectivity

## trial using circuitscape

# create source nodes

nodes <- raster::raster(matrix(-9999,
                               nrow(occurrence[[1]]),
                               ncol(occurrence[[1]])),
                        xmn = 0, xmx = 10,
                        ymn = 0, ymx = 10)

nodes@file@nodatavalue <- -9999

# nodes[250, 1] <- 1
# nodes[250, 500] <- 2

nodes[seq(from = 1, to = 500, by = 50), 1] <- 1:10

nodes[seq(from = 1, to = 500, by = 50), 500] <- 11:20

# nodes[251,500] <- -9999

# write to file

raster::writeRaster(nodes,
                    paste0("output/", now, "/input-maps/nodes"),
                    format = "ascii",
                    overwrite = TRUE)





XRJulia::juliaUsing("Circuitscape")

XRJulia::juliaCommand(paste0("compute(\"/home/liam/Documents/MSc/analysis/MSc_repo/output/", now, "/out.ini\")"))





test_curmap <- raster::raster(paste0("output/", now, "/out_cum_curmap.asc"))

test_voltmap <- raster::raster(paste0("output/", now, "/tmp-out_voltmap.asc"))


raster::plot(test_curmap)

raster::plot(test_voltmap)

raster::plot(suitability)








########using omniscape####################
# create directories for omniscape run
# 
# if(!dir.exists("output/omniscape")){
#     dir.create("output/omniscape")
# }
# 
# dir.create(paste0("output/omniscape/", now))
# 
# dir.create(paste0("output/omniscape/", now, "/ini_files"))
# 
# dir.create(paste0("output/omniscape/", now, "/output_maps"))
# 

# create omniscape initialization file

# writeLines(paste(paste0("resistance_file = ", getwd(),
#                         "/output/sim_suitability/", now,
#                         "/phy", j, "_suitability.tif"),
#                  "radius = 10",
#                  "block_size = 7",
#                  paste0("project_name = ", getwd(),
#                         "/output/omniscape/", now,
#                         "/output_maps/phy", j, "_connectivity"),
#                  "source_from_resistance = true",
#                  # "r_cutoff =5",
#                  "source_threshold = 20",
#                  "resistance_is_conductance = true",
#                  "calc_normalized_current = true",
#                  "calc_flow_potential = true",
#                  "parallelize = true",
#                  "write_raw_currmap = true",
#                  sep = "\n"),
#            con = paste0("output/omniscape/", now,
#                         "/ini_files/phy", j, ".ini")
#            )
# 
# 
# # run omniscape (outputs are written to file)
# 
# XRJulia::juliaUsing("Omniscape")
# 
# XRJulia::juliaCommand(paste0("run_omniscape(\"", getwd(),
#                              "/output/omniscape/", now,
#                              "/ini_files/phy", j,
#                              ".ini\"::String)"))
# 
# 
# # inspect output
# 
# cum_currmap <- raster::raster(paste0("output/omniscape/",
#                                      now, "/output_maps",
#                                      "/phy", j, 
#                                      "_connectivity/cum_currmap.tif"))
# 
# normalized_cum_currmap <- raster::raster(paste0("output/omniscape/",
#                                      now, "/output_maps",
#                                      "/phy", j, 
#                                      "_connectivity/normalized_cum_currmap.tif"))
# 
# flow_potential <- raster::raster(paste0("output/omniscape/",
#                                      now, "/output_maps",
#                                      "/phy", j, 
#                                      "_connectivity/flow_potential.tif"))
# 
# 
# raster::plot(suitability)
# 
# raster::plot(cum_currmap)
# 
# raster::plot(normalized_cum_currmap)
# 
# raster::plot(flow_potential)
