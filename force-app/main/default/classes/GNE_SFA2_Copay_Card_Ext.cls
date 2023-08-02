public with sharing class GNE_SFA2_Copay_Card_Ext extends GNE_SFA2_DynamicVFLoader {   
    public GNE_SFA2_Copay_Card_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_CopayCard_Layout');
    }

    public PageReference edit(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_Copay_Card_Edit_Create_Layout?id='+myObject.id);
        pageref.setredirect(true);
        return pageref;
    }
}