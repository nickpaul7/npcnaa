#"https://www.sports-reference.com/cbb/seasons/2020-advanced-school-stats.html"

#'@param year The four digit year.  Can be character or numeric.
#'@param type the type of stats you want.

create_team_stats_url <- function(year,
                                  opponent = FALSE,
                                  advanced = FALSE){

    # Example URLS
    # https://www.sports-reference.com/cbb/seasons/2019-school-stats.html
    # https://www.sports-reference.com/cbb/seasons/2019-opponent-stats.html
    # https://www.sports-reference.com/cbb/seasons/2019-advanced-school-stats.html
    # https://www.sports-reference.com/cbb/seasons/2019-advanced-opponent-stats.html


    if(opponent){

        team <- "opponent"

    }else{

        team <- "school"

    }

    if(advanced){

        type <- stringr::str_c("advanced",
                                "-",
                                team
                                )

    } else {

        type <- stringr::str_c(team)

    }


    stat_types <- c("advanced-school",
                    "advanced-opponent",
                    "opponent",
                    "school")

    if(type %in% stat_types){

        url <- stringr::str_c("https://www.sports-reference.com/cbb/seasons/",
                              year,
                              "-",
                              type,
                              "-stats.html")


    } else {

        stop("Not a recognized type")

    }

    test <- httr::GET(url)

    if(test$status_code != 200){

        warning(stringr::str_c("URL returned the following status code: ",
                               test$status_code))
        return(test$status_code)

    }

    url

}

get_table_headers <- function(html){

    col_names <- html %>%
        rvest::html_nodes(".sortable") %>%
        rvest::html_nodes("thead") %>%
        rvest::html_children() %>%
        .[[2]] %>%
        rvest::html_nodes("th") %>%
        rvest::html_text() %>%
        .[!stringr::str_detect(.,"^Rk$")]


    col_names[8:9] <- stringr::str_c("conf_",col_names[8:9])
    col_names[10:11] <- stringr::str_c("home_",col_names[10:11])
    col_names[12:13] <- stringr::str_c("away_",col_names[12:13])
    col_names[14:15] <- stringr::str_c("points_",col_names[14:15])
    col_names[16] <- "drop"
    col_names
}

add_names_to_vec <- function(x, vec_names){

    names(x) <- vec_names
    x


}

clean_team_stats_df <- function(df, col_names, end_year){

    numeric_cols <- col_names[!col_names %in% c("School", "drop")]

    df %>%
        select_at(col_names) %>%
        select(-drop) %>%
        mutate_at(numeric_cols, as.numeric) %>%
        mutate(end_year = end_year) %>%
        clean_team_name()

}

get_team_stats_data <- function(html){

    "%>%" <- magrittr::`%>%`

    # end_year <- stringr::str_extract(url, "\\d{4}") %>%
    #     as.numeric()



    team_stats <-  html %>%
        rvest::html_nodes(".sortable") %>%
        rvest::html_nodes("tbody") %>%
        rvest::html_nodes("tr:not(.thead)") %>%
        map(rvest::html_nodes, "td") %>%
        map(rvest::html_text)


    team_stats

}

convert_team_stats_to_df <- function(team_stats, col_names){

    df_team_stats <- purrr::map(team_stats,
                                add_names_to_vec,
                                col_names) %>%
        purrr::map(tibble::enframe) %>%
        purrr::map(tidyr::spread, name, value) %>%
        bind_rows()


    df_team_stats

}

#'@export
ncaa_team_stats <- function(year,
                            opponent = FALSE,
                            advanced = FALSE){

    url <- create_team_stats_url(year,
                                 opponent,
                                 advanced)

    if(stringr::str_length(url) < 4){
        warning_message <- stringr::str_c(".  There is no data for ",
                                          year)
        warning(warning_message)
        return(tibble::tibble())

    }

    html <- xml2::read_html(url)

    team_names <- html %>%
        rvest::html_nodes(".sortable") %>%
        rvest::html_nodes("tbody") %>%
        rvest::html_nodes("tr:not(.thead)") %>%
        rvest::html_nodes("a") %>%
        rvest::html_attr("href") %>%
        stringr::str_extract("(?<=/cbb/schools/).+(?=/\\d{4}\\.html)")

    col_names <- get_table_headers(html)

    df <- html %>%
            get_team_stats_data() %>%
            convert_team_stats_to_df(col_names) %>%
            clean_team_stats_df(col_names, end_year = year) %>%
            dplyr::mutate(team_name = team_names)


    df
}

clean_team_name <- function(df){

    df %>%
        dplyr::mutate(tournament = stringr::str_extract(School, "NCAA"),
               School = School %>%
                   stringr::str_replace("NCAA", "") %>%
                   stringr::str_trim())

}
