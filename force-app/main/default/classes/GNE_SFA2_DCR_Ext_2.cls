/************************************************************
*  @author: Jakub Lewandowski, Roche
*  Date: 2013-02-22
*  Description: This is a controller extension for GNE_SFA2_DCR_Layout page
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_DCR_Ext_2 extends GNE_SFA2_DynamicVFLoader {   
    public GNE_SFA2_DCR_Ext_2(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_DCR_Layout');
        System.debug('inside of DCR_Ext_2');
    }

    public PageReference edit(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_DCR_Edit_Layout?id='+myObject.id);
        pageref.setredirect(true);
        return pageref;
    }
    
    public override PageReference init(){
        PageReference pageref = super.init();
        if(pageref != null && pageref.getParameters().get('exMessage') == 'Layout configuration records not found.'){
	        return null;
        }
        return pageref;
    }
}