library(leaflet)
library(shiny)
library(googleway)

restaurant <- read.csv("/Users/Yunhao/Desktop/shiny_app/data/restaurant_NYC.csv",as.is = T)

navbarPage("Restaurant",id = "nav",
  tabPanel("Interactive map",
    div(class="outer",
        
        tags$head(
          # Include our custom CSS
          includeCSS("styles.css"),
          includeScript("gomap.js")
        ),
        
        leafletOutput("map",width="100%", height="100%"),
        
        absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                      draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                      width = 330, height = "auto",
                      
                      h2("Option"),
                      
                      selectInput("Box1","Restaurant Categories", choices = unique(sort(restaurant$categories)),selected = "Chinese"),
                      selectInput("Box2","Restaurant Price", choices = c("All",unique(sort(restaurant$price)))),
                      selectInput("Box3","Restaurant Rating",choices = list('⭐' = 1, '⭐⭐'= 2, '⭐⭐⭐' = 3, 
                                                                            '⭐⭐⭐⭐' = 4, '⭐⭐⭐⭐⭐' = 5), selected = 4),
                      selectInput("Box5","Arrival time",choices = list('12 AM' = 0,'1 AM' = 1,'2 AM' = 2,'3 AM' = 3,
                                                                      '4 AM' = 4,'5 AM' = 5,'6 AM' = 6,'7 AM' = 7,
                                                                      '8 AM' = 8,'9 AM' = 9,'10 AM' = 10,'11 AM' = 11,
                                                                      '12 AM' = 12,'1 PM' = 13,'2 PM' = 14,'3 PM' = 15,
                                                                      '4 PM' = 16,'5 PM' = 17,'6 PM' = 18,'7 PM' = 19,
                                                                      '8 PM' = 20,'9 PM' = 21,'10 PM' = 22,'11 PM' = 23)),
                      checkboxInput("Box4","Show Non-Problematic Restaurant?", value = TRUE)
        )
        
                      
  )
),
  tabPanel("Data Explore",
    div(
      class = "Outer",
      google_mapOutput("myMap", width = "110%", height = "900px"),
      
      absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                    draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                    width = 330, height = "auto",
      textInput(inputId = "origin", label = "Origin"),
      textInput(inputId = "destination", label = "Destination"),
      selectInput(inputId = "way", label = "Transportation",choices = c("walking","bicycling","transit","driving")),
      actionButton(inputId = "getRoute", label = "Get Rotue")
      
    )
    )
  )

)