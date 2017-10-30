# generate files for food otu stuff

biom convert -i imp.food.otu.txt -o imp.food.otu.biom --table-type "OTU table" --to-json --process-obs-metadata "taxonomy"

summarize_taxa.py -i imp.food.otu.biom -o taxa

beta_diversity.py -i imp.food.otu.biom -o beta -m unweighted_unifrac,weighted_unifrac,bray_curtis,euclidean -t supertracker.tree.txt 



# foods reported only

biom convert -i imp.food.otu.foodsreportedonly.txt -o imp.foodseaten.otu.biom --table-type "OTU table" --to-json --process-obs-metadata "taxonomy"

summarize_taxa.py -i imp.foodseaten.otu.biom -o taxa

beta_diversity.py -i imp.foodseaten.otu.biom -o beta -m unweighted_unifrac,weighted_unifrac,bray_curtis,euclidean -t supertracker.tree.foodsreportedonly.txt 

