/**
* @author ADMD Team
* @date 20/08/2013
* @description gFRS_UnitTestHelperHcChar class - helper class for Unit Tests. Creates data for tests for HC CHAR test.
*
*/
public  without sharing class gFRS_UnitTestHelperHcChar extends gFRS_UnitTestHelper {
	
	private static id ID_FR_HC_CHAR_RECTYPE = [select id from RecordType where SobjectType = 'GFRS_Funding_Request__c' and DeveloperName='HC_CHAR'].id;
	
	/**
   * @author ADMD Team
   * @date 20/08/2013
   * @description CreateHcCharRequestInStatusNew method -  creates HC CHAR request in Status New and Under Review.
   *
   */
    public static id CreateHcCharRequestInStatusNew(Id orgId, Id locId, User usr)
    {
        GFRS_Funding_Request__c req = new GFRS_Funding_Request__c(
        recordTypeId = ID_FR_HC_CHAR_RECTYPE,
        Organization__c = orgId,
        Location__c = locId,
        Status__c = 'HC Compliance',
        Sub_Status__c = 'New',
        External_Sub_status__c = 'Under Review',
        Event_Program_Title__c = 'Text corp. membership program',
        Therapeutic_Area_Parent__c ='Cardiology',
        Therapeutic_Area__c = 'Acute Coronary Syndrome',
        Support_Purpose_Program_Description__c='Test',
        Pediatric_Cancer_Assistance__c='No',
        Delivery_Method__c='Vendor',
        Attention_To__c = 'tuser',
        Requested_Amount__c= 10000,
        Approved_Amount__c=10000,
        Approval_Reason__c='Approved at Full Amount',
        Date_Submitted__c=Date.today(),
        Authorized_Signer__c=usr.id,
        Signing_Authority_Email__c=usr.email,
        Signing_Authority_First_Name__c=usr.FirstName,
        Signing_Authority_Last_Name__c=usr.LastName
        );
        
        insert req;
        
        return req.id;
   }
   
   /**
   * @author ADMD Team
   * @date 20/08/2013
   * @description CreateHcCharRequestInStatusNewAndProperTA method -  creates HC CHAR request in Status New and Under Review.
   *
   */
    public static id CreateHcCharRequestInStatusNewAndProperTA(Id orgId, Id locId, User usr,String TaParent,String DesiseStat)
    {
        GFRS_Funding_Request__c req = new GFRS_Funding_Request__c(
        recordTypeId = ID_FR_HC_CHAR_RECTYPE,
        Organization__c = orgId,
        Location__c = locId,
        Status__c = 'HC Compliance',
        Sub_Status__c = 'New',
        External_Sub_status__c = 'Under Review',
        Event_Program_Title__c = 'Text corp. membership program',
        Therapeutic_Area_Parent__c =TaParent,
        Therapeutic_Area__c = DesiseStat,
        Support_Purpose_Program_Description__c='Test',
        Pediatric_Cancer_Assistance__c='No',
        Delivery_Method__c='Vendor',
        Attention_To__c = 'tuser',
        Requested_Amount__c= 10000,
        Approved_Amount__c=10000,
        Approval_Reason__c='Approved at Full Amount',
        Date_Submitted__c=Date.today(),
        Authorized_Signer__c=usr.id,
        Signing_Authority_Email__c=usr.email,
        Signing_Authority_First_Name__c=usr.FirstName,
        Signing_Authority_Last_Name__c=usr.LastName
        );
        
        insert req;
        
        return req.id;
   }
	
}