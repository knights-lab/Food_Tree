# TODO:make a new node labels file specific for the Twins FFQ data.
# Add levels to the tree for cruciferous vegetables, alium vegetables, HF and LF cereals, etc.

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

format.foods(input_fn="data/TWINS/ffq_foods.txt", 
             output_fn="data/TWINS/TwinsDatabase.txt")

format.foods(input_fn="data/TWINS/dietrecords.txt", 
             output_fn="data/TWINS/dietrecords.formated.txt", 
             dedupe=F)

check.db(food_database_fn = "data/MCT/ASA24Database.txt", 
         food_records_fn="data/TWINS/dietrecords.formated.txt", 
         output_fn="data/TWINS/missing.txt")

# nothing is missing!

# if there are missing foods, then create new files to add them in below under addl_foods
make.food.tree(nodes_fn="data/NodeLabelsMCT.txt", 
               food_database_fn="data/TWINS/TwinsDatabase.txt", 
               output_tree_fn="output/twins.tree.txt", 
               output_taxonomy_fn = "output/twins.taxonomy.txt")


# next we can make the food otu table.
# formatting the ffq records into a useable format must first be compelted 
# see Format_FFQ_for_tree.R to see how raw FFQs are first made to look like otutables.



