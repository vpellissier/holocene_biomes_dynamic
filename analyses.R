library(raster)
library(snowfall)
library(dplyr)
library(tibble)
library(rasterVis)
library(ggplot2)
library(tidyr)
library(here)

# Downloading and processing the maps (only run once)
source("./holocene_biomes_dynamic/functions.R")

stacked_raster_path <- "./holocene_biomes_dynamic/Processed data/stacked_biomes"

dates <- c("10000BC", "9000BC", "8000BC", "7000BC", "6000BC", "5000BC", "4000BC", "3000BC",
           "2000BC", "1000BC", "0AD", "500AD", "1000AD", "1100AD", "1200AD", "1300AD", "1400AD", 
           "1500AD", "1600AD", "1700AD", "1710AD", "1720AD", "1730AD",   "1740AD", "1750AD", 
           "1760AD", "1770AD", "1780AD", "1790AD", "1800AD", "1810AD", "1820AD", "1840AD", 
           "1850AD", "1860AD", "1870AD", "1880AD", "1890AD", "1900AD", "1910AD", "1920AD", 
           "1930AD", "1940AD", "1950AD", "1960AD", "1970AD", "1980AD", "1990AD", "2000AD", 
           "2001AD", "2002AD", "2003AD", "2004AD", "2005AD", "2006AD", "2007AD", "2008AD", 
           "2009AD", "2010AD", "2011AD", "2012AD", "2013AD", "2014AD", "2015AD", "2016AD")

sapply(dates, function(time_point){
    try(compute_non_human(date, "upper", 
                          raster_biomes, 
                          save_path = raster_path))
})


##################################################################################
#             Mapping the biome extant through time                              #
##################################################################################
# Here, in order to make the respresentation clearer, only the cells with less than 50% of their 
# areas as human land-cover are considered as belonging to the biome
# For the sake of representation, only a few stapple date are represented but the rasters are computed 
# for all the dates
raster_biomes <- raster("./holocene_biomes_dynamic/Original data/biomes.tif")
#dataframe matching biomes names and numeric code (embedded in the biome raster)
biomes_codes <- attr(raster_biomes@data, "attributes")[[1]] 

stacked_raster_path <- "./holocene_biomes_dynamic/Processed data/stacked_biomes"
biomes_extent_path <- "./holocene_biomes_dynamic/Processed data/temporal_extent_biomes"

dates <- c("10000BC", "9000BC", "8000BC", "7000BC", "6000BC", "5000BC", "4000BC", "3000BC",
           "2000BC", "1000BC", "0AD", "500AD", "1000AD", "1100AD", "1200AD", "1300AD", "1400AD", 
           "1500AD", "1600AD", "1700AD", "1710AD", "1720AD", "1730AD",   "1740AD", "1750AD", 
           "1760AD", "1770AD", "1780AD", "1790AD", "1800AD", "1810AD", "1820AD", "1840AD", 
           "1850AD", "1860AD", "1870AD", "1880AD", "1890AD", "1900AD", "1910AD", "1920AD", 
           "1930AD", "1940AD", "1950AD", "1960AD", "1970AD", "1980AD", "1990AD", "2000AD", 
           "2001AD", "2002AD", "2003AD", "2004AD", "2005AD", "2006AD", "2007AD", "2008AD", 
           "2009AD", "2010AD", "2011AD", "2012AD", "2013AD", "2014AD", "2015AD", "2016AD")

# Creating maps of biome extant (one map per date and per biome, stored in separate directories)
sapply(seq(16), function(biome_value){
    biome_name <- biomes_codes$category[biomes_codes$ID == biome_value]
    biome_path <- file.path(biomes_extent_path, biome_name)
    
    if(!dir.exists(biome_path))
        dir.create(path = biome_path)
    
    sapply(rasters, function(r){
        r_date <- raster(file.path(stacked_raster_path, r), band = biome_value)
        values(r_date)[values(r_date) < 0.5] <- 0
        d <- gsub("biomes_", "", r)
        d <- gsub(".tif", "", d)
        writeRaster(r_date, 
                    file.path(biomes_extent_path, biome_name, paste0(biome_name, "_", d, ".tif")))
    })
})



# Creating a visual representation for Temperate grasslands and 12 points in time (for the sake of simplicity):
#10000BC, 5000BC, 3000BC, 0AD, 500AD, 1500AD, 1750AD, 1800AD, 1900AD, 1950AD, 1975AD, 2016AD
dates <- c("10000BC", "5000BC", "3000BC", "0AD", 
           "500AD", "1500AD", "1750AD", "1800AD",
           "1900AD", "1950AD", "1970AD", "2016AD")


r.list <- sapply(dates, function(d) raster(file.path(biomes_extent_path, 
                                                 "Temperate Grasslands, Savannas and Shrublands", 
                                                 paste0("Temperate Grasslands, Savannas and Shrublands_", 
                                                        d, ".tif"))))
r.stack <- stack(r.list)
labels <- c(X10000BC = "10000BC", X5000BC = "5000BC", X3000BC = "3000BC", X0AD = "0AD", 
            X500AD = "500AD", X1500AD = "1500AD", X1750AD = "1750AD", X1800AD = "1800AD",
            X1900AD = "1900AD", X1950AD = "1950AD", X1970AD = "1970AD", X2016AD = "2016AD")

gplot(cut(r.stack, breaks= c(-0.1,0.49,0.6,0.7,0.8,0.9,1))) +
    geom_tile(aes(fill = as.factor(value))) +
    scale_discrete_manual(values = c("#D3D3D3", "#FE2200", "#FE9000", "#FFFF00", 
                                     "#7AAB01","#006100"), aesthetics = "fill",
                          name = "Percentage of non\n human land-cover",
                          labels = c("<50% or NA", "50-60%", "60-70%", "70-80%", 
                                     "80-90%", "90-100%", ""),
                          na.value = "white")+
    coord_equal(expand = 0)+
    theme(panel.spacing = unit(3, units = "points"),
          plot.background = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.border = element_blank(),
          axis.ticks = element_blank(),
          axis.text = element_blank(),
          axis.title = element_blank())+
    facet_wrap(~variable, ncol = 3, labeller = labeller(variable = labels))



#################################################################################
#             Computing total area of each biome at each time point             #
#################################################################################
# 1/ Computing total area of each biome at each time point
raster_biomes <- raster("./holocene_biomes_dynamic/Original data/biomes.tif")
#dataframe matching biomes names and numeric code (embedded in the biome raster)
biomes_codes <- attr(raster_biomes@data, "attributes")[[1]] 

rasters <- dir(stacked_raster_path, pattern = ".tif")

sfInit(parallel=TRUE, cpus=6)
sfExport("raster")
df_area_biomes <- sfApply(rasters, function(r){
                    raster_area <- area(raster(file.path(stacked_raster_path, r)))
                    sapply(seq(16), function(layer){
                        biomes_area <- raster(file.path(stacked_raster_path, r), band = layer) * raster_area
                        sum(biomes_area[], na.rm = T)
                        })
                    })

write.table(df_area_biomes, file.path(stacked_raster_path, "df_area_biomes.txt")) # Saving intermediary results

# 2/ Creating a final table to plot the results
# df_area_biomes <- read.table(file.path(stacked_raster_path, "df_area_biomes.txt")) # Only run if the above already ran
# Adding biome names as rownames
rownames(df_area_biomes) <- as.character(biomes_codes$category[-1])

# Computing the percentage remaining of the initial (10000BC) area for each biome
df_area_biomes <- apply(df_area_biomes, 2, function(x){
                        x / df_area_biomes[,grep("10000BC", colnames(df_area_biomes))] *100
                        })

# Transforming the data in long table and adding a year column (using 2016 as present date)
df_area_long <- as.data.frame(t(df_area_biomes)) %>%
                    rownames_to_column(var = "year_AD_BC") %>%
                    gather(Biome, Area, -year_AD_BC) %>%
                    mutate(year_AD_BC = gsub("biomes_", "", year_AD_BC)) %>%
                    mutate(year_AD_BC = gsub(".tif", "", year_AD_BC)) %>%
                    mutate(AD_or_BC = substr(year_AD_BC, nchar(year_AD_BC) - 1, nchar(year_AD_BC ))) %>%
                    mutate(year_BP = as.numeric(substr(year_AD_BC, 1, nchar(year_AD_BC) - 2))) %>%
                    mutate(year_BP = year_BP * ifelse(AD_or_BC == "BC", -1, 1) - 2017)# %>%

# 3/ Plotting the results
p <- ggplot(df_area_long, aes(x = log(-year_BP), y = Area, fill = Biome, color = Biome))+
        geom_area(alpha = .55) +
        geom_line(size=1)+
        scale_x_reverse(
                    labels = scales::math_format(10^.x))+
        scale_fill_manual(values = col.biomes, guide = FALSE) +
        scale_color_manual(values = col.biomes, guide = FALSE) + 
        ylab("Percentage of the initial area")+
        xlab("Time before present (years)")+
        facet_wrap(~Biome, ncol=4, labeller = label_wrap_gen())
p



