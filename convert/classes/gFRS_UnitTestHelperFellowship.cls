/**
* @author ADMD Team
* @date 20/08/2013
* @description gFRS_UnitTestHelperFellowship class - helper class for Unit Tests. Creates data for tests for Fellowship test.
*
*/
public  without sharing class  gFRS_UnitTestHelperFellowship extends gFRS_UnitTestHelper {
	
	private static id ID_FR_FELLOWSHIP_RECTYPE = [select id from RecordType where SobjectType = 'GFRS_Funding_Request__c' and DeveloperName='Fellowships'].id;
	
	/**
   * @author ADMD Team
   * @date 20/08/2013
   * @description CreateFellowshipRequestInStatusNew method -  creates Fellowship request in Status New and Under Review.
   *
   */
    public static id CreateFellowshipRequestInStatusNew(Id orgId, Id locId, User usr)
    {
        GFRS_Funding_Request__c req = new GFRS_Funding_Request__c(
        recordTypeId = ID_FR_FELLOWSHIP_RECTYPE,
        Organization__c = orgId,
        Location__c = locId,
        Status__c = 'HC Compliance',
        Sub_Status__c = 'New',
        External_Sub_status__c = 'Under Review',
        Event_Program_Title__c = 'Text Fellowship program',
        Therapeutic_Area_Parent__c ='Cardiology',
        Therapeutic_Area__c = 'Acute Coronary Syndrome',
        Support_Purpose_Program_Description__c='Fellowship description',
        ACGME_Program_Number__c='12',
        Basic_Research_Fellow__c='No',
        Educational_Objectives_1__c='test Fellowship',
        Fellowship_Opportunity_Publication__c='Fellowship Opportunity Publication',
        Criteria_to_Select_a_Fellow__c='Criteria to Select a Fellow',
        Funds_Used_To_Pay_Licensed_Physician__c='No',
        Clinical_Practice_Guideline_Development__c='No',
        Delivery_Method__c='Vendor',
        Attention_To__c = 'tuser',
        Requested_Amount__c= 10000,
        Approved_Amount__c=10000,
        Approval_Reason__c='Approved at Full Amount',
        Date_Submitted__c=Date.today(),
        Authorized_Signer__c=usr.id,
        Signing_Authority_Email__c=usr.email,
        Signing_Authority_First_Name__c=usr.FirstName,
        Signing_Authority_Last_Name__c=usr.LastName,
        Unix_ID__c=usr.alias

        );
        
        insert req;
        
        return req.id;
   }
}