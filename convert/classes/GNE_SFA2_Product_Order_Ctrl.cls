/************************************************************
*  @author: Kishore Chandolu
*  Date: 2013-02-28
*  Description: This is a controller class for GNE_SFA2_ProductOrder_Layout page.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Product_Order_Ctrl extends GNE_SFA2_DynamicVFLoader {   
    public GNE_SFA2_Product_Order_Ctrl(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_ProductOrder_Layout');
    }
    
    public PageReference edit(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_ProductOrder_Edit_Create_Layout?id='+myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }
     
}