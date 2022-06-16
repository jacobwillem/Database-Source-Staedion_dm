SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE  VIEW [Datakwaliteit].[vw_EenhedenAttentieSpeciekeVerhuringenInPeriode] 
AS
/* ###############################################################################################################
BETREFT: view tbv PowerBi dashboard Datakwaliteit

EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = N'BETREFT: controle op specifiek opgegeven eenheden: is er gedurende specifieke periode sprake van een opzegging huurcontract
Nav verzoek Marieke Peeters
20220409 Marieke Peeters, beschrijving gewenste trigger:
"Als er in tabel Opzegging verhuurcontract 11024057 een kaart ontstaat waarbij:
Ontvangen op >01-04-2022 AND Huurcontracteindedatum < 01-07-2022
AND OGEH-nr zit in de set van de 124 stuks
dan een mailtje naar admis verhuur?*
*evt. specifieker mailen:
als in Contactbeheer bij CB-VHTEAM staat RLTS-0171907 of RLTS-0171908 dan mailen naar admis verhuurcluster1 en anders naar admis verhuurcluster 2
'      ,@level0type = N'SCHEMA'
       ,@level0name = 'Datakwaliteit'
       ,@level1type = N'VIEW'
       ,@level1name = 'vw_EenhedenAttentieSpeciekeVerhuringenInPeriode';
GO

------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
------------------------------------------------------------------------------------------------------------------
20220408 JvdW Toegevoegd ovv Marieke

############################################################################################################### */
with cte_selectie as				-- Per mail door Femke opgegeven adhv filter wwd 1-5-2022 "FR-TEMP"
(	select 'OGEH-0000563' as Eenheidnr union
	select 'OGEH-0000565'  union
	select 'OGEH-0000567'  union
	select 'OGEH-0000571'  union
	select 'OGEH-0000573'  union
	select 'OGEH-0000576'  union
	select 'OGEH-0000578'  union
	select 'OGEH-0000581'  union
	select 'OGEH-0000582'  union
	select 'OGEH-0000590'  union
	select 'OGEH-0003646'  union
	select 'OGEH-0003647'  union
	select 'OGEH-0003657'  union
	select 'OGEH-0003658'  union
	select 'OGEH-0003680'  union
	select 'OGEH-0003681'  union
	select 'OGEH-0003682'  union
	select 'OGEH-0003683'  union
	select 'OGEH-0004468'  union
	select 'OGEH-0006332'  union
	select 'OGEH-0006338'  union
	select 'OGEH-0006339'  union
	select 'OGEH-0006344'  union
	select 'OGEH-0006345'  union
	select 'OGEH-0006596'  union
	select 'OGEH-0006597'  union
	select 'OGEH-0007266'  union
	select 'OGEH-0007268'  union
	select 'OGEH-0007270'  union
	select 'OGEH-0007474'  union
	select 'OGEH-0007482'  union
	select 'OGEH-0007483'  union
	select 'OGEH-0007491'  union
	select 'OGEH-0007492'  union
	select 'OGEH-0007500'  union
	select 'OGEH-0007501'  union
	select 'OGEH-0007509'  union
	select 'OGEH-0007510'  union
	select 'OGEH-0007518'  union
	select 'OGEH-0007519'  union
	select 'OGEH-0007527'  union
	select 'OGEH-0007528'  union
	select 'OGEH-0007536'  union
	select 'OGEH-0007539'  union
	select 'OGEH-0007542'  union
	select 'OGEH-0007545'  union
	select 'OGEH-0007546'  union
	select 'OGEH-0009694'  union
	select 'OGEH-0009705'  union
	select 'OGEH-0009712'  union
	select 'OGEH-0009718'  union
	select 'OGEH-0009724'  union
	select 'OGEH-0009750'  union
	select 'OGEH-0009751'  union
	select 'OGEH-0009757'  union
	select 'OGEH-0009759'  union
	select 'OGEH-0009762'  union
	select 'OGEH-0012397'  union
	select 'OGEH-0012402'  union
	select 'OGEH-0012426'  union
	select 'OGEH-0012455'  union
	select 'OGEH-0012460'  union
	select 'OGEH-0012464'  union
	select 'OGEH-0012469'  union
	select 'OGEH-0012475'  union
	select 'OGEH-0012482'  union
	select 'OGEH-0012486'  union
	select 'OGEH-0012487'  union
	select 'OGEH-0012492'  union
	select 'OGEH-0012496'  union
	select 'OGEH-0012498'  union
	select 'OGEH-0012501'  union
	select 'OGEH-0012518'  union
	select 'OGEH-0012530'  union
	select 'OGEH-0012532'  union
	select 'OGEH-0017273'  union
	select 'OGEH-0017274'  union
	select 'OGEH-0018210'  union
	select 'OGEH-0018211'  union
	select 'OGEH-0018213'  union
	select 'OGEH-0018239'  union
	select 'OGEH-0019167'  union
	select 'OGEH-0026690'  union
	select 'OGEH-0033928'  union
	select 'OGEH-0033930'  union
	select 'OGEH-0033932'  union
	select 'OGEH-0033934'  union
	select 'OGEH-0033936'  union
	select 'OGEH-0038916'  union
	select 'OGEH-0038923'  union
	select 'OGEH-0038924'  union
	select 'OGEH-0039409'  union
	select 'OGEH-0039410'  union
	select 'OGEH-0039416'  union
	select 'OGEH-0039417'  union
	select 'OGEH-0041017'  union
	select 'OGEH-0041495'  union
	select 'OGEH-0041512'  union
	select 'OGEH-0043010'  union
	select 'OGEH-0043029'  union
	select 'OGEH-0043030'  union
	select 'OGEH-0043031'  union
	select 'OGEH-0043032'  union
	select 'OGEH-0043035'  union
	select 'OGEH-0043036'  union
	select 'OGEH-0050597'  union
	select 'OGEH-0052381'  union
	select 'OGEH-0052443'  union
	select 'OGEH-0052455'  union
	select 'OGEH-0052456'  union
	select 'OGEH-0052469'  union
	select 'OGEH-0057315'  union
	select 'OGEH-0057334'  union
	select 'OGEH-0057335'  union
	select 'OGEH-0057587'  union
	select 'OGEH-0058825'  union
	select 'OGEH-0058826'  union
	select 'OGEH-0061284'  union
	select 'OGEH-0061285'  union
	select 'OGEH-0061286'  union
	select 'OGEH-0061287'  union
	select 'OGEH-0061288'  union
	select 'OGEH-0062993'  union
	select 'OGEH-0063029'  )
SELECT OGE.Nr_ AS eenheidnr,
       OGE.straatnaam + '  ' + OGE.huisnr_ + '  ' + OGE.Toevoegsel AS [Adres eenheid],
       CONT.[Verhuurteam],
       TT.Omschrijving AS [Omschrijving technisch type],
       OGE.[Target Group Code] AS Doelgroepcode,
       iif(CTE.Eenheidnr is not null, 'Let op: opzegging van een van de 124 adressen 2022 tussen 1-4-2022 en 30-6-2022',null) as Bevinding,
       CAST(GETDATE() AS DATE) AS [Gegenereerd op],


       -- tbv insert in RealisatieDetails tabel
       1 AS Waarde,
       CAST(GETDATE() AS DATE) AS Laaddatum,
       CONCAT('Adres: ',
                 OGE.straatnaam + ' ' + OGE.huisnr_ + ' ' + OGE.Toevoegsel,
                 '; ',
                 CONT.[Verhuurteam],
                 '; einde contract: ',
                 format(OPZ.[Einde huur klant], 'dd-MM-yyyy', 'nl-NL'),
                 '; datum ontvangst opzegging: ',
                 format(OPZ.[Ontvangst opzegging], 'dd-MM-yyyy', 'nl-NL')
             ) AS Omschrijving,
       NULL AS Teller,
       NULL AS Noemer,
       NULL AS Klantnr,
       CONVERT(DATE, NULL) AS datEinde,
       CONVERT(DATE, NULL) AS datIngang,
       NULL AS Hyperlink,
       NULL AS Gebruiker,
       NULL AS Relatienr
FROM empire_data.dbo.staedion$Oge AS OGE
join empire_data.dbo.[Staedion$Opzegging_verhuurcontract] as OPZ
on OPZ.Eenheidnr_ = OGE.Nr_
    LEFT OUTER JOIN empire_data.dbo.staedion$type AS TT
        ON TT.Code = OGE.[Type]
           AND TT.[Soort] <> 2
    OUTER APPLY staedion_dm.[Eenheden].[fn_ContactbeheerInclNaam](OGE.Nr_) AS CONT
left outer join cte_selectie as CTE on CTE.eenheidnr = OPZ.Eenheidnr_
WHERE OPZ.[Ontvangst opzegging] >= '20220401' 
and OPZ.[Einde huur klant] < '20220701'
AND CTE.eenheidnr is not null
;


GO
EXEC sp_addextendedproperty N'MS_Description', N'BETREFT: controle op specifiek opgegeven eenheden: is er gedurende specifieke periode sprake van een opzegging huurcontract
Nav verzoek Marieke Peeters
20220409 Marieke Peeters, beschrijving gewenste trigger:
"Als er in tabel Opzegging verhuurcontract 11024057 een kaart ontstaat waarbij:
Ontvangen op >01-04-2022 AND Huurcontracteindedatum < 01-07-2022
AND OGEH-nr zit in de set van de 124 stuks
dan een mailtje naar admis verhuur?*
*evt. specifieker mailen:
als in Contactbeheer bij CB-VHTEAM staat RLTS-0171907 of RLTS-0171908 dan mailen naar admis verhuurcluster1 en anders naar admis verhuurcluster 2
', 'SCHEMA', N'Datakwaliteit', 'VIEW', N'vw_EenhedenAttentieSpeciekeVerhuringenInPeriode', NULL, NULL
GO
