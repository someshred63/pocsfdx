public class GNE_SFA2_CopayCardDetailCtlr extends GNE_SFA2_Dynamic_VF_Edit_Create {

    private String entityId = ApexPages.currentPage().getParameters().get('id');
    
    public GNE_SFA2_CopayCardDetailCtlr(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_CopayCard_Layout');
        String accountId = ApexPages.currentPage().getParameters().get('objectId');
        
        if(myObject == null){
                myObject = new Copay_Card_gne__c();
        }
         myObject.put('OwnerId',UserInfo.getUserId());
        if(accountId != null && accountId != '' && myObject.id == null){
          myObject.put('Account_gne__c', accountId);
          
          }
          
    }

    public PageReference edit(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_Copay_Card_Edit_Create_Layout?Id='+entityId);
        pageref.setredirect(true);
        return pageref;
    }        
}