/**
* @author GFRS Dev Team
* @date 14/08/2013
* @description gFRS_PaymentProcess class - class used in triggers for storing methods connected with payment process. 
*/
public without sharing class gFRS_PaymentProcessCopay{
    
    public id idPaymentType{get;set;}
    
    public gFRS_PaymentProcessCopay(){
        
        for (RecordType rt :[SELECT Id, Name FROM RecordType WHERE SObjectType = 'GFRS_Copay_Funding_Allocation__c' AND DeveloperName IN ('Payment')])
        {
            if (rt.Name == 'Payment') idPaymentType = rt.Id;
        } 
    }   
    
    /*** Funding Allocation Methods ***/
    
    /**
  * @author GFRS Dev Team  
  * @date 14/08/2013
  * @description createFundingAllocation method - creates default Funding Allocation record. 
  */

    public static Set<ID> SETRequestToAvoidcreateFundingAllocation = new Set<ID>();

    public void createFundingAllocation(Map<Id, GFRS_Copay_Funding_Request__c> newMapFundingRequest) {
        

        Boolean bCreateFA                                           = false;
        gFRS_Copay_Funding_Allocation__c newObjFundingAllocation    = null;
        gFRS_Copay_Funding_Allocation__c[] tabObjFundingAllocations = new gFRS_Copay_Funding_Allocation__c[]{};
        GFRS_Copay_Funding_Request__c newObjRequest                 = null;
        String strFiscalYear                                        = String.valueOf( date.today().year() );
        GFRS_Copay__c gc = GFRS_Copay__c.getOrgDefaults();
        String strGLaccount                                         = gc.GL_Account__c;
        
        Set<ID> SetToChangedFunding = new Set<ID>();

        for(ID st : newMapFundingRequest.keySet()){
            if(!SETRequestToAvoidcreateFundingAllocation.contains(st)){
                SetToChangedFunding.add(st);
                SETRequestToAvoidcreateFundingAllocation.add(st);
            }
        }

        List<GFRS_Copay_Funding_Request__c> ListForLoopFundingRequest = new List<GFRS_Copay_Funding_Request__c>();

        if(SetToChangedFunding.size() > 0){
         ListForLoopFundingRequest = [
            SELECT Id, Record_Type_Name__c, ( SELECT Id FROM gFRS_Copay_Funding_Allocations__r ) FROM gFRS_Copay_Funding_Request__c
            WHERE Id IN :SetToChangedFunding
        ];
        }


        for(GFRS_Copay_Funding_Request__c objRequest : ListForLoopFundingRequest)
        {
            //-- only requests under consideration are those that do not have allocations
            if( objRequest.gFRS_Copay_Funding_Allocations__r == null || objRequest.gFRS_Copay_Funding_Allocations__r.size() < 1 )
            {

                newObjFundingAllocation = new GFRS_Copay_Funding_Allocation__c(Grant_Request__c = objRequest.Id, Fiscal_Year__c = strFiscalYear, GL_Account_ref__c = strGLaccount, RecordTypeId=idPaymentType);
                tabObjFundingAllocations.add( newObjFundingAllocation );
                        
            }
        }
        
        if( tabObjFundingAllocations.size() > 0 )
        {
            try
            {
                 insert tabObjFundingAllocations;
                 
                 list<GFRS_Copay_Funding_Allocation_Line_Item__c>  lineitemlist = new list<GFRS_Copay_Funding_Allocation_Line_Item__c>();
                 
                 for(gFRS_Copay_Funding_Allocation__c FundAlloc : tabObjFundingAllocations){
                     
                    GFRS_Copay_Funding_Allocation_Line_Item__c  lineitem = new GFRS_Copay_Funding_Allocation_Line_Item__c
                        ( Funding_Allocation__c   = FundAlloc.id,
                          Percent__c              = 100,
                          Funding_Record_Type__c  = FundAlloc.Grant_Request__r.Record_Type_Name__c,
                          Cost_Center_Lookup__c   = gc.Cost_Center__c,
                          WBS_Code_Lookup__c      = gc.WBS_Code__c
                        );              
                    
                    lineitemlist.add(lineitem);                  
                 }
                 insert lineitemlist;
            }
            catch(System.DmlException ex)
            {
                 for (Integer i = 0; i < ex.getNumDml(); i++)
                 {
                    System.debug(ex.getDmlMessage(i)); 
                 }
            }
        }  
    }
    
}