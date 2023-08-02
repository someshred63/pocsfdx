public class ZZ_GNE_CM_MPS_Update_PracticeAgLoc 
{
    public static void updatePractAgrrLoc()
    {
        Map<Id,GNE_CM_MPS_Location__c> mapMPSLocTrue    = new Map<Id,GNE_CM_MPS_Location__c>([Select id,Disabled__c  from GNE_CM_MPS_Location__c where Disabled__c = true]);
        List<GNE_CM_MPS_Practice_Agreement_Location__c> lstPractAgrrLocTruetoUpdate = [Select id,Prescriber_Location_Disabled_gne__c,MPS_Location__c  from GNE_CM_MPS_Practice_Agreement_Location__c];
        List<GNE_CM_MPS_Practice_Agreement_Location__c> lstToUpdate = new List<GNE_CM_MPS_Practice_Agreement_Location__c>();
        if(lstPractAgrrLocTruetoUpdate != null && lstPractAgrrLocTruetoUpdate.size() > 0)
        {
            for(GNE_CM_MPS_Practice_Agreement_Location__c pract :lstPractAgrrLocTruetoUpdate)
            {
                if(pract.MPS_Location__c != null)
                {
                    if(mapMPSLocTrue.containsKey(pract.MPS_Location__c))
                    {
                        pract.Prescriber_Location_Disabled_gne__c = true;
                        lstToUpdate.add(pract);
                    }
                    
                    //lstToUpdate.add(pract);
                }
            }
        }
        if(lstToUpdate != null && lstToUpdate.size() > 0)
        {
            update lstToUpdate;
        }
    }
}