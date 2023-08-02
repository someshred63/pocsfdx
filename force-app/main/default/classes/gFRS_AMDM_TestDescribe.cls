public without sharing class gFRS_AMDM_TestDescribe {
    public string xmlheader {get;set;}
    public string endfile{get;set;}
    public Set<String> getObjects {get;set;}
    public String getDescribe{get;set;}
    public String row{get;set;}
    public List<objectElementItem> objectList{get;set;}
    public List<objectFieldSetElementItem> objectFieldSetList{get;set;}
    public Attachment tmpAtt{get;set;}
    public List<validationRules> valRulesList{get;set;}
    String [] GFRSObjects = new String[]{};
    String [] GFRSObjectsField = new String[]{};
    public List<optionsForSelect> dataModelSelect{get;set;}
    public List<optionsForSelect> dataModelFieldSelect{get;set;}
    public Boolean selectAllDatModel{get;set;}
    public Boolean selectAllFieldSet{get;set;}
    public Boolean generateDataModel{get;set;}
    public Boolean generateFieldSet{get;set;}
    public Boolean generateValidationRule{get;set;}
    public Boolean generateWorkflowRule{get;set;}
    public String  fileName{get;set;}
    public List<workflowRule> workflowRules{get;set;}
    
    public gFRS_AMDM_TestDescribe(){
    	//getAvailableGFRObjects();
        //getObjects=new Set<string>{'GFRS_Funding_Request__c','GFRS_Funding_Request_Status_History__c','GFRS_Log_Entry__c','GFRS_Administrative_Budget__c','GFRS_Administrative_Budget_Line_Item__c','gFRS_Analytic_Snapshot__c','GFRS_Content__c','GFRS_Content_Translation__c','GFRS_Cost_Center_Code__c','GFRS_Funding_Allocation__c','GFRS_Funding_Allocation_Line_Item__c','GFRS_Location__c','GFRS_Organization__c','GFRS_Payment_History__c','GFRS_Program__c','GFRS_Program_Audience_Group__c','GFRS_RequestBudget__c','GFRS_Request_Budget_Line_Item__c','gFRS_Tasks__c','gFRS_Third_Party__c','GFRS_WBS_Codes__c','GFRS_WBS_Codes__c'};
        //this.objectFieldSetList=getObjectFieldSetDescribe();
        this.xmlheader ='<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?>';
        this.endfile = '</Workbook>';
        workflowRuleGenerate();
        //dataModelGenerate();
        //validationRuleGnerate();
        
    }
    public Attachment attachment {
      get {
      	  if(attachment == null){
      	  	attachment=new Attachment();
      	  }
          return attachment;
        }
      set;
    }
    public PageReference  validationRuleGnerate(){
        //String s=EncodingUtil.base64Encode(attachment.Body);
        //system.debug('test output');
        //system.debug(s);
        fileName='ValidationRules.xls';
        generateValidationRule=true;
        generateFieldSet=false;
        generateDataModel=false;
        generateWorkflowRule=false;
        
        if(attachment == null || attachment.body == null){
        	
        	Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Before file generation you have to specify xml file - with extention.object'));
        	return null;        
        }
         valRulesList=new List<validationRules>();
         Attachment at =[select Id, Name,body from Attachment where id='00PS0000001ZvSzMAK' limit 1][0];
         parse(attachment.Body.toString());
         
         PageReference redirect = new PageReference('/apex/gFRS_ADMD_ValidationRuleDescribe');
         
         return redirect.setRedirect(false);
         
        
    }
    public void  workflowRuleGenerate(){
    	fileName='WorkflowRules.xls';
    	generateValidationRule=false;
        generateFieldSet=false;
        generateDataModel=false;
        generateWorkflowRule=true;
        /*
    	if(attachment == null || attachment.body == null){
        	
        	Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Before file generation you have to specify xml file - with extention.workflow'));
        	return null;
        }
        */
        //String s=EncodingUtil.base64Encode(attachment.Body);
        //system.debug('test output');
        //system.debug(s);
         workflowRules=new List<workflowRule>();
        // valRulesList=new List<validationRules>();
         Attachment at =[select Id, Name,body from Attachment where id='00PS0000001ZzYNMA0' limit 1][0];
         parse(at.Body.toString());
         /*
         PageReference redirect = new PageReference('/apex/gFRS_ADMD_WorkflowDescribe');
         
         return redirect.setRedirect(false);
         */
         
        
    }
    public PageReference  dataModelGenerate(){
    	fileName='DataModel.xls';
    	generateValidationRule=false;
        generateFieldSet=false;
        generateDataModel=true;
        generateWorkflowRule=false;
        getObjects=new Set<String>();
        getAvailableGFRObjects();
        for(optionsForSelect item:dataModelSelect){
        	//if(item.isSelected){
        		system.debug('selected item: item.objectName');
        		getObjects.add(item.objectName);
        	//}
        }
        
        this.objectList=getObjectDescribe();
        system.debug('check file size');
        system.debug(this.objectList.size());
        PageReference redirect = new PageReference('/apex/gFRS_ADMD_ModelDescribe');
         return redirect.setRedirect(false);
    }
    public PageReference  fieldSetGenerate(){
    	fileName='FieldSets.xls';
    	generateValidationRule=false;
        generateFieldSet=true;
        generateDataModel=false;
        generateWorkflowRule=false;
        getObjects=new Set<String>();
        for(optionsForSelect item:dataModelFieldSelect){
        	if(item.isSelected){
        		getObjects.add(item.objectName);
        	}
        }
        this.objectFieldSetList=getObjectFieldSetDescribe();
        PageReference redirect = new PageReference('/apex/gFRS_ADMD_FieldSetDescribe');
        return redirect.setRedirect(false);
    }
    public PageReference changeSelectedDataModel(){
    	for(optionsForSelect item: this.dataModelSelect){
    		item.isSelected=this.selectAllDatModel;
    	}
    	return null;
    }
    public PageReference changeSelectedFieldSet(){
    	for(optionsForSelect item: this.dataModelFieldSelect){
    		item.isSelected=this.selectAllFieldSet;
    	}
    	return null;
    }
    public void parse(String toParse) {
     
      DOM.Document doc = new DOM.Document();     
      try {
        doc.load(toParse);   
        DOM.XMLNode root = doc.getRootElement();
        walkThrough(root);
      } catch (System.XMLException e) {  // invalid XML
        e.getMessage();
      }

    }
    public void walkThrough(DOM.XMLNode node) {
        system.debug('start debuging');
        system.debug(node.getName());
      if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            system.debug('was here ' +node.getNodeType());
            for (Dom.XMLNode child: node.getChildElements()) {
                 if(child.getName() == 'validationRules'){
                    system.debug('was there');
                    system.debug(child.getNodeType());
                    walkThroughElement(child);
                 }else if(child.getName() == 'rules'){
                    system.debug('was there');
                    system.debug(child.getNodeType());
                    walkThroughElement(child);
                 }
            }
            return;
      }
     
    
    }
    public void walkThroughElementExtend(DOM.XMLNode node, List<workflowAction> wfActions){
    	String typeOfAction='';
    	String actionName='';
    	for (Dom.XMLNode child: node.getChildElements()) {
	           if (child.getNodeType() == DOM.XMLNodeType.ELEMENT && child.getName() == 'name') {
	                system.debug('was here');
	                actionName=child.getText();
	           }else if (child.getNodeType() == DOM.XMLNodeType.ELEMENT && child.getName() == 'type') {
	                typeOfAction=child.getText();
	           }
	    }
	    wfActions.add(new workflowAction(typeOfAction,actionName));
    	
    }
    public void walkThroughWorflowDependent(DOM.XMLNode node, List<workflowAction> wfActions){
    	String typeOfAction='';
    	String actionName='';
    	for (Dom.XMLNode child: node.getChildElements()) {
	           if (child.getNodeType() == DOM.XMLNodeType.ELEMENT && child.getName() == 'actions') {
	                //system.debug('was here');
	                //actionName=child.getText();
	                walkThroughElementExtend(child,wfActions);
	           }
	    }
	    //wfActions.add(new workflowAction(typeOfAction,actionName));
    	
    }
    public void walkThroughElement(DOM.XMLNode node) {
        String apiName='';
        String timeDependent='';
        String name='';
        String description='';
        String isActive='';
        String errMsg='';
        String condition='';
        List<workflowAction> workflowActions=new List<workflowAction>();
        system.debug('validation was found!');
        system.debug(node.getChildElements().size());
        if(node.getName() == 'validationRules'){
	        for (Dom.XMLNode child: node.getChildElements()) {
	           if (child.getNodeType() == DOM.XMLNodeType.ELEMENT && child.getName() == 'fullName') {
	                system.debug('was here');
	                name=child.getText();
	           }else if (child.getNodeType() == DOM.XMLNodeType.ELEMENT && child.getName() == 'description') {
	                description=child.getText();
	           }else if (child.getNodeType() == DOM.XMLNodeType.ELEMENT && child.getName() == 'active') {
	                isActive=child.getText();
	           }else if (child.getNodeType() == DOM.XMLNodeType.ELEMENT && child.getName() == 'errorMessage') {
	                errMsg=child.getText();
	           }else if (child.getNodeType() == DOM.XMLNodeType.ELEMENT && child.getName() == 'errorConditionFormula') {
	                condition=child.getText();
	           }
	           
	        }
	        if(isActive=='true'){
	            valRulesList.add(new validationRules(name,description,errMsg,condition)); 
	        }
        }else if(node.getName() == 'rules'){
	        for (Dom.XMLNode child: node.getChildElements()) {
	           if (child.getNodeType() == DOM.XMLNodeType.ELEMENT && child.getName() == 'fullName') {
	                system.debug('was here');
	                
	                name=Encodingutil.urlDecode(child.getText(),'UTF-8');
	                apiName=Encodingutil.urlDecode(child.getText(),'UTF-8');
	           }else if (child.getNodeType() == DOM.XMLNodeType.ELEMENT && child.getName() == 'description') {
	                description=child.getText();
	           }else if (child.getNodeType() == DOM.XMLNodeType.ELEMENT && child.getName() == 'active') {
	                isActive=child.getText();
	           }else if(child.getNodeType() == DOM.XMLNodeType.ELEMENT && child.getName() == 'actions'){
	           		walkThroughElementExtend(child,workflowActions);
	           }else if(child.getNodeType() == DOM.XMLNodeType.ELEMENT && child.getName() == 'workflowTimeTriggers'){
	           		timeDependent='TRUE';
	           		walkThroughWorflowDependent(child,workflowActions);
	           }
	           
	        }
	        if(isActive=='true'){
	        	workflowRules.add(new workflowRule(apiName,name,description,workflowActions,timeDependent));
	        	/* Block can be uncommented if we want to displaye onlu time dependent workflows rules.
	        	Boolean containsAlert=false;
	        	for(workflowAction actionItem:workflowActions){
	        		if(actionItem.actionType.toLowerCase()=='alert'){
	        			containsAlert=true;
	        		}
	        	}
	        	if(containsAlert && timeDependent=='TRUE'){
	            	workflowRules.add(new workflowRule(apiName,name,description,workflowActions,timeDependent));
	        	}
	        	*/	 
	        }
        }
        
    }
    
    
    public List<objectElementItem> getObjectDescribe(){
        Map<String,Schema.Sobjecttype> describeObject=Schema.getGlobalDescribe();
        Integer iter=0;
        String outputData='';
        this.objectList=new List<objectElementItem>();
        for(String item:getObjects)
        {
            try{
            Schema.Sobjecttype d=describeObject.get(item);
            Map<String, Schema.SObjectField> objFieldsMap=d.getDescribe().fields.getMap();
            
            List<fieldElementItem> fieldItems=new List<fieldElementItem>();
            Integer iteration=0;
            for(Schema.SObjectField i: objFieldsMap.values()){
                Schema.DescribeFieldResult f=i.getDescribe();
                fieldItems.add(new fieldElementItem(f));
                
            }
            objectList.add(new objectElementItem(d.getDescribe().getLabel(),fieldItems));
            }catch(Exception ex){
                continue;
            }
        }
        return this.objectList;
        
    }
    
    public List<objectFieldSetElementItem> getObjectFieldSetDescribe(){
        Map<String,Schema.Sobjecttype> describeObject=Schema.getGlobalDescribe();
        Integer iter=0;
        String outputData='';
        
        this.objectFieldSetList=new List<objectFieldSetElementItem>();
        for(String item:getObjects)
        {
            try{
            Schema.Sobjecttype d=describeObject.get(item);
            Schema.DescribeSObjectResult fs =d.getDescribe();
             
            Map<String, Schema.FieldSet> objFieldsMap=fs.FieldSets.getMap();
            if(objFieldsMap.size()<1){
            	continue;
            }
            List<fielSetdElementItem> fieldItems=new List<fielSetdElementItem>();
            Integer iteration=0;
            for(Schema.FieldSet i: objFieldsMap.values()){
                
                
                
                //fielSetdElementItem el=new fielSetdElementItem();
                //List<FieldSetMember> fsMember=new List<FieldSetMember>();
                for(FieldSetMember el:i.getFields())
                {
                    
                }
                //fieldElementItem tmp=new fieldElementItem();
                //Schema.DescribeFieldResult f=i.getDescribe();
                //fieldItems.add(new fieldElementItem(f));
                fieldItems.add(new fielSetdElementItem(i.getLabel(),i.getDescription(),i.getFields()));
                
            }
            objectFieldSetList.add(new objectFieldSetElementItem(d.getDescribe().getLabel(),fieldItems));
            }catch(Exception ex){
                continue;
            }
        }
        return this.objectFieldSetList;
        
    }
    
     public String getReportHeader() {
        string ReportHeader='';
        
        ReportHeader ='<td style="background-color:#C0C0C0"><b>#</b></td>';
        ReportHeader +='<td style="background-color:#C0C0C0"><b>Element Name (label)</b></td>';
        ReportHeader +='<td style="background-color:#C0C0C0"><b>Description</b></td>';
        ReportHeader +='<td style="background-color:#C0C0C0"><b>Type</b></td>';
        ReportHeader +='<td style="background-color:#C0C0C0"><b>Size</b></td>';
        ReportHeader +='<td style="background-color:#C0C0C0"><b>Required</b></td>';
                                
        return ReportHeader;
    }
    
    public class objectElementItem{
        public string objectName{get;set;}
        public List<fieldElementItem> objectItems{get;set;}
        
        public objectElementItem(String name,List<fieldElementItem> objItems){
            objectName=name.replace('/','_').replace('\\','_').replace('?','_').replace(':','');
            objectItems=objItems;
        }
    }
    public class objectFieldSetElementItem{
        public string objectName{get;set;}
        public List<fielSetdElementItem> objectItems{get;set;}
        
        public objectFieldSetElementItem(String name,List<fielSetdElementItem> objItems){
            objectName=name.replace('/','_').replace('\\','_').replace('?','_').replace(':','');
            objectItems=objItems;
        }
    }
    
    public class fielSetdElementItem{
        public string fieldSetLabel{get;set;}
        public string fielSetDescription{get;set;}
        public List<FieldSetMember> fSetMembers{get;set;}
        public fielSetdElementItem(string fLabel,string fDescription,List<FieldSetMember> fMemebers){
            fieldSetLabel=fLabel;
            fielSetDescription=fDescription;
            fSetMembers=fMemebers;
        }
    }
    public class fieldElementItem{
        public string fieldLabel{get;set;}
        public string fielDescription{get;set;}
        public string fieldType{get;set;}
        public string fieldSize{get;set;}
        public string fielRequired{get;set;}
        public Schema.DescribeFieldResult describeField{get;set;}
        
        public fieldElementItem(Schema.DescribeFieldResult item){
            describeField=item;
            fieldLabel=item.getLabel();
            setFieldSize(describeField);
            setRequired(describeField);
            setDescription(describeField);
            setDiplayType(describeField);
        }
        public void setRequired(Schema.DescribeFieldResult f){
            Boolean out=f.isCreateable() && !f.isNillable() && !f.isDefaultedOnCreate();
            if(out){
                fielRequired='YES';
            }else{
                fielRequired='NO';
            }
        }
        public void setFieldSize(Schema.DescribeFieldResult f){
            Schema.Displaytype dType=f.getType();
            if(dType == Schema.DisplayType.STRING || dType == Schema.DisplayType.TEXTAREA ||dType == Schema.DisplayType.ENCRYPTEDSTRING){
                fieldSize=String.valueOf(f.getLength());
            }
            else{
                fieldSize='N/A';
            }
            
        }
        public void setDescription(Schema.DescribeFieldResult f){
            fielDescription=f.getInlineHelpText();
            if(fielDescription==null){
                fielDescription='N/A';
            }
        }
        public void setDiplayType(Schema.DescribeFieldResult f){
            String tmpType='';
            Schema.Displaytype dType=f.getType();
            if(dType==Schema.Displaytype.Reference){
                List<Schema.Sobjecttype> referenceList=f.getReferenceTo();
                if(referenceList!=null && referenceList.size()>0){
                    fieldType='Reference to: '+referenceList[0].getDescribe().getName(); 
                }
            }else if(dType==Schema.Displaytype.Boolean){
                fieldType='Checkbox';
            }else if(dType == Schema.DisplayType.DOUBLE || dType == Schema.DisplayType.CURRENCY|| dType == Schema.DisplayType.PERCENT){
                if(f.getCalculatedFormula()!=null && f.isCalculated()){
                    fieldType='Fromula return type: '+dType+'('+f.getPrecision()+','+f.getScale()+')';
                }else if(f.isCalculated()){
                    fieldType='Roll-Up Summary return type: '+dType+'('+f.getPrecision()+','+f.getScale()+')';
                }else{
                    fieldType=dType+'('+f.getPrecision()+','+f.getScale()+')';
                }
                //outputData +='<td>'+dType+'('+f.getPrecision()+','+f.getScale()+')'+f.isCalculated() +'|'+f.isGroupable()+'|'+f.isSortable()+'|'+f.getCalculatedFormula()+'</td>';
            }else if(dType == Schema.DisplayType.STRING && f.getCalculatedFormula()!=null){
                
                fieldType='Fromula return type:'+dType;
            }
            else{
                fieldType=''+dType;     
            }
            
                    
        }
    }
    public void getAvailableGFRObjects(){
     	List<SelectOption> options=new List<SelectOption>();
        dataModelSelect=new List<optionsForSelect>();
        dataModelFieldSelect = new List<optionsForSelect>();
    	//this.getObjects=new Set<String>();
    	Map<String,Schema.Sobjecttype> describeObject=Schema.getGlobalDescribe();
    	for(String item: describeObject.keySet()){
    		if(item.toLowerCase().contains('gfrs')){
    			//this.getObjects.add(item);
    			dataModelSelect.add(new optionsForSelect(item,false)); 
    			dataModelFieldSelect.add(new optionsForSelect(item,false));
    		}
    	}
    }
    
    
    public class validationRules{
        public String name {get;set;}
        public String description{get;set;}
        public String validationMessage{get;set;}
        public String validationCondition{get;set;}
        public validationRules(String n,String descr,string msg,string condition){
            name=n;
            description=descr;
            validationMessage=msg;
            validationCondition=condition;
        }
    }
    public class optionsForSelect{
    	public string objectName{get;set;}
    	public Boolean isSelected{get;set;}
    	public optionsForSelect(String name,Boolean selected){
    		this.objectName=name;
    		this.isSelected=selected;
    	}
    }
    
    public class workflowRule{
    	public string workflowName {get;set;}
    	public String workflowDescription{get;set;}
    	public List<workflowAction> actions{get;set;}
    	public String apiName{get;set;}
    	public String containsTimeDependentActions{get;set;}
    	public workflowRule(String apiN,String name,String description,List<workflowAction> performedActions,String dependentActions){
    		this.apiName=apiN;
    		this.workflowName=name;
    		this.workflowDescription=description;
    		this.actions=performedActions;
    		this.containsTimeDependentActions=dependentActions;
    	}
    	
    }
    public class workflowAction{
    	public string actionType{get;set;}
    	public string actionName{get;set;}
    	public workflowAction(String ation,String name){
    		this.actionType=ation;
    		this.actionName=name;
    	}
    }
    
    
    
}