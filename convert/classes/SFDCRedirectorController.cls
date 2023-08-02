/********************************************************************************************
Name   : SFDCRedirectorController
Usage  : Controller class of SFDCRedirector VF page.
Author : Vinod@Appirio
Date   : 12/08/2009

This is just a utility controller class that, based on the incoming URL parameters, redirects
to proper SFDC page.  This controller and its VF are built to be used by URL requests from
gCal UI.  The goal of this VF is to,

1.  map Call2Vod to Account to show users Account pages.
2.  take users to special headerless Call2vod customized (re-used from standard call2vod layout)
    headerless pages to be presented within gCal page (canvas mash-up).
3.  add any custom URL parameters as needed.
********************************************************************************************/
public class SFDCRedirectorController{
    String INTERACTION_CONSTANT = 'INTERACTION';
    String MEDICAL_EVENT_CONSTANT = 'MEDICAL_EVENT';    
    String ACCOUNT_CONSTANT     = 'ACCOUNT';
    String CREATE_INTERACTION_CONSTANT = 'CREATE_INTERACTION';
    String SAVE_INTERACTION_CONSTANT = 'SAVE_INTERACTION';
    String GCAL_TO_SFDC_REDIRECT_TYPE_CONSTANT = 'REDIRECT_GCAL_TO_SFDC';
    String SFDC_TO_GCAL_REDIRECT_TYPE_CONSTANT = 'REDIRECT_SFDC_TO_GCAL';    
    String ACCOUNT_ID_CONSTANT  = 'account_id';
    String REDIRECTTYPE_CONSTANT= 'redirectType';
    String REDIRECTIDTYPE_CONSTANT='redirectIdType';
    String ID_CONSTANT          = 'id';    
    String DATE_TIME_CONSTANT   = 'stdt';
    String RETURL_CONSTANT      = 'retURL';    
    String SAVEURL_CONSTANT     = 'saveURL';       
    String GCALID_CONSTANT      = 'gCalId'; 
    String PAGE_MODE_CONSTANT   = 'pageMode';
    String GOOGLE_GCAL_ENVIRONMENT_VAR_NAME_CONSTANT = 'GNE_gCal_URL';
    String MYACCOUNTS_WEBTAB_VOD_ID_ENVIRONMENT_VAR_NAME_CONSTANT  ='GNE_MyAccounts_vod_WebTab_ID';
    
    String HEADERLESS_CALL2VOD_VIEW_PAGE_CONSTANT = '/apex/InteractionViewWrapperPage';
    //String HEADERLESS_CALL2VOD_VIEW_PAGE_CONSTANT = '/apex/InteractionEditIncludeModulePage';
   
    String HEADERLESS_CALL2VOD_EDIT_PAGE_CONSTANT = '/apex/InteractionEditWrapperPage';
    //String HEADERLESS_CALL2VOD_EDIT_PAGE_CONSTANT = '/apex/InteractionEditIncludeModulePage';
    String HEADERLESS_CALL_ACCOUNT_PICKER_PAGE_CONSTANT = '/apex/AccountStandarDetailWithNoHeader';
    String HEADERLESS_MEDICAL_EVENT_PAGE_CONTSTANT = '/apex/MedicalEventVodDetailWithoutHeader';
    String HEADERLESS_CREATE_INTERACTION_ACC_PICKER_PAGE_CONTSTANT = '/apex/MyPreferredAccounts';
    String HEADERLESS_SFDC_TO_GCAL_REDIRECT_PROGRESS_PAGE_CONSTANT = '/apex/SFDCToGCalRedirectProgressPage';
    String HEADERLESS_GCAL_TO_SFDC_REDIRECT_PROGRESS_PAGE_CONSTANT = '/apex/GCalToSFDCRedirectProgressPage';
    
    String nextURL   = '';
    String redirectType   = this.INTERACTION_CONSTANT; // we expect ACCOUNT if use needs to be taken to Account
    String redirectIdType = this.INTERACTION_CONSTANT;
    Boolean showHeader    = false; // by default this is what we always expect
    
    String objId          = null;    
    
    String retURL         = null;
    String saveURL        = null;
    String stdt           = null;
    String gCalId         = null;
    String pageMode       = 'VIEW';
    public String gCalURL {get;set;} 
    String myAccountsWebtabUrl = null;
    PageReference nextPage = null;
    String userProfileName = '';
    
    public SFDCRedirectorController(ApexPages.StandardController controller)
    {
        initControllers();
    }
    
    public SFDCRedirectorController() 
    {
        initControllers();
    }
    
    private void initControllers()
    {
        gCalURL = null;
        loadEnvironmentVars();
         
        try{
            redirectType   = ApexPages.currentPage().getParameters().get(this.REDIRECTTYPE_CONSTANT);
        }catch(Exception rdtE){
            // do nothing...
            redirectType   = this.INTERACTION_CONSTANT;
            
        }
        
        try{
            redirectIdType = ApexPages.currentPage().getParameters().get(this.REDIRECTIDTYPE_CONSTANT);
        }catch(Exception ridtE){
            // do nothing...
            redirectIdType = this.INTERACTION_CONSTANT;
        }
        
        try{
            objId        = ApexPages.currentPage().getParameters().get(this.ID_CONSTANT);
        }catch(Exception oIdE){
            // no problem some of the redirects does not require obj ID
            // do nothing here
            objId = null;
        }
                
        try{
            stdt         = ApexPages.currentPage().getParameters().get(this.DATE_TIME_CONSTANT);
        }catch(Exception oIdE){
            // do nothing here
            stdt         = null;
        }
         
        try{
            retURL = ApexPages.currentPage().getParameters().get(this.RETURL_CONSTANT);
        }catch(Exception oIdE){
            // do nothing here
            retURL = null;
        }

        try{
            saveURL = ApexPages.currentPage().getParameters().get(this.SAVEURL_CONSTANT);
        }catch(Exception oIdE){
            // do nothing here
            saveURL = null;
        }
                 
        try{
            gCalId = ApexPages.currentPage().getParameters().get(this.GCALID_CONSTANT);
        }catch(Exception oIdE){
            // do nothing here
            gCalId = null;
        }
                  
        try{
            pageMode = ApexPages.currentPage().getParameters().get(this.PAGE_MODE_CONSTANT);
        }catch(Exception pME){
            // do nothing here
            pageMode = 'VIEW';
        }
                   
        try{
            ID userId = UserInfo.getUserId();
            User currentUserRecord = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()]; 
            userProfileName        = currentUserRecord.Profile.Name;        
        }catch(Exception upE){
            userProfileName = '';
        }          
                                              
    }
    
    // using the current parameters, this method determines and redirects users to the 
    // proper nextPage
    public PageReference redirectMe(){
        try
      {
        Boolean redirectTypeFlat = true;
        
        if(redirectType.equalsIgnoreCase(this.INTERACTION_CONSTANT) && pageMode.equalsIgnoreCase('VIEW') ){
            // send users to headerless call2vod page if its a valid ID, if not send them to a error page
            // VINOD: RE-DESIGN - now take the users to SFDC pages, no more mash-ups
            // nextPage  = new PageReference(this.HEADERLESS_CALL2VOD_VIEW_PAGE_CONSTANT + '?id=' + objId);
            nextPage  = new PageReference('/' + objId);
            try{
                Call2_vod__c viewCall   = [select id from call2_vod__c where id = :objId];
                if(viewCall == null){
                    nextPage = new PageReference('/apex/GNE_CleanErrorPage');
                }else{
                    nextPage  = new PageReference('/'+objId);
                }               
            }catch(Exception vc){
                // bad id
                nextPage = new PageReference('/apex/GNE_CleanErrorPage'); 
            }
        }else if(redirectType.equalsIgnoreCase(this.INTERACTION_CONSTANT) && pageMode.equalsIgnoreCase('EDIT') ){
            // send users to headerless call2vod page
            //nextPage  = new PageReference(this.HEADERLESS_CALL2VOD_EDIT_PAGE_CONSTANT + '?id=' + objId);
            nextPage  = new PageReference('/' + objId + '/e?retURL=' + this.HEADERLESS_SFDC_TO_GCAL_REDIRECT_PROGRESS_PAGE_CONSTANT);
            try{
                Call2_vod__c editCall   = [select id from call2_vod__c where id = :objId];
                if(editCall == null){
                    nextPage = new PageReference('/apex/GNE_CleanErrorPage');
                }else{
                    nextPage  = new PageReference('/' + objId + '/e?retURL=' + this.HEADERLESS_SFDC_TO_GCAL_REDIRECT_PROGRESS_PAGE_CONSTANT);
                }               
            }catch(Exception ec){
                // bad id
                nextPage = new PageReference('/apex/GNE_CleanErrorPage'); 
            }
                        
        }else if(redirectType.equalsIgnoreCase(this.ACCOUNT_CONSTANT) ){
            // send users to headerless call2vod page
            try{
                Call2_vod__c myCall    = [select Account_vod__c from call2_vod__c where Parent_Call_vod__c = null and id=:objId];
                if(myCall != null){
                    objId                  = myCall.Account_vod__c;
                    //VINOD: REDESIGN  
                    //nextPage  = new PageReference(this.HEADERLESS_CALL_ACCOUNT_PICKER_PAGE_CONSTANT + '?id=' + myCall.Account_vod__c);                    
                    nextPage  = new PageReference('/'+ myCall.Account_vod__c + '?retURL=' + this.HEADERLESS_SFDC_TO_GCAL_REDIRECT_PROGRESS_PAGE_CONSTANT);
                }else{
                    nextPage = new PageReference('/apex/GNE_CleanErrorPage');
                }               
            }catch(Exception caE){
                // bad id
                nextPage = new PageReference('/apex/GNE_CleanErrorPage');
            }

        }else if(redirectType.equalsIgnoreCase(this.MEDICAL_EVENT_CONSTANT) ){
            nextPage  = new PageReference('/' + objId + '?retURL=' + this.HEADERLESS_SFDC_TO_GCAL_REDIRECT_PROGRESS_PAGE_CONSTANT);
        }else if(redirectType.equalsIgnoreCase(this.CREATE_INTERACTION_CONSTANT) ){    
        
            // VINOD:RE-DESIGN - all users now need to go to regular My Accounts page
            // for interaction creation            
            nextPage         = new PageReference(this.HEADERLESS_GCAL_TO_SFDC_REDIRECT_PROGRESS_PAGE_CONSTANT + '?retURL=' + this.HEADERLESS_SFDC_TO_GCAL_REDIRECT_PROGRESS_PAGE_CONSTANT);
        }else if(redirectType.equalsIgnoreCase(this.SAVE_INTERACTION_CONSTANT) ){
            // Create Call object, assign the account passsed
            // associate it with current user, defaulting it to current date and 8am
            // take the user to the just created interaction
            Id accountId          = null;
            Call2_vod__c nCall    = new Call2_vod__c();
            try{
                accountId           = ApexPages.currentPage().getParameters().get(this.ACCOUNT_ID_CONSTANT);                
                nCall.Account_vod__c= accountId;
                nCall.User_vod__c   = UserInfo.getUserId();
                // set the time to 8am PST for the current day
                nCall.Call_Datetime_vod__c = System.now();
                
                upsert nCall;      
            }catch(Exception oIdE){
                // this should not happen, throw exception so we can display it on the error page...                
            }           
                        
            nextPage  = new PageReference(this.HEADERLESS_CALL2VOD_EDIT_PAGE_CONSTANT + '?id=' + nCall.id );
        }else if(redirectType.equalsIgnoreCase(this.GCAL_TO_SFDC_REDIRECT_TYPE_CONSTANT) ){ 
            nextPage  = new PageReference(this.HEADERLESS_GCAL_TO_SFDC_REDIRECT_PROGRESS_PAGE_CONSTANT);
            //nextPage.getParameters().put(this.RETURL_CONSTANT, getmyAccountsWebtabUrl());
        }else if(redirectType.equalsIgnoreCase(this.SFDC_TO_GCAL_REDIRECT_TYPE_CONSTANT) ){ 
            nextPage  = new PageReference(this.HEADERLESS_SFDC_TO_GCAL_REDIRECT_PROGRESS_PAGE_CONSTANT);
            //nextPage.getParameters().put(this.RETURL_CONSTANT, getGCalURL());            
        }else{
            // send users to my accounts page, because that page does not require a ID and 
            // we may be in this condition with/without a ID in the URL parameter, so it is safe that way
            nextPage  = new PageReference(this.HEADERLESS_GCAL_TO_SFDC_REDIRECT_PROGRESS_PAGE_CONSTANT);
        }           
            
        if(retURL != null)
            nextPage.getParameters().put(this.RETURL_CONSTANT, retURL);
            
        if(saveURL != null)
            nextPage.getParameters().put(this.SAVEURL_CONSTANT, saveURL);            
        
        if(stdt!= null)
            nextPage.getParameters().put(this.DATE_TIME_CONSTANT, stdt);   
                                        
        if(gCalId!= null)
            nextPage.getParameters().put(this.GCALID_CONSTANT, gCalId ); 
            
        if(objId != null)
            nextPage.getParameters().put(this.ID_CONSTANT, objId);             
                         
        nextPage.setRedirect(true);
      }
      catch(Exception e)
      {
        nextPage = new PageReference('/apex/GNE_CleanErrorPage');
        nextPage.setRedirect(true);
      }               
      return nextPage;
    }
    
   // using the current parameters, this method determines and redirects users to the 
    // proper nextPage
    public PageReference redirectTo(){
        try
      {
        Boolean redirectTypeFlat = true;
        
        if(redirectType.equalsIgnoreCase(this.INTERACTION_CONSTANT) && pageMode.equalsIgnoreCase('VIEW') ){
            // send users to headerless call2vod page if its a valid ID, if not send them to a error page
            // VINOD: RE-DESIGN - now take the users to SFDC pages, no more mash-ups
            // nextPage  = new PageReference(this.HEADERLESS_CALL2VOD_VIEW_PAGE_CONSTANT + '?id=' + objId);
            nextPage  = new PageReference('/' + objId);
            try{
                Call2_vod__c viewCall   = [select id from call2_vod__c where id = :objId];
                if(viewCall == null){
                    nextPage = new PageReference('/apex/GNE_CleanErrorPage');
                }else{
                    nextPage  = new PageReference('/'+objId + '?retURL=' + this.HEADERLESS_SFDC_TO_GCAL_REDIRECT_PROGRESS_PAGE_CONSTANT);
                }               
            }catch(Exception vc){
                // bad id
                nextPage = new PageReference('/apex/GNE_CleanErrorPage'); 
            }
        }else if(redirectType.equalsIgnoreCase(this.INTERACTION_CONSTANT) && pageMode.equalsIgnoreCase('EDIT') ){
            // send users to headerless call2vod page
            //nextPage  = new PageReference(this.HEADERLESS_CALL2VOD_EDIT_PAGE_CONSTANT + '?id=' + objId);
            nextPage  = new PageReference('/' + objId + '/e?retURL=' + this.HEADERLESS_SFDC_TO_GCAL_REDIRECT_PROGRESS_PAGE_CONSTANT);
            try{
                Call2_vod__c editCall   = [select id from call2_vod__c where id = :objId];
                if(editCall == null){
                    nextPage = new PageReference('/apex/GNE_CleanErrorPage');
                }else{
                    nextPage  = new PageReference('/' + objId + '/e?retURL=' + this.HEADERLESS_SFDC_TO_GCAL_REDIRECT_PROGRESS_PAGE_CONSTANT);
                }               
            }catch(Exception ec){
                // bad id
                nextPage = new PageReference('/apex/GNE_CleanErrorPage'); 
            }
                        
        }else if(redirectType.equalsIgnoreCase(this.ACCOUNT_CONSTANT) ){
            // send users to headerless call2vod page
            try{
                Call2_vod__c myCall    = [select Account_vod__c from call2_vod__c where Parent_Call_vod__c = null and id=:objId];
                if(myCall != null){
                    objId                  = myCall.Account_vod__c;
                    //VINOD: REDESIGN  
                    //nextPage  = new PageReference(this.HEADERLESS_CALL_ACCOUNT_PICKER_PAGE_CONSTANT + '?id=' + myCall.Account_vod__c);                    
                    nextPage  = new PageReference('/'+ myCall.Account_vod__c + '?retURL=' + this.HEADERLESS_SFDC_TO_GCAL_REDIRECT_PROGRESS_PAGE_CONSTANT);
                }else{
                    nextPage = new PageReference('/apex/GNE_CleanErrorPage');
                }               
            }catch(Exception caE){
                // bad id
                nextPage = new PageReference('/apex/GNE_CleanErrorPage');
            }

        }else if(redirectType.equalsIgnoreCase(this.MEDICAL_EVENT_CONSTANT) ){
            nextPage  = new PageReference('/' + objId + '?retURL=' + this.HEADERLESS_SFDC_TO_GCAL_REDIRECT_PROGRESS_PAGE_CONSTANT);
        }else if(redirectType.equalsIgnoreCase(this.CREATE_INTERACTION_CONSTANT) ){    
        
            // VINOD:RE-DESIGN - all users now need to go to regular My Accounts page
            // for interaction creation            
            nextPage         = new PageReference(this.HEADERLESS_GCAL_TO_SFDC_REDIRECT_PROGRESS_PAGE_CONSTANT  + '?retURL=' + this.HEADERLESS_SFDC_TO_GCAL_REDIRECT_PROGRESS_PAGE_CONSTANT);
        }else if(redirectType.equalsIgnoreCase(this.SAVE_INTERACTION_CONSTANT) ){
            // Create Call object, assign the account passsed
            // associate it with current user, defaulting it to current date and 8am
            // take the user to the just created interaction
            Id accountId          = null;
            Call2_vod__c nCall    = new Call2_vod__c();
            try{
                accountId           = ApexPages.currentPage().getParameters().get(this.ACCOUNT_ID_CONSTANT);                
                nCall.Account_vod__c= accountId;
                nCall.User_vod__c   = UserInfo.getUserId();
                // set the time to 8am PST for the current day
                nCall.Call_Datetime_vod__c = System.now();
                
                upsert nCall;      
            }catch(Exception oIdE){
                // this should not happen, throw exception so we can display it on the error page...                
            }           
                        
            //nextPage  = new PageReference(this.HEADERLESS_CALL2VOD_EDIT_PAGE_CONSTANT + '?id=' + nCall.id );
             nextPage  = new PageReference('/' + nCall.id + '?retURL=' + this.HEADERLESS_SFDC_TO_GCAL_REDIRECT_PROGRESS_PAGE_CONSTANT);
        }else if(redirectType.equalsIgnoreCase(this.GCAL_TO_SFDC_REDIRECT_TYPE_CONSTANT) ){ 
            nextPage  = new PageReference(this.HEADERLESS_GCAL_TO_SFDC_REDIRECT_PROGRESS_PAGE_CONSTANT);
            //nextPage.getParameters().put(this.RETURL_CONSTANT, getmyAccountsWebtabUrl());
        }else if(redirectType.equalsIgnoreCase(this.SFDC_TO_GCAL_REDIRECT_TYPE_CONSTANT) ){ 
            nextPage  = new PageReference(this.HEADERLESS_SFDC_TO_GCAL_REDIRECT_PROGRESS_PAGE_CONSTANT);
            //nextPage.getParameters().put(this.RETURL_CONSTANT, getGCalURL());            
        }else{
            // send users to my accounts page, because that page does not require a ID and 
            // we may be in this condition with/without a ID in the URL parameter, so it is safe that way
            nextPage  = new PageReference(this.HEADERLESS_GCAL_TO_SFDC_REDIRECT_PROGRESS_PAGE_CONSTANT);
        }           
            
        if(retURL != null)
            nextPage.getParameters().put(this.RETURL_CONSTANT, retURL);
            
        if(saveURL != null)
            nextPage.getParameters().put(this.SAVEURL_CONSTANT, saveURL);            
        
        if(stdt!= null)
            nextPage.getParameters().put(this.DATE_TIME_CONSTANT, stdt);   
                                        
        if(gCalId!= null)
            nextPage.getParameters().put(this.GCALID_CONSTANT, gCalId ); 
            
        if(objId != null)
            nextPage.getParameters().put(this.ID_CONSTANT, objId);             
                         
        nextPage.setRedirect(true);
      }
      catch(Exception e)
      {
        nextPage = new PageReference('/apex/GNE_CleanErrorPage');
        nextPage.setRedirect(true);
      }               
      return nextPage;
    }
        
    /**
    ** A utility method to load environment variables used for Unified Calendar project
    */
    public void loadEnvironmentVars() {
        String username = UserInfo.getUserName();
        String emailAddress = UserInfo.getUserEmail();
        String env='';        
        String myAccountsWebtabId = null;
        List<Environment_Variables__c> environment_vars = new List<Environment_Variables__c>();
    
        try{
            if(username.indexOf('@gene.com.dev') > 0) 
                env='dev'; 
            else if(username.indexOf('@gene.com.sqa') > 0) 
                env= 'sqa'; 
            else if(username.indexOf('@gene.com.mig') >0)
                env='mig';
            else if(username.indexOf('@gene.com.uat') > 0) 
                env= 'uat'; 
            else if(username.indexOf('@gene.com.misc') > 0) 
                env= 'misc'; 
            else if(username.indexOf('@gene.com.ord') > 0) 
                env= 'ord'; 
            else if(username.indexOf('@gene.com.sfa') > 0) 
                env= 'sfa'; 
            else if(username.indexOf('@gene.com.cm') > 0) 
                env= 'cm'; 
            else if(username.indexOf('@gene.com') > 0 && username.indexOf('@gene.com.') <0) {
                env= 'prod';
                if(emailAddress.indexOf('@roche.com') > 0) 
                   env= 'prodcan'; 
            } else if(username.indexOf('@roche.com') > 0) 
                env= 'prodcan'; 
            else if(username.indexOf('@gene.com.') >0){
                env=username.Substring(username.indexOf('@gene.com.')+10, username.length());
            }else{
                env='sqa';
            }
            
            environment_vars=[Select Environment__c, Key__c, Value__c 
                          from Environment_Variables__c 
                          where Key__c in ('GNE_gCal_URL', 'GNE_MyAccounts_vod_WebTab_ID') 
                          and Environment__c = :env ]; 
  
            for (integer i = 0; i < environment_vars.size(); i++)
            {
                if(environment_vars[i].Key__c == 'GNE_gCal_URL')
                    gCalURL = environment_vars[i].Value__c;                
                 
                if(environment_vars[i].Key__c == 'GNE_MyAccounts_vod_WebTab_ID')
                    myAccountsWebtabId = environment_vars[i].Value__c;
            }
            
            if(gCalURL == null)
                gCalURL = 'https://www.google.com/calendar/hosted/dnapoc.com/render';
                
            if(myAccountsWebtabId != null)
                myAccountsWebtabUrl = '/servlet/servlet.Integration?ic=1&lid=' + myAccountsWebtabId;
            else
                myAccountsWebtabUrl = '/home/home.jsp';
                
                
        }catch(Exception eVarE){
            gCalURL = 'https://www.google.com/calendar/hosted/dnapoc.com/render';
            myAccountsWebtabUrl = '/home/home.jsp';
        }
    }                       
    
    public String getGCalURL(){
        return gCalURL;
    }
    
    public String getmyAccountsWebtabUrl(){
        return myAccountsWebtabUrl;
    }
    
    public String getNextPage(){
        return nextPage.getUrl();
    }       
    
    public PageReference forwardMe(){
        return nextPage;
    }
    
    public String getNextUrl(){
        redirectTo();
        return nextPage.getUrl();
    }
}