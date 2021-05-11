# Climate-Science

The folder `Ocean Script` provides the script that I used with the following data from: 
```Webber B.G.M.; Matthews A.; Queste B.Y.; Lee G.A.; Cobas-Garcia M.; Heywood K.J.; Vinayachandran P.N.(2019). Ocean glider data from five Seagliders deployed in the Bay of Bengal during the BoBBLE (Bay of Bengal Boundary Layer Experiment) project in July 2016. British Oceanographic Data Centre, National Oceanography Centre, NERC, UK. doi:10/dgvj.```

**Linear models, and statistical results are present in the R-script**

Below is a map for flag points regarding Oxygen, as you can see they're detected and aligned on the Bay of Bengal as the data suggests. This was only used for ID - 579. Unfortuntely, I couldn't manage any effective way to collect all the time data from the dataset, as the metadata suggest it spans up to 20 days, I could only retrieve data from July 02 2016 - July 17 2016. :



![alt text](https://i.stack.imgur.com/Jowbh.png)
![alt text](https://i.stack.imgur.com/p3YeR.png)

Below is a zoomed in image of the floating points, because these are values of Oxygen then the darker green represents higher Oxygen concentrations and the lighter contrast represent lower Oxygen concentrations. Although, this approach limits the amount of points per grid-cell, failing to provide a concise distribution of the gliders path.
The time-series map show variations in Oxygen concentrations throughout the day, although consistent throughout the weeks, day 16 has a strong anamolous trend in comparison to previous days.


![alt text](https://i.stack.imgur.com/VDALr.png)


Limitations:
The previous map minimises the coordinates per grid-cell to save on memory, therefore not all values from the dataset can be used per grid-cell. To resolve this, a better map with more points per grid-cell would provide a stronger indication, visually on the spatial trends in oxygen fluctuations. Whilst there is no overlay for the image below onto another map because of differences in resolution (rescaling to a finer resolution may fix this), it provides a stronger perception of the distribution of points provided by the floats, and the oxygen levels. A larger proportion are distributed at the lower scale.

![alt text](https://i.stack.imgur.com/CzVpw.png)
