# Collect & organize player first-half stats (2018)

library(data.table)
library(dplyr)
library(gtools)
library(lubridate)
library(reshape2)
library(stringr)

firsthalf <- fread('.\\data\\fangraphs_scraped_2018.csv')

# Team's league
firsthalf$league <- NA
firsthalf$league <- ifelse(firsthalf$team %in% c('Angels', 'Athletics', 'Blue Jays', 'Devil Rays', 'Indians', 
                                                 'Mariners', 'Orioles', 'Rangers', 'Rays', 'Red Sox', 'Royals', 
                                                 'Tigers', 'Twins', 'White Sox', 'Yankees'), 'AL', firsthalf$league)
firsthalf$league <- ifelse(firsthalf$team %in% c('Braves', 'Brewers', 'Cardinals', 'Cubs', 'Diamondbacks', 
                                                 'Dodgers', 'Expos', 'Giants', 'Marlins', 'Mets', 'Nationals', 
                                                 'Padres', 'Phillies', 'Pirates', 'Reds', 'Rockies'), 'NL', firsthalf$league)
firsthalf$league <- ifelse(firsthalf$team != 'Astros', firsthalf$league, ifelse(firsthalf$year<=2012, 'NL', 'AL'))
firsthalf$league <- ifelse(firsthalf$team != 'Brewers', firsthalf$league, ifelse(firsthalf$year<=1997, 'AL', 'NL'))
firsthalf$league_year_ID <- paste0(firsthalf$year, '-', firsthalf$league)

standings <- fread('.\\data\\standings.csv')


# Join & merge with team ASG standings
firsthalf <- firsthalf %>% left_join(standings[,c(9,10,4)], by=c('year'='year', 'team'='team_full_name'))
firsthalf$`W-L%` <- ifelse(is.na(firsthalf$`W-L%`), .500, firsthalf$`W-L%`)
firsthalf$popular <- ifelse(firsthalf$team %in% c('Yankees', 'Red Sox', 'Cubs', 'Dodgers'), 1, 0)
firsthalf$NYY <- ifelse(firsthalf$team == 'Yankees', 1, 0)
firsthalf$BOS <- ifelse(firsthalf$team == 'Red Sox', 1, 0)
firsthalf$CHC <- ifelse(firsthalf$team == 'Cubs', 1, 0)
firsthalf$LAD <- ifelse(firsthalf$team == 'Dodgers', 1, 0)


# Did the team play in the WS in prior year?
ws <- fread('ws.csv')
ws$winner_year_id <- paste0(ws$next_season, '-', ws$winner_name)
ws$loser_year_id <- paste0(ws$next_season, '-', ws$loser_name)
firsthalf$team_year_id <- paste0(firsthalf$year, '-', firsthalf$team)
firsthalf$won_WS_PY <- ifelse(firsthalf$team_year_id %in% ws$winner_year_id, 1, 0)
firsthalf$lost_WS_PY <- ifelse(firsthalf$team_year_id %in% ws$loser_year_id, 1, 0)
firsthalf$played_WS_PY <- firsthalf$won_WS_PY + firsthalf$lost_WS_PY


# Player rank at his position (in his league)
firsthalf <- firsthalf %>% arrange(league_year_ID, position, desc(WAR)) %>% group_by(league_year_ID, position) %>% mutate(rank_WAR= row_number())
firsthalf <- firsthalf %>% arrange(league_year_ID, position, desc(`wRC+`)) %>% group_by(league_year_ID, position) %>% mutate(rank_wRC= row_number())
firsthalf <- firsthalf %>% arrange(league_year_ID, position, desc(OBP)) %>% group_by(league_year_ID, position) %>% mutate(rank_OBP= row_number())
firsthalf <- firsthalf %>% arrange(league_year_ID, position, desc(SLG)) %>% group_by(league_year_ID, position) %>% mutate(rank_SLG= row_number())
firsthalf <- firsthalf %>% arrange(league_year_ID, position, desc(HR)) %>% group_by(league_year_ID, position) %>% mutate(rank_HR= row_number())
firsthalf <- firsthalf %>% arrange(league_year_ID, position, desc(AVG)) %>% group_by(league_year_ID, position) %>% mutate(rank_AVG= row_number())
firsthalf <- firsthalf %>% arrange(league_year_ID, position, desc(Off)) %>% group_by(league_year_ID, position) %>% mutate(rank_Off= row_number())
firsthalf <- firsthalf %>% arrange(league_year_ID, position, desc(Def)) %>% group_by(league_year_ID, position) %>% mutate(rank_Def= row_number())
firsthalf <- firsthalf %>% arrange(league_year_ID, position, desc(SB)) %>% group_by(league_year_ID, position) %>% mutate(rank_SB= row_number())


# Player rank on his team
firsthalf <- firsthalf %>% arrange(team_year_id, desc(WAR)) %>% group_by(team_year_id) %>% mutate(team_rank_WAR = row_number())
firsthalf <- firsthalf %>% arrange(team_year_id, desc(`wRC+`)) %>% group_by(team_year_id) %>% mutate(team_rank_wRC = row_number())
firsthalf <- firsthalf %>% arrange(team_year_id, desc(OBP)) %>% group_by(team_year_id) %>% mutate(team_rank_OBP = row_number())
firsthalf <- firsthalf %>% arrange(team_year_id, desc(SLG)) %>% group_by(team_year_id) %>% mutate(team_rank_SLG = row_number())
firsthalf <- firsthalf %>% arrange(team_year_id, desc(HR)) %>% group_by(team_year_id) %>% mutate(team_rank_HR = row_number())
firsthalf <- firsthalf %>% arrange(team_year_id, desc(AVG)) %>% group_by(team_year_id) %>% mutate(team_rank_AVG = row_number())
firsthalf <- firsthalf %>% arrange(team_year_id, desc(Off)) %>% group_by(team_year_id) %>% mutate(team_rank_Off = row_number())
firsthalf <- firsthalf %>% arrange(team_year_id, desc(Def)) %>% group_by(team_year_id) %>% mutate(team_rank_Def = row_number())
firsthalf <- firsthalf %>% arrange(team_year_id, desc(SB)) %>% group_by(team_year_id) %>% mutate(team_rank_SB = row_number())


write.csv(firsthalf, '.\\data\\firsthalf2018.csv')
