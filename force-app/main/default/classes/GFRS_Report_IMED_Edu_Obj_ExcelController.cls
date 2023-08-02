/**
* @author GFRS Dev Team
* @date 05/08/2013
* @description GFRS_Report_IMED_Edu_Obj_ExcelController class - controller to generate report for IMED Edu in excel format  
*/
public without sharing class GFRS_Report_IMED_Edu_Obj_ExcelController{
    public GFRS_Funding_Request__c request        { get; set; }
    public List<HelperFundingRequest> eduObjsList { get; set; }
    public String startDate                       { get; set; }
    public String endDate                         { get; set; }
    public Date dateSubmitted                     { get; set; }
    public Date closedDate                        { get; set; }
    public String therapeuticArea                 { get {return this.therapeuticArea.escapeHtml4();} set;}
    
    public GFRS_Report_IMED_Edu_Obj_ExcelController()
    {
      
      request         = new GFRS_Funding_Request__c();
      therapeuticArea = System.currentPagereference().getParameters().get('Therapeutic_Area__c');
      dateSubmitted   = Date.parse(System.currentPagereference().getParameters().get('Date_Submitted__c'));
      closedDate      = Date.parse(System.currentPagereference().getParameters().get('Closed_Date__c'));
      startDate       = String.valueof(this.dateSubmitted);
      endDate         = String.valueof(this.closedDate);
      eduObjsList     = new List<HelperFundingRequest>();
      eduObjectivesData() ; 
    }
    
    /**
    * @author GFRS Dev Team
    * @date 05/08/2013
    * @description eduObjectivesData method - controller to generate report for IMED Edu in excel format  
    */
    public void eduObjectivesData()
    {
       
        try
        {
            Map<string,HelperFundingRequest> eduObjectives = new Map<string,HelperFundingRequest>();
            String fundingType = 'Independent Medical Education';
            List<GFRS_Funding_Request__c> fundingRequests = [SELECT SYS_Request_Approved__c, Educational_Objectives__c, 
                                                                    Educational_Objectives_N_to_Z__c,Total_of_Expected_Learners__c 
                                                                FROM GFRS_Funding_Request__c 
                                                                WHERE Funding_Type__c=:fundingType 
                                                                    AND Therapeutic_Area__c =:this.therapeuticArea 
                                                                    AND Date_Submitted__c >=:this.dateSubmitted 
                                                                    AND Date_Submitted__c <=:this.closedDate];
            for(GFRS_Funding_Request__c req : fundingRequests) 
            {
                String edObjs = req.Educational_Objectives__c + ';' + req.Educational_Objectives_N_to_Z__c;
                if(edObjs.trim()!=';' && edObjs.trim()!='null;null')
                {
                 
                    String[] edObjList = edObjs.split(';',0);
                    for(String edObjstr : edobjList)
                    {
                        if(edObjstr!=null && edObjstr.trim()!='' && edObjstr.trim() != 'null')
                        {
                            HelperFundingRequest newReq = new HelperFundingRequest(null,0,0,0);
                            Boolean eduObjExist         = false;
                            if(eduObjectives.containsKey(edObjstr))
                            {
                                eduObjExist = true;
                                newReq      = eduObjectives.get(edObjstr);
                            }
                            newReq.educationalObjectives  = edObjstr;
                            newReq.totaOfExpectedLearners = (eduObjExist)?((req.Total_of_Expected_Learners__c==null?0:req.Total_of_Expected_Learners__c) + newReq.totaOfExpectedLearners):(req.Total_of_Expected_Learners__c==null?0:req.Total_of_Expected_Learners__c);
                            newReq.numberOfTables         = (eduObjExist)?(newReq.numberOfTables+1):1;

                            if(req.SYS_Request_Approved__c!=null && req.SYS_Request_Approved__c=='Yes')
                            {
                                newReq.splitNumber = (eduObjExist)?(newReq.splitNumber+1):1;
                            }
                            else
                            {
                                newReq.splitNumber = (eduObjExist)?(newReq.splitNumber):0;
                            }
                            
                            eduObjectives.put(edObjstr,newReq);
                        }
                   }
               }
            }
            this.eduObjsList=eduObjectives.values();
        }
        catch(Exception ex)
        {
            system.debug('Exception: ' + ex.getmessage());
        }
    }
    
    /**
    * @author GFRS Dev Team
    * @date 05/08/2013
    * @description getReportHeader method - set header in excel file  
    */
    public String getReportHeader() {
        String ReportHeader='';
        
        ReportHeader = '<td><b>Educational Objective</b></td>';
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
        List<String> repData = new List<string>();        
        if( eduObjsList == null || eduObjsList.size() == 0)
            repData.add('<tr><td>No data found.</td></tr>');
        else {
            
            
            Integer rownum    = 0;
            Integer remainder = 0;
            String lineColor  = '';
                        
            for(HelperFundingRequest req : eduObjsList) {
            
                String dataRow = '';
                remainder      = math.mod(rownum, 2);
                if( remainder == 0)
                    lineColor = '#EDEDED';
                else
                    lineColor = '#FFFFFF';
                    
                dataRow = '<tr>';
                
                dataRow +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                dataRow += req.educationalObjectives;
                dataRow +='</td>';
                
                dataRow +='<td style="background-color:' + lineColor + '; text-align:right;vertical-align:top">';
                dataRow += req.numberOfTables;
                dataRow +='</td>';
                
                dataRow +='<td style="background-color:' + lineColor + '; text-align:right;vertical-align:top">';
                dataRow += req.splitNumber;
                dataRow +='</td>';
                
                dataRow +='<td style="background-color:' + lineColor + '; text-align:right;vertical-align:top">';
                dataRow += req.totaOfExpectedLearners;
                dataRow +='</td>';
                                                
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
    public class HelperFundingRequest{
        
        public String educationalObjectives   { get; set; }
        public Decimal totaOfExpectedLearners { get; set; }
        public Integer numberOfTables         { get; set; }
        public Integer splitNumber            { get; set; }
        
        public HelperFundingRequest(string eduObj,Decimal totExpectLearn, Integer numOfTab,Integer splitNum){
            educationalObjectives  = eduObj;
            totaOfExpectedLearners = totExpectLearn;
            numberOfTables         = numOfTab;
            splitNumber            = splitNum;
        }
        
    } 

}