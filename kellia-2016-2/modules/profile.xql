xquery version "3.0";

module namespace profile="http://exist-db.org/app/kellia/profile";

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




declare function local:schemas-used($node as node(), $model as map(*)) {
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


declare function profile:transform-project($nodes as node()*) as item()* {
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
                        profile:transform-project($node/node())
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
    for $node in $nodes/node() return profile:transform-project($node)
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
                    <a href="{data($node/@url)}">
                        {profile:transform-project($node/node()/ka:title)}
                    </a>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-10 col-lg-offset-1 col-md-10 col-md-offset-1">
                <!--col-lg-7 col-lg-offset-1 col-md-10 col-md-offset-1-->
                    <div class="row">
                        <div class="col-lg-6 col-md-5">
                            <h3>general information</h3>
                            {local:project-data($node/ka:projectDesc)}
                        </div>
                        <div class="col-lg-5 col-lg-offset-1 col-md-5 col-md-offset-1">
                        <h3>dates</h3>
                            {local:project-dates($node/ka:projectDesc)}
                        </div>
                    </div>
                    <h3>project-description</h3>
                    {local:project-desc($node/ka:projectDesc)}
                    
                    <h3>data-description</h3>
                    {local:data-desc($node/ka:dataDesc)}
                    <!--
                    {profile:transform-project($node/ka:projectDesc)}
                    {profile:transform-project($node/ka:dataDesc)}
                    -->
                </div>
                <!--
                <div class="col-lg-3 col-lg-offset-1 col-md-10 col-md-offset-1 metadata">
                    
                </div>
                -->
            </div>
            <div class="row">
                <div class="col-lg-10 col-lg-offset-1 col-md-10 col-md-offset-1">
                    
                    {local:revision($node/ka:revision)}
                </div>
            </div>
        </div>
    
    </div>
};

declare function local:project-desc($node as element(ka:projectDesc)) as element() {
    
        <div class="project-desc">
            
            <table class="table table-condensed table-bordered">
                {
                    for $node in $node/ka:desc[@resp]/node()
                    return 
                    typeswitch($node)
                    
                    case element(ka:searchWord) 
                    
                    return (
                        <tr>
                            <td>found on {
                                if($node[@key])
                                then(
                                    <a href="{data($node/@url)}">
                                    {
                                    data($node/@key)
                                    }    
                                    </a>
                                    )
                                else (data($node/@url))
                            }</td>
                            <td><strong>comment:</strong> {$node}</td>
                        </tr>
                        )
                        
                    case element(ka:kelliaRating) return (
                        <tr>
                            <td>rating {data($node/@points)}</td>
                            <td><strong>comment:</strong> {$node}</td>
                        </tr>
                        )
                        
                    case element(ka:respStmt) return (
                        <tr>
                            <td>{$node/ka:resp}</td>
                            <td>
                                <ul>
                                {
                                    for $person in $node/ka:person
                                    let $name := $person/ka:name
                                    let $mail := $person/ka:email
                                    order by $name
                                    return
                                        <li><a href="mailto:{$mail}">{$name}</a></li>
                                }
                                </ul>
                            </td>
                        </tr>
                        )
                        
                    case element(ka:projectAims) return (
                        <tr>
                            <td>project aims</td>
                            <td>
                                <ul>
                                {
                                    for $aim in $node/ka:aim
                                    order by $aim
                                    return
                                        <li>{$aim}</li>
                                }
                                </ul>
                            </td>
                        </tr>
                        )
                        
                    case element(ka:institutions) return (
                        <tr>
                            <td>responsible institutions</td>
                            <td>{
                                if($node[child::ka:note])
                                then(
                                    <div>
                                        <strong>general note:</strong> {
                                        $node/ka:note
                                        }
                                    </div>
                                )
                                else()
                                } 
                                <ul>
                                {
                                    for $institution in $node/ka:institution
                                    let $role := data($institution/@role)
                                    let $url := data($institution/@url)
                                    let $from := data($institution/@from)
                                    let $to := data($institution/@to)
                                    
                                    order by $role
                                    return
                                        <li>{
                                            if($from)
                                            then(
                                                $from,"-",$to,": "
                                                )
                                            else()
                                            }
                                            {
                                             if($url)
                                            then(
                                                <a href="{$url}">
                                                    {$institution}
                                                </a>
                                                )
                                            else($institution)   
                                            }
                                            
                                            ({$role})
                                        </li>
                                }
                                </ul>
                            </td>
                        </tr>
                        )
                        
                    
                    default return ()
                }
            </table>

        </div>
};

declare function local:data-desc($node as element(ka:dataDesc)) as element() {
    
        <div class="data-desc">
            {
            for $node in $node/ka:dataSet/ka:note
            return
                local:transDesc($node),
                
            for $node in $node/ka:dataSet/ka:desc
            return
                local:transDesc($node),
            
            if($node/ka:dataSet/ka:url)
            then(<div>
                <h5>URLs</h5>
                <table class="table table-condensed table-bordered"> 
                    {
                    for $node in $node/ka:dataSet/ka:url
                    let $type := data($node/@type)
                    let $target := util:unescape-uri(data($node/@target), "UTF-8")
                    
                    return
                        <tr>
                            <td>{$type}</td>
                            <td>
                                <a href="{$target}">{$target}</a>
                            </td>
                        </tr>
                    }
                </table>
                </div>
                )
            else()
            
            }   
        </div>
};

declare function local:transDesc($nodes as node()*) as item()* {
    for $node in $nodes
    return 
        typeswitch($node)
            case text() return $node
            case comment() return $node
            
            case element(ka:dataSet) 
                return (
                    <div> 
                        <h5>dataset</h5>
                        {local:transDesc($node/node())}
                    </div>
                    )
            
            case element(ka:note) 
                return (
                    <div> 
                        <h5>note:</h5>
                        {local:transDesc($node/node())}
                    </div>
                    )
                    
            case element(ka:p) 
                return (
                    <p> 
                        {local:transDesc($node/node())}
                    </p>
                    )
            
            case element(ka:desc) 
                return (
                    <div> 
                        <h5>description:</h5>
                        {local:transDesc($node/node())}
                    </div>
                    )
            
            case element(ka:example) 
                return (
                    <div> 
                        <h5>example:</h5>
                        {local:transDesc($node/node())}
                    </div>
                    )
                    
            case element(ka:url) 
                return(
                    <a href="{util:unescape-uri($node/text(), "UTF-8")}">
                        {
                            $node/text()
                        }
                    </a>
                    )
                    
            case element(ka:ref) 
                return(
                    <a href="{util:unescape-uri($node/text(), "UTF-8")}">
                        {
                            $node/text()
                        }
                    </a>
                    )
                
            
            default return local:transDesc($node/node())
};







declare function local:revision($node as element(ka:revision)) as element() {
    <div class="revision">
        <h3>revision history of resource-entry</h3>
        <div class="{data($node/@status)}">
            <strong>
            {
                switch(data($node/@status))
                case ("draft") return ("resource is in draft")
                case ("to_controll") return ("resource needs to be controlled!")
                case ("controlled") return ("resource needs to be accepted!")
                case ("accepted") return ("resource is ready to be finished!")
                case ("finished") return ("resource is finished!")
                default return ()
                
            }
            </strong>
        </div>
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
        <tr>
            <td>resource</td>
            <td>
                <a href="http://localhost:8080/exist/apps/eXide/index.html?open={util:unescape-uri(base-uri($node/ancestor::ka:project), "UTF-8")}">
                    {replace(base-uri($node/ancestor::ka:project), ".+/(.+)$", "$1")}
                </a>
            </td>
        </tr>
        
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
        
        {
            for $schemas in $node/ancestor::ka:project//ka:desc[@schema]
            let $schema := tokenize(data($schemas/@schema), " ")
            return 
                <tr>
                    <td>schemas used</td>
                    <td>
                        <ul>
                        {
                        for $item in $schema
                        return 
                            <li>
                                {
                                $item
                                }
                            </li>
                        }
                        </ul>
                    </td>
                </tr>
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
                return (profile:transform-project($node/node()))
            default return ()
        }
    </div>
};
