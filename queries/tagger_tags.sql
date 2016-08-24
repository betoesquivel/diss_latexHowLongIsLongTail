\begin{lstlisting}[
           language=SQL,
           showspaces=false,
           basicstyle=\ttfamily,
           numbers=left,
           numberstyle=\tiny,
           commentstyle=\color{gray}
        ]
-- LIST EVERY TAG from stanford
INSERT OVERWRITE TABLE stanford_s3
SELECT * FROM tags_s3
WHERE tagger='stanford';
\end{lstlisting}
