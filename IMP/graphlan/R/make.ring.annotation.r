require(faraway)

setwd("~/Dropbox/UMN/KnightsLab/Food_Tree/IMP/graphlan")
source("~/Dropbox/UMN/KnightsLab/IMP/ANALYSES/analysis/lib/utils.r")
use.rare=F
source("~/Dropbox/UMN/KnightsLab/IMP/ANALYSES/analysis/bin/load.r")

use.L3 = TRUE

food.taxonomy <- read.table("~/Dropbox/UMN/KnightsLab/Food_Tree/R/output/supertracker.taxonomy.foodsreportedonly.txt", header=T, sep="\t", colClasses="character")
nutrients <- read.table("~/Dropbox/UMN/KnightsLab/Food_Tree/IMP/generate_meals_nutrients/meals_nutrients.txt", header=T, sep="\t", check.names=F, colClasses="character")
colnames(nutrients) <- gsub(" \\(g\\)", "", colnames(nutrients))
colnames(nutrients) <- gsub(" \\(kcal\\)", "", colnames(nutrients))
colnames(nutrients) <- gsub(" ", ".", colnames(nutrients))

characterCols <- c("FoodID","Diet.ID","Main.food.description","FoodCode","ModCode")
numericCols <- colnames(nutrients)[!(colnames(nutrients) %in% characterCols)]
nutrients[,numericCols] <- apply(nutrients[,numericCols], 1:2, as.numeric)

nutrient.names <- numericCols[numericCols != "FoodAmt"]
nutrient.names <- nutrient.names[nutrient.names != "Energy"] # let's take out Calories for now, too correlated to everything else

if(use.L3) {
    foodnames <- gsub(";L4.+", "", food.taxonomy$taxonomy) # remove everything after
    foodnames <- gsub(".+;L3", "L3", foodnames) #remove everything before
} else {
    foodnames <- gsub(" ", "_", food.taxonomy$Main.food.description) # default aggregate is the most descriptive food name
}
food.taxonomy$foodname <- foodnames

# let's merge the food taxonomy with nutrients to get the full taxonomy list
nutrients <- merge(nutrients, food.taxonomy[,c("FoodID","taxonomy","foodname")], by="FoodID", all.x=TRUE)

# grab cross-sectional IDs only
Hmong2nd <- map_all[hmong_secondgen_cs_all, "Diet.ID"]
Hmong1st <- map_all[hmong_firstgen_cs_all, "Diet.ID"]
Karen1st <- map_all[karen_firstgen_cs_all, "Diet.ID"]
KarenThai <- map_all[karenthai_all, "Diet.ID"]
HmongThai <- map_all[hmongthai_all, "Diet.ID"]
Control <- map_all[controls_all, "Diet.ID"]
sample.list <- list(KarenThai=KarenThai, Karen1st=Karen1st, HmongThai=HmongThai, Hmong1st=Hmong1st, Hmong2nd=Hmong2nd, Control=Control)

# collapse samples into groups
nutrient.group.list <- list()
nutrients.zero <- matrix(rep(0, length(nutrient.names)*length(unique(nutrients$foodname))), ncol=length(nutrient.names))
colnames(nutrients.zero) <- nutrient.names

base.df <- data.frame(foodname = unique(food.taxonomy$foodname), FoodAmt=0, nutrients.zero, stringsAsFactors=F)

for(i in 1:length(sample.list))
{
    group.ix <- nutrients$Diet.ID %in% sample.list[[i]]
    
        # aggregate and divide by number of people in this sample group to get average nutrients
        grouped.nutrients <- aggregate(nutrients[group.ix, c("FoodAmt", nutrient.names)], list(nutrients[group.ix,"foodname"]), function(xx) sum(xx/length(sample.list[[i]])))    
        d <- data.frame(base.df, Group=names(sample.list)[i], stringsAsFactors=F)
        d[d$foodname %in% grouped.nutrients[,1], c("FoodAmt",nutrient.names)] <- grouped.nutrients[, c("FoodAmt",nutrient.names)]
        nutrient.group.list[[names(sample.list)[i]]] <- d

        # aggregate and divide by number of people in this sample group to get average nutrients
#         grouped.nutrients <- aggregate(nutrients[group.ix, c("FoodAmt", nutrient.names)], list(nutrients[group.ix,"FoodID"]), function(xx) sum(xx/length(sample.list[[i]])))    
#         d <- data.frame(base.df, Group=names(sample.list)[i], stringsAsFactors=F)
#         d[d$FoodID %in% grouped.nutrients[,1], c("FoodAmt",nutrient.names)] <- grouped.nutrients[, c("FoodAmt",nutrient.names)]
#         nutrient.group.list[[names(sample.list)[i]]] <- d
}

# color rings by nutrients
# cols <- c("#ba1e12", "#FDCF47","#e98000", "#49274a", "#008f95", "#538527")
# names(cols) <- nutrient.names # protein red ##ba1e12, fat yellow #FDCF47 , carbs orange #e98000, calories purple #49274a, sugars blue #008f95, fiber green #538527

cols <- c("#ba1e12", "#fe6219","#49274a","#008f95", "#1d3c02")
names(cols) <- nutrient.names # protein red ##ba1e12, fat orange #fe6219, carbs purple #49274a, sugars blue #008f95, fiber green #1d3c02


for(i in 1:length(sample.list)) # for each sample group
{
    final.df <- NULL
    this.group.name <- names(sample.list)[i]
    this.samples <- sample.list[[this.group.name]]
    this.nutrient.df <- nutrient.group.list[[this.group.name]]
    
    for(j in 1:length(nutrient.names)) # make a ring for each nutrient
    {
        this.nutrient.name <- nutrient.names[j]

        # use [[ ]] to avoid warnings from name being returned in the cols
        ring.color.df <- data.frame(foodname=this.nutrient.df$foodname, ring_option="ring_color", ring_level=j, ring_option_value=cols[[this.nutrient.name]], stringsAsFactors=F) 
                
        ring.alpha.df <- data.frame(foodname=this.nutrient.df$foodname, ring_option="ring_alpha", ring_level=j, ring_option_value=this.nutrient.df[,this.nutrient.name], stringsAsFactors=F) 

        ring.params <-  data.frame(foodname="", 
                        ring_option=c("ring_label", "ring_label_color", "ring_external_separator_thickness", "ring_separator_color", "ring_label_font_size"), 
                        ring_level = j, 
                        ring_option_value=c(this.nutrient.name, cols[[this.nutrient.name]], "0.5", "#888888", "7"), 
                        stringsAsFactors=F)
                                 
        final.df <- rbind(final.df, ring.color.df, ring.alpha.df, ring.params)    
    }

    # let's rescale the average grams of this nutrient consumed in this group by min/max of all nutrients consumed so that the gradients in color make more sense
    final.alpha.df <- final.df[final.df$ring_option=="ring_alpha",]
    alpha.val <- as.numeric(final.alpha.df$ring_option_value)
    valid.ix <- 1:length(alpha.val)
    if(this.group.name != "Control") # remove RICE from all non-Control groups so the scaling looks a little better
    {
        # let's just set rice to alpha val == 1.0, and remove it from any scaling
        
        rice.ix <- which(final.alpha.df$foodname=="L3_Cooked_cereals_rice") #  "Rice_white_cooked_no_salt_or_fat_added_")
        valid.ix <- valid.ix[-rice.ix]
    }
    alpha.val[valid.ix] <- sqrt(sqrt(alpha.val[valid.ix])) # double sqrt to bring out the low values        
    alpha.val[valid.ix] <- (alpha.val[valid.ix] - min(alpha.val[valid.ix]))/(max(alpha.val[valid.ix])-min(alpha.val[valid.ix])) # rescale 0-1 for required alpha value 

    final.alpha.df[valid.ix,"ring_option_value"] <- sprintf("%.3f", alpha.val[valid.ix])
    if(this.group.name != "Control") final.alpha.df[rice.ix,"ring_option_value"] <- sprintf("%.3f", 1)
        
    final.df[final.df$ring_option=="ring_alpha","ring_option_value"] <- final.alpha.df["ring_option_value"]


    # specify an even outer ring to show histogram of total average consumption of foods
    outer.color.df <-  data.frame(foodname=this.nutrient.df$foodname, 
                        ring_option=c("ring_color"), 
                        ring_level = j+1, 
                        ring_option_value=c("black"), 
                        stringsAsFactors=F)
    food.amt <- this.nutrient.df[,"FoodAmt"]
    food.amt <- sqrt(sqrt(food.amt))
    food.amt <- (food.amt - min(food.amt))/(max(food.amt)-min(food.amt)) # rescale 0-1
    food.amt <- food.amt * 2 # multiply to make it larger
    outer.height.df <-  data.frame(foodname=this.nutrient.df$foodname, 
                        ring_option=c("ring_height"), 
                        ring_level = j+1, 
                        ring_option_value=food.amt, 
                        stringsAsFactors=F)
                        
    final.df <- rbind(final.df, outer.color.df, outer.height.df)
    
    final.df$foodname <- gsub(";", ".", final.df$foodname)
    
    outfile <- paste0("~/Dropbox/UMN/KnightsLab/Food_Tree/IMP/graphlan/annotations/", this.group.name, ".annotation.txt")
    cat(paste0("title\t", this.group.name, "\n"), file=outfile)
    write.table(final.df, outfile, sep="\t", quote=F, row.names=F, col.names=F, append=TRUE)

}
 
