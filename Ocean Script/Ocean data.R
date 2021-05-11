library(tidyverse)
library(raster)
library(ncdf4)
library(lubridate)
library(rworldmap)
library(sf)

# get map by cropping; practice for cropping
test.map <- getData('worldclim', var="bio", res=10)
#worldmap <- rworldmap::getMap(resolution = "coarse")
#out <- crop(test.map$bio14, extent(70,105,-10,70))
#test.map <- worldmap %>% rasterize(out)

#find the file 
test <- "sg532_tseries_flagged_quenching_corrected_v3.nc"
#open the .nc file to see its content
id_579 <- nc_open(test)
#start taking values and coordinates for the file 
lon<-ncvar_get(id_579, "longitude")
lat<-ncvar_get(id_579, "latitude")
oxygen<-ncvar_get(id_579, "oxygen")
depth<-ncvar_get(id_579, "depth")
temp<-ncvar_get(id_579, "temp_flag")
#function that extract time and units for nc
date <- getNcTime(id_579)


#get the world-climate map - just for mapping processes
test.map <- getData('worldclim', var="bio", res=10)
#crop extent
test.map <- crop(test.map$bio14, extent(70,105,-10,70))
 



#convert data into a dataframe
tt <- data.frame(x=lon, y=lat, z=oxygen, date)
#extract dates
tt$day <- day(tt$date)
tt$month <- month(tt$date)
#separate the dates from the time
dataset <-  tt %>% 
  mutate(time = format(date, '%T'), date = as.Date(date))
#arrange the data
dataset <- dataset %>% arrange(x)
#remove the NAs
dataset <- dataset[complete.cases(dataset),]
#Convert to raster
oxy.data <- rasterFromXYZ(dataset)
#assign a crs definition
crs(oxy.data)<- "+proj=longlat +datum=WGS84 +no_defs"


#oxy.agg <- aggregate(oxy.data, fact=10)



#potential to try:

#take the unique values from coordinates and date, then create a column with dates
#extract the coordiantes and convert into a shapefile
#transfer the data into the WGS84 projection
#buffer a 5 degree distance around each ponit
#nest the data within the dates
dataset.expand1 <- dataset %>% 
  distinct(z, x, y, date) %>% 
  # for 2019 use 2018 landcover data
  mutate(year_lc = if_else(as.integer(date) > 2013, 
                           as.character(date), as.character(date))) %>% 
  # convert to spatial features
  st_as_sf(coords = c("x", "y"), crs = 4326) %>% 
  # transform to tif projection
  st_transform(crs = projection(test.map)) %>% 
  # nest by year
  nest(data = c(date, z, geometry))
#arrange
dataset.expand1 <- dataset.expand1 %>% arrange(year_lc)
#glimpse into the outcome
# A tibble: 15 x 2
#year_lc    data                 
#<chr>      <list>               
#  1 2016-07-02 <tibble [10,139 x 3]>
#  2 2016-07-03 <tibble [14,846 x 3]>
#  3 2016-07-04 <tibble [14,048 x 3]>
#  4 2016-07-05 <tibble [14,322 x 3]>
#  5 2016-07-06 <tibble [11,915 x 3]>
#  6 2016-07-07 <tibble [12,066 x 3]>
#  7 2016-07-08 <tibble [13,973 x 3]>
#  8 2016-07-09 <tibble [14,401 x 3]>
#  9 2016-07-10 <tibble [13,296 x 3]>
#  10 2016-07-11 <tibble [14,262 x 3]>
#  11 2016-07-12 <tibble [14,292 x 3]>
#  12 2016-07-13 <tibble [12,956 x 3]>
#  13 2016-07-14 <tibble [11,083 x 3]>
#  14 2016-07-15 <tibble [14,130 x 3]>
#  15 2016-07-16 <tibble [2,687 x 3]> 


#aggregate the lists into a single dataframe;

#loop all the dates into a single dataframe
dataset.expand.one1<-NULL
for(i in 1:length(dataset.expand1$year_lc)){
dataset.expand.one1[[i]] = dataset.expand1$data[i] %>%
  dplyr::bind_rows() %>% #bind the list into a data.frame
  sf::st_cast(to = "POINT") %>% #convert polygon to a list of points
  dplyr::mutate(
    X =  sf::st_coordinates(geometry)[,1], #retrieve X coord
    Y =  sf::st_coordinates(geometry)[,2]  #retrieve Y coord
  ) %>%
  sf::st_drop_geometry() #drop the geometry column
}
#bind them by row
dataset.bind <- do.call(rbind.data.frame, dataset.expand.one1)

#rasterize the dataset
dataset.raster <- dataset.bind[, -1] %>% st_as_sf(coords = c("X", "Y"), crs = 4326) %>% st_transform(crs = projection(test.map)) %>% rasterize(test.map)


#plot the data
#plot(test.map$bio14)
#plot(dataset.raster$z, add=TRUE, legend=FALSE)

#looking at the maps you can see the buffer around the points the data was collected from at th Bay of bengal.
#lets merge the data together to see the distribution of the points
map.merge <- merge(test.map$bio14, dataset.raster$z)

brks <- seq(0, r_max, by = 0.006)

cols <- colorRampPalette(c("red4","gray95","orange","gold","lightskyblue","dodgerblue","blue3"))(length(brks)-1) #this is the colour ramp - change the colours as you like, bu make sure they are symetrical around the "gray95", which represents the zero point!

plot(p.urban, 
     col = cols, breaks = brks, 
     maxpixels = ncell(p.urban),
     legend = FALSE, add = TRUE)
points(ixy_urban[, 1:2], add=TRUE, pch=1, cex=1, col="blue")


plot(map.merge)
zoom(map.merge)

#create a time-series to better understand the map

time.series <- tt[complete.cases(tt),]
time.series <- time.series %>% arrange(date)
time.series$day <- day(time.series$date)
#time.series1 <- ts(time.series$z)

plot(time.series1)
library(scales)
p <- ggplot(time.series, aes(x = date, y = z)) +
  geom_line() + facet_wrap(~day, scales="free") +
  #Here is where I format the x-axis
  scale_x_datetime(labels = date_format("%Y-%m-%d %H"),
                   date_breaks = "8 hours") 
