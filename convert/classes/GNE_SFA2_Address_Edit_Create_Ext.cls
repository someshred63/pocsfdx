/************************************************************
*  @author: Jakub Lewandowski, Roche
*  Date: 2012-12-20
*  Description: This is a controller extension for GNE_SFA2_Address_Edit_Create_Layout page
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Address_Edit_Create_Ext extends GNE_SFA2_Dynamic_VF_Edit_Create { 
    public Boolean recordTypePickerDisplayed {get; set;}
    private RecordType companyMaintainedRecordType;
    private static final String HCP_ADDRESS_DCR_TYPE_NAME = 'HCP_Existing_Address_Typo_Missing_Info';
    
    public GNE_SFA2_Address_Edit_Create_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_Address_Layout');
        companyMaintainedRecordType = [ SELECT Id FROM RecordType WHERE DeveloperName = :GNE_SFA2_Address_Field_Updates.ADDRESS_COMPANY_MAINTEINED_REC_TYPE AND SObjectType = 'Address_vod__c'];
    }
    
    public PageReference doSave(){
        String dcrStatus = 'Submitted';
        Address_vod__c currentRecord = ((Address_vod__c)myObject);
        
        /*For company maintained record type dcr is created automaticaly if some fields are changed*/
        Boolean insertDCR = false; 
        if(currentRecord.RecordTypeId == companyMaintainedRecordType.Id){
            List<String>addressDcrFields = GNE_SFA2_DCR_Config_Items_gne__c.getValues('AddressDcrFields').Value_gne__c.split(',');
            Set<String>addressDcrFieldsSet = new Set<String>();
            addressDcrFieldsSet.addAll(addressDcrFields);
            
			Map<String, String>fieldsMapping = GNE_SFA2_DCR_Util.getAddressDCRFieldMapping('HCP_Existing_Address_Typo_Missing_Info');
			
            String query = 'Select id, ';
            for(String fieldName: fieldsMapping.keySet()){
                query += fieldName + ', ';
            }
            query = query.substring(0, query.length() - 2);
            query += ' FROM Address_vod__c WHERE id = \'' + myObject.id+'\'';

            Address_vod__c oldRecord = (Address_vod__c)Database.query(query)[0];
            for(String fieldName: addressDcrFields){
                if(oldRecord.get(fieldName) != currentRecord.get(fieldName)){
                    insertDCR = true;
                }
            }
            if(insertDCR){
                Id recTypeId = [SELECT id FROM RecordType WHERE SobjectType = 'Change_Request_gne__c' AND developerName = :HCP_ADDRESS_DCR_TYPE_NAME].Id;
                Change_Request_gne__c dcr = new Change_Request_gne__c(Account_gne__c = currentRecord.Account_vod__c, Current_Address_gne__c = currentRecord.Id, RecordTypeId = recTypeId, Status_gne__c = dcrStatus);
                for(String fieldName: fieldsMapping.keySet()){
                    String dcrFieldName = fieldsMapping.get(fieldName);
                    dcr.put(dcrFieldName, currentRecord.get(fieldName));
                    if(addressDcrFieldsSet.contains(fieldName) && oldRecord.get(fieldName) != currentRecord.get(fieldName)){
                        currentRecord.put(fieldName, oldRecord.get(fieldName));
                    }
                }
                insert dcr;
            }
        } 
        
        PageReference pr = super.save();        

        if(insertDCR){
            pr.getParameters().put('DCRSubmitted', 'true');
        }
        return pr;        
    }
    
    public PageReference doCancel(){
        PageReference pr;
        if (String.isNotBlank(ApexPages.currentPage().getParameters().get('retURL'))) {
            pr = new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
            pr.setredirect(true);
        } else if (myObject.id != null) {
            pr = Page.GNE_SFA2_Address_Layout;
            pr.getParameters().put('id', myObject.id);
            pr.setredirect(true);
        } else if (String.isNotBlank(System.currentPageReference().getParameters().get('accountId'))){
            pr = new PageReference('/'+System.currentPageReference().getParameters().get('accountId'));
            pr.setredirect(true);
        } else {            
            pr = super.cancel();
        }        
        return pr;        
    }
    
    protected override void initController(ApexPages.StandardController controller) {
        if(controller.getRecord().Id==null) {
            Address_vod__c newAddress = new Address_vod__c();
            String preSetRecordTypeId = ApexPages.currentPage().getParameters().get('preSetRecordType');
            String accountId = ApexPages.currentPage().getParameters().get('accountId');
        
            recordTypePickerDisplayed = false;
            if(preSetRecordTypeId != null){
                newAddress.RecordTypeId = (Id)preSetRecordTypeId;
            }
            
            if(accountId != null) {
                newAddress.Account_vod__c = (Id)accountId;
            }
            myObject = newAddress;
        }       
        super.initController(controller);
    }  

    // USPS Address Validation Logic 

    @RemoteAction
    public static String addressValidate(Map<String, String> params) {
        return GNE_SFA2_USPSEngine.addressValidate(params);
    }

    @RemoteAction
    public static String cityStateLookup(Map<String, String> params) {
        return GNE_SFA2_USPSEngine.cityStateLookup(params);
    }

    @RemoteAction
    public static String zipCodeLookup(Map<String, String> params) {
        return GNE_SFA2_USPSEngine.zipCodeLookup(params);
    }
}