SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [Datakwaliteit].[fnContactGegevens] ()
RETURNS TABLE
AS
/* ###################################################################################################
VAN         : MV
BETREFT     : Check op combinatie aanhefcode en geslacht
ZIE         : PBI "Dashboard Huurverhoging Datakwaliteit"
------------------------------------------------------------------------------------------------------
WIJZIGINGEN  
------------------------------------------------------------------------------------------------------
20210310 Gekopieerd van [empire_dwh].[dbo].[ITVF_hvh_datakwaliteit]
> hernoemd
> verwijzing naar empire_dwh mbt laaddatum eruit gehaald
> parameters @DatumVanaf/@DatumTotenMet eruit gehaald
------------------------------------------------------------------------------------------------------
CHECKS                   
------------------------------------------------------------------------------------------------------
-- CHECK: Is dit een afwijking ?
-- Contact aanhefcode is van rol KIND
select	[Klant Nummer], [Klant Aanhefcode], [Contact Nummer],[Contact Aanhefcode] , [Contact Geslacht],[Contact Afwijking DHR],*
from		empire_dwh.dbo.[ITVF_hvh_datakwaliteit] (default,default)
where	  [Contact Afwijking DHR] = 1
and		  [Contract Actief] = 'Ja'
and		 [Klant Nummer] = 'HRDR-0002650'

------------------------------------------------------------------------------------------------------
-- CHECK: [Contract Actief] conform empire_dwh ?
select [Klant Nummer], [Klant Aanwezig] ,*
from	 empire_dwh.dbo.[ITVF_hvh_datakwaliteit] (default,default)
where	 [Contract Actief]  = 'Ja'
and    [Klant Nummer] in 
				(select id from empire_dwh.dbo.klant where da_heeft_lopend_contract = 'Nee')

------------------------------------------------------------------------------------------------------
OMBOUWEN NAAR EMPIRE
wissen: "empire_data."
vervangen: contact_role door [contact role]
uit commentarieren: verwijzingen naar functies empire-link

------------------------------------------------------------------------------------------------------
STEEKPROEF

Declare @Nr as nvarchar(20) = 'HRDR-0013797'

select [Klant Nummer], [Klant Aanwezig] ,*
from	 empire_dwh.dbo.[ITVF_hvh_datakwaliteit] (default,default)
where	 [Klant Nummer] = @Nr

select aanhef, [Customer No_], [klantnaam] 
from	 empire_staedion_data.[dbo].[ITVfnContractaanhef] (@Nr)

select * 
from	 empire_data.dbo.Staedion$Additioneel
where	 [Customer No_] = @Nr

select * 
from	 empire_data.dbo.Staedion$Contract
where	 [Customer No_] = @Nr
order by Einddatum desc



select top 10 BRON.[No_], FUNC.aanhef, FUNC.huurder1
from	 empire_data.dbo.customer as BRON
cross apply empire_staedion_data.[dbo].[ITVfnContractaanhef] (No_)  as FUNC

------------------------------------------------------------------------------------------------------



-- op empire ?
-- vervang contact_Role door [Contact Role]
-- vervang empire_Data. door niets
-- functie voor link uit commentarieren


------------------------------------------------------------------------------------------------------
VERVERSEN DATA                  
------------------------------------------------------------------------------------------------------

################################################################################################### */	
RETURN
WITH woonplaats_afwijking
     AS (SELECT DISTINCT 
                City
         FROM empire_data.dbo.postcode),
     postcode_afwijking
     AS (SELECT DISTINCT 
                Code
         FROM empire_data.dbo.postcode)
     SELECT [Klant Aanwezig] = IIF(klant.No_ IS NULL, 'Nee', 'Ja'), 
            [Klant Nummer] = klant.No_, 
            [Klant Geslacht] = CASE klant.[Geslacht]
                                   WHEN 0
                                   THEN 'Onzijdig'
                                   WHEN 1
                                   THEN 'Man'
                                   WHEN 2
                                   THEN 'Vrouw'
                               END, 
            [Klant Aanhefcode] = IIF(klant.No_ IS NULL, NULL, huishouden.[Salutation Code]), 
            [Klant Aanhef] = aanhef.aanhef, 
            [Klant Huurder] = aanhef.huurder1, 
            [Klant Naam] = klant.Name, 
            [Klant Adres] = klant.Address, 
            [Klant Postcode] = klant.[Post Code], 
            [Klant Woonplaats] = klant.City, 
            [Klant Country Region Code] = klant.[Country_Region Code]
            ,

            --,[Klant Hyperlink Empire] = IIF(klant.No_ IS NULL, NULL, IIF(IIF(huishouden.[Salutation Code] = 'DHR', IIF(klant.[Geslacht] = 1, 0, 1), 0) + IIF(huishouden.[Salutation Code] = 'MEVR', IIF(klant.[Geslacht] = 2, 0, 1), 0) + IIF(huishouden.[Salutation Code] NOT IN ('DHR','MEVR'), IIF(klant.[Geslacht] = 0, 0, 1), 0) = 0, NULL, empire_staedion_data.empire.fnEmpireLink('Staedion', 21, 'No.=' + klant.No_ + '', 'view'))) 
            [Huishouden Aanwezig] = IIF(huishouden.No_ IS NULL, 'Nee', 'Ja'), 
            [Huishouden Nummer] = huishouden.No_, 
            [Huishouden Geslacht] = CASE huishouden.[Geslacht]
                                        WHEN 0
                                        THEN 'Onzijdig'
                                        WHEN 1
                                        THEN 'Man'
                                        WHEN 2
                                        THEN 'Vrouw'
                                    END, 
            [Huishouden Aanhefcode] = huishouden.[Salutation Code], 
            [Huishouden Naam] = huishouden.Name, 
            [Huishouden Achternaam] = huishouden.Surname, 
            [Huishouden Tussenvoegsels] = huishouden.[Middle Name], 
            [Huishouden Initialen] = huishouden.[Initials], 
            [Huishouden Adres] = huishouden.Address, 
            [Huishouden Postcode] = huishouden.[Post Code], 
            [Huishouden Woonplaats] = huishouden.City, 
            [Huishouden Country Region Code] = huishouden.[Country_Region Code]   ,
            --,[Huishouden Hyperlink Empire] = IIF(huishouden.No_ IS NULL, NULL, IIF(IIF(huishouden.[Salutation Code] = 'DHR', IIF(huishouden.[Geslacht] = 1, 0, 1), 0) + IIF(huishouden.[Salutation Code] = 'MEVR', IIF(huishouden.[Geslacht] = 2, 0, 1), 0) + IIF(huishouden.[Salutation Code] NOT IN ('DHR','MEVR'), IIF(huishouden.[Geslacht] = 0, 0, 1), 0) = 0, NULL, empire_staedion_data.empire.fnEmpireLink('Staedion', 5050, 'Nr.=' + huishouden.No_ + '', 'view'))) 
            [Huishouden Lengte Initialen] = LEN(huishouden.Initials), 
            [Contact Nummer] = contact.No_, 
            [Contact Geslacht] = CASE contact.[Geslacht]
                                     WHEN 0
                                     THEN 'Onzijdig'
                                     WHEN 1
                                     THEN 'Man'
                                     WHEN 2
                                     THEN 'Vrouw'
                                 END, 
            [Contact Aanhefcode] = contact.[Salutation Code], 
            [Contact Naam] = contact.Name, 
            [Contact Achternaam] = contact.Surname, 
            [Contact Adres] = contact.Address, 
            [Contact Postcode] = contact.[Post Code], 
            [Contact Woonplaats] = contact.City, 
            [Contact Country Region Code] = contact.[Country_Region Code], 
			[Contact Initialen] = contact.Initials,
			[Contact Tussenvoegsels] = contact.[Middle Name],
            [Contact Lengte Initialen] = LEN(contact.Initials), 
            [Contact Contactbeheerder] = contact.Contactbeheerder, 
            [Contact Eerste] = IIF(contact_role.[Show first] = 1, 'Ja', 'Nee'), 
            [Contact Rol] = contact_role.[Role Code]
            ,
            --,[Contact Hyperlink Empire] = IIF(contact.No_ IS NULL, NULL, IIF(IIF(contact.[Salutation Code] = 'DHR', IIF(contact.[Geslacht] = 1, 0, 1), 0) + IIF(contact.[Salutation Code] = 'MEVR', IIF(contact.[Geslacht] = 2, 0, 1), 0) + IIF(contact.[Salutation Code] NOT IN ('DHR','MEVR'), IIF(contact.[Geslacht] = 0, 0, 1), 0) = 0, NULL, empire_staedion_data.empire.fnEmpireLink('Staedion', 5050, 'Nr.=' + huishouden.No_ + '', 'view'))) 
            [Contract Actief] = COALESCE(contracten.[Contract], 'Nee'), 
            [Contract Meerdere Namen] = COALESCE(contracten_meerdere_namen.[Meerdere Namen], 'Nee'), 
            [Afwijking] = IIF(IIF(IIF(klant.No_ IS NULL, NULL, IIF(huishouden.[Salutation Code] = 'DHR', IIF(klant.[Geslacht] = 1, 0, 1), 0) + IIF(huishouden.[Salutation Code] = 'MEVR', IIF(klant.[Geslacht] = 2, 0, 1), 0) + IIF(huishouden.[Salutation Code] NOT IN('DHR', 'MEVR'), IIF(klant.[Geslacht] = 0, 0, 1), 0)) > 0, 'Ja', 'Nee') = 'Nee'
                              AND IIF(IIF(huishouden.No_ IS NULL, NULL, IIF(huishouden.[Salutation Code] = 'DHR', IIF(huishouden.[Geslacht] = 1, 0, 1), 0) + IIF(huishouden.[Salutation Code] = 'MEVR', IIF(huishouden.[Geslacht] = 2, 0, 1), 0) + IIF(huishouden.[Salutation Code] NOT IN('DHR', 'MEVR'), IIF(huishouden.[Geslacht] = 0, 0, 1), 0)) > 0, 'Ja', 'Nee') = 'Nee'
                              AND IIF(IIF(contact.No_ IS NULL, NULL, IIF(contact.[Salutation Code] = 'DHR', IIF(contact.[Geslacht] = 1, 0, 1), 0) + IIF(contact.[Salutation Code] = 'MEVR', IIF(contact.[Geslacht] = 2, 0, 1), 0) + IIF(contact.[Salutation Code] NOT IN('DHR', 'MEVR'), IIF(contact.[Geslacht] = 0, 0, 1), 0)) > 0, 'Ja', 'Nee') = 'Nee', 'Nee', 'Ja'), 
            [Klant Afwijking] = IIF(IIF(klant.No_ IS NULL, NULL, IIF(huishouden.[Salutation Code] = 'DHR', IIF(klant.[Geslacht] = 1, 0, 1), 0) + IIF(huishouden.[Salutation Code] = 'MEVR', IIF(klant.[Geslacht] = 2, 0, 1), 0) + IIF(huishouden.[Salutation Code] NOT IN('DHR', 'MEVR'), IIF(klant.[Geslacht] = 0, 0, 1), 0)) > 0, 'Ja', 'Nee'), 
            [Huishouden Afwijking] = IIF(IIF(huishouden.No_ IS NULL, NULL, IIF(huishouden.[Salutation Code] = 'DHR', IIF(huishouden.[Geslacht] = 1, 0, 1), 0) + IIF(huishouden.[Salutation Code] = 'MEVR', IIF(huishouden.[Geslacht] = 2, 0, 1), 0) + IIF(huishouden.[Salutation Code] NOT IN('DHR', 'MEVR'), IIF(huishouden.[Geslacht] = 0, 0, 1), 0)) > 0, 'Ja', 'Nee'), 
            [Contact Afwijking] = IIF(IIF(contact.No_ IS NULL, NULL, IIF(contact.[Salutation Code] = 'DHR', IIF(contact.[Geslacht] = 1, 0, 1), 0) + IIF(contact.[Salutation Code] = 'MEVR', IIF(contact.[Geslacht] = 2, 0, 1), 0) + IIF(contact.[Salutation Code] NOT IN('DHR', 'MEVR'), IIF(contact.[Geslacht] = 0, 0, 1), 0)) > 0, 'Ja', 'Nee'), 
            [Huishouden Contact Afwijking] = IIF(huishouden.No_ IS NULL, NULL, IIF((huishouden.Name = contact.Name
                                                                                    AND huishouden.[Geslacht] <> contact.[Geslacht])
                                                                                   OR (huishouden.Name = contact.Name
                                                                                       AND huishouden.[Salutation Code] <> contact.[Salutation Code]), 'Ja', 'Nee')), 
            [Huishouden Contact Geslacht Afwijking] = IIF(huishouden.No_ IS NULL, NULL, IIF(huishouden.Name = contact.Name
                                                                                            AND huishouden.[Geslacht] <> contact.[Geslacht], 'Ja', 'Nee')), 
            [Huishouden Contact Aanhefcode Afwijking] = IIF(huishouden.No_ IS NULL, NULL, IIF(huishouden.Name = contact.Name
                                                                                              AND huishouden.[Salutation Code] <> contact.[Salutation Code], 'Ja', 'Nee')), 
            [Contact Prio] = CASE
                                 WHEN IIF(contracten.[Contract] IS NULL, 0, 1) = 1
                                      AND contact_role.[Show first] = 1
                                 THEN 'Prio 1'
                                 WHEN IIF(contracten.[Contract] IS NULL, 0, 1) = 1
                                      AND contact_role.[Show first] = 0
                                      AND contact_role.[Role Code] IN('CONTRACT', 'CPALG')
                                 THEN 'Prio 2'
                                 WHEN IIF(contracten.[Contract] IS NULL, 0, 1) = 1
                                      AND contact_role.[Show first] = 0
                                      AND contact_role.[Role Code] NOT IN('CONTRACT', 'CPALG')
                                 THEN 'Prio 3'
                                 WHEN IIF(contracten.[Contract] IS NULL, 0, 1) = 0
                                 THEN 'Prio 4'
                             END, 
            [Huishouden Initialen Afwijking] = IIF(huishouden.Initials NOT LIKE '%Th%'
                                                   AND huishouden.Initials NOT LIKE '%Ch%'
                                                   AND huishouden.Initials NOT LIKE '%IJ%'
                                                   AND huishouden.Initials NOT LIKE '%Ph%', IIF(LEN(huishouden.Initials) - (LEN(huishouden.Initials) - LEN(REPLACE(huishouden.Initials, '.', ''))) <> LEN(huishouden.Initials) - LEN(REPLACE(huishouden.Initials, '.', '')), 'Ja', IIF(huishouden.Initials COLLATE Latin1_General_CS_AI <> UPPER(huishouden.Initials), 'Ja', 'Nee')), 'Nee'), 
            [Contact Initialen Afwijking] = IIF(contact.Initials NOT LIKE '%Th%'
                                                AND contact.Initials NOT LIKE '%Ch%'
                                                AND contact.Initials NOT LIKE '%IJ%'
                                                AND contact.Initials NOT LIKE '%Ph%', IIF(LEN(contact.Initials) - (LEN(contact.Initials) - LEN(REPLACE(contact.Initials, '.', ''))) <> LEN(contact.Initials) - LEN(REPLACE(contact.Initials, '.', '')), 'Ja', IIF(contact.Initials COLLATE Latin1_General_CS_AI <> UPPER(contact.Initials), 'Ja', 'Nee')), 'Nee'), 
            [Huishouden Achternaam Hoofdletter Afwijking] = IIF(huishouden.Surname COLLATE Latin1_General_CS_AI = UPPER(huishouden.Surname), 'Ja', IIF(LEFT(huishouden.Surname COLLATE Latin1_General_CS_AI, 1) <> UPPER(LEFT(huishouden.Surname, 1)), 'Ja', 'Nee')), 
            [Contact Achternaam Hoofdletter Afwijking] = IIF(contact.Surname COLLATE Latin1_General_CS_AI = UPPER(contact.Surname), 'Ja', IIF(LEFT(contact.Surname COLLATE Latin1_General_CS_AI, 1) <> UPPER(LEFT(contact.Surname, 1)), 'Ja', 'Nee')), 
            [Huishouden Achternaam Naam Afwijking] = IIF(CONCAT(IIF(huishouden.[Initials] <> '', CONCAT(huishouden.[Initials], ' '), ''), IIF(huishouden.[Middle Name] <> '', CONCAT(huishouden.[Middle Name], ' '), ''), huishouden.Surname) <> huishouden.Name, 'Ja', 'Nee'), 
            [Contact Achternaam Naam Afwijking] = IIF(CONCAT(IIF(contact.[Initials] <> '', CONCAT(contact.[Initials], ' '), ''), IIF(contact.[Middle Name] <> '', CONCAT(contact.[Middle Name], ' '), ''), contact.Surname) <> contact.Name, 'Ja', 'Nee'), 
            [Klant Adres Afwijking] = IIF((klant.[Country_Region Code] IN('NL', '')
                                           AND klant.[Address] NOT LIKE '%[A-Za-z]_[0-9]%'), 'Ja', 'Nee'), 
            [Huishouden Adres Afwijking] = IIF((huishouden.[Country_Region Code] IN('NL', '')
                                                AND huishouden.[Straat] NOT LIKE '%[A-Za-z]%')
                                               OR huishouden.Huisnummer <= 0, 'Ja', 'Nee'), 
            [Contact Adres Afwijking] = IIF((contact.[Country_Region Code] IN('NL', '')
                                             AND contact.[Straat] NOT LIKE '%[A-Za-z]%')
                                            OR contact.Huisnummer <= 0, 'Ja', 'Nee'), 
            [Klant Adres Leeg] = IIF((klant.[Address] = ''), 1, 0), 
            [Huishouden Adres Leeg] = IIF((huishouden.[Straat] = '')
                                          OR huishouden.Huisnummer = 0, 1, 0), 
            [Contact Adres Leeg] = IIF((contact.[Straat] = '')
                                       OR contact.Huisnummer = 0, 1, 0), 
            [Klant Postcode Afwijking] = IIF((postcode_afwijking_klant.[Code] IS NULL
                                              AND klant.[Country_Region Code] IN('NL', ''))
                                             OR (klant.[Post Code] IS NULL)
                                             OR (klant.[Post Code] = ''), 'Ja', 'Nee'), 
            [Huishouden Postcode Afwijking] = IIF((postcode_afwijking_huishouden.[Code] IS NULL
                                                   AND huishouden.[Country_Region Code] IN('NL', ''))
                                                  OR (huishouden.[Post Code] IS NULL)
                                                  OR (huishouden.[Post Code] = ''), 'Ja', 'Nee'), 
            [Contact Postcode Afwijking] = IIF((postcode_afwijking_contact.[Code] IS NULL
                                                AND contact.[Country_Region Code] IN('NL', ''))
                                               OR (contact.[Post Code] IS NULL)
                                               OR (contact.[Post Code] = ''), 'Ja', 'Nee'), 
            [Klant Postcode Leeg] = IIF((klant.[Post Code] IS NULL)
                                        OR (klant.[Post Code] = ''), 1, 0), 
            [Huishouden Postcode Leeg] = IIF((huishouden.[Post Code] IS NULL)
                                             OR (huishouden.[Post Code] = ''), 1, 0), 
            [Contact Postcode Leeg] = IIF((contact.[Post Code] IS NULL)
                                          OR (contact.[Post Code] = ''), 1, 0), 
            [Klant Woonplaats Afwijking] = IIF((woonplaats_afwijking_klant.[City] IS NULL
                                                AND klant.[Country_Region Code] IN('NL', ''))
                                               OR (klant.[City] IS NULL)
                                               OR (klant.[City] = ''), 'Ja', 'Nee'), 
            [Huishouden Woonplaats Afwijking] = IIF((woonplaats_afwijking_huishouden.[City] IS NULL
                                                     AND huishouden.[Country_Region Code] IN('NL', ''))
                                                    OR (huishouden.[City] IS NULL)
                                                    OR (huishouden.[City] = ''), 'Ja', 'Nee'), 
            [Contact Woonplaats Afwijking] = IIF((woonplaats_afwijking_contact.[City] IS NULL
                                                  AND contact.[Country_Region Code] IN('NL', ''))
                                                 OR (contact.[City] IS NULL)
                                                 OR (contact.[City] = ''), 'Ja', 'Nee'), 
            [Klant Woonplaats Leeg] = IIF((klant.[City] IS NULL)
                                          OR (klant.[City] = ''), 1, 0), 
            [Huishouden Woonplaats Leeg] = IIF((huishouden.[City] IS NULL)
                                               OR (huishouden.[City] = ''), 1, 0), 
            [Contact Woonplaats Leeg] = IIF((contact.[City] IS NULL)
                                            OR (contact.[City] = ''), 1, 0), 
            [Klant Adressering Afwijking] = IIF((klant.[Country_Region Code] IN('NL', '')
                                                 AND klant.[Address] NOT LIKE '%[A-Za-z]_[0-9]%')
                                                OR ((postcode_afwijking_klant.[Code] IS NULL
                                                     AND klant.[Country_Region Code] IN('NL', ''))
                                                    OR (klant.[Post Code] IS NULL)
                                                    OR (klant.[Post Code] = ''))
                                                OR ((woonplaats_afwijking_klant.[City] IS NULL
                                                     AND klant.[Country_Region Code] IN('NL', ''))
                                                    OR (klant.[City] IS NULL)
                                                    OR (klant.[City] = '')), 'Ja', 'Nee'), 
            [Huishouden Adressering Afwijking] = IIF(((huishouden.[Country_Region Code] IN('NL', '')
                                                       AND huishouden.[Straat] NOT LIKE '%[A-Za-z]%')
                                                      OR huishouden.Huisnummer <= 0)
                                                     OR ((postcode_afwijking_huishouden.[Code] IS NULL
                                                          AND huishouden.[Country_Region Code] IN('NL', ''))
                                                         OR (huishouden.[Post Code] IS NULL)
                                                         OR (huishouden.[Post Code] = ''))
                                                     OR ((woonplaats_afwijking_huishouden.[City] IS NULL
                                                          AND huishouden.[Country_Region Code] IN('NL', ''))
                                                         OR (huishouden.[City] IS NULL)
                                                         OR (huishouden.[City] = '')), 'Ja', 'Nee'), 
            [Contact Adressering Afwijking] = IIF(((contact.[Country_Region Code] IN('NL', '')
                                                    AND contact.[Straat] NOT LIKE '%[A-Za-z]%')
                                                   OR contact.Huisnummer <= 0)
                                                  OR ((postcode_afwijking_contact.[Code] IS NULL
                                                       AND contact.[Country_Region Code] IN('NL', ''))
                                                      OR (contact.[Post Code] IS NULL)
                                                      OR (contact.[Post Code] = ''))
                                                  OR ((woonplaats_afwijking_contact.[City] IS NULL
                                                       AND contact.[Country_Region Code] IN('NL', ''))
                                                      OR (contact.[City] IS NULL)
                                                      OR (contact.[City] = '')), 'Ja', 'Nee'), 
            [Klant E-mail] = klant.[E-Mail], 
            [Huishouden E-mail] = huishouden.[E-Mail], 
            [Contact E-mail] = contact.[E-Mail], 
            [Klant E-mail Leeg] = IIF((klant.[E-Mail] IS NULL)
                                      OR (klant.[E-Mail] = ''), 1, 0), 
            [Huishouden E-mail Leeg] = IIF((huishouden.[E-Mail] IS NULL)
                                           OR (huishouden.[E-Mail] = ''), 1, 0), 
            [Contact E-mail Leeg] = IIF((contact.[E-Mail] IS NULL)
                                        OR (contact.[E-Mail] = ''), 1, 0), 
            [Klant vs Contact E-mail Afwijking] = IIF(klant.[E-Mail] <> contact.[E-Mail], 'Ja', 'Nee')
            ,
            --,[Huishouden E-mail Afwijking] = IIF((huishouden.[E-Mail] IN ('NL','') AND huishouden.[Straat] NOT LIKE '%[A-Za-z]%') OR huishouden.Huisnummer <= 0, 'Ja', 'Nee')
            --,[Contact E-mail Afwijking] = IIF((contact.[E-Mail] IN ('NL','') AND contact.[Straat] NOT LIKE '%[A-Za-z]%') OR contact.Huisnummer <= 0, 'Ja', 'Nee') 
            [Laaddatum] = DateAdd(d,-1,getdate())
     FROM empire_data.dbo.Contact AS contact
          INNER JOIN empire_data.dbo.contact_role ON contact.No_ = contact_role.[Contact No_]
                                                     AND [Role Code] NOT IN('KIND')
          LEFT JOIN --empire_data.dbo.contact_role_history ON contact_role_history.[Contact No_] = contact_role.[Contact No_] AND contact_role_history.[Related Contact No_] = contact_role.[Related Contact No_] AND contact_role_history.[Unlinked] <> '1753-01-01 00:00:00.000' LEFT JOIN
          empire_data.dbo.Contact AS huishouden ON contact_role.[Related Contact No_] = huishouden.No_
          LEFT JOIN empire_data.dbo.Customer AS klant ON huishouden.[Customer No_] = klant.No_
          LEFT JOIN
     (
         SELECT DISTINCT 
                [Customer No_], 
                [Contract] = 'Ja'
         FROM empire_data.dbo.Staedion$Contract
         WHERE [Beëindigd] = 0
               AND [Dummy Contract] = 0
     ) contracten ON klant.No_ = contracten.[Customer No_]
          CROSS APPLY empire_staedion_data.dbo.[ITVfnContractaanhef](klant.No_) AS aanhef
          LEFT JOIN
     (
         SELECT [Customer No_], 
                [Meerdere Namen] = 'Ja'
         FROM empire_data.dbo.Staedion$Contract
         WHERE [Beëindigd] = 0
               AND [Dummy Contract] = 0
               AND [Customer No_] <> ''
               AND [Eenheidnr_] <> ''
         GROUP BY [Customer No_]
         HAVING COUNT(DISTINCT Naam) > 1
     ) contracten_meerdere_namen ON klant.No_ = contracten_meerdere_namen.[Customer No_]
          LEFT JOIN postcode_afwijking postcode_afwijking_klant ON postcode_afwijking_klant.[Code] = klant.[Post Code]
          LEFT JOIN postcode_afwijking postcode_afwijking_huishouden ON postcode_afwijking_huishouden.[Code] = huishouden.[Post Code]
          LEFT JOIN postcode_afwijking postcode_afwijking_contact ON postcode_afwijking_contact.[Code] = contact.[Post Code]
          LEFT JOIN woonplaats_afwijking woonplaats_afwijking_klant ON woonplaats_afwijking_klant.[City] = klant.[City]
          LEFT JOIN woonplaats_afwijking woonplaats_afwijking_huishouden ON woonplaats_afwijking_huishouden.[City] = huishouden.[City]
          LEFT JOIN woonplaats_afwijking woonplaats_afwijking_contact ON woonplaats_afwijking_contact.[City] = contact.[City]
;

/*	
	WHERE 
		IIF(
			IIF(IIF(klant.No_ IS NULL, NULL, IIF(huishouden.[Salutation Code] = 'DHR', IIF(klant.[Geslacht] = 1, 0, 1), 0) + IIF(huishouden.[Salutation Code] = 'MEVR', IIF(klant.[Geslacht] = 2, 0, 1), 0) + IIF(huishouden.[Salutation Code] NOT IN ('DHR','MEVR'), IIF(klant.[Geslacht] = 0, 0, 1), 0)) > 0, 'Ja', 'Nee') = 'Nee' AND 
			IIF(IIF(huishouden.No_ IS NULL, NULL, IIF(huishouden.[Salutation Code] = 'DHR', IIF(huishouden.[Geslacht] = 1, 0, 1), 0) + IIF(huishouden.[Salutation Code] = 'MEVR', IIF(huishouden.[Geslacht] = 2, 0, 1), 0) + IIF(huishouden.[Salutation Code] NOT IN ('DHR','MEVR'), IIF(huishouden.[Geslacht] = 0, 0, 1), 0)) > 0, 'Ja', 'Nee') = 'Nee' AND
			IIF(IIF(contact.No_ IS NULL, NULL, IIF(contact.[Salutation Code] = 'DHR', IIF(contact.[Geslacht] = 1, 0, 1), 0) + IIF(contact.[Salutation Code] = 'MEVR', IIF(contact.[Geslacht] = 2, 0, 1), 0) + IIF(contact.[Salutation Code] NOT IN ('DHR','MEVR'), IIF(contact.[Geslacht] = 0, 0, 1), 0)) > 0, 'Ja', 'Nee') = 'Nee'
		,'Nee', 'Ja') = 'Ja'
		OR contracten_meerdere_namen.[Meerdere Namen] = 'Ja'
		OR len(huishouden.Initials) > 4
		OR len(contact.Initials) > 4
	*/
GO
