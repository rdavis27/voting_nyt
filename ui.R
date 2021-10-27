library(shinycssloaders)

shinyUI(fluidPage(
    titlePanel("Analysis of 2020 Presidential Election Data"),
    sidebarLayout(
        sidebarPanel(
            width = 2,
            selectInput("state", "State",
                        choices = c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL",
                                    "GA","HI","ID","IL","IN","IA","KS","KY","LA","ME",
                                    "MD","MA","MI","MN","MS","MO","MT","NE","NV","NH",
                                    "NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI",
                                    "SC","SD","TN","TX","UT","VT","VA","WA","WV","WI",
                                    "WY","(all)"),
                        selected = "TX"),
            selectInput("county", "County",
                        choices = "Maverick",
                        selected = "(all)")
        ),
        mainPanel(
            width = 10,
            tabsetPanel(
                type = "tabs",
                selected = "Data",
                tabPanel("Data", withSpinner(verbatimTextOutput("myText"))),
                tabPanel("Scan",
                    sidebarPanel(
                        width = 2,
                        helpText("PRECINCT FILTERS"),
                        numericInput("pminmargin", "Min Margin", min = -100, max = 100, value = -100),
                        numericInput("pmaxmargin", "Max Margin", min = -100, max = 100, value = 100),
                        helpText("COUNTY FILTERS"),
                        numericInput("minareas", "Min Areas", min = 0, value = 4),
                        numericInput("minvotes", "Min Votes", min = 0, value = 1),
                        numericInput("minmargin", "Min Margin", min = -100, max = 100, value = -100),
                        numericInput("maxmargin", "Max Margin", min = -100, max = 100, value = 100),
                        selectInput("sortcol", "Sort Column",
                                    choices = c("county","state","fips","sd","sdW",
                                                "min","max","votes","n"),
                                    selected = "sdW")
                    ),
                    mainPanel(
                        width = 10,
                        withSpinner(verbatimTextOutput("myScan"))
                    )
                ),
                tabPanel("Plot",
                         sidebarPanel(
                             width = 2,
                             textInput("lowcolor", "Low Color", value = "red"),
                             textInput("midcolor", "Mid Color", value = "yellow"),
                             textInput("highcolor", "High Color", value = "green"),
                             numericInput("minlimit", "Min Limit", min = -100, max = 100, value = -100),
                             numericInput("maxlimit", "Max Limit", min = -100, max = 100, value = 100),
                             checkboxInput("addtext", "Add Text", value = TRUE)
                         ),
                         mainPanel(
                             width = 10,
                             withSpinner(plotOutput(outputId = "myPlot")))
                         ),
                tabPanel("Hist",
                         sidebarPanel(
                             width = 2,
                             numericInput("minhist", "Min X", min = -100, max = 100, value = -100),
                             numericInput("maxhist", "Max X", min = -100, max = 100, value = 100),
                             numericInput("stephist", "Step X", min = 1, max = 100, value = 5)
                         ),
                         mainPanel(
                             width = 10,
                             withSpinner(plotOutput(outputId = "myHist")))
                )
            )
        )
    )
))
