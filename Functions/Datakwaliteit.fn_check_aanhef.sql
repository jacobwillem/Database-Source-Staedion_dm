SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/* ###################################################################################################
VAN         : MV
BETREFT     : Controle op aanhef
ZIE         : Datakwaliteit
------------------------------------------------------------------------------------------------------
WIJZIGINGEN  
------------------------------------------------------------------------------------------------------
Versie 1
------------------------------------------------------------------------------------------------------
CHECKS                   
------------------------------------------------------------------------------------------------------

declare @huishouden as nvarchar(12) = 'RLTS-0007727'
select [Huishouden] = @huishouden, [Omschrijving] = [staedion_dm].[Datakwaliteit].[fn_check_aanhef] (@huishouden)

declare @huishouden as nvarchar(12) = 'RLTS-0014091'
select [Huishouden] = @huishouden, [Omschrijving] = [staedion_dm].[Datakwaliteit].[fn_check_aanhef] (@huishouden)

declare @huishouden as nvarchar(12) = 'RLTS-0230358'
select [Huishouden] = @huishouden, [Omschrijving] = [staedion_dm].[Datakwaliteit].[fn_check_aanhef] (@huishouden)

TO DO:
Include ipv exclude manier

-- Man = DHR of ERVENVAN
-- Vrouw = MEVR of ERVENVAN
-- Onzijdig = DHR/MEVR of ERVENVAN

################################################################################################### */	
CREATE FUNCTION [Datakwaliteit].[fn_check_aanhef] (@HUISHOUDEN nvarchar(12))
RETURNS NVARCHAR(255)
AS
BEGIN     
  DECLARE @errors as nvarchar(255)

	SELECT @errors =  string_agg(
						concat(c.[No_], ';', 
							case
								when c.[Geslacht] = 0 and c.[Salutation Code] = 'DHR' then 'Geslacht onzijdig, aanhef DHR'
								when c.[Geslacht] = 0 and c.[Salutation Code] = 'MEVR' then 'Geslacht onzijdig, aanhef MEVR'
								when c.[Geslacht] = 1 and c.[Salutation Code] <> 'DHR' then 'Geslacht man, aanhef geen DHR'
								when c.[Geslacht] = 2 and c.[Salutation Code] <> 'MEVR' then 'Geslacht vrouw, aanhef geen MEVR'
							end
						) , ';')
	  from [empire_data].[dbo].[contact_role] r
	inner join [empire_data].[dbo].[contact] c on c.No_ = r.[Contact No_]
	 where r.[Related Contact No_] = @HUISHOUDEN
	   and (
			r.[Role Code] = 'CONTRACT' or
			r.[Role Code] like 'CP%'
			)
	   and (
		   (c.[Geslacht] = 0 and c.[Salutation Code] in ('DHR', 'MEVR')) or
		   (c.[Geslacht] = 1 and c.[Salutation Code] <> 'DHR') or
		   (c.[Geslacht] = 2 and c.[Salutation Code] <> 'MEVR')
	   )

  RETURN @errors
END 
GO
