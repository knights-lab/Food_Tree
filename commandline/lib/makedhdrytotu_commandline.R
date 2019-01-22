option_list = list(
  make_option(c('-i', '--food_records_fn'),
              help = 'Required-input necessary',
              default=NA, type='character'),
  make_option(c('-a', '--food_record_id'),
              help='Required food record ID',
              default=NA, type='character'),
  make_option(c('-b', '--food_taxonomy_fn'),
              help = 'Required food taxonomy',
              default=NA, type='character'),
  make_optioin(c('-o', '--output_fn'),
               help = 'Required, direct output file',
               default=NA, type='character')
)

opt <- parse_args(OptionParser(usage=usage, option_list=option_list))

if (is.na(opt$food_records_fn) | is.na(opt$food_record_id) | is.na(opt$food_taxonomy_fn) | is.na(opt$output_fn)) {
  stop('Missing required parameters. See usage and options (--help')
}

food_records_fn <- opt$food_records_fn
food_record_id <- opt$food_record_id
food_taxonomy_fn <- opt$food_taxonomy_fn
output_fn <- opt$output_fn

make.dhydrt.otu <- function(food_records_fn, food_record_id, food_taxonomy_fn, output_fn)
{
  # read everything in as a character to preserve numeric food codes and IDs
  diet <- read.table(food_records_fn, header = TRUE, sep="\t", colClasses="character", quote="", strip.white=T)
  diet$FoodAmt <- as.numeric(diet$FoodAmt)
  diet$KCAL <- as.numeric(diet$KCAL)
  diet$MOIS <- as.numeric(diet$MOIS)
  
  # make new variable dhydrated grams per kcal
  diet$dhydrt <- (diet$FoodAmt - diet$MOIS)
  
  # sum total grams of each food eaten within a record
  cdiet <- aggregate(diet$dhydrt, by=list(diet[,food_record_id], diet$FoodID), FUN=sum)
  colnames(cdiet) <- c(food_record_id, "FoodID", "dhydrt")
  
  cdiet.w <- reshape(cdiet, timevar = "FoodID", idvar = food_record_id, direction = "wide")
  cdiet.w[is.na(cdiet.w)] <- 0
  rownames(cdiet.w) <- cdiet.w[,1] # make record_ids the rownames
  cdiet.w <- cdiet.w[,-1]    
  colnames(cdiet.w) <- gsub("dhydrt.", "", colnames(cdiet.w)) #rename column names to FoodIDs only
  t.cdiet.w <- t(cdiet.w)
  
  food.taxonomy <- read.table(food_taxonomy_fn, sep="\t", colClasses="character", quote="", header=T, row=1)
  
  dhydrt.otu <- merge(t.cdiet.w, food.taxonomy, by=0)
  
  # let's get rid of the FoodIDs and replace it with the food tree leaf names
  rownames(dhydrt.otu) <- dhydrt.otu[,"Main.food.description"]
  remove.col.ix <- which(colnames(dhydrt.otu) %in% c("Main.food.description", "Row.names"))
  dhydrt.otu <- dhydrt.otu[,-remove.col.ix]
  
  #drop rows with infinate values
  inf.vals <- which(rowSums(dhydrt.otu[,-ncol(dhydrt.otu)]) == Inf)
  dhydrt.otu <- dhydrt.otu[!(rownames(dhydrt.otu) %in% names(inf.vals)),]
  
  cat("#FOODID\t", file=output_fn)
  write.table(dhydrt.otu, output_fn, sep = "\t", quote = F, append=TRUE)
  
  invisible(dhydrt.otu)
}