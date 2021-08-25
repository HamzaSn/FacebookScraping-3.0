library(RSelenium)
library(rvest)
library(tidyverse)
library(odbc)
library(RSQLite)
library(qdapRegex)
library(lubridate)


fb_group <- function(groups, scrolltimes){
    
    print("connecting to database")
    
    
    con <- dbConnect(SQLite(),dbname = "C:/Users/Hamza/Desktop/Internship/facebook.db")
    
    
    adress <- readline("Enter Facebook email adress : ")
    password <- readline("Enter password :")
    
    port <- sample(1000:9999,1)
    eCaps <- list(chromeOptions = list( binary = "C:\\Program Files\\Google\\Chrome Beta\\Application\\chrome.exe" ) )
    
    print("loading WebDriver")
    
    rD <- rsDriver(verbose = F,check = F ,browser = "chrome" , port = port, extraCapabilities = eCaps)
    Sys.sleep(8)
    
    
    print("Connecting To Facebook")
    
    remDr <- rD$client
    
    
    remDr$navigate("https://m.facebook.com")
    
    Sys.sleep(8)
    
    email = remDr$findElement( using  = "id" , value = "m_login_email")
    print("Loging in")
    email$sendKeysToElement(list(adress))
    
    pass = remDr$findElement(using = "id","m_login_password")
    
    pass$sendKeysToElement(list(password,key = "enter"))
    Sys.sleep(8)
    
    skip = remDr$findElement(using = "css" , value = '[class = "_54k8 _56bs _26vk _56b_ _56bw _56bt"]' )
    
    skip$sendKeysToElement(list(key='enter'))
    
    scroller <- function(times){
        k = 100000
        for(i in 1:times){
            scrollJs <- paste0("window.scrollTo(0,", k , ")" )
            remDr$executeScript(scrollJs)
            Sys.sleep(5)
            k = k + 100000
        }
        
    }
    
    
    
    final_content_data = NA
    final_image_data = NA
    
    for(group in groups){
        
        Sys.sleep(5)
        
        print(paste("Accessing Facebook Group" , group) )
        
        remDr$navigate(paste0("https://m.facebook.com/groups/" , group , "/") )
        
        Sys.sleep(5)
        
        print("scrolling")
        
        scroller(scrolltimes)
        
        
        js <- "

        // A JS Script to Query the name , content , time and the url of the image posted.

const container = document.getElementsByClassName('_55wo _5rgr _5gh8 async_like');
let obs = {};
url = {};
let time = {};
let i = 1;
[...container].forEach((post) => {

currentName = [];

[...post.getElementsByTagName('strong')].forEach((elem) =>
currentName.push(elem.textContent))
obs[currentName + ' post ' + i ] = [];


currentContent = [] ;
[...post.getElementsByClassName('_5rgt _5nk5 _5wnf _5msi')].forEach((el) => [...el.getElementsByTagName('p')].forEach((r) =>
 currentContent.push(r.textContent) ))
obs[currentName + ' post ' + i ] = currentContent;

time['post' + i ] = [];

currentTime = [];

[...post.getElementsByClassName('_52jc _5qc4 _78cz _24u0 _36xo')].forEach((el) =>
[...el.getElementsByTagName('abbr')].forEach((r) => currentTime.push(r.textContent)));

time['post' + i ] = currentTime;

currentUrl = [];
[...post.getElementsByClassName('story_body_container')].forEach((e) =>
[...e.getElementsByTagName('i')].forEach((r) => currentUrl.push(r.style.backgroundImage)
)) ;
url['post '+ i] = currentUrl;
i++;

})
return[obs,time,url];
"
        # Executing the script
        
        
        print("sending JavaScript Query")
        results = remDr$executeScript(js)
        
        # Processing Data
        
        print("processing Url Data...")
        
        
        # URL data cleaning and processing
        
        
        urlIds = attr(results[[3]],"names")
        
        image_df = data.frame(post_id = NA , url = NA, group_id = NA)
        
        split = strsplit(urlIds , "post")
        
        for(i in 1:length(urlIds)){
            current_post_id = split[[i]][2]
            listURL = results[[3]][[i]]
            listURL = listURL[-1]
            listURL = listURL[listURL != ""]
            listURL = unique(listURL)
            len = length(listURL)
            if(len == 0 ) {image_df = rbind(image_df , cbind(post_id = current_post_id , url = "No image in post", group_id = group))} else {
                for(j in 1:len){
                    
                    image_df = rbind(image_df , cbind(post_id = current_post_id , url = listURL[j] , group_id = group ) )
                }
            }
        }
        
        image_df = image_df[-1,]
        image_df$url <- gsub('"',"",image_df$url)
        image_df$url <- gsub('url',"",image_df$url)
        
        image_df$url = gsub('[(]', "", image_df$url)
        image_df$url = gsub('[)]', "", image_df$url)
        image_df$post_id <- as.numeric(image_df$post_id)
        image_df$group_id <- rep(group,nrow(image_df))
        
        
        image_df <- arrange(image_df,post_id)
        
        
        # names and content data cleaning and processing
        
        print("proccessing content data")
        names = attr(results[[1]],"names")
        
        
        
        content = character()
        name = character()
        
        
        
        for(i in 1:length(names)){
            if(length(results[[1]][[i]])== 0){next} else {
                txt = unlist(results[[1]][[i]])
                content[i] = paste(txt,collapse = " ")
                name[i] = names[i]
                
            }
        }
        preData = data.frame(name, content)
        preData = preData[complete.cases(preData),]
        
        split = strsplit(preData$name , "post")
        post_id <- numeric()
        owner = character()
        
        for(i in 1:nrow(preData)){
            post_id[i] = as.numeric(split[[i]][2])
            owner[i] = split[[i]][1]
        }
        
        content_data = data.frame(post_id= post_id , name = owner , content = preData$content )
        content_data <- content_data[,c(2,3,1)]
        content_data = arrange(content_data,post_id)
        
        posters = character()
        source = character()
        splitNames = strsplit(content_data$name,",")
        for(i in 1:length(splitNames)){
            
            posters[i] = splitNames[[i]][1]
            source[i] = paste(splitNames[[i]][2],splitNames[[i]][3],sep = "/")
        }
        
        content_data$name <- posters
        content_data$source <- source
        
        
        
        # time data cleaning and processing
        
        print("processing time data")
        
        times = attr(results[[2]],"names")
        post_id = numeric()
        time = character()
        split = strsplit(times,"post")
        for(i in 1:length(times)){
            
            time[i] = results[[2]][[i]][[1]]
            post_id[i] = as.numeric(split[[i]][2])
            
        }
        
        time_data = data.frame(post_id,time)
        time_data = arrange(time_data,post_id)
        
        # Removing missing content data
        
        
        x = content_data$post_id[!is.na(content_data$content)]
        content_data <- content_data[complete.cases(content_data),]
        time_data <- time_data[x,]
        
        # Removing unwanted characters
        
        content_data$content = gsub("\\.(?=[^.]*\\.)", "", content_data$content, perl=TRUE)
        content_data$content = gsub("\\." , "" , content_data$content)
        
        # Joining the time and the content data tables by the post_id.
        
        data = merge(content_data,time_data,by.x= "post_id" , by.y ="post_id",all = T)
        
        print("extracting informations from content and preparing to export")
        
        
        # as the time of the post can be in the formats : 1h , 35 mins , Yesterday ...
        # we need to convert it to a date and time format.
        
        for(i in 1:nrow(data)){
            
            if(grepl("min",data$time[i])){
                t = as.numeric(strsplit(data$time[i]," ")[[1]][1])
                data$time[i] <- as.character(Sys.time() - t*60)
            }
            if(grepl("hr",data$time[i])){
                t = as.numeric(strsplit(data$time[i]," ")[[1]][1])
                data$time[i] <- as.character(Sys.time() - t*60*60)
            }
            if(grepl("Now",data$time[i])){
                
                data$time[i] <- Sys.time()
            }
            if(grepl("Yesterday",data$time[i])){
                data$time[i] <-  gsub("Yesterday",as.character(Sys.Date()-1),data$time[i] )
                data$time[i] <- gsub("at","",data$time[i])
            }
            
        }
        
        newTime <- rep(ymd(Sys.Date()), nrow(data))
        
        for( i in 1:nrow(data)){
            
            if(grepl("at",data$time[i])){
                
                if(grepl("202",data$time[i])){
                    
                    dayMonth =  strsplit(data$time[i],",")[[1]][1]
                    year = strsplit(data$time[i],",")[[1]][2]
                    year = gsub(" ","",year)
                    year = substr(year,1,4)
                    newTime[i] <- mdy(gsub(" ", "-" ,paste(dayMonth,year) ))
                    
                } else {
                    
                    newTime[i] <- mdy(gsub(" ","-",paste0(strsplit(data$time[i],"at")[[1]][1],"2021")))
                    
                }      
            } else { 
                
                
                newTime[i] <- ymd(substr(data$time[i],1,10))
                
            }
            
        }
        
        data$time <- newTime
        
        
        print("Extracting the phone numbers")
        
        
        data$phone_number <- ex_phone(data$content,pattern = '(?<!\\d)[0-9]{8}(?!\\d)')
        
        for(i in 1:length(data$phone_number)){
            
            if(length(data$phone_number[i][[1]]) == 2){
                data$phone_number[i] <- paste( data$phone_number[[i]] , collapse = " / ")
            }
            if(is.na(data$phone_number[i][[1]])[1]){data$phone_number[i] <- "No phone number Available in post"}
            
        }
        
        
        print("Extracting Cities") 
        
        # in ordder to do that we will use a google sheet i created that contains all the cities in tunisia, in both Arabic and Frensh
        
        
        sqlQ1 <- " SELECT * FROM tn_cities"
        tn_cities <- dbGetQuery(con,sqlQ1)
        cities <- tn_cities$cities
        city <- character()
        for(i in 1:nrow(data)){
            
            locate = str_extract(data$content[i],cities)
            locate = locate[!is.na(locate)]
            if(length(locate) == 0){ city[i] = "No city available"} else {
                city[i] = paste(locate,collapse = " / ")
            }
            
        }
        
        data$city <- city
        
        # creating a column with the current group id
        
        data$group_id <- rep(group , nrow(data))
        
        
        
        # row binding the result of the current group with previous data
        
        final_image_data <- rbind(final_image_data , image_df)
        final_content_data <- rbind(final_content_data , data)
        
        
    }
    
    remDr$close()
    
    
    # data type fixing
    
    # str(data) function help to understand the struture of the data
    # i will convert all the lists to character
    
    
    final_content_data$group_id <- as.character(final_content_data$group_id)
    final_content_data$phone_number <- as.character(final_content_data$phone_number)
    final_image_data$group_id <- as.character(final_image_data$group_id)
    final_content_data$time <- as.character(final_content_data$time)
    #  we will neeed to remove the first row as it is an NA row.
    
    final_content_data <- final_content_data[-1,]
    final_image_data <- final_image_data[-1,]
    
    R <<- final_content_data
    RU <<- final_image_data
    print("inserting data into database")
    
    insertData <- data.frame(
        post_number = data$post_id,
        name = final_content_data$name ,
        source = final_content_data$source,
        category = rep(NA,nrow(final_content_data)) ,
        product = rep(NA,nrow(final_content_data)),
        type = rep(NA,nrow(final_content_data)),
        title = rep(NA,nrow(final_content_data)),
        description = final_content_data$content,
        price = rep(NA,nrow(final_content_data)) ,
        city = final_content_data$city,
        tags = rep(NA,nrow(final_content_data)),
        phone_number = final_content_data$phone_number ,
        post_time = final_content_data$time ,
        group_id = final_content_data$group_id,
        insert_time = rep(as.character(Sys.Date()),nrow(final_content_data)) )
    
    insertUrl <- data.frame(
        post_number = final_image_data$post_id ,
        group_id = final_image_data$group_id ,
        url = final_image_data$url
    )
    
    
    dbAppendTable(con,"posts",insertData)
    dbAppendTable(con,"images",insertUrl)
    message("Scrapping finished successfully")
    
    
    
}



