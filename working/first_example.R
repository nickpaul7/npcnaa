
# library ----------------------------------------------------------------------
library(RSelenium)
library(tidyverse)
library(rvest)
library(devtools)


#RSelenium resources
#https://callumgwtaylor.github.io/blog/2018/02/01/using-rselenium-and-docker-to-webscrape-in-r-using-the-who-snake-database/


get_region <- function(region){

    # get the regions from the website

    regions <- c("East"  )

    region_num <- regions[region]

    # start remote driver ----------------------------------------------------------
    remDr <- RSelenium::remoteDriver(remoteServerAddr = "localhost",
                                     port = 4445L,
                                     browserName = "chrome")

    # open connection
    remDr$open()

    # get data from the site -------------------------------------------------------

    # go to site
    remDr$navigate("https://www.sports-reference.com/cbb/postseason/2019-ncaa.html")

    remDr$screenshot(display = TRUE)


    # click a button
    element <- remDr$findElement(using = 'css selector',
                                 "#content > div.switcher.filter > div:nth-child(3) > a")


    element$clickElement()

    remDr$screenshot(display = TRUE)


    # download the west
    html <- xml2::read_html(remDr$getPageSource()[[1]])

    remDr$close


    df <- get_rounds_info(html)

}

# extract data from html -------------------------------------------------------

get_round_info <- function(round){

    winner_seed <- round %>%
        html_nodes(".winner") %>%
        html_nodes("span") %>%
        html_text()

    winner_team <- round %>%
        html_nodes(".winner") %>%
        html_nodes("a:nth-child(2)") %>%
        html_text()

    winner_score <- round %>%
        html_nodes(".winner") %>%
        html_nodes("a:nth-child(3)") %>%
        html_text()


    loser_seed <- round %>%
        html_nodes("div > :not(.winner)") %>%
        html_nodes("span") %>%
        html_text()

    loser_team <- round %>%
        html_nodes("div > :not(.winner)") %>%
        html_nodes("a:nth-child(2)") %>%
        html_text()


    loser_score <- round %>%
        html_nodes("div > :not(.winner)") %>%
        html_nodes("a:nth-child(3)") %>%
        html_text()


    tibble::tibble(winner_seed, winner_team, winner_score, loser_seed, loser_team, loser_score)

}

get_rounds_info <- function(html){

    region <- html %>%
        html_nodes("#brackets > .current") %>%
        html_attrs() %>%
        unlist() %>%
        .["id"]


    rounds <- html %>%
        xml2::xml_find_all('//*[@id="bracket"]/div[1]')


   df <- rounds %>%
        purrr::map(get_round_info) %>%
        tibble::tibble(data = .) %>%
        tibble::rownames_to_column("round") %>%
        tidyr::unnest() %>%
        mutate(region = region)


   df

}




# old --------------------------------------------------------------------------

#bracket > div:nth-child(1) > div:nth-child(1) > div.winner > a:nth-child(2)

#bracket > div:nth-child(1) > div:nth-child(1) > div.winner > a:nth-child(3)

#bracket > div:nth-child(1) > div:nth-child(1) > div:nth-child(2) > a:nth-child(2)




