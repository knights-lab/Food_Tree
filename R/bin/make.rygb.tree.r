# Set FT_FOLDER to your absolute local path to /Food_Tree/R
setwd("/Users/abby/Documents/Projects/Food_Tree/R")

source("lib/newick.tree.r")
source("lib/check.db.r")
source("lib/format.foods.r")
source("lib/make.food.tree.r")
source("lib/make.food.otu.r")
source("lib/make.fiber.otu.r")
source("lib/make.dhydrt.otu.r")
source("lib/filter.db.by.diet.records.r")

# Will need: ASA24 database - previously made: available at "data/RYGB/ASA24Database.txt"
format.foods(input_fn="data/NHANES/processed/foodcodes.txt", output_fn="data/NHANES/NHANESDatabase.txt") # build database from main codes
# format the items file that contains all of the foods - previously pre-processed this file to make txt and remove ",',&,%
# Also need to change the name of the Food_Description field to "Main.food.description
format.foods(input_fn="data/RYGB/raw/items_file.txt", output_fn="data/RYGB/dietrecords.txt", dedupe=F)

# next check to make sure the database has all the foods in the foods file
check.db(food_database_fn = "data/RYGB/ASA24Database.txt", food_records_fn="data/RYGB/dietrecords.txt", output_fn="data/RYGB/missing.txt")

# make the food tree file
# in this case there are no missing items, so no need to add them here
make.food.tree(nodes_fn="data/NodeLabels.txt", 
               food_database_fn="data/RYGB/ASA24Database.txt",
               output_tree_fn="output/rygb.tree.txt", 
               output_taxonomy_fn = "output/rygb.taxonomy.txt")

# this makes the food otu table as dehydrated grams per kcal
make.dhydrt.otu(food_records_fn="data/RYGB/dietrecords.txt", food_record_id = "UserName", food_taxonomy_fn="output/rygb.taxonomy.txt", 
                output_fn = "output/rygb.dhydrt.txt")


### redo tree/taxonomy/otu generation with only the foods actually reported
filter.db.by.diet.records(food_database_fn="data/RYGB/ASA24Database.txt",
                          food_records_fn="data/RYGB/dietrecords.txt", 
                          output_fn="output/rygbfoodreportedonly.txt")

make.food.tree(nodes_fn="data/NodeLabels.txt", 
               food_database_fn = "output/rygbfoodreportedonly.txt", 
               output_tree_fn="output/rygb.tree.foodsreportedonly.txt", 
               output_taxonomy_fn = "output/rygb.taxonomy.foodsreportedonly.txt")
