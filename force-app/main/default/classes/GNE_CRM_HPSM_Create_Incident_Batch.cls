global class GNE_CRM_HPSM_Create_Incident_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    
    List<ErrorMessage> errorMessages;
    private Boolean runMultipleTimes = true;

    global GNE_CRM_HPSM_Create_Incident_Batch() {
        
    }

    global GNE_CRM_HPSM_Create_Incident_Batch(Boolean runMultipleTimes) {
        this.runMultipleTimes = runMultipleTimes;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        errorMessages = new List<ErrorMessage>();
        return Database.getQueryLocator('SELECT Id, Name, Closed_Date_gne__c, Details_gne__c, Device_Information_gne__c, Incident_Id_gne__c, Opened_Date_gne__c, Origin_gne__c, Phone_Number_gne__c, Priority_frm_gne__c, Priority_gne__c, Resolution_Code_gne__c, Resolution_gne__c, Resolved_Date_gne__c, Status_gne__c, Summary_gne__c, Unix_Id_frm_gne__c, Unix_Id_gne__c, Web_Browser_gne__c FROM GNE_CRM_HPSM_Incident__c WHERE Incident_Id_gne__c = null ORDER BY Unix_Id_gne__c');
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        try{
            List<GNE_CRM_HPSM_Incident__c> incidents = (List<GNE_CRM_HPSM_Incident__c>)scope;
            List<GNE_CRM_HPSM_Incident__c> toUpdate = new List<GNE_CRM_HPSM_Incident__c>();
            for(GNE_CRM_HPSM_Incident__c incident :incidents){
                try{
                    Map<String, String> params = GNE_SFA2_HPSMUtil.generateRequestParamsFromRecord(incident);
                    Map<String, String> result = (new GNE_SFA2_HPSMEngine()).executeHPSMRequest('DoCreateIncident', params)[0];
                    if(String.isNotBlank(result.get('returnIncidentId'))){
                        incident.Incident_Id_gne__c = result.get('returnIncidentId');
                        toUpdate.add(incident);
                    } else {
                        errorMessages.add(new ErrorMessage(result.get('errorCode'), result.get('description'), result.get('adapterTrackingId')));
                    }
                } catch(Exception ex){
                    errorMessages.add(new ErrorMessage(ex));
                }
            }
            update toUpdate;
        } catch(Exception ex){
            errorMessages.add(new ErrorMessage(ex));
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        if(this.runMultipleTimes) {
            GNE_Batch_Runner.scheduleBatchBasedOnSettings(
                    new GNE_CRM_HPSM_Create_Incident_Scheduler(),
                    'GNE_CRM_HPSM_Create_Incident', 'HPSM Create Incident');
        }

        if(errorMessages.size() > 0){
            String emailBody = 'Following errors occured during execution of GNE_CRM_HPSM_Create_Incident_Batch:<br/><table><tr><th style="padding:5px">No.</th><th style="padding:5px">Error Origin</th><th style="padding:5px">Error info</th><th style="padding:5px">HPSM Tracking Id</th><th style="padding:5px">SFDC Stacktrace</th></tr>';
            for(Integer i = 0; i < errorMessages.size(); i++){
                Integer rowNo = i + 1;
                emailBody += '<tr><td style="padding:5px">' + rowNo + '</td><td style="padding:5px">' + errorMessages[i].origin + '</td><td style="padding:5px">' + errorMessages[i].errorInfo + '</td><td style="padding:5px">' + errorMessages[i].trackingId + '</td><td style="padding:5px">' + errorMessages[i].stacktrace + '</td></tr>';
            }
            emailBody += '</table>';
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> toList = getToList();
            if(toList.size()>0){
                mail.setToAddresses(toList);
                mail.setSubject('HPSM insert errors');
                mail.setHTMLBody(emailBody);
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
            }
        }
    }

    private List<String> getToList(){
        //Map<String, GNE_SFA2_HPSM_Config__c> hpsmConfig = GNE_SFA2_HPSM_Config__c.getAll();
        List<String> toReturn = new List<String>();
        //try{
            //toReturn.addAll(hpsmConfig.get('IT Support').Configuration_Value_gne__c.split(';'));
        //} catch(Exception ex){

        //} 
        return toReturn;
    }

    public class ErrorMessage{
        public String origin {get; private set;}
        public String errorInfo {get; private set;}
        public String trackingId {get; private set;}
        public String stacktrace {get; private set;}

        public ErrorMessage(String errorCode, String errorMessage, String adapterTrackingId){
            this.origin = '[HPSM]';
            this.errorInfo = errorCode + ': ' + errorMessage;
            this.trackingId = adapterTrackingId;
            this.stacktrace = 'N/A';
        }

        public ErrorMessage(Exception ex){
            this.origin = '[SFDC]';
            this.errorInfo = ex.getMessage();
            this.trackingId = 'N/A';
            this.stacktrace = ex.getStackTraceString();
        }
    }

}