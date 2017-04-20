# Create the correctly formatted input file to use for making the food tree
 # - should only have to run this once on the starting file
 # - Input is a text file that contains columns with extra characters that need to be newick friendly
 # - Output is a text file with newick friendly text strings for food descriptions
 # - columns is the name of the columns that need to be changed
 # - Output directory must include the .txt file name

format.file <- function(filename, foodcodecolname, columns, outdir)
{
  data0 <- read.table(filename, 
                      sep = "\t", 
                      header = TRUE)
  
  for(i in 1:length(columns))
  {
    col <- columns[i]
    # Formatting column text string to work with newick tree
    
    # Remove any leading or trailing spaces in the food descriptions
    data0[,col]<- gsub("^\\s+|\\s+$", "", data0[,col])
    
    # Remove non-text characters
    data0[,col]<- gsub('[():;,/-]+', "", data0[,col])
    
    # Remove pesky apostropies
    data0[,col]<- gsub("'", '', data0[,col])
    
    # Remove pesky percent symbols
    data0[,col]<-gsub("%", '', data0[,col])
    
    # Replace spaces with underscores
    data0[,col]<- gsub(' ','_', data0[,col])
    
    
  }
  
  data1 <- data0[,c(foodcodecolname, columns)]
  
  
  # write out to file
  write.table(data1, file=outdir, sep = "\t", quote = FALSE, row.names = FALSE)
  

}

# format.file(filename = "Documents/Projects/Food_Tree/raw data/coding.scheme.txt",
#             foodcodecolname = "code",
#              columns = "name",
#              outdir = "Documents/Projects/Food_Tree/R/data/NodeLabels.txt")
# 
# format.file(filename = "Documents/Projects/Food_Tree/raw data/main.food.desc.txt",
#             foodcodecolname = "Food.code",
#             columns = "Main.food.description",
#             outdir = "Documents/Projects/Food_Tree/R/data/MainFoodDesc.txt")
# 
# format.file(filename = "Documents/Projects/Food_Tree/raw data/add.food.desc.txt",
#             foodcodecolname = "Food.code",
#             columns = "Additional.food.description",
#             outdir = "Documents/Projects/Food_Tree/R/data/AddFoodDesc.txt")

# format.file(filename = "/Users/abby/Documents/Projects/Food_Tree/raw data/MCTs_study_missing_variables.txt",
#             foodcodecolname = "Food.code",
#             columns = "Description",
#             outdir = "/Users/abby/Documents/Projects/Food_Tree/R/data/MCTs_study_missing_variables.txt")
