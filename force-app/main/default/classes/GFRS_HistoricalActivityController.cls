public class GFRS_HistoricalActivityController {
    public Class searchCritteria{
        public String taxId                 {get; set;}
        public String grantId               {get; set;}  //problematic DOUBLE, replaced with STRING
        public String organization          {get; set;}
        public String status                {get; set;}
        public String legSystem             {get; set;}
        public String area                  {get; set;}
        public String state                 {get; set;}     
        public gFRS_Legacy_Data__c fromDate {get; set;}
        public gFRS_Legacy_Data__c toDate   {get; set;}  
        //.Therapeutic__c, g.State__c, g.Request_Status__c, g.Legacy_System__c 
    }
    
    public integer lineNo {get; set;}
    
    public searchCritteria sc {get; set;}
    
    public gFRS_Legacy_Data__c[] foundLD {get; set;}
    
    public boolean empty {get; set;}
    
    public GFRS_HistoricalActivityController(){
        lineNo      = 0;
        sc          = new searchCritteria();
        sc.fromDate = new gFRS_Legacy_Data__c();
        sc.toDate   = new gFRS_Legacy_Data__c();
        foundLD     = new gFRS_Legacy_Data__c[]{};
        this.empty  = true;
        
        /*KK: below params possibly not longer used ? need to check */
        
        map<String, String> params = Apexpages.currentPage().getParameters();
        if (params.containsKey('oid')) {
            GFRS_Organization__c org = [SELECT Tax_Id__c FROM GFRS_Organization__c WHERe Id =: params.get('oid')];
            if (org != null && org.Tax_Id__c != null) {
                sc.taxId = org.Tax_Id__c;
            } 
        }
    } 
    
    public void clear(){
        sc.taxId        = '';
        sc.grantId      = '';
        sc.organization = '';
        sc.status       = '';
        sc.legSystem    = '';
        sc.area         = '';
        sc.state        = '';
        sc.fromDate     = new gFRS_Legacy_Data__c();
        sc.toDate       = new gFRS_Legacy_Data__c();
        this.empty      = true;
    }
    
    public ApexPages.PageReference goToPDF(){
        ApexPages.PageReference pdfPage = new ApexPages.PageReference('/apex/GFRS_HistoricalActivity_PDF');
        return pdfPage;
    }
    
    public ApexPages.PageReference goToXLS(){
        ApexPages.PageReference xlsPage = new ApexPages.PageReference('/apex/GFRS_HistoricalActivity_XLS');
        return xlsPage;
    }
    
    public ApexPages.PageReference goToCSV(){
        ApexPages.PageReference xlsPage = new ApexPages.PageReference('/apex/GFRS_HistoricalActivity_CSV');
        return xlsPage;
    }
    
    public void search(){
        lineNo            = 0;
        boolean error     = false;
        Integer intTemp   = null;
        Double doubleTemp = null;
        String query      = 'select Id, Grant_Id__c, Therapeutic__c, Tax_Id__c, State__c, Requested_Amount__c, Request_Type__c, Request_Status__c, Program_Title__c, Org_Name__c, Legacy_System__c, CreatedDate, Approved_Amount__c, Request_Date__c From gFRS_Legacy_Data__c where Id != null';
        if(sc.area != '' && sc.area != null ){
            query+= ' AND Therapeutic__c LIKE \'%' + sc.area +'%\'';
        }
        if(sc.legSystem != '' && sc.legSystem != null){
            query+= ' AND Legacy_System__c LIKE \'%' + sc.legSystem +'%\'';
        }
        if(sc.organization != '' && sc.organization != null){
            query+= ' AND Org_Name__c LIKE \'%' + sc.organization +'%\'';
        }
        if(sc.state != '' && sc.state != null){
            query+= ' AND State__c LIKE \'%' + sc.state +'%\'';
        }
        if(sc.status != '' && sc.status != null){
            query+= ' AND Request_Status__c LIKE \'%' + sc.status +'%\'';
        }
        if(sc.taxId!= '' && sc.taxId != null){
            String strippedTax = ('' + sc.taxId ).replaceAll( '[^0-9]', '' );
            query+= ' AND ( Tax_Id__c LIKE \'%' + sc.taxId +'%\' OR Tax_Id__c LIKE \'%' + strippedTax +'%\')';
        }
        if(sc.fromDate.Request_Date__c != null ){
            String tempDt = string.valueOf(sc.fromDate.Request_Date__c).substring(0,10);// + 'T00:00:00Z';
            query+= ' AND Request_Date__c >= ' + tempDt;
        }
        if(sc.toDate.Request_Date__c != null ){
            String tempDt = string.valueOf(sc.toDate.Request_Date__c).substring(0,10);// + 'T23:59:59Z';
            query+= ' AND Request_Date__c <= ' + tempDt;
        }
        if(sc.grantId != '' && sc.grantId != null){
            try{
                intTemp = Integer.valueOf(sc.grantId);
                query+= ' AND Grant_Id__c = \'' + intTemp + '\'';
            } catch (exception e){
                error = true;
                this.empty = true;
                ApexPages.Message tempMyMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Grant ID value should be a number. Please correct it.');
                ApexPages.addMessage(tempMyMsg);
            }
        }
        query += ' order by Request_Date__c desc limit 1000';
        
        if(!error){
            system.debug(query);
            foundLD = Database.query(query);
            if(foundLD.size()>0){
                this.empty = false;
            } else {
                this.empty = true;
                ApexPages.Message tempMyMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'No records matching search criteria were found.');
                ApexPages.addMessage(tempMyMsg);
            }
        }
    }
    
    
    /* data fetch methods below */
    
    /**
    * @author ADMD Team
    * @date updated 11/01/2016
    * @description getLegacySystemItems method - fetches values for Legacy System based on actual records in DB
    */
     public List<SelectOption> getLegacySystemItems (){
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption('',''));
        for (AggregateResult status : [SELECT Legacy_System__c FROM gFRS_Legacy_Data__c where Legacy_System__c != NULL group by Legacy_System__c order by Legacy_System__c asc]){
            options.add(new SelectOption((String) status.get('Legacy_System__c'),(String) status.get('Legacy_System__c')));
        }
        
        return options;
    }
    
    /**
    * @author ADMD Team
    * @date updated 11/01/2016
    * @description getStatusItems method - fetches values for Request Status based on actual records in DB
    */
    public List<SelectOption> getStatusItems (){
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption('',''));
        for (AggregateResult status : [SELECT Request_Status__c FROM gFRS_Legacy_Data__c where Request_Status__c != NULL group by Request_Status__c order by Request_Status__c asc]){
            options.add(new SelectOption((String) status.get('Request_Status__c'),(String) status.get('Request_Status__c')));
        }
        
        return options;
    }
    
    
    /**
    * @author ADMD Team
    * @date updated 11/01/2016
    * @description getStateItems method - fetches values for State based on actual records in DB
    */    
    public List<SelectOption> getStateItems (){
        List<SelectOption> options = new List<SelectOption>();
                
        options.add(new SelectOption('',''));
        for (AggregateResult state : [SELECT State__c FROM gFRS_Legacy_Data__c where State__c != NULL group by State__c order by State__c asc]){
            options.add(new SelectOption((String) state.get('State__c'),(String) state.get('State__c')));
        }
        
        return options;
    }
    

    /**
    * @author ADMD Team
    * @date updated 11/01/2016
    * @description getTherapeuticAreas method - fetches values for Therapeutic Area based on actual records in DB
    */
    public List<SelectOption> getTherapeuticAreas(){
        List<SelectOption> options = new List<SelectOption>();
        
        /* need to filter non-null values in query, and then add it manually to avoid Argument 1 cannot be null error */    
        options.add(new SelectOption('',''));
        for (AggregateResult ta : [SELECT Therapeutic__c FROM gFRS_Legacy_Data__c where Therapeutic__c != NULL group by Therapeutic__c order by Therapeutic__c asc]){
            options.add(new SelectOption((String) ta.get('Therapeutic__c'),(String) ta.get('Therapeutic__c')));
        }
        
        return options;
    }
    
}