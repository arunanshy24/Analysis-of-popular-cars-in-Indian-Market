# Define server logic
server <- function(input, output) {
  
  # Reactive data based on filters
  filteredData <- reactive({
    data <- car_data
    if (length(input$companyFilter) > 0) {
      data <- data[data$Company %in% input$companyFilter, ]
    }
    if (length(input$carnameFilter) > 0) {
      data <- data[data$Name %in% input$carnameFilter, ]
    }
    if (length(input$fuelFilter) > 0) {
      data <- data[data$Fuel_type %in% input$fuelFilter, ]
    }
    if (length(input$seatfilter) > 0) {
      data <- data[data$Seating_capacity %in% input$seatfilter, ]
    }
    if (length(input$pricefilter) > 0) {
      data <- data[data$Price_Category %in% input$pricefilter, ]
    }
    data <- arrange(data, Rank)  # Sorting data by Rank
    data
  })
  
  # Render the image plot
  output$image_plot <- renderPlot({
    # Get the filtered data
    data <- filteredData()
    if (nrow(data) > 0) {
      img_path <- data$Image_Path[1]
      # Load the image
      img <- readJPEG(img_path)
      # Get the dimensions of the image
      img_width <- dim(img)[2]
      img_height <- dim(img)[1]
      par(mar = c(0, 0, 0, 0))
      
      # Create a blank plot with no axes, labels, or ticks
      plot(1:img_width, type = "n", xlab = NULL, ylab = NULL, axes = FALSE, 
           xlim = c(0, img_width*1.5), ylim = c(0, img_height), xaxt = "n", yaxt = "n")
      
      # Plot the image in the plot area using rasterImage
      rasterImage(img, 0, 0, img_width, img_height)
    }
  })
  
  # Render DataTable with reordered columns
  output$carTable <- renderDT({
    datatable(filteredData()[, c("Rank", "Name", "Company", "Fuel_type", "Price", "Seating_capacity", "No_of_Variants", "No_of_Colours")], 
              options = list(autoWidth = TRUE), 
              rownames = FALSE)
  })
  
  # Render images for comparison
  output$car1_image <- renderImage({
    # Get the image path for Car 1
    selected_car1 <- car_data[car_data$Name == input$car1, ]
    img_path1 <- selected_car1$Image_Path[1]
    # Return image output
    list(src = img_path1, contentType = 'image/jpeg', width = 500, height = 300)
  }, deleteFile = FALSE)
  
  output$car2_image <- renderImage({
    # Get the image path for Car 2
    selected_car2 <- car_data[car_data$Name == input$car2, ]
    img_path2 <- selected_car2$Image_Path[1]
    
    # Return image output
    list(src = img_path2, contentType = 'image/jpeg', width = 500, height = 300)
  }, deleteFile = FALSE)
  
  # Render the comparison table
  output$comparisonTable <- renderDT({
    car1Data <- car_data[car_data$Name == input$car1, c("Name", "Company", "Seating_capacity", "Fuel_type", "Price", "No_of_Colours", "No_of_Variants")]
    car2Data <- car_data[car_data$Name == input$car2, c("Name", "Company", "Seating_capacity", "Fuel_type", "Price", "No_of_Colours", "No_of_Variants")]
    comparisonData <- data.frame(
      Attribute = c("Name", "Company", "Seating Capacity", "Fuel Type", "Price", "Colour Options", "Variants Available"),
      Car1 = c(car1Data$Name, car1Data$Company, car1Data$Seating_capacity, car1Data$Fuel_type, car1Data$Price, car1Data$No_of_Colours, car1Data$No_of_Variants),
      Car2 = c(car2Data$Name, car2Data$Company, car2Data$Seating_capacity, car2Data$Fuel_type, car2Data$Price, car2Data$No_of_Colours, car2Data$No_of_Variants)
    )
    datatable(comparisonData, options = list(dom = 't', pageLength = 7))
  })
  
  output$rankVsCompanyPlot <- renderPlotly({
    # Filter data
    filtered_data <- if ("All" %in% input$selected_companies) {
      car_data
    } else {
      car_data[car_data$Company %in% input$selected_companies, ]
    }
    # Filter data based on the selected fuel types
    if (!"All" %in% input$fuelFilter3) {
      filtered_data <- filtered_data[filtered_data$Fuel_type %in% input$fuelFilter3, ]
    }
    # Adjust Fuel_type 
    filtered_data$Fuel_type <- ifelse(filtered_data$Fuel_type %in% c("Petrol", "Diesel", "Electric"),
                                      filtered_data$Fuel_type, "Hybrid")
    # Count the number of cars per company
    carCounts <- table(filtered_data$Company)
    carCountsDF <- as.data.frame(carCounts)
    colnames(carCountsDF) <- c("Company", "Count")
    # Reorder companies based on the count (descending order)
    orderedCompanies <- carCountsDF$Company[order(-carCountsDF$Count)]
    filtered_data$Company <- factor(filtered_data$Company, levels = orderedCompanies)
    # Create the plot for Rank vs Company
    p <- ggplot(filtered_data, aes(
      x = Company, 
      y = Rank, 
      color = Fuel_type,  # Color by Fuel Type
      text = paste(
        "Name:", Name, "<br>",
        "Price:", Price, "<br>",
        "Fuel Type:", Fuel_type
      )
    )) +
      geom_point(size = 1, alpha = 0.7) +
      scale_y_reverse() +  # Reverse the y-axis to have a higher rank at the top
      theme_minimal() + 
      labs(title = "Rank of Cars vs Company", x = "Company", y = "Rank") +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for better readability
    # Convert ggplot to plotly for interactivity with tooltip
    ggplotly(p, tooltip = "text") 
  })
  
  output$companyHistogram <- renderPlotly({
    # Filter data 
    filtered_data <- if ("All" %in% input$selected_companies) {
      car_data
    } else {
      car_data[car_data$Company %in% input$selected_companies, ]
    }
    if (!"All" %in% input$fuelFilter3) {
      filtered_data <- filtered_data[filtered_data$Fuel_type %in% input$fuelFilter3, ]
    }
    # Adjust Fuel_type
    filtered_data$Fuel_type <- ifelse(filtered_data$Fuel_type %in% c("Petrol", "Diesel", "Electric"),
                                      filtered_data$Fuel_type, "Hybrid")
    # Count the number of cars per company
    carCounts <- table(filtered_data$Company)
    carCountsDF <- as.data.frame(carCounts)
    colnames(carCountsDF) <- c("Company", "Count")
    # Reorder companies based on the count
    carCountsDF$Company <- reorder(carCountsDF$Company, -carCountsDF$Count)
    # Create the histogram
    p <- ggplot(carCountsDF, aes(x = Company, y = Count, fill = Company)) +
      geom_bar(stat = "identity") +
      theme_minimal() +
      labs(title = "Number of Cars by Company", x = "Company", y = "Number of Cars") +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    # Return the interactive Plotly plot
    ggplotly(p)
  })
  
  output$rankVsFuelTypePlot <- renderPlotly({
    filtered_data <- car_data
    # Filter based on fuel type
    if (input$fuelFilter2 != "All") {
      filtered_data <- filtered_data[filtered_data$Fuel_type == input$fuelFilter2, ]
    }
    # Filter based on rank range
    filtered_data <- filtered_data[filtered_data$Rank >= input$rankRange[1] & filtered_data$Rank <= input$rankRange[2], ]
    # Plot Rank vs Price Category
    p <- ggplot(filtered_data, aes(x = Rank, y = Price_Category, color = Fuel_type)) +
      geom_point() +
      labs(title = "Rank vs Price Range", x = "Rank", y = "Price Range") +
      theme_minimal()
    ggplotly(p)
  })
  output$rankVsSeatingCapacityPlot <- renderPlotly({
    # Filter the data 
    filtered_data <- car_data
    
    # Filter based on fuel type
    if (input$fuelFilter2 != "All") {
      filtered_data <- filtered_data[filtered_data$Fuel_type == input$fuelFilter2, ]
    }
    # Filter based on rank range from the slider
    filtered_data <- filtered_data[filtered_data$Rank >= input$rankRange[1] & filtered_data$Rank <= input$rankRange[2], ]
    # Plot Rank vs Seating Capacity
    p <- ggplot(filtered_data, aes(x = Rank, y = Seating_capacity, color = Fuel_type)) +
      geom_point() +
      labs(title = "Rank vs Seating Capacity", x = "Rank", y = "Seating Capacity") +
      theme_minimal()
    ggplotly(p)
  })
}
