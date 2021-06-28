# LJ 2021-06-25

library(XRJulia)

# read in character data

i = 1

char <- read.csv(paste0("output/sim_hostStatus/", now, "/true",
                        "/phy", i, "_charTrue.csv"),
                 row.names = 1)

# read in species occurrence rasters

occurrence <- vector("list", nrow(char))

for(j in 1:nrow(char)){
    
    occurrence[[j]] <- raster(paste0("output/sim_occurrence/", now, "/phy", i,
                                   "/", rownames(char)[j], "_occurrence.tif"))
}


## assess available habitat

# For now, we'll consider cell suitability to be equivalent to the number of compatible hosts present in each cell, calculated by summing the host rasters.

# Calculate habitat suitability

suitability <- raster(matrix(1, params$landscape_dim, params$landscape_dim),
                      xmn = 0, xmx = 10,
                      ymn = 0, ymx = 10)

for(j in 1:nrow(char)){
    
    if(char$hostStatus[j] == "Host"){
        
        suitability <- suitability + occurrence[[j]]
}}


suitability[which(suitability[] > 5 )] <- 5


# Write suitability map to file

dir.create(paste0("output/sim_suitability/", now))

writeRaster(suitability,
            paste0("output/sim_suitability/", now,
                   "/phy", i, "_suitability"),
            format = "GTiff", overwrite=TRUE)


## assess connectivity

dir.create(paste0("output/omniscape/ini_files/", now))
dir.create(paste0("output/omniscape/output_maps/", now))

writeLines(paste0("resistance_file = ", getwd(),
            "/output/sim_suitability/", now, "/phy", i, "_suitability.tif\n",
"radius = 20
block_size = 3
project_name = ", getwd(), "/output/omniscape/output_maps/", now, "/phy", i, "_connectivity\n",
"source_from_resistance = true
resistance_is_conductance = true
calc_normalized_current = true
calc_flow_potential = true
parallelize = false
write_raw_currmap = true"),
            con = paste0("output/omniscape/ini_files/", now, "/phy", i, ".ini"), sep="\n")


juliaUsing("Omniscape")

juliaCommand(paste0("run_omniscape(\"",
                    getwd(),
                    "/output/omniscape/ini_files/", now, "/phy", i, ".ini\"::String)"))