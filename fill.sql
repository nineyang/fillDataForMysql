delimiter $$
drop procedure if exists fillTable $$
create procedure fillTable(in num int  , in tbName varchar(16))
begin 
-- 获取当前数据库
	select (@dbName:=database());
	set @tbName = tbName;
-- 获取表的字段总数
	set @currSql = "select count(1) from information_schema.COLUMNS where table_name = ? and table_schema = ? into @columnSum";
	prepare stmt from @currSql;
	execute stmt using @tbName , @dbName;
	deallocate prepare stmt;
	
	set @currNum = 0;
	
-- 这里设置随机的字符串
	set @chars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
	
	while @currNum < num do 
		-- 这里设置sql后面拼接
		set @insertSql = concat("insert into " , @tbName , " values ( ");
		set @columnNum = 1;
		while @columnNum <= @columnSum do
			set @value := '';
			set @currSql = "select (@column := COLUMN_NAME) , (@length := CHARACTER_MAXIMUM_LENGTH) , (@key := COLUMN_KEY) , (@type := DATA_TYPE) from information_schema.COLUMNS where table_name = ? and table_schema = ? limit ?";
			prepare stmt from @currSql;
			execute stmt using @tbName , @dbName , @columnNum;
			deallocate prepare stmt;
			
	-- 根据类型来填充数据
			if right(@type , 3) = 'int' then
				if @type = 'int' then
					set @value = 'default';
				else 
					set @value = floor(rand() * 100);
				end if;
			
			elseif right(@type , 4) = 'char' then
				set @counter = 0;
				while @counter < @length do    
	        		set @value = concat(@value,substr(@chars,ceil(rand()*(length(@chars)-1)),1));  
	    			set @counter = @counter + 1;
	    		end while;
	    		
	    		set @value = concat("'" , @value , "'");
	    		
	    	elseif @type = 'blob' or right(@type , 4) = 'text' then
	    		set @counter = 0;
	    	 	while @counter < 100 do    
	        		set @value = concat(@value,substr(@chars,ceil(rand()*(length(@chars)-1)),1));  
	    			set @counter = @counter + 1;
	    		end while;
	    		
	    		set @value = concat("'" , @value , "'");
	    		
	    	elseif @type = 'float' or @type = 'decimal' then
	    		set @value = round(rand() , 2);
	    	else 
	    		set @value = 'nine';
	    	end if;
	    	
	-- 判断这个数是否是最后一个
			if @columnNum = @columnSum then
				set @insertSql = concat(@insertSql , @value , ' )');
			else 
				set @insertSql = concat(@insertSql , @value , ' , ');
			end if;
			
			set @columnNum = @columnNum + 1;
		end while;
	-- 执行
		prepare stmt from @insertSql;
		execute stmt;
		deallocate prepare stmt;
		
		set @currNum = @currNum + 1;
	
	end while;
	
end $$
delimiter ;
