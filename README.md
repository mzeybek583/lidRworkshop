This repository contains the material for a two days `lidR` workshop as well as the material for its 4 hours and 2 hours versions and its 20 minutes showcase versions. You can install the material on your own machine following this README.

## 1. Material

To follow this workshop you need to download the content of this repository. It contains the code, the shapefiles and the point-clouds we will use during the workshop.

## 2. R version and Rstudio

* You need to install a recent version of `R` i.e. `R 4.0.x` or more.
* We will work with [Rstudio](https://www.rstudio.com/). This IDE is not mandatory to follow the workshop but is highly recommended.

## 3. R Packages

You need to install the `lidR` package in its latest version (v >= 3.1.3). 

```r
install.packages("lidR")
```

The following packages can be installed as well. They enhance the package `lidR` and are useful in some examples. But you can use `lidR` without them.

```r
install.packages("mapview", "progress", "concaveman")
```

You may also want the package `pryr` to run some examples but it is very optional.
