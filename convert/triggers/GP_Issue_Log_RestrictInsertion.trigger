trigger GP_Issue_Log_RestrictInsertion on ContentVersion (after insert) {
    
    // after event
    if (Trigger.isAfter)
    {
        // insert
        if (Trigger.isInsert)
        {
            List<ContentVersion> contentVersions = new List<ContentVersion>();
            contentVersions = GPIssueLogTriggerController.filterGPIssueLogCV(Trigger.new);
            if (contentVersions?.size() > 0) {
                GPIssueLogTriggerController.restrictInsertion(contentVersions, Trigger.newMap.keySet());
            }
        }
    }
}