#!/usr/bin/env Rscript

#chmod +x attempt_formatfoods.R

#probably delete this later
#input_fn <- read.table('~/GitHubnotZip/GitHub/Food_Tree/R/data/NHANES/processed/foodcodes.txt', fill = TRUE)

#load all the necessary packages (call the ones that are already downloaded and download the ones that haven't been yet)
#load packages needed for format foods
suppressPackageStartupMessages(require(optparse))

#usage will pop up to help the person, get the info for this from the README for Food Tree
usage = 'Used to format the food file inputted by the user.'

#make option list 
#To do: find characteristics "type" of data input (ex: numeric vs. character)
option_list = list(
  make_option(c('-i', '--input_fn'),
              help= 'Necessary: food table to be formatted', 
              default=NA, type='character'),
  make_option(c('-o', '--output_fn'),
              help = 'Necessary: direct location of output file',
              default=NA, type='character')
)

#this line is present in splinectomer and I'm not sure what it does
opt = parse_args(OptionParser(usage=usage, option_list=option_list))

if (is.na(opt$input_fn)) {
  stop('Missing data to be formatted')
}

input_fn = opt$input_fn
output_fn = opt$output_fn

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

