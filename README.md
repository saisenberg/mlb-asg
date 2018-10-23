## MLB’s Biggest All-Star Injustices

The Major League Baseball All-Star Game occurs in mid-July every year. All-Star rosters consist of 32 players on each side, made up of twenty position players and twelve pitchers, and each team’s starting lineup is determined by a fan vote that takes place from May to July. Reserves are voted in by a combination of fans, players, and the Commissioner’s Office, and every MLB team is ensured at least one All-Star on their league’s roster. This project creates a model which predicts whether a given position player will make his league’s All-Star roster.

A full description of the project can be found at [**saisenberg.com**](https://saisenberg.com/projects/mlb-asg.html).

### Getting started

#### Prerequisite software

* Python (suggested install through [Anaconda](https://www.anaconda.com/download/))


* [R](https://www.r-project.org/)

#### Prerequisite libraries

* Python:
    - bs4, numpy, pandas, sklearn, seaborn, warnings (```all installed with Anaconda```)
    

* R:

```
lib <- c('data.table', 'dplyr', 'gtools', 'htmltab', 'lubridate', 'reshape2', 'stringr')
install_packages(lib)
```
    
    
### Instructions for use

#### 1. Run the code contained in */python/fangraphs_scrape.ipynb* and */python/fangraphs_scrape_2018.ipynb*

This code scrapes *[FanGraphs](https://fangraphs.com)* for all first-half player statistics (for any position player with at least two hundred plate appearances by the All-Star break). The first Jupyter Notebook scrapes statistics from 1988-2017, and the latter scrapes only 2018 numbers.

The output of */python/fangraphs_scrape.ipynb* can also be found at */data/fangraphs_scraped.csv*. The output of */python/fangraphs_scrape_2018.ipynb* has been manually altered to include player positions, and can be found at */data/fangraphs_scraped_2018.csv*. It is recommended to directly use the included .csv file, as opposed to re-creating one with */python/fangraphs_scrape_2018.ipynb*.

#### 2. Run */r/ws.R*

This program scrapes *[ESPN](http://espn.com)* for World Series history, and cleans the resulting data.

The output of */r/ws.R* can also be found at */data/ws.csv*.

#### 3. Run */r/firsthalf.R* and */r/firsthalf2018.R*

This program collects, cleans, and merges All-Star Game and Appearance data (from the [Lahman DataBase](http://www.seanlahman.com/baseball-archive/statistics/)) with first-half player statistics. Ultimately, the program prepares two datasets for modeling.

The output of */r/firsthalf.R* and */r/firsthalf2018.R* can also be found at */data/firsthalf.csv* and */data/firsthalf2018.csv*, respectively. 

#### 4. Run the code contained in */python/made_asg.ipynb*

This code uses logistic regression, lasso & ridge regression, and random forest modeling (with grid search) to predict whether a given player will make his league's All-Star team. Logistic regression consistely performs the best of the group, and the model is deployed on first-half data from 2018.


### Author

* **Sam Isenberg** - [saisenberg.com](https://saisenberg.com) | [github.com/saisenberg](https://github.com/saisenberg)


### License

This project is licensed under the MIT License - see the *LICENSE.md* file for details.

### Acknowledgements

* [ESPN](http://espn.com)
* [FanGraphs](https://fangraphs.com)
* [Sean Lahman](http://www.seanlahman.com/baseball-archive/statistics/)
