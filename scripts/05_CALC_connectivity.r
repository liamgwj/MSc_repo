# LJ 2021-06-25

# requires packages 'raster', 'XRJulia'

# assess available habitat

# For now, we'll consider cell suitability to be equivalent to the number of compatible hosts present in each cell, calculated by summing the host rasters.

# Calculate habitat suitability

suitability <- raster::raster(matrix(1,
                                     nrow(occurrence[[1]]),
                                     ncol(occurrence[[1]])),
                              xmn = 0, xmx = 10,
                              ymn = 0, ymx = 10)

for(i in 1:nrow(char)){
    
    if(char$hostStatus[i] == "Host"){
        
        suitability <- suitability + occurrence[[i]]
}}


suitability[which(suitability[] > 5 )] <- 5


# Write suitability map to file

dir.create(paste0("output/sim_suitability/", now))

raster::writeRaster(suitability,
            paste0("output/sim_suitability/", now,
                   "/phy", 1, "_suitability"),
            format = "GTiff", overwrite=TRUE)


## assess connectivity

dir.create(paste0("output/omniscape/", now))
dir.create(paste0("output/omniscape/", now, "/ini_files"))
dir.create(paste0("output/omniscape/", now, "/output_maps"))

writeLines(paste0("resistance_file = ", getwd(),
            "/output/sim_suitability/", now, "/phy", 1, "_suitability.tif\n",
"radius = 20
block_size = 3
project_name = ", getwd(), "/output/omniscape/", now, "/output_maps/phy", 1, "_connectivity\n",
"source_from_resistance = true
resistance_is_conductance = true
calc_normalized_current = true
calc_flow_potential = true
parallelize = false
write_raw_currmap = true"),
            con = paste0("output/omniscape/", now, "/ini_files/phy", 1, ".ini"), sep="\n")


XRJulia::juliaUsing("Omniscape")

XRJulia::juliaCommand(paste0("run_omniscape(\"",
                             getwd(),
                             "/output/omniscape/",
                             now,
                             "/ini_files/phy",
                             1,
                             ".ini\"::String)"))
