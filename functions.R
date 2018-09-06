library(seleniumPipes)
library(raster)

# download a HYDE3.2 for a given date, land cover type and scenario in a temp directory
dl_land_use <- function(date, lu_type, scenario, tmpdir, remDr){
    if(!dir.exists(file.path(tmpdir, date)))
        dir.create(file.path(tmpdir, date), recursive = TRUE)
    
    cat("A Chrome windows will open shortly, do not close it!")
    Sys.sleep(3)
    
    go(remDr, "https://easy.dans.knaw.nl/ui/datasets/id/easy-dataset:67445/tab/2")
    
    findElement(remDr, using = "xpath", value = paste0("//span[text()='", scenario, "']")) %>%
        elementClick()
    findElement(remDr, using = "xpath", value = "//span[text()='asc']") %>%
        elementClick()
    findElement(remDr, using = "xpath", value = paste0("//span[text()='", date, "_lu']")) %>%
        elementClick()
    findElement(remDr, using = "xpath", value = paste0("//span[text()='", lu_type, date, ".asc']")) %>%
        elementClick()
}

# computes the proportion in each cell NOT covered by a human land-cover, 
# for each biome and for a given date and scenario (saved as a stacked raster)
# Takes a biomes raster as argument (found in https://github.com/vpellissier/holocene_biomes_dynamics/Original data)
compute_non_human <- function(date, scenario, raster_biomes, save_path){
    tp <- tempdir()
    
    eCaps <- list(
        chromeOptions = 
            list(prefs = list(
                "profile.default_content_settings.popups" = 0L,
                "download.prompt_for_download" = FALSE,
                "download.default_directory" = file.path(tp, date)
            )
            )
    )
    
    remDr <- remoteDr(browserName = "chrome", port = 4444L, extraCapabilities = eCaps)
    
    # download raster files (.asc) for the given date and three land-cover 
    # (pasture, cropland and rangeland) in a temporary file
    sapply(c("pasture", "cropland", "rangeland"), 
           function(x) dl_land_use(date, x, scenario, tmpdir = tp, remDr = remDr))
    
    Sys.sleep(15)
    cat("Waiting for the download to finish...")
    
    # load the downloaded raster into the environment
    pasture <- raster(dir(file.path(tp, date), pattern="pasture", full.names=T))
    rangeland <- raster(dir(file.path(tp, date), pattern="rangeland", full.names=T))
    cropland <- raster(dir(file.path(tp, date), pattern="cropland", full.names=T))
    
    alcc <- (cropland + pasture + rangeland) / 100 # computes total human land-cover in each cell (proportion)

    # computes the proportion in each cell NOT covererd by human land-cover, for each biome
    list_rasters_biomes <- sapply(seq(16), 
                                  function(x) (raster_biomes == x) * (1- alcc))
    stacked_raster_biomes <- stack (list_rasters_biomes)
    writeRaster(stacked_raster_biomes, file.path(save_path, paste0("biomes_", date, ".tiff")))
    
    # removes the temp directory
    unlink(file.path(tp, date), recursive = T)
    deleteSession(remDr)
}    
