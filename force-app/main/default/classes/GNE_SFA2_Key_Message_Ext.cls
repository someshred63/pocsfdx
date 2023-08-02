/************************************************************
*  @author: Sreedhar Karukonda
*  Date: 2013-02-05
*  Description: This is a controller extension for GNE_SFA2_Key_Message page
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Key_Message_Ext extends GNE_SFA2_DynamicVFLoader {   
    public GNE_SFA2_Key_Message_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_Key_Message_Layout');
    }
}