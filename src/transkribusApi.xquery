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

        (:~
        : Returns a single mets:mets document selected by docId.
        :
        : @param $document      document.
        : @return               xs:string.
        :)
        declare function trapi:getDocumentId($document as element()) as xs:string
        {            
            string(($document//*:docId)[1])
        };
        
        
        (:~
        : Returns unique annotated transcribus structure types
        : @param $db        database name.
        : @param $docId     document id. 
        : @return           xs:string*
        :)  
        declare function trapi:getRegionTypes($db as xs:string?, $docId as xs:string?) as xs:string*
        {
            let $pages := trapi:getPages($db, $docId)
            let $result :=
                for $textregion in trapi:getRegions($pages)
                return trapi:getRegionType($textregion)
            return distinct-values($result)
        };        
        
        (:~
        : Returns unique annotated transcribus textual annotation tags
        : @param $db        database name.
        : @param $docId     document id. 
        : @return           xs:string*
        :)  
        declare function trapi:getTextualAnnotationTags($db as xs:string?, $docId as xs:string?) as xs:string*
        {
            let $pages := trapi:getPages($db, $docId)
            let $result :=
                for $textline in trapi:getLines($pages)
                return trapi:parseTranskribusCustomAttribute($textline/@custom)
            return distinct-values($result//*:annotation/@tag)
        };
        
        (:~
        : Returns unique annotated properties of selected transcribus textual annotation tag 
        : @param $db        database name.
        : @param $docId     document id. 
        : @param $tag       Transkribus textual annotation tag. 
        : @return           element()
        :)  
        declare function trapi:getTextualAnnotationTags($db as xs:string?, $docId as xs:string?, $tag as xs:string) as xs:string*
        {
            let $pages := trapi:getPages($db, $docId)
            let $result :=
                for $textline in trapi:getLines($pages)
                return trapi:parseTranskribusCustomAttribute($textline/@custom)            
            return distinct-values($result//*:annotation[@tag=$tag]/*:attr/@key)            
        };
        
        (:~
        : Returns unique values of annotated property of selected transcribus textual annotation tag 
        : @param $db        database name.
        : @param $docId     document id. 
        : @param $tag       Transkribus textual annotation tag. 
        : @param $property  Transkribus textual annotation tag property. 
        : @return           element()
        :)  
        declare function trapi:getTextualAnnotationTagProperties($db as xs:string?, $docId as xs:string?, $tag as xs:string, $property as xs:string) as xs:string*
        {
            let $pages := trapi:getPages($db, $docId)
            let $result :=
                for $textline in trapi:getLines($pages)
                return trapi:parseTranskribusCustomAttribute($textline/@custom)            
            return distinct-values($result//*:annotation[@tag=$tag]/*:attr[@key=$property]/@value)            
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
            let $pageNumber := xs:int($page//*:TranskribusMetadata/@pageNr)
            order by $pageNumber
            return $page
        };

        (:~
        : Returns the ancestor page:PcGts element of a selected by element.
        :
        : @param $element   xml element.        
        : @return element().
        :)
        declare function trapi:getCurrentPage($element as element()) as element()
        {
            ($element/ancestor-or-self::*:PcGts)[1]        
        };
        
        (:~
        : Returns the pagenumber of the selected element.
        :
        : @param $element   textregion element.        
        : @return           xs:string.
        :)
        declare function trapi:getPageNumber($element as element()) as xs:string
        {
            trapi:getCurrentPage($element)//*:TranskribusMetadata/@pageNr          
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
                return string(trapi:getCurrentPage($textRegion)//*:TranskribusMetadata/@pageNr)
            return string-join(distinct-values($TranskribusMetadatas), ', ')
        };    

    (: TextRegions :)
        
        (:~
        : Returns the selected textregion of selected pages.
        :
        : @param $pages   pagexml pages.        
        : @param $regionId   xs:string.     
        : @return element().
        :)
        declare function trapi:getRegion($pages as element()*, $regionId as xs:string) as element()
        {
            ($pages//*:TextRegion[@id=$regionId])[1]
        };

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
        declare function trapi:getRegionType($region as element()) as xs:string?
        {    
            let $annotations := trapi:parseTranskribusCustomAttribute($region/@custom)
            return                 
                ($annotations//*:annotation[@tag='structure']/*:attr[@key='type'])[1]/@value
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
            let $currentPage := trapi:getCurrentPage($startRegion)
            let $followingRegionsCurrentPage := $startRegion/following::*:TextRegion
            let $i := index-of($pages, $currentPage) 
            let $followingRegionsOtherPages :=
                for $page in subsequence($pages, $i + 1, count($pages) - $i) (:count($pages) - $i:)
                return
                    $page//*:TextRegion
            return 
                if (count($followingRegionsOtherPages) > 0)
                then
                    $followingRegionsOtherPages (:($followingRegionsCurrentPage, $followingRegionsOtherPages):)
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
        : Returns all following regions of a specific type of a TextRegion 
        : until the start of the next text in a list of page elements
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
            let $currentPage := trapi:getCurrentPage($startRegion)
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
        : Returns all TextLine belonging to selected element
        :          
        : @param $element           Element. 
        : @return                   element()*
        :)  
        declare function trapi:getLines($elements as element()*) as element()*
        {
            for $element in $elements
            return $element//*:TextLine
        };
        
        (:~
        : Returns all TextLine belonging to selected TextRegion with a specific annotation tag
        :          
        : @param $textRegions           TextRegions.
        : @param $tag                   Annotation tag. 
        : @return                       element()*
        :)  
        declare function trapi:getLines(
        $textRegions as element()*,
        $tag as xs:string) as element()*
        {
            for $textLine in $textRegions/*:TextLine
            where contains(trapi:replaceTranskribusEscapedEntities($textLine/@custom),concat($tag," {"))
            return $textLine
        };
        
        (:~
        : Returns all TextLine belonging to selected TextRegion with a specific annotation tag and attribute key
        :          
        : @param $textRegions           TextRegions.
        : @param $tag                   Annotation tag. 
        : @param $key                   Attribute key. 
        : @return                       element()*
        :)  
        declare function trapi:getLines(
        $textRegions as element()*,
        $tag as xs:string,
        $key as xs:string) as element()*
        {
            for $textLine in trapi:getLines($textRegions,$tag)
            where trapi:parseTranskribusCustomAttribute($textLine/@custom)//*:attr[@key=$key]
            return $textLine
        };
        
        (:~
        : Returns all TextLine belonging to selected TextRegion with a specific annotation tag and attribute key/value
        :          
        : @param $textRegions           TextRegions.
        : @param $tag                   Annotation tag. 
        : @param $key                   Attribute key. 
        : @param $key                   Attribute value. 
        : @return                       element()*
        :)  
        declare function trapi:getLines(
        $textRegions as element()*,
        $tag as xs:string,
        $key as xs:string, 
        $value as xs:string) as element()*
        {
            for $textLine in trapi:getLines($textRegions,$tag)
            where trapi:parseTranskribusCustomAttribute($textLine/@custom)//*:attr[@key=$key][@value=$value]
            return $textLine
        };
        
        
        (:~
        : Returns all annotations on lines of selected textregions
        :          
        : @param $textRegions           TextRegions.
        : @return                       element()*
        :)  
        declare function trapi:getLinesAnnotations($textRegions as element()*) as element()*
        {
            (:($i, $lines, $result, $parsedAnnotations, $lengthOfPrevLines):)
            trapi:getLineAnnotations(1, trapi:getLines($textRegions), (), (), 0)
        };
        
        (:~
        : Returns all annotations on selcted line of selected textregions
        :          
        : @param $i                     Position of current line.
        : @param $lines                 all lines.
        : @return                       element()*
        :)  
        declare function trapi:getLineAnnotations(
            $i as xs:integer,
            $lines as element()*, 
            $result as element()*, 
            $parsedAnnotations as element()*, 
            $lengthOfPrevLines as xs:integer
        ) as element()*
        {
            if ($i < count($lines)) 
            then 
                (:
                <annotation tag="Wunder_Wallfahrt">
                    <attr key="offset" value="33"/>
                    <attr key="length" value="14"/>
                    <attr key="continued" value="true"/>
                </annotation>
                :)
                let $currentLineAnnotations := trapi:parseTranskribusCustomAttribute($lines[$i]/@custom)//*:annotation
                let $newAnnotations := 
                    for $annotation in $currentLineAnnotations
                    let $currentAnnotation := 
                        <annotation tag="{$annotation/@tag}">
                            <attr key="offset" value="{xs:int($annotation/*:attr[@key="offset"]/@value) + $lengthOfPrevLines}"/>
                            {
                                for $attr in $annotation/*:attr
                                where ($attr/@key != 'offset')
                                return $attr
                            }
                        </annotation>
                    let $tag    := $annotation/@tag
                    let $offset := $annotation/*:attr[@key='offset']/@value
                    let $length := $annotation/*:attr[@key='length']/@value
                    where (
                        $annotation/*:attr[@key='offset'] and
                        (: ~~ if $annotation not in $parsedAnnotations ~~ :)
                        (:not(exists($parsedAnnotations intersect $annotation)):)
                        not(
                            exists(
                                $parsedAnnotations
                                    [@tag=$tag]
                                    [./*:attr[@key='offset'][@value=$offset]]
                                    [./*:attr[@key='length'][@value=$length]]
                            )
                        )
                    )
                    
                    return
                        if ($annotation/*:attr[@key='continued']) then
                        (: process annotations spanning multiple lines :)                        
                        trapi:getContinuedAnnotations(
                            $i + 1,
                            $lines,                             
                            $parsedAnnotations, 
                            $currentAnnotation, 
                            $annotation
                        )                        
                        else
                        $currentAnnotation
                let $lengthOfLine := string-length(trapi:getLineUnicode($lines[$i]))
                
                let $newResult := 
                    for $annotation in $newAnnotations
                    where (not($annotation/*:attr[@key='continued']))
                    return $annotation                
                let $result := ($result, $newResult)
                
                let $continuedAnnotations := 
                    for $annotation in $newAnnotations
                    where ($annotation/*:attr[@key='continued'])
                    return $annotation
                let $parsedAnnotations := ($parsedAnnotations, $currentLineAnnotations, $continuedAnnotations)
                
                return                
                trapi:getLineAnnotations(
                    $i + 1, 
                    $lines, 
                    $result, 
                    $parsedAnnotations, 
                    $lengthOfPrevLines + $lengthOfLine
                )
            else $result
        };
        
        (:~
        : Returns a merged annotation element of all parts of a continued annotation
        : Helper function for trapi:getLineAnnotations
        :          
        : @param $i                     Position of current line.
        : @param $lines                 all lines.
        : @param $parsedAnnotations     already processed annotations.
        : @param $currentAnnotation     current annotation object.
        : @param $continuedAnnotations  all processed continued annotations.
        : @return                       element()*
        :)  
        declare function trapi:getContinuedAnnotations(
            $i as xs:integer, 
            $lines as element()*,
            $parsedAnnotations as element()*, 
            $currentAnnotation as element(), 
            $continuedAnnotations as element()*
        ) as element()*
        {
            
            let $curTag := $currentAnnotation/@tag                 
            let $curOffset := $currentAnnotation/*:attr[@key='offset']/@value
            let $curLength := $currentAnnotation/*:attr[@key='length']/@value
            let $annotations := trapi:parseTranskribusCustomAttribute($lines[$i]/@custom)
            let $continuedAnnotation := (
                    $annotations/*:annotation
                        [@tag=$curTag]
                        [./*:attr[@key='continued']]
                        [./*:attr[@key="offset" and @value="0"]]
                )[1] 
            
            return             
                if (
                    exists($continuedAnnotation) and
                    (:not(exists($parsedAnnotations intersect $continuedAnnotation)) and:)
                    $i < count($lines) and                    
                    not(
                        exists(
                            $continuedAnnotation
                                [@tag=$curTag]
                                [./*:attr[@key='offset'][@value=$curOffset]]
                                [./*:attr[@key='length'][@value=$curLength]]
                        )
                    )
                )
                then 
                    let $currentAnnotation := 
                        <annotation tag="{$curTag}">
                            <attr key="iterationCurrentAnnotation" value="debug"/>
                            <attr key="offset" value="{$currentAnnotation/*:attr[@key="offset"]/@value}"/>
                            <attr 
                                key="length" 
                                value="{
                                    xs:int(string($currentAnnotation/*:attr[@key="length"]/@value)) +
                                    xs:int(string($continuedAnnotation/*:attr[@key="length"]/@value))
                                }"
                            />
                            {
                                for $attr in $currentAnnotation/*:attr
                                where (
                                    $attr/@key != 'offset' and 
                                    $attr/@key != 'length' and 
                                    $attr/@key != 'continued'
                                )
                                return $attr
                            }
                        </annotation>
                        
                    return
                    trapi:getContinuedAnnotations(
                        $i + 1,
                        $lines,                        
                        ($parsedAnnotations, $continuedAnnotation),
                        $currentAnnotation,
                        ($continuedAnnotations, $continuedAnnotation)
                    ) 
                else ($continuedAnnotations, $currentAnnotation)
        };
        
        
        (:~
        : Returns a normalized string of the selected line
        :          
        : @param $line                  line.
        : @return                       xs:string
        :)  
        declare function trapi:getLineUnicode($line) as xs:string
        {
            let $norm := normalize-space(string($line//*:Unicode[1]))
            let $break := ends-with($norm,'¬')
            let $unicode := 
                if (ends-with($norm,'¬'))
                then replace($norm, '¬', '')
                else concat($norm,' ')
            return $unicode
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
        ends-with(trapi:replaceTranskribusEscapedEntities($region/@custom), concat('{type:', $regionType,';}'))
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
        let $custom := trapi:replaceTranskribusEscapedEntities($custom)
        return
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
    
(: support functions :)
    (:~
    : Replace unicode number references '\u0020' in Transkribus data
    :          
    : @param $string
    : @return $string
    :) 
    declare function trapi:replaceTranskribusEscapedEntities($string as xs:string?) as xs:string 
    {   
        let $matches := analyze-string($string, "\\u(\w{4})")//fn:match 
        return if (exists($matches)) 
        then
            let $cp := string($matches[1]//*:group[1])
            return trapi:replaceTranskribusEscapedEntities(
                    replace(
                        $string,
                        concat('\\u',$cp),                        
                        codepoints-to-string(xs:int(convert:integer-from-base($cp,16))))
                   )
        else
        $string
    };    

(: json functions:)

    (:~
    : Helper Function for JSON-Export. Gets metadata of a text.
    :          
    : @param $pages                 Page elements.        
    : @param $startRegion           TextRegion. 
    : @param $followingRegionType   Transkribus structure type.
    : @param $chapterRegionType   Transkribus structure type.
    : @return element()*
    :)  
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

    (:~
    : Helper Function for JSON-Export. Gets content of a text.
    :          
    : @param $pages                 Page elements.        
    : @param $startRegion           TextRegion. 
    : @param $followingRegionType   Transkribus structure type.
    : @param $chapterRegionType     Transkribus structure type.
    : @return element()*
    :)  
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
                let $unicode := trapi:getLineUnicode($line)                 
                return
                    <line id='{$line/@id}'>
                        <textRegionId>{$regionId}</textRegionId>
                        <unicode>{$unicode}</unicode>                        
                        <length>{string-length($unicode)}</length>
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
                let $annotations := trapi:getLinesAnnotations($textRegions)                
                return
                    for $annotation in $annotations
                    where $annotation/*:attr[@key='offset']
                    let $offset := string($annotation/*:attr[@key='offset']/@value)
                    let $length := string($annotation/*:attr[@key='length']/@value)
                    let $tag := string($annotation/@tag)
                    return
                    <map>                        
                        <string key="offset">{$offset}</string>
                        <string key="length">{$length}</string>
                        <string key="tag">{$tag}</string>
                        <map key="attributes">  
                        {
                            for $attr in $annotation/*:attr
                            where (
                                $attr/@key != 'offset' and
                                $attr/@key != 'length'
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

    (:~
    : Returns a list of the documents in a database as JSON
    :          
    : @param $db                    Name of database.        
    : @return JSON
    :)
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

    (:~
    : Returns the selected document in a database as JSON
    :          
    : @param $db                    Name of database.      
    : @param $docId                 ID of the document. 
    : @return JSON
    :)
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

    (:~
    : Returns a list of texts in a document, specified by structural annotations in Transkribus.
    :          
    : @param $db                    Name of database.      
    : @param $docId                 ID of the document.
    : @param $startRegionType       TextRegion type, start of a text.
    : @param $followingRegionType   TextRegion type, following regions of a text.
    : @param $chapterRegionType     TextRegion type, optional heading of a text.
    : @return JSON
    :)
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
                    let $pageRange := number(trapi:getPageRange($startRegion))
                    order by $pageRange
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

    (:~
    : Returns a text in a document, specified by structural annotations in Transkribus.
    :          
    : @param $db                    Name of database.      
    : @param $docId                 ID of the document.
    : @param $startRegionId         ID of the start region of the text.
    : @param $followingRegionType   TextRegion type, following regions of a text.
    : @param $chapterRegionType     TextRegion type, optional heading of a text.
    : @return JSON
    :)
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