# filters the entire database of foods by only those that were actually reported in this dataset
# useful for creating trees limited only to foods collected
filter.db.by.diet.records <- function(food_database_fn, food_records_fn, output_fn)
{
    fdata <- read.table(food_database_fn, header = TRUE, sep="\t", colClasses="character", quote="", strip.white=T)
    diet <- read.table(food_records_fn, header = TRUE, sep="\t", colClasses="character", quote="", strip.white=T)
    valid_ids <- intersect(fdata$FoodID, diet$FoodID)
    write.table(fdata[fdata$FoodID %in% valid_ids,], output_fn, sep="\t", quote=FALSE, row.names=FALSE)
}
