SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








create VIEW	[Medewerker].[TalentVisma]

AS 

-- NB: Pentaho gaat uit van Connect IT als bron voor resourcenr
-- In paar gevallen wijkt dit af van Empire, bleek te lastig om dit in de bron van Pentaho toe te voegen, nu op deze manier gedaan met cte naar empire toe
-- select No_, [User ID] from empire_data.dbo.staedion$resource where No_ = '1134'
-- select * from ConnectIT.[dbo].[user_user] where fullname = 'Mike Bodbijl' or external_id = '1134'

with cte_resoureces_empire as 
(select No_ as resourcenr, [User ID] as inlognaam, volgnr = row_number() over (partition by [User ID] order by [Last Date Modified]) 
-- select *
		from empire_data.dbo.staedion$resource
		where [User ID] <> ''
		) 


SELECT VIS.[Personeelsnr],
       VIS.[Aanhef],
       convert(nvarchar(100),NULL) AS [Burgerlijke status],
       VIS.[Voorletters],
       VIS.[Tussenvoegsel],
       VIS.[Voornaam],
       VIS.[Achternaam],
       VIS.[Roepnaam],
       VIS.[volledige_naam] AS [Volledige naam],
       VIS.[Geboortedatum],
       VIS.[Datum_in_dienst] AS [Datum in dienst],
       convert(nvarchar(20),NULL) AS [BSN],
       VIS.[contract_end] AS [Datum Uit Dienst],
       convert(nvarchar(100),[reden_einde_dienstverband]) AS [Reden einde dienstverband],
       VIS.[Afdeling],
       VIS.[Functie],
       VIS.[prive_telefoon] AS [Prive telefoon],
       VIS.[zakelijk_telefoon] AS [Zakelijk telefoon],
       VIS.[zakelijk_mobiel] AS [Zakelijk mobiel],
       VIS.[prive_email] AS [Prive email],
       VIS.[werk_email] AS [Werk email],
       VIS.[Inlognaam],
       VIS.[Geslacht],
       VIS.[EMP_id],
       VIS.[Empire_wrkn],
       VIS.[Empire_res] as [Empire_res OUD],
	   coalesce(RES.resourcenr, VIS.[Empire_res]) as [Empire_res],
       VIS.[org_level_1] AS [Organisatie niveau 1],
       VIS.[org_level_2] AS [Organisatie niveau 2],
       VIS.[Bedrijfsonderdeel],
       VIS.[org_level_3] AS [Organisatie niveau 3],
       VIS.[org_level_4] AS [Organisatie niveau 4],
       VIS.[org_level_5] AS [Organisatie niveau 5],
       VIS.[org_level_6] AS [Organisatie niveau 6],
       VIS.[org_level_7] AS [Organisatie niveau 7],
       VIS.[org_level_8] AS [Organisatie niveau 8],
       VIS.[KamerNr],
       VIS.[Locatie],
       VIS.[limiet_goedkeuring] AS [Limiet goedkeuring],
       VIS.[personeelsnr_manager] AS [Personeelsnr manager],
       VIS.[Leidinggevende],
       VIS.[Kostenplaats],
       VIS.[Maandsalaris],
       VIS.[salaris_per_uur] AS [Salaris per uur],
       VIS.[soort_arbeidscontract] AS [Soort arbeidscontract],
       VIS.[Deeltijdfactor],
       VIS.[Werknemersgroep],
       convert(nvarchar(250),NULL) AS [Bestandsnaam],
       VIS.[Tijdstempel]
FROM TS_data.visma.vault_werknemers AS VIS
left outer join cte_resoureces_empire as RES on RES.inlognaam = VIS.[Inlognaam] and RES.volgnr = 1				-- anders kunnen er dubbele regels ontstaan en geeft PBI een foutmelding
-- where  VIS.[volledige_naam] = 'Mike Bodbijl'


GO
