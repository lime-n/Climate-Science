# Climate-Science

The folder `Ocean Script` provides the script that I used with the following data from: 
```Webber B.G.M.; Matthews A.; Queste B.Y.; Lee G.A.; Cobas-Garcia M.; Heywood K.J.; Vinayachandran P.N.(2019). Ocean glider data from five Seagliders deployed in the Bay of Bengal during the BoBBLE (Bay of Bengal Boundary Layer Experiment) project in July 2016. British Oceanographic Data Centre, National Oceanography Centre, NERC, UK. doi:10/dgvj.```

**Linear models, and statistical results are present in the R-script**

**Methodology**

The data for ID - 579 was extracted using R-studio, using the packages `ncdf4` and `getNCTime` to effectively retrieve the coordinates, oxygen, depth and time from the netCDF file. Furthermore, a template map was taken from an R-repositry this was to overlay the coordinates from the glider data to check whether it matches the metadata. The data went through a filtering processes to select for individual dates and duration, and finally it was made into a raster than aggregated by a factor of 20 to increase the resolutionary scale to provide a finer grain to pixel size, figure 1.

![alt text](https://i.stack.imgur.com/CzVpw.png)
Figure 1. Displays the path the glider has taken alongside with the varying concentrations of Oxygen

Lastly, the data went through a series of further filtering to group the values of depth and oxygen at intervals, the interval was calculated by dividing the max value by 10 and taking a sequence of that product from 0 to the max value, table 1.


Table 1. Displays the number of occurrences of varying intervals of oxygen concentrations collected by the glider at varying depths
```
#Depth beneath the surface in meters
#Column with ranges are the values of Oxygen collected by the glider that fall within one of those ranges.
# A tibble: 10 x 11
   depth_range `0 - 21` `21 - 41` `41 - 61` `61 - 81` `101 - 121` `121 - 141` `141 - 161` `161 - 181` `181 - 201` `201-211`
   <fct>          <int>     <int>     <int>     <int>       <int>       <int>       <int>       <int>       <int>     <int>
 1 0 - 100            0         0         0       116        8153        3757        7063        1170         294         1
 2 100 - 200       2713      2151      2345      4581        2615           0           0           0           0         0
 3 200 - 300      23123       540        28         1           0           0           0           0           0         0
 4 300 - 400      25481         0         0         0           0           0           0           0           0         0
 5 400 - 500      23197         0         0         0           0           0           0           0           0         0
 6 500 - 600      22976         0         0         0           0           0           0           0           0         0
 7 600 - 700      23782         0         0         0           0           0           0           0           0         0
 8 700 - 800       9272       492         0         0           0           0           0           0           0         0
 9 800 - 900       1015      7766         0         0           0           0           0           0           0         0
10 900 - 1010         0      8197         0         0           0           0           0           0           0         0
```

Statistical tests were then performed, and these were a multiple linear regression and a stepwise forward selection for the Minimum-Adequate Model (MAM). Given that the data had poor normality, it was then normalised under a log distribution. While the histogram continued to show slight skewness, the linear models were implemented regardless, figure 2. 

```
Coefficients:

  Estimate Std. Error t value Pr(>|t|)    
(Intercept)            5.82102    0.39905  14.587  < 2e-16 ***
  oxygen_range21 - 41   -1.58408    0.23673  -6.692 1.03e-10 ***
  oxygen_range41 - 61   -1.64861    0.35243  -4.678 4.33e-06 ***
  oxygen_range61 - 81   -1.28990    0.35330  -3.651 0.000306 ***
  oxygen_range81 - 101  -0.86208    0.35433  -2.433 0.015537 *  
  oxygen_range101 - 121 -0.42899    0.35118  -1.222 0.222804    
oxygen_range121 - 141 -0.11510    0.48074  -0.239 0.810930    
oxygen_range141 - 161  0.63774    0.48074   1.327 0.185614    
oxygen_range161 - 181 -1.39896    0.48074  -2.910 0.003875 ** 
  oxygen_range181 - 201 -2.54797    0.48074  -5.300 2.20e-07 ***
  oxygen_range201-211   -5.66754    1.24722  -4.544 7.90e-06 ***
  depth_range100 - 200   0.66111    0.28620   2.310 0.021544 *  
  depth_range200 - 300   0.19288    0.39770   0.485 0.628025    
depth_range300 - 400   1.84981    0.48074   3.848 0.000145 ***
  depth_range400 - 500   1.76826    0.48074   3.678 0.000277 ***
  depth_range500 - 600   1.74791    0.48074   3.636 0.000324 ***
  depth_range600 - 700   1.77561    0.48074   3.694 0.000261 ***
  depth_range700 - 800   0.14827    0.41936   0.354 0.723904    
depth_range800 - 900   1.13086    0.44863   2.521 0.012213 *  
  depth_range900 - 1010  2.25778    0.49681   4.545 7.89e-06 ***
  day                   -0.03837    0.01525  -2.516 0.012389 *  
  ---
  Signif. codes:  0 â***â 0.001 â**â 0.01 â*â 0.05 â.â 0.1 â â 1
Residual standard error: 1.188 on 311 degrees of freedom
Multiple R-squared:  0.534,	Adjusted R-squared:  0.504 
F-statistic: 17.82 on 20 and 311 DF,  p-value: < 2.2e-16
```
Figure 2. A stepforward selection of the Count data and Categorical covariates were fitted 

#Linear model shows that as the number of counts collected from the glider for increase increases, then it declines as the days progress
#A lot of negative estimates, perhaps related towards the decline in accuracy and data-collection from the float over-time
#Counts increase with depth, though increase in counts have a potential decrease in oxygen increase?
#Though a better test may be necessary given that normality was weak, and further assumptions will need to be considered like colinearity between variables.



**Extra notes:**
Below is a map for flag points regarding Oxygen, as you can see they're detected and aligned on the Bay of Bengal as the data suggests. This was only used for ID - 579. Unfortuntely, I couldn't manage any effective way to collect all the time data from the dataset, as the metadata suggest it spans up to 20 days, I could only retrieve data from July 02 2016 - July 17 2016. :

![alt text](https://i.stack.imgur.com/Jowbh.png)
![alt text](https://i.stack.imgur.com/p3YeR.png)

Below is a zoomed in image of the floating points, because these are values of Oxygen then the darker green represents higher Oxygen concentrations and the lighter contrast represent lower Oxygen concentrations. Although, this approach limits the amount of points per grid-cell, failing to provide a concise distribution of the gliders path.
The time-series map show variations in Oxygen concentrations throughout the day, although consistent throughout the weeks, day 16 has a strong anamolous trend in comparison to previous days.


![alt text](https://i.stack.imgur.com/VDALr.png)


Limitations:
The previous map minimises the coordinates per grid-cell to save on memory, therefore not all values from the dataset can be used per grid-cell. To resolve this, a better map with more points per grid-cell would provide a stronger indication, visually on the spatial trends in oxygen fluctuations. Whilst there is no overlay for figure 1, onto another map because of differences in resolution (rescaling to a finer resolution may fix this), it provides a stronger perception of the distribution of points provided by the floats, and the oxygen levels. A larger proportion are distributed at the lower scale and surprisingly at larger depth (Further surprise is that higher concentrations of oxygen are prevalent at the surface, then diminish and lower concentrations are apparent at deeper depth - Inferring that a large-number of phytoplankton are present at the surface.)



