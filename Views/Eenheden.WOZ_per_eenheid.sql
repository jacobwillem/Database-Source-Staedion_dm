SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Eenheden].[WOZ_per_eenheid]
as 
SELECT Eenheid, [WOZ-objectnr] = (Select max([WOZ-objectnr_]) from empire_data.dbo.[Staedion$WOZgegevens] AS WOZ where Eenheidnr_ = Eenheid)
				,[2001],[2002],[2003],[2004],[2005],[2006],[2007],[2008],[2009],[2010]
				,[2011],[2012],[2013],[2014],[2015],[2016],[2017],[2018],[2019],[2020],[2021]
				,[2022],[2023],[2024],[2025],[2026],[2027],[2028],[2029],[2030]
from 

			(SELECT Eenheid, [WOZ-taxatiewaarde], Jaartal
			FROM staedion_dm.Eenheden.WOZ_per_jaar_per_eenheid ) as p  
			PIVOT  
			(  
							max (p.[WOZ-taxatiewaarde])  
							FOR Jaartal IN  
														(  [2001],[2002],[2003],[2004],[2005],[2006],[2007],[2008],[2009],[2010]
																		,[2011],[2012],[2013],[2014],[2015],[2016],[2017],[2018],[2019],[2020],[2021]
																		,[2022],[2023],[2024],[2025],[2026],[2027],[2028],[2029],[2030] )  
			) AS pvt  
			;





	
GO
