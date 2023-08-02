/************************************************************
*  @author: Konrad Russa, Roche
*  Date: 2013-09-05
*  This is a CFAR Home Page (tab) controller
*    
*  Modification History
*  Date        Name        Description
2013-09-10 Maciej Stefański     Add redirection from "New" button
*************************************************************/
public with sharing class CFAR_Home_Controller extends CFAR_BaseController{
    private SFA2_Configuration_Object_gne__c pageConfiguration;
    
    //pagination
    final Integer pageSize = 10;
    private ApexPages.StandardSetController stdSetControllerTrial;
    public List<CFAR_SObjectWrapper> objectListTrial {get; set;}
    public Map<Id, CFAR_SObjectWrapper> objectMapTrial {get; set;}
    public List<AlertWrapper> alerts {get;set;}
    public List<AlertWrapper> displayedAlerts {get;set;}
    private Integer currentPage = 1;
    private Integer lastPage;
        
    public Boolean showSummary {get;set;}
        
    public PageReference myTrialsRef{get;private set;}
    
    public CFAR_Home_Controller() {
        pageConfiguration = GNE_SFA2_Util.getListPageConfiguration('CFAR_Home');
        PageReference pr = ApexPages.currentPage();
        pr.getParameters().put('parentPage','CFAR_Home');
        
        if (pr.getParameters().containsKey('trialadded')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, String.format(Label.CFAR_TRIAL_ADDED, new String[]{pr.getParameters().get('trialadded')})));
        }
   
        showSummary = false;
        myTrialsRef = Page.CFAR_MyTrials;
        sortExpression = 'TrialNumber';
        sortDirection = 'asc';
        alerts = createAlertWrappers();
        for (AlertWrapper aw : alerts) {
        	aw.alertSortDirection = String.valueOf(sortDirection);
        	aw.alertSortExpression = String.valueOf(sortExpression);
        }
        alerts.sort();
        initializePagination();
    }

    public String getActiveMenuItem() {
        String result = '';
        if (pageConfiguration != null && pageConfiguration.Attributes_gne__c!=null && pageConfiguration.Attributes_gne__c.contains('activeMenuItem')) {
            result = pageConfiguration.Attributes_gne__c.substringBetween('activeMenuItem=',';');
        }
        return result;
    }

    public Boolean getRenderNewButton() {
        return CFAR_Utils.isCurrentUserAdmin() || getIsAverageUser(); 
    }
    
    public PageReference createTrial() {
        PageReference newTrialPage = Page.CFAR_NewTrial;  //new PageReference();
        newTrialPage.getParameters().put('retURL', URL.getCurrentRequestUrl().toExternalForm() );  
        return newTrialPage; 
    }
   
    public List<AlertWrapper> createAlertWrappers() {
        Id currentUserId = Id.valueOf(UserInfo.getUserId());
    
        Set<Id> trialsWhereCurrentUserShouldSeeAlerts = CFAR_Utils.getTrialsWhereCurrentUserShouldSeeAlerts(currentUserId);
    
        List<AlertWrapper> alertWrappers = new List<AlertWrapper>();
        Date today = Date.today();
        Date compareDate = today.addDays(31);
        Date compareDateNegative = today.addDays(-30);
        Date oneBusinessWeekCompareDate = today.addDays(7);
    
        alertWrappers.addAll(CFAR_Utils.getRegulatoryDocumentAlertWrappers(trialsWhereCurrentUserShouldSeeAlerts, compareDate, compareDateNegative, today));
        alertWrappers.addAll(CFAR_Utils.getMilestoneActivityAlertWrappers(trialsWhereCurrentUserShouldSeeAlerts, compareDate, today));
        alertWrappers.addAll(CFAR_Utils.getContractAlertWrappers(trialsWhereCurrentUserShouldSeeAlerts, today));
    
        return alertWrappers;
    }
    
    public void initializePagination() {
        lastPage = getLastPageNum();
        firstAlert();
    }
    
    public Integer getLastPageNum() {
        if (math.mod(alerts.size(), pageSize) > 0) {
             return alerts.size()/pageSize;
        } else {
             return (alerts.size()/pageSize) - 1;
        }
    }
    
    public void firstAlert() {
        currentPage = 0;
        populateDisplayAlerts();
    }
    
    public void lastAlert() {
         currentPage = lastPage;
         populateDisplayAlerts();
    }
    
    public void nextAlert() {
        currentPage++;
        populateDisplayAlerts();
    }
    
    public void previousAlert() {
        currentPage--;
        populateDisplayAlerts();
    }
    
    private void populateDisplayAlerts() {
        Integer index = 0;
        displayedAlerts = new List<AlertWrapper>();
        for(AlertWrapper alert : alerts) {
            if (index >= currentPage * pageSize && index < (currentPage + 1) * pageSize) {
                displayedAlerts.add(alert);
            }
            index++;
        }
    }
    
    public void sortAlerts() {
        for (AlertWrapper aw : alerts) {
        	aw.alertSortDirection = String.valueOf(sortDirection);
        	aw.alertSortExpression = String.valueOf(sortExpression);
        }   
        alerts.sort();
        firstAlert();    
    }
    
    public boolean hasNextAlert{
        get{
            return currentPage < lastPage;
        }
        private set;
    }

    public boolean hasPreviousAlert{
        get{
            return currentPage > 0;
        }
        private set;
    }
   
    public class AlertWrapper implements Comparable {
        public String alert {get;set;}
        public String CTMS {get; set;}
        public String investigator {get;set;}
        public String trialNumber {get;set;}
        public String trialId {get;set;}
        public String alertSortDirection;
        public String alertSortExpression;
        
        public AlertWrapper(String alert, String investigator, String trialNumber, Id trialId) {
            this.alert = alert;
            this.investigator = investigator;
            this.trialNumber = trialNumber;
            this.trialId = trialId;
        }

        public AlertWrapper(String alert, String investigator, String trialNumber, String ctmsNumber, Id trialId) {
            this.alert = alert;
            this.investigator = investigator;
            this.trialNumber = trialNumber;
            this.CTMS = ctmsNumber;
            this.trialId = trialId;
        }
        
        public Integer compareTo(Object compareTo) {
        	AlertWrapper compareToAW = (AlertWrapper)compareTo;
        	Integer ret = 0;
        	Integer multiplier = (this.alertSortDirection == 'desc' && compareToAW.alertSortDirection == 'desc') ? -1 : 1;
        	if (this.alertSortExpression == 'TrialNumber' && compareToAW.alertSortExpression == 'TrialNumber' && this.trialNumber != null && compareToAW.trialNumber != null) {
        		ret = this.trialNumber.compareTo(compareToAW.trialNumber) * multiplier;
        	}
        	else if (this.alertSortExpression == 'Investigator' && compareToAW.alertSortExpression == 'Investigator' && this.investigator != null && compareToAW.investigator != null) {
        		ret = this.investigator.compareTo(compareToAW.investigator) * multiplier;
        	}
            else if (this.alertSortExpression == 'CTMS' && compareToAW.alertSortExpression == 'CTMS' && this.CTMS != null && compareToAW.CTMS != null) {
        		ret = this.CTMS.compareTo(compareToAW.CTMS) * multiplier;
        	}
        	return ret;
        }
    }
}