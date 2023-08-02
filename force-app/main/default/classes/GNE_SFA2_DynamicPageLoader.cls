public abstract with sharing class GNE_SFA2_DynamicPageLoader {
    
    public  Map<String, List<SFA2_Configuration_Object_Detail_gne__c>> fieldSetMap {get; set;}
    public  Map<String, List<SFA2_Configuration_Object_Detail_gne__c>> relatedFieldSetMap {get; set;}
    public  List<String> fieldSetList {get; set;}
    public  Map<String, String> fieldSetHeadings {get; set;}
    public  List<String> relatedFieldSetList {get; set;}
    public  Map<String,GNE_SFA2_RL_Component_AttributesWrapper> relatedListAttributes {get; set;}
    public  Boolean isRatingsRendered { get; set; }
    public  Boolean isTerritoryRendered { get; set; }
    public  String RatingsHeading { get; set; }
    public  String TerritoryHeading { get; set; }
    public  sObject entity{get; set;}
    public  Boolean hasMultipleRecordTypes {get; set;}
    public  List<SelectOption> recordTypes {get; set;}
    private Map<String,String> recordTypeMap {get; set;}
    
    public String recordTypeId {get;set;}
    public String recordTypeName{get; set;}
    protected ApexPages.StandardController controller;
    
    public  String entityName;
    private String viewPage;
    protected String entityId;
    
    private static User currentUser = null;
    
    
    public GNE_SFA2_DynamicPageLoader(ApexPages.StandardController controller){
        this.controller = controller;
    }
    public GNE_SFA2_DynamicPageLoader(ApexPages.StandardController controller,String entityName,String viewPage){
        this.controller = controller;
        this.entityName = entityName;
        this.viewPage = viewPage;
        this.recordTypeName = 'Master';
        fieldSetMap = new Map<String, List<SFA2_Configuration_Object_Detail_gne__c>>();
        fieldSetHeadings = new Map<String, String>();
        relatedFieldSetMap = new Map<String, List<SFA2_Configuration_Object_Detail_gne__c>>();
        fieldSetList = new List<String>();
        relatedFieldSetList = new List<String>();
        recordTypes = new List<SelectOption>();
        recordTypeMap = new Map<String,String>();
        relatedListAttributes  = new Map<String,GNE_SFA2_RL_Component_AttributesWrapper>();
        isRatingsRendered = false;
        isTerritoryRendered = false;    
        RatingsHeading = null;
        TerritoryHeading = null;
        hasMultipleRecordTypes = false;
    }
    public PageReference init()
    {
        if(currentUser == null) {
                currentUser = [ SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
                system.debug('****Current User'+currentUser.Id);
        }
        List<SFA2_User_Sales_Roster_gne__c> brandRoleType = GNE_SFA2_Util.getBrandRoleAppType(currentUser.Id);
        fieldSetMap.clear();
        fieldSetHeadings.clear();
        relatedFieldSetMap.clear();
        fieldSetList.clear();
        relatedFieldSetList.clear();
        relatedListAttributes.clear();
        if (brandRoleType.size() > 0){
            List<SFA2_Configuration_Object_gne__c> layouts = new List<SFA2_Configuration_Object_gne__c>();
            try
            {
                if(recordTypeId == null)
                {
                    entityId = ApexPages.currentPage().getParameters().get('id');
                    if(entityId != null) 
                    {
                         // Make your dynamic call
                        entity= Database.query('SELECT RecordTypeId FROM ' + entityName + ' WHERE id = \'' + entityId + '\' LIMIT 1 ');
                        if (entity != null){
                            recordTypeId = (String)entity.get('RecordTypeId');
                            if (recordTypeId != null)
                            {
                                recordTypeName = [Select Name from RecordType where id = :recordTypeId].Name;
                            }
                            else 
                            {
                                recordTypeName = recordTypeName;
                            }
                        }
                    }
                    else
                    {                   
                        Schema.DescribeSObjectResult dsr = Schema.getGlobalDescribe().get(entityName).getDescribe();
                        Schema.RecordTypeInfo defaultRecordType;
                        for(Schema.RecordTypeInfo rti : dsr.getRecordTypeInfos()) {
                            if(rti.isAvailable()&&(rti.getName() != 'Master')){
                                recordTypes.add(new SelectOption(rti.getRecordTypeId(),rti.getName()));
                                recordTypeMap.put(rti.getRecordTypeId(),rti.getName());
                                recordTypeId = rti.getRecordTypeId();
                                recordTypeName=rti.getName();
                            }
                        }
                        hasMultipleRecordTypes = recordTypes.size() > 1;
                    }
                }
                else if(recordTypeMap.containsKey(recordTypeId)){
                    recordTypeName = recordTypeMap.get(recordTypeId);
                }
                layouts = [
                        Select
                          Id, Name,Role_gne__c, External_ID_gne__c, Object_Name_gne__c, Section_Header_gne__c, Record_Type_gne__c , Brand_gne__c, Is_Active_gne__c, Order_gne__c, Style_gne__c, 
                          (Select Name, API_Name_gne__c, Label_gne__c, Attributes_gne__c, Is_Read_Only_gne__c, Is_Required_gne__c, Order_gne__c, Style_gne__c,
                          Type_gne__c from Configuration_Objects__r 
                          where Is_Active_gne__c =: true order by Order_gne__c )
                        From
                          SFA2_Configuration_Object_gne__c
                       where Object_Name_gne__c =: entityName  and Role_gne__c =:brandRoleType[0].role_gne__c
                       and Brand_gne__c =:brandRoleType[0].Sales_Roster_gne__r.Brand_Name_gne__c
                       and Record_Type_gne__c=: recordTypeName and Is_Active_gne__c =: true order by Order_gne__c];
                System.debug('Layout8181'+layouts);
                String theQuery = 'SELECT ';
                if(entityName == 'Account') {
                    theQuery += 'isPersonAccount,';
                }           
                for(SFA2_Configuration_Object_gne__c layout : layouts){
                    String key =layout.Id;
                    fieldSetHeadings.put(key, layout.Section_Header_gne__c);
                    for (SFA2_Configuration_Object_Detail_gne__c layoutDetails: layout.Configuration_Objects__r) {
                        if(layoutDetails.Type_gne__c == 'Field' || layoutDetails.Type_gne__c == 'Blank Space') {
                            if(!fieldSetMap.containsKey(key)) {
                                fieldSetList.add(key);
                                fieldSetMap.put(key, new List<SFA2_Configuration_Object_Detail_gne__c>());
                            }
                            fieldSetMap.get(key).add(layoutDetails);
                            if(layoutDetails.Type_gne__c == 'Field'){
                                theQuery += layoutDetails.API_Name_gne__c+ ',';
                            }                       
                        }
                        else if(layoutDetails.Type_gne__c == 'Related List') {
                            if(!relatedFieldSetMap.containsKey(key)) {
                                relatedFieldSetList.add(key);
                                relatedFieldSetMap.put(key, new List<SFA2_Configuration_Object_Detail_gne__c>());
                            }
                            relatedFieldSetMap.get(key).add(layoutDetails);
                            GNE_SFA2_RL_Component_AttributesWrapper attributesWrapper = new GNE_SFA2_RL_Component_AttributesWrapper(layoutDetails.Attributes_gne__c);                      
                            relatedListAttributes.put(layoutDetails.API_Name_gne__c,attributesWrapper );
                        }
                        else if(layoutDetails.Type_gne__c == 'VF Page') {
                            if(layoutDetails.API_Name_gne__c == 'GNE_SFA2_Ratings_Layout'){
                                isRatingsRendered = true;
                                RatingsHeading = layout.Section_Header_gne__c;
                            }
                            else if(layoutDetails.API_Name_gne__c == 'GNE_SFA2_Territory_Alignment_Layout') {
                                isTerritoryRendered = true;
                                TerritoryHeading = layout.Section_Header_gne__c;
                            }    
                        } 
                    }
                }
                if(entityId != null) {
                    theQuery = theQuery.subString(0, theQuery.length() - 1);
                    theQuery += ' FROM ' + entityName  + ' WHERE id = \'' + entityId + '\' LIMIT 1 ';
                    System.debug('The query'+theQuery);
                    entity= Database.query(theQuery);
                }
                else{
                    entity = newSObject(entityName);
                }
            }    
            catch (Sobjectexception ex) {
               System.debug('Error ' + ex);
            }
        }
        return null;
    }
  
    private SObject newSObject(String typeName) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
        return targetType.newSObject();
    }

    public void onChange(){
        init();
    }
    
    public void setRecordTypeName(String recordId){
        
    }
   
    protected Component.Apex.PageBlockButtons getActiveCustomButtons(String pageName,String recordTypeName) {
       
        if(currentUser == null) {
                currentUser = [ SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        }
        
        List<SFA2_User_Sales_Roster_gne__c> brandRoleType =  GNE_SFA2_Util.getBrandRoleAppType(currentUser.Id);
        
        List<SFA2_Configuration_Object_Detail_gne__c> buttonConfigurations = [SELECT API_Name_gne__c,
                                                     Label_gne__c,
                                                     Attributes_gne__c,
                                                     Is_Required_gne__c,
                                                     Is_Read_Only_gne__c,
                                                     Order_gne__c, 
                                                     Type_gne__c, 
                                                     Style_gne__c                                                                                     
                                                     FROM SFA2_Configuration_Object_Detail_gne__c
                                              WHERE Type_gne__c = : 'Button'
                                              AND Configuration_Object_ref_gne__r.Object_Name_gne__c = :pageName
                                                AND Configuration_Object_ref_gne__r.Role_gne__c =:brandRoleType[0].role_gne__c
                                                AND Configuration_Object_ref_gne__r.Brand_gne__c =:
                                                brandRoleType[0].Sales_Roster_gne__r.Brand_Name_gne__c
                                                and Configuration_Object_ref_gne__r.Record_Type_gne__c =: recordTypeName
                                                AND Configuration_Object_ref_gne__r.Is_Active_gne__c = true
                                                AND Is_Active_gne__c = true order by Order_gne__c];
        Component.Apex.PageBlockButtons dynamicPageBlockButtons = new Component.Apex.PageBlockButtons();
        dynamicPageBlockButtons.location = 'top';
        
        if(buttonConfigurations != null){
            for(SFA2_Configuration_Object_Detail_gne__c buttonConfiguration : buttonConfigurations) {
               Component.Apex.CommandButton dynamicButton = new Component.Apex.CommandButton();
               
               dynamicButton.value = buttonConfiguration.Label_gne__c;
               dynamicButton.disabled = buttonConfiguration.Is_Read_Only_gne__c;
               if(buttonConfiguration.Attributes_gne__c!=null && buttonConfiguration.Attributes_gne__c.contains('action')){
                    System.debug('===========<<<BTN ACTN>>>>============'+buttonConfiguration.Attributes_gne__c);
                    dynamicButton.expressions.action = '{!'+buttonConfiguration.Attributes_gne__c.substringBetween('action=',';')+'}';
               }
               if(buttonConfiguration.Attributes_gne__c!=null && buttonConfiguration.Attributes_gne__c.contains('onclick')){
                    dynamicButton.onclick = buttonConfiguration.Attributes_gne__c.substringBetween('onclick=',';');
               }
               if(buttonConfiguration.Attributes_gne__c!=null && buttonConfiguration.Attributes_gne__c.contains('rerender')){
                    dynamicButton.rerender = new Set<String>(buttonConfiguration.Attributes_gne__c.substringBetween('rerender=',';').split(','));
               }
               if(buttonConfiguration.Attributes_gne__c!=null && buttonConfiguration.Attributes_gne__c.contains('immediate')){
                    System.debug('======immediate====>>>:'+buttonConfiguration.Attributes_gne__c.substringBetween('immediate=',';'));
                    if(buttonConfiguration.Attributes_gne__c!=null && buttonConfiguration.Attributes_gne__c.substringBetween('immediate=',';') == 'true'){
                        System.debug('setting immediate to true');
                        dynamicButton.immediate = true;
                    } else {
                        System.debug('setting immediate to false');
                        dynamicButton.immediate = false;
                    }
                    
               }
               System.debug('dynamic button: '+dynamicButton);
               dynamicPageBlockButtons.childComponents.add(dynamicButton);
            }
        }
        return dynamicPageBlockButtons;
    }
    
    public Component.Apex.PageBlockButtons getCustomButtons(){
        return getActiveCustomButtons(entityName,recordTypeName);
    }
    
    
    public PageReference save() {
        pagereference pageref; 
        try{
            upsert entity;
            String viewURL = viewPage + '?id='+entity.Id;
            pageref = new pagereference(viewURL);
        }
        catch(Exception e){
        return null;
        }
        pageref.setredirect(true);
        return pageref;
    }
    
     public PageReference cancel() {
        String viewURL = viewPage + '?id='+entityId;
        pagereference pageref = new pagereference(viewURL);
        pageref.setredirect(true);
        return pageref;
    }
    

      

}