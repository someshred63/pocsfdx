public class ZZ_GNE_CM_MPS_PopulateTreatingLocationId {
    
    public static void updateRegformMPSFlagonAddress()
    {
        List<GNE_CM_MPS_Practice_Agreement_Location__c> lstPractLoc = [Select id,Address__c from GNE_CM_MPS_Practice_Agreement_Location__c where Address__c != null];
        List<Address_vod__c> lstToUpdate = new List<Address_vod__c>();
        List<Address_vod__c> lstToUpdateT = new List<Address_vod__c>();
        List<Address_vod__c> lstToUpdateF = new List<Address_vod__c>();
        List<Address_vod__c> lstAddress = new List<Address_vod__c>();
        List<Address_vod__c> lstToUpdateTrue = new List<Address_vod__c>();
        List<Address_vod__c> lstToUpdateFalse = new List<Address_vod__c>();
        Set<Id> AddressId                = new Set<Id>();
        Set<Id> AddressIdUpdateTrue      = new Set<Id>();
        Set<Id> AddressIdUpdateFalse     = new Set<Id>();
        if(lstPractLoc != null && lstPractLoc.size() > 0)
        {
            for(GNE_CM_MPS_Practice_Agreement_Location__c loc : lstPractLoc)
            {
                AddressId.add(loc.Address__c);
            }
        }
        if(AddressId != null && AddressId.size() > 0)
            lstAddress =[Select id, Registered_for_MPS_gne__c from Address_vod__c where id in : AddressId];
        
        if(lstAddress != null && lstAddress.size() > 0)
        {
            for(Address_vod__c add :lstAddress)
            {
                add.Registered_for_MPS_gne__c = true;
                lstToUpdate.add(add);
            }   
        }
        if(lstToUpdate != null && lstToUpdate.size() > 0)
            update lstToUpdate; 
        
    }
}