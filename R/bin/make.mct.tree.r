# Set FT_FOLDER to your absolute local path to /Food_Tree/R
setwd("/Users/abby/Documents/Projects/Food_Tree/R")

source("lib/newick.tree.r")
source("lib/check.db.r")
source("lib/format.foods.r")
source("lib/make.food.tree.r")
source("lib/make.food.otu.r")
source("lib/make.fiber.otu.r")
source("lib/make.dhydrt.per.kcal.otu.r")

# note: current ASA24 database doesn't have modcodes
format.foods(input_fn="../raw data/all.food.desc.txt", output_fn="data/MCT/ASA24Database.txt")
#format.foods(input_fn="data/MCT/MCTs_study_missing_variables.txt", output_fn="data/MCT/MCTs_study_missing_variables_formatted.txt")
format.foods(input_fn="data/MCT/Soylent_codes.txt", output_fn="data/MCT/Soylent_codes_formatted.txt")
format.foods(input_fn="../raw data/Items_to_use.txt", output_fn="data/MCT/dietrecords.txt", dedupe=F)

#check.db(food_database_fn = "data/MCT/ASA24Database.txt", food_records_fn="data/MCT/dietrecords.txt", output_fn="data/MCT/missing.txt")

# if there are missing foods, then create new files to add them in below under addl_foods
make.food.tree(nodes_fn="data/NodeLabels.txt", food_database_fn="data/MCT/ASA24Database.txt", 
    addl_foods_fn=c("data/MCT/Soylent_codes_formatted.txt"), output_tree_fn="output/mct.tree.txt", 
    output_taxonomy_fn = "output/mct.taxonomy.txt")

# this makes the standard food otu table with data in gram weights of food
make.food.otu(food_records_fn="data/MCT/dietrecords.txt", food_record_id = "X.SampleID", food_taxonomy_fn="output/mct.taxonomy.txt", 
                output_fn = "output/mct.food.otu.txt")

# this makes the food otu table with data in grams of fiber per food
make.fiber.otu(food_records_fn="data/MCT/dietrecords.txt", food_record_id = "X.SampleID", food_taxonomy_fn="output/mct.taxonomy.txt", 
               output_fn = "output/mct.fiber.otu.txt")

# this makes the food otu table as dehydrated grams per kcal
make.dhydrt.per.kcal.otu(food_records_fn="data/MCT/dietrecords.txt", food_record_id = "X.SampleID", food_taxonomy_fn="output/mct.taxonomy.txt", 
               output_fn = "output/mct.dgpk.otu.txt")
