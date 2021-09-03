SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE  FUNCTION [Algemeen].[fn_StringToArray]
		(@str	varchar(255),		
		@delim	char(1), 
		@token	tinyint)
		RETURNS varchar(255)
AS
/* #################################################################
BETREFT		Ophalen bepaalde waarde in tekstveld waarvan onderdelen zijn gescheiden door een speciaal scheidingsteken
ZIE				http://www.sqlservercentral.com/scripts/Miscellaneous/30334/
VAN				Ray Wong

RECHTEN		grant exec on dbo.StringToArray to public
TEST																														V1									V2
					select dbo.StringToArray('this string', ' ', 1)				--> 'this'					idem
					select dbo.StringToArray('this string', ' ', 2)				--> 'string'				idem
					select dbo.StringToArray('this string', ' ', 3)				--> NULL						idem	
					select dbo.StringToArray('this  string', ' ', 2)			--> ''							idem
					select dbo.StringToArray('this  string', 'X', 2)			--> NULL						idem
					select dbo.StringToArray('this  string', 'X', 1)			--> 'this  string'
					select dbo.StringToArray('Xthis  string', 'X', 1)			--> ''							NULL

--------------------------------------------------------------------------------------------------------------
20181002 JvdW, V2: Liever geen geen lege string als scheidingsteken niet gevonden is
							=> nog niet ge-effectueerd !
20210707 Er is wel een native-functie STRING_SPLIT maar volgens mij werkt dat niet handig met ophalen van bepaald item nr
> https://www.sqlshack.com/implement-array-like-functionality-sql-server/
> deze versie in Staedion_dm gezet (zoveel mogelijk in 1 database als centrale plek)
> basis was empire_staedion_data.dbo.StringToArray
################################################################# */

BEGIN
DECLARE @start tinyint,		
		@end tinyint, 
		@loopcnt tinyint

set		@end = 0
set		@loopcnt = 0
set		@delim = substring(@delim, 1, 1)

--	loop to specific token
while (@loopcnt < @token) begin
		set @start = @end + 1
		set @loopcnt = @loopcnt + 1
		set @end = charindex(@delim, @str +@delim, @start) 
		if  @end = 0 break
end

if @end =0
		set @str = null
else
		set @str = substring(@str, @start, @end-@start)

RETURN	@str

END


GO
