#input year and get brackets

#'@title Get bracket data
#'@description Pull Bracket data for NCAA Basketball Tournaments
#'@param year The year you want tournament data from.
#'@export
get_bracket_data <- function(year){

    url <- create_bracket_url(year)

    html <- xml2::read_html(url)

    regions <- get_region_names(html)

    df_bracket <- purrr::pmap_df(list(region = regions), get_region_data, html) %>%
        dplyr::mutate(year = year)

   df_bracket

}

# get the webpage for that year
#'@title Create the URL for a particular year
#'@description Create the URL for the year you want
#'@param year The year that you want to create a url for
#'@export
create_bracket_url <- function(year){

    stringr::str_c("https://www.sports-reference.com/cbb/postseason/",
                   year,
                   "-ncaa.html")

}

# get the list of regions
#'@title Get the names of the regions
#'@param url The url of the year you want.
get_region_names <- function(html){

    `%>%` <- magrittr::`%>%`

    regions <- html %>%
        rvest::html_nodes(".switcher") %>%
        rvest::html_nodes("div") %>%
        rvest::html_text() %>%
        stringr::str_to_lower()

    regions[regions == "final four"] <- "national"

    regions
}

get_region_data <- function(html, region){

    if(region == "national"){

        region_id <- "#national"
        class <- ".team4"
        round_inflator <- 4

    } else {

        region_id <- region %>%
            stringr::str_c("#", .) %>%
            stringr::str_to_lower()
        class <- ".team16"
        round_inflator <- 0

    }

    rounds <- html %>%
        html_nodes(region_id) %>%
        html_nodes(class) %>%
        html_nodes(".round")

    df_rounds <- purrr::map(rounds, get_round_data) %>%
        bind_rows(.id = "round") %>%
        mutate(region = region,
               round = as.numeric(round) + round_inflator)

    df_rounds

}

get_round_data <- function(round_node){

    winner_seed <- round_node %>%
        rvest::html_nodes(".winner") %>%
        rvest::html_nodes("span") %>%
        rvest::html_text()

    winner_team <- round_node %>%
        rvest::html_nodes(".winner") %>%
        rvest::html_nodes("a:nth-child(2)") %>%
        rvest::html_text()

    winner_score <- round_node %>%
        rvest::html_nodes(".winner") %>%
        rvest::html_nodes("a:nth-child(3)") %>%
        rvest::html_text()


    loser_seed <- round_node %>%
        rvest::html_nodes("div > :not(.winner)") %>%
        rvest::html_nodes("span") %>%
        rvest::html_text()

    loser_team <- round_node %>%
        rvest::html_nodes("div > :not(.winner)") %>%
        rvest::html_nodes("a:nth-child(2)") %>%
        rvest::html_text()


    loser_score <- round_node %>%
        rvest::html_nodes("div > :not(.winner)") %>%
        rvest::html_nodes("a:nth-child(3)") %>%
        rvest::html_text()


    tibble::tibble(winner_seed, winner_team, winner_score, loser_seed, loser_team, loser_score)


}

# old approavh using selenium --------------------------------------------------

get_region_data_selenium <- function(html){

    region <- html %>%
        rvest::html_nodes("#brackets > .current") %>%
        rvest::html_attrs() %>%
        unlist() %>%
        .["id"]

    # need to iterate over this number
    rounds <- html %>%
        rvest::html_nodes(".current") %>%
        xml2::xml_find_all('.//*[@id="bracket"]/div')


    df <- rounds %>%
        purrr::map(get_round_data) %>%
        tibble::tibble(data = .) %>%
        tibble::rownames_to_column("round") %>%
        tidyr::unnest() %>%
        dplyr::mutate(region = region)


    df

}



get_region_html_selenium <- function(num_region, url){

    sleep_time <- 10

    remDr <- RSelenium::remoteDriver(remoteServerAddr = "localhost",
                                     port = 4445L,
                                     browserName = "chrome")

    # open connection
    remDr$open()

    # get data from the site -------------------------------------------------------

    # go to site
    remDr$navigate(url)

    Sys.sleep(sleep_time)

    # remDr$screenshot(display = TRUE)


    selector <- stringr::str_c( "#content > div.switcher.filter > div:nth-child(",
                                num_region,
                                ") > a")

    # click a button
    element <- remDr$findElement(using = 'css selector',
                                 selector)

    Sys.sleep(sleep_time)


    element$clickElement()

    Sys.sleep(sleep_time)

    # remDr$screenshot(display = TRUE)


    # download the west
    html <- xml2::read_html(remDr$getPageSource()[[1]])

    remDr$close()

    html

}

get_bracket_data_selenium <- function(year){

    url <- create_bracket_url(year)

    # get the list of regions for that year

    regions <- get_region_names(url)

    num_regions <- length(regions)

    # collect data from each region

    #start_here : crashing when running multiples
    html_list <- purrr::map(1:2, get_region_html, url = url)

    # collect data from each round for each region

    df <- map_df(html_list, get_region_data)

}
