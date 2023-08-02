public class gFRS_Ltng_ThirdPartyViewController {
    
    @AuraEnabled
    Public static List<gFRS_Ltng_Third_Party__c> getThirdpartyData(Id applicationId){
        List<gFRS_Ltng_Third_Party__c> thrdPartyList = [SELECT Id,Name,Third_party_Organization_Name__c,Third_Party_Contact_First_Name__c,Third_Party_Contact_Last_Name__c
                                                        FROM gFRS_Ltng_Third_Party__c Where gFRS_Application__c=:applicationId];
        return thrdPartyList;
    }
    
    
    //Wrapper Class For Program DataTable  
    public class thirdPartyDataTableWrapper {
        @AuraEnabled
        public Integer pageSize {get;set;}
        @AuraEnabled
        public Integer pageNumber {get;set;}
        @AuraEnabled
        public Integer totalRecords {get;set;}
        @AuraEnabled
        public Integer recordStart {get;set;}
        @AuraEnabled
        public Integer recordEnd {get;set;}
        @AuraEnabled
        public List<gFRS_Ltng_Third_Party__c> thirdPartyList {get;set;}
    }
    
    @AuraEnabled
    public static thirdPartyDataTableWrapper getthirdPtyData(Id applicationId,Integer pageNumber, Integer pageSize) { 
        //Offset for SOQL
        Integer offset = (pageNumber - 1) * pageSize;
        
        //Total Records
        Integer totalRecords = [SELECT COUNT() FROM gFRS_Ltng_Third_Party__c Where gFRS_Application__c=:applicationId];
        Integer recordEnd = pageSize * pageNumber;
        
        //Instance of Contact DataTable Wrapper Class
        thirdPartyDataTableWrapper objDT =  new thirdPartyDataTableWrapper();  
        objDT.pageSize = pageSize;
        objDT.pageNumber = pageNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        objDT.thirdPartyList = [SELECT Id,Name,Third_party_Organization_Name__c,Third_Party_Contact_First_Name__c,Third_Party_Contact_Last_Name__c
                                FROM gFRS_Ltng_Third_Party__c Where gFRS_Application__c=:applicationId
                                ORDER BY Name LIMIT :pageSize OFFSET :offset];
        return objDT;
    }
    
    
    @AuraEnabled
    public static List<LayoutSection> getPageLayoutFields(Id recordId) {
        
        List<LayoutSection> lstSections = new List<LayoutSection>();
        List<String> componentNameList = new List<String>();
        componentNameList.add('gFRS_Ltng_Third_Party__c-gFRS Third Party Layout');
        try {
            // Provide the page layout name here
            // You can give multiple page layout names here as well
            //List<String> componentNameList = new List<String>{'gFRS_Ltng_Program__c-gFRS Program Layout'};
            // Retrieve page layout details
            List<Metadata.Metadata> components = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, componentNameList);
            Metadata.Layout contLayout = (Metadata.Layout) components.get(0);
            
            // We are going to find the fields names and will keep them according to columns so
            // we can show them as per page layout
            for( Metadata.LayoutSection ls : contLayout.layoutSections ) {
                
                system.debug('@@ Layout Name'+ ls.label);
                if(ls.label!='System Information' && ls.label!='Custom Links'){
                    LayoutSection section = new LayoutSection( ls.label, ls.layoutColumns.size() );
                    
                    List<LayoutColumn> lstColumns = new List<LayoutColumn>();
                    Integer maxFieldsInColumn = 0;
                    for( Metadata.LayoutColumn lc : ls.layoutColumns ) {
                        
                        LayoutColumn column = new LayoutColumn();
                        // check if there are fields available in that column
                        if( lc.layoutItems != null ) {
                            // Get the max number of fields in a column to preserve the alignment
                            if( maxFieldsInColumn < lc.layoutItems.size() ) {
                                maxFieldsInColumn = lc.layoutItems.size();
                            }
                            for( Metadata.LayoutItem li : lc.layoutItems ) {
                                
                                // Pass the LayoutItem object in the LayoutField consturctor    
                                column.lstFields.add( new LayoutField( li ) );
                            }
                        }
                        // No need to add a column in the section if there is no field available
                        if( column.lstFields.size() > 0 ) {
                            lstColumns.add( column );
                        }
                    }
                    
                    // Now, we need to arrange the fields in section so we can use them in the iteration
                    // on the component so we will have to arrange them in the order
                    if( maxFieldsInColumn > 0 ) {
                        for( Integer i = 0; i < maxFieldsInColumn; i++ ) {
                            for( Integer j = 0; j < lstColumns.size(); j++ ){
                                if( lstColumns[j].lstFields.size() > i ) {
                                    section.lstFields.add( lstColumns[j].lstFields[i] );    
                                }    
                                else {
                                    section.lstFields.add( new LayoutField() );
                                }
                            }    
                        }    
                    }
                    
                    lstSections.add( section );
                }
            }
        }
        catch( Exception e ){
            System.assert(false, e.getLineNumber() + ' : ' + e.getMessage() );
        }
        return lstSections;
    }
    
    public class LayoutSection {  
        @AuraEnabled public String label;
        @AuraEnabled public List<LayoutField> lstFields;
        @AuraEnabled public Integer totalColumns;
        public LayoutSection( String label, Integer totalColumns ) {
            this.label = label;
            this.totalColumns = totalColumns;
            this.lstFields = new List<LayoutField>();
        }
    }
    
    private class LayoutColumn {
        private List<LayoutField> lstFields;    
        public LayoutColumn() {
            this.lstFields = new List<LayoutField>();
        }
    }
    
    public class LayoutField {
        @AuraEnabled public String fieldName;
        @AuraEnabled public Boolean isRequired;
        @AuraEnabled public Boolean isReadOnly;
        
        public LayoutField() {}
        
        public LayoutField( Metadata.LayoutItem li ) {
            
            this.fieldName = li.field;
            if( li.behavior == Metadata.UiBehavior.Required ) {
                this.isRequired = true;
            }
            else if( li.behavior == Metadata.UiBehavior.ReadOnly ) {
                this.isReadOnly = true;
            }    
        }
    }
    
    
}