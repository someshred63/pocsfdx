/************************************************************
*  @author: Kishore Chandolu
*  Date: 2013-02-16
*  Description: This is a controller class for GNE_SFA2_Product_Catalog_Layout page.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Product_Catalog_Ctrl extends GNE_SFA2_DynamicVFLoader {   
    public GNE_SFA2_Product_Catalog_Ctrl(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_PCatalog_Layout');
    }
    
    public PageReference edit(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_PCatalog_Edit_Create_Layout?id='+myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }
     
}