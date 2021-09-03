SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* ###################################################################################################
VAN         : MV
BETREFT     : Controle op range
ZIE         : Datakwaliteit
------------------------------------------------------------------------------------------------------
WIJZIGINGEN  
------------------------------------------------------------------------------------------------------
Versie 1
------------------------------------------------------------------------------------------------------
CHECKS                   
------------------------------------------------------------------------------------------------------
declare @value as float = 5
declare @min as float = 1
declare @max as float = 10
select [value] = @value, [valid] = [staedion_dm].[Datakwaliteit].[fn_check_range] (@value, @min, @max)

declare @value as float = 12
declare @min as float = 1
declare @max as float = 10
select [value] = @value, [valid] = [staedion_dm].[Datakwaliteit].[fn_check_range] (@value, @min, @max)
################################################################################################### */	
CREATE FUNCTION [Datakwaliteit].[fn_check_range] (@VALUE float, @MIN float, @MAX float)
RETURNS BIT
AS
BEGIN     
  DECLARE @valid as bit

  SET @valid = case when @VALUE = '' then 0
					when @MIN = '' then 0
					when @MAX = '' then 0
					when @VALUE is null then 0
					when @MIN is null then 0
					when @MAX is null then 0
					when ISNUMERIC(@VALUE) = 0 then 0
					when ISNUMERIC(@MIN) = 0 then 0
					when ISNUMERIC(@MAX) = 0 then 0
					when @VALUE between @MIN and @MAX then 1
					else 0
                  end
  RETURN @valid
END 
GO
