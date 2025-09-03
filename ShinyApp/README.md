# Car Data Explorer - Shiny App

## Overview

The Car Data Explorer is an interactive Shiny web application that allows users to explore a dataset of cars with various attributes, including name, company, seating capacity, fuel type, price, and rank. The app includes features to filter, compare, and visualize insights into car rankings and company distributions.

## Features

### 1. All Cars Data
- Allows users to view the entire car dataset with filter options:
  - **Name**: Filter by car name.
  - **Company**: Filter by car company.
  - **Fuel Type**: Filter by fuel type (Petrol, Diesel, Electric, Hybrid).
  - **Seating Capacity**: Filter by seating capacity.
- Displays a car image plot and a data table of filtered results.
  
### 2. Compare Two Cars
- Provides an interface for side-by-side comparison of two selected cars.
- Displays:
  - Images of both cars.
  - Comparison table showing attributes such as name, company, seating capacity, fuel type, price, number of colors available, and number of variants.

### 3. Comparison of Companies
- Visualizes car rankings by company and fuel type, with options to filter by:
  - **Company**: Select one or multiple companies to compare.
  - **Fuel Type**: Select a fuel type to refine the comparison.
- Includes plots for:
  - **Rank vs. Company**: Shows car rankings for selected companies.
  - **Number of Cars by Company**: Histogram showing the count of cars per company.

### 4. Comparison of Rank of Cars
- Visualizes car rank distributions based on fuel type and seating capacity.
- Includes:
  - **Rank Range Slider**: Select a range of ranks to display.
  - **Fuel Type Filter**: Choose a fuel type for additional filtering.
- Plots:
  - **Rank vs. Fuel Type**: Shows rank distributions across fuel types.
  - **Rank vs. Seating Capacity**: Shows rank distributions across seating capacities.

## Installation

1. Install R and Shiny:
    ```R
    install.packages("shiny")
    install.packages("DT")
    install.packages("ggplot2")
    install.packages("plotly")
    install.packages("jpeg")
    install.packages("webshot2")
    ```

2. Load your data files:
   - `Car_data.Rdata`: Contains the car data.
   - `Image_Path.Rdata`: Contains image paths for each car.
   
3. Merge the data files in the code:
    ```R
    car_data <- merge(Car_data, Image_data, by = "Name", all = TRUE)
    ```

## Usage

1. Launch the Shiny app with:
    ```R
    shinyApp(ui = ui, server = server)
    ```

2. Explore car data across four tabs:
   - **All Cars Data**: Filter and view car information.
   - **Compare Two Cars**: Select and compare two cars side-by-side.
   - **Comparison of Companies**: Visualize car rankings by company.
   - **Comparison of Rank of Cars**: Analyze rank distribution based on fuel type and seating capacity.

## Code Structure

- **UI**: The app's user interface, created with `navbarPage` for navigation, includes four main tabs:
  - `All Cars Data`
  - `Compare Two Cars`
  - `Comparison of Companies`
  - `Comparison of Rank of Cars`

- **Server**: The server processes data filtering, plotting, and image rendering based on user inputs.

- **Images**: Images are rendered using the `jpeg` package. Image files are expected to be available at the paths specified in `Image_Path.Rdata`.

## Libraries

- `shiny`: For building the interactive web application.
- `DT`: For rendering data tables.
- `ggplot2` & `plotly`: For creating interactive plots and visualizations.
- `jpeg`: For displaying car images.

## Dataset

Ensure `Car_data.Rdata` and `Image_Path.Rdata` files are available and loaded properly. Data includes:
- `Name`: Car name.
- `Company`: Manufacturer.
- `Fuel_type`: Fuel type.
- `Price`: Car price.
- `Seating_capacity`: Number of seats.
- `Rank`: Car ranking.
- `Image_Path`: Path to car images.
