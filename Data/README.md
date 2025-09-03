# Car Information Scraper

## Overview

This R script scrapes detailed information about cars available in India from the CarTrade website. It retrieves data such as car names, companies, seating capacity, fuel types, prices, and images. The extracted data is then saved in RData files for further analysis.

## Libraries Used

The following R libraries are required to run this script:

- `rvest`: For web scraping and parsing HTML content.
- `tidyverse`: For data manipulation and analysis.
- `httr`: For making HTTP requests and handling web responses.

## Code Explanation

### Loading Required Libraries

```r
library(rvest)
library(tidyverse)
library(httr)
```
## Web Scraping Process

### Extract Car Links

The script starts by scraping car links from multiple pages of the CarTrade website. The main car listing page URL is used to collect the initial batch of links, followed by pagination URLs.

### Combining Links

Car links from different pages are combined into a single list, ensuring that only the top 150 car links are retained for further scraping.

## Data Extraction

The script iteratively goes through each car link and extracts the following data:

- **Car Name:** Extracted from the car's detail page.
- **Company:** The first word of the car name.
- **Seating Capacity:** Retrieved from a specific table on the car's detail page.
- **Fuel Type:** Collected from a designated element.
- **Price:** Extracted from a specific table on the car's detail page.
- **Images:** URLs of car images are fetched, and images are downloaded to a specified folder.
- **Colour_No:** No of colours available in the market of the particular car.
- **Variants_No:** No of variants available for a particular car in the market.

## Saving Data

The script creates two data frames:

- **Car_data:** Contains car name, company, seating capacity, fuel type, and price.
- **Image_data:** Contains paths to the downloaded car images.
- **Colour_Data:** Contains the name of the colours availble of each car with its name.
- **Variants_Data:** Contains the name of all available data of the cars.

These data frames are then saved in RData format for easy loading in future analyses.

### Example of Saving Data

```r
save(Car_data, file = "Car_data.Rdata")
save(Image_data, file = "Image_Path.Rdata")
save(Colours_Avai, file = "Colour_Data.Rdata")
save(Variants_Avai, file= "Variants_Data.Rdata")
```

## Directory Structure

The images downloaded from the car links are stored in a folder named `./images/`, created by the script if it doesn't already exist.

## Requirements

Make sure to have the required libraries installed. You can install them using the following commands:

```r
install.packages("rvest")
install.packages("tidyverse")
install.packages("httr")
```
## Usage

1. Ensure your working directory is set to where you want to save the data and images.
2. Run the script in your R environment.
3. Check the working directory for the saved RData files and the images in the specified folder.

## Note

- The script includes a timeout setting to prevent interruptions during the scraping process.
- The number of car links and pages scraped can be adjusted by modifying the loop parameters.
