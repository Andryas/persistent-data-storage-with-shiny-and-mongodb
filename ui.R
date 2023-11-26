shinyUI(
    bslib::page_fluid(
        title = "A bookmarking with mongodb",
        shinyjs::useShinyjs(),
        tags$head(
            tags$style(HTML(
                "
                    .selectize-dropdown {
                        z-index: 1000;
                    }

                    .bslib-card {
                        overflow: visible;
                    }

                    .bslib-card .card-body {
                        overflow: visible;
                    }
                "
            ))
        ),

        bslib::card(
            bslib::card_header(
                "Screen 0"
            ),
            bslib::card_body(
                column(
                    12,
                    align = "center",
                    selectInput(
                        inputId = "read_client",
                        label = "Select a client",
                        choices = ""
                    ),
                    h5("or"),
                    actionButton(
                        inputId = "add_client_modal",
                        label = "Add a new client"
                    )
                )
            )
        ),

        bslib::card(
            bslib::card_header(
                "Screen 1"
            ),
            bslib::card_body(
                bslib::layout_column_wrap(
                    fixed_width = TRUE,
                    class = "justify-content-center",
                    selectInput(
                        inputId = "gender",
                        label = "Gender",
                        choices = c("Male" = "male", "Female" = "female"),
                        selected = ""
                    ),
                    shinyWidgets::autonumericInput(
                        inputId = "age",
                        label = "Age",
                        value = 0,
                        decimalPlaces = 0,
                        align = "center"
                    )
                ),
                div(
                    class = "row justify-content-center",
                    actionButton(
                        inputId = "add_modal",
                        label = "Add new record",
                        width = "auto"
                    )
                ),
                column(
                    12,
                    align = 'center',
                    column(
                        width = 4,
                        reactable::reactableOutput("record_table")
                    )
                )
            )
        )

    )
)
