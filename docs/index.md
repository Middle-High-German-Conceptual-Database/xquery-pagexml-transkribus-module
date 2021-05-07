# library module: http://transkribusapi.mhdbdb.sbg.ac.at


## Table of Contents

* Functions: [trapi:getDocuments\#1](#func_trapi_getDocuments_1), [trapi:getDocument\#2](#func_trapi_getDocument_2), [trapi:getDocumentId\#1](#func_trapi_getDocumentId_1), [trapi:getRegionTypes\#2](#func_trapi_getRegionTypes_2), [trapi:getTextualAnnotationTags\#2](#func_trapi_getTextualAnnotationTags_2), [trapi:getTextualAnnotationTagProperties\#3](#func_trapi_getTextualAnnotationTagProperties_3), [trapi:getTextualAnnotationTagPropertyValues\#4](#func_trapi_getTextualAnnotationTagPropertyValues_4), [trapi:getPages\#2](#func_trapi_getPages_2), [trapi:getCurrentPage\#1](#func_trapi_getCurrentPage_1), [trapi:getPageNumber\#1](#func_trapi_getPageNumber_1), [trapi:getPageRange\#1](#func_trapi_getPageRange_1), [trapi:getRegion\#2](#func_trapi_getRegion_2), [trapi:getRegions\#1](#func_trapi_getRegions_1), [trapi:getRegions\#2](#func_trapi_getRegions_2), [trapi:getRegionType\#1](#func_trapi_getRegionType_1), [trapi:getFollowingRegions\#2](#func_trapi_getFollowingRegions_2), [trapi:getFollowingRegions\#3](#func_trapi_getFollowingRegions_3), [trapi:getFollowingTextRegions\#3](#func_trapi_getFollowingTextRegions_3), [trapi:getPrecedingRegions\#2](#func_trapi_getPrecedingRegions_2), [trapi:getPrecedingRegions\#3](#func_trapi_getPrecedingRegions_3), [trapi:getchapterHeading\#3](#func_trapi_getchapterHeading_3), [trapi:getTextRegions\#3](#func_trapi_getTextRegions_3), [trapi:getLines\#1](#func_trapi_getLines_1), [trapi:getLines\#2](#func_trapi_getLines_2), [trapi:getLines\#3](#func_trapi_getLines_3), [trapi:getLines\#4](#func_trapi_getLines_4), [trapi:hasRegionType\#2](#func_trapi_hasRegionType_2), [trapi:parseTranskribusCustomAttribute\#1](#func_trapi_parseTranskribusCustomAttribute_1), [trapi:replaceTranskribusEscapedEntities\#1](#func_trapi_replaceTranskribusEscapedEntities_1), [trapi:_getTextMetadata\#4](#func_trapi__getTextMetadata_4), [trapi:_getTextData\#4](#func_trapi__getTextData_4), [trapi:getDocumentsJSON\#1](#func_trapi_getDocumentsJSON_1), [trapi:getDocumentJSON\#2](#func_trapi_getDocumentJSON_2), [trapi:getTextsJSON\#5](#func_trapi_getTextsJSON_5), [trapi:getTextJSON\#5](#func_trapi_getTextJSON_5)


## Functions

### <a name="func_trapi_getDocuments_1"/> trapi:getDocuments\#1
```xquery
trapi:getDocuments($db as xs:string?
) as element()*
```

#### Params

* $db as xs:string?


#### Returns
* element()\*

### <a name="func_trapi_getDocument_2"/> trapi:getDocument\#2
```xquery
trapi:getDocument($db as xs:string?, $docId as xs:string?
) as element()
```

#### Params

* $db as xs:string?

* $docId as xs:string?


#### Returns
* element()

### <a name="func_trapi_getDocumentId_1"/> trapi:getDocumentId\#1
```xquery
trapi:getDocumentId($document as element()
) as xs:string
```

#### Params

* $document as element()


#### Returns
* xs:string

### <a name="func_trapi_getRegionTypes_2"/> trapi:getRegionTypes\#2
```xquery
trapi:getRegionTypes($db as xs:string?, $docId as xs:string?
) as xs:string*
```

#### Params

* $db as xs:string?

* $docId as xs:string?


#### Returns
* xs:string\*

### <a name="func_trapi_getTextualAnnotationTags_2"/> trapi:getTextualAnnotationTags\#2
```xquery
trapi:getTextualAnnotationTags($db as xs:string?, $docId as xs:string?
) as xs:string*
```

#### Params

* $db as xs:string?

* $docId as xs:string?


#### Returns
* xs:string\*

### <a name="func_trapi_getTextualAnnotationTagProperties_3"/> trapi:getTextualAnnotationTagProperties\#3
```xquery
trapi:getTextualAnnotationTagProperties($db as xs:string?, $docId as xs:string?, $tag as xs:string
) as xs:string*
```

#### Params

* $db as xs:string?

* $docId as xs:string?

* $tag as xs:string


#### Returns
* xs:string\*

### <a name="func_trapi_getTextualAnnotationTagPropertyValues_4"/> trapi:getTextualAnnotationTagPropertyValues\#4
```xquery
trapi:getTextualAnnotationTagPropertyValues($db as xs:string?, $docId as xs:string?, $tag as xs:string, $property as xs:string
) as xs:string*
```

#### Params

* $db as xs:string?

* $docId as xs:string?

* $tag as xs:string

* $property as xs:string


#### Returns
* xs:string\*

### <a name="func_trapi_getPages_2"/> trapi:getPages\#2
```xquery
trapi:getPages($db as xs:string?, $docId as xs:string?
) as element()*
```

#### Params

* $db as xs:string?

* $docId as xs:string?


#### Returns
* element()\*

### <a name="func_trapi_getCurrentPage_1"/> trapi:getCurrentPage\#1
```xquery
trapi:getCurrentPage($element as element()
) as element()
```

#### Params

* $element as element()


#### Returns
* element()

### <a name="func_trapi_getPageNumber_1"/> trapi:getPageNumber\#1
```xquery
trapi:getPageNumber($element as element()
) as xs:string
```

#### Params

* $element as element()


#### Returns
* xs:string

### <a name="func_trapi_getPageRange_1"/> trapi:getPageRange\#1
```xquery
trapi:getPageRange($textRegions as element()*
) as xs:string
```

#### Params

* $textRegions as element()\*


#### Returns
* xs:string

### <a name="func_trapi_getRegion_2"/> trapi:getRegion\#2
```xquery
trapi:getRegion($pages as element()*, $regionId as xs:string
) as element()
```

#### Params

* $pages as element()\*

* $regionId as xs:string


#### Returns
* element()

### <a name="func_trapi_getRegions_1"/> trapi:getRegions\#1
```xquery
trapi:getRegions($pages as element()*
) as element()*
```

#### Params

* $pages as element()\*


#### Returns
* element()\*

### <a name="func_trapi_getRegions_2"/> trapi:getRegions\#2
```xquery
trapi:getRegions($pages as element()*, $regionType as xs:string?
) as element()*
```

#### Params

* $pages as element()\*

* $regionType as xs:string?


#### Returns
* element()\*

### <a name="func_trapi_getRegionType_1"/> trapi:getRegionType\#1
```xquery
trapi:getRegionType($region as element()
) as xs:string?
```

#### Params

* $region as element()


#### Returns
* xs:string?

### <a name="func_trapi_getFollowingRegions_2"/> trapi:getFollowingRegions\#2
```xquery
trapi:getFollowingRegions($pages as element()*, $startRegion as element()
) as element()*
```

#### Params

* $pages as element()\*

* $startRegion as element()


#### Returns
* element()\*

### <a name="func_trapi_getFollowingRegions_3"/> trapi:getFollowingRegions\#3
```xquery
trapi:getFollowingRegions($pages as element()*, $startRegion as element(), $followingRegionType as xs:string?
) as element()*
```

#### Params

* $pages as element()\*

* $startRegion as element()

* $followingRegionType as xs:string?


#### Returns
* element()\*

### <a name="func_trapi_getFollowingTextRegions_3"/> trapi:getFollowingTextRegions\#3
```xquery
trapi:getFollowingTextRegions($pages as element()*, 
            $startRegion as element(),
            $followingRegionType as xs:string?
) as element()*
```

#### Params

* $pages as element()\*

* $startRegion as element()

* $followingRegionType as xs:string?


#### Returns
* element()\*

### <a name="func_trapi_getPrecedingRegions_2"/> trapi:getPrecedingRegions\#2
```xquery
trapi:getPrecedingRegions($pages as element()*, $startRegion as element()
) as element()*
```

#### Params

* $pages as element()\*

* $startRegion as element()


#### Returns
* element()\*

### <a name="func_trapi_getPrecedingRegions_3"/> trapi:getPrecedingRegions\#3
```xquery
trapi:getPrecedingRegions($pages as element()*, $startRegion as element(), $precedingRegionType as xs:string?
) as element()*
```

#### Params

* $pages as element()\*

* $startRegion as element()

* $precedingRegionType as xs:string?


#### Returns
* element()\*

### <a name="func_trapi_getchapterHeading_3"/> trapi:getchapterHeading\#3
```xquery
trapi:getchapterHeading($pages as element()*, $startRegion as element(), $chapterRegionType as xs:string
) as xs:string
```

#### Params

* $pages as element()\*

* $startRegion as element()

* $chapterRegionType as xs:string


#### Returns
* xs:string

### <a name="func_trapi_getTextRegions_3"/> trapi:getTextRegions\#3
```xquery
trapi:getTextRegions($pages as element()*, 
            $startRegion as element(), 
            $followingRegionType as xs:string?
) as element()*
```

#### Params

* $pages as element()\*

* $startRegion as element()

* $followingRegionType as xs:string?


#### Returns
* element()\*

### <a name="func_trapi_getLines_1"/> trapi:getLines\#1
```xquery
trapi:getLines($elements as element()*
) as element()*
```

#### Params

* $elements as element()\*


#### Returns
* element()\*

### <a name="func_trapi_getLines_2"/> trapi:getLines\#2
```xquery
trapi:getLines($textRegions as element()*,
        $tag as xs:string
) as element()*
```

#### Params

* $textRegions as element()\*

* $tag as xs:string


#### Returns
* element()\*

### <a name="func_trapi_getLines_3"/> trapi:getLines\#3
```xquery
trapi:getLines($textRegions as element()*,
        $tag as xs:string,
        $key as xs:string
) as element()*
```

#### Params

* $textRegions as element()\*

* $tag as xs:string

* $key as xs:string


#### Returns
* element()\*

### <a name="func_trapi_getLines_4"/> trapi:getLines\#4
```xquery
trapi:getLines($textRegions as element()*,
        $tag as xs:string,
        $key as xs:string, 
        $value as xs:string
) as element()*
```

#### Params

* $textRegions as element()\*

* $tag as xs:string

* $key as xs:string

* $value as xs:string


#### Returns
* element()\*

### <a name="func_trapi_hasRegionType_2"/> trapi:hasRegionType\#2
```xquery
trapi:hasRegionType($region as element(), $regionType as xs:string
) as xs:boolean
```

#### Params

* $region as element()

* $regionType as xs:string


#### Returns
* xs:boolean

### <a name="func_trapi_parseTranskribusCustomAttribute_1"/> trapi:parseTranskribusCustomAttribute\#1
```xquery
trapi:parseTranskribusCustomAttribute($custom as xs:string?
) as element()
```

#### Params

* $custom as xs:string?


#### Returns
* element()

### <a name="func_trapi_replaceTranskribusEscapedEntities_1"/> trapi:replaceTranskribusEscapedEntities\#1
```xquery
trapi:replaceTranskribusEscapedEntities($string as xs:string?
) as xs:string
```

#### Params

* $string as xs:string?


#### Returns
* xs:string

### <a name="func_trapi__getTextMetadata_4"/> trapi:_getTextMetadata\#4
```xquery
trapi:_getTextMetadata($pages as element()*, 
        $startRegion as element()?, 
        $followingRegionType as xs:string?, 
        $chapterRegionType as xs:string?
) as element()*
```

#### Params

* $pages as element()\*

* $startRegion as element()?

* $followingRegionType as xs:string?

* $chapterRegionType as xs:string?


#### Returns
* element()\*

### <a name="func_trapi__getTextData_4"/> trapi:_getTextData\#4
```xquery
trapi:_getTextData($pages as element()*, 
        $startRegion as element()?, 
        $followingRegionType as xs:string?, 
        $chapterRegionType as xs:string?
) as element()*
```

#### Params

* $pages as element()\*

* $startRegion as element()?

* $followingRegionType as xs:string?

* $chapterRegionType as xs:string?


#### Returns
* element()\*

### <a name="func_trapi_getDocumentsJSON_1"/> trapi:getDocumentsJSON\#1
```xquery
trapi:getDocumentsJSON($db as xs:string?
) as xs:string
```

#### Params

* $db as xs:string?


#### Returns
* xs:string

### <a name="func_trapi_getDocumentJSON_2"/> trapi:getDocumentJSON\#2
```xquery
trapi:getDocumentJSON($db as xs:string?, $docId as xs:string?
) as xs:string
```

#### Params

* $db as xs:string?

* $docId as xs:string?


#### Returns
* xs:string

### <a name="func_trapi_getTextsJSON_5"/> trapi:getTextsJSON\#5
```xquery
trapi:getTextsJSON($db as xs:string?, 
        $docId as xs:string?, 
        $startRegionType as xs:string?, 
        $followingRegionType as xs:string?, 
        $chapterRegionType as xs:string?
) as xs:string
```

#### Params

* $db as xs:string?

* $docId as xs:string?

* $startRegionType as xs:string?

* $followingRegionType as xs:string?

* $chapterRegionType as xs:string?


#### Returns
* xs:string

### <a name="func_trapi_getTextJSON_5"/> trapi:getTextJSON\#5
```xquery
trapi:getTextJSON($db as xs:string?, 
        $docId as xs:string?, 
        $startRegionId as xs:string?, 
        $followingRegionType as xs:string?, 
        $chapterRegionType as xs:string?
) as xs:string
```

#### Params

* $db as xs:string?

* $docId as xs:string?

* $startRegionId as xs:string?

* $followingRegionType as xs:string?

* $chapterRegionType as xs:string?


#### Returns
* xs:string





*Generated by [xquerydoc](https://github.com/xquery/xquerydoc)*
