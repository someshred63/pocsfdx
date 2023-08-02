public class ShowMessageController {
    static String MSG_ID    = 'msgid';
    static String FRQ_USER_MSG = 'INFU_FRQ_MSG';
    static String NON_INFU_INTERACTION_MSG='NON_INFU_INTERACTION_MSG';
    static String SPENDUSER_NOT_EXIST = 'SPENDUSER_NOT_EXIST';
    static String INF_USER_PLEASE_VALIDATE = 'INF_USER_PLEASE_VALIDATE';
    static String INF_USER_PLEASE_VALIDATE_FOLLOW = 'INF_USER_PLEASE_VALIDATE_FOLLOW';
    static String INF_USER_CONFIRM_COMPLIANCE = 'INF_USER_CONFIRM_COMPLIANCE';
    static String INF_USER_CONFIRM_COMPLIANCE_MANGER = 'INF_USER_CONFIRM_COMPLIANCE_MANGER';
    static String INF_USER_ACK_LIMIT_REACHED = 'INF_USER_ACK_LIMIT_REACHED';
    static String INF_USER_ACK_LEGAL_LIMIT_REACHED = 'INF_USER_ACK_LEGAL_LIMIT_REACHED';
    //Added to show message for INCORRECT user
    static String INCORRECT_INFREQUENT_USER = 'INCORRECT_INFREQUENT_USER';
    static String INF_USER_ACK_ACTION = 'INF_USER_ACK_ACTION';
    static String INVALID_INTERACTION_ID = 'INVALID_INTERACTION_ID';
     
     
    public String MessageID{get;set;}
    public String Message{get;set;}
     public String Link{get;set;}
      public String LinkLabel{get;set;}
     public boolean showbutton {get;set;}
    
    public ShowMessageController(){ 
        
        MessageID = ApexPages.currentPage().getParameters().get(MSG_ID);
        showbutton=True;
        if (MessageID == FRQ_USER_MSG)
        {
            List<Ags_Email_Links__c> el=[Select name,AGS_b2b_link__c,AGS_commportal_link__c,AGS_Training_Link__c from AGS_Email_Links__c ];
            Link = el[0].ags_commportal_link__c;
            LinkLabel = el[0].ags_commportal_link__c; 
            Message = 'Please use salesforce.com (access via Commercial Portal) to record your interaction & HCP meal information.- ';
        }
        if (MessageID == NON_INFU_INTERACTION_MSG){
            List<Ags_Email_Links__c> el=[Select name,AGS_b2b_link__c,AGS_commportal_link__c,AGS_Training_Link__c from AGS_Email_Links__c ];
            Link = el[0].ags_commportal_link__c;
            LinkLabel = el[0].ags_commportal_link__c;
           // Message = 'Please ensure your interaction(s) in salesforce.com is marked as completed - <a href=http://commportal.gene.com target=comm>commportal.gene.com</a>'; 
            Message = 'Chosen interaction was created in salesforce.com. To modify the interaction please go to  - '; 
        }

        
        if (MessageID == INF_USER_PLEASE_VALIDATE){
            Message='The following confirmation has been submitted';
        }
        
        if (MessageID == INF_USER_PLEASE_VALIDATE_FOLLOW){
            //Message='I confirm that I have taken the steps necessary to make appropriate corrections.';
            Message='Thank you for your confirmation. \n Please close the browser window.';
            showbutton=False;
        }
        
        if (MessageID == INF_USER_CONFIRM_COMPLIANCE){
            //Message='I confirm that I understand this Compliance.';
            Message='Thank you for confirming your understanding of Genentech Compliance Policy on HCP meal spend. \n No further action is required at this time.\n Please close the browser window.';
            showbutton=False;
        }
        
        if (MessageID == INF_USER_CONFIRM_COMPLIANCE_MANGER){
            //Message='I confirm that I understand this Compliance.';
            Message='Thank you for confirming your understanding of Genentech’s policy on HCP meal spend.\n Please close the browser window.';
            showbutton=False;
        }
        
        if (MessageID == INF_USER_ACK_LIMIT_REACHED){
            //Message='I confirm that I understand this Compliance.';
            Message='Thank you for acknowledging that the spending limit has been reached and agreeing to refrain from any additional spend with this HCP for this calendar year.\n Please close the browser window.';
            showbutton=False;
        }
        
        if (MessageID == INF_USER_ACK_LEGAL_LIMIT_REACHED){
            //Message='I confirm that I understand this Compliance.';
            Message='Thank you for acknowledging that the spending limit has been reached and agreeing to refrain from any additional spend with this HCP for this calendar year.\n Please close the browser window.';
            showbutton=False;
        }

        if (MessageID == SPENDUSER_NOT_EXIST){
            Message = 'Spend User does not exist in the System, please contact Help Desk. \n To exit close the browser window.';
        	showbutton=False;
        }
        
        if (MessageID == INCORRECT_INFREQUENT_USER){
            Message = 'This CASE Action is not assigned for you.\n To exit close the browser window.';  
             showbutton=False;         
        }
        
        if (MessageID == INVALID_INTERACTION_ID){
            Message = 'Invalid or incorrect Interaction Id.\n To exit close the browser window.'; 
            showbutton=False;          
        }
        
    }
    
    public PageReference submitMessage()
    {
        
        return null;
    }
    
    
    
}