SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [Dashboard].[vw_Tertaal]asselect Kolomnaam = 'Level', Volgorde = 1union 
select 'T1 Realisatie',2union 
select 'T1 Doel',3union 
select 'T1 Realisatie t.o.v. T1 Doel',4union 
select 'T1 Prognose',5union 
select 'T2 Realisatie',6union 
select 'T2 Doel',7union 
select 'T2 Realisatie t.o.v. T2 Doel',8union 
select 'T2 Prognose',9union 
select 'T3 Realisatie',10union 
select 'Doel in jaar',11union 
select 'T1 Prognose t.o.v. Doel in jaar',12union 
select 'T2 Prognose t.o.v. Doel in jaar',13union 
select 'T3 Realisatie t.o.v. Doel in jaar',14
GO
