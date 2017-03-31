# Code to make a new text file containing your new variables of interest
# These variables will eventually be incorporated into the food tree 
# The food codes assigned should allign with appropriate category in the USDA naming scheme
# Always check the existing database first to make sure your code doesn't alreay map to something else

# Function expects a list of food codes and descriptions
# outdir should contain the complete path and name of the output file
# Use underscores instead of spaces when entering food descriptions

add_new_foodcode <- function(codes, descriptions, outdir)
{
  foodcode <- codes
  names <- descriptions
  
  df <- data.frame(foodcode, names)
  
  colnames(df) <- c("foodcodes", "descriptions")
  
  write.table(df, file = outdir, sep = "\t", quote = FALSE, row.names = FALSE)
}

# add_new_foodcode(codes = c(95120051, 95120053, 95120052, 95120054), 
#                  descriptions = c("Soylent_Original", "Soylent_Cacoa", "Soylent_Nectar", "Soylent_Coffiest"),
#                  outdir = "Documents/Projects/Food_Tree/R/data/NewSoylentFoodCodes.txt")

