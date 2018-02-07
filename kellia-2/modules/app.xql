xquery version "3.0";

module namespace app="http://exist-db.org/app/kellia/templates";

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
import module namespace config="http://exist-db.org/app/kellia/config" at "config.xqm";
import module namespace profile="http://exist-db.org/app/kellia/profile" at "profile.xql";



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
    <td>
        {
        $config:data-root
        }
    </td>
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
                        
                        <a href="project-profile.html?resource={base-uri($project)}&amp;project={util:hash($project-url, 'md5')}">{$title}</a>
                        
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
                                <a href="http://localhost:8080/exist/apps/eXide/index.html?open={base-uri($project)}">
                                {
                                    base-uri($project)
                                }
                                </a>
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
                for $item in $schema
                return tokenize(lower-case($item), " ")
            )

        let $schema-used := distinct-values($schemas)
        
        return (
            <ul style="list-style:none; padding-left:0;">
                {
                for $schema in $schema-used
                let $count := count($schemas[.=$schema])
                
                order by $count descending
                return 
                    <li class="schema" style="padding:0 0 5px 0">
                        {
                        $schema
                        } ({$count})
                    </li>
                }
            </ul>
            )
            
            
            }
        </td>
        
};

declare function app:revision-status($node as node(), $model as map(*)) {
    let $collection := collection($config:data-root)
    
    return
        <td>
            {
        
            for $project in $collection//ka:kelliaEditions/ka:projects/ka:project
            return
                data($project/ka:revision/@status)
            
            }
        </td>
        
};


declare function app:project-profile($node as node(), $model as map(*), $resource as xs:string, $project as xs:string) {
    let $project-hash := $project
    let $resource := doc($resource)
    
    return
        <div>
            {
            (:local:transform-project($project):)
            (:$project,:)
            (:<h1>text:<br></br>{data($resource/ka:kelliaEditions/ka:kelliaHead/ka:title)}</h1>:)
            
            
            for $i in $resource/ka:kelliaEditions/ka:projects/ka:project
            return
                if(util:hash($i/@url, 'md5') eq $project-hash)
                then(profile:transform-project($i))
                else()

                (:util:hash($i/ka:title/text(), 'md5') eq $project-hash:)
            }
        </div>
};


(:  
declare function local:transform-project($nodes as node()*) as item()* {
    for $node in $nodes
    return 
        typeswitch($node)
            case text() return $node
            case comment() return $node
            
            case element(ka:project) return (local:project($node))
            
            case element(ka:projectDesc) return (local:project-desc($node))
            
            case element(ka:title) return (
                <h1 class="project-title">
                    {
                        local:transform-project($node/node())
                    }
                </h1>
                )
                
            case element(ka:country) return ()
                
            case element(ka:dataDesc) return (
                <div class="data-desc">
                    <h3>Data Description:</h3>
                    {
                        local:passthru($node)
                    }
                </div>
                )
                
            case element(ka:dataSet) return (
                <div class="data-set">
                    <h5>data-set</h5>
                    <table class="table table-condensed table-bordered">
                    {
                        for $url in $node/child::ka:url
                        return(
                            if($url[@type])
                            then(
                                <tr>
                                    <td>TYPE:</td>
                                    <td> 
                                        {
                                            data($url/@type)
                                        }
                                    </td>
                                </tr>
                                )
                            else(<tr>
                                    <td>TYPE:</td>
                                    <td>
                                        no type available
                                    </td>
                                </tr>),
                            
                            if($url[@target])
                            then(
                                <tr>
                                    <td>URL:</td>
                                    <td>
                                        <a href="{$url/@target}">
                                        {
                                            data($url/@target)
                                        }
                                        </a><br></br>
                                        {
                                            data($url)
                                        }
                                    </td>
                                </tr>
                                )
                            else(<tr>
                                    <td>URL:</td>
                                    <td>
                                        no link available<br></br>
                                        {
                                            data($url)
                                        }
                                    </td>
                                </tr>)
                        )
                    }
                    {        
                        for $desc in $node/ka:desc
                        return
                            <tr>
                                    <td>Description:</td>
                                    <td>
                                        {
                                            data($desc)
                                        }
                                    </td>
                                </tr>
                    }
                    </table>
                </div>
                )
            
            
            case element(ka:desc) return (local:desc($node))
            
            case element(ka:revision) return ()
            
            
            
            default return local:passthru($node)
};

declare function local:passthru($nodes as node()*) as item()* {
    for $node in $nodes/node() return local:transform-project($node)
};

declare function local:project($node as element(ka:project)) as element() {
    <div class="row">
        <header class="intro-header" style="background-image: url('resources/img/home-bg.jpg')">
            <div class="container">
                <div class="row">
                    <div class="col-lg-8 col-lg-offset-2 col-md-10 col-md-offset-1">
                        <div class="site-heading">
                            <h1>Project-Profile</h1>
                        </div>
                    </div>
                </div>
            </div>
        </header>
        
        <!-- Main Content -->
        <div class="container">
            <div class="row">
                <div class="col-lg-10 col-lg-offset-1 col-md-10 col-md-offset-1">
                    {local:transform-project($node/node()/ka:title)}
                    <span class="glyphicon glyphicon-home" aria-hidden="true"></span> : 
                    <a href="{data($node/@url)}">
                        project-website
                    </a>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-7 col-lg-offset-1 col-md-10 col-md-offset-1">
                    {local:transform-project($node/ka:projectDesc)}
                    {local:transform-project($node/ka:dataDesc)}
                </div>
                <div class="col-lg-3 col-lg-offset-1 col-md-10 col-md-offset-1 metadata">
                    {local:project-data($node/ka:projectDesc)}
                    {local:project-dates($node/ka:projectDesc)}
                </div>
            </div>
            <div class="row">
                <div class="col-lg-10 col-lg-offset-1 col-md-10 col-md-offset-1">
                    <h5>revision history of resource-entry</h5>
                    {local:revision($node/ka:revision)}
                </div>
            </div>
        </div>
    
    </div>
};

declare function local:project-desc($node as element(ka:projectDesc)) as element() {
    
        <div class="project-desc">
            {local:transform-project($node/node() except ($node/ka:title))}
        </div>
    
};

declare function local:revision($node as element(ka:revision)) as element() {
    <div class="revision">
    <table class="table table-condensed table-bordered">
        {
            for $date in $node/ka:date
            let $when := data($date/@when)
            let $datum := replace($when, "([0-9]+)-([0-9]+)-([0-9]+)", "$3.$2.$1") 
            let $text := $date/text()
            let $resp := data($date/@resp)
            order by $when descending
            return 
                <tr>
                    <td>{$datum}</td>
                    <td>{$resp}</td>
                    <td>{$text}</td>
                </tr>
        }
    </table>
    </div>
};

declare function local:project-data($node as element(ka:projectDesc)) as element() {
    <div class="project-data">
    <table class="table table-condensed table-bordered">
        {
            for $node in $node/node()
            return 
                typeswitch($node)
                case element(ka:country) return (
                    <tr>
                        <td>country</td>
                        <td>{data($node)}</td>
                    </tr>
                    )
                    
                case element(ka:links) return (
                    <tr>
                        <td>foreign links</td>
                        <td><ul style="list-style:none; padding-left:0;">
                            {
                                for $url at $nr in $node/ka:url
                                let $link := data($url/@target)
                                let $base := replace($link, "(http://)?(.+)\.", "$2")
                                order by $link
                                return 
                                    <li>
                                        <a href="{$link}">
                                        link {$nr}
                                        </a>
                                    </li>
                            }
                        </ul></td>
                    </tr>
                    )
                default return ()
        }
    </table>
    </div>
};

declare function local:project-dates($node as element(ka:projectDesc)) as element() {
    <div class="project-dates">
    <table class="table table-condensed table-bordered">
        {
            for $date in $node/ka:dates/ka:date
            let $when := data($date/@when)
            let $text := $date/text()
            return 
                <tr>
                    <td>{$text}</td>
                    <td>{$when}</td>
                </tr>
        }
    </table>
    </div>
};

declare function local:desc($node as element(ka:desc)) as element() {
    <div class="description">
        <h3>
            description
            {
                if($node[@source])
                then(
                    "from ",
                    <a href="{data($node/@source)}">
                        <!--{data($node/@source)}-->
                        foreign source
                    </a>
                    )
                else(),
                
                if($node[@resp])
                then(
                    "by ", data($node/@resp)
                    )
                else()
            }
        </h3>
        {
        typeswitch($node/parent::node())
            case element (ka:projectDesc)
                return (local:transform-project($node/node()))
            default return ()
        }
    </div>
};
:)
