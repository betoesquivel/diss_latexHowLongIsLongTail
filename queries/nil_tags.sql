\begin{lstlisting}[
           language=SQL,
           showspaces=false,
           basicstyle=\ttfamily,
           numbers=left,
           numberstyle=\tiny,
           commentstyle=\color{gray}
        ]
INSERT OVERWRITE TABLE nil_s3
select stan.tag_id, stan.tagger, stan.surface_form, stan.start_offset, stan.end_offset, stan.enumex_type
from stanford_s3 stan
left outer join overlapping_s3 overlap
on stan.tag_id = overlap.stanfordid
where stanfordid is null;
\end{lstlisting}
