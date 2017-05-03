# Make combined mod code and food code for ASA24

main.food.desc <- read.table("../raw data/main.food.desc.txt", sep = "\t", header = T)
mod.codes <- read.table("../raw data/mod.desc.txt", sep = "\t", header = T)

require(dplyr)

main.food.desc <- main.food.desc %>% select(FoodCode, Main.food.description)
main.food.desc$ModCode <- 0

mod.codes <- mod.codes %>% select(FoodCode, Main.food.description, ModCode)

all.food.desc <- rbind(main.food.desc, mod.codes)

write.table(all.food.desc, "../raw data/all.food.desc.txt", sep = "\t", col.names = T, row.names = F, quote = F)
