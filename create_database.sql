Create database trade_database;
USE trade_database ;

CREATE TABLE Company_info(
	company_id INT PRIMARY KEY auto_increment,
    company_name VARCHAR(25) NOT NULL ,
    closed_price INT NOT NULL,
    circuit_limit DECIMAL NOT NULL 
);
    
CREATE TABLE user_info(
	user_id INT PRIMARY KEY auto_increment,
    user_name VARCHAR(25) NOT NULL ,
    limit_balance INT NOT NULL 
);
    
CREATE TABLE bid(
	bid_id INT PRIMARY KEY auto_increment,
    company_id INT NOT NULL ,
    user_id INT NOT NULL ,
    quantity INT NOT NULL,
    bid_price DECIMAL NOT NULL ,
    placed_at datetime default current_timestamp,
    foreign key(company_id) references company_info(company_id) ,
	foreign key(user_id) references user_info(user_id) 
);

CREATE TABLE ask(
	ask_id INT PRIMARY KEY auto_increment,
    company_id INT NOT NULL ,
    user_id INT NOT NULL ,
    quantity INT NOT NULL,
    ask_price DECIMAL NOT NULL ,
    placed_at datetime default current_timestamp,
    foreign key(company_id) references company_info(company_id) ,
	foreign key(user_id) references user_info (user_id)
);

CREATE TABLE trade_info(
	trade_id INT primary key auto_increment,
    company_id INT NOT NULL ,
    bid_id INT NOT NULL ,
	ask_id INT NOT NULL ,
    quantity INT NOT NULL,
    trade_price DECIMAL NOT NULL ,
    trade_time DATETIME default current_timestamp,
    foreign key(company_id) references company_info(company_id) ,
    foreign key(bid_id) references bid(bid_id),
    foreign key(ask_id) references ask(ask_id)
);

CREATE TABLE share_balance(
	user_id INT NOT NULL,
    company_id INT NOT NULL,
    quantity INT NOT NULL,
    foreign key(user_id) references user_info(user_id),
    foreign key(company_id) references company_info(company_id),
    primary key(user_id,company_id)
);

create table exec_bid(
	ebid int primary key auto_increment ,
    bid_id int ,
    qty int,
    foreign key(bid_id) references bid(bid_id)
);
create table exec_ask(
	eaid int primary key auto_increment ,
    ask_id int ,
    qty int,
    foreign key(ask_id) references ask(ask_id)
);

insert into user_info values(default , 'Neymar',30000,'njr11');
insert into user_info values(default , 'Messi',30000,'lm10');
insert into user_info values(default , 'Iniesta',30000,'ai8');
insert into user_info values(default , 'Lewandowski',30000,'rl9');

insert into company_info values(default , 'Microsoft' , 1000 , 10);
insert into company_info values(default , 'Google' , 1200 , 10);
insert into company_info values(default , 'JP Morgan Chase.' , 950 , 10);
insert into company_info values(default , 'Oracle' , 850 , 10);
insert into company_info values(default , 'Atlassian' , 700 , 10);
insert into company_info values(default , 'Citi' , 950 , 10);
insert into company_info values(default , 'Walmart' , 800 , 10);
insert into company_info values(default , 'Tesla' , 850 , 10);
insert into company_info values(default , 'SpaceX' , 650 , 10);
insert into company_info values(default , 'Tata' , 900 , 10);
