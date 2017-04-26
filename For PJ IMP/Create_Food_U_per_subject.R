# Need to run the clean_diet_data.R program first.

# TODO generate a food unit/otu table for each day (not just each person) and feed into QIIME/ do to do beta-diversity
# Also want to consider doing a per/kcal basis of the food so we are representing it proportionally to total energy consumed

# Goal is to create a FOOD UNITS table similar in structure to an OTU table
# Rows will be subjects
# Columns will be UDSA FoodCodes

# Need to have data.frame "Items" loaded from Clean_diet_data.R
library(reshape2)
library(tibble)
library(biom)
library(vegan)
library(ggplot2)
library(tidyr)
library(stringr)
library(dplyr)

# NOTE it's important to load dplyr at the end, otherwise the comands wont work properly
 

# This creates a food unit table for the entire study period (17 days)
# To look at a specific day, add filter(RecordDayNo == "day")

FU_subject <- Items.new.with.mapping %>% 
  select(X.SampleID, FoodCode, FoodAmt) %>% 
  group_by(X.SampleID, FoodCode) %>%
  summarize(total = sum(FoodAmt))

FU_subject$FoodCode <- as.character(FU_subject$FoodCode)

FU_subject <- FU_subject %>% spread(FoodCode, total, fill = 0)  #fills the matrix with the total amount of the food consumed (in grams)


FU_subject <- remove_rownames(FU_subject)
                                    
FU_subject <- column_to_rownames(FU_subject, var="X.SampleID")

FU_subject <- FU_subject %>% ungroup()

FU_subject <- FU_subject %>% select(-contains("94")) # removes water codes from the data.frame (since this was poorly reported)


# TODO is it possible to simply divide by total kcal per item to account for low-calorie drinks?

FU_subject <- as.data.frame(t(FU_subject))


### DO NOT USE SWEEP IF YOU WANT TO USE THIS IN QIIME! 
## NEED THE COUNTS! 


#FU.sweep <- FU %>% sweep(.,2, colSums(.), "/")


FU_subject <- rownames_to_column(FU_subject, var = "Food.code")
#FU_subject$Food_code <- as.numeric(FU_subject$Food.code)



# Import the table "export" unless you run the food.codes.r script first to remake the tree
food.taxonomy <- read.table("/Users/abby/Documents/Projects/Food_Tree/R/data/food_taxonomy.txt", 
                     sep = "\t", 
                     header = TRUE, quote = "")

food.taxonomy$Food.code <- as.character(food.taxonomy$Food.code)

FU_subject <- inner_join(FU_subject, food.taxonomy, by = "Food.code")


#FU.sweep <- inner_join(FU.sweep, food.description, by = "Food.code")

colnames(FU_subject)[1] <- "#FOODID"
colnames(FU_subject)[582]<-"taxa"

FU.subject.OTU <- FU_subject %>% select(-taxa, -Description)
FU.subject.just.taxonomy <- FU_subject %>% select(1, taxa) # not currently printed, but here if needed


# Make a taxa table that just has the food description as the OTUID

FU.subject.Taxa.table <- FU_subject %>% select(Description, everything())
FU.subject.Taxa.table <- FU.subject.Taxa.table %>% select(-2, -taxa)


# Export as txt files to use in QIIME
write.table(FU.subject.OTU, "/Users/abby/Documents/Projects/MCTs/Data/Diet_Qiime/MCTs_subject_FU.txt", sep = "\t", row.names = FALSE, quote = FALSE)
write.table(FU.subject.just.taxonomy, "/Users/abby/Documents/Projects/MCTs/Data/Diet_Qiime/MCTs_subject_FU_taxonomy.txt", sep="\t", row.names = FALSE, quote = FALSE)
write.table(FU_subject, "/Users/abby/Documents/Projects/MCTs/Data/Diet_Qiime/MCT_subject_FUs_and_taxonomy.txt", sep="\t", row.names = FALSE, quote = FALSE)
write.table(FU.subject.Taxa.table, "/Users/abby/Documents/Projects/MCTs/Data/Diet_Qiime/MCTs_subject_FU_taxa_table.txt", sep="\t", row.names = FALSE, quote = FALSE)

