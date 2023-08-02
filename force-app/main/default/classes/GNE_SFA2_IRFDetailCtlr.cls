public class GNE_SFA2_IRFDetailCtlr extends GNE_SFA2_Dynamic_VF_Edit_Create {

    private String entityId = ApexPages.currentPage().getParameters().get('id');
    
    public GNE_SFA2_IRFDetailCtlr(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_IRF_Layout');
        if(controller.getRecord() == null){
                myObject = new Issue_gne__c();
        }
        String parentId = ApexPages.currentPage().getParameters().get('objectId');
        if(parentId != null && parentId != '' && myObject.id == null){
            Account AccRecordType = [SELECT RecordType.Name FROM Account WHERE Id= :parentId limit 1];        
            if(AccRecordType.RecordType.Name=='Professional_vod')    
                myObject.put('Physician_Name_frm_gne__c', parentId);
            else
                myObject.put('Practice_Name_frm_gne__c', parentId);
        }    
    }

    public PageReference edit(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_IRF_Edit_Create_Layout?Id='+entityId);
        pageref.setredirect(true);
        return pageref;
    }        
}