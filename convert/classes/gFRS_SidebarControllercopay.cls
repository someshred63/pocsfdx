/**
* @author GFRS Dev Team
* @date 20/08/2013
* @description gFRS_SidebarControllercopay class - controller for the portal sidebar.
*/
public with sharing class gFRS_SidebarControllercopay {
    
    public GFRS_Organization__c organization;
    
    //-- literals
    public static final String STYLE_OVER  = 'over';
    public static final String STYLE_DONE  = 'done';
    public static final String STYLE_CLEAR = '';
    
    //Menu options names
    public static final String MENU_ORGANIZATION     = 'Organization';
    public static final String MENU_APPLICATION      = 'Donation';
    public static final String MENU_PROGRAM          = 'Program';
    public static final String MENU_BUDGET           = 'Budget';
    public static final String MENU_FILE_ATTACHMENTS = 'Attachments';
    public static final String MENU_CONFIRMATION     = 'Confirmation';
    public static final String MENU_THIRDPARTY       = 'Third Party';
    public static final String MENU_PROGRAMDESIGN    = 'Program Design';
    
    //Paths
    public static final String PATH_ORGANIZATION     = '/apex/gFRS_Org_Infocopay';
    public static final String PATH_DECISION         = '/apex/GFRS_Decisioncopay';
    public static final String PATH_APPLICATION      = '/apex/GFRS_Applicationcopay';
    public static final String PATH_DISEASESTATE      = '/apex/gFRS_AddDiseaseStateCopay';
    public static final String PATH_PROGRAMDESIGN    = '/apex/GFRS_ProgramDesigncopay';
    public static final String PATH_THIRDPARTY       = '/apex/gFRS_ThirdPartycopay';
    public static final String PATH_PROGRAM          = '/apex/gFRS_Programcopay';
    public static final String PATH_BUDGET           = '/apex/gFRS_Budgetcopay';
    public static final String PATH_FILE_ATTACHMENTS = '/apex/gFRS_FileAttachmentCopay';
    public static final String PATH_CONFIRMATION     = '/apex/GFRS_Confirmationcopay';
    
    public String nav1Style     { get; set; }
    public String nav2Style     { get; set; }
    public String nav3Style     { get; set; }
    public String nav4Style     { get; set; }
    public String nav5Style     { get; set; }
    public String nav6Style     { get; set; }
    public String nav7Style     { get; set; }
    public String nav8Style     { get; set; }
    
    public Boolean isNewRequest { get; set; }   
    
    public Boolean isOrgSpecified        { get; set; }  
    public Boolean isApplicationFilled   { get; set; }
    public Boolean isProgramDesignSpecified { get; set; }  
    public Boolean isThirdPartySpecified { get; set; }
    public Boolean isProgramSpecified    { get; set; }
    public Boolean isBudgetSpecified     { get; set; }
    public Boolean isAttachmentSpecified { get; set; }
    public Boolean isConfirmed           { get; set; }
    
    public String orgLink                { get; set; }  
    public String applicationLink        { get; set; }
    public String programDesignLink      { get; set; }
    public String thirdPartyLink         { get; set; }
    public String programLink            { get; set; }  
    public String budgetLink             { get; set; }
    public String fileAttachmentsLink    { get; set; }
    public String confirmationLink       { get; set; }
    
    public String orgStyleClass          { get; set; }  
    public String applicationStyleClass  { get; set; }
    public String programDesignStyleClass{ get; set; }
    public String thirdPartyStyleClass   { get; set; }
    public String programStyleClass      { get; set; }  
    public String budgetStyleClass       { get; set; }
    public String attachmentsStyleClass  { get; set; }
    public String confirmationStyleClass { get; set; }
    
    public String parameters             = '';
    
    private String p_currentSection;
    
    public Boolean budgetVisible         { get; set; }
    public Boolean attachmentsVisible    { get; set; }
    public Boolean thirdPartyVisible     { get; set; }
    public Boolean programDesignVisible  { get; set; }
    
    public String activeSection          { get; set; }
    public String resultURL              { get; set; }
    
    public Boolean enableViewMode  = False;
    public String request_progress = '';
    
    public gFRS_SidebarControllercopay(){
        
        this.resultURL = ApexPages.currentPage().getUrl();
        if(this.resultURL!=null)
        { 
            if(this.resultURL.toLowerCase().contains(PATH_ORGANIZATION.toLowerCase()) || this.resultURL.toLowerCase().contains(PATH_DECISION.toLowerCase())){
                this.orgStyleClass = 'active';  
            }else{
                this.orgStyleClass = '';    
            }
        }
    }
    
    private GFRS_Organization__c getOrganization(Id organizationId){
        List<GFRS_Organization__c> organizationsList = gFRS_DAO.getOrganizationById(organizationId);
        if(organizationsList.size()>0)
            return organizationsList.get(0);
        return null;
    }
    
    
    public GFRS_copay_Funding_Request__c fundingRequest { 
        get;
        set{
            //System.debug('PN&&&&: resultURL : ' + resultURL.toLowerCase());
            if(value!=null && value.Id != null){
                
                List<GFRS_copay_Funding_Request__c> requestsList = [
                SELECT  Total_Program_Budget__c  , Locationcopay__c , ParentRecord__c, clonedRequestOwner__c, Request_Cloned__c,
                        Id, Business_Reviewer_1__c, Legal_Reviewer_1__c, Business_Approver_2__c, Business_Approver_3__c, Financial_Approver_1__c,
                        Financial_Approver_1_Decision_Date__c, Financial_Approver_2__c, 
                        Financial_Approver_2_Decision_Date__c, Financial_Approver_3__c, 
                        Financial_Approver_3_Decision_Date__c, isLocked, Name,owner.id, 
                        Owner.Email, Owner.Name, Total_Approved_Amt__c,
                        Foundation_Classified__c, Request_Creation_Progress__c,
                        Building__c, Delivery_Method__c,Payment_Method__c, Event_Program_Title__c, 
                        External_Sub_status__c, Information_Needed__c, LOA_Signed__c, 
                        Locationcopay__r.Vendor_Id__c, Organization__r.Id, Payment_Call_Counter__c, 
                        Payment_Email_Notification__c, Record_Type_Name__c, Request_AutoNumber__c, 
                        Requested_Amount__c, Send_By_FedEx_cost_center_will_be_charg__c, Status__c, 
                        Sub_Status__c, Decision_Reasons__c, Will_You_be_Working_With_a_3rd_Party__c,
                        Unix_ID__c, createdById, Accountable_Employee_Approval__c, 
                        Accountable_Employee_Approval__r.Email,Accountable_Employee_Approval__r.Name, 
                        SYS_Request_Approved__c,LOA_PDF__c, LastModifiedBy.Name,Compliance_flags_PDF__c, 
                        Decision_Date__c, HC_Compliance_Date__c, HC_Compliance_Flags_PDF__c, Authorized_Signer__c, 
                        Signing_Authority_First_Name__c, Signing_Authority_Last_Name__c, Signing_Authority_Email__c, 
                        Evaluation_Completed__c, 
                        Business_Approver__c, Business_Reviewer_Decision_Date__c, Business_Reviewer_Decision__c, 
                        Financial_Approver_1__r.Email, Reconciliation_Completed__c,
                        Closed_Date__c 
                FROM gFRS_Copay_Funding_Request__c where Id =: value.Id limit 1];
                
                //gFRS_DAO.getFundingRequestById(value.Id);
                if(requestsList != null && requestsList.size()>0){
                    value = requestsList.get(0);    
                }
                //Organization              
                if(value.Organization__c != null){
                    this.isOrgSpecified = (value.Organization__c != null)?true:false;
                    parameters = 'org=' + value.Organization__c;
                    this.orgLink = gFRS_Utilcopay.initializeLinkcopay(PATH_ORGANIZATION, value, parameters);
                    if(this.resultURL.toLowerCase().contains(PATH_ORGANIZATION.toLowerCase())){
                        this.orgStyleClass = 'active';  
                    }else{
                        this.orgStyleClass = '';    
                    }
                }
                
                //Application
                if(value.Locationcopay__c != null && value.Organization__c!=null ){
                    this.isApplicationFilled = (value.Requested_Amount__c !=null)?true:false;                       
                    parameters = 'loc=' + value.Locationcopay__c + 'org=' + value.Organization__c;
                    this.applicationLink = gFRS_Utilcopay.initializeLinkcopay(PATH_APPLICATION, value, parameters);
                    if(this.resultURL.toLowerCase().contains(PATH_APPLICATION.toLowerCase()) || this.resultURL.toLowerCase().contains(PATH_DISEASESTATE.toLowerCase()) ){
                        this.applicationStyleClass = 'active';  
                    }else{
                        this.applicationStyleClass = '';        
                    }
                }

                //Third Party
                this.isThirdPartySpecified = checkThirdPartyAvailability(value);        
                parameters = '';
                this.thirdPartyLink = gFRS_Utilcopay.initializeLinkcopay(PATH_THIRDPARTY, value, parameters);
                this.thirdPartyVisible =chechIfThirdPartyVisible(value);
                if(this.resultURL.toLowerCase().contains(PATH_THIRDPARTY.toLowerCase())){
                    this.thirdPartyStyleClass = 'active';   
                }else{
                    this.thirdPartyStyleClass = ''; 
                }

                //Program Design and Implementation - only for IMED
                this.isProgramDesignSpecified = checkProgramDesignAvailability(value);        
                parameters = '';
                this.programDesignLink = gFRS_Utilcopay.initializeLinkcopay(PATH_PROGRAMDESIGN, value, parameters);
                this.programDesignVisible = checkIfProgramDesignVisible(value);
                if(this.resultURL.toLowerCase().contains(PATH_PROGRAMDESIGN.toLowerCase())){
                    this.programDesignStyleClass = 'active';   
                }else{
                    this.programDesignStyleClass = ''; 
                }                
                
                //Program
                this.isProgramSpecified = checkProgramAvailability(value);      
                parameters = '';
                this.programLink = gFRS_Utilcopay.initializeLinkcopay(PATH_PROGRAM, value, parameters);   
                if(this.resultURL.toLowerCase().contains(PATH_PROGRAM.toLowerCase())
                    && !this.resultURL.toLowerCase().contains(PATH_PROGRAMDESIGN.toLowerCase())){
                    this.programStyleClass = 'active';  
                }else{
                    this.programStyleClass = '';    
                }   
                                
                //Budget
                this.isBudgetSpecified = (value.Total_Program_Budget__c !=null && this.isProgramSpecified)?true:false;  
                parameters = '';
                this.budgetLink = gFRS_Utilcopay.initializeLinkcopay(PATH_BUDGET, value, parameters);
                this.budgetVisible = !gFRS_Util.isInternalRequest(value.Record_Type_name__c);
                if(this.resultURL.toLowerCase().contains(PATH_BUDGET.toLowerCase())){
                    this.budgetStyleClass = 'active';   
                }else{
                    this.budgetStyleClass = '';
                }
                
                //File Attachments  
                parameters = '';
                this.fileAttachmentsLink = gFRS_Utilcopay.initializeLinkcopay(PATH_FILE_ATTACHMENTS, value, parameters);
                if(value.Record_Type_Name__c == gFRS_Util.TYPE_PHILANTHROPIC_NAME){
                    this.isAttachmentSpecified = this.isBudgetSpecified;
                }else if(value.Record_Type_Name__c == gFRS_Util.TYPE_FELLOWSHIPS_NAME){
                    this.isAttachmentSpecified = (value.Fellowship_Project_Description__c != null)?true:false;      
                }else if(value.Record_Type_Name__c == gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME){
                    this.isAttachmentSpecified = (value.Letter_of_Request__c != null)?true:false;       
                }else if(value.Record_Type_Name__c == gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME || gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME == value.Record_Type_Name__c){
                    this.isAttachmentSpecified = (value.Letter_of_Request__c != null)?true:false;       
                }else if(value.Record_Type_Name__c == gFRS_Util.TYPE_IMED_NAME){
                    this.isAttachmentSpecified = (value.Meeting_Agenda__c != null)?true:false;      
                }else if(value.Record_Type_Name__c == gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME){
                    this.isAttachmentSpecified = (value.Fellowship_Project_Description__c != null)?true:false;      
                }else if(value.Record_Type_Name__c == gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME){
                    this.isAttachmentSpecified = (value.Letter_of_Request__c != null)?true:false;       
                }
                
                this.attachmentsVisible =(value.Record_Type_Name__c == gFRS_Util.TYPE_HC_CHAR_NAME)?false:true;
                if(this.resultURL.toLowerCase().contains(PATH_FILE_ATTACHMENTS.toLowerCase())){
                    this.attachmentsStyleClass = 'active';  
                }else{
                    this.attachmentsStyleClass = '';
                }
                
                //Confirmation
                this.isConfirmed = (value.Authorized_Signer__c!=null || value.Signing_Authority_Email__c!=null)?true:false;
                parameters = '';
                this.confirmationLink = gFRS_Utilcopay.initializeLinkcopay(PATH_CONFIRMATION, value, parameters); 
                if(this.resultURL.toLowerCase().contains(PATH_CONFIRMATION.toLowerCase())){
                    this.confirmationStyleClass = 'active'; 
                }else{
                    this.confirmationStyleClass = '';   
                }
                
                if(!String.isBlank(value.Sub_Status__c) && value.Sub_Status__c != 'Not Submitted'){
                    this.enableViewMode = True;
                }else{
                    this.request_progress = value.Request_Creation_Progress__c;
                }
                                
            }   
        }
    }
        
    public Boolean checkProgramAvailability(GFRS_copay_Funding_Request__c fundingRequest){
        List<GFRS_Program__c> programList = new List<GFRS_Program__c>();
        if(fundingRequest!=null){
            programList = [SELECT Id, Funding_Request__c, Start_Date__c FROM GFRS_Program__c WHERE Funding_Request__c = : fundingRequest.Id AND Start_Date__c!=null];   
        }       
        return (programList.size()>0);
    }
    
    public Boolean checkProgramDesignAvailability(GFRS_copay_Funding_Request__c fundingRequest){
        List<gFRS_Program_Design_and_Implementation__c> programDesignList = new List<gFRS_Program_Design_and_Implementation__c>();
        if(fundingRequest!=null){
        //    return [SELECT Id FROM gFRS_Program_Design_and_Implementation__c WHERE GFRS_copay_Funding_Request__c = : fundingRequest.Id].size()>0;   
        }       
        return false;
    }

    public Boolean checkThirdPartyAvailability(GFRS_copay_Funding_Request__c fundingRequest){
        if(fundingRequest != null){
            return [SELECT Id FROM gFRS_Third_Party__c WHERE Funding_Request__c =:fundingRequest.Id AND Company_Name__c != null].size()>0;
        }
        return false;
    }
    
    public Boolean chechIfThirdPartyVisible(GFRS_copay_Funding_Request__c fundingRequest){
        if(fundingRequest != null){
            return [SELECT Id, Record_Type_Name__c, Will_You_be_Working_With_a_3rd_Party__c FROM GFRS_copay_Funding_Request__c 
                               WHERE Id =: fundingRequest.Id AND (Record_Type_Name__c =:gFRS_Util.TYPE_IMED_NAME OR Record_Type_Name__c =:gFRS_Util.TYPE_HC_CHAR_NAME) 
                               AND Will_You_be_Working_With_a_3rd_Party__c =:gFRS_Util.YES].size()>0;
        }
        return false;
    }

    public Boolean checkIfProgramDesignVisible(GFRS_copay_Funding_Request__c fundingRequest){
        if(fundingRequest != null && fundingRequest.Record_Type_name__c == gFRS_Util.TYPE_IMED_NAME){
            return true;
        }
        return false;
    }
    
    public String currentSection {
        get {
            return( this.p_currentSection );
        }
        
        set {
            if (value != '5' && value != '6' && value != '7' && value != '8') {
                this.clearStyles();
            }
            this.p_currentSection = value;
            //System.debug( 'currentSection:' + value );
            
            if( value == '1' ){
                this.nav1Style = STYLE_OVER;
                this.nav2Style = this.nav3Style = this.nav4Style = STYLE_CLEAR;
            } else if( value == '2' ){
                this.nav2Style = STYLE_OVER;
                this.nav1Style = STYLE_DONE;
                this.nav3Style = this.nav4Style = STYLE_CLEAR;
            } else if( value == '3' ){
                this.nav3Style = STYLE_OVER;
                this.nav1Style = this.nav2Style = STYLE_DONE;
                this.nav4Style = STYLE_CLEAR;
            } else if( value == '4' ){
                this.nav4Style = STYLE_OVER;
                this.nav1Style = this.nav2Style = this.nav3Style = STYLE_DONE;
            }
            
            this.nav5Style = STYLE_CLEAR;
            this.nav6Style = STYLE_CLEAR;
            this.nav7Style = STYLE_CLEAR;
            this.nav8Style = STYLE_CLEAR;
            //System.debug( 'nav1Style:' + this.nav1Style );
            
            this.nav1Style = STYLE_OVER;
        }
    }
    
    /**
    * @author GFRS Dev Team 
    * @date 20/08/2013
    * @description clearStyles method - clears styles
    */
    private void clearStyles(){
        this.nav1Style = this.nav2Style = this.nav3Style = this.nav4Style = STYLE_CLEAR;
    }
    
    List<MenuWrapper> menuOptions;
    
    /**
    * @author GFRS Dev Team 
    * @date 20/08/2013
    * @description getMenuOptions method - prepares options for left side menu - SFDC-1778 
    */
    public List<MenuWrapper> getMenuOptions1(){
        menuOptions = new List<MenuWrapper>{new MenuWrapper(MENU_ORGANIZATION, orgLink, isOrgSpecified, true, this.orgStyleClass)
             };
        if(attachmentsVisible == null)     
        menuOptions.add(new MenuWrapper(MENU_APPLICATION, applicationLink, isApplicationFilled,true,this.applicationStyleClass));
             
        if(thirdPartyVisible != null && thirdPartyVisible){
        //    menuOptions.add(new MenuWrapper(MENU_THIRDPARTY, thirdPartyLink, isThirdPartySpecified, thirdPartyVisible,this.thirdPartyStyleClass));
        }
        
        if(programDesignVisible != null && programDesignVisible){
         //   menuOptions.add(new MenuWrapper(MENU_PROGRAMDESIGN, programDesignLink, isProgramDesignSpecified, programDesignVisible,this.programDesignStyleClass));
        }

      //  menuOptions.add(new MenuWrapper(MENU_PROGRAM, programLink, isProgramSpecified,true,this.programStyleClass));         
        if(budgetVisible!=null && budgetVisible){
        //    menuOptions.add(new MenuWrapper(MENU_BUDGET, budgetLink, isBudgetSpecified, budgetVisible,this.budgetStyleClass));
        }
        
        //Attachments
        if(this.attachmentsVisible != null && this.attachmentsVisible ){
         menuOptions.add( new MenuWrapper(MENU_APPLICATION, applicationLink, true,true,this.applicationStyleClass) );
           
           
        }
         IF(!(this.resultURL.toLowerCase().contains(PATH_CONFIRMATION.toLowerCase()))){
          menuOptions.add(new MenuWrapper(MENU_FILE_ATTACHMENTS, this.fileAttachmentsLink, this.isAttachmentSpecified, this.attachmentsVisible,this.attachmentsStyleClass));
         }
        if(this.resultURL.toLowerCase().contains(PATH_CONFIRMATION.toLowerCase())){
         menuOptions.add( new MenuWrapper(MENU_FILE_ATTACHMENTS, this.fileAttachmentsLink, true,true,this.applicationStyleClass) );
        }
               
        
        //Confirmation
        menuOptions.add(new MenuWrapper(MENU_CONFIRMATION, confirmationLink, isConfirmed, true,this.confirmationStyleClass));       
        return menuOptions; 
    }
    
    
    public List<MenuWrapper> getMenuOptions(){
    menuOptions = new List<MenuWrapper>();
    
        
        if(this.enableViewMode){
            
            menuOptions.clear();
            menuOptions.add( new MenuWrapper(MENU_ORGANIZATION, orgLink, true, true, STYLE_OVER) );
            menuOptions.add( new MenuWrapper(MENU_APPLICATION, applicationLink, true,true,STYLE_OVER) );
            menuOptions.add( new MenuWrapper(MENU_FILE_ATTACHMENTS, this.fileAttachmentsLink, true,true,STYLE_OVER) );
            menuOptions.add( new MenuWrapper(MENU_CONFIRMATION, confirmationLink, true, true,STYLE_OVER)); 
            
        }
        else{
            if(String.isBlank(request_progress)){

                menuOptions.clear();
                menuOptions.add( new MenuWrapper(MENU_ORGANIZATION, orgLink, true, true, STYLE_OVER) );
                menuOptions.add( new MenuWrapper(MENU_APPLICATION, applicationLink, false, true, STYLE_CLEAR) );
                menuOptions.add( new MenuWrapper(MENU_FILE_ATTACHMENTS, this.fileAttachmentsLink, false,true, STYLE_CLEAR) );
                menuOptions.add( new MenuWrapper(MENU_CONFIRMATION, confirmationLink, false, true, STYLE_CLEAR)); 
            
            }
            else if(request_progress == MENU_ORGANIZATION){
                
                menuOptions.clear();
                menuOptions.add( new MenuWrapper(MENU_ORGANIZATION, orgLink, true, true, STYLE_OVER) );
                menuOptions.add( new MenuWrapper(MENU_APPLICATION, applicationLink, true,true, STYLE_OVER) );
                menuOptions.add( new MenuWrapper(MENU_FILE_ATTACHMENTS, this.fileAttachmentsLink, false,true, STYLE_CLEAR) );
                menuOptions.add( new MenuWrapper(MENU_CONFIRMATION, confirmationLink, false, true, STYLE_CLEAR)); 
            
            }else if(request_progress == MENU_APPLICATION){
                
                menuOptions.clear();
                menuOptions.add( new MenuWrapper(MENU_ORGANIZATION, orgLink, true, true, STYLE_OVER) );
                menuOptions.add( new MenuWrapper(MENU_APPLICATION, applicationLink, true,true, STYLE_OVER) );
                menuOptions.add( new MenuWrapper(MENU_FILE_ATTACHMENTS, this.fileAttachmentsLink, true,true, STYLE_OVER) );
                menuOptions.add( new MenuWrapper(MENU_CONFIRMATION, confirmationLink, false, true, STYLE_CLEAR));
                
            }else if(request_progress == MENU_FILE_ATTACHMENTS){
                
                menuOptions.clear();
                menuOptions.add( new MenuWrapper(MENU_ORGANIZATION, orgLink, true, true, STYLE_OVER) );
                menuOptions.add( new MenuWrapper(MENU_APPLICATION, applicationLink, true,true, STYLE_OVER) );
                menuOptions.add( new MenuWrapper(MENU_FILE_ATTACHMENTS, this.fileAttachmentsLink, true,true, STYLE_OVER) );
                menuOptions.add( new MenuWrapper(MENU_CONFIRMATION, confirmationLink, true, true, STYLE_OVER)); 
                
            } 
            
        }
            
        String strOrg = 'gFRS_Org_Infocopay';
        String strDecision = 'GFRS_Decisioncopay';
        String strApp = 'GFRS_Applicationcopay';
        String strAddDisease = 'gFRS_AddDiseaseStateCopay';
        String strAtt = 'gFRS_FileAttachmentCopay';
        String strConf = 'GFRS_ConfirmationCoPay';
        String currentPage = '';

        if(this.resultURL.toLowerCase().contains(strOrg.toLowerCase()) || this.resultURL.toLowerCase().contains(strDecision.toLowerCase())){
            currentPage = MENU_ORGANIZATION;
        }else if(this.resultURL.toLowerCase().contains(strApp.toLowerCase()) || this.resultURL.toLowerCase().contains(strAddDisease.toLowerCase())){
                //system.assertEquals(3, 4);
            currentPage = MENU_APPLICATION;
        }else if(this.resultURL.toLowerCase().contains(strAtt.toLowerCase())){
            currentPage = MENU_FILE_ATTACHMENTS;
        }else if(this.resultURL.toLowerCase().contains(strConf.toLowerCase())){
            currentPage = MENU_CONFIRMATION;
        }
        
        for(MenuWrapper opt : menuOptions){
            if(opt.label !=null && opt.label == currentPage){
                opt.styleClass = 'active';
                opt.optionAsLink = true;
            }
        }

        return menuOptions;       
    }
    

    /**
    * @author GFRS Dev Team 
    * @date 20/08/2013
    * @description MenuWrapper class - wrapper class for menu options 
    */
    public class MenuWrapper{
        public MenuWrapper(String label, String link, Boolean optionAsLink, Boolean optionVisible, String styleClass){
            this.label         = label;
            this.link          = link;
            this.optionAsLink  = optionAsLink;
            this.optionVisible = optionVisible;
            this.styleClass    = styleClass;
        }
        public String label          { get; set; }
        public String link           { get; set; }
        public Boolean optionAsLink  { get; set; }
        public Boolean optionVisible { get; set; }
        public String styleClass     { get; set; }
    }
}