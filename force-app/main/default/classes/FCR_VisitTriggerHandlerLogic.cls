public class FCR_VisitTriggerHandlerLogic {
    private static Boolean isSandbox;
    private static final String SECUREURL; 
    private static final String REQUEST_STATUS_OPENED   = 'Opened';
    private static final String REQUEST_STATUS_ACCEPTED = 'Accepted';
    private static final String EMPLO_TOOL              = 'employeetool';
    private static final String EMPLO_DEV_APP           = 'com.rochedev.EmployeeTool.dev';
    private static final String EMPLO_PROD_APP          = 'com.roche.ITFemployee';
    private static final String COACH_TOOL              = 'coachingtool';
    private static final String COACH_DEV_APP           = 'com.rochedev.CoachingTool.dev';
    private static final String COACH_PROD_APP          = 'com.roche.ITFcoach';
    private static final String APP_LINK                = 'https://{0}.page.link/?link={1}?id={2}&ibi={3}&ifl={1}?appType={4}';
    private static final String EMAIL_SUBJECT           = '{0} has initiated a {1} for {2}';
    private static final String EMAIL_BODY              = 'Dear {0} <BR/> {1} {2} has scheduled a {3} with you on {4}{5}. <BR/>'+
        'Please log into the In The Field app to find the details.'+
        '<BR/><BR/>To download the {7} edition for In The Field, please navigate to this  {6}. <BR/><BR/> Happy Coaching! ';
    
    static {
        isSandbox = isSandboxEnv();
        Id siteId = [SELECT Id FROM Site WHERE Name = 'FCR_App_Zone_Redirect' LIMIT 1].Id;
        SECUREURL = [SELECT Id, SecureUrl FROM SiteDetail WHERE DurableId = :siteId ].SecureUrl;
    }
          
    private static Boolean isSandboxEnv() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
   
    public static void createSharingsOnInsert(List<Visit_gne__c> scope) {
        List<Visit_gne__Share> visitShrs  = new List<Visit_gne__Share>();
        Set<Id> existingUserIds = new Set<Id>();
        Set<Id> csUserIds = new Set<Id>();

        for(Visit_gne__c record: scope) {
            if(record.Assigned_to_gne__c != null && !existingUserIds.contains(record.Assigned_to_gne__c)) {
                visitShrs.add(createSharingForUser(record.Id, record.Assigned_to_gne__c));
                existingUserIds.add(record.Assigned_to_gne__c);
            }
            if(record.Clinical_Specialist_gne__c != null && !existingUserIds.contains(record.Clinical_Specialist_gne__c)) {
                visitShrs.add(createSharingForUser(record.Id, record.Clinical_Specialist_gne__c));
                existingUserIds.add(record.Clinical_Specialist_gne__c);
                csUserIds.add(record.Clinical_Specialist_gne__c);
            }
            if(record.Proxy_Manager_gne__c != null && !existingUserIds.contains(record.Proxy_Manager_gne__c)) {
                visitShrs.add(createSharingForUser(record.Id, record.Proxy_Manager_gne__c));
                existingUserIds.add(record.Proxy_Manager_gne__c);
            }     
        }
        createSharingForPeepsManager(csUserIds, visitShrs, scope);        
        
        Database.SaveResult[] sr = Database.insert(visitShrs,false);
    }
    
    public static void sendNotification(List<Visit_gne__c> scope) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Set<String> unixIds = new Set<String>();
        List<Visit_gne__c > visitsToSendNotification = new List<Visit_gne__c >();
        try {
            for(Visit_gne__c v:scope) {            
                if(isRecordNeedNotification(v)) {
                    unixIds.add(v.Clinical_Specialist_By_UnixId__c);
                    unixIds.add(v.Assigned_to_UnixId__c);
                    visitsToSendNotification.add(v);
                }                      
            }    
            Map<String, FCR_Peep_gne__c> unixId2Peep = fetchPeepsByUnixId(unixIds);
            for(Visit_gne__c v:visitsToSendNotification) {
                emails.addAll(createEmails(v, unixId2Peep));
            }
            
            Messaging.sendEmail(emails);
            
        } catch (Exception ex){
            system.debug('Exception during send email :'+ex);
        }       
    }
    
    private static Map<String, FCR_Peep_gne__c> fetchPeepsByUnixId(Set<String> unixIds) {
        Map<String, FCR_Peep_gne__c> result = new Map<String, FCR_Peep_gne__c>();
        for(FCR_Peep_gne__c peep: [SELECT UserUnixId__c, Email_gne__c, Full_Name_gne__c FROM FCR_Peep_gne__c WHERE Email_gne__c != null AND UserUnixId__c IN : unixIds]) {
            result.put(peep.UserUnixId__c, peep);
        }
        
        return result;
    }
    
    private static Boolean isRecordNeedNotification(Visit_gne__c v) {        
        Visit_gne__c oldRecord;
        if(Trigger.isUpdate) {
            oldRecord = (Visit_gne__c)Trigger.oldMap.get(v.Id);
        }
        Boolean result = true;
        
        result &= (v.Request_Status_gne__c == REQUEST_STATUS_OPENED || v.Request_Status_gne__c == REQUEST_STATUS_ACCEPTED);
        result &= Trigger.isInsert || (Trigger.isUpdate && (oldRecord.Clinical_Specialist_By_UnixId__c != v.Clinical_Specialist_By_UnixId__c || oldRecord.Assigned_to_UnixId__c != v.Assigned_to_UnixId__c));
        
        return result;
    }
    
    private static Messaging.SingleEmailMessage[] createEmails(Visit_gne__c visit, Map<String, FCR_Peep_gne__c> unixId2Peep) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        if(visit.Assigned_to_UnixId__c != null && visit.Assigned_to_UnixId__c != visit.LastModifiedByUnixId__c) {
            FCR_Peep_gne__c peep = unixId2Peep.get( visit.Assigned_to_UnixId__c) != null ? unixId2Peep.get( visit.Assigned_to_UnixId__c) : null;
            FCR_Peep_gne__c emplo = unixId2Peep.get( visit.Clinical_Specialist_By_UnixId__c) != null ? unixId2Peep.get( visit.Clinical_Specialist_By_UnixId__c) : null;
            if(peep != null && emplo != null) emails.add(createEmail(visit, peep, emplo, 'Coach'));
        }
        if(visit.Clinical_Specialist_By_UnixId__c != null && visit.Clinical_Specialist_By_UnixId__c != visit.LastModifiedByUnixId__c) {
            FCR_Peep_gne__c peep = unixId2Peep.get( visit.Clinical_Specialist_By_UnixId__c) != null ? unixId2Peep.get( visit.Clinical_Specialist_By_UnixId__c) : null;
            FCR_Peep_gne__c manager = unixId2Peep.get( visit.Assigned_to_UnixId__c) != null ? unixId2Peep.get( visit.Assigned_to_UnixId__c) : null;    
            if(peep != null && manager != null) emails.add(createEmail(visit, peep, manager, 'Employee'));
        }

        return emails;
    }
    
    private static Messaging.SingleEmailMessage createEmail(Visit_gne__c visit, FCR_Peep_gne__c peep, FCR_Peep_gne__c requestor, String template) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        List<String> toAddr = new List<String>{peep.Email_gne__c};
        email.setToAddresses(toAddr);
        email.setSaveAsActivity(false);
        email.setSubject(createEmailSubject(visit, template, requestor));
        email.setHtmlBody(createEmailBody(visit, peep, requestor, template));

        return email;
    }

    private static String createEmailSubject(Visit_gne__c visit, String template, FCR_Peep_gne__c requestor) {
		String gmtDt = visit.Start_Date_gne__c.format('MM/dd/yyyy hh:mm a', String.valueOf(UserInfo.getTimeZone()));
        return String.format(EMAIL_SUBJECT, new List<String> {
            requestor.Full_Name_gne__c, visit.Visit_Type__c, gmtDt
        });
    }
    
    private static String createEmailBody(Visit_gne__c visit, FCR_Peep_gne__c peep, FCR_Peep_gne__c requestor, String template) {
        String emailBody = '';
        String c = template == 'Employee' ? 'Your Coach ' : '';
        String gmtDt = visit.Start_Date_gne__c.format('MM/dd/yyyy hh:mm a', String.valueOf(UserInfo.getTimeZone()));
        String link = generateLink(template, visit);
        String communicate = ( visit.Visit_Type__c == 'Check In' && visit.Type_gne__c != null) ? ' and would like to communicate via '+visit.Type_gne__c : '';

        emailBody += String.format(EMAIL_BODY, new List<String> {
            peep.Full_Name_gne__c, c,requestor.Full_Name_gne__c, visit.Visit_Type__c, gmtDt, communicate, ' <a href ="'+link+'" target="_blank" > link</a>' , template.toLowerCase()
        });
        return emailBody;      
    }    
    
    private static String generateLink(String template, Visit_gne__c visit) {
        String tool = template == 'Employee' ? EMPLO_TOOL : COACH_TOOL;
        String app = '';
        if(isSandbox) {
            app = template == 'Employee' ? EMPLO_DEV_APP : COACH_DEV_APP;
        } else {
            app = template == 'Employee' ? EMPLO_PROD_APP : COACH_PROD_APP;
        }

        String theLink = String.format(APP_LINK, new List<String> {
            tool, SECUREURL, visit.Id, app, template
        });
        
        return theLink;
    }
    
    
    public static void manageSharingOnUpdate(List<Visit_gne__c> scope, Map<Id, Visit_gne__c> oldMap) {
        List<Visit_gne__Share> visitShrsToInsert  = new List<Visit_gne__Share>();
        List<Visit_gne__Share> visitShrsToDel  = new List<Visit_gne__Share>();
        Set<Id> existingUserIds = new Set<Id>();
        
        for(Visit_gne__c record: scope) {
            Visit_gne__c oldRecord = oldMap.get(record.Id);
            
            if(oldRecord.Assigned_to_gne__c != record.Assigned_to_gne__c ) {
                if(record.Assigned_to_gne__c != null && !existingUserIds.contains(record.Assigned_to_gne__c)) {
                    visitShrsToInsert.add(createSharingForUser(record.Id, record.Assigned_to_gne__c));
                }     
            }
            if(record.Assigned_to_gne__c != null) existingUserIds.add(record.Assigned_to_gne__c );

            if(oldRecord.Clinical_Specialist_gne__c != record.Clinical_Specialist_gne__c ) {
                if(record.Clinical_Specialist_gne__c != null && !existingUserIds.contains(record.Clinical_Specialist_gne__c)) {
                    visitShrsToInsert.add(createSharingForUser(record.Id, record.Clinical_Specialist_gne__c));
                }
            }
            if(record.Clinical_Specialist_gne__c != null) existingUserIds.add(record.Clinical_Specialist_gne__c );
            
            if(oldRecord.Proxy_Manager_gne__c != record.Proxy_Manager_gne__c ) {
                if(record.Proxy_Manager_gne__c != null && !existingUserIds.contains(record.Proxy_Manager_gne__c)) {
                    visitShrsToInsert.add(createSharingForUser(record.Id, record.Proxy_Manager_gne__c));
                }
            }
            if(record.Proxy_Manager_gne__c != null) existingUserIds.add(record.Proxy_Manager_gne__c );
        }
        Database.SaveResult[] sr = Database.insert(visitShrsToInsert,false);

        delete [SELECT Id FROM Visit_gne__Share WHERE RowCause = :Schema.Visit_gne__Share.RowCause.Manual AND ParentId IN :scope AND UserOrGroupId NOT IN:existingUserIds];
    }
    
    private static void createSharingForPeepsManager(Set<Id> csUserIds, List<Visit_gne__Share> visitShrs, List<Visit_gne__c> scope) {
        Set<String> userUnixIds = new Set<String>();
        Map<String, String> userUnixId2managerUnixId = new Map<String, String>();
        Map<String, String> userUnixId2userId = new Map<String, String>();
        Map<String, String> userId2userUnixId = new Map<String, String>();
        for(User u :[SELECT External_Id_gne__c FROM User WHERE Id IN : csUserIds]) {
            userUnixIds.add(u.External_Id_gne__c);
        }
        for(FCR_Peep_gne__c peep: [
            SELECT UserUnixId__c, Manager_gne__c
            FROM FCR_Peep_gne__c 
            WHERE UserUnixId__c IN :userUnixIds
        ]) {
            userUnixId2managerUnixId.put(peep.UserUnixId__c, peep.Manager_gne__c);
        }
        for(User u :[SELECT Id, External_Id_gne__c FROM User WHERE External_Id_gne__c IN : userUnixId2managerUnixId.values() OR External_Id_gne__c IN :userUnixId2managerUnixId.keySet()]) {
            userUnixId2userId.put(u.External_Id_gne__c, u.Id);
            userId2userUnixId.put(u.Id, u.External_Id_gne__c);
        }
        for(Visit_gne__c record: scope) {
            if(record.Clinical_Specialist_gne__c != null) {
                String unix = userId2userUnixId.get(record.Clinical_Specialist_gne__c);
                String pmUnix = userUnixId2managerUnixId.get(unix);
                Id pmId = userUnixId2userId.get(pmUnix);
                visitShrs.add(createSharingForUser(record.Id, pmId, Schema.Visit_gne__Share.RowCause.Peep_Manager__c));
            }                      
        }
    }
    
    private static Visit_gne__Share createSharingForUser(Id recordId, Id userOrGroupId) {
        Visit_gne__Share ss = new Visit_gne__Share();
        ss.ParentId = recordId;
        ss.UserOrGroupId = userOrGroupId;
        ss.AccessLevel = 'edit';
        ss.RowCause = Schema.Visit_gne__Share.RowCause.Manual;

        return ss;
    }
    
    private static Visit_gne__Share createSharingForUser(Id recordId, Id userOrGroupId, String rowCause) {
        Visit_gne__Share ss = createSharingForUser(recordId, userOrGroupId);
        ss.RowCause = rowCause;

        return ss;
    }
}