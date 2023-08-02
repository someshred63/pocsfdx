/************************************************************
*  @author: Michal Zaganczyk (michal.zaganczyk@contractors.roche.com)
*  Date: 2013-5-9
*  Description: Standard controller extension for Market_Insight_gne__c object, used by the 
*  VF page which overrides the standard view layout for the Market_Insight_gne__c object.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_FRM_Market_Insight_Ext {
    
    /**
     * Current Market Insight record to view.
     */
    private final Market_Insight_gne__c marketInsight;
    
    /**
     * Associations of the current Market Insight with Cases.
     */
    public final GNE_FRM_Market_Insights_Case_Assoc_Util.MarketInsightCaseAssociations caseAssociations {get; private set;}
    
    /**
     * Current User context info (role, isMonitor etc.)
     */
    public final GNE_FRM_Market_Insights_EdCr_Ctrlr.FRMUserContextInfo currentUser {get; private set;}
    
    /**
     * Constructor. Initializes properties based on the data passed by the standard controller.
     */
    public GNE_FRM_Market_Insight_Ext(ApexPages.StandardController stdController) {
        this.marketInsight = (Market_Insight_gne__c) stdController.getRecord();
        this.currentUser = new GNE_FRM_Market_Insights_EdCr_Ctrlr.FRMUserContextInfo();
        this.caseAssociations = new GNE_FRM_Market_Insights_Case_Assoc_Util.MarketInsightCaseAssociations();
        this.caseAssociations.load(this.marketInsight.Id);
    }
    
    /**
     * Action handler for the "Edit" button. Redirects to the edit-mode layout.
     */
    public PageReference editAction() {
        PageReference pr = new PageReference('/apex/GNE_FRM_Market_Insights_Edit_Create?id=' 
            + this.marketInsight.Id + '&mode=edit&retUrl=/'+ this.marketInsight.Id);
        pr.setRedirect(true);
        return pr;
    }
}