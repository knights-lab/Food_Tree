library(Hmisc)
library(dplyr)

setwd(dir = "/Users/abby/Documents/Projects/Food_Tree/R/")

# read in SAS data for 2011-2012 dietary intake
food1 <- sasxport.get("data/NHANES/DR1IFF_G.XPT")
food2 <- sasxport.get("data/NHANES/DR2IFF_G.XPT")
tots1 <- sasxport.get("data/NHANES/DR1TOT_G.XPT")
tots2 <- sasxport.get("data/NHANES/DR2TOT_G.XPT")
demo <- sasxport.get("data/NHANES/DEMO_G.XPT")
adults <- demo[demo$ridageyr >= 18,]

# read in food description files
foodcodes <- sasxport.get("data/NHANES/DRXFCD_G.XPT")
modcodes <- sasxport.get("data/NHANES/DRXMCD_G.XPT")


# Quality filtering
# did the food recall meet the minimum criteria to be considered reliable?
food1 <- food1[food1$dr1drstz == 1,] # this drops people with unreliable records and breastfed children
food2 <- food2[food2$dr2drstz == 1,]


# Naming notes
# food codes: "dr1ifdcd" 
# mod codes: "dr1mc"
# weight in grams: "dr1igrms"

# fix nameing for downstream food tree use
names(food1)[names(food1) == "dr1ifdcd"] <- "FoodCode"
names(food2)[names(food2) == "dr2ifdcd"] <- "FoodCode"
names(food1)[names(food1) == "dr1mc"] <- "ModCode"
names(food2)[names(food2) == "dr2mc"] <- "ModCode"
names(food1)[names(food1) == "dr1igrms"] <- "FoodAmt"
names(food2)[names(food2) == "dr2igrms"] <- "FoodAmt"
names(foodcodes)[names(foodcodes) == "drxfdcd"] <- "FoodCode"
names(foodcodes)[names(foodcodes) == "drxfcld"] <- "Main.food.description"
names(modcodes)[names(modcodes) == "drxmc"] <- "ModCode" 

foodcodes$FoodCode <- as.factor(foodcodes$FoodCode)
modcodes$ModCode <- as.factor(modcodes$ModCode)

## add main food description/or mod code to the raw data
#food1
food1$FoodCode <- as.factor(food1$FoodCode)
food1$ModCode <- as.factor(food1$ModCode)
food1 <- left_join(food1, foodcodes, by = "FoodCode")
food1 <- left_join(food1, modcodes, by = "ModCode")
# replace names
food1$Main.food.description <- ifelse(is.na(food1$drxmcd), food1$Main.food.description, food1$drxmcd)

#food2
food2$FoodCode <- as.factor(food2$FoodCode)
food2$ModCode <- as.factor(food2$ModCode)
food2 <- left_join(food2, foodcodes, by = "FoodCode")
food2 <- left_join(food2, modcodes, by = "ModCode")
# replace names
food2$Main.food.description <- ifelse(is.na(food2$drxmcd), food2$Main.food.description, food2$drxmcd)


# subset to just people in both food1 and food2
food1names <- unique(food1$seqn)
food2names <- unique(food2$seqn)
keepnames <- food1names[food1names %in% food2names]
keepnames_adults <- keepnames[keepnames %in% adults$seqn]

# subset to just the variables we need for food tree
food1 <- food1 %>% select(seqn, FoodCode, ModCode, FoodAmt, Main.food.description)
food2 <- food2 %>% select(seqn, FoodCode, ModCode, FoodAmt, Main.food.description)

# make a day varabile before we bind these together
food1$Day = 1
food2$Day = 2

food12 <- rbind(food1, food2)

# limit to just people who have records from day 1 and 2
food12 <- food12[food12$seqn %in% keepnames_adults,]

# look for people with no foods
sum(table(food12$seqn, food12$Day)[,1] == 1) # 2 people with only one food reported
sum(table(food12$seqn, food12$Day)[,2] == 1)  # 7 people with only one food reported


# dietary pattern/special diet map
diet_type_map <- tots1 %>% select(seqn, drqsdiet, drqsdt1, drqsdt2, drqsdt3, drqsdt4, drqsdt5, drqsdt6, drqsdt7, drqsdt8, drqsdt9, drqsdt10, drqsdt11, drqsdt12, drqsdt91)
diet_type_map <- diet_type_map[diet_type_map$seqn %in% keepnames_adults,]

# demographics map
demo <- demo[demo$seqn %in% keepnames_adults,]


# write to text file (tab separated)
write.table(food1, file = "data/NHANES/processed/foodday1.txt", sep = "\t", quote = F, row.names = F)
write.table(food2, file = "data/NHANES/processed/foodday2.txt", sep = "\t", quote = F, row.names = F)
write.table(food12, file = "data/NHANES/processed/foodday1and2.txt", sep = "\t", quote = F, row.names = F)

# database
write.table(foodcodes, file = "data/NHANES/processed/foodcodes.txt", sep = "\t", quote = F, row.names = F)

# write maps
write.table(diet_type_map, file = "data/NHANES/processed/diet_type_map.txt", sep = "\t", quote = F, row.names = F)
write.table(demo, file = "data/NHANES/processed/demo_map.txt", sep = "\t", quote = F, row.names = F)
