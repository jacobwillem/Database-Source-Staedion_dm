IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'STAEDION\Domain Users')
CREATE LOGIN [STAEDION\Domain Users] FROM WINDOWS
GO
CREATE USER [STAEDION\Domain Users] FOR LOGIN [STAEDION\Domain Users]
GO
