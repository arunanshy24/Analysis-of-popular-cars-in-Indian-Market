# Load required libraries
library(rvest)
library(tidyverse)
library(httr)

final = character(0)

#html link reading
for( i in 1:12){
  url = paste0("https://www.cartrade.com/api/filterpage/models?pageNo=", i)
  webpage = read_html(url)
  # Scrape all car links
  car_links <- webpage %>%
    html_nodes("div.ucarRsltCol-2 h3 a") %>%
    html_attr("href")
  # Base URL to be appended to relative car links
  base_url <- "https://www.cartrade.com"
  # Append the base URL to each car link
  full_car_links <- paste0(base_url, car_links)
  final = c(final, full_car_links )
}

num = length(final)

# Set a longer timeout so not stop in between
response <- GET("https://www.cartrade.com", timeout(50000))
#Creating Arrays of Data
Carname = character(num)
Seating_capacity = character(num)
Fuel_type = character(num)
Price = character(num)
Company = character(num)
Images = character(num)
Colour_No= numeric(length = num)
Variants_No= numeric(length = num)

#extracting car name
#going through each link to get data
for (i in 1:num ){
  #reading url of each car
  url= final[i]
  webpage = read_html(url)
  # Extract the title or name from the 'h1' tag
  Carname[i] <- webpage %>%
    html_node(".model-overview-title") %>% 
    html_text(trim = TRUE)
}
#if error occur then re-run code

#Extracting the company
# Extracting the first word from each car name
Company <- sapply(Carname, function(x) {
  strsplit(x, " ")[[1]][1] 
})

#extracting seating capacity
#going through each link to get data
for (i in 1: num ) {
  #reading url of each car
  url= final[i]
  webpage = read_html(url)
  # Extract the seating capacity by selecting the row with "Seating Capacity"
  Seating_capacity[i] <- webpage %>%
    html_node(xpath = "//tr[th/p[text()='Seating Capacity']]/td") %>%
    html_text(trim = TRUE)
  
}
#if error occur then re-run code

for(i in 1:num){
  Seating_capacity[i]= substr(Seating_capacity[i], start =nchar(Seating_capacity[i])-8 ,
                              stop= nchar(Seating_capacity[i])-7)
}
Seating_capacity = as.numeric(Seating_capacity)

#fuel type
#going through each link to get data
for (i in 1: num ) {
  #reading url of each car
  url= final[i]
  webpage = read_html(url)
  # Extract the fuel type from the specific HTML element
  Fuel_type[i] <- webpage %>%
    html_node(".fueltypes") %>% 
    html_text(trim = TRUE)
}
#if error occur then re-run code

#extracting Price
#going through each link to get data
for (i in 1: num ) {
  #reading url of each car
  url= final[i]
  webpage = read_html(url)
  # Extract the price data
  Price[i] <- webpage %>%
    html_node(xpath = "//tr[th/p[text()='Price']]/td") %>%
    html_text(trim = TRUE)
}
#if error occur then re-run code

#extracting images of each car
# Specify the folder name in which images are stored
output_folder <- "./images/" 
dir.create(output_folder, recursive = TRUE)
i=1
for(i in 1: num){
  url = final[i]
  # Read the HTML content of the webpage
  webpage <- read_html(url)
  # Extract the image URL using CSS selector
  image_url <- webpage %>%
    html_node("img[data-testing-id='overview-carousel-image-0']") %>%
    html_attr("src")
  output_file = paste0("./Images/", Company[i]," ", Carname[i], ".jpg")
  GET(image_url, write_disk(output_file, overwrite = TRUE))
  Images[i] = output_file
}
# if not completed then run this code then re-run
#if completed then continue

#getting no of available colours
# Initialize a list to store colors
colors <- vector("list", num)  # Using a list to store unique colors

# Loop through the URLs
for (i in 1: num) {
  url <- paste0(final[i], "colours/")  # Get the current URL
  page <- read_html(url)  # Read the HTML content of the page
  
  # Extract colors from the page
  extracted_colors <- page %>%
    html_nodes(".seo-text-colour-links") %>%
    html_text()
  
  # Check if extracted_colors is not empty
  if (length(extracted_colors) > 0) {
    # Store unique colors in the list as a character vector
    colors[[i]] <- unique(extracted_colors)  
  } else {
    # Handle the case where no colors are found
    colors[[i]] <- character(0)  # Store an empty character vector
  }
  Colour_No[i]= length(colors[[i]])
}

#extracting variants
#initialising list
variants = vector("list", num)
for (i in 1: num) {
  url = paste0(final[i], "#Vaiants")
  page = read_html(url)
  extracted = page %>% html_nodes(".car-vrsn") %>%
    html_text()
  if (length(extracted) > 0) {
    variants[[i]] <- unique(extracted)  
  } else {
    variants[[i]] <- character(0)
  }
  Variants_No[i]= length(variants[[i]])
}

#saving the data
# Creating the data frame
Car_data <- data.frame(
  Rank= 1:num,
  Name = Carname,
  Company= Company,
  Seating_capacity = Seating_capacity,
  Fuel_type = Fuel_type,
  Price = Price,
  No_of_Colours = Colour_No,
  No_of_Variants = Variants_No
)
Image_data <- data.frame(
  Name = Carname,
  Image_Path = Images
)
Colours_Avai = data.frame(
  Name = Carname,
  Colours = I(colors)
)
Variants_Avai = data.frame(
  Name= Carname,
  Variants = I(variants)
)
Car_data$Company = replace(Car_data$Company, Car_data$Company== "Maruti", "Maruti Suzuki")


#Cleaning Prices
prices <- Car_data$Price
# Function to clean price data
clean_price <- function(price) {
  # Remove '₹' and extra spaces
  price <- gsub("₹", "", price)
  price <- gsub("\\s+", " ", price)
  # Handle 'Crore' and 'Lakh' units
  price <- gsub(" Crore", "0000000", price)
  price <- gsub(" Lakh", "00000", price)
  # Check if it's a range (indicated by '-')
  if (grepl("-", price)) {
    # Extract the range and calculate the average
    values <- as.numeric(unlist(strsplit(price, "-")))
    avg_price <- mean(values)
  } else {
    # Single value
    avg_price <- as.numeric(price)
  }
  return(avg_price)
}
# Apply function to the dataset
Car_data$Cleaned_Price <- sapply(prices, clean_price)
Is_Crore <- grepl("Crore", Car_data$Price)  # TRUE if in Crore
for (i in 1:238) {
  if(Is_Crore[i]){
    Car_data$Cleaned_Price[i]= Car_data$Cleaned_Price[i]*100
  }
}
# Function to categorize price into ranges
categorize_price <- function(price) {
  if (price <= 10) {
    return("0-10 Lakh")
  } else if (price <= 20) {
    return("10-20 Lakh")
  } else if (price <= 50) {
    return("20-50 Lakh")
  } else if (price <= 100) {
    return("50 Lakh - 1 Crore")
  } else {
    return("Above 1 Crore")
  }
}

# Modify Fuel_type to categorize all non-Petrol, non-Diesel, non-Electric as Hybrid
Car_data$Fuel_type <- ifelse(Car_data$Fuel_type %in% c("Petrol", "Diesel", "Electric"), 
                             Car_data$Fuel_type, "Hybrid")

# Categorize Price
Car_data$Price_Category <- sapply(Car_data$Cleaned_Price, categorize_price)

#saving data
save(Car_data, file = "Car_data.Rdata")
save(Image_data, file = "Image_Path.Rdata")
save(Colours_Avai, file = "Colour_Data.Rdata")
save(Variants_Avai, file= "Variants_Data.Rdata")
save.image(".RData")
