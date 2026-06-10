# Introduction to sdc.redistribute

``` r

library(sdc.redistribute)
```

`sdc.redistribute` moves measured values from a *source* set of polygons
onto a *target* set that does not share the same boundaries.

``` r

library(sdc.redistribute)
data(sdc_example)

# Area-weighted: split tract population onto neighborhoods.
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

# Dasymetric: weight the split by parcels (here, by unit count).
redistribute_parcels(
  sdc_example$source, sdc_example$target, sdc_example$parcels,
  extensive = "pop", weights = "units")
#> Simple feature collection with 3 features and 2 fields
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 0 ymin: 0 xmax: 4 ymax: 2
#> Projected CRS: WGS 84 / Pseudo-Mercator
#>   nbhd                       geometry      pop
#> 1   N1 POLYGON ((0 0, 1.5 0, 1.5 2... 90.90909
#> 2   N2 POLYGON ((1.5 0, 2.5 0, 2.5... 43.90572
#> 3   N3 POLYGON ((2.5 0, 4 0, 4 2, ... 65.18519
```

Use `extensive` for counts (totals are preserved) and `intensive` for
rates (area-weighted means).
