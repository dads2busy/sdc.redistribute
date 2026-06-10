# sdc.redistribute 0.1.0

* Initial CRAN release.
* `redistribute_direct()` performs area-weighted areal interpolation between two
  polygon layers: extensive (count) measures are total-preserving and intensive
  (rate) measures are area-weighted means.
* `redistribute_parcels()` performs dasymetric redistribution across a point
  layer (such as parcel centroids), splitting each source value equally or in
  proportion to a `weights` column.
* Ships the `sdc_example` dataset and the `introduction` and `method-comparison`
  vignettes.
