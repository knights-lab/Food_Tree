# Set current directory to R folder 
setwd("/Users/pvangay/Dropbox/UMN/KnightsLab/Food_Tree/R")

source("lib/newick.tree.r")
source("lib/check.db.r")
source("lib/format.foods.r")
source("lib/make.food.tree.r")
source("lib/make.food.otu.r")

orig_food_records_fn <- "../raw data/original_impdietrecords.txt"
orig_database_fn <- "../raw data/original_SuperTrackerDatabase.txt"

food_records_fn <- "data/IMP/dietrecords.txt"
food_records2_fn <- "data/IMP/dietrecords.placeholderIDs.txt"
food_database_fn <- "data/IMP/SuperTrackerDatabase.txt"
food_taxonomy_fn <- "output/supertracker.taxonomy.txt"

# make sure all food files are properly formatted with FoodIDs
format.foods(orig_database_fn, food_database_fn)
format.foods(orig_food_records_fn, food_records_fn, dedupe=F) # do NOT deduplicate records
# format additional food files here as well

# check if any foods in our diets are missing from our database
check.db(food_database_fn, food_records_fn, output_fn="data/IMP/missing.txt")

make.food.tree(nodes_fn="data/NodeLabels.txt", food_database_fn, 
    addl_foods_fn=NULL, output_tree_fn="output/supertracker.tree.txt", 
    output_taxonomy_fn = food_taxonomy_fn)
    
# make food otu table with a placeholder dietrecord for now until we get IDs resolved!
make.food.otu(food_records2_fn, food_record_id = "Sample.ID", food_taxonomy_fn, output_fn = "output/imp.food.otu.txt")