-- 开启定时任务
set global event_scheduler =1; 

-- 设置定时任务
drop event if exists clearDB;
create event clearDB
on schedule every 5 second
on completion preserve disable
do call clearTable();

-- 开启定时任务
alter event clearDB on completion preserve enable;

-- 停止定时任务
alter event clearDB on completion preserve disable;

-- 查询定时任务
SELECT event_name,event_definition,interval_value,interval_field,status FROM information_schema.EVENTS;
