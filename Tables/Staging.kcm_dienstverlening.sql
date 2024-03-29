CREATE TABLE [Staging].[kcm_dienstverlening]
(
[id] [int] NOT NULL,
[ingevulddate] [datetime2] NULL,
[ingevuld_date_sk] [float] NULL,
[ingevuldtimestamp] [datetime2] NULL,
[huurdernr] [nvarchar] (30) COLLATE Latin1_General_CI_AS NULL,
[telefoonnr1] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[telefoonnr2] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[telefoonnr3] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[emailadres] [nvarchar] (200) COLLATE Latin1_General_CI_AS NULL,
[postcode] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[straatnaam] [nvarchar] (200) COLLATE Latin1_General_CI_AS NULL,
[huisnr] [nvarchar] (60) COLLATE Latin1_General_CI_AS NULL,
[stad] [nvarchar] (200) COLLATE Latin1_General_CI_AS NULL,
[eenheidnr] [nvarchar] (60) COLLATE Latin1_General_CI_AS NULL,
[clusternr] [nvarchar] (60) COLLATE Latin1_General_CI_AS NULL,
[divisie] [nvarchar] (60) COLLATE Latin1_General_CI_AS NULL,
[klantbedrijf] [nvarchar] (200) COLLATE Latin1_General_CI_AS NULL,
[huurdernaam] [nvarchar] (200) COLLATE Latin1_General_CI_AS NULL,
[aanhef_huurdernaam] [nvarchar] (200) COLLATE Latin1_General_CI_AS NULL,
[werknemercode_behandelend_medewerker] [nvarchar] (100) COLLATE Latin1_General_CI_AS NULL,
[use_hrm_inlognaam] [nvarchar] (4000) COLLATE Latin1_General_CI_AS NULL,
[use_wrkn_number] [nvarchar] (30) COLLATE Latin1_General_CI_AS NULL,
[naam_behandelend_medewerker] [nvarchar] (100) COLLATE Latin1_General_CI_AS NULL,
[gegenereerd] [nvarchar] (4000) COLLATE Latin1_General_CI_AS NULL,
[contactdatum] [datetime2] NULL,
[contact_date_sk] [float] NULL,
[interactieid] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[use_interactieid] [nvarchar] (30) COLLATE Latin1_General_CI_AS NULL,
[interaction_id] [float] NULL,
[srvcverzoekid] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[use_reparatieverzoekid] [nvarchar] (30) COLLATE Latin1_General_CI_AS NULL,
[maintenance_id] [int] NULL,
[voornaam] [nvarchar] (200) COLLATE Latin1_General_CI_AS NULL,
[eenheidsadres] [nvarchar] (200) COLLATE Latin1_General_CI_AS NULL,
[clusternaam] [nvarchar] (200) COLLATE Latin1_General_CI_AS NULL,
[bouwblok] [nvarchar] (200) COLLATE Latin1_General_CI_AS NULL,
[bouwbloknaam] [nvarchar] (200) COLLATE Latin1_General_CI_AS NULL,
[algemene_tevredenheid] [nvarchar] (30) COLLATE Latin1_General_CI_AS NULL,
[meestpositief_anders] [bit] NULL,
[anders_meest_positief_str] [nvarchar] (2000) COLLATE Latin1_General_CI_AS NULL,
[meestpositief_vriendelijkheid] [bit] NULL,
[meestpositief_meedenken] [bit] NULL,
[meestpositief_wachttijd] [bit] NULL,
[meestpositief_deskundigheid] [bit] NULL,
[meestpositief_afspraakopvolging] [bit] NULL,
[meestpositief_weetikniet] [bit] NULL,
[positief_anders] [bit] NULL,
[anders_positief_str] [nvarchar] (2000) COLLATE Latin1_General_CI_AS NULL,
[positief_vriendelijkheid] [bit] NULL,
[positief_meedenken] [bit] NULL,
[positief_wachttijd] [bit] NULL,
[positief_deskundigheid] [bit] NULL,
[positief_afspraakopvolging] [bit] NULL,
[positief_weetikniet] [bit] NULL,
[meestnegatief_anders] [bit] NULL,
[anders_meest_negatief_str] [nvarchar] (2000) COLLATE Latin1_General_CI_AS NULL,
[meestnegatief_vriendelijkheid] [bit] NULL,
[meestnegatief_meedenken] [bit] NULL,
[meestnegatief_wachttijd] [bit] NULL,
[meestnegatief_deskundigheid] [bit] NULL,
[meestnegatief_afspraakopvolging] [bit] NULL,
[meestnegatief_weetikniet] [bit] NULL,
[negatief_anders] [bit] NULL,
[anders_negatief_str] [nvarchar] (2000) COLLATE Latin1_General_CI_AS NULL,
[negatief_vriendelijkheid] [bit] NULL,
[negatief_meedenken] [bit] NULL,
[negatief_wachttijd] [bit] NULL,
[negatief_deskundigheid] [bit] NULL,
[negatief_afspraakopvolging] [bit] NULL,
[negatief_weetikniet] [bit] NULL,
[gegevenskoppeling_toestemming] [bit] NULL,
[contact_toestemming] [bit] NULL,
[suggestie_gegeven] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[suggestie_string] [nvarchar] (3000) COLLATE Latin1_General_CI_AS NULL,
[negatieve_waardering_string] [nvarchar] (3000) COLLATE Latin1_General_CI_AS NULL,
[meestnegatieve_waardering_string] [nvarchar] (1000) COLLATE Latin1_General_CI_AS NULL,
[positieve_waardering_string] [nvarchar] (3000) COLLATE Latin1_General_CI_AS NULL,
[meestpositieve_waardering_string] [nvarchar] (1000) COLLATE Latin1_General_CI_AS NULL,
[iscontactdateapproximated] [bit] NULL,
[communicatie_medium] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[afdeling] [nvarchar] (60) COLLATE Latin1_General_CI_AS NULL,
[ext_id] [int] NULL
) ON [PRIMARY]
GO
