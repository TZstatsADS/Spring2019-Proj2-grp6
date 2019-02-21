
library(shiny)
library(leaflet.extras)
restaurant <- read.csv("/Users/Yunhao/Desktop/shiny_app/data/restaurant_NYC.csv",as.is = T)
crime <- read.csv("/Users/Yunhao/Desktop/shiny_app/data/Crime_Hour.csv")

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
      if (price == "All"){
        restaurant[restaurant$categories == category & restaurant$rating >= rate,]
      }else{
        restaurant[restaurant$categories == category & restaurant$price == price &
                     restaurant$rating >= rate,]
      }
      
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
# TAB 2

  api_key <- "AIzaSyC_yBRuteiVlRtQ3qjlBZgnc4SUZQ8bupw"
  map_key <- "AIzaSyC_yBRuteiVlRtQ3qjlBZgnc4SUZQ8bupw"
  
  df_route <- eventReactive(input$getRoute,{
    
    print("getting route")
    
    o <- input$origin
    d <- input$destination
    w <- input$way
    
    return(data.frame(origin = o, destination = d, mode = w ,stringsAsFactors = F))
  })
  output$myMap <- renderGoogle_map({
    
    df <- df_route()
    print(df)
    if(df$origin == "" | df$destination == "")
      return()
    
    res <- google_directions(
      key = api_key
      , origin = df$origin
      , destination = df$destination
      , mode = df$mode 
      , alternatives = TRUE
    )
    
    df_route <- data.frame(route = res$routes$overview_polyline$points)
    
    google_map(key = map_key ) %>%
      add_polylines(data = df_route, polyline = "route")
  })
  
})
