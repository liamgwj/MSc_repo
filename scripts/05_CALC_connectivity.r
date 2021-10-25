# LJ started: 2021-06-25 last updated: 2021-10-10

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


# expand patches to simulate dispersal

for(i in 1:length(occurrence)){
  
  for(k in 1:params$dispMax){
    
    if(k==1){tmp_occ <- occurrence[[i]]}
    
    tmp_edge <- landscapemetrics::lsm_c_te(tmp_occ)$value[2]
    
    tmp_occ <- landscapeR::expandClass(context = tmp_occ,
                                       class = max(tmp_occ[]),
                                       size = tmp_edge,
                                       bgr = 0,
                                       pts = NULL)
  }
  
  tmp_lim <- max(occurrence[[i]][])
  
  tmp_occ[which(tmp_occ[]>0)] <- 10
  
  occurrence[[i]] <- occurrence[[i]] + tmp_occ
  
  occurrence[[i]][which(occurrence[[i]][]>10)] <- tmp_lim
  
}


# calculate habitat area and connectivity -------------------------------------

# generate base raster

for(i in 1:length(occurrence)){
    if(i==1){lim <- max(occurrence[[i]][])}else{
        if(max(occurrence[[i]][])>lim){
            lim <- max(occurrence[[i]][])
}}}

for(i in 1:length(occurrence)){
    if(i==1){lim_min <- min(occurrence[[i]][which(occurrence[[i]][]!=0)])}else{
        if(min(occurrence[[i]][which(occurrence[[i]][]!=0)])<lim_min){
            lim_min <- min(occurrence[[i]][which(occurrence[[i]][]!=0)])
        }}}


suitability <- raster::raster(matrix(0,
                                     nrow(occurrence[[1]]),
                                     ncol(occurrence[[1]])),
                              xmn = 0, xmx = nrow(occurrence[[1]]),
                              ymn = 0, ymx = ncol(occurrence[[1]]))


# suitability[250, 1:500] <- 1
# 
# suitability[1:225,200:300] <- -9999
# suitability[275:500,200:300] <- -9999

# combine with host rasters

for(i in 1:length(occurrence)){
    
    suitability <- suitability + occurrence[[i]]
}


suitability[which(suitability[]>lim)] <- lim_min

# suitability[which(suitability[]==0)] <- NA

# 
# landscapetools::show_landscape(suitability,
#                                # discrete=TRUE
#                                )

suitability[which(suitability[]==0)] <- -9999
# suitability[which(is.na(suitability[]))] <- -9999
 
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

if(!dir.exists(paste0("output/", now, "/input-maps/disp_", params$dispMax))){
  dir.create(paste0("output/", now, "/input-maps/disp_", params$dispMax))
}


# write suitability map to file

raster::writeRaster(suitability,
                    paste0("output/", now, "/input-maps/disp_",
                           params$dispMax, "/phy",
                           j, "_suitability"),
                    format = "ascii",
                    overwrite = TRUE)


# calculate habitat connectivity

# create source nodes

nodes <- raster::raster(matrix(-9999,
                               nrow(occurrence[[1]]),
                               ncol(occurrence[[1]])),
                        xmn = 0, xmx = nrow(occurrence[[1]]),
                        ymn = 0, ymx = ncol(occurrence[[1]]))

nodes@file@nodatavalue <- -9999

nodes[seq(from = 1, to = nrow(occurrence[[1]]), length.out = 10), 1] <- 1:10

nodes[seq(from = 1, to = nrow(occurrence[[1]]), length.out = 10), ncol(occurrence[[1]])] <- 11:20


# write to file

raster::writeRaster(nodes,
                    paste0("output/", now, "/input-maps/nodes"),
                    format = "ascii",
                    overwrite = TRUE)


# create .ini file for circuitscape run

if(!dir.exists(paste0("output/", now, "/circuitscape-output"))){
    dir.create(paste0("output/", now, "/circuitscape-output"))
}

if(!dir.exists(paste0("output/", now, "/circuitscape-output/disp_", params$dispMax))){
  dir.create(paste0("output/", now, "/circuitscape-output/disp_", params$dispMax))
}

writeLines(
    c("[Circuitscape Mode]",
      "data_type = raster",
      "scenario = pairwise",
      
      "[Version]",
      "version = 5.0.0",
      
      "[Habitat raster or graph]",
      paste0(
          "habitat_file = /home/liam/Documents/MSc/analysis/MSc_repo/output/",
          now, "/input-maps/disp_", params$dispMax, "/phy0_suitability.asc"),
      "habitat_map_is_resistances = resistances",
      
      "[Connection Scheme for raster habitat data]",
      "connect_four_neighbors_only = false",
      "connect_using_avg_resistances = false",
      
      "[Short circuit regions (aka polygons)]",
      "use_polygons = false",
      "polygon_file = False",
      
      "[Options for advanced mode]",
      "ground_file_is_resistances = true",
      "source_file = (Browse for a current source file)",
      "remove_src_or_gnd = keepall",
      "ground_file = (Browse for a ground point file)",
      "use_unit_currents = false",
      "use_direct_grounds = false",
      
      "[Mask file]",
      "use_mask = false",
      "mask_file = None",
      
      "[Options for one-to-all and all-to-one modes]",
      "use_variable_source_strengths = false",
      "variable_source_file = None",
      
      "[Options for pairwise and one-to-all and all-to-one modes]",
  "included_pairs_file = (Browse for a file with pairs to include or exclude)",
      "use_included_pairs = false",
      paste0(
          "point_file = /home/liam/Documents/MSc/analysis/MSc_repo/output/",
          now, "/input-maps/nodes.asc"),
      
      "[Calculation options]",
      "solver = cg+amg",
      
      "[Output options]",
      "write_cum_cur_map_only = false",
      "log_transform_maps = false",
      paste0(
          "output_file = /home/liam/Documents/MSc/analysis/MSc_repo/output/",
          now, "/circuitscape-output/disp_", params$dispMax, "/", now),
      "write_max_cur_maps = false",
      "write_volt_maps = true",
      "set_null_currents_to_nodata = false",
      "set_null_voltages_to_nodata = false",
      "compress_grids = false",
      "write_cur_maps = true"
    ),
    con = paste0("output/", "lastRun.ini"))


# run circuitscape

XRJulia::juliaUsing("Circuitscape")

XRJulia::juliaCommand(paste0("compute(\"/home/liam/Documents/MSc/analysis",
                             "/MSc_repo/output/lastRun.ini\")"))



# check output

suitPlot <- suitability
suitPlot[which(suitPlot[]==-9999)] <- NA

png(paste0("output/", now, "/", now, "_resistance_d",
           params$dispMax, ".png"),
    width = 960,
    height = 960)

# landscapetools::show_landscape(suitPlot)
raster::plot(suitPlot, col=viridis::viridis(10))

dev.off()

d5_curmap <- raster::raster(paste0("output/", now, "/circuitscape-output/disp_", params$dispMax, "/",
                                     now, "_cum_curmap.asc"))

# d10_curmap <- raster::raster(paste0("output/", now, "/circuitscape-output/disp_", params$dispMax, "/",
                                   # now, "_cum_curmap.asc"))

# d15_curmap <- raster::raster(paste0("output/", now, "/circuitscape-output/",
                                   # now, "_cum_curmap.asc"))




# raster::plot(test_curmap,
#              zlim=c(0.00001,max(test_curmap[])),
#              breaks=c(seq(from=0,
#                           to=max(test_curmap[]),
#                           length.out=30)),
#              col=heat.colors(30)
#              )

# raster::plot(test_curmap)


ttmap <- d5_curmap

# ttmap[which(ttmap[]<0.00001)] <- NA

png(paste0("output/", now, "/", now, "_current_d", params$dispMax, ".png"),
    width = 960,
    height = 960)

raster::plot(ttmap)

dev.off()

# landscapetools::show_landscape(ttmap)

# d <- raster::stack(d5_curmap, d10_curmap, d15_curmap)
# raster::layerStats(d, 'pearson', na.rm=T)



# spatialEco::rasterCorrelation(d5_curmap, d10_curmap,
#                               s = 3, type = "spearman")
# 
# spatialEco::rasterCorrelation(d5_curmap, d15_curmap,
#                   s = 3, type = "spearman")
# 
# spatialEco::rasterCorrelation(d10_curmap, d15_curmap,
#                   s = 3, type = "spearman")

########using omniscape########################################################
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
