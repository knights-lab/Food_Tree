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

# pre-processing steps

# 1. save txt of the items file from the provided excel sheet
# 2. remove problematic text characters like # from the column names
# 3. remove problematic blank rows from data.


# Will need: ASA24 database - previously made: available at "data/RYGB/ASA24Database.txt" 
# this is not correct for this data becuase used canadian version of the ASA24
format.foods(input_fn="../../Jens/FOOD_NAME_recode_min.txt", output_fn = "data/Jens/JensDatabase.txt")

# format the items file that contains all of the foods - previously pre-processed this file to make txt and remove ",',&,%
# Also need to change the name of the Food_Description field to "Main.food.description"
format.foods(input_fn="data/JENS/diet_records_new_foodcodes.txt", output_fn="data/JENS/dietrecords.txt", dedupe=F)


# next check to make sure the database has all the foods in the foods file
check.db(food_database_fn = "data/Jens/JensDatabase.txt", food_records_fn="data/JENS/dietrecords.txt", output_fn="data/JENS/missing.txt")

# in this case there are many foods missing from the database. This is probably a coding issue
# because we didn't start wtih the most raw version of the files from ASA24 and started with a processed excel sheet
# it's possible that there were naming changes or version differences


# make the food tree file
# in this case there are missing items, so we will add them here
make.food.tree(nodes_fn="data/NodeLabels.txt",    # make node labels file for the canadian files
               food_database_fn="data/JENS/JensDatabase.txt",
               #addl_foods_fn="data/JENS/missing.txt",
               output_tree_fn="output/jens.tree.txt", 
               output_taxonomy_fn = "output/jens.taxonomy.txt")

# this makes the food table as dehydrated grams per kcal
make.dhydrt.otu(food_records_fn="data/JENS/dietrecords.txt", food_record_id = "Study_ID", food_taxonomy_fn="output/jens.taxonomy.txt", 
                output_fn = "output/jens.dhydrt.txt")

# make a fiber food table with weights from fiber
make.fiber.otu(food_records_fn="data/JENS/dietrecords.txt", food_record_id = "Study_ID", food_taxonomy_fn="output/jens.taxonomy.txt", 
               output_fn = "output/jens.fiber.txt")
