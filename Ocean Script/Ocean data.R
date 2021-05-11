library(tidyverse)
library(raster)
library(ncdf4)
library(lubridate)
library(rworldmap)
library(sf)

# get map by cropping; practice for cropping
test.map <- getData('worldclim', var="bio", res=10)
worldmap <- rworldmap::getMap(resolution = "coarse")
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
test.map <- crop(test.map, extent(70,105,-10,70))
 
test.map <- worldmap %>% rasterize(test.map, field=1)


#convert data into a dataframe
tt <- data.frame(x=lon, y=lat, z=oxygen,depth,  date)
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
#aggregate to get a finer resolution
oxy.agg <- aggregate(oxy.data, fact=20)

#plot
r_max <- ceiling(10 * cellStats(oxy.agg, max)) / 10
brks <- seq(0, r_max, by = 34.7)
brks
cols <- colorRampPalette(c("red4","orange","gold","lightskyblue","dodgerblue","blue3"))(length(brks)-1) #this is the colour ramp - change the colours as you like, bu make sure they are symetrical around the "gray95", which represents the zero point!

plot(oxy.agg, 
     col = cols, breaks = brks, 
     maxpixels = ncell(oxy.agg),
     legend = TRUE )

#statistical tests
#depth range
 seq(0, max(dataset$depth), 100.8374)
#[1]    0.0000  100.8374  201.6748  302.5122  403.3496  504.1870  605.0244  705.8618  806.6992  907.5366 1008.3740
myIntervals <- c("0 - 100", "100 - 200", "200 - 300", "300 - 400","400 - 500","500 - 600","600 - 700","700 - 800","800 - 900","900 - 1010")
dataset$depth_range<- myIntervals[findInterval(dataset$depth, c(0, 100.8374, 201.6748, 302.5122, 403.3496, 504.1870, 605.0244, 705.8618, 806.6992, 907.5366, 1008.3740))]
dataset$depth_range <- as.factor(dataset$depth_range)
#oxygen range
seq(0, 209.5374, 20.95374)
# [1]   0.00000  20.95374  41.90748  62.86122  83.81496 104.76870 125.72244 146.67618 167.62992 188.58366 209.53740
myIntervals <- c("0 - 21", "21 - 41", "41 - 61", "61 - 81","81 - 101","101 - 121","121 - 141","141 - 161","161 - 181","181 - 201", "201-211")
dataset$oxygen_range<- myIntervals[findInterval(dataset$z, c(0, 20.95374, 41.90748, 62.86122, 83.81496, 104.76870, 125.72244, 146.67618, 167.62992, 188.58366, 209.53740))]
dataset$oxygen_range <- as.factor(dataset$oxygen_range)
#fix the wrong order
dataset$oxygen_range <- factor(dataset$oxygen_range, levels=levels(dataset$oxygen_range)[order(as.numeric(gsub("( -.*)", "", levels(dataset$oxygen_range))))])


#count the frequency by their ranges; To test the distribution of data collected from the glider

ranges <- dataset %>% count(depth_range, oxygen_range, day) %>% group_by(day)
#glimpse
# A tibble: 332 x 4
# Groups:   day [15]
#depth_range oxygen_range   day     n
#<chr>       <chr>        <int> <int>
#  1 0 - 100     101 - 121        2   416
#2 0 - 100     101 - 121        3   566
#3 0 - 100     101 - 121        4   440
#4 0 - 100     101 - 121        5   459
#5 0 - 100     101 - 121        6   753
#6 0 - 100     101 - 121        7   612
#7 0 - 100     101 - 121        8   643
#8 0 - 100     101 - 121        9   499
#9 0 - 100     101 - 121       10   940
#10 0 - 100     101 - 121       11   611
# ... with 322 more rows


ranges <- data.frame(ranges)
#arrange order
ranges$depth_range <- factor(ranges$depth_range, levels=levels(ranges$depth_range)[order(as.numeric(gsub("( -.*)", "", levels(ranges$depth_range))))])
ranges <- ranges[order(ranges$depth_range), ]
str(ranges)
#split data into wide

#ranges <- dataset %>% count(depth_range, oxygen_range) %>% group_by(oxygen_range)
#ranges <- aggregate(n~oxygen_range+depth_range, ranges, sum)
#ranges <- ranges %>% pivot_wider(names_from = oxygen_range, values_from = n, values_fill=list(n=0))
#ranges[, c(1, c(10, 11, 12, 2, 4, 5, 6, 7, 8, 9))]
#names(ranges)[2:12] <- paste0("ranges_", names(ranges)[2:12])

#str(ranges)
#'data.frame':	332 obs. of  4 variables:
#  $ depth_range : chr  "0 - 100" "0 - 100" "0 - 100" "0 - 100" ...
#$ oxygen_range: chr  "101 - 121" "101 - 121" "101 - 121" "101 - 121" ...
#$ day         : int  2 3 4 5 6 7 8 9 10 11 ...
#$ n           : int  416 566 440 459 753 612 643 499 940 611 ...

#factorise the character data
ranges[,1:2] <- lapply(ranges[,1:2], as.factor)

#fit onto a multiple-linear regression after fitting hist for normality; data shows some partial skewness though we'll fit  the mlm anyways
library(olsrr)
hist(sqrt(ranges$n))
#mlm
mlm.dataset <- lm(log(n)~depth_range+oxygen_range+day, ranges)
#stepforward
step.dataset <- ols_step_forward_p(mlm.dataset, p.enter = 0.05)
summary(step.dataset$model)

#Linear model shows that as the number of counts collected from the glider for increase increases, then it declines as the days progress
#A lot of negative estimates, perhaps related towards the decline in accuracy and data-collection from the float over-time
#Counts increase with depth, though increase in counts have a potential decrease in oxygen increase?
#Though a better test may be necessary given that normality was weak, and further assumptions will need to be considered like colinearity between variables.

#Coefficients:

#  Estimate Std. Error t value Pr(>|t|)    
#(Intercept)            5.82102    0.39905  14.587  < 2e-16 ***
#  oxygen_range21 - 41   -1.58408    0.23673  -6.692 1.03e-10 ***
#  oxygen_range41 - 61   -1.64861    0.35243  -4.678 4.33e-06 ***
#  oxygen_range61 - 81   -1.28990    0.35330  -3.651 0.000306 ***
#  oxygen_range81 - 101  -0.86208    0.35433  -2.433 0.015537 *  
#  oxygen_range101 - 121 -0.42899    0.35118  -1.222 0.222804    
#oxygen_range121 - 141 -0.11510    0.48074  -0.239 0.810930    
#oxygen_range141 - 161  0.63774    0.48074   1.327 0.185614    
#oxygen_range161 - 181 -1.39896    0.48074  -2.910 0.003875 ** 
#  oxygen_range181 - 201 -2.54797    0.48074  -5.300 2.20e-07 ***
#  oxygen_range201-211   -5.66754    1.24722  -4.544 7.90e-06 ***
#  depth_range100 - 200   0.66111    0.28620   2.310 0.021544 *  
#  depth_range200 - 300   0.19288    0.39770   0.485 0.628025    
#depth_range300 - 400   1.84981    0.48074   3.848 0.000145 ***
#  depth_range400 - 500   1.76826    0.48074   3.678 0.000277 ***
#  depth_range500 - 600   1.74791    0.48074   3.636 0.000324 ***
#  depth_range600 - 700   1.77561    0.48074   3.694 0.000261 ***
#  depth_range700 - 800   0.14827    0.41936   0.354 0.723904    
#depth_range800 - 900   1.13086    0.44863   2.521 0.012213 *  
#  depth_range900 - 1010  2.25778    0.49681   4.545 7.89e-06 ***
#  day                   -0.03837    0.01525  -2.516 0.012389 *  
#  ---
#  Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

#Residual standard error: 1.188 on 311 degrees of freedom
#Multiple R-squared:  0.534,	Adjusted R-squared:  0.504 
#F-statistic: 17.82 on 20 and 311 DF,  p-value: < 2.2e-16


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
map.merge <- merge(test.map, dataset.raster$z)



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
