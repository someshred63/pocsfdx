/**
* @author GFRS Dev Team
* @date 20/08/2013
* @description gFRS_SidebarController class - controller for the portal sidebar.
*/
public with sharing class gFRS_SidebarController {
    
    public GFRS_Organization__c organization;
    //-- literals
    public static final String STYLE_OVER  = 'over';
    public static final String STYLE_DONE  = 'done';
    public static final String STYLE_CLEAR = '';
    //Menu options names
    public static final String MENU_ORGANIZATION     = 'Organization';
    public static final String MENU_APPLICATION      = 'Application';
    public static final String MENU_PROGRAM          = 'Program';
    public static final String MENU_BUDGET           = 'Budget';
    public static final String MENU_FILE_ATTACHMENTS = 'Attachments';
    public static final String MENU_PAYMENT_METHOD   = 'Payment Method';
    public static final String MENU_CONFIRMATION     = 'Confirmation';
    public static final String MENU_THIRDPARTY       = 'Third Party';
    public static final String MENU_PROGRAMDESIGN    = 'Program Design';
    //Paths
    public static final String PATH_ORGANIZATION     = '/apex/gFRS_Org_Info';
    public static final String PATH_DECISION         = '/apex/GFRS_Decision';
    public static final String PATH_APPLICATION      = '/apex/GFRS_Application';
    public static final String PATH_PROGRAMDESIGN    = '/apex/GFRS_ProgramDesign';
    public static final String PATH_THIRDPARTY       = '/apex/gFRS_ThirdParty';
    public static final String PATH_PROGRAM          = '/apex/gFRS_Program';
    public static final String PATH_BUDGET           = '/apex/gFRS_Budget';
    public static final String PATH_FILE_ATTACHMENTS = '/apex/gFRS_FileAttachments';
    public static final String PATH_PAYMENT_METHOD   = '/apex/gFRS_ACHData';
    public static final String PATH_CONFIRMATION     = '/apex/GFRS_Confirmation';
    
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
    public Boolean isPaymentMethodSpecified { get; set; }
    public Boolean isConfirmed           { get; set; }
    
    public String orgLink                { get; set; }
    public String applicationLink        { get; set; }
    public String programDesignLink      { get; set; }
    public String thirdPartyLink         { get; set; }
    public String programLink            { get; set; }
    public String budgetLink             { get; set; }
    public String fileAttachmentsLink    { get; set; }
    public String paymentMethodLink      { get; set; }
    public String confirmationLink       { get; set; }
    
    public String orgStyleClass          { get; set; }
    public String applicationStyleClass  { get; set; }
    public String programDesignStyleClass{ get; set; }
    public String thirdPartyStyleClass   { get; set; }
    public String programStyleClass      { get; set; }
    public String budgetStyleClass       { get; set; }
    public String attachmentsStyleClass  { get; set; }
    public String paymentMethodStyleClass { get; set; }
    public String confirmationStyleClass { get; set; }
    
    private String p_currentSection;
    
    public Boolean budgetVisible         { get; set; }
    public Boolean attachmentsVisible    { get; set; }
    public Boolean thirdPartyVisible     { get; set; }
    public Boolean paymentMethodVisible  { get; set; }
    public Boolean programDesignVisible  { get; set; }
    
    public String activeSection          { get; set; }
    public String resultURL              { get; set; }
    
    public gFRS_SidebarController() {
        resultURL = ApexPages.currentPage() == null ? null : ApexPages.currentPage().getUrl();
        orgStyleClass = String.isBlank(resultURL) ||
            !resultURL.toLowerCase().contains(PATH_ORGANIZATION.toLowerCase()) &&
            !resultURL.toLowerCase().contains(PATH_DECISION.toLowerCase())? '' : 'active';
    }
    
    private GFRS_Organization__c getOrganization(Id organizationId) {
        final List<GFRS_Organization__c> organizationsList = gFRS_DAO.getOrganizationById(organizationId);
        return organizationsList.isEmpty() ? null : organizationsList[0];
    }
    
    public GFRS_Funding_Request__c fundingRequest { get; set; }
    
    public Boolean checkProgramAvailability(GFRS_Funding_Request__c fundingRequest) {
        return fundingRequest == null ? false : [
            SELECT Id FROM GFRS_Program__c WHERE Funding_Request__c = :fundingRequest.Id
            AND Start_Date__c != null LIMIT 1
        ].size() > 0;
    }
    
    public Boolean checkProgramDesignAvailability(GFRS_Funding_Request__c fundingRequest) {
        return fundingRequest == null ? false : [
            SELECT Id FROM gFRS_Program_Design_and_Implementation__c
            WHERE gFRS_Funding_Request__c = :fundingRequest.Id LIMIT 1
        ].size() > 0;
    }
    
    public Boolean checkThirdPartyAvailability(GFRS_Funding_Request__c fundingRequest) {
        return fundingRequest == null ? false : [
            SELECT Id FROM gFRS_Third_Party__c WHERE Funding_Request__c = :fundingRequest.Id
            AND Company_Name__c != null LIMIT 1
        ].size() > 0;
    }
    
    public Boolean chechIfThirdPartyVisible(GFRS_Funding_Request__c fundingRequest) {
        return fundingRequest == null ? false : [
            SELECT Id FROM GFRS_Funding_Request__c WHERE Id =: fundingRequest.Id AND (
                Record_Type_Name__c = :gFRS_Util.TYPE_IMED_NAME OR Record_Type_Name__c = :gFRS_Util.TYPE_HC_CHAR_NAME
            ) AND Will_You_be_Working_With_a_3rd_Party__c = :gFRS_Util.YES LIMIT 1
        ].size() > 0;
    }
    
    public Boolean chechIfPaymentMethodVisible(GFRS_Funding_Request__c fundingRequest) {
        return fundingRequest == null ? false : [
            SELECT Id FROM GFRS_Funding_Request__c WHERE Id =: fundingRequest.Id AND Foundation_Classified__c = 'FALSE' LIMIT 1
        ].size() > 0;
    }
    
    public Boolean checkIfProgramDesignVisible(GFRS_Funding_Request__c fundingRequest) {
        return fundingRequest != null && fundingRequest.Record_Type_name__c == gFRS_Util.TYPE_IMED_NAME;
    }
    
    public String currentSection {
        get {
            return p_currentSection;
        }
        set {
            if (value != '5' && value != '6' && value != '7' && value != '8') {
                clearStyles();
            }
            p_currentSection = value;
            if (value == '1') {
                nav1Style = STYLE_OVER;
                nav2Style = nav3Style = nav4Style = STYLE_CLEAR;
            } else if (value == '2') {
                nav2Style = STYLE_OVER;
                nav1Style = STYLE_DONE;
                nav3Style = nav4Style = STYLE_CLEAR;
            } else if (value == '3') {
                nav3Style = STYLE_OVER;
                nav1Style = nav2Style = STYLE_DONE;
                nav4Style = STYLE_CLEAR;
            } else if (value == '4') {
                nav4Style = STYLE_OVER;
                nav1Style = nav2Style = nav3Style = STYLE_DONE;
            }
            nav1Style = STYLE_OVER;
            nav5Style = STYLE_CLEAR;
            nav6Style = STYLE_CLEAR;
            nav7Style = STYLE_CLEAR;
            nav8Style = STYLE_CLEAR;
        }
    }
    
    /**
    * @author GFRS Dev Team
    * @date 20/08/2013
    * @description clearStyles method - clears styles
    */
    private void clearStyles() {
        nav1Style = nav2Style = nav3Style = nav4Style = STYLE_CLEAR;
    }
    
    /**
    * @author GFRS Dev Team
    * @date 20/08/2013
    * @description getMenuOptions method - prepares options for left side menu - SFDC-1778
    */
    public List<MenuWrapper> getMenuOptions() {
        if (fundingRequest != null && fundingRequest.Id != null) {
            List<GFRS_Funding_Request__c> requestsList = gFRS_DAO.getFundingRequestById(fundingRequest.Id);
            if (requestsList != null && requestsList.size()>0) {
                fundingRequest = requestsList.get(0);
            }
            //Organization
            if (fundingRequest.Organization__c != null) {
                isOrgSpecified = (fundingRequest.Organization__c != null) ? true : false;
                orgLink = gFRS_Util.initializeLink(PATH_ORGANIZATION, fundingRequest,
                    'org=' + fundingRequest.Organization__c
                );
                orgStyleClass = resultURL.toLowerCase().contains(PATH_ORGANIZATION.toLowerCase()) ? 'active' : '';
            }
            //Application
            if (fundingRequest.Location__c != null && fundingRequest.Organization__c != null) {
                isApplicationFilled = (fundingRequest.Requested_Amount__c != null) ? true : false;
                applicationLink = gFRS_Util.initializeLink(PATH_APPLICATION, fundingRequest,
                    'loc=' + fundingRequest.Location__c + 'org=' + fundingRequest.Organization__c
                );
                applicationStyleClass = resultURL.toLowerCase().contains(PATH_APPLICATION.toLowerCase()) ? 'active' : '';
            }
            //Third Party
            isThirdPartySpecified = checkThirdPartyAvailability(fundingRequest);
            thirdPartyLink = gFRS_Util.initializeLink(PATH_THIRDPARTY, fundingRequest, '');
            thirdPartyVisible = chechIfThirdPartyVisible(fundingRequest);
            paymentMethodVisible = chechIfPaymentMethodVisible(fundingRequest);
            thirdPartyStyleClass = resultURL.toLowerCase().contains(PATH_THIRDPARTY.toLowerCase()) ? 'active' : '';
            //Program Design and Implementation - only for IMED
            isProgramDesignSpecified = checkProgramDesignAvailability(fundingRequest);
            programDesignLink = gFRS_Util.initializeLink(PATH_PROGRAMDESIGN, fundingRequest, '');
            programDesignVisible = checkIfProgramDesignVisible(fundingRequest);
            programDesignStyleClass = resultURL.toLowerCase().contains(PATH_PROGRAMDESIGN.toLowerCase()) ? 'active' : '';
            //Program
            isProgramSpecified = checkProgramAvailability(fundingRequest);
            programLink = gFRS_Util.initializeLink(PATH_PROGRAM, fundingRequest, '');
            programStyleClass = resultURL.toLowerCase().contains(PATH_PROGRAM.toLowerCase()) &&
                !resultURL.toLowerCase().contains(PATH_PROGRAMDESIGN.toLowerCase()) ? 'active' : '';
            //Budget
            isBudgetSpecified = fundingRequest.Total_Program_Budget__c != null && isProgramSpecified;
            budgetLink = gFRS_Util.initializeLink(PATH_BUDGET, fundingRequest, '');
            budgetVisible = !gFRS_Util.isInternalRequest(fundingRequest.Record_Type_name__c);
            budgetStyleClass = resultURL.toLowerCase().contains(PATH_BUDGET.toLowerCase()) ? 'active' : '';
            //File Attachments
            fileAttachmentsLink = gFRS_Util.initializeLink(PATH_FILE_ATTACHMENTS, fundingRequest, '');
            if (fundingRequest.Record_Type_Name__c == gFRS_Util.TYPE_PHILANTHROPIC_NAME) {
                isAttachmentSpecified = isBudgetSpecified;
            } else if (fundingRequest.Record_Type_Name__c == gFRS_Util.TYPE_FELLOWSHIPS_NAME) {
                isAttachmentSpecified = fundingRequest.Fellowship_Project_Description__c != null;
            } else if (fundingRequest.Record_Type_Name__c == gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME) {
                isAttachmentSpecified = fundingRequest.Letter_of_Request__c != null;
            } else if (fundingRequest.Record_Type_Name__c == gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME ||
                gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME == fundingRequest.Record_Type_Name__c
            ) {
                isAttachmentSpecified = fundingRequest.Letter_of_Request__c != null;
            } else if (fundingRequest.Record_Type_Name__c == gFRS_Util.TYPE_IMED_NAME) {
                isAttachmentSpecified = fundingRequest.Meeting_Agenda__c != null;
            } else if (fundingRequest.Record_Type_Name__c == gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME) {
                isAttachmentSpecified = fundingRequest.Fellowship_Project_Description__c != null;
            } else if (fundingRequest.Record_Type_Name__c == gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME) {
                isAttachmentSpecified = fundingRequest.Letter_of_Request__c != null;
            }
            attachmentsVisible = (fundingRequest.Record_Type_Name__c == gFRS_Util.TYPE_HC_CHAR_NAME) ? false : true;
            attachmentsStyleClass = resultURL.toLowerCase().contains(PATH_FILE_ATTACHMENTS.toLowerCase()) ? 'active' : '';
            //Payment Method
            isPaymentMethodSpecified = (fundingRequest.ACH_Received__c != null) ? true : false;
            paymentMethodLink = PATH_PAYMENT_METHOD + '?id=' + fundingRequest.Location__c + '&fundingreq=' + fundingRequest.id;
            paymentMethodStyleClass = resultURL.toLowerCase().contains(PATH_PAYMENT_METHOD.toLowerCase()) ? 'active' : '';          
            //Confirmation
            isConfirmed = fundingRequest.Authorized_Signer__c != null || fundingRequest.Signing_Authority_Email__c != null;
            confirmationLink = gFRS_Util.initializeLink(PATH_CONFIRMATION, fundingRequest, '');
            confirmationStyleClass = resultURL.toLowerCase().contains(PATH_CONFIRMATION.toLowerCase()) ? 'active' : '';
        }
        List<MenuWrapper> menuOptions = new List<MenuWrapper>{
            new MenuWrapper(MENU_ORGANIZATION, orgLink, isOrgSpecified, true, orgStyleClass),
            new MenuWrapper(MENU_APPLICATION, applicationLink, isApplicationFilled, true, applicationStyleClass)
        };
        if (thirdPartyVisible != null && thirdPartyVisible) {
            menuOptions.add(new MenuWrapper(MENU_THIRDPARTY, thirdPartyLink, isThirdPartySpecified, thirdPartyVisible, thirdPartyStyleClass));
        }
        if (programDesignVisible != null && programDesignVisible) {
            menuOptions.add(new MenuWrapper(MENU_PROGRAMDESIGN, programDesignLink, isProgramDesignSpecified, programDesignVisible, programDesignStyleClass));
        }
        menuOptions.add(new MenuWrapper(MENU_PROGRAM, programLink, isProgramSpecified, true, programStyleClass));
        if (budgetVisible != null && budgetVisible) {
            menuOptions.add(new MenuWrapper(MENU_BUDGET, budgetLink, isBudgetSpecified, budgetVisible, budgetStyleClass));
        }
        //Attachments
        if (attachmentsVisible != null && attachmentsVisible) {
            menuOptions.add(new MenuWrapper(MENU_FILE_ATTACHMENTS, fileAttachmentsLink, isAttachmentSpecified, attachmentsVisible, attachmentsStyleClass));
        }
        //Payment Method        
        if (budgetVisible != null && budgetVisible && paymentMethodVisible) {
            menuOptions.add(new MenuWrapper(MENU_PAYMENT_METHOD, paymentMethodLink, isPaymentMethodSpecified, budgetVisible, paymentMethodStyleClass));
        }       
        //Confirmation
        menuOptions.add(new MenuWrapper(MENU_CONFIRMATION, confirmationLink, isConfirmed, true, confirmationStyleClass));
        return menuOptions;
    }
    
    /**
    * @author GFRS Dev Team
    * @date 20/08/2013
    * @description MenuWrapper class - wrapper class for menu options
    */
    public class MenuWrapper{
        public MenuWrapper(String label, String link, Boolean optionAsLink, Boolean optionVisible, String styleClass) {
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