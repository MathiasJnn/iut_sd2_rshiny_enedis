#installe les packages si ce n'est pas déjà fait
if (!require(shiny)) {
  install.packages("shiny")
}
if (!require(shinythemes)) {
  install.packages("shinythemes")
}
if (!require(ggplot2)) {
  install.packages("ggplot2")
}
if (!require(DT)) {
  install.packages("DT")
}
if (!require(dplyr)) {
  install.packages("dplyr")
}
if (!require(leaflet)) {
  install.packages("leaflet")
}
if (!require(shinyWidgets)) {
  install.packages("shinyWidgets")
}
if (!require(base64enc)) {
  install.packages("base64enc")
}
if (!require(httr)) {
  install.packages("httr")
}
if (!require(jsonlite)) {
  install.packages("jsonlite")
}
if (!require(rsconnect)) {
  install.packages("rsconnect")
}

#chargement des library
library(shiny)  # Package principal pour créer des applications web interactives
library(shinythemes)  # Fournit des thèmes pré-définis pour personnaliser l'apparence de l'application
library(ggplot2)  # Pour créer des graphiques
library(DT)  # Pour afficher des tables interactives
library(dplyr)  # Pour manipuler et transformer des dataframes
library(leaflet)  # Pour créer des cartes interactives
library(shinyWidgets)  # Fournit des widgets supplémentaires pour l'interface utilisateur
library(base64enc)  # Pour encoder et décoder des données en base64
library(httr)  # Pour faire des requêtes HTTP
library(jsonlite)  # Pour travailler avec des données JSON
library(rsconnect) # Pour déployer l'appli

#lien pour trouver la bdd du 55 sur mon Git
url_github = "https://raw.githubusercontent.com/MathiasJnn/iut_sd2_rshiny_enedis/refs/heads/main/adresses-55.csv"
Df_code_postal = read.csv(url(url_github), sep = ";",dec = ".")  # ou utilise le bon séparateur selon ton fichier
code_postaux="55*"

# Fonction pour charger les données (nouvelle fonction)
load_data <- function() {
  existants_55 <- data.frame()
  neufs_55 <- data.frame()
  
  Date_existants <- 2020
  Date_neufs <- 2020
  
  base_url_existants = "https://data.ademe.fr/data-fair/api/v1/datasets/dpe-v2-logements-existants/lines"
  base_url_neufs = "https://data.ademe.fr/data-fair/api/v1/datasets/dpe-v2-logements-neufs/lines"
  
  repeat {
    params = list(
      page = 1,
      size = 10000,  
      select = "N°DPE,Identifiant__BAN,Code_postal_(BAN),Etiquette_DPE,Date_réception_DPE,Coordonnée_cartographique_Y_(BAN),Coordonnée_cartographique_X_(BAN)",
      q = code_postaux,
      q_fields = "Code_postal_(BAN)",
      qs = paste0("Date_réception_DPE:[", Date_existants, "-01-01 TO ", Date_existants, "-12-31]")
    )
    
    url_encoded = modify_url(base_url_existants, query = params)
    response = GET(url_encoded)
    if (status_code(response) != 200) {
      stop("Erreur")
    }
    content = fromJSON(rawToChar(response$content), flatten = FALSE)
    df = content$result
    existants_55 = rbind(existants_55, df)
    Date_existants = Date_existants + 1
    if (Date_existants == 2050) break
    if (Date_existants %% 600 == 0) Sys.sleep(60)
  }
  
  repeat {    
    params = list(
      page = 1,
      size = 10000,  
      select = "N°DPE,Identifiant__BAN,Code_postal_(BAN),Etiquette_DPE,Date_réception_DPE,Coordonnée_cartographique_Y_(BAN),Coordonnée_cartographique_X_(BAN)",
      q = code_postaux,
      q_fields = "Code_postal_(BAN)",
      qs = paste0("Date_réception_DPE:[", Date_neufs, "-01-01 TO ", Date_neufs, "-12-31]")
    ) 
    
    url_encoded = modify_url(base_url_neufs, query = params)
    response = GET(url_encoded)
    if (status_code(response) != 200) {
      stop("Erreur")
    }
    content = fromJSON(rawToChar(response$content), flatten = FALSE)
    df = content$result
    neufs_55 = rbind(neufs_55, df)  
    Date_neufs = Date_neufs + 1
    if (Date_neufs == 2050) break
  }  
  
  existants_55$Type_de_logement = "ancien"
  neufs_55$Type_de_logement = "neuf"
  df_logement = rbind(existants_55, neufs_55)
  df_final = merge(df_logement, Df_code_postal, by.x = "Identifiant__BAN", by.y = "id")
  
  return(df_final)
}

df_final <- load_data()

# Fonction pour encoder une image en base64
encode_image <- function(image_path) {
  base64enc::dataURI(file = image_path, mime = "image/png")
}

# Stocker les informations d'authentification de base (vous pouvez changer ces valeurs)
valid_users <- data.frame(
  username = c("asardell"),
  password = c("le_meilleur")
)

# Interface utilisateur (UI)
ui <- tagList(
  tags$head(
    tags$style(HTML("
      body.dark-mode { background-color: #2E2E2E; color: #FFFFFF; }
      .navbar.dark-mode { background-color: #2E2E2E; }
      .well.dark-mode { background-color: #3E3E3E; }
    ")),
    tags$script(HTML("
      $(document).on('shiny:inputchanged', function(event) {
        if (event.name === 'mode' && event.value === true) {
          $('body').addClass('dark-mode');
        } else {
          $('body').removeClass('dark-mode');
        }
      });
    "))
  ),
  
  navbarPage(
    theme = shinytheme("flatly"),
    title = "DPE Logements dans la Meuse",
    
    tabPanel("Accueil",
             fluidPage(
               fluidRow(
                 column(10, titlePanel("La Meuse, ses logements et leurs Diagnostic de performance énergétique")),
                 column(2, switchInput(inputId = "mode", label = "Mode Nuit", value = FALSE))
               ),
               h3("Introduction à la Meuse"),
               p("Bienvenue dans le département de la Meuse. Cette application répertorie les informations concernant les différents logements de la région.
Le département de la Meuse (55), situé dans la région Grand Est, est un territoire essentiellement rural, marqué par son histoire et ses paysages naturels. Avec une densité de population relativement faible et un parc immobilier ancien, il se prête particulièrement à des analyses intéressantes en matière de performance énergétique des bâtiments (DPE).

Dans le cadre de la transition énergétique et de la réduction des consommations d’énergie, l’évaluation de la performance énergétique des logements est un enjeu crucial. Cette étude a pour but d'analyser les Diagnostics de Performance Énergétique (DPE) des logements du département de la Meuse (55).  
              Si vous souhaitez en savoir plus sur ce magnifique département qu'est la Meuse, cliquez sur ce lien : ",
                 a("Meuse - Wikipédia", href = "https://fr.wikipedia.org/wiki/Meuse_(d%C3%A9partement)", target = "_blank")),
               br(),
               fluidRow(
                 column(3, img(src = "https://upload.wikimedia.org/wikipedia/commons/thumb/2/27/Drapeau_fr_d%C3%A9partement_Meuse.svg/1200px-Drapeau_fr_d%C3%A9partement_Meuse.svg.png", height = "200px", width = "100%", alt = "Image drapeau non trouvée")),
                 column(3, img(src = "https://upload.wikimedia.org/wikipedia/commons/3/32/Meuse_Montherme.jpg", height = "200px", width = "100%", alt = "Image beau non trouvée")),
                 column(3, img(src = "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/Meuse-Position.svg/langfr-800px-Meuse-Position.svg.png", height = "200px", width = "100%", alt = "Image carte non trouvée"))
               )
             )
    ),
    
    tabPanel("Graphiques",
             fluidPage(
               actionButton("refresh_graph", "Rafraîchir les données"), 
               h3("Indicateurs Visuels (KPI)"),
               fluidRow(
                 column(6, div(class = "card", style = "border: 1px solid black; padding: 20px; text-align: center;",
                               h2(textOutput("total_logements_kpi")),
                               h4("Total de logements"))),
                 column(6, div(class = "card", style = "border: 1px solid black; padding: 20px; text-align: center;",
                               h2(textOutput("total_communes_kpi")),
                               h4("Total de communes")))
               ),
               
               h3("Filtrer par Classe DPE (pour Répartition des Types de Logements)"),
               selectInput("dpe_filter_types", "Sélectionner les Classes DPE:", 
                           choices = unique(df_final$Etiquette_DPE), 
                           selected = unique(df_final$Etiquette_DPE), 
                           multiple = TRUE),
               plotOutput("plot_type_logement_pie"),
               downloadButton("download_pie", "Télécharger le graphique en PNG"),
               
               h3("Filtrer par Classe DPE (pour Répartition des Classes DPE)"),
               selectInput("dpe_filter_dpe", "Sélectionner les Classes DPE:", 
                           choices = unique(df_final$Etiquette_DPE), 
                           selected = unique(df_final$Etiquette_DPE), 
                           multiple = TRUE),
               plotOutput("plot_dpe"),
               downloadButton("download_dpe", "Télécharger le graphique en PNG"),
               
               h3("Filtrer par Classe DPE (pour Top 3 des Communes avec le Plus de Logements)"),
               selectInput("dpe_filter_communes", "Sélectionner les Classes DPE:", 
                           choices = unique(df_final$Etiquette_DPE), 
                           selected = unique(df_final$Etiquette_DPE), 
                           multiple = TRUE),
               plotOutput("plot_communes"),
               downloadButton("download_communes", "Télécharger le graphique en PNG"),
               
               h3("Distribution des classes DPE par type de logement (Barres empilées)"),
               plotOutput("plot_boxplot_type_dpe"),  # Ce graphique a été remplacé par le graphique de barres empilées
               downloadButton("download_boxplot_type", "Télécharger le graphique en PNG"),
               
               h3("Nuage de points avec régression linéaire"),
               selectInput("x_var", "Sélectionner la variable X:", choices = colnames(df_final)),
               selectInput("y_var", "Sélectionner la variable Y:", choices = colnames(df_final)),
               plotOutput("scatter_plot"),
               textOutput("corr_value"),
               downloadButton("download_scatter", "Télécharger le graphique en PNG")
             )
    ),
    
    tabPanel("Carte",
             fluidPage(
               actionButton("refresh_map", "Rafraîchir les données"), 
               h3("Carte des logements dans la Meuse"),
               # Ajout d'un filtre pour les notes DPE sur la carte
               selectInput("dpe_filter_map", "Filtrer par Classe DPE:", 
                           choices = unique(df_final$Etiquette_DPE), 
                           selected = unique(df_final$Etiquette_DPE), 
                           multiple = TRUE),
               leafletOutput("map", height = "600px"),
               br(),
               div(id = "legend", style = "font-size: 16px; font-weight: bold;"),
               p("Légende : Les couleurs représentent les différentes classes DPE.")
             )
    ),
    
    tabPanel("Contexte",
             fluidPage(
               actionButton("refresh_context", "Rafraîchir les données"),
               h3("Filtres pour les données du tableau"),
               selectInput("select_dpe_context", "Sélectionner une classe DPE :", 
                           choices = unique(df_final$Etiquette_DPE), 
                           selected = unique(df_final$Etiquette_DPE), 
                           multiple = TRUE),
               checkboxInput("show_old_logements_context", 
                             label = "Afficher uniquement les logements anciens", 
                             value = FALSE),
               sliderInput("year_range_context", 
                           label = "Sélectionner la plage des années de réception DPE :", 
                           min = 2020, 
                           max = 2050, 
                           value = c(2020, 2030)),
               radioButtons("logement_type_context", 
                            label = "Type de logement :", 
                            choices = c("Tous" = "all", "Ancien" = "ancien", "Neuf" = "neuf"), 
                            selected = "all"),
               h3("Contexte et Données Complètes"),
               dataTableOutput("full_dataframe"),
               downloadButton("download_data", "Télécharger les données sélectionnées en CSV")
             )
    )
  )
)

# Fonction pour vérifier l'authentification
check_credentials <- function(username, password) {
  if (username %in% valid_users$username) {
    stored_password <- valid_users$password[valid_users$username == username]
    if (stored_password == password) {
      return(TRUE)
    }
  }
  return(FALSE)
}

# Logique serveur (Server)
server <- function(input, output, session) {
  
  # Création d'une variable réactive pour gérer l'authentification
  user_authenticated <- reactiveVal(FALSE)
  
  # Fenêtre modale pour l'authentification
  showModal(modalDialog(
    title = "Authentification",
    textInput("username", "Nom d'utilisateur"),
    passwordInput("password", "Mot de passe"),
    footer = tagList(
      modalButton("Annuler"),
      actionButton("login", "Se connecter")
    ),
    easyClose = FALSE,
    fade = TRUE
  ))
  
  # Observer l'événement de connexion
  observeEvent(input$login, {
    username <- input$username
    password <- input$password
    
    # Vérifier les informations de connexion
    if (check_credentials(username, password)) {
      user_authenticated(TRUE)  # Authentification réussie
      removeModal()  # Retirer la fenêtre modale
    } else {
      showNotification("Nom d'utilisateur ou mot de passe incorrect", type = "error")
    }
  })
  
  # Observer la variable user_authenticated pour afficher ou cacher l'interface
  observe({
    if (!user_authenticated()) {
      hideTab(inputId = "navbar", target = "Graphiques")
    } else {
      showTab(inputId = "navbar", target = "Graphiques")
    }
  })
  
  output$total_logements_kpi <- renderText({
    nrow(df_final)
  })
  
  output$total_communes_kpi <- renderText({
    length(unique(df_final$nom_commune))
  })
  
  observeEvent(input$refresh_graph, {
    df_final <<- load_data()
    showNotification("Données actualisées", type = "message")  # Notification de succès
  })
  
  observeEvent(input$refresh_map, {
    df_final <<- load_data()
    showNotification("Carte actualisée", type = "message")  # Notification de succès
  })
  
  observeEvent(input$refresh_context, {
    df_final <<- load_data()
    showNotification("Données du contexte actualisées", type = "message")  # Notification de succès
  })
  
  output$plot_type_logement_pie <- renderPlot({
    df_pie <- df_final %>%
      filter(Etiquette_DPE %in% input$dpe_filter_types) %>%
      group_by(Type_de_logement) %>%
      summarise(Nombre = n()) %>%
      mutate(Prop=Nombre/sum(Nombre)) #calcul des proportions en %
    
    ggplot(df_pie, aes(x = "", y = Prop, fill = Type_de_logement)) +
      geom_bar(stat = "identity", width = 1) +
      coord_polar("y", start = 0) +
      theme_void() + 
      geom_text(aes(label = scales::percent(Prop,accuracy = 0.1)), position = position_stack(vjust = 0.5)) +
      labs(title = "Répartition des Types de Logements")
  })
  
  output$download_pie <- downloadHandler(
    filename = function() { paste("repartition_types_logement", Sys.Date(), ".png", sep = "") },
    content = function(file) {
      df_pie <- df_final %>%
        filter(Etiquette_DPE %in% input$dpe_filter_types) %>%
        group_by(Type_de_logement) %>%
        summarise(Nombre = n())
      
      plot <- ggplot(df_pie, aes(x = "", y = Nombre, fill = Type_de_logement)) +
        geom_bar(stat = "identity", width = 1) +
        coord_polar("y", start = 0) +
        theme_void() + 
        geom_text(aes(label = Nombre), position = position_stack(vjust = 0.5)) +
        labs(title = "Répartition des Types de Logements")
      
      ggsave(file, plot = plot, device = "png")
    }
  )
  
  output$plot_dpe <- renderPlot({
    df_filtered <- df_final %>%
      filter(Etiquette_DPE %in% input$dpe_filter_dpe)
    
    ggplot(df_filtered, aes(x = Etiquette_DPE, fill = Etiquette_DPE)) +
      geom_bar() +
      geom_text(stat = "count", aes(label = ..count..), vjust = -0.5) +  
      labs(title = "Répartition des Classes DPE", x = "Classe DPE", y = "Nombre de Logements") +
      theme_minimal()
  })
  
  output$download_dpe <- downloadHandler(
    filename = function() { paste("repartition_classes_DPE", Sys.Date(), ".png", sep = "") },
    content = function(file) {
      df_filtered <- df_final %>%
        filter(Etiquette_DPE %in% input$dpe_filter_dpe)
      
      plot <- ggplot(df_filtered, aes(x = Etiquette_DPE, fill = Etiquette_DPE)) +
        geom_bar() +
        geom_text(stat = "count", aes(label = ..count..), vjust = -0.5) +  
        labs(title = "Répartition des Classes DPE", x = "Classe DPE", y = "Nombre de Logements") +
        theme_minimal()
      
      ggsave(file, plot = plot, device = "png")
    }
  )
  
  output$plot_communes <- renderPlot({
    df_filtered <- df_final %>%
      filter(Etiquette_DPE %in% input$dpe_filter_communes) %>%
      group_by(nom_commune) %>%
      summarise(Nombre_de_logements = n()) %>%
      top_n(3, Nombre_de_logements) %>%
      arrange(desc(Nombre_de_logements))
    
    ggplot(df_filtered, aes(x = reorder(nom_commune, -Nombre_de_logements), y = Nombre_de_logements, fill = nom_commune)) +
      geom_bar(stat = "identity") +
      geom_text(aes(label = Nombre_de_logements), vjust = -0.5) +  
      labs(title = "Top 3 des Communes avec le Plus de Logements", x = "Commune", y = "Nombre de Logements") +
      theme_minimal()
  })
  
  output$download_communes <- downloadHandler(
    filename = function() { paste("top3_communes", Sys.Date(), ".png", sep = "") },
    content = function(file) {
      df_filtered <- df_final %>%
        filter(Etiquette_DPE %in% input$dpe_filter_communes) %>%
        group_by(nom_commune) %>%
        summarise(Nombre_de_logements = n()) %>%
        top_n(3, Nombre_de_logements) %>%
        arrange(desc(Nombre_de_logements))
      
      plot <- ggplot(df_filtered, aes(x = reorder(nom_commune, -Nombre_de_logements), y = Nombre_de_logements, fill = nom_commune)) +
        geom_bar(stat = "identity") +
        geom_text(aes(label = Nombre_de_logements), vjust = -0.5) +  
        labs(title = "Top 3 des Communes avec le Plus de Logements", x = "Commune", y = "Nombre de Logements") +
        theme_minimal()
      
      ggsave(file, plot = plot, device = "png")
    }
  )
  
  output$scatter_plot <- renderPlot({
    req(input$x_var, input$y_var)
    ggplot(df_final, aes_string(x = input$x_var, y = input$y_var)) +
      geom_point() +
      geom_smooth(method = "lm", se = FALSE, col = "blue") +
      labs(title = paste("Nuage de points avec régression linéaire:", input$x_var, "vs", input$y_var)) +
      theme_minimal()
  })
  
  output$corr_value <- renderText({
    req(input$x_var, input$y_var)
    corr <- cor(df_final[[input$x_var]], df_final[[input$y_var]], use = "complete.obs")
    paste("Coefficient de corrélation entre", input$x_var, "et", input$y_var, ":", round(corr, 2))
  })
  
  output$download_scatter <- downloadHandler(
    filename = function() { paste("scatter_plot", Sys.Date(), ".png", sep = "") },
    content = function(file) {
      req(input$x_var, input$y_var)
      plot <- ggplot(df_final, aes_string(x = input$x_var, y = input$y_var)) +
        geom_point() +
        geom_smooth(method = "lm", se = FALSE, col = "blue") +
        labs(title = paste("Nuage de points avec régression linéaire:", input$x_var, "vs", input$y_var)) +
        theme_minimal()
      
      ggsave(file, plot = plot, device = "png")
    }
  )
  
  # Remplacement du graphique en boîte à moustache par le graphique de barres empilées
  output$plot_boxplot_type_dpe <- renderPlot({
    df_final <- df_final %>%
      mutate(DPE_Categorie = ifelse(Etiquette_DPE %in% c("A", "B", "C"), "Bon DPE", "Mauvais DPE"))
    
    df_bon_mauvais <- df_final %>%
      group_by(Type_de_logement, DPE_Categorie) %>%
      summarise(n = n(), .groups = "drop") %>%
      group_by(Type_de_logement) %>%
      mutate(prop = n / sum(n))
    
    ggplot(df_bon_mauvais, aes(x = Type_de_logement, y = prop, fill = DPE_Categorie)) +
      geom_bar(stat = "identity") +
      geom_text(aes(label = scales::percent(prop, accuracy = 0.1)), 
                position = position_stack(vjust = 0.5), size = 4, color = "black") +
      scale_y_continuous(labels = scales::percent) +
      scale_fill_manual(values = c("Bon DPE" = "#B5EAD7", "Mauvais DPE" = "#FFB7B2")) +
      labs(x = "Type de logement", y = "Proportion de logements", fill = "Catégorie de DPE") +
      theme_minimal()
  })
  
  output$download_boxplot_type <- downloadHandler(
    filename = function() { paste("proportion_bon_mauvais_dpe", Sys.Date(), ".png", sep = "") },
    content = function(file) {
      df_final <- df_final %>%
        mutate(DPE_Categorie = ifelse(Etiquette_DPE %in% c("A", "B", "C"), "Bon DPE", "Mauvais DPE"))
      
      df_bon_mauvais <- df_final %>%
        group_by(Type_de_logement, DPE_Categorie) %>%
        summarise(n = n(), .groups = "drop") %>%
        group_by(Type_de_logement) %>%
        mutate(prop = n / sum(n))
      
      plot <- ggplot(df_bon_mauvais, aes(x = Type_de_logement, y = prop, fill = DPE_Categorie)) +
        geom_bar(stat = "identity") +
        geom_text(aes(label = scales::percent(prop, accuracy = 0.1)), 
                  position = position_stack(vjust = 0.5), size = 4, color = "black") +
        scale_y_continuous(labels = scales::percent) +
        scale_fill_manual(values = c("Bon DPE" = "#B5EAD7", "Mauvais DPE" = "#FFB7B2")) +
        labs(x = "Type de logement", y = "Proportion de logements", fill = "Catégorie de DPE") +
        theme_minimal()
      
      ggsave(file, plot = plot, device = "png")
    }
  )
  
  # Filtrer le tableau en fonction des widgets dans l'onglet "Contexte"
  output$full_dataframe <- renderDataTable({
    df_filtered <- df_final %>%
      filter(Etiquette_DPE %in% input$select_dpe_context) %>%
      filter(if (input$show_old_logements_context) Type_de_logement == "ancien" else TRUE) %>%
      filter(Date_réception_DPE >= input$year_range_context[1] & Date_réception_DPE <= input$year_range_context[2]) %>%
      filter(if (input$logement_type_context != "all") Type_de_logement == input$logement_type_context else TRUE)
    
    datatable(df_filtered, options = list(pageLength = 10, scrollX = TRUE))
  })
  
  output$download_data <- downloadHandler(
    filename = function() { paste("data_selectionnee", Sys.Date(), ".csv", sep = "") },
    content = function(file) {
      # Récupérer les données filtrées en fonction des sélections de l'utilisateur
      df_filtered <- df_final %>%
        filter(Etiquette_DPE %in% input$select_dpe_context) %>%
        filter(if (input$show_old_logements_context) Type_de_logement == "ancien" else TRUE) %>%
        filter(Date_réception_DPE >= input$year_range_context[1] & Date_réception_DPE <= input$year_range_context[2]) %>%
        filter(if (input$logement_type_context != "all") Type_de_logement == input$logement_type_context else TRUE)
      
      # Utilisation de write.csv pour s'assurer que le fichier est bien un CSV
      write.csv(df_filtered, file, row.names = FALSE)
    }
  )
  
  dpe_colors <- colorFactor(palette = "Set1", domain = df_final$Etiquette_DPE)
  
  # Ajout du filtre de classes DPE sur la carte
  output$map <- renderLeaflet({
    df_filtered_map <- df_final %>%
      filter(Etiquette_DPE %in% input$dpe_filter_map)
    
    leaflet(df_filtered_map) %>%
      addTiles() %>%
      addCircleMarkers(lng = ~lon, lat = ~lat,
                       color = ~dpe_colors(Etiquette_DPE),
                       popup = ~paste("<strong>Logement:</strong>", Identifiant__BAN, "<br>",
                                      "<strong>Classe DPE:</strong>", Etiquette_DPE, "<br>",
                                      "<strong>Commune:</strong>", nom_commune, "<br>",
                                      "<strong>Date DPE:</strong>", Date_réception_DPE),
                       radius = 5, stroke = FALSE, fillOpacity = 0.8) %>%
      addLegend("bottomright", pal = dpe_colors, values = df_filtered_map$Etiquette_DPE,
                title = "Classes DPE", opacity = 1)
  })
}

# Lancer l'application
shinyApp(ui = ui, server = server)
