/**
* @author ADMD Team
* @date 19/06/2013
* @description gFRS_UnitTestHelperCorporateMembership class - helper class for Unit Tests. Creates data for tests for Corporate Membership test.
*
*/
public  without sharing class  gFRS_UnitTestHelperCorporateMembership extends gFRS_UnitTestHelper
{
	
	private static id ID_FR_CORP_MEMBER_RECTYPE = [select id from RecordType where SobjectType = 'GFRS_Funding_Request__c' and DeveloperName='Corporate_Memberships'].id;

        /**
       * @author ADMD Team
       * @date 19/06/2013
       * @description CreateCorpMemberRequestInStatusNew method -  creates Corporate Membership request in Status New and Under Review.
       *
       */
        public static id CreateCorpMemberRequestInStatusNew(Id orgId, Id locId, User usr)
        {
        GFRS_Funding_Request__c req = new GFRS_Funding_Request__c(
        recordTypeId = ID_FR_CORP_MEMBER_RECTYPE,
        Organization__c = orgId,
        Location__c = locId,
        Status__c = 'HC Compliance',
        Sub_Status__c = 'New',
        External_Sub_status__c = 'Under Review',
        Event_Program_Title__c = 'Text corp. membership program',
        Therapeutic_Area_Parent__c ='Cardiology',
        Therapeutic_Area__c = 'Acute Coronary Syndrome',
        Support_Purpose_Program_Description__c='Test',
        Open_to_public__c='Yes',
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
        Accountable_Employee__c=usr.id,
        Financial_Approver_1__c=usr.id,
        Benefits_Exchanged_for_Funding__c='Access to attendee/membership list; Access to leadership/oppty to present',
        Payment_Delivery_Notifications__c=usr.id,
        Unix_ID__c=usr.alias,
        Payment_Email_Notification__c=usr.alias, 
        Send_By_FedEx_cost_center_will_be_charg__c = 'No',
        Financial_Approver_3__c=usr.id,
        Finance_Managers__c='Alexandra Schuman (alehr)'
        );
        
        insert req;
        
        return req.id;
       }
    
	
}