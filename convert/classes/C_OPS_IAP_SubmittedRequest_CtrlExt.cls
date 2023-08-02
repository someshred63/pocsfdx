public with sharing class C_OPS_IAP_SubmittedRequest_CtrlExt {
    public C_Ops_SPLOA_Request__c request { get; set; }
    private ID requestId;
    // public Boolean isnewRecordtype;
    public List<C_Ops_SPLOA_Additional_Pharmacy__c> requestAdtnlPharm;
    public List<APL__c> apls { get; set; }
    public list<C_Ops_SPLOA_Questionnaire_Questions__c> allquestions{ get; set; }
      public list<C_Ops_SPLOA_Questionnaire_Questions__c> allpharquestions{ get; set; }
     public list<C_Ops_SPLOA_Questionnaire_Questions__c> allsubquestions{ get; set; }
    public List<productquestionswrapper> productquestionswrapperlist  { get; set; }
    public List<pharmacyquestionswrapper> pharmacyquestionswrapperlist { get; set; }
    public List<quesquestionswrapper> quesquestionswrapperlist { get; set; }
    
    
    private without sharing class IAP_Controller_internal{
        
        private C_Ops_SPLOA_Request__c Getrequest(string requestId){
            
            return [SELECT Accreditation__c,Added_New_Site_s__c,additional_product_request__c,Additional_Site_DEA_Hit_with_Blacklist_b__c,Additional_Site_DEA_Hit_with_Blacklist__c,Agreement_Type__c,APLs_on_the_Request__c,Assign_To__c,Authorised__c,Automation_Status__c,Bot_change_log__c,CARS_TP_Customer_ID__c,CreatedById,CreatedDate,Customer_Access_Type__c,C_Ops_IAP_Executed_Access_Type__c,C_Ops_SPLOA_City__c,C_Ops_SPLOA_DEA_Number__c,C_Ops_SPLOA_Email__c,C_Ops_SPLOA_Extension__c,C_Ops_SPLOA_Fax__c,C_Ops_SPLOA_First_Name__c,C_Ops_SPLOA_Last_Name__c,C_Ops_SPLOA_Pharmacy_Name__c,C_Ops_SPLOA_Phone__c,C_Ops_SPLOA_Primary_Distributor__c,C_Ops_SPLOA_Product_Name__c,C_Ops_SPLOA_Request_Status__c,C_Ops_SPLOA_Street_Address_2__c,C_Ops_SPLOA_Street_Address__c,C_Ops_SPLOA_Zip__c,Date_Denied_If_Applicable__c,Date_Document_Received_form_SP__c,Date_Document_sent_to_SP__c,Denial_Reason__c,Error_Message__c,Exception_Found__c,File_will_be_emailed__c,GeneCis_CMS_ID__c,geneCIS_Contract_Document_ID__c,Genentech_Contact__c,Id,Is_This_IDN__c,LastModifiedById,LastModifiedDate,Manual_review_required__c,MCC_Managed_Account__c,Name,OwnerId,Primary_DEA_Hit_with_Blacklist_backend__c,Primary_DEA_Hit_with_Blacklist__c,Processed_Date__c,Processed_Request__c,RecordTypeId,Related_Product_s__c,Renew_Request_Submitted__c,Request_PDF_Version_Number__c,Request_Type__c,Reviewed__c,Same_Signing__c,Signee_Email__c,Signee_Extension__c,Signee_First_Name__c,Signee_Last_Name__c,Signee_Phone__c,Signee_Title__c,Signing_Authority_First_name__c,Signing_Authority_Last_Name__c,Signing_Authority_Title__c,SPLOA_All_Documents__c,SPLOA_Initial_Renewal_Email_Sent_Date__c,SPLOA_Parent_Process_Request__c,SPLOA_Renewal__c,SPLOA_Request_Expiry_Date__c,State__c,Status_Category__c,Submission_Date_Time__c,Submission_Date__c,SystemModstamp,Website_URL__c,Workflow_Status_Updated_On__c FROM C_Ops_SPLOA_Request__c where id =:requestId  limit 1];
        }
        
        private list<C_Ops_SPLOA_Additional_Pharmacy__c> GetAdditionalpharmacy(string requestId){
            
            return [select name, C_Ops_SPLOA_DEA_Number__c,Pharmacy_Name__c,C_Ops_SPLOA_Street_Address__c,C_Ops_SPLOA_Street_Address_2__c,
                    C_Ops_SPLOA_City__c,C_Ops_SPLOA_State__c,C_Ops_SPLOA_Zip__c,C_Ops_SPLOA_Request__c from C_Ops_SPLOA_Additional_Pharmacy__c 
                    where C_Ops_SPLOA_Request__c =:requestId order by createddate asc];
        }
        
        private list<APL__c> Getaplslist(string requestId){
            return  [ select name, C_Ops_SPLOA_Product_Name__c , Product__c,Id  FROM APL__c WHERE C_Ops_IAP_Submitted_Requests__c =: requestId];
        }
        
        private list<C_Ops_SPLOA_Questionnaire_Questions__c> Getquestions(string requestId){
            return [select name, Answer__c,C_Ops_SPLOA_Request__c,Data_type__c,Parent_Question_Name__c,
                    C_Ops_SPLOA_Question_Display_Order__c,Question_Label__c,Question_Type__c,
                    C_Ops_SPLOA_Questionnaire__c,apl__c,Group__c,DEA_Number__c from C_Ops_SPLOA_Questionnaire_Questions__c
                    where C_Ops_SPLOA_Request__c =:requestId  ];
        }
        private list<C_Ops_SPLOA_Questionnaire_Questions__c> GetSubquestions(string requestId){
            return [select id,name,Question_Label__c,Answer__c,C_Ops_SPLOA_Questionnaire__c from 
                    C_Ops_SPLOA_Questionnaire_Questions__c where C_Ops_SPLOA_Request__c =:requestId AND 
                    C_Ops_SPLOA_Questionnaire__c!=null ];
        }
        
        private list<C_Ops_SPLOA_Questionnaire_Questions__c> GetPharquestions(string requestId,string typee){
            return [select Id,name, Answer__c,C_Ops_SPLOA_Request__c,Data_type__c,Parent_Question_Name__c,C_Ops_SPLOA_Question_Display_Order__c,
                    Question_Label__c,Question_Type__c,C_Ops_SPLOA_Questionnaire__c,apl__c,DEA_Number__c,Group__c from C_Ops_SPLOA_Questionnaire_Questions__c
                    where C_Ops_SPLOA_Request__c =:requestId AND Question_Type__c =: typee];
        }
        private list<APL_Questionnaire__c> GetAPLquestions(list<C_Ops_SPLOA_Questionnaire_Questions__c> Quess){
            return [SELECT Id,APL__c,C_Ops_IAP_Questionnaire__c FROM APL_Questionnaire__c WHERE C_Ops_IAP_Questionnaire__c =: Quess ];
        }
        
        
    }
    public C_OPS_IAP_SubmittedRequest_CtrlExt(ApexPages.StandardController stdController) {
        
        IAP_Controller_internal internalsave= new IAP_Controller_internal();
        PageReference curPage=ApexPages.currentPage();   
        if(curPage.getParameters()!=null) {
            requestId=curPage.getParameters().get('id');
        }    
        request= new C_Ops_SPLOA_Request__c();
        request=internalsave.Getrequest(requestId);
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('C_Ops_SPLOA_Request__c').getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
        Map<String,Id> mapofReqRecordTypeNameandId = new Map<String,Id>(); 
        
        for(Schema.RecordTypeInfo info : recordTypeInfo){
            mapofReqRecordTypeNameandId.put(info.getName(),info.getRecordTypeId());
        }
        C_Ops_SPLOA_Request__c subreq=internalsave.Getrequest(requestId);
        productquestionswrapperlist= doproductquestionswrapperlist();
        pharmacyquestionswrapperlist=dopharmacyquestionswrapperlist();
        quesquestionswrapperlist=doquesquestionswrapperlist();
        apls=internalsave.Getaplslist(requestId);
    }
    
    public C_OPS_IAP_SubmittedRequest_CtrlExt() {
        
        IAP_Controller_internal internalsave= new IAP_Controller_internal();
        PageReference curPage=ApexPages.currentPage();   
        if(curPage.getParameters()!=null) {
            requestId=curPage.getParameters().get('id');
        }  
        // else requestId=controller.getRecord().id;  
        request= new C_Ops_SPLOA_Request__c();
        request=internalsave.Getrequest(requestId);
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('C_Ops_SPLOA_Request__c').getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
        Map<String,Id> mapofReqRecordTypeNameandId = new Map<String,Id>(); 
        
        for(Schema.RecordTypeInfo info : recordTypeInfo){
            mapofReqRecordTypeNameandId.put(info.getName(),info.getRecordTypeId());
        }
        C_Ops_SPLOA_Request__c subreq=internalsave.Getrequest(requestId);
        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename='+subreq.name+'.pdf');
        /*   if(mapofReqRecordTypeNameandId.get('New IAP Request') != null && request.RecordtypeId != null
&& mapofReqRecordTypeNameandId.get('New IAP Request') == request.RecordtypeId
)
{
isnewRecordtype =  true;
}*/
        productquestionswrapperlist= doproductquestionswrapperlist();
        pharmacyquestionswrapperlist=dopharmacyquestionswrapperlist();
        quesquestionswrapperlist=doquesquestionswrapperlist();
     //   productquestionswrapperlist = new List<productquestionswrapper>();
     //   pharmacyquestionswrapperlist  = new List<pharmacyquestionswrapper>();
     //   quesquestionswrapperlist = new List<quesquestionswrapper>();
        apls=internalsave.Getaplslist(requestId);
      //  allquestions=internalsave.Getquestions(requestId);
      // allsubquestions=internalsave.GetSubquestions(requestId);
      //  allpharquestions=internalsave.GetPharquestions(requestId,'Pharmacy Questions' ) ;
     //   system.debug(allquestions.Size());
    }
    
    
    
    
    public List<productquestionswrapper> doproductquestionswrapperlist(){
        IAP_Controller_internal internalsave= new IAP_Controller_internal();        
        List<APL__c > aplslist = internalsave.Getaplslist(requestId);
        Map<C_Ops_SPLOA_Questionnaire_Questions__c, List<C_Ops_SPLOA_Questionnaire_Questions__c> > QuessubquesMap = new Map<C_Ops_SPLOA_Questionnaire_Questions__c, List<C_Ops_SPLOA_Questionnaire_Questions__c>>();
        List<C_Ops_SPLOA_Questionnaire_Questions__c > Quess = internalsave.Getquestions( requestId);
        
        List<C_Ops_SPLOA_Questionnaire_Questions__c > subQuess = internalsave.GetSubquestions( requestId);
        
        for(C_Ops_SPLOA_Questionnaire_Questions__c p :Quess ){
            List<C_Ops_SPLOA_Questionnaire_Questions__c> subqlist = new List<C_Ops_SPLOA_Questionnaire_Questions__c>();
            for(C_Ops_SPLOA_Questionnaire_Questions__c subq :subQuess ){
                if(p.Id == subq.C_Ops_SPLOA_Questionnaire__c){
                    subqlist.add(subq); 
                }
            }
            if(subqlist.size()>0){ QuessubquesMap.put(p,subqlist );}
        }
        List<productquestionswrapper> productquestionswrapperlist;
        if(productquestionswrapperlist == null){productquestionswrapperlist = new List<productquestionswrapper>();}
        for(APL__c apl: aplslist ){
            for(C_Ops_SPLOA_Questionnaire_Questions__c p :Quess ){
                if(apl.Id == p.APL__c){
                    List<C_Ops_SPLOA_Questionnaire_Questions__c > subqlist =  new List<C_Ops_SPLOA_Questionnaire_Questions__c >();
                    subqlist  = QuessubquesMap.get(p);
                    productquestionswrapperlist.add(new productquestionswrapper (apl, p, subqlist  ) );
                }
            }
        }
        system.debug(productquestionswrapperlist.Size());
        return productquestionswrapperlist;
    }
    public List<C_Ops_SPLOA_Additional_Pharmacy__c> getrequestAdtnlPharm(){
        IAP_Controller_internal internalsave= new IAP_Controller_internal();
        requestAdtnlPharm=internalsave.GetAdditionalpharmacy(requestId);
        return requestAdtnlPharm;
    }
    
    
    
    public List<pharmacyquestionswrapper> dopharmacyquestionswrapperlist(){
        IAP_Controller_internal internalsave= new IAP_Controller_internal();
        Map<Id,APL__c > aplsMap = new Map<Id,APL__c>( internalsave.Getaplslist(requestId));
        Map<String, String> Grprelatedprod= new Map<String, String>();
        Map<C_Ops_SPLOA_Questionnaire_Questions__c, List<C_Ops_SPLOA_Questionnaire_Questions__c> > QuessubquesMap = new Map<C_Ops_SPLOA_Questionnaire_Questions__c, List<C_Ops_SPLOA_Questionnaire_Questions__c>>();
        List<C_Ops_SPLOA_Questionnaire_Questions__c > Quess =  internalsave.GetPharquestions(requestId,'Pharmacy Questions' ) ;
        List<APL_Questionnaire__c> APLques =internalsave.GetAPLquestions(Quess);
        List<C_Ops_SPLOA_Questionnaire_Questions__c > subQuess = internalsave.GetSubquestions( requestId);
        Map<Id,String> APLprodname = new MAP<Id,String>();        
        
        for(C_Ops_SPLOA_Questionnaire_Questions__c p :Quess ){
            String productlist ='';            
            for(APL_Questionnaire__c aplque:APLques ){
                if(p.Id == aplque.C_Ops_IAP_Questionnaire__c ){
                    productlist  = productlist  + aplsMap.get(aplque.APL__c).Product__c  + ', ' ;
                }                
            }
            if(productlist != ''){
                productlist = productlist.removeEnd(', ');
                APLprodname.put(p.Id ,productlist);
            }
        }       
        
        for(C_Ops_SPLOA_Questionnaire_Questions__c p :Quess ){
            List<C_Ops_SPLOA_Questionnaire_Questions__c> subqlist = new List<C_Ops_SPLOA_Questionnaire_Questions__c>();
            for(C_Ops_SPLOA_Questionnaire_Questions__c subq :subQuess ){
                if(p.Id == subq.C_Ops_SPLOA_Questionnaire__c){
                    subqlist.add(subq); 
                }
            }
            if(subqlist.size()>0){  QuessubquesMap.put(p,subqlist );}
        }        
        system.debug(QuessubquesMap);
        if(pharmacyquestionswrapperlist == null){pharmacyquestionswrapperlist  = new List<pharmacyquestionswrapper>();}
        
        for(C_Ops_SPLOA_Questionnaire_Questions__c p :Quess ){
            if(p.Question_Type__c == 'Pharmacy Questions' && (p.C_Ops_SPLOA_Questionnaire__c == null )){
                pharmacyquestionswrapperlist.add(new pharmacyquestionswrapper(p, QuessubquesMap.get(p),APLprodname.get(p.Id ) ));
            }
        }        
        return pharmacyquestionswrapperlist;
    }
    
    public List<quesquestionswrapper> doquesquestionswrapperlist(){
        IAP_Controller_internal internalsave= new IAP_Controller_internal();
        Map<Id,APL__c > aplsMap = new Map<Id,APL__c>( internalsave.Getaplslist(requestId));
        Map<String, String> Grprelatedprod= new Map<String, String>();
        Map<C_Ops_SPLOA_Questionnaire_Questions__c, List<C_Ops_SPLOA_Questionnaire_Questions__c> > QuessubquesMap = new Map<C_Ops_SPLOA_Questionnaire_Questions__c, List<C_Ops_SPLOA_Questionnaire_Questions__c>>();
        List<C_Ops_SPLOA_Questionnaire_Questions__c > Quess =internalsave.GetPharquestions(requestId,'Questionnaire' ) ;
        List<APL_Questionnaire__c> APLques =internalsave.GetAPLquestions(Quess);
        List<C_Ops_SPLOA_Questionnaire_Questions__c > subQuess = internalsave.GetSubquestions( requestId);
        Map<Id,String> APLprodname = new MAP<Id,String>();
        
        
        for(C_Ops_SPLOA_Questionnaire_Questions__c p :Quess ){
            String productlist ='';
            
            for(APL_Questionnaire__c aplque:APLques ){
                if(p.Id == aplque.C_Ops_IAP_Questionnaire__c && aplsMap.containskey(aplque.APL__c)  ){
                    productlist  = productlist  + aplsMap.get(aplque.APL__c).Product__c  + ', ' ;
                }
                
            }
            if(productlist != ''){
                productlist = productlist.removeEnd(', ');
                APLprodname.put(p.Id ,productlist);
            }
        }
        
        
        for(C_Ops_SPLOA_Questionnaire_Questions__c p :Quess ){
            List<C_Ops_SPLOA_Questionnaire_Questions__c> subqlist = new List<C_Ops_SPLOA_Questionnaire_Questions__c>();
            for(C_Ops_SPLOA_Questionnaire_Questions__c subq :subQuess ){
                if(p.Id == subq.C_Ops_SPLOA_Questionnaire__c){
                    subqlist.add(subq); 
                }
            }
            if(subqlist.size()>0){  QuessubquesMap.put(p,subqlist );}
        }
        
        
        if(quesquestionswrapperlist == null){quesquestionswrapperlist = new List<quesquestionswrapper>();}
        
        for(C_Ops_SPLOA_Questionnaire_Questions__c p :Quess ){
            if(p.Question_Type__c == 'Questionnaire' && (p.C_Ops_SPLOA_Questionnaire__c == null )){
                string grpname=APLprodname.get(p.Id );
                if(string.isNotBlank(grpname))
                quesquestionswrapperlist.add(new quesquestionswrapper(p, QuessubquesMap.get(p),APLprodname.get(p.Id ) ));
            }
        }
        return quesquestionswrapperlist;
    }
    
    //Wrapper Class to handle Product Questions and its Answers
    public class productquestionswrapper{
        public APL__c apl{get;set;} 
        public C_Ops_SPLOA_Questionnaire_Questions__c Prodques{get;set;}
        public List<C_Ops_SPLOA_Questionnaire_Questions__c > subqueslist{get;set;}
        public productquestionswrapper(APL__c  aplrcd , C_Ops_SPLOA_Questionnaire_Questions__c Prodque, List<C_Ops_SPLOA_Questionnaire_Questions__c > subquelist){
            this.apl = aplrcd;
            this.Prodques = Prodque;
            this.subqueslist= subquelist;
            
        }
    } 
    
    //Wrapper Class to handle Pharmacy Questions and its Answers
    class pharmacyquestionswrapper{
        public C_Ops_SPLOA_Questionnaire_Questions__c  Pharmques{get;set;}
        public List<C_Ops_SPLOA_Questionnaire_Questions__c > subqueslist{get;set;}
        public String Grp{get;set;}
        public pharmacyquestionswrapper(C_Ops_SPLOA_Questionnaire_Questions__c Pharmque,  List<C_Ops_SPLOA_Questionnaire_Questions__c > subquelist, String Grp){
            this.Pharmques = Pharmque;
            this.subqueslist= subquelist;
            this.Grp = Grp;
        }
    }
    
    
    //Wrapper Class to handle Pharmacy Questions and its Answers
    class quesquestionswrapper{
        public C_Ops_SPLOA_Questionnaire_Questions__c queques{get;set;}
        public List<C_Ops_SPLOA_Questionnaire_Questions__c > subqueslist{get;set;}
        public String Grp{get;set;}
        public quesquestionswrapper(C_Ops_SPLOA_Questionnaire_Questions__c queques,List<C_Ops_SPLOA_Questionnaire_Questions__c > subquelist, String Grp){
            this.queques = queques;
            this.subqueslist= subquelist;
            this.Grp = Grp;
        }
    }
}