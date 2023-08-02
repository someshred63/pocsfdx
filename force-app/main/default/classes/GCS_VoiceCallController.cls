public with sharing class GCS_VoiceCallController {

    @AuraEnabled
    public static List<Case> getCases(String contactId, String caseId){
        if(String.isNotBlank(contactId) || String.isNotBlank(caseId)){
            String query = 'SELECT Id,CaseNumber,Origin,Status,GCS_Inquiry__c,GCS_Inquiry_Subject__c,'+
                           'GCS_Comments__c,ContactId,Contact.Name,OwnerId,Owner.Name,CreatedDate '+
                           'FROM Case WHERE Id = :caseId ';
            if(String.isNotBlank(contactId)) query += 'OR ContactId = :contactId ';
            query += 'ORDER BY CreatedDate DESC';

            return Database.query(query);
        }
        else return new List<Case>();
    }

    @AuraEnabled
    public static Response getRecentCases(String voiceCallId){
        Response response = new Response();
        Set<Id> contactIds = new Set<Id>();
        
        if(String.isBlank(voiceCallId)) return response;

        List<VoiceCall> voiceCalls = [SELECT Id,CallerId,RecipientId,RelatedRecordId,ConversationId,CallType,
                                      Inquiry_Subject__c,Category_Action__c,Detail_Action__c,SR_Number__c,
                                      Escalation__c,Ship_Prior_To__c,Notes__c
                                      FROM VoiceCall WHERE Id = :voiceCallId];
        if(voiceCalls.isEmpty()) return response;

        VoiceCall vc = voiceCalls[0];
        response.voiceCall = vc;
        List<ConversationParticipant> cps = new List<ConversationParticipant>();
        if(vc.CallType == 'Inbound' || vc.CallType == 'Transfer')
        	cps = [SELECT Id,Name,ParticipantEntityId,ConversationId FROM ConversationParticipant 
                                             WHERE ConversationId = :vc.ConversationId AND Id = :vc.CallerId];
        else
            cps = [SELECT Id,Name,ParticipantEntityId,ConversationId FROM ConversationParticipant 
                                             WHERE ConversationId = :vc.ConversationId AND Id = :vc.RecipientId];

        if(!cps.isEmpty() && isContact(cps[0].ParticipantEntityId))
            response.contactId = ''+cps[0].ParticipantEntityId;
        
        if(String.isBlank(response.contactId) && isContact(vc.RelatedRecordId))
            response.contactId = ''+vc.RelatedRecordId;

        response.caseId = isCase(vc.RelatedRecordId) ? ''+vc.RelatedRecordId : '';

        response.cases = getCases(response.contactId, response.caseId);
        return response;
    }

    private static Boolean isContact(Id recordId){
        return String.isNotBlank(recordId) && Contact.sObjectType == recordId.getSobjectType();
    }

    private static Boolean isCase(Id recordId){
        return String.isNotBlank(recordId) && Case.sObjectType == recordId.getSobjectType();
    }
    
    @AuraEnabled
    public static String linkCaseToVoiceCall(String voiceCallId, String caseId){
        try{
            VoiceCall vc = new VoiceCall(Id=voiceCallId);
            vc.RelatedRecordId = caseId;
            update vc;
            return 'Success';
        }
        catch(Exception e){
            System.debug('Error*** '+e.getMessage()+' @ '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String createAndLinkCaseToVoiceCall(String voiceCallId){
        try{
            String contactId;
            List<VoiceCall> voiceCalls = [SELECT Id,CallerId,ConversationId,RelatedRecordId,Inquiry_Subject__c,Category_Action__c,
                                          Detail_Action__c,SR_Number__c,Escalation__c,Ship_Prior_To__c,Notes__c,Product__c
                                          FROM VoiceCall WHERE Id = :voiceCallId LIMIT 1];
            if(voiceCalls.isEmpty()) return 'Something went wrong, please try again.';

            VoiceCall vc = voiceCalls[0];
            if(String.isBlank(vc.Inquiry_Subject__c)) return 'Please complete Inquiry information before clicking "Create & Link a Case".';

            List<ConversationParticipant> cps = [SELECT Id,Name,ParticipantEntityId,ConversationId FROM ConversationParticipant 
                                                 WHERE ConversationId = :vc.ConversationId AND Id = :vc.CallerId];

            if(!cps.isEmpty() && isContact(cps[0].ParticipantEntityId))
                contactId = ''+cps[0].ParticipantEntityId;
            
            if(String.isBlank(contactId) && isContact(vc.RelatedRecordId))
                contactId = ''+vc.RelatedRecordId;

            Case c = new Case();
            c.RecordTypeId = Case.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('GCS_Case').getRecordTypeId();
            c.ContactId = contactId;
            c.Status = 'New';
            c.Origin = 'Phone';
            c.GCS_Inquiry_Subject__c = vc.Inquiry_Subject__c;
            c.GCS_Category_Action__c = vc.Category_Action__c;
            c.GCS_Detail_Action__c = vc.Detail_Action__c;
            c.GCS_OTN__c = vc.SR_Number__c;
            c.GCS_Escalation__c = vc.Escalation__c;
            c.GCS_Ship_Prior_To__c = vc.Ship_Prior_To__c;
            c.GCS_Comments__c = vc.Notes__c;
            c.GCS_Product__c = vc.Product__c;
            insert c;

            vc.RelatedRecordId = c.Id;
            update vc;
            
            return 'Success:-'+c.Id;
        }
        catch(Exception e){
            System.debug('Error*** '+e.getMessage()+' @ '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class Response{
        @AuraEnabled public List<Case> cases = new List<Case>();
        @AuraEnabled public VoiceCall voiceCall;
        @AuraEnabled public String contactId = '';
        @AuraEnabled public String caseId = '';
        //@AuraEnabled public String gcsCaseRTId = Case.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('GCS_Case').getRecordTypeId();
    }
    
    public void onBeforeUpdate(List<VoiceCall> voiceCallList){
        Map<Id, Id> callerIdMap = new Map<Id, Id>();       
        for(VoiceCall call:voiceCallList){
            if(call.CallType == 'Inbound' || call.CallType == 'Transfer')
            	callerIdMap.put(call.Id, call.CallerId);
            else
                callerIdMap.put(call.Id, call.RecipientId);
        }
        Map<Id, Id> ConversationPartContactMap = new Map<Id, Id>();
        for(ConversationParticipant cps: [SELECT Id,Name,ParticipantEntityId,ConversationId FROM ConversationParticipant 
                                          WHERE Id = :callerIdMap.values()]){
                 ConversationPartContactMap.put(cps.Id, cps.ParticipantEntityId);
        }
        
        Map<Id, Contact> contactMap =new Map<Id, Contact>([select id,name,phone,email,MailingPostalCode,AccountId,Account.Name,
                                   Account.GCS_SAP_Customer_ID__c,
                                   Account.GCS_Classification__c 
                                                           from contact where Id IN:ConversationPartContactMap.values() and recordType.DeveloperName='GCS_Contact']);
        if(!contactMap.isEmpty()) {
            for(VoiceCall call:voiceCallList){
                call.GCS_Account__c=contactMap.get(ConversationPartContactMap.get(callerIdMap.get(call.Id))).AccountId;
                call.GCS_Contact__c=contactMap.get(ConversationPartContactMap.get(callerIdMap.get(call.Id))).Id;
                call.Account_Name_VOC__c=contactMap.get(ConversationPartContactMap.get(callerIdMap.get(call.Id))).Account.Name;
                call.Contact_Name_VOC__c=contactMap.get(ConversationPartContactMap.get(callerIdMap.get(call.Id))).name;
               call.Contact_Email_VOC__c=contactMap.get(ConversationPartContactMap.get(callerIdMap.get(call.Id))).email;
                call.Contact_Id__c = contactMap.get(ConversationPartContactMap.get(callerIdMap.get(call.Id))).Id;
                call.Contact_Phone_VOC__c=contactMap.get(ConversationPartContactMap.get(callerIdMap.get(call.Id))).phone; 
                call.Mailing_Postal_Code_VOC__c=contactMap.get(ConversationPartContactMap.get(callerIdMap.get(call.Id))).MailingPostalCode; 
                call.SAP_Customer_Id_VOC__c=contactMap.get(ConversationPartContactMap.get(callerIdMap.get(call.Id))).Account.GCS_SAP_Customer_ID__c; 
                call.Account_Classification_VOC__c=contactMap.get(ConversationPartContactMap.get(callerIdMap.get(call.Id))).Account.GCS_Classification__c; 
            }
        }
      
    }
}