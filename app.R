# Charger les packages nécessaires
library(shiny)
library(googlesheets4)
library(stringr)
library(dplyr)
library(shinythemes)
library(tidyr)
library(httr)
library(jsonlite)
library(kableExtra)

# Définir l'URL de votre Google Sheet
google_sheet_url <- "https://docs.google.com/spreadsheets/d/1-kx5DeAHFoQkVI0W7wNeOwvc2jV1q4IEhG1V0nxANNk/edit?usp=sharing"

# Fonction pour lire les données depuis Google Sheets
read_google_sheet <- function(url) {
  gs4_deauth()
  sheet <- gs4_get(url)
  data <- range_read(sheet)
  return(data)
}

# Définir l'interface utilisateur
ui <- fluidPage(
  theme = shinytheme("darkly"),
  titlePanel("Générateur de liste de courses"),
  sidebarLayout(
    sidebarPanel(
      selectizeInput("mois", "Mois de l'année :", choices = NULL, multiple = TRUE),
      actionButton("generate", "Afficher les repas potentiels"),
      uiOutput("kitten_image")
    ),
    mainPanel(
      uiOutput("repas_potentiels"),
      uiOutput("liste_course"),

    )
  )
)

# Définir le serveur
server <- function(input, output, session) {
  
  # Charger les données depuis Google Sheets au lancement de l'application
  data <- reactive({
    read_google_sheet(google_sheet_url)
  })
  
  # Mettre à jour les choix de la liste déroulante du mois de l'année
  observe({
    updateSelectizeInput(session, "mois", choices = names(data())[3:length(names(data()))])
  })
  
  # Fonction pour générer la liste de repas potentiels
  repas_potentiels <- eventReactive(input$generate, {
    req(input$mois)
    recettes <- data() %>%
      filter_at(vars(input$mois), any_vars(. == "Oui")) %>%
      pull(Repas) %>%
      unique()
    recettes
  })
  
  # Afficher la liste de repas potentiels
  output$repas_potentiels <- renderUI({
    if (!is.null(repas_potentiels())) {
      checkboxGroupInput("selected_repas", "Sélectionnez vos repas :", choices = repas_potentiels())
    }
  })
  

  
  # Generate the list of courses
  output$liste_course <- renderTable({
    if (!is.null(input$selected_repas)) {
      courses <- data() %>%
        filter(Repas %in% input$selected_repas) %>%
        select(Repas, ingredients) %>%
        unique() %>%
        separate_rows(ingredients, sep = ",") %>%
        mutate(ingredients = trimws(ingredients)) %>%
        group_by(ingredients) %>%
        summarize("dans combien de repas ?" = n())
      courses
    }
  })
  
  # Function to fetch a random cat image
  fetch_cat_image <- function(api_key) {
    headers <- add_headers("x-api-key" = api_key)
    response <- GET("https://api.thecatapi.com/v1/images/search", headers)
    if (http_type(response) == "application/json") {
      cat_data <- fromJSON(content(response, as = "text"))
      if (!is.null(cat_data)) {
        cat_url <- cat_data$url
        return(cat_url)
      }
    }
    return(NULL)
  }
  
  
  
  cat_api_key <- "live_7yPVjX52gUfvgfswmYUDOgLOZEExoiYeSpnACyMK2KaCmx7ReFLzErHKwhbWxZGc"  # Replace with your actual API key
  
  # Render kitten image
  output$kitten_image <- renderUI({
    cat_url <- fetch_cat_image(cat_api_key)
    if (!is.null(cat_url)) {
      tags$img(src = cat_url, width = "200px", height = "200px")
    } else {
      tags$p("Failed to fetch cat image")
    }
    
    })

  
  
  
}
# Lancer l'application Shiny
shinyApp(ui = ui, server = server)
