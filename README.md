
<!-- README.md is generated from README.Rmd. Please edit that file -->
npncaa
======

The `npncaa` package scrapes NCAA tournament info from <https://www.sports-reference.com/>.

Installation
------------

You can install npncaa from github with:

``` r
# install.packages("devtools")
devtools::install_github("nickpaul7/npcnaa")
```

Example
-------

To collect data for a given year use the code below:

``` r
library(npncaa)

year <- 2019

df <- get_bracket_data(2019)
```

The `get_bracket_data()` function will return a data frame.

``` r
library(tidyverse)

glimpse(df)
#> Observations: 63
#> Variables: 9
#> $ round        <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 4, 1, 1...
#> $ winner_seed  <chr> "1", "9", "12", "4", "6", "3", "10", "2", "1", "4...
#> $ winner_team  <chr> "Duke", "UCF", "Liberty", "Virginia Tech", "Maryl...
#> $ winner_score <chr> "85", "73", "80", "66", "79", "79", "86", "76", "...
#> $ loser_seed   <chr> "16", "8", "5", "13", "11", "14", "7", "15", "9",...
#> $ loser_team   <chr> "North Dakota State", "VCU", "Mississippi State",...
#> $ loser_score  <chr> "62", "58", "76", "52", "77", "74", "76", "65", "...
#> $ region       <chr> "east", "east", "east", "east", "east", "east", "...
#> $ year         <dbl> 2019, 2019, 2019, 2019, 2019, 2019, 2019, 2019, 2...
```

Finally, you can get all data from 1985 to the present using the following code

``` r
library(tidyverse)
library(npncaa)

years <- c(1985:2019)

df_all_years <- purrr::map_df(years, get_bracket_data)
```
