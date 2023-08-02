global with sharing class gFRS_SingleRunDeploymentBatch implements Database.Batchable<sObject>,Database.Stateful{

    global String csvText = 'Id,Name,OLD_Event_Project_type__c,OLD_Event_Project_sub_type__c,NEW_Event_Project_type__c,NEW_Event_Project_sub_type__c\n';

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = String.join(new String[] {
        'SELECT id, Name,Record_Type_Name__c, Event_Project_type__c, Event_Project_sub_type__c ',
        'FROM GFRS_Funding_Request__c ',
        'WHERE Record_Type_Name__c IN ', 
        '(\'HC Char\')',
        'AND Event_Project_type__c IN ',
        '(\'Financial Assistance\',',
        '\'Patient Services\',',
        '\'Patient Education\',',
        '\'Health Screenings\')'
        }, ' ');
        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        List<GFRS_Funding_Request__c> reqList = (List<GFRS_Funding_Request__c>)scope;
        List<GFRS_Funding_Request__c> reqToUpdate = new List<GFRS_Funding_Request__c>();
        for(GFRS_Funding_Request__c req : reqlist){

            //add old values to report csv
            this.csvText += '"'+req.Id+'","'+req.Name+'","'+req.Event_Project_type__c+'","'+req.Event_Project_sub_type__c+'"';

            //UPDATE HC Char
            if(req.Event_Project_type__c == 'Financial Assistance'){
                req.Event_Project_type__c = 'Patient Support';
                req.Event_Project_sub_type__c = 'Financial Assistance';
                reqToUpdate.add(req);
            }   
            else if(req.Event_Project_type__c == 'Patient Services'){
                req.Event_Project_type__c = 'Patient Support';
                req.Event_Project_sub_type__c = 'Patient Services (e.g., nutrition support, transportation)';
                reqToUpdate.add(req);
            }

            else if(req.Event_Project_type__c == 'Health Screenings'){
                req.Event_Project_type__c = 'Patient Support';
                req.Event_Project_sub_type__c = 'Health Screenings';
                reqToUpdate.add(req);
            }

           else if(req.Event_Project_type__c == 'Patient Education'){
                req.Event_Project_type__c = 'Patient and General Disease Education';
                reqToUpdate.add(req);
            }
           
            //add new values to report csv
            this.csvText += ',"'+req.Event_Project_type__c+'","'+req.Event_Project_sub_type__c+'"\n';
        }

        update reqToUpdate;

    }

    global void finish(Database.BatchableContext BC){

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
        String[] toAddresses = new String[] {'marcin.kowalik@contractors.roche.com'};
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('gFRS_SingleRunDeploymentBatch');
        mail.setSubject('gFRS_SingleRunDeploymentBatch Report: ');
        mail.setPlainTextBody('Execution of batch job is finished. CSV is Attached');
        blob csvBlob = Blob.valueOf(this.csvText);
        string attName = 'Historical Update Report.csv';
        att.setFileName(attName);
        att.setBody(csvBlob);
        mail.setFileAttachments(new Messaging.EmailFileAttachment[]{att});
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        
    }
}