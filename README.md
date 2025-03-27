# Animated Geospatial Visualization

**Link to Publish App: [Geospatial Visualization](https://apiyarali.shinyapps.io/AirMiles3D/)**

  * [Overview](#Overview)
  * [Features](#Features)
  * [Installation](#Installation)
  * [Usage](#Usage)
  * [Mathematical Concepts](#mathematical-concepts)
   *  [Dot Product](#Dot-Product)
   *  [Cross Product](#Cross-Product)
   *  [Great-Circle Navigation](#Great-Circle-Navigation)
   *  [Mercator Projection](#Mercator-Projection)
    

  ## Overview
  This project explores the mathematical foundations of geospatial visualization, specifically focusing on great-circle navigation, vector transformations, and Mercator projections. Using R and Shiny, it provides an interactive experience for users to manipulate geospatial data and apply mathematical principles to navigation and coordinate systems.
  ## Features
  ### 3D Geospatial Navigation
  - Computation and visualization of great-circle routes on a sphere.
  - Interactive city selection and route plotting.
  - Optional Mercator projection with constant compass-heading navigation.
  ## Installation
  ### Prerequisites
  - **R and RStudio**
  - Required R packages: `shiny`, `ggplot2`, `rgl`
  ### Setup
  ```sh
  # Clone the repository
  git clone https://github.com/apiyarali/Animated-Geospatial-Visualization.git
  cd GeospatialVisualization
  ```
  ```r
  # Open RStudio and set working directory
  setwd("path/to/project")

  # Install dependencies
  install.packages(c("shiny", "ggplot2", "rgl"))

  # Run the Shiny app
  shiny::runApp()
  ```
  ## Usage
  ### 3D Navigation
  1. **Load City Data:**
     - Open `spherical.R` and run `sph.makeCityDF()` to load `cities.csv`.
  2. **Select Start and Destination:**
     - Use dropdown menus to pick cities.
     - The system extracts and computes latitude, longitude, and unit vectors.
  3. **Plot Routes:**
     - Choose between **3D globe projection** and **Mercator projection**.
     - Great-circle routes curve correctly in 3D.
     - Mercator projection routes are straight, preserving a constant compass heading.
  4. **Add New Cities:**
     - Enter a city name, latitude, and longitude.
     - Western Hemisphere cities are displayed in **red**.
  5. **Modify Routes:**
     - Click **AddRoute** to append new routes.
     - The app updates distance, direction vectors, and headings accordingly.
  ## Mathematical Concepts
  This project involves several fundamental mathematical principles for geospatial calculations:
  ### **Vector Mathematics**
  #### Dot Product
  Computes the angle between two vectors on a sphere:
  ```math
  \mathbf{A} \cdot \mathbf{B} = |\mathbf{A}| |\mathbf{B}| \cos d
  ```
  where \(d\) is the angular distance between points.
  #### Cross Product
  Determines a perpendicular vector necessary for directional calculations:
  ```math
  \mathbf{A} \times \mathbf{B}
  ```
  ### **Great-Circle Navigation**
  The shortest path between two points on a sphere follows a great circle. The general formula:
  ```math
  \mathbf{P} = \mathbf{A} \cos d + \mathbf{v} \sin d
  ```
  describes how to compute points along this route.

  To find a perpendicular unit vector:
  ```math
  \mathbf{v} = \frac{\mathbf{B} - \mathbf{A} \cos d}{\sin d}
  ```
  This ensures \(\mathbf{v}\) is perpendicular to \(\mathbf{A}\), facilitating accurate geospatial computations.
  ### **Mercator Projection**
  - Transforms spherical coordinates into a 2D Cartesian system.
  - The transformation for latitude \(\phi\) follows:
  ```math
  y = \ln \left( \tan \left( \frac{\pi}{4} + \frac{\phi}{2} \right) \right)
  ```
  - Unlike great-circle routes, Mercator projection routes maintain a constant compass heading, forming straight lines on the map.
 

