# Set FT_FOLDER to absolute local path to /Food_Tree/R
FT_FOLDER <- "/Users/pvangay/Dropbox/UMN/KnightsLab/Food_Tree/R"

source(paste0(FT_FOLDER,"/lib/newick.tree.r"))
source(paste0(FT_FOLDER,"/lib/check.food.db.r"))
source(paste0(FT_FOLDER,"/lib/format.food.db.r"))
source(paste0(FT_FOLDER,"/lib/make.food.tree.r"))

format.food.db(raw_database_fn="data/IMP/CompleteSuperTrackerDatabase.txt", output_fn="data/IMP/SuperTrackerDatabase.txt")

check.food.db(food_database_fn = "data/IMP/SuperTrackerDatabase.txt", food_records_fn="data/IMP/dietrecords.txt", output_fn="data/IMP/missing.txt")

make.food.tree(nodes_fn="data/NodeLabels.txt", food_database_fn="data/IMP/SuperTrackerDatabase.txt", 
    addl_foods_fn=NULL, output_tree_fn="output/supertracker.tree.txt", 
    output_taxonomy_fn = "output/supertracker.taxonomy.txt")