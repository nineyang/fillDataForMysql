-- 开启定时任务
set global event_scheduler =1; 

-- 设置定时任务(每个月1号凌晨3点执行)
drop event if exists clearDB;
create event clearDB
on schedule every 1 month starts date_add(date_add(date_sub(curdate(),interval day(curdate())-1 day),interval 1 month),interval 3 hour)
on completion preserve disable
do call clearTable();

-- 开启定时任务
alter event clearDB on completion preserve enable;

-- 停止定时任务
alter event clearDB on completion preserve disable;

-- 查询定时任务
SELECT event_name,event_definition,interval_value,interval_field,status FROM information_schema.EVENTS;
