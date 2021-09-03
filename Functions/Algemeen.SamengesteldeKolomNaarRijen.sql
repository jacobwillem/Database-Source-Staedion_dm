SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   FUNCTION [Algemeen].[SamengesteldeKolomNaarRijen]
(
  @tekst NVARCHAR(4000),
  @scheidingsteken nvarchar(1)
) 
RETURNS TABLE WITH SCHEMABINDING AS
/* ################################################################################################
BETREFT: geen van een samengestelde kolom de items in rijen weer voorzien van een volgnr

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
--===== "Inline" CTE Driven "Tally Table" produces values from 1 up to 10,000...
     -- enough to cover VARCHAR(8000)
  WITH E1(N) AS (
                 SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL
                 SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL
                 SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1
                ),                          --10E+1 or 10 rows
       E2(N) AS (SELECT 1 FROM E1 a, E1 b), --10E+2 or 100 rows
       E4(N) AS (SELECT 1 FROM E2 a, E2 b), --10E+4 or 10,000 rows max
 cteTally(N) AS (--==== This provides the "base" CTE and limits the number of rows right up front
                     -- for both a performance gain and prevention of accidental "overruns"
                 SELECT TOP (ISNULL(DATALENGTH(@tekst),0)) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E4
                ),
cteStart(N1) AS (--==== This returns N+1 (starting position of each "element" just once for each delimiter)
                 SELECT 1 UNION ALL
                 SELECT t.N+1 FROM cteTally t WHERE SUBSTRING(@tekst,t.N,1) = @scheidingsteken
                ),
cteLen(N1,L1) AS(--==== Return start and length (for use in substring)
                 SELECT s.N1,
                        ISNULL(NULLIF(CHARINDEX(@scheidingsteken,@tekst,s.N1),0)-s.N1,8000)
                   FROM cteStart s
                )
--===== Do the actual split. The ISNULL/NULLIF combo handles the length for the final element when no delimiter is found.
 SELECT Id = ROW_NUMBER() OVER(ORDER BY l.N1),
        Tekstwaarde       = SUBSTRING(@tekst, l.N1, l.L1)
   FROM cteLen l
;
GO
