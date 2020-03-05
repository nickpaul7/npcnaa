prepare_data <- function(df){

    '%>%' <- magrittr::`%>%`

    df_w_index <- df %>%
        dplyr::mutate_at(c("winner_seed", "loser_seed"), str_pad, width = 2, pad = "0") %>%
        dplyr::mutate(game_index = stringr::str_c(round, winner_seed, winner_team, loser_seed, loser_team, region, year))

    type <- "winner"

    winner_cols <- colnames(df_w_index) %>%
        .[stringr::str_detect(., "winner")] %>%
        c("game_index", "round", "region", "year", .)

    df_winners <- df_w_index %>%
        dplyr::select_at(winner_cols) %>%
        dplyr::rename_all(stringr::str_replace, "winner_", "")

    type <- "loser"

    loser_cols <- colnames(df_w_index) %>%
        .[stringr::str_detect(., type)] %>%
        c("game_index", "round", "region", "year", .)

    name_replace <- stringr::str_c(type, "_")

    df_loser <- df_w_index %>%
        dplyr::select_at(loser_cols) %>%
        dplyr::rename_all(stringr::str_replace, name_replace, "")

    df_clean <- df_winners %>%
        dplyr::bind_rows(df_loser) %>%
        dplyr::arrange(game_index, as.numeric(seed)) %>%
        dplyr::mutate_at("seed", as.numeric) %>%
        dplyr::group_by(game_index) %>%
        dplyr::mutate(type = rank(seed, ties.method = "random")) %>%
        dplyr::ungroup() %>%
        dplyr::mutate_at("seed", as.character)

    df_long <- df_clean %>%
        tidyr::pivot_longer(cols = seed:score,
            names_to = "columns",
            values_to = "value") %>%
        tidyr::unite(column_names, columns, type)

    df_wide <- df_long %>%
        tidyr::pivot_wider(names_from = column_names,
                    values_from = value) %>%
        dplyr::mutate_at(c("score_1", "score_2", "seed_1", "seed_2"), as.numeric) %>%
        dplyr::mutate(result = score_1 > score_2,
               diff = score_1 - score_2)

    df_wide


}

add_team_stats <- function(df_bracket, df_team_stats){

    '%>%' <- magrittr::`%>%`

    df_bracket_clean <- df_bracket %>%
        prepare_data()

    df_output <- df_bracket_clean %>%
        dplyr::left_join(df_team_stats, by = c("team_1" = "team_name",
                                               "year" = "end_year")) %>%
        dplyr::left_join(df_team_stats, by = c("team_2" = "team_name",
                                               "year" = "end_year"),
                                               suffix = c("_1","_2"))

    df_output


}

select_features <- function(df_ml){

    '%>%' <- magrittr::`%>%`

    df_ml %>%
        dplyr::select_if(~(is.numeric(.) | is.logical(.))) %>%
        dplyr::select(result, diff, everything())


}
