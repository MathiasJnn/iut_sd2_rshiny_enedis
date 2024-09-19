## EXERCICE 1

# exo 1 à 6
iris
class(iris)
View(iris)
nrow(iris)
ncol(iris)
colnames(iris)
summary(iris)

# exo 7
iris[,c("Sepal.Length","Species")] # mettre une virgule avant car on veut que les colonnes
# exo 9
iris[c(100,103,105),] #virgule après car on veut les lignes 100,103,105
#exo 10
iris[seq(from=50,to=100,by=1),] 
#OU
iris[50:100 ,]
#exo 11
mean(iris$Sepal.Length)
#exo 12
median(iris$Sepal.Width)
#exo 13
sd(iris$Petal.Length)
#exo 14
quantile(iris$Petal.Width,seq(from=0, to=1, by=0.1))

## EXERCICE 2
#exo 1
dfManga=read.csv(file= "L:/BUT/SD/Promo 2023/mjanin/R/manga.csv") #copier le dossier avec "copier le chemin d'accès"
dfAnime=read.csv(file= "L:/BUT/SD/Promo 2023/mjanin/R/anime.csv") # et inverser les \ en /
#ou ci dessous pour connaitre les séparateurs, ...
dfManga <- read.csv(file="L:\BUT\SD\Promo 2023\mjanin\R\manga.csv", header = TRUE, sep = ",", dec = ".")
dfAnime <- read.csv(file="L:\BUT\SD\Promo 2023\mjanin\R\anime.csv", header = TRUE, sep = ",", dec = ".")
class(dfManga)
class(dfAnime)

#exo 2
View(dfManga)
View(dfAnime)

#exo 3
dim(dfManga)
dim(dfAnime)

#exo 4
mean(dfManga$Score)
mean(dfAnime$Score)
max(mean(dfManga$Score),mean(dfAnime$Score))

#exo 5
sum(dfManga$Vote)
sum(dfAnime$Vote)
max(sum(dfManga$Vote),sum(dfAnime$Vote))

#exo 6
sd(dfManga$Score)
sd(dfAnime$Score)
# le sd le plus faible est dans le dataframe manga

#exo 7
quantile(dfManga$Score, seq(from=0,to=1,by=0.1))
quantile(dfAnime$Score, seq(from=0,to=1,by=0.1))
#le plus petit décile 1 est  dans le df Anime


##fonctions subset(),table(),prop.table()



