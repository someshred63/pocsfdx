public class GNE_SFA2_ConfigSetup_Controller{
    
    public String objectName{get;set;}
    public String objectLabel{get;set;}
    public String brandName{get;set;}
    public String usrRole{get;set;}
    public String selRecTypName{get;set;}
    public String layout_fields{get;set;} 
    public String relatedLists{get;set;} 
    public List<List<String>> layoutFields{get;set;}
    public List<List<String>> relFields{get;set;} 
    
    public GNE_SFA2_ConfigSetup_Controller(){
        
    }
    
    public List <SelectOption> recordTypeOptionList{get;set;} 
    public PageReference getRecordTypes(){
      if(objectName!=null && objectName!=''){
        Schema.Describesobjectresult objDesc=Schema.getGlobalDescribe().get(objectName).getDescribe();
        List<SelectOption> recOptionList = new List<SelectOption>();
        recOptionList.add(new SelectOption('Select','--Select--'));
        for(Schema.RecordTypeInfo recTyp:objDesc.getRecordTypeInfos()){
            recOptionList.add(new SelectOption(recTyp.getRecordTypeId()+'_'+recTyp.getName(),recTyp.getName()));
        }
        recordTypeOptionList=recOptionList;
      }
      objectName=objectName;
      return null;
    }
     
   
    
    List<List<String>> lytFields=new List<List<String>>();  
    List<List<String>> rlFields=new List<List<String>>();
    public PageReference getPageLayoutData() {
        layoutFields=new List<List<String>>();
        System.debug('======layout_fields======='+layout_fields);
        if(layout_fields!=null && layout_fields!=''){
            String[] sectionsArry=layout_fields.split('#');
            for(String strSection:sectionsArry){
                List<String> sectionfields=new List<String>();
                if(strSection!=null){
                    String[] fieldsArry=strSection.split('~');
                    if(fieldsArry!=null){
                        for(String strField:fieldsArry){
                            if(strField!=null && strField!=':null'){
                                sectionfields.add(strField);
                            }
                        }
                    }
                    lytFields.add(sectionfields);
                }
                System.debug('======lytFields======='+lytFields);
                layoutFields=lytFields;
            }
        }
        lytFields=new List<List<String>>();
        
     
        if(relatedLists!=null && relatedLists!=''){
            String[] sectionsArry=relatedLists.split('#');
            for(String strSection:sectionsArry){
                List<String> sectionfields=new List<String>();
                if(strSection!=null){
                    String[] fieldsArry=strSection.split(';');
                    if(fieldsArry!=null){
                        for(String strField:fieldsArry){
                            if(strField!=null && strField!='null'){
                                sectionfields.add(strField);
                            }
                        }
                    }
                    rlFields.add(sectionfields);
                }
                System.debug('======rlFields======='+rlFields);
                relFields=rlFields;
            }
        }
        rlFields=new List<List<String>>();
        
     return null;
    }      
    
    
    public PageReference  setupConfigLayoutData(){
      if(brandName!=null && brandName!=''){
       String[] brandNamesArray=brandName.split(';');
       for(String brName:brandNamesArray){
           if(usrRole!=null && usrRole!=''){
               String[] usrRoleArray=usrRole.split(';');
               for(String urole:usrRoleArray){
                   setupConfigData(brName,urole);
                   setupRelatedListsData(brName,urole);
               }
           }
       }
      }
      return null;
    }
    
    public void setupConfigData(String brName,String urole){
      
       if(layoutFields!=null && layoutFields.size()>0){
           integer i=1;
           for(List<String> section:layoutFields){ 
                SFA2_Configuration_Object_gne__c config_obj=new SFA2_Configuration_Object_gne__c();
                config_obj.Name=objectLabel+'Detail';
                config_obj.Application_Type__c='SFA';
                //config_obj.Attributes_gne__c
                config_obj.Brand_gne__c=brName;
                config_obj.Configuration_Type_gne__c='Page';
                config_obj.External_ID_gne__c=objectName+'_'+selRecTypName.split('_')[1]+'_'+objectLabel+'Detail_'+i+'_'+brandName+'_'+usrRole;
                config_obj.Is_Active_gne__c=true;
                config_obj.Object_Name_gne__c=objectName;
                config_obj.Order_gne__c=i;
                config_obj.Record_Type_gne__c=selRecTypName.split('_')[1];
                config_obj.Role_gne__c=urole;
                config_obj.Section_Header_gne__c=section.get(0).split(',')[0];
                config_obj.Style_gne__c='';
                
                Database.insert(config_obj);
                i++;
                setupConfigDetailData(section,config_obj);
           }//main for
       }//main if
    }  
    
    public void setupConfigDetailData(List<String> section,SFA2_Configuration_Object_gne__c config_obj){
        List<SFA2_Configuration_Object_Detail_gne__c> configdtllist=new List<SFA2_Configuration_Object_Detail_gne__c>();
        integer k=1;
        for(String configdtl:section){
            if(configdtl!=null && configdtl!='' && section.get(0).split(',')[0]!=configdtl){
                boolean iseditable=false;boolean isrequired=false;
                String lblname=configdtl.split(':')[0];
                String apiname=configdtl.split(':')[1];
                String taborder=configdtl.split(':')[2];
                String editable=configdtl.split(':')[3];
                String required=configdtl.split(':')[4];
                if(editable!=null && editable!='' && editable=='true'){ iseditable=true; }
                if(required!=null && required!='' && required=='true'){ isrequired=true; }
                
                SFA2_Configuration_Object_Detail_gne__c configdetail=new SFA2_Configuration_Object_Detail_gne__c();
                configdetail.Name=section.get(0).split(',')[0];
                if(apiname!=null && apiname!='' && apiname=='undefined' && lblname!=null && lblname=='Created By'){
                    apiname='CreatedById';
                }
                if(apiname!=null && apiname!='' && apiname=='undefined' && lblname!=null && lblname=='Last Modified By'){
                    apiname='LastModifiedById';
                }
                configdetail.Type_gne__c='Field';
                configdetail.Label_gne__c=lblname;
                configdetail.API_Name_gne__c=apiname;
                configdetail.Configuration_Object_ref_gne__c=config_obj.Id;
                configdetail.Is_Active_gne__c=true;
                configdetail.Is_Read_Only_gne__c=iseditable;
                configdetail.Is_Required_gne__c=isrequired;
                configdetail.Order_gne__c=k;
                //configdetail.Style_gne__c=
                //configdetail.Attributes_gne__c=
                
                if(apiname!=null && apiname!='' && apiname!='null'){
                    configdtllist.add(configdetail);
                    k++;
                } 
            }
        } 
        Database.insert(configdtllist,true);
        System.debug('====<<<Layout>>>====='+configdtllist);
    }     
    
    public void setupRelatedListsData(String brName,String urole){
         if(relFields!=null && relFields.size()>0){
            List<String> rl_list=new List<String>();
            Integer i=1;
            for(List<String> rlData:relFields){
                //rl_list.add(rlData.split(';')[0]);
                SFA2_Configuration_Object_gne__c config_obj=new SFA2_Configuration_Object_gne__c();
                config_obj.Name=objectLabel+'RelatedLists';
                config_obj.Application_Type__c='SFA';
                //config_obj.Attributes_gne__c
                config_obj.Brand_gne__c=brName;
                config_obj.Configuration_Type_gne__c='Page';
                config_obj.External_ID_gne__c=objectName+'_'+selRecTypName.split('_')[1]+'_'+objectLabel+'RelatedLists_'+i+'_'+brandName+'_'+usrRole;
                config_obj.Is_Active_gne__c=true;
                config_obj.Object_Name_gne__c=objectName;
                config_obj.Order_gne__c=i;
                config_obj.Record_Type_gne__c=selRecTypName.split('_')[1];
                config_obj.Role_gne__c=urole;
                config_obj.Section_Header_gne__c=rlData.get(0).split(';')[0];
                config_obj.Style_gne__c='';
                
                Database.insert(config_obj);
                i++;
                setupRelatedListsDetailsData(rlData,config_obj);
            }
        }
    }
    public void setupRelatedListsDetailsData(List<String> section,SFA2_Configuration_Object_gne__c config_obj){
        List<SFA2_Configuration_Object_Detail_gne__c> configdtllist=new List<SFA2_Configuration_Object_Detail_gne__c>();
        integer k=1;
        for(String configdtl:section){
            if(configdtl!=null && configdtl!='' && section.get(0).split(',')[0]!=configdtl){
                String lblname=configdtl.split(':')[0];
                String apiname=configdtl.split(':')[1];
                SFA2_Configuration_Object_Detail_gne__c configdetail=new SFA2_Configuration_Object_Detail_gne__c();
                configdetail.Name=section.get(0).split(',')[0];
                configdetail.Type_gne__c='Field';
                configdetail.Label_gne__c=lblname;
                configdetail.API_Name_gne__c=apiname;
                configdetail.Configuration_Object_ref_gne__c=config_obj.Id;
                configdetail.Is_Active_gne__c=true;
                //configdetail.Is_Read_Only_gne__c=iseditable;
                //configdetail.Is_Required_gne__c=isrequired;
                configdetail.Order_gne__c=k;
                //configdetail.Style_gne__c=
                //configdetail.Attributes_gne__c=
                
                if(apiname!=null && apiname!='' && apiname!='null'){
                    configdtllist.add(configdetail);
                    k++;
                } 
            }
        } 
        System.debug('====<<RelatedList>>>====='+configdtllist);
        Database.insert(configdtllist,true);
    }
    
    public void setupButtonConfig(){
    
    
    }
    

}