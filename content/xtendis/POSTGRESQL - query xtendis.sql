-- 13.933
SELECT DOC.idx_kast AS meta_kast
    , DOC.idx_documentdatum AS meta_datum_brief
    , DOS.idx_relatienummer AS meta_relatie_nr
    , DOC.idx_documentkenmerk AS meta_briefkenmerk
    , ('https://staedion.xtendis.nl/web/weblauncher.aspx?archiefnaam=Centraal&t_DOCUMENTID='::TEXT || DOC.documentid::TEXT) AS doc_hyperlink
    , DOC.idx_hoofdonderwerp as xtds_hoofdonderwerp
    , DOC.idx_subonderwerp as xtds_subonderwerp   
    , DOS.idx_klantnummer AS xtds_klantnummer     
    , DOC.idx_toelichting as xtds_toelichting
    , DOC.idx_afdeling as xtds_afdeling    
    , DOS.idx_clusternummer
    , DOS.idx_ogeh_nummer as xtds_ogeh_nummer
    -- select *
FROM extendis.dim_extendis_metadata_documenten as DOC
left outer join extendis.dim_extendis_metadata_dossiers as DOS 
on DOS.dossierid = DOC.dossierid 
WHERE DOC.idx_subonderwerp = 'Uitvoering werkzaamheden'
and DOS.idx_clusternummer   = 'FT-1128'
and lower(DOC.idx_toelichting) like 'akkoordverklaring'
    and DOS.idx_ogeh_nummer = 'OGEH-0035880'
        AND date_part('year', DOC.idx_documentdatum) >= 2020 


 select  DOS.idx_clusternummer
    , count(distinct DOS.idx_ogeh_nummer) as ogeh_nummers
    -- select *
FROM extendis.dim_extendis_metadata_documenten as DOC
left outer join extendis.dim_extendis_metadata_dossiers as DOS 
on DOS.dossierid = DOC.dossierid 
WHERE lower(DOC.idx_toelichting) like 'akkoordverklaring'
    AND date_part('year', DOC.idx_documentdatum) >= 2020 
   group by DOS.idx_clusternummer

   select 