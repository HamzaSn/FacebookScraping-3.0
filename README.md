## Facebook Scraping

# Facebook groups data scraping solution

A solution for data extraction from facebook tunisian groups built with R programming language, Selenium server ,JavaScript queries and SQLite database

# Details : 

The solution is a function that takes as arguments a list of facebook groups and execute the following steps : 

- connect to facebook account using user fb-credentials
- navigate to group
- reapeat scrolliing and send JS query to get the data 
- process the data ( cleaning and formating )
- extract informations like phone number and city
- append the data to the existing SQLite databse

database ERD :

![ERD](https://user-images.githubusercontent.com/81447987/130847575-257dd13c-6cea-4d0d-8360-1153794b6fea.PNG)

a sample of data extracted 

![datasample](https://user-images.githubusercontent.com/81447987/130845719-3b128923-2db8-4ed1-a6c6-bd5e9f3c96ce.PNG)

![images](https://user-images.githubusercontent.com/81447987/130846211-81192768-912b-4b5a-b803-f3805838975f.PNG)






