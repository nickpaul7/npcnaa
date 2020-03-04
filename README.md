
<!-- README.md is generated from README.Rmd. Please edit that file -->
npncaa
======

The `npncaa` package scrapes NCAA info from <https://www.sports-reference.com/>.

Installation
------------

You can install npncaa from github with:

``` r
# install.packages("devtools")
devtools::install_github("nickpaul7/npcnaa")
```

Tournament Info
---------------

To collect data for a given year use the code below:

``` r
library(npncaa)

year <- 2019

df_bracket <- get_bracket_data(2019)
```

The `get_bracket_data()` function will return a data frame.

``` r
library(tidyverse)
```

    ## ── Attaching packages ────────────────────────────────────────────────────────────────────────────────────── tidyverse 1.3.0 ──

    ## ✓ ggplot2 3.2.1     ✓ purrr   0.3.3
    ## ✓ tibble  2.1.3     ✓ dplyr   0.8.4
    ## ✓ tidyr   1.0.2     ✓ stringr 1.4.0
    ## ✓ readr   1.3.1     ✓ forcats 0.5.0

    ## ── Conflicts ───────────────────────────────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

``` r
glimpse(df)
```

    ## function (x, df1, df2, ncp, log = FALSE)

Finally, you can get all data from 1985 to the present using the following code

``` r
library(tidyverse)
library(npncaa)

years <- c(1993:2019)

df_all_years <- purrr::map_df(years, get_bracket_data)
```

Team Stats by Year
------------------

``` r
# year <- 2019
# url <- create_team_stats_url(year)
```

``` r
# url_opponent_advanced <- create_team_stats_url(year, opponent = TRUE, advanced = TRUE)
# url
```

Get team stats for a particular year.

Not all years have all options, but the function will alert you when this happens.

``` r
# year <- 1955
# url_opponent_advanced <- create_team_stats_url(year, opponent = FALSE, advanced = FALSE)
# url_opponent_advanced
```

``` r
df_team_stats <- ncaa_team_stats(2019)
df_advanced <- ncaa_team_stats(2019, advanced = TRUE)
df_opponent <- ncaa_team_stats(2019, opponent = TRUE)
df_advanced_opponent <- ncaa_team_stats(2019, advanced = TRUE, opponent = TRUE)
```

When the data does not exist, the `ncaa_team_stats()` function will return an empty data frame. This facilitates pulling data over a period of years without knowing where the end is.

``` r
df_advanced_opponent <- ncaa_team_stats(1955, advanced = TRUE, opponent = TRUE)
```

    ## Warning in create_team_stats_url(year, opponent, advanced): URL returned
    ## the following status code: 404

    ## Warning in ncaa_team_stats(1955, advanced = TRUE, opponent = TRUE): . There
    ## is no data for 1955

``` r
years <- 1993:2019
df_team_stats_1993_2019 <- purrr::map_df(years, ncaa_team_stats)
```

Prepare for ML
--------------

``` r
df_ml <- df_all_years %>% 
    add_team_stats(df_team_stats_1993_2019) %>% 
    select_features() %>% 
    select(diff)
```
