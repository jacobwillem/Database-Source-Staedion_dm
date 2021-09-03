SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   FUNCTION [Algemeen].[SamengesteldeKolomNaarRijen TEST]
(
  @tekst NVARCHAR(1000),
  @scheidingsteken nvarchar(1)
) 
RETURNS TABLE WITH SCHEMABINDING AS
/* ################################################################################################
BETREFT: van een samengestelde kolom de items in rijen weer voorzien van een volgnr

--------------------------------------------------------------------------------------------------
VERSIE 2
--------------------------------------------------------------------------------------------------
-- https://www.sqlservercentral.com/articles/tally-oh-an-improved-sql-8k-%e2%80%9ccsv-splitter%e2%80%9d-function
select * from [Algemeen].[SamengesteldeKolomNaarRijen] ('Financien: Financin & Verslaglegging',';')
select * from [Algemeen].[SamengesteldeKolomNaarRijen] ('Financien; Financin  Verslaglegging',';')
--------------------------------------------------------------------------------------------------
VERSIE 1
--------------------------------------------------------------------------------------------------
-- https://www.kodyaz.com/articles/t-sql-convert-split-delimeted-string-as-rows-using-xml.aspx
-- https://forums.asp.net/t/1965445.aspx?How+to+split+a+comma+separated+value+to+columns+in+sql+server
Valt over & ?
XML parsing: line 1, character 34, semicolon expected
select * from [Algemeen].[SamengesteldeKolomNaarRijen] ('Financien: Financin & Verslaglegging',';')
select * from [Algemeen].[SamengesteldeKolomNaarRijen] ('Financien; Financin  Verslaglegging',';')

ALTER   FUNCTION [Algemeen].[SamengesteldeKolomNaarRijen]
(
  @delimited nvarchar(max),
  @delimiter nvarchar(100)
) RETURNS @tbl TABLE
( id int identity(1,1),			-- I use this column for numbering splitted parts, not required for sql splitting string
  tekstwaarde nvarchar(max)
)
AS
BEGIN
  declare @xml xml
  --set @xml = N'<root><r>' + replace((SELECT @delimited AS [*] FOR XML PATH('') ), (SELECT @delimiter AS [*] FOR XML PATH('')) ,'</r><r>') + '</r></root>'
  set @xml = N'<root><r>' + replace((SELECT replace(@delimited,'&','&amp;') AS [*] FOR XML PATH('') ), (SELECT @delimiter AS [*] FOR XML PATH('')) ,'</r><r>') + '</r></root>'
  
  insert into @tbl(tekstwaarde)
  select
    r.value('.','varchar(max)') as item
  from @xml.nodes('//root/r') as records(r)

  RETURN
END


################################################################################################ */
 RETURN

SELECT 1 AS id
	,tekstwaarde = trim(cast('<t><![CDATA[' + replace(@tekst, ';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[1]', 'varchar(128)'))
UNION
SELECT 2 AS id
	,tekstwaarde = trim(cast('<t><![CDATA[' + replace(@tekst, ';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[2]', 'varchar(128)'))
UNION
SELECT 3 AS id
	,tekstwaarde = trim(cast('<t><![CDATA[' + replace(@tekst, ';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[3]', 'varchar(128)'))
UNION
SELECT 4 AS id
	,tekstwaarde = trim(cast('<t><![CDATA[' + replace(@tekst, ';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[4]', 'varchar(128)'))
UNION
SELECT 5 AS id
	,tekstwaarde = trim(cast('<t><![CDATA[' + replace(@tekst, ';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[5]', 'varchar(128)'))
UNION
SELECT 6 AS id
	,tekstwaarde = trim(cast('<t><![CDATA[' + replace(@tekst, ';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[6]', 'varchar(128)'))
UNION
SELECT 7 AS id
	,tekstwaarde = trim(cast('<t><![CDATA[' + replace(@tekst, ';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[7]', 'varchar(128)'))
UNION
SELECT 8 AS id
	,tekstwaarde = trim(cast('<t><![CDATA[' + replace(@tekst, ';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[8]', 'varchar(128)'))
UNION
SELECT 9 AS id
	,tekstwaarde = trim(cast('<t><![CDATA[' + replace(@tekst, ';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[9]', 'varchar(128)'))
UNION
SELECT 10 AS id
	,tekstwaarde = trim(cast('<t><![CDATA[' + replace(@tekst, ';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[10]', 'varchar(128)'))
GO
