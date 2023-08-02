public class AGS_EX_Exclusion_Request_Detail_Ext{

    private AGS_EX_Exclusion_Request_gne__c excRequest;
    public AGS_EX_Exclusion_Check_gne__c excCheck{get;set;}
    public Attachment attachmentFile {get; set;}
    private String nameOfSavedFile;
    public String returnURL {get; set;}
    public String returnMessage {get; set;}
    public Boolean attchmentExist {get;set;}
    private Boolean sfdcMode = true;

    public List<AGS_EX_Exclusion_Requestor_gne__c> requestors {get; set;}
    public List<Affiliation_vod__c> affiliations {get; set;}
    public List<AGS_EX_Exclusion_Check_gne__c> mostRecentCheck {get; set;}

    public AGS_EX_Exclusion_Request_Detail_Ext(ApexPages.StandardController controller){
        this.excRequest = (AGS_EX_Exclusion_Request_gne__c)controller.getRecord();
        List<AGS_EX_Exclusion_Check_gne__c> existingExcCheck = [Select Id,AGS_EX_Comments_gne__c,AGS_EX_Status_gne__c,AGS_EX_Check_Date_gne__c,AGS_EX_Exclusion_Request_gne__c from AGS_EX_Exclusion_Check_gne__c where AGS_EX_Exclusion_Request_gne__c =:excRequest.Id];
        attachmentFile = new Attachment();
        attchmentExist = false;

        if(existingExcCheck.isEmpty()){
            excCheck = new AGS_EX_Exclusion_Check_gne__c();
            excCheck.AGS_EX_Exclusion_Request_gne__c = excRequest.Id;
            excCheck.AGS_EX_Reviewer_Name_gne__c = UserInfo.getUserId();
            excCheck.AGS_EX_Check_Date_gne__c = Date.today();
        } else {
               List<Attachment> existingAttachment = [select Body,BodyLength, ContentType, Id, Name from Attachment where ParentId =:existingExcCheck[0].Id];
               excCheck = existingExcCheck[0];
               if(existingAttachment.size() > 0){
                        attachmentFile = existingAttachment[0];
                        attchmentExist = true;
                }
        }
        

        requestors = [SELECT AGS_EX_Requestor_Name_gne__c, AGS_EX_Requestor_Email_gne__c, AGS_EX_Date_Of_Request_gne__c, AGS_EX_Exclusion_Request_gne__c 
                                                            FROM AGS_EX_Exclusion_Requestor_gne__c WHERE AGS_EX_Exclusion_Request_gne__c=:excRequest.Id];
        
        affiliations = [SELECT To_Account_vod__c, To_Contact_vod__c, Role_vod__c, CreatedById, CreatedDate FROM Affiliation_vod__c 
                                                                WHERE From_Account_vod__c = :excRequest.AGS_EX_Account_Name_gne__c];
        mostRecentCheck = [SELECT AGS_EX_Check_Date_gne__c, AGS_EX_Status_gne__c, AGS_EX_Reviewer_Name_gne__c, AGS_EX_Comments_gne__c, 
                                  AGS_EX_Check_Attachment_gne__c, AGS_EX_Exclusion_Request_gne__c, AGS_EX_Attachment_frm_gne__c 
                            FROM AGS_EX_Exclusion_Check_gne__c 
                            WHERE AGS_EX_Exclusion_Request_gne__r.AGS_EX_Account_Name_gne__c = :excRequest.AGS_EX_Account_Name_gne__c AND AGS_EX_Exclusion_Request_gne__r.AGS_EX_Request_Status_gne__c != 'In Progress'
                            ORDER BY AGS_EX_Check_Date_gne__c DESC, CreatedDate DESC LIMIT 1];
    }
    
    public List<CORE_Pub_License__c>getStateLicenses(){
    	Account account = [SELECT mdmid_gne__c FROM Account WHERE id = :excRequest.AGS_EX_Account_Name_gne__c];
    	return [SELECT Id, License_Number_gne__c, License_State_gne__c FROM CORE_Pub_License__c WHERE Party_Id_ref_gne__r.Mdm_Id_gne__c =:account.mdmId_gne__c];
    }
    
    public String getAccountId(){
        return excRequest.AGS_EX_Account_Name_gne__c;
    }

    public Boolean getIsAnyAffiliation(){
        if(affiliations.size()>0){
            return true;
        } 
        return false;
    }

    public Boolean getIsAnyRequestor(){
        if(requestors.size()>0){
            return true;
        }
        return false;
    }
    public Boolean getIsAnyMRC(){
        if(mostRecentCheck.size()>0){
            return true;
        }
        return false;
    }

    public List<SelectOption> getStatuses() {
        return AGS_EX_Exclusion_Utils.getPickListValues(AGS_EX_Exclusion_Check_gne__c.getSObjectType(), 'AGS_EX_Status_gne__c');
    }

    public static String insertCvAttachmentAndSaveURL(AGS_EX_Exclusion_Check_gne__c exlusionCheck, Attachment attachmentFile) {
        if (AGS_EX_Exclusion_Utils.insertAttachment(attachmentFile,exlusionCheck.Id)) {
            exlusionCheck.AGS_EX_Check_Attachment_gne__c = AGS_EX_Exclusion_Utils.prepareLinkToAttachment(attachmentFile);
            update exlusionCheck;

            return attachmentFile.name;
        }
        return '';
    }

    public PageReference saveExclusionCheck(){
        Attachment attachmentCVCopy;
        
        if(excCheck.AGS_EX_Status_gne__c == null) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select an exclusion status'));
                return ApexPages.currentPage();
        }
        System.debug('$$ attachmentFile' + attachmentFile);
        if(!attchmentExist && attachmentFile.Body != null) {
            attachmentCVCopy = attachmentFile; //copy attachmentCV to not exceeded viewstate when giving response
            attachmentFile = new Attachment();

            /*if(attachmentCVCopy == null || attachmentCVCopy.body == null) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please choose a file to upload'));
                return ApexPages.currentPage();
            }*/
        }
        if (Apexpages.hasMessages()) return ApexPages.currentPage();

        excRequest.AGS_EX_Request_Status_gne__c='Completed';

        List<Account> acc=[SELECT id,AGS_EX_Date_Checked_Exclusion_gne__c,AGS_EX_Exclusion_Status_base_gne__c 
                     FROM Account WHERE id=:excRequest.AGS_EX_Account_Name_gne__c];
        if(acc.size()>0){
            for(Account a : acc){
                a.AGS_EX_Date_Checked_Exclusion_gne__c=Date.today();
                if(excCheck.AGS_EX_Status_gne__c=='Excluded') {
                    a.AGS_EX_Exclusion_Status_base_gne__c=excCheck.AGS_EX_Status_gne__c;
                } else if(excCheck.AGS_EX_Status_gne__c=='Sanctioned but legal approved'){
                    a.AGS_EX_Exclusion_Status_base_gne__c='Sanctioned but legal approved';
                } else a.AGS_EX_Exclusion_Status_base_gne__c='Verified and clear';
        }
        update acc;
        }

        update excRequest;
        upsert excCheck;
        
        if(!attchmentExist && attachmentCVCopy != null && attachmentCVCopy.Body != null){
            nameOfSavedFile = insertCvAttachmentAndSaveURL(excCheck, attachmentCVCopy);
        }
        //prepareReturnMessage('Exclusion check has been submitted');
        //return null;
        //return AGS_EX_Exclusion_Utils.createPageRef('/'+excRequest.AGS_EX_Account_Name_gne__c);
        return goBack();
    }

    public PageReference saveExclusionCheckInProcess(){
        Attachment attachmentCVCopy = attachmentFile; //copy attachmentCV to not exceeded viewstate when giving response
        attachmentFile = new Attachment();

        excRequest.AGS_EX_Request_Status_gne__c='In Progress';

        List<Account> acc=[SELECT id,AGS_EX_Date_Checked_Exclusion_gne__c,AGS_EX_Exclusion_Status_base_gne__c 
                     FROM Account WHERE id=:excRequest.AGS_EX_Account_Name_gne__c];
        if(acc.size()>0){
            for(Account a : acc){
               // a.AGS_EX_Date_Checked_Exclusion_gne__c=Date.today();
                 a.AGS_EX_Exclusion_Status_base_gne__c='In Process';
        }
            update acc;
        }

        update excRequest;
        upsert excCheck;
        
        if(attachmentCVCopy != attachmentFile && attachmentCVCopy != null && attchmentExist == false) {

            nameOfSavedFile = insertCvAttachmentAndSaveURL(excCheck, attachmentCVCopy);
            if(nameOfSavedFile != null) {
                attchmentExist = true;
                attachmentFile = [Select BodyLength, ContentType, Id, Name from Attachment where ParentId =:excCheck.Id ];
            }
        } else if(attchmentExist == true) {

                attachmentFile = [Select BodyLength, ContentType, Id, Name from Attachment where ParentId =:excCheck.Id ];
        }
        return goBack();
    }
    public PageReference deleteAttachment(){

        try{
            delete attachmentFile;
            attchmentExist = false;
            attachmentFile = new Attachment();
        } catch(Exception e) {


        }
        
        return null;
    }
    public PageReference cancelExclusionCheck(){
        return AGS_EX_Exclusion_Utils.createPageRef(AGS_EX_Exclusion_Utils.getReturnURL(excRequest.Id));
    }

    private void prepareReturnMessage(String returnMessage) {
        this.returnMessage = returnMessage;
        if (sfdcMode) {
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.INFO, returnMessage));
        }
        returnURL = getReturnURL();
    }

    private String getReturnURL() {
        return AGS_EX_Exclusion_Utils.getReturnURL(excRequest.AGS_EX_Account_Name_gne__c);
    }

    public PageReference goBack() {
        PageReference pr;
        String retURL = ApexPages.currentPage().getParameters().get('retURL');
        if (!String.isBlank(retURL)) {
            pr = new PageReference(retURL);
            pr.setRedirect(true);
        }
        else {
            pr = new PageReference('/apex/AGS_EX_Exclusion_Req_List');
            pr.setRedirect(true);
        }
        return pr;
    }
}