SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [Algemeen].[Eenheid huur]
as

select 

       [Sleutel eenheid] = e.id
       ,fk_bbshklasse_id
      ,e.[ha_brutohuur_enh]
      ,e.[ha_nettohuur_enh]
      ,e.[kalehuur]
      ,e.[servicekosten]
      ,e.[moethuur]
      ,e.[subsidiabelehuur]
      ,e.[huursubsidie]
      ,e.[huur_maxredelijk_pct]
      ,e.[huur_maxredelijk]
      ,e.[streefhuur]
      ,[Eenheidnummer] = e.[bk_nr_]
      ,e.[da_bedrijf]
 
      
 FROM [empire_dwh].[dbo].[eenheid] as e 
      where da_bedrijf = 'Staedion'
GO
