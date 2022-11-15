CREATE TABLE Previous_Versions
(
	storedProcedure VARCHAR(500),
	versionFrom INT,
	versionTo INT,
	PRIMARY KEY(versionFrom,versionTo)
)
GO

CREATE TABLE Current_Version
(
	currentVersion INT DEFAULT 0
)
GO


update Current_Version set currentVersion=0

select *from Current_Version
select *from Previous_Versions
insert into Current_Version(currentVersion) values(0)

delete from Previous_Versions
delete from Current_Version


go
create or alter procedure addTable (@Tablename varchar(100), @ColumnName varchar(50), @ColumnDataType varchar(100), @Nullable varchar(100),
@insertflag smallint)
as
begin
    declare @query as varchar(100)
	set @query = CONCAT('create table ' , @TableName ,' (' +@ColumnName + ' ' , @ColumnDataType, ' primary key ', @Nullable + ')')
    print(@query)
    exec (@query)
	if @insertflag=1 
	begin
		declare @v1 as int
		select @v1 = currentversion from Current_Version
		declare @query_addTable as varchar(500)
		set @query_addTable = 'addTable '+' , '+@Tablename +' , ' + @ColumnName +' , ' +@ColumnDataType+ ' , '+ @Nullable
		INSERT INTO Previous_Versions(storedProcedure,versionFrom,versionTo) VALUES (@query_addTable,@v1,@v1+1)
		update Current_Version set currentVersion = @v1+1
	end
end
go

select *from Current_Version
select *from Previous_Versions



exec addTable 'T1','c1','smallint','not null','1'
exec addTable 'T2','c2','smallint','not null','1'
exec addTable 'T3','c3','smallint','not null','1'
exec addTable 'T4','c4','smallint','not null','1'

exec reverseVersion'4','3'

exec advanceVersion '7','8'

exec reverseVersion '1','0'

exec advanceVersion '0','1'



drop table T1
drop table T2
drop table T3
drop table T4


select *from Current_Version

select *from Previous_Versions

delete from Previous_Versions
delete from Current_Version

drop table T1


create or alter procedure Undo_addTable (@Tablename varchar(100),@insertflag smallint)
as
begin
    declare @query as varchar(100)
    set @query = CONCAT('DROP TABLE ' , @TableName )
    print(@query)
    exec (@query)
end

exec Undo_addTable 'T1','0'

drop table T1


select *from Previous_Versions



create or alter procedure advanceVersion(@startVersion smallint,@endVersion smallint)
as
begin
	
	declare @v as smallint
	declare @query as varchar(500)
	declare @tabelname as varchar(MAX)
	declare @columnname as varchar(MAX)
	declare @nullable as varchar(MAX)
	declare @columntype as varchar(MAX)
	declare @constraintname as varchar(MAX)
	declare @foreigncolumn as varchar(MAX)
	declare @foreigntable as varchar(MAX)
	declare @foreignkeyvalue as varchar(MAX)
	

	set @query = ''
	select @query= storedProcedure  from Previous_Versions where versionTo=@endVersion


	declare @columnName_2 as varchar(500)
		if (@query like 'addTable%')
		begin

			select @columnName_2 = storedProcedure  from Previous_Versions where versionTo=@endVersion

			SELECT @tabelname = Result.value
			FROM
			(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
			FROM STRING_SPLIT(@columnName_2, ',')) AS Result
			Where Result.Row# = 2
			select @columnName_2 = storedProcedure  from Previous_Versions where versionTo=@endVersion


			SELECT @columnname = Result.value
			FROM
			(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
			FROM STRING_SPLIT(@columnName_2, ',')) AS Result
			Where Result.Row# = 3


			select @columnName_2 = storedProcedure  from Previous_Versions where versionTo=@endVersion
			SELECT @columntype = Result.value
			FROM
			(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
			FROM STRING_SPLIT(@columnName_2, ',')) AS Result
			Where Result.Row# = 4


			select @columnName_2 = storedProcedure  from Previous_Versions where versionTo=@endVersion
			SELECT @nullable = Result.value
			FROM
			(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
			FROM STRING_SPLIT(@columnName_2, ',')) AS Result
			Where Result.Row# = 5


			exec addTable @Tablename=@tabelname,@ColumnName=@columnname,@ColumnDataType=@columntype,@Nullable=@nullable,@insertflag=0

		end

		if (@query like 'addColumn%')
		begin
			declare @addColumn as varchar(500)
			select @addColumn= storedProcedure  from Previous_Versions where versionTo=@endVersion
			SELECT @tabelname = Result.value
			FROM
			(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
			FROM STRING_SPLIT(@addColumn, ',')) AS Result
			Where Result.Row# = 2

			SELECT @columnname = Result.value
			FROM
			(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
			FROM STRING_SPLIT(@addColumn, ',')) AS Result
			Where Result.Row# = 3

			SELECT @columntype = Result.value
			FROM
			(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
			FROM STRING_SPLIT(@addColumn, ',')) AS Result
			Where Result.Row# = 4

			SELECT @nullable = Result.value
			FROM
			(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
			FROM STRING_SPLIT(@addColumn, ',')) AS Result
			Where Result.Row# = 5

			exec addColumn @Tablename=@tabelname,@ColumnName=@columnname,@ColumnDataType=@columntype,@Nullable=@nullable,@insertflag=0

		end

		
		if (@query like  'addDefaultConstraint%')
		begin

			declare @addDefault as varchar(500)
			select @addDefault = storedProcedure  from Previous_Versions where versionTo=@endVersion

			SELECT @tabelname = Result.value
			FROM
			(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
			FROM STRING_SPLIT(@addDefault, ',')) AS Result
			Where Result.Row# = 2

			SELECT @columnname= Result.value
			FROM
			(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
			FROM STRING_SPLIT(@addDefault, ',')) AS Result
			Where Result.Row# = 3

			
			SELECT @foreignkeyvalue= Result.value
			FROM
			(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
			FROM STRING_SPLIT(@addDefault, ',')) AS Result
			Where Result.Row# = 4

			SELECT @constraintname= Result.value
			FROM
			(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
			FROM STRING_SPLIT(@addDefault, ',')) AS Result
			Where Result.Row# = 5

			exec addDefaultConstraint @TabelName=@tabelname,@Column=@columnname,@DefaultValue=@foreignkeyvalue,@ConstraintName=@constraintname,@insertflag=0
		
		end

		
		if (@query like 'addForeignKey%')
		begin
			declare @addForeignKey as varchar(500)
			select @addForeignKey= storedProcedure  from Previous_Versions where versionTo=@endVersion

			SELECT @tabelname = Result.value
			FROM
			(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
			FROM STRING_SPLIT(@addForeignKey, ',')) AS Result
			Where Result.Row# = 2


			SELECT @foreigntable = Result.value
			FROM
			(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
			FROM STRING_SPLIT(@addForeignKey, ',')) AS Result
			Where Result.Row# = 3

			
			SELECT @constraintname = Result.value
			FROM
			(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
			FROM STRING_SPLIT(@addForeignKey, ',')) AS Result
			Where Result.Row# = 4

			
			SELECT @columnname = Result.value
			FROM
			(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
			FROM STRING_SPLIT(@addForeignKey, ',')) AS Result
			Where Result.Row# = 5

			
			SELECT @foreigncolumn = Result.value
			FROM
			(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
			FROM STRING_SPLIT(@addForeignKey, ',')) AS Result
			Where Result.Row# = 6

			exec addForeignKey @tabelname=@tabelname,@foreigntabelname=@foreigntable,@constraintname=@constraintname,@column=@columnname,@foreigncolumn=@foreigncolumn,@insertflag=0

		end
		
		if (@query like 'ModifyColumnType%')
		begin
			declare @addColumnType as varchar(500)
			select @addColumnType = storedProcedure  from Previous_Versions where versionTo=@endVersion

			SELECT @tabelname = Result.value
			FROM
			(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
			FROM STRING_SPLIT(@addColumnType, ',')) AS Result
			Where Result.Row# = 2

			SELECT @columnname = Result.value
			FROM
			(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
			FROM STRING_SPLIT(@addColumnType, ',')) AS Result
			Where Result.Row# = 3

			SELECT @nullable= Result.value
			FROM
			(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
			FROM STRING_SPLIT(@addColumnType, ',')) AS Result
			Where Result.Row# = 5

			SELECT @columntype = Result.value
			FROM
			(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
			FROM STRING_SPLIT(@addColumnType, ',')) AS Result
			Where Result.Row# = 4

			exec ModifyColumnType @TabelName=@tabelname,@Column=@columnname,@ColumnType=@columntype,@Nullable=@nullable,@insertflag=0

		end

		delete Current_Version
		insert into Current_Version values(@endVersion)



end

exec advanceVersion '0','1'
exec advanceVersion '1','2'

delete Current_Version
insert into Current_Version values(1)


select top 1 value from Previous_Versions cross apply string_split(storedProcedure, ',') where versionTo=3

drop table T1




declare @v1 as varchar(MAX)
DECLARE @tags NVARCHAR(400) = 'addTable  T1 ,  c1,  smallint  ,  not null,    0,    1'  
SELECT @v1 = Result.value
FROM
(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
FROM STRING_SPLIT(@tags, ',')) AS Result
Where Result.Row# = 2
print(@v1)

exec reverseVersion '1','0'

exec advanceVersion '0','1'



create or alter procedure reverseVersion(@startVersion smallint,@endVersion smallint)
as
begin

	declare @v as smallint
	declare @query as varchar(500)
	declare @tabelname as varchar(MAX)
	declare @columnname as varchar(MAX)
	declare @nullable as varchar(MAX)
	declare @columntype as varchar(MAX)
	declare @constraintname as varchar(MAX)
	declare @foreigncolumn as varchar(MAX)
	declare @foreigntable as varchar(MAX)
	declare @foreignkeyvalue as varchar(MAX)
	set @v = @startVersion
	set @query = ''

	select @query=storedProcedure  from Previous_Versions where versionFrom=@endVersion

		if (@query like 'addTable%')
		begin
			declare @columnName_2 as varchar(500)
			select @columnName_2 = storedProcedure  from Previous_Versions where versionFrom=@endVersion
			SELECT @tabelname = Result.value
			FROM
			(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
			FROM STRING_SPLIT(@columnName_2, ',')) AS Result
			Where Result.Row# = 2
			exec Undo_addTable @Tablename=@tabelname,@insertflag=0

		end

		if (@query like 'addColumn%')
		begin
			declare @addColumn as varchar(500)
			select @addColumn = storedProcedure  from Previous_Versions where versionFrom=@endVersion

			SELECT @tabelname = Result.value
			FROM
			(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
			FROM STRING_SPLIT(@addColumn, ',')) AS Result
			Where Result.Row# = 2

			SELECT @columnname = Result.value
			FROM
			(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
			FROM STRING_SPLIT(@addColumn, ',')) AS Result
			Where Result.Row# = 3
			--SELECT @columntype = Result.value
			--FROM
			--(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
			--FROM STRING_SPLIT(@addColumn, ',')) AS Result
			--Where Result.Row# = 4
			--SELECT @nullable = Result.value
			--FROM
			--(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
			--FROM STRING_SPLIT(@addColumn, ',')) AS Result
			--Where Result.Row# = 5
			--print(@addColumn)
			exec Undo_addColumn @tableName=@tabelname,@Columnname=@columnname,@insertflag=0
		end


		if (@query like  'addDefaultConstraint%')
		begin
			declare @addDefault as varchar(500)
			select @addDefault = storedProcedure  from Previous_Versions where versionFrom=@endVersion
			SELECT @tabelname = Result.value
			FROM
			(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
			FROM STRING_SPLIT(@addDefault, ',')) AS Result
			Where Result.Row# = 2
			SELECT @constraintname= Result.value
			FROM
			(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
			FROM STRING_SPLIT(@addDefault, ',')) AS Result
			Where Result.Row# = 5
			exec Undo_addDefaultConstraint @TabelName=@tabelname,@ConstraintName=@constraintname

		end
		if (@query like 'addForeignKey%')
		begin
			declare @addForeignKey as varchar(500)
			select @addForeignKey= storedProcedure  from Previous_Versions where versionFrom=@endVersion
			SELECT @tabelname = Result.value
			FROM
			(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
			FROM STRING_SPLIT(@addForeignKey, ',')) AS Result
			Where Result.Row# = 2

			SELECT @constraintname = Result.value
			FROM
			(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
			FROM STRING_SPLIT(@addForeignKey, ',')) AS Result
			Where Result.Row# = 4
			exec Undo_addDefaultConstraint @TabelName=@tabelname,@ConstraintName=@constraintname
		end

		if (@query like 'ModifyColumnType%')
		begin
			declare @addColumnType as varchar(500)
			select @addColumnType = storedProcedure  from Previous_Versions where versionFrom=@endVersion
			SELECT @tabelname = Result.value
			FROM
			(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
			FROM STRING_SPLIT(@addColumnType, ',')) AS Result
			Where Result.Row# = 2
			SELECT @columnname = Result.value
			FROM
			(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
			FROM STRING_SPLIT(@addColumnType, ',')) AS Result
			Where Result.Row# = 3
			SELECT @nullable= Result.value
			FROM
			(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
			FROM STRING_SPLIT(@addColumnType, ',')) AS Result
			Where Result.Row# = 5
			SELECT @columntype = Result.value
			FROM
			(SELECT value, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Row#
			FROM STRING_SPLIT(@addColumnType, ',')) AS Result
			Where Result.Row# = 6
			exec ModifyColumnType @TabelName=@tabelname,@Column=@columnname,@ColumnType=@columntype,@Nullable=@nullable,@insertflag=0

		end
		select @v=versionFrom from Previous_Versions
		where versionTo=@v		
	
	update Current_Version set currentVersion=@endVersion
end


exec reverseVersion '4','3'


select *from string_split(storedProcedure,',')


exec advanceVersion '5', '6'


select *from Previous_Versions
select * from Current_Version




exec reverseVersion '1','0'
exec reverseVersion '4','3'
exec reverseVersion '3','2'

exec changeVersion '3'



exec advanceVersion '2','3'

exec reverseVersion '5','4'


select *from Previous_Versions
select *from Current_Version

drop table T1
drop table T2


create or alter procedure changeVersion(@version smallint)
as 
begin
	declare @currentVersion as smallint
	select @currentVersion = currentVersion from  Current_Version

	declare @temp as int


	while @currentVersion != @version
	begin
			
	if @currentVersion > @version
	begin
		set @temp=@currentVersion-1

		exec reverseVersion @currentVersion,@temp
		set @currentVersion = @currentVersion -1
	end	
	if @currentVersion<@version
	begin
		set @temp=@currentVersion + 1
		exec advanceVersion @currentVersion,@temp
		set @currentVersion = @currentVersion + 1 
	
	end

	delete Current_Version

	insert into Current_Version(currentVersion) values(@currentVersion)



	select @currentVersion = currentVersion from  Current_Version

	end

end



exec changeVersion '0'
exec changeVersion '1'
exec changeVersion '2'
exec changeVersion '3'
exec changeVersion '4'

select *from Current_Version
select *from Previous_Versions

declare @previousType as varchar(100)


select TOP(1) @previousType =	
			SELECT
			DATA_TYPE
			FROM INFORMATION_SCHEMA.COLUMNS 
			WHERE TABLE_NAME = 'T1' 
			AND COLUMN_NAME = 'n1_1';
print(@previousType)

--declare @sql nvarchar(max)
--set @sql = N'SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = T1 AND COLUMN_NAME = n1_1' + CONVERT(VARCHAR(12), @RowTo);
--exec sys.sp_executesql @sql, @previousType = '', @previousType = @previousType OUTPUT


go
create or alter procedure ModifyColumnType (@TabelName varchar(50), @Column varchar(50), @ColumnType varchar(50),@Nullable varchar(50),
@insertflag smallint)
as
begin
    declare @previousType as varchar(100)
	--set @previousType = 
	--print (@previousType)
    declare @query as varchar(100)
    set @query='alter table '  + @TabelName + ' alter column '+ @Column + ' ' + @ColumnType + ' ' + @Nullable
    print(@query)
	if @insertflag=1 
	begin
		declare @query1 as varchar(MAX)
		set @query1=(select T.DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS  T WHERE TABLE_NAME = @TabelName
					AND COLUMN_NAME = @Column)
		declare @query2 as varchar(MAX)
		set @query2=(select T.CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS  T WHERE TABLE_NAME = @TabelName 
					AND COLUMN_NAME = @Column)
		if @query2 is not NULL
			set @query1 = @query1+ '(' + @query2 + ')'
		declare @v1 as int
		select @v1 = currentversion from Current_Version
		declare @query_DataType as varchar(500)
		set @query_DataType = 'ModifyColumnType '+' , '+@TabelName+' , '+@Column+' , ' +@ColumnType+' , '+ @Nullable+ ' , '+@query1
		INSERT INTO Previous_Versions(storedProcedure,versionFrom,versionTo) VALUES (@query_DataType,@v1,@v1+1)
		update Current_Version set currentVersion = @v1+1
	end
	  exec (@query)
end
go

exec ModifyColumnType 'T1', 'N1', 'bigint', 'not null', '1'


select *from INFORMATION_SCHEMA.COLUMNS

create or alter procedure addColumn (@Tablename varchar(100), @ColumnName varchar(50), @ColumnDataType varchar(100), @Nullable varchar(100),
@insertflag smallint)
as
begin
    declare @query as varchar(100)
    set @query = CONCAT('ALTER TABLE ' , @TableName +' ADD '+@ColumnName+' ' + @ColumnDataType +' '+@Nullable )
    print(@query)
    exec (@query)
	if @insertflag=1
	begin
		--exec addColumn @Tablename=N'ProcedureProbing',@ColumnName=N'column1',@ColumnDataType=N'smallint',@Nullable=N'NOT NULL'
		declare @v1 as int
		select @v1 = currentVersion from Current_Version
		declare @query_addColumn as varchar(500)
		set @query_addColumn = 'addColumn '+' , '+@Tablename + ' , ' + @ColumnName +' , '+@ColumnDataType+ ' , '+ @Nullable
		INSERT INTO Previous_Versions(storedProcedure,versionFrom,versionTo) VALUES (@query_addColumn,@v1,@v1+1)
		update Current_Version set currentVersion = @v1+1
	end
end


exec addColumn @Tablename=N'T1',@ColumnName=N'N1',@ColumnDataType=N'int',@Nullable=N'not null',@insertflag=1
exec addColumn @Tablename=N'T2',@ColumnName=N'N2',@ColumnDataType=N'int',@Nullable=N'NOT NULL',@insertflag=1
exec addColumn @Tablename=N'T3',@ColumnName=N'N3',@ColumnDataType=N'int',@Nullable=N'NOT NULL',@insertflag=1
exec addColumn @Tablename=N'T4',@ColumnName=N'N4',@ColumnDataType=N'int',@Nullable=N'NOT NULL',@insertflag=1


delete from T4


create or alter procedure Undo_addColumn(@tableName varchar(50), @Columnname varchar(50),
@insertflag smallint)
as
begin
	declare @query as varchar(100)
    set @query = CONCAT('ALTER TABLE ' , @TableName +' DROP COLUMN '+@ColumnName+' ')
    print(@query)
    exec (@query)
end

exec Undo_addColumn 'T1','N1','0'



exec advanceVersion '0','1'
exec advanceVersion '1','2'
exec advanceVersion '2','3'
exec advanceVersion '3','4'
exec advanceVersion '4','5'
exec advanceVersion '5','6'
exec advanceVersion '6','7'
exec advanceVersion '7','8'
exec reverseVersion '8','7'
exec reverseVersion '7','6'
exec reverseVersion '6','5'
exec reverseVersion '5','4'
exec reverseVersion '4','3'
exec reverseVersion '3','2'
exec reverseVersion '2','1'
exec reverseVersion '1','0'


select *from Current_Version
select *from Previous_Versions


insert into Current_Version(currentVersion) values(0)

exec ModifyColumnName 'T1','N1','decimal','not null','1'
exec ModifyColumnType 'T2','N2','decimal','not null','1'
exec ModifyColumnType 'T3','N3','decimal','not null','1'
exec ModifyColumnType 'T4','N4','decimal','not null','1'

go
create or alter procedure addDefaultConstraint(@TabelName varchar(100), @Column varchar(100), @DefaultValue varchar(50), @ConstraintName varchar(100), 
@insertflag smallint)
as
begin
    declare @query as varchar(100)
    set @query = concat('alter table ',@TabelName,' add constraint ',@ConstraintName,' default ',@DefaultValue, ' for ',@Column)
    print(@query)
    exec (@query)
    if @insertflag=1
    begin
        declare @version as int
        select @version = currentVersion from Current_Version
        declare @query_constraint as varchar(500)
        set @query_constraint = 'addDefaultConstraint'+' , '+ @TabelName+' , '+@Column+' , '+@DefaultValue+ ' , '+ @ConstraintName
        insert into Previous_Versions(storedProcedure,versionFrom,versionTo) values (@query_constraint,@version,@version+1)
        update Current_Version set currentVersion = @version +1
    end
end
go


exec addDefaultConstraint 'T1','N1',"'test'",'constraint_1',1
exec addDefaultConstraint 'T2','N2','1000','constraint_2',1
exec addDefaultConstraint 'T3','N3','2000','constraint_3',1
exec addDefaultConstraint 'T4','N4','3000','constraint_4',1


exec reverseVersion '16','15'
exec reverseVersion '15','14'
exec reverseVersion '14','13'
exec reverseVersion '13','12'

exec reverseVersion '8','7'
exec reverseVersion '7','6'
exec reverseVersion '6','5'
exec reverseVersion '2','1'

exec advanceVersion '1','2'

delete Previous_Versions where versionTo=3


exec changeVersion '7'


select *from Current_Version
select *from Previous_Versions

update Current_Version set currentVersion=2


exec advanceVersion '12','13'
exec advanceVersion '13','14'
exec advanceVersion '14','15'
exec advanceVersion '15','16'

exec reverseVersion '12','11'
exec reverseVersion '11','10'
exec reverseVersion '10','9'
exec reverseVersion '9','8'

exec changeVersion '12'
exec changeVersion '13'
exec changeVersion '14'
exec changeVersion '15'


exec reverseVersion '20','19'
exec reverseVersion '19','18'
exec reverseVersion '18','17'




go
create or alter procedure Undo_addDefaultConstraint (@TabelName varchar(100),@ConstraintName varchar(100),
@insertflag smallint)
as
begin
    declare @query as varchar(100)
    set @query = concat('alter table ',@TabelName,' drop ',@ConstraintName)
    print(@query)
    exec (@query)
end
go





create or alter procedure addForeignKey (@tabelname varchar(100), @foreigntabelname varchar(100) , @constraintname varchar(100), @column varchar(100), @foreigncolumn varchar(100),
@insertflag smallint)
as
begin
    declare @query as varchar(max)
    set @query = 'alter table ' + @tabelname + ' add constraint ' + @constraintname + ' foreign key (' + @column + ') references ' + @foreigntabelname + '(' + @foreigncolumn + ')'
    print(@query)
    exec(@query)
	if @insertflag=1
	begin
		declare @version as int
		select @version = currentVersion from Current_Version
		declare @query_foreignkey as varchar(500)
		set @query_foreignkey = 'addForeignKey '+' , '+@tabelname+' , '+@foreigntabelname+' , '+@constraintname+ ' , '+ @column+' , '+@foreigncolumn 
        insert into Previous_Versions(storedProcedure,versionFrom,versionTo) values (@query_foreignkey,@version,@version+1)
        update Current_Version set currentVersion = @version +1
	end
end
go
--exec addForeignKey 'ProcedureProbing', 'Waiter', 'ConstraintWithWaiterID', 'column1', 'waiterID'

exec addForeignKey 'T1','T3','CONSTRAINT','N1_1','N3',1


exec addColumn 'T2','N6','smallint','not null',1
exec addColumn 'T2','N7','smallint','not null',1



exec addForeignKey 'T1','T3','Foreign_Constraint','N1_1','c3',1

exec addForeignKey 'T2','T4','constraint_name_2','N6','c4',1
exec addForeignKey 'T2','T4','constraint_name_3','N7','c4',1


go
create or alter procedure Undo_addForeignKey (@TabelName varchar(100),@ConstraintName varchar(100),
@insertflag smallint)
as
begin
    declare @query as varchar(100)
    set @query = concat('alter table ',@TabelName,' drop ',@ConstraintName)
    print(@query)
    exec (@query)
end
go


exec reverseVersion '18','17'
exec reverseVersion '17','16'




exec addTable 'T1','N1','smallint','not null',1

exec addColumn 'T1','N1_1','float','not null',1

exec ModifyColumnType 'T1','N1_1','varchar(50)','not null',1

exec addDefaultConstraint 'T1','N1_1','''test''','constraint_name',1

exec addTable 'T2','N2','int','not null',1

exec addColumn 'T2','N2_1','smallint','not null',1

exec addForeignKey 'T2','T1','FK_T2_T1','N2_1','N1',1


select *from Current_Version
select *from Previous_Versions
insert into Current_Version(currentVersion) values(0)
insert into Current_Version(currentVersion) values(7)
insert into Current_Version(currentVersion) values(4)


delete from Current_Version
delete from Previous_Versions

exec reverseVersion '7','6'

exec reverseVersion '6','5'

exec reverseVersion '5','4'

exec reverseVersion '4','3'

exec reverseVersion '3','2'

exec reverseVersion '2','1'

exec reverseVersion '1','0'







exec advanceVersion '0','1'

exec advanceVersion '1','2'

exec advanceVersion '2','3'

exec advanceVersion '3','4'

exec advanceVersion '4','5'

exec advanceVersion '5','6'


exec advanceVersion '6','7'



exec changeVersion '0'
exec changeVersion '7'






exec Undo_addColumn 'T2','N2_1','0'



drop table T2
drop table T1
