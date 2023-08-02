/**
 *  Controller for the PageList - Testing page that shows a list of links for each of the different record types
 *  <p>The purpose of this page is to show a list of all the pages and how they are different for the different record types</p>
 *
 *  <p>THIS CLASS IS FOR TESTING/DEMONSTRATION PURPOSES ONLY AND MUST NOT BE IN PRODUCTION</p>
 **/
public with sharing class gFRS_PageListController {
    
    /** Testing TaxId to use for demonstration purposes **/
    public static final String TEST_TAX_ID = '98-7654321';
    
    /** Example Organization **/
    public GFRS_Organization__c testOrganization { get; set; }
    
    /** Example Location **/
    public GFRS_Location__c testLocation { get; set; }
    
    /** List of funding requests that are of a new status **/
    //public GFRS_Funding_Request__c[] newRequests { get; set; }
    
    /** List of funding requests by record type, status and sub status **/
    public GFRS_Funding_Request__c[] allRequests { get; set; }
    
    /** Lists of funding requests that are in processing and disposition and awaiting LOA **/
    
    
    public gFRS_PageListController(){
        Map<String,GFRS_Funding_Request__c> requestTypes = new Map<String,GFRS_Funding_Request__c>();
        
        //this.newRequests = getUniqueRecordTypes();
        
        this.allRequests = getUniqueRecordTypeAndStatus();
        
        GFRS_Location__c[] locations = [ select id, Organization__r.Name
            from GFRS_Location__c
            where Organization__r.Tax_Id__c = :TEST_TAX_ID
        ];
        if( locations != null && locations.size() > 0 ){
            this.testLocation = locations[0];
            this.testOrganization = this.testLocation.Organization__r;
        }
    }
    
    /**
     *  Returns a list of Funding Requests unique by RecordType.
     *  @return GFRS_Funding_Request__c[] - list of requests paired down to only unique funding request record types.
     **/
    /*
    public static GFRS_Funding_Request__c[] getUniqueRecordTypes(){
        Map<String,GFRS_Funding_Request__c> requestTypes = new Map<String,GFRS_Funding_Request__c>();
        
        for( GFRS_Funding_Request__c request : [ select id, Record_Type_Name__c from GFRS_Funding_Request__c order by Record_Type_Name__c ]){
            if( !requestTypes.containsKey( request.Record_Type_Name__c ) ){
                requestTypes.put( request.Record_Type_Name__c, request );
            }
        }
        
        return( requestTypes.values() );
    }
    */
    
    /**
     *  Returns a list of Funding Requests that are unique by record type, status and sub status.
     *  @return GFRS_Funding_Request__c[] - list of requests paired down to only unique ones by the record type, status and sub status
     **/
    public static GFRS_Funding_Request__c[] getUniqueRecordTypeAndStatus(){
        Map<String, GFRS_Funding_Request__c> uniqueMap= new Map<String, GFRS_Funding_Request__c>();
        
        String key = null;
        for( GFRS_Funding_Request__c request : [ select id, Event_Program_Title__c, Record_Type_Name__c, Status__c, Sub_Status__c, Information_Needed__c
            from GFRS_Funding_Request__c
            order by Record_Type_Name__c, Status__c, Sub_Status__c, CreatedDate desc
        ]){
            key = request.Record_Type_Name__c + ';' + request.Status__c + ';' + request.Sub_Status__c;
            
            if( !uniqueMap.containsKey( key ) ){
                uniqueMap.put( key, request );
            }
        }
        
        GFRS_Funding_Request__c[] results = new GFRS_Funding_Request__c[]{};
        
        //-- stop if no items were found
        if( !uniqueMap.isEmpty() ){
            //-- since we cannot sort the map, we must sort the keys
            String[] keys = new String[]{};
            keys.addAll( uniqueMap.keySet() );
            keys.sort();
            
            for( String key2 : keys ){
                results.add( uniqueMap.get( key2 ));
            }
        }
        
        return( results );
    }
    
    class LabelValueVO {
        public String label;
        public GFRS_Funding_Request__c value;
        
        public LabelValueVO( String label, GFRS_Funding_Request__c value ){
            this.label = label;
            this.value = value;
        }
    }
    
}