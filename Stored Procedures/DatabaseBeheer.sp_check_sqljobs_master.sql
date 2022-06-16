SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [DatabaseBeheer].[sp_check_sqljobs_master] (@peildatum datetime = null)
as
begin
/*	======================================================================================
	procedure die van alle jobs die in de tabel empire_staedion_data.sharepoint.log_job 
	zijn vastgelegd de laatste uitvoerresultaten in de tabel 
	[empire_staedion_data].[sharepoint].[VerwerkingJobs] opslaat

	Optionele parameter @peildatum kan gebruikt worden om de gegevens voor een specifieke 
	datum te laten toevoegen, de jobhistorie is standaard beperkt tot 1000 regels (in te 
	stellen bij de properties van de sqljobagent) waardoor slechts een beperkte tijd
	terug gekeken kan worden.
	--------------------------------------------------------------------------------------
	create table empire_staedion_data.sharepoint.log_job (
	job				varchar(50),	-- naam van de te controleren job (dummynaam Datawarehouse voor DWH!!)
	omgeving		varchar(20))	-- omgeving (Productie, Test of Acceptatie)


	
	insert into empire_staedion_data.sharepoint.log_job values ('Datawarehouse', 'Productie'),
															   ('Datawarehouse', 'Test'),
															   ('Ververs Vabi data', 'Productie')

	insert into empire_staedion_data.sharepoint.log_job values ('Datawarehouse', 'Acceptatie')

	insert into empire_staedion_data.sharepoint.log_job values ('Process WBS', 'Productie')
	insert into empire_staedion_data.sharepoint.log_job values ('Restore WBS', 'Productie')
	insert into empire_staedion_data.sharepoint.log_job values ('Ververs verhuisflow', 'Productie')
	
	--------------------------------------------------------------------------------------
	Van Roelof, nov 2016
	NB: alleen meest recente regel wordt opgehaald en eventueel toegevoegd (toevoegen maar max 1 keer, geen dubbele regels)
		stel regel staat fout, dan:

		delete from  [empire_staedion_data].[sharepoint].[VerwerkingJobs] where Jobnaam = 'Datawarehouse'  and datum in ('20170323')
		exec [empire_staedion_data].[dbo].[dsp_check_sqljobs] '20161112'
		exec [empire_staedion_data].[dbo].[dsp_check_sqljobs] '20161113'
		exec [empire_staedion_data].[dbo].[dsp_check_sqljobs] '20170324'
		select * from  [empire_staedion_data].[sharepoint].[VerwerkingJobs] where Jobnaam = 'Datawarehouse' and datum in ('20170324')
	--------------------------------------------------------------------------------------
*/
	declare @email varchar(200) = 'jvdw@staedion.nl'
	declare @profile varchar(100) = 'dwhmail'
	declare @message varchar(4000)
	set nocount on

	if object_id('tempdb..##log') is not null drop table ##log

	create table ##log (
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
	Opmerking_ETL			varchar(max), 
	Opmerking_OLAP			varchar(max))

	declare @job varchar(50)
	declare @omgeving varchar(20) 
	declare @sql varchar(1000)

	declare sqljob cursor 
	for select job, omgeving
		from staedion_dm.DatabaseBeheer.TeLoggenSQLAgentJobs

	open sqljob

	fetch next from sqljob into @job, @omgeving

	while @@fetch_status = 0 
	begin 
		truncate table ##log
		if @omgeving not in ('Test', 'Acceptatie', 'Productie')
		begin
			set @message = 'Onbekende omgeving [' + @omgeving + '] voor job [' + @job + '] opgegeven, geen controle uitgevoerd. Beschikbare omgevingen zijn Test, Acceptatie en Productie.'
			exec msdb.dbo.sp_send_dbmail @profile_name = @profile, 
				@recipients = @email,
				@subject = 'Onbekende omgeving opgegeven in tabel staedion_dm.DatabaseBeheer.TeLoggenSQLAgentJobs',
				@body = @message 
		end
		else
		begin
			begin try
			set @sql = 'exec ' + iif(@omgeving = 'Test', '[S-DWH2012-TEST].', iif(@omgeving = 'Acceptatie', '[S-DWH2012-ACCP].', '')) + 'staedion_dm.[DatabaseBeheer].[sp_check_sqljob_child] ''' + @job + ''', ''' + @omgeving + iif(@peildatum is not null, ''', ''' + convert(varchar(10), @peildatum, 120), '') + ''''
			print @sql
			insert ##log
			exec (@sql)

			--select * from ##log

			insert into staedion_dm.DatabaseBeheer.VerwerkingSQLAgentJobs (
				omgeving, Jobnaam, Datum, Begintijd, Eindtijd, Duur, Jobstatus, [Server], Bron,
				DWH_versie_empire, DWH_versie_ETL, DWH_versie_maatwerk, Versie_Empire, Aantal_perioden,
				kopieren_data_status, Start_kopieren_data, Einde_kopieren_data, Duur_stap_kopieren,
				Verwerken_data_status, Begin_verwerken_data, Einde_verwerken_data, Duur_verwerken_data,
				Tijdelijke_correctie_status, Begin_tijdelijke_correctie, Einde_tijdelijke_correctie,
				Duur_tijdelijke_correctie, Process_status, Begin_process, Einde_process, Duur_process,
				ETL_tijdig, ETL_ok, Processen_ok, Opmerking_ETL, Opmerking_OLAP)
				select omgeving, Jobnaam, Datum, Begintijd, Eindtijd, Duur, Jobstatus, [Server], Bron,
					DWH_versie_empire, DWH_versie_ETL, DWH_versie_maatwerk, Versie_Empire, Aantal_perioden,
					kopieren_data_status, Start_kopieren_data, Einde_kopieren_data, Duur_stap_kopieren,
					Verwerken_data_status, Begin_verwerken_data, Einde_verwerken_data, Duur_verwerken_data,
					Tijdelijke_correctie_status, Begin_tijdelijke_correctie, Einde_tijdelijke_correctie,
					Duur_tijdelijke_correctie, Process_status, Begin_process, Einde_process, Duur_process,
					ETL_tijdig, ETL_ok, Processen_ok, Opmerking_ETL, Opmerking_OLAP
				from ##log
				where not exists (select 1
					from staedion_dm.DatabaseBeheer.VerwerkingSQLAgentJobs job
					where job.omgeving = ##log.omgeving and
					job.Jobnaam = ##log.Jobnaam and
					job.Datum = ##log.Datum)
			end try
			begin catch
				set @message = 'Fout bij controle van job [' + @job + '] in omgeving [' + @omgeving + ']' + 
					iif(@peildatum is null, '', ' met peildatum ' + convert(varchar(10), @peildatum, 105)) + '. Foutnummer ' + 
					convert(varchar(10), error_number()) + ' regel ' + convert(varchar(10), error_line()) + 
					' melding: '+ error_message()
				exec msdb.dbo.sp_send_dbmail @profile_name = @profile, 
					@recipients = @email,
					@subject = 'Fout bij verwerking tabel staedion_dm.DatabaseBeheer.TeLoggenSQLAgentJobs',
					@body = @message 
			end catch

		end

		fetch next from sqljob into @job, @omgeving

	end

	close sqljob

	deallocate sqljob

	drop table ##log
end
GO
