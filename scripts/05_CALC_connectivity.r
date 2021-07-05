# LJ 2021-06-25

# Calculate habitat suitability and connectivity based on available hosts.

# requires packages 'raster', 'XRJulia'


# load simulated data ----------------------------------------------------

# choose simulation ID

now <- "2021-06-30_11:22:13"


# choose a phylogeny associated with chosen ID

j = 1


# read in character state data associated with chosen ID and phylogeny

char <- read.csv(paste0("output/CALC_charStates/", now,
                        "/phy", j, "_charEst.csv"),
                 row.names = 1)


# subset to only host taxa

hosts <- subset(char, hostStatus == "Host")


# read in host occurrence rasters

occurrence <- vector("list", nrow(hosts))


for(i in 1:nrow(hosts)){
    
    occurrence[[i]] <- raster::raster(paste0("output/sim_occurrence/",
                                             now, "/phy", j, "/",
                                             rownames(hosts)[i],
                                             "_occurrence.tif"))
}


# calculate habitat area and connectivity -------------------------------

# for now, we'll consider cell suitability to be equivalent to the number of compatible hosts present in the cell, up to a maximum value of 4

# sum host rasters to determine suitable habitat (to avoid divisions by zero when running omniscape, a background value of 1 is added to all cells)

# generate base raster

suitability <- raster::raster(matrix(1,
                                     nrow(occurrence[[1]]),
                                     ncol(occurrence[[1]])),
                              xmn = 0, xmx = 10,
                              ymn = 0, ymx = 10)


# combine with host rasters

for(i in 1:length(occurrence)){
    
    suitability <- suitability + occurrence[[i]]
}


# set all cell values >5 to 5

suitability[which(suitability[] > 5 )] <- 5


# write suitability map to file

if(!dir.exists("output/sim_suitability")){
    dir.create("output/sim_suitability")
}

dir.create(paste0("output/sim_suitability/", now))


raster::writeRaster(suitability,
                    paste0("output/sim_suitability/", now,
                           "/phy", j, "_suitability"),
                    format = "GTiff")


# calculate habitat connectivity

# create directories for omniscape run

if(!dir.exists("output/omniscape")){
    dir.create("output/omniscape")
}

dir.create(paste0("output/omniscape/", now))

dir.create(paste0("output/omniscape/", now, "/ini_files"))

dir.create(paste0("output/omniscape/", now, "/output_maps"))


# create omniscape initialization file

writeLines(paste(paste0("resistance_file = ", getwd(),
                        "/output/sim_suitability/", now,
                        "/phy", j, "_suitability.tif"),
                 "radius = 20",
                 "block_size = 3",
                 paste0("project_name = ", getwd(),
                        "/output/omniscape/", now,
                        "/output_maps/phy", j, "_connectivity"),
                 "source_from_resistance = true",
                 "resistance_is_conductance = true",
                 "calc_normalized_current = true",
                 "calc_flow_potential = true",
                 "parallelize = false",
                 "write_raw_currmap = true",
                 sep = "\n"),
           con = paste0("output/omniscape/", now,
                        "/ini_files/phy", j, ".ini")
           )


# run omniscape (outputs are written to file)

XRJulia::juliaUsing("Omniscape")

XRJulia::juliaCommand(paste0("run_omniscape(\"", getwd(),
                             "/output/omniscape/", now,
                             "/ini_files/phy", j,
                             ".ini\"::String)"))
