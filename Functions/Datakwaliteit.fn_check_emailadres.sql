SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* ###################################################################################################
VAN         : MV
BETREFT     : Controle op email
ZIE         : Datakwaliteit
------------------------------------------------------------------------------------------------------
WIJZIGINGEN  
------------------------------------------------------------------------------------------------------
Versie 1
JvdW 20220105 '_demy_@live.nl ' werd afgekeurd maar is toch ok volgens Marieke
------------------------------------------------------------------------------------------------------
CHECKS                   
------------------------------------------------------------------------------------------------------
declare @email as nvarchar(256) = '_demy_@live.nl'
select [email] = @email, [staedion_dm].[Datakwaliteit].[fn_check_emailadres](@email) as valid

declare @email as nvarchar(256) = 'info@staedion.nl'
select [email] = @email, [staedion_dm].[Datakwaliteit].[fn_check_emailadres](@email) as valid

-- invoervereist vanuit DQ-team:
	"1 emailadres
	alleen leestekens . En @
	eindigt met .(twee of drie letters)"
declare @email as nvarchar(256) = 'info@staedion.nl (vriendin)'
select [email] = @email, [staedion_dm].[Datakwaliteit].[fn_check_emailadres](@email) as valid

declare @email as nvarchar(256) = ''
select [email] = @email, [staedion_dm].[Datakwaliteit].[fn_check_emailadres](@email) as valid

declare @email as nvarchar(256) = null
select [email] = @email, [staedion_dm].[Datakwaliteit].[fn_check_emailadres](@email) as valid


################################################################################################### */	
CREATE FUNCTION [Datakwaliteit].[fn_check_emailadres] (@VALUE nvarchar(255))
RETURNS BIT
AS
BEGIN     
  DECLARE @email nvarchar(255)
  DECLARE @valid as bit
  
  SET @email = trim(isnull(@VALUE,''))

  SET @valid = case		  when @email = '' then 1
						  when @email like 'geen@email.nl' then 0
						  when @email like 'geen@mail.nl' then 0
                          when @email like '% %' then 0
                          when @email like ('%["(),:;<>\]%') then 0
                          when substring(@email,charindex('@',@email),len(@email)) like ('%[!#$%&*+/=?^`_{|]%') then 0
                          when (left(@email, 1) like ('[-.+]') or right(@email, 1) like ('[-_.+]')) then 0                                                                                    
                          when (@email like '%[%' or @email like '%]%') then 0
                          when @email like '%@%@%' then 0
                          when @email not like '_%@_%._%' then 0
                          else 1
                  end
  RETURN @valid
END
GO
