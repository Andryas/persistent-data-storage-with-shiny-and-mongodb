shinyServer(function(input, output, session) {

    historic_clients <- reactiveVal({
        conn$find(
            query = '{}',
            fields = '{"name": 1, "_id": 1}'
        )
    })
    historic_record <- reactiveVal(NULL)

    # ! Screen 0 / Projects ----
    observe({
        if (nrow(historic_clients()) > 0) {
            choices <- historic_clients()[["_id"]]
            names(choices) <- historic_clients()[["name"]]

            updateSelectInput(
                session = session,
                inputId = "read_client",
                choices = choices,
                selected = input$read_client
            )
        }

    })

    observeEvent(input$add_client_modal, {
        shiny::showModal(
            shiny::modalDialog(
                title = "Add new client",
                size = "s",
                easyClose = TRUE,
                footer = NULL,

                textInput(
                    inputId = "client_name",
                    label = "Client's name",
                    placeholder = "Type here the client's name..."
                ),

                column(
                    12,
                    align = "center",
                    actionButton(
                        inputId = "add_client",
                        label = "Add client",
                        icon = icon("plus"),
                        width = "auto"
                    )
                )
            )
        )
    })

    observeEvent(input$add_client, {
        req(input$client_name)

        created_at <- format(lubridate::now("utc"), "%Y-%m-%dT%H:%M:%SZ", "UTC")
        new_client <- list(
            name = input$client_name,
            created_at = list("$date" = created_at)
        )
        conn$insert(jsonlite::toJSON(new_client, auto_unbox = TRUE))

        historic_clients(conn$find(
            query = '{}',
            fields = '{"name": 1, "_id": 1}'
        ))

        removeModal()

        shinyalert::shinyalert(
            title = "Client added!",
            type = "success"
        )

    })

    client_info <- reactive({
        req(input$read_client)

        client_info <- conn$iterate(
            query = stringr::str_interp(
                '{"_id": {"$oid": "${oid}"}}',
                list(oid = input$read_client)
            ),
            fields = '{}'
        )

        client_info <- client_info$one()

        updateSelectInput(
            session = session,
            input = "gender",
            selected = ifelse(is.null(client_info$gender), "male", client_info$gender)
        )
        shinyWidgets::updateAutonumericInput(
            session = session,
            input = "age",
            value = ifelse(is.null(client_info$age), 0, client_info$age)
        )
        historic <- dplyr::bind_rows(client_info$historic)
        if (nrow(historic) > 0) {
            historic_record(historic)
        } else {
            historic_record(NULL)
        }

        client_info
    })

    # ! Screen 1 / Session ----
    observeEvent(input$add_modal, {
        shiny::showModal(
            shiny::modalDialog(
                title = "Record your weight",
                size = "s",
                easyClose = TRUE,
                footer = NULL,

                shinyWidgets::airDatepickerInput(
                    inputId = "record_date",
                    label = "Date",
                    value = lubridate::today()
                ),
                shinyWidgets::autonumericInput(
                    inputId = "record_weight",
                    label = "Weight",
                    value = 0,
                    decimalPlaces = 2,
                    align = "center",
                    currencySymbol = " kg",
                    currencySymbolPlacement = "s"
                ),
                column(
                    12,
                    align = "center",
                    actionButton(
                        inputId = "add",
                        label = "Add record",
                        icon = icon("plus"),
                        width = "auto"
                    )
                )
            )
        )
    })

    observeEvent(input$add, {

        new_record <- tibble::tibble(
            date = input$record_date,
            weight = input$record_weight
        )

        message("Add new record")
        print(new_record)

        historic_record(
            historic_record() |>
                dplyr::bind_rows(
                    new_record
                )
        )

        removeModal()
    })

    output$record_table <- reactable::renderReactable({
        req(historic_record())

        reactable::reactable(historic_record())
    })

    # ! Bookmarking ----
    observe({
        req(input$gender, client_info())

        conn$update(
            stringr::str_interp('{"_id": {"$oid": "${id}"}}', list(id = client_info()[["_id"]])),
            jsonlite::toJSON(list("$set" = list("gender" = input$gender)), auto_unbox = TRUE)
        )
    })

    observe({
        req(input$age, client_info())

        conn$update(
            stringr::str_interp('{"_id": {"$oid": "${id}"}}', list(id = client_info()[["_id"]])),
            jsonlite::toJSON(list("$set" = list("age" = input$age)), auto_unbox = TRUE)
        )
    })

    observe({
        req(historic_record(), client_info())

        conn$update(
            stringr::str_interp('{"_id": {"$oid": "${id}"}}', list(id = client_info()[["_id"]])),
            jsonlite::toJSON(list("$set" = list("historic" = historic_record())), auto_unbox = TRUE)
        )
    })

})
