public without sharing class BulkEmailController {
    
    @AuraEnabled public static map<String,String> CGN_List{get;set;}
    
    @AuraEnabled
    public static List<String> getPreappTypes() {
        
        List<String> pickListValuesList = new List<String>();
        //list<GroupMember> publicGrp =[SELECT UserorGroupId,Group.Name,Groupid FROM GroupMember WHERE UserOrGroupId =:userid and Group.Type = 'Regular'];
        list<GroupMember> publicGrp =[SELECT UserorGroupId,Group.Name,Groupid FROM GroupMember WHERE UserOrGroupId =:UserInfo.getUserId() and Group.Type = 'Regular'];
        if(publicGrp.size()>0){
            for(GroupMember Gm:publicGrp){
                
                if(Gm.Group.Name == 'gFRS AEA - PLNG'){
                    Schema.DescribeFieldResult fieldResult = gFRS_CGN_PLNG_Bulk_Email__c.Pre_Application_Queue__c.getDescribe();
                    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                    for( Schema.PicklistEntry pickListVal : ple){
                        if(pickListVal.getLabel() =='AEA - PLNG'){
                            pickListValuesList.add(pickListVal.getLabel());
                        } 
                    } 
                    
                }else if(Gm.Group.Name == 'gFRS IME - CGN Executive Summary'){
                    Schema.DescribeFieldResult fieldResult = gFRS_CGN_PLNG_Bulk_Email__c.Pre_Application_Queue__c.getDescribe();
                    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                    for( Schema.PicklistEntry pickListVal : ple){
                        if(pickListVal.getLabel() =='IME - CGN Executive Summary'){
                            pickListValuesList.add(pickListVal.getLabel());
                        } 
                    }
                    
                }else if(Gm.Group.Name == 'gFRS Foundation- Pre Application'){
                    Schema.DescribeFieldResult fieldResult = gFRS_CGN_PLNG_Bulk_Email__c.Pre_Application_Queue__c.getDescribe();
                    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                    for( Schema.PicklistEntry pickListVal : ple){
                        if(pickListVal.getLabel() =='Foundation- Pre-application'){
                            pickListValuesList.add(pickListVal.getLabel());
                        } 
                    }
                    
                }else if(Gm.Group.Name == 'gFRS CEG - Pre Application'){
                    Schema.DescribeFieldResult fieldResult = gFRS_CGN_PLNG_Bulk_Email__c.Pre_Application_Queue__c.getDescribe();
                    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                    for( Schema.PicklistEntry pickListVal : ple){
                        if(pickListVal.getLabel() =='CEG - Pre-application'){
                            pickListValuesList.add(pickListVal.getLabel());
                        } 
                    }
                }
                
            }
        }else{
            Schema.DescribeFieldResult fieldResult = gFRS_CGN_PLNG_Bulk_Email__c.Pre_Application_Queue__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                pickListValuesList.add(pickListVal.getLabel());
            }     
        }
        
        return pickListValuesList;
    }
    @AuraEnabled
    public static list<String> getallusers(Date myFromdate,Date myTodate,String myFundingList) {
        
        //System.debug('TestZZZZZZZZ'+myFundingList);
        List<String> lstAlpha = myFundingList.split(';');
        
        System.debug('Test12345'+lstAlpha);
        
        map<String,String> CGN_List=new map<String,String>();
        list<String> userList=new list<String>();
        
        List<GFRS_Funding_Request__c> GFRS_List = [SELECT id,CreatedById,CreatedBy.Name,CreatedBy.email,Date_Submitted__c,Funding_Type__c,CreatedDate FROM GFRS_Funding_Request__c where Funding_Type__c IN:lstAlpha AND Date_Submitted__c>=:myFromdate AND Date_Submitted__c<=:myTodate];
        system.debug('GFRS_List'+GFRS_List);
        system.debug('myFromdate'+myFromdate);
        system.debug('myTodate'+myTodate);
        system.debug('FundingList'+myFundingList);
        
        
        CGN_List.put('--Select--','--Select--');
        for(GFRS_Funding_Request__c gFRS_CGN : GFRS_List){
            CGN_List.put(gFRS_CGN.CreatedBy.Name,gFRS_CGN.CreatedBy.email);
            userList.add(gFRS_CGN.CreatedBy.Name);
        }
        
        return userList;
        
    }
    
    @AuraEnabled
    public static string getEmailContents(String CGNTitle){
        
        EmailTemplate  emailCon=[SELECT Subject, Name, Id, Description, Body,DeveloperName
                                 FROM EmailTemplate
                                 WHERE DeveloperName = 'gFRS_CGN_PLNG_Bulk_Email' ];
        
        String body = emailCon.Body;
        System.debug('@@ Body'+body);
        string CGNTitleValue = CGNTitle;
        CGNTitleValue = CGNTitleValue.replace(' ', '+');
        String communityURL = System.Label.gFRS_Ltng_Community_URL;
        String url = 'https://cdcciam.gene.com/?sp=GFRS_PROD&redirectUrl=' + communityURL + 'preapplication?CGNPLNGTitle=';
        //String url = 'https://gfrsdev08-genentech-prod.cs60.force.com/gFRS/s/preapplication?CGNPLNGTitle=';
        url = url + CGNTitleValue + '&ThruMail=Yes';
        body = body.replace('<<Link>>', url);
        system.debug('Email Body : '+body);
        return body;
        
    }    
    
    @AuraEnabled
    public static Id createCGN(gFRS_CGN_PLNG_Bulk_Email__c CGNRec){
        
        insert CGNRec;
        
        return CGNRec.Id;
        
    }
    
    @AuraEnabled
    public static void updateCGN(String recordId,gFRS_CGN_PLNG_Bulk_Email__c CGNRec){
        Id invitationId;
        String surveyName;
        String formattedUrl;
        system.debug('--recordId--'+recordId);
        system.debug('--CGNRec--'+CGNRec);
        if(recordId!=null){
            gFRS_CGN_PLNG_Bulk_Email__c cgnemail=[select Id,RFP_CC_User__c,RFP_Visibleity_on_Entry_Page__c,RFP_Send_Email__c,givingprioritycheck1__c,givingprioritycheck2__c,givingprioritycheck3__c,givingprioritycheck4__c,givingprioritycheck5__c,givingprioritycheck6__c,Email_Body__c,OwnerId,Name,CGN_PLNG_Title__c, Pre_Application_Queue__c, Start_Date__c, End_Date__c, CGN_PLNG_Status__c, Funding_Type__c, From_Date__c, To_Date__c, Pre_App_Type__c, invitationId__c, Survey_Link__c, gFRS_Funding_Request__c, Start_date_Validation__c, Purpose_of_CGN_PLNG__c, Users_to_whom_email_sent__c, Giving_Priorities_Alignment__c, From__c, Event_Program_Origin__c, Briefly_describe_the_intended_audience__c, Do_you_need_custom_questions__c, Event_Program_Origin_SRFG__c, Briefly_describe_intended_audience_SRFG__c, Event_Program_Origin_EFG__c, Briefly_describe_intended_audience_EFG__c, Event_Program_Origin_CG__c, Briefly_describe_intended_audience_CG__c, Event_Program_Origin_CME__c, Briefly_describe_intended_audience_CME__c, What_is_your_organization_s_annual_budge__c, How_many_employees_are_in_your_organizat__c, Sample_Question_Picklist_Multi_SRFG__c, Sample_Question_Radio_SRFG__c, phfgtext4__c, phfgtext5__c, phfgtext6__c, phfgtext8__c, phfgtext9__c, phfgtext10__c, phfgtext7__c, srfgtext4__c, srfgtext5__c, srfgtext6__c, srfgtext7__c, srfgtext8__c, srfgtext9__c, srfgtext10__c, cmetext7__c, cmetext8__c, cmetext9__c, cmetext10__c, cmetext11__c, cmetext12__c, efgtext1__c, efgtext5__c, efgtext2__c, efgtext3__c, efgtext6__c, efgtext4__c, efgtext7__c, efgtext8__c, efgtext9__c, efgtext10__c, cgtext1__c, cgtext2__c, cgtext4__c, cgtext3__c, cgtext5__c, cgtext6__c, cgtext7__c, cgtext8__c, cgtext9__c, cgtext10__c, foundtext5__c, foundtext2__c, foundtext1__c, foundtext3__c, foundtext4__c, foundtext6__c, foundtext7__c, foundtext8__c, foundtext9__c, foundtext10__c ,ProgramStartDateCheck__c,ProgramEndDateCheck__c from gFRS_CGN_PLNG_Bulk_Email__c where id=:recordId];
            
            
            cgnemail.CGN_PLNG_Title__c=CGNRec.CGN_PLNG_Title__c;
            cgnemail.Pre_Application_Queue__c=CGNRec.Pre_Application_Queue__c;
            cgnemail.Start_Date__c=CGNRec.Start_Date__c;
            cgnemail.End_Date__c=CGNRec.End_Date__c;
            
            cgnemail.Funding_Type__c=CGNRec.Funding_Type__c;
            cgnemail.From_Date__c=CGNRec.From_Date__c;
            cgnemail.To_Date__c=CGNRec.To_Date__c;
            cgnemail.Pre_App_Type__c=CGNRec.Pre_App_Type__c;
            cgnemail.invitationId__c=CGNRec.invitationId__c;
            cgnemail.Survey_Link__c=CGNRec.Survey_Link__c;
            cgnemail.gFRS_Funding_Request__c=CGNRec.gFRS_Funding_Request__c;
            cgnemail.Start_date_Validation__c=CGNRec.Start_date_Validation__c;
            cgnemail.Purpose_of_CGN_PLNG__c=CGNRec.Purpose_of_CGN_PLNG__c;
            cgnemail.Users_to_whom_email_sent__c=CGNRec.Users_to_whom_email_sent__c;
            cgnemail.Giving_Priorities_Alignment__c=CGNRec.Giving_Priorities_Alignment__c;
            System.debug('--cgnemail.Giving_Priorities_Alignment__c--'+cgnemail.Giving_Priorities_Alignment__c);
            System.debug('--CGNRec.Giving_Priorities_Alignment__c--'+CGNRec.Giving_Priorities_Alignment__c);
            cgnemail.From__c=CGNRec.From__c;
            cgnemail.Event_Program_Origin__c=CGNRec.Event_Program_Origin__c;
            cgnemail.Briefly_describe_the_intended_audience__c=CGNRec.Briefly_describe_the_intended_audience__c;
            cgnemail.Do_you_need_custom_questions__c=CGNRec.Do_you_need_custom_questions__c;
            cgnemail.Event_Program_Origin_SRFG__c=CGNRec.Event_Program_Origin_SRFG__c;
            cgnemail.Briefly_describe_intended_audience_SRFG__c=CGNRec.Briefly_describe_intended_audience_SRFG__c;
            cgnemail.Event_Program_Origin_EFG__c=CGNRec.Event_Program_Origin_EFG__c;
            cgnemail.Briefly_describe_intended_audience_EFG__c=CGNRec.Briefly_describe_intended_audience_EFG__c;
            cgnemail.Event_Program_Origin_CG__c=CGNRec.Event_Program_Origin_CG__c;
            cgnemail.Briefly_describe_intended_audience_CG__c=CGNRec.Briefly_describe_intended_audience_CG__c;
            cgnemail.Event_Program_Origin_CME__c=CGNRec.Event_Program_Origin_CME__c;
            cgnemail.Briefly_describe_intended_audience_CME__c=CGNRec.Briefly_describe_intended_audience_CME__c;
            cgnemail.What_is_your_organization_s_annual_budge__c=CGNRec.What_is_your_organization_s_annual_budge__c;
            cgnemail.How_many_employees_are_in_your_organizat__c=CGNRec.How_many_employees_are_in_your_organizat__c;
            cgnemail.Sample_Question_Picklist_Multi_SRFG__c=CGNRec.Sample_Question_Picklist_Multi_SRFG__c;
            cgnemail.Sample_Question_Radio_SRFG__c=CGNRec.Sample_Question_Radio_SRFG__c;
            cgnemail.phfgtext4__c=CGNRec.phfgtext4__c;
            cgnemail.phfgtext5__c=CGNRec.phfgtext5__c;
            cgnemail.phfgtext6__c=CGNRec.phfgtext6__c;
            cgnemail.phfgtext8__c=CGNRec.phfgtext8__c;
            cgnemail.phfgtext9__c=CGNRec.phfgtext9__c;
            cgnemail.phfgtext10__c=CGNRec.phfgtext10__c;
            cgnemail.phfgtext7__c=CGNRec.phfgtext7__c;
            cgnemail.srfgtext4__c=CGNRec.srfgtext4__c;
            cgnemail.srfgtext5__c=CGNRec.srfgtext5__c;
            cgnemail.srfgtext6__c=CGNRec.srfgtext6__c;
            cgnemail.srfgtext7__c=CGNRec.srfgtext7__c;
            cgnemail.srfgtext8__c=CGNRec.srfgtext8__c;
            cgnemail.srfgtext9__c=CGNRec.srfgtext9__c;
            cgnemail.srfgtext10__c=CGNRec.srfgtext10__c;
            cgnemail.cmetext7__c=CGNRec.cmetext7__c;
            cgnemail.cmetext8__c=CGNRec.cmetext8__c;
            cgnemail.cmetext9__c=CGNRec.cmetext9__c;
            cgnemail.cmetext10__c=CGNRec.cmetext10__c;
            cgnemail.cmetext11__c=CGNRec.cmetext11__c;
            cgnemail.cmetext12__c=CGNRec.cmetext12__c;
            cgnemail.efgtext1__c=CGNRec.efgtext1__c;
            cgnemail.efgtext5__c=CGNRec.efgtext5__c;
            cgnemail.efgtext2__c=CGNRec.efgtext2__c;
            cgnemail.efgtext3__c=CGNRec.efgtext3__c;
            cgnemail.efgtext6__c=CGNRec.efgtext6__c;
            cgnemail.efgtext4__c=CGNRec.efgtext4__c;
            cgnemail.efgtext7__c=CGNRec.efgtext7__c;
            cgnemail.efgtext8__c=CGNRec.efgtext8__c;
            cgnemail.efgtext9__c=CGNRec.efgtext9__c;
            cgnemail.efgtext10__c=CGNRec.efgtext10__c;
            cgnemail.cgtext1__c=CGNRec.cgtext1__c;
            cgnemail.cgtext2__c=CGNRec.cgtext2__c;
            cgnemail.cgtext4__c=CGNRec.cgtext4__c;
            cgnemail.cgtext3__c=CGNRec.cgtext3__c;
            cgnemail.cgtext5__c=CGNRec.cgtext5__c;
            cgnemail.cgtext6__c=CGNRec.cgtext6__c;
            cgnemail.cgtext7__c=CGNRec.cgtext7__c;
            cgnemail.cgtext8__c=CGNRec.cgtext8__c;
            cgnemail.cgtext9__c=CGNRec.cgtext9__c;
            cgnemail.cgtext10__c=CGNRec.cgtext10__c;
            cgnemail.foundtext5__c=CGNRec.foundtext5__c;
            cgnemail.foundtext2__c=CGNRec.foundtext2__c;
            cgnemail.foundtext1__c=CGNRec.foundtext1__c;
            cgnemail.foundtext3__c=CGNRec.foundtext3__c;
            cgnemail.foundtext4__c=CGNRec.foundtext4__c;
            cgnemail.foundtext6__c=CGNRec.foundtext6__c;
            cgnemail.foundtext7__c=CGNRec.foundtext7__c;
            cgnemail.foundtext8__c=CGNRec.foundtext8__c;
            cgnemail.foundtext9__c=CGNRec.foundtext9__c;
            cgnemail.foundtext10__c=CGNRec.foundtext10__c;
            cgnemail.ProgramStartDateCheck__c=CGNRec.ProgramStartDateCheck__c;
            cgnemail.ProgramEndDateCheck__c=CGNRec.ProgramEndDateCheck__c;
            System.debug('--priority1--'+CGNRec.givingprioritycheck1__c);
            System.debug('--priority2--'+CGNRec.givingprioritycheck2__c);
            System.debug('--priority3--'+CGNRec.givingprioritycheck3__c);
            System.debug('--priority4--'+CGNRec.givingprioritycheck4__c);
            System.debug('--priority5--'+CGNRec.givingprioritycheck5__c);
            cgnemail.givingprioritycheck1__c=CGNRec.givingprioritycheck1__c;
            cgnemail.givingprioritycheck2__c=CGNRec.givingprioritycheck2__c;
            cgnemail.givingprioritycheck3__c=CGNRec.givingprioritycheck3__c;
            cgnemail.givingprioritycheck4__c=CGNRec.givingprioritycheck4__c;
            cgnemail.givingprioritycheck5__c=CGNRec.givingprioritycheck5__c;
            cgnemail.givingprioritycheck6__c=CGNRec.givingprioritycheck6__c;
            cgnemail.givingprioritycheck7__c=CGNRec.givingprioritycheck7__c;
            cgnemail.givingprioritycheck8__c=CGNRec.givingprioritycheck8__c;
            cgnemail.RFP_Visibleity_on_Entry_Page__c=CGNRec.RFP_Visibleity_on_Entry_Page__c;
            cgnemail.RFP_Send_Email__c=CGNRec.RFP_Send_Email__c;
            cgnemail.Efg_Sub_Type__c=CGNRec.Efg_Sub_Type__c;
            //cgnemail.List_Of_email_attachment__c=CGNRec.List_Of_email_attachment__c;
            update cgnemail;
        }
        /*
List<gFRS_CGN_PLNG_Bulk_Email__c> lstcng=new  List<gFRS_CGN_PLNG_Bulk_Email__c>();
for(gFRS_CGN_PLNG_Bulk_Email__c cgnemail:[select Id, OwnerId,Name,CGN_PLNG_Title__c, Pre_Application_Queue__c, Start_Date__c, End_Date__c, CGN_PLNG_Status__c, Funding_Type__c, From_Date__c, To_Date__c, Pre_App_Type__c, invitationId__c, Survey_Link__c, gFRS_Funding_Request__c, Start_date_Validation__c, Purpose_of_CGN_PLNG__c, Users_to_whom_email_sent__c, Giving_Priorities_Alignment__c, From__c, Event_Program_Origin__c, Briefly_describe_the_intended_audience__c, Do_you_need_custom_questions__c, Event_Program_Origin_SRFG__c, Briefly_describe_intended_audience_SRFG__c, Event_Program_Origin_EFG__c, Briefly_describe_intended_audience_EFG__c, Event_Program_Origin_CG__c, Briefly_describe_intended_audience_CG__c, Event_Program_Origin_CME__c, Briefly_describe_intended_audience_CME__c, What_is_your_organization_s_annual_budge__c, How_many_employees_are_in_your_organizat__c, Sample_Question_Picklist_Multi_SRFG__c, Sample_Question_Radio_SRFG__c, phfgtext4__c, phfgtext5__c, phfgtext6__c, phfgtext8__c, phfgtext9__c, phfgtext10__c, phfgtext7__c, srfgtext4__c, srfgtext5__c, srfgtext6__c, srfgtext7__c, srfgtext8__c, srfgtext9__c, srfgtext10__c, cmetext7__c, cmetext8__c, cmetext9__c, cmetext10__c, cmetext11__c, cmetext12__c, efgtext1__c, efgtext5__c, efgtext2__c, efgtext3__c, efgtext6__c, efgtext4__c, efgtext7__c, efgtext8__c, efgtext9__c, efgtext10__c, cgtext1__c, cgtext2__c, cgtext4__c, cgtext3__c, cgtext5__c, cgtext6__c, cgtext7__c, cgtext8__c, cgtext9__c, cgtext10__c, foundtext5__c, foundtext2__c, foundtext1__c, foundtext3__c, foundtext4__c, foundtext6__c, foundtext7__c, foundtext8__c, foundtext9__c, foundtext10__c from gFRS_CGN_PLNG_Bulk_Email__c where id=:recordId]){        
cgnemail.phfgtext4__c=CGNRec.phfgtext4__c;
cgnemail.phfgtext5__c=CGNRec.phfgtext5__c;
cgnemail.phfgtext6__c=CGNRec.phfgtext6__c;
cgnemail.phfgtext7__c=CGNRec.phfgtext7__c;
lstcng.add(cgnemail);
}
update lstcng; 
*/
        /*     if(CGNRec.Survey_Link__c!=null){
System.PageReference pageReference = new System.PageReference(CGNRec.Survey_Link__c);
Map<String,String> parameters = pageReference.getParameters();
invitationId = parameters.get('invitationId'); //Hunter2dog&cat
surveyName = parameters.get('surveyName'); //user@example.com
formattedUrl = CGNRec.Survey_Link__c.replace('&','&amp;');
CGNRec.Survey_Link__c=formattedUrl;
CGNRec.invitationId__c=invitationId;
} */
        
        
        //system.debug('wc'+wc);
        //   update CGNRec;
        //system.debug('wCGNRecc'+CGNRec);
        
        
    }
    
    @AuraEnabled
    public static boolean CGNDuplicateCheck(string CGNTitle){
        
        list<gFRS_CGN_PLNG_Bulk_Email__c> CGNRec = new list<gFRS_CGN_PLNG_Bulk_Email__c>();
        CGNRec = [SELECT Id, Name,CGN_PLNG_Title__c FROM gFRS_CGN_PLNG_Bulk_Email__c WHERE CGN_PLNG_Title__c =:CGNTitle];
        if(CGNRec.size() == 0){
            return false;
        } else {
            return true;
        }
    } 
    
    @AuraEnabled
    public static boolean SendBulkEmail(Id attachId, String CGNTitle, Id CGNRecID, Id CGNPdfId, String mailCont,List<String> ccuser,String Fromaddress) {
        SendBulkEmailFuture(attachId, CGNTitle, CGNRecID, CGNPdfId, mailCont, ccuser, Fromaddress);
        return true;
    }    
    
    @Future
    public static void SendBulkEmailFuture(Id attachId, String CGNTitle, Id CGNRecID, Id CGNPdfId, String mailCont,List<String> ccuser,String Fromaddress) {
        if(attachId != null){
            list<string> emailList = new list<string>();
            Attachment attch = [SELECT Id, Name, Body,createdby.email FROM Attachment Where Id =:attachId];
            blob csvBlob = attch.Body;
            system.debug('Created Email is : '+attch.createdby.email);
            HttpRequest tmp = new HttpRequest();
            tmp.setBodyAsBlob(csvBlob);
            String value = tmp.getBody(); 
            String emailId = '';
            
            String[] filelines= value.split('\n');
            String userEmailList = '';
            System.debug('@@@@ File Lines'+filelines);
            System.debug('@@@@ File Size : '+filelines.size());
            Integer size = filelines.size() - 6;
            System.debug('@@@@ File Size new : '+size);
            for (Integer i=1; i < size; i++){
                String[] inputvalues = new String[]{};
                    inputvalues = filelines[i].split(',');
                system.debug('Email ID is : '+inputvalues[2]);
                emailId = inputvalues[2];
                emailId = emailId.replace('"','');
                emailList.add(emailId);
                userEmailList = userEmailList + emailId + ';';
            }
            
            EmailTemplate  emailCon=[SELECT Subject, Name, Id, Description, Body,DeveloperName
                                     FROM EmailTemplate
                                     WHERE DeveloperName = 'gFRS_CGN_PLNG_Bulk_Email' ];
            Attachment attchmt = new Attachment();
            if(CGNPdfId != null){
                attchmt = [SELECT Id, Name, Body,ContentType FROM Attachment Where Id =: CGNPdfId];
            }
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address=:Fromaddress];
            List<Messaging.SingleEmailMessage> emailGroup = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage emailRec = new Messaging.SingleEmailMessage();
            if(emailList.size()>0){
                
                for(String userMailId : emailList){
                    List<String> mailId = new List<String>();
                    mailId.add(userMailId);
                    string CGNTitleValue = CGNTitle;
                    CGNTitleValue = CGNTitleValue.replace(' ', '+');
                    String body = emailCon.Body;
                    System.debug('@@ Body'+body);
                    string communityURL = System.Label.gFRS_Ltng_Community_URL;
                    //String url = 'https://gfrsdev08-genentech-prod.cs60.force.com/gFRS/s/preapplication?CGNPLNGTitle=';
                    String url = 'https://cdcciam.gene.com/?sp=GFRS_PROD&redirectUrl=' + communityURL + 'preapplication?CGNPLNGTitle=';
                    url = url + CGNTitleValue + '&ThruMail=Yes';
                    body = body.replace('<<Link>>', url);
                    system.debug('Email Body : '+body);	
                    
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    
                    if ( owea.size() > 0 ) {
                        email.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                    
                    //string[] toAdd = new string[]{userEmailList};
                    //string[] ccAdd = new string[]{bcc};
                    // email.setToAddresses(new List<String> {'fundingrequestsystem-donotreply-d@gene.com'});
                    email.setBccAddresses(mailId);
                    email.setCcAddresses(ccuser);
                    //email.setCcAddresses(ccAdd);
                    email.setSubject(emailCon.Subject);
                    email.setPlainTextBody(mailCont);
                    
                    system.debug('CGN Pdf ID is : ' + CGNPdfId);
                    if(CGNPdfId != null){
                        //Attachment attchmt = [SELECT Id, Name, Body,ContentType FROM Attachment Where Id =: CGNPdfId];
                        Blob b = attchmt.Body;                    
                        String str='CNG/PLNG Detailed Information';
                        // Create the email attachment
                        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                        efa.setFileName(attchmt.Name);
                        efa.setBody(b);
                        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                    }                   
                    
                    //Messaging.Email[] emails = new Messaging.Email[]{email}; 
                    emailGroup.add(email);
                    emailRec = email;
                }    
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailGroup);
                if(results[0].success){
                    
                    try{
                        Attachment a       = new Attachment();
                        a.ParentId         = CGNRecID;
                        a.ContentType = '.pdf';
                        String fileContent = '';
                        
                        fileContent +='To: '+emailRec.toAddresses+'\n';
                        
                        if(emailRec.ccAddresses == null){
                            fileContent +='CC: \n';  
                        }else{
                            fileContent +='CC: '+emailRec.ccAddresses+'\n';
                        }
                        fileContent =fileContent.replace(')','').replace('(','');
                        fileContent +='Subject: '+emailRec.subject+'\n\n';
                        
                        
                        if(emailRec.plainTextBody != null){
                            fileContent += EncodingUtil.urlDecode(emailRec.plainTextBody,'UTF-8');
                        }  
                        
                        a.Body = Blob.valueOf(fileContent);  
                        a.Name = emailRec.subject + '.txt'; 
                        a.Description=emailRec.subject; 
                        
                        insert a;               
                        
                        gFRS_CGN_PLNG_Bulk_Email__c CGNRec = [SELECT Id, Name,Users_to_whom_email_sent__c FROM gFRS_CGN_PLNG_Bulk_Email__c WHERE Id =:CGNRecID];
                        CGNRec.Users_to_whom_email_sent__c = userEmailList;
                        //CGNRec.Attachmentrecid__c=a.id;
                        update CGNRec;
                        
                    }
                    catch(Exception e){
                        
                    } 
                } else{
                    
                } 
            }
            
        }
        
    }    
    
    @AuraEnabled
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachemnt Id after insert, 
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with reamins chunks   
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        } else {
            appendToFile(fileId, base64Data);
        }
        
        return Id.valueOf(fileId);
    }
    
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment oAttachment = new Attachment();
        oAttachment.parentId = parentId;
        
        oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        oAttachment.Name = fileName;
        oAttachment.ContentType = contentType;
        
        insert oAttachment;
        gFRS_CGN_PLNG_Bulk_Email__c CGNRec = [SELECT Id, Name,Attachmentrecid__c FROM gFRS_CGN_PLNG_Bulk_Email__c WHERE Id =:parentId];
        
        CGNRec.Attachmentrecid__c=oAttachment.id;
        update CGNRec;
        
        return oAttachment.Id;
    }
    
    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id =: fileId
        ];
        
        String existingBody = EncodingUtil.base64Encode(a.Body);
        
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
        
        update a;
    }
    @AuraEnabled
    public static list<GFRS_Funding_Request__c> getallRecords(Date myFromdate, Date myTodate, String myFundingList) {
        
        List<String> lstAlpha = myFundingList.split(';');
        
        System.debug('Funding Type : ' + lstAlpha);
        
        List<GFRS_Funding_Request__c> requestList = new List<GFRS_Funding_Request__c>();
        
        requestList = [SELECT Name, CreatedBy.Name, CreatedBy.Email FROM GFRS_Funding_Request__c where Funding_Type__c IN:lstAlpha AND Date_Submitted__c>=:myFromdate AND Date_Submitted__c<=:myTodate];
        system.debug('GFRS_Req_List : ' + requestList);
        
        return requestList;       
    }
    @AuraEnabled
    public static wrapperClass getCGN(Date startdate,Date enddate) {
        System.debug('--startdate--'+startdate);
        System.debug('--enddate--'+enddate);
        try{
            wrapperClass returnwrapperClass = new  wrapperClass ();
            List<gFRS_CGN_PLNG_Bulk_Email__c> lstcng=[SELECT Id,Start_Date__c,End_Date__c,CGN_PLNG_Status__c,CGN_PLNG_Title__c,Survey_Link__c,invitationId__c,Users_to_whom_email_sent__c,Do_you_need_custom_questions__c,Event_Program_Origin__c,Briefly_describe_the_intended_audience__c,Event_Program_Origin_SRFG__c,Briefly_describe_intended_audience_SRFG__c,Event_Program_Origin_EFG__c,Briefly_describe_intended_audience_EFG__c,Event_Program_Origin_CG__c,Briefly_describe_intended_audience_CG__c,Event_Program_Origin_CME__c,Briefly_describe_intended_audience_CME__c,Sample_Question_Picklist_Multi_SRFG__c,Sample_Question_Radio_SRFG__c,phfgtext4__c,phfgtext5__c,phfgtext6__c,phfgtext7__c,phfgtext8__c,phfgtext9__c,phfgtext10__c,srfgtext4__c,srfgtext5__c,srfgtext6__c,srfgtext7__c,srfgtext8__c,srfgtext9__c,srfgtext10__c,cmetext7__c,cmetext8__c,cmetext9__c,cmetext10__c,cmetext11__c,cmetext12__c,efgtext1__c,efgtext2__c,efgtext3__c,efgtext4__c,efgtext5__c,efgtext6__c,efgtext7__c,efgtext8__c,efgtext9__c,efgtext10__c,cgtext1__c,cgtext2__c,cgtext3__c,cgtext4__c,cgtext5__c,cgtext6__c,cgtext7__c,cgtext8__c,cgtext9__c,cgtext10__c,foundtext1__c,foundtext2__c,foundtext3__c,foundtext4__c,foundtext5__c,foundtext6__c,foundtext7__c,foundtext8__c,foundtext9__c,foundtext10__c 
                                                      FROM gFRS_CGN_PLNG_Bulk_Email__c where Start_Date__c<=:startdate AND End_Date__c>=:enddate and CGN_PLNG_Status__c=TRUE];
            for(gFRS_CGN_PLNG_Bulk_Email__c cgn:lstcng){
                if(cgn.Event_Program_Origin_CG__c==true){
                    returnwrapperClass.check1=true;
                }
                if(cgn.Briefly_describe_intended_audience_CG__c==true){
                    returnwrapperClass.check2=true;
                }
                if(cgn.Event_Program_Origin_CME__c==true){
                    returnwrapperClass.check3=true;
                }
                
                if(cgn.Briefly_describe_intended_audience_CME__c==true){
                    returnwrapperClass.check4=true;
                }
                if(cgn.Sample_Question_Picklist_Multi_SRFG__c==true){
                    returnwrapperClass.check5=true;
                }
                if(cgn.Sample_Question_Radio_SRFG__c==true){
                    returnwrapperClass.check6=true;
                }
                
                if(cgn.Event_Program_Origin__c==true){
                    returnwrapperClass.check7=true;
                }
                if(cgn.Briefly_describe_the_intended_audience__c==true){
                    returnwrapperClass.check8=true;
                }
                if(cgn.Event_Program_Origin_SRFG__c==true){
                    returnwrapperClass.check9=true;
                }
                if(cgn.Briefly_describe_intended_audience_SRFG__c==true){
                    returnwrapperClass.check10=true;
                }
                if(cgn.Event_Program_Origin_EFG__c==true){
                    returnwrapperClass.check11=true;
                }
                if(cgn.Briefly_describe_intended_audience_EFG__c==true){
                    returnwrapperClass.check12=true;
                }
                if(cgn.phfgtext4__c==true){
                    returnwrapperClass.phfgtext4=true;
                }
                if(cgn.phfgtext5__c==true){
                    returnwrapperClass.phfgtext5=true;
                }
                if(cgn.phfgtext6__c==true){
                    returnwrapperClass.phfgtext6=true;
                }
                if(cgn.phfgtext7__c==true){
                    returnwrapperClass.phfgtext7=true;
                }
                if(cgn.phfgtext8__c==true){
                    returnwrapperClass.phfgtext8=true;
                }
                if(cgn.phfgtext9__c==true){
                    returnwrapperClass.phfgtext9=true;
                }
                if(cgn.phfgtext10__c==true){
                    returnwrapperClass.phfgtext10=true;
                }
                
                if(cgn.srfgtext4__c==true){
                    returnwrapperClass.srfgtext4=true;
                }
                if(cgn.srfgtext5__c==true){
                    returnwrapperClass.srfgtext5=true;
                }
                if(cgn.srfgtext6__c==true){
                    returnwrapperClass.srfgtext6=true;
                }
                if(cgn.srfgtext7__c==true){
                    returnwrapperClass.srfgtext7=true;
                }
                if(cgn.srfgtext8__c==true){
                    returnwrapperClass.srfgtext8=true;
                }
                if(cgn.srfgtext9__c==true){
                    returnwrapperClass.srfgtext9=true;
                }
                if(cgn.srfgtext10__c==true){
                    returnwrapperClass.srfgtext10=true;
                }
                if(cgn.cmetext7__c==true){
                    returnwrapperClass.cmetext7=true;
                }
                if(cgn.cmetext8__c==true){
                    returnwrapperClass.cmetext8=true;
                }
                if(cgn.cmetext9__c==true){
                    returnwrapperClass.cmetext9=true;
                }
                if(cgn.cmetext10__c==true){
                    returnwrapperClass.cmetext10=true;
                }
                if(cgn.cmetext11__c==true){
                    returnwrapperClass.cmetext11=true;
                }
                if(cgn.cmetext12__c==true){
                    returnwrapperClass.cmetext12=true;
                }
                if(cgn.efgtext1__c==true){
                    returnwrapperClass.efgtext1=true;
                }
                if(cgn.efgtext2__c==true){
                    returnwrapperClass.efgtext2=true;
                }
                if(cgn.efgtext3__c==true){
                    returnwrapperClass.efgtext3=true;
                }
                if(cgn.efgtext4__c==true){
                    returnwrapperClass.efgtext4=true;
                }
                if(cgn.efgtext5__c==true){
                    returnwrapperClass.efgtext5=true;
                }
                if(cgn.efgtext6__c==true){
                    returnwrapperClass.efgtext6=true;
                }
                if(cgn.efgtext7__c==true){
                    returnwrapperClass.efgtext7=true;
                }
                if(cgn.efgtext8__c==true){
                    returnwrapperClass.efgtext8=true;
                }
                if(cgn.efgtext9__c==true){
                    returnwrapperClass.efgtext9=true;
                }
                if(cgn.efgtext10__c==true){
                    returnwrapperClass.efgtext10=true;
                }
                
                if(cgn.cgtext1__c==true){
                    returnwrapperClass.cgtext1=true;
                }
                if(cgn.cgtext2__c==true){
                    returnwrapperClass.cgtext2=true;
                }
                if(cgn.cgtext3__c==true){
                    returnwrapperClass.cgtext3=true;
                }
                if(cgn.cgtext4__c==true){
                    returnwrapperClass.cgtext4=true;
                }
                if(cgn.cgtext5__c==true){
                    returnwrapperClass.cgtext5=true;
                }
                if(cgn.cgtext6__c==true){
                    returnwrapperClass.cgtext6=true;
                }
                if(cgn.cgtext7__c==true){
                    returnwrapperClass.cgtext7=true;
                }
                if(cgn.cgtext8__c==true){
                    returnwrapperClass.cgtext8=true;
                }
                if(cgn.cgtext9__c==true){
                    returnwrapperClass.cgtext9=true;
                }
                if(cgn.cgtext10__c==true){
                    returnwrapperClass.cgtext10=true;
                }
                
                if(cgn.foundtext1__c==true){
                    returnwrapperClass.foundtext1=true;
                }
                if(cgn.foundtext2__c==true){
                    returnwrapperClass.foundtext2=true;
                }
                if(cgn.foundtext3__c==true){
                    returnwrapperClass.foundtext3=true;
                }
                if(cgn.foundtext4__c==true){
                    returnwrapperClass.foundtext4=true;
                }
                if(cgn.foundtext5__c==true){
                    returnwrapperClass.foundtext5=true;
                }
                if(cgn.foundtext6__c==true){
                    returnwrapperClass.foundtext6=true;
                }
                if(cgn.foundtext7__c==true){
                    returnwrapperClass.foundtext7=true;
                }
                if(cgn.foundtext8__c==true){
                    returnwrapperClass.foundtext8=true;
                }
                if(cgn.foundtext9__c==true){
                    returnwrapperClass.foundtext9=true;
                }
                if(cgn.foundtext10__c==true){
                    returnwrapperClass.foundtext10=true;
                }
                
            }
            return returnwrapperClass;  
        }
        
        
        catch(Exception e){
            system.debug('@@@:::'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj; 
            
        }
        
    }
    public class wrapperClass{
        @AuraEnabled public boolean check1{get;set;}
        @AuraEnabled public boolean check2{get;set;}
        @AuraEnabled public boolean check3{get;set;}
        @AuraEnabled public boolean check4{get;set;}
        @AuraEnabled public boolean check5{get;set;}
        @AuraEnabled public boolean check6{get;set;}
        @AuraEnabled public boolean check7{get;set;}
        @AuraEnabled public boolean check8{get;set;}
        @AuraEnabled public boolean check9{get;set;}
        @AuraEnabled public boolean check10{get;set;}
        @AuraEnabled public boolean check11{get;set;}
        @AuraEnabled public boolean check12{get;set;}
        @AuraEnabled public boolean phfgtext4{get;set;}
        @AuraEnabled public boolean phfgtext5{get;set;}
        @AuraEnabled public boolean phfgtext6{get;set;}
        @AuraEnabled public boolean phfgtext7{get;set;}
        @AuraEnabled public boolean phfgtext8{get;set;}
        @AuraEnabled public boolean phfgtext9{get;set;}
        @AuraEnabled public boolean phfgtext10{get;set;}
        
        @AuraEnabled public boolean srfgtext4{get;set;}
        @AuraEnabled public boolean srfgtext5{get;set;}
        @AuraEnabled public boolean srfgtext6{get;set;}
        @AuraEnabled public boolean srfgtext7{get;set;}
        @AuraEnabled public boolean srfgtext8{get;set;}
        @AuraEnabled public boolean srfgtext9{get;set;}
        @AuraEnabled public boolean srfgtext10{get;set;}
        
        @AuraEnabled public boolean cmetext7{get;set;}
        @AuraEnabled public boolean cmetext8{get;set;}
        @AuraEnabled public boolean cmetext9{get;set;}
        @AuraEnabled public boolean cmetext10{get;set;}
        @AuraEnabled public boolean cmetext11{get;set;}
        @AuraEnabled public boolean cmetext12{get;set;}
        
        @AuraEnabled public boolean efgtext1{get;set;}
        @AuraEnabled public boolean efgtext2{get;set;}
        @AuraEnabled public boolean efgtext3{get;set;}
        @AuraEnabled public boolean efgtext4{get;set;}
        @AuraEnabled public boolean efgtext5{get;set;}
        @AuraEnabled public boolean efgtext6{get;set;}
        @AuraEnabled public boolean efgtext7{get;set;}
        @AuraEnabled public boolean efgtext8{get;set;}
        @AuraEnabled public boolean efgtext9{get;set;}
        @AuraEnabled public boolean efgtext10{get;set;}
        
        @AuraEnabled public boolean cgtext1{get;set;}
        @AuraEnabled public boolean cgtext2{get;set;}
        @AuraEnabled public boolean cgtext3{get;set;}
        @AuraEnabled public boolean cgtext4{get;set;}
        @AuraEnabled public boolean cgtext5{get;set;}
        @AuraEnabled public boolean cgtext6{get;set;}
        @AuraEnabled public boolean cgtext7{get;set;}
        @AuraEnabled public boolean cgtext8{get;set;}
        @AuraEnabled public boolean cgtext9{get;set;}
        @AuraEnabled public boolean cgtext10{get;set;}
        
        @AuraEnabled public boolean foundtext1{get;set;}
        @AuraEnabled public boolean foundtext2{get;set;}
        @AuraEnabled public boolean foundtext3{get;set;}
        @AuraEnabled public boolean foundtext4{get;set;}
        @AuraEnabled public boolean foundtext5{get;set;}
        @AuraEnabled public boolean foundtext6{get;set;}
        @AuraEnabled public boolean foundtext7{get;set;}
        @AuraEnabled public boolean foundtext8{get;set;}
        @AuraEnabled public boolean foundtext9{get;set;}
        @AuraEnabled public boolean foundtext10{get;set;}
    }
    
    @AuraEnabled
    public static boolean editRfpTitle(String recordId){
        boolean Rfptitlestatus=false;
        for(gFRS_CGN_PLNG_Bulk_Email__c cgn:[SELECT Id,CGN_PLNG_Status__c FROM gFRS_CGN_PLNG_Bulk_Email__c where id=:recordId LIMIT 1]){
            if(cgn.CGN_PLNG_Status__c==TRUE){
                Rfptitlestatus=true;
                return Rfptitlestatus;
            }
        }
        return Rfptitlestatus;
    }
    @AuraEnabled
    public static gFRS_CGN_PLNG_Bulk_Email__c editRfpTitle_doinit(String recordId) {
        
        try{
            if(recordId!=null){
                return [select Id,standquestion1__c,SkipRFPCheck__c,standquestion2__c,standquestion3__c,standquestion4__c,standquestion5__c,standquestion6__c,RFP_CC_User__c,givingprioritycheck7__c,givingprioritycheck8__c,Attachmentrecid__c,Efg_Sub_Type__c,List_Of_email_attachment__c,RFP_Visibleity_on_Entry_Page__c,RFP_Send_Email__c,givingprioritycheck1__c,givingprioritycheck2__c,givingprioritycheck3__c,givingprioritycheck4__c,givingprioritycheck5__c,givingprioritycheck6__c,Email_Body__c,OwnerId,Name,CGN_PLNG_Title__c, Pre_Application_Queue__c, Start_Date__c, End_Date__c, CGN_PLNG_Status__c, Funding_Type__c, From_Date__c, To_Date__c, Pre_App_Type__c, invitationId__c, Survey_Link__c, gFRS_Funding_Request__c, Start_date_Validation__c, Purpose_of_CGN_PLNG__c, Users_to_whom_email_sent__c, Giving_Priorities_Alignment__c, From__c, Event_Program_Origin__c, Briefly_describe_the_intended_audience__c, Do_you_need_custom_questions__c, Event_Program_Origin_SRFG__c, Briefly_describe_intended_audience_SRFG__c, Event_Program_Origin_EFG__c, Briefly_describe_intended_audience_EFG__c, Event_Program_Origin_CG__c, Briefly_describe_intended_audience_CG__c, Event_Program_Origin_CME__c, Briefly_describe_intended_audience_CME__c, What_is_your_organization_s_annual_budge__c, How_many_employees_are_in_your_organizat__c, Sample_Question_Picklist_Multi_SRFG__c, Sample_Question_Radio_SRFG__c, phfgtext4__c, phfgtext5__c, phfgtext6__c, phfgtext8__c, phfgtext9__c, phfgtext10__c, phfgtext7__c, srfgtext4__c, srfgtext5__c, srfgtext6__c, srfgtext7__c, srfgtext8__c, srfgtext9__c, srfgtext10__c, cmetext7__c, cmetext8__c, cmetext9__c, cmetext10__c, cmetext11__c, cmetext12__c, efgtext1__c, efgtext5__c, efgtext2__c, efgtext3__c, efgtext6__c, efgtext4__c, efgtext7__c, efgtext8__c, efgtext9__c, efgtext10__c, cgtext1__c, cgtext2__c, cgtext4__c, cgtext3__c, cgtext5__c, cgtext6__c, cgtext7__c, cgtext8__c, cgtext9__c, cgtext10__c, foundtext5__c, foundtext2__c, foundtext1__c, foundtext3__c, foundtext4__c, foundtext6__c, foundtext7__c, foundtext8__c, foundtext9__c, foundtext10__c from gFRS_CGN_PLNG_Bulk_Email__c where id=:recordId];
            }else{
                return null;
            }
        }catch(Exception e){
            system.debug('@@@:::'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
        
    }
    
}