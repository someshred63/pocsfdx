/***********************************************************************************************************************
Purpose: ChannelOps_SpoilageRequest_Controller class is used to create 
         spoilage request from site.
========================================================================================================================
History                                                            
-------                                                            
VERSION  AUTHOR        DATE            DETAIL                       
1.0                                 INITIAL DEVELOPMENT
1.1     Vijay       08/02/2019      Commented the synchOtherIndicationFields() method. Refer US# COEXP-208
                                    Commented the return_method_detail__c null check in productInfoCompleted 
                                    method  Refer US# COEXP-208
                                    added displayReasonDetail boolan field and populated value
                                    in updateReasonCode method to toggle the reason detail section Refer US# COEXP-208                                  
1.2     Vijay       08/09/2019      If Genentech Patient Foundation Program(GATCF_Product__c) is checked,
                                    no need to chect Auto denial and not applicable
1.3     Vijay       02/14/2020      Updated logic to capture initial submission date and process
                                    auto denial based on that date and Date of spoilage -M&E items
1.4     Vijay       02/14/2020      commmented the updateURL method -M&E items
1.5     Vijay       03/06/2020      add pharmacy Reference field validation message 
1.6     Raheem      04/17/2020      implemented CHG0288837(Added Nutropin section for Self Admin)
1.7     Vijay       04/17/2020      updated business logic for nutropin section
1.7     Vijay       04/17/2020      added getNumOfDaysForAutoDenial method to get number of days for 
                                    spoilage replacement. 
1.8     Vijay &
        Raheem      21/12/2020       As per Guest user security policy in salesforce added ignoreEditPermissionForRendering=true in visualforce page,
                                     created Input text fields varibles in apex side.
                                     Added logic for recordId encryption and decryption.
                                     Updated class support guest user security policies
**********************************************************************************************************************/
public class ChannelOps_SpoilageRequest_Controller {
    public Boolean monday {set;get;}
    public Boolean tuesday {set;get;}
    public Boolean wednesday {set;get;}
    public Boolean thursday {set;get;}
    public Boolean friday {set;get;}
    public Boolean Saturday {set;get;}
    public Boolean Sunday {set;get;}
    public Boolean none {set;get;}
    public String DayValue{get;set;}
    private void updateNoDeliveryDays(){
        String days='';
        if(monday) days +='Monday;';
        if(tuesday) days +='Tuesday;';
        if(wednesday) days +='Wednesday;';
        if(thursday) days +='Thursday;';
        if(friday) days +='Friday;';
        if(Saturday) days +='Saturday;';
        if(Sunday) days +='Sunday;';
        if(none) days ='Able to accept delivery of product every day;';
        
        if(days!=null && days.length()>0) {
            Integer i=days.lastIndexOf(';');
            days = days.substring(0,i);
        }
        DayValue=days;
        request.Do_Not_Deliver_On__c=days;
    }
    // get and set for input text fields 
    public string pharmacyReferenceNum{get; set;}
    public string reason_Detail_2{get; set;}
    public string reason_Detail{get; set;}
    public string hcpName{get; set;}
    public string titleString{get; set;}
    public string otherTitle{get; set;}
    
    public string    otherIndicationDisplayAttribut {set; get;}
    public string    otherTitleDisplayAttribut {set; get;}
    public string    returnDetailDisplayAttribut {set; get;}
    public string pdfurl {set; get;}
    private ID PDFFormDocumentID;
    private List<ChannelOps_Spoilage_Request_Product__c> requestProducts;
    private List<ChannelOps_Spoilage_Product_Master__c> productMaster;
    private List<ChannelOps_Spoilage_Reason_Code_Master__c> reasonCodeMaster;
    private ChannelOps_Spoilage_Product_Master__c selectedProduct;
    private List<ChannelOps_Spoilage_Keywords__c> keywords;
    
    public ChannelOps_Spoilage_Request__c request {set; get;}
    public String selectedProductId {set; get;}
    public String selectedReasonId {set; get;}
    public Boolean reasonDetailRequired {set; get;}
    public String reasonDetailAreaLabel {set; get;}
    public Boolean noUseOfProduct {set; get;}
    Public Boolean noClaimOfProduct {set; get;}
    Public Boolean PatientOrPayer {set; get;}
    Public Boolean notBilledPatient {set; get;}
    Public Boolean notBilledPayer {set; get;}
    Public Boolean productDisposed {set; get;}
    Public Boolean beyondControl {set; get;}
    Public Boolean displayFormType{set; get;}
  
    public ChannelOps_Spoilage_Request_Product__c currRequestProduct {set; get;}
    public Boolean showAddProductForm {set; get;}
    public String addProductButtonLabel {set; get;}
    public String addProductCancelLinkLabel {set; get;}
    public String formTitle {set;}
    public String GATCFstr ;
    //public String catastrophicEventStr;
    public String depleteInventoryStr;
    public String errorMsg {set; get;}
    public String requestId {set; get;}
    
    public String SectionName {set; get;}
    
    public List<SelectOption> SafetySelection{
        get{
            List<SelectOption> optionsToReturn = new List<SelectOption>();       
            optionsToReturn.add(new SelectOption('none','Please make selection'));
            optionsToReturn.add(new SelectOption('I can safely discard product','I can safely discard product'));
            optionsToReturn.add(new SelectOption('I cannot safely discard product','I cannot safely discard product'));  
        return optionsToReturn;
           }
        set;}
    public String SelectedSafetyValue;
    public void setSelectedSafetyValue(String str){
    
        if(str==null || (str.trim()=='none')) request.Return_Method__c=null;
        else {
            SelectedSafetyValue=str;
            assignRequestMethodValue();
        } 
    }
    public String getSelectedSafetyValue(){
        return SelectedSafetyValue;
    }
    public void assignRequestMethodValue(){
        if(request.Spoilage_Type__c != 'Lytics Spoilage' && request.Spoilage_Type__c !='Self-Administered Product Spoilage'){            
            request.Return_Method__c=SelectedSafetyValue;
        }
        
    }
    
    public String licenseNumLabel {set; get;}
    public String DEANumLabel {set; get;}
    public String facilityNameLabel {set; get;}
    public String physicianFNameLabel {set; get;}
    public String physicianLNameLabel {set; get;}
    public String requestRefNum {set; get;}
    public Integer currentProductVolumeLimitation {set; get;}
    
    
    public String generalError {set; get;}
    public String CSSubTitle {set; get;}
    public String helpTextGATCF {set; get;}
    public String helpTextDEA {set; get;}
    public String helpTextNoDelivery {set; get;}
    public String helpTextSerialNum {set; get;}
    public Boolean showHomePopUp {set; get;}
    
    private String LyticsFormTitle, ColdStorageFailureFormTitle, SelfAdministeredProductFormTitle, UniversalFormTitle,generalSpoilageReasonDetailLabel;
    private Integer numOfDaysForAutoDenial;
    
    //The account used for seding email with template
    private String accountName;
    private Boolean bcc;
    private List<String> GATCF_Address;
    
    Static final String emailTemplateNew = 'ChannelOps_Spoilage_confirmation_email';// 'ChannelOps Spoilage confirmation email';
    Static final String emailTemplateReject1 = 'ChannelOps_Spoilage_confirmation_email_AutoDenied_for_greater_than_30_days'; // 'ChannelOps Spoilage confirmation email-AutoDenied for greater than 30 days';
    Static final String emailTemplateReject2 = 'ChannelOps_Spoilage_confirmation_email_AutoDenied_for_offlabel_usage'; // 'ChannelOps Spoilage confirmation email-AutoDenied for offlabel usage';
    Static final String emailTemplateReject3='ChannelOps_Spoilage_confirmation_email_AutoDenied_for_both_reasons'; // 'ChannelOps Spoilage confirmation email-AutoDenied for both reasons';
    Static final String emailTemplateFolder ='ChannelOps Spoilage Email Templates';
    Static final String emailTemplateGATCF = 'ChannelOps_Spoilage_GATCF_confirmation_email'; // 'ChannelOps Spoilage GATCF - confirmation email';
    Static final String emailTemplateToGATCF = 'ChannelOps_Spoilage_To_GATCF_Program'; // 'ChannelOps Forward Spoilage To GATCF Team';
    
    //added below to toggle the reason detail section.Refer US# COEXP-208
    public Boolean displayReasonDetail {set; get;}
    
    //Added by Vijay
    public Boolean enableActionSection {get;set;}
    public Boolean enableSearchSection {get;set;}
    public Boolean enableSpoilageTypeSection {get;set;}
    public Boolean enableMessageSection {get;set;}
    public String userAction {get;set;}
    public String emailAddress {get;set;}
    public String requestNumber {get;set;}
    public String licenseNumber {get;set;}
    public Boolean isSaveDraft {get;set;}
    private List<ChannelOps_Spoilage_Request_Product__c> deleteRemovedProducts;
    Static final String draftRequestEmailtemplate = 'ChannelOps_Spoilage_Draft_Confirmation_Email'; //'ChannelOps Spoilage Draft Confirmation Email';
    Static final String correctionRequestEmailTemplate =  'ChannelOps_Spoilage_Correction_Confirmation_Email'; //'ChannelOps Spoilage Correction Confirmation Email';
    public Boolean displayDraftBtn {get;set;}
    private Integer selfAdminProductVolumeLimit;
    
    public String pharmacyRefVMsg {get;set;}

    //boolean field to toggle Nutropin section
    public Boolean showNutropinSection { get;set;}

     //boolean field to toggle Evrysdi section
     public Boolean showEvrysdiSection { get;set;}

     //String to show the brand section title
     public String brandName {get;set;}
    
    //added by vijay 
    public Integer getNumOfDaysForAutoDenial(){
        return numOfDaysForAutoDenial;
    }

    public ChannelOps_SpoilageRequest_Controller(){
  
        System.debug('----In ChannelOps_SpoilageRequest_Controller Constructor----');
       //load application properties
       ChannelOps_App_Property__c property=[select GCKey__c,GSKey__c,GSite__c,GATCF_Email_Address__c, BCC_CS_email_dlist__c, Account_Name_for_sending_email__c,GATCF_help__c,no_delivery_day_help__c,serial_help__c,DEA_help__c,Spoilage_Request_Time_Window__c, ColdStorageFailureFormTitle__c, General_Application_Error_MEssage__c, LyticsFormTitle__c, SelfAdministeredProductFormTitle__c, UniversalFormTitle__c,DefautlSpoilageReasonDetailFieldLabel__c,CS_subTitle__c,Self_Admin_Product_Volume_Limit__c from ChannelOps_App_Property__c where active__c=true and Application_Name__c='Spoilage From' limit 1];
       numOfDaysForAutoDenial=property.Spoilage_Request_Time_Window__c.intValue();
       LyticsFormTitle = property.LyticsFormTitle__c;
       ColdStorageFailureFormTitle=property.ColdStorageFailureFormTitle__c;
       SelfAdministeredProductFormTitle=property.SelfAdministeredProductFormTitle__c;
       UniversalFormTitle=property.UniversalFormTitle__c;
       generalError=property.General_Application_Error_MEssage__c;
       generalSpoilageReasonDetailLabel=property.DefautlSpoilageReasonDetailFieldLabel__c;
       CSSubTitle =property.CS_subTitle__c;
       helpTextGATCF =property.GATCF_help__c;
       helpTextNoDelivery = property.no_delivery_day_help__c;
       helpTextSerialNum =property.serial_help__c;
       helpTextDEA = property.DEA_help__c;
       accountName=property.Account_Name_for_sending_email__c;
       if(property.GATCF_Email_Address__c!=null && property.GATCF_Email_Address__c.trim().length()>0) {
           GATCF_Address=new List<String>();
           GATCF_Address.add(property.GATCF_Email_Address__c);
       }
       bcc=property.BCC_CS_email_dlist__c;
       privateKey =property.GSKey__c;
       baseUrl =property.GSite__c;
       publicKey =property.GCKey__c;
       //set the self admin product volume limit  
       selfAdminProductVolumeLimit = (property.Self_Admin_Product_Volume_Limit__c != null) ? Integer.valueOf(property.Self_Admin_Product_Volume_Limit__c) : 0;
       //initialize spoilage form information 
       spoilageRequestInit();          
       
       /*//for test
       ChannelOps_Spoilage_Request__c oldRequest=[select Facility_DEA__c, Physician_First_Name__c, Physician_Last_Name__c, Pharmacy_Reference_Num__c, Do_Not_Deliver_On__c,Title_credential__c,Signature_Signed__c,Spoilage_Type__c ,Facility_Name__c, License_Num__c,Street_Name__c,State__c,city__c,Zip__c,Contact_First_Name__c,Contact_Last_Name__c,Contact_Email__c,Contact_Phone__c,Date_of_Spoilage__c from ChannelOps_Spoilage_Request__c where id='a5S1k0000004RoO'];
       // selfadmin: a5S1k0000004RoY; cold storage: a5S1k0000004RoT; Lyctis: a5S1k0000000C8L; universal: a5S1k0000004RoO
       request= oldRequest.clone(false, true,false, false);
       request.Submission_Date__c=System.today();
       request.Spoilage_Type__c ='Universal Spoilage';//'Cold Storage Failure';
       productMaster = [select Reminding_Allowed_QTY__c, id, name, Active__c, NDC__c, Brand__c,Volume_limitation__c from ChannelOps_Spoilage_Product_Master__c where Active__c=true and Spoilage_Type__c=:request.Spoilage_Type__c order by name];
       reasonCodeMaster=[select spoilage_type__c, display_order__c,Brand__c, Spoilage_Reason__c, SAP_Reason_Code__c, Active__c, Explanation_Required__c, Reason_Detail_Question_Label__c,Display_Explanation__c from ChannelOps_Spoilage_Reason_Code_Master__c where Active__c=true and Spoilage_Type__c=:request.Spoilage_Type__c order by display_order__c];
        
       *///end of for test
        
        this.verified = false;
        //checkCurrentValue=false;
       
       //end of reCaptcha
    }
    
    //initialize spoilage request form information
    private void spoilageRequestInit(){
        System.debug('----In spoilageRequestInit method----');
        request = new ChannelOps_Spoilage_Request__c();
        request.Submission_Date__c = (request.Submission_Date__c != null) ? request.Submission_Date__c: System.today();   
               
        requestProducts =new List<ChannelOps_Spoilage_Request_Product__c>();
        
        productMaster = new List<ChannelOps_Spoilage_Product_Master__c>();
        
        reasonCodeMaster = new List<ChannelOps_Spoilage_Reason_Code_Master__c>();
        
        currRequestProduct =new ChannelOps_Spoilage_Request_Product__c ();
        showAddProductForm = false;
        selectedProductId ='';
        selectedReasonId =''; 
        reasonDetailRequired = false;
        reasonDetailAreaLabel =generalSpoilageReasonDetailLabel;
        errorMsg ='';
            
        //initialize the signature box
        noUseOfProduct =false;
        noClaimOfProduct= false;
                      
        //load keywords in memery 
        keywords=[select name,keyword_type__c from ChannelOps_Spoilage_Keywords__c]; 
        
        displayReasonDetail = false;
        
        enableActionSection = true;
        enableSearchSection  = false;
        enableSpoilageTypeSection = false;
        enableMessageSection=false;
        userAction = '';
        isSaveDraft = false;
        deleteRemovedProducts = new List<ChannelOps_Spoilage_Request_Product__c>();
        displayDraftBtn = false;
        pharmacyRefVMsg = '';
        checkSpecificBrandProduct();
    }
    
    public PageReference toGeneralInfo2() {
        System.debug('----In toGeneralInfo2 method----'+request.Spoilage_Type__c);
        PageReference nextPage=Page.ChannelOps_SpoilageRequest_GeneralInfo;
            request.Spoilage_Type__c='Lytics Spoilage';
            licenseNumLabel = 'Facility State License #:';
            DEANumLabel = 'Facility DEA #:';
            facilityNameLabel ='Facility Name:';
            request.License_Type__c='Facility License Number';
        return nextPage;
    }
    
    public PageReference toGeneralInfo() {
        System.debug('----In toGeneralInfo method----'+request.Spoilage_Type__c);
        if(request==null || request.Spoilage_Type__c == null || request.Spoilage_Type__c.trim().length()<=0) {
            errorMsg = 'Error: You must select a Request Spoilage Replacement type';
            return null;
        }
        errorMsg ='';
        
        PageReference nextPage;
        if(request.Spoilage_Type__c=='Lytics Spoilage') {
            nextPage=Page.ChannelOps_SpoilageRequest_GeneralInfo;
            request.Spoilage_Type__c='Lytics Spoilage';
            licenseNumLabel = 'Facility State License #:';
            DEANumLabel = 'Facility DEA #:';
            facilityNameLabel ='Facility Name:';
            request.License_Type__c='Facility License Number';
            SectionName ='Facility Information';
            
            request.Do_Not_Deliver_On__c='';
            request.Physician_First_Name__c='';
            request.Physician_Last_Name__c='';
            
            
        }
       
        else if(request.Spoilage_Type__c=='Cold Storage Failure') {
            nextPage=Page.ChannelOps_SpoilageRequest_GeneralInfo;
            request.Spoilage_Type__c='Cold Storage Failure';
            licenseNumLabel = 'Physician License #:';
            DEANumLabel = 'Physician DEA #:';
            facilityNameLabel ='Facility Name:';
            request.License_Type__c='Physician License Number';
            physicianFNameLabel ='Physician First Name:';
            physicianLNameLabel ='Physician Last Name:';
            SectionName ='Physician Information';
            pharmacyReferenceNum='';
          //  request.Pharmacy_Reference_Num__c='';
            //request.Return_Method__c='I can safely discard product';
        }
        else if(request.Spoilage_Type__c=='Self-Administered Product Spoilage') {
           // nextPage=new PageReference(pdfurl);
            nextPage=Page.ChannelOps_SpoilageRequest_GeneralInfo;
            request.Spoilage_Type__c='Self-Administered Product Spoilage';
            licenseNumLabel = 'Pharmacy License #:';
            DEANumLabel = 'Pharmacy DEA #:';
            facilityNameLabel ='Pharmacy Name:';
            request.License_Type__c='Pharmacy License Number';
            physicianFNameLabel ='Prescribing Physician First Name:';
            physicianLNameLabel ='Prescribing Physician Last Name:';
            SectionName ='Pharmacy Information';
            
        
        }
        else {
            nextPage=Page.ChannelOps_SpoilageRequest_GeneralInfo;
            request.Spoilage_Type__c='Universal Spoilage';
            licenseNumLabel = 'Physician License #:';
            DEANumLabel = 'Physician DEA #:';
            facilityNameLabel ='Facility Name:';
            request.License_Type__c='Physician License Number';
            physicianFNameLabel ='Physician First Name:';
            physicianLNameLabel ='Physician Last Name:';
            SectionName ='Physician Information';
            pharmacyReferenceNum='';
          //  request.Pharmacy_Reference_Num__c='';
            //request.Return_Method__c='I can safely discard product';
        }
        
        productMaster = [select Reminding_Allowed_QTY__c, id, name, Active__c, NDC__c, Brand__c,Volume_limitation__c from ChannelOps_Spoilage_Product_Master__c where Active__c=true and Spoilage_Type__c=:request.Spoilage_Type__c order by name];
        reasonCodeMaster=[select spoilage_type__c, display_order__c,Brand__c, Spoilage_Reason__c, SAP_Reason_Code__c, Active__c, Explanation_Required__c, Reason_Detail_Question_Label__c, Display_Explanation__c from ChannelOps_Spoilage_Reason_Code_Master__c where Active__c=true and Spoilage_Type__c=:request.Spoilage_Type__c order by display_order__c];
        nextPage.setRedirect(false);
        return nextPage;
    }

    /*M&E Item: Remove the dowload PDF link on the new spoilage request page  
    public PageReference updatePDFurl(){
        errorMsg ='';
        if(request==null ||request.Spoilage_Type__c == null || request.Spoilage_Type__c.trim().length()<=0) {
            errorMsg = 'Error: You must select a Request Spoilage Replacement type';
            return null;
        }
        
        String siteDomain, sitePrefix;
        
        if(Site.getDomain()==null || Site.getDomain().trim().length()<=0) siteDomain='dev-gene.cs78.force.com';
        else siteDomain=Site.getDomain();
        
        if(Site.getPathPrefix()==null || Site.getPathPrefix().trim().length()<=0) sitePrefix='/Spoilage';
        else sitePrefix=Site.getPathPrefix();
        
        Document sForm;
        //pdfurl='https://dev-gene.cs78.force.com/Spoilage/servlet/servlet.FileDownload?file=';
        pdfurl='https://'+siteDomain+sitePrefix+'/servlet/servlet.FileDownload?file=';
        
         if(request.Spoilage_Type__c=='Lytics Spoilage') {
            sForm = [Select Id,Name from Document where Name ='ChannelOps_Spoilage_Lytics' limit 1];
        }
        else if(request.Spoilage_Type__c=='Cold Storage Failure') {
            sForm = [Select Id,Name from Document where Name ='ChannelOps_Spoilage_ColdStorageFailure' limit 1];
        }
        else if(request.Spoilage_Type__c=='Self-Administered Product Spoilage') {
            sForm = [Select Id,Name from Document where Name ='ChannelOps_Spoilage_SelfAdministered' limit 1];
        }
        else {
            sForm = [Select Id,Name from Document where Name ='ChannelOps_Spoilage_Universal' limit 1];
        }
        if(sForm !=null) pdfurl+=sForm.id;
        return null;
    
    }*/   
   
    public PageReference trackVisitInfo(){
         PageReference pageRef = new PageReference(System.Label.SpoilageCreateNewURL);             
         return pageRef;
       //  logRequesterInfo();       
      //  return null;
    }

    private void logRequesterInfo(){
        if(request==null) {
       // errorMsg='No request';
        return;
        }
        
        if(request.Starting_Time__c==null) request.Starting_Time__c=System.now();
        request.Ending_Time__c=System.now();
        
        string requestIP = '';   
        // True-Client-IP has the value when the request is coming via the caching integration.
        requestIP = ApexPages.currentPage().getHeaders().get('True-Client-IP');
        
        // X-Salesforce-SIP has the value when no caching integration or via secure URL.
        if (requestIP == '' || requestIP == null) {
         requestIP = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        } // get IP address when no caching (sandbox, dev, secure urls)

        if (requestIP == '' || requestIP == null) {
         requestIP = ApexPages.currentPage().getHeaders().get('X-Forwarded-For');
        } // get IP address from standard header if proxy in use
        
        request.request_IP__c=requestIP ;
        
        String pageURL=ApexPages.currentPage().getUrl();
        if(pageURL!=null) {
            if(request.Page_Visited__c==null) request.Page_Visited__c='';
            String[] strings=pageURL.split('/');
            if(strings!=null && strings.size()>0) {
                String[] pnames=strings[strings.size()-1].split('\\?');
                request.Page_Visited__c +=requestIP+' - '+pnames[0]+' | ';
                //request.Page_Visited__c+=pnames[0];
            }
            
            
            
        }
        
       // errorMsg='IP- '+request.request_IP__c+ ' | started at- '+request.Starting_Time__c+' | ended at- '+request.ending_Time__c+' | page vistied- '+request.Page_Visited__c;
    }

    
    
    public PageReference closeHomePopup(){
        showHomePopUp = false;
        return null;
    }

    public PageReference startPopUp(){
        showHomePopUp = true;
        return null;
    }


    
    //make sure retuen method detail display attribut matches return method selection
    private void synchReturnMethodFields(){
        if(request!=null && request.Return_Method__c!=null && request.Return_Method__c.containsIgnoreCase('Other')){
            returnDetailDisplayAttribut='block';
        }else {
            returnDetailDisplayAttribut='none';
            request.Return_Method_Detail__c='';
        }
    }
    
    
    //make sure other indication detail display attribut matches indication selection
    //commented below synchOtherIndicationFields method. Refer US# COEXP-208
    /*private void synchOtherIndicationFields(){
        if(currRequestProduct!=null && currRequestProduct.Indication__c!=null && currRequestProduct.Indication__c.containsIgnoreCase('Other')){
            otherIndicationDisplayAttribut ='block';
        }else {
            otherIndicationDisplayAttribut ='none';
            currRequestProduct.Other_Indication__c='';
        }
    }*/

    //make sure other title display attribut matches title selection
    private void synchOtherTitleFields(){
        if(request!=null && request.Title_credential__c!=null && request.Title_credential__c.containsIgnoreCase('Other')){
            otherTitleDisplayAttribut ='block';
        }else {
            otherTitleDisplayAttribut ='none';
               request.Other_Title__c=''; 
          //  spoilageReqObj.otherTitle='';
            
        }
    }

    
    public PageReference initReviewPage(){
        
        synchOtherTitleFields();
        logRequesterInfo();
        return null;
    }

    public PageReference initProductInforPage(){

        synchReturnMethodFields();
        //synchOtherIndicationFields();
        logRequesterInfo();
        
        if(String.isNotBlank(selectedReasonId)){
            updateReasonCode();
        }        
        return null;
    }

   
    public void setDepleteInventoryStr (String str){
        if(str!=null && str=='Yes') {
            request.Depleted_Inventory__c=true;
            depleteInventoryStr= 'Yes';
        }
        else {
            request.Depleted_Inventory__c=false;
            depleteInventoryStr= 'No';
        }
    }
    
    
    public String getDepleteInventoryStr (){
        if(request.Depleted_Inventory__c==null || request.Depleted_Inventory__c==false) return 'No';
        else return 'Yes';
    }
    
    public void setGATCFstr (String str){
        if(str!=null && str=='Yes') {
            request.GATCF_Product__c=true;           
        }
        else {
            request.GATCF_Product__c=false;
        }
    }
    
    public String getGATCFstr (){
        if (request.GATCF_Product__c) GATCFstr ='Yes';
        else GATCFstr ='No';
        return GATCFstr;
    }
    
    public string getFormTitle(){
        if(request.Spoilage_Type__c=='Lytics Spoilage') return LyticsFormTitle;
        else if(request.Spoilage_Type__c=='Cold Storage Failure') return ColdStorageFailureFormTitle ;
        else if (request.Spoilage_Type__c=='Self-Administered Product Spoilage') return SelfAdministeredProductFormTitle;
        return UniversalFormTitle;
    }
    
    

    
    // invocted when user select a product from the product selection list
    public PageReference addNewProduct(){
        for(ChannelOps_Spoilage_Product_Master__c p:productMaster){
                       
            if(selectedProductId !=null && selectedProductId.length()>0 && p.id==selectedProductId ) {
                currRequestProduct =new ChannelOps_Spoilage_Request_Product__c ();
                currentProductVolumeLimitation =null;
                currRequestProduct.Product_Name__c=p.name;
                currRequestProduct.NDC__c=p.NDC__c;
                currRequestProduct.Product__c = p.id;                
                currRequestProduct.brand__c=p.Brand__c;                
                if(p.Reminding_Allowed_QTY__c!=null) currentProductVolumeLimitation =Integer.valueOf(p.Reminding_Allowed_QTY__c);
                showAddProductForm = true;
                addProductButtonLabel = 'Add Product';
                addProductCancelLinkLabel = 'Cancel';
              //  otherIndicationRequired =false;
                otherIndicationDisplayAttribut  ='none';
                currRequestProduct.Product__r = p; 
            }
        }         
        return null;
    }
    
    //index for the product on request product list to be edited
    private Integer editProductIndex;
    
    public PageReference cancelAddEditProduct(){   
        //Add the product back to requestProducts list when user cancel product edit action
        //if(addProductCancelLinkLabel == 'Cancel') {
            currRequestProduct =new ChannelOps_Spoilage_Request_Product__c ();
            editProductIndex=null;
       // }
        clearAddEditProductFormLabels();

        return null;
    }
    
    private void clearAddEditProductFormLabels(){
        showAddProductForm = false;
        addProductButtonLabel ='';
        addProductCancelLinkLabel ='';
        selectedProductId ='';
        currentProductVolumeLimitation =null;  
      //  otherIndicationRequired =false;
      //  otherIndicationDisplayAttribut  ='none';
        
    }
    
    // invocted when user click the add product button
    public PageReference addProduct(){    
                   
        if(currRequestProduct!=null && addProductButtonLabel =='Add Product') {
            ChannelOps_Spoilage_Request_Product__c rp= currRequestProduct.clone(false, true,false, false);
            requestProducts.add(rp);            
        }else if(currRequestProduct!=null && addProductButtonLabel =='Save Edit'){        
            requestProducts.set(editProductIndex,currRequestProduct); 
            currRequestProduct =new ChannelOps_Spoilage_Request_Product__c ();
            editProductIndex=null;           
        }
        synchReturnMethodFields();
        //synchOtherIndicationFields();
        clearAddEditProductFormLabels();
        checkSpecificBrandProduct();
        return null;        
    }
    
    
    public PageReference addProductAndClone(){    
                   
        if(currRequestProduct!=null && addProductButtonLabel =='Add Product') {
            ChannelOps_Spoilage_Request_Product__c rp= currRequestProduct.clone(false, true,false, false);
            requestProducts.add(rp);            
        }else if(currRequestProduct!=null && addProductButtonLabel =='Save Edit'){
            requestProducts.set(editProductIndex,currRequestProduct);
            ChannelOps_Spoilage_Request_Product__c rp= currRequestProduct.clone(false, true,false, false);
            currRequestProduct=rp;
        }
        synchReturnMethodFields();
        //synchOtherIndicationFields();
        addProductButtonLabel = 'Add Product';
        addProductCancelLinkLabel = 'Cancel';
        editProductIndex=null;
        currRequestProduct.Serial_Number__c='';
        Integer temp=currentProductVolumeLimitation;
        currentProductVolumeLimitation=null;
        if(temp!=null && temp>0) currentProductVolumeLimitation =temp-Integer.valueOf(currRequestProduct.Quantity__c);
        currRequestProduct.Quantity__c=null;
        checkSpecificBrandProduct();
        return null;        
    }
    /* Comment out by Jie
    public boolean ShowQuickEdit{get;set;}
    public boolean ShowSpoilageInfo{get;set;}
    public boolean ShowContactInfo{get;set;}
    public boolean ShowProdInfo{get;set;}
    public boolean showSpoilageInfoSec{get;set;}
     
     public void quickEdit(){
    ShowQuickEdit=true;
    }
    
    
     public void editContactInfo(){
      ShowContactInfo=true;
    }
     public void editSpoilageInfo(){
      ShowSpoilageInfo=true;
    }
      public void editProdInfo(){
    ShowProdInfo=true;
    }
     public void editSpoilageSecInfo(){
    showSpoilageInfoSec=true;
    }
 */   
    // invocted when user click the Edit link for any product in the product list
    public PageReference EditProduct(){
    
        String indexStr=ApexPages.currentPage().getParameters().get('index');
        if(indexStr!=null && indexStr.trim().length()>0) {
        
            //keep this index to be used in the addProduct method and addProductAndClone method
            editProductIndex=Integer.valueOf(indexStr);
            if(editProductIndex!=null && editProductIndex>=0) {
                //currRequestProduct=requestProducts.get(editProductIndex).clone(false, true,false, false);
                currRequestProduct=requestProducts.get(editProductIndex);
                showAddProductForm=true;
                addProductButtonLabel = 'Save Edit';
                addProductCancelLinkLabel = 'Cancel Edit';   
                currentProductVolumeLimitation =null;            
            }
            
            for(ChannelOps_Spoilage_Product_Master__c p:productMaster){
                if(currRequestProduct.Product__c == p.id) 
                    if(p.Reminding_Allowed_QTY__c!=null)  currentProductVolumeLimitation =Integer.valueOf(p.Reminding_Allowed_QTY__c+currRequestProduct.Quantity__c);
            }
            
            //synchOtherIndicationFields();
        }
        
        
        
     /*   if(productId!=null){
            for(ChannelOps_Spoilage_Request_Product__c rp: requestProducts){               
                if(rp.Product__c==productId) {                   
                    currRequestProduct=rp.clone(true, true,false, false);              
                    showAddProductForm=true;
                    addProductButtonLabel = 'Save Edit';
                    addProductCancelLinkLabel = 'Cancel Edit';
                }
              
            }
            
            for(ChannelOps_Spoilage_Product_Master__c p:productMaster){
                if(currRequestProduct.Product__c == p.id) 
                    if(p.Reminding_Allowed_QTY__c!=null)  currentProductVolumeLimitation =Integer.valueOf(p.Reminding_Allowed_QTY__c+currRequestProduct.Quantity__c);
            }
            
            synchOtherIndicationFields();
            
           
        }*/
        return null;
    }
    
    // invocted when user click the remove product link for any product in the product list
    public PageReference removeProduct() {
        String indexStr=ApexPages.currentPage().getParameters().get('index');
        if(indexStr!=null && indexStr.trim().length()>0) {
            Integer listIndex=Integer.valueOf(indexStr);
            if(listIndex!=null && listIndex>=0){
                ChannelOps_Spoilage_Request_Product__c spoilageReqProduct = requestProducts.get(listIndex);
                if(spoilageReqProduct != null && spoilageReqProduct.Id != null){
                    deleteRemovedProducts.add(spoilageReqProduct);  
                }                
                requestProducts.remove(listIndex);               
            }
        }
        /*
        if(productId!=null){
           // List<ChannelOps_Spoilage_Request_Product__c> requestProductsCopy=requestProducts.clone();
            Integer listIndex=-1;
            for(ChannelOps_Spoilage_Request_Product__c rp:requestProducts){
                
                if(rp.Product__c==productId) {
                    listIndex=requestProducts.indexOf(rp);                    
                }
                
            }
            if(listIndex>-1) requestProducts.remove(listIndex);
           
        }*/
        synchReturnMethodFields();
        //synchOtherIndicationFields();   
        checkSpecificBrandProduct();
        
        return null;
    }
    
    
    public void setRequestProducts (List<ChannelOps_Spoilage_Request_Product__c> l){
        requestProducts=l;
    }
    
    public List<ChannelOps_Spoilage_Request_Product__c> getRequestProducts(){
        if(requestProducts ==null)    requestProducts =new List<ChannelOps_Spoilage_Request_Product__c>();     
        return requestProducts ;
    }
    
//Keep code after Q4 18 release
   /* private List<SelectOption> getProductSelectionsForLyctis(){
        List<SelectOption> optionsToReturn = new List<SelectOption>();
        optionsToReturn.add(new SelectOption('', 'Select Product'));
        if(productMaster!=null && productMaster.size()>0){
                for(ChannelOps_Spoilage_Product_Master__c p:productMaster){
                    Boolean addToList=true;
                    p.Reminding_Allowed_QTY__c=p.Volume_limitation__c;
                    if(requestProducts !=null && requestProducts.size()>0) {
                        for(ChannelOps_Spoilage_Request_Product__c rp:requestProducts ){
                                                
                            if(rp.brand__c==p.brand__c){
                                //when find TNKase or Activase 100mg in request product, then don't add to selection list
                                if(p.Volume_limitation__c==1) addToList=false;
                                //when find Activase 50mg in request product
                                else {
                                    //if product master is Activase 100mg, don't add it to selection list
                                    if(rp.Product__c!=p.id) addToList=false;
                                    //if product master is Activase 50mg, reduce allowed quantity by request product quantity, if remining allowed quantity is 0, than don't add 
                                    else {
                                        p.Reminding_Allowed_QTY__c =p.Reminding_Allowed_QTY__c-rp.Quantity__c;
                                        if (p.Reminding_Allowed_QTY__c<=0) addToList=false;
                                    }
                                }
                                    
                                
                            }
                        }
                    }
                    if(addToList) optionsToReturn.add(new SelectOption(p.id, p.name+' - NDC '+p.NDC__c));
                }
        }
        return optionsToReturn;
    }*/
    
    //Used for froms only allow one product per request - Lytics
    private List<SelectOption> getLimitedProductSelectionsForLytics(){
        List<SelectOption> optionsToReturn = new List<SelectOption>();
        optionsToReturn.add(new SelectOption('', 'Select Product'));
        if(productMaster!=null && productMaster.size()>0){
                for(ChannelOps_Spoilage_Product_Master__c p:productMaster){
                    Boolean addToList=true;
                    p.Reminding_Allowed_QTY__c= p.Volume_limitation__c;
                    if(requestProducts !=null && requestProducts.size()>0) {
                        for(ChannelOps_Spoilage_Request_Product__c rp:requestProducts ){
                            
                            //only allow one product to be reported in a Lytics request                   
                            if(rp.Product__c!=p.id) addToList=false;
                            else {
                                p.Reminding_Allowed_QTY__c =p.Reminding_Allowed_QTY__c-rp.Quantity__c;
                                if (p.Reminding_Allowed_QTY__c<=0) addToList=false;
                                    
                            }
                                    
                        }
                    }
                    if(addToList) optionsToReturn.add(new SelectOption(p.id, p.name));
                }
        }
        return optionsToReturn;
    }
    
    //Used for froms only allow one product per request - Self Admin
    private List<SelectOption> getLimitedProductSelectionsForSelfAdmin(){
        List<SelectOption> optionsToReturn = new List<SelectOption>();
        optionsToReturn.add(new SelectOption('', 'Select Product'));
        if(productMaster!=null && productMaster.size()>0){
                for(ChannelOps_Spoilage_Product_Master__c p:productMaster){
                    Boolean addToList=true;
                //    p.Reminding_Allowed_QTY__c = selfAdminProductVolumeLimit;
                      p.Reminding_Allowed_QTY__c = p.Volume_limitation__c;
                    if(requestProducts !=null && requestProducts.size()>0) {
                        for(ChannelOps_Spoilage_Request_Product__c rp:requestProducts ){
                            
                            //only allow one product to be reported in a Lytics request                   
                            if(rp.Brand__c!=p.Brand__c) addToList=false;
                            else {
                                p.Reminding_Allowed_QTY__c =p.Reminding_Allowed_QTY__c-rp.Quantity__c;
                                if (p.Reminding_Allowed_QTY__c<=0) addToList=false;
                                    
                            }
                                    
                        }
                    }
                    if(addToList) optionsToReturn.add(new SelectOption(p.id, p.name));
                }        }
        return optionsToReturn;
    }
    
   
    //Used for form has no limitation on how many product can be reported in one request - cold storage and universal
    private List<SelectOption> getUnlimitedProductSelections(){
        List<SelectOption> optionsToReturn = new List<SelectOption>();
        optionsToReturn.add(new SelectOption('', 'Select Product'));
        if(productMaster!=null && productMaster.size()>0){
                for(ChannelOps_Spoilage_Product_Master__c p:productMaster){
                    Boolean addToList=true;
                    if (p.Volume_limitation__c!=null && p.Volume_limitation__c>0) p.Reminding_Allowed_QTY__c=p.Volume_limitation__c;
                    
                    if(requestProducts !=null && requestProducts.size()>0) {
                        for(ChannelOps_Spoilage_Request_Product__c rp:requestProducts ){                                              
                            if(rp.Product__c==p.id && p.Reminding_Allowed_QTY__c!=null && p.Reminding_Allowed_QTY__c>0){
                                p.Reminding_Allowed_QTY__c =p.Reminding_Allowed_QTY__c-rp.Quantity__c;
                                if (p.Reminding_Allowed_QTY__c<=0) addToList=false;                                  
                            }
                                    
                        }
                    }
                    if(addToList) optionsToReturn.add(new SelectOption(p.id, p.name));
                }
        }
        return optionsToReturn;
    }


    private List<SelectOption> getProductSelectionsForOthers(){
        List<SelectOption> optionsToReturn = new List<SelectOption>();
        optionsToReturn.add(new SelectOption('', 'Select Product'));
        if(productMaster!=null){
                for(ChannelOps_Spoilage_Product_Master__c p:productMaster){
                     optionsToReturn.add(new SelectOption(p.id, p.name));
                }
        }
        return optionsToReturn;
    }
    
    public List<SelectOption> getProductSelections(){
        if(request.Spoilage_Type__c=='Lytics Spoilage'){
            return getLimitedProductSelectionsForLytics(); 
        }else if(request.Spoilage_Type__c == 'Self-Administered Product Spoilage'){
           return getLimitedProductSelectionsForSelfAdmin(); 
        }else if(request.Spoilage_Type__c=='Cold Storage Failure' || request.Spoilage_Type__c=='Universal Spoilage'){
          return getUnlimitedProductSelections();  
        }else{
            return getProductSelectionsForOthers();
        }
    }
   
    private void clearReasonCodeSelection(){
        selectedReasonId='';
        reason_Detail='';
        //  request.Reason_Detail__c='';          
        reasonDetailRequired = false;
        request.Reason_Code__c='';
        request.Reason__c=null;
        reasonDetailAreaLabel = generalSpoilageReasonDetailLabel;
        displayReasonDetail = false;
    }
    
    public List<SelectOption> getUnavailableDaysSelections(){
        List<SelectOption> optionsToReturn = new List<SelectOption>();
        
        SelectOption op1=new SelectOption('Monday', 'Monday');
        optionsToReturn.add(op1);
        SelectOption op2=new SelectOption('Tuesday', 'Tuesday');
        optionsToReturn.add(op2);
        SelectOption op3=new SelectOption('Wednesday', 'Wednesday');
        optionsToReturn.add(op3);
        SelectOption op4=new SelectOption('Thursday', 'Thursday');
        optionsToReturn.add(op4);
        SelectOption op5=new SelectOption('Friday', 'Friday');
        optionsToReturn.add(op5);
        SelectOption op6=new SelectOption('None', 'None of These');
        optionsToReturn.add(op6);
        
        return optionsToReturn ;
    }
    
    public List<SelectOption> getReasonCodeSelections(){
        List<SelectOption> optionsToReturn = new List<SelectOption>();
        
        //no spoilage reason selection should be displayed when no product is included in the spoilage request
        if(requestProducts==null || requestProducts.size()<=0) {                
            clearReasonCodeSelection();
            return optionsToReturn;
        }
        
        Boolean keepSelectedReasonId=false;       
        for(ChannelOps_Spoilage_Reason_Code_Master__c rcm:reasonCodeMaster){
            Boolean includeIt=true;
            
            for(ChannelOps_Spoilage_Request_Product__c rp:requestProducts){
                if(rcm.Brand__c.containsIgnoreCase(rp.brand__c)==false) {
                    includeIt=false;
                    break;
                }
            }
            
            if(includeIt){
                SelectOption op=new SelectOption(rcm.id, rcm.Spoilage_Reason__c);
                optionsToReturn.add(op);
                
                //only keep reason selection if selectedReasonId is still in the range of updated reason code selection
                if(selectedReasonId!=null && op.getValue() == selectedReasonId)    keepSelectedReasonId=true;            
            }
        }

        //if selectedReasonId isn't in the range of updated reason code selection should reset all reason code related field value
        if(keepSelectedReasonId==false){
            clearReasonCodeSelection();
            
        }
        
        return optionsToReturn;
    }
    
    
    
    public PageReference updateReasonCode() {
        
        for(ChannelOps_Spoilage_Reason_Code_Master__c rcm: reasonCodeMaster) {
            if(selectedReasonId==rcm.id) {
                request.Reason_Code__c=rcm.Spoilage_Reason__c;            
                request.Reason__c=rcm.id;
                reasonDetailRequired =rcm.Explanation_Required__c;                
                reasonDetailAreaLabel = rcm.Reason_Detail_Question_Label__c;
                displayReasonDetail = rcm.Display_Explanation__c;
                
                //SPECIAL LOGIC FOR COLD STORAGE
                if(request.Spoilage_Type__c=='Cold Storage Failure'){
                    if(request.Reason_Code__c!=null && request.Reason_Code__c.containsIgnoreCase('Catastrophic event')){
                        
                        request.CatastrophicEvent__c=true;
                      //  request.Reason_Detail_2__c=null;
                        reason_Detail_2=null;
                    }
                    else {
                        request.CatastrophicEvent__c=false;
                        
                       /* if(request.Reason_Code__c!=null && request.Reason_Code__c.containsIgnoreCase('Redundant system not in place')){
                            request.Have_Redundant_System__c=false;
                        }else request.Have_Redundant_System__c=true;*/
                   }
                }
            }
        }
    
        
        return null;
    }


    public List<SelectOption> getRequestTypeSelections(){
        Schema.DescribeFieldResult describeResult = ChannelOps_Spoilage_Request__c.Spoilage_Type__c.getDescribe();
        List<Schema.PicklistEntry> entries = describeResult.getPicklistValues();
        List<SelectOption> optionsToReturn = new List<SelectOption>();

        for (Schema.PicklistEntry pEntry : entries) {
            if (pEntry.isActive()) {
                optionsToReturn.add(new SelectOption(pEntry.getValue(), pEntry.getLabel()));
            }
        }

        return optionsToReturn;
    }


    public PageReference cancel() {
        PageReference nextPage=Page.ChannelOps_SpoilageRequest_Home;
        nextPage.setRedirect(true);
        return nextPage;
    }
        
    public PageReference goToHomeFromError() {
        PageReference nextPage=Page.ChannelOps_SpoilageRequest_Home;
        nextPage.setRedirect(false);
        return nextPage;
    }

    private Boolean signatureCompleted(){
        Boolean completed=true;
        if(this.verified) errorMsg ='';
        synchOtherTitleFields();
        
        if(request.Spoilage_Type__c =='Universal Spoilage' && (notBilledPatient==false || notBilledPayer==false ||noUseOfProduct==false)){
            if(errorMsg.trim().length()>0) errorMsg +='<br/>';
            errorMsg += 'Error: You must accept all the Terms & Conditions before you can submit this request';
            completed=false;
        }else if(request.Spoilage_Type__c =='Lytics Spoilage' && (noClaimOfProduct ==false ||noUseOfProduct==false)){
            if(errorMsg.trim().length()>0) errorMsg +='<br/>';
            errorMsg += 'Error: You must accept all the Terms & Conditions before you can submit this request';
            completed=false;
        }else if(request.Spoilage_Type__c =='Self-Administered Product Spoilage' && (PatientOrPayer==false ||productDisposed==false)){
            if(errorMsg.trim().length()>0) errorMsg +='<br/>';
            errorMsg += 'Error: You must accept all the Terms & Conditions before you can submit this request';
            completed=false;
        }else if(request.Spoilage_Type__c =='Cold Storage Failure' && (noUseOfProduct==false ||noClaimOfProduct ==false ||beyondControl==false)){
            if(errorMsg.trim().length()>0) errorMsg +='<br/>';
            errorMsg += 'Error: You must accept all the Terms & Conditions before you can submit this request';
            completed=false;
        }
        
       
        
        if(hcpName==null || hcpName.trim().length()==0) {
            if(errorMsg.trim().length()>0) errorMsg +='<br/>';
            errorMsg +='Error: Name in the Terms & Conditions section is required';
            completed=false;
        }
        
        if(titleString == null || titleString.trim().length()==0) {
            if(errorMsg.trim().length()>0) errorMsg +='<br/>';
            errorMsg += 'Error: Title in the Terms & Conditions section is required';
            completed=false;
        }
        
        if(request.Spoilage_Type__c=='Lytics Spoilage') {
            if(request.Title_credential__c==null ) {
                if(errorMsg.trim().length()>0) errorMsg +='<br/>';
                errorMsg += 'Error: Credentials in the Terms & Conditions section is required';
                completed=false;
            }else if(request.Title_credential__c!=null && request.Title_credential__c.contains('Other') && (otherTitle==null || otherTitle.trim().length()==0)) {
                if(errorMsg.trim().length()>0) errorMsg +='<br/>';
                errorMsg += 'Error: Other credentials in the Terms & Conditions section is required';
                completed=false;
            }
        }
        
        return completed;
    
    }
    
    private Boolean beyondTimeWindow(){
        Date submissionDate = (request.Submission_Date__c != null) ? request.Submission_Date__c : System.today();
        integer diffDate = request.Date_of_Spoilage__c.daysBetween(submissionDate) ;
        if(diffDate >= numOfDaysForAutoDenial) {
            return true; 
         } else return false;
    }
    
    //added the logic to exclude the Genentech Patient foundation product from auto denial
    private void autoDenial(){
        request.Status__c='New';
        request.Auto_denial_off_label_use__c=false;
        request.Auto_Denail_late__c=false;
        
        if(request.Spoilage_Type__c=='Lytics Spoilage'){
            //check auto denial for beyond request time window
            if(!request.GATCF_Product__c && beyondTimeWindow()){
                request.Status__c='Rejected - rejection email sent';
                request.Auto_Denail_late__c=true;
            }
            
            //check auto denial for off label use 
             for(ChannelOps_Spoilage_Request_Product__c rp: requestProducts){   
                 if(String.isNotBlank(rp.Indication__c) && rp.Indication__c=='Other') {
                     request.Auto_denial_off_label_use__c=true;
                     request.Status__c='Rejected - rejection email sent';
                     break;
                 }
             }
        }
                        
          /*Cold Storage*/
         if(request.Spoilage_Type__c=='Cold Storage Failure'){
             if(request.Reason_Code__c!='Catastrophic Event' && request.Depleted_Inventory__c==false 
                && !request.GATCF_Product__c && beyondTimeWindow()){
                  request.Status__c='Rejected - rejection email not sent';
                  request.Auto_Denail_late__c=true;
             }
            
         }
         // Self Administerd
         if(request.Spoilage_Type__c=='Self-Administered Product Spoilage'){            
              if(!request.GATCF_Product__c && beyondTimeWindow()){
                  request.Status__c='Rejected - rejection email not sent';
                  request.Auto_Denail_late__c=true;
             }
             
         }
         
         // Universal
          if(request.Spoilage_Type__c=='Universal Spoilage'){
               if(!request.GATCF_Product__c && beyondTimeWindow()){
                  request.Status__c='Rejected - rejection email sent';
                  request.Auto_Denail_late__c=true;
             }
          }
             
        //return false;
    }
    
    List<ChannelOps_Spoilage_Duplicate_Requests__c> dupList=new List<ChannelOps_Spoilage_Duplicate_Requests__c>();
    
    private void checkForDuplicateRequest(){
        request.Possible_Duplicate_Request_ID__c='';
        List<ChannelOps_Spoilage_Request__c> dupOnes = [Select id, Spoilage_Type__c, Date_of_Spoilage__c, License_Num__c, License_Type__c from ChannelOps_Spoilage_Request__c 
        where Spoilage_Type__c=:request.Spoilage_Type__c and Date_of_Spoilage__c=:request.Date_of_Spoilage__c and License_Num__c=:request.License_Num__c and License_Type__c=:request.License_Type__c and id!=:request.id];
            
        if(dupOnes!=null && dupOnes.size()>0){
            List<String> requestNDCs=new List<String>();
            List<String> requestLots =new List<String>();
            
            for(ChannelOps_Spoilage_Request_Product__c rp:requestProducts){
                requestNDCs.add(rp.NDC__c);      
                requestLots.add(rp.Lot_Number__c);          
            }
            
            for(ChannelOps_Spoilage_Request__c old : dupOnes) {
                List<ChannelOps_Spoilage_Request_Product__c> rp=[select NDC__c, Spoilage_Request__c from ChannelOps_Spoilage_Request_Product__c where Spoilage_Request__c=:old.id and NDC__c IN :requestNDCs AND Lot_Number__c IN :requestLots ];
                if(rp!=null && rp.size()>0) {
                    request.Duplicate_Warning__c= true;
                    request.Possible_Duplicate_Request_ID__c +=old.id+',';
                   // request.Duplicate_Spoilage_Request__c=old.id;
                    ChannelOps_Spoilage_Duplicate_Requests__c dup=new ChannelOps_Spoilage_Duplicate_Requests__c();
                    dup.From_Request__c=old.id;
                    dup.To_Request__c=request.id;
                    dupList.add(dup);
                    ChannelOps_Spoilage_Duplicate_Requests__c dup2=new ChannelOps_Spoilage_Duplicate_Requests__c();
                    dup2.From_Request__c=request.id;
                    dup2.To_Request__c=old.id;
                    dupList.add(dup2);
                }
                
            }
        }
               
    }
    
    private void flagRequestForAdverseEventQualityIssue(){
        if(request!=null) {
            request.Adverse_Event__c=false;
            request.Quality_Issue__c=false;
            
            for(ChannelOps_Spoilage_Keywords__c word:keywords){
                //check reason detail text area
                if(reason_Detail!=null && reason_Detail.trim().length()>0){
                    if(reason_Detail.containsIgnoreCase(word.name)){ 
               // if(request.Reason_Detail__c!=null && request.Reason_Detail__c.trim().length()>0){
               //     if(request.Reason_Detail__c.containsIgnoreCase(word.name)){                      
                        if(word.keyword_type__c=='Adverse Event') request.Adverse_Event__c=true;
                        else if(word.keyword_type__c=='Quality Issue') request.Quality_Issue__c=true;
                    }
                }
                if(reason_Detail_2!=null && reason_Detail_2.trim().length()>0){
                    if(reason_Detail_2.containsIgnoreCase(word.name)){                      
             //   if(request.Reason_Detail_2__c!=null && request.Reason_Detail_2__c.trim().length()>0){
                //    if(request.Reason_Detail_2__c.containsIgnoreCase(word.name)){                      
                        if(word.keyword_type__c=='Adverse Event') request.Adverse_Event__c=true;
                        else if(word.keyword_type__c=='Quality Issue') request.Quality_Issue__c=true;
                    }
                }
                
                //check return method detail field
                if(request.return_method_detail__c!=null && request.return_method_detail__c.trim().length()>0){
                    if(request.return_method_detail__c.containsIgnoreCase(word.name)){
                        if(word.keyword_type__c=='Adverse Event') request.Adverse_Event__c=true;
                        else if(word.keyword_type__c=='Quality Issue') request.Quality_Issue__c=true;
                    }
                }
                
                //check each request product other indication field
                for(ChannelOps_Spoilage_Request_Product__c rp:requestProducts){
                    if(rp.Other_Indication__c!=null && rp.Other_Indication__c.trim().length()>0){
                        if(rp.Other_Indication__c.containsIgnoreCase(word.name)){
                            if(word.keyword_type__c=='Adverse Event') request.Adverse_Event__c=true;
                            else if(word.keyword_type__c=='Quality Issue') request.Quality_Issue__c=true;
                    }
                    }              
                }
            }
        }
    }
     
   List<ChannelOps_Spoilage_Human_Error_Tracking__c> HumanErrorList=new List<ChannelOps_Spoilage_Human_Error_Tracking__c>();
 private void checkForPreviousHumanError(){
     Date d=(System.TODAY()-365);
        List<ChannelOps_Spoilage_Request__c> excusedRequests=[select id,Human_Error_excused__c,State__c,License_Num__c,License_Type__c,Human_Error_Excused_Date__c,Date_of_Spoilage__c from ChannelOps_Spoilage_Request__c 
              where License_Type__c=:request.License_Type__c and License_Num__c=:request.License_Num__c and State__c=:request.State__c and Human_Error__c=true and Date_of_Spoilage__c >=: d and id!=:request.id];
              if(excusedRequests!=null && excusedRequests.size()>0) {  
                  
                    for(ChannelOps_Spoilage_Request__c oldRequest:excusedRequests){                       
                        ChannelOps_Spoilage_Human_Error_Tracking__c HumanErrorRecord=new ChannelOps_Spoilage_Human_Error_Tracking__c();
                        HumanErrorRecord.From_Request__c=oldRequest.Id;
                        HumanErrorRecord.To_Request__c=request.Id;
                        HumanErrorRecord.Is_Excused__c=oldRequest.Human_Error_excused__c;
                        HumanErrorRecord.Excused_Date__c=oldRequest.Human_Error_Excused_Date__c;
                        HumanErrorRecord.Spoilage_Date__c=oldRequest.Date_of_Spoilage__c;
                        HumanErrorList.add(HumanErrorRecord);
                        
                        ChannelOps_Spoilage_Human_Error_Tracking__c HumanErrorRecord2=new ChannelOps_Spoilage_Human_Error_Tracking__c();
                        HumanErrorRecord2.From_Request__c=request.Id;
                        HumanErrorRecord2.To_Request__c=oldRequest.Id ;                      
                        HumanErrorRecord2.Spoilage_Date__c=request.Date_of_Spoilage__c;
                        HumanErrorList.add(HumanErrorRecord2);
                        
                    }
                }
    }
 List<ChannelOps_Spoilage_Redundant_System_Not__c> RedundantSystemList=new List<ChannelOps_Spoilage_Redundant_System_Not__c>();
 private void checkForRedundantSystem(){
     
        List<ChannelOps_Spoilage_Request__c> previousRedundantSystemsList=[select id,State__c,License_Num__c,License_Type__c,Date_of_Spoilage__c, No_Redundant_System_Excused__c, No_Redundant_System_Excused_Date__c from ChannelOps_Spoilage_Request__c 
              where License_Type__c=:request.License_Type__c and License_Num__c=:request.License_Num__c and State__c=:request.State__c and Reason_Code__c='Redundant system not in place' and id!=:request.id];
              if(previousRedundantSystemsList!=null && previousRedundantSystemsList.size()>0) {                     
                    for(ChannelOps_Spoilage_Request__c oldRequest:previousRedundantSystemsList){                        
                        ChannelOps_Spoilage_Redundant_System_Not__c RedundantSystem=new ChannelOps_Spoilage_Redundant_System_Not__c();
                        RedundantSystem.From_Request__c=oldRequest.Id;
                        RedundantSystem.To_Request__c=request.Id;
                        RedundantSystem.Excused_Date__c=oldRequest.No_Redundant_System_Excused_Date__c;
                        RedundantSystem.Spoilage_date__c=oldRequest.Date_of_Spoilage__c;
                        RedundantSystem.Is_Excused__c=oldRequest.No_Redundant_System_Excused__c;
                        RedundantSystemList.add(RedundantSystem);
                        if(oldRequest.No_Redundant_System_Excused__c==true) {
                            request.No_Redundant_System_Excused_Request__c=oldRequest.id;
                            upsert request;
                        }
                        
                        ChannelOps_Spoilage_Redundant_System_Not__c RedundantSystem2=new ChannelOps_Spoilage_Redundant_System_Not__c();
                        RedundantSystem2.From_Request__c=request.Id;
                        RedundantSystem2.To_Request__c=oldRequest.Id;
                        RedundantSystem2.Spoilage_date__c=request.Date_of_Spoilage__c;                       
                        RedundantSystemList.add(RedundantSystem2);
                    }
                }
    }

    public PageReference save() {
        
        if(!this.verified) verifyCaptcha();
       
        if(signatureCompleted() && this.verified) {
           //check for possible autodenial
            autoDenial();
            
            if(request.Status__c=='New' && request.GATCF_Product__c==true) request.Status__c='Forwarded to Genentech Patient Foundation';
           
            flagRequestForAdverseEventQualityIssue();
           
            request.Signature_Signed__c=true;
             try{
                logRequesterInfo();
                ChannelOps_Apps_Message_Controller appMsgController = new ChannelOps_Apps_Message_Controller(ChannelOps_Constants.APP_NAME, request.Spoilage_Type__c , '',
                                                                    ChannelOps_Constants.FIELD_MSG_TYPE, request);
                List<ChannelOps_Apps_Message__c> fieldMessageList = appMsgController.getMessageList();
                 if(fieldMessageList != null && !fieldMessageList.isEmpty()){
                     request.Message__c = '';
                     for(ChannelOps_Apps_Message__c fieldMessage : fieldMessageList){
                        request.Message__c += fieldMessage.Message__c + '<br/><br/>';
                     }
                     request.Message__c = request.Message__c.removeEnd('<br/><br/>');
                 }
                 // save input text values
                 request.Title_String__c=titleString;
                 request.HCP_Name__c=hcpName;  
                 request.Other_Title__c=otherTitle;
                 request.Pharmacy_Reference_Num__c=pharmacyReferenceNum;
                 request.Reason_Detail_2__c=reason_Detail_2;
                 request.Reason_Detail__c=reason_Detail;                
                upsert request;
                  system.debug('request!!!!'+request);
                  system.debug('request@@@'+pharmacyReferenceNum);
             }catch(Exception e){
              System.debug('Can insert spoilage request due to: '+e.getMessage());
             }
             
            for (ChannelOps_Spoilage_Request_Product__c rp:requestProducts){
                if(rp.Id == null){
                    rp.Spoilage_Request__c=request.id;
                }
            }
            
            try{
                upsert requestProducts;
                
                //add code to delete the products 
                if(!deleteRemovedProducts.isEmpty()){
                    delete deleteRemovedProducts;
                }
             }catch(Exception e){
              System.debug('Can insert spoilage request product list due to: '+e.getMessage());
             }
            
            
            //populate the duplicate request related list
            checkForDuplicateRequest();
            if(dupList!=null && dupList.size()>0) {
                try{
                    //save input text values
                    request.Title_String__c=titleString;
                    request.HCP_Name__c=hcpName;  
                    request.Other_Title__c=otherTitle;
                    request.Pharmacy_Reference_Num__c=pharmacyReferenceNum;
                    request.Reason_Detail_2__c=reason_Detail_2;
                    request.Reason_Detail__c=reason_Detail;    
                    upsert dupList;
                    upsert request;
                }catch(Exception e){
                    System.debug('failed to insert duplicate request records or update request after dup check due to: '+e.getMessage());
                }
            }
            //insert human error records
            checkForPreviousHumanError();
            if(HumanErrorList <> null && !(HumanErrorList.isEmpty())){
                try{
                    insert HumanErrorList;
                }Catch(Exception e){
                    System.debug('Human Error'+e.getMessage());
                    
                }
                
            }
            if(request.Spoilage_Type__c=='Cold Storage Failure') {
                checkForRedundantSystem();
                if(RedundantSystemList <> null && !(RedundantSystemList.isEmpty())){
                    try{
                    insert RedundantSystemList;
                    }Catch(Exception e){
                    System.debug('Human Error'+e.getMessage());
                    
                    }
                
                }
            }
            //PageReference nextPage = Page.ChannelOps_SpoilageRequest_Confirmation;
            PageReference nextPage = Page.ChannelOps_SpoilageRequest_HiddenPage;
            nextPage.getParameters().put('id',request.id);
            nextPage.getParameters().put('formTitle',getFormTitle());
            nextPage.getParameters().put('CSSubTitle',CSSubTitle);
            return nextPage.setRedirect(true);
        }
        else  return null;
    }
    
    //Added by Vijay
    public PageReference saveAsDraft(){
        PageReference nextPage = null;
        if(verifyCaptcha()) {
            try{
                logRequesterInfo();
                if(request.Spoilage_Type__c!='Lytics Spoilage'){
                    updateNoDeliveryDays();  
                } 
                request.Status__c = ChannelOps_Constants.SPOILAGE_STATUS_DRAFT;
                 request.Title_String__c=titleString;
                 request.HCP_Name__c=hcpName;  
                 request.Other_Title__c=otherTitle;
                 request.Pharmacy_Reference_Num__c=pharmacyReferenceNum;
                 request.Reason_Detail_2__c=reason_Detail_2;
                 request.Reason_Detail__c=reason_Detail;    
                upsert request;
                
                if(requestProducts != null && !requestProducts.isEmpty()){
                    for (ChannelOps_Spoilage_Request_Product__c rp:requestProducts){
                        if(rp.Id == null){
                            rp.Spoilage_Request__c=request.id;
                        }
                    }
                    upsert requestProducts;
                }
                //add code to delete the products 
                if(!deleteRemovedProducts.isEmpty()){
                    delete deleteRemovedProducts;
                }
                //nextPage = Page.ChannelOps_SpoilageRequest_Confirmation;    
                nextPage = Page.ChannelOps_SpoilageRequest_HiddenPage;
                nextPage.getParameters().put('id',request.id);
                nextPage.getParameters().put('formTitle',getFormTitle());
                nextPage.getParameters().put('CSSubTitle',CSSubTitle);
                nextPage.setRedirect(true);
             }catch(Exception e){
                System.debug(Logginglevel.ERROR, e.getMessage());
             }
        }
        return nextPage;
    }
    
    //Commented the return_method_detail__c null check. Refer US# COEXP-208
    private Boolean productInfoCompleted(){
        errorMsg ='';
        Boolean completed=true;
        if(showAddProductForm ==true) {
            errorMsg = 'Error: You must save or cancel the change you made in the Product Information section before you can continue.';
            completed= false;
        }
        if(requestProducts==null || requestProducts.size()<=0){
            errorMsg = 'Error: You must add at least one Genentech Product to this spoilage request.';
            completed= false;
        }
        if(request.Reason_Code__c==null) {
            if(errorMsg.trim().length()>0) errorMsg +='<br/>';
            errorMsg += 'Error: You must select a reason spoilage occurred.';
            completed= false;
        }
        if(request.Reason__c==null) {
            if(errorMsg.trim().length()>0) errorMsg +='<br/>';
            errorMsg += 'Error: You must select a reason spoilage occurred.';
            completed= false;
        }
        if((displayReasonDetail && reasonDetailRequired ==true && (reason_Detail==null || reason_Detail.trim().length()==0))||(request.Reason_Code__c.containsIgnoreCase('Redundant system')&&(reason_Detail_2==null || reason_Detail_2.trim().length()==0))) {
            if(errorMsg.trim().length()>0) errorMsg +='<br/>';
            errorMsg += 'Error: You must provide details for the spoilage reason selected in the comments box below';
            completed= false;
        }
        if((request.Return_Method__c==null || request.Return_Method__c=='') && request.Spoilage_Type__c != 'Self-Administered Product Spoilage'){
            if(errorMsg.trim().length()>0) errorMsg +='<br/>';
             errorMsg += 'Error: You must confirm whether you are able to return product';
            completed= false;
        }
        if(showNutropinSection){
            if(String.isBlank(request.Tracking_of_original_order__c)){
                if(errorMsg.trim().length()>0) errorMsg +='<br/>';
                errorMsg += 'Error: You must Enter Tracking # of original order.';
                completed= false;
            }
            if(String.isBlank(request.Tracking_of_replacement_shipment__c)){
                if(errorMsg.trim().length()>0) errorMsg +='<br/>';
                errorMsg += 'Error: You must Enter Tracking # of replacement shipment.';
                completed= false;
            }
        }
        if(showEvrysdiSection){
            if(String.isBlank(request.Case_ID__c)){
                if(errorMsg.trim().length()>0) errorMsg +='<br/>';
                errorMsg += 'Error: You must Enter Case ID #.';
                completed= false;
            }
            if(String.isBlank(request.Tracking_of_replacement_shipment__c) && !request.Replacement_Unit_Shipped__c){
                if(errorMsg.trim().length()>0) errorMsg +='<br/>';
                errorMsg += 'Error: You must Enter Tracking # of replacement shipment or select a replacement unit was shipped to the patient or caregiver with whom the spoilage event occured';
                completed= false;
            }
        }
        /*else if(request.Return_Method__c <> null && request.Return_Method__c.containsIgnoreCase('Other')==true && (request.return_method_detail__c==null || request.return_method_detail__c.trim().length()==0)){
            if(errorMsg.trim().length()>0) errorMsg +='<br/>';
            errorMsg += 'Error: You must provide detail for the reason that you were unable to return product';
            completed= false;
        }*/
        return completed;
    } 
    
    public PageReference goToReview() {
        synchReturnMethodFields();
        //synchOtherIndicationFields();
        PageReference nextPage;
        errorMsg = '';
        pharmacyRefVMsg ='';
        if(productInfoCompleted()) {
            if(!validateSpoilageRequiredFields() || !validateSpoilageReqBuinessRules()){
               System.debug('errorMsg----------'+errorMsg); 
               errorMsg = 'To Continue Submission (rather than continuing as draft), please use the back button and assure all required fields have been completed for the previous screen.';
            }else{
                errorMsg = '';    
                isSaveDraft = false;
                nextPage=Page.ChannelOps_SpoilageRequest_Review;
                nextPage.setRedirect(false);
                return nextPage;
            }
        }
        return null;
     }
    
    public PageReference navigateToReview(){
        PageReference nextPage = null;
        if(validateFieldsOnSaveDraft()){
            errorMsg = '';
            isSaveDraft = true;
            System.debug('request ---'+request);
            nextPage = Page.ChannelOps_SpoilageRequest_Review;
            nextPage.setRedirect(false);
        }
        return nextPage;
    }
    
    public PageReference navigateToProductInfo(){
        errorMsg ='';
        PageReference nextPage=Page.ChannelOps_SpoilageRequest_ProductInfo;
        nextPage.setRedirect(false);
        return nextPage;
    }
    
    public PageReference goToProductInfoSubmission() {
        errorMsg ='';
        pharmacyRefVMsg ='';
        if(request.Spoilage_Type__c!='Lytics Spoilage') updateNoDeliveryDays();
        
        if(!validateSpoilageRequiredFields() || !validateSpoilageReqBuinessRules()){
            return null;
        }        
        isSaveDraft = false;
        PageReference nextPage=Page.ChannelOps_SpoilageRequest_ProductInfo;
        nextPage.setRedirect(false);
        return nextPage;
    }
    
     public PageReference goToProductInfoDraft() {
        PageReference nextPage = null;
        if(validateFieldsOnSaveDraft()){
            errorMsg = '';
            isSaveDraft = true;
            System.debug('request ---'+request);
            nextPage = Page.ChannelOps_SpoilageRequest_ProductInfo;
            nextPage.setRedirect(false);
        }
        return nextPage;
    }
                
    public PageReference goToGeneralInfo() {
        showHomePopUp =false;
        synchReturnMethodFields();
        errorMsg ='';
        PageReference nextPage=Page.ChannelOps_SpoilageRequest_GeneralInfo;
        nextPage.setRedirect(false);
        return nextPage;
    }    
    

    private ID savepdf() {
        PageReference pdf = Page.ChannelOps_SpoilageRequest_PDF;
        // add parent id to the parameters for standardcontroller
        string encryptedRecordId=GCS_Util.encryptData(request.id,GCS_Util.getCryptoKey());
        pdf.getParameters().put('id',encryptedRecordId);
        pdf.setRedirect(true); 
        // create the new attachment
        Attachment attach = new Attachment();
        // the contents of the attachment from the pdf
        Blob body;
        try {
            // returns the output of the page as a PDF
            body = pdf.getContentasPDF();
        } catch (VisualforceException e) {
            body = Blob.valueOf('Unable to create Spoilage Request PDF file.');
            system.debug('unable to get content as pdf due to: '+e.getMessage());
        }
        attach.Body = body;
        // add the user entered name
        attach.Name = 'Request-'+requestRefNum+'.pdf';
        attach.IsPrivate = false;
        // attach the pdf to the account
        attach.parentid = request.id;
        attach.ContentType = 'application/pdf';
        
        try{ 
            insert attach;
         } catch (Exception e){
             system.debug('insert request PDF attachment failed due to: '+e.getMessage());
         }
         
         
         return attach.id;
        
  } 
  
 
 @future
 static void sendConfirmationEmail(ID attachId, String emailTemplate, List<string> toAddress, ID requestId, String accountName, Boolean bcc) {
    Messaging.EmailFileAttachment efa = null; 
    Attachment att = null;
    if(attachId != null){
        List<attachment>  attachmentList = [select id, body, name from Attachment where id=:attachId Order by LastModifiedDate DESC limit 1];
         
         // Create the email attachment
        if(!attachmentList.isEmpty()){
            att = attachmentList[0];
            efa = new Messaging.EmailFileAttachment();     
            efa.setFileName(att.name);
            efa.setBody(att.body);
        }
     }           
         // Define the email
        EmailTemplate et = [SELECT Id, name,Subject,HtmlValue, body FROM EmailTemplate WHERE DeveloperName =:emailTemplate ];
        
        //only to make email template works well
        Contact c=[select id, name, email from Contact where name=:accountName limit 1];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(et.Id);
        mail.setTreatTargetObjectAsRecipient(false);
        mail.setWhatId(requestId);       
        mail.setTargetObjectId(c.id);
        mail.setToAddresses(toAddress);
        if(bcc) mail.setBccAddresses(new String[]{c.email});
        
        //set from email address to org wide email address
        OrgWideEmailAddress orgWideAddress = null;
        try{
            string sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        
            orgWideAddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'noreplyco-d@gene.com'];
            
            if(sfdcBaseURL.contains('dev') || sfdcBaseURL.contains('sqa') || sfdcBaseURL.contains('uat')){
                orgWideAddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'gneforms-d@gene.com'];
            }
      
        } catch (Exception ex){
            system.debug('OrgWide address or configuration not found');
        }
        if(orgWideAddress != null){
           mail.setOrgWideEmailAddressId(orgWideAddress.Id);
        }
        
      
        
        //set reply to to ChannelOpsCasesSendtemplatereply email service
        EmailServicesFunction emsf = [select id, FunctionName from EmailServicesFunction where functionname='ChannelOpsCasesSendtemplatereply'];
        EmailServicesAddress emsa = [SELECT EmailDomainName,LocalPart FROM EmailServicesAddress where FunctionId=: emsf.id];
        string replyemail = emsa.LocalPart+'@'+emsa.EmailDomainName;
        mail.setReplyTo(replyemail);
        
     if(efa != null){
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
     }    
        // Sends the email 
        try{
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});  
                
        }catch(Exception e){
                System.debug('failed to send spoilage request confirmation email due to: '+e.getMessage());
        }
        
         
        ChannelOps_Spoilage_Request__c req=[select id, Confirmation_Email_Sent__c, Conformation_email_sent_at__c from ChannelOps_Spoilage_Request__c where id=:requestId];
        if(req!=null) {
            req.Confirmation_Email_Sent__c=true;
            req.Conformation_email_sent_at__c=System.now();
            req.PDF_Attachment_ID__c=attachId;
            try{
                upsert req; 
            }catch(Exception e){
                System.debug('update spoilage request record after confirmation email sending failed due to: '+e.getMessage());
            }
         }  
         
         //log outbound emails
         GNE_Channel_Ops_Email_Tracker__c newEmail=new GNE_Channel_Ops_Email_Tracker__c();
         newEmail.From_Address__c =orgWideAddress.Address ;
         newEmail.ChannelOps_Spoilage_Request__c=requestId;
         newEmail.Use_email_Tempate__c=true;
         newEmail.Email_Template_Name__c=et.name;
         newEmail.Time_Stamp__c=System.now();
         newEmail.To_Address__c='';
         for(String temp: toAddress) {
             newEmail.To_Address__c+=temp+',';
         }
        if(att != null){
            newEmail.Attachments__c=att.name;
        }
         try{
             
             insert newEmail;
            
         }catch(Exception e){
             System.debug('Log email failed due to: '+e.getMessage());
         }
     } 
  
  
  //action needs to be completed before confirmation page displays
/*  public PageReference initConfirmationPage(){
     List<ChannelOps_Spoilage_Request__c> reqs = [select name from ChannelOps_Spoilage_Request__c where id=:request.id];
     if(reqs!=null && reqs.size()>0) requestRefNum = reqs[0].name;
     else requestRefNum='error';
     
     string attachId=savepdf();
     
     List<string> toAddress = new List<string>();
     toAddress.add(request.Contact_Email__c);
     String template='';
     if(request.status__c=='New') template=emailTemplateNew;
     else if(request.Auto_Denail_late__c==true) template='ChannelOps Spoilage confirmation email-AutoDenied for greater than 30 days';
     else if(request.Auto_Denial_off_label_use__c==true) template='ChannelOps Spoilage confirmation email-AutoDenied for offlabel usage';
     try{
         sendConfirmationEmail(attachId,template, toAddress, request.Id);
     }catch(Exception e){
         System.debug('failed to send spoilage request confirmation email due to: '+e.getMessage());
     }
    
     return null;
      
  }*/
  
  public PageReference initConfirmPage(){
          List<ChannelOps_Spoilage_Request__History> spoilageReqHistoryList = null;
        PageReference curPage=ApexPages.currentPage();       
           if(curPage.getParameters()!=null) {
               
               requestId=GCS_Util.decryptData(curPage.getParameters().get('id'),GCS_Util.getCryptoKey());
               request = [select id,name,Spoilage_Type__c,Contact_Email__c,status__c,Auto_Denail_late__c,Auto_Denial_off_label_use__c, GATCF_Product__c,Message__c, Confirmation_Email_Sent__c from ChannelOps_Spoilage_Request__c where id=:requestId limit 1];
               
               formTitle=curPage.getParameters().get('formTitle');
               CSSubTitle=curPage.getParameters().get('CSSubTitle');
               isSaveDraft = false;
               if(request.Status__c == ChannelOps_Constants.SPOILAGE_STATUS_DRAFT){
                  isSaveDraft = true; 
               }
               spoilageReqHistoryList = [SELECT Id, NewValue,OldValue, Field FROM ChannelOps_Spoilage_Request__History Where ParentId =: requestId AND Field =: ChannelOps_Constants.CHANNELOPS_SPOILAGE_REQ_STATUS_APINAME Order By CreatedDate DESC];
           }
           if(request!=null) requestRefNum = request.name;
            else requestRefNum='error';
      return null;
  }
  
    //action needs to be completed before confirmation page displays      
    public PageReference initHiddenPage(){
        
        List<ChannelOps_Spoilage_Request__History> spoilageReqHistoryList = null;
        PageReference curPage=ApexPages.currentPage();       
           if(curPage.getParameters()!=null) {
               requestId=curPage.getParameters().get('id');
               request = [select id,name,Spoilage_Type__c,Contact_Email__c,status__c,Auto_Denail_late__c,Auto_Denial_off_label_use__c, GATCF_Product__c,Message__c, Confirmation_Email_Sent__c from ChannelOps_Spoilage_Request__c where id=:requestId limit 1];
               
               formTitle=curPage.getParameters().get('formTitle');
               CSSubTitle=curPage.getParameters().get('CSSubTitle');
               isSaveDraft = false;
               if(request.Status__c == ChannelOps_Constants.SPOILAGE_STATUS_DRAFT){
                  isSaveDraft = true; 
               }
               spoilageReqHistoryList = [SELECT Id, NewValue,OldValue, Field FROM ChannelOps_Spoilage_Request__History Where ParentId =: requestId AND Field =: ChannelOps_Constants.CHANNELOPS_SPOILAGE_REQ_STATUS_APINAME Order By CreatedDate DESC];
           }
           if(request!=null) requestRefNum = request.name;
            else requestRefNum='error';
            
     Id attachId = null;
     if(!isSaveDraft){
        attachId = savepdf();
     }
     
     List<string> toAddress = new List<string>();
     toAddress.add(request.Contact_Email__c);
     String template='';
     
     if(request.Status__c == Channelops_Constants.SPOILAGE_STATUS_DRAFT){
        template=draftRequestEmailtemplate;
     }else if(spoilageReqHistoryList != null && !spoilageReqHistoryList.isEmpty() && 
             spoilageReqHistoryList[0].OldValue == ChannelOps_Constants.SPOILAGE_STATUS_PENDING_CUST_CORRECTION
             && spoilageReqHistoryList[0].newValue == ChannelOps_Constants.SPOILAGE_STATUS_NEW){
        template = correctionRequestEmailTemplate;
     }else if(request.Status__c==ChannelOps_Constants.SPOILAGE_STATUS_FTGPF){
         template=emailTemplateGATCF;
         try{
         //forward request to GATCF program
         sendConfirmationEmail(attachId,emailTemplateToGATCF, GATCF_Address, request.Id, accountName, bcc);  
                 
         }catch(Exception e){
             System.debug('failed to send spoilage request confirmation email due to: '+e.getMessage());
         }
     }
     else if(request.status__c == ChannelOps_Constants.SPOILAGE_STATUS_NEW ||
             request.status__c == ChannelOps_Constants.SPOILAGE_STATUS_REJECTED_EMAIL_NOT_SENT){
         template=emailTemplateNew;
     }
     else if(request.Auto_Denail_late__c==true && request.Auto_Denial_off_label_use__c==true) template=emailTemplateReject3;
     else if(request.Auto_Denail_late__c==true) template=emailTemplateReject1;
     else if(request.Auto_Denial_off_label_use__c==true) template=emailTemplateReject2;
     try{
         sendConfirmationEmail(attachId,template, toAddress, request.Id, accountName, bcc); 
     }catch(Exception e){
         System.debug('failed to send spoilage request confirmation email due to: '+e.getMessage());
     }
    
        string encryptedRecordId=GCS_Util.encryptData(request.id,GCS_Util.getCryptoKey());
        
        PageReference nextPage = Page.ChannelOps_SpoilageRequest_Confirmation;
        nextPage.getParameters().put('id',encryptedRecordId);    
        nextPage.getParameters().put('formTitle',getFormTitle());
        nextPage.getParameters().put('CSSubTitle',CSSubTitle);
        nextPage.setRedirect(true);     
        return nextPage;
  } 
 
  public PageReference newRequestSameFacility(){
      ChannelOps_Spoilage_Request__c oldRequest=[select Street_2__c, Physician_First_Name__c, Physician_Last_Name__c, Pharmacy_Reference_Num__c, Do_Not_Deliver_On__c, Contact_Fax__c, Contact_Middle_Name__c, Facility_DEA__c,name, Facility_Name__c, License_Num__c,Street_Name__c,State__c,city__c,Zip__c,Contact_First_Name__c,Contact_Last_Name__c,Contact_Email__c,Contact_Phone__c from ChannelOps_Spoilage_Request__c where name =: requestRefNum];
      request= new ChannelOps_Spoilage_Request__c();
      request.Facility_Name__c=oldRequest.Facility_Name__c;
      request.License_Num__c=oldRequest.License_Num__c;
      request.Street_Name__c=oldRequest.Street_Name__c;
      request.State__c=oldRequest.State__c;
      request.city__c=oldRequest.city__c;
      request.Zip__c=oldRequest.Zip__c;
      request.Contact_First_Name__c=oldRequest.Contact_First_Name__c;
      request.Contact_Last_Name__c=oldRequest.Contact_Last_Name__c;
      request.Contact_Email__c=oldRequest.Contact_Email__c;
      request.Contact_Phone__c =oldRequest.Contact_Phone__c ;
      
      if(!String.isBlank(oldRequest.Do_Not_Deliver_On__c)) request.Do_Not_Deliver_On__c=oldRequest.Do_Not_Deliver_On__c;
      if(!String.isBlank(oldRequest.Physician_First_Name__c)) request.Physician_First_Name__c=oldRequest.Physician_First_Name__c;
      if(!String.isBlank(oldRequest.Physician_Last_Name__c)) request.Physician_Last_Name__c=oldRequest.Physician_Last_Name__c;
       if(!String.isBlank(oldRequest.Pharmacy_Reference_Num__c)) pharmacyReferenceNum=oldRequest.Pharmacy_Reference_Num__c;
     // if(!String.isBlank(oldRequest.Pharmacy_Reference_Num__c)) request.Pharmacy_Reference_Num__c=oldRequest.Pharmacy_Reference_Num__c;
     
      
      if(!String.isBlank(oldRequest.Facility_DEA__c)) request.Facility_DEA__c=oldRequest.Facility_DEA__c;
      if(!String.isBlank(oldRequest.Contact_Middle_Name__c)) request.Contact_Middle_Name__c=oldRequest.Contact_Middle_Name__c;
      if(!String.isBlank(oldRequest.Contact_Fax__c)) request.Contact_Fax__c=oldRequest.Contact_Fax__c;
      if(!String.isBlank(oldRequest.Street_2__c)) request.Street_2__c=oldRequest.Street_2__c;
      request.Submission_Date__c=System.today(); 
      PageReference nextPage=Page.ChannelOps_SpoilageRequest_Home;
      nextPage.setRedirect(false);
      return nextPage;
  }
  
     public PageReference viewRequestPDFPage() {
         string encryptedRecordId=GCS_Util.encryptData(request.id,GCS_Util.getCryptoKey());
         PageReference nextPage=Page.ChannelOps_SpoilageRequest_PDF;
         nextPage.getParameters().put('id',encryptedRecordId);
         return nextPage;
    }
    
    // reCaptcha - added by Jie at Oct 2, 2018 
    //public boolean checkCurrentValue{get;set;}
    public String challenge{get;set;}
    public String response{get;set;}
    public String publicKey {get;set;}
    public Boolean verified { get; private set; }
    private String privateKey;
    private String baseUrl;
    //public String testMS {set; get;}
    
   
    private boolean verifyCaptcha()
    {
      errorMsg ='';
        
        if (this.verified) return true;
        
        //testMS ='In verify method';
        // On first page load, form is empty, so no request to make yet
        if ( String.isBlank(response))
        {
            errorMsg ='Please acknowledge the reCAPTCHA by checking the I\'m not a robot checkbox';
            return false;
        }
        
        String urlbody='secret=' + privateKey + '&response='  +  response;
        HttpResponse r = makeRequest(baseUrl, urlbody);
        
        if ( r!= null )
        {
            
            // Parse JSON response to get all the totalPrice field values.

           JSONParser parser = JSON.createParser(r.getBody());
           
           while (parser.nextToken() != null) {

            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                (parser.getText() == 'success')) {
                // Get the value.
                parser.nextToken();
                if(parser.getText()=='true') this.verified = true;
            }
          }
        }else {
            errorMsg ='Please acknowledge the reCAPTCHA by checking the I\'m not a robot checkbox';
            return false;
        }
        
        if(this.verified)
        {
            // Pass verification, not robot
            
            return true;
        }
        else
        {
            // stay on page to re-try reCAPTCHA
            errorMsg ='Please acknowledge the reCAPTCHA by checking the I\'m not a robot checkbox';
            return false;
        }
         
    }
    
    
    public PageReference reset()
    {
        return null;
    }  
    /* Helper methods */
    private HttpResponse makeRequest(string url, string body) 
    {
       // String tempurl='https://www.google.com/recaptcha/api/siteverify?secret=6LcPp20UAAAAAMowSOP8dB842maumm9JPNXcTMl2&response=03AHqfIOmyWq5nnqEyR5ZDjY9-fpRYOIf0j-MQg8Nk2L7KLOckbsKKfbWeeUFqTZxHGiFHpw6jRFINZ4ZDHkbTzqo6NmJays1KWvZGtjv9LA1EfM70YxLCgkpAH3bXmV5YGO9XaI8cJR_vsnoKO7Peoxe4NvbmDEz7lQfKWBEfthGO_e_xiwg-H76EszjV8Jk7Wva8zvTtsc-ikYqUPLiG5js0QzVU28IjUMWgLOWEe2uFchSLLakVqnffS_MN-IubSPV1ubbQBxEhnx8nP7muIoxN7YDoBVpZWETucsOAwv-T146qoWT6Ikc';
        HttpResponse response = null;
        HttpRequest req = new HttpRequest();  
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setBody (body);
        try
        {
            Http http = new Http();
            response = http.send(req);
            System.debug('reCAPTCHA response: ' + response);
            System.debug('reCAPTCHA body: ' + response.getBody());
        }
        catch(System.Exception e)
        {
            System.debug('ERROR: ' + e);
        }
        return response;
    }
    private String remoteHost
    {
        get {
            String ret = '127.0.0.1';
            // also could use x-original-remote-host
            Map<String, String> hdrs = ApexPages.currentPage().getHeaders();
            if (hdrs.get('x-original-remote-addr')!= null)
                ret =  hdrs.get('x-original-remote-addr');
            else if (hdrs.get('X-Salesforce-SIP')!= null)
                ret =  hdrs.get('X-Salesforce-SIP');
            return ret;
        }
    } 
    //End of reCaptcha
    
    public PageReference navigateToSelectionPage() {
        
        PageReference nextPage=Page.ChannelOps_SpoilageRequest_Selection;
        userAction = emailAddress = requestNumber = licenseNumber = errorMsg = '';
        isSaveDraft = displayDraftBtn = false;
        nextPage.setRedirect(false);
        return nextPage;
    }
    
    public PageReference enableActionSection(){
        enableActionSection = true;
        enableSearchSection  = false;
        enableSpoilageTypeSection = false;
        enableMessageSection=false;
        userAction = emailAddress = requestNumber = licenseNumber = errorMsg = '';
        return null;        
    }  
    
    public PageReference createOrUpdateRequest(){
        System.debug('----In createOrUpdateRequest method----');
        if(String.isNotBlank(userAction)){
            if(userAction == 'draftRequest' || userAction == 'submittedRequest'){
                enableMessageSection=false;
                enableActionSection = false;
                enableSearchSection  = true;
                enableSpoilageTypeSection = false;                
                errorMsg ='';
            }else if(userAction == 'newRequest'){
                enableActionSection = false;
                enableSearchSection  = false;
                enableMessageSection=false;
                PageReference pageRef = new PageReference(System.Label.SpoilageCreateNewURL);
              //  enableSpoilageTypeSection = true;
                 return pageRef;
              //  displayDraftBtn = true;
              //  errorMsg ='';
            }
        }else{
            errorMsg = 'Please select one option';
        }
        return null;        
    }
    public void selectedOption(){        
        if(String.isNotBlank(userAction)){
            enableMessageSection=true;
            if(userAction == 'draftRequest'){
                 errorMsg ='You have until 04/30/2022 to complete saved draft spoilage requests or correct  previously submitted <br/> spoilage requests that were submitted on this website.<br/> <br/>'
                           +'After 04/30/2022 any incomplete draft spoilage requests or requests requiring correction will be  <br/> automatically closed.  You may re-submit them through the new website, genentechdirect.com/returns';
            }else if(userAction == 'submittedRequest'){
                errorMsg ='You have until 04/30/2022 to complete saved draft spoilage requests or correct  previously submitted <br/> spoilage requests that were submitted on this website.<br/> <br/>'
                           +'After 04/30/2022 any incomplete draft spoilage requests or requests requiring correction will be  <br/> automatically closed.  You may re-submit them through the new website, genentechdirect.com/returns';
            }else if(userAction == 'newRequest'){
                 errorMsg ='Our Spoilage and Expired Returns website has changed.  Click the “Continue” button to be redirected to the new website for Spoilage and Expired Returns.';
            }
        }
    }

    public PageReference searchSpoilageRequest(){
        System.debug('----In searchSpoilageRequest method----');
        errorMsg = '';
        enableMessageSection=false;
        if(validateSearchParams()){
            List<ChannelOps_Spoilage_Request__c> spoilageRequestList = fetchChannelOpsSPRequests(emailAddress,requestNumber,
                                                                                                licenseNumber);
            System.debug('spoilageRequestList ----'+spoilageRequestList);
            
            if(!spoilageRequestList.isEmpty()){             
                if(spoilageRequestList[0].Status__c != ChannelOps_Constants.SPOILAGE_STATUS_NEW && spoilageRequestList[0].Status__c != ChannelOps_Constants.SPOILAGE_STATUS_DRAFT
                   && spoilageRequestList[0].Status__c != ChannelOps_Constants.SPOILAGE_STATUS_PENDING_CUST_CORRECTION){
                     errorMsg = 'Spoilage request '+ spoilageRequestList[0].Name  +' is being processed, and not available for edits. If you have questions, please contact Genentech Customer Service at 800-551-2231.';
                }else{
                    request = spoilageRequestList[0];
                    reason_Detail_2=spoilageRequestList[0].Reason_Detail_2__c;
                    reason_Detail=spoilageRequestList[0].Reason_Detail__c;
                    pharmacyReferenceNum=spoilageRequestList[0].Pharmacy_Reference_Num__c;
                    otherTitle=spoilageRequestList[0].Other_Title__c;
                    hcpName=spoilageRequestList[0].HCP_Name__c;
                    titleString=spoilageRequestList[0].Title_String__c;
                    if(request.Status__c == ChannelOps_Constants.SPOILAGE_STATUS_DRAFT){
                        displayDraftBtn = true;
                        request.Submission_Date__c = System.today();
                    }
                    if(!request.ChannelOps_Spoilage_Product_Master__r.isEmpty()){
                        requestProducts.addAll(spoilageRequestList[0].ChannelOps_Spoilage_Product_Master__r);
                    }
                    if(request.Spoilage_Type__c!='Lytics Spoilage'){
                        updateNoDeliveryDays(request.Do_Not_Deliver_On__c);  
                    }
                    if(String.isNotBlank(request.Return_Method__c)){
                        setSelectedSafetyValue(request.Return_Method__c);
                    }
                    if(request.Reason__c != null){
                        selectedReasonId = request.Reason__c;
                    }
                    errorMsg = '';
                    checkSpecificBrandProduct();
                    return toGeneralInfo();
                }
            }else{
               errorMsg = ChannelOps_Constants.NO_SPOILAGE_REQ_FOUND; 
            }
        }
        return null;
    }
    
    private Boolean validateSearchParams(){
        Boolean isValid = true;
        if(String.isBlank(emailAddress)){
            errorMsg += 'Please enter valid email address';
            isValid = false;
        } 
        if(String.isBlank(requestNumber)){
            if(String.isNotBlank(errorMsg)){
               errorMsg += '<br/>';
            }
            errorMsg += 'Please enter request number';
            isValid = false;
        }
        if(String.isBlank(licenseNumber)){
            if(String.isNotBlank(errorMsg)){
               errorMsg += '<br/>';
            }
            errorMsg += 'Please enter license number';
            isValid = false;
        }
        return isValid;
    }
        
    private List<ChannelOps_Spoilage_Request__c> fetchChannelOpsSPRequests(String emailAddress, String requestNumber, 
                                                                          String licenseNumber){
        System.debug('----In fetchChannelOpsSPRequests method----');
        List<ChannelOps_Spoilage_Request__c> spoilageRequestList = new List<ChannelOps_Spoilage_Request__c>();                                                                  
        if(String.isNotBlank(emailAddress) && String.isNotBlank(requestNumber) && String.isNotBlank(licenseNumber)){
            spoilageRequestList = [SELECT  Adverse_Event__c,Assigned_To__c,AutoDenial_Excused__c,Auto_Denail_late__c,
                                           Auto_Denial_Excuse_Justification__c,Auto_Denial_off_label_use__c,
                                           CatastrophicEvent__c,ChannelOps_user_comment__c,City__c,Confirmation_Email_Sent__c,
                                           Conformation_email_sent_at__c,Contact_Email__c,Contact_Fax__c,Contact_First_Name__c,Contact_Last_Name__c,
                                           Contact_Middle_Name__c,Contact_Name__c,Contact_Phone__c,
                                           CreatedById,CreatedDate,Date_of_Spoilage__c,Depleted_Inventory__c,
                                           Do_Not_Deliver_On__c,Duplicate_Warning__c,Ending_Time__c,Facility_DEA__c,
                                           Facility_Name__c,GATCF_Product__c,HCP_Name__c,Human_Error_Excused_Date__c,
                                           Human_Error_Excused__c,Human_Error_Excuse_Justification__c,Human_Error__c,Id,                                           
                                           License_Num__c,License_Type__c,Name,No_Redundant_System_Excused_Date__c,
                                           No_Redundant_System_Excused_Request__c,No_Redundant_System_Excused__c,No_Redundant_System_excuse_justification__c,
                                           Other_Title__c,OwnerId,Page_Visited__c,PDF_Attachment_ID__c,
                                           Pharmacy_Reference_Num__c,Physician_First_Name__c,Physician_Last_Name__c,
                                           Possible_Duplicate_Request_ID__c,Quality_Issue__c,Reason_Code__c,
                                           Reason_Detail_2__c,Reason_Detail__c,Reason__c,request_IP__c,
                                           Return_Method_Detail__c,Return_Method__c,Reviewed_Date__c,SAP_Reason_Code__c,
                                           Signature_Signed__c,Spoilage_Type__c,Starting_Time__c,State__c,Status__c,
                                           Street_2__c,Street_Name__c,Submission_Date__c,Title_credential__c,
                                           Title_String__c,Zip__c,Tracking_of_original_order__c,Tracking_of_replacement_shipment__c,
                                           Case_ID__c, Replacement_Unit_Shipped__c,
                                (SELECT    Id,Indication__c,Lot_Number__c,Name,NDC__c,
                                            Other_Indication__c,Product_Name__c,Product__c,Quantity__c,Serial_Number__c,
                                            Spoilage_Request__c,Product__r.Brand__c, Brand__c FROM ChannelOps_Spoilage_Product_Master__r)
                                FROM       ChannelOps_Spoilage_Request__c
                                WHERE      Name =: requestNumber.trim() AND Contact_Email__c =: emailAddress.trim() AND 
                                           License_Num__c =: licenseNumber.trim()];
        }                                                                                
        return spoilageRequestList;                                                                     
    }
    
    private void updateNoDeliveryDays(String doNotDeliveryDays){
        if(String.isNotBlank(doNotDeliveryDays)){
            List<String> dayList = doNotDeliveryDays.split(';');
            if(!dayList.isEmpty()){
                Set<String> daySet = new Set<String>(dayList);
                if(daySet.contains('Monday')) monday = true;
                if(daySet.contains('Tuesday')) tuesday = true;
                if(daySet.contains('Wednesday')) wednesday = true;
                if(daySet.contains('Thursday')) thursday = true;
                if(daySet.contains('Friday')) friday = true;
                if(daySet.contains('Saturday')) saturday = true; 
                if(daySet.contains('Sunday')) sunday = true;
                if(daySet.contains('Able to accept delivery of product every day')) none =true;
            }
        }
    }
    
    private Boolean validateSpoilageReqBuinessRules(){
                   
        if(String.isBlank(request.Facility_DEA__c)){
            errorMsg ='Error: '+ DEANumLabel+' is required. If you do not have a DEA #, please enter “No DEA” in the DEA # field.';
        }
        if(request.Date_of_Spoilage__c>System.today()){
            String temp ='Error: Date of Spoilage can not be a future date';
            if(errorMsg !=null || errorMsg.trim().length()>0) errorMsg +='<br/>'+temp;
            else errorMsg = temp;
        }
        if((DayValue=='' || DayValue==null) && request.Spoilage_Type__c!='Lytics Spoilage'){
            String temp ='Error: Please indicate which days your office is unable to accept replacement';
            if(errorMsg !=null || errorMsg.trim().length()>0) errorMsg +='<br/>'+temp;
            else errorMsg =temp;          
        }
        if(String.isNotBlank(errorMsg)){
            return false;
        }
        return true;   
    }
    
    private Boolean validateSpoilageRequiredFields(){
        Boolean isValid = true;
        if(request != null){
            if(request.Spoilage_Type__c != ChannelOps_Constants.SPOILAGE_TYPE_LYTICS){
                 if(String.isBlank(request.Physician_First_Name__c)){
                    request.Physician_First_Name__c.addError(ChannelOps_Constants.REQ_FIELD_MSG);
                     isValid = false;
                }
                if(String.isBlank(request.License_Num__c)){
                    request.License_Num__c.addError(ChannelOps_Constants.REQ_FIELD_MSG);
                    isValid = false;
                }
                if(String.isBlank(request.Physician_Last_Name__c)){
                    request.Physician_Last_Name__c.addError(ChannelOps_Constants.REQ_FIELD_MSG);
                    isValid = false;
                }
                if(request.Spoilage_Type__c == ChannelOps_Constants.SPOILAGE_TYPE_SELF_ADMIN &&
                   String.isBlank(pharmacyReferenceNum)){
                   // String.isBlank(request.Pharmacy_Reference_Num__c)){
                    //request.Pharmacy_Reference_Num__c.addError(ChannelOps_Constants.REQ_FIELD_MSG);
                    pharmacyRefVMsg = ChannelOps_Constants.REQ_FIELD_MSG;
                    isValid = false;
                }
            }
            if(String.isBlank(request.Facility_Name__c)){
                request.Facility_Name__c.addError(ChannelOps_Constants.REQ_FIELD_MSG);
                isValid = false;
            }
            if(String.isBlank(request.License_Num__c)){
                request.License_Num__c.addError(ChannelOps_Constants.REQ_FIELD_MSG);
                isValid = false;
            }
            if(String.isBlank(request.Contact_First_Name__c)){
                request.Contact_First_Name__c.addError(ChannelOps_Constants.REQ_FIELD_MSG);
                isValid = false;
            }
            if(String.isBlank(request.Contact_Last_Name__c)){
                request.Contact_Last_Name__c.addError(ChannelOps_Constants.REQ_FIELD_MSG);
                isValid = false;
            }
            if(String.isBlank(request.Street_Name__c)){
                request.Street_Name__c.addError(ChannelOps_Constants.REQ_FIELD_MSG);
                isValid = false;
            }
            if(String.isBlank(request.Contact_Email__c)){
                request.Contact_Email__c.addError(ChannelOps_Constants.REQ_FIELD_MSG);
                isValid = false;
            }
            if(String.isBlank(request.City__c)){
                request.City__c.addError(ChannelOps_Constants.REQ_FIELD_MSG);
                isValid = false;
            }
            if(String.isBlank(request.Contact_Phone__c)){
                request.Contact_Phone__c.addError(ChannelOps_Constants.REQ_FIELD_MSG);
                isValid = false;
            }
            if(String.isBlank(request.Contact_Phone__c)){
                request.Contact_Phone__c.addError(ChannelOps_Constants.REQ_FIELD_MSG);
                isValid = false;
            }
            if(String.isBlank(request.State__c)){
                request.State__c.addError(ChannelOps_Constants.REQ_FIELD_MSG);
                isValid = false;
            }
            if(String.isBlank(request.Zip__c)){
                request.Zip__c.addError(ChannelOps_Constants.REQ_FIELD_MSG);
                isValid = false;
            }
            if(request.Date_of_Spoilage__c == null){
                request.Date_of_Spoilage__c.addError(ChannelOps_Constants.REQ_FIELD_MSG);
                isValid = false;
            }
        }
        return isValid;
    }
    
    private Boolean validateFieldsOnSaveDraft(){
        Boolean isValid = true;
        if(String.isBlank(request.License_Num__c)){
            request.License_Num__c.addError(ChannelOps_Constants.REQ_FIELD_MSG);
            isValid = false;
        }
        if(String.isBlank(request.Contact_Email__c)){
            request.Contact_Email__c.addError(ChannelOps_Constants.REQ_FIELD_MSG);
            isValid = false;
        }
        return isValid;
    }
    
    public PageReference goToSelection() {
        PageReference selectionPage = Page.ChannelOps_SpoilageRequest_Selection;
        selectionPage.setRedirect(true);
        return selectionPage;
    }
    
    private void checkSpecificBrandProduct(){        
        showNutropinSection = false;
        showEvrysdiSection = false;

        if(requestProducts != null && !requestProducts.isEmpty()){
            for(ChannelOps_Spoilage_Request_Product__c spoilageProduct: requestProducts){
                system.debug('spoilageProduct.brand__c--------'+spoilageProduct.brand__c);
                if(spoilageProduct.brand__c == 'Nutropin'){
                     showNutropinSection = true;
                     brandName = spoilageProduct.brand__c;
                     break;
                }

                if(spoilageProduct.brand__c == 'Evrysdi'){
                    showEvrysdiSection = true;
                    brandName = spoilageProduct.brand__c;
                    break;
               }

            }
        }
        request.Tracking_of_original_order__c = (!showNutropinSection) ? '':request.Tracking_of_original_order__c;
        request.Tracking_of_replacement_shipment__c = (!showNutropinSection && !showEvrysdiSection) ? '':request.Tracking_of_replacement_shipment__c;
        request.Case_ID__c = (!showEvrysdiSection) ? null:request.Case_ID__c;
        request.Replacement_Unit_Shipped__c = (!showEvrysdiSection) ? false :request.Replacement_Unit_Shipped__c;
    }
    
    /*private String replaceFieldInEmailBody(String body, ChannelOps_Spoilage_Request__c spoilageRequest){
        String emailBody = '';
        if(String.isNotBlank(body) && spoilageRequest != null){
            body = body.replace('{!ChannelOps_Spoilage_Request__c.Contact_Name__c}', spoilageRequest.Contact_Name__c);
            body = body.replace('{!SpoilageRequestURL}', );
        }
        
    }*/
}