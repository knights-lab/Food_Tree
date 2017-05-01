# deduplicates database file, replaces special chars with _ and creates a new FoodID out of foodcode and modcode
# leaves all other columns intact
format.foods <- function(input_fn, output_fn, dedupe=T)
{
    fdata <- read.table(input_fn, header = TRUE, sep="\t", colClasses="character", quote="", strip.white=T)

    # if it exists as a column, reformat the Main.food.description
    if(sum(colnames(fdata) == "Main.food.description") == 1){
        fdata$Old.Main.food.description <- fdata$Main.food.description
        # replace anything that isn't a number or character with an underscore (format for QIIME)
        fdata$Main.food.description <- gsub("[^[:alnum:]]+", "_", fdata$Main.food.description)
    }

    # add a default ModCode column if it doesn't exist
    if(sum(colnames(fdata) == "ModCode")==0)
        fdata$ModCode <- rep("0", nrow(fdata))
        
    # make a new food id that also uses the mod.code 
    fdata$FoodID <- paste(fdata$FoodCode, fdata$ModCode, sep=".")
    # grab the first occurence of any food id and we'll use that to construct the tree 
    # note that SuperTracker has duplicate names for each Food ID (important for mapping, but not for the actual tree)
    if(dedupe) fdata <- fdata[!duplicated(fdata$FoodID),]

    # write everything out so that we have it for reference
    write.table(fdata, output_fn, sep = "\t", quote = FALSE, row.names = FALSE)
}
