# checks if anything recorded in all food records that are missing in the food db
check.db <- function(food_database_fn, food_records_fn, output_fn)
{
    fdata <- read.table(food_database_fn, header = TRUE, sep="\t", colClasses="character", quote="", strip.white=T)
    diet <- read.table(food_records_fn, header = TRUE, sep="\t", colClasses="character", quote="", strip.white=T)
    
    foods.missing <- unique(diet[!(diet$FoodID %in% fdata$FoodID), c("Main.food.description", "FoodID")])
    
    write.table(foods.missing, output_fn, sep = "\t", quote = FALSE, row.names = FALSE)
    
}

