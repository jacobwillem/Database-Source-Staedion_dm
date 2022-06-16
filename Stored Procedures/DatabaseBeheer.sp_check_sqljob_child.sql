SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [DatabaseBeheer].[sp_check_sqljob_child] (@job varchar(50), @omgeving varchar(30) = 'Productie', @peildatum datetime = null)
as
BEGIN

/* #############################################################################################################################
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = N'
Procedure om de uitvoer van verschillende job te kunnen monitoren
		@job => naam van de te controleren job (voor DWH is een generieke naam Datawarehouse genomen)
		@omgeving => geeft de omgeving aan (productie, test of acceptatie)
		@peildatum => optionele parameter om gegevens van een specifieke peildatum op te kunnen halen, indien leeg
					  wordt de meest recente regel uit de jobhistory opgehaald
VOORWAARDE		EXEC sp_serveroption [S-DWH2012-accp],DATA ACCESS,TRUE 
'
       ,@level0type = N'SCHEMA'
       ,@level0name = 'DatabaseBeheer'
       ,@level1type = N'PROCEDURE'
       ,@level1name = 'sp_check_sqljob_child';
GO

--------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN 
--------------------------------------------------------------------------------------------------------------------------------
20170323: Versie 3: server down tijdens step 3, sysjobhistory 
			step 2 kopieren compleet
			step 3 afwezig 
			step 4 wel ed
			step 0 wordt niet vermeld
		=> om toch deze gevallen te loggen: niet alleen afvangen op step=0 
				exec [empire_staedion_data].dbo.dsp_log_job 'Datawarehouse','Productie','20170324' 
				exec [empire_staedion_data].dbo.dsp_log_job 'Datawarehouse','Productie','20170329' 
				exec [empire_staedion_data].dbo.dsp_log_job 'Datawarehouse','Acceptatie'
			#run vervangen door ##run voor controle-doeleinden
			zie ook /* LOS TE DRAAIEN BEGIN */ ..... /*LOS TE DRAAIEN EINDE */			
			exec dbo.dsp_check_sqljobs
20170331: Versie 4: Bij process data terughalen van bepaalde datum in het verleden: dan alleen kijken naar die jobs die op die dag of de dag ernaar geprocessed zijn
			Soms wordt job gestart vanaf begin verwerken data, vandaar duur load gewijzigd zodat duur dan berekend wordt vanaf verwerken data en niet vanaf kopieren data
20170406: Versie 5: exec [empire_staedion_data].dbo.dsp_log_job 'Datawarehouse','Productie' ,'20170405'
			> ETL = fout, stond op ok
20171221: Versie 6: toegevoegd tbv Opmerking_ETL
			> hst.[subject] <> 'ETL definition warning: 50212' and
20211228: JvdW Overgezet van empire_staedion_data.[dbo].[dsp_log_job] en in staedion_dm verwerkt
			> + aanpassing om start laden dwh goed weer te geven - nu heb je vaak een herstart en wordt pas gelogd bij herstart
NOG DOEN: loading_day zit ook in tabel, makkelijker op te halen (select * from empire_logic.dbo.dlt_loading_day)


--------------------------------------------------------------------------------------------------------------------------------
TESTEN 
--------------------------------------------------------------------------------------------------------------------------------
exec [staedion_dm].[DatabaseBeheer].sp_check_sqljob_child 'Datawarehouse','Productie' ,'20211227'
exec [staedion_dm].[DatabaseBeheer].sp_check_sqljob_child 'Datawarehouse','Productie' ,'20170330'
exec [staedion_dm].[DatabaseBeheer].sp_check_sqljob_child 'Datawarehouse','Productie' 
select * from ##run
--------------------------------------------------------------------------------------------------------------------------------
ACHTERGRONDINFORMATIE 
--------------------------------------------------------------------------------------------------------------------------------

############################################################################################################################# */


	set nocount on
	
	if object_id('tempdb..##res') is not null drop table ##res

	create table ##res (
	omgeving				nvarchar(20),
	Jobnaam					nvarchar(50),
	Datum					datetime,	
	Begintijd				datetime,
	Eindtijd				datetime,
	Duur					datetime,
	Jobstatus				tinyint,
	[Server]				varchar(30),
	Bron					nvarchar(50),
	DWH_versie_empire		nvarchar(50),
	DWH_versie_ETL			nvarchar(50),
	DWH_versie_maatwerk		nvarchar(50),
	Versie_Empire			nvarchar(50),
	Aantal_perioden			int,
	kopieren_data_status	tinyint,
	Start_kopieren_data		datetime,
	Einde_kopieren_data		datetime,
	Duur_stap_kopieren		datetime,
	Verwerken_data_status	tinyint,
	Begin_verwerken_data	datetime,
	Einde_verwerken_data	datetime,
	Duur_verwerken_data		datetime,
	Tijdelijke_correctie_status	tinyint,
	Begin_tijdelijke_correctie datetime,
	Einde_tijdelijke_correctie datetime,
	Duur_tijdelijke_correctie datetime,
	Process_status			tinyint,
	Begin_process			datetime,
	Einde_process			datetime,
	Duur_process			datetime,
	ETL_tijdig				tinyint,
	ETL_ok					tinyint,
	Processen_ok			tinyint,
	Opmerking_ETL			nvarchar(max),
	Opmerking_OLAP			nvarchar(max))

	if @job = 'Datawarehouse' -- dummynaam om gedetaileerde info van de jobs 'Laden DWH Empire' en 'Process Empire' samen op te halen
	begin
		if object_id('tempdb..##run') is not null drop table ##run

		-- vaststellen wanneer de job voor het laatst is uitgevoerd
		-- V3: apart voor laden en aprt voor processnn: alleen processen meenemen van dag erna
		; with tyd1 (job, lastrun, run_time, volgnr)
		as (select iif(j.name = 'Laden DWH Empire', 'Laden', 'Process') job, h.run_date lastrun, h.run_time, row_number() over (partition by iif(j.name = 'Laden DWH Empire', 'Laden', 'Process') order by run_date desc, h.run_time desc) volgnr
			from msdb.dbo.sysjobs j inner join msdb.dbo.sysjobhistory h
			on j.job_id = h.job_id
			where j.name in ('Laden DWH Empire') and
			(h.step_id = 0 ) and -- RVG alleen als step_id 0 bestaat loopt de job niet meer
								-- Als server herstart wordt, heb je ook geen step_id 0
			-- or h.step_name = 'DB-engine fine-tunen voor ETL') and		-- Als server na deze stap herstart wordt heb je geen step_id = 0 maar wel deze nog, alleen dan andere fouten
			(h.run_date = convert(int, convert(varchar(8), @peildatum, 112)) or @peildatum is null))
		select tyd1.job, tyd1.lastrun, tyd1.run_time
		into ##run
		from tyd1
		where tyd1.volgnr = 1

		; with tyd2 (job, lastrun, run_time, volgnr)
		as (select iif(j.name = 'Laden DWH Empire', 'Laden', 'Process') job, h.run_date lastrun, h.run_time, row_number() over (partition by iif(j.name = 'Laden DWH Empire', 'Laden', 'Process') order by run_date desc, h.run_time desc) volgnr
			from msdb.dbo.sysjobs j inner join msdb.dbo.sysjobhistory h
			on j.job_id = h.job_id
			where j.name in ('Process Empire', 'Process Empire-kubus Productie') and
			h.step_id = 0 and -- RVG alleen als step_id 0 bestaat loopt de job niet meer
			--(h.run_date >= convert(int, convert(varchar(8), dateadd(d,0,@peildatum), 112)) or @peildatum is null))
			(
				(h.run_date between convert(int, convert(varchar(8), dateadd(d,0,@peildatum), 112))
						and convert(int, convert(varchar(8), dateadd(d,1,@peildatum), 112)))
						 or @peildatum is null)
						 )
		insert into ##run
		select tyd2.job, tyd2.lastrun, tyd2.run_time
		from tyd2
		where tyd2.volgnr =1

		-- V3: Processen voor Laden > dan verkeerde te pakken en niet meenemen (zitten in 2 jobs - anders had je dat issue niet)
		delete	
		from	##run
		where	job = 'Process' 
		and		lastrun <= (select lastrun from ##run where job = 'Laden' )
		and		run_time < (select run_time from ##run where job = 'Laden' )

		insert into ##res (Jobnaam, omgeving, datum) 
			select @job, @omgeving, convert(date, convert(varchar(8), run.lastrun), 108) 
			from ##run run
			where run.job = 'Laden'

		-- versies bepalen
		update ##res set DWH_versie_empire = ver.DWH_versie_empire,
			DWH_versie_ETL = ver.DWH_versie_ETL,
			DWH_versie_maatwerk = ver.DWH_versie_maatwerk,
			Versie_Empire = ver.Versie_Empire
		from ##res inner join (
			select max(iif(dat.module = 'DWH empire', dat.versie,'')) DWH_versie_empire,
				max(iif(dat.module = 'DWH ETL Library', dat.versie,'')) DWH_versie_ETL,
				max(iif(dat.module = 'DWH empire_staedion', dat.versie,'')) DWH_versie_maatwerk,
				max(iif(dat.module = 'Empire', dat.versie,'')) Versie_Empire
			from (select 'DWH ' + rel.module module, 
					rel.[version] + ' (' + convert(varchar(10), rel.install_date, 105) + ' ' + convert(varchar(10), rel.install_date, 108) + ')' [versie], 
					row_number() over (partition by rel.module order by rel.install_date desc) volgnr
				from empire_logic.dbo.dlt_releases rel
				where rel.module in ('ETL Library', 'empire', 'empire_staedion')
				union
				select 'Empire', 
					ver.Versienr_ + ' (' + convert(varchar(10), ver.Datum_tijd, 105) + ' ' + convert(varchar(10), ver.Datum_tijd, 108) + ')' [versie], 
					row_number() over (order by ver.Datum_tijd desc)
				from empire_data.dbo.empire_Versie ver) dat
			where dat.volgnr = 1) ver
		on 1 = 1

		-- aantal perioden
		update ##res set Aantal_perioden = (select count(*) 
			from    empire_logic.dbo.dlt_load_Status_hist 
			where   dsp_name = 'dsp_load_d_bestand'
			and     loading_day = (select convert(date, convert(varchar(8), run.lastrun), 108) from ##run run where run.job = 'Laden')
			and     comment = 'end')

		-- ophalen gegevens linked server
		if object_id('tempdb..##srv') is not null drop table ##srv

		select srv_name, srv_datasource, srv_cat
		into ##srv
		from openquery([S-DWH2012-db], 'exec sp_linkedservers')
		where srv_name = 'EMPIRE'

		update ##res set server = srv.srv_name, bron = '[' + srv.srv_datasource + '].[' + srv.srv_cat + ']' 
		from ##res inner join ##srv srv
		on 1 = 1

		-- resultaten afzonderlijke stappen bepalen
		update ##res set Begintijd = (case when job.Start_kopieren_data = '1900-01-01 00:00:00.000' 
														then job.Begin_verwerken_data else job.Start_kopieren_data end ),
			Eindtijd = job.Eindtijd,
--			Duur = dateadd(s, datediff(s, job.Start_kopieren_data, job.Eindtijd), '1753-01-01'),
			Duur = case when job.Eindtijd < (case when job.Start_kopieren_data = '1900-01-01 00:00:00.000' 
														then job.Begin_verwerken_data else job.Start_kopieren_data end )
												then null 
						else dateadd(s, datediff(s, (case when job.Start_kopieren_data = '1900-01-01 00:00:00.000' 
														then job.Begin_verwerken_data else job.Start_kopieren_data end )
													, job.Eindtijd), '1753-01-01') end,
			Jobstatus = job.ETL_ok,																					-- JvdW 20211228 was job.ETL_ok * job.Processen_ok
			kopieren_data_status = job.kopieren_data_status,
			Start_kopieren_data = job.Start_kopieren_data,
			Einde_kopieren_data = job.Einde_kopieren_data,
			Duur_stap_kopieren = job.Duur_stap_kopieren,
			Verwerken_data_status = job.Verwerken_data_status,
			Begin_verwerken_data = job.Begin_verwerken_data,
			Einde_verwerken_data = job.Einde_verwerken_data,
			Duur_verwerken_data = dateadd(s,DATEDIFF(SECOND , job.Begin_verwerken_data,job.Einde_verwerken_data), '1753-01-01'),				-- JvdW 20211228 was job.Duur_verwerken_data,
			Tijdelijke_correctie_status = job.Tijdelijke_correctie_status,
			Begin_tijdelijke_correctie = job.Begin_tijdelijke_correctie,
			Einde_tijdelijke_correctie = job.Einde_tijdelijke_correctie,
			Duur_tijdelijke_correctie = job.Duur_tijdelijke_correctie,
			Process_status = job.Process_status,
			Begin_process = job.Begin_process,
			Einde_process = job.Einde_process,
			Duur_process = job.Duur_process,
			ETL_tijdig = iif(datename(weekday, job.Einde_Process) in ('Saturday', 'Sunday') or datepart(hour, job.Einde_Process) < 10, job.ETL_ok, 0),
			ETL_ok = job.ETL_ok,
			Processen_ok = job.Processen_ok, 
			Opmerking_ETL = (select top 10 hst.[subject] + ' - ' + hst.[message] + ' ' 
							from empire_logic.dbo.dlt_load_messages_hist hst
							--where hst.[message] like 'ETL%' and
							where hst.[subject] <> 'ETL definition warning: 50212' and
							hst.[message] not like 'ETL definition warning%wht_inkomensgroep%' and
							hst.loading_day = (select convert(date, convert(varchar(8), run.lastrun), 108) from ##run run where run.job = 'Laden')
							for xml path('')), 
			Opmerking_OLAP = (select top 10 hst.[subject] + ' - ' + hst.[message] + ' ' 
							from empire_logic.dbo.dlt_load_messages_hist hst
							where hst.[message] not like 'ETL%' and
							hst.loading_day = (select convert(date, convert(varchar(8), run.lastrun), 108) from ##run run where run.job = 'Laden')
							for xml path(''))
		from ##res inner join (
			 /*LOS TE DRAAIEN BEGIN */	
			select max(iif(dat.step_name = 'Finish kopieren', dat.run_status, 0)) kopieren_data_status,
				max(iif(dat.step_name = 'Start kopieren', dat.run_time, 0)) Start_kopieren_data,													-- JvdW 20211228 was 'Kopieren brondata'
				max(iif(dat.step_name = 'Finish kopieren', dat.run_time, 0)) Einde_kopieren_data,													-- JvdW 20211228 was 'Kopieren brondata'
				max(iif(dat.step_name = 'Finish kopieren', dateadd(s, dat.run_duration, '1753-01-01'), '1753-01-01')) Duur_stap_kopieren,			-- JvdW 20211228 was 'Kopieren brondata'
				max(iif(dat.step_name = 'Finish laden - tijdstip', dat.run_status, 0)) Verwerken_data_status,										-- JvdW 20211228 was 'Laden'	
				max(iif(dat.step_name = 'Finish kopieren', dat.run_time, 0)) Begin_verwerken_data,													-- JvdW 20211228 was 'Laden'
				max(iif(dat.step_name = 'Finish laden - tijdstip', dateadd(s, dat.run_duration, dat.run_time), 0)) Einde_verwerken_data,			-- JvdW 20211228 was 'Laden'
				max(iif(dat.step_name = 'Finish laden - duration', dateadd(s, dat.run_duration, '1753-01-01'), '1753-01-01')) Duur_verwerken_data,	-- JvdW 20211228 was 'Laden'
				max(iif(dat.step_name = 'Tijdelijke aanpassingen', dat.run_status, 0)) Tijdelijke_correctie_status,
				max(iif(dat.step_name = 'Tijdelijke aanpassingen', dat.run_time, 0)) Begin_tijdelijke_correctie,
				max(iif(dat.step_name = 'Tijdelijke aanpassingen', dateadd(s, dat.run_duration, dat.run_time), 0)) Einde_tijdelijke_correctie,
				max(iif(dat.step_name = 'Tijdelijke aanpassingen', dateadd(s, dat.run_duration, '1753-01-01'), '1753-01-01')) Duur_tijdelijke_correctie,
				max(iif(dat.step_name = 'Process Empire', dat.run_status, 0)) Process_status,
				max(iif(dat.step_name = 'Process Empire', dat.run_time, 0)) Begin_process,
				max(iif(dat.step_name = 'Process Empire', dateadd(s, dat.run_duration, dat.run_time), 0)) Einde_process,
				max(iif(dat.step_name = 'Process Empire', dateadd(s, dat.run_duration, '1753-01-01'), '1753-01-01')) Duur_process,
				max(iif(dat.name = 'Laden DWH Empire' and dat.step_name = 'Finish laden - tijdstip'/* 06-04-2017'(Job outcome)'*/, dat.run_status, 0)) ETL_ok,					-- JvdW 20211228 was 'Laden DWH Empire'
				max(iif(dat.name = 'Process Empire-kubus Productie' and dat.step_name = 'Process Empire'  /* 06-04-2017 '(Job outcome)'*/, dat.run_status, 0)) Processen_ok,
				max(iif(dat.name = 'Process Empire' and dat.step_name = '(Job outcome)', dateadd(s, dat.run_duration, dat.run_time), 0)) Eindtijd
			from (
				--20211228 JvdW Start_kopieren_data wordt niet goed bepaald bij herstarts
				--select j.name, h.step_name, 
				--	convert(datetime, convert(varchar(8), h.run_date), 108) run_date, 
				--	datetimefromparts(h.run_date / 10000, h.run_date % 10000 / 100, h.run_date % 100, (h.run_time % 10000000) / 10000, (h.run_time % 10000) / 100, h.run_time % 100, 0) run_time,
				--	3600 * (h.run_duration / 10000) + 60 * ((h.run_duration % 10000) / 100) + h.run_duration % 100 run_duration, 
				--	h.run_status 
				--from msdb.dbo.sysjobs j inner join msdb.dbo.sysjobhistory h
				--on j.job_id = h.job_id
				--where j.name = 'Laden DWH Empire' and
				--h.run_date = (select run.lastrun from ##run run where run.job = 'Laden') and
				--(h.step_name in ('Kopieren brondata', 'Laden') or h.step_id = 0)

				--20211228 JvdW Start_kopieren_data apart samenvatten met fictieve stapnaam die hierboven wordt aangelopen
				SELECT j.name, 'Start kopieren' AS step_name, 
					convert(datetime, convert(varchar(8), h.run_date), 108) run_date, 
					datetimefromparts(min(h.run_date) / 10000, min(h.run_date) % 10000 / 100, min(h.run_date) % 100, (min(h.run_time) % 10000000) / 10000, (min(h.run_time) % 10000) / 100, min(h.run_time) % 100, 0)AS  run_time,
					3600 * (MAX(h.run_duration) / 10000) + 60 * ((MAX(h.run_duration) % 10000) / 100) + MAX(h.run_duration) % 100 run_duration, 
					MIN(h.run_status) AS run_status
				from msdb.dbo.sysjobs j inner join msdb.dbo.sysjobhistory h
				on j.job_id = h.job_id
				where j.name = 'Laden DWH Empire' and
				h.run_date = (select run.lastrun from ##run run where run.job = 'Laden') and
				(h.step_name in ('Kopieren brondata') )
				-- 20211228 JvdW toegevoegd - laden gebeurt laatste tijd in 2 stappen, met een retry
				GROUP BY j.name, h.step_name,h.run_date

				union
				--20211228 JvdW Einde_kopieren_data apart samenvatten met fictieve stapnaam die hierboven wordt aangelopen
				SELECT j.name, 'Finish kopieren' AS step_name, 
					convert(datetime, convert(varchar(8), h.run_date), 108) run_date, 
					datetimefromparts(MAX(h.run_date) / 10000, MAX(h.run_date) % 10000 / 100, MAX(h.run_date) % 100, (MAX(h.run_time) % 10000000) / 10000, (MAX(h.run_time) % 10000) / 100, MAX(h.run_time) % 100, 0)AS  run_time,
					3600 * (MAX(h.run_duration) / 10000) + 60 * ((MAX(h.run_duration) % 10000) / 100) + MAX(h.run_duration) % 100 run_duration, 
					MIN(h.run_status) AS run_status
				from msdb.dbo.sysjobs j inner join msdb.dbo.sysjobhistory h
				on j.job_id = h.job_id
				where j.name = 'Laden DWH Empire' and
				h.run_date = (select run.lastrun from ##run run where run.job = 'Laden') and
				(h.step_name in ('Kopieren brondata') )
				-- 20211228 JvdW toegevoegd - laden gebeurt laatste tijd in 2 stappen, met een retry
				GROUP BY j.name, h.step_name,h.run_date

				UNION
				--20211228 JvdW Start_kopieren_data apart samenvatten met fictieve stapnaam die hierboven wordt aangelopen
				SELECT j.name,  CASE h.step_name
									WHEN '(Job outcome)' THEN 'Finish laden - duration' 
									WHEN 'Rapporteer succes' THEN 'Finish laden - tijdstip' 									
									WHEN 'Rapporteer fouten' THEN 'Finish laden - tijdstip' 									
									END AS step_name, 
					convert(datetime, convert(varchar(8), h.run_date), 108) run_date, 
					datetimefromparts(min(h.run_date) / 10000, min(h.run_date) % 10000 / 100, min(h.run_date) % 100, (max(h.run_time) % 10000000) / 10000, (max(h.run_time) % 10000) / 100, max(h.run_time) % 100, 0)AS  run_time,
					3600 * (MAX(h.run_duration) / 10000) + 60 * ((MAX(h.run_duration) % 10000) / 100) + MAX(h.run_duration) % 100 run_duration, 
					MIN(h.run_status) AS run_status
				from msdb.dbo.sysjobs j inner join msdb.dbo.sysjobhistory h
				on j.job_id = h.job_id
				where j.name = 'Laden DWH Empire' and
				h.run_date >= (select run.lastrun from ##run run where run.job = 'Laden') 
					AND	(h.step_name in ('(Job Outcome)', 'Rapporteer succes','Rapporteer fouten') or h.step_id = 0)
				GROUP BY j.name, h.step_name,h.run_date

				union
				select j.name, iif(h.step_name like 'Tijdelijke aanpassingen%', 'Tijdelijke aanpassingen', h.step_name) step_name, 
					convert(datetime, convert(varchar(8), h.run_date), 108) run_date, 
					datetimefromparts(h.run_date / 10000, h.run_date % 10000 / 100, h.run_date % 100, (h.run_time % 10000000) / 10000, (h.run_time % 10000) / 100, h.run_time % 100, 0) run_time,
					3600 * (h.run_duration / 10000) + 60 * ((h.run_duration % 10000) / 100) + h.run_duration % 100 run_duration, 
					h.run_status 
				from msdb.dbo.sysjobs j inner join msdb.dbo.sysjobhistory h
				on j.job_id = h.job_id
				where j.name IN ( 'Process Empire', 'Process Empire-kubus Productie') and
				h.run_date = (select run.lastrun from ##run run where run.job = 'Process') and
				(h.step_name like 'Tijdelijke aanpassingen%' or h.step_name = 'Process Empire' or h.step_id = 0)) dat  /*LOS TE DRAAIEN EINDE */) job
		on 1 = 1

--		drop table ##run

		drop table ##srv
	end
	else
	begin

		if object_id('tempdb..##tmp') is not null drop table ##tmp

		; with tyd (job, lastrun, run_time, volgnr)
		as (select j.name job, h.run_date lastrun, h.run_time, row_number() over (partition by j.name order by run_date desc, h.run_time desc) volgnr
			from msdb.dbo.sysjobs j inner join msdb.dbo.sysjobhistory h
			on j.job_id = h.job_id
			where j.name = @job and
			h.step_id = 0 and
			(h.run_date = convert(int, convert(varchar(8), @peildatum, 112)) or @peildatum is null))
		select tyd.job, tyd.lastrun, tyd.run_time
		into ##tmp
		from tyd
		where tyd.volgnr = 1

		insert into ##res (Jobnaam, omgeving, datum) 
			select @job, @omgeving, convert(date, convert(varchar(8), tmp.lastrun), 108) 
			from ##tmp tmp
		
		update ##res set Begintijd = job.run_time,
			Eindtijd = dateadd(s, job.run_duration, job.run_time),
			Duur = dateadd(s, job.run_duration, '1753-01-01'),
			Jobstatus = job.run_status
		from ##res inner join (
				select h.run_status, 
					convert(datetime, convert(varchar(8), h.run_date), 108) run_date, 
					datetimefromparts(h.run_date / 10000, h.run_date % 10000 / 100, h.run_date % 100, (h.run_time % 10000000) / 10000, (h.run_time % 10000) / 100, h.run_time % 100, 0) run_time,
					3600 * (h.run_duration / 10000) + 60 * ((h.run_duration % 10000) / 100) + h.run_duration % 100 run_duration
				from msdb.dbo.sysjobs j inner join msdb.dbo.sysjobhistory h
				on j.job_id = h.job_id
				where j.name = @job and
				h.step_id = 0 and
				h.run_date = (select tmp.lastrun from ##tmp tmp)) job
		on 1 = 1 

		-- JvdW 20211228 toegevoegd om processen wat nu onder andere naam gebeurt ook tijdelijk te loggen
		update ##res set Begintijd = job.run_time,
			Eindtijd = dateadd(s, job.run_duration, job.run_time),
			Duur = dateadd(s, job.run_duration, '1753-01-01'),
			Jobstatus = job.run_status,
			processen_ok = job.run_status
		from ##res inner join (
				select h.run_status, 
					convert(datetime, convert(varchar(8), h.run_date), 108) run_date, 
					datetimefromparts(h.run_date / 10000, h.run_date % 10000 / 100, h.run_date % 100, (h.run_time % 10000000) / 10000, (h.run_time % 10000) / 100, h.run_time % 100, 0) run_time,
					3600 * (h.run_duration / 10000) + 60 * ((h.run_duration % 10000) / 100) + h.run_duration % 100 run_duration
				from msdb.dbo.sysjobs j inner join msdb.dbo.sysjobhistory h
				on j.job_id = h.job_id
				where j.name = @job and
				h.step_id = 0 and
				h.run_date = (select tmp.lastrun from ##tmp tmp)
				AND j.NAME = 'Process Empire-kubus Productie'
				) job
				
		on 1 = 1 



		--drop table ##tmp

	end

	select omgeving, Jobnaam, Datum, Begintijd, Eindtijd, Duur, Jobstatus, [Server], Bron,
		DWH_versie_empire, DWH_versie_ETL, DWH_versie_maatwerk, Versie_Empire, Aantal_perioden,
		kopieren_data_status, Start_kopieren_data, Einde_kopieren_data, Duur_stap_kopieren,
		Verwerken_data_status, Begin_verwerken_data, Einde_verwerken_data, Duur_verwerken_data,
		Tijdelijke_correctie_status, Begin_tijdelijke_correctie, Einde_tijdelijke_correctie,
		Duur_tijdelijke_correctie, Process_status, Begin_process, Einde_process, Duur_process,
		ETL_tijdig, ETL_ok, Processen_ok, Opmerking_ETL, Opmerking_OLAP
	from ##res

	--drop table ##res

END


/*
	create table [empire_staedion_data].[sharepoint].[VerwerkingJobs] (
	id						int identity,		-- unieke identificatie van het record
	omgeving				nvarchar(20),		-- omgeving (productie. test of acceptatie
	Jobnaam					nvarchar(50),		-- naam van de uitgevoerde job
	Datum					datetime,			-- datum waarop de job is gestart
	Begintijd				datetime,			-- begintijd uitvoer job
	Eindtijd				datetime,			-- eindtijd uitvoer job
	Duur					datetime,			-- uitvoerduur job
	Jobstatus				tinyint,			-- Status van de job
												-- onderstaande velden zijn voor monitoring DWH load
	[Server]				varchar(30),		-- gebruikte linked server
	Bron					nvarchar(50),		-- server en catalog
	DWH_versie_empire		nvarchar(50),		-- DWH versie Empire
	DWH_versie_ETL			nvarchar(50),		-- Versie ETL
	DWH_versie_maatwerk		nvarchar(50),		-- Versie Staedion maatwerk
	Versie_Empire			nvarchar(50),		-- Empire versie
	Aantal_perioden			int,				-- Aantal perioden
	kopieren_data_status	tinyint,			-- Status stap kopiëren data
	Start_kopieren_data		datetime,			-- Start stap kopiëren data
	Einde_kopieren_data		datetime,			-- Einde stap kopiëren data
	Duur_stap_kopieren		datetime,			-- Duur stap kopiëren data
	Verwerken_data_status	tinyint,			-- Status stap verwerken data
	Begin_verwerken_data	datetime,			-- Begin stap verwerken data
	Einde_verwerken_data	datetime,			-- Einde stap verwerken data
	Duur_verwerken_data		datetime,			-- Duur stap verwerken data
	Tijdelijke_correctie_status	tinyint,		-- Status stap tijdelijke correctie
	Begin_tijdelijke_correctie datetime,		-- Start stap tijdelijke correctie
	Einde_tijdelijke_correctie datetime,		-- Einde stap tijdelijke correctie
	Duur_tijdelijke_correctie datetime,			-- Duur stap tijdelijke correctie
	Process_status			tinyint,			-- Status stap Process data
	Begin_process			datetime,			-- Start stap Process data
	Einde_process			datetime,			-- Einde stap Process data
	Duur_process			datetime,			-- Duur stap Process data
	ETL_tijdig				tinyint,			-- ETL op werkdagen voor 08:00 klaar
	ETL_ok					tinyint,			-- Status ETL
	Processen_ok			tinyint,			-- Status Process
	Opmerking_ETL			nvarchar(max),		-- Opmerking ETL uit empire_logic.dbo.dlt_load_messages_hist
	Opmerking_OLAP			nva`rchar(max))		-- Opmerking OLAP uit empire_logic.dbo.dlt_load_messages_hist



*/
GO
EXEC sp_addextendedproperty N'MS_Description', N'
Procedure om de uitvoer van verschillende job te kunnen monitoren
		@job => naam van de te controleren job (voor DWH is een generieke naam Datawarehouse genomen)
		@omgeving => geeft de omgeving aan (productie, test of acceptatie)
		@peildatum => optionele parameter om gegevens van een specifieke peildatum op te kunnen halen, indien leeg
					  wordt de meest recente regel uit de jobhistory opgehaald
VOORWAARDE		EXEC sp_serveroption [S-DWH2012-accp],DATA ACCESS,TRUE 
', 'SCHEMA', N'DatabaseBeheer', 'PROCEDURE', N'sp_check_sqljob_child', NULL, NULL
GO
