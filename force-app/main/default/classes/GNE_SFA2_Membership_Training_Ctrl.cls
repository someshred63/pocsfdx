/************************************************************
*  @author: Kishore Chandolu
*  Date: 2013-02-05
*  Description: This is a controller class for GNE_SFA2_Membership_Training_Layout page.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Membership_Training_Ctrl extends GNE_SFA2_DynamicVFLoader {   
    public GNE_SFA2_Membership_Training_Ctrl(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_MTraining_Layout');
    }
}