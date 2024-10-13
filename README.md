# Projet R - Département de la Meuse (55)
## Auteurs : Mathias Janin & Azad Lucas

Ce README est composé de:
1. Rappel du projet
2. Structure des fichiers du repository


## Rappel du projet
Dans le cadre du projet R réalisé à l'IUT par les SD2 (années 2024-25), nous avons choisi de travailler sur le département de la Meuse (55). Pour rappel, le projet consiste à développer une application RShiny permettant de visualiser des données énergétiques (logements neufs et anciens) pour un département donné.  L'objectif est d'offrir à l'utilisateur des outils pour explorer les données via des graphiques, tableaux et cartographies interactives. En complément de cette application, un rapport RMarkdown a été produit pour détailler les analyses statistiques réalisées sur ces données. Ce projet s'inscrit dans le cadre d'une étude visant à explorer l'impact du Diagnostic de Performance Energétique (DPE) sur les consommations énergétiques des logements grâce à des données provenant de plusieurs sources, notamment la [Base Adresse Nationale](https://adresse.data.gouv.fr/data/ban/adresses/latest/csv) (BAN) et deux API fournies par l'[ADEME](https://data.ademe.fr/datasets?topics=BR8GjsXga) (logements neufs et existants).
<br>
</br>

## Structure des fichiers du repository
Voici la liste des fichiers disponibles dans ce repository et leur utilité dans le projet :
<br>
</br>
### **`Application_Meuse.R`**: 
Ce fichier est le script R qui permet d'éxécuter l'application RShiny. Ayant eu des soucis quant au déploiement de l'application, il faut copier le code afin de l'éxécuter sur R.
<br>
</br>
### **`adresses-55.csv`**: 
Ce fichier contient les données issues de la Base Adresse Nationale (BAN) pour le département de la Meuse (55). Il nous a permis d'importer les informations géographiques des logements dans notre base de données. Il sert également de lien pour éxécuter le code sans avoir à importer localement les données sur le poste de l'utilisateur.
<br>
</br>
### **`Base_de_données.R`** : 
Script R permettant de générer la base de données finale. Cette base regroupe les données de la BAN ainsi que celles des API "logements neufs" et "logements existants" de l'ADEME. Des commentaires explicatifs du code y sont associé.
<br>
</br>
### **`Documentation.pdf`** : 
Documentation est le fichier regroupant la doc technique et fonctionnelle pour l'application Shiny. La première est orientée développeur et la seconde orientée utilisateur. Vous y retrouverez tout ce qui est important pour la bonne utilisation de l'appli.
<br>
</br>
### **`Rapport_final_Script.Rmd`** : 
Ce fichier est un document RMarkdown qui contient le code source permettant de générer le rapport final en format HTML. Il regroupe les analyses et visualisations réalisées à partir des données collectées ainsi que des commentaires du code (commentaires qui ne sont pas forcément répétés dans le shiny).
<br>
</br>
### **`Rapport_final_HTML.html`** : 
Rapport final généré en format HTML. Il présente les analyses statistiques et graphiques réalisées à partir des données collectées. C'est un fichier html récupéré pour un exemple visuel du 13/10/2024.
<br>
</br>
### **`README.md`** : 
Ce fichier que vous lisez actuellement. Il présente une vue d'ensemble du projet, sa structure, ainsi que les fichiers présents dans le repository.
