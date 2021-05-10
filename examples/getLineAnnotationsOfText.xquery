import module namespace trapi="http://transkribusapi.mhdbdb.sbg.ac.at";

let $pages := trapi:getPages('wunderzeichen', '659824')
let $textRegions := trapi:getTextRegions(
						$pages,
                        trapi:getRegion($pages,'region_1616072000485_306'),
                        'Wunder_Fortsetzung-Wunderbericht'
                     )
return trapi:getLinesAnnotations($textRegions)