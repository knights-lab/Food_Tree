option_list = list(
  make_option(c('-i', '--food_database_fn'),
              help = 'Required, input table',
              default=NA, type='character'),
  make_option(c('-a', '--food_records_fn'),
              help = 'Required, food records',
              default=NA, type = 'character'),
  make_option(c('o', '--output_fn'),
              help= 'Required, direct output table',
              default=NA, type='character')
)

opt <- parse_args(OptionParser(usage=usage, option_list=option_list))

if (is.na(opt$food_database_fn) | is.na(opt$food_records_fn) | is.na(opt$output_fn)) {
  stop('Missing required parameters. See usage and options (--help)')
}

food_database_fn <- opt$food_database_fn
food_records_fn <- opt$food_records_fn
output_fn <- opt$output_fn

check.db <- function(food_database_fn, food_records_fn, output_fn)
{
  fdata <- read.table(food_database_fn, header = TRUE, sep="\t", colClasses="character", quote="", strip.white=T)
  diet <- read.table(food_records_fn, header = TRUE, sep="\t", colClasses="character", quote="", strip.white=T)
  
  # if interested in missing unique portions, add "Portion" to this list
  foods.missing <- unique(diet[!(diet$FoodID %in% fdata$FoodID), c("Main.food.description", "FoodID")])
  
  # foods missing that already actually exist in the data
  overlap <- foods.missing[foods.missing$Main.food.description %in% fdata$Main.food.description,]
  
  # remove these from the missing foods file
  foods.missing <- foods.missing[!(foods.missing$Main.food.description %in% overlap$Main.food.description),]
  
  write.table(foods.missing, output_fn, sep = "\t", quote = FALSE, row.names = FALSE)
  
}

#included the filter for these diet records because it uses the exact same files
filter.db.by.diet.records <- function(food_database_fn, food_records_fn, output_fn)
{
  fdata <- read.table(food_database_fn, header = TRUE, sep="\t", colClasses="character", quote="", strip.white=T)
  diet <- read.table(food_records_fn, header = TRUE, sep="\t", colClasses="character", quote="", strip.white=T)
  valid_ids <- intersect(fdata$FoodID, diet$FoodID)
  write.table(fdata[fdata$FoodID %in% valid_ids,], output_fn, sep="\t", quote=FALSE, row.names=FALSE)
}
