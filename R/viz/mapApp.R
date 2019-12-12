#!/usr/bin/env Rscript
setwd('C:/users/giovanni.marelli/lav/media/')

library(shiny)
library(rCharts)

dat <- data.frame(Offence =  c("Assault","Assault","Assault","Weapon","Assault","Burglary"),
                  Date = c("2015-10-02","2015-10-03","2015-10-04","2015-04-12","2015-06-30","2015-09-04"),
                  Longitude = c(-122.3809, -122.3269, -122.3342, -122.2984, -122.3044, -122.2754),
                  Latitude = c(47.66796,47.63436,47.57665,47.71930,47.60616,47.55392),
                  intensity = c(10,20,30,40,50,30000))


serverS <- shinyServer(function(input, output, session) {

  output$baseMap <- renderMap({
    baseMap <- Leaflet$new()
    baseMap$setView(c(47.5982623,-122.3415519) ,12)
    baseMap$tileLayer(provider="Esri.WorldStreetMap")
    baseMap
  })

  output$heatMap <- renderUI({

    ## here I'm creating the JSON through 'paste0()'.
    ## you can also use jsonlite::toJSON or RJSONIO::toJSON

    j <- paste0("[",dat[,"Latitude"], ",", dat[,"Longitude"], ",", dat[,"intensity"], "]", collapse=",")
    j <- paste0("[",j,"]")
    j

    tags$body(tags$script(HTML(sprintf("
                      var addressPoints = %s
                      var heat = L.heatLayer(addressPoints).addTo(map)"
                                       , j
    ))))
  })

})

uiS <- shinyUI(fluidPage(

  mainPanel(
    headerPanel("title"),
    chartOutput("baseMap", "leaflet"),
    tags$style('.leaflet {height: 500px;}'),
    tags$head(tags$script(src="http://leaflet.github.io/Leaflet.heat/dist/leaflet-heat.js")),
    uiOutput('heatMap')
    )
  ))
runApp(list(ui=uiS,server=serverS))
