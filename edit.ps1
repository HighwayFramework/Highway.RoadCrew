$files = Get-ChildItem *.ps1 -Recurse | select -ExpandProperty FullName
ise $($files -join ",")