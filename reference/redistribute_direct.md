# Area-weighted redistribution between polygon layers

Area-weighted redistribution between polygon layers

## Usage

``` r
redistribute_direct(
  source,
  target,
  extensive = NULL,
  intensive = NULL,
  preserve_totals = TRUE,
  suffix = NULL
)
```

## Arguments

- source:

  An `sf` polygon layer carrying the values to redistribute.

- target:

  An `sf` polygon layer to estimate values for.

- extensive:

  Character vector of count column names in `source` to redistribute as
  totals (area-share weighted, optionally rescaled to preserve the
  source total).

- intensive:

  Character vector of rate/density column names in `source` to
  redistribute as area-weighted means.

- preserve_totals:

  Logical; if `TRUE` (default) extensive results are rescaled so each
  target column sums to the source total.

- suffix:

  Optional string appended to each new column name.

## Value

The `target` layer (an `sf` object) with one new column per
redistributed measure.

## Details

Extensive measures (counts) are redistributed by each intersection's
share of the source polygon area and, when `preserve_totals = TRUE`,
rescaled so the target totals match the source totals. Intensive
measures (rates/densities) are area-weighted means: the sum of each
source value times the intersection's share of the target polygon area
(the standard areal-weighting intensive estimator). This equals a true
area-weighted mean when the target is fully covered by the source and
treats any uncovered part of a target as contributing zero. `NA` source
values are omitted from the weighted sums. Targets that no source
polygon covers receive `0` for extensive measures and `NA` for intensive
measures. If `target` already has a column named like a redistributed
measure, it is overwritten; pass `suffix` to keep both.

## Examples

``` r
src <- sf::st_sf(pop = 100, geometry = sf::st_sfc(
  sf::st_polygon(list(rbind(c(0,0), c(2,0), c(2,2), c(0,2), c(0,0)))),
  crs = 3857))
tgt <- sf::st_sf(id = c("A", "B"), geometry = sf::st_sfc(
  sf::st_polygon(list(rbind(c(0,0), c(1,0), c(1,2), c(0,2), c(0,0)))),
  sf::st_polygon(list(rbind(c(1,0), c(2,0), c(2,2), c(1,2), c(1,0)))),
  crs = 3857))
redistribute_direct(src, tgt, extensive = "pop")
#> Simple feature collection with 2 features and 2 fields
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 0 ymin: 0 xmax: 2 ymax: 2
#> Projected CRS: WGS 84 / Pseudo-Mercator
#>   id                       geometry pop
#> 1  A POLYGON ((0 0, 1 0, 1 2, 0 ...  50
#> 2  B POLYGON ((1 0, 2 0, 2 2, 1 ...  50
```
