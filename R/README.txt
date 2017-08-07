README for creating food trees

PREREQUISITES
1. All input files must be tab-delimited and should be preprocessed to remove any special characters that will mess up reading in files in R such as:
    "
    '
    &
    #
2. Raw food database files must contain:
        FoodCode
        ModCode
        Main.food.description
3. Formatted food database files (including supplemental additional foods) to be used to construct tree must contain at least:
        FoodID
        Main.food.description
4. Diet records must have at least:
        FoodCode
        ModCode
5. To create fiber.otu table diet records must contain all of the above plus a fiber variable labeled:
        FIBE
6. To create dhydrated food weight diet records must contain all of the above plus:
        MOIS
     

USAGE
    see /bin/make.supertracker.tree.r
    and /bin/make.mct.tree.r
