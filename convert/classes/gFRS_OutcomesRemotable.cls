global class gFRS_OutcomesRemotable {


    public gFRS_OutcomesRemotable( ApexPages.StandardController std ) {

    }

    /**
     *  Remoting method that returns all outcome data
     *  @return GFRS_Program_Audience_Group__c[] - list of audience members
     **/
    @RemoteAction
    global static GFRS_Program_Audience_Group__c[] fetchAttendees( String programId ) {
        GFRS_Program_Audience_Group__c[] audience = [ select id, Name, Program__c, Actual_Learners__c, Actual_Learners_with_Credit__c, Actual_Number_Participants__c, Category_of_Credit__c, Credit_Hours__c, Expected_Learners_Credit__c, Expected_Learners__c, Intended_Audience__c, Invitations_Distributed__c, Number_of_Participants__c, Number_of_Speaking__c, Other__c, Specialty__c
                from GFRS_Program_Audience_Group__c
                where Program__c = :programId ];
        return ( audience );
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
    global static GFRS_Program_Audience_Group__c updateAudienceField( String audienceId, String fieldName, String value ) {
        GFRS_Program_Audience_Group__c audience = new GFRS_Program_Audience_Group__c(
            Id = audienceId
        );

        if ( !gFRS_Util.assignSObjectValue( audience, fieldName, value )) {
            return null;
        }
        else {
            update audience;
            return audience;
        }

    }
}