/**
 *  Utility class for managing content translations.
 **/
public with sharing class gFRS_ContentTranslationUtil {
    
    /**
     *  Determines the content translations given a content filter and content language.
     *  @param contentFilter (String) - one of the GFRS Content Filters to filter the results by
     *  @param lang (String) - the use language/locale
     *  @return Map<String,String> - Map of the translations by keys and texts.
     **/
    public static Map<String,String> fetchContentTranslationsByFilter( String contentFilter, String lang ){
        Map<String,String> results = new Map<String,String>();
        
        for( GFRS_Content_Translation__c translation : [ select GFRS_Content__r.Name, GFRS_Content__r.Filter__c, TextBlock__c, Language__c from GFRS_Content_Translation__c
            where Language__c = :lang and GFRS_Content__r.Filter__c = :contentFilter ]
        ){
            results.put( translation.GFRS_Content__r.Name, translation.TextBlock__c );
            //System.debug( 'putting [' + translation.GFRS_Content__r.Name + '] = ' + translation.TextBlock__c );
        }
        
        return( results );
    }
}