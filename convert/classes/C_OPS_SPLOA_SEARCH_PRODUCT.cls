public without sharing  class C_OPS_SPLOA_SEARCH_PRODUCT {
    public integer addPharmListSize;    
    public String addAPListDisplay{set;}
    
    //babatope
    public String getRequestType(){
             String requestType = ApexPages.CurrentPage().getparameters().get('requestType');
             return requestType;
    }
   
    public String getAddAPListDisplay(){
        if( selectedOption!=null && selectedOption=='Yes') return 'block';
        else return 'none';
    }
    
    public integer getAddPharmListSize(){
        if(AddPharmList==null) return 0;
        else return AddPharmList.size();
    }
    
    public PageReference resetRadioSelection(){
        selectedOption='Yes';
        return null;
    }
    
    public PageReference clearAddPharmList(){
        selectedOption='No';
        AddPharmList.clear();
        return null;
    }
    
    public void setAddPharmListSize(integer i){
        addPharmListSize=i;
    }
    
    // Jie - debug code
    public String errorMsg {set; get;}
    public Boolean getDebugOn () {
        //when need to turn on debug message
        // return true;
        
        //turn off debug message before deploy to any none dev envirnoment
        return false;
    }
    // End of Jie - debug code    
    public String selectedOption { get; set; }
    public boolean makeSelectionNo{get;set;}
    public boolean makeYes{get;set;}
    public boolean makeNo{get;set;}
    private ID requestId;
    public Id corrReqId{get;set;}
    public String reqTyp {get;set;}
    public C_Ops_SPLOA_Request__c oldRequest {set; get;}
    public C_Ops_SPLOA_Request__c oldcurrRequest = new C_Ops_SPLOA_Request__c(); 
    public String SelectedProductName{get;set;}
    public String searchKey{get;set;}
    public String errorMessage{get;set;}
    public C_Ops_SPLOA_Request__c mainRequest{get;set;}
    public Boolean RequestDenial{ get; set; }
    public String oldproductName;
    
    public C_Ops_SPLOA_Additional_Pharmacy__c currAddPharm{get;set;}
    public List<C_Ops_SPLOA_Additional_Pharmacy__c> AddPharmList{get;set;}
    public boolean isEditAddPharm {get;set;}
    String requestToEdit;
    
    public List<SelectOption> productslist{get;set;}
    public List<C_Ops_SPLOA_Questions__c> PharmacyQuestions{get;set;}
    public List<C_Ops_SPLOA_Questions__c> QuestionnaireQuestions{get;set;}
    public List<C_Ops_SPLOA_Questions__c> superseededQuestionnaireQuestions{get;set;}
    public List<pharmacyquestionswrapper> pharmqueswrapperlist{get;set;}
    public List<quesquestionswrapper> quesquestionswrapperlist{get;set;}
    public List<C_Ops_SPLOA_Physicians__c> physicianSpecialitylist{get;set;}
    public List<C_Ops_SPLOA_Questions__c> Allquestions ;
    public List<C_Ops_SPLOA_Sub_Question__c> Allsubquestions ;
    public Boolean productNamechanged;
    public String response { get; set; }
    public String publicKey { get; set; }
    public C_Ops_Captcha_Property__c prop{get;set;}
    private Integer counter = 0;
    private Integer qquescounter = 0;
    public Boolean showList{get;set;}
    public Boolean renewRequest{get;set;}
    public Boolean haveDEAError = false;
    public Boolean trueOption{get;set;}
    public Boolean showfileupload{get;set;}
    public Boolean superexceededset{get;set;}
    private string recaptchaPublicSecret;
    private string recaptchaPrivateSecret;
    private String baseUrl;
    Decimal numberofRenewalmonths;    
    Date startOfMonth = Date.today().toStartOfMonth();
    Date startOfPreviousMonths = startOfMonth.addMonths(-21);
    public boolean recaptchaVerified {public get; public set;}
    public string getRecaptchaPublicSecret() {
        return this.recaptchaPublicSecret;
    }
    public String CorrReqTyp{get;set;}
    private string oldaccesstype;
    public Map<C_Ops_SPLOA_Questions__c,List<C_Ops_SPLOA_Sub_Question__c>> quesMap;
    public Id mainRequestId;
    private Boolean hasproductError;
    private List<C_Ops_SPLOA_Product__c> productslsts = new List<C_Ops_SPLOA_Product__c>();
    private List<C_Ops_SPLOA_Questionnaire_Questions__c> questionnairelist;
    public Boolean correctionReq{get;set;}
    private List<C_Ops_SPLOA_Questionnaire_Questions__c > QuesquestionscorrReq ;
    private Map<String,C_Ops_SPLOA_Questionnaire_Questions__c > QuesquestionscorrReqMap;
    private Map<Id,List<C_Ops_SPLOA_Sub_Question__c>> pharmquessubquesMap;
    private Boolean accesstypechanged;
    private List<C_Ops_SPLOA_Additional_Pharmacy__c > AddPharmoldListcorrReq ;
    public String prodname{get;set;}
    public String email{get;set;}
    public String dea{get;set;}
    public Boolean disableprodname{get;set;}
    public Boolean disabledea{get;set;}
    public Boolean showaddsitepage{get;set;}
    public Boolean addpharmacayOption{get;set;}
    
    public Attachment document{
        get;
        
        set{                                        
            Try{document = value;}
            catch(exception e)
            {
                handleError(e.getMessage());            
            }
        }
    }

    public List<SelectOption> getOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('New Product Access','New Product Access'));
        options.add(new SelectOption('Renew Product Access','Renew Product Access'));  return options;
        
    }
    
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Yes','Yes'));
        options.add(new SelectOption('No','No'));  return options;
        
    }

    public List<SelectOption> getPhysianSpeciality() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Select One','Select One'));
        for(C_Ops_SPLOA_Physicians__c specialityoption :physicianSpecialitylist){
            options.add(new SelectOption(specialityoption.Name, specialityoption.Name));
        }
        return options;        
    }
    
    //Constructor
    public C_OPS_SPLOA_SEARCH_PRODUCT (){ 
        disableprodname = false; 
        disabledea = false;
        makeSelectionNo=false;  
        addAPListDisplay='none';
        makeYes=false;
        makeNo=true;
        reqTyp = 'new';
        correctionReq = false;
        renewRequest = false;
        //Below handles the "Submit Another Request" functionality from Confirmation page
        requestId=ApexPages.currentPage().getParameters().get('id');
        List<C_Ops_SPLOA_Additional_Pharmacy__c > AddPharmoldList = new List<C_Ops_SPLOA_Additional_Pharmacy__c >();         
        if(requestId!=null) {
            selectedOption='No';
            oldRequest=[select id,Name,C_Ops_SPLOA_First_Name__c,C_Ops_SPLOA_Last_Name__c,C_Ops_SPLOA_Phone__c,C_Ops_SPLOA_Extension__c,C_Ops_SPLOA_Fax__c,C_Ops_SPLOA_Pharmacy_Name__c,C_Ops_SPLOA_Email__c,C_Ops_SPLOA_Primary_Distributor__c,C_Ops_SPLOA_DEA_Number__c,C_Ops_SPLOA_Street_Address__c,C_Ops_SPLOA_Street_Address_2__c,C_Ops_SPLOA_City__c,State__c,C_Ops_SPLOA_Zip__c,Website_URL__c,C_Ops_SPLOA_Product_Name__c,C_Ops_SPLOA_Request_Status__c,SPLOA_Renewal__c from C_Ops_SPLOA_Request__c where id=:requestId];
            AddPharmoldList =[select name, C_Ops_SPLOA_DEA_Number__c,Pharmacy_Name__c,C_Ops_SPLOA_Street_Address__c,C_Ops_SPLOA_Street_Address_2__c,C_Ops_SPLOA_City__c,C_Ops_SPLOA_State__c,C_Ops_SPLOA_Zip__c,C_Ops_SPLOA_Request__c from C_Ops_SPLOA_Additional_Pharmacy__c where C_Ops_SPLOA_Request__c =:requestId];
            if(!AddPharmoldList.isEmpty()){
                selectedOption='Yes';
                if(AddPharmList== null){
                    AddPharmList =  new list<C_Ops_SPLOA_Additional_Pharmacy__c>();
                }
                for(C_Ops_SPLOA_Additional_Pharmacy__c oldPharm : AddPharmoldList ){
                    C_Ops_SPLOA_Additional_Pharmacy__c copyPharm= new C_Ops_SPLOA_Additional_Pharmacy__c();
                    copyPharm.C_Ops_SPLOA_DEA_Number__c = oldPharm.C_Ops_SPLOA_DEA_Number__c;
                    copyPharm.Pharmacy_Name__c = oldPharm.Pharmacy_Name__c;
                    copyPharm.C_Ops_SPLOA_Street_Address__c = oldPharm.C_Ops_SPLOA_Street_Address__c;
                    copyPharm.C_Ops_SPLOA_Street_Address_2__c = oldPharm.C_Ops_SPLOA_Street_Address_2__c;
                    copyPharm.C_Ops_SPLOA_City__c = oldPharm.C_Ops_SPLOA_City__c;
                    copyPharm.C_Ops_SPLOA_State__c = oldPharm.C_Ops_SPLOA_State__c;
                    copyPharm.C_Ops_SPLOA_Zip__c = oldPharm.C_Ops_SPLOA_Zip__c;            
                    AddPharmList.add(copyPharm);
                }
            }
        }        
        
        mainRequest = new C_Ops_SPLOA_Request__c();
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
            //system.debug('Request type is' + requestType);
            mainRequest.Request_Type__c = getRequestType();
        }        
        
        //Below is the code for handling correction page Request
        /* String corrid= ApexPages.currentPage().getParameters().get('corrid');
        if(corrid != null && corrid != ''){
        corrReqId =Id.valueof(corrid);
        }*/
        corrReqId = ApexPages.currentPage().getParameters().get('corrid');
        reqTyp = ApexPages.currentPage().getParameters().get('reqTyp');
        String requestType = ApexPages.CurrentPage().getparameters().get('requestType');
         

        prodname = ApexPages.currentPage().getParameters().get('prodName');
        email = ApexPages.currentPage().getParameters().get('email');
        dea = ApexPages.currentPage().getParameters().get('dea');
        if(reqTyp == 'update'){
            if(corrReqId != null){
                disableprodname = true;
            }
            populatedataforupdate();
            if(AddPharmList == null || AddPharmList.size() == 0){selectedOption ='No';}
        }
      //  else if (reqTyp == 'renew') {
         else if(RequestType == 'Renewal') {
            reqTyp = 'renew';
            disableprodname = true;
            disabledea  = true;
            renewRequest=true;
            populatedataforupdate();
            if((AddPharmList == null || AddPharmList.size() == 0) && corrReqId!= null){selectedOption ='No';}
            if(corrReqId == null){
                mainRequest.C_Ops_SPLOA_Email__c = email;
                mainRequest.C_Ops_SPLOA_DEA_Number__c = dea;
                mainRequest.Request_Type__c = getRequestType();
            }
        }
       // else if(reqTyp == 'addProd'){
        else if( RequestType == 'Add Product'){
            reqTyp = 'addProd';
            disableprodname = false;
            disabledea = true;
            populatedataforaddprod();
            if(corrReqId == null){
                mainRequest.C_Ops_SPLOA_Email__c = email;
                mainRequest.C_Ops_SPLOA_DEA_Number__c = dea;
                mainRequest.Request_Type__c = getRequestType();
            }
        }
      //  else if(reqTyp == 'addSite'){
       else if( RequestType == 'Add Location'){
              reqTyp = 'addSite';
            populatedataforaddsite();
            selectedOption ='Yes';
            mainRequest.Request_Type__c = getRequestType();
        }
        
       if(reqTyp == 'addSite'){addpharmacayOption = true;}else{addpharmacayOption = false;}
        
        RequestDenial = false;
        productNamechanged = false;
        this.document = new Attachment();
        this.recaptchaVerified = false;
        superexceededset= false;
        productNamechanged = false;
        hasproductError= false;
        showfileupload = false;
        documentuploaded  = false;
        productslsts = [
            SELECT Name FROM C_Ops_SPLOA_Product__c
            WHERE C_Ops_SPLOA_Active__c =  True AND C_Ops_SPLOA_Effective_Date__c <= TODAY];
        
        physicianSpecialitylist =[SELECT Name FROM C_Ops_SPLOA_Physicians__c];
        
        prop = [SELECT ID, GSiteKey__c, GSecurityKey__c, GSite__c,Active__c FROM C_Ops_Captcha_Property__c WHERE Active__c=true LIMIT 1];        
        recaptchaPublicSecret = prop.GSiteKey__c;
        recaptchaPrivateSecret = prop.GSecurityKey__c;
        baseUrl=prop.GSite__c;
        mainRequestId=null;
        accesstypechanged = false;
        if(reqTyp == ''|| reqTyp  == null){reqTyp = 'new';}
    }

    /*    comment out by Jie
    public void fetchRadio() {    
    //objList = JSON.serialize(accList);
    system.debug('RADIO VALUE #####:'+selectedOption);
    if(selectedOption=='Yes'){
    methodYes();
    }
    else{
    methodNo();
    }
    }

    public void methodYes() {
    //makeSelectionNo=true;
    system.debug('*******makeSelectionNo*******'+makeSelectionNo);
    }
    public pageReference methodNo() {   
    selectedOption='No';   
    system.debug('*******entering to methodNo*******'+makeSelectionNo);


    if(AddPharmList!= NULL && AddPharmList.size()!= 0){
    List<C_Ops_SPLOA_Additional_Pharmacy__c> replacementList = new List<C_Ops_SPLOA_Additional_Pharmacy__c>();                
    AddPharmList = replacementList;
    system.debug('*******AddPharmList*******'+AddPharmList);
    }       

    return null;   
    }
    */

    public void populatedataforupdate(){
        AddPharmoldListcorrReq = new List<C_Ops_SPLOA_Additional_Pharmacy__c >();
        if(corrReqId !=null ){
            if(reqTyp == 'update' ){correctionReq = true;}
            oldcurrRequest=[select Id,Name,C_Ops_SPLOA_First_Name__c,C_Ops_SPLOA_Last_Name__c,C_Ops_SPLOA_Phone__c,C_Ops_SPLOA_Extension__c,C_Ops_SPLOA_Fax__c,C_Ops_SPLOA_Pharmacy_Name__c,C_Ops_SPLOA_Email__c,C_Ops_SPLOA_Primary_Distributor__c,C_Ops_SPLOA_DEA_Number__c,C_Ops_SPLOA_Street_Address__c,C_Ops_SPLOA_Street_Address_2__c,C_Ops_SPLOA_City__c,State__c,C_Ops_SPLOA_Zip__c,Website_URL__c,C_Ops_SPLOA_Product_Name__c,C_Ops_SPLOA_Request_Status__c,Processed_Date__c,Customer_Access_Type__c, File_will_be_emailed__c, SPLOA_Renewal__c  FROM C_Ops_SPLOA_Request__c WHERE Id=:corrReqId];
            AddPharmoldListcorrReq =[select name, C_Ops_SPLOA_DEA_Number__c,Pharmacy_Name__c,C_Ops_SPLOA_Street_Address__c,C_Ops_SPLOA_Street_Address_2__c,C_Ops_SPLOA_City__c,C_Ops_SPLOA_State__c,C_Ops_SPLOA_Zip__c,C_Ops_SPLOA_Request__c from C_Ops_SPLOA_Additional_Pharmacy__c where C_Ops_SPLOA_Request__c =:corrReqId];
            questionnairelist =[SELECT Id,Data_type__c,Answer__c,Parent_Question_Name__c,C_Ops_SPLOA_Question_Display_Order__c,Question_Label__c,Question_Type__c,C_Ops_SPLOA_Questionnaire__c,C_Ops_SPLOA_Request__c FROM C_Ops_SPLOA_Questionnaire_Questions__c WHERE C_Ops_SPLOA_Request__c=:corrReqId];
        }
        mainRequest = new C_Ops_SPLOA_Request__c();
        if(oldcurrRequest!=null){
         //   mainRequest.Id = oldcurrRequest.Id;
            mainRequest.C_Ops_SPLOA_Product_Name__c=oldcurrRequest.C_Ops_SPLOA_Product_Name__c;
            if(prodname !=null){mainRequest.C_Ops_SPLOA_Product_Name__c = prodname ;}
            mainRequest.C_Ops_SPLOA_First_Name__c=oldcurrRequest.C_Ops_SPLOA_First_Name__c;
            mainRequest.C_Ops_SPLOA_Last_Name__c=oldcurrRequest.C_Ops_SPLOA_Last_Name__c;
            mainRequest.C_Ops_SPLOA_Phone__c=oldcurrRequest.C_Ops_SPLOA_Phone__c;
            mainRequest.C_Ops_SPLOA_Extension__c=oldcurrRequest.C_Ops_SPLOA_Extension__c;
            mainRequest.C_Ops_SPLOA_Fax__c=oldcurrRequest.C_Ops_SPLOA_Fax__c;
            mainRequest.C_Ops_SPLOA_Email__c=oldcurrRequest.C_Ops_SPLOA_Email__c;
            mainRequest.C_Ops_SPLOA_Primary_Distributor__c=oldcurrRequest.C_Ops_SPLOA_Primary_Distributor__c;
            mainRequest.C_Ops_SPLOA_Pharmacy_Name__c=oldcurrRequest.C_Ops_SPLOA_Pharmacy_Name__c;
            mainRequest.C_Ops_SPLOA_DEA_Number__c=oldcurrRequest.C_Ops_SPLOA_DEA_Number__c;
            mainRequest.C_Ops_SPLOA_Street_Address__c=oldcurrRequest.C_Ops_SPLOA_Street_Address__c;
            mainRequest.C_Ops_SPLOA_Street_Address_2__c=oldcurrRequest.C_Ops_SPLOA_Street_Address_2__c;
            mainRequest.C_Ops_SPLOA_City__c=oldcurrRequest.C_Ops_SPLOA_City__c;
            mainRequest.State__c=oldcurrRequest.State__c;
            mainRequest.C_Ops_SPLOA_Zip__c=oldcurrRequest.C_Ops_SPLOA_Zip__c;
            mainRequest.Website_URL__c=oldcurrRequest.Website_URL__c;
            mainRequest.Customer_Access_Type__c = oldcurrRequest.Customer_Access_Type__c;
            //system.debug('Request type is' + requestType);
            mainRequest.Request_Type__c = getRequestType();
            if(reqTyp == 'update' ) {mainRequest.SPLOA_Renewal__c  = oldcurrRequest.SPLOA_Renewal__c == true;}
            /*   if(oldcurrRequest.SPLOA_Renewal__c!= null && oldcurrRequest.SPLOA_Renewal__c == true){
            reqTyp = 'renew';
            }*/
        }
        
        if(!AddPharmoldListcorrReq.isEmpty()){
            if(AddPharmList== null){
                AddPharmList =  new list<C_Ops_SPLOA_Additional_Pharmacy__c>();
            }
            for(C_Ops_SPLOA_Additional_Pharmacy__c oldPharm : AddPharmoldListcorrReq ){
                C_Ops_SPLOA_Additional_Pharmacy__c copyPharm= new C_Ops_SPLOA_Additional_Pharmacy__c();
                copyPharm.C_Ops_SPLOA_DEA_Number__c = oldPharm.C_Ops_SPLOA_DEA_Number__c;
                copyPharm.Pharmacy_Name__c = oldPharm.Pharmacy_Name__c;
                copyPharm.C_Ops_SPLOA_Street_Address__c = oldPharm.C_Ops_SPLOA_Street_Address__c;
                copyPharm.C_Ops_SPLOA_Street_Address_2__c = oldPharm.C_Ops_SPLOA_Street_Address_2__c;
                copyPharm.C_Ops_SPLOA_City__c = oldPharm.C_Ops_SPLOA_City__c;
                copyPharm.C_Ops_SPLOA_State__c = oldPharm.C_Ops_SPLOA_State__c;
                copyPharm.C_Ops_SPLOA_Zip__c = oldPharm.C_Ops_SPLOA_Zip__c;            
                AddPharmList.add(copyPharm);
            }
        }
        if(questionnairelist!= null && !questionnairelist.isempty()){
            QuesquestionscorrReq = new List<C_Ops_SPLOA_Questionnaire_Questions__c >();
            QuesquestionscorrReqMap = new Map<String,C_Ops_SPLOA_Questionnaire_Questions__c >();
            for(C_Ops_SPLOA_Questionnaire_Questions__c pharmques:questionnairelist){
                if(pharmques.Question_Type__c == 'Questionnaire'){
                    QuesquestionscorrReq.add(pharmques);
                    QuesquestionscorrReqMap.put(pharmques.Question_Label__c,pharmques);
                }
            }
        }
        
        if(AddPharmList != null && AddPharmList.size() > 0){selectedOption ='Yes';}        
    }

    //Method to pre populate for add product
    public void populatedataforaddprod(){
        AddPharmoldListcorrReq = new List<C_Ops_SPLOA_Additional_Pharmacy__c >();
        if(corrReqId!=null){
            if(reqTyp == 'addProd' )
                oldcurrRequest=[select Id,Name,C_Ops_SPLOA_First_Name__c,C_Ops_SPLOA_Last_Name__c,C_Ops_SPLOA_Phone__c,C_Ops_SPLOA_Extension__c,C_Ops_SPLOA_Fax__c,C_Ops_SPLOA_Pharmacy_Name__c,C_Ops_SPLOA_Email__c,C_Ops_SPLOA_Primary_Distributor__c,C_Ops_SPLOA_DEA_Number__c,C_Ops_SPLOA_Street_Address__c,C_Ops_SPLOA_Street_Address_2__c,C_Ops_SPLOA_City__c,State__c,C_Ops_SPLOA_Zip__c,Website_URL__c,C_Ops_SPLOA_Product_Name__c,C_Ops_SPLOA_Request_Status__c,Processed_Date__c,Customer_Access_Type__c, File_will_be_emailed__c, SPLOA_Renewal__c  FROM C_Ops_SPLOA_Request__c WHERE Id=:corrReqId];
            AddPharmoldListcorrReq =[select name, C_Ops_SPLOA_DEA_Number__c,Pharmacy_Name__c,C_Ops_SPLOA_Street_Address__c,C_Ops_SPLOA_Street_Address_2__c,C_Ops_SPLOA_City__c,C_Ops_SPLOA_State__c,C_Ops_SPLOA_Zip__c,C_Ops_SPLOA_Request__c from C_Ops_SPLOA_Additional_Pharmacy__c where C_Ops_SPLOA_Request__c =:corrReqId];
            questionnairelist =[SELECT Id,Data_type__c,Answer__c,Parent_Question_Name__c,C_Ops_SPLOA_Question_Display_Order__c,Question_Label__c,Question_Type__c,C_Ops_SPLOA_Questionnaire__c,C_Ops_SPLOA_Request__c FROM C_Ops_SPLOA_Questionnaire_Questions__c WHERE C_Ops_SPLOA_Request__c=:corrReqId];
        }
        mainRequest = new C_Ops_SPLOA_Request__c();
        if(oldcurrRequest!=null){
         //   mainRequest.Id = oldcurrRequest.Id;
            mainRequest.C_Ops_SPLOA_First_Name__c=oldcurrRequest.C_Ops_SPLOA_First_Name__c;
            mainRequest.C_Ops_SPLOA_Last_Name__c=oldcurrRequest.C_Ops_SPLOA_Last_Name__c;
            mainRequest.C_Ops_SPLOA_Phone__c=oldcurrRequest.C_Ops_SPLOA_Phone__c;
            mainRequest.C_Ops_SPLOA_Extension__c=oldcurrRequest.C_Ops_SPLOA_Extension__c;
            mainRequest.C_Ops_SPLOA_Fax__c=oldcurrRequest.C_Ops_SPLOA_Fax__c;
            mainRequest.C_Ops_SPLOA_Email__c=oldcurrRequest.C_Ops_SPLOA_Email__c;
            mainRequest.C_Ops_SPLOA_Primary_Distributor__c=oldcurrRequest.C_Ops_SPLOA_Primary_Distributor__c;
            mainRequest.C_Ops_SPLOA_Pharmacy_Name__c=oldcurrRequest.C_Ops_SPLOA_Pharmacy_Name__c;
            mainRequest.C_Ops_SPLOA_DEA_Number__c=oldcurrRequest.C_Ops_SPLOA_DEA_Number__c;
            mainRequest.C_Ops_SPLOA_Street_Address__c=oldcurrRequest.C_Ops_SPLOA_Street_Address__c;
            mainRequest.C_Ops_SPLOA_Street_Address_2__c=oldcurrRequest.C_Ops_SPLOA_Street_Address_2__c;
            mainRequest.C_Ops_SPLOA_City__c=oldcurrRequest.C_Ops_SPLOA_City__c;
            mainRequest.State__c=oldcurrRequest.State__c;
            mainRequest.C_Ops_SPLOA_Zip__c=oldcurrRequest.C_Ops_SPLOA_Zip__c;
            mainRequest.Website_URL__c=oldcurrRequest.Website_URL__c;
            //system.debug('Request type is' + requestType);
            mainRequest.Request_Type__c = getRequestType();
        }
    }
    
    //Method to pre populate for add site
    public void populatedataforaddsite(){
        AddPharmoldListcorrReq = new List<C_Ops_SPLOA_Additional_Pharmacy__c >();
        if(corrReqId!=null){
            if(reqTyp == 'addSite')
                oldcurrRequest=[select Id,Name,C_Ops_SPLOA_First_Name__c,C_Ops_SPLOA_Last_Name__c,C_Ops_SPLOA_Phone__c,C_Ops_SPLOA_Extension__c,C_Ops_SPLOA_Fax__c,C_Ops_SPLOA_Pharmacy_Name__c,C_Ops_SPLOA_Email__c,C_Ops_SPLOA_Primary_Distributor__c,C_Ops_SPLOA_DEA_Number__c,C_Ops_SPLOA_Street_Address__c,C_Ops_SPLOA_Street_Address_2__c,C_Ops_SPLOA_City__c,State__c,C_Ops_SPLOA_Zip__c,Website_URL__c,C_Ops_SPLOA_Product_Name__c,C_Ops_SPLOA_Request_Status__c,Processed_Date__c,Customer_Access_Type__c, File_will_be_emailed__c, SPLOA_Renewal__c  FROM C_Ops_SPLOA_Request__c WHERE Id=:corrReqId];
            AddPharmoldListcorrReq =[select name, C_Ops_SPLOA_DEA_Number__c,Pharmacy_Name__c,C_Ops_SPLOA_Street_Address__c,C_Ops_SPLOA_Street_Address_2__c,C_Ops_SPLOA_City__c,C_Ops_SPLOA_State__c,C_Ops_SPLOA_Zip__c,C_Ops_SPLOA_Request__c from C_Ops_SPLOA_Additional_Pharmacy__c where C_Ops_SPLOA_Request__c =:corrReqId];
            questionnairelist =[SELECT Id,Data_type__c,Answer__c,Parent_Question_Name__c,C_Ops_SPLOA_Question_Display_Order__c,Question_Label__c,Question_Type__c,C_Ops_SPLOA_Questionnaire__c,C_Ops_SPLOA_Request__c FROM C_Ops_SPLOA_Questionnaire_Questions__c WHERE C_Ops_SPLOA_Request__c=:corrReqId];
        }
        mainRequest = new C_Ops_SPLOA_Request__c();
        if(oldcurrRequest!=null){
            mainRequest.C_Ops_SPLOA_Product_Name__c=oldcurrRequest.C_Ops_SPLOA_Product_Name__c;
          //  mainRequest.Id = oldcurrRequest.Id;
            mainRequest.C_Ops_SPLOA_First_Name__c=oldcurrRequest.C_Ops_SPLOA_First_Name__c;
            mainRequest.C_Ops_SPLOA_Last_Name__c=oldcurrRequest.C_Ops_SPLOA_Last_Name__c;
            mainRequest.C_Ops_SPLOA_Phone__c=oldcurrRequest.C_Ops_SPLOA_Phone__c;
            mainRequest.C_Ops_SPLOA_Extension__c=oldcurrRequest.C_Ops_SPLOA_Extension__c;
            mainRequest.C_Ops_SPLOA_Fax__c=oldcurrRequest.C_Ops_SPLOA_Fax__c;
            mainRequest.C_Ops_SPLOA_Email__c=oldcurrRequest.C_Ops_SPLOA_Email__c;
            mainRequest.C_Ops_SPLOA_Primary_Distributor__c=oldcurrRequest.C_Ops_SPLOA_Primary_Distributor__c;
            mainRequest.C_Ops_SPLOA_Pharmacy_Name__c=oldcurrRequest.C_Ops_SPLOA_Pharmacy_Name__c;
            mainRequest.C_Ops_SPLOA_DEA_Number__c=oldcurrRequest.C_Ops_SPLOA_DEA_Number__c;
            mainRequest.C_Ops_SPLOA_Street_Address__c=oldcurrRequest.C_Ops_SPLOA_Street_Address__c;
            mainRequest.C_Ops_SPLOA_Street_Address_2__c=oldcurrRequest.C_Ops_SPLOA_Street_Address_2__c;
            mainRequest.C_Ops_SPLOA_City__c=oldcurrRequest.C_Ops_SPLOA_City__c;
            mainRequest.State__c=oldcurrRequest.State__c;
            mainRequest.C_Ops_SPLOA_Zip__c=oldcurrRequest.C_Ops_SPLOA_Zip__c;
            mainRequest.Website_URL__c=oldcurrRequest.Website_URL__c;
            //system.debug('Request type is' + requestType);
            mainRequest.Request_Type__c = getRequestType();
        }
    }
    
    //To check whether entered string is valid
    public void verifyValidProduct(){
        if(String.isBlank(mainRequest.C_Ops_SPLOA_Product_Name__c)){
            errorMessage = 'Product Name is missing';
            handleError(errorMessage);
            return;
        }   
        boolean findit=false;
        mainRequest.C_Ops_SPLOA_Product_Name__c=mainRequest.C_Ops_SPLOA_Product_Name__c.trim();
        for(C_Ops_SPLOA_Product__c prod:productslsts ){
            String prodName = prod.Name; 
            if (mainRequest.C_Ops_SPLOA_Product_Name__c.equalsIgnoreCase(prodName )) {
                findit=true;  
                break;
            }        
        }
        if(!findit) {
            errorMessage = 'The Product you entered is not a Genentech Product, please confirm the product name on the prescription';
            handleError(errorMessage);
        }        
    }
    //Methods related to first page
    
    public void checkreqforaddprod(){
        // Added below code to check for add product functionality
        if( reqTyp == 'addProd' && mainRequest.C_Ops_SPLOA_Email__c != null && mainRequest.C_Ops_SPLOA_DEA_Number__c !=null && mainRequest.C_Ops_SPLOA_Product_Name__c != null){
            system.debug('inside the correct method');
            List<C_Ops_SPLOA_Request__c> reqlist  = new List<C_Ops_SPLOA_Request__c>([SELECT Id,C_Ops_SPLOA_Email__c ,Name  ,C_Ops_SPLOA_DEA_Number__c, Processed_Date__c,C_Ops_SPLOA_Request_Status__c,C_Ops_SPLOA_Product_Name__c,Submission_Date__c   FROM C_Ops_SPLOA_Request__c WHERE C_Ops_SPLOA_Email__c =: mainRequest.C_Ops_SPLOA_Email__c AND C_Ops_SPLOA_DEA_Number__c =:mainRequest.C_Ops_SPLOA_DEA_Number__c AND C_Ops_SPLOA_Product_Name__c =: mainRequest.C_Ops_SPLOA_Product_Name__c AND (C_Ops_SPLOA_Request_Status__c != 'Processed' OR C_Ops_SPLOA_Request_Status__c != 'Expired' OR C_Ops_SPLOA_Request_Status__c != 'Denied' ) ] );
            if(reqlist!= null && reqlist.size()>0){
                errorMessage = 'There is currently a request being processed for this product and facility. If you are trying to revise a request that has already been submitted please email indirectaccess@gene.com';
                handleError(errorMessage);
            }
        }        
    }
    
    //Method to check the product name entered and display the name of product(s)
    public void findProducts(){
        showList = false;
        errorMessage = '';

        List<C_Ops_SPLOA_Product__c> prdNameOptions= new  List<C_Ops_SPLOA_Product__c>();
        
        if(String.isNotBlank(mainRequest.C_Ops_SPLOA_Product_Name__c)) 
            mainRequest.C_Ops_SPLOA_Product_Name__c = mainRequest.C_Ops_SPLOA_Product_Name__c.trim();
        searchKey = mainRequest.C_Ops_SPLOA_Product_Name__c;
        
        if(String.isNotBlank(searchKey) && searchKey.trim().length() >= 3 ){
            for(C_Ops_SPLOA_Product__c prod:productslsts ){
                String prodName = prod.Name; 
                if (prodName.startsWithIgnoreCase(searchKey)) {
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
                    if(prdNameOptions.size() == 1 ){
                        SelectedProductName =prdNameOptions[0].Name;
                        mainRequest.C_Ops_SPLOA_Product_Name__c = SelectedProductName ;
                    }
                    else{
                        showList = true;
                        productslist = new List<SelectOption>();
                        for(C_Ops_SPLOA_Product__c prod : prdNameOptions){
                            productslist.add(new SelectOption(prod.Name,prod.Name));
                        }
                        productslist.add(new SelectOption('None','Enter Other Genentech Product'));
                    }  
                }
            }            
        }
        UpdateselectedProduct();
        //checkreqforaddprod();
    }
    
    
    //Method to handle multi product list
    public void UpdateselectedProduct(){
        if(mainRequest.C_Ops_SPLOA_Product_Name__c == 'None'){
            mainRequest.C_Ops_SPLOA_Product_Name__c = '';
            showList = false;
        }
    }
    
    
    //Querying all Active and Effective Questions
    public void queryAllquestions(){
        Allquestions  =   [SELECT Id,Name , C_Ops_SPLOA_Active__c , C_Ops_SPLOA_Credential__c , C_Ops_SPLOA_Customer_Type__c , C_Ops_SPLOA_Data_Type__c,
                           C_Ops_SPLOA_Effective_Date__c , Has_Next_Question__c , C_Ops_SPLOA_Has_Subquestion__c  ,Manual_review__c , Product__c , Answer__c,Attachement_required__c,
                           C_Ops_SPLOA_Question_Display_Order__c , C_Ops_SPLOA_Question_Label__c , Question_Type__c , Super_exceeded_question__c , alternative_value__c , C_Ops_SPLOA_Applicable_To__c , IDbackup__c  
                           FROM C_Ops_SPLOA_Questions__c
                           WHERE C_Ops_SPLOA_Active__c =  True AND C_Ops_SPLOA_Effective_Date__c <= TODAY
                           ORDER BY C_Ops_SPLOA_Question_Display_Order__c ASC ];
    
         //Jie guest user fix code 10-2020
    
    for (C_Ops_SPLOA_Questions__c q:Allquestions ) {
           q.id=null;
       }
    
    }

    
    //Querying all Active and Effective sub Questions
    public void queryAllsubquestions(){
        Allsubquestions  =   [SELECT Id,Name , C_Ops_SPLOA_Active__c, C_Ops_SPLOA_Credential__c, Parent_Question__c,C_Ops_SPLOA_Data_Type__c,Date_Input__c,
                              C_Ops_SPLOA_Effective_Date__c , C_Ops_SPLOA_Next_Question_Needed__c , C_Ops_SPLOA_Question_Display_Order__c,Question_Label__c,Answer__c , Date_has_not_been_scheduled__c
                              FROM C_Ops_SPLOA_Sub_Question__c
                              WHERE C_Ops_SPLOA_Active__c =  True AND C_Ops_SPLOA_Effective_Date__c <= TODAY
                              ORDER BY C_Ops_SPLOA_Question_Display_Order__c ASC ];
                              
      //Jie guest user fix code 10-2020
       for (C_Ops_SPLOA_Sub_Question__c q:Allsubquestions   ) {
           q.id=null;
       }
    }
    //Method to add Additional Pharmacy Information
    public pageReference addAnotherPharmacy(){
        errorMessage = '';
        Boolean haveError = false;
        /*
        //Commenting below lines as per the Jira - ROBOCOPS-346
        // DEA format is not required
        if(mainRequest.C_Ops_SPLOA_DEA_Number__c == null || mainRequest.C_Ops_SPLOA_DEA_Number__c == '' || !isValidDEA(mainRequest.C_Ops_SPLOA_DEA_Number__c)  ){
        errorMessage = 'DEA number format is incorrect';
        handleError(errorMessage);
        haveError = true;
        }
        else{
        errorMessage = null;
        haveError = false;
        }  
        */
        if(haveError != true) {
            currAddPharm = new C_Ops_SPLOA_Additional_Pharmacy__c();
            if(AddPharmList== null){
                AddPharmList =  new list<C_Ops_SPLOA_Additional_Pharmacy__c>();
            }
            pageReference c_ops_sploa_addpharm = new PageReference('/apex/C_OPS_SPLOA_ADDPHARM');
            c_ops_sploa_addpharm.setRedirect(false);
            return c_ops_sploa_addpharm ;
        }
        return null;
        
    }
    
    public void checkingDEAdup(){
        errorMessage = '';
        
        if(!(isValidZip(currAddPharm.C_Ops_SPLOA_Zip__c)) || currAddPharm.C_Ops_SPLOA_Zip__c == null) {
            errorMessage = 'Please enter a valid ZIP code';
            handleError(errorMessage);
        }
        //Checking Curr Pharmacy is valid
        /*
        //Commenting below lines as per the Jira - ROBOCOPS-346
        // DEA format is not required
        if(!(isValidDEA(currAddPharm.C_Ops_SPLOA_DEA_Number__c))) {
        errorMessage = 'DEA number format is incorrect';
        handleError(errorMessage);
        }
        */
        //Checking Curr Pharmacy is matching with Main Pharmacy DEA
        if(currAddPharm.C_Ops_SPLOA_DEA_Number__c == mainRequest.C_Ops_SPLOA_DEA_Number__c){
            errorMessage = 'Please enter a unique DEA Number';
            handleError(errorMessage);
        }
        //Checking the current DEA is matching with Add Pharmacy list -- When we add new Add Pharm
        if(AddPharmList.size()>0 && isEditAddPharm != true){
            for(C_Ops_SPLOA_Additional_Pharmacy__c   AddPharm : AddPharmList){
                if(AddPharm.C_Ops_SPLOA_DEA_Number__c ==  currAddPharm.C_Ops_SPLOA_DEA_Number__c){
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
    }
    
    //Method to commit entered Additional Pharmacy
    public PageReference commitAddPharm() {
        //makeSelectionNo=true;
        
        checkingDEAdup();
        haveDEAError = ApexPages.hasMessages() || String.isNotBlank(errorMessage);
        
        if(haveDEAError == false){
            if(isEditAddPharm != true){
                AddPharmList.add(currAddPharm);
            }
            isEditAddPharm = false;
            pageReference c_ops_sploa_contact_infopg = new PageReference('/apex/C_OPS_SPLOA_CONTACT_INFOPG');
            c_ops_sploa_contact_infopg.setRedirect(false);
            return c_ops_sploa_contact_infopg ;
        }
        
        return null;
    }
    
    //Method to cancel entered Additional Pharmacy
    public PageReference cancelAddPharm() {
        errorMessage = null;
        pageReference c_ops_sploa_contact_infopg = new PageReference('/apex/C_OPS_SPLOA_CONTACT_INFOPG');
        c_ops_sploa_contact_infopg.setRedirect(false);
        return c_ops_sploa_contact_infopg ;
    }
    
    //Method to edit added Additional Pharmacy
    public PageReference editAddPharm(){
        isEditAddPharm = true;                  
        requestToEdit = Apexpages.currentpage().getParameters().get('editIndex');
        
        for(C_Ops_SPLOA_Additional_Pharmacy__c r: AddPharmList){                      
            if(r.C_Ops_SPLOA_DEA_Number__c == requestToEdit)
                currAddPharm = r;
        }
        
        pageReference c_ops_sploa_addpharm = new PageReference('/apex/C_OPS_SPLOA_ADDPHARM');
        c_ops_sploa_addpharm.setRedirect(false);
        return c_ops_sploa_addpharm ;
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
        if(AddPharmList.size()<=0 && reqTyp != 'addSite') selectedOption='No';
        else selectedOption='Yes';
    }
    
    private boolean emptyString(String s){
        if(s==null || s.trim().length()<=0) return true;        
        
        else return false;
    }
    
    public boolean isValidZip(string z){        
        if(z.length() == 0){            
            return false;
        }
        
        Pattern zipCodeChecker = Pattern.compile('^(\\d{5}(\\-\\d{4})?)?$');
        Matcher zipMatcher = ZipCodeChecker.matcher(z);
        
        return (zipMatcher.matches());            
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
    
    public boolean isValidDEA(string z){        
        if(z.length() == 0 ){            
            return false;
        }
        
        Pattern zipCodeChecker = Pattern.compile('[a-zA-Z]{2}[0-9]{7}');
        Matcher zipMatcher = ZipCodeChecker.matcher(z);
        
        return (zipMatcher.matches());            
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
    
    //Method to check for Errors in the Contact Info Page
    public void checkforErrors(){
        errorMessage = '';
        verifyValidProduct();
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
        if(emptyString(mainRequest.C_Ops_SPLOA_Pharmacy_Name__c)) {
            errorMessage = 'Primary Pharmacy Name is missing';
            handleError(errorMessage);
        }
        if(emptyString(mainRequest.C_Ops_SPLOA_DEA_Number__c)) {
            errorMessage = 'Primary DEA Number is missing';
            handleError(errorMessage);
        }
        /*
        //Commenting below lines as per the Jira - ROBOCOPS-346
        // DEA format is not required
        if(!emptyString(mainRequest.C_Ops_SPLOA_DEA_Number__c) && (!isValidDEA(mainRequest.C_Ops_SPLOA_DEA_Number__c))) {
        errorMessage = 'DEA Number format is incorrect';
        handleError(errorMessage);
        }
        */
        if(emptyString(mainRequest.C_Ops_SPLOA_Street_Address__c)) {
            errorMessage = 'Address Line 1 is missing';
            handleError(errorMessage);
        }
        if(emptyString(mainRequest.C_Ops_SPLOA_City__c)) {
            errorMessage = 'City field is missing';
            handleError(errorMessage);
        }
        if(emptyString(mainRequest.State__c)) {
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
        
    }    
    
    //Method to determine the Pharmacy Questions related to Selected Product
    public void findPharQues() {
        queryAllquestions();
        queryAllsubquestions();
        String products;
        List<C_Ops_SPLOA_Questions__c> AllselectedProdPharmQues = new  List<C_Ops_SPLOA_Questions__c>();
        for(C_Ops_SPLOA_Questions__c question:Allquestions){
            if(question.Product__c!=null){
                products = question.Product__c;
                products =products.touppercase();
            }                        
            if(SelectedProductName!=null){
                SelectedProductName =  SelectedProductName.touppercase();
            }
            List<String> productlist = products.split(';');
            if(SelectedProductName!=null && productlist.contains(SelectedProductName) && question.Question_Type__c == 'Pharmacy Questions'){
                if(question.Answer__c != null && productNamechanged && question.C_Ops_SPLOA_Applicable_To__c != null && question.C_Ops_SPLOA_Applicable_To__c == 'Both'){
                    question.Answer__c = null;
                }
                if((reqTyp == 'renew' || (reqTyp == 'update' && mainRequest.SPLOA_Renewal__c  == true) )&& productNamechanged && question.C_Ops_SPLOA_Applicable_To__c != null && question.C_Ops_SPLOA_Applicable_To__c == 'Contract Renewal Request'){
                    AllselectedProdPharmQues.add(question);
                }
                if((reqTyp == 'new' || reqTyp == 'addProd' || (reqTyp == 'update' && mainRequest.SPLOA_Renewal__c  == false) )&& productNamechanged && question.C_Ops_SPLOA_Applicable_To__c != null && question.C_Ops_SPLOA_Applicable_To__c == 'New Contract Request'){
                    AllselectedProdPharmQues.add(question);
                }
                /*  if(reqTyp == 'update'){
                if( mainRequest.SPLOA_Renewal__c  == true && question.C_Ops_SPLOA_Applicable_To__c == 'Contract Renewal Request'){
                AllselectedProdPharmQues.add(question);
                }
                if(mainRequest.SPLOA_Renewal__c  == false && question.C_Ops_SPLOA_Applicable_To__c == 'New Contract Request'){
                AllselectedProdPharmQues.add(question);
                }
                }*/
                AllselectedProdPharmQues.add(question);
            }
        }
        
        if(AllselectedProdPharmQues.size()>0 ){   
            PharmacyQuestions = new List<C_Ops_SPLOA_Questions__c>();
            PharmacyQuestions = AllselectedProdPharmQues;
        }
    }
    
    //Method to check Duplicate Request in the system    
    public void checkfordupeRequest(){        
        
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
            
            //Checking for Existing Requests with product and main DEA number combination     
            List<C_Ops_SPLOA_Request__c> existingRequests =[SELECT Id,C_Ops_SPLOA_DEA_Number__c ,C_Ops_SPLOA_Product_Name__c, Processed_Date__c FROM C_Ops_SPLOA_Request__c
                                                            WHERE C_Ops_SPLOA_DEA_Number__c =: DEAlist AND  C_Ops_SPLOA_Product_Name__c =: product 
                                                            AND C_Ops_SPLOA_Request_Status__c != 'Denied' and C_Ops_SPLOA_Request_Status__c != 'Expired'
                                                            and (Processed_Date__c =null or Processed_Date__c >= :dupCheckStartingDateTime)];
            
            //Checking for Existing Requests with product , main DEA number and additional pharmacy combination 
            List<C_Ops_SPLOA_Request__c> existingRequestswithaddpharm =[SELECT Id,C_Ops_SPLOA_DEA_Number__c ,C_Ops_SPLOA_Product_Name__c, Processed_Date__c 
                                                                        FROM C_Ops_SPLOA_Request__c WHERE
                                                                        Id IN (SELECT C_Ops_SPLOA_Request__c FROM C_Ops_SPLOA_Additional_Pharmacy__c WHERE C_Ops_SPLOA_DEA_Number__c =: DEAlist ) AND
                                                                        C_Ops_SPLOA_Product_Name__c =: product AND C_Ops_SPLOA_Request_Status__c != 'Denied' and C_Ops_SPLOA_Request_Status__c != 'Expired'
                                                                        and (Processed_Date__c =null or Processed_Date__c >= :dupCheckStartingDateTime)];
            
            
            if(existingRequests.size() > 0 || existingRequestswithaddpharm.size() > 0){
                errorMessage = 'There is currently a request being processed for this product and facility. If you are trying to revise a request that has already been submitted please email indirectaccess@gene.com ';
                handleError(errorMessage);
            }
        }        
    } 

    //Method to check product name changed and refresh the list according to the change
    public PageReference pharmpageaction() {
        findPharQues();
        if(oldproductName!= null && oldproductName != mainRequest.C_Ops_SPLOA_Product_Name__c){
            productNamechanged  = true;
        }
        if(pharmqueswrapperlist == null || productNamechanged ){
            pharmqueswrapperlist = new List<pharmacyquestionswrapper>();
        }
        resetProductchange();
        
        if(PharmacyQuestions!=null &&  PharmacyQuestions.size()>0){
            List<C_Ops_SPLOA_Sub_Question__c> subquestionlist = new List<C_Ops_SPLOA_Sub_Question__c>();
            //new code to handle correction request
            if(correctionReq ){
                for(C_Ops_SPLOA_Questionnaire_Questions__c pharmques : questionnairelist){
                    if(pharmques.Question_Type__c == 'Pharmacy Questions'){
                        for(C_Ops_SPLOA_Questions__c  pharmQue  : PharmacyQuestions){
                            if(pharmques.Question_Label__c == pharmQue.C_Ops_SPLOA_Question_Label__c  ){
                                pharmQue.Answer__c = pharmques.Answer__c;
                            }
                        }
                        for(C_Ops_SPLOA_Sub_Question__c subquestion :Allsubquestions ){
                            if(pharmques.Question_Label__c == subquestion.Question_Label__c){
                                subquestion.Answer__c = pharmques.Answer__c;
                            }
                        }
                    }
                }
                for(C_Ops_SPLOA_Sub_Question__c subquestion :Allsubquestions ){
                    if(subquestion.Parent_Question__c == PharmacyQuestions[0].IDbackup__c && PharmacyQuestions[0].C_Ops_SPLOA_Has_Subquestion__c == true ){
                        subquestionlist.add(subquestion );
                    }
                }
                if( PharmacyQuestions.size()>0 && pharmqueswrapperlist.size() == 0){
                    for(C_Ops_SPLOA_Questions__c  pharmQue  : PharmacyQuestions){
                        if(PharmacyQuestions.indexOf(pharmQue) == 0 ){
                            pharmqueswrapperlist.add(new pharmacyquestionswrapper(pharmQue,PharmacyQuestions.indexOf(pharmQue)+1,subquestionlist ));
                        }
                        else if(PharmacyQuestions[0].Answer__c !='Yes' && PharmacyQuestions.indexOf(pharmQue) == 1 ){
                            pharmqueswrapperlist.add(new pharmacyquestionswrapper(pharmQue,PharmacyQuestions.indexOf(pharmQue)+1,subquestionlist ));
                        }
                    }
                }
            }
            else if(reqTyp == 'renew' && questionnairelist != null){
                
                for(C_Ops_SPLOA_Questionnaire_Questions__c pharmques : questionnairelist){
                    if(pharmques.Question_Type__c == 'Pharmacy Questions'){
                        for(C_Ops_SPLOA_Questions__c  pharmQue  : PharmacyQuestions){
                            if(pharmques.Question_Label__c == pharmQue.C_Ops_SPLOA_Question_Label__c  ){
                                pharmQue.Answer__c = pharmques.Answer__c;
                            }
                        }
                        for(C_Ops_SPLOA_Sub_Question__c subquestion :Allsubquestions ){
                            if(pharmques.Question_Label__c == subquestion.Question_Label__c){
                                subquestion.Answer__c = pharmques.Answer__c;
                            }
                        }
                    }
                }
                for(C_Ops_SPLOA_Sub_Question__c subquestion :Allsubquestions ){
                    if(subquestion.Parent_Question__c == PharmacyQuestions[0].IDbackup__c  && PharmacyQuestions[0].C_Ops_SPLOA_Has_Subquestion__c == true ){
                        subquestionlist.add(subquestion );
                    }
                }
                if( PharmacyQuestions.size()>0 && pharmqueswrapperlist.size() == 0){
                    for(C_Ops_SPLOA_Questions__c  pharmQue  : PharmacyQuestions){
                        if(PharmacyQuestions.indexOf(pharmQue) == 0 ){
                            pharmqueswrapperlist.add(new pharmacyquestionswrapper(pharmQue,PharmacyQuestions.indexOf(pharmQue)+1,subquestionlist ));
                        }
                        else if(PharmacyQuestions[0].Answer__c !='Yes' && PharmacyQuestions.indexOf(pharmQue) == 1 ){
                            pharmqueswrapperlist.add(new pharmacyquestionswrapper(pharmQue,PharmacyQuestions.indexOf(pharmQue)+1,subquestionlist ));
                        }
                    }
                }
                
            }
            
            else{
                
                for(C_Ops_SPLOA_Sub_Question__c subquestion :Allsubquestions ){
                    if(subquestion.Parent_Question__c == PharmacyQuestions[0].IDbackup__c && PharmacyQuestions[0].C_Ops_SPLOA_Has_Subquestion__c == true ){
                        subquestionlist.add(subquestion );
                    }
                }
                if(pharmqueswrapperlist!= null && PharmacyQuestions.size()>0 && pharmqueswrapperlist.size() == 0){
                    pharmqueswrapperlist.add(new pharmacyquestionswrapper(PharmacyQuestions[0],1,subquestionlist));
                }
            }
        }
        productNamechanged = false;
        oldproductName = mainRequest.C_Ops_SPLOA_Product_Name__c;
        return null;
    }
    
    //Clear the flags when Product Name is changed
    public void resetProductchange(){
        if(quesquestionswrapperlist !=null && quesquestionswrapperlist.size()>0 && productNamechanged ){
            quesquestionswrapperlist = new  List<quesquestionswrapper>();
        }
        if(productNamechanged ){
            superexceededset= false;
            mainRequest.File_will_be_emailed__c = False;
            removeUnusedAttachment();
            oldAttachmentID= null;
            UploadeddocName= null;
            mainRequest.Manual_review_required__c = False;
        }
    }
    
    public PageReference cancelToHome(){
        PageReference nextPage;  
        
        if(reqTyp == 'update'){
            nextPage=Page.C_OPS_SPLOA_CORRECTION_PAGE;
        }
        else  
            nextPage=Page.C_OPS_SPLOA_Request_Home; 
        return nextPage;    
    }

    //Method to navigate to Pharmacy Info Page if there is no error(s) in Contact Info Page
    public pageReference startSubmission(){
        if(oldproductName == null){
            oldproductName = mainRequest.C_Ops_SPLOA_Product_Name__c;
        }
        SelectedProductName = mainRequest.C_Ops_SPLOA_Product_Name__c;
        checkforErrors();
        if(!correctionReq ){
            checkfordupeRequest();
        }
        Boolean haveAuthError = ApexPages.hasMessages() || String.isNotBlank(errorMessage);
        if(!haveAuthError){
            if(reqTyp == 'addSite'){
                PageReference c_ops_sploa_reviewandsubmit= New PageReference('/apex/C_OPS_SPLOA_REVIEWANDSUBMIT');
                //c_ops_sploa_reviewandsubmit.setRedirect(false);
                return c_ops_sploa_reviewandsubmit;
            }
            else{
                PageReference c_ops_sploa_pharm_infopg = New PageReference('/apex/C_OPS_SPLOA_PHARM_INFOPG');
                c_ops_sploa_pharm_infopg.setRedirect(false);
                return c_ops_sploa_pharm_infopg ;
            }
        }
        productNamechanged  = false;
        
        return null;
    }
    
    //Method to Navigate to Contact Info Page from Pharmacy Info Page
    public pageReference backtofirstpage(){
        PageReference c_ops_sploa_pharm_infopg = New PageReference('/apex/C_OPS_SPLOA_CONTACT_INFOPG');
        c_ops_sploa_pharm_infopg.setRedirect(false);
        return c_ops_sploa_pharm_infopg ;
    }
    
    public void accesstypecheck(){
        //Assigning the access type value to Main Request
        if(pharmqueswrapperlist[0].Pharmques.Answer__c == PharmacyQuestions[0].C_Ops_SPLOA_Credential__c && PharmacyQuestions[0].C_Ops_SPLOA_Customer_Type__c != null && PharmacyQuestions[0].C_Ops_SPLOA_Credential__c != ''  ){
            mainRequest.Customer_Access_Type__c =    PharmacyQuestions[0].C_Ops_SPLOA_Customer_Type__c ;
        }
        else if((PharmacyQuestions[0].C_Ops_SPLOA_Credential__c == null || PharmacyQuestions[0].C_Ops_SPLOA_Credential__c == '' )&& (pharmqueswrapperlist[0].Pharmques.Answer__c == 'Yes' || pharmqueswrapperlist[0].Pharmques.Answer__c == 'No')  ){
            mainRequest.Customer_Access_Type__c =    PharmacyQuestions[0].C_Ops_SPLOA_Customer_Type__c ;
        }
        else if(pharmqueswrapperlist[0].Pharmques.Answer__c != PharmacyQuestions[0].C_Ops_SPLOA_Credential__c && PharmacyQuestions[0].alternative_value__c!= ''  ){
            mainRequest.Customer_Access_Type__c =    PharmacyQuestions[0].alternative_value__c;
        }
        if(pharmqueswrapperlist.size()>1){
            
            if(pharmqueswrapperlist[1].Pharmques.Answer__c == 'Yes' && PharmacyQuestions[0].C_Ops_SPLOA_Customer_Type__c != '' ){
                mainRequest.Customer_Access_Type__c =    PharmacyQuestions[1].C_Ops_SPLOA_Customer_Type__c ;
            }
            else if(pharmqueswrapperlist[1].Pharmques.Answer__c== 'No' && PharmacyQuestions[0].alternative_value__c!= '' ){
                mainRequest.Customer_Access_Type__c =    PharmacyQuestions[1].alternative_value__c;
            }
        }
    }

    //Method to Navigate to Questionnaire Page from Pharmacy Info Page
    public pageReference nextpagenavigation(){
        Boolean haveError = false;
        mainRequest.Submission_Date__c= date.today();
        
        accesstypecheck();
        
        for(pharmacyquestionswrapper pharmwrap  :pharmqueswrapperlist ){
            if(string.isBlank(pharmwrap.Pharmques.Answer__c)){
                haveError = true;
                errorMessage = 'Please answer all questions';
                handleError(errorMessage);
            }
        }
        if(pharmqueswrapperlist[0].Pharmques.Answer__c == 'Yes' && (pharmqueswrapperlist[0].subqueslist!= null && string.isBlank(pharmqueswrapperlist[0].subqueslist[0].Answer__c))){
            haveError = true;
            errorMessage = 'Please answer all questions';
            handleError(errorMessage);
        }
        if(haveError != true){
            RequestDenial = false;
          //  List<String> ProductNamesfordenial = new List<String>{'ACTEMRA','AVASTIN','GAZYVA','HERCEPTIN','KADCYLA','LUCENTIS','PERJETA','RITUXAN','TECENTRIQ','PHESGO'};
           //     List<String> ProductNamesfordenialonequestion = new List<String>{'ALECENSA','COTELLIC','ERIVEDGE','ZELBORAF','ROZLYTREK','NUTROPIN','POLIVY','TARCEVA','ESBRIET','XOLAIR','TARCEVA ONA','ENSPRYNG'};
                //    if(ProductNamesfordenial.contains(SelectedProductName) && pharmqueswrapperlist[0].Pharmques.Answer__c == 'No' && pharmqueswrapperlist[1].Pharmques.Answer__c =='No' ){
                    if(pharmqueswrapperlist.size() == 2 && pharmqueswrapperlist[0].Pharmques.Answer__c == 'No' && 
                        pharmqueswrapperlist[1].Pharmques.Answer__c =='No' && (pharmqueswrapperlist[1].Pharmques.alternative_value__c == '' || pharmqueswrapperlist[1].Pharmques.alternative_value__c == null)){
                        RequestDenial = true;
                        if( quesquestionswrapperlist != null && quesquestionswrapperlist.size()>0){
                            quesquestionswrapperlist = new  List<quesquestionswrapper>();
                        }
                        resetAccestypechange();
                    }
          //  else if(ProductNamesfordenialonequestion.contains(SelectedProductName) && pharmqueswrapperlist[0].Pharmques.Answer__c == 'No'){
            else if(pharmqueswrapperlist.size() == 1 && pharmqueswrapperlist[0].Pharmques.Answer__c == 'No' && 
                    (pharmqueswrapperlist[0].Pharmques.alternative_value__c == '' || pharmqueswrapperlist[0].Pharmques.alternative_value__c == null) && 
                    pharmqueswrapperlist[0].Pharmques.C_Ops_SPLOA_Credential__c != '' && pharmqueswrapperlist[0].Pharmques.C_Ops_SPLOA_Credential__c != null){
                RequestDenial = true;
                if(quesquestionswrapperlist != null && quesquestionswrapperlist.size()>0){
                    quesquestionswrapperlist = new  List<quesquestionswrapper>();
                }
                resetAccestypechange();
            }
            
            findQuestionnaireQues();
            
            if(RequestDenial == true ){
                PageReference c_ops_sploa_reviewandsubmit= New PageReference('/apex/C_OPS_SPLOA_REVIEWANDSUBMIT');
                c_ops_sploa_reviewandsubmit.setRedirect(false);
                return c_ops_sploa_reviewandsubmit;
            }  
            if(RequestDenial == false){
                PageReference c_ops_sploa_ques_page = New PageReference('/apex/C_OPS_SPLOA_QUES_PAGE');
                c_ops_sploa_ques_page.setRedirect(false);
                return c_ops_sploa_ques_page ;
            }
        }
        haveError = false;
        return null;
    }
    
    //Clear the data when Access type is changed
    public void resetAccestypechange(){
        superexceededset= false;
        mainRequest.File_will_be_emailed__c = False;
        removeUnusedAttachment();
        oldAttachmentID= null;
        UploadeddocName= null;
        mainRequest.Manual_review_required__c = False;
        accesstypechanged = true;
    }
    
    //Method to Navigate to Pharmacy Info Page from Questionnaire Page
    public PageReference prevpagenavigation() {
        PageReference c_ops_sploa_pharm_infopg= New PageReference('/apex/C_OPS_SPLOA_PHARM_INFOPG');
        c_ops_sploa_pharm_infopg.setRedirect(false);
        return c_ops_sploa_pharm_infopg;
    }
    
    //Method to show upload Document popup
    public void checksuperseededques(){
        Integer superseededmatch = 0;
        
        if(superseededQuestionnaireQuestions.size()>0){
            for(quesquestionswrapper   queswrp :  quesquestionswrapperlist){
                if(queswrp.queques.Super_exceeded_question__c == true && queswrp.queques.Answer__c == 'Yes'){
                    superseededmatch++;
                }
            }
        }
        if(superseededmatch!= 0 && superseededQuestionnaireQuestions.size()>0 && superseededmatch == superseededQuestionnaireQuestions.size()){
            superexceededset= true;
        }
        else{
            superexceededset= false;
        }
    }
    
    public PageReference  reviewandsubmitnavigation(){  
        Boolean haveError = false;
        for( quesquestionswrapper   queswrp : quesquestionswrapperlist){
            if(string.isBlank(queswrp.queques.Answer__c)){
                haveError  = true;
                errorMessage = 'Please answer all questions';
                handleError(errorMessage);
            }
            else if(queswrp.queques.Answer__c != null && queswrp.queques.C_Ops_SPLOA_Has_Subquestion__c == true && queswrp.queques.Answer__c == 'Yes' && queswrp.queques.C_Ops_SPLOA_Data_Type__c =='checkbox' ){
                for(C_Ops_SPLOA_Sub_Question__c  subques : queswrp.subqueslist){
                    if(string.isBlank(subques.Answer__c) && subques.C_Ops_SPLOA_Data_Type__c != 'Date'){
                        haveError  = true;
                        errorMessage = 'Please answer all questions';
                        handleError(errorMessage);
                    }
                    else if(subques.Date_Input__c == null && subques.Date_has_not_been_scheduled__c == false && subques.C_Ops_SPLOA_Data_Type__c == 'Date'){
                        haveError  = true;
                        errorMessage = 'Please answer all questions';
                        handleError(errorMessage);
                    }
                    else if(subques.Date_Input__c != null && subques.Date_has_not_been_scheduled__c == false && subques.C_Ops_SPLOA_Data_Type__c == 'Date'&& subques.Date_Input__c <= system.today()){
                        haveError  = true;
                        errorMessage = 'Please enter a future scheduled date';
                        handleError(errorMessage);
                    }
                    else if(subques.Answer__c == 'Select One' && subques.C_Ops_SPLOA_Data_Type__c == 'Picklist'){
                        haveError  = true;
                        errorMessage = 'Please answer all questions';
                        handleError(errorMessage);
                    }
                    else if(subques.C_Ops_SPLOA_Data_Type__c == 'date' && subques.Date_has_not_been_scheduled__c == true){
                        subques.Answer__c = 'Not Scheduled';
                    } 
                    else if(subques.C_Ops_SPLOA_Data_Type__c == 'date' && subques.Date_Input__c != null && subques.Date_has_not_been_scheduled__c != true ){
                        subques.Answer__c = string.valueOf(subques.Date_Input__c);
                    }
                    
                }
            }
            
        }
        if(haveError  != true){
            checksuperseededques();
            if(superexceededset == false){
                for( quesquestionswrapper   queswrp : quesquestionswrapperlist){
                    if(queswrp.queques.C_Ops_SPLOA_Data_Type__c == 'checkbox' && queswrp.queques.C_Ops_SPLOA_Credential__c != '' && queswrp.queques.C_Ops_SPLOA_Credential__c != null && queswrp.queques.C_Ops_SPLOA_Credential__c != '--None--' && queswrp.queques.Answer__c != queswrp.queques.C_Ops_SPLOA_Credential__c ){
                        RequestDenial = true;
                    }
                    else if(queswrp.subqueslist.size()>0 && queswrp.queques.C_Ops_SPLOA_Data_Type__c == 'checkbox' && queswrp.queques.Answer__c == 'Yes' && queswrp.queques.C_Ops_SPLOA_Has_Subquestion__c == true){
                        for(C_Ops_SPLOA_Sub_Question__c  subques : queswrp.subqueslist){
                            if(subques.C_Ops_SPLOA_Data_Type__c == 'Checkbox' && subques.C_Ops_SPLOA_Credential__c!= null && subques.C_Ops_SPLOA_Credential__c!= '' && subques.Answer__c != null && subques.Answer__c !=subques.C_Ops_SPLOA_Credential__c ){
                                RequestDenial = true;
                            }
                        }
                    }
                }
            }
            //Manual Review being set
            for(C_Ops_SPLOA_Questions__c  ques : QuestionnaireQuestions){
                if(ques.Manual_review__c == true)
                    mainRequest.Manual_review_required__c = true;
            }
            for( quesquestionswrapper   queswrp : quesquestionswrapperlist){
                if(queswrp.queques.Answer__c == 'Yes' && queswrp.queques.Attachement_required__c == true && 
                   (oldAttachmentId == null && mainRequest.File_will_be_emailed__c == false  )){
                    showfileupload = true;
                }
                else if(queswrp.queques.Answer__c == 'No' && queswrp.queques.Attachement_required__c == true ){
                    removeUnusedAttachment();
                    UploadeddocName= null;
                    mainRequest.File_will_be_emailed__c = false;
                }
            }
            //Check for request accept or denial
            if(showfileupload == false){
                PageReference c_ops_sploa_reviewandsubmit= New PageReference('/apex/C_OPS_SPLOA_REVIEWANDSUBMIT');
                c_ops_sploa_reviewandsubmit.setRedirect(false);
                return c_ops_sploa_reviewandsubmit;
            }
        }        
        return null;
        
    }
    
    //Method to replace doc
    public PageReference updateDoc() {
        showfileupload = true;
        return null;
    }    
    
    public PageReference updatingFileemail() {
        
        if(oldAttachmentId != null){
            removeUnusedAttachment();
            oldAttachmentID= null;
            UploadeddocName= null;
            
        }
        showfileupload = false;
        mainRequest.File_will_be_emailed__c = true;
        PageReference c_ops_sploa_reviewandsubmit= New PageReference('/apex/C_OPS_SPLOA_REVIEWANDSUBMIT');
        c_ops_sploa_reviewandsubmit.setRedirect(false);
        return c_ops_sploa_reviewandsubmit;
    }

    //Wrapper Class to handle Pharmacy Questions and its Answers
    class pharmacyquestionswrapper{
        public C_Ops_SPLOA_Questions__c Pharmques{get;set;}
        public Integer iIndex {get;set;}
        public List<C_Ops_SPLOA_Sub_Question__c> subqueslist{get;set;}
        public pharmacyquestionswrapper(C_Ops_SPLOA_Questions__c  Pharmque, Integer iRow, List<C_Ops_SPLOA_Sub_Question__c> subquelist){
            this.Pharmques = Pharmque;
            this.iIndex = iRow;
            this.subqueslist= subquelist;
            
        }
    }
    
    public pageReference backtoquespage(){        
        
        PageReference c_ops_sploa_ques_page = New PageReference('/apex/C_OPS_SPLOA_QUES_PAGE');
        c_ops_sploa_ques_page.setRedirect(false);
        return c_ops_sploa_ques_page ;
    }
    
    public string oldAttachmentID {get;set;}
    public Boolean documentuploaded{get;set;}
    public String UploadeddocName {get;set;}
    
    //Method to check the document provided to upload is fine
    public PageReference uploadDoc(){
        
        if(document==null || String.IsBlank(document.Name) ){            
            errorMessage = 'You must choose a file before uploading';
            handleError(errorMessage);  
            return null;  
        }
        
        if(document.Name.right(4).containsIgnoreCase('.jpg')||
           document.Name.right(4).containsIgnoreCase('.pdf')||
           document.Name.right(4).containsIgnoreCase('.png')||
           document.Name.right(4).containsIgnoreCase('.jpg')||
           document.Name.right(5).containsIgnoreCase('.jpeg')||
           document.Name.right(4).containsIgnoreCase('.gif')||
           document.Name.right(4).containsIgnoreCase('.tif')||
           document.Name.right(4).containsIgnoreCase('.jif')||
           document.Name.right(5).containsIgnoreCase('.jfif')||
           document.Name.right(4).containsIgnoreCase('.jfi')||
           document.Name.right(5).containsIgnoreCase('.tiff')||
           document.Name.right(4).containsIgnoreCase('.psd')||
           document.Name.right(4).containsIgnoreCase('.raw')||
           document.Name.right(4).containsIgnoreCase('.arw')||
           document.Name.right(4).containsIgnoreCase('.cr2')||
           document.Name.right(4).containsIgnoreCase('.nrw')||
           document.Name.right(4).containsIgnoreCase('.k25')||
           document.Name.right(4).containsIgnoreCase('.bmp')||
           document.Name.right(4).containsIgnoreCase('.dib')
          ) {
              document.parentId = prop.Id;
              insert document;    
              removeUnusedAttachment();
              UploadeddocName = document.Name;
              oldAttachmentID = document.id;
              
              if(mainRequest.File_will_be_emailed__c == true){
                  mainRequest.File_will_be_emailed__c = false;
              }
              
              document = new Attachment();
              documentuploaded = true;
              showfileupload = false;
              //Jie - remove email file flag
              mainRequest.File_will_be_emailed__c=false;
              PageReference c_ops_sploa_reviewandsubmit= New PageReference('/apex/C_OPS_SPLOA_REVIEWANDSUBMIT');
              c_ops_sploa_reviewandsubmit.setRedirect(false);
              return c_ops_sploa_reviewandsubmit;
              
          }
        else{            
            string error = 'File Uploads are restricted to files of type pdf/image. Please upload a valid file type.';            
            handleError(error);
            return null;            
        }
    }
    
    private void removeUnusedAttachment(){
        Attachment att;
        if(oldAttachmentID!=null) {      
            List<Attachment> atts=[SELECT ID from Attachment where id =: oldAttachmentId];
            if (atts!=null && atts.size()>0) delete atts;
            oldAttachmentID=null;
        }
        
    }
    
    //Method to display Next question dynamically from Pharmacy Info page
    public void nextpharmquestion(){
        if(PharmacyQuestions.size()>1 ){
            
            if(pharmqueswrapperlist[0].Pharmques.Answer__c== 'No' && PharmacyQuestions[0].C_Ops_SPLOA_Customer_Type__c != '' && pharmqueswrapperlist.size() == 1){
                if(PharmacyQuestions[1].Answer__c!= null){
                    PharmacyQuestions[1].Answer__c = null;
                }
                pharmqueswrapperlist.add(new pharmacyquestionswrapper(PharmacyQuestions[1],2,null));  
            }
            else if (pharmqueswrapperlist[0].Pharmques.Answer__c == 'Yes' && pharmqueswrapperlist.size() == 2){
                pharmqueswrapperlist.remove(1);  
            }
        }
    }
    
    
    //Wrapper Class to handle Pharmacy Questions and its Answers
    public class quesquestionswrapper{
        public C_Ops_SPLOA_Questions__c queques{get;set;}
        public Integer iIndex {get;set;}
        public List<C_Ops_SPLOA_Sub_Question__c> subqueslist{get;set;}
        public quesquestionswrapper(C_Ops_SPLOA_Questions__c  queques, Integer iRow, List<C_Ops_SPLOA_Sub_Question__c> subquelist){
            this.queques = queques;
            this.iIndex = iRow;
            this.subqueslist= subquelist;
        }
    }
    
    public void closePopup() {        
        showfileupload = false;    
    }
    
    
    public void pharmQueschk() {
        if(quesquestionswrapperlist == null){
            quesquestionswrapperlist = new  List<quesquestionswrapper>();
        }
        if(oldaccesstype==null){
            oldaccesstype =  mainRequest.Customer_Access_Type__c;
        }
        else if(oldaccesstype !=mainRequest.Customer_Access_Type__c){
            quesquestionswrapperlist = new  List<quesquestionswrapper>();
            resetAccestypechange();
        }
        
        if(quesquestionswrapperlist!= null && quesquestionswrapperlist.size() == 0 && quesMap!=null ){
            for(C_Ops_SPLOA_Questions__c ques : quesMap.keyset()){
                quesquestionswrapperlist.add(new quesquestionswrapper(ques,QuestionnaireQuestions.Indexof(ques)+1,quesMap.get(ques) ));
            }
        }
        RequestDenial = false;
        oldaccesstype =  mainRequest.Customer_Access_Type__c;
        
    }    
    
    //Method to determine the Questionnaire Questions related to Selected Product and Access Type
    public void findQuestionnaireQues() {
        qquescounter++;
        QuestionnaireQuestions = new List<C_Ops_SPLOA_Questions__c>();
        superseededQuestionnaireQuestions = new List<C_Ops_SPLOA_Questions__c>();
        quesMap = new Map<C_Ops_SPLOA_Questions__c,List<C_Ops_SPLOA_Sub_Question__c>>();
        List<C_Ops_SPLOA_Questions__c> AllselectedProdQuesQues = new  List<C_Ops_SPLOA_Questions__c>();
        List<C_Ops_SPLOA_Sub_Question__c> subquestionlist = new List<C_Ops_SPLOA_Sub_Question__c>();
        String products;
        for(C_Ops_SPLOA_Questions__c question:Allquestions){
            if(question.Product__c!=null){
                products = question.Product__c;
                products  =products.touppercase();
            }
            List<String> productlist = new List<string>();
            productlist  = products.split(';');
            SelectedProductName =  SelectedProductName.touppercase();
            subquestionlist = new List<C_Ops_SPLOA_Sub_Question__c>();
            if(SelectedProductName!=null && productlist.contains(SelectedProductName) && question.Question_Type__c == 'Questionnaire' && mainRequest.Customer_Access_Type__c==question.C_Ops_SPLOA_Customer_Type__c ){
                AllselectedProdQuesQues.add(question);
                if(question.Super_exceeded_question__c != null && question.Super_exceeded_question__c   ==true)
                    superseededQuestionnaireQuestions.add(question);
                if((correctionReq || renewRequest)  && QuesquestionscorrReqMap!= null && QuesquestionscorrReqMap.size()>0 && QuesquestionscorrReqMap.get(question.C_Ops_SPLOA_Question_Label__c)!= null ){
                    question.Answer__c = QuesquestionscorrReqMap.get(question.C_Ops_SPLOA_Question_Label__c).Answer__c;
                }
                for(C_Ops_SPLOA_Sub_Question__c subquestion :Allsubquestions ){
                    if((correctionReq || renewRequest)  && QuesquestionscorrReqMap!= null && QuesquestionscorrReqMap.size()>0 && QuesquestionscorrReqMap.get(subquestion.Question_Label__c)!= null ){
                        subquestion.Answer__c = QuesquestionscorrReqMap.get(subquestion.Question_Label__c).Answer__c;
                    }
                    if((correctionReq || renewRequest) && QuesquestionscorrReqMap!= null && QuesquestionscorrReqMap.size()>0 && QuesquestionscorrReqMap.get(subquestion.Question_Label__c)!= null && subquestion.C_Ops_SPLOA_Data_Type__c == 'Date'){
                        if(QuesquestionscorrReqMap.get(subquestion.Question_Label__c).Answer__c == 'Not Scheduled'){
                            subquestion.Date_has_not_been_scheduled__c = true;
                        }
                        else{
                            subquestion.Date_Input__c = date.valueOf(QuesquestionscorrReqMap.get(subquestion.Question_Label__c).Answer__c);
                        }
                    }
                    if(subquestion.Parent_Question__c == question.IDbackup__c && question.C_Ops_SPLOA_Has_Subquestion__c == true ){
                        subquestionlist.add(subquestion );
                    }
                    if(question.C_Ops_SPLOA_Applicable_To__c == 'Both'){
                        quesMap.put(question,subquestionlist);
                    }
                    if((reqTyp == 'renew' || (reqTyp == 'update' && mainRequest.SPLOA_Renewal__c  == true) ) &&  question.C_Ops_SPLOA_Applicable_To__c == 'Contract Renewal Request'){
                        quesMap.put(question,subquestionlist);
                    }
                    if((reqTyp == 'new' || reqTyp == 'addProd' || (reqTyp == 'update' && mainRequest.SPLOA_Renewal__c  == false) ) && question.C_Ops_SPLOA_Applicable_To__c == 'New Contract Request'){
                        quesMap.put(question,subquestionlist);
                    }
                }
                if(question.C_Ops_SPLOA_Applicable_To__c == 'Both'){ QuestionnaireQuestions.add(question);}
                if((reqTyp == 'renew' || (reqTyp == 'update' && mainRequest.SPLOA_Renewal__c  == true) ) &&  question.C_Ops_SPLOA_Applicable_To__c == 'Contract Renewal Request'){ QuestionnaireQuestions.add(question);}
                if((reqTyp == 'new'|| reqTyp == 'addProd' || (reqTyp == 'update' && mainRequest.SPLOA_Renewal__c  == false) ) && question.C_Ops_SPLOA_Applicable_To__c == 'New Contract Request'){QuestionnaireQuestions.add(question);}
            }
        }
    }
    
    public PageReference returntocontactinfopage() {
        PageReference c_ops_sploa_pharm_infopg = New PageReference('/apex/C_OPS_SPLOA_CONTACT_INFOPG');
        c_ops_sploa_pharm_infopg.setRedirect(false);
        return c_ops_sploa_pharm_infopg ;
    }
    public PageReference returntopharminfopage(){
        PageReference c_ops_sploa_pharm_infopg= New PageReference('/apex/C_OPS_SPLOA_PHARM_INFOPG');
        c_ops_sploa_pharm_infopg.setRedirect(false);
        return c_ops_sploa_pharm_infopg;
    }
    
    public PageReference returntoquesinfopage(){
        if(addpharmacayOption == true){
            PageReference c_ops_sploa_ques_page = New PageReference('/apex/C_OPS_SPLOA_CONTACT_INFOPG');
            c_ops_sploa_ques_page.setRedirect(false);
            return c_ops_sploa_ques_page ;
        }
        if(quesquestionswrapperlist != null && quesquestionswrapperlist.size()>0){
            PageReference c_ops_sploa_ques_page = New PageReference('/apex/C_OPS_SPLOA_QUES_PAGE');
            c_ops_sploa_ques_page.setRedirect(false);
            return c_ops_sploa_ques_page ;
        }
        else{
            PageReference c_ops_sploa_pharm_infopg= New PageReference('/apex/C_OPS_SPLOA_PHARM_INFOPG');
            c_ops_sploa_pharm_infopg.setRedirect(false);
            return c_ops_sploa_pharm_infopg;
        }
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
    
    public PageReference reachedreviewandsubmit() {
        return null;
    }
    
    //Creation of records into DB: SPLOA Requests ,Pharmacy and Questionnaire Questions, Sub questions , Attach the Doc to the Request , Create and Attach PDF
    public void createRecords(){
        errorMessage ='';
        
        system.debug(mainRequest.Authorised__c+mainRequest.Signee_First_Name__c+mainRequest.Signee_Last_Name__c+mainRequest.Signee_Title__c);
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
            if(reqTyp != 'renew'){
                if(superexceededset == true || RequestDenial != true){
                    mainRequest.C_Ops_SPLOA_Request_Status__c = 'New';
                }
                else if(RequestDenial == true){
                    mainRequest.Date_Denied_If_Applicable__c = system.now();
                    mainRequest.C_Ops_SPLOA_Request_Status__c = 'Denied';
                }
            }
            else if(reqTyp == 'renew'){
                mainRequest.C_Ops_SPLOA_Request_Status__c = 'New';
                mainRequest.SPLOA_Renewal__c = true;
            }
            mainRequest.Submission_Date_Time__c= system.now();
            mainRequest.Request_Type__c = getRequestType();
            
            try{
                Insert mainRequest;
            }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
            
            
            
            mainRequestId = mainRequest.Id;
            
            
            if(mainRequestId != null){
                
                
                if(oldAttachmentID!=null && oldAttachmentID != '') document = [SELECT NAME, body from Attachment where id =: oldAttachmentID];
                
                if(document.Id != null){
                    Attachment clonedAtt = new Attachment();
                    
                    clonedAtt.Name = document.Name;
                    clonedAtt.Body = document.Body;
                    
                    delete document;
                    
                    
                    clonedAtt.ParentId = mainRequestId;
                    
                    insert clonedAtt;
                }
                if(AddPharmList != null && AddPharmList.size()>0){
                    for(C_Ops_SPLOA_Additional_Pharmacy__c addPharm :AddPharmList){
                        addPharm.C_Ops_SPLOA_Request__c = mainRequestId;
                    }
                    Insert AddPharmList;
                }
                
                List<C_Ops_SPLOA_Questionnaire_Questions__c> pharmacyqueslist = new List<C_Ops_SPLOA_Questionnaire_Questions__c>();
                List<C_Ops_SPLOA_Questionnaire_Questions__c> pharmacysubqueslist = new List<C_Ops_SPLOA_Questionnaire_Questions__c>();
                
                for(pharmacyquestionswrapper pharmwrap  :pharmqueswrapperlist ){
                    C_Ops_SPLOA_Questionnaire_Questions__c pharmques = new C_Ops_SPLOA_Questionnaire_Questions__c();
                    pharmques.Data_type__c = pharmwrap.Pharmques.C_Ops_SPLOA_Data_Type__c;
                    pharmques.C_Ops_SPLOA_Request__c = mainRequestId ;
                    pharmques.Question_Label__c = pharmwrap.Pharmques.C_Ops_SPLOA_Question_Label__c;
                    pharmques.Answer__c = pharmwrap.Pharmques.Answer__c;
                    pharmques.Question_Type__c = 'Pharmacy Questions';
                    pharmques.C_Ops_SPLOA_Question_Display_Order__c = pharmwrap.Pharmques.C_Ops_SPLOA_Question_Display_Order__c ;
                    pharmques.Parent_Question_Name__c= pharmwrap.Pharmques.Name;
                    // Included Validation flag for all the questions
                    if(pharmwrap.Pharmques.C_Ops_SPLOA_Data_Type__c == 'checkbox' &&( pharmwrap.Pharmques.Answer__c == pharmwrap.Pharmques.C_Ops_SPLOA_Credential__c ||( pharmwrap.Pharmques.C_Ops_SPLOA_Credential__c == '' || pharmwrap.Pharmques.C_Ops_SPLOA_Credential__c == null))){
                        pharmques.Validation_flag__c = true;
                    }
                    pharmacyqueslist.add(pharmques);
                    if(pharmwrap.subqueslist!=null){
                        for(C_Ops_SPLOA_Sub_Question__c subques  : pharmwrap.subqueslist){
                            if(pharmwrap.Pharmques.Answer__c  =='Yes' && pharmwrap.Pharmques.C_Ops_SPLOA_Has_Subquestion__c == true){
                                C_Ops_SPLOA_Questionnaire_Questions__c pharmsubques = new C_Ops_SPLOA_Questionnaire_Questions__c();
                                pharmsubques.Data_type__c = subques.C_Ops_SPLOA_Data_Type__c;
                                pharmsubques.C_Ops_SPLOA_Request__c = mainRequestId ;
                                pharmsubques.Question_Label__c = subques.Question_Label__c;
                                pharmsubques.Answer__c = subques.Answer__c;
                                pharmsubques.Question_Type__c = 'Pharmacy Questions';
                                pharmsubques.C_Ops_SPLOA_Question_Display_Order__c = subques.C_Ops_SPLOA_Question_Display_Order__c ;
                                pharmsubques.Parent_Question_Name__c= pharmwrap.Pharmques.Name;
                                //Included Validation flag for all the questions
                                if(subques.C_Ops_SPLOA_Data_Type__c == 'checkbox' &&( subques.Answer__c == subques.C_Ops_SPLOA_Credential__c || (subques.C_Ops_SPLOA_Credential__c == '' || subques.C_Ops_SPLOA_Credential__c == null))){
                                    pharmsubques.Validation_flag__c = true;
                                }
                                pharmacysubqueslist.add(pharmsubques );
                            }
                        }
                    }
                }
                
                if(pharmacyqueslist.size()>0){
                    Insert pharmacyqueslist;
                }
                
                if(pharmacysubqueslist.size()>0){
                    for(C_Ops_SPLOA_Questionnaire_Questions__c pharmacysubques:pharmacysubqueslist)
                        for(C_Ops_SPLOA_Questionnaire_Questions__c pharmques: pharmacyqueslist){
                            if(pharmacysubques.Parent_Question_Name__c == pharmques.Parent_Question_Name__c)
                                pharmacysubques.C_Ops_SPLOA_Questionnaire__c = pharmques.Id;
                        }
                    
                    Insert pharmacysubqueslist;
                }
                
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
                        quesques.C_Ops_SPLOA_Question_Display_Order__c = queswrp.queques.C_Ops_SPLOA_Question_Display_Order__c ;
                        quesques.Parent_Question_Name__c= queswrp.queques.Name;
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
                                    quessubques.Parent_Question_Name__c= queswrp.queques.Name;
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
                    Insert quesqueslist;
                }
                
                if(quessubqueslist.size()>0){
                    for(C_Ops_SPLOA_Questionnaire_Questions__c quessubques : quessubqueslist )
                        for(C_Ops_SPLOA_Questionnaire_Questions__c quesques: quesqueslist){
                            if(quessubques.Parent_Question_Name__c == quesques.Parent_Question_Name__c)
                                quessubques.C_Ops_SPLOA_Questionnaire__c = quesques.Id;
                        }
                    
                    Insert quessubqueslist ;
                }                
            }            
        }
        
    }

    public void updateRecords(){
        errorMessage ='';
        
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
        
                    mainRequestId = corrReqId ;
                    
                    
             //Inserting the Stage record 
             C_Ops_IAP_Requests_Stage__c reqstage = new C_Ops_IAP_Requests_Stage__c();
                reqstage.Main_Req__c = mainRequestId ;
                reqstage.Submission_Date__c = system.today();
                reqstage.Submission_Date_Time__c= system.now();
                reqstage.Type_of_action__c = 'Correction';
                reqstage.C_Ops_SPLOA_First_Name__c= mainRequest.C_Ops_SPLOA_First_Name__c;
                reqstage.C_Ops_SPLOA_Last_Name__c= mainRequest.C_Ops_SPLOA_Last_Name__c;
                reqstage.C_Ops_SPLOA_Phone__c= mainRequest.C_Ops_SPLOA_Phone__c;
                reqstage.C_Ops_SPLOA_Extension__c =  mainRequest.C_Ops_SPLOA_Extension__c ;
                reqstage.C_Ops_SPLOA_Fax__c = mainRequest.C_Ops_SPLOA_Fax__c ;
                reqstage.C_Ops_SPLOA_Email__c  = mainRequest.C_Ops_SPLOA_Email__c  ;
                reqstage.C_Ops_SPLOA_Primary_Distributor__c = mainRequest.C_Ops_SPLOA_Primary_Distributor__c ;
                reqstage.C_Ops_SPLOA_Pharmacy_Name__c = mainRequest.C_Ops_SPLOA_Pharmacy_Name__c ;
                reqstage.C_Ops_SPLOA_DEA_Number__c = mainRequest.C_Ops_SPLOA_DEA_Number__c ;
                reqstage.C_Ops_SPLOA_Street_Address__c = mainRequest.C_Ops_SPLOA_Street_Address__c ;
                reqstage.C_Ops_SPLOA_Street_Address_2__c = mainRequest.C_Ops_SPLOA_Street_Address_2__c ;
                reqstage.C_Ops_SPLOA_City__c = mainRequest.C_Ops_SPLOA_City__c ;
                reqstage.State__c = mainRequest.State__c ;
                reqstage.C_Ops_SPLOA_Zip__c = mainRequest.C_Ops_SPLOA_Zip__c ;
                reqstage.Website_URL__c = mainRequest.Website_URL__c ;
                reqstage.Signee_First_Name__c= mainRequest.Signee_First_Name__c;
                reqstage.Signee_Last_Name__c= mainRequest.Signee_Last_Name__c;
                reqstage.Signee_Title__c= mainRequest.Signee_Title__c;
                Insert reqstage;

            
            if(mainRequestId != null){
                
                
                if(oldAttachmentID!=null && oldAttachmentID != '') document = [SELECT NAME, body from Attachment where id =: oldAttachmentID];
                
                if(document.Id != null){
                    Attachment clonedAtt = new Attachment();
                    
                    clonedAtt.Name = document.Name;
                    clonedAtt.Body = document.Body;
                    
                 //   delete document;
                    
                    
                    clonedAtt.ParentId = mainRequestId;
                    
                    insert clonedAtt;
                }
                if(AddPharmoldListcorrReq.size()>0 ){
                    
             //       Delete AddPharmoldListcorrReq ;
                }
                if(AddPharmList != null && AddPharmList.size()>0){
                    for(C_Ops_SPLOA_Additional_Pharmacy__c addPharm :AddPharmList){
                        addPharm.C_Ops_IAP_Requests_Stage__c = reqstage.Id;
                        addPharm.C_Ops_SPLOA_Request__c = mainRequestId ;
                    }
                    Insert AddPharmList;
                }
              /*  if(questionnairelist.size()>0){
                    for(C_Ops_SPLOA_Questionnaire_Questions__c quesques: questionnairelist){
                        if(quesques.C_Ops_SPLOA_Request__c != null)
                            quesques.C_Ops_SPLOA_Request__c = null;
                    }
                    
                    Update questionnairelist;
                    
                 //   Delete questionnairelist;
                }*/
                
                List<C_Ops_SPLOA_Questionnaire_Questions__c> queslist = new List<C_Ops_SPLOA_Questionnaire_Questions__c>();
                List<C_Ops_SPLOA_Questionnaire_Questions__c> pharmacyqueslist = new List<C_Ops_SPLOA_Questionnaire_Questions__c>();
                List<C_Ops_SPLOA_Questionnaire_Questions__c> pharmacysubqueslist = new List<C_Ops_SPLOA_Questionnaire_Questions__c>();
                
                for(pharmacyquestionswrapper pharmwrap  :pharmqueswrapperlist ){
                    C_Ops_SPLOA_Questionnaire_Questions__c pharmques = new C_Ops_SPLOA_Questionnaire_Questions__c();
                    pharmques.Data_type__c = pharmwrap.Pharmques.C_Ops_SPLOA_Data_Type__c;
                    pharmques.C_Ops_SPLOA_Request__c = mainRequestId ;
                    pharmques.C_Ops_IAP_Requests_Stage__c = reqstage.Id;
                    pharmques.Question_Label__c = pharmwrap.Pharmques.C_Ops_SPLOA_Question_Label__c;
                    pharmques.Answer__c = pharmwrap.Pharmques.Answer__c;
                    pharmques.Question_Type__c = 'Pharmacy Questions';
                    pharmques.C_Ops_SPLOA_Question_Display_Order__c = pharmwrap.Pharmques.C_Ops_SPLOA_Question_Display_Order__c ;
                    pharmques.Parent_Question_Name__c= pharmwrap.Pharmques.Name;
                    if(pharmwrap.Pharmques.C_Ops_SPLOA_Data_Type__c == 'checkbox' &&( pharmwrap.Pharmques.Answer__c == pharmwrap.Pharmques.C_Ops_SPLOA_Credential__c || (pharmwrap.Pharmques.C_Ops_SPLOA_Credential__c == '' || pharmwrap.Pharmques.C_Ops_SPLOA_Credential__c == null))){
                        pharmques.Validation_flag__c = true;
                    }
                    pharmacyqueslist.add(pharmques);
                    if(pharmwrap.subqueslist!=null){
                        for(C_Ops_SPLOA_Sub_Question__c subques  : pharmwrap.subqueslist){
                            if(pharmwrap.Pharmques.Answer__c  =='Yes' && pharmwrap.Pharmques.C_Ops_SPLOA_Has_Subquestion__c == true){
                                C_Ops_SPLOA_Questionnaire_Questions__c pharmsubques = new C_Ops_SPLOA_Questionnaire_Questions__c();
                                pharmsubques.Data_type__c = subques.C_Ops_SPLOA_Data_Type__c;
                                pharmsubques.C_Ops_SPLOA_Request__c = mainRequestId ;
                                pharmsubques.C_Ops_IAP_Requests_Stage__c = reqstage.Id;
                                pharmsubques.Question_Label__c = subques.Question_Label__c;
                                pharmsubques.Answer__c = subques.Answer__c;
                                pharmsubques.Question_Type__c = 'Pharmacy Questions';
                                pharmsubques.C_Ops_SPLOA_Question_Display_Order__c = subques.C_Ops_SPLOA_Question_Display_Order__c ;
                                pharmsubques.Parent_Question_Name__c= pharmwrap.Pharmques.Name;
                                if(subques.C_Ops_SPLOA_Data_Type__c == 'checkbox' &&( subques.Answer__c == subques.C_Ops_SPLOA_Credential__c || (subques.C_Ops_SPLOA_Credential__c == '' || subques.C_Ops_SPLOA_Credential__c == null))){
                                    pharmsubques.Validation_flag__c = true;
                                }
                                pharmacysubqueslist.add(pharmsubques );
                            }
                        }
                    }
                }
                
                if(pharmacyqueslist.size()>0){
                    Insert pharmacyqueslist;
              // queslist.addAll(pharmacyqueslist);
                }
                
                if(pharmacysubqueslist.size()>0){
                    for(C_Ops_SPLOA_Questionnaire_Questions__c pharmacysubques:pharmacysubqueslist){
                        for(C_Ops_SPLOA_Questionnaire_Questions__c pharmques: pharmacyqueslist){
                            if(pharmacysubques.Parent_Question_Name__c == pharmques.Parent_Question_Name__c)
                                pharmacysubques.C_Ops_SPLOA_Questionnaire__c = pharmques.Id;
                        }
                        }
                   //   queslist.addAll(pharmacysubqueslist);
                    Insert pharmacysubqueslist;
                }
                
             //   if(questionnairelist.size()>0){   Delete questionnairelist;}
                
                List<C_Ops_SPLOA_Questionnaire_Questions__c> quesqueslist = new List<C_Ops_SPLOA_Questionnaire_Questions__c>();
                List<C_Ops_SPLOA_Questionnaire_Questions__c> quessubqueslist = new List<C_Ops_SPLOA_Questionnaire_Questions__c>();
                if(quesquestionswrapperlist!=null && quesquestionswrapperlist.size()>0){
                    for( quesquestionswrapper   queswrp : quesquestionswrapperlist){
                        C_Ops_SPLOA_Questionnaire_Questions__c quesques = new C_Ops_SPLOA_Questionnaire_Questions__c();
                        quesques.Data_type__c = queswrp.queques.C_Ops_SPLOA_Data_Type__c;
                        quesques.C_Ops_SPLOA_Request__c = mainRequestId ;
                        quesques.C_Ops_IAP_Requests_Stage__c = reqstage.Id;
                        quesques.Question_Label__c = queswrp.queques.C_Ops_SPLOA_Question_Label__c;
                        quesques.Answer__c = queswrp.queques.Answer__c;
                        quesques.Question_Type__c = 'Questionnaire';
                        quesques.C_Ops_SPLOA_Question_Display_Order__c = queswrp.queques.C_Ops_SPLOA_Question_Display_Order__c ;
                        quesques.Parent_Question_Name__c= queswrp.queques.Name;
                        //Adding code to populate Validation_flag__c
                        if(queswrp.queques.C_Ops_SPLOA_Data_Type__c == 'checkbox' && ((queswrp.queques.C_Ops_SPLOA_Credential__c == '' || queswrp.queques.C_Ops_SPLOA_Credential__c == null )|| queswrp.queques.Answer__c == queswrp.queques.C_Ops_SPLOA_Credential__c )){
                            quesques.Validation_flag__c = true;
                        }
                        quesqueslist.add(quesques);
                        if(queswrp.subqueslist != null){
                            for(C_Ops_SPLOA_Sub_Question__c subques  : queswrp.subqueslist){
                                if(queswrp.queques.Answer__c =='Yes' && queswrp.queques.C_Ops_SPLOA_Has_Subquestion__c == true){
                                    C_Ops_SPLOA_Questionnaire_Questions__c quessubques = new C_Ops_SPLOA_Questionnaire_Questions__c();
                                    quessubques.Data_type__c = subques.C_Ops_SPLOA_Data_Type__c;
                                    quessubques.C_Ops_SPLOA_Request__c = mainRequestId  ;
                                    quessubques.C_Ops_IAP_Requests_Stage__c = reqstage.Id;
                                    quessubques.Question_Label__c = subques.Question_Label__c;
                                    quessubques.Answer__c = subques.Answer__c;
                                    quessubques.Question_Type__c = 'Questionnaire';
                                    quessubques.C_Ops_SPLOA_Question_Display_Order__c = subques.C_Ops_SPLOA_Question_Display_Order__c ;
                                    quessubques.Parent_Question_Name__c= queswrp.queques.Name;
                                    if(subques.C_Ops_SPLOA_Data_Type__c == 'checkbox' && ((subques.C_Ops_SPLOA_Credential__c == '' || subques.C_Ops_SPLOA_Credential__c == null )|| subques.Answer__c == subques.C_Ops_SPLOA_Credential__c )){
                                        quessubques.Validation_flag__c = true;
                                    }
                                    quessubqueslist.add(quessubques);
                                }
                            }
                        }
                    }
                }
                
                if(quesqueslist.size()>0){
                    Insert quesqueslist;
                }
                
                if(quessubqueslist.size()>0){
                    for(C_Ops_SPLOA_Questionnaire_Questions__c quessubques : quessubqueslist )
                        for(C_Ops_SPLOA_Questionnaire_Questions__c quesques: quesqueslist){
                            if(quessubques.Parent_Question_Name__c == quesques.Parent_Question_Name__c)
                                quessubques.C_Ops_SPLOA_Questionnaire__c = quesques.Id;
                        }
                    
                    Insert quessubqueslist ;
                }
                
            }
            
        }
    }
    
    public void insertrenewreq(){
        Id parentrecordId;
        errorMessage ='';
        
        system.debug(mainRequest.Authorised__c+mainRequest.Signee_First_Name__c+mainRequest.Signee_Last_Name__c+mainRequest.Signee_Title__c);
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
            if(reqTyp == 'renew'){
                mainRequest.C_Ops_SPLOA_Request_Status__c = 'New';
                mainRequest.Manual_review_required__c = true;
                mainRequest.SPLOA_Renewal__c = true;
            }
            
          //  parentrecordId = mainRequest.Id;
           if(corrReqId != NULL){ mainRequest.SPLOA_Parent_Process_Request__c = corrReqId ;}
            
            if(mainRequest.Id != null){
                mainRequest.Id = null;
            }
            mainRequest.Submission_Date_Time__c= system.now();
            mainRequest.Request_Type__c = getRequestType();
            
            try{
                Insert mainRequest;
            }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
            
            mainRequestId = mainRequest.Id;
            
            //Inserting the Stage record 
            if(mainRequestId  != null){
             C_Ops_IAP_Requests_Stage__c reqstage = new C_Ops_IAP_Requests_Stage__c();
                reqstage.SPLOA_Parent_Process_Request__c  =  mainRequest.Id;
                reqstage.Renew_Request_Submitted__c = true;
                reqstage.Main_Req__c = corrReqId ;
                reqstage.Type_of_action__c = 'Renew';
                Insert reqstage;
                          
                
            }
            
            if(parentrecordId != null){
             /*   C_Ops_SPLOA_Request__c prevprocessedReq = new C_Ops_SPLOA_Request__c();
                prevprocessedReq.Id = parentrecordId;
                prevprocessedReq.Renew_Request_Submitted__c = true;
                prevprocessedReq.Processed_Request__c = mainRequest.Id;
                
                Update prevprocessedReq;*/
                
            }
            
            
            if(mainRequestId != null){
                
                
                if(oldAttachmentID!=null && oldAttachmentID != '') document = [SELECT NAME, body from Attachment where id =: oldAttachmentID];
                
                if(document.Id != null){
                    Attachment clonedAtt = new Attachment();
                    
                    clonedAtt.Name = document.Name;
                    clonedAtt.Body = document.Body;
                    
               //     delete document;
                    
                    
                    clonedAtt.ParentId = mainRequestId;
                    
                    insert clonedAtt;
                }
                if(AddPharmList != null && AddPharmList.size()>0){
                    for(C_Ops_SPLOA_Additional_Pharmacy__c addPharm :AddPharmList){
                        addPharm.C_Ops_SPLOA_Request__c = mainRequestId;
                    }
                    Insert AddPharmList;
                }
                
                List<C_Ops_SPLOA_Questionnaire_Questions__c> pharmacyqueslist = new List<C_Ops_SPLOA_Questionnaire_Questions__c>();
                List<C_Ops_SPLOA_Questionnaire_Questions__c> pharmacysubqueslist = new List<C_Ops_SPLOA_Questionnaire_Questions__c>();
                
                for(pharmacyquestionswrapper pharmwrap  :pharmqueswrapperlist ){
                    C_Ops_SPLOA_Questionnaire_Questions__c pharmques = new C_Ops_SPLOA_Questionnaire_Questions__c();
                    pharmques.Data_type__c = pharmwrap.Pharmques.C_Ops_SPLOA_Data_Type__c;
                    pharmques.C_Ops_SPLOA_Request__c = mainRequestId ;
                    pharmques.Question_Label__c = pharmwrap.Pharmques.C_Ops_SPLOA_Question_Label__c;
                    pharmques.Answer__c = pharmwrap.Pharmques.Answer__c;
                    pharmques.Question_Type__c = 'Pharmacy Questions';
                    pharmques.C_Ops_SPLOA_Question_Display_Order__c = pharmwrap.Pharmques.C_Ops_SPLOA_Question_Display_Order__c ;
                    pharmques.Parent_Question_Name__c= pharmwrap.Pharmques.Name;
                    if(pharmwrap.Pharmques.C_Ops_SPLOA_Data_Type__c == 'checkbox' && ((pharmwrap.Pharmques.C_Ops_SPLOA_Credential__c == '' || pharmwrap.Pharmques.C_Ops_SPLOA_Credential__c == null )|| pharmwrap.Pharmques.Answer__c == pharmwrap.Pharmques.C_Ops_SPLOA_Credential__c )){
                        pharmques.Validation_flag__c = true;
                    }
                    pharmacyqueslist.add(pharmques);
                    if(pharmwrap.subqueslist!=null){
                        for(C_Ops_SPLOA_Sub_Question__c subques  : pharmwrap.subqueslist){
                            if(pharmwrap.Pharmques.Answer__c  =='Yes' && pharmwrap.Pharmques.C_Ops_SPLOA_Has_Subquestion__c == true){
                                C_Ops_SPLOA_Questionnaire_Questions__c pharmsubques = new C_Ops_SPLOA_Questionnaire_Questions__c();
                                pharmsubques.Data_type__c = subques.C_Ops_SPLOA_Data_Type__c;
                                pharmsubques.C_Ops_SPLOA_Request__c = mainRequestId ;
                                pharmsubques.Question_Label__c = subques.Question_Label__c;
                                pharmsubques.Answer__c = subques.Answer__c;
                                pharmsubques.Question_Type__c = 'Pharmacy Questions';
                                pharmsubques.C_Ops_SPLOA_Question_Display_Order__c = subques.C_Ops_SPLOA_Question_Display_Order__c ;
                                pharmsubques.Parent_Question_Name__c= pharmwrap.Pharmques.Name;
                                if(subques.C_Ops_SPLOA_Data_Type__c == 'checkbox' && ((subques.C_Ops_SPLOA_Credential__c == '' || subques.C_Ops_SPLOA_Credential__c == null )|| subques.Answer__c == subques.C_Ops_SPLOA_Credential__c )){
                                    pharmsubques.Validation_flag__c = true;
                                }
                                pharmacysubqueslist.add(pharmsubques );
                            }
                        }
                    }
                }
                
                if(pharmacyqueslist.size()>0){
                    Insert pharmacyqueslist;
                }
                
                if(pharmacysubqueslist.size()>0){
                    for(C_Ops_SPLOA_Questionnaire_Questions__c pharmacysubques:pharmacysubqueslist)
                        for(C_Ops_SPLOA_Questionnaire_Questions__c pharmques: pharmacyqueslist){
                            if(pharmacysubques.Parent_Question_Name__c == pharmques.Parent_Question_Name__c)
                                pharmacysubques.C_Ops_SPLOA_Questionnaire__c = pharmques.Id;
                        }
                    
                    Insert pharmacysubqueslist;
                }
                
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
                        quesques.C_Ops_SPLOA_Question_Display_Order__c = queswrp.queques.C_Ops_SPLOA_Question_Display_Order__c ;
                        quesques.Parent_Question_Name__c= queswrp.queques.Name;
                        if(queswrp.queques.C_Ops_SPLOA_Data_Type__c == 'checkbox' && ((queswrp.queques.C_Ops_SPLOA_Credential__c == '' || queswrp.queques.C_Ops_SPLOA_Credential__c == null )|| queswrp.queques.Answer__c == queswrp.queques.C_Ops_SPLOA_Credential__c )){
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
                                    quessubques.Parent_Question_Name__c= queswrp.queques.Name;
                                    if(subques.C_Ops_SPLOA_Data_Type__c == 'checkbox' && ((subques.C_Ops_SPLOA_Credential__c == '' || subques.C_Ops_SPLOA_Credential__c == null )|| subques.Answer__c == subques.C_Ops_SPLOA_Credential__c )){
                                        quessubques.Validation_flag__c = true;
                                    }
                                    quessubqueslist.add(quessubques);
                                }
                            }
                        }
                    }
                }
                
                if(quesqueslist.size()>0){
                    Insert quesqueslist;
                }
                
                if(quessubqueslist.size()>0){
                    for(C_Ops_SPLOA_Questionnaire_Questions__c quessubques : quessubqueslist )
                        for(C_Ops_SPLOA_Questionnaire_Questions__c quesques: quesqueslist){
                            if(quessubques.Parent_Question_Name__c == quesques.Parent_Question_Name__c)
                                quessubques.C_Ops_SPLOA_Questionnaire__c = quesques.Id;
                        }
                    
                    Insert quessubqueslist ;
                }
                
            }
            
        }
        
    }
    
    public void createaddprodRecords(){
        errorMessage ='';
        
        system.debug(mainRequest.Authorised__c+mainRequest.Signee_First_Name__c+mainRequest.Signee_Last_Name__c+mainRequest.Signee_Title__c);
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
            
          //  if(superexceededset == true || RequestDenial != true){
                mainRequest.C_Ops_SPLOA_Request_Status__c = 'New';
                mainRequest.Manual_review_required__c = true;
           // }
           // else if(RequestDenial == true){
           //     mainRequest.Date_Denied_If_Applicable__c = system.now();
           //     mainRequest.C_Ops_SPLOA_Request_Status__c = 'Denied';
           // }
            
            mainRequest.Submission_Date_Time__c= system.now();
            mainRequest.additional_product_request__c = true;
            
            if(corrReqId != null){
                mainRequest.SPLOA_Parent_Process_Request__c = corrReqId;
           //     mainRequest.Id = null;
            }
            mainRequest.Request_Type__c = getRequestType();
            try{
                Insert mainRequest;
            }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
            
            
            
            mainRequestId = mainRequest.Id;
            
            
            if(mainRequestId != null){
                
                
                if(oldAttachmentID!=null && oldAttachmentID != '') document = [SELECT NAME, body from Attachment where id =: oldAttachmentID];
                
                if(document.Id != null){
                    Attachment clonedAtt = new Attachment();
                    
                    clonedAtt.Name = document.Name;
                    clonedAtt.Body = document.Body;
                    
                    delete document;
                    
                    
                    clonedAtt.ParentId = mainRequestId;
                    
                    insert clonedAtt;
                }
                if(AddPharmList != null && AddPharmList.size()>0){
                    for(C_Ops_SPLOA_Additional_Pharmacy__c addPharm :AddPharmList){
                        addPharm.C_Ops_SPLOA_Request__c = mainRequestId;
                    }
                    Insert AddPharmList;
                }
                
                List<C_Ops_SPLOA_Questionnaire_Questions__c> pharmacyqueslist = new List<C_Ops_SPLOA_Questionnaire_Questions__c>();
                List<C_Ops_SPLOA_Questionnaire_Questions__c> pharmacysubqueslist = new List<C_Ops_SPLOA_Questionnaire_Questions__c>();
                
                for(pharmacyquestionswrapper pharmwrap  :pharmqueswrapperlist ){
                    C_Ops_SPLOA_Questionnaire_Questions__c pharmques = new C_Ops_SPLOA_Questionnaire_Questions__c();
                    pharmques.Data_type__c = pharmwrap.Pharmques.C_Ops_SPLOA_Data_Type__c;
                    pharmques.C_Ops_SPLOA_Request__c = mainRequestId ;
                    pharmques.Question_Label__c = pharmwrap.Pharmques.C_Ops_SPLOA_Question_Label__c;
                    pharmques.Answer__c = pharmwrap.Pharmques.Answer__c;
                    pharmques.Question_Type__c = 'Pharmacy Questions';
                    pharmques.C_Ops_SPLOA_Question_Display_Order__c = pharmwrap.Pharmques.C_Ops_SPLOA_Question_Display_Order__c ;
                    pharmques.Parent_Question_Name__c= pharmwrap.Pharmques.Name;
                    if(pharmwrap.Pharmques.C_Ops_SPLOA_Data_Type__c == 'checkbox' &&( pharmwrap.Pharmques.Answer__c == pharmwrap.Pharmques.C_Ops_SPLOA_Credential__c || pharmwrap.Pharmques.C_Ops_SPLOA_Credential__c == '')){
                        pharmques.Validation_flag__c = true;
                    }
                    pharmacyqueslist.add(pharmques);
                    if(pharmwrap.subqueslist!=null){
                        for(C_Ops_SPLOA_Sub_Question__c subques  : pharmwrap.subqueslist){
                            if(pharmwrap.Pharmques.Answer__c  =='Yes' && pharmwrap.Pharmques.C_Ops_SPLOA_Has_Subquestion__c == true){
                                C_Ops_SPLOA_Questionnaire_Questions__c pharmsubques = new C_Ops_SPLOA_Questionnaire_Questions__c();
                                pharmsubques.Data_type__c = subques.C_Ops_SPLOA_Data_Type__c;
                                pharmsubques.C_Ops_SPLOA_Request__c = mainRequestId ;
                                pharmsubques.Question_Label__c = subques.Question_Label__c;
                                pharmsubques.Answer__c = subques.Answer__c;
                                pharmsubques.Question_Type__c = 'Pharmacy Questions';
                                pharmsubques.C_Ops_SPLOA_Question_Display_Order__c = subques.C_Ops_SPLOA_Question_Display_Order__c ;
                                pharmsubques.Parent_Question_Name__c= pharmwrap.Pharmques.Name;
                                if(subques.C_Ops_SPLOA_Data_Type__c == 'checkbox' &&( subques.Answer__c == subques.C_Ops_SPLOA_Credential__c || subques.C_Ops_SPLOA_Credential__c == '')){
                                    pharmsubques.Validation_flag__c = true;
                                }
                                pharmacysubqueslist.add(pharmsubques );
                            }
                        }
                    }
                }
                
                if(pharmacyqueslist.size()>0){
                    Insert pharmacyqueslist;
                }
                
                if(pharmacysubqueslist.size()>0){
                    for(C_Ops_SPLOA_Questionnaire_Questions__c pharmacysubques:pharmacysubqueslist)
                        for(C_Ops_SPLOA_Questionnaire_Questions__c pharmques: pharmacyqueslist){
                            if(pharmacysubques.Parent_Question_Name__c == pharmques.Parent_Question_Name__c)
                                pharmacysubques.C_Ops_SPLOA_Questionnaire__c = pharmques.Id;
                        }
                    
                    Insert pharmacysubqueslist;
                }
                
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
                        quesques.C_Ops_SPLOA_Question_Display_Order__c = queswrp.queques.C_Ops_SPLOA_Question_Display_Order__c ;
                        quesques.Parent_Question_Name__c= queswrp.queques.Name;
                        if(queswrp.queques.C_Ops_SPLOA_Data_Type__c == 'checkbox' &&( queswrp.queques.Answer__c == queswrp.queques.C_Ops_SPLOA_Credential__c || (queswrp.queques.C_Ops_SPLOA_Credential__c == '' || queswrp.queques.C_Ops_SPLOA_Credential__c == null))){
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
                                    quessubques.Parent_Question_Name__c= queswrp.queques.Name;
                                    if(subques.C_Ops_SPLOA_Data_Type__c == 'checkbox' &&( subques.Answer__c == subques.C_Ops_SPLOA_Credential__c || (subques.C_Ops_SPLOA_Credential__c == '' || subques.C_Ops_SPLOA_Credential__c == null))){
                                        quessubques.Validation_flag__c = true;
                                    }
                                    quessubqueslist.add(quessubques);
                                }
                            }
                        }
                    }
                }
                
                if(quesqueslist.size()>0){
                    Insert quesqueslist;
                }
                
                if(quessubqueslist.size()>0){
                    for(C_Ops_SPLOA_Questionnaire_Questions__c quessubques : quessubqueslist )
                        for(C_Ops_SPLOA_Questionnaire_Questions__c quesques: quesqueslist){
                            if(quessubques.Parent_Question_Name__c == quesques.Parent_Question_Name__c)
                                quessubques.C_Ops_SPLOA_Questionnaire__c = quesques.Id;
                        }
                    
                    Insert quessubqueslist ;
                }
                
            }            
        }        
    }

    public void updateaddSiteRecords(){
        
        errorMessage ='';
        
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
        
        mainRequest.C_Ops_SPLOA_Request_Status__c = 'New';
                mainRequest.Manual_review_required__c = true;
                mainRequest.Added_New_Site_s__c = true;
          
            
            mainRequest.Submission_Date_Time__c= system.now();
            mainRequest.Request_Type__c = getRequestType();
            try{
                Insert mainRequest;
            }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
        
            //Inserting the Stage record 
         /*   if(corrReqId != null){
             C_Ops_IAP_Requests_Stage__c reqstage = new C_Ops_IAP_Requests_Stage__c();
                reqstage.Added_New_Site_s__c = true;
                reqstage.Main_Req__c = corrReqId ;
                reqstage.Type_of_action__c = 'Site';
                Insert reqstage; */
        
        mainRequestId = mainRequest.Id;
        system.debug('mainRequestId  '+mainRequestId );
        if(mainRequestId != null){    
            if(AddPharmList != null && AddPharmList.size()>0 ){
                for(C_Ops_SPLOA_Additional_Pharmacy__c addPharm :AddPharmList){
                addPharm.C_Ops_SPLOA_Request__c = mainRequestId ;

                }
                Insert AddPharmList;
            }
            }            

        //    mainRequestId  = corrReqId;
         //   mainRequest.Added_New_Site_s__c = true;
            
          //  Update mainRequest;
        }        
    }
    
    public pageReference navtoconfirmpage(){ 
        if(reqTyp == 'new'){
            createRecords();
            if(mainRequestId != null && String.IsBlank(errorMessage)){
                cleanUpSavedData();
                //response = null;
                PageReference nextPage=Page.C_OpsSPLOA_ConfirmationPage;
                nextPage.getParameters().put('id',mainRequestId );
                nextPage.setredirect(true);
                return nextPage;         
            } 
        } 
        else if(reqTyp == 'renew'){
            insertrenewreq();
            if(mainRequestId != null && String.IsBlank(errorMessage)){
                cleanUpSavedData();
                PageReference nextPage=Page.C_OpsSPLOA_ConfirmationPage;
                nextPage.getParameters().put('id',mainRequestId );
                nextPage.getParameters().put('reqtyp','renew');
                nextPage.setredirect(true);
                return nextPage;         
            } 
        }     
        else if(!correctionReq && reqTyp == 'addProd' ){
            createaddprodRecords();
            if(mainRequestId != null && String.IsBlank(errorMessage)){
                cleanUpSavedData();
                PageReference nextPage=Page.C_OpsSPLOA_ConfirmationPage;
                nextPage.getParameters().put('id',mainRequestId );
                nextPage.setredirect(true);
                return nextPage;         
            } 
        }
        else if(reqTyp == 'update' ){
            updateRecords();
            if(mainRequestId != null && String.IsBlank(errorMessage)){
                cleanUpSavedData();
                PageReference nextPage=Page.C_OpsSPLOA_ConfirmationPage;
                nextPage.getParameters().put('id',mainRequestId );
                nextPage.getParameters().put('reqtyp','update');
                nextPage.setredirect(true);
                return nextPage;         
            } 
        }
        else if(reqTyp == 'addSite' ){
            updateaddSiteRecords();
            if(mainRequestId != null && String.IsBlank(errorMessage)){
                 cleanUpSavedData();
                PageReference nextPage=Page.C_OpsSPLOA_ConfirmationPage;
                nextPage.getParameters().put('id',mainRequestId );
                nextPage.getParameters().put('reqtyp','addSite');
                nextPage.setredirect(true);
                return nextPage;         
            } 
        }          
        return null;
    }  
    
    private void cleanUpSavedData(){
        mainRequest = new C_Ops_SPLOA_Request__c();
        oldAttachmentID=null;
        AddPharmList=new List<C_Ops_SPLOA_Additional_Pharmacy__c>();
        pharmqueswrapperlist =new List<pharmacyquestionswrapper>();
        quesquestionswrapperlist=new List<quesquestionswrapper>();
        this.response = '';
        this.recaptchaVerified = false;
    }
}