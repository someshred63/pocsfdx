global class GFRS_ProgramRemotable {
    
    public GFRS_ProgramRemotable( ApexPages.StandardController std ){
        
    }
    /**
     *  Creates a new audience object
     *  @param programId (String)
     *  @return GFRS_Program_Audience_Group__c if successful
     **/
    @RemoteAction
    global static GFRS_Program_Audience_Group__c addAudience( String programId ){
        GFRS_Program_Audience_Group__c audience = new GFRS_Program_Audience_Group__c( Program__c = Id.valueOf( programId ) );
        gFRS_Util_NoShare.saveLockedProgramAudience( new gFRS_Program_Audience_Group__c[]{ audience });
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
        gFRS_Util_NoShare.removeLockedProgramAudience( new gFRS_Program_Audience_Group__c[]{ obj } );
        return( obj );
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
        
        gFRS_Util_NoShare.saveLockedProgramAudience( new gFRS_Program_Audience_Group__c[]{ obj });
        
        return( obj );
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
}