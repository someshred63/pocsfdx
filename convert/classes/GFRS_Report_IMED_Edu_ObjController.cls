/**
* @author GFRS Dev Team
* @date 05/08/2013
* @description GFRS_Report_IMED_Edu_ObjController class - controller to generate report for IMED Edu  
*/
public without sharing class GFRS_Report_IMED_Edu_ObjController {

    public GFRS_Funding_Request__c request        { get; set; }
    public List<HelperFundingRequest> eduObjsList { get; set; }
    public Boolean isGraphRender                  { get; set; }
    public String jsonData                        { get; set; }
    public String dateSubmitted                   { get; set; }
    public String closedDate                      { get; set; }
    public List<string> therapeuticAreaSelected   { get; set; }
    public List<Selectoption> leftSelectOptions;
    public List<Selectoption> rightSelectOptions  { get; set; }
    
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
    
    public GFRS_Report_IMED_Edu_ObjController(ApexPages.StandardController std ){

      request                 = (GFRS_Funding_Request__c)std.getRecord();
      eduObjsList             = new list<HelperFundingRequest>();  
      dateSubmitted           = '11/6/2011';
      closedDate              = Date.today().format();
      isGraphRender           = false;
      jsonData                = '';
      rightSelectOptions      = new List<Selectoption>();
      leftSelectOptions       = getTherapeuticArea();
      therapeuticAreaSelected = new List<String>();
    }
    
    /**
    * @author GFRS Dev Team
    * @date 05/08/2013
    * @description getTherapeuticArea method - getter method to which return all defined options in  Therapeutic_Area__c field under GFRS_Funding_Request__c custom object  
    */
    public List<Selectoption> getTherapeuticArea(){
        Schema.DescribeFieldResult taField = GFRS_Funding_Request__c.Therapeutic_Area__c.getDescribe();
        List<Selectoption> taOptions       = new List<Selectoption>();
        for(Schema.PicklistEntry taVal : taField.getPicklistValues()){
            taOptions.add(new Selectoption(taVal.getLabel(),taVal.getValue()));
        }
        return taOptions;
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
           ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Please select Disease State'));
        }
        if(String.isEmpty(dateSubmitted)){
            isFilterEmpty=true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Date Submitted From : You must enter a value'));   
        }
        if(String.isEmpty(closedDate)){
            isFilterEmpty=true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'To : You must enter a value'));
        }
            
        if(isFilterEmpty)
        {
            return null;
        }
        
        Pagereference renderedReport = eduObjectivesData();
        
        //return( new ApexPages.PageReference('apex/GFRS_Report_IMED_Edu_Obj_Excel'));
        PageReference excelPage = new PageReference('/apex/GFRS_Report_IMED_Edu_Obj_Excel');
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
               ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Please select Disease State'));
            }
            if(String.isEmpty(dateSubmitted)){
                isFilterEmpty=true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Date Submitted From : You must enter a value'));   
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
            
            Map<String,HelperFundingRequest> eduObjectives = new Map<String,HelperFundingRequest>();
            
            String fundingType = 'Independent Medical Education';
            List<GFRS_Funding_Request__c> fundingRequests = [SELECT SYS_Request_Approved__c, Educational_Objectives__c,
                                                                    Educational_Objectives_N_to_Z__c, Total_of_Expected_Learners__c,Therapeutic_Area__c
                                                            FROM GFRS_Funding_Request__c 
                                                            WHERE Funding_Type__c =:fundingType 
                                                                AND Therapeutic_Area__c IN : this.therapeuticAreaSelected 
                                                                AND Date_Submitted__c>=:Date.parse(this.dateSubmitted) 
                                                                AND Date_Submitted__c<=:Date.parse(this.closedDate) 
                                                                ORDER BY Therapeutic_Area__c ASC];
            for(GFRS_Funding_Request__c req : fundingRequests) 
            {
                String edObjs = req.Educational_Objectives__c + ';' + req.Educational_Objectives_N_to_Z__c;
                if(edObjs.trim()!=';' && edObjs.trim()!='null;null')
                {
                    String[] edObjList = edObjs.split(';',0);
                    for(String edObjstr : edobjList)
                    {
                        if(edObjstr != null && edObjstr.trim() !='' && edObjstr.trim() != 'null')
                        {
                            HelperFundingRequest newReq = new HelperFundingRequest(null,0,0,0);
                            Boolean eduObjExist = false;
                            if(eduObjectives.containsKey(edObjstr))
                            {
                                eduObjExist=true;
                                newReq=eduObjectives.get(edObjstr);
                            }
                            newReq.educationalObjectives  = edObjstr;
                            newReq.totaOfExpectedLearners = (eduObjExist)?((req.Total_of_Expected_Learners__c==null?0:req.Total_of_Expected_Learners__c) + newReq.totaOfExpectedLearners):(req.Total_of_Expected_Learners__c==null?0:req.Total_of_Expected_Learners__c);
                            newReq.numberOfTables         = (eduObjExist)?(newReq.numberOfTables+1):1;

                            if(req.SYS_Request_Approved__c != null && req.SYS_Request_Approved__c == 'Yes')
                            {
                                newReq.splitNumber = (eduObjExist)?(newReq.splitNumber+1):1;
                            }
                            else
                            {
                                newReq.splitNumber = (eduObjExist)?(newReq.splitNumber):0;
                            }
                            newReq.diseaseState = req.Therapeutic_Area__c;
                            eduObjectives.put(edObjstr,newReq);
                           
                        }
                   }
               }
            }
            this.eduObjsList = eduObjectives.values();
            String sortOrder = getSortDirection();
            for(HelperFundingRequest item : eduObjsList){

                item.sortOrder = sortOrder;
                item.sortByField = sortExpression;
            }
            eduObjsList.sort();     
            if(eduObjsList.size()>0){
                this.isGraphRender = true;
                GoogleViz gv       = new GoogleViz();
                gv.cols = new list<GoogleViz.col> { 
                    new GoogleViz.Col('col1','Education Objectives','string'),
                    new GoogleViz.Col('col2','Number of Tables','number')
                };
                for(HelperFundingRequest fr:this.eduObjsList){
                    GoogleViz.row r = new GoogleViz.row();
                    r.cells.add ( new GoogleViz.cell(fr.educationalObjectives));
                    r.cells.add ( new GoogleViz.cell(fr.numberOfTables));
                    gv.addRow(r);
                }
                this.jsonData = gv.toJsonString();
            }else{
                this.isGraphRender = false;
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
        ReportHeader = '<td><b>Disease State</b></td>';
        ReportHeader += '<td><b>Educational Objective</b></td>';
        ReportHeader += '<td><b>Total # of Grants</b></td>';
        ReportHeader += '<td><b># Approved Grants</b></td>';
        ReportHeader += '<td><b># of Estimated Attendees</b></td>';
                                
        return ReportHeader;
    }
    
    /**
    * @author GFRS Dev Team
    * @date 05/08/2013
    * @description getReportData method - write rows with data in excel file.
    */
     public List<String> getReportData() {
        List<String> repData = new list<string>();        
        if( eduObjsList == null || eduObjsList.size() == 0)
            repData.add('<tr><td>No data found.</td></tr>');
        else {
            
            
            Integer rownum    = 0;
            Integer remainder = 0;
            String lineColor  = '';
                        
            for(HelperFundingRequest req : eduObjsList) {
            
                String dataRow = '';
                remainder = math.mod(rownum, 2);
                if( remainder == 0)
                    lineColor = '#EDEDED';
                else
                    lineColor = '#FFFFFF';
                    
                dataRow = '<tr>';
                
                dataRow += '<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                dataRow += req.diseaseState;
                dataRow += '</td>';
                
                dataRow += '<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                dataRow += req.educationalObjectives;
                dataRow += '</td>';
                
                dataRow += '<td style="background-color:' + lineColor + '; text-align:right;vertical-align:top">';
                dataRow += req.numberOfTables;
                dataRow += '</td>';
                
                dataRow += '<td style="background-color:' + lineColor + '; text-align:right;vertical-align:top">';
                dataRow += req.splitNumber;
                dataRow += '</td>';
                
                dataRow += '<td style="background-color:' + lineColor + '; text-align:right;vertical-align:top">';
                dataRow += req.totaOfExpectedLearners;
                dataRow += '</td>';
                                                
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
    
}