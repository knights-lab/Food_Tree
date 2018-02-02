# Set FT_FOLDER to your absolute local path to /Food_Tree/R
setwd("/Users/abby/Documents/Projects/Food_Tree/R")

source("lib/newick.tree.r")
source("lib/check.db.r")
source("lib/format.foods.r")
source("lib/make.food.tree.r")
source("lib/make.food.otu.r")
source("lib/make.dhydrt.otu.r")
source("lib/make.fiber.otu.R")
source("lib/filter.db.by.diet.records.r")

# note: ASA24 now has modcodes
#format.foods(input_fn="../raw data/all.food.desc.txt", output_fn="data/MCT/ASA24Database.txt")
#format.foods(input_fn="data/MCT/MCTs_study_missing_variables.txt", output_fn="data/MCT/MCTs_study_missing_variables_formatted.txt")
#format.foods(input_fn="data/MCT/Soylent_codes.txt", output_fn="data/MCT/Soylent_codes_formatted.txt")
format.foods(input_fn="../raw data/IBS_Final_ASA_Items.txt", output_fn="data/IBS/dietrecords.txt", dedupe=F)

# since the IBS study used the ASA24 database (just an older version) we can use the ASA24 database from the MCT study
check.db(food_database_fn = "data/MCT/ASA24Database.txt", food_records_fn="data/IBS/dietrecords.txt", output_fn="data/IBS/missing.txt")

# if there are missing foods, then create new files to add them in below under addl_foods
make.food.tree(nodes_fn="data/NodeLabels.txt", 
              addl_foods_fn = "data/IBS/missing.txt",
               food_database_fn="data/MCT/ASA24Database.txt", 
               output_tree_fn="output/ibs.tree.txt", 
               output_taxonomy_fn = "output/ibs.taxonomy.txt")

# create a reduced node tree that will show just the foods consumed in the study (for visualizations)
### redo tree/taxonomy/otu generation with only the foods actually reported
filter.db.by.diet.records(food_database_fn="data/MCT/ASA24Database.txt",
                          food_records_fn="data/IBS/dietrecords.txt", 
                          output_fn="output/ibs.foodreportedonly.txt")

make.food.tree(nodes_fn="data/NodeLabels.txt", 
               food_database_fn = "output/ibs.foodreportedonly.txt", 
               addl_foods_fn= "data/IBS/missing.txt", 
               output_tree_fn="output/ibs.tree.foodsreportedonly.txt", 
               output_taxonomy_fn = "output/ibs.taxonomy.foodsreportedonly.txt")




# make the different food-out tables for downstream analysis
make.food.otu(food_records_fn="data/IBS/dietrecords.txt", 
              food_record_id = "Timepoint.ID", 
              food_taxonomy_fn="output/ibs.taxonomy.txt", 
              output_fn = "output/ibs.food.otu.txt")

make.dhydrt.otu(food_records_fn="data/IBS/dietrecords.txt", 
                food_record_id = "Timepoint.ID", 
                food_taxonomy_fn="output/ibs.taxonomy.txt", 
                output_fn = "output/ibs.dhydrt.otu.txt")

make.fiber.otu(food_records_fn="data/IBS/dietrecords.txt", 
               food_record_id = "Timepoint.ID", 
               food_taxonomy_fn="output/ibs.taxonomy.txt", 
               output_fn = "output/ibs.fiber.otu.txt")
