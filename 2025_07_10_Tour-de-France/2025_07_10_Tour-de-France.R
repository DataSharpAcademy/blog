library(stringr)
library(readr)

setwd('/Users/palaeosaurus/DataSharp/blog/2025_07_10_Tour-de-France')

##tours <- read.csv('./data/tdf_tours.csv', encoding='ISO8859-1')
tours <- readr::read_csv('./data/tdf_tours.csv', locale=readr::locale(encoding="latin1"))

##- First thing to talk about, loading the data.
stages <- read.csv('./data/tdf_stages.csv')
head(stages)
##- We can see that some columns contains 2 types of information, none of which usable.
##- The dates are also tough to use.

finishers <- read.csv('./data/tdf_finishers.csv')
##- Lots of NA in Team
##- Time is always relative to the winner. Maybe it would be better to convert in absolute times?



### How many unique stage winners?
print(length(unique(stages$Winner)))

### How many unique tour winners?
##- Need to subset before counting
finishers[finishers$Rank ==1, ]
print(length(unique(finishers[finishers$Rank ==1, "Rider"])))

### How many tour winners never won a stage

l <- unique(finishers[finishers$Rank ==1, "Rider"])
l[! l %in% unique(stages$Winner)]

##- Hum, it seems that 5 riders won the Tour without never winner a stage.
##- Is that even correct?
##- Luckily there are only five names and we can investigate one by one.

sort(table(finishers[finishers$Rank ==1, "Rider"]))
##- Chris Froome won 3 tours without a single stage?!
##- Luckiest man alive, or something is off here.

##- The usual suspect: a typo / difference in name writing between the two tables we compared
##- Let's search for a subset of the name 'Chris Froome (UK)', 'Froome'
##- Introduction of the

str_detect(unique(stages$Winner), 'Froome')
unique(stages$Winner)[str_detect(unique(stages$Winner), 'Froome')]

At the end of the day 'Chris Froome (GBR)' won 3 tour de france and many stages, while 'Chris Froome (UK)' won the Tour and no stages. Typical example of improper data that leads to false conclusions.

##- What about the other 4 Tour winners without stages?
unique(stages$Winner)[str_detect(unique(stages$Winner), 'Cornet')]
unique(stages$Winner)[str_detect(unique(stages$Winner), 'Waele')]
unique(stages$Winner)[str_detect(tolower(unique(stages$Winner)), tolower('Waele'))]
unique(stages$Winner)[str_detect(tolower(unique(stages$Winner)), tolower('henri'))]

unique(stages$Winner)[str_detect(unique(stages$Winner), 'Walkowiak')]
unique(stages$Winner)[str_detect(tolower(unique(stages$Winner)), tolower('roger'))]

unique(stages$Winner)[str_detect(unique(stages$Winner), 'Bernal')]

## ==> 3 riders won the Tour without ever winning a Tour de France stage (although Egan Bernal is still active and may well repair this oddity)


### Trickier question, how many riders won the Tour de France without winning the stage _that year_.
##- The problem does not involve compiling two lists and comparing them anymore. We need to link stage wins with Tour wins.

##- Introduction to merging data frames.
##- We need to link tour wins with stage wins by year_
==> The common denominator between the two tables: Year
While we should have the same values in the two tables, it never hurts to check!
How can we check if two vectors have all their elements in common?

all(sort(tours$Year) == sort(unique(stages$Year)))

stage_finish <- merge(stages, finishers[finishers$Rank ==1, ], by='Year')


unique(stage_finish[stage_finish$Winner == stage_finish$Rider, "Rider"])
58 of the 66 tour winners have also won a stage the year they won the tour.
+ Froome (making 65 tour winners) + Maurice de Waele (making 59)

stage_finish[stage_finish$Rider == "Chris Froome (UK)", ] ## Yes he won
stage_finish[stage_finish$Rider == "Maurice De Waele (BEL)", ] ## Yes he won

so 59 out of 65 winners.














Few individuals share the record of the number of Tour de France wins. Among these, who has riden the most to get thoese victories.
If we pretend the most Tour wins is 8 (it is not!), I want to know the cumulated distance across these 8 tours.

The problem must be decomposed
1. identify the most wins
2. Identify who won that many times
3. How many km each win brings (process tours table)
4. Sum across victories


## HOw many wins is the max?

max_wins <- max(table(finishers[finishers$Rank ==1, "Rider"]))
max_winners <- table(finishers[finishers$Rank ==1, "Rider"])[table(finishers[finishers$Rank ==1, "Rider"]) == max_wins]

4 riders share the maximum number of tour victories -- but who rode the most to get these 5 wins?!

The tours table contains some overall distances, but the information is buried
head(tours)

The 'Distance' column is encided as character -- so we need to extract what we want from it.

dist_clean <- gsub("[^[:alnum:][:blank:]?&/\\-\\.]", "", tours$Distance)
dist_clean <- stringr::str_split(dist_clean, 'km', simplify=TRUE)[, 1]

# "[^[:alnum:][:blank:]?&/\\-]"
# This grammar means: remove everything but:
# [:alnum:] Alphanumeric characters: 0-9 a-Z
# [:blank:] spaces and tabs
# ?&/\\- Specific characters you want to save for some reason. Punctuation signs can be saved here

tours$Distance_clean_km <- as.numeric(dist_clean)



all_dtst <- merge(stage_finish[stage_finish$Rider %in% names(max_winners), ], tours, by='Year')
all_dtst <- unique(all_dtst[, c('Year', 'Rider', 'Distance_clean_km')])

sort(tapply(all_dtst$Distance_clean_km, all_dtst$Rider, sum))

##-;
