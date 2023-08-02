public class GNE_AP_Process_Buttons extends GNE_AP_Base_Class{
    
    /*remote method name to retrieve FM users*/
    public String getUsersMethodName {get; set;}
    public String accPlanStatus {get; set;}
    //list view or detail
    public String pageView {get; set;}
    public String dmReturnComments {get; set;}
    
    public PageReference dmSaveComments(){
        try{
            AP_Account_Planning_gne__c plan = new AP_Account_Planning_gne__c(id=accountPlanId);
            plan.DM_Comments_gne__c = dmReturnComments;
            update plan;            
        }catch (Exception ex){
            return GNE_AP_Util.redirectToErrorPage('DM return comments save failed!', Apexpages.currentPage().getUrl(), ex.getMessage());
        }        
        return null;
    }
    
    class EmailSender{
        public String fromEmail {get; set;}
        public String toEmail {get; set;}
        public String ccEmail {get; set;}
        public String bccEmail {get; set;}
        public String subject {get; set;}
        public String body {get; set;}
        public String attachmentName {get; set;}
    }
    
    @RemoteAction
    public static EmailSender getEmailSender(String accountPlanId){
        EmailSender emailSender = new EmailSender();
        emailSender.fromEmail = UserInfo.getUserEmail();
        
        AP_Account_Planning_gne__c currentAP = GNE_AP_DAO.getAccountPlan(accountPlanId);
        List <User> toEmails = [SELECT Email FROM User WHERE id = :currentAP.CS_User_gne__c LIMIT 1];
        List <User> ccEmails = [SELECT Email FROM User WHERE id = :currentAP.DM_User_gne__c LIMIT 1];
        if(toEmails.size()>0){
            emailSender.toEmail = toEmails.get(0).Email + ';';
        }
        if(ccEmails.size()>0){
            emailSender.ccEmail = ccEmails.get(0).Email + ';';
        }
        emailSender.subject = 'AP: '+currentAP.Name;
        emailSender.attachmentName = currentAP.Name.trim()+'.pdf';  
        return emailSender;
    }
    
    @RemoteAction
    public static List<User>getAvailableUsersToSharePlanWith(String accountPlanId, String searchTerm){
        List<Id>userIds = new List<Id>();
        for(User user : getUsersWithAlreadySharedPlan(accountPlanId)){
            userIds.add(user.Id);
        }
        Id dmUserId = [SELECT DM_User_gne__c FROM AP_Account_Planning_gne__c WHERE Id = :accountPlanId].DM_User_gne__c;
        userIds.add(dmUserId);
        if(String.isEmpty(searchTerm)){
            return [SELECT LastName, FirstName, Id, Name, Profile_Name_gne__c FROM User WHERE IsActive = true AND Id NOT IN :userIds AND (Profile_Name_gne__c LIKE 'GNE-TLS%' OR Profile_Name_gne__c LIKE 'gne-mcco%' OR Profile_Name_gne__c LIKE 'gne-sfa%') ORDER BY LastName LIMIT 100];
        }else{
            searchTerm += '%';
            return [SELECT LastName, FirstName, Id, Name, Profile_Name_gne__c FROM User WHERE IsActive = true AND Id NOT IN :userIds AND LastName LIKE :searchTerm AND (Profile_Name_gne__c LIKE 'GNE-TLS%' OR Profile_Name_gne__c LIKE 'gne-mcco%' OR Profile_Name_gne__c LIKE 'gne-sfa%') ORDER BY LastName LIMIT 100];
        }
    }
    
    @RemoteAction
    public static List<User>getUsersWithAlreadySharedPlan(String accountPlanId){
        Id dmUserId = [SELECT DM_User_gne__c FROM AP_Account_Planning_gne__c WHERE Id = :accountPlanId].DM_User_gne__c;
        Set<Id>userIds = new Set<Id>();
        for(AP_Account_Planning_gne__Share apShare : [SELECT UserOrGroupId FROM AP_Account_Planning_gne__Share WHERE ParentId = :accountPlanId AND RowCause = :Schema.AP_Account_Planning_gne__Share.RowCause.Manual]){
            if(apShare.UserOrGroupId != dmUserId && Schema.User.SObjectType == apShare.UserOrGroupId.getSobjectType()){
                userIds.add(apShare.UserOrGroupId);
            }
        }
        return [SELECT LastName, FirstName, Id, Name, Profile_Name_gne__c FROM User WHERE id IN :userIds ORDER BY LastName];
    }
    
    @RemoteAction
    public static void sharePlan(String accountPlanId, List<Id>users){
        system.debug(accountPlanId);
        system.debug(users);
        Set<Id>userIds = new Set<Id>(users);
        AP_Account_Planning_gne__c accountPlan = [SELECT Name, DM_User_gne__c FROM AP_Account_Planning_gne__c WHERE Id = :accountPlanId];
        List<AP_Account_Planning_gne__Share>sharingsToRemove = new List<AP_Account_Planning_gne__Share>();
        for(AP_Account_Planning_gne__Share apShare : [SELECT Id, UserOrGroupId FROM AP_Account_Planning_gne__Share WHERE ParentId = :accountPlanId AND RowCause = :Schema.AP_Account_Planning_gne__Share.RowCause.Manual]){
            if(Schema.User.SObjectType == apShare.UserOrGroupId.getSobjectType() && accountPlan.DM_User_gne__c != apShare.UserOrGroupId && !userIds.remove(apShare.UserOrGroupId)){
                sharingsToRemove.add(apShare); 
            }
        }
        system.debug(sharingsToRemove);
        delete sharingsToRemove;
                
        List<AP_Account_Planning_gne__Share>sharings = new List<AP_Account_Planning_gne__Share>();
        List<Messaging.SingleEmailMessage>messages = new List<Messaging.SingleEmailMessage>();
        for(Id userId: userIds){
            AP_Account_Planning_gne__Share apShare = new AP_Account_Planning_gne__Share();
            apShare.ParentId = accountPlanId;
            apShare.AccessLevel = 'Read';
            apShare.RowCause = Schema.AP_Account_Planning_gne__Share.RowCause.Manual;
            apShare.UserOrGroupId = userId;
            sharings.add(apShare);
            
        }
        List<String>toAddresses = new List<String>();
        
        for(User u: [SELECT Email FROM User WHERE Id in :users]){
            toAddresses.add(u.Email);
        }
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject('Account Plan '+ accountPlan.Name +' Shared');
        email.setPlainTextBody('Account Plan '+ accountPlan.Name +' was shared with you as of '+ System.today().format());
        email.setToAddresses(toAddresses);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        
        system.debug(sharings);
        insert sharings;
        system.debug(sharings);
    } 
    
    @RemoteAction
    public static List<User>getFMUsers(){
        return GNE_FCR_DAO.getAvailableFRs(UserInfo.getUserId());
    } 
    
    @RemoteAction
    public static List<String> searchEmail(String searchTerm) {
        String[] emails = searchTerm.split(';', 0);
        searchTerm = emails[emails.size()-1];
        searchTerm = String.escapeSingleQuotes(searchTerm)+'%';
        Set<String>result = new Set<String>();
        for(User user: Database.query('Select Email from User where Email like :searchTerm ORDER BY Email LIMIT 20')){
            result.add(user.Email);
        }
        List<String>sortedResult = new List<String>();
        Integer i = 0;
        for(String mail: result){
            if(++i>5){
                break;
            }
            sortedResult.add(mail);
        }
        sortedResult.sort();
        return sortedResult;
    }
    
    @RemoteAction
    public static void sendEmail(EmailSender sender, Id accountPlanId, Id csUserId){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses;
        if(String.isNotEmpty(sender.toEmail)){
            sender.toEmail = sender.toEmail.replaceAll('(\\s+)','');
            toAddresses = sender.toEmail.split(';', 0);  
        }
        String[] ccAddresses;
        if(sender.ccEmail != ''){
            sender.ccEmail = sender.ccEmail.replaceAll('(\\s+)','');
            ccAddresses = sender.ccEmail.split(';', 0);  
        }
        String[] bccAddresses;
        if(sender.bccEmail != ''){
            sender.bccEmail = sender.bccEmail.replaceAll('(\\s+)','');
            bccAddresses = sender.bccEmail.split(';', 0);
        }else{
            mail.setBccSender(false);
        }
        
        mail.setToAddresses(toAddresses);
        mail.setCcAddresses(ccAddresses);
        mail.setSubject(sender.subject);
        mail.setbccAddresses(bccAddresses);
        mail.setUseSignature(false);
        mail.setPlainTextBody(sender.body);
        PageReference pdf = Page.GNE_AP_Pdf_Report;        
        Blob pdfPreview = null;
        pdf.setRedirect(true);        
        pdf.getParameters().put('planId', accountPlanId);
        pdf.getParameters().put('csUserId', csUserId);
        

        pdfPreview = pdf.getContentAsPdf();
        
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(sender.attachmentName);
        efa.setInline(false);
        efa.setContentType('application/pdf');
        efa.Body = pdfPreview;
        
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    } 
    
    public String getAccountPlanName(){
        if (accountPlanId != null){
            return [SELECT Name FROM AP_Account_Planning_gne__c WHERE Id = :accountPlanId].Name;
        }
        return null;
    }
    
    @RemoteAction
    public static String getAccountPlanName(String accountPlanId){
        if (accountPlanId != null){
            return [SELECT Name FROM AP_Account_Planning_gne__c WHERE Id = :accountPlanId].Name;
        }
        return null;
    }
    
    public List<TerritoryWrapper> getAvailableTerritories(){
        List<TerritoryWrapper> result = new List<TerritoryWrapper>();
        for(Territory2 territory: GNE_AP_Util.getUserTerritories(UserInfo.getUserId())){
            result.add(new TerritoryWrapper(territory));
        }
        return result;
    }
    
    class TerritoryWrapper{
        public Id territoryId {get; set;}
        public String name {get; set;}
        
        public TerritoryWrapper(Territory2 terr){
            this.territoryId = terr.id;
            this.name = terr.name;
        }
    }
}