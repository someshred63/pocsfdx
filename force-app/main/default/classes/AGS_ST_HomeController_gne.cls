global without sharing class AGS_ST_HomeController_gne {
    public String didYouKnow                { get; set; }
    public PageReference loadDyk() {
        didYouKnow = AGS_ST_DbUtils.getDidYouKnowText();
        return null;
    }
    public String toolTips {
        get {
            List<AGS_ST_FAQ_DYK_gne__c> toolTipsList = [SELECT ToolTip_Subject_gne__c, ToolTip_Text_gne__c, ToolTip_Type_gne__c FROM AGS_ST_FAQ_DYK_gne__c WHERE Type_gne__c='ToolTip'];
            return JSON.serialize(toolTipsList);
        }
        set;
    }
    public Boolean showCmsPaymentId {
        get {
            AGS_ST_Settings_gne__c agsStSet = AGS_ST_Utils.getDefaultCustomSettings();
            if(agsStSet != null && agsStSet.CmsPaymentIdDisplayDate_gne__c != null) {
                Date displayDate = agsStSet.CmsPaymentIdDisplayDate_gne__c;
                Date currentDate = Date.today();
                if(displayDate <= currentDate) {
                    return true;
                }
            }
            return false;
        }
    }
    public static AGS_ST_Settings_gne__c stSettingPub { 
        get {
            if(Site.getDomain()!=null)
                return AGS_ST_Utils.getCustomSettingsInSite();
            else
                return AGS_ST_Utils.getCustomSettings();
        }
        private set;
    } 
    global static AGS_ST_User_gne__c stUser {
        get {
            return AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId());
        }
        set;
    }

    public String getCurrentUserName() {
        return UserInfo.getName();
    }
    
    public PageReference loadTcAction() {
        if(stUser.isTCaccepted__c)
        {
            PageReference pr = Page.AGS_ST_Home_gne;
            pr.setRedirect(true);
            return pr;
        }
        return null;
    }
    
    public PageReference goToLoginPage() {
        PageReference pr = new PageReference('/AGS_ST_Login_gne');
        pr.setRedirect(true);
        return pr;
    }
    
    public PageReference acceptTcAction() {
        AGS_ST_User_gne__c st = AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId());
        st.isTCaccepted__c = true;
        update st;
        system.debug('-----stUser'+stUser);
        PageReference pr = new PageReference('/apex/AGS_ST_Home_gne');
        pr.setRedirect(true);
        return pr;
    }
    
    public PageReference goToHomePage() {
        PageReference pr = new PageReference('/apex/AGS_ST_Home_gne');
        pr.setRedirect(true);
        return pr;              
    }
    
    public PageReference goToAccountSettings() {
        PageReference pr = new PageReference('/apex/AGS_ST_ChangeUserData_gne');
        pr.setRedirect(true);
        return pr;              
    }
    
    public PageReference sysLogout() {
        PageReference pr = new PageReference(Site.getPrefix() + '/secur/logout.jsp');
        pr.setRedirect(true);
        return pr;
    }
    
    public static String removeLastComma(String stringToRemove) {
        return stringToRemove.substringBeforeLast(',');
    }
    
    public static void updateStUserWithFilter(Boolean researchPayment, Boolean isDateFilterApply, Boolean isAmountFilterApply, String dateFrom, String dateTo, Decimal dateRangeDays, String amount) {
        AGS_ST_User_gne__c st = AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId());
        if(researchPayment == true && isDateFilterApply) {
            st.Research_Spends_Date_From_gne__c = dateFrom;
            st.Research_Spends_Date_Range_gne__c = dateRangeDays;
            st.Research_Spends_Date_To_gne__c = dateTo;         
        } else if(isDateFilterApply) {
            st.Filter_date_from_gne__c = dateFrom;
            st.Filter_date_to_gne__c = dateTo;
            st.Filter_date_range_gne__c = dateRangeDays;
        }
        if(researchPayment == true && isAmountFilterApply) {
            st.Research_Spends_Filter_Amount_gne__c = amount;
        } else if(isAmountFilterApply) {
            st.Filter_amount__c = amount;
        }
        update st;
    }
    
    public static String getHistoryDescription(AGS_ST_DisputeManagement_gne__History disputeHistory) {
        String histTxt; 
        if(disputeHistory.Field == 'created')
        {
            histTxt = 'Disputed on ' + disputeHistory.CreatedDate.format('MMM d yyyy HH:mm:ss') + ' (Case: '+ disputeHistory.Parent.Name+')';
        }
        else if(disputeHistory.Field == 'External_Status_gne__c')
        {
            histTxt = 'Status changed to '+disputeHistory.NewValue + ' on ' + disputeHistory.CreatedDate.format('MMM d yyyy HH:mm:ss');
        }
        else
        {
            return null;
        }
        return histTxt;
    }
    
    global static List<String> getMethods() {
        Schema.DescribeFieldResult fieldResult = AGS_ST_DisputeManagement_gne__c.Form_Of_Payment_gne__c.getDescribe();
        List<String> result = new List<String>();
        for(Schema.Picklistentry p : fieldResult.getPicklistValues()) {
        	if(!'UNCLASSIFIED'.equals(p.getValue()))
            	result.add(p.getValue());
        }
        result.sort();
        return result;
    }
    
    global static List<String> getReasons() {
        Schema.DescribeFieldResult fieldResult = AGS_ST_DisputeManagement_gne__c.Nature_Of_Payment_gne__c.getDescribe();
        List<String> result = new List<String>();
        for(Schema.Picklistentry p : fieldResult.getPicklistValues()) {
            if(!'UNCLASSIFIED'.equals(p.getValue()))
            	result.add(p.getValue());
        }
        result.sort();
        return result;
    }
    
    global static List<String> getBrands() {
        List<String> result = new List<String>(); 
        for(AGS_Brand_gne__c brand : [SELECT Brand_Name__c FROM AGS_Brand_gne__c])
        {
            result.add(brand.Brand_Name__c);
        }
        result.sort();
        return result;
    }
    
    @RemoteAction
    global static AGS_ST_SpendSearch_Utils_gne.NonResearchPaymentsData getSpendTransactions(Boolean isFirstCall,Boolean isDateFilterApply, Boolean isAmountFilterApply, Boolean isYearFilterApply, String dateFrom, String dateTo,String amountFrom,List<String> status, List<String> method, List<String> reason, List<String> brand,Boolean getBookmarked,Boolean getNewest, Decimal dateRangeDays, String cmsPaymentId) {
        return AGS_ST_SpendSearch_Utils_gne.getNonResearchSpends(isFirstCall,isDateFilterApply,isAmountFilterApply,isYearFilterApply,dateFrom,dateTo,amountFrom,status,method, reason, brand,getBookmarked,getNewest,dateRangeDays,cmsPaymentId);
        //return getSpends(isFirstCall,isDateFilterApply,isAmountFilterApply,dateFrom,dateTo,amountFrom,status,method, reason, brand,getBookmarked,getNewest,dateRangeDays);
    }
    
    @RemoteAction
    global static AGS_ST_SpendSearch_Utils_gne.ResearchPaymentsData getResearchSpendTransactions(Boolean isFirstCall,Boolean isDateFilterApply, Boolean isAmountFilterApply,  Boolean isYearFilterApply, String dateFrom, String dateTo,String amountFrom,List<String> status, List<String> brand,Boolean getBookmarked,Boolean getNewest, Decimal dateRangeDays, String cmsPaymentId) {
        return AGS_ST_SpendSearch_Utils_gne.getResearchSpends(isFirstCall,isDateFilterApply,isAmountFilterApply,isYearFilterApply,dateFrom,dateTo,amountFrom,status, brand,getBookmarked,getNewest,dateRangeDays,cmsPaymentId);
        //return getResearchSpends(isFirstCall,isDateFilterApply,isAmountFilterApply,dateFrom,dateTo,amountFrom,status, brand,getBookmarked,getNewest,dateRangeDays);
    }
    
    @RemoteAction
    global static String saveBookmark(String spendId) {
        try
        {
            system.debug('-----'+spendId);
            AGS_ST_Expense_Bookmark__c bookmark = new AGS_ST_Expense_Bookmark__c(Bookmarked_User_gne__c=UserInfo.getUserId(),AGS_Spend_Expense_Transaction__c=spendId);
            insert bookmark;
            return 'Success';
        }
        catch(Exception e)
        {
            AGS_ST_Utils.logException(AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId()).id,'Dispute Tool','AGS_ST_HomeController_gne',e, 'saveBookmark');
            return e.getMessage();
        }
    }
    
    @RemoteAction
    global static String removeBookmark(String spendId) {
        try
        {
            system.debug('-----'+spendId);
            AGS_ST_Expense_Bookmark__c bookmark = [select id from AGS_ST_Expense_Bookmark__c where AGS_Spend_Expense_Transaction__c=:spendId and Bookmarked_User_gne__c=:UserInfo.getUserId()];
            delete bookmark;
            return 'Success';
        }
        catch(Exception e)
        {
            AGS_ST_Utils.logException(AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId()).id,'Dispute Tool','AGS_ST_HomeController_gne',e, 'removeBookmark');
            return e.getMessage();
        }
    }
    
    @RemoteAction
    global static DisputeCommunication getCommunications() {
        DisputeCommunication dc = new DisputeCommunication();
        List<AGS_ST_User_gne__c> dispUsr = [select Dispute_Contact_preferences_gne__c, Email_address__c, Phone_number__c,Phone_number_ext__c from AGS_ST_User_gne__c where SFDC_User__c=:UserInfo.getUserId()];
        dc.dispEmail = dispUsr[0].Email_address__c;
        if(dispUsr[0].Phone_number__c != null && dispUsr[0].Phone_number__c != '')
        {
            dc.dispPhone = dispUsr[0].Phone_number__c;
        }
        else if(dispUsr[0].Phone_number_ext__c != null && dispUsr[0].Phone_number_ext__c != '')
        {
            dc.dispPhone = dispUsr[0].Phone_number_ext__c;
        }
        
        dc.dispMethod = dispUsr[0].Dispute_Contact_preferences_gne__c;
        return dc;
    }
    
    @RemoteAction
    global static DisputeCreationResult saveDispute(String spendId,String amount,String method,String reason,String brand,String hcpNote,String communicationMethod, String communication, Boolean saveSetting) {
        try
        {
            AGS_Spend_Expense_Transaction_gne__c spend = [SELECT Form_Of_Payment_gne__c, Nature_Of_Payment_gne__c, id, Allocated_Transaction_Amount_gne__c, Event_Date_gne__c,
                                                                (select AGS_Brand_gne__r.Brand_Name__c from AGS_expense_products_intercations1__r)
                                                                FROM AGS_Spend_Expense_Transaction_gne__c where id =:spendId];
            DisputeCreationResult dcr = new DisputeCreationResult();
            List<AGS_ST_DisputeManagement_gne__c> externalDisputes = [select id from AGS_ST_DisputeManagement_gne__c where AGS_Spend_Expense_Transaction_gne__c=:spendId and External_Status_gne__c='In Progress' and isPrivate__c=false];
            if(externalDisputes.size() > 0)
            {
                dcr.errorMessage = 'Please note there is another dispute created on this payment that is set to In Progress.';
                return dcr;
            }
            String orgBrands = '';
            for(AGS_Expense_Products_Interaction__c spendBrand:spend.AGS_expense_products_intercations1__r)
            {
                orgBrands += spendBrand.AGS_Brand_gne__r.Brand_Name__c + ',';
            }
            orgBrands = removeLastComma(orgBrands);
            
            AGS_ST_Dispute_List_gne__c disputeList = new AGS_ST_Dispute_List_gne__c();
            disputeList.AGS_Spend_Expense_Transaction_gne__c = spendId; 
            disputeList.Dispute_Date_gne__c  = DateTime.Now();  
            disputeList.Payment_Date_gne__c = Date.Today(); 
            AGS_ST_DisputeManagement_gne__c dispute = new AGS_ST_DisputeManagement_gne__c();
            dispute.AGS_Spend_Expense_Transaction_gne__c = spendId;
            dispute.Dispute_Date_gne__c = DateTime.Now();
            dispute.Payment_Date_gne__c = Date.Today(); 
            if(amount != '' && amount != null)
            {
                disputeList.Amount_gne__c = Decimal.valueOf(amount);  
                dispute.Amount_gne__c = Decimal.valueOf(amount);
                disputeList.isAmountDisputed_gne__c = true;
            }
            else
            {
                disputeList.Amount_gne__c = spend.Allocated_Transaction_Amount_gne__c;
                dispute.Amount_gne__c = spend.Allocated_Transaction_Amount_gne__c;
            }
            if(brand != '' && brand != null)
            {
                disputeList.Drug_Name_gne__c  = brand; 
                dispute.Drug_Name_gne__c  = brand; 
                disputeList.isBrandDisputed_gne__c = true;
            }
            else
            {
                disputeList.Drug_Name_gne__c  = orgBrands;
                dispute.Drug_Name_gne__c  = orgBrands;
            }
            if(method != '' && method != null)
            {
                disputeList.Form_Of_Payment_gne__c  = method;   
                dispute.Form_Of_Payment_gne__c  = method;
                disputeList.isFormDisputed_gne__c = true;
            }
            else
            {
                disputeList.Form_Of_Payment_gne__c  = spend.Form_Of_Payment_gne__c;   
                dispute.Form_Of_Payment_gne__c  = spend.Form_Of_Payment_gne__c; 
            }
            if(reason != '' && reason != null)
            {
                disputeList.Nature_Of_Payment_gne__c  = reason;  
                dispute.Nature_Of_Payment_gne__c  = reason; 
                disputeList.isNatureDisputed_gne__c = true;
            }
            else
            {
                disputeList.Nature_Of_Payment_gne__c = spend.Nature_Of_Payment_gne__c;
                dispute.Nature_Of_Payment_gne__c = spend.Nature_Of_Payment_gne__c;
            }
            insert disputeList;
            dispute.Internal_Status_gne__c = 'Submitted';
            dispute.Dispute_List_gne__c = disputeList.id;
            dispute.Preferred_communication_method_gne__c = communicationMethod;
            dispute.Preferred_communication_value_gne__c = communication;
            insert dispute;
            AGS_ST_User_gne__c sunshineUser = AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId());
            if(saveSetting)
            {
                if(communicationMethod == 'Phone')
                {
                    sunshineUser.Phone_number__c = communication;
                }
                else if(communicationMethod == 'Email')
                {
                    sunshineUser.Email_address__c = communication;
                }
                sunshineUser.Dispute_Contact_preferences_gne__c = communicationMethod;
                update sunshineUser;
            }
            system.debug('---'+dispute);
            //if(hcpNote != '')    
            //{
                saveDisputeNotesFromDisputeId(dispute.id,hcpNote);
            //}
            AGS_ST_DisputeManagement_gne__c disputed = [select Name,CreatedDate from AGS_ST_DisputeManagement_gne__c where id=:dispute.id];
            dcr.disputeName = disputed.Name;
            dcr.disputeCreationDate = disputed.CreatedDate.format('MMM d yyyy HH:mm:ss') ;
            
            AGS_ST_MailUtil.sendSaveDisputeEmail(sunshineUser, disputed.Name, amount, method, reason, brand, null);
            /*String hcpName = sunshineUser.First_name__c + ' ' + sunshineUser.Last_name__c;
            String body = '<p>Dear Dr. '+hcpName+',</p>';
            body += '<p></p>';
            body += '<p>We have received the following dispute submitted by you and the Sunshine Track team is looking into it.</p>';
            body += '<p></p>';
            body += '<p>Dispute ID: '+disputed.Name+'</p>';
            body += '<p>Include Dispute Details:</p>';
            body += '<p>Amount:'+amount+'</p>';
            body += '<p>Method:'+method+'</p>';
            body += '<p>Reason:'+reason+'</p>';
            body += '<p>Brand:'+brand+'</p>';
            body += '<p></p>';
            body += '<p>Please reach out to us at <CCO contact details>,  if you have any questions.</p>';
            body += '<p></p>';
            body += '<p>Thanks,</p>';
            body += '<p>Customer Services Team</p>';
            body += '<p>Sunshine Track</p>';
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddress = new String[] {sunshineUser.Email_address__c};
            mail.setToAddresses(toAddress);
            mail.setSenderDisplayName('Genentech Sunshine Track Support');
            mail.setSubject('Dispute of Payment has been received - Dispute ID ' + disputed.Name);
            mail.setHtmlBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});*/
            return dcr;
        }
        catch(Exception e)
        {
            AGS_ST_Utils.logException(AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId()).id,'Dispute Tool','AGS_ST_HomeController_gne',e, 'saveDispute');
            DisputeCreationResult dcr = new DisputeCreationResult();
            dcr.errorMessage = e.getMessage();
            return dcr;
        }
    }
    
    @RemoteAction
    global static DisputeCreationResult saveResearchDispute(String spendId,String hcpNote,String communicationMethod, String communication, Boolean saveSetting) {
        try
        {
            AGS_Spend_Expense_Transaction_gne__c spend = [SELECT Form_Of_Payment_gne__c,Brands_gne__c,Nature_Of_Payment_gne__c,id,Allocated_Transaction_Amount_gne__c,Event_Date_gne__c FROM AGS_Spend_Expense_Transaction_gne__c where id =:spendId];
            DisputeCreationResult dcr = new DisputeCreationResult();
            List<AGS_ST_DisputeManagement_gne__c> externalDisputes = [select id from AGS_ST_DisputeManagement_gne__c where AGS_Spend_Expense_Transaction_gne__c=:spendId and External_Status_gne__c='In Progress' and isPrivate__c=false];
            if(externalDisputes.size() > 0) {
                dcr.errorMessage = 'Please note there is another dispute created on this payment that is set to In Progress.';
                return dcr;
            }
            
            AGS_ST_Dispute_List_gne__c disputeList = new AGS_ST_Dispute_List_gne__c();
            disputeList.AGS_Spend_Expense_Transaction_gne__c = spendId; 
            disputeList.Dispute_Date_gne__c  = DateTime.Now();  
            disputeList.Payment_Date_gne__c = Date.Today(); 
            AGS_ST_DisputeManagement_gne__c dispute = new AGS_ST_DisputeManagement_gne__c();
            dispute.AGS_Spend_Expense_Transaction_gne__c = spendId;
            dispute.Dispute_Date_gne__c = DateTime.Now();
            dispute.Payment_Date_gne__c = Date.Today(); 
            // amount
            disputeList.Amount_gne__c = spend.Allocated_Transaction_Amount_gne__c;
            dispute.Amount_gne__c = spend.Allocated_Transaction_Amount_gne__c;
            // brands
            String brands = (spend.Brands_gne__c != null) ? spend.Brands_gne__c.replace(', ', ',') : null;
            disputeList.Drug_Name_gne__c  = brands; //spend.Brands_gne__c;
            dispute.Drug_Name_gne__c  = brands; // spend.Brands_gne__c;
            // method
            disputeList.Form_Of_Payment_gne__c  = spend.Form_Of_Payment_gne__c;   
            dispute.Form_Of_Payment_gne__c  = spend.Form_Of_Payment_gne__c; 
            // reason
            disputeList.Nature_Of_Payment_gne__c = spend.Nature_Of_Payment_gne__c;
            dispute.Nature_Of_Payment_gne__c = spend.Nature_Of_Payment_gne__c;
            
            insert disputeList;
            dispute.Internal_Status_gne__c = 'Submitted';
            dispute.Dispute_List_gne__c = disputeList.id;
            dispute.Preferred_communication_method_gne__c = communicationMethod;
            dispute.Preferred_communication_value_gne__c = communication;
            insert dispute;
            AGS_ST_User_gne__c sunshineUser = AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId());
            if(saveSetting) {
                if(communicationMethod == 'Phone') {
                    sunshineUser.Phone_number__c = communication;
                }
                else if(communicationMethod == 'Email') {
                    sunshineUser.Email_address__c = communication;
                }
                sunshineUser.Dispute_Contact_preferences_gne__c = communicationMethod;
                update sunshineUser;
            }
            //if(hcpNote != '') {
                // save note and send email 
                saveDisputeNotesFromDisputeId(dispute.id,hcpNote);
            //}
            AGS_ST_DisputeManagement_gne__c disputed = [select Name,CreatedDate from AGS_ST_DisputeManagement_gne__c where id=:dispute.id];
            dcr.disputeName = disputed.Name;
            dcr.disputeCreationDate = disputed.CreatedDate.format('MMM d yyyy HH:mm:ss') ;
            
            AGS_ST_MailUtil.sendSaveDisputeEmail(sunshineUser, disputed.Name, null, null, null, null, hcpNote);
            return dcr;
        }
        catch(Exception e) {
            AGS_ST_Utils.logException(AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId()).id,'Dispute Tool','AGS_ST_HomeController_gne',e, 'saveDispute');
            DisputeCreationResult dcr = new DisputeCreationResult();
            dcr.errorMessage = e.getMessage();
            return dcr;
        }
    }
    
    @RemoteAction
    global static String saveDisputeNotesFromDisputeId(String disputeId,String noteTxt) {
        try
        {
            AGS_ST_Dispute_Note_and_Attachment_gne__c na = new AGS_ST_Dispute_Note_and_Attachment_gne__c(About_gne__c='HCP Dispute',AGS_ST_Dispute_Management_gne__c=disputeId,isPrivate_gne__c=false);
            insert na;
            Note n = new Note(body=noteTxt,ParentId=na.id,Title = 'HCP Dispute Note',IsPrivate = false);
            insert n;
            return 'Success';
        }
        catch(Exception e)
        {
            AGS_ST_Utils.logException(AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId()).id,'Dispute Tool','AGS_ST_HomeController_gne',e, 'saveDisputeNotesFromDisputeId');
            return e.getMessage();
        }
    }
    
    @RemoteAction
    global static NonResearchSpendDetailsView getDisputeDetails(String spendId) {
        try
        {
            NonResearchSpendDetailsView result = new NonResearchSpendDetailsView();
            List<AGS_ST_Dispute_List_gne__c> disputeList = [select IsCmsDispute_gne__c,isAmountDisputed_gne__c,isBrandDisputed_gne__c,isFormDisputed_gne__c,isNatureDisputed_gne__c,CreatedDate,Amount_gne__c,Drug_Name_gne__c,Form_Of_Payment_gne__c,Nature_Of_Payment_gne__c from AGS_ST_Dispute_List_gne__c where AGS_Spend_Expense_Transaction_gne__c=:spendId and isPrivate_gne__c=false order by createddate desc];
            List<AGS_ST_DisputeManagement_gne__c> disputes = [select id from AGS_ST_DisputeManagement_gne__c where AGS_Spend_Expense_Transaction_gne__c=:spendId and isPrivate__c=false];
            List<Id> disputesIds = new List<Id>();
            for(AGS_ST_DisputeManagement_gne__c dispute:disputes)
            {
                disputesIds.add(dispute.id);        
            }
            List<AGS_ST_Dispute_Note_and_Attachment_gne__c> disputeNote = [select id,Communication_Type_gne__c from AGS_ST_Dispute_Note_and_Attachment_gne__c where AGS_ST_Dispute_Management_gne__c in :disputesIds and isPrivate_gne__c=false and About_gne__c != null order by createddate desc];
            if(disputeNote.size() > 0)
            {
                Note disputeNoteTxt = [select id,body,LastModifiedDate from Note where ParentId = :disputeNote[0].id];
                result.explanationString = disputeNoteTxt.body;
            }
            
            List<AGS_ST_Dispute_Note_and_Attachment_gne__c> disputeDetailsNotes = [select id,CreatedDate,Communication_Type_gne__c, Email_Recipients_gne__c from AGS_ST_Dispute_Note_and_Attachment_gne__c where AGS_ST_Dispute_Management_gne__c in :disputesIds and isPrivate_gne__c=false and About_gne__c = null order by createddate desc];
            Map<Id, Id> emailNotes = new Map<Id, Id>();
            Map<Id, AGS_ST_Dispute_Note_and_Attachment_gne__c> dnaDetailsIds = new Map<Id, AGS_ST_Dispute_Note_and_Attachment_gne__c>();
            for(AGS_ST_Dispute_Note_and_Attachment_gne__c dna:disputeDetailsNotes)
            {
                if(dna.Email_Recipients_gne__c != null) {
                    emailNotes.put(dna.id, dna.id);
                }
                dnaDetailsIds.put(dna.id, dna);
            }
            List<Note> detailsNotes = [select id,body,ParentId,LastModifiedById,LastModifiedDate from Note where ParentId in :dnaDetailsIds.keySet()];
            NonResearchSpendDetails[] details = new NonResearchSpendDetails[]{};
            // CMS flag value
            if(disputeList[0].IsCmsDispute_gne__c) {
                result.isCmsDispute = true;
            } else {
            	result.isCmsDispute = false;
            }
            // Other values
            if(disputeList[0].isAmountDisputed_gne__c)
            {
                NonResearchSpendDetails detail = new NonResearchSpendDetails();
                detail.disputed = 'Amount';
                detail.dateToCompare = String.valueOf(disputeList[0].createddate);
                detail.suggestedValue = String.valueOf(disputeList[0].Amount_gne__c);
                details.add(detail);
            }
            if(disputeList[0].isFormDisputed_gne__c)
            {
                NonResearchSpendDetails detail = new NonResearchSpendDetails();
                detail.disputed = 'Method';
                detail.dateToCompare = String.valueOf(disputeList[0].createddate);
                detail.suggestedValue = disputeList[0].Form_Of_Payment_gne__c;
                details.add(detail);
            }
            if(disputeList[0].isNatureDisputed_gne__c)
            {
                NonResearchSpendDetails detail = new NonResearchSpendDetails();
                detail.disputed = 'Reason';
                detail.dateToCompare = String.valueOf(disputeList[0].createddate);
                detail.suggestedValue = disputeList[0].Nature_Of_Payment_gne__c;
                details.add(detail);
            }
            if(disputeList[0].isBrandDisputed_gne__c)
            {
                NonResearchSpendDetails detail = new NonResearchSpendDetails();
                detail.disputed = 'Brand';
                detail.dateToCompare = String.valueOf(disputeList[0].createddate);
                detail.suggestedValue = disputeList[0].Drug_Name_gne__c;
                details.add(detail);
            }
            system.debug('--'+details);
            result.detailTab = details;
            NonResearchSpendDetails[] historyDetails = new NonResearchSpendDetails[]{};
            for(Note dispNandA:detailsNotes)
            {
                NonResearchSpendDetails detail = new NonResearchSpendDetails();
                detail.dateToCompare = String.valueOf(dispNandA.LastModifiedDate);
                if(emailNotes.containsKey(dispNandA.parentId)) {
                    detail.detailTxt = 'Message was sent to physician on '+dispNandA.LastModifiedDate.format('MMM d yyyy HH:mm:ss') ;
                } else {
                	AGS_ST_Dispute_Note_and_Attachment_gne__c dispNote = dnaDetailsIds.get(dispNandA.parentId);
                	if('From Physician'.equals(dispNote.Communication_Type_gne__c)) 
                    	detail.detailTxt = 'Physician added message \'' + dispNandA.body + '\' on '+dispNandA.LastModifiedDate.format('MMM d yyyy HH:mm:ss') ;
                	else 
                		detail.detailTxt = 'Genentech Sunshine Help Desk added message \'' + dispNandA.body + '\' on '+dispNandA.LastModifiedDate.format('MMM d yyyy HH:mm:ss') ;                	
                }
                historyDetails.add(detail);
            }
            
            List<AGS_ST_DisputeManagement_gne__History> disputesHistory = [SELECT CreatedDate,Field,NewValue,OldValue,ParentId,Parent.Name FROM AGS_ST_DisputeManagement_gne__History where ParentId in :disputesIds order by createddate];
            for(AGS_ST_DisputeManagement_gne__History disputeHistory:disputesHistory)
            {
                if(disputeHistory.Field == 'External_Status_gne__c' || disputeHistory.Field == 'created')
                {
                    String historyDescription = getHistoryDescription(disputeHistory);
                    NonResearchSpendDetails detail = new NonResearchSpendDetails();
                    detail.dateToCompare = String.valueOf(disputeHistory.CreatedDate);
                    detail.detailTxt = historyDescription;
                    historyDetails.add(detail);
                }
            }
            historyDetails.sort(); 
            result.historyTab = historyDetails;
            return result;
        }
        catch(Exception e)
        {
            AGS_ST_Utils.logException(AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId()).id,'Dispute Tool','AGS_ST_HomeController_gne',e, 'getDisputeDetails');
            return new NonResearchSpendDetailsView();
        }
    }
    
    @RemoteAction
    global static ResearchSpendDetailsView getResearchDisputeDetails(String spendId) {
        try
        {
            ResearchSpendDetailsView result = new ResearchSpendDetailsView();
            //List<AGS_ST_Dispute_List_gne__c> disputeList = [select isAmountDisputed_gne__c,isBrandDisputed_gne__c,isFormDisputed_gne__c,isNatureDisputed_gne__c,CreatedDate,Amount_gne__c,Drug_Name_gne__c,Form_Of_Payment_gne__c,Nature_Of_Payment_gne__c from AGS_ST_Dispute_List_gne__c where AGS_Spend_Expense_Transaction_gne__c=:spendId and isPrivate_gne__c=false];
            List<AGS_ST_DisputeManagement_gne__c> disputes = [select id, Dispute_List_gne__r.IsCmsDispute_gne__c from AGS_ST_DisputeManagement_gne__c where AGS_Spend_Expense_Transaction_gne__c=:spendId and isPrivate__c=false ORDER BY CreatedDate DESC];
            if(disputes[0].Dispute_List_gne__r.IsCmsDispute_gne__c) {
                result.isCmsDispute = true;
            } else {
                result.isCmsDispute = false;
            }
            List<Id> disputesIds = new List<Id>();
            for(AGS_ST_DisputeManagement_gne__c dispute:disputes)
            {
                disputesIds.add(dispute.id);        
            }
            List<AGS_ST_Dispute_Note_and_Attachment_gne__c> disputeNote = [select id,Communication_Type_gne__c from AGS_ST_Dispute_Note_and_Attachment_gne__c where AGS_ST_Dispute_Management_gne__c in :disputesIds and isPrivate_gne__c=false and About_gne__c != null order by createddate desc];
            if(disputeNote.size() > 0)
            {
                Note disputeNoteTxt = [select id,body,LastModifiedDate from Note where ParentId = :disputeNote[0].id];
                result.explanationString = disputeNoteTxt.body;
            }
            
            List<AGS_ST_Dispute_Note_and_Attachment_gne__c> disputeDetailsNotes = [select id,CreatedDate,Email_Recipients_gne__c,Communication_Type_gne__c from AGS_ST_Dispute_Note_and_Attachment_gne__c where AGS_ST_Dispute_Management_gne__c in :disputesIds and isPrivate_gne__c=false and About_gne__c = null order by createddate desc];
            Map<Id, Id> emailNotes = new Map<Id, Id>();
            Map<Id,AGS_ST_Dispute_Note_and_Attachment_gne__c> dnaDetailsIds = new Map<Id,AGS_ST_Dispute_Note_and_Attachment_gne__c>();
            for(AGS_ST_Dispute_Note_and_Attachment_gne__c dna:disputeDetailsNotes)
            {
                if(dna.Email_Recipients_gne__c != null) {
                    emailNotes.put(dna.id, dna.id);
                }
                dnaDetailsIds.put(dna.id, dna);
            }
            List<Note> detailsNotes = [select id,body,ParentId,LastModifiedById,LastModifiedDate from Note where ParentId in :dnaDetailsIds.keySet()];
            ResearchSpendDetails[] historyDetails = new ResearchSpendDetails[]{};
            for(Note dispNandA:detailsNotes)
            {
                ResearchSpendDetails detail = new ResearchSpendDetails();
                detail.dateToCompare = String.valueOf(dispNandA.LastModifiedDate);
                if(emailNotes.containsKey(dispNandA.parentId)) {
                    detail.detailTxt = 'Message was sent to physician on '+ dispNandA.LastModifiedDate.format('MMM d yyyy HH:mm:ss') ;
                } else {
                    AGS_ST_Dispute_Note_and_Attachment_gne__c dispNote = dnaDetailsIds.get(dispNandA.parentId);
                	if('From Physician'.equals(dispNote.Communication_Type_gne__c)) 
                    	detail.detailTxt = 'Physician added message \'' + dispNandA.body + '\' on '+dispNandA.LastModifiedDate.format('MMM d yyyy HH:mm:ss') ;
                	else 
                		detail.detailTxt = 'Genentech Sunshine Help Desk added message \'' + dispNandA.body + '\' on '+dispNandA.LastModifiedDate.format('MMM d yyyy HH:mm:ss') ;                	
                
                }
                historyDetails.add(detail);
            }
            
            List<AGS_ST_DisputeManagement_gne__History> disputesHistory = [SELECT CreatedDate,Field,NewValue,OldValue,ParentId,Parent.Name FROM AGS_ST_DisputeManagement_gne__History where ParentId in :disputesIds order by createddate];
            for(AGS_ST_DisputeManagement_gne__History disputeHistory:disputesHistory)
            {
                if(disputeHistory.Field == 'External_Status_gne__c' || disputeHistory.Field == 'created')
                {
                    String historyDescription = getHistoryDescription(disputeHistory);
                    ResearchSpendDetails detail = new ResearchSpendDetails();
                    detail.dateToCompare = String.valueOf(disputeHistory.CreatedDate);
                    detail.detailTxt = historyDescription;
                    historyDetails.add(detail);
                }
            }
            historyDetails.sort(); 
            result.historyTab = historyDetails;
            return result;
        }
        catch(Exception e)
        {
            System.debug('--------- error ' + e.getMessage());  
            AGS_ST_Utils.logException(AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId()).id,'Dispute Tool','AGS_ST_HomeController_gne',e, 'getDisputeDetails');
            return new ResearchSpendDetailsView();
        }
    }
    
    @RemoteAction
    global static String saveDisputeNotes(String spendId,String noteTxt) {
        try {
            List<AGS_ST_DisputeManagement_gne__c> disputes = [select id from AGS_ST_DisputeManagement_gne__c where AGS_Spend_Expense_Transaction_gne__c=:spendId AND isPrivate__c=false ORDER BY createddate DESC];
            AGS_ST_Dispute_Note_and_Attachment_gne__c na = new AGS_ST_Dispute_Note_and_Attachment_gne__c(AGS_ST_Dispute_Management_gne__c=disputes[disputes.size()-1].id,isPrivate_gne__c=false,Communication_Type_gne__c='From Physician');
            insert na;
            Note n = new Note(body=noteTxt,ParentId=na.id,Title = 'HCP Message Note',IsPrivate = false);
            insert n;
            system.debug('start sending email');
            AGS_ST_User_gne__c sunshineUser = AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId());
            AGS_ST_MailUtil.sendSaveDisputeNoteEmail(sunshineUser, disputes[disputes.size()-1].id, noteTxt);
            /*
            String hcpName = sunshineUser.First_name__c + ' ' + sunshineUser.Last_name__c;
            String body = '<p>Dear CCO,</p>';
            body += '<p></p>';
            AGS_ST_Settings_gne__c stSetting = AGS_ST_Utils.getCustomSettingsInSite();
            body += '<p>HCP '+hcpName+' sent a message about <a href="'+ stSetting.Domain_gne__c +'/'+disputes[disputes.size()-1].id+'">dispute</a> with following text:</p>';
            body += '<p>'+noteTxt+'</p>';
            body += '<p></p>';
            body += '<p>If you want to see user details click <a href="'+ stSetting.Domain_gne__c +'/'+sunshineUser.id+'">here</a>.</p>';
            body += '<p>Thank you</p>';
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddress = new String[] {stSetting.CCO_Email_gne__c};
            mail.setToAddresses(toAddress);
            mail.setInReplyTo(UserInfo.getUserName());
            mail.setSenderDisplayName(hcpName);
            mail.setSubject('HCP message about dispute');
            mail.setHtmlBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            system.debug('---'+mail); 
            */
            return 'Physician sent message :\'' + noteTxt + '\' on '+DateTime.Now().format('MMM d yyyy HH:mm:ss');
        } catch(Exception e) {
            AGS_ST_Utils.logException(AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId()).id,'Dispute Tool','AGS_ST_HomeController_gne',e, 'saveDisputeNotes');
            return e.getMessage();
        }
    }
    
    @RemoteAction
    global static DisputeTypesValues getDisputeTypesValues() {
        try
        {
            DisputeTypesValues disputeTypes = new DisputeTypesValues();
            disputeTypes.reasonsList = getReasons();
            disputeTypes.methodsList = getMethods();
            disputeTypes.brandsList = getBrands();
            return disputeTypes; 
        }
        catch(Exception e)
        {
            return new DisputeTypesValues();
        }
    }

    @RemoteAction
    global static Boolean deactivatePopup() {
    	try {
            Map<Id, Id> popupMap = new Map<Id, Id>();
            for(AGS_ST_Popup_gne__c popup : [SELECT Id, AGS_ST_CMS_gne__c FROM AGS_ST_Popup_gne__c WHERE AGS_ST_CMS_gne__r.IsVisible_gne__c = true AND AGS_ST_User_gne__c = :stUser.Id]) {
                popupMap.put(popup.AGS_ST_CMS_gne__c, popup.AGS_ST_CMS_gne__c);
            }
            List<AGS_ST_Popup_gne__c> newPopups = new List<AGS_ST_Popup_gne__c>();
            for(AGS_ST_FAQ_DYK_gne__c popup : [SELECT Id, TC_Description_Text_gne__c FROM AGS_ST_FAQ_DYK_gne__c WHERE Type_gne__c = 'Popup' AND IsVisible_gne__c = true]) {
                if(!popupMap.containsKey(popup.Id)) {
                    newPopups.add(new AGS_ST_Popup_gne__c(AGS_ST_CMS_gne__c = popup.Id, AGS_ST_User_gne__c = stUser.Id, Status_gne__c = 'Inactive'));
                }
            }
            insert newPopups;
    	    // TODO: AND AGS_ST_User_gne__c = :stUser.Id
    	    /*
    	    AGS_ST_Popup_gne__c popupData = [SELECT Id, Status_gne__c FROM AGS_ST_Popup_gne__c WHERE IsVisible_gne__c = true];
    	    popupData.Status_gne__c = 'Inactive';
    	    update popupData;
    	    */
    	    return true;
        } catch(Exception e) {
            return false;
        }
    }

    @RemoteAction
    global static PopupData getPopupData() {
        try {
        	List<PopupRecord> popupDesc = new List<PopupRecord>();
            List<String> idList = new List<String>();
            // TODO: WHERE IsVisible_gne__c = true AND AGS_ST_User_gne__c = :stUser.Id
            /*
            for(AGS_ST_Popup_gne__c popup : [SELECT AGS_ST_CMS_gne__c FROM AGS_ST_Popup_gne__c]) {
                idList.add(popup.AGS_ST_CMS_gne__c);
            }
            */
            Map<Id, Id> popupMap = new Map<Id, Id>();
            for(AGS_ST_Popup_gne__c popup : [SELECT Id, AGS_ST_CMS_gne__c FROM AGS_ST_Popup_gne__c WHERE AGS_ST_CMS_gne__r.IsVisible_gne__c = true AND AGS_ST_User_gne__c = :stUser.Id]) {
            	popupMap.put(popup.AGS_ST_CMS_gne__c, popup.AGS_ST_CMS_gne__c);
            }
        	//for(AGS_ST_FAQ_DYK_gne__c popup : [SELECT Id, TC_Description_Text_gne__c FROM AGS_ST_FAQ_DYK_gne__c WHERE Type_gne__c = 'Popup' AND Id IN :idList]) {
        	for(AGS_ST_FAQ_DYK_gne__c popup : [SELECT Id, TC_Description_Text_gne__c FROM AGS_ST_FAQ_DYK_gne__c WHERE Type_gne__c = 'Popup' AND IsVisible_gne__c = true]) {
        		if(!popupMap.containsKey(popup.Id)) {
        		  popupDesc.add(new PopupRecord(popup.Id, popup.TC_Description_Text_gne__c));
        		}
        	}
        	// FAQ LIST
        	List<FaqRecord> faqList = new List<FaqRecord>();
        	for(AGS_ST_FAQ_DYK_gne__c faq : [SELECT Id, Answer_gne__c, Question_gne__c, Question_number_gne__c FROM AGS_ST_FAQ_DYK_gne__c WHERE Type_gne__c = 'FAQ']) {
        		faqList.add(new FaqRecord(faq.Id, Integer.valueOf(faq.Question_number_gne__c), faq.Question_gne__c, faq.Answer_gne__c));
        	}
        	return new PopupData(popupDesc, faqList);
        } catch(Exception e) {
            return new PopupData();
        }
    }

    global class PopupData {
        public List<PopupRecord>      popupDescriptions;
        public List<FaqRecord>        faqData;
        // Constructors
        public PopupData(List<PopupRecord> popupDesc, List<FaqRecord> faqData) {
        	this.faqData = faqData;
        	popupDescriptions = popupDesc;
        }
        public PopupData() {
        	// For exception
        }
    }

    global class PopupRecord {
    	public Id popupId;
    	public String popupDescr;
        // Constructor
        public PopupRecord(String popupId, String popupDescr) {
        	this.popupId = popupId;
        	this.popupDescr = popupDescr;
        }
    }

    global class FaqRecord {
    	public Id                  qId;
    	public Integer             qNum;
    	public String              qQuestion;
    	public String              qAnswer;
    	// Constructor
    	public FaqRecord(Id faqId, Integer num, String question, String answer) {
    		qId = faqId;
    		qNum = num;
    		qQuestion = question;
    		qAnswer = answer;
    	}
    }

    global class ResearchSpendDetailsView {
        public ResearchSpendDetails[] historyTab = new ResearchSpendDetails[]{};
        public String explanationString;
        public Boolean isCmsDispute;
    }  
    
    global class ResearchSpendDetails implements Comparable {
        public String detailTxt;
        public String dateToCompare;
        
        global Integer compareTo(Object compareTo)
        {
            ResearchSpendDetails compareToSpend = (ResearchSpendDetails)compareTo;
            if (dateToCompare == compareToSpend.dateToCompare) return 0;
            if (dateToCompare < compareToSpend.dateToCompare) return 1;
            return -1;   
        }
    }
    
    global class NonResearchSpendDetailsView {
        public NonResearchSpendDetails[] detailTab = new NonResearchSpendDetails[]{};
        public NonResearchSpendDetails[] historyTab = new NonResearchSpendDetails[]{};
        public String explanationString;
        public Boolean isCmsDispute;
    }   
    
    global class NonResearchSpendDetails implements Comparable {
        public String detailTxt;
        public String dateToCompare;
        public String about;
        public String suggestedValue;
        public String disputed;

        global Integer compareTo(Object compareTo)
        {
            NonResearchSpendDetails compareToSpend = (NonResearchSpendDetails)compareTo;
            if (dateToCompare == compareToSpend.dateToCompare) return 0;
            if (dateToCompare < compareToSpend.dateToCompare) return 1;
            return -1;   
        }
    }
    
    global class DisputeCreationResult {
        public String disputeName;
        public String disputeCreationDate;
        public String errorMessage;
    }
    
    global class DisputeTypesValues {
        public String[] reasonsList = new String[]{};
        public String[] methodsList = new String[]{};
        public String[] brandsList = new String[]{};
    }
    
        
    global class DisputeCommunication {
        public String dispEmail;
        public String dispPhone;
        public String dispMethod;
    }
    
    global class SpendAdditionalInfo {
        public String field;
        public String value;
        
        public SpendAdditionalInfo(String field, String val)
        {
            this.field = field;
            this.value = val;
        }
    }
}