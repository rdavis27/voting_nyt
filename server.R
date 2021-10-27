library(shiny)
library(tidyverse)
library(ggplot2)
library(geojsonio)
library(sf)
library(statmod)
library(semEff)
library(ggrepel)

shinyServer(function(session, input, output) {
    ff <- read_csv("fips-by-state.csv")
    names(ff) <- c("fips","county","state")
    ff$county <- gsub(" County","",ff$county)
    output$myText <- renderPrint({
        dd <- getNYTData()
        dd <- data.frame(dd$GEOID,dd$pct_dem_lead,dd$votes_dem,dd$votes_rep,dd$votes_per_sqkm,dd$votes_total)
        names(dd) <- c("GEOID","margin","votes_dem","votes_rep","votes_per_sqkm","votes_total")
        return(as.data.frame(dd))
    })
    output$myScan <- renderPrint({
        dd <- getNYTData()
        dd <- data.frame(dd$GEOID,dd$pct_dem_lead,dd$votes_dem,dd$votes_rep,dd$votes_per_sqkm,dd$votes_total)
        names(dd) <- c("GEOID","margin","votes_dem","votes_rep","votes_per_sqkm","votes_total")
        dd$fips <- substr(dd$GEOID,1,5)
        dd <- merge(dd,ff)
        dd <- dd[dd$margin >= input$pminmargin & dd$margin <= input$pmaxmargin,]
        dd <- dd %>%
            group_by(county, state, fips) %>%
            summarize(sd=sd(margin),sdW=sdW(margin,votes_total),
                      min=min(margin),max=max(margin),votes=sum(votes_total),n=n()) %>%
            arrange(get(input$sortcol))
        dd <- dd[dd$n >= input$minareas,]
        dd <- dd[dd$votes >= input$minvotes,]
        dd <- dd[dd$min >= input$minmargin,]
        dd <- dd[dd$max <= input$maxmargin,]
        title <- paste0("2020 Presidential Race Margins, ordered by Standard Deviation, weighted by Votes\n\n")
        cat(title)
        return(as.data.frame(dd))
    })
    output$myPlot <- renderPlot({
        dd <- getNYTData()
        if (input$state != "(all)"){
            if (input$county == "(all)"){
                fips <- substr(ff$fips[ff$state == input$state][1],1,2)
            }
            else{
                fips <- ff$fips[ff$state == input$state & ff$county == input$county]
            }
            fips <- paste0("^",fips)
            ee <- dd[grepl(fips, dd$GEOID),]
        }
        else{
            ee <- dd[grepl("^48", dd$GEOID),]
        }
        gg <- ggplot() + geom_sf(data = ee, aes(fill = pct_dem_lead), lwd = 0)
        if (input$addtext){
            gg <- gg + geom_sf_text(data = ee, aes(label = pct_dem_lead), check_overlap = TRUE)
        }
        if (input$midcolor == ""){
            gg <- gg + scale_fill_gradient(low = input$lowcolor, high = input$highcolor,
                                           limits = c(input$minlimit, input$maxlimit))
        }
        else{
            gg <- gg + scale_fill_gradient2(low = input$lowcolor, mid = input$midcolor,
                                            high = input$highcolor, midpoint = 0,
                                            limits = c(input$minlimit, input$maxlimit))
        }
        title <- paste0(input$county," County, ",input$state," - 2020 Presidential Race Margins (percent Democrat lead)")
        gg <- gg + ggtitle(title)
        gg <- gg + xlab("Longitude\nSources: see https://econdataus.com/voting_nyt.htm")
        gg <- gg + ylab("Latitude")
        gg
    }, width = 1000, height = 800)
    output$myHist <- renderPlot({
        dd <- getNYTData()
        if (input$state != "(all)"){
            if (input$county == "(all)"){
                fips <- substr(ff$fips[ff$state == input$state][1],1,2)
            }
            else{
                fips <- ff$fips[ff$state == input$state & ff$county == input$county]
            }
            fips <- paste0("^",fips)
            ee <- dd[grepl(fips, dd$GEOID),]
        }
        else{
            ee <- dd[grepl("^48", dd$GEOID),]
        }
        gg <- ggplot(ee, aes(x=pct_dem_lead))
        gg <- gg + geom_histogram(breaks=seq(input$minhist,input$maxhist,input$stephist),
                                  color="darkblue", fill="lightblue")
        title <- paste0(input$county," County, ",input$state," - 2020 Presidential Race Margins (percent Democrat lead)")
        gg <- gg + ggtitle(title)
        gg <- gg + xlab("Margin") + ylab("Count")
        gg
    }, width = 800, height = 600)
    observeEvent(input$state,{
        if (input$state == "all"){
            updateSelectInput(session, "county", choices = "(all)", selected = "(all)") 
        }
        else{
            counties <- c(ff$county[ff$state == input$state], "(all)")
            if (input$county == "(all)"){
                updateSelectInput(session, "county", choices = counties, selected = "(all)")
            }
            else{
                updateSelectInput(session, "county", choices = counties, selected = counties[1])
            }
        }
    })
    getNYTData <- reactive({
        if (exists("zzdd")){
            dd <- zzdd
        }
        else{
            #print("BEFORE getNYTData()")
            dd <- geojsonsf::geojson_sf("precincts-with-results.geojson/precincts-with-results.geojson",
                                        expand_geometries = TRUE)
            #print(" AFTER getNYTData()")
            zzdd <<- dd
        }
        return(dd)
    })
})
