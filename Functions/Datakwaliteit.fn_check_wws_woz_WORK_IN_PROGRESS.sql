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
CREATE FUNCTION [Datakwaliteit].[fn_check_wws_woz_WORK_IN_PROGRESS] (@WOZ float, @OPPERVLAKTE float, @PUNTEN float, @VAR1 float = 10289, @VAR2 float = 160)
RETURNS BIT
AS
BEGIN   
  DECLARE @wws as float
  DECLARE @valid as bit




  SET @valid = case when @WOZ = '' then 0
					when @OPPERVLAKTE = '' then 0
					when @VAR1 = '' then 0
					when @VAR2 = '' then 0
					when @WWS = '' then 0
					when @WOZ is null then 0
					when @OPPERVLAKTE is null then 0
					when @VAR1 is null then 0
					when @VAR2 is null then 0
					when @WWS is null then 0
					when ISNUMERIC(@WOZ) = 0 then 0
					when ISNUMERIC(@OPPERVLAKTE) = 0 then 0
					when ISNUMERIC(@VAR1) = 0 then 0
					when ISNUMERIC(@VAR2) = 0 then 0
					when ISNUMERIC(@WWS) = 0 then 0
					when round((@WOZ/@VAR1) + (@WOZ/@OPPERVLAKTE/@VAR2), 0) = @PUNTEN then 1
					else 0
                  end
  RETURN @valid
END 




/*
round((@WOZ/@VAR1) + (@WOZ/@OPPERVLAKTE/@VAR2)) = @PUNTEN

Punten berekenen over WOZ-waarde huurwoning
Uw gemeente stelt de WOZ-waarde jaarlijks opnieuw vast. Daarom is de puntenberekening ook elk jaar iets anders. U kunt zelf in 4 stappen uitrekenen hoeveel punten uw huurwoning tot 1 juli 2020 over de WOZ-waarde krijgt:

Deel de WOZ-waarde door € 10.289. De uitkomst is een puntenaantal.
Deel de WOZ-waarde door de woningoppervlakte (m2). En deel de uitkomst daarna door € 160. Ook dit geeft een puntenaantal.
Tel de punten van stap 1 en 2 bij elkaar op. Dit is het totaal aantal punten over de WOZ-waarde.
Rond af op een heel getal.
Rekenvoorbeeld punten over de WOZ-waarde huurwoning
Stel: de WOZ-waarde van uw huurwoning is € 197.000  en de oppervlakte van uw woning is 70 m2. U berekent de punten bij uw WOZ-waarde in 3 stappen:

Berekening	 Punten
€ 197.000 / 10.289	 = 19,15
€ 197.000 / 70 / € 160	 = 17,59
Totaal: 36,74 punten
Na afronding: 37 punten

De bedragen om de WOZ-punten te berekenen veranderen elk jaar:

Voor de punten per 1 juli 2020 gelden: € 10.289 en € 160. 

Voor de punten per 1 juli 2019 gelden: € 9.474 en € 147.

Belangrijk bij de berekening:
Per 1 juli 2020 rekent u met een waarde van minimaal €52.085, ook als uw WOZ-waarde minder is. Tot 1 juli 2020 is de minimale rekenwaarde €47.960.
Is uw huurwoning in aanbouw? Dan geldt de WOZ-waarde van de woning als die helemaal af is. Tel de eindwaarde en de grondwaarde van de huurwoning bij elkaar op. U vindt beide in het taxatieverslag van de gemeente.
Heeft de huurwoning zonder de WOZ-punten al 110 punten of meer? En is de woning gebouwd in de periode 2015 t/m 2019? Dan is het aantal punten over de WOZ-waarde minimaal 40.
Er zijn bijzondere regels voor woningen in een zorgwoning en voor monumentenwoningen.https://www.rijksoverheid.nl/onderwerpen/huurprijs-en-puntentelling/vraag-en-antwoord/woz-waarde-woning-en-huurprijs
*/
GO
