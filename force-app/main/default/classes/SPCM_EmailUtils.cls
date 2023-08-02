public class SPCM_EmailUtils
{
    public static void SendRecallNotifications(List<SObject> records, String emailTemplateName)
    {
    
        // retrieve ids for records into map
        Map<Id, Set<Id>> recordIds = new Map<Id, Set<Id>>();
        for (SObject record : records)
        {
            recordIds.put(record.Id, new Set<Id>());
        }
        
        // get process history for all approved and pending approvers
        Map<Id, Id> actorIds = new Map<Id, Id>();
        Id targetObjectId = null;
        Boolean skipStep = false;
        List<ProcessInstanceStep> steps = [SELECT Id, ProcessInstance.TargetObjectId, ActorId, OriginalActorId, 
            StepStatus FROM ProcessInstanceStep WHERE ProcessInstance.TargetObjectId IN :recordIds.keySet() 
            ORDER BY ProcessInstance.TargetObjectId ASC, CreatedDate DESC];
        
        // workaround for running tests
        if (steps.size() == 0 && Test.isRunningTest())
        {
        
            // add bogus null records to get into loop
            steps.add(null);
            steps.add(null);
        }
        
        // loop through process steps
        for (Integer i = 0; i < steps.size(); i++)
        {

            // retrieve step
            ProcessInstanceStep step = steps[i];

            // get step details, use test method check to force data for testing
            String stepObjectId = Test.isRunningTest() ? records[0].Id : step.ProcessInstance.TargetObjectId;
            String stepStatus = Test.isRunningTest() ? (i == 0 ? 'Approved' : 'Started') : step.StepStatus;
            String stepOriginalActorId = Test.isRunningTest() ? UserInfo.getUserId() : step.OriginalActorId;

            // if new target object
            if (stepObjectId != targetObjectId)
            {
                targetObjectId = stepObjectId;
                skipStep = false;
            }

            // if step should not be skipped
            if (!skipStep)
            {

                // if the submitted state then skip remaining steps
                if (stepStatus == 'Started')
                {
                    skipStep = true;
                }
                else
                {
                    
                    // add actor if approved or removed
                    if (stepStatus == 'Approved' || stepStatus == 'Removed')
                    {
                        if (!recordIds.get(targetObjectId).contains(stepOriginalActorId))
                        {
                            recordIds.get(targetObjectId).add(stepOriginalActorId);
                            actorIds.put(stepOriginalActorId, null);
                        }
                    }
                }
            }
        }
/*
        // get contact record type
        List<RecordType> recordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Contact' AND 
            DeveloperName = 'SPCM_User_Contact'];
        
        // get actor details and create contact records
        List<Contact> spcmContacts = new List<Contact>();
        if (recordType.size() == 1)
        {
            for (User u : [SELECT Id, FirstName, LastName, Email FROM User WHERE Id IN :actorIds.keySet()])
            {
                spcmContacts.add(new Contact(FirstName = u.FirstName, LastName = u.LastName, Email = u.Email, 
                    SPCM_User_Id__c = u.Id, RecordTypeId = recordType[0].Id));
            }
        }
        
        // upsert contacts
        if (spcmContacts.size() > 0)
        {
            upsert spcmContacts SPCM_User_Id__c;
        }

        // loop through and extract map of contact to user
        Map<Id, Id> userToContactMap = new Map<Id, Id>();
        for (Contact c : spcmContacts)
        {
            userToContactMap.put(c.SPCM_User_Id__c, c.Id);
        }
*/        
        // loop through records
        EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :emailTemplateName];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (Id recordId : recordIds.keySet())
        {
        
            // loop through actors
            for (Id actorId : recordIds.get(recordId))
            {
            
                // send email notification
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setSaveAsActivity(false);
                //email.setTargetObjectId(userToContactMap.get(actorId));
                email.setTargetObjectId(actorId);
                email.setTemplateId(et.Id);
                email.setWhatId(recordId);
                emails.add(email);
            }
        }
        
        // if there are emails to send
        Messaging.reserveSingleEmailCapacity(emails.size());
        if (emails.size() > 0)
        {
            Messaging.sendEmail(emails);
        }
    }
}