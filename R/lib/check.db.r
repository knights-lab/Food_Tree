# checks if anything recorded in all food records that are missing in the food db
check.db <- function(food_database_fn, food_records_fn, output_fn)
{
    fdata <- read.table(food_database_fn, header = TRUE, sep="\t", colClasses="character", quote="", strip.white=T)
    diet <- read.table(food_records_fn, header = TRUE, sep="\t", colClasses="character", quote="", strip.white=T)
    
    foods.missing <- unique(diet[!(diet$FoodID %in% fdata$FoodID), c("Main.food.description", "FoodID")])
    
    # foods missing that already actually exist in the data
    overlap <- foods.missing[foods.missing$Main.food.description %in% fdata$Main.food.description,]
    
    # remove these from the missing foods file
    foods.missing <- foods.missing[!(foods.missing$Main.food.description %in% overlap$Main.food.description),]
    
    write.table(foods.missing, output_fn, sep = "\t", quote = FALSE, row.names = FALSE)
    
}


