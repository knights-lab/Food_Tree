# Loads USDA Main Food Descriptions, create Node tree
#
# 

# Add packages
packages <- c('data.tree', 'haven')
# lapply(packages, install.packages, character.only=TRUE)
lapply(packages, require, character.only=TRUE)

# Might take database off of project files to keep project file size small (db is ~350MB)
# Found Supertracker DB
rootdir<-Sys.getenv('Food Tree')
meals<-read.csv(paste(rootdir,'data', 'SuperTracker Foods Database 2017.csv', sep='/'))
mainFoodDescriptions <- read_sas(paste(rootdir, "data", "mainfooddesc.sas7bdat", sep='/'))

#Replace commas to _
mainFoodDescriptions$Main_food_description<- sub(' ','_', mainFoodDesc$Main_food_description)
mainFoodDescriptions$Main_food_description<- gsub('[, ]+','_', mainFoodDesc$Main_food_description)
mainFoodDesc$Main_food_description<- gsub('[__]+','_', mainFoodDesc$Main_food_description)

# Create pathString based on foodCode descriptors
mainFoodDescriptions$pathString<-paste("food codes", mainFoodDescriptions$Food_code%/%10000000, mainFoodDescriptions$Food_code%/%1000000, mainFoodDescriptions$Food_code%/%100000, mainFoodDescriptions$Food_code%/%10000, mainFoodDescriptions$Food_code%/%1000, mainFoodDescriptions$Main_food_description, sep="/")



#Combine USDA and Supertracker data
#mealCodes<-meals[,c("foodcode", "Food_Item_Description_ID")]
#mainFoodDescriptions<-merge(mainFoodDescriptions, mealCodes, by.x=c("Food_code"), by.y=c("foodcode"))
#mainFoodDescriptions$pathString<-paste("food codes", mainFoodDescriptions$Food_code%/%10000000, mainFoodDescriptions$Food_code%/%1000000, mainFoodDescriptions$Food_code%/%100000, mainFoodDescriptions$Food_code%/%10000, mainFoodDescriptions$Food_code%/%1000, mainFoodDescriptions$Food_Item_Description_ID, sep="/")

foodTree<-as.Node(mainFoodDescriptions)
