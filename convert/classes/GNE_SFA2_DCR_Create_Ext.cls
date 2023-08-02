public with sharing class GNE_SFA2_DCR_Create_Ext extends GNE_SFA2_Dynamic_VF_Edit_Create  {
        
        public Map<String,String> fieldTypes  {get; private set;}
        
        public GNE_SFA2_DCR_Create_Ext(ApexPages.StandardController controller) {
                super(controller,'/apex/GNE_SFA2_DCR_Layout');
        }
        
        protected override void initController(ApexPages.StandardController controller) {
                if(controller.getRecord().Id==null) {
                        Change_Request_gne__c newDCR = new Change_Request_gne__c();
                        String recordTypeId     = ApexPages.currentPage().getParameters().get('RecordTypeId');
                String accountId        = ApexPages.currentPage().getParameters().get('AccountId');
                
                if(recordTypeId!=null) {
                        newDCR.RecordTypeId = (Id)recordTypeId;
                }
                
                if(accountId!=null) {
                        newDCR.Account_gne__c = (Id)accountId;
                }
                
                myObject = newDCR;
                }
                
        super.initController(controller);
        
        Map<String, Schema.SObjectField> fieldMap = myObject.getSObjectType().getDescribe().fields.getMap();
        fieldTypes = new Map<String,String>();
        
        for(String fieldName : fieldMap.keySet()) {
          System.debug('BOS::' + fieldName);
          fieldTypes.put(fieldName.toUpperCase(),fieldMap.get(fieldName).getDescribe().getType().name());  
        }
    }
}