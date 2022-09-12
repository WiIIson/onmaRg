# Notes

## Fifth Sumbission

> Maintainer: 'William Conley <william@cconley.ca>'

As per the R package documentation, this is just a note that this is my first package I have submitted, and it can't be eliminated.

Added a "value" description in the function documentation, and added links to the data sources in the description as requested.

---

## Fourth Sumbission

> Maintainer: 'William Conley <william@cconley.ca>'

As per the R package documentation, this is just a note that this is my first package I have submitted, and it can't be eliminated.

> om_geo: no visible binding for global variable 'geometry'
>
> Undefined global functions or variables:
>
>  geometry

The second note was addressed by declaring geometry as a global variable.

```r
globalVariables(c("geometry"))
```

As requested, the title was reduced to less than 65 characters.

---

## Third Submission

> Maintainer: 'William Conley <william@cconley.ca>'

As per the R package documentation, this is just a note that this is my first package I have submitted, and it can't be eliminated.

> om_geo: no visible binding for global variable 'geometry'
>
> Undefined global functions or variables:
>
>  geometry

`om_geo` is an sf object. The `geometry` variable is created by the sf package when it converts the ESRI shapefiles (which contain geometry data).
