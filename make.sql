delimiter $$
drop procedure if exists clearTable $$
create procedure clearTable()
begin 
-- 设置表的总数
	set @tableNum = 0;
-- 当前游标	
	set @currNum = 0;
-- 当前表的名字
	set @tableName = '';
-- 获取当前数据库
	select (@dbName:=database());
-- 获取这个当前数据库的表的总数
	set @currSql = "select (@tableNum:=count(1)) as sum from information_schema.tables where table_schema= ? ";
	prepare stmt from @currSql;
	execute stmt using @dbName;
	deallocate prepare stmt;
	
	while @currNum < @tableNum do
-- 获取当前表名
		set @currSql = "select ( @tableName :=table_name) from information_schema.tables where table_schema= ? limit ? , 1";
		prepare stmt from @currSql;
		execute stmt using @dbName , @currNum;
		deallocate prepare stmt;
		
		set @currNum = @currNum + 1;
		
		insert into user values(default , @tableName , @currNum);
		
-- 对当前表做optimize 索引碎片整理
		/* set @optimizeSql = "optimize table ?";
		prepare stmt from @optimizeSql;
		execute stmt using @tableName;
		deallocate prepare stmt; */
		
-- 对当前表做analyze 	修复索引散列
		/* set @analyzeSql = "analyze table ?";
		prepare stmt from @analyzeSql;
		execute stmt using @tableName;
		deallocate prepare stmt; */
		
	end while;
end $$
delimiter ;


