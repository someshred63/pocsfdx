/**
* @author GFRS Dev Team
* @date 28/02/2015
* @description gFRS_MergMultiSelectCustomController class - controller for gFRS_MergMultiSelectCustomReport page. Class is responsible for generating report data.
  More detail under following jira: http://jira.intranet.roche.com/jira/browse/GFRS-274
*/

public without sharing class gFRS_MergMultiSelectCustomController {
    
    public GFRS_Funding_Request__c helperRequest { get; set; }
    public String selectedFundingType            { get; set; }
    public String selectedFundingTypeDesc        { get; set; }
    public String nqsPicklstVal                  { get; set; }
    public String barrierPicklstVal              { get; set; }
    public String qualityPicklstVal              { get; set; }
    public Boolean idPieChartRendered            { get; set; }
    public Decimal summarySubmitted              { get; set; }
    public Decimal summaryApproved               { get; set; }
    public Decimal summaryPercentApproved        { get; set; }
    public Decimal summaryPatients               { get; set; }
    public List<TableWrapper> reportData         { get; set; }
    public string jsonData                       { get; set; }
    public Boolean isReportDataCleard            { get; set; }
    public String dsAvailableValuesToSelect      { get; set; }
    public List<string> therapeuticAreaSelected  { get; set; }
    public List<Selectoption> leftSelectOptions  { get; set; }
    public List<Selectoption> rightSelectOptions { get; set; }
    public String whereDs                        { get; set; }
    String isExportToExcel                       { get; set; }
    //public List<PieChartWrapper> pieData{get;set;} 
    
    /**
    * @author GFRS Dev Team
    * @date 28/02/2015
    * @description class constructor settin initial data
    */
    public gFRS_MergMultiSelectCustomController(ApexPages.StandardController std){
        helperRequest = new GFRS_Funding_Request__c();
        //workaround for Grand Cordinator Profiles - don't have create priviligaes 
        //and TA DS fiels were not editabel using standard input fields
        //need to set some id of existing request request will not be modified 

        helperRequest.id       = [SELECT Id FROM gFRS_Funding_Request__c LIMIT 1].get(0).Id;
        String defaultFundType = ApexPages.currentPage().getParameters().get('fundType');
        isExportToExcel        = ApexPages.currentPage().getParameters().get('isExportToExcel');

        if(!String.isEmpty(defaultFundType)){
            selectedFundingType = defaultFundType;
            if(selectedFundingType == gFRS_Util.TYPE_IMED_NAME){

                selectedFundingTypeDesc    = gFRS_Util.TYPE_IMED_DESCRIPTION;
                helperRequest.RecordTypeId = [SELECT DeveloperName, Id, SobjectType FROM RecordType WHERE SobjectType='GFRS_Funding_Request__c' AND DeveloperName=: gFRS_Util.TYPE_IMED_NAME limit 1].get(0).Id;

            }else if(selectedFundingType == gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME){

                selectedFundingTypeDesc    = selectedFundingType;
                helperRequest.RecordTypeId = [SELECT DeveloperName, Id, SobjectType FROM RecordType WHERE SobjectType='GFRS_Funding_Request__c' AND DeveloperName='Scientific_Projects' limit 1].get(0).Id;
            }
        }
        resetAllMultiselects();
        dsAvailableValuesToSelect ='';
        rightSelectOptions        = new List<Selectoption>();
        leftSelectOptions         = new List<Selectoption>();
        therapeuticAreaSelected   = new List<String>();

        if(selectedFundingType == gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME){
            nqsPicklstVal='Yes';
        }

        idPieChartRendered = false;
        reportData         = new List<TableWrapper>();

        if(isExportToExcel == 'Yes'){

            nqsPicklstVal                            = ApexPages.currentPage().getParameters().get('nqsPicklstVal');
            barrierPicklstVal                        = ApexPages.currentPage().getParameters().get('barrierPicklstVal');
            qualityPicklstVal                        = ApexPages.currentPage().getParameters().get('qualityPicklstVal');
            helperRequest.Therapeutic_Area_Parent__c = ApexPages.currentPage().getParameters().get('TA');
            helperRequest.Therapeutic_Area__c        = ApexPages.currentPage().getParameters().get('DS');
            whereDs                                  = ApexPages.currentPage().getParameters().get('DS');

            if(nqsPicklstVal != null && nqsPicklstVal== 'Yes'){
                helperRequest.NQS_Criteria__c =ApexPages.currentPage().getParameters().get('NQS');
            }else if(barrierPicklstVal != null && barrierPicklstVal== 'Yes'){
                helperRequest.Barriers_to_Optimal_Patient_Care__c =ApexPages.currentPage().getParameters().get('BR');
            }else if(qualityPicklstVal != null && qualityPicklstVal== 'Yes'){
                helperRequest.Quality_of_Care_Components__c =ApexPages.currentPage().getParameters().get('QUALITY');
            }
            generateReport();
        }
        
        
    }
    
    public String getMuliSelectDSExcel(){
        
        String selectedDS = ApexPages.currentPage().getParameters().get('DS');
        if(!String.isEmpty(selectedDS)){
            
            return selectedDS.replace('\'', '').replace('(','').replace(')','').replace(',','<br/>');
        }
        return '';
    }
    
    /**
    * @author GFRS Dev Team
    * @date 28/02/2015
    * @description property which displaying available funding types for report
    */
    public List<SelectOption> getfundingType(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME,gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME));
        options.add(new SelectOption(gFRS_Util.TYPE_IMED_NAME,gFRS_Util.TYPE_IMED_DESCRIPTION));
        return options;
    }
    
    public void setMultiselect(){

        resetReportData();
        therapeuticAreaSelected = new List<String>();
        leftSelectOptions       = new List<SelectOption>();
        rightSelectOptions      = new List<SelectOption>();

        if(dsAvailableValuesToSelect != null && dsAvailableValuesToSelect.length() > 0){
            for(String s : dsAvailableValuesToSelect.split(',')){
                system.debug('values to render:'+s);
                if(s !='__'){
                	leftSelectOptions.add(new SelectOption(s,s));   
                }
            }
        }
    }
    
     /**
    * @author GFRS Dev Team
    * @date 28/02/2015
    * @description property which displaying available values for picklists:
    * NQS Question #1,Barriers question #2,Quality of Care Components #3
    */
    public List<SelectOption> getQuestionPickList(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('No','No'));
        options.add(new SelectOption('Yes','Yes'));
        return options;
    }
    
    /**
    * @author GFRS Dev Team
    * @date 28/02/2015
    * @description event triggered when Funding Type piclist changed
    */
    public void changeFundingType(){
        if(selectedFundingType == 'Scientific Projects'){
            nqsPicklstVal='Yes';
            changeNQS();
        }
        reportData         = new List<TableWrapper>();
        idPieChartRendered = false;
        //showApplicableMultiselect();
    }
    
    public void resetReportData(){
        reportData             = new List<TableWrapper>();
        idPieChartRendered     = false; 
        summarySubmitted       = null;
        summaryApproved        = null;
        summaryPercentApproved = null;
        summaryPatients        = null;
        
    }
    
    /**
    * @author GFRS Dev Team
    * @date 28/02/2015
    * @description method triggered when NQS Question #1 selected to Yes
    * reset other picklist values to No and reset related multiselect pickl list
    */
    public void changeNQS(){
        barrierPicklstVal             = 'No';
        qualityPicklstVal             = 'No';
        helperRequest.NQS_Criteria__c = null;

		resetReportData();       
    }
    
    /**
    * @author GFRS Dev Team
    * @date 28/02/2015
    * @description method triggered when Barriers question #2 selected to Yes
    * reset other picklist values to No and reset related multiselect pickl list
    */
    public void changeBarrier(){
        nqsPicklstVal                                     = 'No';
        qualityPicklstVal                                 = 'No';
        helperRequest.Barriers_to_Optimal_Patient_Care__c = null;

        resetReportData();
    }
    
    /**
    * @author GFRS Dev Team
    * @date 28/02/2015
    * @description method triggered when Quality of Care Components #3 selected to Yes
    * reset other picklist values to No and reset related multiselect pickl list
    */
    public void changeQuality(){
        nqsPicklstVal                               = 'No';
        barrierPicklstVal                           = 'No';
        helperRequest.Quality_of_Care_Components__c = null;
        resetReportData();
    }
    
    /**
    * @author GFRS Dev Team
    * @date 28/02/2015
    * @description method reset all multi select picklist to null
    */
    public void resetAllMultiselects(){
        helperRequest.NQS_Criteria__c                     = null;
        helperRequest.Barriers_to_Optimal_Patient_Care__c = null;
        helperRequest.Quality_of_Care_Components__c       = null;
    }
    
    /**
    * @author GFRS Dev Team
    * @date 28/02/2015
    * @description method generateReport rendering report data
    */
    
    public String renderInConditionForDs(){
        String outputString ='(';
        for(String s : therapeuticAreaSelected){
            outputString +='\''+String.escapeSingleQuotes(s)+'\',';
        }
        outputString = outputString.substring(0, outputString.length() -1);
        outputString +=')';

        return outputString;
    }

    public PageReference generateReport(){
        //reset fields
        resetReportData();
        
        if(helperRequest.Therapeutic_Area_Parent__c == null){
            helperRequest.Therapeutic_Area_Parent__c.addError(Label.gFRS_FIELD_NAME_REQUIRED1); 
            return null;
        }
		if(therapeuticAreaSelected.size() == 0){
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Disease State is required'));
            helperRequest.Therapeutic_Area__c.addError(Label.gFRS_FIELD_NAME_REQUIRED1); 
            return null;
        }
        
        String mainQuery  = 'SELECT SYS_Request_Approved__c,Record_Type_Name__c,Therapeutic_Area_Parent__c,Therapeutic_Area__c,NQS_Criteria__c,Barriers_to_Optimal_Patient_Care__c,Quality_of_Care_Components__c,Patients_treated_annually__c FROM GFRS_Funding_Request__c';
        String whreClause ='';

        if(isExportToExcel == 'Yes'){
            whreClause =' WHERE Date_Submitted__c != null AND Therapeutic_Area_Parent__c =\'' + helperRequest.Therapeutic_Area_Parent__c + '\' AND Therapeutic_Area__c =\'' + whereDs + '\' AND Record_Type_Name__c = \''+selectedFundingType + '\'';
            
        }else{
        	whreClause =' WHERE Date_Submitted__c != null AND Therapeutic_Area_Parent__c =\''+helperRequest.Therapeutic_Area_Parent__c+ '\' AND Therapeutic_Area__c =\'' + renderInConditionForDs() + '\' AND Record_Type_Name__c = \''+selectedFundingType+'\'';
        }
        
        String selectedValues = null;
        if(nqsPicklstVal == 'Yes'){

            whreClause     +=' and NQS_Criteria__c != null';
            selectedValues = helperRequest.NQS_Criteria__c;

            if(helperRequest.NQS_Criteria__c == null){
                helperRequest.NQS_Criteria__c.addError('Please select at least one value on multi-select'); 
                return null;
            }
        }else if(barrierPicklstVal == 'Yes'){

            whreClause     +=' and Barriers_to_Optimal_Patient_Care__c != null';
            selectedValues = helperRequest.Barriers_to_Optimal_Patient_Care__c;

            if(helperRequest.Barriers_to_Optimal_Patient_Care__c == null){
                helperRequest.Barriers_to_Optimal_Patient_Care__c.addError(Label.gFRS_MergRepSecifyValueMultiSelect); 
                return null;
            }
        }else if(qualityPicklstVal == 'Yes'){

            whreClause     +=' and Quality_of_Care_Components__c != null';
            selectedValues = helperRequest.Quality_of_Care_Components__c;

            if(helperRequest.Quality_of_Care_Components__c == null){
                
                helperRequest.Quality_of_Care_Components__c.addError(Label.gFRS_MergRepSecifyValueMultiSelect); 
                return null;
            }
        }else{
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.gFRS_MergRepInfoPickToYes));
            return null;
            
        }
        
        
        
        
        mainQuery += whreClause;

        if(selectedValues == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.gFRS_MergRepSecifyValueMultiSelect));
            return null;
        }
        
        Map<String,TableWrapper> tableWrapperMap = new Map<String,TableWrapper>();
        
        for(String s : selectedValues.split(';')){
            for(GFRS_Funding_Request__c request : (List<GFRS_Funding_Request__c>)Database.query(mainQuery)){
                if(nqsPicklstVal == 'Yes' && request.NQS_Criteria__c.contains(s)){
                    if(tableWrapperMap.containsKey(s)){
                        tableWrapperMap.put(s,populateValuesForSingleTableItem(s,tableWrapperMap.get(s),request));
                    }else{
                        tableWrapperMap.put(s,populateValuesForSingleTableItem(s,null,request));
                    }
                }else if(barrierPicklstVal == 'Yes' && request.Barriers_to_Optimal_Patient_Care__c.contains(s)){
                    if(tableWrapperMap.containsKey(s)){
                        tableWrapperMap.put(s,populateValuesForSingleTableItem(s,tableWrapperMap.get(s),request));
                    }else{
                        tableWrapperMap.put(s,populateValuesForSingleTableItem(s,null,request));
                    }
                    
                }else if(qualityPicklstVal == 'Yes' && request.Quality_of_Care_Components__c.contains(s)){
                    if(tableWrapperMap.containsKey(s)){
                        tableWrapperMap.put(s,populateValuesForSingleTableItem(s,tableWrapperMap.get(s),request));
                    }else{
                        tableWrapperMap.put(s,populateValuesForSingleTableItem(s,null,request));
                    }
                }
            }
        }
        
        if(tableWrapperMap.size()>0){

            this.idPieChartRendered = true;
            GoogleViz gv            = new GoogleViz();
            gv.cols                 = new list<GoogleViz.col> { 
                                                new GoogleViz.Col('col1','Multi Select Picklist','string'),
                                                new GoogleViz.Col('col2','Number of Tables','number')
                                              };
                        
            summarySubmitted = 0;
            summaryApproved  = 0;
            summaryPatients  = 0;
            system.debug(JSON.serialize(tableWrapperMap.values()));
            for(TableWrapper t : tableWrapperMap.values()){

                summarySubmitted += t.totalSubmitted;
    			summaryApproved  += t.numbOfApprovedGrants;
                summaryPatients  += t.numberOfPatients!=null?t.numberOfPatients:0;
                GoogleViz.row r = new GoogleViz.row();
                r.cells.add ( new GoogleViz.cell(t.pickListVal));
                r.cells.add ( new GoogleViz.cell(t.numbOfApprovedGrants));
                /*
                if(t.numbOfApprovedGrants >0){
                	PieChartWrapper pWrap =new PieChartWrapper(t.pickListVal, t.numbOfApprovedGrants);
                	pieData.add(pWrap);    
                }
                */
                gv.addRow(r);
            }
            //summaryPercentApproved
            summaryPercentApproved = (summaryApproved/summarySubmitted)*100;
            this.jsonData          = gv.toJsonString();
            reportData             = tableWrapperMap.values();
            
        }else{
            system.debug('was here');
            this.idPieChartRendered = false;
        }
        return null;
        
        
        
        
    }
    
    public TableWrapper populateValuesForSingleTableItem(String pickListVal, TableWrapper item,GFRS_Funding_Request__c req){
        if(item == null){

            TableWrapper tableWrap         = new TableWrapper();
            tableWrap.pickListVal          = pickListVal;
            tableWrap.numbOfApprovedGrants = req.SYS_Request_Approved__c == 'Yes' ? 1 : 0;
            tableWrap.totalSubmitted       = 1;
            tableWrap.totalApprovedPercent = ( tableWrap.numbOfApprovedGrants/ tableWrap.totalSubmitted) * 100;
            tableWrap.isReqApproved        = 'Yes'.equals(req.SYS_Request_Approved__c) ? true: false; 

            if(tableWrap.isReqApproved){
                tableWrap.numberOfPatients = req.Patients_treated_annually__c == null ? 0 : req.Patients_treated_annually__c;
            }
            else {
            	tableWrap.numberOfPatients = tableWrap.numberOfPatients==null ? 0  :tableWrap.numberOfPatients;
            }       
            return tableWrap;
        }else{
            item.numbOfApprovedGrants = req.SYS_Request_Approved__c == 'Yes' ? item.numbOfApprovedGrants+1 : item.numbOfApprovedGrants;
            item.totalSubmitted       += 1;
            item.totalApprovedPercent = ( item.numbOfApprovedGrants/ item.totalSubmitted) * 100;
            item.isReqApproved        = 'Yes'.equals(req.SYS_Request_Approved__c) ? true: false;  

            if(item.isReqApproved){          
          	  item.numberOfPatients = req.Patients_treated_annually__c == null ? item.numberOfPatients : item.numberOfPatients+req.Patients_treated_annually__c;
            }
            else {
            	item.numberOfPatients = item.numberOfPatients==null ? 0  :item.numberOfPatients;
            }                             
            return item;
        }
    }
    
    public class TableWrapper{
        public Boolean isReqApproved        { get; set; } 
        public String pickListVal           { get; set; }
        public Decimal numbOfApprovedGrants { get; set; }
        public Decimal totalSubmitted       { get; set; }
        public Decimal totalApprovedPercent { get; set; }
        public Decimal numberOfPatients     { get; set; }
        
    }
    
    public class PieChartWrapper{
        String picklistVal              { get; set; }
        Decimal numberOfApprovedRequest { get; set; }
        
        public PieChartWrapper(String cPicklistVal, Decimal cNumberOfApprovedRequest){
            this.picklistVal             = cPicklistVal;
            this.numberOfApprovedRequest = cNumberOfApprovedRequest;
        }
    }
    
    public String getReportHeader() {
        String ReportHeader='';
        
        ReportHeader ='<td><b>Selected multi-select question</b></td>';
        ReportHeader +='<td><b># Approved grants</b></td>';
        ReportHeader +='<td><b>Total submitted grants</b></td>';
        ReportHeader +='<td><b>Total Approved %</b></td>';

        if(selectedFundingType == gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME){
            ReportHeader +='<td><b># of Patients</b></td>';
        }
                                
        return ReportHeader;
    }
    
    public List<String> getSelectedValuesOnMultiselect(){
        if(nqsPicklstVal == 'Yes'){
            if(helperRequest.NQS_Criteria__c != null){
                return helperRequest.NQS_Criteria__c.split(';');
            }
            return new List<String>();
        }else if(barrierPicklstVal == 'Yes'){
            if(helperRequest.Barriers_to_Optimal_Patient_Care__c != null){
                return helperRequest.Barriers_to_Optimal_Patient_Care__c.split(';');
            }
            return new List<String>();
        }else if(qualityPicklstVal == 'Yes'){
            if(helperRequest.Quality_of_Care_Components__c != null){
                return helperRequest.Quality_of_Care_Components__c.split(';');
            }
            return new List<String>();
        }else{
            return new List<String>();
        }
    }
    
    public List<String> getDataRows() {

        List<String> repData = new List<String>();        

        if( reportData == null || reportData.size() == 0)
            repData.add('<tr><td>No data found.</td></tr>');
        else {
            
            
            Integer rownum    = 0;
            Integer remainder = 0;
            String lineColor  = '';
                        
            for(TableWrapper req : reportData) {
            
                String dataRow = '';
                remainder = math.mod(rownum, 2);
                if( remainder == 0)
                    lineColor = '#EDEDED';
                else
                    lineColor = '#FFFFFF';
                    
                dataRow = '<tr>';
                
                dataRow +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
                dataRow += req.pickListVal;
                dataRow +='</td>';
                
                dataRow +='<td style="background-color:' + lineColor + '; text-align:right;vertical-align:top">';
                dataRow += req.numbOfApprovedGrants;
                dataRow +='</td>';
                
                dataRow +='<td style="background-color:' + lineColor + '; text-align:right;vertical-align:top">';
                dataRow += req.totalSubmitted;
                dataRow +='</td>';
                
                dataRow +='<td style="background-color:' + lineColor + '; text-align:right;vertical-align:top">';
                dataRow += req.totalApprovedPercent.setScale(2);
                dataRow +='</td>';
                
                if(selectedFundingType == gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME){
                    dataRow +='<td style="background-color:' + lineColor + '; text-align:right;vertical-align:top">';
                    dataRow += req.numberOfPatients;
                    dataRow +='</td>';
                }
                                                
                dataRow +='</tr>';
                repData.add(dataRow);
                rownum +=1;
                
                                       
            }
            //add table footer
            lineColor='#FFFFFF';
            String dataRow = '<tr>';
                
            dataRow +='<td style="background-color:' + lineColor + '; text-align:left;vertical-align:top">';
            dataRow += '<b>Total</b>';
            dataRow +='</td>';
            
            dataRow +='<td style="background-color:' + lineColor + '; text-align:right;vertical-align:top">';
            dataRow += '<b>'+String.valueOF(summaryApproved)+'</b>';
            dataRow +='</td>';
            
            dataRow +='<td style="background-color:' + lineColor + '; text-align:right;vertical-align:top">';
            dataRow += '<b>'+String.valueOF(summarySubmitted)+'</b>';
            dataRow +='</td>';
            
            dataRow +='<td style="background-color:' + lineColor + '; text-align:right;vertical-align:top">';
            dataRow += '<b>'+summaryPercentApproved.setScale(2) +'</b>';
            dataRow +='</td>';
            
            if(selectedFundingType == gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME){
                dataRow +='<td style="background-color:' + lineColor + '; text-align:right;vertical-align:top">';
                dataRow += '<b>'+summaryPatients+'</b>';
                dataRow +='</td>';
            }
            
            dataRow +='</tr>';
            repData.add(dataRow);
        }
                        
        return repData;
    }
    
    public PageReference exportToExcel(){
        if(reportData == null || reportData.size() == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.gFRS_MergRepInfoExportNoData));
            return null;
        }
        
       
        PageReference excelPage = new PageReference('/apex/gFRS_MergMultiSelectReportExcel');

        excelPage.getParameters().put('isExportToExcel','Yes');
        excelPage.getParameters().put('fundType',selectedFundingType);
        excelPage.getParameters().put('fundType',selectedFundingType);
        excelPage.getParameters().put('TA',helperRequest.Therapeutic_Area_Parent__c);
        excelPage.getParameters().put('DS',renderInConditionForDs());
        
        if(nqsPicklstVal != null && nqsPicklstVal== 'Yes'){
            excelPage.getParameters().put('nqsPicklstVal',nqsPicklstVal);
            excelPage.getParameters().put('NQS',helperRequest.NQS_Criteria__c);
        }else if(barrierPicklstVal != null && barrierPicklstVal== 'Yes'){
            excelPage.getParameters().put('barrierPicklstVal',barrierPicklstVal);
            excelPage.getParameters().put('BR',helperRequest.Barriers_to_Optimal_Patient_Care__c);
        }else if(qualityPicklstVal != null && qualityPicklstVal== 'Yes'){
            excelPage.getParameters().put('qualityPicklstVal',qualityPicklstVal);
            excelPage.getParameters().put('QUALITY',helperRequest.Quality_of_Care_Components__c);
        }
        
		excelPage.setRedirect(false);
		return excelPage;
    }
}