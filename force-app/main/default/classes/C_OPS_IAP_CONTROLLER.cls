public with sharing class C_OPS_IAP_CONTROLLER {
    
    public PageReference navtoContact() {
        pageReference c_ops_iap_contact_infopg = new PageReference('/apex/C_OPS_IAP_CONTACT_INFOPG');
        c_ops_iap_contact_infopg.setRedirect(false);
        return c_ops_iap_contact_infopg ;
    }
    public PageReference reachedreviewandsubmit() {
        return null;
    }
    
    public List<SelectOption> getstatelist()
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = C_Ops_SPLOA_Request__c.State__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('Select One','Select One' ));
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption( f.getValue(),f.getLabel()));
        }     
        return options;
    }
    
    public List<SelectOption> getpharstatelist()
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = C_Ops_SPLOA_Additional_Pharmacy__c.C_Ops_SPLOA_State__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('Select One','Select One' ));
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption( f.getValue(),f.getLabel()));
        }     
        return options;
    }    
    public integer addPharmListSize; 
    Decimal numberofRenewalmonths;   
    public List<pharmacyquestionswrapper> pharmqueswrapperlist{get;set;}
    public List<pharmacyquestionswrapper> curqueswrapperlist{get;set;}
    public List<quesquestionswrapper> quesquestionswrapperlist{get;set;}
    public Map<C_Ops_SPLOA_Questions__c,List<C_Ops_SPLOA_Sub_Question__c>> quesMap;
    public Map<C_Ops_SPLOA_Questions__c,List<C_Ops_SPLOA_Sub_Question__c>> pharmquesMap; 
    public Map<C_Ops_SPLOA_Questions__c,List<C_Ops_SPLOA_Sub_Question__c>> quesquesMap; 
    public String oldproductName;
    public Boolean haveDEAError = false;
    public List<C_Ops_SPLOA_Questions__c> PharmacyQuestions{get;set;}
    public List<Business_Rule__c> businessrulslist{get;set;}
    public List<C_Ops_IAPDEA_Number__c> DEAexceptionlist{get;set;}
    public List<C_Ops_SPLOA_Questionnaire_Questions__c> existingQuestions;
    public String relatedAPLproductnames { get; set; }
    public Boolean editProd {get; set; }
    public String productToEdit {get; set; }
    public boolean  refreshquestion=false;
    public boolean  canSubmit {get; set; }    
    public String prodmessage { get; set; }
    public productquestionswrapper prdqueswrapper{ get; set;}
    public String ProductName{get;set;}
    public String GeneContactName{get;set;}
    public String GeneContactid{get;set;}
    public String GeneContactidbackup{get;set;}
    public Map<String,String> ProductnameandAPL = new Map<String,String>();
    public Map<String,String> ProductnameandGroupName = new Map<String,String>();
    public Map<String,String> APLandGroupMap = new Map<String,String>();
    public Map<String,String> APLtoAccessmap = new Map<String,String>();
    public Map<String, String> GroupandAccessTypMap{get;set;}
    public Map<String, String> GroupandAccessTypMapbackup{get;set;}
    public Map<String, String> GroupandDenialCodeatpharm{get;set;}
    public Map<String,String> GroupandDenialCodeatques{get;set;}
    public Map<String,String> ProductQuesNameandlabel ;
    public Map<String,String> AllQuesNameandlabel ;
    public Map<Id,String> AllQuesIdandlabel;
    public Map<String, String> Grprelatedprod{get;set;}
    public String Grp1pharmacyproducts{get;set;}
    public String Grp2pharmacyproducts{get;set;}
    public String Grp3pharmacyproducts{get;set;}
    public String Grp4pharmacyproducts{get;set;}
    public String Grp5pharmacyproducts{get;set;}
    public String Grp6pharmacyproducts{get;set;}
    public String Grp7pharmacyproducts{get;set;}
    public String Grp8pharmacyproducts{get;set;}
    public String Grp9pharmacyproducts{get;set;}
    public String Grp10pharmacyproducts{get;set;}
    public String Grp1quesproducts{get;set;}
    public String Grp2quesproducts{get;set;}
    public String Grp3quesproducts{get;set;}
    public String Grp4quesproducts{get;set;}
    public String Grp5quesproducts{get;set;}
    public String Grp6quesproducts{get;set;}
    public String Grp7quesproducts{get;set;}
    public String Grp8quesproducts{get;set;}
    public String Grp9quesproducts{get;set;}
    public String Grp10quesproducts{get;set;}
    public String GroupNamequestoshow{get;set;}
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Yes','Yes'));
        options.add(new SelectOption('No','No'));  return options;
        
    }
    
    public String addprodOption;
    public void SetaddprodOption(String addprodOption) {
        this.addprodOption = addprodOption;
        if(addprodOption =='Yes'){
            mainRequest.Additional_Products__c= true;
        }else{
            mainRequest.Additional_Products__c= false;
        }
    }
    public String getaddprodOption() {
        if(mainRequest.Additional_Products__c){
            addprodOption= 'Yes';
        }else{
            if(reqTyp == 'update' || addprodOption == 'No'){
                addprodOption= 'No';
            }else{
                addprodOption= '';
            }
        }
        return addprodOption;
    }
    public string signingperson;
    public void Setsigningperson(String signingperson) {
        this.signingperson = signingperson;
        if(signingperson =='Yes'){
            //Signing_Authority_Title__c,Signing_Authority_Last_Name__c,Signing_Authority_First_name__c,
            mainRequest.Same_Signing__c= true;
            mainRequest.Signing_Authority_First_name__c=mainRequest.C_Ops_SPLOA_First_Name__c;
            mainRequest.Signing_Authority_Last_Name__c=mainRequest.C_Ops_SPLOA_Last_Name__c;
            mainRequest.Signee_Email__c=mainRequest.C_Ops_SPLOA_Email__c;
            mainRequest.Signee_Phone__c=mainRequest.C_Ops_SPLOA_Phone__c;
            mainRequest.Signee_Email__c=mainRequest.C_Ops_SPLOA_Email__c;
            mainRequest.Signee_Extension__c=mainRequest.C_Ops_SPLOA_Extension__c;
        }else{
            mainRequest.Same_Signing__c= false;
            mainRequest.Signing_Authority_First_name__c='';
            mainRequest.Signing_Authority_Last_Name__c='';
            mainRequest.Signee_Email__c='';
            mainRequest.Signee_Phone__c='';
            mainRequest.Signee_Email__c='';
            mainRequest.Signee_Extension__c='';
        }
    }
    public String getsigningperson() {
        if(mainRequest.Same_Signing__c){
            signingperson= 'Yes';
        }else{
            signingperson= 'No';
        }
        return signingperson;
    }
    
    public void signingchange() {
        if(mainRequest.Same_Signing__c){
            mainRequest.Same_Signing__c= true;
            mainRequest.Signing_Authority_First_name__c=mainRequest.C_Ops_SPLOA_First_Name__c;
            mainRequest.Signing_Authority_Last_Name__c=mainRequest.C_Ops_SPLOA_Last_Name__c;
            mainRequest.Signee_Email__c=mainRequest.C_Ops_SPLOA_Email__c;
            mainRequest.Signee_Phone__c=mainRequest.C_Ops_SPLOA_Phone__c;
            mainRequest.Signee_Extension__c=mainRequest.C_Ops_SPLOA_Extension__c;
        }else{
            mainRequest.Signing_Authority_First_name__c='';
            mainRequest.Signing_Authority_Last_Name__c='';
            mainRequest.Signee_Email__c='';
            mainRequest.Signee_Phone__c='';
            mainRequest.Signee_Extension__c='';
        }
    }    
    
    public List<SelectOption> getPhysianSpeciality() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','Select One'));
        /*  for(C_Ops_SPLOA_Physicians__c specialityoption :physicianSpecialitylist){
options.add(new SelectOption(specialityoption.Name, specialityoption.Name));
}*/
        return options;        
    }      
    //Recaptcha variables
    private string recaptchaPrivateSecret;
    private String baseUrl;
    public C_Ops_Captcha_Property__c prop{get;set;}
    public String response { get; set; }
    
    //Document variables
    private string recaptchaPublicSecret;
    public boolean recaptchaVerified {public get; public set;}
    public string getRecaptchaPublicSecret() {
        return this.recaptchaPublicSecret;
    }    
    public integer getAddPharmListSize(){
        if(AddPharmList==null) return 0;
        else return AddPharmList.size();
    }
    //Question variables
    public List<C_Ops_SPLOA_Physicians__c> physicianSpecialitylist{get;set;}
    public List<C_Ops_SPLOA_Questions__c> Allquestions ;
    public List<C_Ops_SPLOA_Sub_Question__c> Allsubquestions ;
    private List<C_Ops_SPLOA_Questionnaire_Questions__c> questionnairelist;
    private List<C_Ops_SPLOA_Questionnaire_Questions__c > QuesquestionscorrReq ;
    private Map<String,C_Ops_SPLOA_Questionnaire_Questions__c > QuesquestionscorrReqMap;
    private Map<Id,List<C_Ops_SPLOA_Sub_Question__c>> pharmquessubquesMap;    
    //Product variables
    public Boolean productNamechanged {get;set;}
    public String SelectedProductName{get;set;}
    public String prodname{get;set;}
    public String searchKey{get;set;}
    private Boolean hasproductError;
    private List<C_Ops_SPLOA_Product__c> productslsts = new List<C_Ops_SPLOA_Product__c>();
    public C_Ops_SPLOA_Request__c mainRequest{get;set;}
    public Boolean showList { get; set; }
    public String errorMessage { get; set; }
   // public List<SelectOption> productslist { get; set; }
   public List<string> productslist { get; set; }
    public List<productquestionswrapper> productquestionswrapperlist{get;set;}
    public List<productquestionswrapper> productquestionswrapperlistbackup{get;set;}
    public Map<C_Ops_SPLOA_Questions__c,List<C_Ops_SPLOA_Sub_Question__c>> prodqueMap = new Map<C_Ops_SPLOA_Questions__c,List<C_Ops_SPLOA_Sub_Question__c>>();
    // Additional Pharmacy variables
    public list<C_Ops_SPLOA_Additional_Pharmacy__c> AddPharmList { get; set; }
    public C_Ops_SPLOA_Additional_Pharmacy__c PrimaryPharmacydetails { get; set; }
    public boolean makeSelectionNo{get;set;}
    public boolean makeYes{get;set;}
    public boolean makeNo{get;set;}
    public String selectedOption { get; set; }
    
    public Boolean addpharmacayOption { get; set; }
    private List<C_Ops_SPLOA_Additional_Pharmacy__c > AddPharmoldListcorrReq ;
    public C_Ops_SPLOA_Additional_Pharmacy__c currAddPharm{get;set;}
    public boolean isEditAddPharm {get;set;}
    public String requestToEdit{get;set;}   
    //APL variables
    public list<APL__c> APLlist{get;set;}
    public APL__c currAPL{get;set;}
    public String addAPListDisplay { set; }  
    public String addProdDisplay { set; }   
    //Correction variables
    public Id corrReqId{get;set;}
    //  public Boolean correctionReq{get;set;}
    public Boolean renewRequest{get;set;}
    public List<Access_Type_Calculation__c> accessTypeList{get;set;}    
    public Id mainRequestId;
    //public Boolean superexceededset {get;set;}
    public Boolean RequestDenial{ get; set; }    
    public String reqTyp { get; set; }
    public String updatereqTyp { get; set; }
    public C_Ops_SPLOA_Request__c oldcurrRequest = new C_Ops_SPLOA_Request__c();     
    public  Map<String,Id> mapofReqRecordTypeNameandId = new Map<String,Id>();    
    private ID requestId;
    public C_Ops_SPLOA_Request__c oldRequest {set; get;}
    //  private Boolean accesstypechanged;
    
    public Boolean showaddsitepage { get; set; } 
    public String Requestdetails { get; set; } 
    public String getAddAPListDisplay(){
        if( selectedOption!=null && selectedOption=='Yes') return 'block';
        else return 'none';
    }
    public String getaddProdDisplay(){
        // return 'block';
        if( mainRequest.Additional_Products__c) return 'block';
        else return 'none';
    }
    
    
    public PageReference cancelToHome() {
        PageReference nextPage;  
        
        if(reqTyp == 'update'){
            nextPage=Page.C_OPS_SPLOA_CORRECTION_PAGE;
        }
        else  
            nextPage=Page.C_OPS_IAP_Request_HomePage; 
        return nextPage;  
    }
    
    public PageReference resetRadioSelection() {
        selectedOption='Yes';
        return null;
    }    
    
    public PageReference clearAddPharmList() {
        selectedOption='No';
        AddPharmList.clear();
        return null;
    }
    
    public void setAddPharmListSize(integer i){
        addPharmListSize=i;
    }
    
    public PageReference addAnotherPharmacy() {
        requestToEdit='';
        errorMessage = '';
        Boolean haveError = false;
        if(haveError != true) {
            currAddPharm = new C_Ops_SPLOA_Additional_Pharmacy__c();
            if(AddPharmList== null){
                AddPharmList =  new list<C_Ops_SPLOA_Additional_Pharmacy__c>();
            }
            pharmpageaction(); 
            pageReference c_ops_iap_addpharm = new PageReference('/apex/C_OPS_IAP_ADDPHARM');
            c_ops_iap_addpharm.setRedirect(false);
            return c_ops_iap_addpharm ;
        }
        return null;
    }    
    
    public void handleError(string errorText){
        if(String.isBlank(errorText)){
            return;
        }
        ApexPages.Message[] curMsgs=ApexPages.getMessages();
        boolean notFind=true;
        if(curMsgs!=null && curMsgs.size()>=1){
            for (ApexPages.Message msg:curMsgs){
                if(msg!=null && (!String.isBlank(msg.getSummary())) && msg.getSummary().trim().equalsIgnoreCase(errorText.trim())){
                    notFind=false;
                    break;
                }
            }
        }
        
        if(notFind) {
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorText);
            ApexPages.addMessage(errorMsg);
        }
        
        return;
    }
    
    //********** Constructor    
    public C_OPS_IAP_CONTROLLER() {
        requestToEdit='';
        addpharmacayOption=false;
        GroupandAccessTypMap = new Map<String,String>();
        GeneContactName='';
        canSubmit=true;
        queryAllquestions();
        queryAllsubquestions();
        editProd  = false;
        makeSelectionNo=false;  
        addAPListDisplay='none';
        addProdDisplay='none';
        makeYes=false;
        makeNo=true;
        reqTyp = 'new';
        updatereqTyp='';
        // addprodOption='No';
        // correctionReq = false;
        renewRequest = false;
        //   queryAllquestions();
        //   queryAllsubquestions();
        Grp1pharmacyproducts = '';
        Grp2pharmacyproducts = '';
        Grp3pharmacyproducts = '';
        Grp4pharmacyproducts = '';
        Grp5pharmacyproducts = '';
        Grp6pharmacyproducts = '';
        Grp7pharmacyproducts = '';
        Grp8pharmacyproducts = '';
        Grp9pharmacyproducts = '';
        Grp10pharmacyproducts = '';
        Grp1quesproducts = '';
        Grp2quesproducts = '';
        Grp3quesproducts = '';
        Grp4quesproducts = '';
        Grp5quesproducts = '';
        Grp7quesproducts = '';
        Grp8quesproducts = '';
        Grp9quesproducts = '';
        Grp6quesproducts = '';
        Grp10quesproducts = '';
        boolean callphar=true;
        PrimaryPharmacydetails= new C_Ops_SPLOA_Additional_Pharmacy__c();
        IAP_Controller_internal internalsave= new IAP_Controller_internal();
        //  AllQuesNameandlabel = new Map<String,String>();
        List<productquestionswrapper> productquestionswrapperlist = new List<productquestionswrapper>();
        productquestionswrapperlistbackup= new List<productquestionswrapper>();
        DEAexceptionlist = [SELECT Name, Active__c , DEA_Number__c FROM C_Ops_IAPDEA_Number__c WHERE Active__c = true];
        
        businessrulslist = internalsave.getBusinessruleslist();
        
        accessTypeList = internalsave.getAccessTypes();
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('C_Ops_SPLOA_Request__c').getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
        Map<C_Ops_SPLOA_Questions__c,List<C_Ops_SPLOA_Sub_Question__c>> prodqueMap = new Map<C_Ops_SPLOA_Questions__c,List<C_Ops_SPLOA_Sub_Question__c>>();
        //       mapofReqRecordTypeNameandId = new Map<String,Id>();
        for(Schema.RecordTypeInfo info : recordTypeInfo){
            mapofReqRecordTypeNameandId.put(info.getName(),info.getRecordTypeId());
        }
        
        
        //Below handles the "Submit Another Request" functionality from Confirmation page
        requestId=ApexPages.currentPage().getParameters().get('id');
        List<C_Ops_SPLOA_Additional_Pharmacy__c > AddPharmoldList = new List<C_Ops_SPLOA_Additional_Pharmacy__c >();         
        if(requestId!=null) {
            selectedOption='No';//Signee_Extension__c,Signee_Phone__c,Signee_Email__c
            // oldRequest=[select id,Signing_Authority_Title__c,Signing_Authority_Last_Name__c,Signing_Authority_First_name__c,Genentech_Contact__c,Genentech_Contact__r.name,Same_Signing__c,Signee_Last_Name__c,Signee_First_Name__c,Signee_Extension__c,Signee_Phone__c,Signee_Email__c,Name,Request_PDF_Version_Number__c,C_Ops_SPLOA_First_Name__c,C_Ops_SPLOA_Last_Name__c,C_Ops_SPLOA_Phone__c,C_Ops_SPLOA_Extension__c,C_Ops_SPLOA_Fax__c,C_Ops_SPLOA_Pharmacy_Name__c,C_Ops_SPLOA_Email__c,C_Ops_SPLOA_Primary_Distributor__c,C_Ops_SPLOA_DEA_Number__c,C_Ops_SPLOA_Street_Address__c,C_Ops_SPLOA_Street_Address_2__c,C_Ops_SPLOA_City__c,State__c,C_Ops_SPLOA_Zip__c,Website_URL__c,C_Ops_SPLOA_Product_Name__c,C_Ops_SPLOA_Request_Status__c,SPLOA_Renewal__c from C_Ops_SPLOA_Request__c where id=:requestId];
            oldRequest=internalsave.getrequest( requestId);
            
            AddPharmoldList = internalsave.getadditionalphar(requestId);
            
            if(!AddPharmoldList.isEmpty()){
                selectedOption='Yes';
                
                if(AddPharmList== null){
                    AddPharmList =  new list<C_Ops_SPLOA_Additional_Pharmacy__c>();
                }
                for(C_Ops_SPLOA_Additional_Pharmacy__c oldPharm : AddPharmoldList ){
                    
                    if(!oldPharm.Is_Primary_Pharmacy__c){
                        C_Ops_SPLOA_Additional_Pharmacy__c copyPharm= new C_Ops_SPLOA_Additional_Pharmacy__c();
                        copyPharm.C_Ops_SPLOA_DEA_Number__c = oldPharm.C_Ops_SPLOA_DEA_Number__c;
                        copyPharm.Pharmacy_Name__c = oldPharm.Pharmacy_Name__c;
                        copyPharm.C_Ops_SPLOA_Street_Address__c = oldPharm.C_Ops_SPLOA_Street_Address__c;
                        copyPharm.C_Ops_SPLOA_Street_Address_2__c = oldPharm.C_Ops_SPLOA_Street_Address_2__c;
                        copyPharm.C_Ops_SPLOA_City__c = oldPharm.C_Ops_SPLOA_City__c;
                        copyPharm.C_Ops_SPLOA_State__c = oldPharm.C_Ops_SPLOA_State__c;
                        copyPharm.C_Ops_SPLOA_Zip__c = oldPharm.C_Ops_SPLOA_Zip__c;  
                        copyPharm.Accreditation__c = oldPharm.Accreditation__c;            
                        AddPharmList.add(copyPharm);
                    }else{
                        C_Ops_SPLOA_Additional_Pharmacy__c copyPharm= new C_Ops_SPLOA_Additional_Pharmacy__c();
                        copyPharm.C_Ops_SPLOA_DEA_Number__c = oldPharm.C_Ops_SPLOA_DEA_Number__c;
                        copyPharm.Pharmacy_Name__c = oldPharm.Pharmacy_Name__c;
                        copyPharm.C_Ops_SPLOA_Street_Address__c = oldPharm.C_Ops_SPLOA_Street_Address__c;
                        copyPharm.C_Ops_SPLOA_Street_Address_2__c = oldPharm.C_Ops_SPLOA_Street_Address_2__c;
                        copyPharm.C_Ops_SPLOA_City__c = oldPharm.C_Ops_SPLOA_City__c;
                        copyPharm.C_Ops_SPLOA_State__c = oldPharm.C_Ops_SPLOA_State__c;
                        copyPharm.C_Ops_SPLOA_Zip__c = oldPharm.C_Ops_SPLOA_Zip__c;  
                        copyPharm.Accreditation__c = oldPharm.Accreditation__c; 
                        PrimaryPharmacydetails=copyPharm;
                    }
                }
            }
        }        
        currAPL = new APL__c();
        mainRequest = new C_Ops_SPLOA_Request__c();
        if(mapofReqRecordTypeNameandId.get('New IAP Request') != null){mainRequest.RecordTypeId = mapofReqRecordTypeNameandId.get('New IAP Request');}
        if(oldRequest!=null){
            mainRequest.C_Ops_SPLOA_First_Name__c=oldRequest.C_Ops_SPLOA_First_Name__c;
            mainRequest.C_Ops_SPLOA_Last_Name__c=oldRequest.C_Ops_SPLOA_Last_Name__c;
            mainRequest.C_Ops_SPLOA_Phone__c=oldRequest.C_Ops_SPLOA_Phone__c;
            mainRequest.C_Ops_SPLOA_Extension__c=oldRequest.C_Ops_SPLOA_Extension__c;
            mainRequest.C_Ops_SPLOA_Fax__c=oldRequest.C_Ops_SPLOA_Fax__c;
            mainRequest.C_Ops_SPLOA_Email__c=oldRequest.C_Ops_SPLOA_Email__c;
            mainRequest.C_Ops_SPLOA_Primary_Distributor__c=oldRequest.C_Ops_SPLOA_Primary_Distributor__c;
            mainRequest.C_Ops_SPLOA_Pharmacy_Name__c=oldRequest.C_Ops_SPLOA_Pharmacy_Name__c;
            mainRequest.C_Ops_SPLOA_DEA_Number__c=oldRequest.C_Ops_SPLOA_DEA_Number__c;
            mainRequest.C_Ops_SPLOA_Street_Address__c=oldRequest.C_Ops_SPLOA_Street_Address__c;
            mainRequest.C_Ops_SPLOA_Street_Address_2__c=oldRequest.C_Ops_SPLOA_Street_Address_2__c;
            mainRequest.C_Ops_SPLOA_City__c=oldRequest.C_Ops_SPLOA_City__c;
            mainRequest.State__c=oldRequest.State__c;
            mainRequest.C_Ops_SPLOA_Zip__c=oldRequest.C_Ops_SPLOA_Zip__c;
            mainRequest.Website_URL__c=oldRequest.Website_URL__c;
            mainRequest.Signee_First_Name__c=oldRequest.Signee_First_Name__c;
            mainRequest.Signee_Last_Name__c=oldRequest.Signee_Last_Name__c;
            mainRequest.Signee_Email__c=oldRequest.Signee_Email__c;
            mainRequest.Signee_Phone__c=oldRequest.Signee_Phone__c;
            mainRequest.Signee_Extension__c=oldRequest.Signee_Extension__c;
            mainRequest.Same_Signing__c=oldRequest.Same_Signing__c; 
            mainRequest.Genentech_Contact__c=oldRequest.Genentech_Contact__c;    
            GeneContactName=oldRequest.Genentech_Contact__r.name;
            mainRequest.Signing_Authority_Title__c=oldRequest.Signing_Authority_Title__c;    
            mainRequest.Signing_Authority_Last_Name__c=oldRequest.Signing_Authority_Last_Name__c;    
            mainRequest.Signing_Authority_First_name__c=oldRequest.Signing_Authority_First_name__c;
            mainRequest.Additional_Products__c=oldRequest.Additional_Products__c;
            mainRequest.SPLOA_Renewal__c=oldRequest.SPLOA_Renewal__c;  
            
            //Signing_Authority_Title__c,Signing_Authority_Last_Name__c,Signing_Authority_First_name__c,
            mainRequest.Request_Type__c = getRequestType();
        }        
        
        RequestDenial = false;
        productNamechanged = false;
        if(System.Label.IAP_Capcha =='false'){
            this.recaptchaVerified = false;
        }else{
            this.recaptchaVerified = true;
        }
        
        hasproductError= false;
        
        productslsts = [
            SELECT Name , APL__c , Group__c,Access_Type__c FROM C_Ops_SPLOA_Product__c
            WHERE C_Ops_SPLOA_Active__c =  True AND C_Ops_SPLOA_Effective_Date__c <= TODAY];
        
        for(C_Ops_SPLOA_Product__c prod:productslsts ){
            ProductnameandAPL.put(prod.Name.touppercase(), prod.APL__c);
            ProductnameandAPL.put(prod.APL__c.touppercase(), prod.APL__c);
            ProductnameandGroupName.put(prod.Name.touppercase(), prod.Group__c);
            ProductnameandGroupName.put(prod.APL__c.touppercase(), prod.Group__c);
            APLandGroupMap.put(prod.APL__c,prod.Group__c);
            APLtoAccessmap.put(prod.Name.touppercase(),prod.Access_Type__c);
            APLtoAccessmap.put(prod.APL__c.touppercase(),prod.Access_Type__c);
        }
        
        //  physicianSpecialitylist =[SELECT Name FROM C_Ops_SPLOA_Physicians__c];
        
        prop = [SELECT ID, GSiteKey__c, GSecurityKey__c, GSite__c,Active__c FROM C_Ops_Captcha_Property__c WHERE Active__c=true LIMIT 1];        
        recaptchaPublicSecret = prop.GSiteKey__c;
        recaptchaPrivateSecret = prop.GSecurityKey__c;
        baseUrl=prop.GSite__c;
        mainRequestId=null;
        //   accesstypechanged = false;
        
        corrReqId = ApexPages.currentPage().getParameters().get('corrid');
        reqTyp = ApexPages.currentPage().getParameters().get('reqTyp');
        String requestType = ApexPages.CurrentPage().getparameters().get('requestType');
        Requestdetails=requestType;
        if(string.isBlank(Requestdetails))
            Requestdetails='New Request';
        
        if(string.isBlank(reqTyp)){reqTyp = 'new';}
        system.debug('-->'+reqTyp);
        existingQuestions = new  List<C_Ops_SPLOA_Questionnaire_Questions__c>();
        if(reqTyp == 'update'){
            if(corrReqId != null){
                List<C_Ops_SPLOA_Additional_Pharmacy__c > AddPharmoldList2 = new List<C_Ops_SPLOA_Additional_Pharmacy__c >();         
                if(corrReqId!=null) {
                    selectedOption='No';
                    existingQuestions= internalsave.getexistingQuestions( corrReqId);
                    oldRequest=internalsave.getrequest( corrReqId);
                    AddPharmoldList2 = internalsave.getadditionalphar(corrReqId); 
                    //[select name, C_Ops_SPLOA_DEA_Number__c,Pharmacy_Name__c,C_Ops_SPLOA_Street_Address__c,C_Ops_SPLOA_Street_Address_2__c,C_Ops_SPLOA_City__c,C_Ops_SPLOA_State__c,C_Ops_SPLOA_Zip__c,C_Ops_SPLOA_Request__c from C_Ops_SPLOA_Additional_Pharmacy__c where C_Ops_SPLOA_Request__c =:corrReqId];
                    if(!AddPharmoldList2.isEmpty()){
                        if(AddPharmoldList2.size()>1){
                            selectedOption='Yes';
                            addpharmacayOption=true;
                        }
                        if(AddPharmList== null){
                            AddPharmList =  new list<C_Ops_SPLOA_Additional_Pharmacy__c>();
                        }
                        for(C_Ops_SPLOA_Additional_Pharmacy__c oldPharm : AddPharmoldList2 ){
                            if(!oldPharm.Is_Primary_Pharmacy__c){
                                C_Ops_SPLOA_Additional_Pharmacy__c copyPharm= new C_Ops_SPLOA_Additional_Pharmacy__c();                           
                                copyPharm = oldPharm.clone(true, true, false, false);
                                AddPharmList.add(copyPharm);
                            }else{
                                PrimaryPharmacydetails= oldPharm.clone(true, true, false, false);
                            }
                        }
                    }
                }        
                currAPL = new APL__c();
                mainRequest = new C_Ops_SPLOA_Request__c();
                if(mapofReqRecordTypeNameandId.get('New IAP Request') != null){mainRequest.RecordTypeId = mapofReqRecordTypeNameandId.get('New IAP Request');}
                if(oldRequest!=null){                   
                    mainRequest  = oldRequest.clone(false,true);
                    GeneContactName=oldRequest.Genentech_Contact__r.name;
                }    
                ProductName=mainRequest.APLs_on_the_Request__c;
                 if(mainRequest.SPLOA_Renewal__c)
                businessrulslist= new List<Business_Rule__c>();
                if( string.isnotblank(ProductName)){
                    if(ProductName.contains(';')){
                        list<string> productnames = new list<string>();
                        productnames.addall(ProductName.split(';',-1));
                        integer i=1;
                        pharmpageaction2(); 
                        callphar=false;  
                        for(string pro:productnames){
                            ProductName=pro;                        
                            findProducts();
                            commitAddProd();
                            if(i != productnames.size())
                                navtoProductPage();
                            i++;
                        }
                        // addprodOption='Yes';
                    }else{
                        findProducts();
                        pharmpageaction2(); 
                        commitAddProd();
                        callphar=false;   
                    }
                    
                }
            }
            if(AddPharmList == null || AddPharmList.size() == 0){selectedOption ='No';}
            if(oldRequest.Request_Type__c == 'Add Location'){
                updatereqTyp = 'addSite';            
            }
        }
        else if(RequestType == 'Renewal') {
            businessrulslist= new List<Business_Rule__c>();
            reqTyp = 'renew';
            renewRequest=true;
            //  populatedataforupdate();
            if((AddPharmList == null || AddPharmList.size() == 0) && corrReqId!= null){selectedOption ='No';}
            if(corrReqId == null){
                mainRequest.Request_Type__c = getRequestType();
            }
        }
        else if( RequestType == 'Add Product'){
            reqTyp = 'addProd';
            if(corrReqId == null){
                mainRequest.Request_Type__c = getRequestType();
            }
        }
        else if( RequestType == 'Add Location'){
            reqTyp = 'addSite';
            selectedOption ='Yes';
            mainRequest.Request_Type__c = getRequestType();
        }
        
        if(string.isBlank( mainRequest.Request_Type__c))
            mainRequest.Request_Type__c = getRequestType();
        
        if(reqTyp == 'addSite'){addpharmacayOption = true;}else{//addpharmacayOption = false;
        }   
        if(callphar)
            pharmpageaction2(); 
    }    
    //********************************** End of Constructor
    //****************** Methods related to Product Page
    //To check whether entered string is valid
    public void verifyValidProduct(){
        system.debug('Inside verifyValidProduct');
        prodmessage = '';
        boolean findit=false;
        if( prdqueswrapper.apl.C_Ops_SPLOA_Product_Name__c != null){
            prdqueswrapper.apl.C_Ops_SPLOA_Product_Name__c = prdqueswrapper.apl.C_Ops_SPLOA_Product_Name__c.trim();
            for(C_Ops_SPLOA_Product__c prod:productslsts ){
                String prodName = prod.Name; 
                if (prdqueswrapper.apl.C_Ops_SPLOA_Product_Name__c.equalsIgnoreCase(prodName )) {
                    findit=true;  
                    break;
                }        
            }
        }
        if(!findit) {
            errorMessage = 'Please add Product before submiting the Request';
            handleError(errorMessage);
        }        
    }
    
    //Method to handle multi product list
    public void UpdateselectedProduct(){
        if(currAPL.C_Ops_SPLOA_Product_Name__c == 'None'){
            currAPL.C_Ops_SPLOA_Product_Name__c = '';
            showList = false;
        }
    }
    
    public List<PRP_BEM__c> GeneContactresults{get;set;}   
    
    public void findGeneContact(){
        system.debug('Inside findGeneContact');       
        errorMessage = '';
        prodmessage = '';        
        if(String.isNotBlank(GeneContactName)) 
            GeneContactName = GeneContactName.trim();      
        
        if(String.isNotBlank(GeneContactName) && GeneContactName.trim().length() >= 3 ){
            IAP_Controller_internal internalsave= new IAP_Controller_internal();
            GeneContactresults=internalsave.performSearch(GeneContactName);   
            if(GeneContactresults.size()== 0 && GeneContactName !='None'){                                
                errorMessage = 'No Contact Found';
                handleError(errorMessage);
            }else if(GeneContactresults.size()== 1) {
                GeneContactName= GeneContactresults[0].name;
                mainRequest.Genentech_Contact__c= GeneContactresults[0].id;
            }          
        }
    }
    public PageReference cancelAddGenetechContact() {
        GeneContactid=GeneContactidbackup;
        system.debug(GeneContactid);
        findGeneContactbyid();
        system.debug(GeneContactName);
        errorMessage = null;        
        pageReference c_ops_iap_contact_infopg = new PageReference('/apex/C_OPS_IAP_CONTACT_INFOPG');
        c_ops_iap_contact_infopg.setRedirect(false);
        return c_ops_iap_contact_infopg ;
    }
    
    public void findGeneContactbyid(){
        system.debug('Inside findGeneContact');       
        errorMessage = '';
        prodmessage = '';        
        if(String.isNotBlank(GeneContactid)) 
            GeneContactid = GeneContactid.trim();      
        
        if(String.isNotBlank(GeneContactid) && GeneContactid.trim().length() >= 3 ){
            try{
                IAP_Controller_internal internalsave= new IAP_Controller_internal();
                GeneContactresults=internalsave.performSearchbyif(GeneContactid);   
            }catch(exception ex){
                system.debug('--->'+ex);
            }
            if(GeneContactresults.size()== 0 && GeneContactName !='None'){                                
                errorMessage = 'No Contact Found';
                handleError(errorMessage);
            }else if(GeneContactresults.size()== 1) {
                GeneContactName= GeneContactresults[0].name;
                mainRequest.Genentech_Contact__c= GeneContactresults[0].id;
            }          
        }else{
            GeneContactName= '';
        }
    }
    
    //Save the Product and its details
    public PageReference  commitAddGeneContact() {
        if(string.isBlank(GeneContactName)) {           
            mainRequest.Genentech_Contact__c=null;
            // errorMessage = 'No Contact Found';
            //handleError(errorMessage);
            // return null;
        }else{       
            if(GeneContactresults.size()== 1) {
                if(GeneContactName != GeneContactresults[0].name)
                    GeneContactName= GeneContactresults[0].name;
                mainRequest.Genentech_Contact__c= GeneContactresults[0].id;
            } else{
                errorMessage = 'No Contact selected';
                handleError(errorMessage);
                return null;
            }    
        } 
        pageReference c_ops_iap_contact_infopg = new PageReference('/apex/C_OPS_IAP_CONTACT_INFOPG');
        c_ops_iap_contact_infopg.setRedirect(false);
        return c_ops_iap_contact_infopg ;  
    }    
    public void findProducts(){
        system.debug('Inside findProducts');
      
        errorMessage = '';
        prodmessage = '';
        
        APL__c apl = new APL__c();
        List<C_Ops_SPLOA_Product__c> prdNameOptions= new  List<C_Ops_SPLOA_Product__c>();
        
        prdqueswrapper = new productquestionswrapper(apl, null,1,null);
        if(String.isNotBlank(ProductName)) 
            ProductName = ProductName.trim();
        searchKey = ProductName;
        SelectedProductName=ProductName;
        system.debug(searchKey);
      
        showList = false;
        
        if(String.isNotBlank(searchKey) && searchKey.trim().length() >= 3 ){
            for(C_Ops_SPLOA_Product__c prod:productslsts ){
                    String prodName = prod.Name; 
                    if (prodName == searchKey){
                    prdNameOptions.add(prod);
                    showList = false;
                    break;
                    
                }
            }
            if(prdNameOptions.size() == 0 )
            for(C_Ops_SPLOA_Product__c prod:productslsts ){
                String prodName = prod.Name; 
                if ( (prodName == searchKey) || (prodName.startsWithIgnoreCase(searchKey) || prod.APL__c.startsWithIgnoreCase(searchKey) )) {
                    prdNameOptions.add(prod);
                }  
            }
            
            if(prdNameOptions!= null ){
                if(prdNameOptions.size() == 0 && searchKey!='None'){
                    hasproductError = true;
                    errorMessage = 'The Product you entered is not a Genentech Product, please confirm the product name on the prescription.';
                    handleError(errorMessage);
                }
                else{
                    
                    hasproductError = false;
                    system.debug('prdNameOptions-->'+prdNameOptions);
                    if(prdNameOptions.size() == 1){
                        SelectedProductName =prdNameOptions[0].Name;
                        ProductName = SelectedProductName ;
                        showList = false;
                    }
                    else{
                        showList = true;
                      /* productslist = new List<SelectOption>();
                        productslist.add(new SelectOption('Select one','Select one'));
                        for(C_Ops_SPLOA_Product__c prod : prdNameOptions){
                            productslist.add(new SelectOption(prod.Name,prod.Name));
                        }
                        productslist.add(new SelectOption('None','Enter Other Genentech Product'));
                        */
                        productslist = new List<string>();
                      //  productslist.add(new SelectOption('Select one','Select one'));
                        for(C_Ops_SPLOA_Product__c prod : prdNameOptions){
                            productslist.add(prod.Name);
                        }
                      //  productslist.add(new SelectOption('None','Enter Other Genentech Product'));
                    
                    }
                    verifydupeProduct();
                    //Added logic to populate question related to Product
                    if(hasproductError != true){ getallProductquestions();  }              
                }
            }            
        }
        //  UpdateselectedProduct();
    }    
    public String getRequestType(){
        String requestType = ApexPages.CurrentPage().getparameters().get('requestType');
        return requestType;
    }
    public PageReference navtoProductPage() {
        showList = false;
        productslist = new List<string>();
        errorMessage = null;
        if(productquestionswrapperlist != null){
            productquestionswrapperlistbackup=productquestionswrapperlist;
            productquestionswrapperlist = new  List<productquestionswrapper>();
        }
        PageReference C_OPS_IAP_ADDPRODUCT = New PageReference('/apex/C_OPS_IAP_ADDPRODUCT');
        C_OPS_IAP_ADDPRODUCT.setRedirect(false);
        return C_OPS_IAP_ADDPRODUCT ;
    }
    public PageReference navtoGeneContactPage() {
        GeneContactidbackup= mainRequest.Genentech_Contact__c;
        
        PageReference C_OPS_IAP_ADDGeneContact = New PageReference('/apex/C_OPS_IAP_ADDGenetechContact');
        C_OPS_IAP_ADDGeneContact.setRedirect(false);
        return C_OPS_IAP_ADDGeneContact ;
    }
    public void resetPharmacyandQuesWrpfornewProd(){
        RequestDenial  = false;
        //  if(pharmqueswrapperlist != null && pharmqueswrapperlist.size()>0){pharmqueswrapperlist =new List<pharmacyquestionswrapper>();}
        if(quesquestionswrapperlist!= null && quesquestionswrapperlist.size()>0){quesquestionswrapperlist=new List<quesquestionswrapper>();} 
    }    
    public void updatefielddynamically(string fieldname,string fieldvalue){
        sobject temobj=(sobject)mainRequest;
        if(fieldname!='Accreditation__c'){            
            temobj.put(fieldname,fieldvalue);
            
        }else{
            string stetempacce=(string)temobj.get(fieldname);
            set<string> options2=new set<string>();
            if(string.isnotblank(stetempacce)){
                options2.addall(stetempacce.split(';'));
            }
            options2.addall(fieldvalue.split(';'));
            temobj.put(fieldname,string.join(new list<string>(options2),';')); 
        }
        mainRequest=(C_Ops_SPLOA_Request__c)temobj;
    }
    public PageReference  commitAddProdandnew() {
        PageReference redi=commitAddProd();
        if(redi != null ){
            //   addprodOption='Yes';
            //   mainRequest.Additional_Products__c=true;
            return navtoProductPage();
        }else{
            return redi;
        }
        
    }
    
    //Save the Product and its details
    public PageReference  commitAddProd() {
        refreshquestion= true;
        system.debug('hasproductError '+hasproductError );
        if(hasproductError != true){
            system.debug('ErrorMEssage'+ErrorMessage);
            Boolean haveError = false;  
            APL__c apl = new APL__C();    
            mainRequest.Accreditation__c='';
            List<String> grouplist  = new List<String>();  
            if(productquestionswrapperlist == null )
                productquestionswrapperlist = new  List<productquestionswrapper>();
            // assignAccesTypeafterproduct();            
            for(productquestionswrapper prodquemwrap  : productquestionswrapperlist){   
                string str='';
                for(SelectOption opt:prodquemwrap.selectlistOption){                    
                    str=str+opt.getValue()+';';
                }
                if(string.isnotblank(str))
                    str = str.removeEnd(';');
                if( prodquemwrap.prodQues.C_Ops_SPLOA_Data_Type__c=='MultiPicklist'){
                    prodquemwrap.prodQues.Answer__c=str;
                }
                if(string.isBlank(prodquemwrap.prodQues.Answer__c)){
                    haveError = true;
                    errorMessage = 'Please answer all questions';
                    handleError(errorMessage);
                    // system.debug(' haveError 525'+haveError);
                }
                if(prodquemwrap.subqueslist != null && prodquemwrap.prodQues.Answer__c == 'Yes' ){
                    for(C_Ops_SPLOA_Sub_Question__c subques: prodquemwrap.subqueslist ){
                        /* system.debug('Parent Prod Que:'+subques.Question_Label__c);
system.debug('Parent Prod Ans:'+prodquemwrap.prodQues.Answer__c);
system.debug('C_Ops_SPLOA_Data_Type__c:'+subques.C_Ops_SPLOA_Data_Type__c);
system.debug('Sub Que Ans:'+subques.Answer__c);*/
                        if( subques.C_Ops_SPLOA_Data_Type__c=='MultiPicklist' && prodquemwrap.prodQues.IDbackup__c == subques.Parent_Question__c){
                            subques.Answer__c=str;
                        }
                        if(string.isBlank(subques.Answer__c) && !subques.Date_has_not_been_scheduled__c && string.isBlank(string.valueof(subques.Date_Input__c)) && prodquemwrap.prodQues.IDbackup__c == subques.Parent_Question__c){                             
                            haveError = true;
                            errorMessage = 'Please answer all questions';
                            handleError(errorMessage);
                            system.debug(' haveError 545'+haveError);
                        }
                        if(string.isBlank(subques.Answer__c) && !string.isBlank(string.valueof(subques.Date_Input__c))){
                            subques.Answer__c=string.valueof(subques.Date_Input__c);
                        }                       
                    }
                }
            }
            system.debug('535 haveError::'+haveError);
            system.debug('before Business_Rule');
            for(Business_Rule__c br : businessrulslist ){
                
                for(productquestionswrapper prodquemwrap  : productquestionswrapperlist){     
                  /*  prodquemwrap.apl.Request_Status__c = '';
                    prodquemwrap.apl.Denial_Reason_Code__c = '' ; 
                    prodquemwrap.apl.Denied_for_which_Question_Type__c = '';*/
                    system.debug('Denied -->'+prodquemwrap);          
                    if(prodquemwrap.prodQues.Answer__c != null)
                        if(br.C_Ops_IAP_Questions_List__r.C_Ops_SPLOA_Question_Label__c == prodquemwrap.prodQues.C_Ops_SPLOA_Question_Label__c ||
                           br.C_Ops_IAP_Sub_Questions__r.Question_Label__c  == prodquemwrap.prodQues.C_Ops_SPLOA_Question_Label__c){
                               String QuesGroup = br.Group__c;
                               grouplist = QuesGroup.split(';');
                               String GroupName = ProductnameandGroupName.get(ProductName.touppercase());
                               
                               if( grouplist!= null && grouplist.size() >0 && grouplist.contains(GroupName ) && br.Value_for_Outcome__c == prodquemwrap.prodQues.Answer__c ){    
                                   prodquemwrap.apl.Request_Status__c = 'Denied';
                                   prodquemwrap.apl.Denial_Reason_Code__c = br.Denial_Reason_Code__c ; 
                                   prodquemwrap.apl.Denied_for_which_Question_Type__c = 'Product Question';
                                   system.debug('Denied -->'+prodquemwrap);
                               }
                           }
                }
            }            
            // resetPharmacyandQuesWrpfornewProd();
            //Navigation based on Error
            if(haveError == false){
                productquestionswrapperlist.addall(productquestionswrapperlistbackup);
                set<productquestionswrapper> productquestionswrapperset = new  set<productquestionswrapper>();
                productquestionswrapperset.addall(productquestionswrapperlist);
                productquestionswrapperlist = new  List<productquestionswrapper>();
                productquestionswrapperlist.addall(productquestionswrapperset);
                productquestionswrapperset = new  set<productquestionswrapper>();			
                productquestionswrapperlistbackup = new  List<productquestionswrapper>();
                //Add an entry to wrapper list - If its a new Product
                for(productquestionswrapper prodquemwrap  : productquestionswrapperlist){ 
                    if(prodquemwrap.subqueslist != null && prodquemwrap.prodQues.Answer__c == 'Yes' ){
                        for(C_Ops_SPLOA_Sub_Question__c subques: prodquemwrap.subqueslist ){                          
                            if(string.isnotblank(subques.Field_To_Copy__c) && prodquemwrap.prodQues.IDbackup__c == subques.Parent_Question__c)
                                updatefielddynamically(subques.Field_To_Copy__c,subques.Answer__c);
                        }
                    }
                }
                if(editProd != true ){                    
                }
                //Update existing product
                if(editProd  == true){
                    productNamechanged = true;                    
                }        
                
                //Reset all flags
                ProductName =''; 
                // prodQuestion = new C_Ops_SPLOA_Questions__c();
                //  prodsubqueslist = new List<C_Ops_SPLOA_Sub_Question__c>();
                apl = new APL__C();
                prodmessage = '';
                productToEdit = '';
                editProd  = false;
                prdqueswrapper = new productquestionswrapper(apl, null,1,null);
                CurrAPL = new APL__c();
                // assignAccesTypeafterproduct();
                pageReference c_ops_iap_contact_infopg = new PageReference('/apex/C_OPS_IAP_CONTACT_INFOPG');
                c_ops_iap_contact_infopg.setRedirect(false);
                errorMessage = null;
                return c_ops_iap_contact_infopg ;
            }
            haveError = false;
            productNamechanged = false;
        }
        refreshquestion= true;
        
        return null;
    }    
    
    public void assignAccesTypeafterproduct() {
        GroupandAccessTypMap = new Map<String,String>();
        system.debug('Assigning the Access Type');
        if(productquestionswrapperlist== null){
            productquestionswrapperlist = new  List<productquestionswrapper>();
        }
        
        if(pharmqueswrapperlist == null ){pharmqueswrapperlist =new List<pharmacyquestionswrapper>();}
        
        Boolean firstquesmatched = false;
        Map<String,String> grpPharmanswers = new Map<String,String>();
        
        string firstquestion='No',secondquestion='No',thirdquestion='No';
        String prodGroupName = '';
        String uniprodGroupName = '';
        
        for(Access_Type_Calculation__c accTyp : accessTypeList){
            map<string,string> questionandans= new map<string,string>();
            map<string,integer> questionandmatched= new map<string,integer>();
            if(string.isNotBlank(accTyp.Question1__r.C_Ops_SPLOA_Question_Label__c))
                questionandans.put(accTyp.Question1__r.C_Ops_SPLOA_Question_Label__c,accTyp.Question1_Response__c);
            if(string.isNotBlank(accTyp.Question2__r.C_Ops_SPLOA_Question_Label__c))
                questionandans.put(accTyp.Question2__r.C_Ops_SPLOA_Question_Label__c,accTyp.Question2_Response__c);
            if(string.isNotBlank(accTyp.Question3__r.C_Ops_SPLOA_Question_Label__c))
                questionandans.put(accTyp.Question3__r.C_Ops_SPLOA_Question_Label__c,accTyp.Question3_Response__c);
            if(string.isNotBlank(accTyp.Question4__r.C_Ops_SPLOA_Question_Label__c))
                questionandans.put(accTyp.Question4__r.C_Ops_SPLOA_Question_Label__c,accTyp.Question4_Response__c);
            if(string.isNotBlank(accTyp.Question5__r.C_Ops_SPLOA_Question_Label__c))
                questionandans.put(accTyp.Question5__r.C_Ops_SPLOA_Question_Label__c,accTyp.Question5_Response__c);
            integer countmatched =0;
            System.debug(accTyp.Name);
            // System.debug(accTyp);
            for(  productquestionswrapper pharmwrap  : productquestionswrapperlist){  
                prodGroupName=ProductnameandGroupName.get(pharmwrap.apl.C_Ops_SPLOA_Product_Name__c.touppercase());
                uniprodGroupName=prodGroupName+'#'+pharmwrap.apl.C_Ops_SPLOA_Product_Name__c.touppercase();
                String accTypgroup = accTyp.APL_Group__c;
                if( accTypgroup.contains(prodGroupName)){
                    if(!questionandmatched.containskey(uniprodGroupName)){
                        questionandmatched.put(uniprodGroupName,0);
                    }
                    if(questionandans.containskey(pharmwrap.prodQues.C_Ops_SPLOA_Question_Label__c)){
                        string valueourcome= questionandans.get(pharmwrap.prodQues.C_Ops_SPLOA_Question_Label__c);
                        if(pharmwrap.prodQues.Answer__c == valueourcome){
                            countmatched++;
                            integer tempint=questionandmatched.get(uniprodGroupName);
                            questionandmatched.put(uniprodGroupName,++tempint);
                            System.debug(questionandmatched);
                            System.debug(pharmwrap.prodQues.C_Ops_SPLOA_Question_Label__c+valueourcome);
                        }
                    }
                }
            }
            integer first =0,second=0;
            string outcomephar='';
            for( pharmacyquestionswrapper prodquemwrap:pharmqueswrapperlist){ 
                if(questionandans.containskey(prodquemwrap.Pharmques.C_Ops_SPLOA_Question_Label__c)){
                    string valueourcome= questionandans.get(prodquemwrap.Pharmques.C_Ops_SPLOA_Question_Label__c);
                    first++;
                    if(prodquemwrap.Pharmques.Answer__c == valueourcome){
                        // countmatched++;
                        outcomephar=valueourcome;
                        second++;
                    }
                }                
            }
            
            if(string.isnotBlank(outcomephar)){
                if(outcomephar.equalsIgnoreCase('yes')){
                    countmatched++;
                    for(string grpname:questionandmatched.keyset()){
                        integer tempint=questionandmatched.get(grpname);
                        questionandmatched.put(grpname,++tempint);
                    }
                }else{
                    if(first == second && first>0){
                        countmatched++;
                        for(string grpname:questionandmatched.keyset()){
                            integer tempint=questionandmatched.get(grpname);
                            questionandmatched.put(grpname,++tempint);
                        }
                    }
                }
            }
            for(string grpname:questionandmatched.keyset()){
                integer tempint=questionandmatched.get(grpname);
                
                if(tempint == questionandans.size() || tempint > questionandans.size() ){
                    list<string> splitchange =grpname.split('#', -2);
                    if(splitchange.size()>0)
                        GroupandAccessTypMap.put(splitchange[0],accTyp.Name);
                }
                // System.debug(accTyp);
                system.debug(grpname+'-->'+tempint+'-->'+questionandans.size()+'-->'+GroupandAccessTypMap );
            }
        }
        for(productquestionswrapper wrp:productquestionswrapperlist){
            wrp.apl.Customer_Access_Type__c = '';
            if(wrp.apl.Request_Status__c != 'Denied')
                wrp.apl.Request_Status__c ='';
        }
        //Assign Access Type to APL
        for(productquestionswrapper wrp:productquestionswrapperlist){
            String GroupName = ProductnameandGroupName.get(wrp.apl.C_Ops_SPLOA_Product_Name__c.touppercase());
            
            if(GroupName!= null ){          
                wrp.apl.Customer_Access_Type__c ='Not Identified';  
                string custyprew=   GroupandAccessTypMap.get(GroupName);
                if(string.isnotBlank(custyprew) ){
                    wrp.apl.Customer_Access_Type__c = GroupandAccessTypMap.get(GroupName);
                }
                system.debug('wrp.apl.Customer_Access_Type__c'+wrp.apl.Customer_Access_Type__c);
                if( GroupandAccessTypMap.get(GroupName)!= null && wrp.apl.Request_Status__c != 'Denied'){
                    wrp.apl.Customer_Access_Type__c = GroupandAccessTypMap.get(GroupName);
                    wrp.apl.Request_Status__c ='New';
                    string tempaccestype=APLtoAccessmap.get(wrp.apl.C_Ops_SPLOA_Product_Name__c.touppercase());
                    if(string.isNotBlank(tempaccestype) ){
                        List<String> grouplist  = new List<String>();    
                        grouplist = tempaccestype.split(';');
                        if( !grouplist.contains(wrp.apl.Customer_Access_Type__c )) {
                            wrp.apl.Request_Status__c ='Denied';
                            wrp.apl.Denial_Reason_Code__c = 'SP Network Closed' ; 
                        }
                    }
                }
            }
        }
        system.debug('Group and Access Type Map'+GroupandAccessTypMap);
        if(GroupandAccessTypMapbackup != GroupandAccessTypMap){
            system.debug('modified Group and Access Type Map'+GroupandAccessTypMapbackup);
            refreshquestion=true;
        }
        GroupandAccessTypMapbackup = GroupandAccessTypMap;
    }
    
    
    public PageReference cancelAddProd() {
        errorMessage = null;
        if(productquestionswrapperlistbackup != null && editProd != true ){
            system.debug('no edit product ');
            productquestionswrapperlist=productquestionswrapperlistbackup;
            productquestionswrapperlistbackup = new  List<productquestionswrapper>();
        }
        if( editProd == true ){
            system.debug('edit product ');
            productquestionswrapperlist = new  List<productquestionswrapper>();
            productquestionswrapperlist.addall(productquestionswrapperlistbackup);
            productquestionswrapperlistbackup = new  List<productquestionswrapper>();
        }
        //Reset all flags
        ProductName =''; 
        // prodQuestion = new C_Ops_SPLOA_Questions__c();
        //  prodsubqueslist = new List<C_Ops_SPLOA_Sub_Question__c>();
        APL__c  apl = new APL__C();
        prodmessage = '';
        productToEdit = '';
        editProd  = false;
        prdqueswrapper = new productquestionswrapper(apl, null,1,null);
        CurrAPL = new APL__c();
        pageReference c_ops_iap_contact_infopg = new PageReference('/apex/C_OPS_IAP_CONTACT_INFOPG');
        c_ops_iap_contact_infopg.setRedirect(false);
        return c_ops_iap_contact_infopg ;
    }
    //Remove the product from list
    public PageReference removeProd() {
        String productToRemove = Apexpages.currentpage().getParameters().get('removeprodIndex');
        List<productquestionswrapper> replacementprodlist = new List<productquestionswrapper>();
        for(productquestionswrapper r: productquestionswrapperList){            
            if(r.apl.C_Ops_SPLOA_Product_Name__c != productToRemove ){                
                replacementprodlist.add(r);
            }
        }
        productquestionswrapperList = replacementprodlist;
        if(quesquestionswrapperlist != null && quesquestionswrapperlist.size()>0){
        String groupToRemove='';
        if(Grprelatedprod != null && Grprelatedprod.size() >0){   
            for(string grpnumber:Grprelatedprod.keyset()){
                system.System.debug(Grprelatedprod.get(grpnumber)+'--->'+productToRemove);
                if(Grprelatedprod.get(grpnumber).contains(productToRemove))
                groupToRemove=grpnumber;
            }
        }
        List<quesquestionswrapper> replacementqueslist = new List<quesquestionswrapper>();
        for(quesquestionswrapper r: quesquestionswrapperlist){            
            if(r.Grp != groupToRemove ){                
                replacementqueslist.add(r);
            }
        }
        quesquestionswrapperlist = replacementqueslist;
        }
        return null;
    }
    
    //Prepopulate for editing an added Product
    public PageReference editProd() {
        editProd  = true;
        resetProductchange();
        productToEdit = Apexpages.currentpage().getParameters().get('editprodIndex');
        productquestionswrapperlistbackup = new  List<productquestionswrapper>();
        productquestionswrapperlistbackup.addall(productquestionswrapperlist);
        productquestionswrapperlist = new  List<productquestionswrapper>();
        for(productquestionswrapper r: productquestionswrapperlistbackup){                      
            if(r.apl.C_Ops_SPLOA_Product_Name__c == productToEdit ){
                ProductName = r.apl.C_Ops_SPLOA_Product_Name__c ;
                currAPL.C_Ops_SPLOA_Product_Name__c = r.apl.C_Ops_SPLOA_Product_Name__c ;
                currAPL.Product__c = r.apl.Product__c;
                currAPL.Name =  r.apl.Name;
                prdqueswrapper.Prodques = r.Prodques;
                prdqueswrapper.subqueslist = r.subqueslist;
                r.apl.Request_Status__c = '';
                r.apl.Denial_Reason_Code__c = '';
                for(C_Ops_SPLOA_Sub_Question__c q:   prdqueswrapper.subqueslist){
                    if(q.Answer__c == 'Not Scheduled' && q.C_Ops_SPLOA_Data_Type__c == 'Date'){q.Date_has_not_been_scheduled__c = true;}
                    if(q.Answer__c != 'Not Scheduled' && q.C_Ops_SPLOA_Data_Type__c == 'Date'){
                        if(string.isNotBlank(q.Answer__c)) 
                            q.Date_Input__c= Date.valueOf(q.Answer__c);}
                    prodmessage ='As you have requested for <strong>'+ r.apl.C_Ops_SPLOA_Product_Name__c + '</strong>, you will get access to these products as well (provided all criteria are met) : <strong>'+r.apl.Product__c+ '</strong>' ;
                    
                }
                productquestionswrapperlist.add(r);
            }
        }
        
        pageReference c_ops_iap_addprod = new PageReference('/apex/C_OPS_IAP_ADDPRODUCT');
        c_ops_iap_addprod.setRedirect(false);
        return c_ops_iap_addprod ;
    }
    
    
    //Clear the flags when Product Name is changed
    public void resetProductchange(){
        RequestDenial  = false;
        //   if(pharmqueswrapperlist != null && pharmqueswrapperlist.size()>0){pharmqueswrapperlist =new List<pharmacyquestionswrapper>();}
        //   if(quesquestionswrapperlist!= null && quesquestionswrapperlist.size()>0){quesquestionswrapperlist=new List<quesquestionswrapper>();}  
    }
    
    //Verify if entered Product is duplicate
    public void verifydupeProduct(){
        hasproductError = false;
        if(productquestionswrapperlist != null && productquestionswrapperlist.size()>0){
            for(productquestionswrapper prdwrp : productquestionswrapperlist ){
                if(ProductnameandAPL.get(SelectedProductName.touppercase() ) == ProductnameandAPL.get(prdwrp.apl.C_Ops_SPLOA_Product_Name__c.touppercase() )){
                    hasproductError = true;
                    errorMessage = 'Product is already added to the request, please select another product';
                    handleError(errorMessage);
                }
            }
        }
        if(productquestionswrapperlistbackup != null && productquestionswrapperlistbackup.size()>0){
            for(productquestionswrapper prdwrp : productquestionswrapperlistbackup ){
                if(ProductnameandAPL.get(SelectedProductName.touppercase() ) == ProductnameandAPL.get(prdwrp.apl.C_Ops_SPLOA_Product_Name__c.touppercase() )){
                    hasproductError = true;                        
                    errorMessage = 'Product is already added to the request, please select another product';
                    handleError(errorMessage);
                }
                
            }                
        }
        
    }
    public boolean getquestioncheck(string applicableto){
        if(applicableto.contains('Both') &&(Requestdetails=='Renewal' || Requestdetails=='New Request') )
            return true;
        if(Requestdetails=='Renewal' && applicableto.contains('Contract Renewal Request'))
            return true;
        if(Requestdetails=='New Request' && applicableto.contains('New Contract Request'))
            return true;
        if( applicableto.contains(Requestdetails))
            return true;
        return false;
    }
    
    public void getallProductquestions(){                   
        ProductQuesNameandlabel = new Map<String, String>();
        system.debug('-->requesttype'+Requestdetails);
        String products = '';
        List<C_Ops_SPLOA_Questions__c> AllselectedProdQues = new  List<C_Ops_SPLOA_Questions__c>();
        List<C_Ops_SPLOA_Sub_Question__c> subquestionlist = new List<C_Ops_SPLOA_Sub_Question__c>();
        List<String> grouplist  = new List<String>();
        if(SelectedProductName!=null){
            String GroupName ='';
            for(C_Ops_SPLOA_Questions__c question:Allquestions){  
                String QuesGroup = question.Group__c;
                grouplist = QuesGroup.split(';');
                GroupName = ProductnameandGroupName.get(SelectedProductName.touppercase());
                system.debug('-->gROUP SELECTED '+GroupName);
                if(grouplist  != null && grouplist .size() >0 && grouplist.contains(GroupName)  && question.Question_Type__c == 'Product Question' && getquestioncheck(question.C_Ops_SPLOA_Applicable_To__c)){
                    if(question.Answer__C != ''){question.Answer__c = '';}
                    C_Ops_SPLOA_Questions__c pharQuestion1;
                    if(existingQuestions.size()>0){                       
                        for(C_Ops_SPLOA_Questionnaire_Questions__c oldanswers:existingQuestions){
                            if(question.C_Ops_SPLOA_Question_Label__c == oldanswers.Question_Label__c ){
                                pharQuestion1 =new C_Ops_SPLOA_Questions__c (IDbackup__c = question.Id,
                                                                             C_Ops_SPLOA_Data_Type__c = question.C_Ops_SPLOA_Data_Type__c,
                                                                             C_Ops_SPLOA_Question_Label__c = question.C_Ops_SPLOA_Question_Label__c,
                                                                             Answer__c = oldanswers.Answer__c,
                                                                             C_Ops_SPLOA_Question_Display_Order__c = question.C_Ops_SPLOA_Question_Display_Order__c,
                                                                             C_Ops_SPLOA_Has_Subquestion__c = question.C_Ops_SPLOA_Has_Subquestion__c
                                                                            );
                                system.debug(pharQuestion1.Answer__c+'-->QUESTION SELECTED '+pharQuestion1.C_Ops_SPLOA_Question_Label__c);
                            }
                        }
                    }
                    if(pharQuestion1 == null){
                        pharQuestion1 =new C_Ops_SPLOA_Questions__c (IDbackup__c = question.Id,
                                                                     C_Ops_SPLOA_Data_Type__c = question.C_Ops_SPLOA_Data_Type__c,
                                                                     C_Ops_SPLOA_Question_Label__c = question.C_Ops_SPLOA_Question_Label__c,
                                                                     Answer__c = question.Answer__c,
                                                                     C_Ops_SPLOA_Question_Display_Order__c = question.C_Ops_SPLOA_Question_Display_Order__c,
                                                                     C_Ops_SPLOA_Has_Subquestion__c = question.C_Ops_SPLOA_Has_Subquestion__c
                                                                    );
                    }
                    // system.debug('-->QUESTION SELECTED '+question.C_Ops_SPLOA_Question_Label__c);
                    
                    AllselectedProdQues.add(pharQuestion1);
                    ProductQuesNameandlabel.put(question.C_Ops_SPLOA_Question_Label__c  , question.Name);
                }
            }
            //Get Subquestions based on above questions
            if(AllselectedProdQues != null && AllselectedProdQues.size()>0){
                for(C_Ops_SPLOA_Sub_Question__c subquestion :Allsubquestions ){                 
                    
                    if(subquestion.Parent_Question__c == AllselectedProdQues[0].IDbackup__c  && AllselectedProdQues[0].C_Ops_SPLOA_Has_Subquestion__c == true ){
                        List<String> subgrouplist  = new List<String>();
                        String subQuesGroup = subquestion.APL_Group__c;
                        subgrouplist = subQuesGroup.split(';');                      
                        system.debug('-->gROUP SELECTED '+GroupName);
                        
                        if( subgrouplist  != null && subgrouplist .size() >0 && subgrouplist.contains(GroupName) ){
                            if(subquestion.Answer__C != ''){subquestion.Answer__c = '';}
                            if(subquestion.Date_has_not_been_scheduled__c == true ){subquestion.Date_has_not_been_scheduled__c = false;}
                            if(subquestion.Date_Input__c != null){subquestion.Date_Input__c = null;}
                            C_Ops_SPLOA_Sub_Question__c subqu;
                            if(existingQuestions.size()>0){                       
                                for(C_Ops_SPLOA_Questionnaire_Questions__c oldanswers:existingQuestions){
                                    if(subquestion.Question_Label__c == oldanswers.Question_Label__c){
                                        
                                        subqu = new C_Ops_SPLOA_Sub_Question__c(C_Ops_SPLOA_Data_Type__c = subquestion.C_Ops_SPLOA_Data_Type__c,
                                                                                Question_Label__c = subquestion.Question_Label__c,
                                                                                Answer__c = oldanswers.Answer__c,
                                                                                C_Ops_SPLOA_Question_Display_Order__c = subquestion.C_Ops_SPLOA_Question_Display_Order__c,
                                                                                Parent_Question__c = subquestion.Parent_Question__c 
                                                                               );
                                        
                                    }
                                }
                            }
                            if(subqu == null )
                                subqu = new C_Ops_SPLOA_Sub_Question__c(External_id__c=subquestion.id,
                                                                        C_Ops_SPLOA_Data_Type__c = subquestion.C_Ops_SPLOA_Data_Type__c,
                                                                        Question_Label__c = subquestion.Question_Label__c,
                                                                        Answer__c = subquestion.Answer__c,
                                                                        C_Ops_SPLOA_Question_Display_Order__c = subquestion.C_Ops_SPLOA_Question_Display_Order__c,
                                                                        Parent_Question__c = subquestion.Parent_Question__c 
                                                                       );
                            
                            subquestionlist.add(subqu );
                            ProductQuesNameandlabel.put(subquestion.Question_Label__c, subquestion.Name);
                        }
                    }
                }
            }
            String relatedAPLproductnames = '';
            String SelectedProductAPL = '';
            
            SelectedProductAPL = ProductnameandAPL.get(SelectedProductName.touppercase() );
            
            for(C_Ops_SPLOA_Product__c prod: productslsts){
                if(prod.APL__c== SelectedProductAPL  && SelectedProductAPL != null && SelectedProductAPL  != '')
                    relatedAPLproductnames = relatedAPLproductnames  +  prod.Name + ', ' ;
            }
            relatedAPLproductnames  = relatedAPLproductnames.removeEnd(', ');
            
            if(relatedAPLproductnames != ''){
                prodmessage = 'As you have requested for <strong>'+ SelectedProductName+ '</strong>, you will get access to these products as well (provided all criteria are met) : <strong>'+relatedAPLproductnames + '</strong>' ;
                system.debug('-->810'+relatedAPLproductnames);
                currAPL = new APL__c(Product__c =relatedAPLproductnames ,C_Ops_SPLOA_Product_Name__c = SelectedProductName , Name = SelectedProductAPL );
            }
        }
        
        //Create Product Wrapper record if the selected product is correct
        if(AllselectedProdQues.size()>0  ){
            productquestionswrapperlist = new List<productquestionswrapper>();
            if(productquestionswrapperlist == null ){productquestionswrapperlist = new List<productquestionswrapper>();}
            Set<Id>setprodqueIds = new Set<Id>();
            Set<string>setsubquesIds = new Set<string>();
            List<C_Ops_SPLOA_Questions__c> ProdQueList = new List<C_Ops_SPLOA_Questions__c>();
            prodqueMap = new Map<C_Ops_SPLOA_Questions__c,List<C_Ops_SPLOA_Sub_Question__c>>();
            for(C_Ops_SPLOA_Questions__c  prodQue  :AllselectedProdQues){
                //prdqueswrapper = new productquestionswrapper(currAPL ,prodQue ,AllselectedProdQues.indexOf(prodQue )+1,subquestionlist);
                setprodqueIds.add(prodQue.IDbackup__c);
            }
            
            for(C_Ops_SPLOA_Sub_Question__c  prodQue  :subquestionlist){
                setsubquesIds.add(prodQue.External_id__c);
            }
            //  system.debug('setprodqueIds'+setprodqueIds);
            // ProdQueList = [Select id,Name,C_Ops_SPLOA_Customer_Type__c,alternative_value__c,Answer__c,Group__c,Attachement_required__c,C_Ops_SPLOA_Applicable_To__c,C_Ops_SPLOA_Effective_Date__c,Has_Next_Question__c,C_Ops_SPLOA_Has_Subquestion__c,IAP_Access_Type__c,IDbackup__c,C_Ops_SPLOA_Question_Display_Order__c,C_Ops_SPLOA_Question_Label__c,Question_Type__c,Product__c,Manual_review__c,C_Ops_SPLOA_Data_Type__c,Super_exceeded_question__c,C_Ops_SPLOA_Credential__c,(SELECT Id,Name,Field_To_Copy__c,APL_Group__c, C_Ops_SPLOA_Active__c,Answer__c,Parent_Question__c,Parent_Question__r.Group__c,Question_Label__c,C_Ops_SPLOA_Data_Type__c,C_Ops_SPLOA_Credential__c,Date_has_not_been_scheduled__c,Date_Input__c,C_Ops_SPLOA_Question_Display_Order__c from C_Ops_SPLOA_Sub_Question__r  order by C_Ops_SPLOA_Question_Display_Order__c asc) from C_Ops_SPLOA_Questions__c WHERE ID IN :setprodqueIds order by C_Ops_SPLOA_Question_Display_Order__c asc ];
            IAP_Controller_internal internalsave= new IAP_Controller_internal();          
            ProdQueList= internalsave.performqueryAllquestionsbyid(setprodqueIds); 
            
            //  system.debug('ProdQueList:'+ProdQueList);
            for(C_Ops_SPLOA_Questions__c prdq: ProdQueList){
                prodqueMap.put(prdq,prdq.C_Ops_SPLOA_Sub_Question__r);
            }
            AllselectedProdQues.clear();
            subquestionlist.clear();
            string GroupName = ProductnameandGroupName.get(SelectedProductName.touppercase());
            for(C_Ops_SPLOA_Questions__c  prodQue  : prodqueMap.Keyset()){
                C_Ops_SPLOA_Questions__c pharQuestion1;
                // subquestionlist.clear();
                if(existingQuestions.size()>0){                       
                    for(C_Ops_SPLOA_Questionnaire_Questions__c oldanswers:existingQuestions){
                        if(prodQue.C_Ops_SPLOA_Question_Label__c == oldanswers.Question_Label__c && currAPL.Name == oldanswers.Backend_to_store_products__c){
                            pharQuestion1 =new C_Ops_SPLOA_Questions__c (IDbackup__c = prodQue.Id,
                                                                         C_Ops_SPLOA_Data_Type__c = prodQue.C_Ops_SPLOA_Data_Type__c,
                                                                         C_Ops_SPLOA_Question_Label__c = prodQue.C_Ops_SPLOA_Question_Label__c,
                                                                         Answer__c = oldanswers.Answer__c,
                                                                         C_Ops_SPLOA_Question_Display_Order__c = prodQue.C_Ops_SPLOA_Question_Display_Order__c,
                                                                         C_Ops_SPLOA_Has_Subquestion__c = prodQue.C_Ops_SPLOA_Has_Subquestion__c
                                                                        );
                            system.debug(pharQuestion1.Answer__c+'-->QUESTION SELECTED '+pharQuestion1.C_Ops_SPLOA_Question_Label__c);
                        }
                    }
                }
                if(pharQuestion1 == null){
                    pharQuestion1 =new C_Ops_SPLOA_Questions__c (IDbackup__c = prodQue.Id,
                                                                 C_Ops_SPLOA_Data_Type__c = prodQue.C_Ops_SPLOA_Data_Type__c,
                                                                 C_Ops_SPLOA_Question_Label__c = prodQue.C_Ops_SPLOA_Question_Label__c,
                                                                 Answer__c = prodQue.Answer__c,
                                                                 C_Ops_SPLOA_Question_Display_Order__c = prodQue.C_Ops_SPLOA_Question_Display_Order__c,
                                                                 C_Ops_SPLOA_Has_Subquestion__c = prodQue.C_Ops_SPLOA_Has_Subquestion__c
                                                                );
                }
                AllselectedProdQues.add(pharQuestion1);
                // subquestionlist.clear();
                system.debug('pharQuestion1:'+pharQuestion1);
                for(C_Ops_SPLOA_Sub_Question__c subq : prodqueMap.get(prodQue)){
                    C_Ops_SPLOA_Sub_Question__c subqu;
                    List<String> subgrouplist  = new List<String>();
                    String subQuesGroup = subq.APL_Group__c;
                    if(string.isBlank(subQuesGroup))
                        subQuesGroup=subq.Parent_Question__r.Group__c;
                    subgrouplist = subQuesGroup.split(';');                      
                    system.debug('-->gROUP SELECTED '+GroupName);
                    if( subgrouplist  != null && subgrouplist .size() >0 && subgrouplist.contains(GroupName) ){
                        
                        if(existingQuestions.size()>0){                       
                            for(C_Ops_SPLOA_Questionnaire_Questions__c oldanswers:existingQuestions){
                                if(subq.Question_Label__c == oldanswers.Question_Label__c && currAPL.Name == oldanswers.Backend_to_store_products__c){
                                    
                                    subqu = new C_Ops_SPLOA_Sub_Question__c(C_Ops_SPLOA_Data_Type__c = subq.C_Ops_SPLOA_Data_Type__c,
                                                                            Question_Label__c = subq.Question_Label__c,
                                                                            Answer__c = oldanswers.Answer__c,
                                                                            C_Ops_SPLOA_Question_Display_Order__c = subq.C_Ops_SPLOA_Question_Display_Order__c,
                                                                            Parent_Question__c = subq.Parent_Question__c ,
                                                                            Field_To_Copy__c=subq.Field_To_Copy__c,
                                                                            C_Ops_SPLOA_Credential__c= subq.Answer__c
                                                                           );                                    
                                }
                            }
                        }
                        if(subqu == null )
                            subqu = new C_Ops_SPLOA_Sub_Question__c(C_Ops_SPLOA_Data_Type__c = subq.C_Ops_SPLOA_Data_Type__c,
                                                                    Question_Label__c = subq.Question_Label__c,
                                                                    Answer__c = subq.Answer__c,
                                                                    C_Ops_SPLOA_Question_Display_Order__c = subq.C_Ops_SPLOA_Question_Display_Order__c,
                                                                    Parent_Question__c = subq.Parent_Question__c ,
                                                                    Field_To_Copy__c=subq.Field_To_Copy__c
                                                                   );
                        subquestionlist.add(subqu);
                    }
                }
                system.debug('subquestionlist:'+subquestionlist);
                productquestionswrapperlist.add(new productquestionswrapper(currAPL ,pharQuestion1 ,AllselectedProdQues.indexOf(pharQuestion1 )+1,subquestionlist,reqTyp));
                //subquestionlist.clear();	
            }
            
        }
        if(productquestionswrapperlist != null){
            if(productquestionswrapperlist.size() >0){system.debug(productquestionswrapperlist[0].prodQues.Answer__c);
                                                      system.debug(productquestionswrapperlist[0]);}
            system.debug(productquestionswrapperlist.size());}
        
    }
    //**************** Methods related to contact info Page
    public void checkreqforaddprod(){
        // Added below code to check for add product functionality
        if( reqTyp == 'addProd' && mainRequest.C_Ops_SPLOA_Email__c != null && mainRequest.C_Ops_SPLOA_DEA_Number__c !=null && currAPL.C_Ops_SPLOA_Product_Name__c != null){
            List<C_Ops_SPLOA_Request__c> reqlist  = new List<C_Ops_SPLOA_Request__c>([SELECT Id,C_Ops_SPLOA_Email__c ,Name  ,C_Ops_SPLOA_DEA_Number__c, Processed_Date__c,C_Ops_SPLOA_Request_Status__c,C_Ops_SPLOA_Product_Name__c,Submission_Date__c   FROM C_Ops_SPLOA_Request__c WHERE C_Ops_SPLOA_Email__c =: mainRequest.C_Ops_SPLOA_Email__c AND C_Ops_SPLOA_DEA_Number__c =:mainRequest.C_Ops_SPLOA_DEA_Number__c AND C_Ops_SPLOA_Product_Name__c =: mainRequest.C_Ops_SPLOA_Product_Name__c AND (C_Ops_SPLOA_Request_Status__c != 'Processed' OR C_Ops_SPLOA_Request_Status__c != 'Expired' OR C_Ops_SPLOA_Request_Status__c != 'Denied' ) ] );
            if(reqlist!= null && reqlist.size()>0){
                errorMessage = 'There is currently a request being processed for this product and facility. If you are trying to revise a request that has already been submitted please email indirectaccess@gene.com';
                handleError(errorMessage);
            }
        }        
    }
    
    public boolean isValidZip(string z){        
        if(z.length() == 0){            
            return false;
        }
        
        Pattern zipCodeChecker = Pattern.compile('^(\\d{5}(\\-\\d{4})?)?$');
        Matcher zipMatcher = ZipCodeChecker.matcher(z);
        
        return (zipMatcher.matches());            
    }
    public PageReference startSubmission() {
        if(mainRequest.Same_Signing__c){
            //Signing_Authority_Title__c,Signing_Authority_Last_Name__c,Signing_Authority_First_name__c,
            mainRequest.Signing_Authority_First_name__c=mainRequest.C_Ops_SPLOA_First_Name__c;
            mainRequest.Signing_Authority_Last_Name__c=mainRequest.C_Ops_SPLOA_Last_Name__c;
            mainRequest.Signee_Email__c=mainRequest.C_Ops_SPLOA_Email__c;
            mainRequest.Signee_Phone__c=mainRequest.C_Ops_SPLOA_Phone__c;
            mainRequest.Signee_Extension__c=mainRequest.C_Ops_SPLOA_Extension__c;
        }
        checkforErrors();
        checkifRequestDenied();
        Boolean haveAuthError = ApexPages.hasMessages() || String.isNotBlank(errorMessage);
        if(!haveAuthError){
            assignAccesTypeafterproduct();
            if(reqTyp == 'addSite' || RequestDenial || updatereqTyp == 'addSite' || GroupandAccessTypMap.size()==0 ){
                quesquestionswrapperlist= new List<quesquestionswrapper>();
                PageReference c_ops_iap_reviewandsubmit= New PageReference('/apex/C_OPS_IAP_REVIEWANDSUBMIT');
                return c_ops_iap_reviewandsubmit;
            }
            else{
                PageReference C_OPS_IAP_QUES_PAGE = New PageReference('/apex/C_OPS_IAP_QUES_PAGE');
                C_OPS_IAP_QUES_PAGE.setRedirect(false);
                return C_OPS_IAP_QUES_PAGE;
            }
        }
        productNamechanged  = false;
        
        return null;
    }
    
    public void checkifRequestDenied(){
        RequestDenial  = true;
        // Integer aplsdeneid= 0;
        if(productquestionswrapperList != null && productquestionswrapperList.size() >0){
            for(productquestionswrapper r: productquestionswrapperList){  
                system.debug('productquestionswrapper -->'+r.apl);
                if(r.apl.Request_Status__c != 'Denied' ){
                    RequestDenial  = false; 
                }
            }
            
            // if( aplsdeneid != 0)RequestDenial = true;
        }
    }
    //Method to check Duplicate Request in the system    
    public void checkfordupeRequest(){   
        //Keeping the old logic for Non record type assigned records     
        if(mainRequest.RecordTypeId != mapofReqRecordTypeNameandId.get('New IAP Request')){
            if(String.IsNotBlank (mainRequest.C_Ops_SPLOA_Product_Name__c) && String.IsNotBlank ( mainRequest.C_Ops_SPLOA_DEA_Number__c) ){
                List<String> DEAlist = new List<String>();
                String product = mainRequest.C_Ops_SPLOA_Product_Name__c;
                //By passing main Request DEA Number dupe check for Add Sites criteria
                if(reqTyp != 'addSite'){ DEAlist.add(mainRequest.C_Ops_SPLOA_DEA_Number__c);}
                if(AddPharmList != null && AddPharmList.size()>0){
                    for(C_Ops_SPLOA_Additional_Pharmacy__c addpharm :AddPharmList){
                        DEAlist.add(addpharm.C_Ops_SPLOA_DEA_Number__c);
                    }
                }
                
                C_Ops_Captcha_Property__c prop = [select id,Auto_Renewal_Send_Cadence__c from C_Ops_Captcha_Property__c limit 1];
                numberofRenewalmonths = prop.Auto_Renewal_Send_Cadence__c;
                
                DateTime dupCheckStartingDateTime=System.now().addMonths(0-Integer.valueOf(numberofRenewalmonths));
                IAP_Controller_internal internalsave= new IAP_Controller_internal();
                //Checking for Existing Requests with product and main DEA number combination     
                List<C_Ops_SPLOA_Request__c> existingRequests =internalsave.getexistrequestonphar(product,DEAlist,dupCheckStartingDateTime);
                
                //Checking for Existing Requests with product , main DEA number and additional pharmacy combination 
                List<C_Ops_SPLOA_Request__c> existingRequestswithaddpharm =internalsave.getexistrequestonphar2(product,DEAlist,dupCheckStartingDateTime);
                
                
                if(existingRequests.size() > 0 || existingRequestswithaddpharm.size() > 0){
                    errorMessage = 'There is currently a request being processed for this product and facility. If you are trying to revise a request that has already been submitted please email indirectaccess@gene.com ';
                    handleError(errorMessage);
                }
            } 
        }
        //Check for new record type records
        else if(mainRequest.RecordTypeId == mapofReqRecordTypeNameandId.get('New IAP Request')){
            if(String.IsNotBlank (mainRequest.C_Ops_SPLOA_Product_Name__c) && String.IsNotBlank ( mainRequest.C_Ops_SPLOA_DEA_Number__c) ){
                List<String> DEAlist = new List<String>();
                String product = mainRequest.Related_Product_s__c;
                //By passing main Request DEA Number dupe check for Add Sites criteria
                if(reqTyp != 'addSite'){ DEAlist.add(mainRequest.C_Ops_SPLOA_DEA_Number__c);}
                if(AddPharmList != null && AddPharmList.size()>0){
                    for(C_Ops_SPLOA_Additional_Pharmacy__c addpharm :AddPharmList){
                        DEAlist.add(addpharm.C_Ops_SPLOA_DEA_Number__c);
                    }
                }
                
                C_Ops_Captcha_Property__c prop = [select id,Auto_Renewal_Send_Cadence__c from C_Ops_Captcha_Property__c limit 1];
                numberofRenewalmonths = prop.Auto_Renewal_Send_Cadence__c;
                
                DateTime dupCheckStartingDateTime=System.now().addMonths(0-Integer.valueOf(numberofRenewalmonths));
                IAP_Controller_internal internalsave= new IAP_Controller_internal();
                //Checking for Existing Requests with product and main DEA number combination     
                List<C_Ops_SPLOA_Request__c> existingRequests =internalsave.getexistrequestonphar(product,DEAlist,dupCheckStartingDateTime);
                
                //Checking for Existing Requests with product , main DEA number and additional pharmacy combination 
                List<C_Ops_SPLOA_Request__c> existingRequestswithaddpharm =internalsave.getexistrequestonphar2(product,DEAlist,dupCheckStartingDateTime);
                
                
                if(existingRequests.size() > 0 || existingRequestswithaddpharm.size() > 0){
                    errorMessage = 'There is currently a request being processed for this product and facility. If you are trying to revise a request that has already been submitted please email indirectaccess@gene.com ';
                    handleError(errorMessage);
                }
            }
        }       
    }
    
    private boolean emptyString(String s){
        if(s==null || s.trim().length()<=0) return true;        
        
        else return false;
    }
    public boolean isValidPhone(string checker){     
        String phoneRegex ='^\\(?([0-9]{3})\\)?[-.\\s]?([0-9]{3})[-.\\s]?([0-9]{4})$';
        Pattern phonePattern = Pattern.Compile(phoneRegex); 
        Matcher phoneMatcher = phonePattern.Matcher(checker);         
        return phoneMatcher.Matches();              
    }
    public boolean isValidExtension(string checker){        
        String phoneRegex ='^[0-9]+$';
        Pattern phonePattern = Pattern.Compile(phoneRegex); 
        Matcher phoneMatcher = phonePattern.Matcher(checker);         
        return phoneMatcher.Matches();                  
    }
    
    // Method to get same APL Product Names list
    public String getAPLproductName(String Product){
        String productname = Product;
        String relatedAPLproductnames = '';
        String SelectedProductAPL;
        
        SelectedProductAPL = ProductnameandAPL.get(productname.touppercase() );
        
        for(C_Ops_SPLOA_Product__c prod: productslsts){
            if(prod.APL__c== SelectedProductAPL  && SelectedProductAPL != null && SelectedProductAPL  != '')
                relatedAPLproductnames = relatedAPLproductnames  +  prod.Name + ', ' ;
        }
        relatedAPLproductnames  = relatedAPLproductnames.removeEnd(',');
        return relatedAPLproductnames  ;
    }
    
    //Method to check for Errors in the Contact Info Page
    public void checkforErrors(){
        //system.debug('-->requesttype'+Requestdetails);
        errorMessage = '';
        if((productquestionswrapperlist!= null && productquestionswrapperlist.size() == 0)||productquestionswrapperlist == null){
            if(Requestdetails !='Add Location'){
                errorMessage = 'Please add Product details';
                handleError(errorMessage);
                return;
            }
        } 
        if(Requestdetails !='Add Location'){
            system.debug('-->addprodOption'+addprodOption);
            if(addprodOption=='' || addprodOption==null ){
                errorMessage = 'Please answer all the mandatory questions.';
                handleError(errorMessage);
            }
            if(mainRequest.Additional_Products__c){
                
                if(productquestionswrapperlist!= null && productquestionswrapperlist.size() != 0){
                    set<string> productsnames=new set<string>();
                    for(  productquestionswrapper pharmwrap  : productquestionswrapperlist){  
                        productsnames.add(pharmwrap.apl.C_Ops_SPLOA_Product_Name__c);
                    }
                    if(productsnames.size() < 2){
                        errorMessage = 'As you have answered Yes to adding more products, please add more products to continue';
                        handleError(errorMessage);
                        return;    
                    }           
                }
            }
        }
        if(emptyString(mainRequest.C_Ops_SPLOA_First_Name__c)) {
            errorMessage = 'First Name is missing';
            handleError(errorMessage);
        }
        if(emptyString(mainRequest.C_Ops_SPLOA_Last_Name__c)) {
            errorMessage = 'Last Name is missing';
            handleError(errorMessage);
        }
        if(emptyString(mainRequest.C_Ops_SPLOA_Phone__c)) {
            errorMessage = 'Phone number is missing';
            handleError(errorMessage);
        }
        
        if((mainRequest.C_Ops_SPLOA_Phone__c!=null && mainRequest.C_Ops_SPLOA_Phone__c != '' && mainRequest.C_Ops_SPLOA_Phone__c.length()>0) && !isValidphone(mainRequest.C_Ops_SPLOA_Phone__c)){
            errorMessage = 'Phone number format must be 111-222-3333';
            handleError(errorMessage);
        }
        if(mainRequest.C_Ops_SPLOA_Fax__c != null && mainRequest.C_Ops_SPLOA_Fax__c != '' && !isValidphone(mainRequest.C_Ops_SPLOA_Fax__c)) {
            errorMessage = 'Fax number format must be 111-222-3333';
            handleError(errorMessage);
        }
        if(mainRequest.C_Ops_SPLOA_Extension__c!= null && mainRequest.C_Ops_SPLOA_Extension__c != '' && !isValidExtension(mainRequest.C_Ops_SPLOA_Extension__c)) {
            errorMessage = 'Please enter valid Extension';
            handleError(errorMessage);
        }
        if(emptyString(mainRequest.C_Ops_SPLOA_Email__c)) {
            errorMessage = 'Email address is missing';
            handleError(errorMessage);
        }
        /*if(mainRequest.Same_Signing__c){
mainRequest.Same_Signing__c= true;
mainRequest.Signee_First_Name__c=mainRequest.C_Ops_SPLOA_First_Name__c;
mainRequest.Signee_Last_Name__c=mainRequest.C_Ops_SPLOA_Last_Name__c;
mainRequest.Signee_Email__c=mainRequest.C_Ops_SPLOA_Email__c;
mainRequest.Signee_Phone__c=mainRequest.C_Ops_SPLOA_Phone__c;
mainRequest.Signee_Extension__c=mainRequest.C_Ops_SPLOA_Extension__c;
//Signing_Authority_Title__c,Signing_Authority_Last_Name__c,Signing_Authority_First_name__c,
}*/
        if(emptyString(mainRequest.Signing_Authority_First_name__c)) {
            errorMessage = 'Signer First Name is missing';
            handleError(errorMessage);
        }
        if(emptyString(mainRequest.Signing_Authority_Last_Name__c)) {
            errorMessage = 'Signer Last Name is missing';
            handleError(errorMessage);
        }
        if(emptyString(mainRequest.Signee_Phone__c)) {
            errorMessage = 'Signer Phone number is missing';
            handleError(errorMessage);
        }
        
        if((mainRequest.Signee_Phone__c!=null && mainRequest.Signee_Phone__c != '' && mainRequest.Signee_Phone__c.length()>0) && !isValidphone(mainRequest.Signee_Phone__c)){
            errorMessage = 'Signer Phone number format must be 111-222-3333';
            handleError(errorMessage);
        }
        
        if(mainRequest.Signee_Extension__c!= null && mainRequest.Signee_Extension__c != '' && !isValidExtension(mainRequest.Signee_Extension__c)) {
            errorMessage = 'Please enter valid Extension';
            handleError(errorMessage);
        }
        if(emptyString(mainRequest.Signee_Email__c)) {
            errorMessage = 'Signer Email address is missing';
            handleError(errorMessage);
        }
        
        if(emptyString(mainRequest.C_Ops_SPLOA_Pharmacy_Name__c)) {
            errorMessage = 'Primary Pharmacy Name is missing';
            handleError(errorMessage);
        }
        if(emptyString(mainRequest.C_Ops_SPLOA_DEA_Number__c)) {
            errorMessage = 'Primary DEA Number is missing';
            handleError(errorMessage);
        }
        if(emptyString(mainRequest.C_Ops_SPLOA_Street_Address__c)) {
            errorMessage = 'Address Line 1 is missing';
            handleError(errorMessage);
        }
        if(emptyString(mainRequest.C_Ops_SPLOA_City__c)) {
            errorMessage = 'City field is missing';
            handleError(errorMessage);
        }
        if(emptyString(mainRequest.State__c) || mainRequest.State__c == 'Select One') {
            errorMessage = 'State field is missing';
            handleError(errorMessage);
        }
        if(emptyString(mainRequest.C_Ops_SPLOA_Zip__c)) {
            errorMessage = 'ZIP code is missing';
            handleError(errorMessage);
        }
        if(!emptyString(mainRequest.C_Ops_SPLOA_Zip__c) && (!isValidZip(mainRequest.C_Ops_SPLOA_Zip__c))) {
            errorMessage = 'ZIP code is invalid';
            handleError(errorMessage);
        }
        if(selectedOption == null && reqTyp != 'addProd'){ //VK 3/5/21, Added reqTyp condition as part of ROBOCOPS-481
            errorMessage = 'Please answer question Do you have additional pharmacies to be added';
            handleError(errorMessage);
        }
        if(AddPharmList!=null && AddPharmList.size()>0 ){
            for(C_Ops_SPLOA_Additional_Pharmacy__c   AddPharm : AddPharmList){
                if(AddPharm.C_Ops_SPLOA_DEA_Number__c ==  mainRequest.C_Ops_SPLOA_DEA_Number__c){
                    errorMessage = 'Please enter a unique DEA Number';
                    handleError(errorMessage);
                }
            }
        }
        if((AddPharmList==null || AddPharmList.size()==0) && selectedOption=='Yes'){  
            if(reqTyp  != null && reqTyp == 'addSite'){
                errorMessage = 'Additional Pharmacy question is marked "Yes". Please add another pharmacy before proceeding.';
                handleError(errorMessage);  
            }
            else{          
                errorMessage = 'You selected Yes for Additional Pharmacies, but did not add pharmacy information. Please add the pharmacy information or change the response to No.';
                handleError(errorMessage);       
            }     
        } 
        if(errorMessage == ''){
            for( pharmacyquestionswrapper prodquemwrap:pharmqueswrapperlist){ 
                if(prodquemwrap.Grp=='1' || prodquemwrap.Grp == mainRequest.C_Ops_SPLOA_DEA_Number__c  ){
                    prodquemwrap.Grp = mainRequest.C_Ops_SPLOA_DEA_Number__c ;
                    string str='';
                    for(SelectOption opt:prodquemwrap.selectlistOption){                    
                        str=str+opt.getValue()+';';
                    }
                    if(string.isnotblank(str))
                        str = str.removeEnd(';');
                    if( prodquemwrap.Pharmques.C_Ops_SPLOA_Data_Type__c=='MultiPicklist'){
                        prodquemwrap.Pharmques.Answer__c=str;
                    }
                    if(string.isBlank(prodquemwrap.Pharmques.Answer__c)){
                        errorMessage = 'Please answer all questions';
                        handleError(errorMessage);
                        // system.debug(' haveError 525'+haveError);
                    }
                    if(prodquemwrap.subqueslist != null && prodquemwrap.Pharmques.Answer__c == 'Yes' ){
                        for(C_Ops_SPLOA_Sub_Question__c subques: prodquemwrap.subqueslist ){                  
                            if( subques.C_Ops_SPLOA_Data_Type__c=='MultiPicklist' && prodquemwrap.Pharmques.IDbackup__c == subques.Parent_Question__c){
                                subques.Answer__c=str;
                            }
                            if(string.isBlank(subques.Answer__c) && !subques.Date_has_not_been_scheduled__c && string.isBlank(string.valueof(subques.Date_Input__c)) && prodquemwrap.Pharmques.IDbackup__c == subques.Parent_Question__c){                             
                                errorMessage = 'Please answer all questions';
                                handleError(errorMessage);                        
                            }
                            if(string.isBlank(subques.Answer__c) && !string.isBlank(string.valueof(subques.Date_Input__c))){
                                subques.Answer__c=string.valueof(subques.Date_Input__c);
                            }                       
                        }
                    }
                }
            }
            mainRequest.Accreditation__c='';
            
            for( pharmacyquestionswrapper prodquemwrap:pharmqueswrapperlist){  
                if(prodquemwrap.subqueslist != null && prodquemwrap.Pharmques.Answer__c == 'Yes' ){
                    for(C_Ops_SPLOA_Sub_Question__c subques: prodquemwrap.subqueslist ){                          
                        if(string.isnotblank(subques.Field_To_Copy__c) && prodquemwrap.Pharmques.IDbackup__c == subques.Parent_Question__c)
                            updatefielddynamically(subques.Field_To_Copy__c,subques.Answer__c);
                    }
                }
                if(prodquemwrap.Pharmques.Answer__c != null){
                    prodquemwrap.Deniedreason='';
                    for(Business_Rule__c br : businessrulslist ){
                        if(br.C_Ops_IAP_Questions_List__r.C_Ops_SPLOA_Question_Label__c == prodquemwrap.Pharmques.C_Ops_SPLOA_Question_Label__c){
                            if(br.Value_for_Outcome__c == prodquemwrap.Pharmques.Answer__c ){ 
                                prodquemwrap.Deniedreason = br.Denial_Reason_Code__c ; 
                            }
                        }
                    }
                }
            }         
        }
        
    }    
    //**************** Methods related to Add Pharm info Page     
    //Method to commit entered Additional Pharmacy
    public PageReference commitAddPharm() {
        Boolean haveError = false;
        checkingDEAdup();
        haveDEAError = ApexPages.hasMessages() || String.isNotBlank(errorMessage);
        
        if(haveDEAError == false){
            if(isEditAddPharm != true){
                AddPharmList.add(currAddPharm);
            }
            isEditAddPharm = false;
            for( pharmacyquestionswrapper prodquemwrap:pharmqueswrapperlist){  
                system.System.debug(prodquemwrap.Grp+'-->'+requestToEdit);
                if(prodquemwrap.Grp=='' || prodquemwrap.Grp==null ||prodquemwrap.Grp== requestToEdit ){
                    prodquemwrap.Grp= currAddPharm.C_Ops_SPLOA_DEA_Number__c;  
                    prodquemwrap.Pharmques.C_Ops_SPLOA_Credential__c=currAddPharm.C_Ops_SPLOA_DEA_Number__c;             
                    
                    if(prodquemwrap.subqueslist != null && prodquemwrap.Pharmques.Answer__c == 'Yes' ){
                        for(C_Ops_SPLOA_Sub_Question__c subques: prodquemwrap.subqueslist ){                  
                            if( subques.C_Ops_SPLOA_Data_Type__c=='MultiPicklist' && prodquemwrap.Pharmques.IDbackup__c == subques.Parent_Question__c){
                                currAddPharm.Accreditation__c= subques.Answer__c;
                                subques.C_Ops_SPLOA_Credential__c=currAddPharm.C_Ops_SPLOA_DEA_Number__c; 
                            }
                        }
                    }
                }
            }           
            
            pageReference c_ops_iap_contact_infopg = new PageReference('/apex/C_OPS_IAP_CONTACT_INFOPG');
            c_ops_iap_contact_infopg.setRedirect(false);
            if (!haveError)
                return c_ops_iap_contact_infopg ;
        }
        
        return null;
    }
    public PageReference changeAnswer() {
        
        for( pharmacyquestionswrapper prodquemwrap:pharmqueswrapperlist){  
            if(prodquemwrap.Grp=='' || prodquemwrap.Grp== requestToEdit ){
                prodquemwrap.Grp= currAddPharm.C_Ops_SPLOA_DEA_Number__c;              
            }
            System.debug(prodquemwrap.Pharmques.Answer__c);
        }           
        
        
        return null;
    }
    
    
    public void checkingDEAdup(){
        errorMessage = '';
        
        if(!(isValidZip(currAddPharm.C_Ops_SPLOA_Zip__c)) || currAddPharm.C_Ops_SPLOA_Zip__c == null) {
            errorMessage = 'Please enter a valid ZIP code';
            handleError(errorMessage);
        }
        //Checking Curr Pharmacy is matching with Main Pharmacy DEA
        if(currAddPharm.C_Ops_SPLOA_DEA_Number__c == mainRequest.C_Ops_SPLOA_DEA_Number__c  ){
            errorMessage = 'Please enter a unique DEA Number';
            handleError(errorMessage);
        }
        if( currAddPharm.C_Ops_SPLOA_DEA_Number__c=='1'){
            errorMessage = 'Please enter a valid DEA Number';
            handleError(errorMessage);
        }
        //Checking the current DEA is matching with Add Pharmacy list -- When we add new Add Pharm
        if(AddPharmList.size()>0 && isEditAddPharm != true){
            for(C_Ops_SPLOA_Additional_Pharmacy__c   AddPharm : AddPharmList){
                if(AddPharm.C_Ops_SPLOA_DEA_Number__c ==  currAddPharm.C_Ops_SPLOA_DEA_Number__c ){
                    errorMessage = 'Please enter a unique DEA Number';
                    handleError(errorMessage);
                }
            }
        }
        //Checking the edited Add Pharm (current DEA) is matching with Add Pharmacy list -- When we edit an existing Add Pharm
        if(AddPharmList.size()>0 && isEditAddPharm == true && currAddPharm.C_Ops_SPLOA_DEA_Number__c!= requestToEdit){
            Integer numberofocc =0;
            for(C_Ops_SPLOA_Additional_Pharmacy__c   AddPharm : AddPharmList){
                if(AddPharm.C_Ops_SPLOA_DEA_Number__c ==  currAddPharm.C_Ops_SPLOA_DEA_Number__c)
                    numberofocc++;
            }
            if(numberofocc >1){
                errorMessage = 'Please enter a unique DEA Number';
                handleError(errorMessage);
            }
            numberofocc = 0;
        }
        
        for( pharmacyquestionswrapper prodquemwrap:pharmqueswrapperlist){ 
            if(prodquemwrap.Grp=='' ||prodquemwrap.Grp==null || prodquemwrap.Grp== requestToEdit ){  
                string str='';
                for(SelectOption opt:prodquemwrap.selectlistOption){                    
                    str=str+opt.getValue()+';';
                }
                if(string.isnotblank(str))
                    str = str.removeEnd(';');
                if( prodquemwrap.Pharmques.C_Ops_SPLOA_Data_Type__c=='MultiPicklist'){
                    prodquemwrap.Pharmques.Answer__c=str;
                }
                if(string.isBlank(prodquemwrap.Pharmques.Answer__c)){
                    errorMessage = 'Please answer all questions';
                    handleError(errorMessage);
                    // system.debug(' haveError 525'+haveError);
                }
                if(prodquemwrap.subqueslist != null && prodquemwrap.Pharmques.Answer__c == 'Yes' ){
                    for(C_Ops_SPLOA_Sub_Question__c subques: prodquemwrap.subqueslist ){                  
                        if( subques.C_Ops_SPLOA_Data_Type__c=='MultiPicklist' && prodquemwrap.Pharmques.IDbackup__c == subques.Parent_Question__c){
                            subques.Answer__c=str;
                        }
                        if(string.isBlank(subques.Answer__c) && !subques.Date_has_not_been_scheduled__c && string.isBlank(string.valueof(subques.Date_Input__c)) && prodquemwrap.Pharmques.IDbackup__c == subques.Parent_Question__c){                             
                            errorMessage = 'Please answer all questions';
                            handleError(errorMessage);                        
                        }
                        if(string.isBlank(subques.Answer__c) && !string.isBlank(string.valueof(subques.Date_Input__c))){
                            subques.Answer__c=string.valueof(subques.Date_Input__c);
                        }                       
                    }
                }
            }
        }
    }
    
    //Method to edit added Additional Pharmacy
    public PageReference editAddPharm(){
        isEditAddPharm = true;                  
        requestToEdit = Apexpages.currentpage().getParameters().get('editIndex');
        
        for(C_Ops_SPLOA_Additional_Pharmacy__c r: AddPharmList){                      
            if(r.C_Ops_SPLOA_DEA_Number__c == requestToEdit)
                currAddPharm = r;
        }
        /*   curqueswrapperlist = new List<pharmacyquestionswrapper>();
for( pharmacyquestionswrapper pharmaquesss:pharmqueswrapperlist){
if(pharmaquesss.Grp=='' || pharmaquesss.Grp== requestToEdit ){
curqueswrapperlist.add(pharmaquesss);    
}
}*/
        
        pageReference c_ops_iap_addpharm = new PageReference('/apex/C_OPS_IAP_ADDPHARM');
        c_ops_iap_addpharm.setRedirect(false);
        return c_ops_iap_addpharm ;
    }
    //Method to remove added Additional Pharmacy
    public void removeAddPharm(){
        String requestToRemove = Apexpages.currentpage().getParameters().get('removeIndex');
        
        List<C_Ops_SPLOA_Additional_Pharmacy__c> replacementList = new List<C_Ops_SPLOA_Additional_Pharmacy__c>();        
        for(C_Ops_SPLOA_Additional_Pharmacy__c r: AddPharmList){            
            if(r.C_Ops_SPLOA_DEA_Number__c != requestToRemove){                
                replacementList.add(r);
            }
        }
        AddPharmList = replacementList;
        if(reqTyp != 'update')
            if(AddPharmList.size()<=0 && reqTyp != 'addSite') selectedOption='No';
        else selectedOption='Yes';
    }
    
    //Method to cancel entered Additional Pharmacy
    public PageReference cancelAddPharm() {
        errorMessage = null;
        
        for (Integer i = (pharmqueswrapperlist.size()-1) ; i>= 0 ; i--){           
            if(pharmqueswrapperlist[i].Grp=='' || pharmqueswrapperlist[i].Grp==null ){
                pharmqueswrapperlist.remove(i);
            }
        } 
        pageReference c_ops_iap_contact_infopg = new PageReference('/apex/C_OPS_IAP_CONTACT_INFOPG');
        c_ops_iap_contact_infopg.setRedirect(false);
        return c_ops_iap_contact_infopg ;
    }
    //**********************Methods related to Pharmacy Page
    //Method to Navigate to Questionnaire Page from Pharmacy Info Page
    public pageReference nextpagenavigation(){
        Boolean haveError = false;
        //Verify all questions are answered
        for(  pharmacyquestionswrapper pharmwrap  : pharmqueswrapperlist){
            if(string.isBlank(pharmwrap.Pharmques.Answer__c)){
                haveError = true;
                errorMessage = 'Please answer all questions';
                handleError(errorMessage);
            }
            if(pharmwrap.subqueslist != null && pharmwrap.Pharmques.Answer__c == 'Yes'){
                for(C_Ops_SPLOA_Sub_Question__c subques: pharmwrap.subqueslist ){
                    if(string.isBlank(subques.Answer__c) && subques.Question_Label__c  !=  'If yes, will you renew at that time?'){
                        haveError = true;
                        errorMessage = 'Please answer all questions';
                        handleError(errorMessage);
                    }
                    if(string.isBlank(subques.Answer__c) && pharmwrap.subqueslist.size() >2 && (pharmwrap.subqueslist[1].Answer__c == 'Yes' && pharmwrap.subqueslist[1].Question_Label__c  == 'Will your accreditation expire in the next two years?')&& subques.Question_Label__c  ==  'If yes, will you renew at that time?'){
                        haveError = true;
                        errorMessage = 'Please answer all questions';
                        handleError(errorMessage);
                    }
                }
                
            }
        }        
        if(haveError != true){
            RequestDenial = false;
            checkBusinessRules();
            if(RequestDenial == false){ assignAccesType(); }
            
            if(RequestDenial == true ){
                refreshquestion=true;
                if(quesquestionswrapperlist != null && quesquestionswrapperlist.size()>0 ){
                    quesquestionswrapperlist= new List<quesquestionswrapper>();
                }
                PageReference c_ops_iap_reviewandsubmit = New PageReference('/apex/C_OPS_IAP_REVIEWANDSUBMIT');
                c_ops_iap_reviewandsubmit.setRedirect(false);
                return c_ops_iap_reviewandsubmit;
            }  
            if(RequestDenial == false){
                PageReference c_ops_iap_ques_page = New PageReference('/apex/C_OPS_IAP_QUES_PAGE');
                c_ops_iap_ques_page.setRedirect(false);
                return c_ops_iap_ques_page ;
            }
        }
        haveError = false;
        return null;
    }    
    public void pharmpageaction() {
        if(pharmqueswrapperlist == null ){
            pharmqueswrapperlist = new List<pharmacyquestionswrapper>();
        }        
        curqueswrapperlist = new List<pharmacyquestionswrapper>();
        Map<C_Ops_SPLOA_Questions__c,List<C_Ops_SPLOA_Sub_Question__c>> pharmacyquesMap = new Map<C_Ops_SPLOA_Questions__c,List<C_Ops_SPLOA_Sub_Question__c>>();
        
        boolean firstrequest=false;
        if( pharmqueswrapperlist.size() == 0){
            firstrequest=true;
        }else{
            for (Integer i = (pharmqueswrapperlist.size()-1) ; i>= 0 ; i--){           
                if(pharmqueswrapperlist[i].Grp=='' || pharmqueswrapperlist[i].Grp==null){
                    pharmqueswrapperlist.remove(i);
                }
            }       
        }   
        List<C_Ops_SPLOA_Questions__c> pharmacyqueslist = new List<C_Ops_SPLOA_Questions__c>(); 
        pharmacyquesMap = getPharmQuesbasedonGroup('1');
        for( C_Ops_SPLOA_Questions__c ques : pharmacyquesMap.keyset()){
            C_Ops_SPLOA_Questions__c pharQuestion1;
            // subquestionlist.clear();
            
            if(pharQuestion1 == null){
                pharQuestion1 =new C_Ops_SPLOA_Questions__c (IDbackup__c = ques.Id,
                                                             C_Ops_SPLOA_Data_Type__c = ques.C_Ops_SPLOA_Data_Type__c,
                                                             C_Ops_SPLOA_Question_Label__c = ques.C_Ops_SPLOA_Question_Label__c,
                                                             Answer__c = ques.Answer__c,
                                                             C_Ops_SPLOA_Question_Display_Order__c = ques.C_Ops_SPLOA_Question_Display_Order__c,
                                                             C_Ops_SPLOA_Has_Subquestion__c = ques.C_Ops_SPLOA_Has_Subquestion__c
                                                            );
            }
            List<C_Ops_SPLOA_Sub_Question__c> pharsubqueslist1 = new List<C_Ops_SPLOA_Sub_Question__c>();
            for(C_Ops_SPLOA_Sub_Question__c subq : pharmacyquesMap.get(ques )){
                C_Ops_SPLOA_Sub_Question__c subqu;                       
                if(subqu == null )
                    subqu = new C_Ops_SPLOA_Sub_Question__c(C_Ops_SPLOA_Data_Type__c = subq.C_Ops_SPLOA_Data_Type__c,
                                                            Question_Label__c = subq.Question_Label__c,
                                                            Answer__c = subq.Answer__c,
                                                            Field_To_Copy__c=subq.Field_To_Copy__c,
                                                            C_Ops_SPLOA_Question_Display_Order__c = subq.C_Ops_SPLOA_Question_Display_Order__c,
                                                            Parent_Question__c = subq.Parent_Question__c 
                                                           );
                pharsubqueslist1.add(subqu );
            }
            pharmacyqueslist.add(pharQuestion1 );
            System.debug('pharmacyqueslist-->'+pharmacyqueslist);
            if(firstrequest){
                pharmqueswrapperlist.add(new pharmacyquestionswrapper(pharQuestion1 ,pharmacyqueslist.indexOf(pharQuestion1 )+1,pharsubqueslist1 ,'1',reqTyp));
            }   else{
                pharmqueswrapperlist.add(new pharmacyquestionswrapper(pharQuestion1 ,pharmacyqueslist.indexOf(pharQuestion1 )+1,pharsubqueslist1 ,'',reqTyp));
            }
        }
        if(curqueswrapperlist.size() > 0)   
            // pharmqueswrapperlist.addall(curqueswrapperlist);  
            for(pharmacyquestionswrapper tempwrap:pharmqueswrapperlist){
                System.debug('-->'+tempwrap);
                System.debug('-->'+tempwrap.subqueslist);
            }
    }
    
    
    
    public void pharmpageaction2() {
        if(pharmqueswrapperlist == null ){
            pharmqueswrapperlist = new List<pharmacyquestionswrapper>();
        }        
        curqueswrapperlist = new List<pharmacyquestionswrapper>();
        
        boolean firstrequest=false;
        if( pharmqueswrapperlist.size() == 0){
            firstrequest=true;
        }else{
            for (Integer i = (pharmqueswrapperlist.size()-1) ; i>= 0 ; i--){           
                if(pharmqueswrapperlist[i].Grp=='' || pharmqueswrapperlist[i].Grp==null){
                    pharmqueswrapperlist.remove(i);
                }
            }       
        } 
        Map<C_Ops_SPLOA_Questions__c,List<C_Ops_SPLOA_Sub_Question__c>> pharmacyquesMap = new Map<C_Ops_SPLOA_Questions__c,List<C_Ops_SPLOA_Sub_Question__c>>();
        pharmacyquesMap = getPharmQuesbasedonGroup('1');
        if(reqTyp == 'update'){        
            if(existingQuestions.size()>0){      
                C_Ops_SPLOA_Questions__c  pharQuestion2;                 
                for(C_Ops_SPLOA_Questionnaire_Questions__c oldanswers:existingQuestions){
                    List<C_Ops_SPLOA_Sub_Question__c> temsublist = new List<C_Ops_SPLOA_Sub_Question__c>();
                    if(oldanswers.Question_Type__c =='Pharmacy Questions' && string.isBlank(oldanswers.C_Ops_SPLOA_Questionnaire__c)  ){
                        string grpforphar=oldanswers.C_Ops_SPLOA_Request__r.C_Ops_SPLOA_DEA_Number__c;
                        //system.debug('-->QUESTION SELECTED '+oldanswers);
                        if(string.isnotBlank(oldanswers.IAP_Additional_Pharmacies__c)){
                            grpforphar= oldanswers.IAP_Additional_Pharmacies__r.C_Ops_SPLOA_DEA_Number__c;
                        }
                        C_Ops_SPLOA_Questions__c parentsques = new C_Ops_SPLOA_Questions__c();
                        for( C_Ops_SPLOA_Questions__c ques : pharmacyquesMap.keyset()){
                            if(ques.C_Ops_SPLOA_Question_Label__c == oldanswers.Question_Label__c ){
                                parentsques=ques;
                                temsublist=pharmacyquesMap.get(ques );
                            }
                        }
                        pharQuestion2 =new C_Ops_SPLOA_Questions__c (IDbackup__c = oldanswers.Id,
                                                                     C_Ops_SPLOA_Data_Type__c = oldanswers.Data_type__c,
                                                                     C_Ops_SPLOA_Question_Label__c = oldanswers.Question_Label__c,
                                                                     Answer__c = oldanswers.Answer__c,
                                                                     C_Ops_SPLOA_Question_Display_Order__c = oldanswers.C_Ops_SPLOA_Question_Display_Order__c,
                                                                     C_Ops_SPLOA_Credential__c=grpforphar,
                                                                     C_Ops_SPLOA_Has_Subquestion__c = parentsques.C_Ops_SPLOA_Has_Subquestion__c
                                                                    );
                        
                        
                        List<C_Ops_SPLOA_Sub_Question__c> pharsubqueslist2 = new List<C_Ops_SPLOA_Sub_Question__c>();
                        C_Ops_SPLOA_Sub_Question__c subqu32;                      
                        for(C_Ops_SPLOA_Questionnaire_Questions__c oldanswers2:existingQuestions){
                            
                            if(pharQuestion2.IDbackup__c == oldanswers2.C_Ops_SPLOA_Questionnaire__c   ){
                                string subgrpforphar=oldanswers2.C_Ops_SPLOA_Request__r.C_Ops_SPLOA_DEA_Number__c;
                                if(string.isnotBlank(oldanswers2.IAP_Additional_Pharmacies__c)){
                                    subgrpforphar=oldanswers2.IAP_Additional_Pharmacies__r.C_Ops_SPLOA_DEA_Number__c;
                                }
                                C_Ops_SPLOA_Sub_Question__c matchsubques=new C_Ops_SPLOA_Sub_Question__c();
                                for(C_Ops_SPLOA_Sub_Question__c subques:temsublist){
                                    if(subques.Question_Label__c == oldanswers2.Question_Label__c   ){
                                        matchsubques=subques;
                                    }
                                }
                                subqu32 = new C_Ops_SPLOA_Sub_Question__c(External_id__c=oldanswers2.id,
                                                                          C_Ops_SPLOA_Data_Type__c = oldanswers2.Data_type__c,
                                                                          Question_Label__c = oldanswers2.Question_Label__c,
                                                                          Answer__c = oldanswers2.Answer__c,
                                                                          C_Ops_SPLOA_Question_Display_Order__c = oldanswers2.C_Ops_SPLOA_Question_Display_Order__c,
                                                                          Parent_Question__c = oldanswers2.C_Ops_SPLOA_Questionnaire__c,
                                                                          C_Ops_SPLOA_Credential__c=subgrpforphar,
                                                                          Answer2__c= matchsubques.Answer__c,
                                                                          Field_To_Copy__c=matchsubques.Field_To_Copy__c                                                                      
                                                                         );
                                pharsubqueslist2.add(subqu32);
                                
                            }
                        }
                        //system.System.debug('**** Group'+grpforphar);
                        pharmqueswrapperlist.add(new pharmacyquestionswrapper(pharQuestion2 ,1,pharsubqueslist2 ,grpforphar,reqTyp));
                    }
                }
            }
        }else{
            List<C_Ops_SPLOA_Questions__c> pharmacyqueslist = new List<C_Ops_SPLOA_Questions__c>(); 
            
            for( C_Ops_SPLOA_Questions__c ques : pharmacyquesMap.keyset()){
                C_Ops_SPLOA_Questions__c pharQuestion1;
                
                if(pharQuestion1 == null){
                    pharQuestion1 =new C_Ops_SPLOA_Questions__c (IDbackup__c = ques.Id,
                                                                 C_Ops_SPLOA_Data_Type__c = ques.C_Ops_SPLOA_Data_Type__c,
                                                                 C_Ops_SPLOA_Question_Label__c = ques.C_Ops_SPLOA_Question_Label__c,
                                                                 Answer__c = ques.Answer__c,
                                                                 C_Ops_SPLOA_Question_Display_Order__c = ques.C_Ops_SPLOA_Question_Display_Order__c,
                                                                 C_Ops_SPLOA_Has_Subquestion__c = ques.C_Ops_SPLOA_Has_Subquestion__c
                                                                );
                }
                List<C_Ops_SPLOA_Sub_Question__c> pharsubqueslist1 = new List<C_Ops_SPLOA_Sub_Question__c>();
                for(C_Ops_SPLOA_Sub_Question__c subq : pharmacyquesMap.get(ques )){
                    C_Ops_SPLOA_Sub_Question__c subqu;
                    
                    if(subqu == null )
                        subqu = new C_Ops_SPLOA_Sub_Question__c(C_Ops_SPLOA_Data_Type__c = subq.C_Ops_SPLOA_Data_Type__c,
                                                                Question_Label__c = subq.Question_Label__c,
                                                                Answer__c = subq.Answer__c,
                                                                Field_To_Copy__c=subq.Field_To_Copy__c,
                                                                C_Ops_SPLOA_Question_Display_Order__c = subq.C_Ops_SPLOA_Question_Display_Order__c,
                                                                Parent_Question__c = subq.Parent_Question__c 
                                                               );
                    pharsubqueslist1.add(subqu );
                }
                pharmacyqueslist.add(pharQuestion1 );
                System.debug('pharmacyqueslist-->'+pharmacyqueslist);
                if(firstrequest){
                    pharmqueswrapperlist.add(new pharmacyquestionswrapper(pharQuestion1 ,pharmacyqueslist.indexOf(pharQuestion1 )+1,pharsubqueslist1 ,'1',reqTyp));
                }   else{
                    pharmqueswrapperlist.add(new pharmacyquestionswrapper(pharQuestion1 ,pharmacyqueslist.indexOf(pharQuestion1 )+1,pharsubqueslist1 ,'',reqTyp));
                }
            }
        }
        
        if(curqueswrapperlist.size() > 0)   
            // pharmqueswrapperlist.addall(curqueswrapperlist);  
            for(pharmacyquestionswrapper tempwrap:pharmqueswrapperlist){
                System.debug('-->'+tempwrap);
                System.debug('-->'+tempwrap.subqueslist);
            }
    }
    
    public void resetaplstatusforeditpharm(){
        if(quesquestionswrapperlist != null && quesquestionswrapperlist.size() >0){
            for(productquestionswrapper r: productquestionswrapperList){
                if(r.apl.Denied_for_which_Question_Type__c == 'Questionnaire' && r.apl.Request_Status__c == 'Denied'){
                    system.debug('Inside the loop');
                    r.apl.Denial_Reason_Code__c  = '';
                    r.apl.Request_Status__c = '';
                }
            }
        }
        /*  if(pharmqueswrapperlist != null && pharmqueswrapperlist.size()>0){
for(productquestionswrapper r: productquestionswrapperList){
if(r.apl.Denied_for_which_Question_Type__c == 'Pharmacy Questions' && r.apl.Request_Status__c == 'Denied'){
r.apl.Denial_Reason_Code__c  = '';
r.apl.Request_Status__c = '';
}
}
}*/
    }    
    //Nav to Contact Info Page from Pharmacy Info Page
    public pageReference backtofirstpage(){
        PageReference C_OPS_IAP_QUES_PAGE = New PageReference('/apex/C_OPS_IAP_CONTACT_INFOPG');
        C_OPS_IAP_QUES_PAGE.setRedirect(false);
        return C_OPS_IAP_QUES_PAGE ;
    }    
    
    public Map<C_Ops_SPLOA_Questions__c,List<C_Ops_SPLOA_Sub_Question__c>> getPharmQuesbasedonGroup(String GroupName){
        //   List<C_Ops_SPLOA_Questions__c> PharmQuesperGroup = new  List<C_Ops_SPLOA_Questions__c>();
        pharmquesMap = new Map<C_Ops_SPLOA_Questions__c,List<C_Ops_SPLOA_Sub_Question__c>>();
        
        List<String> grouplist = new List<string>(); 
        for(C_Ops_SPLOA_Questions__c question:Allquestions){
            
            List<C_Ops_SPLOA_Sub_Question__c> subquestionlist = new List<C_Ops_SPLOA_Sub_Question__c>();
            if(question.Group__c!=null){
                String QuesGroup = question.Group__c;
                
                grouplist = QuesGroup.split(';');
                
                if(grouplist!=null && grouplist.size() > 0 && grouplist.contains(GroupName) && question.Question_Type__c == 'Pharmacy Questions'){
                    // if(question.Answer__c != ''){question.Answer__c = '';}
                    
                    for(C_Ops_SPLOA_Sub_Question__c subquestion :Allsubquestions ){
                        if(subquestion.Parent_Question__c == question.IDbackup__c && question.C_Ops_SPLOA_Has_Subquestion__c == true ){
                            // if(subquestion.Answer__c != ''){subquestion.Answer__c = '';}
                            subquestionlist.add(subquestion );
                        }
                    }
                    pharmquesMap.put(question,subquestionlist );
                }
            }
        }
        
        return pharmquesMap ;
    }
    //****************Methods related to questionnaire page
    //Method to determine the Questionnaire Questions related to Selected Product and Access Type
    public pagereference pharmQueschk() {
        resetaplstatusforedit();
        Set<String> GroupNames = new Set<String>();
        Map<C_Ops_SPLOA_Questions__c,List<C_Ops_SPLOA_Sub_Question__c>> quesquesMap = new Map<C_Ops_SPLOA_Questions__c,List<C_Ops_SPLOA_Sub_Question__c>>();
        if(productquestionswrapperList!= null && productquestionswrapperList.size() >0){
            
            for(productquestionswrapper r: productquestionswrapperList){
                if(r.apl.Request_Status__c != 'Denied'){
                    GroupNames.add(ProductnameandGroupName.get(r.apl.C_Ops_SPLOA_Product_Name__c.touppercase()));
                }
            }
        }
        Grprelatedprod = new Map<String,String>();
        
        if(quesquestionswrapperlist != null && quesquestionswrapperlist.size()== 0  && !refreshquestion && GroupNames.size()>0 ){
            refreshquestion= true;
        }
        system.debug('GroupNames refreshed '+GroupNames+quesquestionswrapperlist+refreshquestion);
        for(String grp: GroupNames){  
            String relatedProdName = '';
            for(productquestionswrapper r: productquestionswrapperList){
                if(Grp == ProductnameandGroupName.get(r.apl.C_Ops_SPLOA_Product_Name__c.touppercase()) && r.apl.Request_Status__c != 'Denied'){
                    //  system.debug(r.apl.Product__c+'-->relatedProdName'+relatedProdName);
                    if(!relatedProdName.contains(r.apl.Product__c))
                        relatedProdName  = relatedProdName + r.apl.Product__c + ', ' ;
                }
            }
            relatedProdName  = relatedProdName.removeEnd(', ');
            Grprelatedprod.put(Grp,relatedProdName  );
        }
        if(quesquestionswrapperlist == null  || refreshquestion  ){
            system.debug('Questions refreshed ');
            quesquestionswrapperlist= new List<quesquestionswrapper>();
            refreshquestion= false;
            
            if(GroupNames!= null && GroupNames.size() >0 && quesquestionswrapperlist.size() == 0){
                for(String grp: GroupNames){  
                    List<C_Ops_SPLOA_Questions__c> quequeslist = new List<C_Ops_SPLOA_Questions__c>(); 
                    quesquesMap = getQueQuesbasedonGroup(grp);
                    for( C_Ops_SPLOA_Questions__c ques : quesquesMap.keyset()){
                        C_Ops_SPLOA_Questions__c queQuestion1;
                        if(existingQuestions.size()>0){                       
                            for(C_Ops_SPLOA_Questionnaire_Questions__c oldanswers:existingQuestions){
                                if(ques.C_Ops_SPLOA_Question_Label__c == oldanswers.Question_Label__c && grp == oldanswers.Group__c){
                                    queQuestion1 =new C_Ops_SPLOA_Questions__c (IDbackup__c = ques.Id,
                                                                                C_Ops_SPLOA_Data_Type__c = ques.C_Ops_SPLOA_Data_Type__c,
                                                                                C_Ops_SPLOA_Question_Label__c = ques.C_Ops_SPLOA_Question_Label__c,
                                                                                Answer__c = oldanswers.Answer__c,
                                                                                C_Ops_SPLOA_Question_Display_Order__c = ques.C_Ops_SPLOA_Question_Display_Order__c,
                                                                                C_Ops_SPLOA_Has_Subquestion__c = ques.C_Ops_SPLOA_Has_Subquestion__c
                                                                               );
                                    system.debug(queQuestion1.Answer__c+'-->QUESTION SELECTED '+queQuestion1.C_Ops_SPLOA_Question_Label__c);
                                }
                            }
                        }
                        if(queQuestion1 == null){
                            
                            queQuestion1 =new C_Ops_SPLOA_Questions__c (IDbackup__c = ques.Id,
                                                                        C_Ops_SPLOA_Data_Type__c = ques.C_Ops_SPLOA_Data_Type__c,
                                                                        C_Ops_SPLOA_Question_Label__c = ques.C_Ops_SPLOA_Question_Label__c,
                                                                        Answer__c = ques.Answer__c,
                                                                        C_Ops_SPLOA_Question_Display_Order__c = ques.C_Ops_SPLOA_Question_Display_Order__c,
                                                                        C_Ops_SPLOA_Has_Subquestion__c = ques.C_Ops_SPLOA_Has_Subquestion__c
                                                                       );
                        }
                        
                        List<C_Ops_SPLOA_Sub_Question__c> quessubqueslist1 = new List<C_Ops_SPLOA_Sub_Question__c>();
                        for(C_Ops_SPLOA_Sub_Question__c subq : quesquesMap.get(ques )){
                            
                            C_Ops_SPLOA_Sub_Question__c subqu;
                            if(existingQuestions.size()>0){                       
                                for(C_Ops_SPLOA_Questionnaire_Questions__c oldanswers:existingQuestions){
                                    if(subq.Question_Label__c == oldanswers.Question_Label__c && grp == oldanswers.Group__c){
                                        
                                        subqu = new C_Ops_SPLOA_Sub_Question__c(C_Ops_SPLOA_Data_Type__c = subq.C_Ops_SPLOA_Data_Type__c,
                                                                                Question_Label__c = subq.Question_Label__c,
                                                                                Answer__c = oldanswers.Answer__c,
                                                                                C_Ops_SPLOA_Question_Display_Order__c = subq.C_Ops_SPLOA_Question_Display_Order__c,
                                                                                Parent_Question__c = subq.Parent_Question__c 
                                                                               );
                                        
                                    }
                                }
                            }
                            if(subqu == null )
                                subqu = new C_Ops_SPLOA_Sub_Question__c(C_Ops_SPLOA_Data_Type__c = subq.C_Ops_SPLOA_Data_Type__c,
                                                                        Question_Label__c = subq.Question_Label__c,
                                                                        Answer__c = subq.Answer__c,
                                                                        C_Ops_SPLOA_Question_Display_Order__c = subq.C_Ops_SPLOA_Question_Display_Order__c,
                                                                        Parent_Question__c = subq.Parent_Question__c 
                                                                       );
                            quessubqueslist1.add(subqu );
                        }
                        quequeslist.add(queQuestion1);
                       
                        quesquestionswrapperlist.add(new quesquestionswrapper(queQuestion1,quequeslist.indexOf(queQuestion1)+1,quessubqueslist1, grp));
                        
                    }          
                }
            }
        }
        system.debug('-->Grprelatedprod'+Grprelatedprod);
        if(Grprelatedprod != null && Grprelatedprod.size() >0){   
            if(Grprelatedprod.get('1')!= null ){Grp1quesproducts = Grprelatedprod.get('1');}
            if(Grprelatedprod.get('2')!= null ){Grp2quesproducts = Grprelatedprod.get('2');}
            if(Grprelatedprod.get('3')!= null ){Grp3quesproducts = Grprelatedprod.get('3');}
            if(Grprelatedprod.get('4')!= null ){Grp4quesproducts = Grprelatedprod.get('4');}
            if(Grprelatedprod.get('5')!= null ){Grp5quesproducts = Grprelatedprod.get('5');}
            if(Grprelatedprod.get('6')!= null ){Grp6quesproducts = Grprelatedprod.get('6');}
            if(Grprelatedprod.get('7')!= null ){Grp7quesproducts = Grprelatedprod.get('7');}
            if(Grprelatedprod.get('8')!= null ){Grp8quesproducts = Grprelatedprod.get('8');}
            if(Grprelatedprod.get('9')!= null ){Grp9quesproducts = Grprelatedprod.get('9');}
            if(Grprelatedprod.get('10')!= null ){Grp10quesproducts = Grprelatedprod.get('10');}
        }else{
            PageReference c_ops_iap_reviewandsubmit= New PageReference('/apex/C_OPS_IAP_REVIEWANDSUBMIT');
            c_ops_iap_reviewandsubmit.setRedirect(false);
            return c_ops_iap_reviewandsubmit;
        }

        if(quesquestionswrapperlist == null  || quesquestionswrapperlist.size()==0  ){
           
                PageReference c_ops_iap_reviewandsubmit= New PageReference('/apex/C_OPS_IAP_REVIEWANDSUBMIT');
                c_ops_iap_reviewandsubmit.setRedirect(false);
                return c_ops_iap_reviewandsubmit;
        }
        if(Grp1quesproducts != ''){Grp1quesproducts = '<b>' + Grp1quesproducts + '</b>';}
        if(Grp2quesproducts != ''){Grp2quesproducts = '<b>' + Grp2quesproducts + '</b>';}
        if(Grp3quesproducts != ''){Grp3quesproducts = '<b>' + Grp3quesproducts + '</b>';}
        if(Grp4quesproducts != ''){Grp4quesproducts = '<b>' + Grp4quesproducts + '</b>';}
        if(Grp5quesproducts != ''){Grp5quesproducts = '<b>' + Grp5quesproducts + '</b>';}
        if(Grp6quesproducts != ''){Grp6quesproducts = '<b>' + Grp6quesproducts + '</b>';}
        if(Grp7quesproducts != ''){Grp7quesproducts = '<b>' + Grp7quesproducts + '</b>';}
        if(Grp8quesproducts != ''){Grp8quesproducts = '<b>' + Grp8quesproducts + '</b>';}
        if(Grp9quesproducts != ''){Grp9quesproducts = '<b>' + Grp9quesproducts + '</b>';}
        if(Grp10quesproducts != ''){Grp10quesproducts = '<b>' + Grp10quesproducts + '</b>';}
        system.debug('-->Grp6quesproducts'+quesquestionswrapperlist);
        return null;
    }
    
    public void resetaplstatusforedit(){
        if(quesquestionswrapperlist != null && quesquestionswrapperlist.size() >0){
            for(productquestionswrapper r: productquestionswrapperList){
                if(r.apl.Denied_for_which_Question_Type__c == 'Questionnaire' && r.apl.Request_Status__c == 'Denied'){
                    system.debug('Inside the loop');
                    r.apl.Denial_Reason_Code__c  = '';
                    r.apl.Request_Status__c = '';
                }
            }
        }
    }
    
    public Map<C_Ops_SPLOA_Questions__c,List<C_Ops_SPLOA_Sub_Question__c>> getQueQuesbasedonGroup(String GroupName){
        QuesquesMap = new Map<C_Ops_SPLOA_Questions__c,List<C_Ops_SPLOA_Sub_Question__c>>();
        string accesstypeselected='';
        if(GroupandAccessTypMap.size()>0){
            accesstypeselected = GroupandAccessTypMap.get(GroupName);
        }
        
        for(C_Ops_SPLOA_Questions__c question:Allquestions){
            List<String> grouplist = new List<string>(); 
            List<String> accesslist = new List<string>();
            List<C_Ops_SPLOA_Sub_Question__c> subquestionlist = new List<C_Ops_SPLOA_Sub_Question__c>();
            if(question.Group__c!=null){
                String QuesGroup = question.Group__c;
                String quesAccesstype=question.IAP_Access_Type__c;
                grouplist = QuesGroup.split(';');
                if(string.isnotempty(quesAccesstype))
                    accesslist=quesAccesstype.split(';');
                if(grouplist!=null && grouplist.size() > 0 && grouplist.contains(GroupName) && question.Question_Type__c == 'Questionnaire' &&  getquestioncheck(question.C_Ops_SPLOA_Applicable_To__c)){
                    if(question.Answer__c != ''){question.Answer__c = '';}
                    if(question.C_Ops_SPLOA_Has_Subquestion__c)
                        for(C_Ops_SPLOA_Sub_Question__c subquestion :Allsubquestions ){                        
                            string ids=subquestion.Parent_Question__c;                      
                            if(ids.substring(0, 15) == question.IDbackup__c && question.C_Ops_SPLOA_Has_Subquestion__c == true ){
                                if(subquestion.Answer__c != ''){subquestion.Answer__c = '';}
                                List<String> subgrouplist = new List<string>();
                                String subQuesGroup ='';
                                if(string.isnotempty(subquestion.APL_Group__c)) {
                                    subQuesGroup = subquestion.APL_Group__c;
                                }else {
                                    subQuesGroup = question.Group__c;
                                }
                                subgrouplist = subQuesGroup.split(';');
                                if(subgrouplist!=null && subgrouplist.size() > 0 && subgrouplist.contains(GroupName) ){
                                    subquestionlist.add(subquestion );
                                }
                            }
                        }
                    if(accesslist == null || accesslist.size()<1 ){
                        QuesquesMap.put(question,subquestionlist );
                    }else{
                        if(accesslist.contains(accesstypeselected)|| accesslist.contains('ALL')){
                            QuesquesMap.put(question,subquestionlist );
                        }
                    }                    
                }
            }
        }        
        system.debug('--->QuesquesMap'+QuesquesMap.size());
        return QuesquesMap ;
    }
    
    public void checkBusinessRules() {
        Set<String> GroupNames = new Set<String>();
        GroupandDenialCodeatpharm = new Map<String,String>();
        /*  for(  pharmacyquestionswrapper pharmwrap  : pharmqueswrapperlist){  
GroupNames.add(pharmwrap.Grp); 
for(Business_Rule__c br:businessrulslist){

if((br.C_Ops_IAP_Questions_List__r.C_Ops_SPLOA_Question_Label__c == pharmwrap.Pharmques.C_Ops_SPLOA_Question_Label__c ||
br.C_Ops_IAP_Sub_Questions__r.Question_Label__c  == pharmwrap.Pharmques.C_Ops_SPLOA_Question_Label__c)
&& pharmwrap.Pharmques.Answer__c == br.Value_for_Outcome__c && br.Group__c.contains(pharmwrap.Grp)){
GroupandDenialCodeatpharm.put(pharmwrap.Grp,br.Denial_Reason_Code__c);
}
}
}*/
        //Adding Group 5 and its Denial Reason Code
        // GroupandDenialCodeatpharm.put('5','Not Accepting additional SP');
        //Denied APLs needs to be updated
        for(productquestionswrapper wrp:productquestionswrapperlist){
            if(ProductnameandGroupName.get(wrp.apl.C_Ops_SPLOA_Product_Name__c.touppercase())!= null ){
                String GroupName = ProductnameandGroupName.get(wrp.apl.C_Ops_SPLOA_Product_Name__c.touppercase());
                if( GroupandDenialCodeatpharm.get(GroupName)!= null ){
                    wrp.apl.Request_Status__c = 'Denied';
                    wrp.apl.Denial_Reason_Code__c = GroupandDenialCodeatpharm.get(GroupName);
                    wrp.apl.Denied_for_which_Question_Type__c = 'Pharmacy Questions';
                }
            }
        }
        checkifRequestDenied();
    }    
    public void assignAccesType() {
        
        system.debug('Assigning the Access Type');
        GroupandAccessTypMap = new Map<String,String>();
        
        Boolean firstquesmatched = false;
        Map<String,String> grpPharmanswers = new Map<String,String>();
        
        /*   for(Access_Type_Calculation__c accTyp : accessTypeList){
for(  pharmacyquestionswrapper pharmwrap  : pharmqueswrapperlist){  
//List<String> 
String accTypgroup = accTyp.APL_Group__c;
//    if(pharmwrap.Grp == accTyp.Group__c){
if( accTypgroup.contains(pharmwrap.Grp)){
if(pharmwrap.Pharmques.C_Ops_SPLOA_Question_Label__c ==  'Is your pharmacy a department, affiliate or subsidiary of a hospital, hospital system or clinic?' &&
(accTyp.Is_your_pharmacy_a_department_affiliate__c  == pharmwrap.Pharmques.Answer__c || accTyp.Is_your_pharmacy_a_department_affiliate__c =='' || accTyp.Is_your_pharmacy_a_department_affiliate__c == null)){
firstquesmatched = true;
} 
if(pharmwrap.Pharmques.C_Ops_SPLOA_Question_Label__c ==  'Is your pharmacy accredited? The accepted national certification: URAC, ACHC, Joint Commission, NABP, CHAP.' &&
accTyp.Is_your_pharmacy_accredited_The_accepte__c == pharmwrap.Pharmques.Answer__c && firstquesmatched == true){
GroupandAccessTypMap.put(pharmwrap.Grp,accTyp.Name);
} 

}
}
firstquesmatched = false;
}*/
        
        //Assign Access Type to APL
        for(productquestionswrapper wrp:productquestionswrapperlist){
            system.debug(ProductnameandGroupName.get(wrp.apl.C_Ops_SPLOA_Product_Name__c.touppercase()));
            if(ProductnameandGroupName.get(wrp.apl.C_Ops_SPLOA_Product_Name__c.touppercase())!= null ){
                String GroupName = ProductnameandGroupName.get(wrp.apl.C_Ops_SPLOA_Product_Name__c.touppercase());
                if( GroupandAccessTypMap.get(GroupName)!= null && wrp.apl.Request_Status__c != 'Denied'){
                    wrp.apl.Customer_Access_Type__c = GroupandAccessTypMap.get(GroupName);
                    wrp.apl.Request_Status__c ='New';
                }
            }
        }
        system.debug('Group and Access Type Map'+GroupandAccessTypMap);
        if(GroupandAccessTypMapbackup != GroupandAccessTypMap){
            refreshquestion=true;
        }
        GroupandAccessTypMapbackup = GroupandAccessTypMap;
    }   
    //Method to Navigate to Pharmacy Info Page from Questionnaire Page
    public PageReference prevpagenavigation() {
        PageReference C_OPS_IAP_QUES_PAGE= New PageReference('/apex/C_OPS_IAP_CONTACT_INFOPG');
        C_OPS_IAP_QUES_PAGE.setRedirect(false);
        return C_OPS_IAP_QUES_PAGE;
    }
    
    public PageReference  reviewandsubmitnavigation(){  
        Boolean haveError = false;
        if(quesquestionswrapperlist.size() >0){
            for(  quesquestionswrapper queswrap  : quesquestionswrapperlist){
                string str='';
                for(SelectOption opt:queswrap.selectlistOption){
                    system.debug(opt);
                    system.debug(opt.getValue());
                    str=str+opt.getValue()+';';
                }
                if( queswrap.queques.C_Ops_SPLOA_Data_Type__c=='MultiPicklist'){
                    queswrap.queques.Answer__c=str;
                }
                
                if(string.isBlank(queswrap.queques.Answer__c)){
                    haveError = true;
                    errorMessage = 'Please answer all questions';
                    handleError(errorMessage);
                }
                if(queswrap.queques.Answer__c == 'Yes'){
                    for(C_Ops_SPLOA_Sub_Question__c subques: queswrap.subqueslist ){
                        if( subques.C_Ops_SPLOA_Data_Type__c=='MultiPicklist'){
                            subques.Answer__c=str;
                        }
                        if(string.isBlank(subques.Answer__c)){
                            haveError = true;
                            errorMessage = 'Please answer all questions';
                            handleError(errorMessage);
                        }
                    }
                }
            }   
        }
        if(haveError  != true){
            checkBusinessRulesques();
            PageReference c_ops_iap_reviewandsubmit= New PageReference('/apex/C_OPS_IAP_REVIEWANDSUBMIT');
            c_ops_iap_reviewandsubmit.setRedirect(false);
            return c_ops_iap_reviewandsubmit;
            
        } 
        haveError = false;    
        return null;        
    }        
    public void checkBusinessRulesques() {
        //    Set<String> GroupNames = new Set<String>();
        GroupandDenialCodeatques = new Map<String,String>();
        for(quesquestionswrapper queswrap  :  quesquestionswrapperlist){  
            //    GroupNames.add(queswrap.Grp); 
            for(Business_Rule__c br:businessrulslist){
                
                if((br.C_Ops_IAP_Questions_List__r.C_Ops_SPLOA_Question_Label__c == queswrap.queques.C_Ops_SPLOA_Question_Label__c ||
                    br.C_Ops_IAP_Sub_Questions__r.Question_Label__c  == queswrap.queques.C_Ops_SPLOA_Question_Label__c) && queswrap.queques.Answer__c == br.Value_for_Outcome__c && br.Group__c.contains(queswrap.Grp)&& (br.Access_Type__c == '' ||br.Access_Type__c == null) ){
                        GroupandDenialCodeatques.put(queswrap.Grp,br.Denial_Reason_Code__c);
                    }
                if((br.C_Ops_IAP_Questions_List__r.C_Ops_SPLOA_Question_Label__c == queswrap.queques.C_Ops_SPLOA_Question_Label__c ||
                    br.C_Ops_IAP_Sub_Questions__r.Question_Label__c  == queswrap.queques.C_Ops_SPLOA_Question_Label__c) && queswrap.queques.Answer__c == br.Value_for_Outcome__c && br.Group__c.contains(queswrap.Grp) && br.Access_Type__c != '' &&   br.Access_Type__c != null){
                        //  system.debug(br.Name);
                        String AccessType = br.Access_Type__c ;
                        List<String> AccessTypelist = new List<String>();
                        AccessTypelist  = AccessType.split(';');
                        if(GroupandAccessTypMap!= null && GroupandAccessTypMap.get(queswrap.Grp) != null && AccessTypelist.contains(GroupandAccessTypMap.get(queswrap.Grp)))
                            GroupandDenialCodeatques.put(queswrap.Grp,br.Denial_Reason_Code__c);
                    }  
                //  system.debug('queswrap.queques.Answer__c-----+'+queswrap.queques.Answer__c);
                // system.debug('GroupandDenialCodeatques-----+'+GroupandDenialCodeatques);
                if(queswrap.subqueslist != null && queswrap.queques.Answer__c =='Yes'){
                    for(C_Ops_SPLOA_Sub_Question__c subques  : queswrap.subqueslist){
                        if(subques.Question_Label__c ==  br.C_Ops_IAP_Sub_Questions__r.Question_Label__c && subques.Answer__c == br.Value_for_Outcome__c && br.Group__c.contains(queswrap.Grp)&& (br.Access_Type__c == '' ||br.Access_Type__c == null) ){
                            GroupandDenialCodeatques.put(queswrap.Grp,br.Denial_Reason_Code__c);
                        }
                        
                    }
                }
            }
        }
        system.debug('GroupandDenialCodeatques-----+'+GroupandDenialCodeatques);
        //Denied APL needs to be updated
        for(productquestionswrapper wrp:productquestionswrapperlist){
            if(ProductnameandGroupName.get(wrp.apl.C_Ops_SPLOA_Product_Name__c.touppercase())!= null ){
                String GroupName = ProductnameandGroupName.get(wrp.apl.C_Ops_SPLOA_Product_Name__c.touppercase());
                if( GroupandDenialCodeatques.get(GroupName)!= null ){
                    wrp.apl.Request_Status__c = 'Denied';
                    wrp.apl.Denial_Reason_Code__c = GroupandDenialCodeatques.get(GroupName);
                    wrp.apl.Denied_for_which_Question_Type__c = 'Questionnaire';
                }
            }
        }
        
    }
    public void resetaplstatusforeditprod(){
        if(quesquestionswrapperlist != null && quesquestionswrapperlist.size() >0){
            for(productquestionswrapper r: productquestionswrapperList){
                if(r.apl.Denied_for_which_Question_Type__c == 'Questionnaire' && r.apl.Request_Status__c == 'Denied'){
                    system.debug('Inside the loop');
                    r.apl.Denial_Reason_Code__c  = '';
                    r.apl.Request_Status__c = '';
                }
            }
        }
        /*  if(pharmqueswrapperlist != null && pharmqueswrapperlist.size()>0){
for(productquestionswrapper r: productquestionswrapperList){
if(r.apl.Denied_for_which_Question_Type__c == 'Pharmacy Questions' && r.apl.Request_Status__c == 'Denied'){
r.apl.Denial_Reason_Code__c  = '';
r.apl.Request_Status__c = '';
}
}
}*/
        if(productquestionswrapperList!= null && productquestionswrapperList.size()>0){
            for(productquestionswrapper r: productquestionswrapperList){
                if(r.apl.Denied_for_which_Question_Type__c == 'Product Question' && r.apl.Request_Status__c == 'Denied'){
                    r.apl.Denial_Reason_Code__c  = '';
                    r.apl.Request_Status__c = '';
                }
            }
        }
    }    
    //********************
    //Methods related to Review and Submit Page
    public PageReference returntocontactinfopage() {
        resetaplstatusforeditprod();
        PageReference c_ops_iap_con_infopg = New PageReference('/apex/C_OPS_IAP_CONTACT_INFOPG');
        c_ops_iap_con_infopg.setRedirect(false);
        return c_ops_iap_con_infopg;
    }
    public PageReference returntopharminfopage(){
        PageReference C_OPS_IAP_QUES_PAGE= New PageReference('/apex/C_OPS_IAP_QUES_PAGE');
        C_OPS_IAP_QUES_PAGE.setRedirect(false);
        return C_OPS_IAP_QUES_PAGE;
    }    
    //productquestionswrapper
    public PageReference returntoquesinfopage(){
        if(addpharmacayOption == true){
            PageReference c_ops_iap_con_infopg = New PageReference('/apex/C_OPS_IAP_CONTACT_INFOPG');
            c_ops_iap_con_infopg .setRedirect(false);
            return c_ops_iap_con_infopg ;
        }
        else if(quesquestionswrapperlist != null && quesquestionswrapperlist.size()>0){
            PageReference c_ops_iap_ques_page = New PageReference('/apex/C_OPS_IAP_QUES_PAGE');
            c_ops_iap_ques_page .setRedirect(false);
            return c_ops_iap_ques_page  ;
        }
        /*  else if(pharmqueswrapperlist != null && pharmqueswrapperlist.size() > 0){
PageReference C_OPS_IAP_QUES_PAGE= New PageReference('/apex/C_OPS_IAP_QUES_PAGE');
C_OPS_IAP_QUES_PAGE.setRedirect(false);
return C_OPS_IAP_QUES_PAGE;
}*/
        else if(productquestionswrapperlist != null && productquestionswrapperlist.size() > 0){
            PageReference C_OPS_IAP_QUES_PAGE= New PageReference('/apex/C_OPS_IAP_CONTACT_INFOPG');
            C_OPS_IAP_QUES_PAGE.setRedirect(false);
            return C_OPS_IAP_QUES_PAGE;
        }
        return null;
    }   
    
    //Check for DEA Blacklis tand update the flags
    public void updateDEAflags(){
        if(productquestionswrapperlist!= null && productquestionswrapperlist.size() >0){
            String APLName  = '';
            for(productquestionswrapper prodwrp : productquestionswrapperlist){
                if(!APLName.contains(prodwrp.apl.Name))
                    APLName = APLName + prodwrp.apl.Name+ ';' ;
            }
            
            APLName = APLName.removeEnd(';');
            
            mainRequest.APLs_on_the_Request__c = APLName ;
        }
        if(DEAexceptionlist!= null && DEAexceptionlist.size() >0  ){
            system.debug('Inside the DEA EXception List'+DEAexceptionlist);
            for(C_Ops_IAPDEA_Number__c deaexp : DEAexceptionlist){
                String deaexprcd = deaexp.DEA_Number__c ;
                if(deaexprcd.equalsIgnoreCase(mainRequest.C_Ops_SPLOA_DEA_Number__c)){
                    mainRequest.Primary_DEA_Hit_with_Blacklist_backend__c = true;
                }
                if(AddPharmList != null && AddPharmList.size() >0){
                    system.debug('Inside the Add Pharmacy loop');
                    for(C_Ops_SPLOA_Additional_Pharmacy__c addPharm :AddPharmList){
                        if(deaexprcd.containsignorecase(addPharm.C_Ops_SPLOA_DEA_Number__c)){
                            addPharm.Additional_Site_DEA_Hit_with_Bl_Backend__c = true;
                            mainRequest.Additional_Site_DEA_Hit_with_Blacklist_b__c= true;
                        }
                    }
                }
            }
        }
    }
    
    //Creation of records into DB: SPLOA Requests ,Pharmacy and Questionnaire Questions, Sub questions , Attach the Doc to the Request , Create and Attach PDF
    public void createRecords(){
        errorMessage ='';
        IAP_Controller_internal internalsave= new IAP_Controller_internal();
        //  system.debug(mainRequest.Authorised__c+mainRequest.Signee_First_Name__c+mainRequest.Signee_Last_Name__c+mainRequest.Signee_Title__c);
        if(mainRequest.Authorised__c != true ||String.IsBlank(mainRequest.Signee_First_Name__c)||String.IsBlank(mainRequest.Signee_Last_Name__c)||String.IsBlank(mainRequest.Signee_Title__c)){
            errorMessage ='Please fill in the Authorization Information';
            handleError(errorMessage);           
        }
        
        if(!this.recaptchaVerified){
            verifyCaptcha();
        }        
        //error happened, return to current page
        if(!recaptchaVerified || (!String.IsBlank(errorMessage))) return;
        if(recaptchaVerified && errorMessage =='' ) {
            mainRequest.Submission_Date_Time__c= system.now();
            if(string.isBlank( mainRequest.Request_Type__c))
                mainRequest.Request_Type__c = getRequestType();
            system.debug('---->'+mainRequest.Request_Type__c);
            //Assigning the list of Products to Main Request
            updateDEAflags();
            String mainReqprodlist ='';
            if(productquestionswrapperlist!= null && productquestionswrapperlist.size()>0){               
                for(productquestionswrapper prodwrp : productquestionswrapperlist){
                    
                    if( prodwrp.apl.Name != null){
                        for(C_Ops_SPLOA_Product__c prod: productslsts){
                            if(prod.APL__c== prodwrp.apl.Name){
                                if(!mainReqprodlist.contains(prod.Name))
                                    mainReqprodlist = mainReqprodlist  + prod.Name + ', ' ; 
                                if(prod.Group__c == '5'){
                                    mainRequest.Manual_review_required__c = true;
                                }
                            }
                        }
                    }
                    if(prodwrp.apl.Request_Status__c != 'Denied' && string.isblank(prodwrp.apl.Customer_Access_Type__c)){prodwrp.apl.Customer_Access_Type__c = 'Not Identified'; }
                    //  if(ProductnameandGroupName.get(prodwrp.apl.C_Ops_SPLOA_Product_Name__c.touppercase()) == '5'  && prodwrp.apl.Customer_Access_Type__c == 'Not Identified'){prodwrp.apl.Request_Status__c = 'Denied';}
                    if(prodwrp.apl.Request_Status__c != 'Denied'){prodwrp.apl.Request_Status__c = 'New';}
                }
                
            }            
            //Assigning main Request based on APL status
            List<APL__c> APLlists= new List<APL__c>();
            if(productquestionswrapperlist != null)
                for(productquestionswrapper prodwrp : productquestionswrapperlist){
                    APLlists.add(prodwrp.apl );
                }
            
            Integer deniedAPLcount =0;
            if(APLlists!= null && APLlists.size() >0){
                for(APL__c apl:APLlists){
                    if(apl.Request_Status__c == 'New'){ mainRequest.C_Ops_SPLOA_Request_Status__c = 'New';}
                    
                    else if(apl.Request_Status__c == 'Denied') {deniedAPLcount++;}
                }
                
            }
            if(APLlists.size() == deniedAPLcount && APLlists.size() >0){
                mainRequest.Date_Denied_If_Applicable__c = system.now();
                mainRequest.C_Ops_SPLOA_Request_Status__c = 'Denied';
            }
            mainReqprodlist = mainReqprodlist.removeEnd(', ');
            mainRequest.Related_Product_s__c = mainReqprodlist ;
            
            try{
                if( reqTyp == 'update' ){
                    mainRequestId = oldRequest.Id;
                    oldRequest   = mainRequest.clone(false,true);
                    oldRequest.id=corrReqId;
                    if(oldRequest.C_Ops_SPLOA_Request_Status__c != 'Denied')
                        oldRequest.C_Ops_SPLOA_Request_Status__c = 'In Process';
                    oldRequest.Status_Category__c='Revised by Customer';
                    if (oldRequest.Request_PDF_Version_Number__c  != null){
                        oldRequest.Request_PDF_Version_Number__c += 1;
                    } else {
                        oldRequest.Request_PDF_Version_Number__c = 1;
                    }
                    oldRequest=internalsave.saverequest(oldRequest);
                    //update oldRequest;		
                    mainRequest=oldRequest;
                }else{
                    mainRequest=internalsave.saverequest(mainRequest);
                    //insert mainRequest;
                }                
            }catch(DmlException e) {
                
                errorMessage ='The following exception has occurred: ' + e.getMessage();
                System.debug(errorMessage);
                handleError(errorMessage); 
            }
            mainRequestId = mainRequest.Id;
            if(mainRequestId != null){
                PrimaryPharmacydetails.C_Ops_SPLOA_DEA_Number__c = mainRequest.C_Ops_SPLOA_DEA_Number__c;
                PrimaryPharmacydetails.Pharmacy_Name__c = mainRequest.C_Ops_SPLOA_Pharmacy_Name__c;
                PrimaryPharmacydetails.C_Ops_SPLOA_Street_Address__c = mainRequest.C_Ops_SPLOA_Street_Address__c;
                PrimaryPharmacydetails.C_Ops_SPLOA_Street_Address_2__c = mainRequest.C_Ops_SPLOA_Street_Address_2__c;
                PrimaryPharmacydetails.C_Ops_SPLOA_City__c = mainRequest.C_Ops_SPLOA_City__c;
                PrimaryPharmacydetails.C_Ops_SPLOA_State__c = mainRequest.State__c;
                PrimaryPharmacydetails.C_Ops_SPLOA_Zip__c = mainRequest.C_Ops_SPLOA_Zip__c;  
                PrimaryPharmacydetails.Request_Status__c='New';
                PrimaryPharmacydetails.Denial_Reason_Code__c='';
                PrimaryPharmacydetails.Is_Primary_Pharmacy__c= true;
                PrimaryPharmacydetails.C_Ops_SPLOA_Request__c = mainRequestId;
                //PrimaryPharmacydetails.Accreditation__c = mainRequest.Accreditation__c;
                for( pharmacyquestionswrapper prodquemwrap:pharmqueswrapperlist){  
                    if(prodquemwrap.grp == mainRequest.C_Ops_SPLOA_DEA_Number__c )
                        if(prodquemwrap.subqueslist != null && prodquemwrap.Pharmques.Answer__c == 'Yes' ){
                            for(C_Ops_SPLOA_Sub_Question__c subques: prodquemwrap.subqueslist ){                  
                                if( subques.C_Ops_SPLOA_Data_Type__c=='MultiPicklist' && prodquemwrap.Pharmques.IDbackup__c == subques.Parent_Question__c){
                                    PrimaryPharmacydetails.Accreditation__c= subques.Answer__c;
                                }
                            }
                        }
                    
                }  
                
                if(AddPharmList == null )
                    AddPharmList= new list<C_Ops_SPLOA_Additional_Pharmacy__c>();
                AddPharmList.add(PrimaryPharmacydetails);
                integer pharmaciesdenied=0;
                string pharmaciesdeniedreason='';
                if(AddPharmList != null && AddPharmList.size()>0){
                    for(C_Ops_SPLOA_Additional_Pharmacy__c addPharm :AddPharmList){
                        addPharm.C_Ops_SPLOA_Request__c = mainRequestId;
                        addPharm.Request_Status__c='New';
                        addPharm.Denial_Reason_Code__c='';
                        for(pharmacyquestionswrapper pharmwrap  :pharmqueswrapperlist ){
                            if( pharmwrap.Grp == addPharm.C_Ops_SPLOA_DEA_Number__c){
                                if(string.isnotBlank(pharmwrap.Deniedreason)){
                                    pharmaciesdenied ++;
                                    addPharm.Request_Status__c='Denied';
                                    addPharm.Denial_Reason_Code__c=pharmwrap.Deniedreason;
                                    pharmaciesdeniedreason=pharmwrap.Deniedreason;
                                }
                            }
                        }
                    }
                    
                    AddPharmList= internalsave.savephar(AddPharmList);
                    if( reqTyp == 'update' ){
                        List<C_Ops_SPLOA_Additional_Pharmacy__c > AddPharmoldList2 = new List<C_Ops_SPLOA_Additional_Pharmacy__c >();         
                        List<C_Ops_SPLOA_Additional_Pharmacy__c > Pharmoldtodel = new List<C_Ops_SPLOA_Additional_Pharmacy__c >();         
                        AddPharmoldList2 = internalsave.getadditionalphar(corrReqId); 
                        for(C_Ops_SPLOA_Additional_Pharmacy__c oldPharm :AddPharmoldList2){
                            boolean notfound=true;
                            for(C_Ops_SPLOA_Additional_Pharmacy__c addPharm :AddPharmList){
                                if(oldPharm.id==addPharm.id)
                                    notfound=false;
                            }
                            if(notfound)
                                Pharmoldtodel.add(oldPharm);
                        }
                        if(Pharmoldtodel.size()>0)
                            internalsave.delphar(Pharmoldtodel);
                        
                    }
                    
                    // upsert AddPharmList;
                }               
                
                if(pharmaciesdenied ==1){
                    mainRequest.C_Ops_SPLOA_Request_Status__c = 'Denied';
                    mainRequest.Denial_Reason__c=pharmaciesdeniedreason;
                    mainRequest=internalsave.saverequest(mainRequest);
                }else if(pharmaciesdenied > 1){
                    mainRequest.C_Ops_SPLOA_Request_Status__c = 'Denied';
                    mainRequest.Denial_Reason__c='One or more pharmacies denied';
                    mainRequest=internalsave.saverequest(mainRequest);
                }
                
                //APL check for Main Request status
                List<APL__c> APLsList = new List<APL__c>();
                set<APL__c> APLsset = new set<APL__c>();
                if(productquestionswrapperlist!= null && productquestionswrapperlist.size()>0){
                    for(productquestionswrapper prodwrp : productquestionswrapperlist){
                        if(prodwrp.apl.Request_Status__c != 'Denied' && prodwrp.apl.Customer_Access_Type__c ==null){prodwrp.apl.Customer_Access_Type__c = 'Not Identified';}
                        //  if(ProductnameandGroupName.get(prodwrp.apl.C_Ops_SPLOA_Product_Name__c.touppercase()) == '5' && prodwrp.apl.Customer_Access_Type__c == 'Not Identified' ){prodwrp.apl.Request_Status__c = 'Denied';}
                        if(prodwrp.apl.Request_Status__c != 'Denied'){prodwrp.apl.Request_Status__c = 'New';}
                        prodwrp.apl.C_Ops_IAP_Submitted_Requests__c = mainRequestId;
                        APLsset.add(prodwrp.apl);
                    }
                    APLsList.addall(APLsset);
                    APLsset = new set<APL__c>();
                    if( reqTyp == 'update' ){
                        list<APL__C> existapl=[SELECT id,name,C_Ops_IAP_Submitted_Requests__c,Product__c,C_Ops_SPLOA_Product_Name__c from APL__C where C_Ops_IAP_Submitted_Requests__c =: mainRequestId];
                        list<APL__C> addapl= new list<APL__C>();
                        list<APL__C> upadteapl= new list<APL__C>();
                        for(APL__C aplsnew:APLsList){
                            boolean oldrecordfound= false;
                            
                            for(integer indexlist=0;indexlist <existapl.size();indexlist++){
                                if(existapl[indexlist].name==aplsnew.name){
                                    oldrecordfound=true; 
                                    aplsnew.id=existapl[indexlist].id;
                                    upadteapl.add(aplsnew);
                                    existapl.remove(indexlist);
                                    indexlist--;
                                }                                    
                            }
                            
                            if(!oldrecordfound)
                                addapl.add(aplsnew);
                        }
                        if(existapl.size()>0)
                            internalsave.delapl(existapl);                         
                        if(addapl.size()>0)
                            addapl=internalsave.saveapl(addapl);
                        //   Insert addapl;
                        if(upadteapl.size()>0)
                            upadteapl=internalsave.saveapl(upadteapl);
                        //  update upadteapl;
                        APLsList= new list<APL__C>();
                        APLsList.addall(addapl);                       
                        APLsList.addall(upadteapl);
                    }else 		
                        APLsList=internalsave.saveapl(APLsList);
                    // Insert APLsList;
                }
                Map<String,Id> APlNameandIdMap = new Map<String,Id>();
                if(APLsList!= null && APLsList.size() >0){
                    for(APL__c apl:APLsList){
                        APlNameandIdMap.put(apl.Name,apl.Id);
                    }
                }
                
                List<C_Ops_SPLOA_Questionnaire_Questions__c> productqueslist = new List<C_Ops_SPLOA_Questionnaire_Questions__c>();
                List<C_Ops_SPLOA_Questionnaire_Questions__c> productsubqueslist = new List<C_Ops_SPLOA_Questionnaire_Questions__c>();
                
                if(productquestionswrapperlist!= null && productquestionswrapperlist.size()>0){
                    for(productquestionswrapper prodwrp : productquestionswrapperlist){
                        C_Ops_SPLOA_Questionnaire_Questions__c prodques = new C_Ops_SPLOA_Questionnaire_Questions__c();
                        prodques.Data_type__c = prodwrp.Prodques.C_Ops_SPLOA_Data_Type__c;
                        prodques.C_Ops_SPLOA_Request__c = mainRequestId ;
                        prodques.Question_Label__c = prodwrp.Prodques.C_Ops_SPLOA_Question_Label__c;
                        prodques.Answer__c = prodwrp.Prodques.Answer__c;
                        prodques.Question_Type__c = 'Product Question';
                        prodques.C_Ops_SPLOA_Question_Display_Order__c = prodwrp.Prodques.C_Ops_SPLOA_Question_Display_Order__c ;
                        prodques.Parent_Question_Name__c= ProductQuesNameandlabel.get(prodwrp.Prodques.C_Ops_SPLOA_Question_Label__c) ;
                        prodques.Backend_to_store_products__c = prodwrp.apl.Name;
                        if(prodwrp.apl.Name!= null){prodques.APL__c = APlNameandIdMap.get(prodwrp.apl.Name);}
                        // Included Validation flag for all the questions
                        if(prodwrp.Prodques.C_Ops_SPLOA_Data_Type__c == 'checkbox'  &&( prodwrp.Prodques.Answer__c == prodwrp.Prodques.C_Ops_SPLOA_Credential__c || ( prodwrp.Prodques.C_Ops_SPLOA_Credential__c == '' || prodwrp.Prodques.C_Ops_SPLOA_Credential__c == null))){
                            prodques.Validation_flag__c = true;
                        }
                        productqueslist.add(prodques); 
                        if(prodwrp.subqueslist!=null){
                            for(C_Ops_SPLOA_Sub_Question__c subques  : prodwrp.subqueslist){
                                if(prodwrp.Prodques.Answer__c  =='Yes' && prodwrp.Prodques.C_Ops_SPLOA_Has_Subquestion__c == true && prodwrp.Prodques.IDbackup__c == subques.Parent_Question__c){
                                    C_Ops_SPLOA_Questionnaire_Questions__c prodsubques = new C_Ops_SPLOA_Questionnaire_Questions__c();
                                    prodsubques.Data_type__c = subques.C_Ops_SPLOA_Data_Type__c;
                                    prodsubques.C_Ops_SPLOA_Request__c = mainRequestId ;
                                    prodsubques.Question_Label__c = subques.Question_Label__c;
                                    prodsubques.Answer__c = subques.Answer__c;
                                    prodsubques.Question_Type__c = 'Product Question';
                                    prodsubques.C_Ops_SPLOA_Question_Display_Order__c = subques.C_Ops_SPLOA_Question_Display_Order__c ;
                                    prodsubques.Parent_Question_Name__c=  ProductQuesNameandlabel.get(prodwrp.Prodques.C_Ops_SPLOA_Question_Label__c);
                                    prodsubques.Backend_to_store_products__c = prodwrp.apl.Name;
                                    //Included Validation flag for all the questions
                                    if(subques.C_Ops_SPLOA_Data_Type__c == 'checkbox' &&( subques.Answer__c == subques.C_Ops_SPLOA_Credential__c || (subques.C_Ops_SPLOA_Credential__c == '' || subques.C_Ops_SPLOA_Credential__c == null))){
                                        prodsubques.Validation_flag__c = true;
                                    }
                                    productsubqueslist.add(prodsubques);
                                }
                            }
                        }
                    }
                }
                list<C_Ops_SPLOA_Questionnaire_Questions__c> existapl= new list<C_Ops_SPLOA_Questionnaire_Questions__c>();
                list<APL_Questionnaire__c> existaplques=new list<APL_Questionnaire__c>();
                if( reqTyp == 'update' ){
                    //  existapl=[SELECT id,name,Question_Label__c,Backend_to_store_products__c,Group__c from C_Ops_SPLOA_Questionnaire_Questions__c where C_Ops_SPLOA_Request__c =: mainRequestId];
                    existapl=internalsave.getexistingQuestions( mainRequestId);
                }
                if(productqueslist.size()>0){
                    if( reqTyp == 'update' ){
                        for(C_Ops_SPLOA_Questionnaire_Questions__c aplsnew:productqueslist){
                            for(C_Ops_SPLOA_Questionnaire_Questions__c aplsold:existapl){
                                if(aplsold.Question_Label__c==aplsnew.Question_Label__c && aplsold.Backend_to_store_products__c==aplsnew.Backend_to_store_products__c ){
                                    aplsnew.id=aplsold.id;                                     
                                }                                
                            }
                        }
                        // upsert productqueslist;
                        productqueslist=internalsave.savequestions(productqueslist);
                        
                    }else 		
                        productqueslist=internalsave.savequestions(productqueslist);
                    //  Insert productqueslist;
                }
                
                if(productsubqueslist.size()>0){
                    for(C_Ops_SPLOA_Questionnaire_Questions__c productsubques : productsubqueslist)
                        for(C_Ops_SPLOA_Questionnaire_Questions__c prodques: productqueslist){
                            if(productsubques.Parent_Question_Name__c == prodques.Parent_Question_Name__c && productsubques.Backend_to_store_products__c == prodques.Backend_to_store_products__c  )
                                productsubques.C_Ops_SPLOA_Questionnaire__c = prodques.Id;
                        }
                    if( reqTyp == 'update' ){
                        for(C_Ops_SPLOA_Questionnaire_Questions__c aplsnew:productsubqueslist){
                            for(C_Ops_SPLOA_Questionnaire_Questions__c aplsold:existapl){
                                if(aplsold.Question_Label__c==aplsnew.Question_Label__c && aplsold.Backend_to_store_products__c==aplsnew.Backend_to_store_products__c ){
                                    aplsnew.id=aplsold.id;                                     
                                }                                
                            }
                        }
                        //upsert productsubqueslist;
                        productsubqueslist=internalsave.savequestions(productsubqueslist);
                    }else 		
                        productsubqueslist=internalsave.savequestions(productsubqueslist);
                    //  Insert productsubqueslist;                    
                }                
                //APL Questionnaire Records needs to be created
                List<APL_Questionnaire__c > aplqueslist = new List<APL_Questionnaire__c >();
                for(C_Ops_SPLOA_Questionnaire_Questions__c  prodques :productqueslist){
                    APL_Questionnaire__c aplques = new APL_Questionnaire__c();
                    aplques.C_Ops_IAP_Questionnaire__c = prodques.Id;
                    aplques.APL__c = prodques.APL__c ;
                    aplqueslist.add(aplques);
                }
                
                if(aplqueslist.size()>0){
                    if( reqTyp == 'update' ){
                        list<id> questionsapl= new list<id>();
                        for(C_Ops_SPLOA_Questionnaire_Questions__c  prodques :productqueslist){
                            questionsapl.add(prodques.Id);
                        }
                        existaplques=[SELECT id,APL__c,C_Ops_IAP_Questionnaire__c from APL_Questionnaire__c where C_Ops_IAP_Questionnaire__c in: questionsapl];
                        aplqueslist = new List<APL_Questionnaire__c >();
                        
                        for(C_Ops_SPLOA_Questionnaire_Questions__c  prodques :productqueslist){
                            boolean found = false;
                            for(APL_Questionnaire__c aplsold:existaplques){
                                if(aplsold.C_Ops_IAP_Questionnaire__c==prodques.id){
                                    found=true;                                     
                                }                                
                            }
                            if(!found){
                                APL_Questionnaire__c aplques = new APL_Questionnaire__c();
                                aplques.C_Ops_IAP_Questionnaire__c = prodques.Id;
                                aplques.APL__c = prodques.APL__c ;
                                aplqueslist.add(aplques);
                            }
                            
                        }
                        if(aplqueslist.size()>0)
                            aplqueslist=internalsave.saveaplquestions(aplqueslist);
                        // upsert aplqueslist;
                    }else 		
                        aplqueslist=internalsave.saveaplquestions(aplqueslist);
                    //  Insert aplqueslist;
                }  
                List<C_Ops_SPLOA_Questionnaire_Questions__c> pharmacyqueslist = new List<C_Ops_SPLOA_Questionnaire_Questions__c>();
                List<C_Ops_SPLOA_Questionnaire_Questions__c> pharmacysubqueslist = new List<C_Ops_SPLOA_Questionnaire_Questions__c>();
                
                Map<C_Ops_SPLOA_Questions__c,List<C_Ops_SPLOA_Sub_Question__c>> pharmacyquesMap = new Map<C_Ops_SPLOA_Questions__c,List<C_Ops_SPLOA_Sub_Question__c>>();
                pharmacyquesMap = getPharmQuesbasedonGroup('1');
                set<string> pharidstorefer= new set<string>();
                for( C_Ops_SPLOA_Questions__c ques : pharmacyquesMap.keyset()){
                    pharidstorefer.add(ques.id);
                    for(C_Ops_SPLOA_Sub_Question__c subq : pharmacyquesMap.get(ques )){ 
                        pharidstorefer.add(subq.id);
                    }
                }
                
                if(pharmqueswrapperlist != null && pharmqueswrapperlist .size()>0){
                    for(pharmacyquestionswrapper pharmwrap  :pharmqueswrapperlist ){
                        C_Ops_SPLOA_Questionnaire_Questions__c pharmques = new C_Ops_SPLOA_Questionnaire_Questions__c();
                        if(AddPharmList != null && AddPharmList.size()>0)
                            for(C_Ops_SPLOA_Additional_Pharmacy__c addPharm :AddPharmList){
                                if( pharmwrap.Grp == addPharm.C_Ops_SPLOA_DEA_Number__c){
                                    pharmques.IAP_Additional_Pharmacies__c=addPharm.id;
                                    pharmques.DEA_Number__c=pharmwrap.Grp;
                                }
                            }
                        pharmques.Data_type__c = pharmwrap.Pharmques.C_Ops_SPLOA_Data_Type__c;
                        pharmques.C_Ops_SPLOA_Request__c = mainRequestId ;
                        pharmques.Question_Label__c = pharmwrap.Pharmques.C_Ops_SPLOA_Question_Label__c;
                        pharmques.Answer__c = pharmwrap.Pharmques.Answer__c;
                        pharmques.Question_Type__c = 'Pharmacy Questions';
                        if(string.isnotBlank(pharmwrap.Pharmques.IDbackup__c)){
                            if(!pharidstorefer.contains(pharmwrap.Pharmques.IDbackup__c)){
                                pharmques.id=pharmwrap.Pharmques.IDbackup__c;
                            }
                        }
                        pharmques.C_Ops_SPLOA_Question_Display_Order__c = pharmwrap.Pharmques.C_Ops_SPLOA_Question_Display_Order__c ;
                        pharmques.Parent_Question_Name__c= AllQuesNameandlabel.get(pharmwrap.Pharmques.C_Ops_SPLOA_Question_Label__c);
                        // pharmques.Group__c = pharmwrap.Grp;
                        // Included Validation flag for all the questions
                        if(pharmwrap.Pharmques.C_Ops_SPLOA_Data_Type__c == 'checkbox' &&( pharmwrap.Pharmques.Answer__c == pharmwrap.Pharmques.C_Ops_SPLOA_Credential__c ||( pharmwrap.Pharmques.C_Ops_SPLOA_Credential__c == '' || pharmwrap.Pharmques.C_Ops_SPLOA_Credential__c == null))){
                            pharmques.Validation_flag__c = true;
                        }
                        pharmacyqueslist.add(pharmques);
                        if(pharmwrap.subqueslist!=null){
                            for(C_Ops_SPLOA_Sub_Question__c subques  : pharmwrap.subqueslist){
                                // if(pharmwrap.Pharmques.Answer__c  =='Yes' ){
                                C_Ops_SPLOA_Questionnaire_Questions__c pharmsubques = new C_Ops_SPLOA_Questionnaire_Questions__c();
                                pharmsubques.Data_type__c = subques.C_Ops_SPLOA_Data_Type__c;
                                pharmsubques.C_Ops_SPLOA_Request__c = mainRequestId ;
                                pharmsubques.Question_Label__c = subques.Question_Label__c;
                                pharmsubques.Answer__c = subques.Answer__c;
                                pharmsubques.DEA_Number__c=pharmwrap.Grp;
                                pharmsubques.Question_Type__c = 'Pharmacy Questions';
                                pharmsubques.C_Ops_SPLOA_Question_Display_Order__c = subques.C_Ops_SPLOA_Question_Display_Order__c ;
                                pharmsubques.Parent_Question_Name__c= AllQuesIdandlabel.get(subques.Parent_Question__c);
                                // pharmsubques.Group__c = pharmwrap.Grp;
                                //Included Validation flag for all the questions
                                if(string.isnotBlank(subques.External_id__c)){
                                    if(!pharidstorefer.contains(subques.External_id__c)){
                                        pharmsubques.id=subques.External_id__c;
                                    }
                                }
                                if(subques.C_Ops_SPLOA_Data_Type__c == 'checkbox' &&( subques.Answer__c == subques.C_Ops_SPLOA_Credential__c || (subques.C_Ops_SPLOA_Credential__c == '' || subques.C_Ops_SPLOA_Credential__c == null))){
                                    pharmsubques.Validation_flag__c = true;
                                }
                                // if(pharmsubques.Answer__c != ''){
                                pharmacysubqueslist.add(pharmsubques );
                                // }
                                //}ji
                            }
                        }
                    }
                    
                    if(pharmacyqueslist.size()>0){
                        if( reqTyp == 'update' ){
                            /* for(C_Ops_SPLOA_Questionnaire_Questions__c aplsnew:pharmacyqueslist){
for(C_Ops_SPLOA_Questionnaire_Questions__c aplsold:existapl){
System.debug('-->'+aplsnew.DEA_Number__c);
System.debug('-->'+aplsold.DEA_Number__c);
if(aplsold.Question_Label__c==aplsnew.Question_Label__c && aplsold.DEA_Number__c==aplsnew.DEA_Number__c && aplsold.Group__c==aplsnew.Group__c){
aplsnew.id=aplsold.id;                                     
}                                
}
}*/
                            pharmacyqueslist=internalsave.savequestions(pharmacyqueslist);
                            // upsert pharmacyqueslist;
                        }else 	
                            pharmacyqueslist=internalsave.savequestions(pharmacyqueslist);	
                        //  Insert pharmacyqueslist;
                    }
                    
                    if(pharmacysubqueslist.size()>0){
                        for(C_Ops_SPLOA_Questionnaire_Questions__c pharmacysubques:pharmacysubqueslist)
                            for(C_Ops_SPLOA_Questionnaire_Questions__c pharmques: pharmacyqueslist){
                                if(pharmacysubques.Group__c == pharmques.Group__c  && pharmacysubques.DEA_Number__c==pharmques.DEA_Number__c && pharmacysubques.Parent_Question_Name__c == pharmques.Parent_Question_Name__c)
                                    pharmacysubques.C_Ops_SPLOA_Questionnaire__c = pharmques.Id;
                            }
                        if( reqTyp == 'update' ){
                            /*  for(C_Ops_SPLOA_Questionnaire_Questions__c aplsnew:pharmacysubqueslist){
for(C_Ops_SPLOA_Questionnaire_Questions__c aplsold:existapl){
if(aplsold.Question_Label__c==aplsnew.Question_Label__c  && aplsold.DEA_Number__c==aplsnew.DEA_Number__c && aplsold.Group__c==aplsnew.Group__c){
aplsnew.id=aplsold.id;                                     
}                                
}
}*/
                            for(C_Ops_SPLOA_Questionnaire_Questions__c pharmacysubques:pharmacysubqueslist)
                                System.debug('-->'+pharmacysubques.Answer__c);
                            pharmacysubqueslist=internalsave.savequestions(pharmacysubqueslist);
                            //  upsert pharmacysubqueslist;
                        }else 	
                            pharmacysubqueslist=internalsave.savequestions(pharmacysubqueslist);
                        // Insert pharmacysubqueslist;
                        
                    }
                    //Inserting APL and Questionnaire records
                    /*
List<APL_Questionnaire__c > aplpharmqueslist = new List<APL_Questionnaire__c >();
for( C_Ops_SPLOA_Questionnaire_Questions__c pharmques :pharmacyqueslist){
for(APL__c apl : APLsList){
if(ProductnameandGroupName.get(apl.C_Ops_SPLOA_Product_Name__c.touppercase())!= null ){
String GroupName = ProductnameandGroupName.get(apl.C_Ops_SPLOA_Product_Name__c.touppercase());
if(pharmques.Group__c == GroupName ){
APL_Questionnaire__c aplques = new APL_Questionnaire__c();
aplques.C_Ops_IAP_Questionnaire__c = pharmques.Id;
aplques.APL__c = apl.Id;
aplpharmqueslist.add(aplques);
}
}
}
}             

if(aplpharmqueslist.size()>0){
if( reqTyp == 'update' ){
list<id> questionsapl= new list<id>();
for(C_Ops_SPLOA_Questionnaire_Questions__c  prodques :pharmacyqueslist){
questionsapl.add(prodques.Id);
}
existaplques=[SELECT id,APL__c,C_Ops_IAP_Questionnaire__c from APL_Questionnaire__c where C_Ops_IAP_Questionnaire__c in: questionsapl];
//aplpharmqueslist = new List<APL_Questionnaire__c >();
List<APL_Questionnaire__c > aplpharmqueslistupdate = new List<APL_Questionnaire__c >();
for(C_Ops_SPLOA_Questionnaire_Questions__c  prodques :pharmacyqueslist){
boolean found = false;
for(APL_Questionnaire__c aplsold:existaplques){
if(aplsold.C_Ops_IAP_Questionnaire__c==prodques.id){
found=true;                                     
}                                
}
if(!found){
for(APL_Questionnaire__c aplsnew:aplpharmqueslist){
if(aplsnew.C_Ops_IAP_Questionnaire__c==prodques.id){
aplpharmqueslistupdate.add(aplsnew);                             
}                                
}
}

}
if(aplpharmqueslistupdate.size()>0)
aplpharmqueslistupdate=internalsave.saveaplquestions(aplpharmqueslistupdate);
// upsert aplpharmqueslistupdate;
}else 	
aplpharmqueslist=internalsave.saveaplquestions(aplpharmqueslist);	
//Insert aplpharmqueslist;
} 
*/
                }
                //APLandGroupMap                
                List<C_Ops_SPLOA_Questionnaire_Questions__c> quesqueslist = new List<C_Ops_SPLOA_Questionnaire_Questions__c>();
                List<C_Ops_SPLOA_Questionnaire_Questions__c> quessubqueslist = new List<C_Ops_SPLOA_Questionnaire_Questions__c>();
                if(quesquestionswrapperlist!=null && quesquestionswrapperlist.size()>0){
                    for( quesquestionswrapper   queswrp : quesquestionswrapperlist){
                        C_Ops_SPLOA_Questionnaire_Questions__c quesques = new C_Ops_SPLOA_Questionnaire_Questions__c();
                        quesques.Data_type__c = queswrp.queques.C_Ops_SPLOA_Data_Type__c;
                        quesques.C_Ops_SPLOA_Request__c = mainRequestId ;
                        quesques.Question_Label__c = queswrp.queques.C_Ops_SPLOA_Question_Label__c;
                        quesques.Answer__c = queswrp.queques.Answer__c;
                        quesques.Question_Type__c = 'Questionnaire';
                        quesques.Group__c = queswrp.Grp;
                        quesques.C_Ops_SPLOA_Question_Display_Order__c = queswrp.queques.C_Ops_SPLOA_Question_Display_Order__c ;
                        quesques.Parent_Question_Name__c= AllQuesNameandlabel.get(queswrp.queques.C_Ops_SPLOA_Question_Label__c);
                        if(queswrp.queques.C_Ops_SPLOA_Data_Type__c == 'checkbox' &&( queswrp.queques.Answer__c == queswrp.queques.C_Ops_SPLOA_Credential__c || (queswrp.queques.C_Ops_SPLOA_Credential__c == '' || queswrp.queques.C_Ops_SPLOA_Credential__c == null ))){
                            quesques.Validation_flag__c = true;
                        }
                        quesqueslist.add(quesques);
                        if(queswrp.subqueslist != null){
                            for(C_Ops_SPLOA_Sub_Question__c subques  : queswrp.subqueslist){
                                if(queswrp.queques.Answer__c =='Yes' && queswrp.queques.C_Ops_SPLOA_Has_Subquestion__c == true){
                                    C_Ops_SPLOA_Questionnaire_Questions__c quessubques = new C_Ops_SPLOA_Questionnaire_Questions__c();
                                    quessubques.Data_type__c = subques.C_Ops_SPLOA_Data_Type__c;
                                    quessubques.C_Ops_SPLOA_Request__c = mainRequestId ;
                                    quessubques.Question_Label__c = subques.Question_Label__c;
                                    quessubques.Answer__c = subques.Answer__c;
                                    quessubques.Question_Type__c = 'Questionnaire';
                                    quessubques.C_Ops_SPLOA_Question_Display_Order__c = subques.C_Ops_SPLOA_Question_Display_Order__c ;
                                    quessubques.Parent_Question_Name__c= AllQuesIdandlabel.get(subques.Parent_Question__c);
                                    quessubques.Group__c = queswrp.Grp;
                                    if(subques.C_Ops_SPLOA_Data_Type__c == 'checkbox' &&( subques.Answer__c == subques.C_Ops_SPLOA_Credential__c || (subques.C_Ops_SPLOA_Credential__c == '' || subques.C_Ops_SPLOA_Credential__c == null ))){
                                        quessubques.Validation_flag__c = true;
                                    }
                                    quessubqueslist.add(quessubques);
                                }
                            }
                        }
                    }
                }                
                if(quesqueslist.size()>0){
                    if( reqTyp == 'update' ){
                        for(C_Ops_SPLOA_Questionnaire_Questions__c aplsnew:quesqueslist){
                            for(C_Ops_SPLOA_Questionnaire_Questions__c aplsold:existapl){
                                if(aplsold.Question_Label__c==aplsnew.Question_Label__c  && aplsold.Group__c==aplsnew.Group__c  ){
                                    aplsnew.id=aplsold.id;                                     
                                }                                
                            }
                        }
                        List<C_Ops_SPLOA_Questionnaire_Questions__c> delqueslist = new List<C_Ops_SPLOA_Questionnaire_Questions__c>();
               
                        for(C_Ops_SPLOA_Questionnaire_Questions__c aplsold:existapl){
                           
                            if(aplsold.Question_Type__c == 'Questionnaire'){
                                boolean notfoundold=true;
                                for(C_Ops_SPLOA_Questionnaire_Questions__c aplsnew:quesqueslist){
                            
                                    if(aplsold.id==aplsnew.id ){
                                        notfoundold=false;                                    
                                    }                                
                                }
                                if(notfoundold){
                                    delqueslist.add(aplsold);
                                }
                            }
                        }
                        quesqueslist=internalsave.savequestions(quesqueslist);
                        //  upsert quesqueslist;
                        if(delqueslist.size()>0){
                            internalsave.deletequestions(delqueslist);
                        }
                    }else 		
                        quesqueslist=internalsave.savequestions(quesqueslist);// Insert quesqueslist;                    
                }else{
                    List<C_Ops_SPLOA_Questionnaire_Questions__c> delqueslist = new List<C_Ops_SPLOA_Questionnaire_Questions__c>();
                    for(C_Ops_SPLOA_Questionnaire_Questions__c aplsold:existapl){                       
                        if(aplsold.Question_Type__c == 'Questionnaire'){                            
                                delqueslist.add(aplsold);                            
                        }
                    }
                  
                    if(delqueslist.size()>0){
                        internalsave.deletequestions(delqueslist);
                    }
                }              
                if(quessubqueslist.size()>0){
                    for(C_Ops_SPLOA_Questionnaire_Questions__c quessubques : quessubqueslist )
                        for(C_Ops_SPLOA_Questionnaire_Questions__c quesques: quesqueslist){
                            if(quessubques.Group__c == quesques.Group__c && quessubques.Parent_Question_Name__c == quesques.Parent_Question_Name__c)
                                quessubques.C_Ops_SPLOA_Questionnaire__c = quesques.Id;
                        }
                    if( reqTyp == 'update' ){
                        for(C_Ops_SPLOA_Questionnaire_Questions__c aplsnew:quessubqueslist){
                            for(C_Ops_SPLOA_Questionnaire_Questions__c aplsold:existapl){
                                if(aplsold.Question_Label__c==aplsnew.Question_Label__c &&  aplsold.Group__c == aplsnew.Group__c){
                                    aplsnew.id=aplsold.id;                                     
                                }                                
                            }
                        }
                        quessubqueslist=internalsave.savequestions(quessubqueslist);
                        //upsert quessubqueslist;
                    }else 	
                        quessubqueslist=internalsave.savequestions(quessubqueslist);	
                    //   Insert quessubqueslist;  
                }
                //Inserting APL and Questionnaire records
                List<APL_Questionnaire__c > aplquesqueslist = new List<APL_Questionnaire__c >();
                for( C_Ops_SPLOA_Questionnaire_Questions__c quesques :quesqueslist){
                    for(APL__c apl : APLsList){
                        if(ProductnameandGroupName.get(apl.C_Ops_SPLOA_Product_Name__c.touppercase())!= null ){
                            String GroupName = ProductnameandGroupName.get(apl.C_Ops_SPLOA_Product_Name__c.touppercase());
                            if(quesques.Group__c == GroupName ){
                                APL_Questionnaire__c aplques = new APL_Questionnaire__c();
                                aplques.C_Ops_IAP_Questionnaire__c = quesques.Id;
                                aplques.APL__c = apl.Id;
                                aplquesqueslist.add(aplques);
                            }
                        }
                    }
                }              
                
                if(aplquesqueslist.size()>0){                    
                    if( reqTyp == 'update' ){
                        list<id> questionsapl= new list<id>();
                        for(C_Ops_SPLOA_Questionnaire_Questions__c  prodques :quesqueslist){
                            questionsapl.add(prodques.Id);
                        }
                        existaplques=[SELECT id,APL__c,C_Ops_IAP_Questionnaire__c from APL_Questionnaire__c where C_Ops_IAP_Questionnaire__c in: questionsapl];
                        //aplquesqueslist = new List<APL_Questionnaire__c >();
                        List<APL_Questionnaire__c > aplpharmqueslistupdate = new List<APL_Questionnaire__c >();
                        for(C_Ops_SPLOA_Questionnaire_Questions__c  prodques :quesqueslist){
                            boolean found = false;
                            for(APL_Questionnaire__c aplsold:existaplques){
                                if(aplsold.C_Ops_IAP_Questionnaire__c==prodques.id){
                                    found=true;                                     
                                }                                
                            }
                            if(!found){
                                for(APL_Questionnaire__c aplsnew:aplquesqueslist){
                                    if(aplsnew.C_Ops_IAP_Questionnaire__c==prodques.id){
                                        aplpharmqueslistupdate.add(aplsnew);                             
                                    }                                
                                }
                            }
                            
                        }
                        if(aplpharmqueslistupdate.size()>0)
                            aplpharmqueslistupdate=internalsave.saveaplquestions(aplpharmqueslistupdate);
                        // upsert aplpharmqueslistupdate;
                    }else 		
                        aplquesqueslist=internalsave.saveaplquestions(aplquesqueslist); // Insert aplquesqueslist;
                    
                }                
            }
        }  
    }
    
    public pageReference navtoconfirmpage(){ 
        system.debug('-------> SK Debug -->'+reqTyp);
        system.debug(mainRequest.Submission_Date__c);
        mainRequest.Submission_Date__c= date.today();
        PageReference nextPage;
        system.debug(canSubmit+''+mainRequestId);
        if(canSubmit){
            if(reqTyp == 'new' || reqTyp == 'update' ){
                createRecords();
                if(mainRequestId != null && String.IsBlank(errorMessage)){
                    cleanUpSavedData();
                    nextPage=Page.C_OPS_IAP_ConfirmationPage;
                    nextPage.getParameters().put('id',mainRequestId );
                    nextPage.setredirect(true);                
                    canSubmit=false;
                } 
            } 
            else if(reqTyp == 'renew'){
                mainRequest.C_Ops_SPLOA_Request_Status__c = 'New';
                mainRequest.Manual_review_required__c = true;
                mainRequest.SPLOA_Renewal__c = true;  
                createRecords();  
                // insertrenewreq();
                if(mainRequestId != null && String.IsBlank(errorMessage)){
                    cleanUpSavedData();
                    nextPage=Page.C_OPS_IAP_ConfirmationPage;
                    nextPage.getParameters().put('id',mainRequestId );
                    nextPage.getParameters().put('reqtyp','renew');
                    nextPage.setredirect(true);
                    canSubmit=false;
                } 
            }     
            else if(reqTyp == 'addProd' ){
                //  createaddprodRecords();          
                createRecords();
                if(mainRequestId != null && String.IsBlank(errorMessage)){
                    cleanUpSavedData();
                    nextPage=Page.C_OPS_IAP_ConfirmationPage;
                    nextPage.getParameters().put('id',mainRequestId );
                    nextPage.setredirect(true);
                    canSubmit=false;
                } 
            }
            else if(reqTyp == 'addSite' ){
                // updateaddSiteRecords();
                mainRequest.C_Ops_SPLOA_Request_Status__c = 'New';
                mainRequest.Manual_review_required__c = true;
                mainRequest.Added_New_Site_s__c = true;
                createRecords();
                if(mainRequestId != null && String.IsBlank(errorMessage)){
                    cleanUpSavedData();
                    nextPage=Page.C_OPS_IAP_ConfirmationPage;
                    nextPage.getParameters().put('id',mainRequestId );
                    nextPage.getParameters().put('reqtyp','addSite');
                    nextPage.setredirect(true);
                    canSubmit=false;
                } 
            }   
        }  
        system.debug(canSubmit);
        system.debug(nextPage);
        return nextPage;
    }  
    
    private void cleanUpSavedData(){
        mainRequest = new C_Ops_SPLOA_Request__c();
        //  oldAttachmentID=null;
        AddPharmList=new List<C_Ops_SPLOA_Additional_Pharmacy__c>();
        pharmqueswrapperlist =new List<pharmacyquestionswrapper>();
        quesquestionswrapperlist=new List<quesquestionswrapper>();
        this.response = '';
        this.recaptchaVerified = false;
    }
    
    @testVisible private boolean verifyCaptcha()
    {
        system.debug('response'+response+'this.recaptchaVerified'+this.recaptchaVerified);
        if (this.recaptchaVerified) return true;
        
        if( String.IsBlank(response))
        {
            errorMessage ='Please acknowledge the reCAPTCHA by checking the I\'m not a robot checkbox';
            handleError(errorMessage);
            return false;
        }
        
        String urlbody='secret=' + recaptchaPrivateSecret + '&response='  +  response;
        HttpResponse r = makeRequest(baseUrl, urlbody);
        if( r!= null )
        {            
            
            JSONParser parser = JSON.createParser(r.getBody());
            
            if(r.getBody()!=null && r.getBody().containsIgnoreCase('timeout-or-duplicate')){
                this.recaptchaVerified = true;                
            }            
            while (parser.nextToken() != null) {
                
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'success')) {              
                    parser.nextToken();
                    if(parser.getText()=='true') this.recaptchaVerified = true;
                }              
                
            }
        }else {
            errorMessage ='Please acknowledge the reCAPTCHA by checking the I\'m not a robot checkbox';            
            handleError(errorMessage);
            return false;
        }
        
        if(this.recaptchaVerified)
        {
            return true;
        }
        else
        {
            errorMessage ='Please acknowledge the reCAPTCHA by checking the I\'m not a robot checkbox';
            handleError(errorMessage);
            return false;
        }
    }    
    
    @testVisible private HttpResponse makeRequest(string url, string body)
    {
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
    
    //Wrapper Class to handle Pharmacy Questions and its Answers
    class pharmacyquestionswrapper{
        public C_Ops_SPLOA_Questions__c Pharmques{get;set;}
        public Integer iIndex {get;set;}
        public List<C_Ops_SPLOA_Sub_Question__c> subqueslist{get;set;}
        public String Grp{get;set;}
        public String Deniedreason{get;set;}
        public List<SelectOption> selectlistOption{get;set;}
        public List<SelectOption> PicklistOption{get;set;}
        
        public pharmacyquestionswrapper(C_Ops_SPLOA_Questions__c  Pharmque, Integer iRow, List<C_Ops_SPLOA_Sub_Question__c> subquelist, String Grp,string reqTyp){
            
            this.iIndex = iRow;
            List<SelectOption> pickoptions2 = new List<SelectOption>();
            this.Grp = Grp;
            this.selectlistOption= new list<SelectOption>();
            if(Pharmque != null)
                if(Pharmque.C_Ops_SPLOA_Data_Type__c=='Picklist' || Pharmque.C_Ops_SPLOA_Data_Type__c=='MultiPicklist'){
                    List<SelectOption> pickoptions = new List<SelectOption>();
                    list<string> options= new  list<string>();
                    if(string.isnotBlank(Pharmque.Answer__c))
                        options =Pharmque.Answer__c.split(';');    
                    if(options.size()>0){
                        for(string str:options){
                            if(string.isnotblank(str))
                                pickoptions.add(new SelectOption(str,str));
                        }
                    }
                    this.PicklistOption=pickoptions;
                    Pharmque.Answer__c='';
                }
            if(subquelist != null)
                for(C_Ops_SPLOA_Sub_Question__c subques:subquelist){
                    if(subques != null)
                        if(subques.C_Ops_SPLOA_Data_Type__c=='Picklist' || subques.C_Ops_SPLOA_Data_Type__c=='MultiPicklist'){
                            List<SelectOption> pickoptions = new List<SelectOption>();
                            list<string> options= new  list<string>();
                            if(string.isNotBlank(subques.Answer__c))
                                options =subques.Answer__c.split(';');    
                            if(options.size()>0){
                                for(string str:options){
                                    if(string.isnotblank(str))
                                        pickoptions.add(new SelectOption(str,str));
                                }
                            }
                            
                            if(string.isnotblank(subques.Answer2__c)){                        
                                set<string> options2=new set<string>();
                                options2.addall(subques.Answer2__c.split(';'));                          
                                if(options.size()>0){
                                    options2.removeall(options);                            
                                }
                                for(string str:options2){
                                    if(string.isnotblank(str))
                                        pickoptions2.add(new SelectOption(str,str));
                                }
                            }
                            if(reqTyp == 'update' && string.isnotblank(subques.Answer2__c)){
                                
                                this.selectlistOption=pickoptions;
                                this.PicklistOption=pickoptions2;
                                
                            }else{
                                this.PicklistOption=pickoptions;
                                subques.Answer__c=''; 
                            }                                         
                        }
                }
            this.subqueslist= subquelist;
            this.Pharmques = Pharmque;
        }
    }
    
    //Wrapper Class to handle Pharmacy Questions and its Answers
    class quesquestionswrapper{
        public C_Ops_SPLOA_Questions__c queques{get;set;}
        public Integer iIndex {get;set;}
        public List<SelectOption> PicklistOption{get;set;}
        public List<C_Ops_SPLOA_Sub_Question__c> subqueslist{get;set;}
        public String Grp{get;set;}
        public List<SelectOption> selectlistOption{get;set;}
        public quesquestionswrapper(C_Ops_SPLOA_Questions__c  queques, Integer iRow, List<C_Ops_SPLOA_Sub_Question__c> subquelist, String Grp){
            selectlistOption= new list<SelectOption>();
            if(queques != null)
                if(queques.C_Ops_SPLOA_Data_Type__c=='Picklist'){
                    List<SelectOption> pickoptions = new List<SelectOption>();
                    list<string> options =queques.Answer__c.split(';');    
                    if(options.size()>0){
                        for(string str:options){
                            if(string.isnotblank(str))
                                pickoptions.add(new SelectOption(str,str));
                        }
                    }
                    this.PicklistOption=pickoptions;
                    queques.Answer__c='';
                }
            if(subquelist != null)
                for(C_Ops_SPLOA_Sub_Question__c subques:subquelist){
                    if(subques != null)
                        if(subques.C_Ops_SPLOA_Data_Type__c=='Picklist'){
                            List<SelectOption> pickoptions = new List<SelectOption>();
                            list<string> options =subques.Answer__c.split(';');    
                            if(options.size()>0){
                                for(string str:options){
                                    if(string.isnotblank(str))
                                        pickoptions.add(new SelectOption(str,str));
                                }
                            }
                            this.PicklistOption=pickoptions;
                            subques.Answer__c='';
                        }
                }
            
            
            
            this.queques = queques;
            this.iIndex = iRow;
            this.subqueslist= subquelist;
            this.Grp = Grp;
        }
    }
    
    //Wrapper Class to handle Product Questions and its Answers
    public class productquestionswrapper{
        public APL__c apl{get;set;} 
        public C_Ops_SPLOA_Questions__c Prodques{get;set;}
        public Integer iIndex {get;set;}
        public List<SelectOption> PicklistOption{get;set;}
        public List<C_Ops_SPLOA_Sub_Question__c> subqueslist{get;set;}
        public List<SelectOption> selectlistOption{get;set;}
        public productquestionswrapper(APL__c  aplrcd , C_Ops_SPLOA_Questions__c  Prodque, Integer iRow, List<C_Ops_SPLOA_Sub_Question__c> subquelist,string reqTyp){
            selectlistOption= new list<SelectOption>();
            PicklistOption= new list<SelectOption>();
            List<SelectOption> pickoptions2 = new List<SelectOption>();
            if(Prodque != null)
                if(Prodque.C_Ops_SPLOA_Data_Type__c=='Picklist' || Prodque.C_Ops_SPLOA_Data_Type__c=='MultiPicklist'){
                    List<SelectOption> pickoptions = new List<SelectOption>();
                    
                    list<string> options =Prodque.Answer__c.split(';');    
                    if(options.size()>0){
                        for(string str:options){
                            if(string.isnotblank(str))
                                pickoptions.add(new SelectOption(str,str));
                        }
                    }
                    
                    if(reqTyp == 'update'){
                        this.selectlistOption=pickoptions;
                        this.PicklistOption=pickoptions2;
                        
                    }else{
                        this.PicklistOption=pickoptions;
                        Prodque.Answer__c=''; 
                    }
                }
            if(subquelist != null)
                for(C_Ops_SPLOA_Sub_Question__c subques:subquelist){
                    if(subques != null)
                        if(subques.C_Ops_SPLOA_Data_Type__c=='Picklist' || subques.C_Ops_SPLOA_Data_Type__c=='MultiPicklist'){
                            List<SelectOption> pickoptions = new List<SelectOption>();
                            list<string> options =new list<string>();
                            if(string.isNotBlank(subques.Answer__c))
                                options=subques.Answer__c.split(';');    
                            if(options.size()>0){
                                for(string str:options){
                                    if(string.isnotblank(str))
                                        pickoptions.add(new SelectOption(str,str));
                                }
                            }
                            if(string.isnotblank(subques.C_Ops_SPLOA_Credential__c)){                        
                                set<string> options2=new set<string>();
                                options2.addall(subques.C_Ops_SPLOA_Credential__c.split(';'));                          
                                if(options.size()>0){
                                    options2.removeall(options);
                                    for(string str:options2){
                                        if(string.isnotblank(str))
                                            pickoptions2.add(new SelectOption(str,str));
                                    }
                                }
                            }
                            if(reqTyp == 'update' && string.isnotblank(subques.C_Ops_SPLOA_Credential__c)){
                                
                                this.selectlistOption=pickoptions;
                                this.PicklistOption=pickoptions2;
                                
                            }else{
                                this.PicklistOption=pickoptions;
                                subques.Answer__c=''; 
                            }
                            
                        }
                }
            this.apl = aplrcd;
            this.Prodques = Prodque;
            this.iIndex = iRow;
            this.subqueslist= subquelist;
        }
        
        public productquestionswrapper(APL__c  aplrcd , C_Ops_SPLOA_Questions__c  Prodque, Integer iRow, List<C_Ops_SPLOA_Sub_Question__c> subquelist){
            selectlistOption= new list<SelectOption>();
            if(Prodque != null)
                if(Prodque.C_Ops_SPLOA_Data_Type__c=='Picklist' || Prodque.C_Ops_SPLOA_Data_Type__c=='MultiPicklist'){
                    List<SelectOption> pickoptions = new List<SelectOption>();
                    list<string> options =Prodque.Answer__c.split(';');    
                    if(options.size()>0){
                        for(string str:options){
                            if(string.isnotblank(str))
                                pickoptions.add(new SelectOption(str,str));
                        }
                    }
                    this.PicklistOption=pickoptions;
                    Prodque.Answer__c='';
                }
            if(subquelist != null)
                for(C_Ops_SPLOA_Sub_Question__c subques:subquelist){
                    if(subques != null)
                        if(subques.C_Ops_SPLOA_Data_Type__c=='Picklist' || subques.C_Ops_SPLOA_Data_Type__c=='MultiPicklist'){
                            List<SelectOption> pickoptions = new List<SelectOption>();
                            list<string> options =subques.Answer__c.split(';');    
                            if(options.size()>0){
                                for(string str:options){
                                    if(string.isnotblank(str))
                                        pickoptions.add(new SelectOption(str,str));
                                }
                            }
                            
                            this.PicklistOption=pickoptions;
                            subques.Answer__c=''; 
                            
                            
                        }
                }
            this.apl = aplrcd;
            this.Prodques = Prodque;
            this.iIndex = iRow;
            this.subqueslist= subquelist;
            
        }
        
        
    }   
    
    //Querying all Active and Effective Questions  C_Ops_SPLOA_Applicable_To__c  3134 780
    public void queryAllquestions(){
        IAP_Controller_internal internalsave= new IAP_Controller_internal();
        Allquestions=internalsave.performqueryAllquestions(); 
        AllQuesNameandlabel = new Map<String,String>();
        AllQuesIdandlabel = new Map<Id,String>();
        /*   Allquestions  =   [SELECT Id,Name ,Group__c, C_Ops_SPLOA_Active__c , C_Ops_SPLOA_Credential__c , IAP_Access_Type__c, C_Ops_SPLOA_Data_Type__c,
C_Ops_SPLOA_Effective_Date__c , Has_Next_Question__c , C_Ops_SPLOA_Has_Subquestion__c  ,Manual_review__c , Product__c , Answer__c,Attachement_required__c,
C_Ops_SPLOA_Question_Display_Order__c ,C_Ops_SPLOA_Applicable_To__c, C_Ops_SPLOA_Question_Label__c , Question_Type__c , Super_exceeded_question__c , alternative_value__c ,  IDbackup__c  
FROM C_Ops_SPLOA_Questions__c
WHERE C_Ops_SPLOA_Active__c =  True AND C_Ops_SPLOA_Effective_Date__c <= TODAY
ORDER BY C_Ops_SPLOA_Question_Display_Order__c ASC ];*/
        
        for(C_Ops_SPLOA_Questions__c q:Allquestions){
            AllQuesIdandlabel.put(q.Id,q.Name);
            AllQuesNameandlabel.put(q.C_Ops_SPLOA_Question_Label__c,q.Name);
        }
    }
    
    //Querying all Active and Effective sub Questions
    public void queryAllsubquestions(){
        IAP_Controller_internal internalsave= new IAP_Controller_internal();
        Allsubquestions=internalsave.performqueryAllsubquestions(); 
        //Jie guest user fix code 10-2020
        for (C_Ops_SPLOA_Sub_Question__c q:Allsubquestions   ) {
            q.id=null;
        }
    }
    
    public PageReference refreshPage(){
        return null;
    }
    
    private without sharing class IAP_Controller_internal{
        Public C_Ops_SPLOA_Request__c saverequest(C_Ops_SPLOA_Request__c requesttosave){
            upsert requesttosave;
            return requesttosave;
        }
        private  list<C_Ops_SPLOA_Additional_Pharmacy__c> savephar(list<C_Ops_SPLOA_Additional_Pharmacy__c> AddPharmList){
            upsert AddPharmList;
            return AddPharmList;
        }
        private void  delphar(list<C_Ops_SPLOA_Additional_Pharmacy__c> AddPharmList){
            delete AddPharmList;
        }
        private  List<APL__c> saveapl(List<APL__c> APLsList){
            upsert APLsList;
            return APLsList;
        }
        private  void delapl(List<APL__c> APLsList){
            delete APLsList;           
        }
        private  list<C_Ops_SPLOA_Questionnaire_Questions__c> savequestions(list<C_Ops_SPLOA_Questionnaire_Questions__c> APLsquestions){
            upsert APLsquestions;
            return APLsquestions;
        }
        private  void deletequestions(list<C_Ops_SPLOA_Questionnaire_Questions__c> APLsquestions){
            delete APLsquestions;
        }
        private  List<APL_Questionnaire__c > saveaplquestions(List<APL_Questionnaire__c > aplqueslist){
            upsert aplqueslist;
            return aplqueslist;
        }
        private List<PRP_BEM__c> performSearch(string searchString) {
            
            String soql = 'select id, name from PRP_BEM__c';
            if(searchString != '' && searchString != null)
                soql = soql +  ' where Is_Active__c =true and name LIKE \'%' + searchString +'%\' ';
            soql = soql + ' limit 5';
            return database.query(soql); 
            
        }
        private List<PRP_BEM__c> performSearchbyif(string searchString) {
            return [select id, name from PRP_BEM__c where id =:searchString limit 1 ]; 
        }
        
        private List<C_Ops_SPLOA_Sub_Question__c> performqueryAllsubquestions(){
            return  [SELECT Id,Name ,Field_To_Copy__c, C_Ops_SPLOA_Active__c, C_Ops_SPLOA_Credential__c, Parent_Question__c,C_Ops_SPLOA_Data_Type__c,Date_Input__c,APL_Group__c,
                     C_Ops_SPLOA_Effective_Date__c , C_Ops_SPLOA_Next_Question_Needed__c , C_Ops_SPLOA_Question_Display_Order__c,Question_Label__c,Answer__c , Date_has_not_been_scheduled__c
                     FROM C_Ops_SPLOA_Sub_Question__c
                     WHERE C_Ops_SPLOA_Active__c =  True AND Parent_Question__r.C_Ops_SPLOA_Active__c =  True  AND C_Ops_SPLOA_Effective_Date__c <= TODAY
                     ORDER BY C_Ops_SPLOA_Question_Display_Order__c ASC ];
        }
        
        private List<C_Ops_SPLOA_Questions__c> performqueryAllquestions(){
            return [SELECT Id,Name ,Group__c, C_Ops_SPLOA_Active__c , C_Ops_SPLOA_Credential__c , IAP_Access_Type__c, C_Ops_SPLOA_Data_Type__c,
                    C_Ops_SPLOA_Effective_Date__c , Has_Next_Question__c , C_Ops_SPLOA_Has_Subquestion__c  ,Manual_review__c , Product__c , Answer__c,Attachement_required__c,
                    C_Ops_SPLOA_Question_Display_Order__c ,C_Ops_SPLOA_Applicable_To__c, C_Ops_SPLOA_Question_Label__c , Question_Type__c , Super_exceeded_question__c , alternative_value__c ,  IDbackup__c  
                    FROM C_Ops_SPLOA_Questions__c
                    WHERE C_Ops_SPLOA_Active__c =  True  AND C_Ops_SPLOA_Effective_Date__c <= TODAY
                    ORDER BY C_Ops_SPLOA_Question_Display_Order__c ASC ];
        }
        
        private List<C_Ops_SPLOA_Questions__c> performqueryAllquestionsbyid( Set<Id> setprodqueIds ){
            return [Select id,Name,C_Ops_SPLOA_Customer_Type__c,alternative_value__c,Answer__c,Group__c,Attachement_required__c,C_Ops_SPLOA_Applicable_To__c,C_Ops_SPLOA_Effective_Date__c,Has_Next_Question__c,C_Ops_SPLOA_Has_Subquestion__c,IAP_Access_Type__c,IDbackup__c,C_Ops_SPLOA_Question_Display_Order__c,C_Ops_SPLOA_Question_Label__c,Question_Type__c,Product__c,Manual_review__c,C_Ops_SPLOA_Data_Type__c,Super_exceeded_question__c,C_Ops_SPLOA_Credential__c,(SELECT Id,Name,Field_To_Copy__c,APL_Group__c, C_Ops_SPLOA_Active__c,Answer__c,Parent_Question__c,Parent_Question__r.Group__c,Question_Label__c,C_Ops_SPLOA_Data_Type__c,C_Ops_SPLOA_Credential__c,Date_has_not_been_scheduled__c,Date_Input__c,C_Ops_SPLOA_Question_Display_Order__c from C_Ops_SPLOA_Sub_Question__r  order by C_Ops_SPLOA_Question_Display_Order__c asc) from C_Ops_SPLOA_Questions__c WHERE ID IN :setprodqueIds order by C_Ops_SPLOA_Question_Display_Order__c asc ];
        }
        
        private C_Ops_SPLOA_Request__c getrequest(string corrReqId){
            return [select id,Signing_Authority_Title__c,Additional_Products__c,Signing_Authority_Last_Name__c,Signing_Authority_First_name__c,Genentech_Contact__c,Genentech_Contact__r.name,Same_Signing__c,Signee_Extension__c,Signee_Phone__c,Signee_Email__c,Accreditation__c,Request_Type__c,Request_PDF_Version_Number__c,Name,APLs_on_the_Request__c,Authorised__c,Submission_Date__c,Signee_First_Name__c,Signee_Title__c,Signee_Last_Name__c,C_Ops_SPLOA_First_Name__c,C_Ops_SPLOA_Last_Name__c,C_Ops_SPLOA_Phone__c,C_Ops_SPLOA_Extension__c,C_Ops_SPLOA_Fax__c,C_Ops_SPLOA_Pharmacy_Name__c,C_Ops_SPLOA_Email__c,C_Ops_SPLOA_Primary_Distributor__c,C_Ops_SPLOA_DEA_Number__c,C_Ops_SPLOA_Street_Address__c,C_Ops_SPLOA_Street_Address_2__c,C_Ops_SPLOA_City__c,State__c,C_Ops_SPLOA_Zip__c,Website_URL__c,C_Ops_SPLOA_Product_Name__c,C_Ops_SPLOA_Request_Status__c,SPLOA_Renewal__c from C_Ops_SPLOA_Request__c where id=:corrReqId];
        }
        private list<Access_Type_Calculation__c> getAccessTypes(){
            return  [SELECT Id,Name , APL_Group__c ,Is_there_at_least_1_prescription_referra__c, C_Ops_IAP_Questions_List__c , Is_your_pharmacy_a_department_affiliate__c , Is_your_pharmacy_accredited_The_accepte__c,Question1__r.C_Ops_SPLOA_Question_Label__c, Question1_Response__c
                     ,Question2__r.C_Ops_SPLOA_Question_Label__c, Question2_Response__c
                     ,Question3__r.C_Ops_SPLOA_Question_Label__c, Question3_Response__c
                     ,Question4__r.C_Ops_SPLOA_Question_Label__c, Question4_Response__c
                     ,Question5__r.C_Ops_SPLOA_Question_Label__c, Question5_Response__c FROM Access_Type_Calculation__c];
        }
        
        Private list<Business_Rule__c> getBusinessruleslist(){
            return [SELECT Id , Access_Type__c, Denial_Reason_Code__c , Group__c , Outcome__c,  Value_for_Outcome__c,C_Ops_IAP_Questions_List__r.C_Ops_SPLOA_Question_Label__c,C_Ops_IAP_Sub_Questions__r.Question_Label__c FROM Business_Rule__c where Inactive__c = false   ];
        }
        Private list<C_Ops_SPLOA_Additional_Pharmacy__c> getadditionalphar(string requestId )
        {
            return [select id,name, C_Ops_SPLOA_DEA_Number__c,Pharmacy_Name__c,C_Ops_SPLOA_Street_Address__c,C_Ops_SPLOA_Street_Address_2__c,C_Ops_SPLOA_City__c,C_Ops_SPLOA_State__c,C_Ops_SPLOA_Zip__c,C_Ops_SPLOA_Request__c,Accreditation__c,Is_Primary_Pharmacy__c,Denial_Reason_Code__c,Request_Status__c from C_Ops_SPLOA_Additional_Pharmacy__c where C_Ops_SPLOA_Request__c =:requestId];
            
        }
        
        Private  List<C_Ops_SPLOA_Request__c> getexistrequestonphar( String product , List<String> DEAlist, DateTime dupCheckStartingDateTime){
            return [SELECT Id,C_Ops_SPLOA_DEA_Number__c ,C_Ops_SPLOA_Product_Name__c, Processed_Date__c FROM C_Ops_SPLOA_Request__c
                    WHERE C_Ops_SPLOA_DEA_Number__c =: DEAlist AND  C_Ops_SPLOA_Product_Name__c =: product 
                    AND C_Ops_SPLOA_Request_Status__c != 'Denied' and C_Ops_SPLOA_Request_Status__c != 'Expired'
                    and (Processed_Date__c =null or Processed_Date__c >= :dupCheckStartingDateTime)];
            
        }
        
        
        Private  List<C_Ops_SPLOA_Request__c> getexistrequestonphar2( String product , List<String> DEAlist, DateTime dupCheckStartingDateTime){
            return [SELECT Id,C_Ops_SPLOA_DEA_Number__c ,C_Ops_SPLOA_Product_Name__c, Processed_Date__c 
                    FROM C_Ops_SPLOA_Request__c WHERE
                    Id IN (SELECT C_Ops_SPLOA_Request__c FROM C_Ops_SPLOA_Additional_Pharmacy__c WHERE C_Ops_SPLOA_DEA_Number__c =: DEAlist ) AND
                    C_Ops_SPLOA_Product_Name__c =: product AND C_Ops_SPLOA_Request_Status__c != 'Denied' and C_Ops_SPLOA_Request_Status__c != 'Expired'
                    and (Processed_Date__c =null or Processed_Date__c >= :dupCheckStartingDateTime)];
            
        }
        Private  List<C_Ops_SPLOA_Questionnaire_Questions__c> getexistingQuestions( String corrReqIds ){
            return [select id,name,C_Ops_SPLOA_Request__r.C_Ops_SPLOA_DEA_Number__c,Question_Label__c,C_Ops_SPLOA_Questionnaire__c,C_Ops_SPLOA_Question_Display_Order__c,Data_type__c,IAP_Additional_Pharmacies__c,IAP_Additional_Pharmacies__r.C_Ops_SPLOA_DEA_Number__c,DEA_Number__c, Answer__c, APL__c,Group__c, C_Ops_SPLOA_Request__c,Question_Type__c,Backend_to_store_products__c from C_Ops_SPLOA_Questionnaire_Questions__c where C_Ops_SPLOA_Request__c=:corrReqIds ];
            
        }
    }                                                                    
}