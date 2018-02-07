xquery version "3.0";

module namespace app="http://exist-db.org/app/kellia/templates";

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
import module namespace config="http://exist-db.org/app/kellia/config" at "config.xqm";



declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace ka="http://www.uni-goettingen.de/kellia";



(:~
 : This is a sample templating function. It will be called by the templating module if
 : it encounters an HTML element with an attribute data-template="app:test" 
 : or class="app:test" (deprecated). The function has to take at least 2 default
 : parameters. Additional parameters will be mapped to matching request or session parameters.
 : 
 : @param $node the HTML node with the attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
declare function app:test($node as node(), $model as map(*)) {
    <p>{current-dateTime()}: {$config:data-root}.</p>
};

declare function app:list-projects($node as node(), $model as map(*)) {
    let $collection := collection($config:data-root)
    
    return
        <ol class="project-list">
            {
            (:let $resource-uri := base-uri($resource):)
            let $projects := (
                for $resource in $collection
                return
                    $resource/ka:kelliaEditions/ka:projects/ka:project
            )
            for $project at $nr in $projects
            let $title := $project/ka:projectDesc/ka:title/text()
            let $project-url := $project/@url
            
            order by lower-case($title)
            return 
                <li>
                   
                    {
                        (:data($nr),
                        ": ",:)
                        
                        $title,
                        " (",
                        <a class="website" href="{$project-url}">
                            www
                        </a>,
                        ")"
                        
                    }
                    
                    <div class="small-profile">
                        <div class="row">
                            <div class="col-lg-4 col-md-4">
                                
                            </div>
                            <div class="col-lg-4 col-md-4">
                                
                            </div>
                            <div class="col-lg-4 col-md-4">
                                
                            </div>
                            
                        </div>
                    
                        <div class="row">
                            <div class="col-lg-12 col-md-12">
                                <strong>resource:</strong><br></br>
                                {
                                    base-uri($project)
                                }
                            </div>
                            
                            <div class="col-lg-12 col-md-12">
                                <strong>project aims:</strong><br></br>
                                {
                                    $project//ka:projectAims
                                }
                            </div>
                        </div>
                    </div>
                </li>
        
            }
        </ol>
};

declare function app:projects-count($node as node(), $model as map(*)) {
    let $collection := collection($config:data-root)
    let $projects := (
        for $resource in $collection
        return
            $resource/ka:kelliaEditions/ka:projects/ka:project
            )
    return <td>{count($projects)}</td>
};

declare function app:schemas-used($node as node(), $model as map(*)) {
    let $collection := collection($config:data-root)
    
    return
        <td>
            {
        let $schemas := (
            for $schema in $collection//ka:kelliaEditions/ka:projects/ka:project/ka:dataDesc//ka:desc/@schema
            return 
                lower-case($schema)
            )
        
        let $schema-used := distinct-values($schemas)
        
        return 
            $schema-used
            }
        </td>
};