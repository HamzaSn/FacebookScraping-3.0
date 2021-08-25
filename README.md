## FacebookScraping-3.0

# Facebook group Data scraping solution

A solution for data scraping from facebook tunisian groups built with R programming language, Selenium server ,JavaScrip queries and SQLite


# Details : 

The solution is a function that takes as arguments a vector of facebook groups and the number of scroll units ( 1 units : scroll to the botton of the current page )

and execute the following steps : 

- connect to facebook account 
- navigate to group
- scroll
- send JS query to get the data 
- process the data ( cleaning and formating )
- extract informations like phone number and city
- append the data to the existing SQLite databse



here's the ERD of the database

![ERD](https://user-images.githubusercontent.com/81447987/130844749-8665205d-2909-4b74-9e54-65116db07ec4.PNG)

a sample of data extracted 

![datasample](https://user-images.githubusercontent.com/81447987/130845719-3b128923-2db8-4ed1-a6c6-bd5e9f3c96ce.PNG)








