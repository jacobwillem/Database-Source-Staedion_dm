SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [Verhuur].[AfgeslotenWoonfraudeDossiers_Correctie_TE_VERWIJDEREN_20201028MV]
as

SELECT ldo.Dossiertype Leefbaarheidsdossiertype
       ,ldo.[No_] Leefbaarheidsdossier
       ,ldo.[Description] [Omschrijving dossier]
       ,isnull(ldc.Code, 'Niet ingevuld') Dossiersoort
       ,ldc.[Description] Dossiersoortomschrijving
       ,spc.[Show on Form] [Toon op kaart]
       ,ldo.Afhandelingsreden
       ,iif(ldo.[Juridische kosten] = 1, 'Ja', 'Nee') [Juridische procedure]
       ,ldo.Dossierstatus
       ,ldo.Datum [Start dossier]
       ,(
              SELECT min(lda.[Date])
              FROM empire_data.dbo.Staedion$Livability_DossierAction_Line lda
              INNER JOIN empire_data.dbo.Staedion$Livability_Action act
                     ON lda.Actie = act.Code
                            AND act.[Gerechtelijke procedure] = 1
              WHERE lda.DossierNo_ = ldo.[No_]
              ) [Datum gerechtelijke procedure]
       ,CASE 
              WHEN ldo.[Dossierstatus] = 'VOLTOOID'
                     AND ldo.Afhandelingsreden IN (
                            'HUUROPZ'
                            ,'ONTRUIM'
                            )
                     THEN 'Telt mee voor KPI-woonfraude'
              WHEN ldo.[Dossierstatus] = 'VOLTOOID'
                     AND ldo.Afhandelingsreden NOT IN (
                            'HUUROPZ'
                            ,'ONTRUIM'
                            )
                     THEN 'Telt mee niet voor KPI-woonfraude'
              ELSE 'Lopende zaak'
              END [Opmerking]
       ,ldo.[Afgehandeld per] [Afhandeling dossier]
       ,datediff(d, ldo.Datum, ldo.[Afgehandeld per]) [Doorlooptijd]
       ,replace(oge.Straatnaam + ' ' + oge.[Huisnr_] + ' ' + oge.Toevoegsel, '  ', ' ') [Adres]
       ,oge.Nr_ sleutel_eenheid
       ,wkn.Code [Afgehandeld door]
			 -- mogelijkheid 1: ter voorkoming van dubbele records bij foutieve data
			 -- select * from empire_data.dbo.Staedion$Additioneel adi where Eenheidnr_ = 'OGEH-0057888'
       --,(
       --       SELECT max( adi.[Customer No_])
       --       FROM empire_data.dbo.Staedion$Additioneel adi
       --       WHERE adi.Eenheidnr_ = oge.[Nr_]
       --              AND adi.Ingangsdatum <= ldo.[Datum]
       --              AND (
       --                     adi.Einddatum = '1753-01-01'
       --                     OR adi.Einddatum >= ldo.[Datum]
       --                     )
       --       ) [Customer No_]
			 -- mogelijkheid 2
         ,(
              SELECT fk_klant_id
              FROM empire_dwh.dbo.[contract] con
              WHERE con.bk_eenheidnr = oge.[Nr_]
                     AND con.dt_ingang <= ldo.[Datum]
                     AND (
                            con.dt_einde IS NULL
                            OR con.dt_einde >= ldo.[Datum]
                            )
              ) [Customer No_]
       ,(
              SELECT distinct con.id
              FROM empire_dwh.dbo.[contract] con
              WHERE con.bk_eenheidnr = oge.[Nr_]
                     AND con.dt_ingang <= ldo.[Datum]
                     AND (
                            con.dt_einde IS NULL
                            OR con.dt_einde >= ldo.[Datum]
                            )
              ) Contract_id
FROM empire_data.dbo.Staedion$Livability_Dossier ldo
INNER JOIN empire_data.dbo.Staedion$Liv__Dossier_Closing_Reason lcr
       ON ldo.Afhandelingsreden = lcr.Code
INNER JOIN empire_data.dbo.salesperson_purchaser wkn
       ON ldo.[Assigned Person Code] = wkn.Code
LEFT OUTER JOIN empire_data.dbo.Staedion$Liv__Dossier_Type ldt
       ON ldo.Dossiertype = ldt.Code
LEFT OUTER JOIN empire_data.dbo.Staedion$Liv__Dossier_Specification spc
       ON ldo.No_ = spc.[Dossier No_]
LEFT OUTER JOIN empire_data.dbo.Staedion$Liv__Dossier_Complaint_Type ldc
       ON spc.Code = ldc.Code
LEFT OUTER JOIN empire_data.dbo.Staedion$OGE oge
       ON ldo.Eenheidnr_ = oge.Nr_
WHERE ldo.[Afgehandeld per] <> '1753-01-01'
       and ldo.[Dossierstatus] = 'VOLTOOID' and
       (ldt.code = 'ONRMGEBR' or ldc.[Description] IN ('Woonfraude', 'Hennep')) -- onrechtmatige bewoning or 
       and ldo.Afhandelingsreden in ('HUUROPZ', 'ONTRUIM')
      -- AND oge.nr_ = 'OGEH-0057888'
GO
