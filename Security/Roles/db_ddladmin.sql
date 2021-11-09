
EXEC sp_addrolemember N'db_ddladmin', N'STAEDION\svcDwhReport'
ALTER ROLE [db_ddladmin] ADD MEMBER [powerbi]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [STAEDION\PowerBi]
GO
