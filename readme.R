---
title: "Holocene biomes dynamic"
author: "Vincent Pellissier"
date: "29 août 2018"
output: html_document
---

# Spatial dynamic of the biomes through the Holocene

While organizing a workshop on the impact of human activities on biodiversity at different spatial
scales, I realized that a good entry point would be to illustrate how some physical features of
the environment (for example biome area, as defined as the area of a biome not being covered by land-use) 
have changed through time.

## The historical land-use dataset
The HYDE 3.2 dataset is a well-known reconstruction of past land-use (from the beginning of the Holocene to present day). For each time point the percentage of each cell being cropland (divided into irrigated and rain-fed non-rice crops and irrigated and rain-fed rice crops) or grazing land (divided into intensive pasture and less intensive rangeland) is modelled based on population estimates. The whole data set comprises 67 series of maps: for each time point, a map for each of the above land-cover was produced. In addition, at each time point, three different population estimate are used (lower, median and upper)

## Outputs
I had two visual outputs in mind. (1) A temporal graph of the total area for each simplified biomes (Boreal forests, Temperate forests, Tropical forests, Temperate grasslands, Tropical grasslands, Desert and Other biomes) and (2) a series of chronological maps showing the variation of the extant of each biome through time

## Methods
### Downloading and extracting maps
On the HYDE website, maps are downloadable either one by one (that is, for each point in time, one has to select the desired population scenario, format, date and type of land-cover)
 



```{r cars}
summary(cars)
```

## Including Plots

You can also embed plots, for example:

```{r pressure, echo=FALSE}
plot(pressure)
```

Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.
