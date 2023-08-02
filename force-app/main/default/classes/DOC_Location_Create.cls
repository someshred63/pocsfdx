public class DOC_Location_Create
{

public static Integer Create_Affiliation_On_Parent_Change(Map <Id, Id> newAffMap)
{
    // Only process DoC Location records, otherwise return
    // If Parent DoC not changed nothing to process. Return
    
    if (newAffMap.size() == 0)
    {
        return 0;
    }
    // Forward affiliation. Location -> DoC
    
    List <Affiliation_vod__c> affList = 
        [select Id, from_Account_vod__c, To_Account_vod__c,
            Affiliation_Type_gne__c, Role_vod__c,Portal_Affiliation_gne__c
            from Affiliation_vod__c
            where from_Account_vod__c in :newAffMap.keyset()
                and Affiliation_Type_gne__c = 'AFFILIATION'
                and Role_vod__c = 'DoC Location'];
    
    List <Affiliation_vod__c> newAffList =new List <Affiliation_vod__c>();

    // Create new Affiliation from Location -> DoC
        
    for (Id fromId : newAffMap.keyset())
    {
        Id toId = newAffMap.get(fromId);
        if (toId == null)
        {
            continue;
        }
        Boolean affExist = false;
        for (Affiliation_vod__c aff : affList)
        {
            if (aff.From_Account_vod__c == fromId && aff.To_Account_vod__c == toId)
            {
                // Affiliation already exists
                affExist = true;
                break;
            }
        }
        if (affExist == false)
        {
            // Affiliation not exists. Create new
            Affiliation_vod__c a = new Affiliation_vod__c();
            a.from_Account_vod__c = fromId;
            a.To_Account_vod__c = toId;
            a.Role_vod__c = 'DoC Location';
            newAffList.add(a);
        }
    } 
    if (newAffList.size() > 0)
    {
        insert(newAffList);
    } 
 
    return newAffList.size();
}
@future
public static void Create_Affiliation_On_Parent_Change_Future(Map <Id, Id> newAffMap)
{
    Create_Affiliation_On_Parent_Change(newAffMap);
}
}