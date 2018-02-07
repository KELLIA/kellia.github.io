declare namespace ka = "http://www.uni-goettingen.de/kellia";


let $xml := doc("eDitions_projects_tiffany.xml")

for $out in $xml/ka:kelliaEditions/ka:projects/ka:project/ka:data/ka:dataSet/ka:p/ka:standard
where $out[@name = 'tei']
return
    <standard>
        {data($out/ancestor::ka:project/ka:title)}
    </standard>

    


