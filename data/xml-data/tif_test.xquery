for $searchWord in doc("eDitions_projects_tiffany.xml")/projects/project/information/desc/searchWord
where $searchWord/searchWord = 'dh-dashboard'
return data($searchWord)
