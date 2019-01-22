suppressPackageStartupMessages(require(data.tree))
suppressPackageStartupMessages(require(viridisLite))
suppressPackageStartupMessages(require(dplyr))
suppressPackageStartupMessages(require(tidyr))
suppressPackageStartupMessages(require(reshape2))

usage = 'This function takes an id-to-description food file and named nodes, then constructs a newick tree.'

option_list = list(
  make_option(c('-n', '--nodes_fn'),
              help = 'Direct path to nodes file',
              default=NA, type='character'),
  make_option(c('-d', '--food_database_fn'),
              help = 'Direct path to food_database file',
              default=NA, type = 'character'),
  make_option(c('-f', '--output_tree_fn'),
              help = 'Direct path for output file',
              default=NA, type = 'character'),
  make_option(c('-t', '--output_taxonomy_fn'),
              help = 'Direct path for output taxonomy',
              default=NA, type='character')
)

opt <- parse_args(OptionParser(usage=usage, option_list=option_list))

if (is.na(opt$nodes_fn) | is.na(opt$food_database_fn) | is.na(opt$output_tree_fn) | is.na(opt$output_taxonomy_fn)) {
  stop('Missing required parameters.')
}  
  
nodes_fn <- opt$nodes_fn
food_database_fn <- opt$food_database_fn
output_tree_fn <- opt$output_tree_fn
output_taxonomy_fn <- opt$output_taxonomy_fn


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
  # if there happen to be duplicate FoodIDs in main, remove them
  main <- main[!duplicated(main$FoodID),]
  
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