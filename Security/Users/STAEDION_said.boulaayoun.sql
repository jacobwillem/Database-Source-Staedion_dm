IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'STAEDION\said.boulaayoun')
CREATE LOGIN [STAEDION\said.boulaayoun] FROM WINDOWS
GO
CREATE USER [STAEDION\said.boulaayoun] FOR LOGIN [STAEDION\said.boulaayoun]
GO
