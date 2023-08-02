public with sharing class GNE_SFA2_Contact_Edit_Create_Ext extends GNE_SFA2_Dynamic_VF_Edit_Create {

    public GNE_SFA2_Contact_Edit_Create_Ext(ApexPages.StandardController controller) {
        super(controller,'/apex/GNE_SFA2_Contact_Layout');

        String accountId = Apexpages.currentPage().getParameters().get('accountId');
        String recordTypeId = Apexpages.currentPage().getParameters().get('recordTypeId');
        String ownerId = UserInfo.getUserId();
        if(myObject == null || myObject.id==null){
            myObject = new Contact(AccountId = accountId, RecordTypeId=recordTypeId,OwnerId=ownerId);
        }
        String parentId = ApexPages.currentPage().getParameters().get('objectId');
        if(parentId != null && parentId != ''){
            myObject.put('AccountId', parentId);
        }
    }

    
    public override PageReference init(){
        PageReference result = super.init();
        if(availabilityMode == 'Edit' && myObject.id!=null && String.valueOf(myObject.id)!='')
        { 
            // for PersonAccount contacts we should display PersonAccount instead of Contact
            List<Account> contactPersonAccountList = [SELECT Id FROM Account WHERE PersonContactId = :myObject.Id limit 1];
            if(contactPersonAccountList != null && contactPersonAccountList.size() > 0){
                result = new PageReference('/apex/GNE_SFA2_Account_Edit_Create_Layout?id='+contactPersonAccountList[0].Id);
                result.setredirect(true);
            }
        }
        return result;
    }
}