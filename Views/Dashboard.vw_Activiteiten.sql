SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [Dashboard].[vw_Activiteiten]
AS
SELECT  
	  [fk_indicator_id]     = AC.[fk_indicator_id]
	 ,[Activiteit]          = AC.[Activiteit]
	 ,[Datum planning]      = AC.[Datum planning]
	 ,[Datum gerealiseerd]  = AC.[Datum gerealiseerd]
	 ,[Status]              = case 
								when [Datum gerealiseerd] <= [Datum planning] then 'Op tijd' 
								when [Datum planning] > GETDATE() then 'Lopend'
								when [Datum gerealiseerd] > [Datum planning] then 'Te laat klaar'
								else 'Te laat' 
							 end
	 ,[Waarde]              = AC.[Waarde]
FROM [Dashboard].[Activiteiten] AS AC
JOIN [Dashboard].[vw_Indicator] AS I
	 ON I.[id] = AC.[fk_indicator_id]
	 AND I.[Jaargang] = year(AC.[Datum planning])-- AND I.[Zichtbaar] = 1
GO
