public class CMT_JSONUtils
{
    public static String format (Object o)
    {
        String jsonObj = JSON.serialize(o);
        
        // the mobile app expects the name 'Abstract' to appear, but this is a reserved keyword so we can't use it as field name
        // and it has to be replaced here
        return jsonObj.replaceAll(',', ', ').replaceAll('\"', '"').replaceAll('AbstractGroup', 'Abstract').replaceAll('\\342\\200\\236','„');
    }
    
    public static String format (Object[] objs)
    {
        String jsonObj = JSON.serialize(objs);
        return jsonObj.replaceAll(',', ', ').replaceAll('\\342\\200\\236','„');
    }
    
    /**
     * Transforms attachments into CMT_Attachments and groups them by parent ID.
     */
    public static Map<ID, List<CMT_Attachment>> groupAttachments (CMT_Attachment_gne__c[] attachments)
    {
        Map<ID, List<CMT_Attachment>> groups = new Map<ID, List<CMT_Attachment>>();
        
        for (CMT_Attachment_gne__c a : attachments)
        {
            // if a sub map does not exist, create it
            if (!groups.containsKey(a.Parent_Id_gne__c))
            {
                groups.put(a.Parent_Id_gne__c, new List<CMT_Attachment>());
            }
            
            groups.get(a.Parent_Id_gne__c).add(new CMT_Attachment(a));
        }
        
        return groups;
    }
    
    /**
     * Transforms attachments into CMT_Attachments and groups them on two levels:
     * - the first level are attachments grouped by the ParentType
     * - the second level are attachments grouped by the ParentId
     */
    public static Map<String, Map<ID, List<CMT_Attachment>>> groupAttachmentsByParentTypeAndId (CMT_Attachment_gne__c[] attachments)
    {
        Map<String, Map<ID, List<CMT_Attachment>>> groups = new Map<String, Map<ID, List<CMT_Attachment>>>();
        
        for (CMT_Attachment_gne__c a : attachments)
        {
            // if a sub map does not exist, create it
            if (!groups.containsKey(a.Parent_Type_gne__c))
            {
                groups.put(a.Parent_Type_gne__c, new Map<ID, List<CMT_Attachment>>());
            }
            
            Map<ID, List<CMT_Attachment>> submap = groups.get(a.Parent_Type_gne__c);
            
            if (submap == null)
            {
                submap = new Map<ID, List<CMT_Attachment>>();
            }
            
            if (!submap.containsKey(a.Parent_Id_gne__c))
            {
                submap.put(a.Parent_Id_gne__c, new List<CMT_Attachment>());
            }
            
            submap.get(a.Parent_Id_gne__c).add(new CMT_Attachment(a));
            
            groups.put(a.Parent_Type_gne__c, submap);
        }
        
        return groups;
    }
}