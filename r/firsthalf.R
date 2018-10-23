# Collect & organize player first-half stats

library(data.table)
library(dplyr)
library(gtools)
library(lubridate)
library(reshape2)
library(stringr)

firsthalf <- fread('.\\data\\fangraphs_scraped.csv')
firsthalf <- firsthalf %>% 
  select(-V1) %>% 
  filter(team != 'Multiple', year != 2018)
asg <- fread('.\\data\\AllstarFull.csv')
people <- fread('.\\data\\People.csv')
appearances <- fread('.\\data\\Appearances.csv')

# Clean "people" df
people$full_name <- paste(people$nameFirst, people$nameLast)
people$DOB <- ymd(paste0(people$birthYear, '-', people$birthMonth, '-', people$birthDay))
people$bbrefID <- str_replace(people$bbrefID, 'drewj.01', 'drewjd01')
people$bbrefID <- str_replace(people$bbrefID, 'furcara02', 'furcara01')
people$bbrefID <- str_replace(people$bbrefID, "harriwi02", 'harriwi01')
people$bbrefID <- str_replace(people$bbrefID, "hincha.01", 'hinchaj01')
people$bbrefID <- str_replace(people$bbrefID, "jimend'01", 'jimenda01')
people$bbrefID <- str_replace(people$bbrefID, "o'bripe03", 'obriepe03')
people$bbrefID <- str_replace(people$bbrefID, "o'leatr01", 'oleartr01')
people$bbrefID <- str_replace(people$bbrefID, "o'neipa01", 'oneilpa01')
people$bbrefID <- str_replace(people$bbrefID, 'pierza.01', 'pierzaj01')
people$bbrefID <- str_replace(people$bbrefID, 'redmaju01', 'redmati01')
people$bbrefID <- str_replace(people$bbrefID, 'reynor.01', 'reynorj01')
people <- people %>% filter(full_name != 'Ross Reynolds')
people$bbrefID <- str_replace(people$bbrefID, 'santaf.01', 'santafp01')
people$bbrefID <- str_replace(people$bbrefID, 'snowj.01', 'snowjt01')
people$bbrefID <- str_replace(people$bbrefID, 'surhob.01', 'surhobj01')


# Connect full player name to ASG df
asg <- asg %>% 
  left_join(people[,c('playerID', 'full_name')], by = 'playerID') %>% 
  filter(yearID >= min(firsthalf$year)) %>% 
  mutate(player_year_ID = paste(yearID, playerID, sep = '-'),
         started = ifelse(is.na(startingPos), 0, 1))


# Each player's most commonly played position
appearances <- appearances %>% 
  filter(yearID >= min(firsthalf$year), G_all >= 30) %>% 
  mutate(player_year_ID = paste(yearID, playerID, sep = '-')) %>% 
  left_join(people[,c('playerID', 'full_name')], by='playerID') %>% 
  group_by(player_year_ID) %>% summarise(G_p=sum(G_p), G_c=sum(G_c), G_1b=sum(G_1b), G_2b=sum(G_2b), G_3b=sum(G_3b), G_ss=sum(G_ss), G_of=sum(G_of), G_dh=sum(G_dh), G_ph=sum(G_ph), G_pr=sum(G_pr)) %>% 
  mutate(made_asg = ifelse(player_year_ID %in% asg$player_year_ID, 1, 0))
appearances <- melt(data = appearances, id.vars = c('player_year_ID', 'made_asg')) %>% 
  filter(!(variable %in% c('G_ph', 'G_pr'))) %>% 
  arrange(player_year_ID, desc(value)) %>% 
  group_by(player_year_ID) %>% 
  top_n(1, value)


# Randomly choose a position for all common position ties
ties <- as.data.frame(cbind(names(table(appearances$player_year_ID)), unname(table(appearances$player_year_ID))))
ties <- ties %>% 
  filter(as.numeric(V2) > 1) %>% 
  rename(player_year_ID = V1, count = V2)
ties_choices <- filter(appearances, player_year_ID %in% ties$player_year_ID) %>% group_by(player_year_ID) %>% sample_n(1)
nonties <- filter(appearances, !(player_year_ID %in% ties$player_year_ID))
appearances <- bind_rows(ties_choices, nonties) %>% 
  rename(position = variable, num_games = value)
rm(nonties, ties, ties_choices)


# Join player names & cleaning
appearances$yearID <- as.numeric(sapply(str_split(appearances$player_year_ID, '-'), `[`, 1))
appearances$playerID <- sapply(str_split(appearances$player_year_ID, '-'), `[`, 2)
appearances <- left_join(appearances, people[,c('playerID', 'full_name')], by='playerID')
appearances$position <- toupper(str_replace(appearances$position, 'G_', ''))
appearances <- appearances %>% 
  filter(position != 'P') %>% 
  arrange(player_year_ID)
appearances <- appearances %>% 
  left_join(asg[,c(10,11)], by='player_year_ID') %>% 
  rename(started_asg = started) %>% 
  mutate(started_asg = ifelse(is.na(started_asg), 0, started_asg))


# Name matching
firsthalf$player <- str_replace(firsthalf$player, ' Jr.', '')
firsthalf$player <- str_replace(firsthalf$player, 'A.J.', 'A. J.')
firsthalf$player <- str_replace(firsthalf$player, 'B.J.', 'B. J.')
firsthalf$player <- str_replace(firsthalf$player, 'C.J.', 'C. J.')
firsthalf$player <- str_replace(firsthalf$player, 'F.P.', 'F. P.')
firsthalf$player <- str_replace(firsthalf$player, 'J.B.', 'J. B.')
firsthalf$player <- str_replace(firsthalf$player, 'J.J.', 'J. J.')
firsthalf$player <- str_replace(firsthalf$player, 'J.D.', 'J. D.')
firsthalf$player <- str_replace(firsthalf$player, 'J.P.', 'J. P.')
firsthalf$player <- str_replace(firsthalf$player, 'J.T.', 'J. T.')
firsthalf$player <- str_replace(firsthalf$player, 'R.J.', 'R. J.')
firsthalf$player <- str_replace(firsthalf$player, 'J. T. Riddle', 'JT Riddle')
firsthalf$player <- str_replace(firsthalf$player, 'Byung-ho Park', 'Byung Ho Park')
firsthalf$player <- str_replace(firsthalf$player, 'DiSarcina', 'Disarcina')
firsthalf$player <- str_replace(firsthalf$player, 'Eddie Taubensee', 'Ed Taubensee')
firsthalf$player <- str_replace(firsthalf$player, 'Ernest Riles', 'Ernie Riles')
firsthalf$player <- str_replace(firsthalf$player, 'Hee Seop', 'Hee-Seop')
firsthalf$player <- str_replace(firsthalf$player, 'Karl Rhodes', 'Tuffy Rhodes')
firsthalf$player <- str_replace(firsthalf$player, 'Kaz Matsui', 'Kazuo Matsui')
firsthalf$player <- str_replace(firsthalf$player, 'Matt Joyce', 'Matthew Joyce')
firsthalf$player <- str_replace(firsthalf$player, 'Michael Morse', 'Mike Morse')
firsthalf$player <- str_replace(firsthalf$player, 'Michael A. Taylor', 'Michael Taylor')
firsthalf$player <- str_replace(firsthalf$player, 'Nicholas Castellanos', 'Nick Castellanos')
firsthalf$player <- str_replace(firsthalf$player, 'Yolmer Sanchez', 'Carlos Sanchez')

# Alex Gonzalez(es)
firsthalf$player <- ifelse(firsthalf$player == 'Alex Gonzalez' & firsthalf$year < 1998, 'Alex Gonzalez (1)', firsthalf$player)
firsthalf$player <- ifelse(firsthalf$player == 'Alex Gonzalez' & firsthalf$year > 2006, 'Alex Gonzalez (2)', firsthalf$player)
firsthalf$player <- ifelse(firsthalf$player == 'Alex Gonzalez' & firsthalf$team %in% c('Blue Jays', 'Cubs'), 'Alex Gonzalez (1)', firsthalf$player)
firsthalf$player <- ifelse(firsthalf$player == 'Alex Gonzalez' & firsthalf$team %in% c('Marlins', 'Red Sox'), 'Alex Gonzalez (2)', firsthalf$player)
appearances$full_name <- ifelse(appearances$full_name == 'Alex Gonzalez' & appearances$playerID == 'gonzaal01', 'Alex Gonzalez (1)', appearances$full_name)
appearances$full_name <- ifelse(appearances$full_name == 'Alex Gonzalez' & appearances$playerID == 'gonzaal02', 'Alex Gonzalez (2)', appearances$full_name)


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

# Join & merge with first-half stats and asg
firsthalf <- firsthalf %>% 
  left_join(appearances, by = c('player'='full_name', 'year'='yearID'))
firsthalf <- firsthalf %>% 
  filter(!playerID %in% c('griffke01', 'huntebr01', 'gonzalu02', 'taylomi01'))


# Join & merge with team ASG standings
standings <- fread('.\\data\\standings.csv')
firsthalf <- firsthalf %>% left_join(standings[,c(9,10,4)], by=c('year'='year', 'team'='team_full_name'))
firsthalf$`W-L%` <- ifelse(is.na(firsthalf$`W-L%`), .500, firsthalf$`W-L%`)
firsthalf$popular <- ifelse(firsthalf$team %in% c('Yankees', 'Red Sox', 'Cubs', 'Dodgers'), 1, 0)
firsthalf$NYY <- ifelse(firsthalf$team == 'Yankees', 1, 0)
firsthalf$BOS <- ifelse(firsthalf$team == 'Red Sox', 1, 0)
firsthalf$CHC <- ifelse(firsthalf$team == 'Cubs', 1, 0)
firsthalf$LAD <- ifelse(firsthalf$team == 'Dodgers', 1, 0)


# Did the team play in the WS in prior year?
ws <- fread('.\\data\\ws.csv')
ws$winner_year_id <- paste0(ws$next_season, '-', ws$winner_name)
ws$loser_year_id <- paste0(ws$next_season, '-', ws$loser_name)
firsthalf$team_year_id <- paste0(firsthalf$year, '-', firsthalf$team)
firsthalf$won_WS_PY <- ifelse(firsthalf$team_year_id %in% ws$winner_year_id, 1, 0)
firsthalf$lost_WS_PY <- ifelse(firsthalf$team_year_id %in% ws$loser_year_id, 1, 0)
firsthalf$played_WS_PY <- firsthalf$won_WS_PY + firsthalf$lost_WS_PY


# How old was the player at the start of the season? (Apr. 1)
firsthalf <- firsthalf %>% 
  left_join(people[,c('bbrefID', 'DOB')], by=c('playerID'='bbrefID'))
firsthalf$years_old_SOS <- round((ymd(paste0(firsthalf$year, '-', '4', '-', '1')) - firsthalf$DOB)/365,2)


# Player rank at his position (in his league)
firsthalf <- firsthalf %>% arrange(league_year_ID, position, desc(WAR)) %>% group_by(league_year_ID, position) %>% mutate(rank_WAR= row_number()) %>% arrange(player_year_ID)
firsthalf <- firsthalf %>% arrange(league_year_ID, position, desc(`wRC+`)) %>% group_by(league_year_ID, position) %>% mutate(rank_wRC= row_number()) %>% arrange(player_year_ID)
firsthalf <- firsthalf %>% arrange(league_year_ID, position, desc(OBP)) %>% group_by(league_year_ID, position) %>% mutate(rank_OBP= row_number()) %>% arrange(player_year_ID)
firsthalf <- firsthalf %>% arrange(league_year_ID, position, desc(SLG)) %>% group_by(league_year_ID, position) %>% mutate(rank_SLG= row_number()) %>% arrange(player_year_ID)
firsthalf <- firsthalf %>% arrange(league_year_ID, position, desc(HR)) %>% group_by(league_year_ID, position) %>% mutate(rank_HR= row_number()) %>% arrange(player_year_ID)
firsthalf <- firsthalf %>% arrange(league_year_ID, position, desc(AVG)) %>% group_by(league_year_ID, position) %>% mutate(rank_AVG= row_number()) %>% arrange(player_year_ID)
firsthalf <- firsthalf %>% arrange(league_year_ID, position, desc(Off)) %>% group_by(league_year_ID, position) %>% mutate(rank_Off= row_number()) %>% arrange(player_year_ID)
firsthalf <- firsthalf %>% arrange(league_year_ID, position, desc(Def)) %>% group_by(league_year_ID, position) %>% mutate(rank_Def= row_number()) %>% arrange(player_year_ID)
firsthalf <- firsthalf %>% arrange(league_year_ID, position, desc(SB)) %>% group_by(league_year_ID, position) %>% mutate(rank_SB= row_number()) %>% arrange(player_year_ID)


# Player rank on his team
firsthalf <- firsthalf %>% arrange(team_year_id, desc(WAR)) %>% group_by(team_year_id) %>% mutate(team_rank_WAR = row_number()) %>% arrange(player_year_ID)
firsthalf <- firsthalf %>% arrange(team_year_id, desc(`wRC+`)) %>% group_by(team_year_id) %>% mutate(team_rank_wRC = row_number()) %>% arrange(player_year_ID)
firsthalf <- firsthalf %>% arrange(team_year_id, desc(OBP)) %>% group_by(team_year_id) %>% mutate(team_rank_OBP = row_number()) %>% arrange(player_year_ID)
firsthalf <- firsthalf %>% arrange(team_year_id, desc(SLG)) %>% group_by(team_year_id) %>% mutate(team_rank_SLG = row_number()) %>% arrange(player_year_ID)
firsthalf <- firsthalf %>% arrange(team_year_id, desc(HR)) %>% group_by(team_year_id) %>% mutate(team_rank_HR = row_number()) %>% arrange(player_year_ID)
firsthalf <- firsthalf %>% arrange(team_year_id, desc(AVG)) %>% group_by(team_year_id) %>% mutate(team_rank_AVG = row_number()) %>% arrange(player_year_ID)
firsthalf <- firsthalf %>% arrange(team_year_id, desc(Off)) %>% group_by(team_year_id) %>% mutate(team_rank_Off = row_number()) %>% arrange(player_year_ID)
firsthalf <- firsthalf %>% arrange(team_year_id, desc(Def)) %>% group_by(team_year_id) %>% mutate(team_rank_Def = row_number()) %>% arrange(player_year_ID)
firsthalf <- firsthalf %>% arrange(team_year_id, desc(SB)) %>% group_by(team_year_id) %>% mutate(team_rank_SB = row_number()) %>% arrange(player_year_ID)


write.csv(firsthalf, '.\\data\\firsthalf.csv', row.names = F)
