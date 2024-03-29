#######
#######
### SQL SAT Madrid
### Some goofying around with the data
### 28.September 209
#######
#######

setwd("C:/DataTK")


Matija_Lah     <- c(1,1,2,5,7,8,9,7)
Tomaz_Kastrun  <- c(5,9,4,1,1,7,5,9)
Dejan_Sarka    <- c(1,4,2,5,8,6,2,8)
Mladen_Prajdic <- c(2,6,7,2,6,1,8,9)
Sasa_Masic     <- c(1,3,2,4,8,9,7,7)


restaurantRatings <- rbind(Matija_Lah, Tomaz_Kastrun, Dejan_Sarka, Mladen_Prajdic, Sasa_Masic) 

colnames(restaurantRatings) <- c("Foculus", "Pr' Matiji doma", "Sir William's Pub", "Eksperiment", "Pivnica Union", "Pikniki pr Dejanu", "Manna", "Compa")

restaurantRatings


dist(restaurantRatings, method = 'euclidean')


dist(t(restaurantRatings), method = 'euclidean')




# install.packages("proxy")
library(proxy)

dist(restaurantRatings, method = 'cosine')

binaryRatingMatrix <- restaurantRatings > 5

dist(binaryRatingMatrix, method = 'jaccard')

# Note the z-score!
# rm_cen <- t(apply(restaurantRatings, 1, function(x) x - mean(x)/sd(x)))
rm_cen <- 
  t(apply(restaurantRatings, 1, function(x) x - mean(x)))

rm_cen


library(ggplot2)

RR <- data.frame(restaurantRatings)


RRCluster <- kmeans(RR, 2, nstart = 20)
RRCluster

RRCluster <- kmeans(RR, 3, nstart = 20)
RRCluster

#already absurd, because 5 people and 4 clusters is "overfitting"
RRCluster <- kmeans(RR, 4, nstart = 20)
RRCluster

#so we stick with 3 clusters solution
RRCluster <- kmeans(RR, 3, nstart = 20)


RRCluster$cluster <- as.factor(RRCluster$cluster)

#transpose dataset 
tRR <- data.frame(t(RR))

#clusters for the restaurants
tRRCluster <- kmeans(tRR, 3, nstart = 20)

# cluster 4 has loading = 0
tRRCluster <- kmeans(tRR, 4, nstart = 20)

# no way
tRRCluster <- kmeans(tRR, 5, nstart = 20)

#so we stick to 3 clusters
tRRCluster <- kmeans(tRR, 3, nstart = 20)
tRRCluster

#based on three clusters of restaurants, I want to plot the differences from euclidian difference between friends

# Tomaz_Kastrun, Mladen_Prajdic -> should be far apart
# Matija_Lah, Sasa_Masic -> should be very close

ggplot(tRR, aes(Tomaz_Kastrun, Mladen_Prajdic, color = tRRCluster$cluster)) + geom_point()


# you can almost see a regression line :-) with minimal SSE (sum of squared errors)
ggplot(tRR, aes(Matija_Lah, Sasa_Masic, color = tRRCluster$cluster)) + geom_point() 


# draw that regression line
ggplot(tRR, aes(Matija_Lah, Sasa_Masic, color = tRRCluster$cluster)) + geom_point() +
  geom_abline(intercept = -0.1352, slope = 1.0020)


#where to get intercept and slope?
lm(tRR$Matija_Lah ~ tRR$Sasa_Masic)




# we can also check the regression line for previous example
ggplot(tRR, aes(Tomaz_Kastrun, Mladen_Prajdic, color = tRRCluster$cluster)) + geom_point() + geom_abline(intercept=3.7129, slope=0.2755)


# lm(tRR$Tomaz_Kastrun ~ tRR$Mladen_Prajdic)





# ~~~~~~~~~~~~~~~~~~~~~~
# CASE  of relevant data
# ~~~~~~~~~~~~~~~~~~~~~~

Matija_Lah     <- c(1,1,2,5,7,8,9,7)
Tomaz_Kastrun  <- c(5,9,4,1,1,7,5,9)
Dejan_Sarka    <- c(1,4,2,5,8,6,2,8)
Mladen_Prajdic <- c(2,6,7,2,6,1,8,9)
Sasa_Masic     <- c(1,3,2,4,8,9,7,7)


restaurantRatings <- rbind(Matija_Lah, Tomaz_Kastrun, Dejan_Sarka, Mladen_Prajdic, Sasa_Masic) 

colnames(restaurantRatings) <- c("Foculus", "Pr' Matiji doma", "Sir William's Pub", "Eksperiment", "Pivnica Union", "Pikniki pr Dejanu", "Manna", "Compa")

restaurantRatings

#~~~~~~~~~~~~~~~~~~~~~~~~~
# case of ir-relevant data
#~~~~~~~~~~~~~~~~~~~~~~~~~

Matija_Lah     <- c(1,1,2, "blue", FALSE)
Tomaz_Kastrun  <- c(5,9,4, "white", FALSE)
Dejan_Sarka    <- c(1,4,2, "black", FALSE)
Mladen_Prajdic <- c(2,6,7, "blue", FALSE)
Sasa_Masic     <- c(1,3,2, "white", TRUE)

restaurantRatings <- rbind(Matija_Lah, Tomaz_Kastrun, Dejan_Sarka, Mladen_Prajdic, Sasa_Masic) 

colnames(restaurantRatings) <- c("Foculus", "Pr' Matiji doma", "Sir William's Pub", "Socks Color", "Has a hat")

df_restaurantRatings <- data.frame(restaurantRatings)



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# missing data  /  related data?
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Matija_Lah     <- c(1,1,2, "blue", FALSE)
Tomaz_Kastrun  <- c(5,9,NA, "white", FALSE)
Dejan_Sarka    <- c(1,4,2, "black", FALSE)
Mladen_Prajdic <- c(2,6,7, NA , FALSE)
Sasa_Masic     <- c(1,3,NA , "white", TRUE)



restaurantRatings <- rbind(Matija_Lah, Tomaz_Kastrun, Dejan_Sarka, Mladen_Prajdic, Sasa_Masic) 

colnames(restaurantRatings) <- c("Foculus", "Pr' Matiji doma", "Sir William's Pub", "Socks Color", "Has a hat")

df_restaurantRatings_missing <- data.frame(restaurantRatings)







#########################################################
### End of file
#########################################################













































options(digits = 2)
(rm_svd <- svd(restaurantRatings))


reconstructed_rm <- rm_svd$u %*% diag(rm_svd$d) %*% t(rm_svd$v)
reconstructed_rm


energy <- rm_svd$d ^ 2
cumsum(energy) / sum(energy)

d92 <- c(rm_svd$d[1:2], rep(0, length(rm_svd$d) - 2))
reconstructed92_rm <- rm_svd$u %*% diag(d92) %*% t(rm_svd$v)
reconstructed92_rm





######################################################################
######################################################################


#################################
# Introducing the Iris Data Set
#################################

head(iris, n = 3)

new_sample <- c(4.8, 2.9, 3.7, 1.7)
names(new_sample)<-c("Sepal.Length","Sepal.Width","Petal.Length","Petal.Width")
new_sample

iris_features <- iris[1:4]
dist_eucl <- function(x1, x2) sqrt(sum((x1 - x2) ^ 2))
distances <- apply(iris_features,1,function(x) dist_eucl(x,new_sample))
distances_sorted <- sort(distances,index.return = T)
str(distances_sorted)

nn_5 <- iris[distances_sorted$ix[1:5],]
nn_5

#################################
# Preprocessing with caret
#################################

library("caret")
iris_numeric <- iris[1:4]
pp_unit <- preProcess(iris_numeric, method = c("range"))
iris_numeric_unit <- predict(pp_unit, iris_numeric)
pp_zscore <- preProcess(iris_numeric, method = c("center", "scale"))
iris_numeric_zscore <- predict(pp_zscore, iris_numeric)
pp_boxcox <- preProcess(iris_numeric, method = c("BoxCox"))
iris_numeric_boxcox <- predict(pp_boxcox, iris_numeric)

p1 <- ggplot(iris_numeric, aes(x=Sepal.Length)) + geom_density(color="black",fill="black",alpha=0.4)+ ggtitle("Unnormalized")
p1

p2 <- ggplot(iris_numeric_unit, aes(x=Sepal.Length)) + geom_density(color="black",fill="black",alpha=0.4)+ ggtitle("Unit Interval Transformation")
p2

p3 <- ggplot(iris_numeric_zscore, aes(x=Sepal.Length)) + geom_density(color="black",fill="black",alpha=0.4)+ ggtitle("Z-Score Transformation")
p3

p4 <- ggplot(iris_numeric_boxcox, aes(x=Sepal.Length)) + geom_density(color="black",fill="black",alpha=0.4)+ ggtitle("Box Cox Transformation")
p4

#################################
# Problematic Features
#################################

cor(iris_numeric)

iris_cor <- cor(iris_numeric)
findCorrelation(iris_cor)
findCorrelation(iris_cor,cutoff=0.99)
findCorrelation(iris_cor,cutoff=0.80)

new_iris <- iris_numeric
new_iris$Cmb <- 6.7*new_iris$Sepal.Length - 0.9*new_iris$Petal.Width
set.seed(68)
new_iris$Cmb.N <- new_iris$Cmb + rnorm(nrow(new_iris),sd=0.1)
options(digits = 4)
head(new_iris, n = 3)

findLinearCombos(new_iris)

newer_iris <- iris_numeric
newer_iris$ZV <- 6.5
newer_iris$Yellow <- ifelse(rownames(newer_iris)==1,T,F)
head(newer_iris,n=3)

nearZeroVar(newer_iris)
nearZeroVar(newer_iris, saveMetrics=T)

#################################
# Principal Components Analysis
#################################

pp_pca <- preProcess(iris_numeric, method=c("BoxCox", "center", "scale", "pca"), thresh=0.95)
iris_numeric_pca <- predict(pp_pca, iris_numeric)
head(iris_numeric_pca, n=3)

options(digits=2)
pp_pca$rotation

pp_pca_full <- preProcess(iris_numeric, method=c("BoxCox", "center", "scale", "pca"), pcaComp=4)
iris_pca_full <- predict(pp_pca_full, iris_numeric)
pp_pca_var <- apply(iris_pca_full,2,var)
iris_pca_var <- data.frame(Variance = round(100*pp_pca_var/sum(pp_pca_var),2), CumulativeVariance = round(100*cumsum(pp_pca_var) / sum(pp_pca_var),2))
iris_pca_var

p <- ggplot(data=iris_pca_var) 
p <- p + aes(x=rownames(iris_pca_var), y=Variance, group=1) 
p <- p + geom_line() 
p <- p + geom_point() 
p <- p + xlab("Principal Component") 
p <- p + ylab ("Percentage of Original Variance Captured")
p <- p +  ggtitle("Scree Plot for Iris PCA") 
p <- p + geom_text(aes(label = paste(Variance, "% (", CumulativeVariance, "%)", sep = ""), parse = F),hjust=0, vjust=-0.5)
p

#################################
# k-Nearest Neighbors
#################################

set.seed(2412)
iris_sampling_vector <- createDataPartition(iris$Species, p = 0.8, list = FALSE)

iris_train <- iris_numeric[iris_sampling_vector,]
iris_train_z <- iris_numeric_zscore[iris_sampling_vector,]
iris_train_pca <- iris_numeric_pca[iris_sampling_vector,]
iris_train_labels <- iris$Species[iris_sampling_vector]

iris_test <- iris_numeric[-iris_sampling_vector,]
iris_test_z <- iris_numeric_zscore[-iris_sampling_vector,]
iris_test_pca <- iris_numeric_pca[-iris_sampling_vector,]
iris_test_labels <- iris$Species[-iris_sampling_vector]

knn_model <- knn3(iris_train, iris_train_labels, k = 5)
knn_model_z <- knn3(iris_train_z, iris_train_labels, k = 5)
knn_model_pca <- knn3(iris_train_pca, iris_train_labels, k = 5)

#################################
# kNN Contour Plots
#################################

require(class)

layout(matrix(1:4,2,2, byrow=T))

for (k in c(1,5,10,15)) {
  x <- iris_train_pca
  px1 <- seq(from=-3.5, to=3.5, by=0.1)
  px2 <- seq(from=-3.0, to=3.5, by=0.1)
  g <- iris_train_labels
  xnew <- as.matrix(expand.grid(px1, px2))
  mod15 <- knn(x, xnew, g, k=k, prob=F)
  prob <- ifelse(mod15=="setosa", 1.0, ifelse(mod15=="virginica", 0.6, 0.1))
  prob15 <- matrix(prob, length(px1), length(px2))
  par(mar=rep(2,4))
  contour(px1, px2, prob15, levels=c(0.2), labels="", xlab="", ylab="", main=paste(k,"NN on Iris PCA",sep=""), axes=FALSE)
  train_pch <- ifelse(g=="setosa", 15, ifelse(g=="virginica", 16, 17))
  grid_pch <- ifelse(mod15=="setosa", 15, ifelse(mod15=="virginica", 16 , 17))
  points(x, pch=train_pch, cex=1.2, col="gray40")
  gd <- expand.grid(x=px1, y=px2)
  points(gd, pch=".", cex=0.4)
  box()
}

#################################
# Assessing Models
#################################

knn_predictions_prob <- predict(knn_model, iris_test, type="prob")
tail(knn_predictions_prob, n=3)

knn_predictions <- predict(knn_model, iris_test, type="class")
knn_predictions_z <- predict(knn_model_z, iris_test_z, type="class")
knn_predictions_pca <- predict(knn_model_pca, iris_test_pca, type="class")

postResample(knn_predictions, iris_test_labels)
postResample(knn_predictions_z, iris_test_labels)
postResample(knn_predictions_pca, iris_test_labels)

table(knn_predictions,iris_test_labels)

#################################
# Binary Classification
#################################

set.seed(56)
actual <- rbinom(100000, 1, 1/10000)
a_f <- as.factor(ifelse(actual==1,"positive","negative"))
set.seed(59)
predicted <- rbinom(100000, 1, 1/1000)
p_f <- as.factor(ifelse((predicted+actual)==1,"positive","negative"))
table(actual=a_f,predicted=p_f)






















