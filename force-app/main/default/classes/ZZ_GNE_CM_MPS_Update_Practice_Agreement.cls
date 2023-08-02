public class ZZ_GNE_CM_MPS_Update_Practice_Agreement {

    public static void updatePracticeAgrrLoc()
    {
        Set<Id> regIdTrue   = new  Set<Id>();
        Set<Id> prescIdTrue = new  Set<Id>();
        Set<Id> regIdFalse   = new  Set<Id>();
        Set<Id> prescIdFalse = new  Set<Id>();
        Set<Id> PractAgreeIdTrue = new  Set<Id>();
        Set<Id> PractAgreeIdFalse = new  Set<Id>();
        
        
        List<GNE_CM_MPS_Prescriber__c> lstMPSPresc = [Select id,Disabled__c,GNE_CM_MPS_Registration__c  from GNE_CM_MPS_Prescriber__c where Disabled__c = true];
        
        if(lstMPSPresc != null && lstMPSPresc.size() > 0)
        {
            for(GNE_CM_MPS_Prescriber__c presc : lstMPSPresc)
            {
                prescIdTrue.add(presc.id);
            }
        }
        List<GNE_CM_MPS_Practice_Agreement__c> lstPractAgrTrue = new List<GNE_CM_MPS_Practice_Agreement__c>();
         //List<GNE_CM_MPS_Practice_Agreement__c> lstPractAgrFalse = new List<GNE_CM_MPS_Practice_Agreement__c>();
         if(prescIdTrue != null && prescIdTrue.size() > 0)
         {
                lstPractAgrTrue = [Select id,Name from GNE_CM_MPS_Practice_Agreement__c where MPS_Prescriber__c in :prescIdTrue];
                if(lstPractAgrTrue != null && lstPractAgrTrue.size() > 0)
                {
                  for(GNE_CM_MPS_Practice_Agreement__c pract : lstPractAgrTrue)
                  {
                    PractAgreeIdTrue.add(pract.id);
                  }
                }
         }
          List<GNE_CM_MPS_Practice_Agreement_Location__c> lstPractToUpdate = new  List<GNE_CM_MPS_Practice_Agreement_Location__c>();
          List<GNE_CM_MPS_Practice_Agreement_Location__c> lstPractTrue = [Select id,Prescriber_Location_Disabled_gne__c from GNE_CM_MPS_Practice_Agreement_Location__c where MPS_Practice_Agreement__c in : PractAgreeIdTrue];
          if(lstPractTrue != null && lstPractTrue.size() > 0)
          {
             for(GNE_CM_MPS_Practice_Agreement_Location__c presc : lstPractTrue)
             {
                presc.Prescriber_Location_Disabled_gne__c = true;
                lstPractToUpdate.add(presc);
             }
          }
          if(lstPractToUpdate != null && lstPractToUpdate.size() > 0)
          {
            update lstPractToUpdate;
          }
    } 
}