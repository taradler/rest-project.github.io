create database Resturant_Management;
use Resturant_Management;

SET SQL_SAFE_UPDATES = 0;

create table Adminstration(
id int primary key auto_increment,
fname varchar(200) not null,
lname varchar(200) not null,
username varchar(200) not null,
positionn enum('Manager','Supervisor','FB Supervisor','Financial Manager') default ('Supervisor')
);

insert into adminstration Values(1,'Ahmed','Muhammad','ahmed.muhammad@gmail.com','Manager');
insert into adminstration Values(2,'Sherwan','Jamal','sherwan.jamal@gmail.com','Supervisor');
insert into adminstration Values(3,'Zhala','Haji','zhala.haje@gmail.com','Supervisor');
insert into adminstration Values(4,'Muhammad','Shamal','muhammad.shamal@gmail.com','FB Supervisor');
insert into adminstration Values(5,'Sanar','Dler','sanar.dler@gmail.com','FB Supervisor');
insert into adminstration Values(6,'Rawezh','khasro','rawezh.khasro@gmail.com','Financial Manager');
insert into adminstration Values(7,'Mina','Yassin','mina.yassin@gmail.com','Financial Manager');

create table employee(
id int primary key auto_increment,
fname varchar(200) not null,
lname varchar(200) not null,
age int check(age>=18),
time_work enum('8','7','6') default('8'),
employee_salary dec(5,2) not null,
start_contract date not null,
end_contract date not null,
positionn enum('dishwasher','cashier','server') default('cashier')
);

create table chef(
id int primary key auto_increment,
fname varchar(200) not null,
lname varchar(200) not null,
age int check (age>=30),
experience_year int check (experience_year>=4), 
time_work enum('4','5','6') default('4'),
chef_salary dec(5,2) not null,
start_contract date not null,
end_contract date not null,
constraint fk_type foreign key(food_type) references item_type(foodType),
constraint fk_food foreign key(food_name) references item_import(id)
on update cascade
on delete cascade
);
ALTER TABLE chef
DROP CONSTRAINT fk_type;

update chef
set experience_year=6
where fname='sara';

create table item(
id int primary key auto_increment,
food_name varchar(200) not null,
price dec(6,3) not null,
food_type enum('meat','Kurdaware','fastfood','ice','drinks') default('ice'),
reg_date date not null

);

update item
set price=0.500
where price=500.000;

create table item_import(
id int unique primary key,
import_food_name varchar(200) ,
import_company enum('Everlast','Tarin') default('Tarin') not null,
import_price dec(6,2) not null,
import_date date not null,
expire_imDate date not null

);
create table company(
company_id int primary key  auto_increment,
company_name enum('Everlast','Tarin') default('Tarin') ,
phone_number int not null,
address varchar(200) not null
);
create table item_type(
id int primary key auto_increment,
foodType enum('meat','Kurdaware','fastfood','ice','drinks') default('ice') 
);

create table benefit(
id int primary key auto_increment,
benefit dec(6,2),
food_type varchar(200)
);
-- creating view--

CREATE VIEW year_of_experience as 
SELECT fname,lname,experience_year
FROM chef
WHERE experience_year>4;

select * from year_of_experience;

CREATE VIEW ordered_item AS
SELECT import_food_name,food_type,company_name
FROM item_import,item,company;
   
select * from ordered_item;

-- Conditions --
SELECT fname,lname,end_contract,
CASE 
WHEN end_contract<current_date() then 'Contract Expirted'
ELSE 'Contract not Expired'
END AS contract_status
FROM chef;

SELECT fname,lname,experience_year,
if(experience_year=4,'inexpert',
if(experience_year>4 and experience_year<6,'Intermediate','Advanced') ) AS experience_status
from chef;

-- Pre-defined functions --
select fname,lname, round(employee_salary,1) as full_salary
from employee;

select import_food_name,import_company,datediff(expire_imDate,current_date()) as date_difference
from item_import;

select foodType,replace(foodType,'Kurdaware','Kurdish food') as food
from item_type;

/*DML && TCL*/
START transaction;
savepoint FIRST;

update chef
set Fname = 'Ahmed'
where Fname = 'Azad';

savepoint SECOND;

delete from chef
where age=40;

ROLLBACK TO FIRST;

-- Procedure --

select user();

DELIMITER ##
CREATE PROCEDURE admin_authorization()
begin
if user()='root@localhost' then
set transaction read only;
else set transaction read write;
end if;
END ##
DELIMITER ;

call admin_authorization();

DELIMITER $$
CREATE PROCEDURE contract_expiration()
begin
SELECT fname,lname,end_contract,
CASE 
WHEN end_contract<current_date() then 'Contract Expirted'
ELSE 'Contract not Expired'
END AS contract_status
FROM employee;
end $$
delimiter ;

call contract_expiration();

-- Creating Triggers // Log of Records --

create table Adminstration_log(
id int primary key auto_increment,
actionn varchar(200) not null,
new_fname varchar(200) not null,
new_lname varchar(200) not null,
new_username varchar(200) not null,
new_positionn enum('Manager','Supervisor','FB Supervisor','Financial Manager') default ('Supervisor'),
old_fname varchar(200) not null,
old_lname varchar(200) not null,
old_username varchar(200) not null,
old_positionn enum('Manager','Supervisor','FB Supervisor','Financial Manager') default ('Supervisor'),
reg_date date,
reg_time date,
reg_username varchar(200)
);
create trigger admin_insert
after insert on Adminstration
for each row
insert into Adminstration_log
set
actionn='insert',
new_fname=new.fname,
new_lname=new.lname,
new_username=new.username,
new_positionn=new.positionn,
reg_date=current_date,
reg_time=current_time(),
reg_username=current_user();

create trigger admin_delete
after delete on adminstration
for each row
insert into Adminstration_log
set
actionn='delete',
old_fname=old.fname,
old_lname=old.lname,
old_username=old.username,
old_positionn=old.positionn,
reg_date=current_date,
reg_time=current_time(),
reg_username=current_user();

create trigger admin_update
after update on adminstration
for each row
insert into Adminstration_log
set
actionn='update',
new_fname=new.fname,
old_fname=old.fname,
new_lname=new.lname,
old_lname=old.lname,
new_username=new.username,
old_username=old.username,
new_positionn=new.positionn,
old_positionn=old.positionn,
reg_date=current_date,
reg_time=current_time(),
reg_username=current_user();

create table employee_log(
id int primary key auto_increment,
actionn varchar(200),
old_fname varchar(200) not null,
new_fname varchar(200) not null,
old_lname varchar(200) not null,
new_lname varchar(200) not null,
old_age int ,
new_age int ,
old_time_work enum('8','7','6') default('8'),
new_time_work enum('8','7','6') default('8'),
old_employee_salary dec(5,2) not null,
new_employee_salary dec(5,2) not null,
old_start_contract date not null,
new_start_contract date not null,
old_end_contract date not null,
new_end_contract date not null,
old_positionn enum('dishwasher','cashier','server') default('cashier'),
new_positionn enum('dishwasher','cashier','server') default('cashier'),
reg_date date,
reg_time date,
reg_username varchar(200)
);

create trigger employee_insert
after insert on employee
for each row
insert into employee_log
set
actionn='insert',
new_fname=new.fname,
new_lname=new.lname,
new_age=new.age,
new_time_work=new.time_work,
new_employee_salary=new.employee_salary,
new_start_contract=new.start_contract,
new_end_contract=new.end_contract,
new_positionn=new.positionn,
reg_date=current_date(),
reg_time=current_time(),
reg_username=current_user();

create trigger employee_delete
after delete on employee
for each row
insert into employee_log
set
actionn='delete',
old_fname=old.fname,
old_lname=old.lname,
old_age=old.age,
old_time_work=old.time_work,
old_employee_salary=old.employee_salary,
old_start_contract=old.start_contract,
old_end_contract=old.end_contract,
old_positionn=old.positionn,
reg_date=current_date(),
reg_time=current_time(),
reg_username=current_user();

create trigger employee_update
after update on employee
for each row
insert into employee_log
set
actionn='update',
new_fname=new.fname,
old_fname=old.fname,
new_lname=new.lname,
old_lname=old.lname,
new_age=new.age,
old_age=old.age,
new_time_work=new.time_work,
old_time_work=old.time_work,
new_employee_salary=new.employee_salary,
old_employee_salary=old.employee_salary,
new_start_contract=new.start_contract,
old_start_contract=old.start_contract,
new_end_contract=new.end_contract,
old_end_contract=old.end_contract,
new_positionn=new.positionn,
old_positionn=old.positionn,
reg_date=current_date(),
reg_time=current_time(),
reg_username=current_user();

-- data validation--
delimiter #
create trigger employee_validate
before insert on employee
for each row
begin
if new.age<18 then
set new.age=null;
end if;
end #
delimiter ;

create table chef_log(
id int primary key auto_increment,
actionn varchar(200),
new_fname varchar(200) not null,
old_fname varchar(200) not null,
new_lname varchar(200) not null,
old_lname varchar(200) not null,
new_age int ,
old_age int ,
new_experience_year int , 
old_experience_year int ,
new_time_work enum('4','5','6') default('4'),
old_time_work enum('4','5','6') default('4'),
new_chef_salary dec(5,2) not null,
old_chef_salary dec(5,2) not null,
new_start_contract date not null,
old_start_contract date not null,
new_end_contract date not null,
old_end_contract date not null,
reg_date date,
reg_time date,
reg_username varchar(200)
);

create trigger chef_insert
after insert on chef
for each row
insert into chef_log
set
actionn='insert',
new_fname=new.fname,
new_lname=new.lname,
new_age=new.age,
new_experience_year=new.experience_year,
new_time_work=new.time_work,
new_chef_salary=new.chef_salary,
new_start_contract=new.start_contract,
new_end_contract=new.end_contract,
reg_date=current_date(),
reg_time=current_time(),
reg_username=current_user();

create trigger chef_delete
after delete on chef
for each row
insert into chef_log
set
actionn='delete',
old_fname=old.fname,
old_lname=old.lname,
old_age=old.age,
old_experience_year=old.experience_year,
old_time_work=old.time_work,
old_chef_salary=old.chef_salary,
old_start_contract=old.start_contract,
old_end_contract=old.end_contract,
reg_date=current_date(),
reg_time=current_time(),
reg_username=current_user();

create trigger chef_update
after update on chef
for each row
insert into chef_log
set
actionn='update',
old_fname=old.fname,
new_fname=new.fname,
old_lname=old.lname,
new_lname=new.lname,
old_age=old.age,
new_age=new.age,
old_experience_year=old.experience_year,
new_experience_year=new.experience_year,
old_time_work=old.time_work,
new_time_work=new.time_work,
old_chef_salary=old.chef_salary,
new_chef_salary=new.chef_salary,
old_start_contract=old.start_contract,
new_start_contract=new.start_contract,
old_end_contract=old.end_contract,
new_end_contract=new.end_contract,
reg_date=current_date(),
reg_time=current_time(),
reg_username=current_user();

-- data validation--
delimiter #
create trigger chef_validate
before insert on chef
for each row
begin
if new.experience_year<4 then
set new.experience_year=null;
end if;
end #
delimiter ;

create table item_log(
id int primary key auto_increment,
actionn varchar(200),
new_food_name varchar(200) not null,
new_price dec(6,3) not null,
new_food_type enum('meat','Kurdaware','fastfood','ice','drinks') default('ice'),
new_reg_date date not null,
old_food_name varchar(200) not null,
old_price dec(6,3) not null,
old_food_type enum('meat','Kurdaware','fastfood','ice','drinks') default('ice'),
old_reg_date date not null,
reg_date date,
reg_time date,
reg_username varchar(200)
);
-- data validation--
delimiter #
create trigger item_validate
before insert on item
for each row
begin
if new.price>30 then
set new.price=null;
end if;
end #
delimiter ;

create trigger item_insert
after insert on item
for each row
insert into item_log
set
actionn='insert',
new_food_name=new.food_name ,
new_price=new.price ,
new_food_type=new.food_type ,
new_reg_date=new.reg_date ,
reg_date=current_date(),
reg_time=current_time(),
reg_username=current_user();

create trigger item_delete
after delete on item
for each row
insert into item_log
set
actionn='delete',
old_food_name=old.food_name ,
old_price=old.price ,
old_food_type=old.food_type ,
old_reg_date=old.reg_date ,
reg_date=current_date(),
reg_time=current_time(),
reg_username=current_user();

create trigger item_update
after update on item
for each row
insert into item_log
set
actionn='update',
new_food_name=new.food_name ,
old_food_name=old.food_name ,
new_price=new.price ,
old_price=old.price ,
new_food_type=new.food_type ,
old_food_type=old.food_type ,
new_reg_date=new.reg_date ,
old_reg_date=old.reg_date ,
reg_date=current_date(),
reg_time=current_time(),
reg_username=current_user();

create table item_import_log(
id int unique,
actionn varchar(200) not null,
new_import_food_name varchar(200) primary key,
new_import_company enum('Everlast','Tarin') default('Tarin') not null,
new_import_price dec(6,2) not null,
new_import_date date not null,
new_expire_imDate date not null,
old_import_food_name varchar(200),
old_import_company enum('Everlast','Tarin') default('Tarin') not null,
old_import_price dec(6,2) not null,
old_import_date date not null,
old_expire_imDate date not null,
reg_date date,
reg_time date,
reg_username varchar(200)
);
create trigger item_import_insert
after insert on item_import
for each row
insert into item_import_log
set
actionn='insert',
new_import_food_name=new.import_food_name ,
new_import_company=new.import_company ,
new_import_price=new.import_price ,
new_import_date=new.import_date ,
new_expire_imDate=new.expire_imDate,
reg_date=current_date(),
reg_time=current_time(),
reg_username=current_user();

create trigger item_import_delete
after delete on item_import
for each row
insert into item_import_log
set
actionn='delete',
old_import_food_name=old.import_food_name,
old_import_company=old.import_company ,
old_import_price=old.import_price,
old_import_date=old.import_date ,
old_expire_imDate=old.expire_imDate,
reg_date=current_date(),
reg_time=current_time(),
reg_username=current_user();

create trigger item_import_update
after update on item_import
for each row
insert into item_import_log
set
actionn='update',
new_import_food_name=new.import_food_name ,
old_import_food_name=old.import_food_name,
new_import_company=new.import_company ,
old_import_company=old.import_company ,
new_import_price=new.import_price ,
old_import_price=old.import_price,
new_import_date=new.import_date ,
old_import_date=old.import_date ,
new_expire_imDate=new.expire_imDate,
old_expire_imDate=old.expire_imDate,
reg_date=current_date(),
reg_time=current_time(),
reg_username=current_user();

-- data validation--
delimiter #
create trigger item_import_validate
before insert on item_import
for each row
begin
if new.import_date>new.expire_imDate then
set new.import_date= null;
end if;
end #
delimiter ;

create table company_log(
id int unique auto_increment,
actionn varchar(200),
new_company_name enum('Everlast','Tarin') default('Tarin') primary key ,
new_phone_number int not null,
new_address varchar(200) not null,
old_company_name enum('Everlast','Tarin') default('Tarin') ,
old_phone_number int not null,
old_address varchar(200) not null,
reg_date date,
reg_time date,
reg_username varchar(200)
);
create trigger company_insert
after insert on company
for each row
insert into company_log
set
actionn='insert',
new_company_name=new.company_name,
new_phone_number=new.phone_number,
new_address=new.address,
reg_date=current_date(),
reg_time=current_time(),
reg_username=current_user();

create trigger company_delete
after delete on company
for each row
insert into company_log
set
actionn='delete',
old_company_name=old.company_name,
old_phone_number=old.phone_number,
old_address=old.address,
reg_date=current_date(),
reg_time=current_time(),
reg_username=current_user();

create trigger company_update
after update on company
for each row
insert into company_log
set
actionn='update',
new_company_name=new.company_name,
old_company_name=old.company_name,
new_phone_number=new.phone_number,
old_phone_number=old.phone_number,
new_address=new.address,
old_address=old.address,
reg_date=current_date(),
reg_time=current_time(),
reg_username=current_user();

create table item_type_log(
id int unique auto_increment,
actionn varchar(200),
new_foodType enum('meat','Kurdaware','fastfood','ice','drinks') default('ice') primary key,
old_foodType enum('meat','Kurdaware','fastfood','ice','drinks') default('ice') 
);
create trigger item_type_insert
after insert on item_type
for each row
insert into item_type_log
set
actionn='insert',
new_foodType=new.foodType,
reg_date=current_date(),
reg_time=current_time(),
reg_username=current_user();

create trigger item_type_delete
after delete on item_type
for each row
insert into item_type_log
set
actionn='delete',
old_foodType=old.foodType,
reg_date=current_date(),
reg_time=current_time(),
reg_username=current_user();

create trigger item_type_update
after update on item_type
for each row
insert into item_type_log
set
actionn='update',
new_foodType=new.foodType,
old_foodType=old.foodType,
reg_date=current_date(),
reg_time=current_time(),
reg_username=current_user();

/*insert into adminstration Values(1,'Ahmed','Muhammad','ahmed.muhammad@gmail.com','Manager');
insert into adminstration Values(2,'Sherwan','Jamal','sherwan.jamal@gmail.com','Supervisor');
insert into adminstration Values(3,'Zhala','Haji','zhala.haje@gmail.com','Supervisor');
insert into adminstration Values(4,'Muhammad','Shamal','muhammad.shamal@gmail.com','FB Supervisor');
insert into adminstration Values(5,'Sanar','Dler','sanar.dler@gmail.com','FB Supervisor');
insert into adminstration Values(6,'Rawezh','khasro','rawezh.khasro@gmail.com','Financial Manager');
insert into adminstration Values(7,'Mina','Yassin','mina.yassin@gmail.com','Financial Manager');*/

-- Privileges --
create user 'ahmed.muhammad'@'gmail' identified by '123abc';
grant all privileges on *.* to 'ahmed.muhammad'@'gmail';

revoke all privileges, grant option from 'ahmed.muhammad'@'gmail';

create user 'sherwan.jamal'@'gmail' identified by '123def';
grant select,create,drop,delete,insert on *.* to 'sherwan.jamal'@'gmail';

revoke select,create,drop,delete,insert,update on Resturant_Management.* from 'sherwan.jamal'@'gmail';

create user 'zhala.haje'@'gmail' identified by '123ghi';
grant select,create,drop,delete,insert on Resturant_Management.* to 'zhala.haje'@'gmail';

revoke select,create,drop,delete,insert on Resturant_Management.* from 'zhala.haje'@'gmail';

create user 'muhammad.shamal'@'gmail' identified by '123jkl';
grant select,create, drop,delete,insert,update on *.* to 'muhammad.shamal'@'gmail';

revoke  select,create, drop,delete,insert,update on *.* from'muhammad.shamal'@'gmail';

create user 'sanar.dler'@'gmail' identified by '123mno';
grant select,create, drop,delete,insert,update on *.* to 'sanar.dler'@'gmail';

revoke  select,create, drop,delete,insert,update on *.* from 'sanar.dler'@'gmail';

create user 'rawezh.khasro'@'gmail' identified by '123pqr';
grant select,update on *.* to 'rawezh.khasro'@'gmail';

revoke select,update on *.* from 'rawezh.khasro'@'gmail';

create user 'mina.yassin'@'gmail' identified by '123stu' ;
grant select,update on *.* to 'mina.yassin'@'gmail' ;

revoke select,update on *.* from 'mina.yassin'@'gmail' ;

DROP USER 'ahmed.muhammad'@'gmail' ;
DROP USER 'sherwan.jamal'@'gmail' ;
DROP USER 'zhala.haje'@'gmail' ;
DROP USER 'muhammad.shamal'@'gmail' ;
DROP USER 'sanar.dler'@'gmail' ;
DROP USER 'rawezh.khasro'@'gmail'  ;
DROP USER  'mina.yassin'@'gmail' ;

SELECT * FROM MYSQL.USER;
SELECT HOST, USER FROM MYSQL.USER;

-- SubQuery  && Reporting--

select fname,lname,experience_year,chef_salary+100
from chef
where (select avg(chef_salary)
from chef) and experience_year>=6;

select fname,lname,time_work,employee_salary+100
from employee
where (select avg(employee_salary)
from employee) and positionn='server';

select import_company,import_price,import_date
from item_import
where (select count(import_company)
from item_import)and import_date>'2022-3-3' and import_company='tarin';

select import_company,import_price,import_date
from item_import
where (select count(import_company)
from item_import)and import_date>'2022-3-3' and import_company='Everlast';

insert into benefit(benefit,food_type)
select avg(price),food_type
from item
where food_type='kurdaware' ;

insert into benefit(benefit,food_type)
select avg(price),food_type
from item
where food_type='fastfood' ;


















