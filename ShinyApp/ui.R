# Define UI
ui <- navbarPage(
  "Car Data Explorer",

  tags$style(HTML("
    body {
      background-color: #f0f8ff; 
    }
    h1 {
      color: #4CAF50;
    }
    .my-button {
      background-color: #FF6347;
      color: white;
      border-radius: 5px;
      padding: 10px;
    }
  ")),
  
  # Page 1 for viewing all car with filters
  tabPanel("All Car Data",
           sidebarLayout(
             sidebarPanel(
               h4("Filter options:"),
               selectInput("carnameFilter", "Name:", 
                           choices = unique(car_data$Name), 
                           selected = NULL, multiple = TRUE),
               selectInput("companyFilter", "Company:", 
                           choices = unique(car_data$Company), 
                           selected = NULL, multiple = TRUE),
               selectInput("fuelFilter", "Fuel Type:", 
                           choices = unique(car_data$Fuel_type), 
                           selected = NULL, multiple = TRUE),
               selectInput("seatfilter", "Seating Capacity:", 
                           choices = unique(car_data$Seating_capacity), 
                           selected = NULL, multiple = TRUE),
               selectInput("pricefilter", "Price Range:", 
                           choices = unique(car_data$Price_Category), 
                           selected = NULL, multiple = TRUE)
             ),
             mainPanel(
               # Image Plot section
               div(
                 class = "center-plot", 
                 plotOutput("image_plot", height = "500px") 
               ),
               
               # Car Data Table
               div(
                 class = "dataset-table",
                 DTOutput("carTable")
               )
             )
           )
  ),
  # Tab 2: Compare Cars
  tabPanel("Comparison",
           sidebarLayout(
             sidebarPanel(
               selectInput("car1", "Select Car 1", choices = car_data$Name, selected = "MG Windsor EV"),
               selectInput("car2", "Select Car 2", choices = car_data$Name, selected = "Hyundai Alcazar")
             ),
             mainPanel(
               h2("Car Comparison"),
               
               # Two images side by side
               fluidRow(
                 column(6, 
                        imageOutput("car1_image", height = "auto")),
                 column(6, 
                        imageOutput("car2_image", height = "auto"))
               ),
               
               # Comparison Table
               DTOutput("comparisonTable")
             )
           )
  ),
  #tab 3: comparision of companies
  tabPanel("Company Analysis",
           sidebarLayout(
             sidebarPanel(
               h4("Car Data Overview"),
               p("Select companies to display the corresponding graphs."),
               
               # Dropdown for selecting companies
               selectInput("selected_companies", 
                           "Select Company:", 
                           choices = c("All" = "All", unique(car_data$Company)), 
                           selected = "All", multiple = TRUE),
               # Dropdown for selecting fuel type
               selectInput("fuelFilter3", 
                           "Select Fuel Type:", 
                           choices = c("All" = "All", "Petrol", "Diesel", "Electric", "Hybrid"), 
                           selected = "All", multiple = TRUE)
             ),
             mainPanel(
               h2("Car Comparison Graphs"),
               fluidRow(
                 column(12, plotlyOutput("rankVsCompanyPlot"))
               ),
               fluidRow(
                 column(12, plotlyOutput("companyHistogram"))
               )
             )
           )
  ),
  # Page 4: Stats Based on Rank
  tabPanel("Rank Analysis",
           sidebarLayout(
             sidebarPanel(
               # Slider input for selecting the range of Rank
               sliderInput("rankRange", "Select Rank Range:",
                           min = min(car_data$Rank, na.rm = TRUE),
                           max = max(car_data$Rank, na.rm = TRUE),
                           value = c(min(car_data$Rank, na.rm = TRUE), 100),
                           step = 10), 
               h4("Filter by Fuel Type"),
               selectInput("fuelFilter2", "Fuel Type:", 
                           choices = c("All", "Petrol", "Diesel", "Electric", "Hybrid"), 
                           selected = "All", multiple = FALSE)
             ),
             mainPanel(
               plotlyOutput("rankVsFuelTypePlot"),
               plotlyOutput("rankVsSeatingCapacityPlot")
             )
           )
  )
)
