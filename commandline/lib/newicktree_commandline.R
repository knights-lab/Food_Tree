#!/usr/bin/env Rscript

suppressPackageStartupMessages(require("data.tree"))

usage = 'Creates a Node Object, input in a node-based tree, output is a Newick file formatted character vector'

option_list = list(
  make_option(c('-i', '--input'),
              help = 'Node based tree with path variables',
              default=NA, type = 'character'),
  make_option(c('-o', '--output'),
              help = 'Newick file formatted character vector',
              default=NA, type = 'character')
)

opt <- parse_args(OptionParser(usage=usage, option_list=option_list))

if (is.na(opt$input) | is.na(opt$output)) {
  stop('Missing parameters')
}

input <- opt$input
output <- opt$output

# Based on Input node, recursively generate Newick Tree
recursiveNewickWrite <- function(node)
{
  # If Node has no children, just return its name and distance value
  if(length(node$children)==0) {
    dist<-distance()
    return (sprintf("%s:%.1f", node$name, dist))
  }else{
    # Set current node as "internal", Get Children of Node and apply fn recursiveNewickWrite
    dist<-distance()
    # Result Format example : (  result from child nodes, separated by commas ) CurrentNode$name:1.0
    return (sprintf("(%s)%s:%.1f", paste(vapply(node$children, recursiveNewickWrite, FUN.VALUE = character(1)), collapse=", "), node$name, dist))
    
  }
}

# Generate Newick Format WITHOUT internal nodes 
recursiveNewickWrite2 <- function(node)
{
  # If Node has no children, just return its name and distance value
  if(length(node$children)==0) {
    dist<-distance()
    return (sprintf("%s:%.1f", node$name, dist))
  }else{
    # Set current node as "internal", Get Children of Node and apply fn recursiveNewickWrite
    dist<-distance()
    # Result Format example : (  result from child nodes, separated by commas ) CurrentNode$name:1.0
    return (sprintf("(%s)", paste(vapply(node$children, recursiveNewickWrite2, FUN.VALUE = character(1)), collapse=", ")))
    
  }
}

#Distance Function for Tree, tbd
distance<-function()
{
  return (1.0)
}