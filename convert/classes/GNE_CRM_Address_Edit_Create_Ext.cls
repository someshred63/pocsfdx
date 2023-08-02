/************************************************************
*  @author: Lukasz Kozminski, Roche
*  Date: 2016-12-06
*  Description: This is a controller extension for GNE_CRM_Address_Edit_Create_Layout page
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_CRM_Address_Edit_Create_Ext extends GNE_SFA2_Dynamic_VF_Edit_Create {
    private static final String LEVEL_OF_ACCESS = 'You do not have the level of access necessary to perform the operation you requested. ' +
            'Please contact the owner of the record or your administrator if access is necessary.';
    private Boolean HasUserEditAccess;

    public GNE_CRM_Address_Edit_Create_Ext(ApexPages.StandardController controller) {
        super(controller, '/apex/GNE_CRM_Address_Edit_Create');
    }

    public PageReference doSave() {

        PageReference pr = super.save();
        if (pr != null) {
            pr = new PageReference('/' + myObject.Id);
        }
        return pr;
    }

    public override PageReference init() {
        PageReference result = super.init();
        HasUserEditAccess = true;
        if (controller.getId() != null) {
            UserRecordAccess userRecordAccess = GNE_SFA2_Util.getUserRecordAccess(UserInfo.getUserId(), controller.getId());
            if (!userRecordAccess.HasEditAccess) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, LEVEL_OF_ACCESS));
                HasUserEditAccess = false;
                return null;
            }
        }
        if (result == null) {
            return null;
        } else if (myObject.Id != null) {
            result = new PageReference('/' + myObject.Id + '/e?nooverride=1');
            result.getParameters().put('retURL', ApexPages.currentPage().getParameters().get('retURL'));
            result.setRedirect(true);
        } else {
            Schema.DescribeSObjectResult schema = Address_vod__c.SObjectType.getDescribe();
            String accountId = System.currentPageReference().getParameters().get('objectId');
            Account acc = [SELECT Id, Name FROM Account WHERE Id = :accountId];
            result = new PageReference('/' + schema.getKeyPrefix() + '/e?nooverride=1');
            result.getParameters().put('accountId', acc.Id);
            result.getParameters().put('CF00N70000001tDKx', acc.Name);
            result.getParameters().put('CF00N70000001tDKx_lkid', acc.Id);
            result.getParameters().putAll(System.currentPageReference().getParameters());
        }
        return result;
    }

    public Boolean getHasUserEditAccess() {
        return HasUserEditAccess;
    }

    public PageReference doCancel() {
        PageReference pr;
        if (String.isNotBlank(ApexPages.currentPage().getParameters().get('retURL'))) {
            pr = new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
            pr.setRedirect(true);
        } else if (myObject.Id != null) {
            pr = new PageReference('/' + myObject.Id);
            pr.setRedirect(true);
        } else if (String.isNotBlank(System.currentPageReference().getParameters().get('accountId'))) {
            pr = new PageReference('/' + System.currentPageReference().getParameters().get('accountId'));
            pr.setRedirect(true);
        } else {
            pr = super.cancel();
        }
        return pr;
    }

    protected override void initController(ApexPages.StandardController controller) {
        if (controller.getRecord().Id == null) {
            Address_vod__c newAddress = new Address_vod__c();
            String preSetRecordTypeId = ApexPages.currentPage().getParameters().get('preSetRecordType');
            String accountId = ApexPages.currentPage().getParameters().get('accountId');

            if (preSetRecordTypeId != null) {
                newAddress.RecordTypeId = (Id) preSetRecordTypeId;
            }

            if (accountId != null) {
                newAddress.Account_vod__c = (Id) accountId;
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