# Projet R - Département de la Meuse (55)
## Auteurs : Mathias Janin & Azad Lucas

### Introduction
Dans le cadre du projet R réalisé à l'IUT par les SD2 (années 2024-25), nous avons choisi de travailler sur le département de la Meuse (55). Pour rappel, le projet consiste à développer une application RShiny permettant de visualiser des données énergétiques (logements neufs et anciens) pour un département donné.  L'objectif est d'offrir à l'utilisateur des outils pour explorer les données via des graphiques, tableaux et cartographies interactives. En complément de cette application, un rapport RMarkdown a été produit pour détailler les analyses statistiques réalisées sur ces données. Ce projet s'inscrit dans le cadre d'une étude visant à explorer l'impact du Diagnostic de Performance Energétique (DPE) sur les consommations énergétiques des logements grâce à des données provenant de plusieurs sources, notamment la Base Adresse Nationale (BAN) et deux API fournies par l'ADEME (logements neufs et existants).

### Structure des fichiers du repository
Voici la liste des fichiers disponibles dans ce repository et leur utilité dans le projet :
<br>
</br>
#### **adresses-55.csv**: 
Ce fichier contient les données issues de la Base Adresse Nationale (BAN) pour le département de la Meuse (55). Il nous a permis d'importer les informations géographiques des logements dans notre base de données.
<br>
</br>
#### **Base_de_données.R** : 
Script R permettant de générer la base de données finale. Cette base regroupe les données de la BAN ainsi que celles des API "logements neufs" et "logements existants" de l'ADEME.
<br>
</br>
#### **Rapport_final_Script.Rmd** : 
Ce fichier est un document RMarkdown qui contient le code source permettant de générer le rapport final en format HTML. Il regroupe les analyses et visualisations réalisées à partir des données collectées.
<br>
</br>
#### **Rapport_final_HTML.html** : 
Rapport final généré en format HTML. Il présente les analyses statistiques et graphiques réalisées à partir des données collectées.
<br>
</br>
#### **README.md** : 
Ce fichier que vous lisez actuellement. Il présente une vue d'ensemble du projet, sa structure, ainsi que les fichiers présents dans le repository.


il faut mettre en tout: le rshiny
                        les deux docus
