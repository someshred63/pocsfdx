public class gFRS_Ltng_ProgramViewController {
    @AuraEnabled
    Public static List<gFRS_Ltng_Program__c> getProgramListData(Id applicationId){
        List<gFRS_Ltng_Program__c> prgList = [SELECT Id,Name,gFRS_Application__r.Record_Type__c,gFRS_End_Date__c,gFRS_Sub_Focus_Area__c,gFRS_Start_Date__c,How_many_attendees_do_you_expect__c,Number_of_Attendees__c,gFRS_Expected_number_of_patients_served__c,gFRS_Program_Type__c,gFRS_Program_Subtype__c,gFRS_Focus_Area__c,gFRS_Expected_number_of_attendees__c,gFRS_Expected_of_Attendees_US_Based_HCPs__c,gFRS_Venue_City__c,gFRS_Secondary_program_title__c
                                              FROM gFRS_Ltng_Program__c Where gFRS_Application__c=:applicationId];
        return prgList;
    }
    
    
    @AuraEnabled
    Public static List<gFRS_Ltng_Program_Audience_Group__c> getProgramAudList(Id prgmAudId){
        List<gFRS_Ltng_Program_Audience_Group__c> prgAudList = [SELECT Id,Name,gFRS_Degree__c,gFRS_Credit_Type__c,gFRS_Exp_Learners__c,
                                                                gFRS_Credit_Hours__c,gFRS_Expected_Learners_With_Credit__c,gFRS_Specialty__c,Total_of_Actual_Learners__c
                                                                FROM gFRS_Ltng_Program_Audience_Group__c Where gFRS_Program__c=:prgmAudId];
        return prgAudList;
    }
    
    @AuraEnabled
    Public static UserRecordAccess UserRecordAccess(Id prgmAudId){
        user u= [Select Id,Name From User Where Id =:UserInfo.getUserId()];
        return[SELECT RecordId, MaxAccessLevel, HasAllAccess, HasDeleteAccess, HasEditAccess, HasReadAccess, HasTransferAccess 
                                              FROM UserRecordAccess where (UserId =: u.id and RecordId =: prgmAudId)];
    }
    
    @AuraEnabled
    public static List<LayoutSection> getPageLayoutFields(Id recordId) {
        
        List<LayoutSection> lstSections = new List<LayoutSection>();
        List<String> componentNameList = new List<String>();
        Map<String,String> pageLayMap=new  Map<String,String>();
        Set<String> sectionSets=new Set<String>();
        
        //pageLayMap.put('Community_Giving_Program','gFRS_Ltng_Program__c-Community Giving-Program');
        //pageLayMap.put('IME_Program','gFRS_Ltng_Program__c-IME Program layout');
        //pageLayMap.put('Patient_Health_Focused_Program','gFRS_Ltng_Program__c-Patient and Health FocusedProgram Layout');
        
        
        gFRS_Program_Layout__mdt[] prglayoutMappings = [SELECT Id, DeveloperName, MasterLabel, 
                                                        RecordType_Developer_Name__c, Program_Page_layout_Name__c FROM gFRS_Program_Layout__mdt];
        
        for (gFRS_Program_Layout__mdt prglayout : prglayoutMappings) {
            pageLayMap.put(prglayout.RecordType_Developer_Name__c,prglayout.Program_Page_layout_Name__c);
        } 
        
        gFRS_Ltng_Program__c currentRec=[SELECT Id,Name,gFRS_End_Date__c,gFRS_Start_Date__c,Program_Type__c,
                                         Venue_associated_with_this_event_program__c,gFRS_Program_Type__c,gFRS_Application__r.Record_Type__c,
                                         gFRS_Program_Subtype__c,gFRS_Focus_Area__c,gFRS_Sub_Focus_Area__c,
                                         gFRS_Expected_number_of_attendees__c,gFRS_Expected_of_Attendees_US_Based_HCPs__c,
                                         gFRS_Venue_City__c,gFRS_Secondary_program_title__c,Recordtype.Developername,
                                         gFRS_Application__r.Recordtype.Developername
                                         FROM gFRS_Ltng_Program__c Where Id=:recordId];
        
        String rectypeName=currentRec.Recordtype.Developername;
        //String rectypeName=currentRec.gFRS_Application__r.Recordtype.Developername;
        System.debug('@@@@ '+rectypeName);
        
        // if(pageLayMap.containsKey(currentRec.gFRS_Program_Type__c)){
        //componentNameList.add(pageLayMap.get(currentRec.gFRS_Program_Type__c));
        // }
        if(pageLayMap.containsKey(rectypeName)){
            componentNameList.add(pageLayMap.get(rectypeName));
            System.debug('@@ Veera'+pageLayMap.get(currentRec.Recordtype.Developername));
        }
        else{
            system.debug('gFRS_Ltng_Program__c-gFRS Program Layou');
            componentNameList.add('gFRS_Ltng_Program__c-gFRS Program Layout');
        }
        
        
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
                
                if(currentRec.gFRS_Program_Type__c=='Virtual (online)')
                {
                    sectionSets.add('Program Section');
                //    sectionSets.add('Outcome');
                }
                else{
                    sectionSets.add('Program Section'); 
                    sectionSets.add('Venue Section');
              //      sectionSets.add('Outcome');
                } 
                
                
                //ls.label!='Custom Links'
                if(sectionSets.contains(ls.label))
                {
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

                                    if(currentRec.gFRS_Application__r.Record_Type__c == 'Education Focused Giving K-12' && String.valueOf(lstColumns[j].lstFields[i].fieldName) == 'gFRS_Sub_Focus_Area__c'){
                                        //nothing to do
                                    } else if(currentRec.gFRS_Application__r.Record_Type__c == 'Education Focused Giving Graduate and Post-Graduate' && String.valueOf(lstColumns[j].lstFields[i].fieldName) == 'SubFocusArea__c'){
                                        //nothing to do
                                    } else {
                                        section.lstFields.add( lstColumns[j].lstFields[i] );    
                                    }
                                    
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
    
    //Wrapper Class For Program DataTable  
    public class programDataTableWrapper {
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
        public List<gFRS_Ltng_Program__c> programList {get;set;}
    }
    
    @AuraEnabled
    public static programDataTableWrapper getProgramData(Id applicationId,Integer pageNumber, Integer pageSize) { 
        //Offset for SOQL
        Integer offset = (pageNumber - 1) * pageSize;
        
        //Total Records
        Integer totalRecords = [SELECT COUNT() FROM gFRS_Ltng_Program__c Where gFRS_Application__c=:applicationId];
        Integer recordEnd = pageSize * pageNumber;
        
        //Instance of Contact DataTable Wrapper Class
        programDataTableWrapper objDT =  new programDataTableWrapper();  
        objDT.pageSize = pageSize;
        objDT.pageNumber = pageNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        objDT.programList = [SELECT Id,Name,gFRS_End_Date__c,RecordTypeId,gFRS_Start_Date__c,gFRS_Sub_Focus_Area__c,gFRS_Program_Type__c,gFRS_Program_Subtype__c,gFRS_Focus_Area__c,Venue_associated_with_this_event_program__c,How_many_attendees_do_you_expect__c,gFRS_Expected_number_of_attendees__c,gFRS_Expected_of_Attendees_US_Based_HCPs__c,gFRS_Venue_City__c,gFRS_Secondary_program_title__c,gFRS_Expected_number_of_patients_served__c
                             FROM gFRS_Ltng_Program__c Where gFRS_Application__c=:applicationId
                             ORDER BY Name LIMIT :pageSize OFFSET :offset];
        return objDT;
    }
    
    @AuraEnabled
    public static void deleteProgram(List<gFRS_Ltng_Program__c> delProgRec, string appId, string pgmType){
        SavePoint sp = Database.setSavepoint();
		
        try{
            //Delete delProgRec;
            gFRS_Ltng_Util_NoShare.deletePrograms(delProgRec);
        }
        catch(Exception e){
            
            Database.rollback(sp);
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }  
    
    @AuraEnabled
    public static programRecordCheckWrapper getRecordAduCheck(String recordId)
    {
        gFRS_Ltng_Application__c appRecord=[SELECT Id, RecordtypeId,Funding_Sub_Type__c,RecordType.name FROM gFRS_Ltng_Application__c where Id =:RecordId];
        Boolean cMEValue;
        Boolean cMGValue;
        Boolean eDFValue;
        Boolean pATHValue;
        Boolean sCiFiRValue;
        Boolean internalValue;
        
        programRecordCheckWrapper prgChkWrapper =new programRecordCheckWrapper();
        
        if(appRecord.RecordType.name=='Independent Medical Education (CME)'){
            prgChkWrapper.cMEValue=true;
            prgChkWrapper.cMGValue=false;
            prgChkWrapper.eDFValue=false;
            prgChkWrapper.pATHValue=false;
            prgChkWrapper.sCiFiRValue=false;
            prgChkWrapper.EduSubValue=false;
            prgChkWrapper.eDFValue=false;
            prgChkWrapper.internalValue=false; 
        }
                /*else if(appRecord.RecordType.name=='Education Focused Giving'){
        prgChkWrapper.cMEValue=false;
        prgChkWrapper.cMGValue=false;
        prgChkWrapper.pATHValue=false;
        prgChkWrapper.sCiFiRValue=false; //K-12
        if(appRecord.Funding_Sub_Type__c=='K-12'){
        prgChkWrapper.EduSubValue=true;
        prgChkWrapper.eDFValue=false;
        }
        else{
        prgChkWrapper.eDFValue=true;
        prgChkWrapper.EduSubValue=false;
        }
        }*/
        else if(appRecord.RecordType.name=='Education Focused Giving Graduate and Post-Graduate'){
            prgChkWrapper.cMEValue=false;
            prgChkWrapper.cMGValue=false;
            prgChkWrapper.pATHValue=false;
            prgChkWrapper.sCiFiRValue=false;
            prgChkWrapper.eDFValue=true;
            prgChkWrapper.EduSubValue=false;
            prgChkWrapper.internalValue=false; 
        }else if(appRecord.RecordType.name=='Education Focused Giving K-12'){
            prgChkWrapper.cMEValue=false;
            prgChkWrapper.cMGValue=false;
            prgChkWrapper.pATHValue=false;
            prgChkWrapper.sCiFiRValue=false;
            prgChkWrapper.eDFValue=false;
            prgChkWrapper.EduSubValue=true;
            prgChkWrapper.internalValue=false; 
        }else if(appRecord.RecordType.name=='Community Giving'){
            prgChkWrapper.cMEValue=false;
            prgChkWrapper.cMGValue=true;
            prgChkWrapper.eDFValue=false;
            prgChkWrapper.pATHValue=false;
            prgChkWrapper.sCiFiRValue=false;
            prgChkWrapper.EduSubValue=false;
            prgChkWrapper.eDFValue=false;
            prgChkWrapper.internalValue=false; 
        }
        else if(appRecord.RecordType.name=='Patient and Health Focused Giving'){
            prgChkWrapper.cMEValue=false;
            prgChkWrapper.cMGValue=false;
            prgChkWrapper.eDFValue=false;
            prgChkWrapper.pATHValue=true;
            prgChkWrapper.EduSubValue=false;
            prgChkWrapper.eDFValue=false;
            prgChkWrapper.sCiFiRValue=false; //Scientific and Research Focused Giving
            prgChkWrapper.internalValue=false; 
        }
        else if(appRecord.RecordType.name=='Scientific and Research Focused Giving'){
            prgChkWrapper.cMEValue=false;
            prgChkWrapper.cMGValue=false;
            prgChkWrapper.eDFValue=false;
            prgChkWrapper.pATHValue=false;
            prgChkWrapper.sCiFiRValue=true; //Scientific and Research Focused Giving
            prgChkWrapper.internalValue=false; 
        } else if(appRecord.RecordType.name=='Field Exhibits'||appRecord.RecordType.name=='Corporate Memberships'||appRecord.RecordType.name=='Commercial Sponsorship'||appRecord.RecordType.name=='Non_Commercial_Sponsorship'){
            prgChkWrapper.cMEValue=false;
            prgChkWrapper.cMGValue=false;
            prgChkWrapper.eDFValue=false;
            prgChkWrapper.pATHValue=false;
            prgChkWrapper.sCiFiRValue=false; //Scientific and Research Focused Giving
            prgChkWrapper.internalValue=true; 
        }
        return prgChkWrapper;
    } 
    
    
    public class programRecordCheckWrapper {
        @AuraEnabled
        public Boolean cMEValue {get;set;}
        @AuraEnabled
        public Boolean cMGValue {get;set;}
        @AuraEnabled
        public Boolean eDFValue {get;set;}
        @AuraEnabled
        public Boolean pATHValue {get;set;}
        @AuraEnabled
        public Boolean sCiFiRValue {get;set;}
        @AuraEnabled
        public Boolean EduSubValue {get;set;}
        @AuraEnabled
        public Boolean internalValue {get;set;}
        
    }

        
}