/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-12-11
*  Description: This is a base class for all SFA2 list view controllers used for storing selected records.
*  
*  Modification History
*  Date        Name        Description
*  4/17/2013   osowiecb    Add handling for custom filter
*  8/06/2013   kozminsl    Remove unworked functions   
*  2/24/2015   smagaw1     Add setPageConfiguration    
*************************************************************/
public abstract class GNE_SFA2_List_View_Base_Controller {
	private Set<Id> selectedRecords;
    private SFA2_Configuration_Object_gne__c pageConfiguration;
    private String objectName;
    
    public Object customFilterVariable_1;
    public Object customFilterVariable_2;
    public Object customFilterVariable_3;
    public Object customFilterVariable_4;
    public Object customFilterVariable_5;
    public Object customFilterVariable_6;
    public Object customFilterVariable_7;
    public Object customFilterVariable_8;
    public Object customFilterVariable_9;
    public Object customFilterVariable_10;
    
    public GNE_SFA2_List_View_Base_Controller(String objectName) {
        this.objectName = objectName;
        pageConfiguration = GNE_SFA2_Util.getListPageConfiguration(objectName);
    }

    public Component.Apex.PageBlockButtons getButtons() {
        return GNE_SFA2_Util.getCustomButtons(objectName, 'List Page', 'Button');
    }
    
    public String getListPageName() {
        String result;
        if(pageConfiguration != null) {
            result = pageConfiguration.Section_Header_gne__c;
        } else {
            result = '';
        }
        return result;
    }
    
    public String getActiveMenuItem() {
        String result = '';
        if(pageConfiguration != null && pageConfiguration.Attributes_gne__c!=null && pageConfiguration.Attributes_gne__c.contains('activeMenuItem')){
            result = pageConfiguration.Attributes_gne__c.substringBetween('activeMenuItem=',';');
        }
        return result;
    }
    
    public virtual String getCustomFilterExpression(GNE_SFA2_List_View_Setup_Ext.ConditionItem cItem) {
    	return '';
    }
    
    public void setSelectedRecords(Set<Id> selectedRecords) {
        this.selectedRecords = selectedRecords;
    }
    
    public Set<Id> getSelectedRecords() {
        return selectedRecords;
    }

    //for classification log
    public void setPageConfiguration(SFA2_Configuration_Object_gne__c pageConfiguration) {
        this.pageConfiguration = pageConfiguration;
    }
}