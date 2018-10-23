# Scrape WS winners

library(data.table)
library(dplyr)
library(htmltab)
library(stringr)

ws <- htmltab('http://www.espn.com/mlb/worldseries/history/winners', which=1)
names(ws) <- ws[1,]
ws <- ws[2:nrow(ws),]
ws <- ws %>% 
  filter(SEASON >= 1985)
ws$WINNER <- str_replace_all(ws$WINNER, '( )+', ' ')
ws$LOSER <- str_replace_all(ws$LOSER, '( )+', ' ')

team_abbrvs <- c("Anaheim Angels"="Angels", "Arizona Diamondbacks"="Diamondbacks", "Atlanta Braves"="Braves", "Boston Red Sox"="Red Sox", "Chicago Cubs"="Cubs", "Chicago White Sox"="White Sox", "Cincinnati Reds"="Reds", "Cleveland Indians"="Indians", "Colorado Rockies"="Rockies", "Detroit Tigers"="Tigers", "Florida Marlins"="Marlins", "Houston Astros"="Astros", "Kansas City Royals"="Royals", "Los Angeles Dodgers"="Dodgers", "Minnesota Twins"="Twins", "New York Mets"="Mets", "New York Yankees"="Yankees", "Oakland Athletics"="Athletics", "Philadelphia Phillies"="Phillies", "San Diego Padres"="Padres", "San Francisco Giants"="Giants", "St. Louis Cardinals"="Cardinals", "Tampa Bay Rays"="Rays", "Texas Rangers"="Rangers", "Toronto Blue Jays"="Blue Jays")

ws$unname(team_abbrvs[ws$WINNER])
ws$winner_name <- unname(team_abbrvs[ws$WINNER])
ws$loser_name <- unname(team_abbrvs[ws$LOSER])
ws$next_season <- as.numeric(ws$SEASON) + 1

write.csv(ws, '.\\data\\ws.csv', row.names = F)
