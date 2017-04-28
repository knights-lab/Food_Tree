# Set FT_FOLDER to your absolute local path to /Food_Tree/R
FT_FOLDER <- "/Users/pvangay/Dropbox/UMN/KnightsLab/Food_Tree/R"

source(paste0(FT_FOLDER,"/lib/newick.tree.r"))
source(paste0(FT_FOLDER,"/lib/check.food.db.r"))
source(paste0(FT_FOLDER,"/lib/format.food.db.r"))
source(paste0(FT_FOLDER,"/lib/make.food.tree.r"))

format.food.db(raw_database_fn="data/MCT/MainFoodDesc.txt", output_fn="data/MCT/ASA24Database.txt")
format.food.db(raw_database_fn="data/MCT/MCTs_study_missing_variables.txt", output_fn="data/MCT/MCTs_study_missing_variables_formatted.txt")
format.food.db(raw_database_fn="data/MCT/Soylent_codes.txt", output_fn="data/MCT/Soylent_codes_formatted.txt")

#check.food.db(food_database_fn = "data/MCT/ASA24Database.txt", food_records_fn="data/MCT/dietrecords.txt", output_fn="data/MCT/missing.txt")

# if there are missing foods, then create new files to add them in below under addl_foods
make.food.tree(nodes_fn="data/NodeLabels.txt", food_database_fn="data/MCT/ASA24Database.txt", 
    addl_foods_fn=c("data/MCT/Soylent_codes_formatted.txt","data/MCT/MCTs_study_missing_variables_formatted.txt"), output_tree_fn="output/mct.tree.txt", 
    output_taxonomy_fn = "output/mct.taxonomy.txt")