public with sharing class GNE_CM_MHRA_Hotline_PDF_Controller 
{
	public transient Hotline_gne__c hotlineRecord { get; set; }
    public transient Account accountRecord { get; set; }

    public transient List<Task> openActivityList { get; set; }
    public transient List<Task> activityHistoryList { get; set; }

    public transient List<String> hotlineFields { get; set; }
    public transient List<String> taskFields { get; set; }
    public transient List<String> accountFields { get; set; }

    public transient Map<String, String> hotlineLabels { get; set; }
    public transient Map<String, String> taskLabels { get; set; }
    public transient Map<String, String> accountLabels { get; set; }

    public Set<String> fields2Hide=new Set<String> { 'Id', 'Name', 'CaseNumber', 'Subject', 'IsDeleted', 'IsLocked', 'MayEdit', 'SpringCM_PoC__c'};

    public GNE_CM_MHRA_Hotline_PDF_Controller (ApexPages.StandardController stdController) 
    {
        string hotlineId = stdController.getId();

       // load in our labels
        
        hotlineLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('Hotline_gne__c');
        taskLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('Task');
        accountLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('Account');


        openActivityList = new List<Task>();
        activityHistoryList = new List<Task>();
        
        hotlineFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('Hotline_gne__c');
        taskFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('Task');
        accountFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('Account');

        // sort
        hotlineFields.sort();
        taskFields.sort();
        accountFields.sort();

        // push the 'Name' field to the top
        hotlineFields.add(0, 'Name');
        taskFields.add(0, 'Subject');
        accountFields.add(0, 'Name');

        hotlineRecord = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('Hotline_gne__c', hotlineFields, 'id', hotlineId));

        if (hotlineRecord.Physician_Hospital_gne__c != null) 
        {
            accountRecord = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('Account', accountFields, 'id', hotlineRecord.Physician_Hospital_gne__c));
        }

        for (Task t : Database.query('SELECT ' + GlobalUtils.implode(taskFields, ', ') + ' FROM Task WHERE WhatId = :hotlineId ORDER BY ActivityDate ALL ROWS'))
        {
            if (t.isClosed)
            {
                activityHistoryList.add(t);
            }
            else
            {
                openActivityList.add(t);
            }
        }

    }    	
}