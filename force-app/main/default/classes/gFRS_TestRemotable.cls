/**
 *  Allowed functionality for JS remoting.
 *  
 *  <p>This must be made global and have fewer permissions, so added here for simplicity</p>
 **/
global class gFRS_TestRemotable {
    
    private GFRS_Funding_Request__c fundingRequest;
    
    public string specialtyOptions { get; set; }
    
    public String creditCategoryOptions { get; set; }
    
    public String intendedAudienceOptions { get; set; }
    
    public gFRS_TestRemotable( ApexPages.StandardController std ){
        //-- don't do anything yet
        this.fundingRequest = (GFRS_Funding_Request__c)std.getRecord();
        System.debug( 'fundingRequest:' + fundingRequest );
        
        this.specialtyOptions =  gFRS_Util.convertPicklistOptions( GFRS_Program_Audience_Group__c.Category_of_Credit__c.getDescribe().getpicklistValues() );
        //'Allergy,Anesthesia,Cardiovascular Disease,Dermatology,Emergency Medicine';
        this.creditCategoryOptions = gFRS_Util.convertPicklistOptions( GFRS_Program_Audience_Group__c.Specialty__c.getDescribe().getpicklistValues() );
        //'Credit A,Credit B';
        this.intendedAudienceOptions = gFRS_Util.convertPicklistOptions( GFRS_Program_Audience_Group__c.Intended_Audience__c.getDescribe().getpicklistValues() );
        //'Allied Health Professional,Case Manager,Employer,EMS Professional';
    }
    
    /**
     *  Simple remoting example that returns the translation string
     *  <p>Simply called by remoting: gFRS_TestRemotable.getTranslation1( function( result, event){ alert( result ) } );
     **/
    @RemoteAction
    global static String getTranslation1(){
        String lang = 'en_US';
        String contentFilter = '';
        String contentName = 'NonLegalAuthDisclaim';
        
        /*
        GFRS_Content_Translation__c translation = [ select GFRS_Content__r.Name, GFRS_Content__r.Filter__c, TextBlock__c, Language__c from GFRS_Content_Translation__c
            where Language__c = :lang and GFRS_Content__r.Filter__c = :contentFilter ];
        */
        GFRS_Content_Translation__c translation = [ select GFRS_Content__r.Name, GFRS_Content__r.Filter__c, TextBlock__c, Language__c
            from GFRS_Content_Translation__c
            where Language__c = :lang and GFRS_Content__r.Name = :contentName ];
        
        return( translation.TextBlock__c );
    }
    
    /**
     *  Remoting example that returns multiple translation records
     *  @return GFRS_Content_Translation__c[] - multiple translations
     **/
    @RemoteAction
    global static GFRS_Content_Translation__c[] getTranslations(){
        String lang = 'en_US';
        
        GFRS_Content_Translation__c[] translations = [ select GFRS_Content__r.Name, GFRS_Content__r.Filter__c, TextBlock__c, Language__c
            from GFRS_Content_Translation__c
            where Language__c = :lang ];
            
        return( translations );
    }
    
    /**
     *  Remoting method that returns all remoting attendees
     *  <p>TODO: change argument to accept the program Id to filter by</p>
     *  @return GFRS_Program_Audience_Group__c[] - list of audience members
     **/
    @RemoteAction
    global static GFRS_Program_Audience_Group__c[] fetchAttendees( String programId ){
        GFRS_Program_Audience_Group__c[] audience = [ select id, Name, Program__c, Actual_Learners__c, Actual_Learners_with_Credit__c, Actual_Number_Participants__c, Category_of_Credit__c, Credit_Hours__c, Expected_Learners_Credit__c, Expected_Learners__c, Intended_Audience__c, Invitations_Distributed__c, Number_of_Participants__c, Number_of_Speaking__c, Other__c, Specialty__c
            from GFRS_Program_Audience_Group__c
            where Program__c = :programId ];
        return( audience );
    }
    
    /**
     *  Remoting method that updates a single specific audience field.
     *  <p>Instead of updating all objects, this updates each field as the field is changed,
     *  to avoid requiring to hit save</p>
     *  @param stringId (String) - the string representation of the Audience id
     *  @param fieldName (String) - the name of the field to update on the audience
     *  @param value (Stirng) - the string representation of the value to update
     *  @return GFRS_Program_Audience_Group__c - the updated audience object or NULL if it could not be updated
     **/
    @RemoteAction
    global static GFRS_Program_Audience_Group__c updateAudienceField( String stringId, String fieldName, String value ){
        Id newId = Id.valueOf( stringId );
        GFRS_Program_Audience_Group__c obj = [ select id from GFRS_Program_Audience_Group__c where id = :newId ];
        
        if( !gFRS_Util.assignSObjectValue( obj, fieldName, value )){
            //-- unable to assign
            return( null );
        }
        
        update obj;
        
        return( obj );
    }
    
    /**
     *  Creates a new audience object
     *  @param programId (String)
     *  @return GFRS_Program_Audience_Group__c if successful
     **/
    @RemoteAction
    global static GFRS_Program_Audience_Group__c addAudience( String programId ){
        GFRS_Program_Audience_Group__c audience = new GFRS_Program_Audience_Group__c( Program__c = Id.valueOf( programId ) );
        insert audience;
        return( audience );
    }
    
    /**
     *  Removes an audience object
     *  @param audienceId (String)
     *  @return GFRS_Program_Audience_Group__c - if the object could be deleted
     **/
    @RemoteAction
    global static GFRS_Program_Audience_Group__c removeAudience( String audienceId ){
        Id newId = Id.valueOf( audienceId );
        GFRS_Program_Audience_Group__c obj = [ select id from GFRS_Program_Audience_Group__c where id = :newId ];
        delete obj;
        return( obj );
    }
}