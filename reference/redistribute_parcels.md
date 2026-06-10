# Dasymetric redistribution via a point layer

Distributes each `source` value across the points (e.g. parcel
centroids) that fall inside it, then reaggregates the point-level values
to `target` polygons. With `weights = NULL` the value is split evenly
across points; otherwise it is split in proportion to a points column
(the extension point for household-size or unit-count weighting).

## Usage

``` r
redistribute_parcels(
  source,
  target,
  points,
  extensive = NULL,
  weights = NULL,
  suffix = NULL
)
```

## Arguments

- source:

  An `sf` polygon layer carrying the values to redistribute.

- target:

  An `sf` polygon layer to estimate values for.

- points:

  An `sf` point layer (e.g. parcel centroids).

- extensive:

  Character vector of count column names in `source`.

- weights:

  Optional name of a numeric column in `points` to weight by.

- suffix:

  Optional string appended to each new column name.

## Value

The `target` layer (an `sf` object) with one new column per measure.

## Details

Each source value is split across the points inside that source polygon
in proportion to `weights` (equally when `weights = NULL`), then summed
within each target polygon. A source polygon that contains no points
contributes nothing to any target (its value cannot be placed). If the
total weight of a source's points is zero, that source likewise
contributes nothing. If `target` already has a column named like a
redistributed measure, it is overwritten; pass `suffix` to keep both.

## Examples

``` r
src <- sf::st_sf(pop = 100, geometry = sf::st_sfc(
  sf::st_polygon(list(rbind(c(0,0), c(2,0), c(2,2), c(0,2), c(0,0)))),
  crs = 3857))
tgt <- sf::st_sf(id = c("A", "B"), geometry = sf::st_sfc(
  sf::st_polygon(list(rbind(c(0,0), c(1,0), c(1,2), c(0,2), c(0,0)))),
  sf::st_polygon(list(rbind(c(1,0), c(2,0), c(2,2), c(1,2), c(1,0)))),
  crs = 3857))
pts <- sf::st_sf(geometry = sf::st_sfc(
  sf::st_point(c(0.5, 1)), sf::st_point(c(1.5, 1)), crs = 3857))
redistribute_parcels(src, tgt, pts, extensive = "pop")
#> Simple feature collection with 2 features and 2 fields
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 0 ymin: 0 xmax: 2 ymax: 2
#> Projected CRS: WGS 84 / Pseudo-Mercator
#>   id                       geometry pop
#> 1  A POLYGON ((0 0, 1 0, 1 2, 0 ...  50
#> 2  B POLYGON ((1 0, 2 0, 2 2, 1 ...  50
```
