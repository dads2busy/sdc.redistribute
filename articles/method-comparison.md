# Comparing redistribution methods

``` r

library(sdc.redistribute)
```

Both methods estimate target values from source values; they differ in
the weight each assigns to a piece of a source polygon.

- **`redistribute_direct`** assumes the measure is spread *uniformly by
  area* within each source polygon. It needs only the two polygon
  layers.
- **`redistribute_parcels`** assumes the measure follows a *point layer*
  (e.g. parcels), which usually tracks where people and housing actually
  are. It is more accurate where such points exist, at the cost of
  needing that layer.

``` r

library(sdc.redistribute)
data(sdc_example)

direct  <- redistribute_direct(sdc_example$source, sdc_example$target,
                               extensive = "pop", suffix = "_direct")
parcels <- redistribute_parcels(sdc_example$source, sdc_example$target,
                                sdc_example$parcels, extensive = "pop",
                                suffix = "_parcels")

cbind(sf::st_drop_geometry(direct["pop_direct"]),
      sf::st_drop_geometry(parcels["pop_parcels"]))
#>   pop_direct pop_parcels
#> 1         90          90
#> 2         50          50
#> 3         60          60
```

Both preserve the source total; they differ in how they place it.
