
# Installation des packages
if (!require(httr)) {
  install.packages("httr")
}

if (!require(jsonlite)) {
  install.packages("jsonlite")
}

library(httr)
library(jsonlite)

# Lecture du fichier et préparation des codes postaux
# Choix du département de la Meuse (55)

url_github <- "https://raw.githubusercontent.com/MathiasJnn/iut_sd2_rshiny_enedis/refs/heads/main/adresses-55.csv"
Df_code_postal <- read.csv(url(url_github), sep = ";",dec = ".")  # ou utilise le bon séparateur selon ton fichier
code_postaux="55*"


# Initialisation des dataframes vides pour stocker les résultats
existants_55=data.frame()
neufs_55=data.frame()

#initialisation des dates avant boucles
#choix des dates à partir de 2020 car il n'y a pas de données dans l'API avant 2021
Date_existants=2020
Date_neufs=2020

# Base URL de l'API existants
base_url_existants = "https://data.ademe.fr/data-fair/api/v1/datasets/dpe-v2-logements-existants/lines"

# Base URL de l'API neufs
base_url_neufs= "https://data.ademe.fr/data-fair/api/v1/datasets/dpe-v2-logements-neufs/lines"  


#boucles
repeat{
  
  # Paramètres de la requête
  params = list(
    page = 1,
    size = 10000,  # taille max possible en 1 fois
    select = "N°DPE,Identifiant__BAN,Code_postal_(BAN),Etiquette_DPE,Date_réception_DPE,Coordonnée_cartographique_Y_(BAN),Coordonnée_cartographique_X_(BAN)",
    q = code_postaux,
    q_fields = "Code_postal_(BAN)",
    qs = paste0("Date_réception_DPE:[",Date_existants,"-01-01 TO ",Date_existants,"-12-31]")
  ) 
 #
  # Encodage des paramètres dans l'URL
  url_encoded = modify_url(base_url_existants, query = params)
  
  # Effectuer la requête
  response = GET(url_encoded)
  
  # Vérification du statut de la réponse
  if (status_code(response) != 200) {
    stop("Erreur")
  }
      # Convertir la réponse en JSON et extraire les données
    content = fromJSON(rawToChar(response$content), flatten = FALSE)
    
    # Extraire les données sous forme de dataframe
    df = content$result
    
    # Si des données sont présentes, les ajouter au dataframe final
    existants_55 = rbind(existants_55, df)
    
    #incrémentation de la date
    Date_existants=Date_existants+1
    
    #stop si 2050 trouvé
    if (Date_existants ==2050){
      break
    }
    if (Date_existants %%600 ==0){
      Sys.sleep(60)
    }
}  

 #idem pour les logements neufs   

#boucles    
repeat{    
    
  # Paramètres de la requête
  params = list(
    page = 1,
    size = 10000,  # Vous pouvez ajuster cette taille selon vos besoins
    select = "N°DPE,Identifiant__BAN,Code_postal_(BAN),Etiquette_DPE,Date_réception_DPE,Coordonnée_cartographique_Y_(BAN),Coordonnée_cartographique_X_(BAN)",
    q = code_postaux,
    q_fields = "Code_postal_(BAN)",
    qs = paste0("Date_réception_DPE:[",Date_neufs,"-01-01 TO ",Date_neufs,"-12-31]")
  ) 
  
  # Encodage des paramètres dans l'URL
  url_encoded = modify_url(base_url_neufs, query = params)
  
  # Effectuer la requête
  response = GET(url_encoded)
  
  # Vérification du statut de la réponse
  if (status_code(response) != 200) {
    stop("Erreur")
  }
  # Convertir la réponse en JSON et extraire les données
  content = fromJSON(rawToChar(response$content), flatten = FALSE)
  
  # Extraire les données sous forme de dataframe
  df = content$result
  
  # Si des données sont présentes, les ajouter au dataframe final
  neufs_55 = rbind(neufs_55, df)  
    
#incrémentation de la date
  Date_neufs=Date_neufs+1
  
  #stop si 2050 trouvé
  if (Date_neufs ==2050){
    break
  }
}  
#----------------------------fin de l'importation des données-----------------------------------------

#ajout de la colonne "Type_de_logement" dans les deux df
existants_55$Type_de_logement="ancien"
neufs_55$Type_de_logement="neuf"

#créer un df unique avec les existants et les neufs
df_logement=rbind(existants_55,neufs_55)

#création du df unique avec les deux existants (Df_code_postal & df_logement)
#On ne gardera que les logements ou les deux sont renseignés et joignable avec la jointure 
# sur ID (Df_code_postal) et identifiant_BAN sur (df_logement) car certains ne peuvent pas être liés

#vérif si les 2 ont le même type
class(df_logement$Identifiant__BAN)
class(Df_code_postal$id)

#liaison des deux df
df_final = merge(df_logement, Df_code_postal, 
                   by.x = "Identifiant__BAN", 
                   by.y = "id")

# Affiche le début du dataframe fusionné voir si c'est OK
head(df_final)

#Exporter df_final en CSV dans le répertoire de travail actuel
write.csv(df_final, "df_final.csv", row.names = FALSE)

