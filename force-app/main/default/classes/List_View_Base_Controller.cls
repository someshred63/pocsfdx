/************************************************************
*  @author: Grzegorz Zajac, Roche
*  Date: 2013-04-10
*  Description: This is a base class for all SFA2 list view controllers used for storing selected records.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public abstract class List_View_Base_Controller {

    public String selectedRecordsString { get; set; }

    private SFA2_Configuration_Object_gne__c pageConfiguration;
    private String objectName;
    private String selectedView;

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

    public List_View_Base_Controller(String objectName) {
        this.objectName = objectName;
        pageConfiguration = Configuration_Util.getListPageConfiguration(objectName);
    }

    public String[] getSelectedRecords() {
        return selectedRecordsString.split(',');
    }

    public String getSelectedView() {
        return selectedView;
    }

    public void setSelectedView(String selectedView) {
        this.selectedView = selectedView;
    }

    public Component.Apex.PageBlockButtons getButtons() {
        Component.Apex.PageBlockButtons res = Configuration_Util.getCustomButtons(objectName, 'List Page', 'Button');
        res.location = 'top';
        return res;
    }

    public String getListPageName() {
        String result;
        if (pageConfiguration != null) {
            result = pageConfiguration.Section_Header_gne__c;
        } else {
            result = '';
        }
        return result;
    }

    public String getActiveMenuItem() {
        String result = '';
        if (pageConfiguration != null && pageConfiguration.Attributes_gne__c != null && pageConfiguration.Attributes_gne__c.contains('activeMenuItem')) {
            result = pageConfiguration.Attributes_gne__c.substringBetween('activeMenuItem=', ';');
        }
        return result;
    }

    public virtual String getCustomFilterExpression(List_View_Setup_Ext.ConditionItem cItem) {
        return cItem.field + ' ' + cItem.operator + ' ' + cItem.value;
    }
}