SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [Financieel].[fn_Grootboekdetails]
(@Rekeningnummer NVARCHAR(10) = NULL, 
 @Onderwerp      NVARCHAR(20) = NULL, 
 @DatumVanaf     DATE         = '20210101', 
 @DatumTotenMet  DATE         = '20211231'
)
RETURNS TABLE
AS
/* ########################################################################################################################## 
VAN 		  JvdW
Betreft		
--------------------------------------------------------------------------------------------------------------------------
TEST
--------------------------------------------------------------------------------------------------------------------------
-- performance
select * from [Financieel].[fn_Grootboekdetails] (default,'Huur',default,default)
select * from [Financieel].[fn_Grootboekdetails] ('A815320',default,default,default)

--------------------------------------------------------------------------------------------------------------------------
METADATA
--------------------------------------------------------------------------------------------------------------------------
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] staedion_dm, 'Financieel', 'fn_Grootboekdetails'

-- extended property toevoegen op object-niveau
USE staedion_dm;  
GO  
EXEC sys.sp_updateextendedproperty   
@name = N'MS_Description',   
@value = N'Functie voor ophalen van grootboekposten aangevuld met eenheid uit tabel  "Grootboekpost - Aanvullende informatie" - alleen van bedrijf Staedion',   
@level0type = N'SCHEMA', @level0name =  'Financieel',  
@level1type = N'FUNCTION',  @level1name = 'fn_Grootboekdetails'
;  
EXEC sys.sp_addextendedproperty   
@name = N'Auteur',   
@value = N'JvdW',   
@level0type = N'SCHEMA', @level0name =  'Financieel',  
@level1type = N'FUNCTION',  @level1name = 'fn_Grootboekdetails'
;  
EXEC sys.sp_addextendedproperty   
@name = N'VoorbeeldAanroep',   
@value = N'',   
@level0type = N'SCHEMA', @level0name =  'Financieel',  
@level1type = N'FUNCTION',  @level1name = 'fn_Grootboekdetails'
;  
EXEC sys.sp_addextendedproperty   
@name = N'CNSAfhankelijk',   
@value = N'Nee',   
@level0type = N'SCHEMA', @level0name =  'Financieel',  
@level1type = N'FUNCTION',  @level1name = 'fn_Grootboekdetails'

EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: Rekeningnr van de betreffende grootboekpost ',   
@level0type = N'SCHEMA', @level0name = 'Financieel',  
@level1type = N'FUNCTION',  @level1name = 'fn_Grootboekdetails',
@level2type = N'Column',@level2name = 'Rekeningnr';
;  

EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: Rekeningnaam van de betreffende grootboekpost ',   
@level0type = N'SCHEMA', @level0name = 'Financieel',  
@level1type = N'FUNCTION',  @level1name = 'fn_Grootboekdetails',
@level2type = N'Column',@level2name = 'Rekeningnaam';
;  

EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: Bedrag van betreffende grootboekpost',   
@level0type = N'SCHEMA', @level0name = 'Financieel',  
@level1type = N'FUNCTION',  @level1name = 'fn_Grootboekdetails',
@level2type = N'Column',@level2name = 'Bedrag';
;  
EXEC sys.sp_updateextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: Eenheidnr van betreffende grootboekpost volgens de tabel "Grootboekpost - Aanvullende informatie"',   
@level0type = N'SCHEMA', @level0name = 'Financieel',  
@level1type = N'FUNCTION',  @level1name = 'fn_Grootboekdetails',
@level2type = N'Column',@level2name = 'Eenheidnr';
;  
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: Documentnr zoals terug te vinden in de tabel grootboekpost',   
@level0type = N'SCHEMA', @level0name = 'Financieel',  
@level1type = N'FUNCTION',  @level1name = 'fn_Grootboekdetails',
@level2type = N'Column',@level2name = 'Documentnr';
;   
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: Boekdatum zoals terug te vinden in de tabel grootboekpost',   
@level0type = N'SCHEMA', @level0name = 'Financieel',  
@level1type = N'FUNCTION',  @level1name = 'fn_Grootboekdetails',
@level2type = N'Column',@level2name = 'Boekdatum';
;   
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: Kostenplaats zoals terug te vinden in de tabel grootboekpost',   
@level0type = N'SCHEMA', @level0name = 'Financieel',  
@level1type = N'FUNCTION',  @level1name = 'fn_Grootboekdetails',
@level2type = N'Column',@level2name = 'Kostenplaats';
;  
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: Volgnummer zoals terug te vinden in de tabel grootboekpost',   
@level0type = N'SCHEMA', @level0name = 'Financieel',  
@level1type = N'FUNCTION',  @level1name = 'fn_Grootboekdetails',
@level2type = N'Column',@level2name = 'Volgnummer';
;  
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: Omschrijving zoals terug te vinden in de tabel grootboekpost',   
@level0type = N'SCHEMA', @level0name = 'Financieel',  
@level1type = N'FUNCTION',  @level1name = 'fn_Grootboekdetails',
@level2type = N'Column',@level2name = 'Omschrijving';
;  
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: Productboekingsgroep zoals terug te vinden in de tabel grootboekpost',   
@level0type = N'SCHEMA', @level0name = 'Financieel',  
@level1type = N'FUNCTION',  @level1name = 'fn_Grootboekdetails',
@level2type = N'Column',@level2name = 'Productboekingsgroep';
; 
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: Broncode zoals terug te vinden in de tabel grootboekpost',   
@level0type = N'SCHEMA', @level0name = 'Financieel',  
@level1type = N'FUNCTION',  @level1name = 'fn_Grootboekdetails',
@level2type = N'Column',@level2name = 'Broncode';
;
EXEC sys.sp_updateextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: Zoals te vinden in in het scherm achter "Type" op de eenheidskaart ',   
@level0type = N'SCHEMA', @level0name = 'Financieel',  
@level1type = N'FUNCTION',  @level1name = 'fn_Grootboekdetails',
@level2type = N'Column',@level2name = 'Eenheidtype Corpodata';
; 
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: Cluster van betreffende eenheid per vandaag',   
@level0type = N'SCHEMA', @level0name = 'Financieel',  
@level1type = N'FUNCTION',  @level1name = 'fn_Grootboekdetails',
@level2type = N'Column',@level2name = 'Cluster';
;  
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: Administratief eigenaar van betreffende eenheid per vandaag',   
@level0type = N'SCHEMA', @level0name = 'Financieel',  
@level1type = N'FUNCTION',  @level1name = 'fn_Grootboekdetails',
@level2type = N'Column',@level2name = 'Administratief eigenaar';
;  
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: Gebruiker zoals terug te vinden in de tabel grootboekpost ',   
@level0type = N'SCHEMA', @level0name = 'Financieel',  
@level1type = N'FUNCTION',  @level1name = 'fn_Grootboekdetails',
@level2type = N'Column',@level2name = 'Gebruikers-id';
;  
EXEC sys.sp_addextendedproperty   
@name = N'MS_Description',   
@value = N'BRON: Vermeldt de periode waar de boekdatum betrekking op heeft - laaddatum is "vandaag"',   
@level0type = N'SCHEMA', @level0name = 'Financieel',  
@level1type = N'FUNCTION',  @level1name = 'fn_Grootboekdetails',
@level2type = N'Column',@level2name = 'Periode';
;   

--------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
--------------------------------------------------------------------------------------------------------------------------
20210216 Aangemaakt ter vervanging van variant met empire_dwh.dbo.f_grootboek 
20210429 Juridisch eigenaar toegevoegd
########################################################################################################################## */
     RETURN
     SELECT Rekeningnr = GL.[G_L Account No_], 
            Rekeningnaam = GA.[Name], 
            Bedrag = CONVERT(FLOAT, Amount), 
            Eenheidnr = OGE.[Realty Object No_], 
            Documentnr = GL.[Document No_], 
            Boekdatum = GL.[Posting Date], 
            Kostenplaats = GL.[Global Dimension 1 Code], 
            Volgnummer = GL.[Entry No_], 
            [Omschrijving] = GL.[Description], 
            [Productboekingsgroep ] = GL.[Gen_ Prod_ Posting Group], 
            [Broncode] = GL.[Source Code], 
            KENM.[Corpodata type], 
            Cluster = CL.Clusternr, 
            KENM.[Administratief eigenaar], 
			KENM.[Juridisch eigenaar],	-- JVDW 20210429 toegevoegd
            [Gebruikers-id] = GL.[User ID], 
            [Periode] = 'Van ' + CONVERT(NVARCHAR(20), COALESCE(@DatumVanaf, DATEFROMPARTS(YEAR(GETDATE()), 1, 1)), 105) + ' t/m ' + CONVERT(NVARCHAR(20), COALESCE(@DatumTotenMet, EOMONTH(GETDATE())), 105) + ' - verversdatum = ' + CONVERT(NVARCHAR(20), GETDATE(), 105)
     FROM empire_data.dbo.Staedion$G_L_Entry AS GL
          JOIN empire_data.dbo.Staedion$G_L_Account AS GA ON GL.[G_L Account No_] = GA.No_
          LEFT OUTER JOIN empire_data.dbo.Staedion$G_L_Entry___Additional_Data AS OGE ON GL.[Entry No_] = OGE.[G_L Entry No_]
          OUTER APPLY empire_staedion_Data.dbo.ITVfnCLusterBouwblok(OGE.[Realty Object No_]) AS CL
          OUTER APPLY staedion_dm.[Eenheden].[fn_Eigenschappen](OGE.[Realty Object No_], GETDATE()) KENM
     WHERE(GA.No_ = @Rekeningnummer
           OR (@Rekeningnummer IS NULL
		   AND GA.No_ IN
     ('A810200', 'A810250', 'A810300', 'A810350' -- jvdw 20180903 toegevoegd
               , 'A810400', 'A810450', 'A810500'
     )
               AND @Onderwerp = 'Huur'))
          --AND GL.[Source code] NOT LIKE '%DAEB%'
          --AND GL.[Source code] NOT LIKE '%BEHEER%'
          AND GL.[Posting Date] BETWEEN COALESCE(@DatumVanaf, DATEFROMPARTS(YEAR(GETDATE()), 1, 1)) AND COALESCE(@DatumTotenMet, EOMONTH(GETDATE()));
GO
EXEC sp_addextendedproperty N'Auteur', N'JvdW', 'SCHEMA', N'Financieel', 'FUNCTION', N'fn_Grootboekdetails', NULL, NULL
GO
EXEC sp_addextendedproperty N'CNSAfhankelijk', N'Nee', 'SCHEMA', N'Financieel', 'FUNCTION', N'fn_Grootboekdetails', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Functie voor ophalen van grootboekposten aangevuld met eenheid uit tabel  "Grootboekpost - Aanvullende informatie" - alleen van bedrijf Staedion
NB: verversdatum is datum vandaag - data van Empire is normaliter 1 dag oud
NB: Voor onderwerp Huur (tweede parameter - is uitbreidbaar) duurt het nu in februari 2 minuten om te verversen voor 2 maanden
', 'SCHEMA', N'Financieel', 'FUNCTION', N'fn_Grootboekdetails', NULL, NULL
GO
EXEC sp_addextendedproperty N'VoorbeeldAanroep', N'', 'SCHEMA', N'Financieel', 'FUNCTION', N'fn_Grootboekdetails', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'BRON: Administratief eigenaar van betreffende eenheid per vandaag', 'SCHEMA', N'Financieel', 'FUNCTION', N'fn_Grootboekdetails', 'COLUMN', N'Administratief eigenaar'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BRON: Bedrag van betreffende grootboekpost', 'SCHEMA', N'Financieel', 'FUNCTION', N'fn_Grootboekdetails', 'COLUMN', N'Bedrag'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BRON: Boekdatum zoals terug te vinden in de tabel grootboekpost', 'SCHEMA', N'Financieel', 'FUNCTION', N'fn_Grootboekdetails', 'COLUMN', N'Boekdatum'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BRON: Broncode zoals terug te vinden in de tabel grootboekpost', 'SCHEMA', N'Financieel', 'FUNCTION', N'fn_Grootboekdetails', 'COLUMN', N'Broncode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BRON: Cluster van betreffende eenheid per vandaag', 'SCHEMA', N'Financieel', 'FUNCTION', N'fn_Grootboekdetails', 'COLUMN', N'Cluster'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BRON: Documentnr zoals terug te vinden in de tabel grootboekpost', 'SCHEMA', N'Financieel', 'FUNCTION', N'fn_Grootboekdetails', 'COLUMN', N'Documentnr'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BRON: Eenheidnr van betreffende grootboekpost volgens de tabel "Grootboekpost - Aanvullende informatie"', 'SCHEMA', N'Financieel', 'FUNCTION', N'fn_Grootboekdetails', 'COLUMN', N'Eenheidnr'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BRON: Gebruiker zoals terug te vinden in de tabel grootboekpost ', 'SCHEMA', N'Financieel', 'FUNCTION', N'fn_Grootboekdetails', 'COLUMN', N'Gebruikers-id'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BRON: Kostenplaats zoals terug te vinden in de tabel grootboekpost', 'SCHEMA', N'Financieel', 'FUNCTION', N'fn_Grootboekdetails', 'COLUMN', N'Kostenplaats'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BRON: Omschrijving zoals terug te vinden in de tabel grootboekpost', 'SCHEMA', N'Financieel', 'FUNCTION', N'fn_Grootboekdetails', 'COLUMN', N'Omschrijving'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BRON: Vermeldt de periode waar de boekdatum betrekking op heeft - laaddatum is "vandaag"', 'SCHEMA', N'Financieel', 'FUNCTION', N'fn_Grootboekdetails', 'COLUMN', N'Periode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BRON: Productboekingsgroep zoals terug te vinden in de tabel grootboekpost', 'SCHEMA', N'Financieel', 'FUNCTION', N'fn_Grootboekdetails', 'COLUMN', N'Productboekingsgroep '
GO
EXEC sp_addextendedproperty N'MS_Description', N'BRON: Rekeningnaam van de betreffende grootboekpost ', 'SCHEMA', N'Financieel', 'FUNCTION', N'fn_Grootboekdetails', 'COLUMN', N'Rekeningnaam'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BRON: Rekeningnr van de betreffende grootboekpost ', 'SCHEMA', N'Financieel', 'FUNCTION', N'fn_Grootboekdetails', 'COLUMN', N'Rekeningnr'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BRON: Volgnummer zoals terug te vinden in de tabel grootboekpost', 'SCHEMA', N'Financieel', 'FUNCTION', N'fn_Grootboekdetails', 'COLUMN', N'Volgnummer'
GO
