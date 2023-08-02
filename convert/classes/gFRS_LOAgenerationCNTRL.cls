public class gFRS_LOAgenerationCNTRL {
	public static Map<Id, String> recordtypemap {get;set;}
    @AuraEnabled        
    public static List<String> fetchRecordTypeValues(){
        List<Schema.RecordTypeInfo> recordtypes = gFRS_Ltng_Application__c.SObjectType.getDescribe().getRecordTypeInfos();    
        recordtypemap = new Map<Id, String>();
        for(RecordTypeInfo rt : recordtypes){
            if(rt.getName() == 'Community Giving' ||  rt.getName() == 'Commercial Sponsorship' ||  rt.getName() == 'Corporate Memberships' ||  rt.getName() == 'Education Focused Giving Graduate and Post-Graduate' ||  rt.getName() == 'Education Focused Giving K-12' ||  rt.getName() == 'Field Exhibits' ||  rt.getName() == 'Independent Medical Education (CME)' ||  rt.getName() == 'Non-Commercial Sponsorship' ||  rt.getName() =='Patient and Health Focused Giving' ||  rt.getName() == 'Scientific and Research Focused Giving'|| rt.getName() == 'Foundation Safety Net Support'|| rt.getName() == 'Foundation Undergraduate')
            recordtypemap.put(rt.getRecordTypeId(), rt.getName());
        }        
        return recordtypemap.values();
    }
     @AuraEnabled  
    public static List<picklistWrapper> getPicklistvalues(string objAPIName, string fieldAPIname) {        
       
        list<picklistWrapper> returnValue = new list<picklistWrapper>();
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = gd.get(objAPIName.toLowerCase()).getDescribe().fields.getMap();
        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values = field_map.get(fieldAPIname).getDescribe().getPickListValues();
        
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a: values) {
            picklistWrapper aa = new picklistWrapper();
            aa.pickListLabel = a.getLabel();
            aa.pickListValue = a.getValue();
            returnValue.add(aa);
        }
        
        return returnValue;
        
    }
    
    
    @AuraEnabled
    public static list < LOAdocumentInfo__mdt > fetchLOAdocument(string recdType) {
        if(recdType == 'Patient and Health Focused Giving'){
            return  [SELECT Label,Paragraph1__c,Paragraph2__c,Paragraph3__c,Paragraph4__c,Paragraph5__c,Paragraph6__c,Paragraph7__c,Paragraph8__c,Paragraph9__c,Paragraph10__c,Paragraph11__c,Paragraph12__c,Paragraph13__c,Paragraph14__c,Paragraph15__c,
                     Paragraph16__c,Paragraph17__c,Paragraph18__c,Paragraph19__c,Paragraph20__c,Paragraph21__c,Paragraph22__c,Paragraph23__c,Paragraph24__c,Paragraph25__c,Paragraph26__c,Paragraph27__c,Paragraph28__c,Paragraph29__c,Paragraph30__c,
                     Paragraph31__c,Paragraph32__c,Paragraph33__c,Paragraph34__c,Paragraph35__c,Paragraph36__c,Paragraph37__c,Paragraph38__c,Paragraph39__c,Paragraph40__c,Paragraph41__c,Paragraph42__c,Paragraph43__c,Paragraph44__c,Paragraph45__c,
                     Paragraph46__c,Paragraph47__c,Paragraph48__c,Paragraph49__c,Paragraph50__c,Paragraph51__c,Paragraph52__c,Paragraph53__c,Paragraph54__c,Paragraphs__c,Section_Name__c,Addendum_Paragraph1__c,Addendum_Paragraph2__c,Addendum_Paragraph3__c,Addendum_Paragraph4__c,Addendum_Paragraph5__c,Independence__c,Payment__c  FROM LOAdocumentInfo__mdt where Label='LOA_Pat_Sci_Edu' limit 1];
            
        }
        if( recdType == 'Scientific and Research Focused Giving'){
            return  [SELECT Label,Paragraph1__c,Paragraph2__c,Paragraph3__c,Paragraph4__c,Paragraph5__c,Paragraph6__c,Paragraph7__c,Paragraph8__c,Paragraph9__c,Paragraph10__c,Paragraph11__c,Paragraph12__c,Paragraph13__c,Paragraph14__c,Paragraph15__c,
                     Paragraph16__c,Paragraph17__c,Paragraph18__c,Paragraph19__c,Paragraph20__c,Paragraph21__c,Paragraph22__c,Paragraph23__c,Paragraph24__c,Paragraph25__c,Paragraph26__c,Paragraph27__c,Paragraph28__c,Paragraph29__c,Paragraph30__c,
                     Paragraph31__c,Paragraph32__c,Paragraph33__c,Paragraph34__c,Paragraph35__c,Paragraph36__c,Paragraph37__c,Paragraph38__c,Paragraph39__c,Paragraph40__c,Paragraph41__c,Paragraph42__c,Paragraph43__c,Paragraph44__c,Paragraph45__c,
                     Paragraph46__c,Paragraph47__c,Paragraph48__c,Paragraph49__c,Paragraph50__c,Paragraph51__c,Paragraph52__c,Paragraph53__c,Paragraph54__c,Paragraphs__c,Section_Name__c,Addendum_Paragraph1__c,Addendum_Paragraph2__c,Addendum_Paragraph3__c,Addendum_Paragraph4__c,Addendum_Paragraph5__c,Independence__c,Payment__c  FROM LOAdocumentInfo__mdt where Label='LOA_ScienceReq' limit 1];
            
        }
        if(recdType == 'Education Focused Giving Graduate and Post-Graduate'){
            return  [SELECT Label,Paragraph1__c,Paragraph2__c,Paragraph3__c,Paragraph4__c,Paragraph5__c,Paragraph6__c,Paragraph7__c,Paragraph8__c,Paragraph9__c,Paragraph10__c,Paragraph11__c,Paragraph12__c,Paragraph13__c,Paragraph14__c,Paragraph15__c,
                     Paragraph16__c,Paragraph17__c,Paragraph18__c,Paragraph19__c,Paragraph20__c,Paragraph21__c,Paragraph22__c,Paragraph23__c,Paragraph24__c,Paragraph25__c,Paragraph26__c,Paragraph27__c,Paragraph28__c,Paragraph29__c,Paragraph30__c,
                     Paragraph31__c,Paragraph32__c,Paragraph33__c,Paragraph34__c,Paragraph35__c,Paragraph36__c,Paragraph37__c,Paragraph38__c,Paragraph39__c,Paragraph40__c,Paragraph41__c,Paragraph42__c,Paragraph43__c,Paragraph44__c,Paragraph45__c,
                     Paragraph46__c,Paragraph47__c,Paragraph48__c,Paragraph49__c,Paragraph50__c,Paragraph51__c,Paragraph52__c,Paragraph53__c,Paragraph54__c,Paragraphs__c,Section_Name__c,Addendum_Paragraph1__c,Addendum_Paragraph2__c,Addendum_Paragraph3__c,Addendum_Paragraph4__c,Addendum_Paragraph5__c,Independence__c,Payment__c  FROM LOAdocumentInfo__mdt where Label='LOA_EducationPostReq' limit 1];
            
        }
        if(recdType == 'Education Focused Giving K-12'){
          return [SELECT Label,Paragraph1__c,Paragraph2__c,Paragraph3__c,Paragraph4__c,Paragraph5__c,Paragraph6__c,Paragraph7__c,Paragraph8__c,Paragraph9__c,Paragraph10__c,Paragraph11__c,Paragraph12__c,Paragraph13__c,Paragraph14__c,Paragraph15__c,Paragraph16__c,Paragraph17__c,Paragraph18__c,Paragraph19__c,Paragraph20__c,
                                                 Paragraph21__c,Paragraph22__c,Paragraph23__c,Paragraph24__c,Paragraph25__c,Paragraph26__c,Paragraph27__c,Paragraph28__c,Paragraph29__c,Paragraph30__c,Paragraph31__c,Paragraph32__c,Paragraph33__c,Paragraph34__c,Paragraph35__c,Paragraphs__c,Section_Name__c,Addendum_Paragraph1__c,Addendum_Paragraph2__c,Addendum_Paragraph3__c,Addendum_Paragraph4__c,Addendum_Paragraph5__c,Independence__c,Payment__c  FROM LOAdocumentInfo__mdt where Label='LOA_CG_K12' limit 1];
   
        }if(recdType == 'Community Giving'){
          return [SELECT Label,Paragraph1__c,Paragraph2__c,Paragraph3__c,Paragraph4__c,Paragraph5__c,Paragraph6__c,Paragraph7__c,Paragraph8__c,Paragraph9__c,Paragraph10__c,Paragraph11__c,Paragraph12__c,Paragraph13__c,Paragraph14__c,Paragraph15__c,Paragraph16__c,Paragraph17__c,Paragraph18__c,Paragraph19__c,Paragraph20__c,
                                                 Paragraph21__c,Paragraph22__c,Paragraph23__c,Paragraph24__c,Paragraph25__c,Paragraph26__c,Paragraph27__c,Paragraph28__c,Paragraph29__c,Paragraph30__c,Paragraph31__c,Paragraph32__c,Paragraph33__c,Paragraph34__c,Paragraph35__c,Paragraphs__c,Section_Name__c,Addendum_Paragraph1__c,Addendum_Paragraph2__c,Addendum_Paragraph3__c,Addendum_Paragraph4__c,Addendum_Paragraph5__c,Independence__c,Payment__c  FROM LOAdocumentInfo__mdt where Label='LOA_CG' limit 1];
   
        }
        if(recdType == 'Commercial Sponsorship' || recdType == 'Corporate Memberships' || recdType == 'Non-Commercial Sponsorship' || recdType == 'Field exhibits'){
           return[SELECT Label,Paragraph1__c,Paragraph2__c,Paragraph3__c,Paragraph4__c,Paragraph5__c,Paragraph6__c,Paragraph7__c,Paragraph8__c,Paragraph9__c,Paragraph10__c,Paragraph11__c,Paragraph12__c,Paragraph13__c,Paragraph14__c,Paragraph15__c,Paragraph16__c,Paragraph17__c,Paragraph18__c,Paragraph19__c,Paragraph20__c,Paragraph21__c,Paragraph22__c,Paragraph23__c,Paragraph24__c,Paragraph25__c,Paragraph26__c,Paragraph27__c,
                  Paragraph40__c,Paragraph41__c,Paragraphs__c,Section_Name__c,Addendum_Paragraph1__c,Addendum_Paragraph2__c,Addendum_Paragraph3__c,Addendum_Paragraph4__c,Addendum_Paragraph5__c,Independence__c,Payment__c FROM LOAdocumentInfo__mdt where Label='Internal Funding Types' limit 1];

        }
        if(recdType == 'Independent Medical Education (CME)'){
           return[SELECT Label,Paragraph1__c,Paragraph2__c,Paragraph3__c,Paragraph4__c,Paragraph5__c,Paragraph6__c,Paragraph7__c,Paragraph8__c,Paragraph9__c,Paragraph10__c,Paragraph11__c,Paragraph12__c,Paragraph13__c,Paragraph14__c,Paragraph15__c,Paragraph16__c,Paragraph17__c,Paragraph18__c,Paragraph19__c,Paragraph20__c,
                      Paragraph21__c,Paragraph22__c,Paragraph23__c,Paragraph24__c,Paragraph25__c,Paragraph26__c,Paragraph27__c,Paragraph28__c,Paragraph29__c,Paragraph30__c,Paragraph31__c,Paragraph32__c,Paragraph33__c,Paragraph34__c,Paragraph35__c,Paragraphs__c,Section_Name__c,Addendum_Paragraph1__c,Addendum_Paragraph2__c,Addendum_Paragraph3__c,Addendum_Paragraph4__c,Addendum_Paragraph5__c,Independence__c,Payment__c
         FROM LOAdocumentInfo__mdt where Label='LOA_CME' limit 1];

        }
        if(recdType == 'Foundation Safety Net Support' || recdType == 'Foundation Undergraduate'){
            return[SELECT Label,Paragraph1__c,Paragraph2__c,Paragraph3__c,Paragraph4__c,Paragraph5__c,Paragraph6__c,Paragraph7__c,Paragraph8__c,Paragraph9__c,Paragraph10__c,Paragraph11__c,Paragraph12__c,Paragraph13__c,Paragraph14__c,Paragraph15__c,Paragraph16__c,Paragraph17__c,Paragraph18__c,Paragraph19__c,Paragraph20__c,
                   Paragraph21__c,Paragraph22__c,Paragraph23__c,Paragraph24__c,Paragraph25__c,Paragraph26__c,Paragraph27__c,Paragraph28__c,Paragraph29__c,Paragraph30__c,Paragraph31__c,Paragraph32__c,Paragraph33__c,Paragraph34__c,Paragraph35__c,Paragraphs__c,Section_Name__c,Addendum_Paragraph1__c,Addendum_Paragraph2__c,Addendum_Paragraph3__c,Addendum_Paragraph4__c,Addendum_Paragraph5__c
                   FROM LOAdocumentInfo__mdt where Label='LOA_Foundation' limit 1];
            
        }
	return null  ;      
    }
    
    @AuraEnabled
    public static list < LOA_Revision_Document__mdt > fetchRevisedLOAdocument(string recdType) {
        if(recdType == 'Patient and Health Focused Giving' || recdType == 'Scientific and Research Focused Giving' || recdType == 'Education Focused Giving Graduate and Post-Graduate'){
            return  [SELECT Label,Alternative_Paragrap1__c,Alternative_Paragrap2__c,Alternative_Paragrap3__c,Alternative_Paragrap4__c,Alternative_Paragrap5__c,Alternative_Paragrap6__c,Alternative_Paragrap7__c,Alternative_Paragrap8__c,Alternative_Paragrap9__c,Alternative_Paragrap10__c,Alternative_Paragrap11__c,Alternative_Paragrap12__c,Alternative_Paragrap13__c,Alternative_Paragrap14__c,Alternative_Paragrap15__c,
                     Alternative_Paragrap16__c,Alternative_Paragrap17__c,Alternative_Paragrap18__c,Alternative_Paragrap19__c,Alternative_Paragrap20__c,Alternative_Paragrap21__c,Alternative_Paragrap22__c,Alternative_Paragrap23__c,Alternative_Paragrap24__c,Alternative_Paragrap25__c,Alternative_Paragrap26__c,Alternative_Paragrap27__c,Alternative_Paragrap28__c,Alternative_Paragrap29__c,Alternative_Paragrap30__c,
                     Alternative_Paragrap31__c,Alternative_Paragrap32__c,Alternative_Paragrap33__c,Alternative_Paragrap34__c,Alternative_Paragrap35__c,Alternative_Paragrap36__c,Alternative_Paragrap37__c,Alternative_Paragrap38__c,Alternative_Paragrap39__c,Alternative_Paragrap40__c,Alternative_Paragrap41__c,Alternative_Paragrap42__c,Alternative_Paragrap43__c,Alternative_Paragrap44__c,Alternative_Paragrap45__c,
                     Alternative_Paragrap46__c,Alternative_Paragrap47__c,Alternative_Paragrap48__c,Alternative_Paragrap49__c,Alternative_Paragrap50__c,Alternative_Paragrap51__c,Alternative_Paragrap52__c,Alternative_Paragrap53__c,Alternative_Paragrap54__c,Section_Names__c,Addendum_Paragraph1__c,Addendum_Paragraph2__c,Addendum_Paragraph3__c,Addendum_Paragraph4__c,Addendum_Paragraph5__c  FROM LOA_Revision_Document__mdt where Label='LOA_Pat_Sci_Edu' limit 1];
            
        }
        if(recdType == 'Community Giving' || recdType == 'Education Focused Giving K-12'){
          return [SELECT Label,Alternative_Paragrap1__c,Alternative_Paragrap2__c,Alternative_Paragrap3__c,Alternative_Paragrap4__c,Alternative_Paragrap5__c,Alternative_Paragrap6__c,Alternative_Paragrap7__c,Alternative_Paragrap8__c,Alternative_Paragrap9__c,Alternative_Paragrap10__c,Alternative_Paragrap11__c,Alternative_Paragrap12__c,Alternative_Paragrap13__c,Alternative_Paragrap14__c,Alternative_Paragrap15__c,
                     Alternative_Paragrap16__c,Alternative_Paragrap17__c,Alternative_Paragrap18__c,Alternative_Paragrap19__c,Alternative_Paragrap20__c,Alternative_Paragrap21__c,Alternative_Paragrap22__c,Alternative_Paragrap23__c,Alternative_Paragrap24__c,Alternative_Paragrap25__c,Alternative_Paragrap26__c,Alternative_Paragrap27__c,Alternative_Paragrap28__c,Alternative_Paragrap29__c,Alternative_Paragrap30__c,
                     Alternative_Paragrap31__c,Alternative_Paragrap32__c,Alternative_Paragrap33__c,Alternative_Paragrap34__c,Alternative_Paragrap35__c,Section_Names__c,Addendum_Paragraph1__c,Addendum_Paragraph2__c,Addendum_Paragraph3__c,Addendum_Paragraph4__c,Addendum_Paragraph5__c,Alternative_Paragrap40__c,Alternative_Paragrap41__c  FROM LOA_Revision_Document__mdt where Label='LOA_CG_K12' limit 1];
   
        }
        if(recdType == 'Commercial Sponsorship' || recdType == 'Corporate Memberships' || recdType == 'Non-Commercial Sponsorship' || recdType == 'Field exhibits'){
           return[SELECT Label,Alternative_Paragrap1__c,Alternative_Paragrap2__c,Alternative_Paragrap3__c,Alternative_Paragrap4__c,Alternative_Paragrap5__c,Alternative_Paragrap6__c,Alternative_Paragrap7__c,Alternative_Paragrap8__c,Alternative_Paragrap9__c,Alternative_Paragrap10__c,Alternative_Paragrap11__c,Alternative_Paragrap12__c,Alternative_Paragrap13__c,Alternative_Paragrap14__c,Alternative_Paragrap15__c,
                     Alternative_Paragrap16__c,Alternative_Paragrap17__c,Alternative_Paragrap18__c,Alternative_Paragrap19__c,Alternative_Paragrap20__c,Alternative_Paragrap21__c,Alternative_Paragrap22__c,Alternative_Paragrap23__c,Alternative_Paragrap24__c,Alternative_Paragrap25__c,Alternative_Paragrap26__c,Alternative_Paragrap27__c,Alternative_Paragrap40__c,Alternative_Paragrap41__c,
                  Section_Names__c,Addendum_Paragraph1__c,Addendum_Paragraph2__c,Addendum_Paragraph3__c,Addendum_Paragraph4__c,Addendum_Paragraph5__c FROM LOA_Revision_Document__mdt where Label='Internal Funding Types' limit 1];

        }
        if(recdType == 'Independent Medical Education (CME)'){
           return[SELECT Label,Alternative_Paragrap1__c,Alternative_Paragrap2__c,Alternative_Paragrap3__c,Alternative_Paragrap4__c,Alternative_Paragrap5__c,Alternative_Paragrap6__c,Alternative_Paragrap7__c,Alternative_Paragrap8__c,Alternative_Paragrap9__c,Alternative_Paragrap10__c,Alternative_Paragrap11__c,Alternative_Paragrap12__c,Alternative_Paragrap13__c,Alternative_Paragrap14__c,Alternative_Paragrap15__c,
                     Alternative_Paragrap16__c,Alternative_Paragrap17__c,Alternative_Paragrap18__c,Alternative_Paragrap19__c,Alternative_Paragrap20__c,Alternative_Paragrap21__c,Alternative_Paragrap22__c,Alternative_Paragrap23__c,Alternative_Paragrap24__c,Alternative_Paragrap25__c,Alternative_Paragrap26__c,Alternative_Paragrap27__c,Alternative_Paragrap28__c,Alternative_Paragrap29__c,Alternative_Paragrap30__c,
                     Alternative_Paragrap31__c,Alternative_Paragrap32__c,Alternative_Paragrap33__c,Alternative_Paragrap34__c,Alternative_Paragrap35__c,Section_Names__c,Addendum_Paragraph1__c,Addendum_Paragraph2__c,Addendum_Paragraph3__c,Addendum_Paragraph4__c,Addendum_Paragraph5__c,Alternative_Paragrap40__c,Alternative_Paragrap41__c
         FROM LOA_Revision_Document__mdt where Label='LOA_CME' limit 1];

        }
        if(recdType == 'Foundation Safety Net Support' || recdType == 'Foundation Undergraduate'){
           return[SELECT Label,Alternative_Paragrap1__c,Alternative_Paragrap2__c,Alternative_Paragrap3__c,Alternative_Paragrap4__c,Alternative_Paragrap5__c,Alternative_Paragrap6__c,Alternative_Paragrap7__c,Alternative_Paragrap8__c,Alternative_Paragrap9__c,Alternative_Paragrap10__c,Alternative_Paragrap11__c,Alternative_Paragrap12__c,Alternative_Paragrap13__c,Alternative_Paragrap14__c,Alternative_Paragrap15__c,
                     Alternative_Paragrap16__c,Alternative_Paragrap17__c,Alternative_Paragrap18__c,Alternative_Paragrap19__c,Alternative_Paragrap20__c,Alternative_Paragrap21__c,Alternative_Paragrap22__c,Alternative_Paragrap23__c,Alternative_Paragrap24__c,Alternative_Paragrap25__c,Alternative_Paragrap26__c,Alternative_Paragrap27__c,Alternative_Paragrap28__c,Alternative_Paragrap29__c,Alternative_Paragrap30__c,
                     Alternative_Paragrap31__c,Alternative_Paragrap32__c,Alternative_Paragrap33__c,Alternative_Paragrap34__c,Alternative_Paragrap35__c,Section_Names__c,Addendum_Paragraph1__c,Addendum_Paragraph2__c,Addendum_Paragraph3__c,Addendum_Paragraph4__c,Addendum_Paragraph5__c
         FROM LOA_Revision_Document__mdt where Label='LOA_Foundation' limit 1];

        }
	return null  ;      
    }
 @AuraEnabled
    public static List<sObject> getFundingDetails(string searchKey, string recdType) {   
        String searchKeys = searchKey + '%';
       
        String sQuery='';     
        system.debug('searchKeys@@' +searchKeys);
        system.debug('recdTypes@@@' +recdType);
        List <sObject> returnList = new List <sObject>();
        sQuery ='select id, Name  from  gFRS_Ltng_Application__c where RecordType.Name=:recdType and Name LIKE:searchKeys  order by createdDate DESC limit 100'; 
            system.debug('query' +sQuery);
        List <sObject> lstOfRecords = Database.query(sQuery);
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;      
    }
    
    @AuraEnabled
    public static void savePDFHTML(LOA_Revision_Document__mdt p1 ,String recdId,String RecdType,string section) {    
         system.debug('section'+section);
        if(recdType == 'Community Giving' || recdType == 'Education Focused Giving K-12'){            
            gFRS_LOA_Revision_DocumentPDF_CG_K12.InsertDocument(recdId,p1,section);
        } 
        if(recdType == 'Patient and Health Focused Giving' || recdType == 'Scientific and Research Focused Giving' || recdType == 'Education Focused Giving Graduate and Post-Graduate'){
        	gFRS_LOA_Revision_Document_PSE.InsertDocument(recdId,p1,section);
        }
        if(recdType == 'Commercial Sponsorship' || recdType == 'Corporate Memberships' || recdType == 'Non-Commercial Sponsorship' || recdType == 'Field exhibits'){
          gFRS_LOA_Revision_DocumentPDF.InsertDocument(recdId,p1,section);

        }
        if(recdType == 'Independent Medical Education (CME)'){
          gFRS_LOA_Revision_DocumentPDF_CME.InsertDocument(recdId,p1,section);

        }
        if(recdType == 'Foundation Safety Net Support' || recdType == 'Foundation Undergraduate'){
            gFRS_LOA_Revision_DocumentPDF_Foundation.InsertDocument(recdId,p1,section);
        }
    }
    @AuraEnabled
    public static gFRS_Ltng_Application__c fetchApplicationReq(Id reqId){
        return [SELECT Id,Name,Approved_Amount__c,Event_Program_Title__c,Record_Type__c,EnvelopeId__c,
                                          LOA_RevisionsId__c,Email_Address__c,First_Name__c,Last_Name__c,Authorized_Signer__r.Name
                                          FROM gFRS_Ltng_Application__c WHERE Id =:reqId ];
				
					
    }
    @future(callout=true)  
    @AuraEnabled
    public static void SendNow(Id sourceId){
       String envelopeId;
       GFRS_Ltng_OrgSettings__c orgCS = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
       String accountId = orgCS.DocuSign_AccountId__c;
       String userId = orgCS.DocuSign_UserId__c;
       String password = orgCS.DocuSign_Password__c;
       String integratorsKey = orgCS.DocuSign_IntegratorsKey__c;    //DocuSign_IntegratorsKey__c
       String webServiceUrl = orgCS.DocuSign_WebServiceUrl__c;  //DocuSign_WebServiceUrl__c
        
    /* String accountId = '95bf06d3-cfb9-452a-9d7d-e1ce96948270';   //DocuSign_AccountId__c
       String userId = '3bb814d2-2623-415f-90c5-2e16e4af6019';  //DocuSign_UserId__c
       String password = 'Demo2021';    //DocuSign_Password__c
       String integratorsKey = '7b3934f7-593a-411b-8a56-c9a254e73348';  //DocuSign_IntegratorsKey__c
       String webServiceUrl = 'https://demo.docusign.net/api/3.0/dsapi.asmx';   //DocuSign_WebServiceUrl__c*/
       gFRS_Ltng_Application__c appRec = [SELECT Id,Name,Approved_Amount__c,Event_Program_Title__c,Record_Type__c,EnvelopeId__c,
                                          LOA_RevisionsId__c,Email_Address__c,First_Name__c,Last_Name__c,Authorized_Signer__r.Name,Program_Start_Date_Min__c
                                          FROM gFRS_Ltng_Application__c WHERE Id =: sourceId LIMIT 1];
       Blob pdfBlob = [SELECT Id,VersionData from ContentVersion WHERE ContentDocumentId =: appRec.LOA_RevisionsId__c LIMIT 1].VersionData;
       String loaRevisionId = appRec.LOA_RevisionsId__c; // GFRS-1048
       
        EmailTemplate  emailCon = [SELECT Subject, Name, Id, Description,HTMLValue,Body,DeveloperName
                                   FROM EmailTemplate WHERE DeveloperName = 'LOA_DocuSign_Review_Attachment'];
        //emailCon.setTargetObjectId(appRec.Id);

        string Subject = emailCon.Subject.replace('{!gFRS_Ltng_Application__c.Name}', appRec.Name);
        //String body = emailCon.Body.replace('{!gFRS_Ltng_Application__c.Name}', appRec.Name); 
        String body = emailCon.HTMLValue.replace('{!gFRS_Ltng_Application__c.Name}', appRec.Name);
        string prgStartDate =  string.valueOf(appRec.Program_Start_Date_Min__c);
        String programDate = '';
        if(String.isNotBlank(prgStartDate)){
            Date dt=appRec.Program_Start_Date_Min__c;
            programDate=dt.format();
        }
        body = body.replace('{!gFRS_Ltng_Application__c.Program_Start_Date_Min__c}',programDate);
        body = body.replace('{!gFRS_Ltng_Application__c.Record_Type__c}',appRec.Record_Type__c);
        //body = body.replace('{!gFRS_Ltng_Application__c.First_Name__c} {!gFRS_Ltng_Application__c.Last_Name__c}',appRec.First_Name__c + appRec.Last_Name__c);
        if(string.isNotBlank(appRec.First_Name__c)) {
            body = body.replace('{!gFRS_Ltng_Application__c.First_Name__c}',appRec.First_Name__c);
        }
        if(string.isNotBlank(appRec.Last_Name__c)) {
            body = body.replace('{!gFRS_Ltng_Application__c.Last_Name__c}',appRec.Last_Name__c);
        }
        if(appRec.Approved_Amount__c!=null){
            Decimal input=appRec.Approved_Amount__c;
            String AppAmount = '$' + String.valueOf(input.format());
            body = body.replace('{!gFRS_Ltng_Application__c.Approved_Amount__c}',AppAmount);
        }else{
            body = body.replace('{!gFRS_Ltng_Application__c.Approved_Amount__c}','');
        }
		
        if(string.isNotBlank(appRec.Event_Program_Title__c)) {
            body = body.replace('{!gFRS_Ltng_Application__c.Event_Program_Title__c}', appRec.Event_Program_Title__c);
        }else{
            body = body.replace('{!gFRS_Ltng_Application__c.Event_Program_Title__c}', '');
        }
        body = body.replace(']]>', '');
        DocuSignAPI.APIServiceSoap dsApiSend = new DocuSignAPI.APIServiceSoap();
        dsApiSend.endpoint_x = webServiceUrl;

        //Set Authentication
        String auth = '<DocuSignCredentials><Username>'+ userId 
            +'</Username><Password>' + password 
            + '</Password><IntegratorKey>' + integratorsKey 
            + '</IntegratorKey></DocuSignCredentials>';
        System.debug('Setting authentication to: ' + auth);
            
        dsApiSend.inputHttpHeaders_x = new Map<String, String>();
        dsApiSend.inputHttpHeaders_x.put('X-DocuSign-Authentication', 
            auth);
 
        DocuSignAPI.Envelope envelope = new DocuSignAPI.Envelope();
        envelope.Subject = Subject;
        //envelope.EmailBlurb = 'I am sending you this request for your electronic signature, please review and electronically sign by following the link below.';
        envelope.EmailBlurb = body;
        envelope.AccountId  = accountId; 


        // Render the contract
       // System.debug('Rendering the contract');
        //PageReference pageRef = new PageReference('/apex/RenderContract');
       // pageRef.getParameters().put('id',contract.Id);
        //Blob pdfBlob = pageRef.getContent();     
        //Blob pdfBlob = [SELECT Id,ContentDocumentId,ContentBodyId,ContentSize,VersionData from ContentVersion].VersionData;
        

        // Document
        DocuSignAPI.Document document = new DocuSignAPI.Document();
        document.ID = 1;
        document.pdfBytes = EncodingUtil.base64Encode(pdfBlob);
        document.Name = appRec.Name+'_Executed LOA';
        document.FileExtension = 'pdf';
        envelope.Documents = new DocuSignAPI.ArrayOfDocument();
        envelope.Documents.Document = new DocuSignAPI.Document[1];
        envelope.Documents.Document[0] = document;
        
        // Recipient
        System.debug('getting the contact');
        
        DocuSignAPI.Recipient recipient = new DocuSignAPI.Recipient();
        recipient.ID = 1;
        recipient.Type_x = 'Signer';
        recipient.RoutingOrder = 1;
        recipient.Email = appRec.Email_Address__c;
        //recipient.UserName = appRec.Authorized_Signer__r.Name;
        recipient.UserName = appRec.First_Name__c+' '+appRec.Last_Name__c;
            
        // This setting seems required or you see the error:
        // "The string '' is not a valid Boolean value. 
        // at System.Xml.XmlConvert.ToBoolean(String s)" 
        recipient.RequireIDLookup = false;      
        
        envelope.Recipients = new DocuSignAPI.ArrayOfRecipient();
        envelope.Recipients.Recipient = new DocuSignAPI.Recipient[1];
        envelope.Recipients.Recipient[0] = recipient;
        
        // Tab
        DocuSignAPI.Tab tab1 = new DocuSignAPI.Tab();
        tab1.Type_x = 'SignHere';
        tab1.RecipientID = 1;
        tab1.DocumentID = 1;
        tab1.AnchorTabItem = new DocuSignAPI.AnchorTab();
        tab1.AnchorTabItem.AnchorTabString = 'By:';
        tab1.AnchorTabItem.XOffset = 50;
        //tab1.AnchorTabItem.YOffset = 100;
        //tab1.PageNumber = 1;
        //tab1.XPosition = 100;
        //tab1.YPosition = 100;

        
        DocuSignAPI.Tab tab2 = new DocuSignAPI.Tab();
        tab2.Type_x = 'DateSigned';
        tab2.RecipientID = 1;
        tab2.DocumentID = 1;
        tab2.AnchorTabItem = new DocuSignAPI.AnchorTab();
        tab2.AnchorTabItem.AnchorTabString = 'Date/Time:';
        tab2.AnchorTabItem.XOffset = 80;
        //tab2.XPosition = 100;
        //tab2.YPosition = 100;       
        envelope.Tabs = new DocuSignAPI.ArrayOfTab();
        envelope.Tabs.Tab = new DocuSignAPI.Tab[2];
        envelope.Tabs.Tab[0] = tab1;        
        envelope.Tabs.Tab[1] = tab2;        
        system.debug('tabs'+envelope.Tabs);
        System.debug('Calling the API');
        try {
            DocuSignAPI.EnvelopeStatus es 
            = dsApiSend.CreateAndSendEnvelope(envelope);
            envelopeId = es.EnvelopeID;
            gFRS_Ltng_Application__c appObj = new gFRS_Ltng_Application__c();
            if(appRec.EnvelopeId__c == ''){
                appObj.Docusign_Task_Check__c = True;
            }
            appObj.EnvelopeId__c = es.EnvelopeID;
            appObj.Id = sourceId;
            appObj.User_who_sent_LOA_from_LOA_playbook__c = UserInfo.getUserId();
            appObj.LOA_sent_date_from_LOA_playbook__c =  System.today();
            appObj.DocuSign_Revised_LOA_Id__c = loaRevisionId; // GFRS-1048
            update appObj;
            
            system.debug('status'+es.EnvelopeID);

        } catch ( CalloutException e) {
            System.debug('Exception - ' + e );
            envelopeId = 'Exception - ' + e;
        }
      
    }
    public class picklistWrapper{
        @AuraEnabled 
        public string pickListLabel{get;set;}
        @AuraEnabled 
        public string pickListValue{get;set;}
        
    }
}