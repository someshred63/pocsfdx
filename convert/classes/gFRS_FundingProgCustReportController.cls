public without sharing class gFRS_FundingProgCustReportController {
    public GFRS_Funding_Request__c helperRequest {get;set;}
    public String dsAvailableValuesToSelect {get;set;}
    public String selectedFundingType{get;set;}
    public String selectedSubStatus{get;set;}
    public String selectedTaxStatus{get;set;}
    public String datename{get;set;}
    public String datename1{get;set;}
    public String reportErrMsg{get;set;}
    private List<ReportWrapper> reportData;
    public List<string> fundingTypeSelected{get;set;}
    public List<Selectoption> ftLeftOptions{get;set;}
    public List<Selectoption> ftRightSelectOptions{get;set;}
    public List<string> subStatusesSelected{get;set;}
    public List<Selectoption> subStatusesLeftOptions{get;set;}
    public List<Selectoption> subStatusesRightOptions{get;set;}

    public String gFRS_ReqProg_Rep_FR_1_API {get {return 'Name,Record_Type_Name__c';} set;}
    public String gFRS_ReqProg_Rep_Org_API  {get{return 'Organization__r.Name,Organization__r.Organization_Name__c,Organization__r.Type__c,Organization__r.Tax_Id__c,Organization__r.Tax_Status__c,Organization__r.Country__c';} set;}
    public String gFRS_ReqProg_Rep_Location_API {get{return 'Location__r.Name,Location__r.Address__c,Location__r.City__c,Location__r.Zip__c,Location__r.Province_Region_Territory__c,Location__r.Department_Chapter_Country__c';} set;}
    public String gFRS_ReqProg_Rep_Payment_API {get{return 'Payment_Method__c,Payment_Block__c,Status__c,Payment_Sub_status__c,Check_Number__c,Encashment_Date__c,Date__c,SAP_Payment_Sent_Date__c';} set;}
    public String gFRS_ReqProg_Rep_FR_2_API {get{return 'Status__c,Sub_Status__c,Date_Submitted__c,Program_Start_Date_Min__c,Decision_Date__c,HC_Compliance_Date__c,Business_Unit_2__c,Therapeutic_Area_Parent__c,Therapeutic_Area__c,Event_Project_type__c,Event_Program_Title__c,Requested_Amount__c,Approved_Amount__c,Refundable_Deposit_Amount_if_any__c,CCO_Owner__c,Owner.Name,Accountable_Employee_Approval__r.Name,Business_Reviewer_1__r.Name,Business_Approver__r.Name,Business_Approver_2__r.Name,Business_Approver_3__r.Name,Legal_Reviewer_1__r.Name,Financial_Approver_1__r.Name,Financial_Approver_2__r.Name,Financial_Approver_3__r.Name,Venue_City__c';} set;}
    public String gFRS_ReqProg_Rep_Prog_API {get{return 'Name,Start_Date__c,End_Date__c,Expected_Number_of_Attendees__c,Expected_of_attendees_that_are_HCPs__c,Product_being_Promoted__c,Booth_Type__c,Size_of_Exhibit__c,Number_of_Tables__c,Actual_Time_at_Display_Table_Hours__c,Venue_Name__c,Venue_City__c,Venue_State__c,Venue_Province_Region__c,Venue_Zip_Code__c,Venue_Country__c';} set;}
    public String gFRS_ReqProg_Rep_FLI_API {get{return 'Cost_Center__c,Cost_Center_Description__c,WBS__c,WBS_Description__c,GL_Account_Code__c';} set;}
    public List<string> therapeuticAreaSelected{get;set;}
    public List<Selectoption> leftSelectOptions{get;set;}
    public List<Selectoption> rightSelectOptions{get;set;}
    public String sapPaymentSentFrom{get;set;}
    public String sapPaymentSentTo{get;set;}
    public String dateSubmittedFrom{get;set;}
    public String dateSubmittedTo{get;set;}
    public String firstProgramStartDateFrom{get;set;}
    public String firstProgramStartDateTo{get;set;}
    public String decisionDateFrom{get;set;}
    public String decisionDateTo{get;set;}
    public String hcComplianceDateFrom{get;set;}
    public String hcComplianceDateTo{get;set;}
    public String whereDs{get;set;}
    public String excelOrgType{get;set;}
    public Integer rowLimit{get;set;}
    String isExportToExcel{get;set;}
    public String instanceUrl{get;set;}
    public String orgType{get;set;}

    /**
    * @author GFRS Dev Team
    * @date 17/03/2015
    * @description controller constructor
    */
    public gFRS_FundingProgCustReportController(ApexPages.StandardController std){
        rowLimit=1000;
        system.debug('page constructor executed');
        instanceUrl = URL.getSalesforceBaseUrl().toExternalForm();
        isExportToExcel = ApexPages.currentPage().getParameters().get('isExportToExcel');
        helperRequest = new GFRS_Funding_Request__c();
        //workaround for Grand Cordinator Profiles - don't have create priviligaes 
        //and TA DS fiels were not editabel using standard input fields
        //need to set some id of existing request request will not be modified 
        helperRequest.id = [Select id from gFRS_Funding_Request__c where Record_Type_Name__c =: gFRS_Util.TYPE_IMED_NAME limit 1].get(0).Id;
        if(isExportToExcel == 'Yes'){
            system.debug('exported in excel');
            sapPaymentSentFrom = ApexPages.currentPage().getParameters().get('sapPaymentSentFrom');
            system.debug(sapPaymentSentFrom);
            sapPaymentSentTo = ApexPages.currentPage().getParameters().get('sapPaymentSentTo');
            system.debug(sapPaymentSentTo);
            dateSubmittedFrom = ApexPages.currentPage().getParameters().get('dateSubmittedFrom');
            system.debug(dateSubmittedFrom);
            dateSubmittedTo = ApexPages.currentPage().getParameters().get('dateSubmittedTo');
            system.debug(dateSubmittedTo);
            firstProgramStartDateFrom = ApexPages.currentPage().getParameters().get('firstProgramStartDateFrom');
            system.debug(firstProgramStartDateFrom);
            firstProgramStartDateTo = ApexPages.currentPage().getParameters().get('firstProgramStartDateTo');
            system.debug(firstProgramStartDateTo);
            decisionDateFrom = ApexPages.currentPage().getParameters().get('decisionDateFrom');
            system.debug(decisionDateFrom);
            decisionDateTo = ApexPages.currentPage().getParameters().get('decisionDateTo');
            system.debug(decisionDateTo);
            system.debug(ApexPages.currentPage().getParameters().get('DS'));
            system.debug(ApexPages.currentPage().getParameters().get('FT'));
            //excelPage.getParameters().put('FT',selectedFundingType);
            helperRequest.Business_Unit_2__c = ApexPages.currentPage().getParameters().get('BU');
            system.debug(helperRequest.Business_Unit_2__c);
            system.debug(ApexPages.currentPage().getParameters().get('SubStatuses'));
            excelOrgType = ApexPages.currentPage().getParameters().get('OrgType');
            system.debug(excelOrgType);
            selectedTaxStatus = ApexPages.currentPage().getParameters().get('TaxStatus');
            system.debug(selectedTaxStatus);
            helperRequest.Therapeutic_Area_Parent__c = ApexPages.currentPage().getParameters().get('TA');
            system.debug(helperRequest.Therapeutic_Area_Parent__c);
            system.debug('before method execution');
            reportData = getReportDateForExcel(ApexPages.currentPage().getParameters().get('FT'),ApexPages.currentPage().getParameters().get('TA'),ApexPages.currentPage().getParameters().get('BU'),ApexPages.currentPage().getParameters().get('DS'),ApexPages.currentPage().getParameters().get('SubStatus'),ApexPages.currentPage().getParameters().get('OrgType'),ApexPages.currentPage().getParameters().get('TaxStatus'), sapPaymentSentFrom, sapPaymentSentTo, dateSubmittedFrom, dateSubmittedTo, firstProgramStartDateFrom, firstProgramStartDateTo, decisionDateFrom, decisionDateTo,hcComplianceDateFrom,hcComplianceDateTo);
            system.debug(reportData);
        }

        dsAvailableValuesToSelect='';
        rightSelectOptions=new List<Selectoption>();
        leftSelectOptions= new List<Selectoption>();
        therapeuticAreaSelected=new List<String>();

        fundingTypeSelected = new List<string>();
        ftLeftOptions = getFundingType();
        ftRightSelectOptions = new List<Selectoption>();

        subStatusesSelected = new List<String>();
        subStatusesLeftOptions = getSubstatuses();
        subStatusesRightOptions = new List<Selectoption>();

    }

    /**
    * @author GFRS Dev Team
    * @date 17/03/2015
    * @description method bindValues is responsibel for make callout to create excell file
    * getting all parameters passed from previous page and making qury to retrive applicable rows
    */
    public void bindValuesWhileForExcelDocument(){
        sapPaymentSentFrom = ApexPages.currentPage().getParameters().get('sapPaymentSentFrom');
        sapPaymentSentTo = ApexPages.currentPage().getParameters().get('sapPaymentSentTo');
        dateSubmittedFrom = ApexPages.currentPage().getParameters().get('dateSubmittedFrom');
        dateSubmittedTo = ApexPages.currentPage().getParameters().get('dateSubmittedTo');
        firstProgramStartDateFrom = ApexPages.currentPage().getParameters().get('firstProgramStartDateFrom');
        firstProgramStartDateTo = ApexPages.currentPage().getParameters().get('firstProgramStartDateTo');
        decisionDateFrom = ApexPages.currentPage().getParameters().get('decisionDateFrom');
        decisionDateTo = ApexPages.currentPage().getParameters().get('decisionDateTo');

        hcComplianceDateFrom = ApexPages.currentPage().getParameters().get('hcComplianceDateFrom');
        hcComplianceDateTo = ApexPages.currentPage().getParameters().get('hcComplianceDateTo');

        //excelPage.getParameters().put('FT',selectedFundingType);
        helperRequest.Business_Unit_2__c = ApexPages.currentPage().getParameters().get('BU');
        selectedSubStatus = ApexPages.currentPage().getParameters().get('SubStatus');
        excelOrgType = ApexPages.currentPage().getParameters().get('OrgType');
        selectedTaxStatus = ApexPages.currentPage().getParameters().get('TaxStatus');
        helperRequest.Therapeutic_Area_Parent__c = ApexPages.currentPage().getParameters().get('TA');
        reportData = new list<ReportWrapper>();
        reportData = getReportDateForExcel(ApexPages.currentPage().getParameters().get('FT'),ApexPages.currentPage().getParameters().get('TA'),ApexPages.currentPage().getParameters().get('BU'),ApexPages.currentPage().getParameters().get('DS'),ApexPages.currentPage().getParameters().get('SubStatus'),ApexPages.currentPage().getParameters().get('OrgType'),ApexPages.currentPage().getParameters().get('TaxStatus'), sapPaymentSentFrom, sapPaymentSentTo, dateSubmittedFrom, dateSubmittedTo, firstProgramStartDateFrom, firstProgramStartDateTo, decisionDateFrom, decisionDateTo,hcComplianceDateFrom,hcComplianceDateTo);
        system.debug(reportData);
    }

    /**
    * @author GFRS Dev Team
    * @date 17/03/2015
    * @description getter method to return all avaliable Funding Types in system
    */
    public List<SelectOption> getFundingType(){
        List<SelectOption> fundingTypes = new List<SelectOption>();
        for(RecordType rt : [select DeveloperName, Name, SobjectType from RecordType where SobjectType='GFRS_Funding_Request__c']){
            fundingTypes.add(new SelectOption(rt.Name,rt.Name));
        }
        return fundingTypes;
    }

    /**
    * @author GFRS Dev Team
    * @date 11/06/2015
    * @description getter method to return all avaliable Funding Request Sub Status values
    */
    public List<SelectOption> getSubStatuses(){
        List<SelectOption> subStats =new List<SelectOption>();
        for(PicklistEntry ent : GFRS_Funding_Request__c.Sub_Status__c.getDescribe().getPicklistValues()){
            subStats.add(new SelectOption(ent.getValue() ,ent.getLabel()));
        }
        return subStats;
    }

    /**
    * @author GFRS Dev Team
    * @date 17/03/2015
    * @description getter method to return all avaliable Organization Tax Status field values
    */
    public List<SelectOption> getTaxStatus(){
        List<SelectOption> taxStats =new List<SelectOption>();
        taxStats.add(new SelectOption('','--None--'));
        for(PicklistEntry ent : GFRS_Organization__c.Tax_Status__c.getDescribe().getPicklistValues()){
            taxStats.add(new SelectOption(ent.getValue() ,ent.getLabel()));
        }
        return taxStats;
    }

    /**
    * @author GFRS Dev Team
    * @date 17/03/2015
    * @description getter method to return all datta which apply initial criteria
    */
    public List<ReportWrapper> GetreportData(){
        return reportData;
    }

    /**
    * @author GFRS Dev Team
    * @date 17/03/2015
    * @description reset fields 
    */
    public void resetFields(){
        helperRequest.Therapeutic_Area_Parent__c='';
        dsAvailableValuesToSelect ='';
        reportData=new List<ReportWrapper>();
        therapeuticAreaSelected = new List<String>();
        leftSelectOptions = new List<SelectOption>();
        rightSelectOptions = new List<SelectOption>();
    }


    /**
    * @author GFRS Dev Team
    * @date 17/03/2015
    * @description setting values for Desese State Multiselect List depending on selecte TA 
    */
    public void setMultiselect(){
        reportData=new List<ReportWrapper>();
        therapeuticAreaSelected = new List<String>();
        leftSelectOptions = new List<SelectOption>();
        rightSelectOptions = new List<SelectOption>();
        if(dsAvailableValuesToSelect != null && dsAvailableValuesToSelect.length() > 0){
            for(String s : dsAvailableValuesToSelect.split(',')){
                if(s !='__'){
                    leftSelectOptions.add(new SelectOption(s,s));
                }
            }
        }
    }


     /**
    * @author GFRS Dev Team
    * @date 17/03/2015
    * @description remove quotes form DS selected values
    */
    public String renderInConditionForDs(){
        String outputString ='(';
        for(String s : therapeuticAreaSelected){
            outputString +='\''+String.escapeSingleQuotes(s)+'\',';
        }
        outputString = outputString.substring(0, outputString.length() -1);
        system.debug('in DS clause looks as following:'+outputString);
        outputString +=')';
        return outputString;
    }

     /**
    * @author GFRS Dev Team
    * @date 17/03/2015
    * @description helper method used to generate propere where clause for Multiselect fields
    */
    public static String renderInConditionForDsRemote(List<String> ds){
        String outputString ='(';
        for(String s : ds){
            outputString +='\''+String.escapeSingleQuotes(s)+'\',';
        }
        outputString = outputString.substring(0, outputString.length() -1);
        system.debug('in DS clause looks as following:'+outputString);
        outputString +=')';
        return outputString;
    }


     /**
    * @author GFRS Dev Team
    * @date 17/03/2015
    * @description getReportDateForExcel method retrive all applicable records for excel sheet
    */
    public static List<ReportWrapper> getReportDateForExcel(String selectedFundingType,String ta,String bi,String Ds,String SubStatus,String orgType,String taxStatus,String sapPaymentDateFrom,String sapPaymentDateTo,String dateSubmittedFrom,String dateSubmittedTo,String firstProgramFrom,String firstProgramTo,String decisionDateFrom,String decisionDateTo,String hcComplianceDateFrom,String hcComplianceDateTo){
        system.debug('getReportDateForExcel');

        String mainQuery = 'select Foundation_Classified__c,Id,Name,Record_Type_Name__c,Organization__r.Name,Organization__r.Organization_Name__c,Organization__r.Type__c,Organization__r.Tax_Id__c,Organization__r.Tax_Status__c,Organization__r.Country__c,'+
                            'Location__r.Id,Location__r.Name,Location__r.Address__c, Location__r.City__c,Location__r.Zip__c,Location__r.Province_Region_Territory__c,Location__r.Department_Chapter_Country__c,'+
                            '(select Id,Payment_Method__c,Payment_Block__c,Status__c,Payment_Sub_status__c,Check_Number__c,Encashment_Date__c,Date__c,SAP_Payment_Sent_Date__c from Payment_History__r limit 100),'+
                            'Status__c,Sub_Status__c,Date_Submitted__c,Program_Start_Date_Min__c,Decision_Date__c,HC_Compliance_Date__c,Business_Unit_2__c,Therapeutic_Area__c,Therapeutic_Area_Parent__c,Event_Project_type__c,Event_Program_Title__c,Requested_Amount__c,Approved_Amount__c,Refundable_Deposit_Amount_if_any__c,CCO_Owner__c,Owner.Name,Owner_First_Name_Last_Name__c,Accountable_Employee_Approval__r.Name,'+
                            'Business_Reviewer_1__r.Name,Business_Approver__r.Name,Business_Approver_2__r.Name,Business_Approver_3__r.Name,Legal_Reviewer_1__r.Name,Financial_Approver_1__r.Name,Financial_Approver_2__r.Name,Financial_Approver_3__r.Name,Venue_City__c,'+
                            '(select Id,Name,Start_Date__c,End_Date__c,Expected_Number_of_Attendees__c,Expected_of_attendees_that_are_HCPs__c,Product_being_Promoted__c,Booth_Type__c,Size_of_Exhibit__c,Number_of_Tables__c,Actual_Time_at_Display_Table_Hours__c,Venue_Name__c,Venue_City__c,Venue_State__c,Venue_Province_Region__c,Venue_Zip_Code__c,Venue_Country__c from Request_Delivery_Formats__r limit 100)'+
                            ' from GFRS_Funding_Request__c';

        String whreClause ='';

        if(selectedFundingType != null && selectedFundingType != ''){
            if(whreClause != '' && whreClause.containsIgnoreCase('where')){
                whreClause +=' and Record_Type_Name__c = \'' + selectedFundingType + '\'';
            }else{
                whreClause =' where Record_Type_Name__c = \'' + selectedFundingType + '\'';
            }
        }
        if(ta != null && ta != ''){
            if(whreClause != '' && whreClause.containsIgnoreCase('where')){
                whreClause +=' and Therapeutic_Area_Parent__c = \''+ta+'\'';
            }else{
                whreClause =' where Therapeutic_Area_Parent__c = \''+ta+'\'';
            }

            if(Ds != null && Ds != ''){
                whreClause +=' and Therapeutic_Area__c = \''+Ds +'\'';
            }
          // +
        }
        //BU can be set only when TA is set /dependent pick list
        if(bi != null && bi != '' && ta != null && ta != ''){
            if(whreClause != '' && whreClause.containsIgnoreCase('where')){
                whreClause +=' and Business_Unit_2__c = \''+bi+'\'';
            }else{
                whreClause =' where Business_Unit_2__c = \''+bi+'\'';
            }
        }

        if(SubStatus != null && SubStatus != ''){
            if(whreClause != '' && whreClause.containsIgnoreCase('where')){
                whreClause +=' and Sub_Status__c = \''+SubStatus +'\'';
            }else{
                whreClause =' where Sub_Status__c = \''+SubStatus +'\'';
            }
        }

        if(orgType != null && orgType != ''){
            if(whreClause != '' && whreClause.containsIgnoreCase('where')){
                whreClause +=' and Organization__r.Type__c = \''+orgType+'\'';
            }else{
                whreClause =' where Organization__r.Type__c = \''+orgType+'\'';
            }
        }

        if(taxStatus != null && taxStatus != ''){
            if(whreClause != '' && whreClause.containsIgnoreCase('where')){
                whreClause +=' and Organization__r.Tax_Status__c = \''+taxStatus+'\'';
            }else{
                whreClause =' where Organization__r.Tax_Status__c = \''+taxStatus+'\'';
            }
        }

        if(sapPaymentDateFrom != null && sapPaymentDateFrom !=''){
            if(whreClause != '' && whreClause.containsIgnoreCase('where')){
                whreClause +=' and SAP_Payment_Sent_Date__c >= '+convertDateForQueryRemote(sapPaymentDateFrom);
            }else{
                whreClause =' where SAP_Payment_Sent_Date__c >= '+convertDateForQueryRemote(sapPaymentDateFrom);
            }
        }
        if(sapPaymentDateTo != null && sapPaymentDateTo !=''){
            if(whreClause != '' && whreClause.containsIgnoreCase('where')){
                whreClause +=' and SAP_Payment_Sent_Date__c <= '+convertDateForQueryRemote(sapPaymentDateTo);
            }else{
                whreClause =' where SAP_Payment_Sent_Date__c <= '+convertDateForQueryRemote(sapPaymentDateTo);
            }
        }

        if(dateSubmittedFrom != null && dateSubmittedFrom !=''){
            if(whreClause != '' && whreClause.containsIgnoreCase('where')){
                whreClause +=' and Date_Submitted__c >= '+convertDateForQueryRemote(dateSubmittedFrom);
            }else{
                whreClause =' where Date_Submitted__c >= '+convertDateForQueryRemote(dateSubmittedFrom);
            }
        }
        if(dateSubmittedTo != null && dateSubmittedTo !=''){
            if(whreClause != '' && whreClause.containsIgnoreCase('where')){
                whreClause +=' and Date_Submitted__c <= '+convertDateForQueryRemote(dateSubmittedTo);
            }else{
                whreClause =' where Date_Submitted__c <= '+convertDateForQueryRemote(dateSubmittedFrom);
            }
        }

        if(firstProgramFrom != null && firstProgramFrom !=''){
            if(whreClause != '' && whreClause.containsIgnoreCase('where')){
                whreClause +=' and Program_Start_Date_Min__c >= '+convertDateForQueryRemote(firstProgramFrom);
            }else{
                whreClause =' where Program_Start_Date_Min__c >= '+convertDateForQueryRemote(firstProgramFrom);
            }
        }
        if(firstProgramTo != null && firstProgramTo !=''){
            if(whreClause != '' && whreClause.containsIgnoreCase('where')){
                whreClause +=' and Program_Start_Date_Min__c <= '+convertDateForQueryRemote(firstProgramTo);
            }else{
                whreClause =' where Program_Start_Date_Min__c <= '+convertDateForQueryRemote(firstProgramTo);
            }
        }

        if(decisionDateFrom != null && decisionDateFrom !=''){
            if(whreClause != '' && whreClause.containsIgnoreCase('where')){
                whreClause +=' and Decision_Date__c >= '+convertDateForQueryRemote(decisionDateFrom);
            }else{
                whreClause =' where Decision_Date__c >= '+convertDateForQueryRemote(decisionDateFrom);
            }
        }
        if(decisionDateTo != null && decisionDateTo !=''){
            if(whreClause != '' && whreClause.containsIgnoreCase('where')){
                whreClause +=' and Decision_Date__c <= '+convertDateForQueryRemote(decisionDateTo);
            }else{
                whreClause =' where Decision_Date__c <= '+convertDateForQueryRemote(decisionDateTo);
            }
        }

        if(hcComplianceDateFrom != null && hcComplianceDateFrom !=''){
            if(whreClause != '' && whreClause.containsIgnoreCase('where')){
                whreClause +=' and HC_Compliance_Date__c >= '+convertDateForQueryRemote(hcComplianceDateFrom);
            }else{
                whreClause =' where HC_Compliance_Date__c >= '+convertDateForQueryRemote(hcComplianceDateFrom);
            }
        }
        if(hcComplianceDateTo != null && hcComplianceDateTo !=''){
            if(whreClause != '' && whreClause.containsIgnoreCase('where')){
                whreClause +=' and HC_Compliance_Date__c <= '+convertDateForQueryRemote(hcComplianceDateTo);
            }else{
                whreClause =' where HC_Compliance_Date__c <= '+convertDateForQueryRemote(hcComplianceDateTo);
            }
        }





        mainQuery += whreClause+ ' Order by Name Limit 1000';
        List<ReportWrapper> reportData = new List<ReportWrapper>();
        //reportData = new List<ReportWrapper>();
        system.debug('#########generateReport query: '+mainQuery);
        Set<String> requestNames = new Set<String>();
        Map<String,String> ownerNameMap = new Map<String,String>();
        Map<String,GFRS_Funding_Request__c> resultMap = new Map<String,GFRS_Funding_Request__c>();
        Map<String,List<GFRS_Funding_Allocation_Line_Item__c>> fliFRMap = new Map<String,List<GFRS_Funding_Allocation_Line_Item__c>>();
        GFRS_OrgSettings__c customSettings = GFRS_OrgSettings__c.getOrgDefaults();
        Set<Id> userSetIds = new Set<Id>();
        userSetIds.add(customSettings.CapFA1__c);
        userSetIds.add(customSettings.CapFA2__c);
        userSetIds.add(customSettings.CapFA3__c);
        userSetIds.add(customSettings.ImedFA2__c);
        userSetIds.add(customSettings.ImedFA3__c);
        Map<id,User> mapOfUsers = new Map<id,User>([Select Id,Name from user where id in : userSetIds]);

        Integer countNumberOfRecors = 0;
        Boolean breakWholeLoop = false;
        for(List<GFRS_Funding_Request__c> requestLst : Database.query(mainQuery)){
            for(GFRS_Funding_Request__c r : requestLst){
                if(r.Foundation_Classified__c !='TRUE' &&  checkIfRequestIsCAP(r.Record_Type_Name__c)){
                    r.Financial_Approver_1__r = mapOfUsers.get(customSettings.CapFA1__c);
                    r.Financial_Approver_2__r = mapOfUsers.get(customSettings.CapFA2__c);
                    r.Financial_Approver_3__r = mapOfUsers.get(customSettings.CapFA3__c);
                }
                if(r.Record_Type_Name__c == gFRS_Util.TYPE_IMED_NAME){
                    r.Financial_Approver_2__r = mapOfUsers.get(customSettings.ImedFA2__c);
                    r.Financial_Approver_3__r = mapOfUsers.get(customSettings.ImedFA3__c);
                }
                countNumberOfRecors++;
                if(r.Request_Delivery_Formats__r.size()>1 && r.Request_Delivery_Formats__r.size() > r.Payment_History__r.size()){
                    countNumberOfRecors+=r.Request_Delivery_Formats__r.size()-1;
                }else if(r.Payment_History__r.size() >1 && r.Payment_History__r.size() >r.Request_Delivery_Formats__r.size()){
                    countNumberOfRecors+=r.Payment_History__r.size()-1;
                }

                requestNames.add(r.Name);
                resultMap.put(r.Name,r);
                if(countNumberOfRecors>1000){
                    break;
                    breakWholeLoop=true;
                }
            }
            if(breakWholeLoop){
                break;
            }
        }
        system.debug('check numebr of records to display:'+countNumberOfRecors);
        if(!requestNames.isEmpty()){
            for(GFRS_Funding_Allocation_Line_Item__c fli : [select Cost_Center__c,Cost_Center_Description__c, GL_Account_Code__c, WBS__c, WBS_Description__c,Grant_Request__c from GFRS_Funding_Allocation_Line_Item__c where Grant_Request__c in : requestNames]){
                if(fliFRMap.containsKey(fli.Grant_Request__c)){
                    List<GFRS_Funding_Allocation_Line_Item__c> tmpFLi = fliFRMap.get(fli.Grant_Request__c);
                    tmpFLi.add(fli);
                }else{
                    fliFRMap.put(fli.Grant_Request__c,new List<GFRS_Funding_Allocation_Line_Item__c>{fli} );
                }
            }
        }
        for(String frName : resultMap.keySet()){
            ReportWrapper wrap = new ReportWrapper();
            wrap.request=resultMap.get(frName);
            wrap.requestName=frName;
            wrap.ownerName=wrap.request.Owner_First_Name_Last_Name__c;
            if(fliFRMap.containsKey(frName)){
                wrap.allocations=fliFRMap.get(frName);
            }
            reportData.add(wrap);
        }
        system.debug(reportData.size());
        return reportData;
    }

    /**
    * @author GFRS Dev Team
    * @date 17/03/2015
    * @description Method is executed when defined RowLimit is exceeded only VF page not on excell side
    */
    public void addLimitMessage(){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.gFRS_Master_Report_Row_Limit));
    }

    /**
    * @author GFRS Dev Team
    * @date 15/04/2015
    * @description Method is executed when error is reproted while executing the report
    */
    public void addReportErrMsg(){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, reportErrMsg));
    }

    /**
    * @author GFRS Dev Team
    * @date 17/03/2015
    * @description Method returning all aplicable records for report, used on VF page
    */
    @RemoteAction
    public static List<ReportWrapper> getReportDateRemote(List<String> selectedFundingType,String ta,String bi,List<String> Ds,List<String> selectedSubStatues, String orgType,String taxStatus,String sapPaymentDateFrom,String sapPaymentDateTo,String dateSubmittedFrom,String dateSubmittedTo,String firstProgramFrom,String firstProgramTo,String decisionDateFrom,String decisionDateTo,String hcComplianceDateFrom,String hcComplianceDateTo){

        String mainQuery = 'select Foundation_Classified__c,Id,Name,Record_Type_Name__c,Organization__r.Name,Organization__r.Organization_Name__c,Organization__r.Type__c,Organization__r.Tax_Id__c,Organization__r.Tax_Status__c,Organization__r.Country__c,'+
                            'Location__r.Id,Location__r.Name,Location__r.Address__c, Location__r.City__c,Location__r.Zip__c,Location__r.Province_Region_Territory__c,Location__r.Department_Chapter_Country__c,'+
                            '(select Id,Payment_Method__c,Payment_Block__c,Status__c,Payment_Sub_status__c,Check_Number__c,Encashment_Date__c,Date__c,SAP_Payment_Sent_Date__c from Payment_History__r limit 100),'+
                            'Status__c,Sub_Status__c,Date_Submitted__c,Program_Start_Date_Min__c,Decision_Date__c,HC_Compliance_Date__c,Business_Unit_2__c,Therapeutic_Area__c,Therapeutic_Area_Parent__c,Event_Project_type__c,Event_Program_Title__c,Requested_Amount__c,Approved_Amount__c,Refundable_Deposit_Amount_if_any__c,CCO_Owner__c,Owner.Name,Accountable_Employee_Approval__r.Name,'+
                            'Business_Reviewer_1__r.Name,Business_Approver__r.Name,Business_Approver_2__r.Name,Business_Approver_3__r.Name,Legal_Reviewer_1__r.Name,Financial_Approver_1__r.Name,Financial_Approver_2__r.Name,Financial_Approver_3__r.Name,Venue_City__c,'+
                            '(select Id,Name,Start_Date__c,End_Date__c,Expected_Number_of_Attendees__c,Expected_of_attendees_that_are_HCPs__c,Product_being_Promoted__c,Booth_Type__c,Size_of_Exhibit__c,Number_of_Tables__c,Actual_Time_at_Display_Table_Hours__c,Venue_Name__c,Venue_City__c,Venue_State__c,Venue_Province_Region__c,Venue_Zip_Code__c,Venue_Country__c from Request_Delivery_Formats__r limit 100)'+
                            ' from GFRS_Funding_Request__c';

        String whreClause ='';

        if(selectedFundingType != null && !selectedFundingType.isEmpty()){
            if(whreClause != '' && whreClause.containsIgnoreCase('where')){
                whreClause +=' and Record_Type_Name__c in '+renderInConditionForDsRemote(selectedFundingType);
            }else{
                whreClause =' where Record_Type_Name__c in '+renderInConditionForDsRemote(selectedFundingType);
            }
        }
        if(ta != null && ta != ''){
            if(whreClause != '' && whreClause.containsIgnoreCase('where')){
                whreClause +=' and Therapeutic_Area_Parent__c = \''+ta+'\'';
            }else{
                whreClause =' where Therapeutic_Area_Parent__c = \''+ta+'\'';
            }

            if(Ds != null && !Ds.isEmpty()){
                whreClause +=' and Therapeutic_Area__c in '+renderInConditionForDsRemote(Ds);
            }
          // +
        }
        //BU can be set only when TA is set /dependent pick list
        if(bi != null && bi != '' && ta != null && ta != ''){
            if(whreClause != '' && whreClause.containsIgnoreCase('where')){
                whreClause +=' and Business_Unit_2__c = \''+bi+'\'';
            }else{
                whreClause =' where Business_Unit_2__c = \''+bi+'\'';
            }
        }

        if(selectedSubStatues != null && !selectedSubStatues.isEmpty()){
            if(whreClause != '' && whreClause.containsIgnoreCase('where')){
                whreClause +=' and Sub_Status__c in '+renderInConditionForDsRemote(selectedSubStatues);
            }else{
                whreClause =' where Sub_Status__c in '+renderInConditionForDsRemote(selectedSubStatues);
            }
        }

        if(orgType != null && orgType != ''){
            if(whreClause != '' && whreClause.containsIgnoreCase('where')){
                whreClause +=' and Organization__r.Type__c = \''+orgType+'\'';
            }else{
                whreClause =' where Organization__r.Type__c = \''+orgType+'\'';
            }
        }

        if(taxStatus != null && taxStatus != ''){
            if(whreClause != '' && whreClause.containsIgnoreCase('where')){
                whreClause +=' and Organization__r.Tax_Status__c = \''+taxStatus+'\'';
            }else{
                whreClause =' where Organization__r.Tax_Status__c = \''+taxStatus+'\'';
            }
        }

        if(sapPaymentDateFrom != null && sapPaymentDateFrom !=''){
            if(whreClause != '' && whreClause.containsIgnoreCase('where')){
                whreClause +=' and SAP_Payment_Sent_Date__c >= '+convertDateForQueryRemote(sapPaymentDateFrom);
            }else{
                whreClause =' where SAP_Payment_Sent_Date__c >= '+convertDateForQueryRemote(sapPaymentDateFrom);
            }
        }
        if(sapPaymentDateTo != null && sapPaymentDateTo !=''){
            if(whreClause != '' && whreClause.containsIgnoreCase('where')){
                whreClause +=' and SAP_Payment_Sent_Date__c <= '+convertDateForQueryRemote(sapPaymentDateTo);
            }else{
                whreClause =' where SAP_Payment_Sent_Date__c <= '+convertDateForQueryRemote(sapPaymentDateTo);
            }
        }

        if(dateSubmittedFrom != null && dateSubmittedFrom !=''){
            if(whreClause != '' && whreClause.containsIgnoreCase('where')){
                whreClause +=' and Date_Submitted__c >= '+convertDateForQueryRemote(dateSubmittedFrom);
            }else{
                whreClause =' where Date_Submitted__c >= '+convertDateForQueryRemote(dateSubmittedFrom);
            }
        }
        if(dateSubmittedTo != null && dateSubmittedTo !=''){
            if(whreClause != '' && whreClause.containsIgnoreCase('where')){
                whreClause +=' and Date_Submitted__c <= '+convertDateForQueryRemote(dateSubmittedTo);
            }else{
                whreClause =' where Date_Submitted__c <= '+convertDateForQueryRemote(dateSubmittedFrom);
            }
        }

        if(firstProgramFrom != null && firstProgramFrom !=''){
            if(whreClause != '' && whreClause.containsIgnoreCase('where')){
                whreClause +=' and Program_Start_Date_Min__c >= '+convertDateForQueryRemote(firstProgramFrom);
            }else{
                whreClause =' where Program_Start_Date_Min__c >= '+convertDateForQueryRemote(firstProgramFrom);
            }
        }
        if(firstProgramTo != null && firstProgramTo !=''){
            if(whreClause != '' && whreClause.containsIgnoreCase('where')){
                whreClause +=' and Program_Start_Date_Min__c <= '+convertDateForQueryRemote(firstProgramTo);
            }else{
                whreClause =' where Program_Start_Date_Min__c <= '+convertDateForQueryRemote(firstProgramTo);
            }
        }

        if(decisionDateFrom != null && decisionDateFrom !=''){
            if(whreClause != '' && whreClause.containsIgnoreCase('where')){
                whreClause +=' and Decision_Date__c >= '+convertDateForQueryRemote(decisionDateFrom);
            }else{
                whreClause =' where Decision_Date__c >= '+convertDateForQueryRemote(decisionDateFrom);
            }
        }
        if(decisionDateTo != null && decisionDateTo !=''){
            if(whreClause != '' && whreClause.containsIgnoreCase('where')){
                whreClause +=' and Decision_Date__c <= '+convertDateForQueryRemote(decisionDateTo);
            }else{
                whreClause =' where Decision_Date__c <= '+convertDateForQueryRemote(decisionDateTo);
            }
        }
        if(hcComplianceDateFrom != null && hcComplianceDateFrom !=''){
            if(whreClause != '' && whreClause.containsIgnoreCase('where')){
                whreClause +=' and HC_Compliance_Date__c >= '+convertDateForQueryRemote(hcComplianceDateFrom);
            }else{
                whreClause =' where HC_Compliance_Date__c >= '+convertDateForQueryRemote(hcComplianceDateFrom);
            }
        }
        if(hcComplianceDateTo != null && hcComplianceDateTo !=''){
            if(whreClause != '' && whreClause.containsIgnoreCase('where')){
                whreClause +=' and HC_Compliance_Date__c <= '+convertDateForQueryRemote(hcComplianceDateTo);
            }else{
                whreClause =' where HC_Compliance_Date__c <= '+convertDateForQueryRemote(hcComplianceDateTo);
            }
        }


        mainQuery += whreClause+ ' Order by Name Limit 1000';
        List<ReportWrapper> reportData = new List<ReportWrapper>();
        //reportData = new List<ReportWrapper>();
        system.debug('#########generateReport query: '+mainQuery);
        Set<String> requestNames = new Set<String>();
        Map<String,GFRS_Funding_Request__c> resultMap = new Map<String,GFRS_Funding_Request__c>();
        Map<String,List<GFRS_Funding_Allocation_Line_Item__c>> fliFRMap = new Map<String,List<GFRS_Funding_Allocation_Line_Item__c>>();
        GFRS_OrgSettings__c customSettings = GFRS_OrgSettings__c.getOrgDefaults();
        Set<Id> userSetIds = new Set<Id>();
        userSetIds.add(customSettings.CapFA1__c);
        userSetIds.add(customSettings.CapFA2__c);
        userSetIds.add(customSettings.CapFA3__c);
        userSetIds.add(customSettings.ImedFA2__c);
        userSetIds.add(customSettings.ImedFA3__c);
        //Financial approvers are defined statically under approval process and for report perpouse 
        //they are copied to custom settigns and used in this report 
        Map<id,User> mapOfUsers = new Map<id,User>([Select Id,Name from user where id in : userSetIds]);
        Integer countNumberOfRecors = 0;
        Boolean breakWholeLoop = false;
        for(List<GFRS_Funding_Request__c> requestLst : Database.query(mainQuery)){
            for(GFRS_Funding_Request__c r : requestLst){
                if(r.Foundation_Classified__c !='TRUE' &&  checkIfRequestIsCAP(r.Record_Type_Name__c)){
                    r.Financial_Approver_1__r = mapOfUsers.get(customSettings.CapFA1__c);
                    r.Financial_Approver_2__r = mapOfUsers.get(customSettings.CapFA2__c);
                    r.Financial_Approver_3__r = mapOfUsers.get(customSettings.CapFA3__c);
                }
                if(r.Record_Type_Name__c == gFRS_Util.TYPE_IMED_NAME){
                    r.Financial_Approver_2__r = mapOfUsers.get(customSettings.ImedFA2__c);
                    r.Financial_Approver_3__r = mapOfUsers.get(customSettings.ImedFA3__c);
                }
                countNumberOfRecors++;
                if(r.Request_Delivery_Formats__r.size()>1 && r.Request_Delivery_Formats__r.size() > r.Payment_History__r.size()){
                    countNumberOfRecors+=r.Request_Delivery_Formats__r.size()-1;
                }else if(r.Payment_History__r.size() >1 && r.Payment_History__r.size() >r.Request_Delivery_Formats__r.size()){
                    countNumberOfRecors+=r.Payment_History__r.size()-1;
                }

                requestNames.add(r.Name);
                resultMap.put(r.Name,r);
                if(countNumberOfRecors>1000){
                    break;
                    breakWholeLoop=true;
                }
            }
            if(breakWholeLoop){
                break;
            }
        }
        system.debug('check numebr of records to display:'+countNumberOfRecors);
        if(!requestNames.isEmpty()){
            for(GFRS_Funding_Allocation_Line_Item__c fli : [select Cost_Center__c,Cost_Center_Description__c, GL_Account_Code__c, WBS__c, WBS_Description__c,Grant_Request__c from GFRS_Funding_Allocation_Line_Item__c where Grant_Request__c in : requestNames]){
                if(fliFRMap.containsKey(fli.Grant_Request__c)){
                    List<GFRS_Funding_Allocation_Line_Item__c> tmpFLi = fliFRMap.get(fli.Grant_Request__c);
                    tmpFLi.add(fli);
                }else{
                    fliFRMap.put(fli.Grant_Request__c,new List<GFRS_Funding_Allocation_Line_Item__c>{fli} );
                }
            }
        }
        for(String frName : resultMap.keySet()){
            ReportWrapper wrap = new ReportWrapper();
            wrap.request=resultMap.get(frName);

            if(fliFRMap.containsKey(frName)){
                wrap.allocations=fliFRMap.get(frName);
            }
            reportData.add(wrap);
        }
        system.debug(reportData.size());
        return reportData;
    }

    /**
    * @author GFRS Dev Team
    * @date 17/03/2015
    * @description Heleper Class which is placeholder for report Data
    */
    public class ReportWrapper implements Comparable{
        public String ownerName{get;set;}
        public String requestName{get;set;}
        public GFRS_Funding_Request__c request{get;set;}
        public List<GFRS_Funding_Allocation_Line_Item__c> allocations{get;set;}

        public ReportWrapper(GFRS_Funding_Request__c req,List<GFRS_Funding_Allocation_Line_Item__c> fli,List<GFRS_Program__c> progs ){
            this.request = req;
            this.allocations = fli;
        }

        public ReportWrapper(){
        }

        public Integer compareTo(Object compareTo) {
            ReportWrapper compareToEmp = (ReportWrapper)compareTo;
            return requestName.compareTo(compareToEmp.requestName);
        }
    }


    /**
    * @author GFRS Dev Team
    * @date 17/03/2015
    * @description method string date to applicable format which can be used
    * in SOQL queries
    */
    public static String convertDateForQueryRemote(String s){
        //date parse always using user localization  date
        Date d = Date.parse(s);
        DateTime dt = DateTime.newInstance(d, Time.newInstance(0, 0, 0, 0));

        //convert date to utc format
        String outputDate = dt.format('yyyy-MM-dd');
        system.debug('converted date to utc format:' +outputDate);
        return outputDate;

    }

    /**
    * @author GFRS Dev Team
    * @date 17/03/2015
    * @description method string date to applicable format which can be used
    * in SOQL queries
    */
    public static String convertDateForQuery(Date d){
        //date parse always using user localization  date
        DateTime dt = DateTime.newInstance(d, Time.newInstance(0, 0, 0, 0));

        //convert date to utc format
        String outputDate = dt.format('yyyy-MM-dd');
        system.debug('converted date to utc format:' +outputDate);
        return outputDate;

    }

    /**
    * @author GFRS Dev Team
    * @date 17/03/2015
    * @description method getReportHeader - generate headers for report
    */
    public String getReportHeader() {
        string ReportHeader='';
        for(String headerItem : Label.gFRS_RequestProgram_Report_Headers.split(',')){
            ReportHeader +='<td><b>'+headerItem+'</b></td>';
        }
        for(String headerItem : Label.gFRS_RequestProgram_Report_Headers_1.split(',')){
            ReportHeader +='<td><b>'+headerItem+'</b></td>';
        }

        return ReportHeader;
    }

    /**
    * @author GFRS Dev Team
    * @date 17/03/2015
    * @description rendering empty colums in report
    */
    public String buildEmptyCols(List<String> strLst,String mainColor){
        String currentRow='';
        for(String s: strLst){
            if(mainColor != null){
                currentRow += '<td style="background-color:'+mainColor+';"></td>';
            }else{
                currentRow += '<td></td>';
            }

        }
        return currentRow;
    }

    /**
    * @author GFRS Dev Team
    * @date 17/03/2015
    * @description method rendering additional records for each child object : programs,funding allocations, payments
    * checking wich array is the longes one and rendering such number of rows
    */
    public Integer generateChildren(ReportWrapper wrap,Integer arrayLength,String mainColor,List<String> tableRows,Integer recordRowNumber){

        String redColorCode = '#F7C5CE';
        String greenColorCode = '#C9F7C5';
        String blueColorCode = '#C5CAF7';
        String outputString ='';
        for(Integer i=1; i<arrayLength; i++){
            outputString = '<tr>';
                //system.debug(wrap.request.Name);
                for(String s : gFRS_ReqProg_Rep_FR_1_API.split(',')){
                    outputString += '<td style="background-color:'+mainColor+';">'+clearNull(wrap.request.get(s))+'</td>';
                }
                for(String s : gFRS_ReqProg_Rep_Org_API.split(',')){
                    try{
                       outputString += '<td style="background-color:'+mainColor+';">'+clearNull(wrap.request.Organization__r.get(s.replace('Organization__r.','')))+'</td>';
                    }catch(Exception ex){
                       outputString += '<td style="background-color:'+mainColor+';">'+clearNull(null)+'</td>';
                    }
                    //outputString += '<td style="background-color:'+mainColor+';">'+clearNull(wrap.request.Organization__r.get(s.replace('Organization__r.','')))+'</td>';
                }
                for(String s : gFRS_ReqProg_Rep_Location_API.split(',')){
                    try{
                        outputString += '<td style="background-color:'+mainColor+';">'+clearNull(wrap.request.Location__r.get(s.replace('Location__r.','')))+'</td>';
                    }catch(Exception ex){
                        outputString += '<td style="background-color:'+mainColor+';">'+clearNull(null)+'</td>';

                    }

                }
                //generating payment history columns
                system.debug('before payments');
                system.debug(outputString);
                if(wrap.request.Payment_History__r.isEmpty() || wrap.request.Payment_History__r.size() <= i){
                    system.debug('was here build empty columns for payments');
                    outputString += buildEmptyCols(gFRS_ReqProg_Rep_Payment_API.split(','),mainColor);
                    system.debug(outputString);
                }else{
                    system.debug('was here build empty columns for payments 1');
                    for(String s : gFRS_ReqProg_Rep_Payment_API.split(',')){
                        outputString += '<td style="background-color:'+greenColorCode+';">'+clearNull(wrap.request.Payment_History__r[i].get(s))+'</td>';
                        system.debug(outputString);
                    }
                }
                for(String s : gFRS_ReqProg_Rep_FR_2_API.split(',')){
                    if(s.indexOf('.') != -1){
                        List<String> strApiLst=s.split('\\.');

                        if(strApiLst[0] == 'Owner'){
                            outputString += '<td style="background-color:'+mainColor+';">'+wrap.ownerName+'</td>';
                        }else{
                            User tmpObj = (User)wrap.request.getSObject(strApiLst[0]);
                            if(tmpObj != null){
                                outputString += '<td style="background-color:'+mainColor+';">'+clearNull(tmpObj.Name)+'</td>';
                            }else{
                                outputString += '<td style="background-color:'+mainColor+';"></td>';
                            }
                        }
                    }else{
                        try{
                            outputString += '<td style="background-color:'+mainColor+';">'+clearNull(wrap.request.get(s))+'</td>';
                        }catch(exception ex){
                            outputString += '<td style="background-color:'+mainColor+';"></td>';
                        }

                    }
                }

                //generating program columns
                if(wrap.request.Request_Delivery_Formats__r.isEmpty() ||  wrap.request.Request_Delivery_Formats__r.size() <= i){
                    outputString += buildEmptyCols(gFRS_ReqProg_Rep_Prog_API.split(','),mainColor);
                }else{
                    for(String s : gFRS_ReqProg_Rep_Prog_API.split(',')){
                        outputString += '<td style="background-color:'+redColorCode+';">'+clearNull(wrap.request.Request_Delivery_Formats__r[i].get(s))+'</td>';
                    }
                }

                //gerate allocation columns
                if(wrap.allocations == null || wrap.allocations.isEmpty() || wrap.allocations.size() <= i){
                    outputString += buildEmptyCols(gFRS_ReqProg_Rep_FLI_API.split(','),mainColor);
                }else{
                    for(String s : gFRS_ReqProg_Rep_FLI_API.split(',')){
                        outputString += '<td style="background-color:'+blueColorCode+';">'+clearNull(wrap.allocations[i].get(s))+'</td>';
                    }
                }
                outputString += '</tr>';
                recordRowNumber++;

                tableRows.add(outputString);
                if(recordRowNumber >= 1000){
                    break;
                }

        }
        return recordRowNumber;
    }

    /**
    * @author GFRS Dev Team
    * @date 17/03/2015
    * @description method rendering proper rows for report tabel
    */
    public List<String> getReportTableRows(){
        String redColorCode = '#F7C5CE';
        String greenColorCode = '#C9F7C5';
        String blueColorCode = '#C5CAF7';
        bindValuesWhileForExcelDocument();
        List<String> outputList = new List<String>();
        String outputString = '';
        Integer theLongestArray = null;
        //system.debug(reportData);
        system.debug('#### Report Data Size'+reportData.size());
        reportData.sort();
        String mainColor='';
        Integer recordRowNumber=0;
        if(reportData != null){
            for(ReportWrapper wrap : reportData){
                outputString = '<tr>';
                //system.debug(wrap.request.Name);
                for(String s : gFRS_ReqProg_Rep_FR_1_API.split(',')){
                    outputString += '<td>'+clearNull(wrap.request.get(s))+'</td>';
                }
                for(String s : gFRS_ReqProg_Rep_Org_API.split(',')){
                    try{
                        outputString += '<td>'+clearNull(wrap.request.Organization__r.get(s.replace('Organization__r.','')))+'</td>';
                    }catch(Exception ex){
                        outputString += '<td>'+clearNull(null)+'</td>';
                    }
                }
                for(String s : gFRS_ReqProg_Rep_Location_API.split(',')){
                    try{
                        outputString += '<td>'+clearNull(wrap.request.Location__r.get(s.replace('Location__r.','')))+'</td>';
                    }catch(Exception ex){
                        outputString += '<td>'+clearNull(null)+'</td>';
                    }
                }
                //generating payment history columns
                system.debug('before payments');
                system.debug(outputString);
                if(wrap.request.Payment_History__r.isEmpty()){
                    system.debug('was here build empty columns for payments');
                    outputString += buildEmptyCols(gFRS_ReqProg_Rep_Payment_API.split(','),null);
                    system.debug(outputString);
                }else{
                    //system.debug('was here build empty columns for payments 1');
                    theLongestArray = wrap.request.Payment_History__r.size();
                    mainColor=greenColorCode;
                    for(String s : gFRS_ReqProg_Rep_Payment_API.split(',')){
                        outputString += '<td>'+clearNull(wrap.request.Payment_History__r[0].get(s))+'</td>';
                    }
                }
                for(String s : gFRS_ReqProg_Rep_FR_2_API.split(',')){
                    if(s.indexOf('.') != -1){
                        List<String> strApiLst=s.split('\\.');

                        if(strApiLst[0] == 'Owner'){
                            outputString += '<td>'+wrap.ownerName+'</td>';
                        }else{
                            User tmpObj = (User)wrap.request.getSObject(strApiLst[0]);
                            if(tmpObj != null){
                                outputString += '<td>'+clearNull(tmpObj.Name)+'</td>';
                            }else{
                                outputString += '<td></td>';
                            }
                        }


                    }else{
                        try{
                            outputString += '<td>'+clearNull(wrap.request.get(s))+'</td>';
                        }catch(exception ex){
                            outputString += '<td></td>';
                        }

                    }
                }

                //generating program columns
                if(wrap.request.Request_Delivery_Formats__r.isEmpty()){
                    outputString += buildEmptyCols(gFRS_ReqProg_Rep_Prog_API.split(','),null);
                }else{
                    if(theLongestArray == null || theLongestArray <  wrap.request.Request_Delivery_Formats__r.size()){
                        theLongestArray = wrap.request.Request_Delivery_Formats__r.size();
                        mainColor=redColorCode;
                    }

                    for(String s : gFRS_ReqProg_Rep_Prog_API.split(',')){
                        outputString += '<td>'+clearNull(wrap.request.Request_Delivery_Formats__r[0].get(s))+'</td>';
                    }
                }

                //gerate allocation columns
                if(wrap.allocations == null || wrap.allocations.isEmpty()){
                    outputString += buildEmptyCols(gFRS_ReqProg_Rep_FLI_API.split(','),null);
                }else{
                    if(theLongestArray == null || theLongestArray <  wrap.allocations.size()){
                        theLongestArray = wrap.allocations.size();
                        mainColor=blueColorCode;
                    }

                    for(String s : gFRS_ReqProg_Rep_FLI_API.split(',')){
                        outputString += '<td>'+clearNull(wrap.allocations[0].get(s))+'</td>';
                    }
                }
                outputString += '</tr>';
                recordRowNumber++;
                if(recordRowNumber >= rowLimit){
                    break;
                }
                system.debug(outputString);
                outputList.add(outputString);
                if(theLongestArray > 1){
                       recordRowNumber=generateChildren(wrap,theLongestArray,mainColor,outputList,recordRowNumber);
                       theLongestArray=null;
                }



            }
        }
        system.debug('end processing');
        system.debug(outputList.size());
        return outputList;
    }

    /**
    * @author GFRS Dev Team
    * @date 17/03/2015
    * @description method set to empty if value null used in excel data generation
    */
    public object clearNull(Object obj){
        if(obj == null){
            return '';
        }
        return obj;
    }

    /**
    * @author GFRS Dev Team
    * @date 17/03/2015
    * @description helper method which is used to pass selected dates in report criteria
    * method called form actionFunction tag on visualforce page
    */
    public PageReference setDateParams(){
        return null;
    }

    /**
    * @author GFRS Dev Team
    * @date 17/03/2015
    * @description rendering multiselect values in proprer format in excel
    */
    public String getMuliSelectFtToExcel(){
        //system.debug('get ,multiselect DS '+ApexPages.currentPage().getParameters().get('DS'));
        String selectedFT = ApexPages.currentPage().getParameters().get('FT');
        if(selectedFT != null && selectedFT != ''){

            return selectedFT.replace('\'', '').replace('(','').replace(')','').replace(',','<br/>');
        }
        return '';
    }

    /**
    * @author GFRS Dev Team
    * @date 17/03/2015
    * @description rendering multiselect values in proprer format in excel
    */
    public String getMuliSelectDSToExcel(){
        //system.debug('get ,multiselect DS '+ApexPages.currentPage().getParameters().get('DS'));
        String selectedDS = ApexPages.currentPage().getParameters().get('DS');
        if(selectedDS != null && selectedDS != ''){

            return selectedDS.replace('\'', '').replace('(','').replace(')','').replace(',','<br/>');
        }
        return '';
    }

    /* @author GFRS Dev Team
    * @date 17/06/2015
    * @description rendering multiselect values in proprer format in excel
    */
     public String getMuliSelectSubstatuesToExcel(){
        //system.debug('get ,multiselect DS '+ApexPages.currentPage().getParameters().get('DS'));
        String selectedSubstats = ApexPages.currentPage().getParameters().get('SubStatuses');
        if(selectedSubstats != null && selectedSubstats!= ''){
            return selectedSubstats.replace('\'', '').replace('(','').replace(')','').replace(',','<br/>');
        }
        return '';
    }

    /**
    * @author GFRS Dev Team
    * @date 17/03/2015
    * @description helper method for where clasue condition in main report query
    */
    public String renderInConditionForMultiSelect(List<String> inputLst){
        String outputString ='(';
        for(String s : inputLst){
            outputString +='\''+String.escapeSingleQuotes(s)+'\',';
        }
        outputString = outputString.substring(0, outputString.length() -1);
        system.debug('in DS clause looks as following:'+outputString);
        if(!inputLst.isEmpty()){
            outputString +=')';
        }

        return outputString;
    }

    public static Boolean checkIfRequestIsCAP(String recordType){
        if(recordType == gFRS_Util.TYPE_FELLOWSHIPS_NAME || recordType == gFRS_Util.TYPE_HC_CHAR_NAME || recordType == gFRS_Util.TYPE_PHILANTHROPIC_NAME || recordType == gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME){
            return true;
        }

        return false;
    }

    /**
    * @author GFRS Dev Team
    * @date 17/03/2015
    * @description method resposible for exporting date into the excel file
    */
    public PageReference exportToExcel(){

        PageReference excelPage = new PageReference('/apex/gFRS_FundingProgramReportExcel');

        excelPage.getParameters().put('isExportToExcel','Yes');
        excelPage.getParameters().put('sapPaymentSentFrom',sapPaymentSentFrom);
        excelPage.getParameters().put('sapPaymentSentTo',sapPaymentSentTo);
        excelPage.getParameters().put('dateSubmittedFrom',dateSubmittedFrom);
        excelPage.getParameters().put('dateSubmittedTo',dateSubmittedTo);
        excelPage.getParameters().put('firstProgramStartDateFrom',firstProgramStartDateFrom);
        excelPage.getParameters().put('firstProgramStartDateTo',firstProgramStartDateTo);
        excelPage.getParameters().put('decisionDateFrom',decisionDateFrom);
        excelPage.getParameters().put('decisionDateTo',decisionDateTo);
        excelPage.getParameters().put('hcComplianceDateFrom',hcComplianceDateFrom);
        excelPage.getParameters().put('hcComplianceDateTo',hcComplianceDateTo);

        excelPage.getParameters().put('DS',renderInConditionForMultiSelect(therapeuticAreaSelected));
        excelPage.getParameters().put('FT',renderInConditionForMultiSelect(fundingTypeSelected));
        excelPage.getParameters().put('BU',helperRequest.Business_Unit_2__c);
        excelPage.getParameters().put('SubStatuses',renderInConditionForMultiSelect(subStatusesSelected));
        system.debug('Passed to Excel:' +helperRequest.Organization__r.Type__c);
        excelPage.getParameters().put('OrgType',orgType);
        excelPage.getParameters().put('TaxStatus',selectedTaxStatus);
        excelPage.getParameters().put('TA',helperRequest.Therapeutic_Area_Parent__c);

        excelPage.setRedirect(false);
        return excelPage;
    }
}