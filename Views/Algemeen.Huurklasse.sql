SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [Algemeen].[Huurklasse]
as
select *,
[Groep Staedion] =  case 
                      when business_key in (2,4,5) then 'Goedkoop + Met HS betaalbaar'
                      when business_key = 6 then 'Middelduur'
                      when business_key = 8 then 'Duur'
                      else 'Onbekend'
                    end,
[Groep Staedion sort] =   case 
                            when business_key in (2,4,5) then 1
                            when business_key = 6 then 2
                            when business_key = 8 then 3
                            else 4
                          end,
[Huurprijsklasse Staedion] =  case huurprijsklasse_std_descr
                                when 'Kwaliteitsgrens' then 'Kwaliteitskortingsgrens'
                                when 'Maximale huurgrens' then 'Tot huurprijsgrens'
                                when 'Geliberaliseerd' then 'Boven huurprijsgrens'
                                else huurprijsklasse_std_descr
                              end
from empire_dwh.dbo.bbshklasse
GO
