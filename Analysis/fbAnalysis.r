

fbAnalysis <- function(){
    
    
    Connect <- function(){
        require(RSQLite)
        dbConnect(SQLite(),dbname = file.choose())
    }
    
    postsByUserHistogram <- function(){
        SQL <- " 
        SELECT name , count(*) as count  FROM posts GROUP BY name
        ORDER BY count desc ;
        "
        
        name_occrences <- dbGetQuery(con,SQL)
        firstPost <- dbGetQuery(con,"SELECT MIN(post_time) as f FROM posts")$f
        hist(name_occrences$count,breaks = 20,ylim = c(0,300),labels = T , freq = T,
             main = paste("Number of content posted since"  , firstPost) , 
             xlab = "number of posts",
             col = rainbow(1500,alpha = 0.5),plot = T)
        
    }
    
    postsOfUserByDates <- function(name = "" , rank = -1){
        
        SQL <- " 
        SELECT name , count(*) as count  FROM posts GROUP BY name
        ORDER BY count desc ;
        "
        
        
        name_occrences <- dbGetQuery(con,SQL)
        
        if(name != ""){
            
            dates <- dbGetQuery(con,paste0("SELECT post_time FROM posts WHERE name = '",name , "';") )
            require(lubridate)
            d <- ymd(dates$post_time)
            hist(d,breaks = 10 , col = rainbow(33,alpha = 0.7),labels = T , freq = T , 
                 main = "Histogram of dates of posts 
        of user ***" , xlab = "number of posts")
        }  
        if(rank != -1 & rank > 0 & rank < nrow(name_occrences) ){
            name <- name_occrences$name[rank]
            dates <- dbGetQuery(con,paste0("SELECT post_time FROM posts WHERE name = '",name , "';") )
            require(lubridate)
            d <- ymd(dates$post_time)
            hist(d,breaks = 10 , col = rainbow(33,alpha = 0.7),labels = T , freq = T , 
                 main = "Histogram of dates of posts 
        of user ***" , xlab = "number of posts")
        } 
        
        
        
        
        
        
        
    }
    
    groupsActivityPlot <- function(name = "",rank = -1){
        
        SQL <- " 
        SELECT name , count(*) as count  FROM posts GROUP BY name
        ORDER BY count desc ;
        "
        
        
        name_occrences <- dbGetQuery(con,SQL)
        
        if(name != ""){
            
            SQL2 <- paste0("SELECT group_id,count(group_id) FROM posts WHERE name = '", name ,"' GROUP BY group_id;"  )
            
            
            groups <- dbGetQuery(con,SQL2)
            
            groups$ID <- 1:nrow(groups)
            groups$group_id <- factor(as.character(groups$group_id))
            
            require(ggplot2)
            require(ggthemes)
            
            ggplot(groups, aes(x = paste("group",ID), y = `count(group_id)`,fill = group_id)) +
                geom_col() + scale_color_gradient2() + 
                geom_text(aes(label = `count(group_id)`, vjust = -0.2,size = I(5) )) + 
                labs(x = "Groups",
                     y = "Posts") +
                theme_excel_new(base_size = 18) 
            
            
            
        }
        
        if(rank != -1 & rank > 0 & rank < nrow(name_occrences)){
            
            SQL <- " 
        SELECT name , count(*) as count  FROM posts GROUP BY name
        ORDER BY count desc ;
        "
            
            name_occrences <- dbGetQuery(con,SQL)
            name <- name_occrences$name[rank]
            SQL2 <- paste0("SELECT group_id,count(group_id) FROM posts WHERE name = '", name ,"' GROUP BY group_id;"  )
            
            
            groups <- dbGetQuery(con,SQL2)
            
            groups$ID <- 1:nrow(groups)
            groups$group_id <- factor(as.character(groups$group_id))
            
            require(ggplot2)
            require(ggthemes)
            
            ggplot(groups, aes(x = paste("group",ID), y = `count(group_id)`,fill = group_id)) +
                geom_col() + scale_color_gradient2() + 
                geom_text(aes(label = `count(group_id)`, vjust = -0.2,size = I(5) )) + 
                labs(x = "Groups",
                     y = "Posts") +
                theme_excel_new(base_size = 18) 
            
        }
        
        
    }
    
    wordCloudContent <- function(name = "" , rank = -1 ){
        
        SQL <- " 
        SELECT name , count(*) as count  FROM posts GROUP BY name
        ORDER BY count desc ;
        "
        
        
        name_occrences <- dbGetQuery(con,SQL)
        
        if(name != ""){
            
            require(tm)
            require(wordcloud)
            SQL3 <- paste0("SELECT description as d FROM posts WHERE name ='" ,name , "';")
            content <- dbGetQuery(con,SQL3)$d
            text = paste(content,collapse = "\n")
            corpus = VCorpus(VectorSource(text))
            corpus = tm_map(corpus , removeNumbers)
            corpus = tm_map(corpus , removePunctuation)
            corpus = tm_map(corpus , stripWhitespace)
            corpus = tm_map(corpus , removeWords , stopwords("en"))
            corpus = tm_map(corpus , removeWords , stopwords("fr"))
            dtm = DocumentTermMatrix(corpus)
            dtm = as.matrix(dtm)
            dtm = t(dtm)
            occ = rowSums(dtm)
            occ = sort(occ,decreasing = T)
            occ = occ[1:20]
            wordcloud(names(occ),occ,colors = rainbow(200),random.color = T,scale = c(2,5), rot.per=0)
        }
        
        if(rank != -1 & rank > 0 & rank < nrow(name_occrences)){
            
            name <- name_occrences$name[rank]
            require(tm)
            require(wordcloud)
            SQL3 <- paste0("SELECT description as d FROM posts WHERE name ='" ,name , "';")
            content <- dbGetQuery(con,SQL3)$d
            text = paste(content,collapse = "\n")
            corpus = VCorpus(VectorSource(text))
            corpus = tm_map(corpus , removeNumbers)
            corpus = tm_map(corpus , removePunctuation)
            corpus = tm_map(corpus , stripWhitespace)
            corpus = tm_map(corpus , removeWords , stopwords("en"))
            corpus = tm_map(corpus , removeWords , stopwords("fr"))
            dtm = DocumentTermMatrix(corpus)
            dtm = as.matrix(dtm)
            dtm = t(dtm)
            occ = rowSums(dtm)
            occ = sort(occ,decreasing = T)
            occ = occ[1:20]
            wordcloud(names(occ),occ,colors = rainbow(200),random.color = T,scale = c(2,5), rot.per=0)
            
            
            
        }
        
        
        
    }
    
    functions <- list(Connect = Connect , postsByUserHistogram = postsByUserHistogram , postsOfUserByDates = postsOfUserByDates,
                      groupsActivityPlot = groupsActivityPlot  , wordCloudContent = wordCloudContent  
    )
    
}





