/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-08-21
*  Description: This is a helper class for GNE_SFA2_Affiliation_Trigger
*  Test class: GNE_SFA2_Affiliation_Trigger_Test
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public without sharing class GNE_SFA2_Affiliation_Trigger_Helper {
    private static Boolean inAffiliationTrigger = false;
    
    public static void setAfilTrig (Boolean inAffilTrig) {
        inAffiliationTrigger = inAffilTrig;
    }
    
    public static Boolean inAfilTrig() {
        return inAffiliationTrigger;
    } 
}