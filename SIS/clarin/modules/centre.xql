xquery version "3.0";

module namespace cm = "http://clarin.ids-mannheim.de/standards/centre-module";
import module namespace centre = "http://clarin.ids-mannheim.de/standards/centre" at "../model/centre.xqm";
import module namespace format = "http://clarin.ids-mannheim.de/standards/format" at "../model/format.xqm";
import module namespace recommendation = "http://clarin.ids-mannheim.de/standards/recommendation-model"
at "../model/recommendation-by-centre.xqm";

import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "app.xql";
import module namespace rf = "http://clarin.ids-mannheim.de/standards/recommended-formats" at "recommended-formats.xql";
import module namespace dm = "http://clarin.ids-mannheim.de/standards/domain-module" at "domain.xql";
import module namespace web="https://clarin.ids-mannheim.de/standards/web" at "../model/web.xqm";


declare function cm:get-centre($id) {
    centre:get-centre($id)
};

declare function cm:getLastUpdateCommitId($id){
    let $recommendation := recommendation:get-recommendations-for-centre($id)
    let $commitId := $recommendation/header/lastUpdateCommitID/text()
    let $githubLink := concat("https://github.com/clarin-eric/standards/commit/", $commitId)
    let $short-commitId := fn:substring($commitId,1,8)
    return <a href="{$githubLink}">{$short-commitId}</a>
};


declare function cm:getGithubCentreIssueLink($centre-id) {
    let $ghLink := 'https://github.com/clarin-eric/standards/issues/new?assignees=&amp;labels=centre+data%2C+templatic&amp;template=incorrect-missing-centre-recommendations.md&amp;title=Suggestion regarding the recommendations of centre ID="' 
    let $ghLink := concat($ghLink, $centre-id, '", webCommitId=',web:get-short-commitId())
    return $ghLink
};

declare function cm:print-statuses($status){
   let $statutes := centre:get-statutes()
   for $s in $statutes
   order by fn:lower-case($s)
   return
           if ($s eq $status)
           then
               (<option
                   value="{$s}"
                   selected="selected">{$s}</option>)
           else
               (<option
                   value="{$s}">{$s}</option>)
};

declare function cm:list-centre($sortBy,$statusFilter) {
    for $c in $centre:centres
        let $name := $c/name/text()
        let $ri := $c/nodeInfo/ri/text()
        let $id := data($c/@id)
        let $status-text := data($c/nodeInfo/ri/@status)
        let $statuses :=
        if (fn:contains($status-text, ","))
        then
            <span>{
                    for $status in fn:tokenize(data($c/nodeInfo/ri/@status), ",")
                    return
                        ($status, <br/>)
                }
            </span>
        else
            $status-text
        
        order by
        
        if ($sortBy eq 'name')
        then fn:lower-case($name)
        else if ($sortBy eq 'ri')
        then fn:lower-case($ri)
        else if ($sortBy eq 'id')
        then (fn:lower-case($id))
        else (fn:lower-case($id))
        
        return
            if ($statusFilter)
            then 
                if ($statuses[.=$statusFilter])
                then cm:print-centre-row($id, $name, $ri, $statuses)
                else ()
            else (cm:print-centre-row($id, $name, $ri, $statuses))
};

declare function cm:print-centre-row($id, $name, $ri, $statuses){
    <tr>
        <td class="recommendation-row"><a href="{app:link(concat("views/view-centre.xq?id=", $id))}">{$id}</a></td>
        <td class="recommendation-row">{$name}</td>
        <td class="recommendation-row">{$ri}</td>
        <td class="recommendation-row">{$statuses}</td>
    </tr>
};

declare function cm:print-recommendation-table($id, $sortBy) {
    let $recommendation := recommendation:get-recommendations-for-centre($id)
    let $path := concat('/db/apps/clarin/data/recommendations', $id, "-recommendation.xml")
    return
        if (count($recommendation/formats/format)>0)
        then
            (
            <div style="margin-top: 30px;">
                <span class="heading" id="recommendationTable">Recommendations: </span>
            </div>,
            <div style="margin-bottom: 30px;">
                <span >Last update commit-id: </span>
                <span id="commit-id">{cm:getLastUpdateCommitId($id)}</span>
                <span style ="float:right;">
                    <a href="{cm:getGithubCentreIssueLink($id)}" class="button" 
                        style="padding: 5px 5px 2px 5px; color:darkred; border-color:darkred">
                        suggest a fix or extension</a>
                </span>
            </div>,
            <table cellspacing="4px" style="width:97%">
                <tr>
                    <th class="header" style="width:15%;">
                        <a href="{
                                    app:link(concat("views/view-centre.xq?id=", $id, "&amp;sortBy=format#recommendationTable"))
                                }">Format</a>
                    </th>
                    <th class="header" style="width:30%;">
                        <a href="{
                                    app:link(concat("views/view-centre.xq?id=", $id, "&amp;sortBy=domain#recommendationTable"))
                                }">Domain</a></th>
                    <th class="header" style="width:15%;">
                        <a href="{
                                    app:link(concat("views/view-centre.xq?id=", $id, "&amp;sortBy=recommendation#recommendationTable"))
                                }">
                            Level</a></th>
                    <th class="header" style="width:40%;">
                        Comments
                    </th>
                </tr>
                {cm:print-recommendation-rows($recommendation, $id, $sortBy)}
            </table>
            )
        else
            ()
};

declare function cm:print-recommendation-rows($recommendation, $centre-id, $sortBy) {
    for $format in $recommendation/formats/format
        let $format-id := data($format/@id)
        let $format-obj := format:get-format($format-id)
        let $format-abbr := $format-obj/titleStmt/abbr/text()
        let $level := $format/level/text()
        let $domainName := $format/domain/text()
        let $domain :=
            if ($domainName) then
                dm:get-domain-by-name($domainName)
            else ()
            
        order by
        if ($sortBy = 'format') then
            (if ($format-abbr) then fn:lower-case($format-abbr) else fn:lower-case(fn:substring($format-id,2)))
        else
            if ($sortBy = 'domain') then
                $domainName
            else
                if ($sortBy = 'recommendation') then
                    $level
                else (:by format:)
                    (if ($format-abbr) then fn:lower-case($format-abbr) else fn:lower-case(fn:substring($format-id,2)))
    return 
        rf:print-recommendation-row($format, $centre-id, $domain, fn:true(), fn:false())
};
