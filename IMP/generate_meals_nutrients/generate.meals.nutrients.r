# this script adds the list of favorite foods nutrients to the current database of food nutrients, and composes a final diet record that also contains all nutrients of each food, per person per day

# manually check spelling etc between fave foods list from supertracker and curated sheet
    fave.foods <- read.table("/Users/pvangay/Dropbox/UMN/KnightsLab/Food_Tree/IMP/generate_meals_nutrients/favorite foods nutrients - raw.txt", head=TRUE, sep="\t", strip.white=T, colClasses="character", check.names=F)

    # replace all special chars
    fave.foods$Main.food.description <- gsub("[^[:alnum:]]+", "_", fave.foods[,"Food Name"])
    # separate out portion from amount

    portionsplit <- regmatches(fave.foods[,"Food Portion"], regexpr(" ", fave.foods[,"Food Portion"]), invert = TRUE)

    d <- data.frame(matrix(unlist(portionsplit), nrow=length(portionsplit), byrow=T), stringsAsFactors=FALSE)
    colnames(d) <- c("Amount", "Portion")
    d$Amount[d$Amount == "1/2"] <- .5
    d$Amount[d$Amount == "3/2"] <- 3/2
    d$Amount[d$Amount == "1/8"] <- 1/8
    d$Amount[d$Amount == "1/4"] <- 1/4
    d$Amount[d$Amount == "5/4"] <- 5/4
    d$Amount <- as.numeric(d$Amount)

    favefoods_nutrients <- data.frame(fave.foods, d, check.names=F)

    new.foods <- read.table("/Users/pvangay/Dropbox/UMN/KnightsLab/Food_Tree/raw data/original_imp.missing.foods.txt", head=TRUE, sep="\t", strip.white=T, colClasses="character", check.names=F)
    new.foods$ModCode[new.foods$ModCode == ""] <- "0"
    new.foods$FoodID <- paste(new.foods$FoodCode, new.foods$ModCode, sep=".")

    missing <- new.foods$Main.food.description[!(new.foods$Main.food.description %in% favefoods_nutrients$Main.food.description)]
    #sort(missing)
    # at this point manually edit the fave.foods names with search/replace in text file so that it matches new.foods because this is what is in the diets

    # edit the portions 
    #missing.portions <- unique(favefoods_nutrients$Portion)[!(unique(favefoods_nutrients$Portion) %in% unique(new.foods$Portion))]
    old.portions <- c("oz", "cups","package"," tablespoon","a churro","g","fl oz","lean cuisine meal","pizza","serving","roll","stick","eggroll")
    new.portions <- c("ounce(s)", "cup", "package (3 oz), prepared", "tablespoon", "portion", "portion", "mug (8 fl oz)", "lean cuisine meal",
        "pizza", "serving", "egg roll", "stick", "egg roll")
    for(i in 1:length(old.portions))  favefoods_nutrients$Portion[favefoods_nutrients$Portion == old.portions[i]] <- new.portions[i]
    
    colnames(favefoods_nutrients)[2] <- "Old.Food.Portion"
    colnames(favefoods_nutrients)[which(colnames(favefoods_nutrients) == "Amount")] <- "FoodAmt" # so it matches other tables

# at this point, we want to check that all foods in diet all have nutrients
    # load diets
    food_records_fn <- "/Users/pvangay/Dropbox/UMN/KnightsLab/Food_Tree/R/data/IMP/dietrecords.txt" # already formatted, NAs corrected by add.missing.foods.to.diets
    food_records <- read.table(food_records_fn, header = TRUE, sep="\t", colClasses="character", quote="", strip.white=T)

    # load current nutrients database
    supertracker_db_nutrients_fn <- "/Users/pvangay/Dropbox/UMN/KnightsLab/Food_Tree/IMP/generate_meals_nutrients/SuperTracker Database - Nutrients.txt"    
    db_nutrients <- read.table(supertracker_db_nutrients_fn, header = TRUE, sep="\t", colClasses="character", quote="", strip.white=T, check.names=F)
    db_nutrients$Main.food.description <- gsub("[^[:alnum:]]+", "_", db_nutrients[,"Food Name"])
    db_nutrients$FoodID <- paste(db_nutrients$FoodCode, db_nutrients$ModCode, sep=".")
    

    # check that all foods in food_records are found in either db_nutrients or favefoods_nutrients
    # need to check based on IDs against database
    missing.from.db <- food_records[!(food_records$FoodID %in% db_nutrients$FoodID), c("FoodID", "Main.food.description")]
    
    missing.from.favefoods <- missing.from.db[!(missing.from.db$Main.food.description %in% favefoods_nutrients$Main.food.description),]
####### missing.from.favefoods should be empty!
    
    # let's only grab food IDs from our custom nutrient list for those that are missing.from.db
    missing.from.db <- unique(missing.from.db)
    addl_foods_sub <- new.foods[new.foods$Main.food.description %in% missing.from.db$Main.food.description,]
    # check that all foods and all portions are accounted for
    diffs <- addl_foods_sub[!(paste(addl_foods_sub[,1], addl_foods_sub[,2],sep="-") %in% paste(favefoods_nutrients[,"Main.food.description"], favefoods_nutrients[,"Portion"],sep="-")),]
####### diffs should also be empty!!
    
    addl_foods_nutrients <- merge(addl_foods_sub, favefoods_nutrients, by=c("Main.food.description","Portion"))

    write.table(addl_foods_nutrients, file="/Users/pvangay/Dropbox/UMN/KnightsLab/Food_Tree/IMP/generate_meals_nutrients/favorite foods nutrients - formatted.txt", sep="\t", row.names=F, quote=F)

    # now let's match up all of the names so that they're identical
    colnames(addl_foods_nutrients)[which(colnames(addl_foods_nutrients) == "Dietary Fiber (g)")] <- "Total Dietary Fiber (g)"
    colnames(addl_foods_nutrients)[which(colnames(addl_foods_nutrients) == "Total Calories")] <- "Energy (kcal)"
    
    valid_cols <- intersect(colnames(db_nutrients), colnames(addl_foods_nutrients))
    # reorder a bit
    valid_cols <- valid_cols[c(length(valid_cols),(length(valid_cols)-1),1:(length(valid_cols)-2))]
    valid_nutrients <- valid_cols[6:length(valid_cols)]

    # at this point, addl_foods_nutrients are given as nutrients per portionwgt
    # whereas, db_nutrients are given as nutrients per 100 grams
    # convert this so that their numbers are all consistent per gram
    
    # calculate the nutrients PER GRAM
    addl_foods_nutrients_gram <- addl_foods_nutrients[, c("portionwgt",valid_cols)]
    nutrients_ix <- 7:ncol(addl_foods_nutrients_gram)
    addl_foods_nutrients_gram[,nutrients_ix] <- apply(addl_foods_nutrients_gram[,nutrients_ix], 1:2, as.numeric)
    addl_foods_nutrients_gram$portionwgt <- as.numeric(addl_foods_nutrients_gram$portionwgt)
    addl_foods_nutrients_gram[,nutrients_ix] <- addl_foods_nutrients_gram[,nutrients_ix]/addl_foods_nutrients_gram$portionwgt

    db_nutrients_gram <- db_nutrients[,valid_cols]
    nutrients_ix <- 6:ncol(db_nutrients_gram)
    db_nutrients_gram[,nutrients_ix] <- apply(db_nutrients_gram[,nutrients_ix], 1:2, as.numeric)
    db_nutrients_gram[,nutrients_ix] <- db_nutrients_gram[,nutrients_ix]/100
    
    all_nutrients <- rbind(db_nutrients_gram[,valid_cols], addl_foods_nutrients_gram[,valid_cols])
    # food names : Food ID are N:1 because some names are the same for the same ID. For our purposes, let's remove the duplicates (since addl_foods were added later, it'll keep the 
    # database version)
    all_nutrients <- all_nutrients[!duplicated(all_nutrients$FoodID),] 
    
    # all diet records also already have each food and their respective weights in grams (including missing foods)! So simply do:
    # aggregate all food records by subject and FoodID (sum up how much of "rice" someone ate for a total day, in grams)    
    # lump all foods eaten per person per day --> use Diet.ID
    food_records_grouped <- aggregate(as.numeric(as.character(food_records$FoodAmt)), list(Diet.ID=food_records$Diet.ID, FoodID=food_records$FoodID), sum)
    colnames(food_records_grouped)[3] <- "FoodAmt" # total grams of this food eaten by this person-day

    # take grams of each food per subject and multiply by (all_nutrients / 100) to get total nutrients for that food for that subject    
    food_records_nutrients <- merge(food_records_grouped, all_nutrients, by="FoodID", all.x=TRUE) # not multiplied yet        
    food_records_nutrients[,valid_nutrients] <- food_records_nutrients$FoodAmt * food_records_nutrients[,valid_nutrients]
    
    # let's not write out the Food Name because it contains too many special characters
    write.table(food_records_nutrients[,-which(colnames(food_records_nutrients)=="Food Name")], file="/Users/pvangay/Dropbox/UMN/KnightsLab/Food_Tree/IMP/generate_meals_nutrients/meals_nutrients.txt", sep="\t", row.names=F, quote=F)
        
        
        
        
        
        
    