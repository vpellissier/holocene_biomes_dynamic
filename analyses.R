library(raster)
raster("C:/Users/vincent/Documents/holocene_biomes_dynamic/Original data/biomes.tif")
biomes_codes <- attr(rr@data, "attributes")[[1]] #dataframe matching biomes names and numeric code (embedded in the biome raster)

# Simplifying the biomes into broader categories to simplify vizualization
list_biomes <- list("Boreal forest" = c("Boreal Forests/Taiga"),
                    "Temperate forest" = c("Mediterranean Forests, Woodlands and Scrub",
                                           "Temperate Broadleaf and Mixed Forests",
                                           "Temperate Conifer Forests" ),
                    "tropical forest" = c("Tropical and Subtropical Coniferous Forests",
                                          "Tropical and Subtropical Dry Broadleaf Forests",
                                          "Tropical and Subtropical Moist Broadleaf Forests"), 
                    "Temperate grassland" = c("Temperate Grasslands, Savannas and Shrublands"),
                    "Tropical grassland" = c("Tropical and Subtropical Grasslands, Savannas and Shrublands", 
                                             "Flooded Grasslands and Savannas"),
                    "Desert" = c("Deserts and Xeric Shrublands", "Tundra"),
                    "Other" = c("Inland Water", "Mangroves", "Rock and Ice", 
                                "Montane Grasslands and Shrublands"))

for(date in dates){
    for(biome in names(list_biomes)){
        
        biomes_in_biome <- biomes_codes$ID[biomes_codes$category %in% list_biomes[["Temperate forest"]]]
        
        list_raster <- sapply(biomes_in_biome, function(code){
            raster(file.path("C:/Users/vincent/Documents/holocene_biomes_dynamic/Processed data",
                             paste0("biomes_", date, ".tif")), band = code)})
                         
        # calculer surface dans chaque biome
        # additionner les differents rasters
                         
                         
    }
}


biomes_codes$ID[biomes_codes$category %in% temperate_forest]
