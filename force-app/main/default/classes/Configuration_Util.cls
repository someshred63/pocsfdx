public without sharing class Configuration_Util { 

    public static String createInListForQuery(Set<Id> ids){
        if (ids==null || ids.isEmpty()){
            return '(\'\')';
        }else{
            String queryList='(';
            for(Id tkdId: ids){
                queryList+='\''+tkdId+'\', ';
            }
            queryList = queryList.subString(0,queryList.Length()-2);
            queryList+=')';
            return queryList;
        }
    }
    
    /*
    *Methods create string "('id1', 'id2')" base on argument.
    */  
    public static String createInListForQuery(List<Id> ids){
        if (ids==null || ids.isEmpty()){
            return '(\'\')';
        }else{
            String queryList='(';
            for(Id tkdId: ids){
                queryList+='\''+tkdId+'\', ';
            }
            queryList = queryList.subString(0,queryList.Length()-2);
            queryList+=')';
            return queryList;
        }
    }
    
   /*
    *Methods create string "('string1', 'string2')" base on argument.
    */  
    public static String createInListForQuery(List<String> expressions){
        if (expressions==null || expressions.isEmpty()){
            return '(\'\')';
        }else{
            String queryList='(';
            for(String expression: expressions){
                queryList+='\''+String.escapeSingleQuotes(expression).escapeEcmaScript() +'\', ';
            }
            queryList = queryList.subString(0,queryList.Length()-2);
            queryList+=')';
            return queryList;
        }
    }
    
    /**
    *   Methods create string "('string1', 'string2')" base on argument.
    */  
    public static String createInListForQueryNotEscaping(List<String> expressions){
        if (expressions==null || expressions.isEmpty()){
            return '(\'\')';
        }else{
            String queryList='(';
            for(String expression: expressions){
                if(expression.contains('\'')) {
                    expression = expression.replace('\'', '\\'+'\'');
                    queryList+='\''+expression+'\', ';
                }else{
                    queryList+='\''+expression+'\', ';
                }
            }
            queryList = queryList.subString(0,queryList.Length()-2);
            queryList+=')';
            return queryList;
        }
    }
    
     public static void sortList(List<Sobject> items, String sortField, Boolean sortAscending){
       List<Sobject> resultList = new List<Sobject>();
        //Create a map that can be used for sorting 
       Map<object, List<Sobject>> objectMap = new Map<object, List<Sobject>>();
       for(Sobject ob : items){
                if(objectMap.get(ob.get(sortField)) == null){  // For non Sobject use obj.ProperyName
                    objectMap.put(ob.get(sortField), new List<Sobject>()); 
                }
                objectMap.get(ob.get(sortField)).add(ob);
        }       
        //Sort the keys
        List<object> keys = new List<object>(objectMap.keySet());
        keys.sort();
       
        for(object key : keys){ 
            resultList.addAll(objectMap.get(key)); 
        }
       
        //Apply the sorted values to the source list
        items.clear();
        if(sortAscending){
            for(Sobject ob : resultList){
                items.add(ob); 
            }
        }else{
            for(integer i = resultList.size()-1; i >= 0; i--){
                items.add(resultList[i]);  
            }
        }
    }
    
    //  This is a simple quicksort algorithm to sort a SelectOption list (dropdown) by label alphabetically. Select option with --None-- label option is set on 1 place.    
    public static List<SelectOption> sortOptionList(List<SelectOption> listToSort)  {
        if(listToSort == null || listToSort.size() <= 1) {
            return listToSort;                  
        }
        
        List<SelectOption> less = new List<SelectOption>();     
        List<SelectOption> greater = new List<SelectOption>();  
            
        Integer pivot = 0;              
        // save the pivot and remove it from the list       
        SelectOption pivotValue = listToSort[pivot];        
        listToSort.remove(pivot);               
        for(SelectOption x : listToSort) {          
            if(x.getLabel().toLowerCase().compareTo(pivotValue.getLabel().toLowerCase()) <= 0) {
                less.add(x);
            } else if(x.getLabel().toLowerCase().compareTo(pivotValue.getLabel().toLowerCase()) > 0) {
                greater.add(x);
            }   
        }       
        List<SelectOption> returnList = new List<SelectOption> ();      
        returnList.addAll(sortOptionList(less));
        returnList.add(pivotValue); 
        returnList.addAll(sortOptionList(greater));
        
        SelectOption noneOption = null;         
        for(Integer i = 0; i< returnList.size(); i++){
            if(returnList.get(i).getLabel()=='--None--'){
                noneOption = returnList.remove(i);  
            }
        }
        if(noneOption != null){
            returnList.add(0, noneOption);
        }
        return returnList; 
    }

    public static List<SFA2_Configuration_Object_Detail_gne__c> getUIComponentsConfiguration(String pageName, String configurationType, String componentType){
        
        /*String sBrandname, sRole;
        
        List<SFA2_User_Sales_Roster_gne__c> userSalesRosters = getUserSalesRosters(UserInfo.getUserId());
        sBrandname = getUserBrandName(userSalesRosters);
        if (userSalesRosters != null && userSalesRosters.size() > 0){
            sRole = userSalesRosters[0].Role_gne__c;
        }*/
      
        GNE_SFA2_User_App_Context_gne__c userContext = GNE_SFA2_Util.getUserApplicationContext();
        
        System.debug('****component type**' + componentType +'**obj name' +pageName+'**app*'+userContext.App_Name_gne__c+'**role*'+userContext.Role_gne__c+'**brand*'+userContext.Brand_gne__c+'**config type*'+configurationType);             
        
        List<SFA2_Configuration_Object_Detail_gne__c> result = [
                SELECT API_Name_gne__c,
                        Label_gne__c,
                        Attributes_gne__c,
                        Is_Required_gne__c,
                        Is_Read_Only_gne__c,
                        Order_gne__c,
                        Type_gne__c,
                        Style_gne__c
                FROM SFA2_Configuration_Object_Detail_gne__c
                WHERE Type_gne__c = :componentType
                AND Configuration_Object_ref_gne__r.Object_Name_gne__c = :pageName
                AND Configuration_Object_ref_gne__r.Application_Type__c =:userContext.App_Name_gne__c
                AND Configuration_Object_ref_gne__r.Role_gne__c =:userContext.Role_gne__c
                AND Configuration_Object_ref_gne__r.Brand_gne__c =:userContext.Brand_gne__c
                AND Configuration_Object_ref_gne__r.Is_Active_gne__c = true
                AND Configuration_Object_ref_gne__r.Configuration_Type_gne__c = :configurationType
                AND Is_Active_gne__c = true order by Order_gne__c
        ];
    
        return result;
    }
    
    
    // method for dynamic button rendering basing on button configuration record(s)
    public static Component.Apex.PageBlockButtons getCustomButtons(String pageName, String configurationType, String componentType) {
        List<SFA2_Configuration_Object_Detail_gne__c> buttonConfigurations = getUIComponentsConfiguration(pageName, configurationType, componentType);
        
        Component.Apex.PageBlockButtons dynamicPageBlockButtons = new Component.Apex.PageBlockButtons();
        
        
        if(buttonConfigurations != null && buttonConfigurations.size() >= 0){
            for(SFA2_Configuration_Object_Detail_gne__c buttonConfiguration : buttonConfigurations) {
               Component.Apex.CommandButton dynamicButton = new Component.Apex.CommandButton();
               
               dynamicButton.value = buttonConfiguration.Label_gne__c;
               dynamicButton.disabled = buttonConfiguration.Is_Read_Only_gne__c;
               if(buttonConfiguration.Attributes_gne__c!=null && buttonConfiguration.Attributes_gne__c.contains('action')){
                    dynamicButton.expressions.action = '{!'+buttonConfiguration.Attributes_gne__c.substringBetween('action=',';')+'}';
                    System.debug( '****actionin***'+'{!'+buttonConfiguration.Attributes_gne__c.substringBetween('action=',';')+'}');
                    System.debug('**action***'+dynamicButton.expressions.action);
               }
               if(buttonConfiguration.Attributes_gne__c!=null && buttonConfiguration.Attributes_gne__c.contains('styleClass')){
                    dynamicButton.styleClass = buttonConfiguration.Attributes_gne__c.substringBetween('styleClass=',';');
               }
               if(buttonConfiguration.Attributes_gne__c!=null && buttonConfiguration.Attributes_gne__c.contains('dir')){
                    dynamicButton.dir = buttonConfiguration.Attributes_gne__c.substringBetween('dir=',';');
               }
               if(buttonConfiguration.Attributes_gne__c!=null && buttonConfiguration.Attributes_gne__c.contains('onclick')){
                    dynamicButton.onclick = buttonConfiguration.Attributes_gne__c.substringBetween('onclick=',';');
               }
               if(buttonConfiguration.Attributes_gne__c!=null && buttonConfiguration.Attributes_gne__c.contains('rerender')){
                    dynamicButton.rerender = new Set<String>(buttonConfiguration.Attributes_gne__c.substringBetween('rerender=',';').split(','));
               }
               if(buttonConfiguration.Attributes_gne__c!=null && buttonConfiguration.Attributes_gne__c.contains('immediate')){
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
        dynamicPageBlockButtons.location = 'top';
        return dynamicPageBlockButtons;
    }

    // method for dynamic button rendering basing on button configuration record(s)
    public static Component.Apex.OutputPanel getCustomButtonsOutputPanel(String controllerName, String pageName, String configurationType, String componentType) {
        List<SFA2_Configuration_Object_Detail_gne__c> buttonConfigurations = getUIComponentsConfiguration(pageName, configurationType, componentType);
        
        Component.Apex.OutputPanel dynamicOutputPanel = new Component.Apex.OutputPanel();
        
        if(buttonConfigurations != null && buttonConfigurations.size() >= 0){
            for(SFA2_Configuration_Object_Detail_gne__c buttonConfiguration : buttonConfigurations) {
               Component.Apex.CommandButton dynamicButton = new Component.Apex.CommandButton();
               
               dynamicButton.value = buttonConfiguration.Label_gne__c;
               dynamicButton.disabled = buttonConfiguration.Is_Read_Only_gne__c;
               if(buttonConfiguration.Attributes_gne__c!=null && buttonConfiguration.Attributes_gne__c.contains('action')){
                    dynamicButton.expressions.action = '{!'+controllerName+'.'+buttonConfiguration.Attributes_gne__c.substringBetween('action=',';')+'}';
                    System.debug( '****actionin***'+'{!'+controllerName+'.'+buttonConfiguration.Attributes_gne__c.substringBetween('action=',';')+'}');
                    System.debug('**action***'+dynamicButton.expressions.action);
               }
               if(buttonConfiguration.Attributes_gne__c!=null && buttonConfiguration.Attributes_gne__c.contains('styleClass')){
                    dynamicButton.styleClass = buttonConfiguration.Attributes_gne__c.substringBetween('styleClass=',';');
               }
               if(buttonConfiguration.Attributes_gne__c!=null && buttonConfiguration.Attributes_gne__c.contains('dir')){
                    dynamicButton.dir = buttonConfiguration.Attributes_gne__c.substringBetween('dir=',';');
               }
               if(buttonConfiguration.Attributes_gne__c!=null && buttonConfiguration.Attributes_gne__c.contains('onclick')){
                    dynamicButton.onclick = buttonConfiguration.Attributes_gne__c.substringBetween('onclick=',';');
               }
               if(buttonConfiguration.Attributes_gne__c!=null && buttonConfiguration.Attributes_gne__c.contains('rerender')){
                    dynamicButton.rerender = new Set<String>(buttonConfiguration.Attributes_gne__c.substringBetween('rerender=',';').split(','));
               }
               if(buttonConfiguration.Attributes_gne__c!=null && buttonConfiguration.Attributes_gne__c.contains('immediate')){
                    if(buttonConfiguration.Attributes_gne__c!=null && buttonConfiguration.Attributes_gne__c.substringBetween('immediate=',';') == 'true'){
                        System.debug('setting immediate to true');
                        dynamicButton.immediate = true;
                    } else {
                        System.debug('setting immediate to false');
                        dynamicButton.immediate = false;
                    }
                    
               }
               System.debug('dynamic button: '+dynamicButton);
               dynamicOutputPanel.childComponents.add(dynamicButton);
            }
        }
        dynamicOutputPanel.layout = 'none';
        return dynamicOutputPanel;
    }

    // method for dynamic button rendering basing on button configuration record(s)
    public static Component.Apex.OutputPanel getCustomBootstrapButtonsOutputPanel(String controllerName, String pageName, String configurationType, String componentType) {
        List<SFA2_Configuration_Object_Detail_gne__c> buttonConfigurations = getUIComponentsConfiguration(pageName, configurationType, componentType);

        Component.Apex.OutputPanel dynamicOutputPanel = new Component.Apex.OutputPanel();

        if(buttonConfigurations != null && buttonConfigurations.size() >= 0){
            for(SFA2_Configuration_Object_Detail_gne__c buttonConfiguration : buttonConfigurations) {
                Component.Apex.CommandLink dynamicButton = new Component.Apex.CommandLink();

                dynamicButton.value = buttonConfiguration.Label_gne__c;
                if(buttonConfiguration.Attributes_gne__c!=null && buttonConfiguration.Attributes_gne__c.contains('action')){
                    dynamicButton.expressions.action = '{!'+controllerName+'.'+buttonConfiguration.Attributes_gne__c.substringBetween('action=',';')+'}';
                }
                if(buttonConfiguration.Attributes_gne__c!=null && buttonConfiguration.Attributes_gne__c.contains('styleClass')){
                    dynamicButton.styleClass = buttonConfiguration.Attributes_gne__c.substringBetween('styleClass=',';');
                }
                if (buttonConfiguration.Is_Read_Only_gne__c) {
                    // works only with Bootstrap
                    dynamicButton.styleClass += ' disabled';
                }
                if(buttonConfiguration.Attributes_gne__c!=null && buttonConfiguration.Attributes_gne__c.contains('dir')){
                    dynamicButton.dir = buttonConfiguration.Attributes_gne__c.substringBetween('dir=',';');
                }
                if(buttonConfiguration.Attributes_gne__c!=null && buttonConfiguration.Attributes_gne__c.contains('onclick')){
                    dynamicButton.onclick = buttonConfiguration.Attributes_gne__c.substringBetween('onclick=',';');
                }
                if(buttonConfiguration.Attributes_gne__c!=null && buttonConfiguration.Attributes_gne__c.contains('rerender')){
                    dynamicButton.rerender = new Set<String>(buttonConfiguration.Attributes_gne__c.substringBetween('rerender=',';').split(','));
                }
                if(buttonConfiguration.Attributes_gne__c!=null && buttonConfiguration.Attributes_gne__c.contains('immediate')){
                    if(buttonConfiguration.Attributes_gne__c!=null && buttonConfiguration.Attributes_gne__c.substringBetween('immediate=',';') == 'true'){
                        dynamicButton.immediate = true;
                    } else {
                        dynamicButton.immediate = false;
                    }

                }
                dynamicOutputPanel.childComponents.add(dynamicButton);
            }
        }
        dynamicOutputPanel.layout = 'none';
        return dynamicOutputPanel;
    }
   
    public static SFA2_Configuration_Object_gne__c getListPageConfiguration(String objectName) {
    	
    	GNE_SFA2_User_App_Context_gne__c userContext = GNE_SFA2_Util.getUserApplicationContext();
    	
        List<SFA2_Configuration_Object_gne__c>  config = [ SELECT Name, Attributes_gne__c, Section_Header_gne__c FROM SFA2_Configuration_Object_gne__c
                                              WHERE Configuration_Type_gne__c = 'List Page' AND Is_Active_gne__c = true AND Application_Type__c = :userContext.App_Name_gne__c
                							  AND Role_gne__c = :userContext.Role_gne__c AND Brand_gne__c = :userContext.Brand_gne__c
                                              AND Object_Name_gne__c = :objectName ORDER BY Name LIMIT 1 ];
        
        if(config != null && config.size() > 0){
            return config[0];       
        } else {
            return null;
        }
    }
     
    public static PageReference redirectToErrorPage(String errorMessage, String currentURL, String developerMessage) {
    	PageReference pageref = Page.GNE_SFA2_Exception_Layout;
        pageref.setredirect(true);
        pageref.getParameters().put('exMessage', errorMessage);
        pageref.getParameters().put('exUrl', currentURL);
        pageref.getParameters().put('developerMessage', developerMessage);
        return pageref;
    }
}