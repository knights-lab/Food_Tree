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

# clean up files so they work with the tree building downstream
format.foods(input_fn="data/NHANES/processed/foodcodes.txt", output_fn="data/NHANES/NHANESDatabase.txt") # build database from main FoodCodes
#format.foods(input_fn="data/NHANES/processed/individual.foods.from.deceased_NHANES_2007-2010.txt", output_fn="data/NHANES/dietrecords.txt", dedupe=F)
format.foods(input_fn="data/NHANES/processed/individual.foods.from.NHANES_2007-2010.txt", output_fn="data/NHANES/dietrecords_all.txt", dedupe=F)

# do this for the entire database of people
check.db(food_database_fn = "data/NHANES/NHANESDatabase.txt", food_records_fn="data/NHANES/dietrecords_all.txt", output_fn="data/NHANES/missing.txt")


make.food.tree(nodes_fn="data/NodeLabelsMCT.txt", 
               addl_foods_fn = "data/NHANES/missing.txt",
               food_database_fn="data/NHANES/NHANESDatabase.txt", 
               output_tree_fn="output/nhanes.tree.txt", 
               output_taxonomy_fn = "output/nhanes.taxonomy.txt",
               num.levels=5)


# this makes the standard food otu table with data in gram weights of food
make.food.otu(food_records_fn="data/NHANES/dietrecords_all.txt", 
              food_record_id = "seqn", 
              food_taxonomy_fn="output/nhanes.taxonomy.txt", 
              output_fn = "output/nhanes.food.otu.txt")


### redo tree/taxonomy/otu generation with only the foods actually reported
filter.db.by.diet.records(food_database_fn="data/NHANES/NHANESDatabase.txt",
                          food_records_fn="data/NHANES/dietrecords_all.txt", 
                          output_fn="output/nhanesfoodreportedonly.txt")

make.food.tree(nodes_fn="data/NodeLabelsMCT.txt", 
               food_database_fn = "output/nhanesfoodreportedonly.txt", 
               addl_foods_fn= "data/NHANES/missing.txt", 
               output_tree_fn="output/nhanes.tree.foodsreportedonly.txt", 
               output_taxonomy_fn = "output/nhanes.taxonomy.foodsreportedonly.txt",
               num.levels=5)


