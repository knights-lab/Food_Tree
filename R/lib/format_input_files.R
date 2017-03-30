# Create the correctly formatted input file to use for making the food tree
 # - should only have to run this once on the starting file
 # - Input is a text file that contains columns with extra characters that need to be newick friendly
 # - Output is a text file with newick friendly text strings


format.file <- function(filename, columns, outdir)
{
  data0 <- read.table(filename, 
                      sep = "\t", 
                      header = TRUE,
                      quote = "")
  
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
    
    # Replace spaces with underscores
    data0[,col]<- gsub(' ','_', data0[,col])
    
  }
  
  # write out to file
  write.table(data0, file=paste(outdir,"data0.txt",sep="/"), sep = "\t", quote = FALSE, row.names = FALSE)
  

}

format.file(filename = "Documents/Projects/FoodTree/Food_Tree/data/Coding Scheme.txt", 
            columns = "name", 
            outdir = "Documents/Projects/Food_Tree/R/data/") 

