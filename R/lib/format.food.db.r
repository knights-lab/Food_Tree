# deduplicates database file, replaces special chars with _ and creates a new FoodID out of foodcode and modcode
# to be used as a filtering step prior to creating a food tree
format.food.db <- function(raw_database_fn, output_fn)
{
    fdata <- read.table(raw_database_fn, header = TRUE, sep="\t", colClasses="character", quote="", strip.white=T)
    fdata$Old.Main.food.description <- fdata$Main.food.description
    # replace anything that isn't a number or character with an underscore (format for QIIME)
    fdata$Main.food.description <- gsub("[^[:alnum:]]+", "_", fdata$Main.food.description)
    
    if(sum(colnames(fdata) == "Mod.code")==0) # if no Mod.code column, then add a default 0
        fdata$Mod.code <- rep("0", nrow(fdata))
        
    # make a new food id that also uses the mod.code 
    fdata$FoodID <- paste(fdata$Food.code, fdata$Mod.code, sep=".")
    # grab the first occurence of any food id and we'll use that to construct the tree 
    # note that SuperTracker has duplicate names for each Food ID (important for mapping, but not for the actual tree)
    fdata <- fdata[!duplicated(fdata$FoodID),]

    # write everything out so that we have it for reference
    write.table(fdata, output_fn, sep = "\t", quote = FALSE, row.names = FALSE)
}
