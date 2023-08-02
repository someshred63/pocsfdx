/******************************************************************************************
*  @author: Lukasz Bieniawski, Roche (contractor)
*  @email: lukasz.bieniawski@contractors.roche.com   
*  Created: 2014-05-30
*  Description: Controller extension class for GNE_SFA2_Revegy_Account_Layout

*  Modification History
*  Date            Name               Description
*******************************************************************************************/
public with sharing class GNE_SFA2_Revegy_Account_Layout_Ext {
    
    public String iFrameUrl { 
        get;
        private set;
    }
    
    public GNE_SFA2_Revegy_Account_Layout_Ext(ApexPages.StandardController controller){
        this.iFrameUrl = GNE_SFA2_Revegy_Utils.getIFrameUrl(controller.getId());
    }        
}