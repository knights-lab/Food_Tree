# Set current directory to R folder 
setwd("/Users/pvangay/Dropbox/UMN/KnightsLab/Food_Tree/R")

source("lib/newick.tree.r")
source("lib/check.db.r")
source("lib/format.foods.r")
source("lib/make.food.tree.r")
source("lib/make.food.otu.r")
source("lib/filter.db.by.diet.records.r")


orig_food_records_fn <- "../raw data/original_impdietrecords.txt" # original diet records with special characters removed
orig_database_fn <- "../raw data/original_SuperTrackerDatabase.txt" # original supertracker database
orig_new_foods_fn <-  "../raw data/original_imp.missing.foods.txt" # hand-curated foods that were missing now assigned with food IDs

old_food_records_fn <- "data/IMP/dietrecords.with.NAs.txt" # first run through, contains NAs
food_records_fn <- "data/IMP/dietrecords.txt" # already formatted, NAs corrected by add.missing.foods.to.diets
new_foods_fn <- "data/IMP/new.foods.tree.building.txt" # new foods used to construct tree only, duplicates caused by portions removed (written by add.missing.foods.to.diets)
food_database_fn <- "data/IMP/SuperTrackerDatabase.txt" # formatted
food_taxonomy_fn <- "output/supertracker.taxonomy.txt" # outputted by make.food.tree

food_reported_database_fn <- "data/IMP/SuperTrackerDatabase.foodsreportedonly.txt" # database containing only the foods eaten in this specific dataset
food_reported_taxonomy_fn <- "output/supertracker.taxonomy.foodsreportedonly.txt" # outputted by make.food.tree

# make sure all food files are properly formatted with FoodIDs
format.foods(orig_database_fn, food_database_fn)
format.foods(orig_food_records_fn, old_food_records_fn, dedupe=F) # do NOT deduplicate records

###### run code in add.missing.foods.to.diets here

# check if any foods in our diets are missing from our database (this step not super useful)
check.db(food_database_fn, food_records_fn, output_fn="data/IMP/missing.txt")

make.food.tree(nodes_fn="data/NodeLabels.txt", food_database_fn, 
    addl_foods_fn=new_foods_fn, output_tree_fn="output/supertracker.tree.txt", 
    output_taxonomy_fn = food_taxonomy_fn)

# check our full taxonomy against our food records (should be empty if all foods are covered)
check.db(food_taxonomy_fn, food_records_fn, output_fn="data/IMP/diet.missing.from.taxonomy.file.txt")

fotu <- make.food.otu(food_records_fn, food_record_id = "Sample.ID", food_taxonomy_fn, output_fn = "output/imp.food.otu.txt")


### redo tree/taxonomy/otu generation with only the foods actually reported
    filter.db.by.diet.records(food_database_fn=food_database_fn, food_records_fn=food_records_fn, output_fn=food_reported_database_fn)

    make.food.tree(nodes_fn="data/NodeLabels.txt", food_reported_database_fn, 
        addl_foods_fn=new_foods_fn, output_tree_fn="output/supertracker.tree.foodsreportedonly.txt", 
        output_taxonomy_fn = food_reported_taxonomy_fn)

    # check our full taxonomy against our food records (should be empty if all foods are covered)
    check.db(food_reported_taxonomy_fn, food_records_fn, output_fn="data/IMP/diet.missing.from.taxonomy.file.foodsreportedonly.txt")

    # OTU generation should not be necessary here, but can double check
    make.food.otu(food_records_fn, food_record_id = "Sample.ID", food_reported_taxonomy_fn, output_fn = "output/imp.food.otu.foodsreportedonly.txt")






# NOTE: Probably only useful for IMP dataset!
# this code merges the manually assigned Missing Foods list to the Diet Records, so that all diet records with FoodCodes==NA 
# will now have Food Codes assigned. The reason for this is that the diet records still contain food portions in them, so it's important to make use
# of the portion in calculating the final grams in each food eaten
add.missing.foods.to.diets <- function()
{
    diet <- read.table(old_food_records_fn, header = TRUE, sep="\t", colClasses="character", quote="", strip.white=T)
    new.foods <- read.table(orig_new_foods_fn, header = TRUE, sep="\t", colClasses="character", quote="", strip.white=T)

    diet$tempID <- 1:nrow(diet) # create dummy ID for now
    
    new.foods$ModCode[new.foods$ModCode == ""] <- "0"

    # write this out so we can pass it in when we make the food tree; remove foods with duplicate portions
    # This file will be the formatted "new foods" that we'd like to supplement the SuperTracker Database with
    x <- new.foods
    x$FoodID <- paste(x$FoodCode, x$ModCode, sep=".")
    x <- x[!duplicated(x$Main.food.description),]
    write.table(x, new_foods_fn, sep = "\t", quote = FALSE, row.names = FALSE)

    blank.diets <- diet[is.na(diet$FoodCode),]
    # remove columns we're going to fill in 
    c.ix <- which(colnames(blank.diets) %in% c("FoodCode", "ModCode", "FoodAmt", "FoodID", "portionwgt"))
    blank.diets <- blank.diets[,-c.ix]

    new.diet <- merge(blank.diets, new.foods, by=c("Main.food.description", "Portion"))
    
    valid.diets <- diet[!is.na(diet$FoodCode),]
    valid.diets <- rbind(valid.diets[,intersect(colnames(new.diet), colnames(valid.diets))], new.diet[,intersect(colnames(new.diet), colnames(valid.diets))])
    # now calculate the total grams eaten, and call it "FoodAmt" to be consistent with ASA24
    valid.diets$FoodAmt <- as.numeric(valid.diets$PortionAmt) * as.numeric(valid.diets$portionwgt)
    
    # make FoodID
    valid.diets$FoodID <- paste(valid.diets$FoodCode, valid.diets$ModCode, sep=".")
    
    # check temporary variable ID only to see if any foods are missing
    #diet[!(diet$tempID %in% valid.diets$tempID),]
    #write.table(unique(diet[!(diet$ID %in% valid.diets$ID),c("Main.food.description", "Old.Main.food.description")]), file="new.missing.foods.txt", sep="\t", row=F, quote=F)
    
    write.table(valid.diets, food_records_fn, sep = "\t", quote = FALSE, row.names = FALSE)
    
}