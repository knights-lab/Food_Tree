README for creating food trees

PREREQUISITES
1. All input files must be tab-delimited and should be preprocessed to remove all double quotes
2. Raw food database files must contain:
        Foodcode
        Modcode
        Main.food.description
3. Formatted food database files (including supplemental additional foods) to be used to construct tree must contain at least:
        FoodID
        Main.food.description
4. Diet records must have at least:
        Foodcode
        Modcode

USAGE
    see /bin/make.supertracker.tree.r
    and /bin/make.mct.tree.r