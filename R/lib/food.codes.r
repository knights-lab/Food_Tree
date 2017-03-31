# Loads ASA/Supertracker Food Descriptions and creates a Newick formatted tree from naming conventions


# Add packages

library(data.tree)
library(haven)
library(dplyr)
library(tidyr)
library(reshape2)

# set working directory to the main github Food_code folder

# setwd(dir = "Documents/Projects/Food_Tree/")

# set paths to necessary files
main.desc <- "R/data/MainFoodDesc.txt"
node.labels <- "R/data/NodeLabels.txt"

# read in files

main <- read.table(main.desc, header = TRUE)
nodes <- read.table(node.labels, header = TRUE)

# fix node column names
colnames(nodes) <- c("code","description")

nodes$code <- as.character(nodes$code)
# main$Food.code <- as.character(main$Food.code)



# Create pathString based on foodCode descriptors
main$pathString<-paste("foodcode", 
                       main$Food.code%/%10000000, 
                       main$Food.code%/%1000000,
                       main$Food.code%/%100000,
                       main$Food.code%/%10000,
                       main$Food.code%/%1000,
                       main$Main.food.description,
                       sep = "/")
                                      

# Split the pathString so that it has one column per string step
pathstring <- main %>% separate(pathString, into = c("root", "L1", "L2", "L3", "L4", "L5", "Description"), sep = "/")

# Format the level descriptions

main <- pathstring %>% select(Food.code, L1:L5)

# melt the data
main.melt <- melt(main, id.vars = "Food.code", variable.name = "Level", value.name = "code")

# merge to get the names
main.merge <- merge(main.melt, nodes, by = "code")


# new.merge$name <- ifelse(is.na(new.merge$name),new.merge$code,new.merge$name)

# reform into original shape
main.cast <- dcast(main.merge, Food.code ~ Level, value.var = "description")


# fill in values that don't have a named level with the numeric code
main.cast$L1 <- paste("L1_", main.cast$L1, sep = "")
main.cast$L2 <- paste("L2_", main.cast$L2, sep = "")
main.cast$L3 <- ifelse(is.na(main.cast$L3), "L3_", paste("L3_", main.cast$L3, sep = ""))
main.cast$L4 <- ifelse(is.na(main.cast$L4), "L4_", paste("L4_", main.cast$L4, sep = ""))
main.cast$L5 <- ifelse(is.na(main.cast$L5), "L5_", paste("L5_", main.cast$L5, sep = ""))




# Rejoin the newly made columns to remake the pathString and taxonomy variable
main.join <- left_join(main.cast, pathstring, by = "Food.code") %>%
             mutate(pathString = paste("foodcode", L1.x, L2.x, L3.x, L4.x, L5.x, Description, sep = "/"), 
                    taxonomy = paste(L1.x, L2.x, L3.x, L4.x, L5.x, Description, sep = ";"))

# Export the the main join file


#### Make the foodTree environment####

foodTree<-as.Node(main.join, pathName = "pathString")


#### Make and export the taxonomy file ####

export <- main.join %>% select(Food.code, taxonomy, Description)
export$Description <- gsub("_", " ", export$Description)

write.table(export, "R/data/food_taxonomy.txt", sep = "/t")

