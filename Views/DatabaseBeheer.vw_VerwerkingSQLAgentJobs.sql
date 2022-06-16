SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [DatabaseBeheer].[vw_VerwerkingSQLAgentJobs] AS 
SELECT JOBS.[id],
       JOBS.[omgeving],
       JOBS.[Jobnaam],
       JOBS.[Datum],
       JOBS.[Begintijd],
       JOBS.[Eindtijd],
       JOBS.[Duur],
       JOBS.[Jobstatus],
       JOBS.[Server],
       JOBS.[Bron],
       JOBS.[DWH_versie_empire],
       JOBS.[DWH_versie_ETL],
       JOBS.[DWH_versie_maatwerk],
       JOBS.[Versie_Empire],
       JOBS.[Aantal_perioden],
       JOBS.[kopieren_data_status],
       JOBS.[Start_kopieren_data],
       JOBS.[Einde_kopieren_data],
       JOBS.[Duur_stap_kopieren],
       JOBS.[Verwerken_data_status],
       JOBS.[Begin_verwerken_data],
       JOBS.[Einde_verwerken_data],
       JOBS.[Duur_verwerken_data],
       JOBS.[Tijdelijke_correctie_status],
       JOBS.[Begin_tijdelijke_correctie],
       JOBS.[Einde_tijdelijke_correctie],
       JOBS.[Duur_tijdelijke_correctie],
       JOBS.[Process_status],
       JOBS.[Begin_process],
       JOBS.[Einde_process],
       JOBS.[Duur_process],
       JOBS.[ETL_tijdig],
       JOBS.[ETL_ok],
       JOBS.[Processen_ok],
       JOBS.[Opmerking_ETL],
       JOBS.[Opmerking_OLAP],
       INFO.Toelichting,
	   INFO.categorie AS Categorie
	   -- select *
FROM staedion_dm.DatabaseBeheer.VerwerkingSQLAgentJobs AS JOBS
    LEFT OUTER JOIN staedion_dm.DatabaseBeheer.TeLoggenSQLAgentJobs AS INFO
        ON INFO.omgeving = JOBS.omgeving
           AND INFO.job = JOBS.Jobnaam
		   WHERE JOBS.Datum >= '20210101';
GO
