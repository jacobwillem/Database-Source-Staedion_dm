SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [Algemeen].[Eenheid BBSH]
as
select 
      id
      ,[omschrijving]
      ,[huurprijsklasse_std_descr]
      ,[huurprijsklasse_std_bedrag_descr]
      ,vanaf
      ,tot
      ,[Jaar BBSH] = convert(date,convert(varchar,YEAR(vanaf))+'01'+'01')

   

from [empire_dwh].[dbo].[bbshklasse]
      where YEAR(vanaf) > Year(dateadd(YY,-5,getdate()))
GO
