
<!-- README.md is generated from README.Rmd. Please edit that file -->

# sdc.redistribute

<!-- badges: start -->

[![R-CMD-check](https://github.com/dads2busy/sdc.redistribute/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/dads2busy/sdc.redistribute/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

Redistribute attribute values from one set of polygons onto another, by
area weighting (`redistribute_direct`) or by a dasymetric point layer
such as parcel centroids (`redistribute_parcels`).

## Installation

``` r
# install.packages("pak")
pak::pak("dads2busy/sdc.redistribute")
```

## Example

``` r
library(sdc.redistribute)
data(sdc_example)
redistribute_direct(sdc_example$source, sdc_example$target, extensive = "pop")
#> Simple feature collection with 3 features and 2 fields
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 0 ymin: 0 xmax: 4 ymax: 2
#> Projected CRS: WGS 84 / Pseudo-Mercator
#>   nbhd                       geometry pop
#> 1   N1 POLYGON ((0 0, 1.5 0, 1.5 2...  90
#> 2   N2 POLYGON ((1.5 0, 2.5 0, 2.5...  50
#> 3   N3 POLYGON ((2.5 0, 4 0, 4 2, ...  60
```
