[xml]$doc = Get-Content -Raw -Encoding utf8 .\doc_extract\word\document.xml
$doc.SelectNodes('//*[local-name()="t"]') | Select-Object -ExpandProperty '#text' | Out-File -Encoding utf8 parsed_doc.txt
