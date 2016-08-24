\begin{lstlisting}[
           language=SQL,
           showspaces=false,
           basicstyle=\ttfamily,
           numbers=left,
           numberstyle=\tiny,
           commentstyle=\color{gray}
        ]
INSERT OVERWRITE TABLE overlapping_s3
select
substring_index(stan.tag_id, '_', 1) as ArticleID,
stan.surface_form as StanfordSurface,
spot.surface_form as SpotlightSurface,
stan.enumex_type as StanfordType,
spot.enumex_type as SpotlightType,
stan.start_offset as StanfordStart,
stan.end_offset as StanfordEnd,
spot.start_offset as SpotlightStart,
spot.end_offset as SpotlightEnd,
stan.tag_id as StanfordID,
spot.tag_id as SpotlightID
from spotlight_s3 spot
cross join stanford_s3 stan
on
( substring_index(spot.tag_id, '_', 1) = substring_index(stan.tag_id, '_', 1) )
where
((spot.start_offset between stan.start_offset and stan.end_offset)
or (stan.start_offset between spot.start_offset and spot.end_offset))
and
(instr(spot.surface_form, stan.surface_form)>0
or instr(stan.surface_form, spot.surface_form)>0);
\end{lstlisting}
