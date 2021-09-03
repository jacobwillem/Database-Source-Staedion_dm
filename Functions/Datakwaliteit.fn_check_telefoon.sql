SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* ###################################################################################################
VAN         : JvdW
BETREFT     : Controle op telefoonnr
ZIE         : Datakwaliteit
------------------------------------------------------------------------------------------------------
WIJZIGINGEN  
------------------------------------------------------------------------------------------------------
Versie 1: kopie van fn_check_emailadres + aanpassing op basis van onderstaande specificatie
>  ben uitgegaan van 13 cijfers maximaal
-- invoervereist vanuit DQ-team:
cijfers, maximaal 12
leestekens: +,-, beide maximaal 1 x
totaal tekens maximaal 15


------------------------------------------------------------------------------------------------------
CHECKS                   
------------------------------------------------------------------------------------------------------
declare @tblTestGevallen as Table (tel nvarchar(256), opmerking nvarchar(100))
insert into @tblTestGevallen (tel,opmerking) 
	values	('123456789012456', 'Meer dan 15 posities - fout')
			,('123456789012', 'Niet te lang - ok')
			,('+00311746258561', 'Meer dan 13 getallen - fout')
			,('+0031174625856', '+0031 niet ok volgens Sander - fout')
			,('0031174625856', '13 getallen - ok')
			,('++0031174625856', '2x + - fout')
			,('12345(6789012', 'Slechts 1 haakje - fout')
			,('1234(456)9012', 'Drie getallen tussen() - ok')
			,('(06) 22 48 04 27', 'Geen 2, 4 of 4 vier getallen tussen() - ok')
			,('12345X67890123', 'Fout teken - fout')
			,('123456', 'Minimaal 7 cijfers - fout')
		    ,('(070) 389 28 78','lijkt me ok toch ?')
			,('06 - 10 61 14 10','lijkt me ok toch ?')
select * , [Resultaat check] = [Datakwaliteit].[fn_check_telefoon] (tel), len(tel)
from	@tblTestGevallen
;

################################################################################################### */	
CREATE FUNCTION [Datakwaliteit].[fn_check_telefoon] (@VALUE nvarchar(255))
RETURNS BIT
AS
BEGIN     
  DECLARE @tel nvarchar(255)
  DECLARE @valid as bit
  
  SET @tel = replace(trim(isnull(@VALUE,'')), ' ','')

  --SET @valid = case		  when @tel = '' then 0
		--				  when len(@tel) > 14 then 0
		--				  when len(@tel) = 14 and not(@tel like '[0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-]') then 0
		--				  when len(@tel) = 13 and not(@tel like '[0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-]') then 0
		--				  when len(@tel) = 12 and not(@tel like '[0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-]') then 0
		--				  when len(@tel) = 11 and not(@tel like '[0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-]') then 0
		--				  when len(@tel) = 10 and not(@tel like '[0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-]') then 0
		--				  when len(@tel) = 9 and not(@tel like '[0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-]') then 0
		--				  when len(@tel) = 8 and not(@tel like '[0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-]') then 0
		--				  when len(@tel) = 7 and not(@tel like '[0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-][0-9+()-]') then 0
		--				  when len(@tel) < 7 then 0
		--				  when LEN(@tel) - LEN(REPLACE(@tel, '+', '')) > 1 then 0
		--				  when LEN(@tel) - LEN(REPLACE(@tel, '(', '')) > 1 then 0
		--				  when LEN(@tel) - LEN(REPLACE(@tel, ')', '')) > 1 then 0
  --                        else 1
  --                end

  SET @valid = case		  when @tel = '' then 0
						  when len(@tel) > 15 then 0									-- fout als lengte van veld langer is dan 15
						  when len(@tel) between 7 and 15 and not(@tel like replicate('[0-9+()-]',len(@tel))) then 0
						  when len(@tel) < 7 then 0										-- fout als lengte van veld korter dan 7 is
						  when LEN(@tel) - LEN(REPLACE(@tel, '+', '')) > 1 then 0		-- fout bij meer dan 1x +	
						  when LEN(@tel) - LEN(REPLACE(@tel, '(', '')) > 1 then 0		-- fout bij meer dan 1x ( 
						  when LEN(@tel) - LEN(REPLACE(@tel, ')', '')) > 1 then 0		-- fout bij meer dan 1x )	
																						-- fout bij meer dan 10 getallen
						  when LEN(@tel) - LEN(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@tel, '0',''),'1',''),'2',''),'3',''),'4',''),'5',''),'6',''),'7',''),'8',''),'9',''))>13 then 0
						  when not (LEN(@tel) - LEN(REPLACE(@tel, ')', ''))				-- fout bij alleen ( of alleen )
									+
									LEN(@tel) - LEN(REPLACE(@tel, '(', '')) 
									in (0,2)
									) then 0												
						  when (NOT(@tel like '%(__)%' or @tel like '(__)%' or @tel like '%(___)%' or (@tel like '(___)%' or @tel like '%(____)%') or @tel like '(____)%'))		-- fout als er geen 3 of 4 getallen voorkomen tussen de haakjes
									 and (LEN(@tel) - LEN(REPLACE(@tel, ')', ''))) = 1 	
									 then 0
						  when @tel like '+00%' then 0
                          else 1
                  end
  RETURN @valid
END
GO
