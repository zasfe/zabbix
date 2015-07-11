@echo off

chcp 65001 & netstat -anp TCP | LogParser "SELECT State, count(*) AS NumberOfHits FROM STDIN Group BY State ORDER BY State " -i:TSV -iSeparator:space -nSep:2 -fixedSep:off -nSkipLines:3
