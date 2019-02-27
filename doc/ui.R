#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(leaflet)
library(shiny)
library(googleway)
library(shinyWidgets)
library(shinydashboard)

restaurant <- read.csv('restaurant_NYC.csv',as.is = T)


navbarPage("Safe Dining",id = "panels",
           tabPanel("Home",icon=icon("home"),
                    
                    div(class="home",
                        align="center",
                        setBackgroundImage(src = "https://res.cloudinary.com/trump-hotels/image/upload/c_fill,w_1440,ar_8:3/v1519329701/htwwgwknufwes5185ebe.jpg"),
                        
                        br(),
                        br(),
                        br(),
                        br(),
                        br(),
                        br(),
                        br(),
                        h3("Group6 - Spring 2019",style="color:black;font-family: Times New Roman;font-size: 300%;font-weight: bold;"),
                        h3("Project 2: Safe Dining", style = "color:black;font-family: Times New Roman;font-size: 300%;font-weight:bold;")
                      )),
           tabPanel("Interactive map",
                    div(class="outer",
                        
                        tags$head(
                          # Include our custom CSS
                          includeCSS("styles.css"),
                          includeScript("gomap.js")
                        ),
                        
                        leafletOutput("map",width="100%", height="100%"),
                        
                        absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                      draggable = TRUE, top = "auto", left = 20, right = "auto", bottom = 5,
                                      width = "auto", height = "auto",
                                      
                                      h2("  "),
                                      
                                      selectInput("Box1","Cuisine", choices = unique(sort(restaurant$categories)),selected = "Chinese"),
                                      pickerInput("Box2","Restaurant Price", choices=unique(sort(restaurant$price)), options = list(`actions-box` = TRUE),multiple = T,selected = "$$"),
                                      
                                      selectInput("Box3","Restaurant Rating (Above)",choices = list('⭐' = 1, '⭐⭐'= 2, '⭐⭐⭐' = 3, 
                                                                                                    '⭐⭐⭐⭐' = 4, '⭐⭐⭐⭐⭐' = 5), selected = 4),
                                      selectInput("Box5","Arrival/Departure time",choices = list('12 AM' = 0,'1 AM' = 1,'2 AM' = 2,'3 AM' = 3,
                                                                                       '4 AM' = 4,'5 AM' = 5,'6 AM' = 6,'7 AM' = 7,
                                                                                       '8 AM' = 8,'9 AM' = 9,'10 AM' = 10,'11 AM' = 11,
                                                                                       '12 AM' = 12,'1 PM' = 13,'2 PM' = 14,'3 PM' = 15,
                                                                                       '4 PM' = 16,'5 PM' = 17,'6 PM' = 18,'7 PM' = 19,
                                                                                       '8 PM' = 20,'9 PM' = 21,'10 PM' = 22,'11 PM' = 23)),
                                      checkboxInput("Box4","Hide Poor Hygiene Restaurant", value = FALSE),
                                      textInput("name","Enter Restaurant:"),
                                      actionButton("direction","Get Direction")
                        )
                        
                        
                    )
           ),
           tabPanel("Direction",
                    div(
                      class = "Outer",
                      google_mapOutput("myMap", width = "100%", height = "600px"),
                      
                      absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                    draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                    width = 330, height = "auto",
                                    textInput(inputId = "origin", label = "Origin", value='Columbia University'),
                                    textInput(inputId = "destination", label = "Destination"),
                                    selectInput(inputId = "way", label = "Transportation",choices = list("Driving" ="driving","Bus" = "bus","Subway" = 'subway',"Bicycling" = "bicycling","Walking"='walking')),
                                    selectInput(inputId = "avoid", label = "Avoid (Driving Only)",choices = list('Tolls'='tolls', 'Highways'='highways','Ferries'='ferries', 'Indoor'='indoor')),
                                    # selectInput(inputId = "transit_mode", label = "Transit mode",choices = list('Bus'='bus', 'Train'='train','Subway'='subway')),
                                    selectInput(inputId = "prefer", label = "Routing Preference (Non-Driving Only)",choices = list('Fewer transfers'='fewer_transfers', 'Less walking'= 'less_walking')),
                                    actionButton(inputId = "getRoute", label = "Get Route")
                                    
                      )
                    )
           )
           
)