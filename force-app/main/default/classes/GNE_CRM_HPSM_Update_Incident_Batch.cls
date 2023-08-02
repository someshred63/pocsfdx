global class GNE_CRM_HPSM_Update_Incident_Batch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {

    List<ErrorMessage> errorMessages;
    //Map<String, GNE_SFA2_HPSM_Config__c> hpsmConfig;
    private Boolean runMultipleTimes = true;

    global GNE_CRM_HPSM_Update_Incident_Batch() {

    }

    global GNE_CRM_HPSM_Update_Incident_Batch(Boolean runMultipleTimes) {
        this.runMultipleTimes = runMultipleTimes;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        errorMessages = new List<ErrorMessage>();
        //hpsmConfig = GNE_SFA2_HPSM_Config__c.getAll();
        Set<String> unixIds = new Set<String>();
        for (GNE_CRM_HPSM_Incident__c incident : [SELECT Unix_Id_gne__c FROM GNE_CRM_HPSM_Incident__c WHERE Status_gne__c != 'Closed' AND Status_gne__c != 'Canceled' AND Incident_Id_gne__c != NULL ORDER BY Unix_Id_gne__c]) {
            unixIds.add(incident.Unix_Id_gne__c);
        }
        return Database.getQueryLocator('SELECT Id, External_Id_gne__c FROM User WHERE External_Id_gne__c IN :unixIds AND IsActive = true');
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<User> users = (List<User>) scope;
        Set<String> unixIds = new Set<String>();
        for (User u : users) {
            unixIds.add(u.External_ID_gne__c);
        }

        Map<String, GNE_CRM_HPSM_Incident__c> incidentIdToIncidentMap = new Map<String, GNE_CRM_HPSM_Incident__c>();
        for (GNE_CRM_HPSM_Incident__c incident : [SELECT Id, Closed_Date_gne__c, Details_gne__c, Incident_Id_gne__c, Opened_Date_gne__c, Priority_gne__c, Resolution_Code_gne__c, Resolution_gne__c, Resolved_Date_gne__c, Status_gne__c, Summary_gne__c, Unix_Id_gne__c FROM GNE_CRM_HPSM_Incident__c WHERE Status_gne__c != 'Closed' AND Incident_Id_gne__c != NULL AND Unix_Id_gne__c IN :unixIds ORDER BY Unix_Id_gne__c]) {
            incidentIdToIncidentMap.put(incident.Incident_Id_gne__c, incident);
        }
        Map<String, String> params = new Map<String, String>();
        //params.put('regId', String.valueOf(hpsmConfig.get('HPSMRegistrationId').Configuration_Value_gne__c));
        //params.put('tibcoUrl', String.valueOf(hpsmConfig.get('TibcoUrlForIncidents').Configuration_Value_gne__c));
        List<Map<String, String>> resultList = new List<Map<String, String>>();
        for (String unixId : unixIds) {
            try {
                params.put('unixId', unixId);
                List<Map<String, String>> resultPart = (new GNE_SFA2_HPSMEngine()).executeHPSMRequest('DoReadIncidents', params);
                if (resultPart.size() == 1 && String.isNotBlank(resultPart[0].get('errorCode'))) {
                    errorMessages.add(new ErrorMessage(resultPart[0].get('errorCode'), resultPart[0].get('description'), resultPart[0].get('adapterTrackingId'), unixId));
                } else {
                    resultList.addAll(resultPart);
                }
            } catch (Exception ex) {
                errorMessages.add(new ErrorMessage(ex, unixId));
            }
        }

        List<GNE_CRM_HPSM_Incident__c> incidentsToUpdate = new List<GNE_CRM_HPSM_Incident__c>();
        for (Map<String, String> incidentDetails : resultList) {
            if (incidentIdToIncidentMap.containsKey(incidentDetails.get('incidentId'))) {
                incidentsToUpdate.add(updateIncidentFromResult(incidentIdToIncidentMap.get(incidentDetails.get('incidentId')), incidentDetails));
            }
        }
        if (incidentsToUpdate.size() > 0) {
            try {
                update incidentsToUpdate;
            } catch (Exception ex) {
                errorMessages.add(new ErrorMessage(ex));
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        if(this.runMultipleTimes) {
            GNE_Batch_Runner.scheduleBatchBasedOnSettings(
                    new GNE_CRM_HPSM_Update_Incident_Scheduler(),
                    'GNE_CRM_HPSM_Update_Incident', 'HPSM Update Incident');
        }

        if (errorMessages.size() > 0) {
            String emailBody = 'Following errors occurred during execution of GNE_CRM_HPSM_Update_Incident_Batch:<br/><table><tr><th style="padding:5px">No.</th><th style="padding:5px">Error Origin</th><th style="padding:5px">Error info</th><th style="padding:5px">HPSM Tracking Id</th><th style="padding:5px">SFDC Stacktrace</th></tr>';
            for (Integer i = 0; i < errorMessages.size(); i++) {
                Integer rowNo = i + 1;
                emailBody += '<tr><td style="padding:5px">' + rowNo + '</td><td style="padding:5px">' + errorMessages[i].origin + '</td><td style="padding:5px">' + errorMessages[i].errorInfo + '</td><td style="padding:5px">' + errorMessages[i].trackingId + '</td><td style="padding:5px">' + errorMessages[i].stacktrace + '</td></tr>';
            }
            emailBody += '</table>';
            List<String> toList = new List<String>();
            try {
                //toList.addAll(hpsmConfig.get('IT Support').Configuration_Value_gne__c.split(';'));
            } catch (Exception ex) {
            }
            if (toList.size() > 0) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                mail.setToAddresses(toList);
                mail.setSubject('HPSM update errors');
                mail.setHtmlBody(emailBody);
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{
                        mail
                });
            }
        }
    }

    private GNE_CRM_HPSM_Incident__c updateIncidentFromResult(GNE_CRM_HPSM_Incident__c incident, Map<String, String> incidentDetails) {
        incident.Summary_gne__c = incidentDetails.get('title');
        incident.Details_gne__c = incidentDetails.get('description').replace('@|@', '\n');
        incident.Status_gne__c = getStatus(incidentDetails.get('status'));
        incident.Opened_Date_gne__c = parseDateTime(incidentDetails.get('opentime'));
        incident.Priority_gne__c = Integer.valueOf(incidentDetails.get('priority'));
        incident.Resolution_Code_gne__c = incidentDetails.get('solutionCode');
        if (String.isNotBlank(incidentDetails.get('solution'))) {
            incident.Resolution_gne__c = incidentDetails.get('solution').replace('@|@', '\n');
        }
        incident.Resolved_Date_gne__c = parseDateTime(incidentDetails.get('resolvedTime'));
        incident.Closed_Date_gne__c = parseDateTime(incidentDetails.get('closeTime'));
        return incident;
    }

    private String getStatus(String serviceNowStatus) {
        String status = serviceNowStatus;
        if (serviceNowStatus == '1') {
            status = 'New';
        } else if (serviceNowStatus == '2') {
            status = 'In Progress';
        } else if (serviceNowStatus == '3') {
            status = 'On Hold';
        } else if (serviceNowStatus == '6') {
            status = 'Resolved';
        } else if (serviceNowStatus == '7') {
            status = 'Closed';
        } else if (serviceNowStatus == '8') {
            status = 'Canceled';
        }
        return status;
    }

    private Datetime parseDateTime(String receivedDateStr) {
        if (String.isBlank(receivedDateStr)) {
            return null;
        }
        receivedDateStr = receivedDateStr.replace('T', ' ').replace('Z', '');
        Datetime dtgmt = Datetime.valueOfGmt(receivedDateStr);
        Datetime dtToReturn = Datetime.newInstance(dtgmt.date(), dtgmt.time());
        return dtToReturn;
    }

    public class ErrorMessage {
        public String origin { get; private set; }
        public String errorInfo { get; private set; }
        public String trackingId { get; private set; }
        public String stacktrace { get; private set; }
        public String unixId { get; private set; }

        public ErrorMessage(String errorCode, String errorMessage, String adapterTrackingId, String unixId) {
            this.origin = '[HPSM]';
            this.errorInfo = errorCode + ': ' + errorMessage;
            this.trackingId = adapterTrackingId;
            this.stacktrace = 'N/A';
            this.unixId = unixId;
        }

        public ErrorMessage(Exception ex, String unixId) {
            this.origin = '[SFDC]';
            this.errorInfo = ex.getMessage();
            this.trackingId = 'N/A';
            this.stacktrace = ex.getStackTraceString();
            this.unixId = unixId;
        }

        public ErrorMessage(Exception ex) {
            this.origin = '[SFDC]';
            this.errorInfo = ex.getMessage();
            this.trackingId = 'N/A';
            this.stacktrace = ex.getStackTraceString();
            this.unixId = 'N/A';
        }
    }
}