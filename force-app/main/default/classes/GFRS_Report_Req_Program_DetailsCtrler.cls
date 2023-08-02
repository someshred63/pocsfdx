/**
* @author GFRS Dev Team
* @date 05/09/2019
* @description GFRS_Report_Req_Program_DetailsCtrler class - controller to generate report for Request and corresponding programs
*/
public without sharing class GFRS_Report_Req_Program_DetailsCtrler {

    public GFRS_Funding_Request__c request        { get; set; }
    public List<HelperFundingRequest> eduObjsList { get; set; }
    public Boolean isGraphRender                  { get; set; }
    public String jsonData                        { get; set; }
    public String dateSubmitted                   { get; set; }
    public String closedDate                      { get; set; }
    public List<string> therapeuticAreaSelected   { get; set; }
    public List<Selectoption> leftSelectOptions;
    public List<Selectoption> rightSelectOptions  { get; set; }
    public transient List<RequestProgramWrapper> reqPgmWrapper  { get; set; }
    public Boolean isComplianceUser {get; set;}
    public Boolean isIMEDorHCCharUser {get; set;}
    public integer counter=0;  //keeps track of the offset
    public integer list_size=20; //sets the page size or number of rows
    public integer total_size; //used to show user the total size of the list   
    public Boolean  DisablePrevious {get; set;}
    public Boolean  DisableNext {get; set;}
    public Boolean  exportToExcel;
    
    private String sortDirection = 'ASC';
    private String sortExp       = 'DiseaseState';

    public String therapeuticAreaSelectedString {
        get{
        String output ='';
        if(therapeuticAreaSelected != null){
            for(String s:therapeuticAreaSelected){
                output += s+',';
            }
                        
        }
        return output;
        }
    }   
    

    public String sortExpression
    {
        get{
         
                return sortExp;
         }
         set{
         
               //if the column is clicked on then switch between Ascending and Descending modes
               if (value == sortExp)
                 sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
               else
                 sortDirection = 'ASC';
               sortExp = value;
         }
     }

     public String getSortDirection(){
     
        //if not column is selected 
        if (String.isEmpty(sortExpression))
          return 'ASC';
        else
         return sortDirection;
     }
    
     public void setSortDirection(String value){
       
       sortDirection = value;
     }
    
    public GFRS_Report_Req_Program_DetailsCtrler(ApexPages.StandardController std ){

      request                 = (GFRS_Funding_Request__c)std.getRecord();
      eduObjsList             = new list<HelperFundingRequest>();  
      reqPgmWrapper           = new list<RequestProgramWrapper>();  
      date dt                 = Date.today().addDays(-365);      
//      dateSubmitted           = '11/6/2018';
      dateSubmitted           = dt.format();
      closedDate              = Date.today().format();
      isGraphRender           = false;
      jsonData                = '';
      rightSelectOptions      = new List<Selectoption>();
      leftSelectOptions       = getTherapeuticArea();
      therapeuticAreaSelected = new List<String>();
      DisableNext = true;
      DisablePrevious = true;
      exportToExcel = false;
    }
    
    /**
    * @author GFRS Dev Team
    * @date 05/08/2013
    * @description getTherapeuticArea method - getter method to which return all defined options in  Therapeutic_Area__c field under GFRS_Funding_Request__c custom object  
    */
    public List<Selectoption> getTherapeuticArea(){
        
        String userType = '';
        List<Selectoption> taOptions = new List<Selectoption>();
        isIMEDorHCCharUser = False;
        isComplianceUser = False;
        
        if(isUserInPermissionSet('gFRS_Compliance_Flags_Notes')){
            taOptions.add(new Selectoption('Exhibits & Other Promos','Exhibits & Other Promos'));
            taOptions.add(new Selectoption('Sci/Pipeline Exhibits & Other Non-Promo','Sci/Pipeline Exhibits & Other Non-Promo'));
            taOptions.add(new Selectoption('Corporate Memberships','Corporate Memberships'));
            isComplianceUser = True;
        }
        if(isUserInPublicGroup('GNE-GFRS-CEG Team')){
            taOptions.add(new Selectoption('HC Char','HC Char'));
            isIMEDorHCCharUser = True;
        }
        if(isUserInPublicGroup('GNE-GFRS-IMED Team')){
            taOptions.add(new Selectoption('IMED','IMED'));
            isIMEDorHCCharUser = True;
        }
        
        return taOptions;
    }
    
    public Boolean isUserInPublicGroup(String groupName){
        
        Boolean isInGroup = False;
        Group grp = [ SELECT Id, Name FROM Group WHERE Name =: groupName LIMIT 1];
            
        if (grp != null && grp.Id != null) {
            if ([SELECT GroupId, Id, UserOrGroupId FROM GroupMember WHERE GroupId = :grp.id AND UserOrGroupId = :UserInfo.getUserId()].size() > 0) {
                isInGroup = True;
            }
        }
        return isInGroup;
    }
    
    public Boolean isUserInPermissionSet(String PermissionSetName){
        
        Boolean isInPermissionSet = False;
        for(PermissionSetAssignment pr : [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =: UserInfo.getUserId() AND PermissionSet.Name =: PermissionSetName]) {
            isInPermissionSet = True;
            break;
        }
        return isInPermissionSet;
    }
    
    public List<SelectOption> getLeftSelectOptions(){
        return leftSelectOptions;
    }
    
     /**
    * @author GFRS Dev Team
    * @date 05/08/2013
    * @description exportDetails method - redirecting page to excel page report will be generate in xls format  
    */
    public pagereference exportDetails()
    {
        boolean isFilterEmpty=false;
         
        if(this.therapeuticAreaSelected.isEmpty())
        {
           isFilterEmpty=true;  
           ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Please select Funding Type'));
        }
        if(String.isEmpty(dateSubmitted)){
            isFilterEmpty=true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Decision Date From : You must enter a value'));   
        }
        if(String.isEmpty(closedDate)){
            isFilterEmpty=true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'To : You must enter a value'));
        }
            
        if(isFilterEmpty)
        {
            return null;
        }
        exportToExcel = true;
        
        Pagereference renderedReport = eduObjectivesData();
        
        //return( new ApexPages.PageReference('apex/GFRS_Report_IMED_Edu_Obj_Excel'));
        PageReference excelPage = new PageReference('/apex/GFRS_Report_Request_Program_Excel');
        excelPage.setRedirect(false);
        return excelPage;
    }
    
    public pagereference doSort()
    {
        String sortOrder = getSortDirection();
        
        for(HelperFundingRequest item : eduObjsList){
            item.sortOrder   = sortOrder;
            item.sortByField = sortExpression;
        }
        eduObjsList.sort();
        return null;
    }
    
    public PageReference Next() { 
        counter += list_size;
        eduObjectivesData();
        return null;
    }   
    
    public PageReference Previous() { 
        counter -= list_size;
        eduObjectivesData();
        return null;
    }
    
    public PageReference Beginning() { 
        counter = 0;
        eduObjectivesData();
        return null;
    }
    
    public PageReference End() { 
        counter = total_size - math.mod(total_size, list_size);
        eduObjectivesData();
        return null;
    }
    
    /**
    * @author GFRS Dev Team
    * @date 05/08/2013
    * @description eduObjectivesData method - agregating data to the IMED Edu report  
    */
    public pagereference eduObjectivesData()
    {
        try{    
            Boolean isFilterEmpty=false;
            if(this.therapeuticAreaSelected.isEmpty())
            {
               isFilterEmpty=true;  
               ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Please select Funding Type'));
            }
            if(String.isEmpty(dateSubmitted)){
                isFilterEmpty=true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Decision Date From : You must enter a value'));   
            }
            if(String.isEmpty(closedDate) || String.isEmpty(dateSubmitted)){
                isFilterEmpty=true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'To : You must enter a value'));
            }
                
            if(isFilterEmpty)
            {
                return null;
            }
        }catch(Exception ex){
             system.debug('Exception: ' + ex.getmessage());
        }
        
        try
        {
            
            reqPgmWrapper           = new list<RequestProgramWrapper>();  
            List<GFRS_Funding_Request__c> fundingRequests = new List<GFRS_Funding_Request__c>();
            
            if(exportToExcel){
                fundingRequests = [SELECT Id, Name, Organization_Name__c, Sub_Status__c, External_Tracking_Code_optional__c, Business_Unit_2__c, Therapeutic_Area__c, Event_Program_Title__c,Approved_Amount__c, (SELECT Id,Name,Are_there_any_other_commercial_sponsors__c, Did_you_exhibit_sponsor_at_the_event__c,Genentech_is_not_supporting_more_than_75__c,Venue_Name__c,Venue_City__c,Start_Date__c,End_Date__c,Venue_State__c,Venue_Zip_Code__c FROM Request_Delivery_Formats__r)
                                                            FROM GFRS_Funding_Request__c 
                                                            WHERE Record_Type_Name__c IN :therapeuticAreaSelected
                                                                AND Number_of_Programs__c > 1 
                                                                AND Decision_Date__c>=:Date.parse(this.dateSubmitted) 
                                                                AND Decision_Date__c<=:Date.parse(this.closedDate) 
                                                                ORDER BY Name ASC];
            } else {
                total_size = [select count() from GFRS_Funding_Request__c WHERE Record_Type_Name__c IN :therapeuticAreaSelected
                                                                AND Number_of_Programs__c > 1 
                                                                AND Decision_Date__c>=:Date.parse(this.dateSubmitted) 
                                                                AND Decision_Date__c<=:Date.parse(this.closedDate)];
                fundingRequests = [SELECT Id, Name, Organization_Name__c, Sub_Status__c, External_Tracking_Code_optional__c, Business_Unit_2__c, Therapeutic_Area__c, Event_Program_Title__c,Approved_Amount__c, (SELECT Id,Name,Are_there_any_other_commercial_sponsors__c, Did_you_exhibit_sponsor_at_the_event__c,Genentech_is_not_supporting_more_than_75__c,Venue_Name__c,Venue_City__c,Start_Date__c,End_Date__c,Venue_State__c,Venue_Zip_Code__c FROM Request_Delivery_Formats__r)
                                                            FROM GFRS_Funding_Request__c 
                                                            WHERE Record_Type_Name__c IN :therapeuticAreaSelected
                                                                AND Number_of_Programs__c > 1 
                                                                AND Decision_Date__c>=:Date.parse(this.dateSubmitted) 
                                                                AND Decision_Date__c<=:Date.parse(this.closedDate) 
                                                                ORDER BY Name ASC
                                                                limit :list_size offset :counter];
                                                        
                if (counter + list_size < total_size){
                    DisableNext = false;
                } else {
                    DisableNext = true;
                }
                
                if (counter>0){
                    disablePrevious = false;
                } else {
                    disablePrevious = true;
                }
            }
            string reqNumber = '';
            for(GFRS_Funding_Request__c req : fundingRequests) 
            {
                for(GFRS_Program__c pgm : req.Request_Delivery_Formats__r){
                    RequestProgramWrapper wrapper = new RequestProgramWrapper();
                    if(req.name == reqNumber){
                        wrapper.reqName = '';
                        wrapper.orgName = '';
                        wrapper.overallPgm = '';
                        wrapper.approvedAmt = '';
                        wrapper.subStatus = '';
                        wrapper.diseaseState = '';
                        wrapper.businessUnit = '';
                        wrapper.extTrackingCode = '';
                    } else {
                        wrapper.reqName = req.Name;
                        wrapper.reqId = req.Id;
                        wrapper.orgName = req.Organization_Name__c;
                        wrapper.overallPgm = req.Event_Program_Title__c;
                        wrapper.approvedAmt = string.valueOf(req.Approved_Amount__c);
                        wrapper.subStatus = req.Sub_Status__c;
                        wrapper.diseaseState = req.Therapeutic_Area__c;
                        wrapper.businessUnit = req.Business_Unit_2__c;
                        wrapper.extTrackingCode = req.External_Tracking_Code_optional__c;
                    }
                    wrapper.pgmName = pgm.name;
                    wrapper.pgmStartDate = string.valueof(pgm.Start_Date__c);
                    wrapper.pgmEndDate = string.valueof(pgm.End_Date__c);
                    wrapper.venueName = pgm.Venue_Name__c;
                    wrapper.VenueCity = pgm.Venue_City__c;
                    wrapper.venueState = pgm.Venue_State__c;
                    wrapper.venueZipCode = pgm.Venue_Zip_Code__c;
                    wrapper.anySponsors = pgm.Are_there_any_other_commercial_sponsors__c;
                    wrapper.geneSupport = pgm.Genentech_is_not_supporting_more_than_75__c;
                    wrapper.didYouExhibit = pgm.Did_you_exhibit_sponsor_at_the_event__c;
                    reqNumber = req.name;
                    
                    reqPgmWrapper.add(wrapper);
                } 
            }              
        }
        catch(Exception ex)
        {
            system.debug('Exception: ' + ex.getmessage());
        }
        return null;
    }
    
    /**
    * @author GFRS Dev Team
    * @date 05/08/2013
    * @description getReportHeader method - set header in excel file  
    */
    public String getReportHeader() {
        string ReportHeader='';
        ReportHeader = '<td><b>Request Number</b></td>';
        ReportHeader += '<td><b>Sub Status</b></td>';
        ReportHeader += '<td><b>Business Unit</b></td>';
        ReportHeader += '<td><b>Disease State</b></td>';
        ReportHeader += '<td><b>External Tracking Code</b></td>';
        ReportHeader += '<td><b>Organization Name</b></td>';
        ReportHeader += '<td><b>Program Title</b></td>';
        if(isIMEDorHCCharUser){
            ReportHeader += '<td><b>Approved Amount</b></td>';    
        }
        ReportHeader += '<td><b>Program Number</b></td>';
        ReportHeader += '<td><b>Program Start Date</b></td>';
        ReportHeader += '<td><b>Program End Date</b></td>';
        ReportHeader += '<td><b>Venue Name</b></td>';
        ReportHeader += '<td><b>Venue City</b></td>';
        if(isIMEDorHCCharUser){
            ReportHeader += '<td><b>Venue State</b></td>'; 
            ReportHeader += '<td><b>Venue Zip Code</b></td>'; 
        }
        if(isComplianceUser){
            ReportHeader += '<td><b>Are there any other commercial sponsors</b></td>';
            ReportHeader += '<td><b>Genentech is not supporting more than 75% of the event activity?</b></td>';
            ReportHeader += '<td><b>Did you exhibit/sponsor at the event?</b></td>';
        }
        return ReportHeader;
    }
    
    /**
    * @author GFRS Dev Team
    * @date 05/08/2013
    * @description getReportData method - write rows with data in excel file.
    */
     public List<String> getReportData() {
        List<String> repData = new list<string>();        
        if( reqPgmWrapper == null || reqPgmWrapper.size() == 0)
            repData.add('<tr><td>No data found.</td></tr>');
        else {
            
            
            Integer rownum    = 0;
            Integer remainder = 0;
            String lineColor  = '';
                        
            for(RequestProgramWrapper req : reqPgmWrapper) {
            
                String dataRow = '';
                remainder = math.mod(rownum, 2);
                if( remainder == 0)
                    lineColor = '#EDEDED';
                else
                    lineColor = '#FFFFFF';
                    
                dataRow = '<tr>';
                
                dataRow += '<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                dataRow += req.reqName;
                dataRow += '</td>';
                
                dataRow += '<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                dataRow += req.subStatus;
                dataRow += '</td>';
                
                dataRow += '<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                dataRow += req.businessUnit;
                dataRow += '</td>';
                
                dataRow += '<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                dataRow += req.diseaseState;
                dataRow += '</td>';
                
                dataRow += '<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                dataRow += req.extTrackingCode;
                dataRow += '</td>';             
                
                dataRow += '<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                dataRow += req.orgName;
                dataRow += '</td>';
                
                dataRow += '<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                dataRow += req.overallPgm;
                dataRow += '</td>';
                
                if(isIMEDorHCCharUser){
                    dataRow += '<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                    dataRow += req.approvedAmt;
                    dataRow += '</td>';
                }
                
                dataRow += '<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                dataRow += req.pgmName;
                dataRow += '</td>';
                
                dataRow += '<td style="background-color:' + lineColor + '; text-align:right;vertical-align:top">';
                dataRow += req.pgmStartDate;
                dataRow += '</td>';
                
                dataRow += '<td style="background-color:' + lineColor + '; text-align:right;vertical-align:top">';
                dataRow += req.pgmEndDate;
                dataRow += '</td>';
                
                dataRow += '<td style="background-color:' + lineColor + '; text-align:right;vertical-align:top">';
                dataRow += req.venueName;
                dataRow += '</td>';
                
                dataRow += '<td style="background-color:' + lineColor + '; text-align:right;vertical-align:top">';
                dataRow += req.VenueCity;
                dataRow += '</td>';
                
                if(isIMEDorHCCharUser){
                    
                    dataRow += '<td style="background-color:' + lineColor + '; text-align:right;vertical-align:top">';
                    dataRow += req.venueState;
                    dataRow += '</td>';
                
                    dataRow += '<td style="background-color:' + lineColor + '; text-align:right;vertical-align:top">';
                    dataRow += req.venueZipCode;
                    dataRow += '</td>';
                    
                }
                
                if(isComplianceUser){
                    
                    dataRow += '<td style="background-color:' + lineColor + '; text-align:right;vertical-align:top">';
                    dataRow += req.anySponsors;
                    dataRow += '</td>';
                
                    dataRow += '<td style="background-color:' + lineColor + '; text-align:right;vertical-align:top">';
                    dataRow += req.geneSupport;
                    dataRow += '</td>';
                
                    dataRow += '<td style="background-color:' + lineColor + '; text-align:right;vertical-align:top">';
                    dataRow += req.didYouExhibit;
                    dataRow += '</td>'; 
                    
                }
            
                dataRow +='</tr>';
                repData.add(dataRow);
                rownum +=1;
                
                                       
            }
        }
                        
        return repData;
    }
    
    
    /**
    * @author GFRS Dev Team
    * @date 05/08/2013
    * @description HelperFundingRequest class - helper class to agregate data to the IMED Edu report  
    */
    public class HelperFundingRequest implements Comparable{
        
        public String educationalObjectives   { get; set; }
        public Decimal totaOfExpectedLearners { get; set; }
        public Integer numberOfTables         { get; set; }
        public Integer splitNumber            { get; set; }
        public String diseaseState            { get; set; }
        public transient String sortOrder     { get; set; }
        public transient String sortByField   { get; set; }
        
        public HelperFundingRequest(string eduObj,Decimal totExpectLearn, Integer numOfTab,Integer splitNum){
            educationalObjectives  = eduObj;
            totaOfExpectedLearners = totExpectLearn;
            numberOfTables         = numOfTab;
            splitNumber            = splitNum;
        }
        
        public HelperFundingRequest(string eduObj,Decimal totExpectLearn, Integer numOfTab,Integer splitNum,String diseaseState,String sortOrder,String sortByField){
            educationalObjectives  = eduObj;                  
            totaOfExpectedLearners = totExpectLearn;
            numberOfTables         = numOfTab;
            splitNumber            = splitNum;
            this.diseaseState           = diseaseState;
            this.sortOrder              = sortOrder;
            this.sortByField            = sortByField;
        }
        
        public Integer compareTo(Object compareTo) 
        {
            
            HelperFundingRequest helpFR = (HelperFundingRequest) compareTo;
            if(sortByField=='DiseaseState'){
                if(sortOrder=='ASC'){
                    return diseaseState.compareTo(helpFR.diseaseState);                 
                }else{ 
                    return diseaseState.compareTo(helpFR.diseaseState)*(-1);
                }
            }else if(sortByField=='EducationalObjective'){
                if(sortOrder=='ASC'){
                    return educationalObjectives.compareTo(helpFR.educationalObjectives);                   
                }else{ 
                    return educationalObjectives.compareTo(helpFR.educationalObjectives)*(-1);
                }
            }else if(sortByField=='ApprovedGrants'){
                if(sortOrder=='ASC'){
                    if(splitNumber > helpFR.splitNumber){
                        return 1;
                    }else if(splitNumber == helpFR.splitNumber){
                        return 0;
                    }else{
                        return -1;
                    }                   
                }else {
                    if(splitNumber < helpFR.splitNumber){
                        return 1;
                    }else if(splitNumber == helpFR.splitNumber){
                        return 0;
                    }else{
                        return -1;
                    }    
                }
            }else if(sortByField=='EstimatedAttendees'){
                if(sortOrder=='ASC'){
                    if(totaOfExpectedLearners > helpFR.totaOfExpectedLearners){
                        return 1;
                    }else if(totaOfExpectedLearners == helpFR.totaOfExpectedLearners){
                        return 0;
                    }else{
                        return -1;
                    }                   
                }else {
                    if(totaOfExpectedLearners < helpFR.totaOfExpectedLearners){
                        return 1;
                    }else if(totaOfExpectedLearners == helpFR.totaOfExpectedLearners){
                        return 0;
                    }else{
                        return -1;
                    }    
                }
            }else if(sortByField=='TotalGrants'){
                if(sortOrder=='ASC'){
                    if(numberOfTables > helpFR.numberOfTables){
                        return 1;
                    }else if(numberOfTables == helpFR.numberOfTables){
                        return 0;
                    }else{
                        return -1;
                    }                   
                }else {
                    if(numberOfTables < helpFR.numberOfTables){
                        return 1;
                    }else if(numberOfTables == helpFR.numberOfTables){
                        return 0;
                    }else{
                        return -1;
                    }    
                }
            }else{
                return 0;
            }
            
               
        }
    }
    
    
    public Class RequestProgramWrapper{
        public Id reqId{get; set;}
        public string reqName{get; set;}
        public string orgName{get; set;}
        public string overallPgm{get; set;}
        public string approvedAmt{get; set;}
        public string pgmName{get; set;}
        public string pgmStartDate{get; set;}
        public string pgmEndDate{get; set;}
        public string venueName{get; set;}
        public string VenueCity{get; set;}
        public string venueState {get; set;}
        public string venueZipCode{get; set;}
        public string anySponsors{get; set;}
        public string geneSupport{get; set;}
        public string didYouExhibit{get; set;}
        public string subStatus{get; set;}
        public string businessUnit{get; set;}
        public string diseaseState{get; set;}
        public string extTrackingCode{get; set;}
    }    
}