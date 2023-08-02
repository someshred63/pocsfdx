/**
* @author ADMD Team
* @date 20/08/2013
* @description gFRS_UnitTestHelperPhilanthropic class - helper class for Unit Tests. Creates data for tests for Philanthropic test.
*
*/
public  without sharing class gFRS_UnitTestHelperPhilanthropic extends gFRS_UnitTestHelper {
	
	private static id ID_FR_PHILANTHROPIC_RECTYPE = [select id from RecordType where SobjectType = 'GFRS_Funding_Request__c' and DeveloperName='Philanthropic'].id;
	
	/**
   * @author ADMD Team
   * @date 20/08/2013
   * @description CreatePhilanthropicRequestInStatusNew method -  creates Philanthropic request in Status New and Under Review.
   *
   */
    public static id CreatePhilanthropicRequestInStatusNew(Id orgId, Id locId, User usr)
    {
        GFRS_Funding_Request__c req = new GFRS_Funding_Request__c(
        recordTypeId = ID_FR_PHILANTHROPIC_RECTYPE,
        Organization__c = orgId,
        Location__c = locId,
        Status__c = 'HC Compliance',
        Sub_Status__c = 'New',
        External_Sub_status__c = 'Under Review',
        Event_Program_Title__c = 'Text Philanthropic program',
        Support_Purpose_Program_Description__c='Philanthropic description',
        Students_of_Color_Scholarships__c='No',
        Hunger__c='No',
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