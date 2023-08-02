public class gFRS_Ltng_ScopeChangeEmailAlert {    
    public static  Map<Id, gFRS_Ltng_Task_Update__c> requestIdToTaskUpdate ;
    public static  Map<Id, List<gFRS_Ltng_Program__c>> requestIdToPrograms ;  
    public static  Map<Id, List<gFRS_Ltng_Task_Update__History>> requestIdToTaskUpdateHistory;
    public static  Map<Id, List<gFRS_Ltng_Program__History>> requestIdToProgramsHistory;    
    public static  set<Id> taskId;
    public static  set<Id> programsId;    
    @InvocableMethod(label='Send ScopeChange Email Notification')    
    
    public static void SendScopeChangeNotification(List<String> reqIds){        
        String[] VarIds;        
        for (integer i=0;i< reqIds.size(); i++) {
            string str= reqIds[i].replace('(','');
            str=str.replace('[','');
            str=str.replace(']','');
            str=str.replace(')','');
            VarIds = str.split(',');
        }        
        system.debug('@@@ VarIds'+VarIds);
        requestIdToTaskUpdate = new Map<Id, gFRS_Ltng_Task_Update__c>();
        requestIdToPrograms = new Map<Id, List<gFRS_Ltng_Program__c>>();
        requestIdToTaskUpdateHistory = new Map<Id, List<gFRS_Ltng_Task_Update__History>>();
        requestIdToProgramsHistory = new Map<Id, List<gFRS_Ltng_Program__History>>();
        taskId=new set<Id>();
        programsId=new set<Id>();
        for(gFRS_Ltng_Task_Update__c taskUpdate:[select Id,Name,gFRS_Application__r.Id from gFRS_Ltng_Task_Update__c where Name='Post Payment' and gFRS_Application__c=:VarIds]){
            if(requestIdToTaskUpdate.containsKey(taskUpdate.gFRS_Application__r.Id)){
                requestIdToTaskUpdate.put(taskUpdate.gFRS_Application__r.Id,taskUpdate);
            }else{
                requestIdToTaskUpdate.put(taskUpdate.gFRS_Application__r.Id, taskUpdate);
                taskId.add(taskUpdate.Id);
            }
        }
        for(gFRS_Ltng_Program__c programRec:[select Id,Name,gFRS_Application__r.Id from gFRS_Ltng_Program__c where gFRS_Application__c=:VarIds and LastModifiedDate >= TODAY AND LastModifiedDate < TOMORROW]){
            if(requestIdToPrograms.containsKey(programRec.gFRS_Application__r.Id)){
                requestIdToPrograms.get(programRec.gFRS_Application__r.Id).add(programRec);
            }else{
                requestIdToPrograms.put(programRec.gFRS_Application__r.Id, new List<gFRS_Ltng_Program__c>{programRec});
                programsId.add(programRec.Id);
            }
        }
        for(gFRS_Ltng_Task_Update__History taskHistoryRec:[select Id,field,newvalue,oldvalue,ParentId, Parent.Name,Parent.If_yes_did_the_educational_objective__c,Parent.If_yes_did_the_expected_outcomes__c from gFRS_Ltng_Task_Update__History where ParentId=:taskId and  CreatedDate>=TODAY]){
            if(requestIdToTaskUpdateHistory.containsKey(taskHistoryRec.ParentId)){
                requestIdToTaskUpdateHistory.get(taskHistoryRec.ParentId).add(taskHistoryRec);
            }else{
                requestIdToTaskUpdateHistory.put(taskHistoryRec.ParentId, new List<gFRS_Ltng_Task_Update__History>{taskHistoryRec});
            }
        }
        for(gFRS_Ltng_Program__History programHistoryRec:[select Id,field,newvalue,oldvalue,ParentId,Parent.Name from gFRS_Ltng_Program__History where ParentId=:programsId and CreatedDate>=TODAY ]){
            if(requestIdToProgramsHistory.containsKey(programHistoryRec.ParentId)){
                requestIdToProgramsHistory.get(programHistoryRec.ParentId).add(programHistoryRec);
            }else{
                requestIdToProgramsHistory.put(programHistoryRec.ParentId, new List<gFRS_Ltng_Program__History>{programHistoryRec});
            }
        }
        String bccEmailAddress='';
        GFRS_Ltng_OrgSettings__c myOrgCS = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
        if(myOrgCS.gFRS_Inbound_Email__c != null){
            bccEmailAddress=myOrgCS.gFRS_Inbound_Email__c;
        } 
        EmailTemplate sendTemplate = [SELECT Id, HtmlValue,subject,Body FROM EmailTemplate WHERE developerName = 'gFRS2_0Change_of_Scope_Notification_CME'];
    
        Id senderId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'fundingrequestsystem-donotreply-d@gene.com' LIMIT 1].id;
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        System.debug('### requestIdToTaskUpdate.values() : ' + requestIdToTaskUpdate.values());
        System.debug('### requestIdToPrograms.values() : ' + requestIdToPrograms.values());
        System.debug('### requestIdToTaskUpdateHistory.values() : ' + requestIdToTaskUpdateHistory.values());
        System.debug('### requestIdToProgramsHistory.values() : ' + requestIdToProgramsHistory.values());
        System.debug('### today : ' + system.now());
        System.debug('### taskId : ' + taskId);
        System.debug('### programsId : ' + programsId);
        
        for(gFRS_Ltng_Application__c app:[select id,name,Scope_Change_Date__c,Disease_State__c from gFRS_Ltng_Application__c where id=:VarIds]){
            mails.add( createRemainderEmail(app,senderId,sendTemplate));
        }
        try{
        Messaging.sendEmail(mails); 
        }
        catch (Exception e){
            system.debug('Exception' +e);
        }
    }
    public static Messaging.SingleEmailMessage createRemainderEmail(gFRS_Ltng_Application__c request,Id senderId,EmailTemplate template){
        String type1='gFRS_Ltng_Task_Update__c';
        String type2='gFRS_Ltng_Program__c';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema1 = schemaMap.get(type1);
        Schema.SObjectType leadSchema2 = schemaMap.get(type2);
        Map<String, Schema.SObjectField> fieldMap1 = leadSchema1.getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> fieldMap2 = leadSchema2.getDescribe().fields.getMap(); 
        
        String emailSub = template.Subject;
        String htmlText = template.HtmlValue;        
        String body;
        String requestHistoryrecords           = '';
        String programHistoryrecords           = '';
        body = template.body;
        htmlText=htmlText.replace(']]>','');
        if( request != null && requestIdToTaskUpdate.containsKey(request.Id)){
           gFRS_Ltng_Task_Update__c taskId=requestIdToTaskUpdate.get(request.Id);
            if(requestIdToTaskUpdateHistory.size() > 0){
                for(gFRS_Ltng_Task_Update__History taskHistory : requestIdToTaskUpdateHistory.get(taskId.Id)){
                    if(taskHistory.field=='If_yes_did_the_educational_objective__c' && taskHistory.Parent.If_yes_did_the_educational_objective__c!=Null){
                        requestHistoryrecords += 'Changed From:'+' '+fieldMap1.get(taskHistory.field).getDescribe().getLabel()+':'+' '+taskHistory.oldvalue+'\n\n';
                        requestHistoryrecords += 'Changed To:'+' '+fieldMap1.get(taskHistory.field).getDescribe().getLabel()+':'+' ' +taskHistory.Parent.If_yes_did_the_educational_objective__c+'\n\n';
                    } 
                    if(taskHistory.field=='If_yes_did_the_expected_outcomes__c' && taskHistory.Parent.If_yes_did_the_expected_outcomes__c!=Null){
                        requestHistoryrecords += 'Changed From:'+' '+fieldMap1.get(taskHistory.field).getDescribe().getLabel()+':'+' ' +taskHistory.oldvalue+'\n\n';
                        requestHistoryrecords += 'Changed To:'+' '+fieldMap1.get(taskHistory.field).getDescribe().getLabel()+':' +' '+taskHistory.Parent.If_yes_did_the_expected_outcomes__c+'\n\n';
                    }if((taskHistory.field!='If_yes_did_the_expected_outcomes__c' || taskHistory.field!='If_yes_did_the_educational_objective__c') && taskHistory.field!='created'){
                        requestHistoryrecords += 'Changed From:'+' '+fieldMap1.get(taskHistory.field).getDescribe().getLabel()+':' +' '+taskHistory.oldvalue+'\n\n';
                        requestHistoryrecords += 'Changed To:'+' '+fieldMap1.get(taskHistory.field).getDescribe().getLabel()+':'+' ' +taskHistory.newvalue+'\n\n';
                    }
                }
            }
        }
               
        if( request != null && requestIdToPrograms.containsKey(request.Id)){
            List<gFRS_Ltng_Program__c> programrecords=requestIdToPrograms.get(request.Id);
            for(gFRS_Ltng_Program__c programRec:requestIdToPrograms.get(request.Id)){ 
                 programHistoryrecords +='Program:'+programRec.Name +'\n';
                if(requestIdToProgramsHistory.get(programRec.Id).size() > 0){
                    for(gFRS_Ltng_Program__History programHistory : requestIdToProgramsHistory.get(programRec.Id)){ 
                        if(programHistory.field!='created'){
                            programHistoryrecords += 'Changed From:'+' '+fieldMap2.get(programHistory.field).getDescribe().getLabel()+':'+' ' +programHistory.oldvalue+'\n\n';
                            programHistoryrecords += 'Changed To:'+' '+fieldMap2.get(programHistory.field).getDescribe().getLabel()+':'+' ' +programHistory.newvalue+'\n\n';
                        }
                    }
                }
            }
        }
        string scopeChangeDate = string.valueOf(request.Scope_Change_Date__c);
        emailSub = emailSub.replace('{!gFRS_Ltng_Application__c.Name}', request.Name); 
        emailSub = emailSub.replace('{!gFRS_Ltng_Application__c.Disease_State__c}', request.Disease_State__c);
        body = body.replace('{!gFRS_Ltng_Application__c.Scope_Change_Date__c}', scopeChangeDate);        
        body = body.replace('{!gFRS_Ltng_Application__c.Name}', request.Name); 
        body = body.replace('<<Request>>', requestHistoryrecords);
        body = body.replace('<<Programs>>', programHistoryrecords);
        htmlText = htmlText.replace('{!gFRS_Ltng_Application__c.Scope_Change_Date__c}', scopeChangeDate);        
        htmlText = htmlText.replace('{!gFRS_Ltng_Application__c.Name}', request.Name); 
        htmlText = htmlText.replace('{Request}', requestHistoryrecords);
        htmlText = htmlText.replace('{Programs}', programHistoryrecords);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        List<string> emails = new List<String>();  
        List<string> bCCEmails = new List<String>();  
        emails.add(System.Label.gFRS2_0_IMED_ScopeChangeAddress);                
        if(senderId!=null){
            mail.setOrgWideEmailAddressId(senderId);
        }        
       mail.setToAddresses(emails);
       //mail.setHtmlBody(body);
       //mail.setPlainTextBody(body);       
       mail.setHtmlBody(htmlText);
       mail.setTreatBodiesAsTemplate(true);
       mail.setSubject(emailSub);
       mail.setSaveAsActivity(true);
        return mail;
        
    }
}