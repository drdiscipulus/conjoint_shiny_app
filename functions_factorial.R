# Function to generate two-level full fractional design
# Relies on the FrF2 package - consult this for further information
get_two_level_full <- function(attributes) {
  # Create an empty character vector for attribute names
  att_names <- vector(mode = "character", length = attributes)
  
  # Fill vector with names
  for (i in seq_along(att_names)) {
    att_names[[i]] <- paste0("att_", i)
  }
  
  # Try to find optimal solution
  res <- fac.design(
    nlevels = 2, nfactors = attributes, factor.names = att_names,
    replications = 1
  )
  
  # Create CorrPlot
  cor_plot <- corrPlot(res, main.only = FALSE, three = FALSE)
  cor_plot <- as.data.frame(cor_plot)
  cor_plot <- rownames_to_column(cor_plot)
  cor_plot <- pivot_longer(cor_plot, cols = !rowname, names_to = "variables", values_to = "correlation")
  cor_plot <- cor_plot |> 
    mutate(rowname = str_sub(rowname, end = -2)) |> 
    mutate(variables = str_sub(variables, end = -2))
  
  str_sub(cor_plot$rowname, 6, 6) <- ""
  str_sub(cor_plot$variables , 6, 6) <- ""
  
  # Convert to data frame
  res <- as.data.frame(res)
  
  # Convert factor to numeric
  res <- res |>
    mutate_if(is.factor, as.character) |>
    mutate_if(is.character, as.numeric)
  
  # Change 1/2 values to 0/1
  res[res == 1] <- 0
  res[res == 2] <- 1
  
  # Create profile column
  profiles <- tibble(Profiles = 1:nrow(res))
  
  # Merge
  res <- cbind(profiles, res)
  
  # Create list
  res <- list(table = res, plot = cor_plot)
  
  # Return
  return(res)
}


# Get two-level full factorial design
get_two_level_fractional <- function(attributes, effects) {
  # Create an empty character vector for attribute names
  att_names <- vector(mode = "character", length = attributes)
  
  # Fill vector with names
  for (i in seq_along(att_names)) {
    att_names[[i]] <- paste0("att_", i)
  }
  
  # Select resoultion based on input
  resolution <- switch(effects,
                       "main_effects" = 3,
                       "two-way" = 4
  )
  
  # Try to find optimal solution
  res <- FrF2(
    nfactors = attributes,
    resolution = resolution,
    factor.names = att_names,
    replications = 1
  )
  
  # Create CorrPlot
  cor_plot <- corrPlot(res, main.only = FALSE, three = FALSE)
  cor_plot <- as.data.frame(cor_plot)
  cor_plot <- rownames_to_column(cor_plot)
  cor_plot <- pivot_longer(cor_plot, cols = !rowname, names_to = "variables", values_to = "correlation")
  cor_plot <- cor_plot |> 
    mutate(rowname = str_sub(rowname, end = -2)) |> 
    mutate(variables = str_sub(variables, end = -2))
  
  str_sub(cor_plot$rowname, 6, 6) <- ""
  str_sub(cor_plot$variables , 6, 6) <- ""
  
  # Convert to data frame
  res <- as.data.frame(res)
  
  # Convert factor to numeric
  res <- res |>
    mutate_if(is.factor, as.character) |>
    mutate_if(is.character, as.numeric)
  
  # Change 1/2 values to 0/1
  res[res == -1] <- 0
  res[res == 1] <- 1
  
  # Create profile column
  profiles <- tibble(Profiles = 1:nrow(res))
  
  # Merge
  res <- cbind(profiles, res)
  
  # Create list
  res <- list(table = res, plot = cor_plot)
  
  # Return
  return(res)
}


# Function to generate any kind of n- or mixed-level designs
get_n_level_full <- function(attributes) {
  # split single string into a string vector
  attributes <- unlist(strsplit(attributes, ","))
  
  # Create empty character vector for attribute names
  att_names <- vector(mode = "character", length = length(attributes))
  
  # Fill vector with names
  for (i in seq_along(att_names)) {
    att_names[[i]] <- paste0("att_", i)
  }
  
  # Coerce character input to numeric
  attributes <- as.numeric(attributes)
  
  # Generate a full factorial design
  res <- fac.design(
    nlevels = attributes, factor.names = att_names,
    replications = 1
  )
  
  # Create CorrPlot
  cor_plot <- corrPlot(res, main.only = FALSE, three = FALSE)
  cor_plot <- as.data.frame(cor_plot)
  cor_plot <- rownames_to_column(cor_plot)
  cor_plot <- pivot_longer(cor_plot, cols = !rowname, names_to = "variables", values_to = "correlation")
  cor_plot <- cor_plot |> 
    mutate(rowname = str_sub(rowname, end = -2)) |> 
    mutate(variables = str_sub(variables, end = -2))
  
  str_sub(cor_plot$rowname, 6, 6) <- ""
  str_sub(cor_plot$variables , 6, 6) <- ""
  
  # Convert to data frame
  res <- as.data.frame(res)
  
  # Convert factor to numeric
  res <- res |>
    mutate_if(is.factor, as.character) |>
    mutate_if(is.character, as.numeric)
  
  # Create profile column
  profiles <- tibble(Profiles = 1:nrow(res))
  
  # Merge
  res <- cbind(profiles, res)
  
  # Create list
  res <- list(table = res, plot = cor_plot)
  
  # Return
  return(res)
}


# Function to generate any kind of n- or mixed-level designs
get_n_level_fractional <- function(attributes, effects, type) {
  # split single string into a string vector
  attributes <- unlist(strsplit(attributes, ","))
  
  # Create empty character vector for attribute names
  att_names <- vector(mode = "character", length = length(attributes))
  
  # Fill vector with names
  for (i in seq_along(att_names)) {
    att_names[[i]] <- paste0("att_", i)
  }
  
  # Coerce character input to numeric
  attributes <- as.numeric(attributes)
  
  
  if (effects == "main_effects") {
    res <- oa.design(nlevels = attributes, columns = "min3", factor.names = att_names)
    
    # Create CorrPlot
    cor_plot <- corrPlot(res, main.only = FALSE, three = FALSE)
    cor_plot <- as.data.frame(cor_plot)
    cor_plot <- rownames_to_column(cor_plot)
    cor_plot <- pivot_longer(cor_plot, cols = !rowname, names_to = "variables", values_to = "correlation")
    cor_plot <- cor_plot |> 
      mutate(rowname = str_sub(rowname, end = -2)) |> 
      mutate(variables = str_sub(variables, end = -2))
    
    str_sub(cor_plot$rowname, 6, 6) <- ""
    str_sub(cor_plot$variables , 6, 6) <- ""
    
    # Create profile column
    profiles <- tibble(Profiles = 1:nrow(res))
    
    # Merge
    res <- cbind(profiles, res)
    
    # Create list
    res <- list(table = res, plot = cor_plot)
  }
  
  if (effects == "two-way") {
    # Create data frame with suitable arrys
    arry_list <- show.oas(nlevels = attributes, regular = "all", GRgt3 = "all", Rgt3 = FALSE, show = 0, parents.only = FALSE, showGRs = TRUE, showmetrics = TRUE, digits = 2)
    
    # Filter out resolution four or better
    arry_list <- arry_list |>
      filter(GR < 4) |>
      # Sort ascending by runs
      arrange(nruns)
    
    # Get the maximum number of rows
    max_rows <- nrow(arry_list)
    
    # If there are more than 100 rows, just pick top 100
    if (max_rows > 100) max_rows <- 100
    
    # Filter out arrays with lineage
    arry_list <- arry_list |>
      slice(1:max_rows) |>
      filter(lineage == "")
    
    # Only get the names of the arrays
    arry_list <- arry_list$name
    
    # Loop over all arrays
    for (i in seq_along(arry_list)) {
      # Load array from namespace
      id <- getAnywhere(arry_list[[i]])$objs$"package:DoE.base"
      class(id) <- c("oa", "matrix")
      
      # Call design function
      res <- oa.design(id, nlevels = attributes, columns = "min3", factor.names = att_names)
      resolution <- GR(res, digits = 2)$GR
      
      # If the resolution is four or better - break
      if (resolution >= 4) {
        
        # Create correlation plot
        cor_plot <- corrPlot(res, main.only = FALSE, three = FALSE)
        cor_plot <- as.data.frame(cor_plot)
        cor_plot <- rownames_to_column(cor_plot)
        cor_plot <- pivot_longer(cor_plot, cols = !rowname, names_to = "variables", values_to = "correlation")
        cor_plot <- cor_plot |> 
          mutate(rowname = str_sub(rowname, end = -2)) |> 
          mutate(variables = str_sub(variables, end = -2))
        
        str_sub(cor_plot$rowname, 6, 6) <- ""
        str_sub(cor_plot$variables , 6, 6) <- ""
        
        # Create profile column
        profiles <- tibble(Profiles = 1:nrow(res))
        
        # Merge
        res <- cbind(profiles, res)
        
        # Create list
        res <- list(table = res, plot = cor_plot)
        
        break
      }
      
      # Else return null
      res <- NULL
    }
    
    # Look up resolution 4 arrays if res is null
    if (is.null(res)) {
      # Get list of possible arrays
      arry_list <- show.oas(nlevels = attributes, regular = "all", GRgt3 = "all", Rgt3 = TRUE, show = 0, parents.only = FALSE, showGRs = TRUE, showmetrics = TRUE, digits = 2)
      
      # Arrange rows by number of runs
      arry_list <- arry_list |>
        arrange(nruns)
      
      # Get total number of rows
      max_rows <- nrow(arry_list)
      
      # Only consider top 100 arrays
      if (max_rows > 100) max_rows <- 100
      
      # Filter for arrays with no lineage
      arry_list <- arry_list |>
        slice(1:max_rows) |>
        filter(lineage == "")
      
      # Array id vector
      arry_names <- arry_list$name
      
      # Loop over all array names
      for (i in seq_along(arry_names)) {
        # Get the matrix
        id <- getAnywhere(arry_names[[i]])$objs$"package:DoE.base"
        class(id) <- c("oa", "matrix")
        
        # Create array
        res <- oa.design(id, nlevels = attributes, columns = "min3", factor.names = att_names)
        resolution <- GR(res, digits = 2)$GR
        
        # Break if there is a solution
        if (resolution >= 4) {
          
          # Create correlation plot
          cor_plot <- corrPlot(res, main.only = FALSE, three = FALSE)
          cor_plot <- as.data.frame(cor_plot)
          cor_plot <- rownames_to_column(cor_plot)
          cor_plot <- pivot_longer(cor_plot, cols = !rowname, names_to = "variables", values_to = "correlation")
          cor_plot <- cor_plot |> 
            mutate(rowname = str_sub(rowname, end = -2)) |> 
            mutate(variables = str_sub(variables, end = -2))
          
          str_sub(cor_plot$rowname, 6, 6) <- ""
          str_sub(cor_plot$variables , 6, 6) <- ""
          
          # Create profile column
          profiles <- tibble(Profiles = 1:nrow(res))
          
          # Merge
          res <- cbind(profiles, res)
          
          # Create list
          res <- list(table = res, plot = cor_plot)
          break
        }
        
        stop("No array exists.")
      }
    }
  }
  
  # Return
  return(res)
}