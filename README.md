# onmaRg Library

onmaRg is an R library that takes care of loading and merging Ontario Marginalization data. This includes functions for automatically creating dataframes containing marginalization data joined with geographic data, allowing the spatial analysis of this data to be more accessible.

onmaRg takes all of it's data directly off of the government websites and merges them into a dataframe without creating any permanant local files.

onmaRg can load historical marginalization files, or the most recent version put out, as well as being able to specify what level of detail to go in to, down to dissemination areas.

To get started working with this data, use the `shapeMarg()` function to load it in.