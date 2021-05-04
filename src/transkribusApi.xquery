(:~
: XQuery Module API for Transkribus PageXML
: This module provides access to Transkribus PageXML files via Xquery functions. 
: It is designed to be used in context of a Basex xml database, but should work with other xml databases as well.
:
: @author Peter Hinkelmanns
: @version 1.0
:)

module namespace  trapi = "http://transkribusapi.mhdbdb.sbg.ac.at" ;

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace mets="http://www.loc.gov/METS/";
declare namespace xlink="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace page="http://schema.primaresearch.org/PAGE/gts/pagecontent/2013-07-15";
declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace err = "http://www.w3.org/2005/xqt-errors";
declare namespace output = 'http://www.w3.org/2010/xslt-xquery-serialization';

(: get functions :)
    (: Document :)
        
        (:~
        : Returns all mets:mets document elements of the database.
        :
        : @param    $db database name.
        : @return   element()*.
        :)
        declare function trapi:getDocuments($db as xs:string?) as element()*
        {
            db:open($db)//mets:mets
        };

        (:~
        : Returns a single mets:mets document selected by docId.
        :
        : @param $db        database name.
        : @param $docId     document id.
        : @return element().
        :)
        declare function trapi:getDocument($db as xs:string?, $docId as xs:string?) as element()
        {
            (db:open($db)//mets:mets[string(//*:docId[1]) = $docId])[1]
        };

    (: Pages :)
        (:~
        : Returns all page:PcGts elements of a document selected by docId.
        :
        : @param $db        database name.
        : @param $docId     document id.
        : @return element()*.
        :)
        declare function trapi:getPages($db as xs:string?, $docId as xs:string?) as element()*
        {
            for $page in db:open($db)//page:PcGts[//*:TranskribusMetadata[@docId=$docId]]
            order by $page//*:TranskribusMetadata[@pageNr]
            return $page
        };

        (:~
        : Returns the ancestor page:PcGts element of a selected by element.
        :
        : @param $element   xml element.        
        : @return element().
        :)
        declare function trapi:currentPage($element as element()) as element()
        {
            ($element/ancestor-or-self::*:PcGts)[1]        
        };
        
        (:~
        : Returns a comma seperated string of all pagenumbers of the selected textregions.
        :
        : @param $element   textregion element.        
        : @return           xs:string.
        :)
        declare function trapi:getPageRange($textRegions as element()*) as xs:string
        {
            let $TranskribusMetadatas := 
                for $textRegion in $textRegions
                return string(trapi:currentPage($textRegion)//*:TranskribusMetadata/@pageNr)
            return string-join(distinct-values($TranskribusMetadatas), ', ')
        };    

    (: TextRegions :)
        
        (:~
        : Returns the all textregions of selected pages.
        :
        : @param $pages   pagexml pages.        
        : @return element()*.
        :)
        declare function trapi:getRegions($pages as element()*) as element()*
        {
            $pages//*:TextRegion
        };

        (:~
        : Returns the all textregions of selected pages and a specific region type (Transkribus structure type).
        :
        : @param $pages         pagexml pages.      
        : @param $regionType    Transkribus structure type.     
        : @return element()*.
        :)
        declare function trapi:getRegions($pages as element()*, $regionType as xs:string?) as element()*
        {
            for $region in trapi:getRegions($pages)
            where trapi:getRegionType($region) eq $regionType
            return 
            $region 
        };

        (:~
        : Returns the region type (Transkribus structure type) of a selected textregion.
        :
        : @param $region    TextRegion.        
        : @return           xs:string.
        :)
        declare function trapi:getRegionType($region as element()) as xs:string
        {    
            let $annotations := trapi:parseTranskribusCustomAttribute($region/@custom)
            return 
                if (exists($annotations)) then
                string($annotations//*:annotation[@tag='structure']/*:attr[@key='type']/@value)
                else
                'NONE'
        };        

        (:~
        : Returns all following regions of a TextRegion in a list of page elements
        :
        : @param $pages         Page elements.        
        : @param $startRegion   TextRegion.
        : @return               element()*.
        :)
        declare function trapi:getFollowingRegions($pages as element()*, $startRegion as element()) as element()*
        {
            let $currentPage := trapi:currentPage($startRegion)
            let $followingRegionsCurrentPage := $startRegion/following::*:TextRegion
            let $i := index-of($pages, $currentPage) + 1 
            let $followingRegionsOtherPages :=
                for $page in subsequence($pages, $i, count($pages))
                return
                    $page//*:TextRegion
            return 
                if (count($followingRegionsOtherPages) > 0)
                then
                    ($followingRegionsCurrentPage, $followingRegionsOtherPages)
                else $followingRegionsCurrentPage
        };
            
        (:~
        : Returns all following regions of a specific type of a TextRegion in a list of page elements
        :
        : @param $pages                 Page elements.        
        : @param $startRegion           TextRegion.
        : @param $followingRegionType   Transkribus structure type.  
        : @return                       element()*.
        :)    
        declare function trapi:getFollowingRegions($pages as element()*, $startRegion as element(), $followingRegionType as xs:string?) as element()*
        {
            let $textRegions := trapi:getFollowingRegions($pages,$startRegion)
            return
                for $textRegion in $textRegions
                where trapi:hasRegionType($textRegion, $followingRegionType)
                return $textRegion
        };

        (:~
        : Returns all following regions of a specific type of a TextRegion in a list of page elements
        :
        : @param $pages                 Page elements.        
        : @param $startRegion           TextRegion.
        : @param $followingRegionType   Transkribus structure type.  
        : @return                       element()*.
        :)   
        declare function trapi:getFollowingTextRegions(
            $pages as element()*, 
            $startRegion as element(), 
            $followingRegionType as xs:string?) as element()*
        {
            let $followingRegions := trapi:getFollowingRegions($pages, $startRegion)
            let $startRegionType := trapi:getRegionType($startRegion)
            let $firstFollowingStartRegion := 
                (
                    for $followingRegion in $followingRegions
                    where trapi:hasRegionType($followingRegion, $startRegionType)                
                    return $followingRegion
                )[1]
            
            return 
                if (exists($firstFollowingStartRegion))
                then
                    let $iFirstFollowingStartRegion := index-of($followingRegions, $firstFollowingStartRegion)
                    return
                        for $followingRegion in subsequence($followingRegions, 1, $iFirstFollowingStartRegion)
                        where trapi:hasRegionType($followingRegion, $followingRegionType)                
                        return $followingRegion
                else
                    for $followingRegion in $followingRegions
                    where trapi:hasRegionType($followingRegion, $followingRegionType)                
                    return $followingRegion
        };
        
        (:~
        : Returns all preceding regions of a TextRegion in a list of page elements
        :
        : @param $pages         Page elements.        
        : @param $startRegion   TextRegion.
        : @return               element()*.
        :)
        declare function trapi:getPrecedingRegions($pages as element()*, $startRegion as element()) as element()*
        {
            let $currentPage := trapi:currentPage($startRegion)
            let $precedingRegionsCurrentPage := $startRegion/preceding::*:TextRegion
            let $i := index-of($pages, $currentPage)    
            let $precedingRegionsOtherPages :=
                for $page in reverse(subsequence($pages, 1, $i))
                return
                    for $textRegion in reverse($page//*:TextRegion)
                    return
                    $textRegion
            return ($precedingRegionsCurrentPage, $precedingRegionsOtherPages)        
        };
        
        (:~
        : Returns all preceding regions of a specific type of a TextRegion in a list of page elements
        :
        : @param $pages                 Page elements.        
        : @param $startRegion           TextRegion.
        : @param $precedingRegionType   Transkribus structure type.  
        : @return                       element()*.
        :)    
        declare function trapi:getPrecedingRegions($pages as element()*, $startRegion as element(), $precedingRegionType as xs:string?) as element()*
        {
            let $textRegions := trapi:getPrecedingRegions($pages,$startRegion)
            return
                for $textRegion in $textRegions
                where trapi:hasRegionType($textRegion, $precedingRegionType)
                return $textRegion
        }; 

        (:~
        : Returns the text of the next preceding textregion selected by type
        :
        : @param $pages                 Page elements.        
        : @param $startRegion           TextRegion.
        : @param $chapterRegionType     Transkribus structure type.  
        : @return                       xs:string.
        :)   
        declare function trapi:getchapterHeading($pages as element()*, $startRegion as element(), $chapterRegionType as xs:string) as xs:string
        {   
            let $precedingChapterHeading:= trapi:getPrecedingRegions($pages, $startRegion, $chapterRegionType)[1] 
            return
            normalize-space(string($precedingChapterHeading/*:TextEquiv[1]))        
        };

        (:~
        : Returns all textregions belonging to a text, selected by start and the type of the following textregions
        :
        : @param $pages                 Page elements.        
        : @param $startRegion           TextRegion.
        : @param $followingRegionType   Transkribus structure type.  
        : @return                       element()*
        :)   
        declare function trapi:getTextRegions(
            $pages as element()*, 
            $startRegion as element(), 
            $followingRegionType as xs:string?) as element()*
        {
            let $followingTextRegions := trapi:getFollowingTextRegions($pages, $startRegion, $followingRegionType)
            
            let $textRegions :=
                if (count($followingTextRegions) > 0) 
                then
                (
                    $startRegion,
                    $followingTextRegions
                )
                else 
                $startRegion

            return $textRegions
        };

    (: TextLines :)
        (:~
        : Returns all TextLine belonging to selected TextRegion
        :          
        : @param $textRegions           TextRegions. 
        : @return                       element()*
        :)  
        declare function trapi:getLines($textRegions as element()*) as element()*
        {
            for $textRegion in $textRegions
            return $textRegion/*:TextLine
        };


(: test functions :)
    (:~
        : Tests if a selected TextRegion is of a certain type
        :          
        : @param $region       TextRegion. 
        : @param $regionType   Transkribus structure type.
        : @return              xs:boolean
        :)  
    declare function trapi:hasRegionType($region as element(), $regionType as xs:string) as xs:boolean
        {    
            ends-with($region/@custom, concat('{type:', $regionType,';}'))
        };


(: parsing functions :)
    (:~
    : This funtions parses a transkribus @custom attribute and returns it as an element of the following form:
    :   <annotations>
    :       <attr key="index" value="2"/>
    :       <annotation tag="readingOrder">
    :        </annotation>
    :        <annotation tag="Wunder_Ort">
    :            <attr key="offset" value="7"/>
    :            <attr key="length" value="25"/>
    :            <attr key="Name" value="Olmütz"/>
    :        </annotation>
    :        <annotation tag="Wunder_Wallfahrt">
    :            <attr key="offset" value="33"/>
    :            <attr key="length" value="14"/>
    :            <attr key="continued" value="true"/>
    :        </annotation>
    :    </annotations>
    : @param   $custom string value of a Transkribus @custom attribute
    : @return  annotations element
    :)
    declare function trapi:parseTranskribusCustomAttribute($custom as xs:string?) as element()
    {   
        <annotations>
        {
            for $annotation in analyze-string($custom, "[^\{]+\{[^\}]+\}")//fn:match
            return 
                let $tag := string(analyze-string(string($annotation), "^\s*([^\s]+)")//*:group[1])
                let $attributes := 
                    for $attribute in analyze-string(string($annotation), "[\w-_]+:[^;]+")//*:match
                    return
                        let $keyValue := analyze-string(string($attribute), "([^:]+):([^;]+)")
                        return 
                        <attr key="{string($keyValue//*:group[@nr='1'])}" value="{string($keyValue//*:group[@nr='2'])}"/>
                return 
                <annotation tag="{$tag}">
                    {$attributes}
                </annotation>
        }
        </annotations>
    };

(: json functions:)
    declare function trapi:_getTextMetadata(
        $pages as element()*, 
        $startRegion as element()?, 
        $followingRegionType as xs:string?, 
        $chapterRegionType as xs:string?
    ) as element()*
    {                        
        let $textRegions := trapi:getTextRegions($pages, $startRegion, $followingRegionType)        
        let $result := 
            (
                <string xmlns="http://www.w3.org/2005/xpath-functions" key="id">{ string($startRegion/@id) }</string>,                               
                <string xmlns="http://www.w3.org/2005/xpath-functions" key="chapterHeading">{ trapi:getchapterHeading($pages, $startRegion, $chapterRegionType) }</string>, 
                <string xmlns="http://www.w3.org/2005/xpath-functions" key="pageRange">{ trapi:getPageRange($textRegions) }</string>                
            )

        return
            try {     
                $result
            } catch * {
                'trapi:_getTextMetadata: Sonstiger Fehler (' || $err:code || '): ' || $err:description
            }        
    };

    declare function trapi:_getTextData(
        $pages as element()*, 
        $startRegion as element()?, 
        $followingRegionType as xs:string?, 
        $chapterRegionType as xs:string?
    ) as element()*
    {
        let $textRegions := trapi:getTextRegions($pages, $startRegion, $followingRegionType)        
        let $lineData := 
        <lines>{
            for $textRegion in $textRegions
                let $regionId := string($textRegion/@id)
            return
                for $line in trapi:getLines($textRegion)                        
                    let $norm := normalize-space(string($line//*:Unicode[1]))
                    let $break := ends-with($norm,'¬')
                    let $unicode := 
                        if (ends-with($norm,'¬'))
                        then replace($norm, '¬', '')
                        else concat($norm,' ')
                    let $annotations := trapi:parseTranskribusCustomAttribute($line/@custom)
                return
                    <line break='{$break}' id='{$line/@id}'>
                        <textRegionId>{$regionId}</textRegionId>
                        <unicode>{$unicode}</unicode>                        
                        <length>{string-length($unicode)}</length>
                        {$annotations}
                    </line>
        }</lines>

        let $result := 
        (
            <string key="unicode">{
                normalize-space(
                    string-join(
                        for $unicode in $lineData//*:unicode return string($unicode)
                    )
                )
            }</string>,
            <array key="annotations">
            {
                for $line in $lineData//*:line
                    let $prevLength := 
                        sum(
                            for $length in $line/preceding::*:length return number($length)
                        )
                return
                    for $annotation in $line//*:annotation
                    where $annotation/*:attr[@key='offset']
                        let $oldOffset := $annotation/*:attr[@key='offset']/@value
                        let $newOffset := number($oldOffset) + $prevLength 
                        let $length := string($annotation/*:attr[@key='length']/@value)
                        let $tag := string($annotation/@tag)
                    return
                    <map>                        
                        <string key="offset">{$newOffset}</string>
                        <string key="length">{$length}</string>
                        <string key="tag">{$tag}</string>    
                        {
                            if (exists($annotation/*:attr[@key='continued']))
                            then <string key="continued">true</string>
                            else ()
                        }
                        <map key="attributes">  
                        {
                            for $attr in $annotation/*:attr
                            where (
                                $attr/@key != 'offset' and
                                $attr/@key != 'length' and
                                $attr/@key != 'continued'
                            ) 
                            return
                                <string key="{string($attr/@key)}">{data($attr/@value)}</string>
                        }     
                        </map>                                       
                    </map>
            }
            </array>,
            <array key="lines">
            {
                for $line in $lineData//*:line
                    let $prevLength := 
                        sum(
                            for $length in $line/preceding::*:length return number($length)
                        )
                return
                <map>                                            
                    <string key="id">{string($line/@id)}</string>
                    <string key="textRegionId">{string($line/*:textRegionId)}</string>
                    <string key="offset">{$prevLength}</string>
                    <string key="length">{string($line/*:length)}</string>
                </map>
            }
            </array>,
            <array key="regions">
            {
                for $textRegion in $textRegions return
                <map>                                            
                    <string key="id">{string($textRegion/@id)}</string>
                    <string key="page">{trapi:getPageRange($textRegion)}</string>
                </map>
            }
            </array>
        )
             
         return
            try {     
                $result
            } catch * {
                'trapi:_getTextData: Sonstiger Fehler (' || $err:code || '): ' || $err:description
            }
    };

    declare function trapi:getDocumentsJSON($db as xs:string?)
    {
        let $result := 
            <array xmlns="http://www.w3.org/2005/xpath-functions"> 
                { for $doc in trapi:getDocuments($db) return
                    <map>
                        <string key="id">{ string($doc//*:docId) }</string>    
                        <string key="title">{ string($doc//*:title) }</string>    
                        <string key="uploader">{ string($doc//*:uploader) }</string>   
                        <string key="pages">{ string(count($doc//*:file)) }</string>                                     
                    </map>
                }
            </array>
        return
            try {     
                xml-to-json($result)
            } catch * {
                'trapi:getDocumentsJSON: Sonstiger Fehler (' || $err:code || '): ' || $err:description
            }
    };

    declare function trapi:getDocumentJSON($db as xs:string?, $docId as xs:string?)
    {
        let $result := 
            <array xmlns="http://www.w3.org/2005/xpath-functions"> 
                { 
                    let $doc := trapi:getDocument($db, $docId)
                    return
                    <map>
                        <string key="id">{ string($doc//*:docId) }</string>    
                        <string key="title">{ string($doc//*:title) }</string>    
                        <string key="uploader">{ string($doc//*:uploader) }</string>   
                        <string key="pages">{ string(count($doc//*:file)) }</string>                                     
                    </map>
                }
            </array>
        return
            try {     
                xml-to-json($result)
            } catch * {
                'trapi:getDocumentsJSON: Sonstiger Fehler (' || $err:code || '): ' || $err:description
            }
    };


    declare function trapi:getTextsJSON(
        $db as xs:string?, 
        $docId as xs:string?, 
        $startRegionType as xs:string?, 
        $followingRegionType as xs:string?, 
        $chapterRegionType as xs:string?
    )
    {
        let $pages := trapi:getPages($db, $docId)
        let $result := 
            <array xmlns="http://www.w3.org/2005/xpath-functions"> 
                {   for $startRegion in trapi:getRegions($pages, $startRegionType)                 
                    return
                        <map xmlns="http://www.w3.org/2005/xpath-functions">
                            {trapi:_getTextMetadata($pages, $startRegion, $followingRegionType, $chapterRegionType)}
                        </map>
                }
            </array>
        return        
            try {     
                xml-to-json($result)
            } catch * {
                'trapi:getTextsJSON: Sonstiger Fehler (' || $err:code || '): ' || $err:description
            }
    };

    declare function trapi:getTextJSON(
        $db as xs:string?, 
        $docId as xs:string?, 
        $startRegionId as xs:string?, 
        $followingRegionType as xs:string?, 
        $chapterRegionType as xs:string?
    )
    {
        let $pages := trapi:getPages($db, $docId)
        let $startRegion := ($pages//*:TextRegion[@id=$startRegionId])[1]
        let $result := 
            <array xmlns="http://www.w3.org/2005/xpath-functions"> 
                <map xmlns="http://www.w3.org/2005/xpath-functions">
                    {trapi:_getTextMetadata($pages, $startRegion, $followingRegionType, $chapterRegionType)}
                    {trapi:_getTextData($pages, $startRegion, $followingRegionType, $chapterRegionType)}
                </map>
            </array>
        return   
            try {     
                xml-to-json($result)
            } catch * {
                'trapi:getTextJSON: Sonstiger Fehler (' || $err:code || '): ' || $err:description
            }
    };