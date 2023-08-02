public without sharing class IRecord 
{  
    
    /***********************************************
    * Project Name          : Infrequent User Interaction Record
    * File                  : IRecord.cls
    * Version               : 1.0 
    * Author                : Shakil Bagwan
    * Description           : Used to record Infrequent User Interaction.
    *                             
    *************************************************/
    //Constant Init 
    //URL Params from g2g System

    static String SPEND_USER            = 'spenduser';
    static String MIN_DATE              = 'startdate';
    static String MAX_DATE              = 'enddate'; 
    static String CALL_ID               = 'interactionid';
    static String CASE_ID               = 'caseid';
    
    static String MODE_PARAM            = 'mode';
    static String CREATE_MODE           = 'create';
    static String EDIT_MODE             = 'edit';
    static String CONFIRM_MODE          = 'confirm';
    static String CASEACTION_ID         = 'caseactionid';
    
    static String DEFAULT_CANCEL_URL    = 'http://www.gene.com';
    static String INF_PROFILE_NAME      = 'GNE-INFREQUENT-USER';
    static String COMM_EMPLOYEE         = 'Commercial Employee';
    static String DEV_EMPLOYEE          = 'Development Employee';
    static String MED_AFFAIR_EMPLOYEE   = 'Medical Affairs Employee';    
    static String CONTRACT_SERVICES     = 'Contracted Services';
    static Double DEFAULT_MEALAMOUNT    = .001;
    //added by LJI for use in addAttendee logi
    
    private transient GNE_Account_Dao acctDao;        
    private transient GNE_Stg_Party_Dao ptyDao;
    
    //Product Discussed Information
    public List<Brand> brandList = new List<Brand>(); 
    public String sErrMessage{get;set;} 
    public Boolean showConfirm {get;set;}
    public Boolean showButtons {get;set;}
    public Boolean showclosedconfirmation {get;set;}
    public Boolean NOnCommDisable{get;set;}
    public String sPVDMessage{get;set;}
    public String GetHost{get;set;}
    public String CreatedByEmployee{get;set;}
    public Boolean disablebuttons {get;set;}
    public Boolean disableresponsebuttons {get;set;}
    public String Mode;
    
    //Interacton Record Details 
    public Call2_vod__c tempObject {get; set;}
    public String interactionID;  
    public String InteractionType{get;set;}  
    public String sotherActual='';
    public String shcpActual='';
    public Date MinDate, MaxDate;
    public String DateList{get;Set;}
    public String caseActionId {get; set;}
    public String sExpenseAmount{get;set;}
    
    public String CaseId{get;set;}

    // Main call Account
    public String accountId;
    public String accountAddressId;
    public String accountPrimaryAddress;
    public String JScript{get;set;} 
    public Integer otherActual{get;set;}
    public Integer hcpActual{get;set;} 

    public set<Id> DeletedAccount =  New Set<Id>();//added to hold the deleted accounts
    public List<Attendee> PersonAcount = New List<Attendee>();//added to hold all PERSON accounts
    public User CreatedbyUserInfo;//to store created by user info   
    
    public String contractType{get;set;}
    
    //Payment Information 
    public String payerUnix{get;set;}
    public String spendUser{get;set;}
    public String SpenduserId{get;set;}
    public User loginUserInfo;
    public Boolean frmUpdated{get;set;}

    //User Error Handling Messages
    public String strErrInteractionType{get;set;}
    public String strErrState{get;set;}
    public String strErrBusinessSponsor{get;set;}
    
    public String pgeMessage{get;set;}
    
    public AGS_Case_gne__c agsCaseObj;   //{get;set;} 
    //chaitanya added
    public  AGS_Case_Action_gne__c objCaseActions;  
    //Attendee Search Information
    public String sAddHCPId {get; set;}
    public String sHelpLink {get; set;}
    public String SAddHCPIdType {get; set;}
    public String SAddMdm {get; set;} //sets to true if mdm record is selected from child(pop up) window
    public String SAddHCPRecord {get; set;} //to get the complete record selected by the user from the child window onto the parent window
    public String SAddHCPAddressMdmId {get; set;}
    public String SAddHCPAddressId {get; set;}
    
    public String isSubscribeSuccess{get; set;}
    public String isSubscribeSuccess1{get; set;}
    public String isSubscribeSuccess2{get; set;}
    public String isSubscribeSuccess3{get; set;}
    
    public String sAddAddrId {get; set;}
    
    public String STheraArea {get; set;}
    public String STheraIndication {get; set;}
    
    Address_vod__c objAddressMdm=new Address_vod__c();
    Account objAcctMdm = new Account();
    public boolean savestate{get;set;}  
    public boolean showmealdate{get;set;}
    public boolean showDatelist{get;set;}  

  public String businessSponsorSavedValue {get; set;}
    
    public class Brand{
        public String id{get;set;}
        public String name{get;set;}
        public String Therapeutic_Area {get;set;}
        public string Indication{get;set;}
        
        public Brand(Product_vod__c p){
            Integer pos;
            if(p!= null && p.name!=null){
                /*
                if(p.name.LastindexOf('-')!=-1){
                    pos = p.name.LastindexOf('-');
                    name = p.name.substring(0,pos); 
                    try{
                        Indication = p.name.substring(pos +1);
                    }
                    catch(Exception ex){
                        //do nothing
                    }
                }
                else{
                    name = p.name;
                }
                */
                name = p.name;
            }
            
            if (p.Therapeutic_Area_vod__c=='' || p.Therapeutic_Area_vod__c==null )
            {
                //Therapeutic_Area = 'General';
            }
            else
            Therapeutic_Area = p.Therapeutic_Area_vod__c;
            
            if  (p.Disease_Indication_gne__c=='' || p.Disease_Indication_gne__c==null)
            {
                //Indication='General';
            }
            else
            Indication=p.Disease_Indication_gne__c;
            
            id = p.id;
        }
    }

    public List<Attendee> attendeeList;  
    
    public class Attendee{
        public String id{get;set;}
        public String name {get;set;}
        public String attendeeType{get;set;}    
        public String primaryAddress{get;set;}
        public Boolean IsPayer{get;set;}
        public iPhoneApex.AttendeeType iAttendeeType;       
    }

    //begin added by LJI   
    //This method is called when a user uses the HCP Search page to add an attendee to an interaction
    
    public PageReference addAttendee()
    {
        //the passed in addrId is either a Stg_Pty_Loc.Id, an Address_vod__c.Id or an Account Id
        String addrId = System.currentPageReference().getParameters().get('addrId');
        
        if (!Utility.isNull(sAddAddrId)) 
        {
            //check to see what type of id was passed in
            System.debug('addrId='+addrId);
            if (addrId.startsWith(Schema.SObjectType.Account.getKeyPrefix()))
            {
                sAddHCPId = addrId;
            } else if (addrId.startsWith(Schema.SObjectType.Address_vod__c.getKeyPrefix()))
            {
                SAddHCPAddressId = sAddAddrId;
                acctDao = new GNE_Account_Dao(false);
                sAddHCPId = acctDao.getAccountIdForAddressId(addrId);
            } 
            else    
            {   
                Account acct = ptyDao.subscribeAddress(addrId);
                sAddHCPId = acct.Id;
                
            }
            System.debug('SAddHCPAddressId='+SAddHCPAddressId); 
            sAddHCPIdType = 'Account';  
        }
        return null;
    }
    //end added by LJI
    
    //begin by sandeep
    //This method is called when a user uses the HCP Search page to add an attendee to an interaction
    //This method substitutes the method addAttendee() to support adding an attendee by form submit as adding an attendee by 
    //by calling addAttendee() method without submitting form did not persist the added attendee during further postbacks
    public void addAttendeeFormSubmit()
    {
        isSubscribeSuccess = '';
        system.debug('XXXX Param pass to IRecord from SBC page sAddAddrId -'+sAddAddrId);
        //the passed in addrId is either a Stg_Pty_Loc.Id, an Address_vod__c.Id or an Account Id
        if (!Utility.isNull(sAddAddrId)) 
        {
            //check to see what type of id was passed in
            if (sAddAddrId.startsWith(Schema.SObjectType.Account.getKeyPrefix()))
            {
                sAddHCPId = sAddAddrId;
                system.debug('XXXX  Acc went well and acct :' + sAddHCPId);
            } else if (sAddAddrId.startsWith(Schema.SObjectType.Address_vod__c.getKeyPrefix()))
            {
                SAddHCPAddressId = sAddAddrId;
                acctDao = new GNE_Account_Dao(false);
                sAddHCPId = acctDao.getAccountIdForAddressId(sAddAddrId);
                system.debug('XXXX  Acc selecting went well and acct :' + sAddHCPId);
            } 
            else    
            {   
                ptyDao = new GNE_Stg_Party_Dao(false);
                try
                {
                    
                    Account acct = ptyDao.subscribeAddress(sAddAddrId);
                    system.debug('XXXX ptyDao.getMdmAddressId(sAddAddrId):' + ptyDao.getMdmAddressId(sAddAddrId));
                    system.debug('XXXX Subscribe went well and acct :' +acct);
                    sAddHCPId = acct.Id;
                }
                catch(Exception ex)
                {
                    isSubscribeSuccess = 'HCP could not be added to interaction.Please create a new HCP account:';
                    isSubscribeSuccess1 = '• Click on Add HCP' ;
                    isSubscribeSuccess2 = '• Enter the Details of the HCP and search';
                    isSubscribeSuccess3 = '• Click on Create New Account';
                    return;
                }
            }  
            sAddHCPIdType = 'Account'; 
        }
        
    }
    //ends by sandeep
    
    public IRecord()
    {
        //String UserId = UserInfo.getUserId();  commented 07/28/2010 Gitika
        //Payer Unix is input from SAP System
        spendUser      = ApexPages.currentPage().getParameters().get(SPEND_USER);
        MinDate        = Utility.formatDate_newformat(ApexPages.currentPage().getParameters().get(MIN_DATE));
        MaxDate        = Utility.formatDate_newformat(ApexPages.currentPage().getParameters().get(MAX_DATE));
        Mode           = ApexPages.currentPage().getParameters().get(MODE_PARAM);
        // savestate=false;
        
        if (MinDate==null && MaxDate==null)
        {showmealdate=True;
            showDatelist=False;
        }
        else
        {showmealdate=False;
            showDatelist=True;
        }
        if (Utility.isNull(Mode)){
            Mode = CREATE_MODE;   
        }

        interactionID  = ApexPages.currentPage().getParameters().get(CALL_ID);
        caseActionId = ApexPages.currentPage().getParameters().get(CASEACTION_ID);

        if (!Utility.isNull(interactionID))
        {
            Call2_vod__c callobj;
            //try catch added by sandeep
            try
            {
                callobj = [select Id, Name from Call2_vod__c where Name = :interactionID];
            }
            catch(Exception ex)
            {
                //interactionID=null;//added by sandeep
                return;
            }
            if(callobj != null)
            {
                // handle error
                interactionID = callobj.Id;
            }
        }
        
        caseId        = ApexPages.currentPage().getParameters().get(CASE_ID);
        
        otherActual    = 0;
        hcpActual      = 0; 
        //String UserId=UserInfo.getUserId();  
        //Added on 07/28/2010 Gitika
        String UserId;
        String EmployeeUID;
        //fetch UserId(Actual spend User based on mode)
        
        if (Mode == CREATE_MODE)
        {
            if (!Utility.isNull(spendUser))
            {
                //try catch added by sandeep
                try
                {
                    UserId=[Select Id from user where External_ID_gne__c=:spendUser and UserType ='Standard'].Id;
                }
                catch(Exception ex)
                {
                    //return;
                }
            }
            else
            UserId =UserInfo.getUserId();    
            EmployeeUID =UserInfo.getUserId();         
        }
        else
        {
            if(Mode == CONFIRM_MODE || Mode == EDIT_MODE )
            {
                if (!Utility.isNull(interactionID))
                {
                    Call2_vod__c callrec=null;
                    //try catch added by sandeep
                    try
                    {
                        callrec = [select Id, Name,Spend_User_gne__c,createdbyid from Call2_vod__c where Id = :interactionID];
                    }
                    catch(Exception ex)
                    {
                        return;
                    }
                    
                    if(callrec != null)
                    {
                        if(!Utility.isNull(callrec.Spend_User_gne__c))
                        UserId=callrec.Spend_User_gne__c;
                        else
                        UserId=callrec.createdbyid;
                        EmployeeUID =callrec.createdbyid;
                    }
                    
                }
                
            }          
            
        }
        
        SpenduserId=UserId;
        //end of code 07/28/2010 Gitika
        try
        {
            CreatedbyUserInfo =   [select FirstName,LastName,Alias from User where Id= :EmployeeUID];
        } 
        catch(Exception ex){
            //do nothing
        }
        if(CreatedbyUserInfo!=null) {
            CreatedByEmployee = CreatedbyUserInfo.Alias+'['+CreatedbyUserInfo.FirstName+','+CreatedbyUserInfo.LastName+']';
        }
        //loginUserInfo = [select Id, Profile.Name, ProfileId, Infrequent_Interacton_Enabled_gne__c from User where Id= :UserId ];
        try
        {
            loginUserInfo = [select Id, Profile.Name, ProfileId, CompanyName from User where Id= :UserId ];
            system.debug('loginUserInfo Profile'+ loginUserInfo.Profile.Name);
        }
        catch(Exception ex)
        {
            //return;
        }
        //Added 07/28/2010 -- Gitika
        
        if(loginUserInfo!=null && loginUserInfo.Profile.Name =='GNE-INFREQUENT-USER' )    
        NOnCommDisable=false;
        else
        NOnCommDisable=false;
        
        //End of code 07/28/2010  --Gitika
        brandList      = new List <Brand>();
        attendeeList   = new List<Attendee>();
        tempObject     = new Call2_vod__c();
        
        showConfirm        = false;         

        //     if(Mode == CONFIRM_MODE) showConfirm = true;
        //chaitanya added start 
        if(Mode == CONFIRM_MODE)
        { 
            //LJI - removed column Action_Status_internal_gne__c from query because
            //it doesn't exist everywhere but the column value wasn't being used in this code.
            objCaseActions = [select Action_Status_gne__c,AGS_Validate_Data_1_box_gne__c,AGS_Validate_Data_2_box_gne__c,AGS_Validate_Data_3_box_gne__c from AGS_Case_Action_gne__c where Id=:caseActionId]; 
            if(objCaseActions.Action_Status_gne__c =='Closed')
            {
                showButtons = false;
                showConfirm = true; 
                showclosedconfirmation = true;
                if(objCaseActions.AGS_Validate_Data_3_box_gne__c == TRUE)
                {
                    sPVDMessage = 'The confirmation  "The $ amount is incorrect and I cannot correct it" was submitted. Please close the browser window.';                        
                }                    
                else if(objCaseActions.AGS_Validate_Data_2_box_gne__c == TRUE)
                {
                    sPVDMessage = 'The confirmation "The data was incorrect and I have corrected it" was submitted. Please close the browser window.';
                }
                else if(objCaseActions.AGS_Validate_Data_1_box_gne__c == TRUE)
                {
                    sPVDMessage = 'The confirmation "The data is correct and I have not modified it" was submitted. Please close the browser window.';
                }
            }
            if(objCaseActions.Action_Status_gne__c =='Open')
            {
                showButtons = true;
                showConfirm = true;    
            }
        }
        //end   
        
        if (Mode == CONFIRM_MODE && !Utility.isNull(interactionID) && !Utility.isNull(caseId)){
            if (!this.loadInteraction(interactionID)){
                addMessage('Could not be able to find Interaction');
                Mode = CREATE_MODE; 
            }

            agsCaseObj = [select Id, Name, Expense_Transaction_Total_gne__c from AGS_Case_gne__c where Id= :caseId];
            sExpenseAmount = String.valueOf(agsCaseObj.Expense_Transaction_Total_gne__c); 
        }       

        
        if (Mode == CONFIRM_MODE && !Utility.isNull(interactionID) && Utility.isNull(case_Id) ){
            Mode = EDIT_MODE;   
        }

        if (Mode == CONFIRM_MODE && Utility.isNull(interactionID)){
            addMessage('Pass Interaction ID');
            Mode = CREATE_MODE;         
        }
        
        if (Mode == EDIT_MODE && Utility.isNull(interactionID) ){
            addMessage('Pass Interaction ID');
            Mode = CREATE_MODE;         
        }       
        
        if (Mode == EDIT_MODE && !Utility.isNull(interactionID) ){
            if (!this.loadInteraction(interactionID)){
                addMessage('Could not be able to find Interaction');                    
            }
        }

    }


    public PageReference Page_Load(){
        String env = GlobalUtils.getEnvironment();
        MAP<String,Concur_Environment_Domain_gne__c> domains = Concur_Environment_Domain_gne__c.getAll();
        for(Concur_Environment_Domain_gne__c env_domain : domains.values())
        {
            if (env_domain.Name.contains(env))
            {
                sHelpLink = env_domain.Help_Link_gne__c;
            }
        }
        
        sHelpLink += '/InfrequentUserHelp.pdf';
        GetHost = 'https://'+ApexPages.currentPage().getHeaders().get('Host');
        system.debug(GetHost);
        // remove the flag from USER......Instead use custom setting
        /*  if (loginUserInfo.Infrequent_Interacton_Enabled_gne__c != true){         
                return Utility.RedirectPage('/apex/ShowMessage?msgid=INFU_FRQ_MSG');
        }*/
        
        //sErrmessage = 'hello : ' + GetHost;
        //return null;
        
        //starts added by sandeep
        //if(Mode == EDIT_MODE || Mode == CONFIRM_MODE)
        //{
        //if(interactionId==null)
        // {
        //   return Utility.RedirectPage(GetHost + '/apex/ShowMessage?msgid=INVALID_INTERACTION_ID');
        // }
        //}
        
        //if(loginUserInfo==null)
        //{
        //  return Utility.RedirectPage(GetHost + '/apex/ShowMessage?msgid=SPENDUSER_NOT_EXIST');
        //}
        //ends added by sandeep
        
        //Added 07/28/2010 Gitika .If interaction is not of type Call2_vod__c callobj
        //try catch added by sandeep
        if(Mode == EDIT_MODE)
        {
            call2_vod__c c;
            try
            {
                c=[Select id, recordtype.name from call2_vod__c where id=:interactionId];
            }
            catch(Exception ex)
            {
                
            }
            if(c==null )
            {
                //return Utility.RedirectPage(GetHost + '/apex/ShowMessage?msgid=INVALID_INTERACTION_ID');
            }
            else if(c!=null && c.recordtype.name != 'INFU Interaction')
            {
                return Utility.RedirectPage(GetHost + '/apex/ShowMessage?msgid=NON_INFU_INTERACTION_MSG');
            }
        }      
        
        
        List<Infrequent_interaction_enabled_profiles__c> LoginProfile = new List<Infrequent_interaction_enabled_profiles__c>();
        //try catch added by sandeep
        try
        {
            LoginProfile=[Select Infrequent_enabled_profile__c from Infrequent_interaction_enabled_profiles__c i  
            where Infrequent_enabled_profile__c=:loginUserInfo.Profile.Name];
        }
        catch(Exception ex)
        {
            //do nothing
        }
        
        if(Mode == CREATE_MODE) 
        {         
            if(loginUserInfo!=null && LoginProfile.size() == 0)
            {
                return Utility.RedirectPage(GetHost + '/apex/ShowMessage?msgid=INFU_FRQ_MSG');
            }
        }
        else
        {
            if(LoginProfile.size() == 0)
            {
                return Utility.RedirectPage(GetHost + '/apex/ShowMessage?msgid=INFU_FRQ_MSG');
            }
        }
        
        //added by chaitanya to redirect if loginuserinfo is different from spend user unix ID
        if(Mode == CREATE_MODE || Utility.isNull(Mode)){
            if (!Utility.isNull(spendUser)){
                if(addActualPayer(spendUser) != true){
                    return Utility.RedirectPage(GetHost + '/apex/ShowMessage?msgid=SPENDUSER_NOT_EXIST');
                }
            }else{
                addUserAttendee(UserInfo.getUserId(), true);              
            }         
            tempObject.Call_Date_vod__c = null;
            
            //set up picklist values based on parameters in the url June25
            //MinDate
            //MaxDate
            
            /* System.debug('June 25 Mindate'+MinDate);
            System.debug('June 25 Maxdate'+MaxDate);
            DateList  ='<SELECT  id=MealDate><OPTION  VALUE='+MinDate+'>'+MinDate+'</Option>';
            integer numberDays =MinDate.daysBetween(MaxDate);
            Date nextdate=MinDate;
            For(integer i=0;i<numberDays;i++)
            {
                nextdate=nextdate.adddays(1);
                DateList=DateList+'<OPTION  VALUE='+nextdate+'>'+nextdate+'</Option>';
            }   
            DateList=DateList+'</SELECT>';*/
        }
        
        // INCORRECT_INFREQUENT_USER     
        /*
            if (!Utility.isNull(interactionID) && loginUserInfo.Profile.Name != INF_PROFILE_NAME){         
                    //return Utility.RedirectPage('/' + interactionID);
            }
                    
            if (loginUserInfo.Profile.Name != INF_PROFILE_NAME){           
                    //return Utility.RedirectPage('/a04/e');
            }              
        */
        if(!Utility.isNull(SAddHCPIdType) && SAddHCPIdType.toUpperCase()=='User'.toUpperCase()){
            addUserAttendee(sAddHCPId, false);
        }
        
        return null;
        
    }
    
    public List<SelectOption> getInteractionDateOptions(){ 
        List<SelectOption> options= new List<SelectOption>();
        //if(Mode == CREATE_MODE || Utility.isNull(Mode)){
        options.add(new SelectOption(mindate.format(),mindate.format()));
        integer numberDays =MinDate.daysBetween(MaxDate);
        Date nextdate=MinDate;
        For(integer i=0;i<numberDays;i++)
        {
            nextdate=nextdate.adddays(1);
            options.add(new SelectOption(nextdate.format(),nextdate.format()));
            
        }   
        
        //} 
        return options; 
        
    }
    
    
    
    public List<SelectOption> getInteractionTypeOptions(){ 
        List<SelectOption> options= new List<SelectOption>();
        options.add(new SelectOption('','--None--')); 
        options.add(new SelectOption('In-Office','In-Office')); 
        options.add(new SelectOption('Out-Of-Office','Out-Of-Office')); 
        return options; 
    } 

    public List<SelectOption> getBusinessSponsorStatusOptions(){ 
        List<SelectOption> options= new List<SelectOption>();
        options.add(new SelectOption('','--None--'));   
        if (!Utility.IsNull(contractType))
        {
          if(contractType.contains('Commercial')) 
          {
            options.add(new SelectOption(contractType,contractType)); 
          }
          else
            options.add(new SelectOption('Commercial','Commercial')); 
          if(contractType.contains('Product Development (PD)')) 
          {
            options.add(new SelectOption(contractType,contractType)); 
          }
          else
              options.add(new SelectOption('Product Development (PD)','Product Development (PD)'));
            if(contractType.contains('Medical Affairs')) 
          {
            options.add(new SelectOption(contractType,contractType)); 
          }
          else
              options.add(new SelectOption('Medical Affairs (gMed)','Medical Affairs (gMed)'));
            if(contractType.contains('gRED')) 
          {
            options.add(new SelectOption(contractType,contractType)); 
          }
          else
              options.add(new SelectOption('gRED','gRED'));
             if(contractType.contains('pRED')) 
          {
            options.add(new SelectOption(contractType,contractType)); 
          }
          else
              options.add(new SelectOption('pRED','pRED'));
            if(contractType.contains('GPS')) 
          {
            options.add(new SelectOption(contractType,contractType)); 
          }
          else
              options.add(new SelectOption('GPS','GPS'));
            if(contractType.contains('Pharma Global Technical Ops (PT)')) 
          {
            options.add(new SelectOption(contractType,contractType)); 
          }
          else
              options.add(new SelectOption('Pharma Global Technical Ops (PT)','Pharma Global Technical Ops (PT)'));
            if(contractType.contains('Corporate')) 
          {
            options.add(new SelectOption(contractType,contractType)); 
          }
          else
              options.add(new SelectOption('Corporate','Corporate'));
            tempObject.Business_Sponsor_gne__c = contractType; 
        }
        else
        {
          if(businessSponsorSavedValue != null)
          {            
            if(businessSponsorSavedValue.contains('Commercial'))
            {
              if(businessSponsorSavedValue == 'Commercial Employee')
              {
                options.add(new SelectOption('Commercial Employee','Commercial Employee'));
                businessSponsorSavedValue = 'Commercial Employee';
              }
              else
                options.add(new SelectOption(businessSponsorSavedValue,businessSponsorSavedValue));
            }
            else
              options.add(new SelectOption('Commercial','Commercial')); 
            if(businessSponsorSavedValue.contains('Development'))
            { 
              system.debug('----businessSponsorSavedValue'+businessSponsorSavedValue);
              if(businessSponsorSavedValue == 'Development Employee')   
              { 
                options.add(new SelectOption('Development Employee','Development Employee'));
                businessSponsorSavedValue = 'Development Employee';
              }
              else
                options.add(new SelectOption(businessSponsorSavedValue,businessSponsorSavedValue));
            }
            else
              options.add(new SelectOption('Product Development (PD)','Product Development (PD)'));
            if(businessSponsorSavedValue.contains('Medical Affairs'))
            {
              options.add(new SelectOption(businessSponsorSavedValue,businessSponsorSavedValue));
            }
            else
              options.add(new SelectOption('Medical Affairs (gMed)','Medical Affairs (gMed)'));
            if(businessSponsorSavedValue.contains('gRED'))
              options.add(new SelectOption(businessSponsorSavedValue,businessSponsorSavedValue));
            else
              options.add(new SelectOption('gRED','gRED'));  
            if(businessSponsorSavedValue.contains('pRED'))
              options.add(new SelectOption(businessSponsorSavedValue,businessSponsorSavedValue));
            else
              options.add(new SelectOption('pRED','pRED'));  
            if(businessSponsorSavedValue.contains('GPS'))
              options.add(new SelectOption(businessSponsorSavedValue,businessSponsorSavedValue));
            else
              options.add(new SelectOption('GPS','GPS'));  
            if(businessSponsorSavedValue.contains('Pharma Global Technical Ops (PT)'))
              options.add(new SelectOption(businessSponsorSavedValue,businessSponsorSavedValue));
            else
              options.add(new SelectOption('Pharma Global Technical Ops (PT)','Pharma Global Technical Ops (PT)'));
            if(businessSponsorSavedValue.contains('Corporate'))
              options.add(new SelectOption(businessSponsorSavedValue,businessSponsorSavedValue));
            else
              options.add(new SelectOption('Corporate','Corporate'));    
            system.debug('----businessSponsorSavedValue'+businessSponsorSavedValue);  
            tempObject.Business_Sponsor_gne__c = businessSponsorSavedValue;
          }
          else
          {
            options.add(new SelectOption('Commercial','Commercial'));
            options.add(new SelectOption('Product Development (PD)','Product Development (PD)'));
            options.add(new SelectOption('Medical Affairs (gMed)','Medical Affairs (gMed)'));
            options.add(new SelectOption('gRED','gRED'));
            options.add(new SelectOption('pRED','pRED'));
            options.add(new SelectOption('GPS','GPS'));
            options.add(new SelectOption('Pharma Global Technical Ops (PT)','Pharma Global Technical Ops (PT)'));
            options.add(new SelectOption('Corporate','Corporate'));
            tempObject.Business_Sponsor_gne__c = '';
          }
        }
        system.debug('-------businessSponsorSavedValue'+businessSponsorSavedValue);
        /* 
        String MedicalAffair = MED_AFFAIR_EMPLOYEE;
        
        if (!Utility.IsNull(contractType)){
            
            MedicalAffair = MedicalAffair + ' - ' + contractType;
            if ((tempObject.Business_Sponsor_gne__c).substring(0,7)=='Medical')
            tempObject.Business_Sponsor_gne__c  = MedicalAffair;
            
        }
        else if(mode != CREATE_MODE && tempObject.Business_Sponsor_gne__c != null && tempObject.Business_Sponsor_gne__c != DEV_EMPLOYEE && tempObject.Business_Sponsor_gne__c != COMM_EMPLOYEE){       
            MedicalAffair =  tempObject.Business_Sponsor_gne__c;
        }        
        
        options.add(new SelectOption(MedicalAffair,MedicalAffair)); */
        
        return options; 
    }
    

    
    public List<Attendee> getAttendeeList(){
       
        Attendee tempAttendee = new Attendee();
        //to add attendee from new search page functionality
        //addAttendeeFormSubmit();
        System.Debug('XXX Previous sAddHCPId and SAddHCPIdType:' + sAddHCPId + ' & ' +  SAddHCPIdType);
        if(!Utility.isNull(sAddHCPId) && !Utility.isNull(SAddHCPIdType) && SAddHCPIdType.toUpperCase()=='Account'.toUpperCase()){
            addPersonAccount(sAddHCPId);   
        }

        if(!Utility.isNull(sAddHCPId)){
            //add User to the list from child window
            if(!Utility.isNull(SAddHCPIdType) && SAddHCPIdType.toUpperCase()=='User'.toUpperCase()){
                addUserAttendee(sAddHCPId, false);
            }
            //add product to product list from child window
            if(!Utility.isNull(sAddHCPId)){
                //add Product to Product List in Parent window when user selects product from product pop up  
                if(!Utility.isNull(SAddHCPIdType) && SAddHCPIdType.toUpperCase()=='Product'.toUpperCase()){
                    Product_Vod__c objProduct=[ Select Id, Name, Product_Code_gne__c, Product_Type_vod__c,GNE_Part_Number_gne__c, Therapeutic_Area_vod__c,Disease_Indication_gne__c, Therapeutic_Class_vod__c from Product_Vod__c where id = :sAddHCPId ];
                    // brandList.add(new Brand(objProduct));
                    if(brandList.size()== 0)
                    { 
                        brandList.add(new Brand(objProduct));
                    }
                    else
                    {
                        integer duplicateproduct = 1;
                        for (integer i=0; i <brandList.size(); i++ )
                        { 
                            if(objProduct.Name == brandList[i].Name)
                            { 
                                duplicateproduct = -1;
                            }                       
                        } 
                        
                        if(duplicateproduct == 1)
                        {
                            brandList.add(new Brand(objProduct));                                   
                        }    
                    }
                }
            }

            //add product to Thera product list from child window
            if(!Utility.isNull(sAddHCPId)){
                //add Product to Product List in Parent window when user selects product from product pop up  
                if(!Utility.isNull(SAddHCPIdType) && SAddHCPIdType.toUpperCase()=='TheraProduct'.toUpperCase()){
                    this.addTheraProductList(sAddHCPId, sTheraArea, sTheraIndication);
                }
            }
        }
        
        sAddHCPId = '';
        SAddHCPIdType = '';
        SAddMdm='';
        SAddHCPRecord='';
        SAddHCPAddressId='';
        sAddAddrId='';
        
        return attendeeList; 
    }

    public List<Brand> getBrandList(){
        return brandList;
    }

    public PageReference delProd(){
        String delname = ApexPages.CurrentPage().getParameters().get('delProdname');
        
        integer gone = -1;
        integer i = 0;   
        for ( i=0; i < brandList.size(); i++ ){ 
            if (brandList[i].Name == delname){ 
                gone = i;
                brandList[gone] = null;
                brandList.remove(gone);
            }   
        } 
        return null;
    }

    //Add actual Payer into attendee list only in case of proxy user is logined.
    public boolean addActualPayer(String unixId){
        User actualUser;
        String UserID;
        
        try{
            actualUser = Database.Query('select id  from User where external_id_gne__c = \'' + unixId + '\' and UserType =\'Standard\' limit 1');
        }catch(Exception e){
            //do nothing    
        }
        
        if(actualUser == null){
            String strResult = UserManager.activateSFUser(unixId, true);
            //if(strResult == UserManager.INFREQUENT_USER_PROF){
            if(!Utility.isNull(strResult) && strResult.IndexOf('Error')==-1){
                actualUser = Database.Query('select id  from User where external_id_gne__c = \'' + unixId + '\' and UserType =\'Standard\' limit 1');
                UserID = actualUser.Id;             
            }
            else
            {
                //UserID = UserInfo.getUserId();
                
                return false;
            }
        }
        else
        {
            UserID = actualUser.Id;
        }

        tempObject.Spend_User_gne__c = UserID;         
        return this.addUserAttendee(UserID, true);
    }
    
    public boolean addUserAttendee(String userId, Boolean isPayer){
        
        Attendee tempAttendee = new Attendee();
        system.debug(' Trying to get user for unix id '+userId);
        User objUser;
        try{ 
            //if (userId.substring(0,3)=='005')
            //{
            objUser = [SELECT  u.Name, u.FirstName, u.Id, u.LastName, u.Phone, u.MobilePhone, u.Title, u.Email, u.CompanyName, u.UserRoleId, u.UserRole.Name, u.Username, u.City, u.Street, u.State, u.PostalCode, u.Country, u.isActive, u.external_id_gne__c FROM User u where id = :userId and UserType ='Standard'];
            //}
            /*else
        {
            String userresult= UserManager.activateSFUser(userId,true);
            if(userresult.substring(0,3)=='005')
            {
                    userId=userresult;
                objUser = [SELECT  u.Name, u.FirstName, u.Id, u.LastName, u.Phone, u.MobilePhone, u.Title, u.Email, u.CompanyName, u.UserRoleId, u.UserRole.Name, u.Username, u.City, u.Street, u.State, u.PostalCode, u.Country, u.isActive, u.external_id_gne__c FROM User u where id = :userId ];
            }
        }*/
            
            String sAddress='';
            
            if(!Utility.isNull(objUser.Street)){
                sAddress+=objUser.Street;
            }
            
            if(!Utility.isNull(objUser.City)){
                sAddress+=' '+objUser.City;
            }
            
            if(!Utility.isNull(objUser.State)){
                sAddress+=' '+objUser.State;
            }
            
            if(!Utility.isNull(objUser.PostalCode)){
                sAddress+=' '+objUser.PostalCode;
            }
            
            if(!Utility.isNull(objUser.Country)){
                sAddress+=' '+objUser.Country;
            }
            

            
            tempAttendee.id = objUser.id;
            tempAttendee.name = objUser.Name;
            tempAttendee.attendeeType = objUser.CompanyName;
            tempAttendee.primaryAddress = sAddress;
            tempAttendee.iAttendeeType = iPhoneApex.AttendeeType.USER;
            tempAttendee.isPayer = false;            
            if(isPayer || objUser.id == tempObject.Spend_User_gne__c){
                tempAttendee.isPayer = true;
            }             
            
            
            if(isPayer){
                payerUnix = objUser.external_id_gne__c + '[' + objUser.FirstName + ', ' + objUser.LastName + ']';
                tempObject.Spend_User_gne__c = objUser.id;               
            }  
            
            attendeeList.add(tempAttendee);
            otherActual = otherActual + 1;
        }catch(Exception e){
            //handle error 
            
        }
        
        return true; 
    }
    
    public PageReference del() {
        String delattndid = ApexPages.CurrentPage().getParameters().get('delattndid');
        system.assert( delattndid != null );
        integer gone = -1;
        integer i = 0; 
        
        for ( i=0; i< attendeeList.size(); i++ ) { 
            if (attendeeList[i].id == delattndid) { 
                gone = i;  
                if (attendeeList[i].iAttendeeType == iPhoneApex.AttendeeType.PERSONACCOUNT){            
                    hcpActual = hcpActual - 1;
                    DeletedAccount.add(delattndid);//ADDED to store all deleted Account IDS
                    
                }else{
                    otherActual = otherActual - 1;  
                }
                attendeeList.remove(gone);
            } system.debug('adelattndid !!!'+delattndid);  
        }system.debug('attendeeList AFTER REMOVAL'+attendeeList);
        return null;
        
    }

    ///////Starts getters and Setters/////////
    public String getSOtherActual()
    {
        String strTemp='';
        if(OtherActual!=null && OtherActual>=0)
        {
            strTemp=String.valueOf(OtherActual);
        }
        return strTemp;
    }
    
    public void setSOtherActual(String val){
        this.sotherActual=val;
    }
    
    public String getSHcpActual(){
        String strTemp='';
        if(HcpActual!=null && HcpActual>=0){
            strTemp=String.valueOf(HcpActual);
        }
        return strTemp;
    }
    
    public void setSHcpActual(String val){
        this.shcpActual=val;
    }


    public PageReference Save()
    {
        
        //commented by sandeep
        ////2010-07-28 Gitika
        ////change call records owner to current logged in user 
        //system.debug('interactionID  '+interactionID);
        //if (Mode == EDIT_MODE || Mode == CONFIRM_MODE)
        //{
        //     Call2_vod__c c=[Select id,ownerid from Call2_vod__c where id=:interactionID];
        //    List<Call2_vod__c >  childcallrec=[Select id,ownerid from Call2_vod__c where Parent_Call_vod__c=:interactionID];
        //    c.ownerid=UserInfo.getUserId();
        //    for(Call2_vod__c cv :childcallrec)
        //        cv.ownerid=UserInfo.getUserId();
        //    childcallrec.add(c);
        //    update c;       
        //}
        //end of code 
        //ends commented b sandeep
        
        ApexPages.Message testMsg;
        String strcontinueURL;
        system.debug('save method invoked');

        if (!this.Validate()){
            savestate=false;
            system.debug('I validated '+savestate);
            return null;
        }
        else
        {
            savestate=true;
        }
        iphoneApex.CallAttributes cAttributes = new iphoneApex.CallAttributes();
        if(!Utility.isNull(interactionID)) cAttributes.Id = interactionID;
        
        //added by sandeep
        //change call records owner to current logged in user 
        if (Mode == EDIT_MODE || Mode == CONFIRM_MODE)
        {
            cAttributes.OwnerId                 =   UserInfo.getUserId();
        }
        //ends added by sandeep
        
        cAttributes.Account                     = AccountId;  
        cAttributes.CallDateTime                = DateTime.newInstance(tempObject.Call_Date_vod__c, DateTime.now().time());
        //cAttributes.RequestId = RequestId;
        cAttributes.Address                     = accountAddressId;
        cAttributes.AddressText                 = accountPrimaryAddress; 
        cAttributes.MealLocationCity            = tempObject.City_gne__c;
        cAttributes.MealLocationState           = tempObject.State_gne__c;
        cAttributes.AddressText                 = tempObject.City_gne__c + ' ' + tempObject.State_gne__c;
        cAttributes.CallAttendeeType            = iphoneApex.AttendeeType.PERSONACCOUNT;
        cAttributes.IsComplete                  = true;
        cAttributes.MealAmount                  = null;     
        cAttributes.MealPlannedAttendeeCount    = tempObject.Planned_Attendees_gne__c.IntValue();
        cAttributes.MealActualAttendeeCount     = tempObject.Actual_Attendees_gne__c.IntValue();
        cAttributes.SpendUser                   = tempObject.Spend_User_gne__c;
        
        //cAttributes.MealExpense               = true;    
        cAttributes.NumOfCustomersPresent       = hcpActual;
        cAttributes.IsComplete                  = true;
        cAttributes.InteractionType             = InteractionType;
        cAttributes.BusinessSponsor             = tempObject.Business_Sponsor_gne__c;
        
        
        
        
        //update meal amount and interaction location to avoid triggering validation rule errors
        //actual meal amount is never updated from this page so assign default meal amount
        /*if(tempObject.Meal_Amount_gne__c!=null) {
            //to update meal amount for Roche Employees validation rule 'Meal_Amount_Needed_for_Meal_Expense'
            if(tempObject.Meal_Amount_gne__c <= 0)  {
                cAttributes.MealAmount = DEFAULT_MEALAMOUNT;
            }
            else {
                cAttributes.MealAmount = tempObject.Meal_Amount_gne__c;
            }
        }
        else {
            cAttributes.MealAmount = DEFAULT_MEALAMOUNT;
        }*/
        
        cAttributes.InteractionLocation = InteractionType;
        
        system.debug('cAttributes:'+cAttributes);
        
        if(contractType == 'Contracted Services'){
            cAttributes.ContractedServices          = true;         
        }else{
            if (contractType == 'Without Contracted Services')//added 07/30/2010 gitika
            cAttributes.ContractedServices          = false;            
        }
        
        
        
        //Add attendee list in iPhoneApex API
        cAttributes.callAttendeeList = new List <iPhoneApex.CallAttendee>();
        iPhoneApex.CallAttendee tempAttendee ; 
        
        Integer i = 0;
        
        for(Attendee attnd : attendeeList){
            tempAttendee = new iphoneApex.CallAttendee();
            tempAttendee.CallAttendeeType = attnd.iAttendeeType;
            tempAttendee.Attendee =     attnd.id; 
            cAttributes.callAttendeeList.add(tempAttendee);
            //sErrMessage = sErrMessage + attnd.id + ' : ';
            
            i++; 
            
        }
        //sErrMessage = sErrMessage + ' count : ' + i++;
        
        
        
        //Add attendee list in iPhoneApex API
        cAttributes.callDetailList = new List<iPhoneApex.CallDetail>();
        
        iPhoneApex.CallDetail tempCallDetail; 
        i = 1; 
        for(Brand brnd :brandList){
            tempCallDetail = new iPhoneApex.CallDetail();
            tempCallDetail.DetailPriority = String.valueof(i) ;
            tempCallDetail.Product = brnd.id;
            //sErrMessage = sErrMessage + ' ' + brnd.id;
            if(brnd.Indication=='' || brnd.Indication!=null)
            tempCallDetail.DiseaseIndication = brnd.Indication;
            if(brnd.Indication=='' || brnd.Therapeutic_Area!=null)
            tempCallDetail.TherapeuticArea = brnd.Therapeutic_Area;
            cAttributes.callDetailList.add(tempCallDetail);
            i++;
        }
        
        
        if(DeletedAccount.contains(AccountId))//added to override if main account was deleted. **************
        {
            
            for ( i=0; i< attendeeList.size(); i++ )
            {
                if(attendeeList[i].iAttendeeType == iPhoneApex.AttendeeType.PERSONACCOUNT)
                PersonAcount.add(attendeeList[i]);              
            }
            cAttributes.Account = PersonAcount[0].id;      
            
            List<Address_vod__c> AddressID = New List<Address_vod__c>([select id,Name from Address_vod__c where Account_vod__c =:PersonAcount[0].id]);
            cAttributes.Address = AddressID[0].id;
            cAttributes.AddressText =   PersonAcount[0].primaryAddress;

        }
        
        system.debug('June8 cAttributes '+cAttributes);
        iPhoneApex.Response  resp = iPhoneApex.updateOrCreateCallForIFU(cAttributes);
        system.debug(' June8 resp '+resp);
        sErrMessage = resp.ErrorMessage;
        
        if (resp.ErrorMessage != null){         
            testMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Could not able to save \n' +  resp.ErrorMessage + ' .... ');
            ApexPages.addMessage(testMsg);
        }
        else 
        {
            // update the record types for call2_vod__c records 
            Set <Id> CallIds=new Set<Id>();
            String callresp=resp.tostring();
            List <String> Resp_part1=callresp.split('RequestIdResponseIdList',2);
            system.debug('Resp_part1 '+Resp_part1);
            
            if (Resp_part1.size()==2)
            {   
                system.debug('Resp_part1[1] '+Resp_part1[1]);
                List <String> Resp_part2=Resp_part1[1].split(',',-2);
                system.debug('Resp_part2 '+Resp_part2);
                for (integer j=0;j<Resp_part2.size();j++)
                {  
                    //system.debug('Resp_part2[j] :'+j +'  '+Resp_part2[j] +' '+(Resp_part2[j].trim()).startswith('ResponseId='));
                    if ((Resp_part2[j].trim()).startsWith('ResponseId='))
                    {
                        system.debug(Resp_part2[j].substring(12,30));
                        Callids.add(Resp_part2[j].substring(12,30));
                    } 
                }
                system.debug('Callids.size() '+Callids.size());
                system.debug('Callids list  '+Callids);
                if (Callids.size()>0)       
                {
                    List <Call2_vod__c> CallRectypeupdate=[Select recordtypeid,id,Spend_User_gne__c,Parent_call_vod__c from Call2_vod__c where id in :Callids];
                    //fetch spend user from master record
                    String Master_Spend_user;
                    for (integer k=0;k<CallRectypeupdate.size();k++)
                    {
                        if (CallRectypeupdate[k].Parent_call_vod__c==null)
                        Master_Spend_user=CallRectypeupdate[k].Spend_User_gne__c;
                    }
                    List <recordtype> call_rectype=[Select id from recordtype where SobjectType='Call2_vod__c' and  name='INFU Interaction'];
                    QueueSobject ifu_queue=[Select q.QueueId from QueueSobject q  where Queue.Name='AGS Infrequent Owner'];
                    if (call_rectype.size()>0)
                    for (integer k=0;k<CallRectypeupdate.size();k++)
                    {
                        CallRectypeupdate[k].recordtypeid=call_rectype[0].Id;
                        CallRectypeupdate[k].ownerid=ifu_queue.QueueId;
                        if (CallRectypeupdate[k].Parent_call_vod__c!=null && CallRectypeupdate[k].Spend_User_gne__c==null)
                        CallRectypeupdate[k].Spend_User_gne__c=Master_Spend_user;
                    }
                    update  CallRectypeupdate;  
                }   
            }
            
            
            
            if(Mode == CONFIRM_MODE)
            {
                system.debug('I am in option 2 July 16');
                if(!Utility.isNull(caseActionId))
                {
                    AGS_Case_Action_gne__c objCaseAction;
                    try{
                        objCaseAction=[Select Id, AGS_Validate_Data_1_box_gne__c, AGS_Validate_Data_2_box_gne__c, AGS_Validate_Data_3_box_gne__c from AGS_Case_Action_gne__c where id=:caseActionId];
                    }
                    catch(Exception ex){}
                    //disp;lay cobjCaseActiononfirmation message if compliance is accepted by user 
                    if(objCaseAction!=null && objCaseAction.AGS_Validate_Data_2_box_gne__c == true)
                    {
                        return Utility.RedirectPage(GetHost + '/apex/ShowMessage?msgid=INF_USER_PLEASE_VALIDATE');
                    }
                    //update option selected. The trigger on case action will send confirmation email
                    objCaseAction.AGS_Validate_Data_1_box_gne__c = false;
                    objCaseAction.AGS_Validate_Data_2_box_gne__c = true;
                    objCaseAction.AGS_Validate_Data_3_box_gne__c = false;
                    system.debug('I am in option 2 update July 16');
                    update objCaseAction;
                    
                }
                //JScript = 'CloseWindow();'; 
                return  Utility.RedirectPage(GetHost + '/apex/IRecord?caseactionid='+caseActionId+'&caseid='+caseId+'&interactionid='+ApexPages.currentPage().getParameters().get(CALL_ID)+'&mode='+Mode);
            }
            
            system.debug('I am about to close');    
            JScript = 'CloseWindow();'; 
            return null;
            strcontinueURL = ApexPages.currentPage().getParameters().get('continueURL');
            iPhoneApex.RequestIdResponseIdMap result = resp.RequestIdResponseIdList[0];
            testMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Saved Successfully >> Request Details for Test only:' + result.ResponseId);
            ApexPages.addMessage(testMsg);
            
            if(Utility.isNull(strContinueURL)){
                strcontinueURL = ApexPages.currentPage().getUrl() + '&Id=' + result.ResponseId;
            } 
            JScript = 'CloseWindow();';
            //return Utility.RedirectPage(strcontinueURL);
        }
        
        return null;
    }


    //Server validation will be done here!  
    public Boolean Validate(){
        Boolean ret = true;
        
        if(hcpActual <= 0){
            addErrMessage('Minimum a Health Care Professional should be as an attendee');
            ret= false;
        }
        if(tempObject.Actual_Attendees_gne__c < hcpActual + OtherActual){
            addErrMessage('Number of Actual attendees should be at least equal to #HCP Actual + #Other Actual');
            ret= false;
        }
        
        if(brandList.size() <= 0){
            addErrMessage('Minimum a Product (Brand) should be discussed for meal interaction');
            ret= false;
        }
        
        DateTime currDateTime = system.now();
        
        Date currDate = Date.newInstance(currDateTime.year(),currDateTime.month(),currDateTime.day());
        
        if(tempObject.Call_Date_vod__c == null){
            tempObject.Call_Date_vod__c.addError('Interaction Date is required');
            ret = false;
        }else if(MinDate != null && MaxDate != null){
            
            if ( MinDate > tempObject.Call_Date_vod__c || MaxDate < tempObject.Call_Date_vod__c){           
                tempObject.Call_Date_vod__c.addError('Interaction date is invalid, valid Date should be between ' + MinDate.format() + ' and ' + MaxDate.format());
                ret = false;                        
            }
        }
        
        if(tempObject.Call_Date_vod__c != null)
        {
            if(tempObject.Call_Date_vod__c > currDate)
            {
                tempObject.Call_Date_vod__c.addError('Meal Date can not be greater than current date');
                ret = false;
            }
        }
        
        if(tempObject.City_gne__c == null){
            tempObject.City_gne__c.addError('Interaction City is required');
            ret = false;
            
        }
        
        if(tempObject.State_gne__c == null || tempObject.State_gne__c == '--'){
            tempObject.State_gne__c.addError('Interaction State is required');
            strErrState= '<strong>Error:</strong> Interaction State is required';
            ret = false;
        }else
        strErrState='';
        
        if(InteractionType == null){
            strErrInteractionType = '<strong>Error:</strong> Interaction Type is required';
            addErrMessage('In-Office/Out-of-Office - Interaction Type is required');
            ret = false;
        }else{
            strErrInteractionType = '';
        }
        
        if(tempObject.Business_Sponsor_gne__c == null || tempObject.Business_Sponsor_gne__c == '')
        {
            strErrBusinessSponsor = '<strong>Error:</strong> Bussiness Sponsor is required';
            ret = false;
        }
        else if (!tempObject.Business_Sponsor_gne__c.contains('Contracted'))
        {
          if(tempObject.Business_Sponsor_gne__c != 'Development Employee' && tempObject.Business_Sponsor_gne__c != 'Commercial Employee')
              strErrBusinessSponsor = '<strong>Error:</strong> Contract or Without Contracted Services is required';
            ret = false;
        }
        else
      {
        strErrBusinessSponsor = '';
      }
        
        if(tempObject.Actual_Attendees_gne__c == null){
            tempObject.Actual_Attendees_gne__c.addError('Actual Attendee is required and numeric');         
            ret = false;
        }else if(tempObject.Actual_Attendees_gne__c != null  && tempObject.Actual_Attendees_gne__c == 0){
            tempObject.Actual_Attendees_gne__c.addError('Actual Attendee is required and numeric');
            ret = false;    
        }else if(tempObject.Actual_Attendees_gne__c != null  && tempObject.Actual_Attendees_gne__c < 1){
            tempObject.Actual_Attendees_gne__c.addError('Number of Actual Attendee can not be less than 1');
            ret = false;
        }
        
        if(tempObject.Planned_Attendees_gne__c == null){
            tempObject.Planned_Attendees_gne__c.addError('Planned Attendee is required and numeric');          
            ret = false;
        }else if(tempObject.Planned_Attendees_gne__c != null && tempObject.Planned_Attendees_gne__c == 0){
            tempObject.Planned_Attendees_gne__c.addError('Planned Attendee is required and numeric');
            ret = false;
        }else if(tempObject.Planned_Attendees_gne__c != null  && tempObject.Planned_Attendees_gne__c < 1){
            tempObject.Planned_Attendees_gne__c.addError('Number of Planned Attendee can not be less than 1');
            ret = false;            
        }   

        return ret;
    }
    
    //  public List<Call2_vod__c> getcallList(){        
    //      return callList;
    //  }
    
    public PageReference Cancel(){  
        String strCanURL = ApexPages.currentPage().getParameters().get('canURL');
        if(Utility.Isnull(strCanURL)) strCanURL = DEFAULT_CANCEL_URL;       
        return Utility.RedirectPage(strCanURL);         
    }

    /*  public PageReference Continu(){ 
            return Utility.RedirectPage('/apex/IRecord?' + CONFIRM + '=true&Id=' + interactionID);          
        }
    */  
    public void addMessage(String strMsg){
        if(strMsg == null) strMsg = 'null';
        ApexPages.Message testMsg = new ApexPages.Message(ApexPages.Severity.WARNING, strMsg);
        ApexPages.addMessage(testMsg);
    }

    public void addErrMessage(String strMsg){
        
        if(strMsg == null) strMsg = 'null';
        ApexPages.Message testMsg = new ApexPages.Message(ApexPages.Severity.WARNING, strMsg);
        ApexPages.addMessage(testMsg);
    }
    
    //added by sandeep
    //This method adds a Non COmmercial Molecule from IRecord page without invoking Non-Commercial Popup
    private Boolean addTheraProductList(String sAddHCPId, String sTheraArea, String sIndication)
    {
        List<Product_vod__c> lstProductCatalog = new List<Product_vod__c>();
        Id sNonCommProductId;
        String sProductNonCommercial;
        
        try
        {
            lstProductCatalog=[SELECT Id, Name, Product_Code_gne__c, Product_Type_vod__c, GNE_Part_Number_gne__c, Therapeutic_Area_vod__c, Therapeutic_Class_vod__c, Disease_Indication_gne__c FROM Product_Vod__c WHERE Product_Type_vod__c='Detail' and Name Like 'Non-Commercial%' order by Name ];
        }
        catch(Exception ex)
        {
            //do nothing
        }
        if(lstProductCatalog!=null && lstProductCatalog.size()>0)
        {
            sNonCommProductId=lstProductCatalog[0].Id;
            sProductNonCommercial=lstProductCatalog[0].Name;
            
            Brand clsBrand = new Brand(lstProductCatalog[0]);
            integer duplicateNonCommercialBrand = 1;
            for (integer i=0; i <brandList.size(); i++ )
            { 
                if(brandList[i].Id == sNonCommProductId)
                { 
                    duplicateNonCommercialBrand = -1;
                }  
            }
            
            if(duplicateNonCommercialBrand==1)
            {
                brandList.add(clsBrand);
            } 
        }
        
        return true;
    }
    
    
    private Boolean addProductList(String sAddHCPId, String sTheraArea, String sIndication)
    {
        
        Product_Vod__c objProduct = [ Select Id, Name, Product_Code_gne__c, Product_Type_vod__c, GNE_Part_Number_gne__c,Disease_Indication_gne__c, Therapeutic_Area_vod__c, Therapeutic_Class_vod__c from Product_Vod__c where id = :sAddHCPId ];
        
        Brand clsBrand = new Brand(objProduct);
        clsBrand.Therapeutic_Area = objProduct.Therapeutic_Area_vod__c;
        
        if (!Utility.IsNull(sTheraArea))
        {
            clsBrand.Therapeutic_Area = STheraArea;
        }
        
        if (!Utility.IsNull(sIndication)){
            clsBrand.Indication = sIndication;
        }
        
        
        //starts updated sandeep
        //does not make sense to check duplicate products by name when adding products
        //and by Therapeutic Area or Indication while loading interaction, so made it consistent by name
        integer duplicatetherapatic = 1;
        //integer duplicatedi = 1;
        
        for (integer i=0; i <brandList.size(); i++ )
        { 
            //    if(brandList[i].Therapeutic_Area == STheraArea)
            //    { 
            //        duplicatetherapatic = -1;
            //    }  
            //    if(brandList[i].Indication == sIndication)
            //    { 
            //       duplicatedi = -1;
            //   } 
            
            if(brandList[i].Name == objProduct.Name)
            {
                duplicatetherapatic = -1;
            }                 
        } 
        
        
        
        if(duplicatetherapatic == 1)
        {
            brandList.add(clsBrand);                                    
        } 
        //else if(duplicatedi == 1)
        //{
        //    brandList.add(clsBrand);
        //}  
        //ends updated sandeep
        return true;

    }

    private Boolean addPersonAccount(String sAddHCPId){
        //add HCP to the list from child window         
        Account acct; 
        String acctPrimaryAdd = '';
        Attendee tempAttendee = new Attendee();
        System.debug('XXXX addPersonAccount was trigger');
        try
        {
            //the account record with the Id may not be found if the record is deleted so catch the exception here
            //acct = [Select id,name, Account_Type_gne__c, (select id, Name, City_vod__c, State_vod__c,Zip_vod__c from Address_vod__r where Primary_vod__c = true ) from Account where id = :sAddHCPId]; //Order By Primary_vod__c, Gold_Record_gne__c, Active_Flag_gne__c
            //acct = [Select id,name, Account_Type_gne__c, RecordType.Description, (select id, Name, City_vod__c, State_vod__c,Zip_vod__c from Address_vod__r) from Account where id = :sAddHCPId]; //Order By Primary_vod__c, Gold_Record_gne__c, Active_Flag_gne__c
            acctDao = new GNE_Account_Dao(false);
            acct = acctDao.getById(sAddHCPId);
            System.debug('XXXX acctDao.getById(sAddHCPId) : '+ acct);
            System.debug('XXXX  SAddHCPAddressId : '+  SAddHCPAddressId);
            
            if(acct!=null)
            {
                Address_vod__c selectedAddr;
                if (!Utility.isNull(SAddHCPAddressId))
                {
                    for (Address_vod__c addrRow : acct.Address_vod__r)
                    {
                        if (addrRow.Id == SAddHCPAddressId)
                        {
                            selectedAddr = addrRow;                             
                        }
                    }   
                }   
                if (selectedAddr == null && acct.Address_vod__r != null && acct.Address_vod__r.size() > 0){ selectedAddr = acct.Address_vod__r[0];}
                
                if (!Utility.isNull(selectedAddr.Name)){ acctPrimaryAdd +=' ' +  selectedAddr.Name; }    
                if (!Utility.isNull(selectedAddr.Address_line_2_vod__c)){ acctPrimaryAdd +=' ' +  selectedAddr.Address_line_2_vod__c; }
                if (!Utility.isNull(selectedAddr.City_vod__c)){ acctPrimaryAdd += ' ' + selectedAddr.City_vod__c;}    
                if (!Utility.isNull(selectedAddr.State_vod__c)){ acctPrimaryAdd +=' ' +  selectedAddr.State_vod__c;}
                if (!Utility.isNull(selectedAddr.Zip_vod__c)){ acctPrimaryAdd += ' ' +  selectedAddr.Zip_vod__c;}
                
                if(hcpActual == 0){
                    accountId = acct.id;
                    accountAddressId = selectedAddr.Id;
                    accountPrimaryAddress = acctPrimaryAdd;              
                }
                tempAttendee.id = acct.id;
                tempAttendee.name = acct.FirstName;
                if (!Utility.isNull(acct.Middle_vod__c)) { tempAttendee.name += ' ' + acct.Middle_vod__c;}
                tempAttendee.name += ' ' + acct.LastName;
                tempAttendee.attendeeType = acct.RecordType.Description;
                tempAttendee.primaryAddress = acctPrimaryAdd ;
                tempAttendee.iAttendeeType = iPhoneApex.AttendeeType.PERSONACCOUNT;
                System.debug('XXXX tempAttendee :' +tempAttendee );
                attendeeList.add(tempAttendee);
                hcpActual = hcpActual + 1;  
                
            }
            else
            {
              Account failedAcct = [Select name from Account where id = :sAddHCPId];
              if(failedAcct != null)
                isSubscribeSuccess = 'System was not able to add HCP to the interaction. Please contact Help Desk with the following information '+failedAcct.Name+' or '+sAddHCPId+'.';
              else
                isSubscribeSuccess = 'System was not able to add HCP to the interaction. Please contact Help Desk with the following information Account Name or '+sAddHCPId+'.';
            }
        } catch(Exception ex)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Unexpected Exception: Message = '+ex.getMessage()));
            return false;
        }          
        return true;
    }
    
    //  Load Existing Interaction
    private boolean loadInteraction(String Call2_Id) {
        iPhoneApex.CallAttributes existInteraction = new iPhoneApex.CallAttributes();

        existInteraction = iPhoneApex.getCallAttributes(Call2_Id);

        if(existInteraction == null){
            // handle error
            addMessage('Can`t find the Interaction');
            return false;   
        }
        
        if(!Utility.isNull(existInteraction.id))
        {
            tempObject.id = existInteraction.id;
        }
        tempObject.Call_Date_vod__c             = existInteraction.CallDateTime.Date();
        tempObject.Planned_Attendees_gne__c     = existinteraction.MealPlannedAttendeeCount;
        tempObject.Actual_Attendees_gne__c      = existinteraction.MealActualAttendeeCount;
        tempObject.City_gne__c                  = existinteraction.MealLocationCity;
        tempObject.State_gne__c                 = existinteraction.MealLocationState;
        tempObject.Business_Sponsor_gne__c      = existinteraction.BusinessSponsor;
        businessSponsorSavedValue         = existinteraction.BusinessSponsor;
        tempObject.Spend_User_gne__c            = existinteraction.SpendUser;  
        tempObject.Interaction_Type_gne__c      =  existinteraction.InteractionType; 
        tempObject.Interaction_Location_gne__c  = existinteraction.InteractionLocation;
        tempObject.Meal_Amount_gne__c           = existinteraction.MealAmount;
        
        InteractionType = existinteraction.InteractionType;
        
        //Explicity adding the main account to accomidate the changes in IPHONE APEX
        this.addPersonAccount(existinteraction.Account);
        Boolean isPayer = true; 
        for(iPhoneApex.CallAttendee attnd : existInteraction.callAttendeeList){
            if (attnd.CallAttendeeType == iPhoneApex.AttendeeType.USER){
                this.addUserAttendee( attnd.Attendee, isPayer);
                isPayer =  false;
            }
            
            if (attnd.CallAttendeeType == iPhoneApex.AttendeeType.PERSONACCOUNT){
                this.addPersonAccount(attnd.Attendee);
            }   
        }
        
        for(iPhoneApex.CallDetail detail : existInteraction.callDetailList){
            addProductList (detail.Product, detail.TherapeuticArea, detail.DiseaseIndication);  
        }
        return true;
    }
    
    //No action on Data
    public PageReference dataIncorrectNoChange ()
    {
        disableButtons = false;
        if(!Utility.isNull(caseActionId))
        {
            AGS_Case_Action_gne__c objCaseAction;
            try{
                objCaseAction=[Select Id, AGS_Validate_Data_1_box_gne__c, AGS_Validate_Data_2_box_gne__c, AGS_Validate_Data_3_box_gne__c from AGS_Case_Action_gne__c where id=:caseActionId];
            }catch(Exception ex){}
            //disp;lay confirmation message if compliance is accepted by user 
            if(objCaseAction!=null && objCaseAction.AGS_Validate_Data_3_box_gne__c == true)
            {
                return Utility.RedirectPage(GetHost + '/apex/ShowMessage?msgid=INF_USER_PLEASE_VALIDATE');
            }
            //update option selected. The trigger on case action will send confirmation email
            objCaseAction.AGS_Validate_Data_1_box_gne__c = false;
            objCaseAction.AGS_Validate_Data_2_box_gne__c = false;
            objCaseAction.AGS_Validate_Data_3_box_gne__c = true;
            JScript = 'CloseWindow();'; 
            update objCaseAction;
        }
        
        //return null;
        return  Utility.RedirectPage(GetHost + '/apex/IRecord?caseactionid='+caseActionId+'&caseid='+caseId+'&interactionid='+ApexPages.currentPage().getParameters().get(CALL_ID)+'&mode='+Mode);
    }
    
    //Data Correct No Change
    public PageReference dataCorrectNoChange (){
        /* CHAITANYA START
        if(!Utility.isNull(caseActionId))
        {
            AGS_Case_Action_gne__c objCaseAction;
            try{
            objCaseAction=[Select Id, AGS_Validate_Data_1_box_gne__c, AGS_Validate_Data_2_box_gne__c, AGS_Validate_Data_3_box_gne__c, Action_Status_internal_gne__c from AGS_Case_Action_gne__c where id=:caseActionId];
            }catch(Exception ex){}
            //display confirmation message if compliance is accepted by user //adeed action status below and above for testing
            if(objCaseAction!=null && objCaseAction.AGS_Validate_Data_1_box_gne__c == true && objCaseAction.Action_Status_internal_gne__c == 'Closed')
            {system.debug('hello');
                return Utility.RedirectPage('/apex/ShowMessage?msgid=INF_USER_PLEASE_VALIDATE');
            }
            //update option selected. The trigger on case action will send confirmation email
            objCaseAction.AGS_Validate_Data_1_box_gne__c = true;
            objCaseAction.AGS_Validate_Data_2_box_gne__c = false;
            objCaseAction.AGS_Validate_Data_3_box_gne__c = false;
            system.debug('hello');
            system.debug('INFREQUENT USERS INF USERS IF USERS @@@@@@@@@@@@@@@@@@@@@@@@@@*****************************');
            update objCaseAction;
        }
        //JScript = 'CloseWindow();'; 
        system.debug('About to set url'); 
        CHAITANYA END*/
        return  Utility.RedirectPage(GetHost + '/apex/ConfirmPolicy?caseactionid='+caseActionId+'&caseid='+caseId+'&interactionid='+ApexPages.currentPage().getParameters().get(CALL_ID));
        //return  Utility.RedirectPage('/apex/IRecord?caseactionid='+caseActionId+'&caseid='+caseId+'&interactionid='+ApexPages.currentPage().getParameters().get(CALL_ID)+'&mode='+Mode);
    }
    
    //Data is corrected
    public Pagereference  dataIncorrectChange (){
        disableButtons = false;
        system.debug('I am in option 2 July 16');
        if(!Utility.isNull(caseActionId))
        {
            AGS_Case_Action_gne__c objCaseAction;
            try{
                objCaseAction=[Select Id, AGS_Validate_Data_1_box_gne__c, AGS_Validate_Data_2_box_gne__c, AGS_Validate_Data_3_box_gne__c from AGS_Case_Action_gne__c where id=:caseActionId];
            }
            catch(Exception ex){}
            //disp;lay cobjCaseActiononfirmation message if compliance is accepted by user 
            if(objCaseAction!=null && objCaseAction.AGS_Validate_Data_2_box_gne__c == true)
            {
                return Utility.RedirectPage(GetHost + '/apex/ShowMessage?msgid=INF_USER_PLEASE_VALIDATE');
            }
            //update option selected. The trigger on case action will send confirmation email
            objCaseAction.AGS_Validate_Data_1_box_gne__c = false;
            objCaseAction.AGS_Validate_Data_2_box_gne__c = true;
            objCaseAction.AGS_Validate_Data_3_box_gne__c = false;
            system.debug('I am in option 2 update July 16');
            update objCaseAction;
            
        }
        // JScript = 'CloseWindow();'; 
        return null;
    }
    public void disablebuttons(){
        disableButtons = false;
    }
    public String getUserName(){
        return UserInfo.getLastName() + ' ' + UserInfo.getFirstName();
    }
    /*  $$$$  NO more using ready for deactivation flag on USER object $$$$
    public Boolean setUserReadyForDeactivate(){
        if (loginUserInfo.Profile.Name == INF_PROFILE_NAME){           
                loginUserInfo.Ready_For_Deactivate_gne__c = true;
                update loginUserInfo;
        }              

        return true;       
    }   
*/  
    public PageReference RefreshBusinessSponsorStatusOptions(){
        // contractType = 'Refresh';
        return null;
    }
    /*  public String getConfirmMessage(){
            return ' Please confirm that do you want to apply new  changes to existing Interaction Record as data is incorrect.<br>';   
        }
    */
    public List<SelectOption> getstates()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult =
        Call2_vod__c.State_gne__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('--', '--'));
        options.add(new SelectOption('Non-US State', 'Non-US State'));
        
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    public void savedisable()
    {
        savestate=true;
        
    }

}