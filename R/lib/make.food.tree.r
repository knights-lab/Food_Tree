# This function takes an id-to-description food file + named nodes, then constructs a newick tree.
#
#   food_database_fn = file containing food id and full food description (e.g. ASA24 or SuperTracker database)
#   nodes_fn = file containing all numbered nodes and their descriptions (constructed manually from previous file)
#   addl_foods_fn = vector of files containing additional foods to add [optional]
#   num.levels = number of levels to create tree on

library(data.tree)
library(dplyr)
library(tidyr)
library(reshape2)

make.food.tree <- function(nodes_fn, food_database_fn, addl_foods_fn=NULL, output_tree_fn, output_taxonomy_fn, num.levels=5)
{
    fdata <- read.table(food_database_fn, header = TRUE, sep="\t", colClasses="character", quote="", strip.white=T)
    nodes <- read.table(nodes_fn, header = TRUE, sep="\t", colClasses="character")

    main <- fdata[,c("FoodID", "Main.food.description")]

    # add additional food codes
    if(!is.null(addl_foods_fn))
        for(i in 1:length(addl_foods_fn)){
            new.foods <- read.table(addl_foods_fn[i], header=T, sep="\t", colClasses="character")
            main <- rbind(main, new.foods[,c("FoodID", "Main.food.description")])
        }

    flevels <- NULL
    for(i in 1:num.levels)
        flevels <- cbind(flevels, I(substr(main$FoodID, 1, i)))
    colnames(flevels) <- paste0("L",1:num.levels)
    main <- data.frame(main, flevels, stringsAsFactors=F)
    
    # melt the data, merge to get the node names, then cast back
    main.melt <- melt(main, id.vars = "FoodID", variable.name = "Level", value.name = "Level.code")
    main.merge <- merge(main.melt, nodes, by = "Level.code")
    main.cast <- dcast(main.merge, FoodID ~ Level, value.var = "Main.food.description")

    # prepend level to all level descriptions
    main.cast[is.na(main.cast)] <- ""
    main.cast[,colnames(main.cast)[-1]] <- sapply(colnames(main.cast)[-1], function(colname) paste(colname, main.cast[,colname], sep="_"))

    # merge back with original table to grab Food Description
    main.join <- merge(main.cast, main[,c("FoodID","Main.food.description")], by="FoodID")

    # create a proper newick string for the tree
    newickstring <- paste("foodtreeroot", apply(main.join, 1, function(xx) paste(xx[-1], collapse="/")), sep="/")
    # create a proper taxonomy string for QIIME
    taxonomy <- apply(main.join, 1, function(xx) paste(xx[-1], collapse=";"))

    final.table <- data.frame(main.join, newickstring, taxonomy, stringsAsFactors=F)

    #### Make and export the tree ####
    foodTree <- as.Node(final.table, pathName = "newickstring")
    tree <- recursiveNewickWrite(foodTree)
    cat(tree, file = output_tree_fn)

    #### Make and export the taxonomy file ####
    export <- final.table %>% select(FoodID, taxonomy, Main.food.description)
    export$Main.food.description <- gsub("_", " ", export$Main.food.description)
    write.table(export, output_taxonomy_fn, sep = "\t", quote = FALSE, row.names = FALSE)

}