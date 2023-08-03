/***************************************************************************
Purpose: Restrict the SPLOA read only user to attach files.
Jira:ROBOCOPS-146
============================================================================
History                                                            
-------                                                            
VERSION  AUTHOR             DATE            DETAIL                       
1.0      Raju Manche        08/18/2020      INITIAL DEVELOPMENT     
2.0      Palani             05/02/2022      Added Trigger Controller Class
****************************************************************************/
trigger SPLOA_File_Insertion on ContentDocumentLink (before insert) {        
    
    // Before event
    if (Trigger.isBefore)
    {
        // insert
        if (Trigger.isInsert)
        {
            SPLOATriggerController.checkFileInsertion(Trigger.new);
        }
    }
}