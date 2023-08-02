public class gFRS_Ltng_BudgetController {
    /**
* This method calls the meta data to get picklist values 
*
* @param String,String
* @return Picklistwrapper 
*/
    
    @AuraEnabled  
    public static List<picklistWrapper> getPicklistvalues(string objAPIName, string fieldAPIname) {
        list<picklistWrapper> returnValue = new list<picklistWrapper>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        // Get the object type of the SObject.
        Schema.sObjectType objType = schemaMap.get(objAPIName);
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        // Get a map of fields for the SObject
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values = fieldMap.get(fieldAPIname).getDescribe().getPickListValues();
        
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a: values) {
            picklistWrapper aa = new picklistWrapper();
            aa.pickListLabel = a.getLabel();
            aa.pickListValue = a.getValue();
            returnValue.add(aa);
        }
        system.debug('*****returnValue'+returnValue);
        return returnValue;   
    }    
    
    public class picklistWrapper{
        @AuraEnabled 
        public string pickListLabel;
        @AuraEnabled 
        public string pickListValue;
        
    }
    
    @AuraEnabled  
    public static picklistWrapperObj getRecordTypePicklist(string objAPIName,string recordtypename) {
        system.debug('rec '+recordtypename);
        list<picklistWrapper> returnValue = new list<picklistWrapper>();
        List<RecordType> recordTypeList =[Select Id,Name from RecordType where SobjectType =: objAPIName];
        Id recordTypeId = [SELECT Id,DeveloperName,Name FROM recordtype WHERE SobjectType = 'gFRS_Ltng_Request_Budget_Detail__c' AND Name =:recordtypename].Id;
        
        //string recordTypeId = Schema.SObjectType.gFRS_Ltng_Request_Budget_Detail__c.getRecordTypeInfosByDeveloperName().get(recordtypename).getRecordTypeId();
        for(RecordType rec : recordTypeList)
        {
            picklistWrapper aa = new picklistWrapper();  
            aa.pickListLabel = rec.Name;
            aa.pickListValue = rec.Id;
            returnValue.add(aa);
        }
        picklistWrapperObj recObj = new picklistWrapperObj();
        recObj.rectypelist = returnValue;
        recObj.recordtypeIdValue = recordTypeId;
        return recObj;
    }
    
    public class picklistWrapperObj{
        @AuraEnabled 
        public List<picklistWrapper> rectypelist;
        @AuraEnabled 
        public string recordtypeIdValue;
        
    }
    
    @AuraEnabled 
    public static String getPicklistValueBasedonRecordType(String objectAPIName, String fieldAPIName, String recordTypeNm){
        
        list<PicklistValue> picklistValues = new list<PicklistValue>();
        
        //get record type Id
        /* list<RecordType> recordTypes = [Select Id, Name From RecordType  Where SobjectType = :objectAPIName and Id = :recordTypeId limit 1];
Id recordTypeId = (!recordTypes.isEmpty()) ? recordTypes.get(0).Id : null;*/
        
        if(String.isNotBlank(recordTypeNm)){
            Id recordTypeId = [SELECT Id,DeveloperName,Name FROM recordtype WHERE SobjectType = 'gFRS_Ltng_Request_Budget_Detail__c' AND Name =:recordTypeNm].Id;
            //string recordTypeId = Schema.SObjectType.gFRS_Ltng_Request_Budget_Detail__c.getRecordTypeInfosByDeveloperName().get(recordTypeNm).getRecordTypeId();
            String method = 'GET';
            String endpoint = String.format('/services/data/v43.0/ui-api/object-info/{0}/picklist-values/{1}/{2}', new String[]{ objectAPIName, recordTypeId, fieldAPIName });
            
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:Record_Type_Named_Credentials'+endPoint);
            request.setMethod(method);
            
            HTTPResponse response = (new Http()).send(request);
            
            if(response.getStatusCode() == 200){
                
                Map<String,Object> root = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
                if(root.containsKey('values')){ 
                    List<Object> picklistVals = (List<Object>)root.get('values');
                    for(Object picklistVal : picklistVals){
                        Map<String,Object> picklistValMap = (Map<String,Object>) picklistVal;
                        picklistValue pickVal = new picklistValue();
                        pickVal.value = (String) picklistValMap.get('value');
                        pickVal.label = (String) picklistValMap.get('label');
                        picklistValues.add(pickVal);
                    }
                }
                
            }
            
        }
        
        return JSON.serialize(picklistValues);
    }
    
    public class PicklistValue{
        @AuraEnabled public String value {get;set;}
        @AuraEnabled public String label {get;set;}
    }
    
    
    
    @AuraEnabled
    public static List<gFRSLtngParentRequestBudgetWrapper> getBudgetDetails(Id appId,String objectAPIName,String controllingFieldAPI, String dependentPicklistAPI){
        List<gFRSLtngParentRequestBudgetWrapper> gFRSLtngParentRequestBudgetWrappList = new List<gFRSLtngParentRequestBudgetWrapper>();
        //return [Select id,name,gFRS_Program_Type__c From gFRS_Ltng_Program__c Where gFRS_Application__c='aKP3C0000004CN5WAM'];
        List<gFRS_Ltng_Request_Budget__c> listOfrequestBudget =   [Select id,Name
                                                                   ,Total_Amount__c
                                                                   ,Total_Ltng_Amount__c
                                                                   ,Type__c
                                                                   ,gFRS_Application__c
                                                                   ,gFRS_Application__r.Record_Type_Name__c,Multi_year_budget_attachment__c,Budget_Attachment_File_Name__c,Budget_Attachment_File_Type__c,
                                                                   (Select id,RecordTypeId,Category__c,Subcategory__c,Amount__c,Count__c,Explanation__c,gFRS_Request_Budget__c From FRS_Request_Budget_Line_Items__r) 
                                                                   From gFRS_Ltng_Request_Budget__c Where gFRS_Application__c=:appId];
        
        
        List<PicklistValue>  picklistVal = new List<PicklistValue>();
        PicklistValue  picklVal = new PicklistValue();
        picklVal.label = '--None--';
        picklVal.value = '';
        picklistVal.add(picklVal);
        Map<String,List<String>> mapDependentPicklist  = getDependentPicklist('gFRS_Ltng_Request_Budget_Detail__c','Category__c','Subcategory__c');
        
        for(gFRS_Ltng_Request_Budget__c budget : listOfrequestBudget)
        {
            
            gFRSLtngParentRequestBudgetWrapper gFRSLtngParentRequestBudgetWrap = new gFRSLtngParentRequestBudgetWrapper();
            gFRSLtngParentRequestBudgetWrap.requestBudget =  new List<gFRS_Ltng_Request_Budget__c>();
            gFRSLtngParentRequestBudgetWrap.gFRSLtngRequestBudgetWrapList = new List<gFRSLtngRequestBudgetWrapper>();
            gFRSLtngParentRequestBudgetWrap.requestBudget.add(budget);
            if( budget.FRS_Request_Budget_Line_Items__r.size() > 0){
                for(gFRS_Ltng_Request_Budget_Detail__c budgetLine : budget.FRS_Request_Budget_Line_Items__r){
                    gFRSLtngRequestBudgetWrapper gFRSLtngRequestBudgetWrap = new gFRSLtngRequestBudgetWrapper(); 
                    System.debug('mapDependentPicklist '+mapDependentPicklist);
                    System.debug('budgetLine.Category__c '+budgetLine.Category__c);
                    if(mapDependentPicklist.containsKey(budgetLine.Category__c))
                    {
                        for(String key : mapDependentPicklist.get(budgetLine.Category__c)){
                            PicklistValue  picklVal1 = new PicklistValue();
                            picklVal1.label = key;
                            picklVal1.value = key;
                            picklistVal.add(picklVal1);
                        }
                    }
                    gFRSLtngRequestBudgetWrap.dependentPiklistMap = picklistVal;
                    gFRSLtngRequestBudgetWrap.requestLineBudget = budgetLine;
                    gFRSLtngParentRequestBudgetWrap.gFRSLtngRequestBudgetWrapList.add(gFRSLtngRequestBudgetWrap);
                }
                
            }
            gFRSLtngParentRequestBudgetWrappList.add(gFRSLtngParentRequestBudgetWrap);
        }
        // gFRSLtngParentRequestBudgetWrap.gFRSLtngRequestBudgetWrapList.addAll(gFRSLtngRequestBudgetWrapLists);
        return gFRSLtngParentRequestBudgetWrappList;// gFRS_Application__c='aKP3C0000004CN5WAM' LIMIT 1
    }
    
    @AuraEnabled
    public static Map<String,List<String>> getDependentPicklist(String objectAPIName,String controllingFieldAPI, String dependentPicklistAPI){
        
        Map<String,List<String>> valueMap = DependentPicklistUtils.getFieldDependencies(
            objectAPIName,controllingFieldAPI,dependentPicklistAPI);
        return valueMap;
    }
    
    Public class gFRSLtngParentRequestBudgetWrapper
    {
        @AuraEnabled Public List<gFRSLtngRequestBudgetWrapper> gFRSLtngRequestBudgetWrapList {get;set;}
        @AuraEnabled Public List<gFRS_Ltng_Request_Budget__c> requestBudget {get;set;}
    }
    
    public class gFRSLtngRequestBudgetWrapper{
        //@AuraEnabled   public gFRS_Ltng_Request_Budget__c requestBudget {get;set;}
        @AuraEnabled   public gFRS_Ltng_Request_Budget_Detail__c requestLineBudget {get;set;}
        @AuraEnabled   public List<PicklistValue> dependentPiklistMap {get;set;}
    }
    
    @AuraEnabled
    public static void updateBudegtsItems(List<gFRS_Ltng_Request_Budget__c> budgetlst,
                                          List<gFRS_Ltng_Request_Budget_Detail__c> lstbdgUpitems,
                                          List<gFRS_Ltng_Request_Budget_Detail__c> lstbdgInitems,Integer totalOverallBgt,Id appId){
                                              
                                              SavePoint sp = Database.setSavepoint();
                                              List<gFRS_Ltng_Request_Budget__c> lstbudegt = new List<gFRS_Ltng_Request_Budget__c>();
                                              List<gFRS_Ltng_Request_Budget_Detail__c> lstMembers = new List<gFRS_Ltng_Request_Budget_Detail__c>();
                                              List<gFRS_Ltng_Request_Budget_Detail__c> uplstMembers = new List<gFRS_Ltng_Request_Budget_Detail__c>();                                         
                                              
                                              
                                              try{
                                                  
                                                  
                                                  gFRS_Ltng_Application__c updateApplication=new gFRS_Ltng_Application__c();
                                                  updateApplication.Id=appId;
                                                  updateApplication.Selected_Tab_Val__c='reqAttch';
                                                  updateApplication.Total_Overall_Budget__c=Integer.valueOf(totalOverallBgt);
                                                  // update updateApplication;
                                                  gFRS_Ltng_Util_NoShare.updateGfrsAPP(updateApplication);
                                                  
                                                  for( gFRS_Ltng_Request_Budget__c brec : budgetlst ) {
                                                      
                                                      gFRS_Ltng_Request_Budget__c rec=new gFRS_Ltng_Request_Budget__c();
                                                      rec.Id=brec.Id;
                                                      rec.Total_Amount__c=brec.Total_Amount__c;
                                                      lstbudegt.add(rec);
                                                      System.debug('@@@ Parent Records'+brec);
                                                  }
                                                  
                                                  if(lstbdgInitems.size()>0)
                                                  {
                                                      
                                                      for(gFRS_Ltng_Request_Budget_Detail__c chItem:lstbdgInitems){
                                                          
                                                          lstMembers.add(new gFRS_Ltng_Request_Budget_Detail__c(
                                                              Category__c=chItem.Category__c,
                                                              Subcategory__c=chItem.Subcategory__c,
                                                              Amount__c=chItem.Amount__c,
                                                              Count__c=chItem.Count__c,
                                                              Explanation__c=chItem.Explanation__c,
                                                              gFRS_Request_Budget__c=chItem.gFRS_Request_Budget__c));
                                                      } 
                                                      
                                                  }
                                                  
                                                  
                                                  if(lstbdgUpitems.size()>0)
                                                  {
                                                      
                                                      for(gFRS_Ltng_Request_Budget_Detail__c chItem:lstbdgUpitems){
                                                          
                                                          uplstMembers.add(new gFRS_Ltng_Request_Budget_Detail__c(
                                                              Id=chItem.Id,
                                                              Category__c=chItem.Category__c,
                                                              Subcategory__c=chItem.Subcategory__c,
                                                              Amount__c=chItem.Amount__c,
                                                              Count__c=chItem.Count__c,
                                                              Explanation__c=chItem.Explanation__c,
                                                              gFRS_Request_Budget__c=chItem.gFRS_Request_Budget__c));
                                                      } 
                                                      
                                                  }
                                                  
                                                  system.debug('@@@hhhhh'+lstMembers);
                                                  
                                                  
                                                  //Database.UpsertResult[] resultsbudegts = Database.upsert( lstbudegt,false);
                                                  gFRS_Ltng_Util_NoShare.updateBudgetRecList(lstbudegt);
                                                  
                                                  
                                                  
                                                  //if(uplstMembers.size()>0){
                                                  //Database.SaveResult[] upResults= Database.update(uplstMembers,false);
                                                  gFRS_Ltng_Util_NoShare.updateBudgetLineItemRecList(uplstMembers);
                                                  //}
                                                  
                                                  //if(lstMembers.size()>0){ 
                                                  //Database.SaveResult[] inRresults= Database.insert(lstMembers,false);
                                                  gFRS_Ltng_Util_NoShare.insertBudgetLineItemRecList(lstMembers);
                                                  //}
                                                  
                                                  //system.debug('@@@ Veera Debug upResults'+upResults);
                                                  //system.debug('@@@ Veera Debug inRresults'+inRresults);
                                                  
                                                  
                                              }
                                              catch(Exception e){
                                                  
                                                  Database.rollback(sp);
                                                  System.debug('@@@@'+e.getMessage());
                                                  AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
                                                  throw auraExceptionObj;              
                                              }
                                          }
    
    @AuraEnabled
    public static void delBudgetItems(List<Id> lstIds){
        
        SavePoint sp = Database.setSavepoint();
        try{
            
            Database.DeleteResult[] delResults=Database.delete(lstIds,false);
            system.debug('@@@ deleted Records '+delResults);
            
        }
        catch(Exception e){
            
            Database.rollback(sp);
            System.debug('@@@@'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
        
    }
    
    @AuraEnabled 
    public static Map<String, List<String>> getDependentMap(sObject objDetail, string contrfieldApiName,string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        Schema.sObjectType objType = objDetail.getSObjectType();
        if (objType==null){
            return objResults;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        return objResults;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){            
        }
        
    }
    
    public class budgetExplanationWrapper{
        @AuraEnabled public Map<String,String> explanationMap {get;set;}
        @AuraEnabled public Id budgetLineRecTypeId {get;set;}
        
    }
    
    @AuraEnabled
    public static budgetExplanationWrapper getBudgetExplantions(String recType){
        
        Map<String,String> explMap=new Map<String,String>();
        Id recTypeId;
        for(Budget_Explantion__mdt bdg:[SELECT Id, MasterLabel, DeveloperName, Label,Value__c FROM Budget_Explantion__mdt])
        {
            
            explMap.put(bdg.Label,bdg.Value__c);
            
        }
        if(recType == 'Independent Medical Education (CME)'){
            recTypeId = [SELECT Id, Name FROM RecordType where SobjectType = 'gFRS_Ltng_Request_Budget_Detail__c' and Name = 'Independent Medical Education (CME)'].Id;
        } else if(recType == 'Patient and Health Focused Giving'){
            recTypeId = [SELECT Id, Name FROM RecordType where SobjectType = 'gFRS_Ltng_Request_Budget_Detail__c' and Name = 'Patient and Health Focused Giving'].Id;
        } else if(recType == 'Scientific and Research Focused Giving'){
            recTypeId = [SELECT Id, Name FROM RecordType where SobjectType = 'gFRS_Ltng_Request_Budget_Detail__c' and Name = 'Scientific and Research Focused Giving'].Id;
        } else if(recType == 'Education Focused Giving Graduate and Post-Graduate'){
            recTypeId = [SELECT Id, Name FROM RecordType where SobjectType = 'gFRS_Ltng_Request_Budget_Detail__c' and Name = 'Education Focused Giving Graduate and Post-Graduate'].Id;
        }
        
        
        budgetExplanationWrapper budgetExplanationWrap = new budgetExplanationWrapper();
        budgetExplanationWrap.explanationMap        = explMap;
        budgetExplanationWrap.budgetLineRecTypeId   = recTypeId;
        return budgetExplanationWrap;
    }
    @AuraEnabled    
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        
        try{
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');            
            Attachment oAttachment = new Attachment();
            oAttachment.parentId = parentId;
            oAttachment.OwnerId = UserInfo.getUserId();
            oAttachment.Body = EncodingUtil.base64Decode(base64Data);
            oAttachment.Name = fileName;
            oAttachment.ContentType = contentType;
            
            //insert oAttachment;
            system.debug('@@@:::base64Data::::'+base64Data);
            system.debug('@@@ Attch insert');
            
            
            //Insert ContentVersion
            ContentVersion cVersion = new ContentVersion();
            cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
            cVersion.PathOnClient = fileName;//File name with extention
            cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
            cVersion.OwnerId = UserInfo.getUserId();//Owner of the file
            cVersion.Title = fileName;//Name of the file
            cVersion.VersionData = oAttachment.Body;//File content
            Insert cVersion;     
            
            system.debug('@@@ CV insert');
            //After saved the Content Verison, get the ContentDocumentId
            Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            
            //Insert ContentDocumentLink
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
            cDocLink.LinkedEntityId = parentId;//Add attachment parentId
            cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
            Insert cDocLink;            
            system.debug('@@@ CDL insert');
            
            system.debug('oAttachment'+oAttachment);
            
            //return oAttachment.Id;
            return cDocLink.ContentDocumentId;
        }catch(Exception e){
            System.debug('@@@@ Save File Error :'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
        
        
    }
    
    @AuraEnabled
    public static void deleteAttachment(Id attchId, Id parentId) {
        try{            
            /* attachment att = [SELECT Id, name, parentId FROM Attachment WHERE Id =: attchId];
Id parentId = att.parentId;
delete att; */
            
            List<ContentDocument> entries = [SELECT id,Title,FileType,CreatedBy.Name,ContentSize FROM ContentDocument WHERE Id =:attchId]; 
            delete entries;            
            
            gFRS_Ltng_Request_Budget__c objBudget = [Select id,Multi_year_budget_attachment__c From gFRS_Ltng_Request_Budget__c
                                                     where id=: parentId];
            
            
            objBudget.id = parentId;
            objBudget.Multi_year_budget_attachment__c = '';
            
            gFRS_Ltng_Util_NoShare.updateBudgetRec(objBudget);
            //upsert objBudget;
            
        }catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }    
     @AuraEnabled
    public static Id updateBudgetRecd (Id parentId, Id docId, string typOfFile, string fileName,string extension) {
        try{ 
            gFRS_Ltng_Request_Budget__c objBudget =new gFRS_Ltng_Request_Budget__c();
            objBudget.id = parentId;
            objBudget.Multi_year_budget_attachment__c = docId;                
            objBudget.Budget_Attachment_File_Name__c  = fileName;
            objBudget.Budget_Attachment_File_Type__c  = extension; 
            
            gFRS_Ltng_Util_NoShare.updateBudgetRec(objBudget);
            //upsert objBudget;            
            return docId;
        }catch(Exception e){
            System.debug('@@@@ Upload chunk Error :'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }  
    
    
    @AuraEnabled
    public static gFRS_Ltng_Application__c fetchFundingReqDetails(String reqId){
        Id recId = Id.valueof(reqId);
        system.debug('Application Id is : '+recId);
        gFRS_Ltng_Application__c appRec = new gFRS_Ltng_Application__c();
        try{
            appRec = [SELECT Id, Name, What_are_you_seeking_funding_for__c, Target_audience__c, Organization__c, Information_Needed__c,
                      Sister_Parent_Org_Strategic_Promo_Mktg__c,Focus_Area__c,Firewall_for_Strategic_Promo_Mktg__c, 
                      Is_this_program_accredited__c, Org_the_Accreditor__c, Content_Development__c, 
                      Requested_Amount__c, Event_Program_Title__c, Therapeutic_Area__c, Disease_State__c,
                      Please_Specify_If_Disease_State_Other__c, Support_Purpose_Program_Description__c, 
                      Clinical_Practice_Guideline_Development__c, Associated_clinical_practice_guidelines__c,
                      Primary_Audience_Description__c, Addressed_by_this_Program_Initiative__c, Program_Objectives__c, Outcome_levels_to_be_achieved__c,
                      Other_Commercial_Supporters__c, If_known_List_Other_Supporters__c, Resubmission_of_Previous_Request__c, Resubmission_Request_Name__c,
                      Secondary_Invitations_BRC_s_Help_Request__c, Is_there_an_exhibit_opportunity_for_this__c, External_Tracking_Code__c, 
                      Opt_In_Process_for_Enduring_Materials__c, If_Yes_Please_Describe_Opt_In_Process__c, Will_You_be_Working_With_a_third_Party__c,Total_Overall_Budget__c,
                      Evaluation_Methodology__c, Unrestricted_Support_Request__c, Thank_You_Benifits__c, Non_Charitable_Amount__c,
                      Record_Type_Name__c, Print_Deadline__c, Print_Deadline_Date__c ,Funding_Sub_Type__c,Invite_Code__c,Multi_year_grant__c
                      FROM gFRS_Ltng_Application__c WHERE Id =: recId];
            system.debug('Application record is : '+appRec);
            return appRec;
        }
        catch(Exception e){ 
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        } 
    } 
    
    @AuraEnabled
    public static void updateTotalBudget(Integer totalOverallBgt,Id appId,String orgSupport){
        try{
            gFRS_Ltng_Application__c updateApplication = new gFRS_Ltng_Application__c();
            updateApplication.Id = appId;
            if(orgSupport!=''){
                updateApplication.Unrestricted_Support_Request__c = orgSupport;
            }
            updateApplication.Selected_Tab_Val__c = 'reqAttch';
            updateApplication.Total_Overall_Budget__c = Integer.valueOf(totalOverallBgt);
            
            gFRS_Ltng_Util_NoShare.updateGfrsAPP(updateApplication);
            
        }
        catch(Exception e){
            
            System.debug('@@@@'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }                                                
    }
    @AuraEnabled
    public static String fetchDocId(String funding,String focusarea){
        String str;
        if(funding=='Education Focused Giving K-12'||funding=='Community Giving'){
        str=[select id,DeveloperName  from Document where DeveloperName='Budget_Template_K12'].id;    
        }else if(funding=='Independent Medical Education (CME)'){
        str=[select id,DeveloperName  from Document where DeveloperName='Budget_Template_IME'].id;
        }else{
        str=[select id,DeveloperName  from Document where DeveloperName='Budget_Template'].id;
        }
        return str;
    }
    
}