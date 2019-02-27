#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
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

restaurant <- read.csv("restaurant_NYC.csv",as.is = T)
crime <- read.csv("Crime_Hour.csv")

# Marker
crime_icon <- makeIcon(
  iconUrl = "https://upload.wikimedia.org/wikipedia/commons/c/c3/Maki2-danger-24.svg"
)


shinyServer(function(input, output,session) {
  
  # TAB 1
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$Esri.WorldTopoMap,
                       options = providerTileOptions(noWrap = TRUE)) %>%
      setView(lng = -73.985664, lat = 40.748440, zoom = 12) %>%
      addLayersControl(position = "topleft", overlayGroups = c("Crime","Restaurants")) %>%
      hideGroup("Crime")
  })
  
  observe({
    category = input$Box1
    price = input$Box2
    rate = input$Box3
    crime_time = input$Box5
    violated = input$Box4
    
    
    data1 <-reactive({
      restaurant[restaurant$categories == category & restaurant$price %in% price &
                   restaurant$rating >= rate,]
    })
    
    data3 <- reactive({
      if(violated){
        data1()[data1()$Problem == 0,]
      }
      else{
        data1()
      }
    })
    
    
    data2 <-reactive({
      crime[crime$Hour == crime_time,]
    })
    
    points <- reactive({
      data3()[,c(5,6)]
    })
    
    points_crime <-reactive({
      data2()[,c(1,2)]
    })
    
    observe({
      leafletProxy("map") %>%
        clearMarkers() %>%
        addMarkers(data =points(),popup = paste("<B><font size=\"4\"><b>",'<a href = "http://www.google.com/search?q=',data3()$name,'">',data3()$name, "</a></b></font></B> <br>",
                                                data3()$address, "<br>",
                                                "<B> Price:</B>","<font color=\"#EA3D18\"><b>",data3()$price,"</b></font>","<br>",
                                                "<B> Rating: </B>","<font color=\"#EA3D18\"><b>",data3()$rating,"</b></font>","<br>",
                                                "<B> Reviews: </B>",data3()$review_count),group = "Restaurants") %>%
        clearMarkerClusters() %>%
        addMarkers(data =points_crime(),popup = paste("<B>",data2()$LAW_CAT_CD,"</B>"),clusterOptions = markerClusterOptions(),icon = crime_icon,group = "Crime")
    })
  })
  
  observeEvent(input$direction,{
    newvalue <- "Direction"
    updateTabItems(session, "panels", newvalue)
    x <- input$name
    updateTextInput(session,"destination",value = paste(x))
  })
  
  # TAB 2
  
  api_key <- "AIzaSyCIbMSl4ey6gxtalI71vGBOjhKXVcCjOLY"
  map_key <- "AIzaSyCIbMSl4ey6gxtalI71vGBOjhKXVcCjOLY"
  
  df_route <- eventReactive(input$getRoute,{
    
    
    o <- input$origin
    d <- input$destination
    w <- input$way
    a <- input$avoid
    # t <- input$transit_mode
    p <- input$prefer
    

    if(w == 'driving'){
      return(data.frame(origin = o, destination = d, mode = w ,avoid = a,stringsAsFactors = F))
    }else if(w == 'bus' | w == 'subway'){
      return(data.frame(origin = o, destination = d, mode = 'transit',transit_mode = w,prefer = p,stringsAsFactors = F))
    }else{
      return(data.frame(origin = o, destination = d,mode = w,stringsAsFactors = F))
    }

    return(data.frame(origin = o, destination = d, mode = w, avoid = a, prefer = p, transit_mode=t ,stringsAsFactors = F))
  })
  output$myMap <- renderGoogle_map({
    
    df <- df_route()
    if(df$origin == "" | df$destination == "")
      return()
  
    res <- google_directions(
      key = api_key
      , origin = df$origin
      , destination = df$destination
      , mode = df$mode 
      , avoid = df$avoid
      , transit_mode = df$transit_mode
      , transit_routing_preference = df$prefer
      , alternatives = FALSE
    )
    
    df_route <- data.frame(route = res$routes$overview_polyline$points)
    
    start<- google_geocode(address = df$origin,
                           key = map_key,
                           simplify = TRUE)$results$geometry$location
    start$address<-df$origin
    end<- google_geocode(address = df$destination,
                         key = map_key,
                         simplify = TRUE)$results$geometry$location
    end$address<-df$destination
    c<-rbind(start,end)
    
    google_map(key = map_key ) %>%
      add_polylines(data = df_route, polyline = "route",stroke_colour = "#05066A")%>%
      add_markers(data=c,lat='lat',lon='lng',mouse_over='address') 
  })
  
})
