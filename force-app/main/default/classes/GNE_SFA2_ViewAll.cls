public class GNE_SFA2_ViewAll{
    public String viewObjectName{get;set;}
    public String viewFieldsCSV{get;set;}
    public String viewFilter{get;set;}
    public Integer viewPageSize{get;set;}
    public Id viewParentId{get;set;}
    public String viewParentFieldName{get;set;}
    public String viewOrderByFieldName{get;set;}
    public String viewUrlForNewRecord{get;set;}
    public String viewSortDirection{get;set;}
    public Boolean viewHideButtons{get;set;}
    public Boolean viewHideEditLink{get;set;}
    public Boolean viewHideDeleteLink{get;set;}
    public String viewRelatedListLabel{get;set;}
    public GNE_SFA2_ViewAll(){
        String viewParentObjectName = ApexPages.currentPage().getParameters().get('parentObjectName');
        String viewRecordTypeName = ApexPages.currentPage().getParameters().get('parentRecordType');
        viewObjectName=ApexPages.currentPage().getParameters().get('viewObjectName');
        List<SFA2_Configuration_Object_Detail_gne__c> configurations = getUIConfigurationObjectDetails(viewParentObjectName ,viewRecordTypeName ,viewObjectName);
        System.debug('Configurations'+ configurations .get(0).Attributes_gne__c);
        GNE_SFA2_RL_Component_AttributesWrapper attributesWrapper = new GNE_SFA2_RL_Component_AttributesWrapper(configurations.get(0).Attributes_gne__c);
                            
        viewFieldsCSV=attributesWrapper.fieldsCSV;
        viewPageSize= Integer.valueOf(ApexPages.currentPage().getParameters().get('viewPageSize'));
        viewParentId = Id.valueOf(ApexPages.currentPage().getParameters().get('viewParentId'));
        viewParentFieldName = ApexPages.currentPage().getParameters().get('viewParentFieldName');
        viewOrderByFieldName = ApexPages.currentPage().getParameters().get('viewOrderByFieldName');
        viewUrlForNewRecord =ApexPages.currentPage().getParameters().get('viewUrlForNewRecord');
        viewSortDirection = ApexPages.currentPage().getParameters().get('viewSortDirection');
        viewHideEditLink = Boolean.valueOf(ApexPages.currentPage().getParameters().get('viewHideEditLink'));
        viewHideDeleteLink = Boolean.valueOf(ApexPages.currentPage().getParameters().get('viewHideDeleteLink'));
        viewRelatedListLabel= ApexPages.currentPage().getParameters().get('viewRelatedListLabel');
        viewHideButtons = Boolean.valueOf(ApexPages.currentPage().getParameters().get('viewHideButtons'));
        if (String.isNotBlank(attributesWrapper.filter)) {
            viewFilter = attributesWrapper.filter;
        }        
    }
    
    public static List<SFA2_Configuration_Object_Detail_gne__c> getUIConfigurationObjectDetails( String parentObjectName, String recordTypeName, String apiName){
            GNE_SFA2_User_App_Context_gne__c userApplicationContext = GNE_SFA2_Util.getUserApplicationContext();
            return [SELECT API_Name_gne__c, Label_gne__c, Attributes_gne__c, Is_Required_gne__c,
                            Is_Read_Only_gne__c, Order_gne__c, Type_gne__c, Style_gne__c , Availability_Mode_gne__c                                                                                      
                    FROM SFA2_Configuration_Object_Detail_gne__c
                    WHERE Type_gne__c = 'Related List'
                        AND Configuration_Object_ref_gne__r.Object_Name_gne__c =  :parentObjectName 
                        AND Configuration_Object_ref_gne__r.Role_gne__c = :userApplicationContext.Role_gne__c
                        AND Configuration_Object_ref_gne__r.Brand_gne__c = :userApplicationContext.Brand_gne__c
                        AND Configuration_Object_ref_gne__r.Application_Type__c = :userApplicationContext.App_Name_gne__c
                        AND Configuration_Object_ref_gne__r.Record_Type_gne__c = :recordTypeName
                        AND Configuration_Object_ref_gne__r.Is_Active_gne__c = true
                        AND Configuration_Object_ref_gne__r.Configuration_Type_gne__c='Page' 
                        AND Is_Active_gne__c = true and API_Name_gne__c=:apiName
                   ORDER BY Order_gne__c, API_Name_gne__c];
    }
    
    

}