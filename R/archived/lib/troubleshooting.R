# check to see what items from the tree don't match up with the MCT data

items <- read.table("/Users/abby/Documents/Projects/MCTs/Data/All Diet Data/Items_to_use.txt", 
           sep = "\t", 
           header = TRUE,
           comment = "",
           quote = "")

# Check to see if there are any foodcodes in the ASA24 output that are not in the main.join df from food.codes.r

asa.codes <- items %>% select(FoodCode, Food_Description) %>% unique()
tree.codes <- main.join %>% select(Food.code) %>% unique()

colnames(asa.codes) <- c("Food.code", "Description")

# work out which items from the MCT study data are not included in the tree file 
tree.missing <- anti_join(asa.codes, tree.codes)

class(tree.missing$Food.code)

# drop the code 9 which represents missing, not the main category of foods.
tree.missing <- tree.missing %>% filter(Food.code != 9)

# we are missing 25 food variables from the tree file
# these variables are in tree.missing and need to be added to the precursor file for the tree


# We need to eventually write some code that will automatically add these missing food variables to the tree file
# For now I will do this manually

write.table(tree.missing, "/Users/abby/Documents/Projects/Food_Tree/raw data/MCTs_study_missing_variables.txt",
            sep = "\t",
            col.names = T,
            row.names = F,
            quote = F)