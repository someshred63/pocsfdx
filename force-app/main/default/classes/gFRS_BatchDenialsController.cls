public without sharing class gFRS_BatchDenialsController {
    public Boolean showPageBody{get;set;}
    public GFRS_Funding_Request__c helperRequest {get;set;}
    public String dsAvailableValuesToSelect {get;set;}
    public String selectedFundingType{get;set;}
    public String selectedSubStatus{get;set;}
    public String selectedTaxStatus{get;set;}
    public String datename{get;set;}
    public String datename1{get;set;}
    public String reportErrMsg{get;set;}
    public List<string> fundingTypeSelected{get;set;}
    public List<Selectoption> ftLeftOptions{get;set;}
    public List<Selectoption> ftRightSelectOptions{get;set;}
    public List<string> subStatusesSelected{get;set;}
    public List<Selectoption> subStatusesLeftOptions{get;set;}
    public List<Selectoption> subStatusesRightOptions{get;set;}
    public List<String> itcSelected{get;set;}
    public List<SelectOption> itcLeftSelectOptions{get;set;}
    public List<SelectOption> itcRightSelectOptions{get;set;}

    public String resultHeaders {get {return 'Select All,Funding Request Id,Organization Name,Date Submitted,First Program Start Date,Event / Program Title,Requested Amount,Comments,Total Overall Budget,Program Type Combined,Disease State,Internal Tracking Code,External Tracking Code,Third Party Company Name';} set;}
    public String resultFields {get {return 'Select All,Name,Organization__r.Organization_Name__c,Date_Submitted__c,Program_Start_Date_Min__c,Event_Program_Title__c,Requested_Amount__c,Comments__c,Total_Program_Budget__c,Program_Type_Combined__c,Therapeutic_Area__c,Internal_Tracking_Code_optional__c,External_Tracking_Code_optional__c,Third_Parties__r';} set;}
    public List<string> therapeuticAreaSelected{get;set;}
    public List<Selectoption> leftSelectOptions{get;set;}
    public List<Selectoption> rightSelectOptions{get;set;}
    public String whereDs{get;set;}
    public String instanceUrl{get;set;}
    public String orgType{get;set;}
    public Boolean isBatchDenials{get;set;}
    public Set<String> userGroups{get;set;}

    public static Set<String> subStatusesToShowBD = new Set<String>{'New', 'CCO Review'};
    public static Set<String> subStatusesToShowITC = new Set<String>{'New'};
    public static Set<String> fundingTypesToShow = new Set<String>{'Fellowships', 'HC Char', 'IMED', 'Philanthropic', 'Scientific Projects'};
    public static Set<String> fundingTypesToShowCEG = new Set<String>{'HC Char', 'Philanthropic'};
    public static Set<String> fundingTypesToShowIMED = new Set<String>{'Fellowships', 'IMED', 'Scientific Projects'};
    public static List<String> itcPermittedGroups = new List<String>{'GNE_GFRS_CEG_Team', 'GNE_GFRS_IMED_Team'};
    public static List<String> permittedProfiles = new List<String>{'System Administrator', 'GNE-GFRS-Admin', 'GNE-SYS-Support'};

    /**
    * @author GFRS Dev Team
    * @date 17/03/2015
    * @description controller constructor
    */
    public gFRS_BatchDenialsController(ApexPages.StandardController std){
        List<User> user = [SELECT Id, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
        isBatchDenials = isDenialTab();
        userGroups = getUserPermittedGroups();
        if(!isBatchDenials && userGroups.isEmpty() && !permittedProfiles.contains(user[0].Profile.Name)){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, 'You need to be assinged to GNE-GFRS-CEG Team or GNE-GFRS-IMED Team group in order to access this page.'));
            return;
        }
        if(isBatchDenials && !isUserPermittedForDenialsTab() && !permittedProfiles.contains(user[0].Profile.Name)){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, 'You don\'t have access to this page.'));
            return;
        }

        showPageBody = true;
        instanceUrl = URL.getSalesforceBaseUrl().toExternalForm();
        helperRequest = new GFRS_Funding_Request__c();
        //workaround for Grand Cordinator Profiles - don't have create priviligaes
        //and TA DS fiels were not editabel using standard input fields
        //need to set some id of existing request request will not be modified
        helperRequest.id = [Select id from gFRS_Funding_Request__c where Record_Type_Name__c =: gFRS_Util.TYPE_IMED_NAME limit 1].get(0).Id;

        dsAvailableValuesToSelect='';
        rightSelectOptions=new List<Selectoption>();
        leftSelectOptions= new List<Selectoption>();
        therapeuticAreaSelected=new List<String>();

        fundingTypeSelected = new List<string>();
        ftRightSelectOptions = new List<Selectoption>();
        ftLeftOptions = getFundingType();

        subStatusesSelected = new List<String>();
        subStatusesRightOptions = new List<Selectoption>();
        subStatusesLeftOptions = getSubstatuses();

        itcSelected = new List<String>();
        itcRightSelectOptions = new List<SelectOption>();
        itcLeftSelectOptions = getInternalTrackingCodes();
    }

    /**
    * @author GFRS Dev Team
    * @date 17/03/2015
    * @description getter method to return all avaliable Funding Types in system
    */
    public List<SelectOption> getFundingType(){
        List<SelectOption> fundingTypes = new List<SelectOption>();
        List<RecordType> fundingRecordTypes = [SELECT DeveloperName, Name, SobjectType FROM RecordType WHERE SobjectType='GFRS_Funding_Request__c'];
        for(RecordType rt : fundingRecordTypes){
            if(isBatchDenials){
                if(fundingTypesToShow.contains(rt.Name)){
                    fundingTypes.add(new SelectOption(rt.Name,rt.Name));
                }
            }
            else{
                if(userGroups.contains(itcPermittedGroups[0]) && fundingTypesToShowCEG.contains(rt.Name)){
                    ftRightSelectOptions.add(new SelectOption(rt.Name,rt.Name));
                }
                if(userGroups.contains(itcPermittedGroups[1]) && fundingTypesToShowIMED.contains(rt.Name)){
                    ftRightSelectOptions.add(new SelectOption(rt.Name,rt.Name));
                }
            }
        }
        if(fundingTypes.isEmpty() && ftRightSelectOptions.isEmpty() && !isBatchDenials){
            for(RecordType rt : fundingRecordTypes){
                if(fundingTypesToShow.contains(rt.Name)){
                    fundingTypes.add(new SelectOption(rt.Name,rt.Name));
                }
            }
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
            if(isBatchDenials){
                if(subStatusesToShowBD.contains(ent.getValue())){
                    if(ent.getValue() == gFRS_Util.REQUEST_SUB_STATUS_CCO){
                        subStatusesRightOptions.add(new SelectOption(ent.getValue() ,ent.getLabel()));
                    }
                    else{
                        subStats.add(new SelectOption(ent.getValue() ,ent.getLabel()));
                    }
                }
            }
            else{
                if(subStatusesToShowITC.contains(ent.getValue())){
                    subStatusesRightOptions.add(new SelectOption(ent.getValue() ,ent.getLabel()));
                }
            }
        }
        return subStats;
    }

    public List<SelectOption> getInternalTrackingCodes(){
        List<SelectOption> itcs = new List<SelectOption>();
        for(PicklistEntry ent : GFRS_Funding_Request__c.Internal_Tracking_Code_optional__c.getDescribe().getPicklistValues()){
            itcs.add(new SelectOption(ent.getValue() ,ent.getLabel()));
        }
        return itcs;
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
    * @description reset fields
    */
    public void resetFields(){
        helperRequest.Therapeutic_Area_Parent__c='';
        dsAvailableValuesToSelect ='';
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
    public static List<ReportWrapper> getReportDateRemote(List<String> selectedFundingType, String ta, List<String> ds, List<String> selectedSubStatues, List<String> itcs){

        String mainQuery = 'SELECT Foundation_Classified__c,Id,Name,Record_Type_Name__c,Organization__r.Name,Organization__r.Organization_Name__c,Organization__r.Type__c,Organization__r.Tax_Id__c,Organization__r.Tax_Status__c,Organization__r.Country__c,'+
                'Location__r.Id,Location__r.Name,Location__r.Address__c, Location__r.City__c,Location__r.Zip__c,Location__r.Province_Region_Territory__c,Location__r.Department_Chapter_Country__c,'+
                'Status__c,toLabel(Sub_Status__c),Date_Submitted__c,Program_Start_Date_Min__c,Decision_Date__c,HC_Compliance_Date__c,Business_Unit_2__c,Therapeutic_Area__c,Therapeutic_Area_Parent__c,Event_Project_type__c,Event_Program_Title__c,Requested_Amount__c,Approved_Amount__c,Refundable_Deposit_Amount_if_any__c,CCO_Owner__c,Owner.Name,Accountable_Employee_Approval__r.Name,'+
                'Business_Reviewer_1__r.Name,Business_Approver__r.Name,Business_Approver_2__r.Name,Business_Approver_3__r.Name,Legal_Reviewer_1__r.Name,Financial_Approver_1__r.Name,Financial_Approver_2__r.Name,Financial_Approver_3__r.Name,Venue_City__c,Comments__c,Total_Program_Budget__c,Program_Type_Combined__c,Internal_Tracking_Code_optional__c,External_Tracking_Code_optional__c,'+
                '(SELECT Company_Name__c FROM Third_Parties__r)' +
                ' FROM GFRS_Funding_Request__c';

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

            if(ds != null && !ds.isEmpty()){
                whreClause +=' and Therapeutic_Area__c in '+renderInConditionForDsRemote(ds);
            }
        }

        if(selectedSubStatues != null && !selectedSubStatues.isEmpty()){
            if(whreClause != '' && whreClause.containsIgnoreCase('where')){
                whreClause +=' and Sub_Status__c in '+renderInConditionForDsRemote(selectedSubStatues);
            }else{
                whreClause =' where Sub_Status__c in '+renderInConditionForDsRemote(selectedSubStatues);
            }
        }

        if(itcs != null && !itcs.isEmpty()){
            if(whreClause != '' && whreClause.containsIgnoreCase('where')){
                whreClause +=' and Internal_Tracking_Code_optional__c in '+renderInConditionForDsRemote(itcs);
            }else{
                whreClause =' where Internal_Tracking_Code_optional__c in '+renderInConditionForDsRemote(itcs);
            }
        }

        mainQuery += whreClause+ ' Order by Name';
        List<ReportWrapper> reportData = new List<ReportWrapper>();
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
                requestNames.add(r.Name);
                resultMap.put(r.Name,r);
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

    public Boolean isDenialTab(){
        GFRS_OrgSettings__c customSettings = GFRS_OrgSettings__c.getOrgDefaults();
        if(ApexPages.currentPage().getParameters().get('sfdc.tabName') == customSettings.Batch_Denials_Tab_Id__c){
            return true;
        }
        return false;
    }

    public Set<String> getUserPermittedGroups(){
        Set<String> userPermittedGroups = new Set<String>();
        List<GroupMember> userGroups = [SELECT Id, Group.DeveloperName FROM GroupMember WHERE UserOrGroupId =: UserInfo.getUserId() AND Group.DeveloperName IN :itcPermittedGroups];
        for(GroupMember gm : userGroups){
            userPermittedGroups.add(gm.Group.DeveloperName);
        }
        return userPermittedGroups;
    }

    public Boolean isUserPermittedForDenialsTab(){
        List<PermissionSetAssignment> userHCCompliancePermSet = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name = 'gFRS_Compliance_Flags_Notes'];
        if(!userHCCompliancePermSet.isEmpty()){
            return true;
        }
        return false;
    }

    @RemoteAction
    public static void processDenialBatch(List<String> fundingIds, Boolean isDenialBatch, List<String> itcs){
        if(!fundingIds.isEmpty()){
            String jobType = isDenialBatch ? gFRS_FundingRequestDenialBatch.SET_QCO_REVIEW_STATUS : gFRS_FundingRequestDenialBatch.SET_INTERNAL_TRACKING_CODE;
            GFRS_OrgSettings__c customSettings = GFRS_OrgSettings__c.getOrgDefaults();
            String debugId = 'gFRS_FundingRequestDenialBatch_' + UserInfo.getUserName() + '_' + Datetime.now();
            if(customSettings.DenialBatchSize__c != null && customSettings.DenialBatchExecuteSize__c != null){
                if(fundingIds.size() > customSettings.DenialBatchSize__c){
                    List<String> idsBatch = new List<String>();
                    Integer batchCounter = 1;
                    for(Integer i = 0; i < fundingIds.size(); i++){
                        if(i < batchCounter * customSettings.DenialBatchSize__c){
                            idsBatch.add(fundingIds.get(i));
                        }
                        else{
                            Database.executeBatch(new gFRS_FundingRequestDenialBatch(idsBatch, itcs,
                                    jobType, Integer.valueOf(customSettings.DenialBatchExecuteSize__c), debugId),
                                    Integer.valueOf(customSettings.DenialBatchExecuteSize__c));
                            batchCounter++;
                            idsBatch = new List<String>();
                            idsBatch.add(fundingIds.get(i));
                        }
                    }
                }
                else{
                    Database.executeBatch(new gFRS_FundingRequestDenialBatch(fundingIds, itcs,
                            jobType, Integer.valueOf(customSettings.DenialBatchExecuteSize__c), debugId),
                            Integer.valueOf(customSettings.DenialBatchExecuteSize__c));
                }
            }
        }
    }
}