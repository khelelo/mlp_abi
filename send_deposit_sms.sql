drop table sms;
# for deposits
create table sms
(
c_loadedtime timestamp not null default current_timestamp,
sms_db_name varchar(50) not null,
app_name varchar(50) not null,
contact_name varchar(50) not null, 
contact_no varchar(20) not null, 
flag_active int not null
);

#setting sms notification
insert into sms(sms_db_name,app_name,contact_name, contact_no,flag_active)
values('playsmsL','mpl','Khelelo Mahlatji','0726876562',1);

#adding a flag
ALTER TABLE `mpl`.`deposits` 
ADD COLUMN `flag_active` INT NULL DEFAULT 0 AFTER `Description`;

#insert sms destination
insert playsms_featureSchedule(c_timestamp, uid, name, message, schedule_rule, flag_active) 
select unix_timestamp(), 1,'MLP deposited',concat('MLP deposited amount: ', 'R',deposit_amount,' ', ddate, ' total amount paid to date ','R',sum(deposit_amount)), 0, 1 from mpl.deposits;

#procedure to insert into playsms destination
DELIMITER //
CREATE PROCEDURE send_deposit_sms()
   BEGIN
	insert playsms_featureSchedule(c_timestamp, uid, name, message, schedule_rule, flag_active) 
	select unix_timestamp(), 1,'MLP deposited',concat('MLP deposited amount: ', 'R',deposit_amount,' ', ddate, ' total amount paid to date ','R',sum(deposit_amount)), 0, 1 from mpl.deposits where flag_active = 0;
    
    update playsms_featureSchedule set flag_active = 1;

	insert playsmsL.playsms_featureSchedule_dst(c_timestamp, schedule_id, schedule, scheduled, name, destination)
	select unix_timestamp(),1,now(), date_sub(now(), interval 2 hour),  contact_name, contact_no FROM sms;
   END //
DELIMITER ;

