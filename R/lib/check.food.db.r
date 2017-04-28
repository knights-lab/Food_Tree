# checks if anything recorded in all food records that are missing in the food db
check.food.db <- function(food_database_fn, food_records_fn, output_fn)
{
    fdata <- read.table(food_database_fn, header = TRUE, sep="\t", colClasses="character", quote="", strip.white=T)
    diet <- read.table(food_records_fn, header = TRUE, sep="\t", colClasses="character", quote="", strip.white=T)
    
    diet$FoodID <- paste(diet$Food.code, diet$Mod.code, sep=".")
    foods.missing <- unique(diet[!(diet$FoodID %in% fdata$FoodID), "Main.food.description"])
    
    write.table(foods.missing, output_fn, sep = "\t", quote = FALSE, row.names = FALSE)
}

