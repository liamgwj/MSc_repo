#LJ 2021-10-22 troubleshooting circuitscape

now <- gsub(" ", "T", Sys.time())

if(!dir.exists("output")){
    dir.create("output")
}

if(!dir.exists(paste0("output/", now))){
    dir.create(paste0("output/", now))
}

if(!dir.exists(paste0("output/", now, "/input-maps"))){
    dir.create(paste0("output/", now, "/input-maps"))
}


# none ####
type <- "none"

suitability <- raster::raster(matrix(0,
                                     100,
                                     100),
                              xmn = 0, xmx = 100,
                              ymn = 0, ymx = 100)

### linear ####
type <- "linear"

suitability <- raster::raster(matrix(1000,
                                     100,
                                     100),
                              xmn = 0, xmx = 100,
                              ymn = 0, ymx = 100)

suitability[50, 1:100] <- 1
suitability[1:100, 1] <- 1
suitability[1:100, 100] <- 1

### linear in infinite matrix ####
type <- "linear_inf"

suitability <- raster::raster(matrix(0,
                                     100,
                                     100),
                              xmn = 0, xmx = 100,
                              ymn = 0, ymx = 100)

suitability[50, 1:100] <- 1
suitability[1:100, 1] <- 1
suitability[1:100, 100] <- 1

# stepping stone
type <- "dashed"

suitability <- raster::raster(matrix(1000,
                                     100,
                                     100),
                              xmn = 0, xmx = 100,
                              ymn = 0, ymx = 100)

suitability[50, c(1:10, 20:30, 40:50, 60:70, 80:90)] <- 1


# diffuse ######
type <- "diffuse"

suitability <- raster::raster(matrix(1000,
                                     100,
                                     100),
                              xmn = 0, xmx = 100,
                              ymn = 0, ymx = 100)

# disjunct patch ####
type <- "disjunct"

suitability[45:55, 45:55] <- 1

# patch in resistant matrix
type <- "island"

suitability <- raster::raster(matrix(1000,
                                     100,
                                     100),
                              xmn = 0, xmx = 100,
                              ymn = 0, ymx = 100)

suitability[45:55, 45:55] <- 1

type <- "island_hi"

suitability <- raster::raster(matrix(10000,
                                     100,
                                     100),
                              xmn = 0, xmx = 100,
                              ymn = 0, ymx = 100)

suitability[45:55, 45:55] <- 1


# linear route
type <- "line"

suitability <- raster::raster(matrix(1000,
                                     100,
                                     100),
                              xmn = 0, xmx = 100,
                              ymn = 0, ymx = 100)

suitability[48:52, 10:90] <- 1



raster::plot(suitability)

suitability[which(suitability[]==0)] <- -9999

suitability@file@nodatavalue <- -9999

raster::writeRaster(suitability,
                    paste0("output/", now, "/input-maps/resistance"),
                    format = "ascii",
                    overwrite = TRUE)

# create source nodes

sources <- raster::raster(matrix(-9999,
                               100,
                               100),
                        xmn = 0, xmx = 100,
                        ymn = 0, ymx = 100)

sources@file@nodatavalue <- -9999

sources[seq(from = 1, to = 100, length.out = 10), 1] <- 1

raster::writeRaster(sources,
                    paste0("output/", now, "/input-maps/sources"),
                    format = "ascii",
                    overwrite = TRUE)

# create sink nodes

sinks <- raster::raster(matrix(-9999,
                               100,
                               100),
                        xmn = 0, xmx = 100,
                        ymn = 0, ymx = 100)

sinks@file@nodatavalue <- -9999

sinks[seq(from = 1, to = 100, length.out = 10), 100] <- 1

raster::writeRaster(sinks,
                    paste0("output/", now, "/input-maps/sinks"),
                    format = "ascii",
                    overwrite = TRUE)

# create .ini file for circuitscape run

if(!dir.exists(paste0("output/", now, "/circuitscape-output"))){
    dir.create(paste0("output/", now, "/circuitscape-output"))
}

writeLines(
    c("[Circuitscape Mode]",
      "data_type = raster",
      "scenario = advanced",
      
      "[Version]",
      "version = 5.0.0",
      
      "[Habitat raster or graph]",
      paste0(
          "habitat_file = /home/liam/Documents/MSc/analysis/MSc_repo/output/",
          now, "/input-maps/resistance.asc"),
      "habitat_map_is_resistances = resistances",
      
      "[Connection Scheme for raster habitat data]",
      "connect_four_neighbors_only = false",
      "connect_using_avg_resistances = false",
      
      "[Short circuit regions (aka polygons)]",
      "use_polygons = false",
      "polygon_file = False",
      
      "[Options for advanced mode]",
      "ground_file_is_resistances = true",
      paste0(
        "source_file = /home/liam/Documents/MSc/analysis/MSc_repo/output/",
        now, "/input-maps/sources.asc"),
      "remove_src_or_gnd = keepall",
      paste0(
        "ground_file = /home/liam/Documents/MSc/analysis/MSc_repo/output/",
        now, "/input-maps/sinks.asc"),
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
      "point_file = (Browse for file with locations of focal points or regions)",
      
      "[Calculation options]",
      "solver = cg+amg",
      
      "[Output options]",
      "write_cum_cur_map_only = false",
      "log_transform_maps = false",
      paste0(
          "output_file = /home/liam/Documents/MSc/analysis/MSc_repo/output/",
          now, "/circuitscape-output/", now),
      "write_max_cur_maps = false",
      "write_volt_maps = false",
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

curmap <- raster::raster(paste0("output/", now, "/circuitscape-output/",
                         now, "_curmap.asc"))

png(paste0("output/", now, "/", type, "_curmap.png"),
    width = 960,
    height = 960)

raster::plot(curmap, col=viridis::viridis(10))

dev.off()

png(paste0("output/", now, "/", type, "_hist.png"),
    width = 500,
    height = 400)

hist(curmap[], main="",xlab="current value")

dev.off()

suitability[which(suitability[]==-9999)] <- NA

png(paste0("output/", now, "/", type, "_resistance.png"),
    width = 960,
    height = 960)

raster::plot(suitability, col=viridis::viridis(10))
dev.off()
