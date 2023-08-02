/************************************************************
*  @author: Kishore Chandolu
*  Date: 2013-03-28
*  Description: This is a controller class for GNE_SFA2_IRF_Case_Layout page.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_IRF_Case_Layout_Ctrl extends GNE_SFA2_DynamicVFLoader {   
    
    public GNE_SFA2_IRF_Case_Layout_Ctrl(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_IRF_Case_Layout');
    }
    
    public PageReference edit(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_IRF_Case_Edit_Create_Layout?id='+myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }

    public PageReference deleteIRFCase(){

     try{  
            delete myObject;
            pagereference pageref = new pagereference('/apex/GNE_SFA2_myAccounts');
            pageref.setredirect(true);
            return pageref;
        }
        catch (Exception ex){
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage())); 
           return null;
        }
    }
     
}