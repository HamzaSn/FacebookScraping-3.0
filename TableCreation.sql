
CREATE TABLE posts(  
    id INTEGER NOT NULL primary key AUTOINCREMENT,
	post_number INTEGER NOT NULL ,
    name TEXT , 
    source TEXT ,
    category TEXT , 
    product TEXT , 
    type TEXT , 
    title TEXT ,
    description text NOT NULL,
    price double ,  
    city TEXT NOT NULL, 
    tags TEXT  , 
    phone_number TEXT NOT NULL,
    post_time TEXT ,
    group_id NUMERIC ,
    insert_time TEXT
 );



CREATE TABLE images(  post_number INTEGER NOT NULL , group_id NUMERIC , url TEXT);