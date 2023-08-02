/**
* @author GFRS 2.0 Dev Team
* @date 14/07/2021
* @description gFRS_Util class - utility Class for the GFRS 2.0 application. 
*/
public without sharing class gFRS_Ltng_Util {
    
    public static final String Commercial_Sponsorship = 'Commercial Sponsorship';
    public static final String Community_Giving = 'Community Giving';
    public static final String Continuing_Medical_Education_CME = 'Independent Medical Education (CME)';
    public static final String Corporate_Memberships = 'Corporate Memberships';
    public static final String Education_Focused_Giving_Graduate_and_Under_Graduate = 'Education Focused Giving Graduate and Post-Graduate';
    public static final String Education_Focused_Giving_K12 = 'Education Focused Giving K-12';
    public static final String Field_Exhibits = 'Field Exhibits';
    public static final String TYPE_FIELD_INITIATED_EXHIBITS_DESCRIPTION ='Field Exhibits';
    public static final String Foundation_Safety_Net_Support = 'Foundation Safety Net Support';
    public static final String Foundation_Undergraduate = 'Foundation Undergraduate';
    public static final String Non_Commercial_Sponsorship = 'Non-Commercial Sponsorship';
    public static final String Patient_and_Health_Focused_Giving = 'Patient and Health Focused Giving';
    public static final String Scientific_and_Research_Focused_Giving = 'Scientific and Research Focused Giving';
    public static boolean firstRun = true;
    
    // Added for Payment Process
    public static final String SFDC_ORANGE_POUCH = 'Orange Pouch';
    public static final String SFDC_VENDOR = 'Vendor';
    public static final String SFDC_SALES_REP = 'Field Sales Rep';
    
    public static final String ESB_ORANGE_POUCH = 'OrangePouch';
    public static final String ESB_VENDOR = 'Vendor';
    public static final String ESB_SALES_REP = 'SalesRep';
    
    public static final String ESB_CHEQUE = 'Cheque';
    public static final String ESB_ACH = 'Ach';
    
    public static GFRS_Ltng_OrgSettings__c cs = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
    
    public static String getCustomSettingStringValue(String csName) {
        return String.valueOf(cs.get(csName + '__c'));
    }
    
    
    public static final Set<String> INTERNAL_FUNDING_TYPES = new Set<String>{
        gFRS_Ltng_Util.Commercial_Sponsorship, gFRS_Ltng_Util.Corporate_Memberships, gFRS_Ltng_Util.Field_Exhibits, gFRS_Ltng_Util.Non_Commercial_Sponsorship
            };
                
                public static Boolean isInternalRequest(String recordTypeName) {
                    return INTERNAL_FUNDING_TYPES.contains(recordTypeName);
                }      
    
    // Added for Payment Process
    
    public static String translateDeliveryMethodToESB(String deliveryMethod) {
        if (deliveryMethod == SFDC_ORANGE_POUCH) {
            return(ESB_ORANGE_POUCH);
        } else if (deliveryMethod == SFDC_VENDOR) {
            return(ESB_VENDOR);
        } else if (deliveryMethod == SFDC_SALES_REP) {
            return(ESB_SALES_REP);
        } else {
            return(deliveryMethod);
        }
    } 
    
    public static String determineCompanyCode(List<gFRS_Ltng_Funding_Allocation_Line_Item__c> splits) {
        String result = null;
        try {
            if (splits != null && splits.size() > 0) {
                result = splits[0].Cost_Center_Code__r.SAP_Company_Code__c;
            }
        } catch (Exception err) {
            System.debug('Splits must have the cost center and company code to determine the company code.');
        }
        return(result);
    }
    
    public static String convertFundingTypeSAP(String recordTypeName) {
        if (recordTypeName == gFRS_Util.TYPE_IMED_NAME) {
            return (gFRS_Util.TYPE_IMED_SAP);
        } else if (recordTypeName == gFRS_Util.TYPE_HC_CHAR_NAME) {
            return (gFRS_Util.TYPE_HC_CHAR_SAP);
        } else if (recordTypeName == gFRS_Util.TYPE_PHILANTHROPIC_NAME) {
            return (gFRS_Util.TYPE_PHILANTHROPIC_SAP);
        } else if (recordTypeName == gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME) {
            return (gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_SAP);
        } else if (recordTypeName == gFRS_Util.TYPE_FELLOWSHIPS_NAME) {
            return (gFRS_Util.TYPE_FELLOWSHIPS_SAP);
        } else if (recordTypeName == gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME) {
            return (gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_SAP);
        } else if (recordTypeName == gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME) {
            return (gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_SAP);
        } else if (recordTypeName == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME) {
            return (gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_SAP);
        } else if (recordTypeName == gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME) {
            return (gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_SAP);
        } else {
            return (null);
        }
        
    } 
    public static Boolean isCMEOShown(gFRS_Ltng_Application__c request) {
        return(gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME.equals(request.Record_Type_Name__c) &&
               request.Benefits_Exchanged_for_Funding__c != null &&
               (gFRS_Util.multiSelectHasItem(request.Benefits_Exchanged_for_Funding__c, gFRS_Util.EXHIBIT_SPACE) || gFRS_Util.multiSelectHasItem(request.Benefits_Exchanged_for_Funding__c, gFRS_Util.EXHIBIT_SPACE_PREF_LOCATION))
              );
    }
    
    /**
* @Author gFRS 2.0 Team
* @date 27/8/2021
* @description getFundingRequestsByLocationId method - getter util method for querying gFRS_Ltng_Application__c objects from database for a given location id, but only with Status != "Intake","Closed".
*/
    public static List<gFRS_Ltng_Application__c> getFundingRequestsByLocationId(String locationId) {
        
        return [SELECT Id, Name, Record_Type__c, Vendor_Detail__c, Person_To_Whom_Payment_should_addressed__c, Giact_Response__c FROM gFRS_Ltng_Application__c WHERE Vendor_Detail__c = :locationId AND Status__c NOT IN ('Intake', 'Closed') ORDER BY Record_Type__c];
    }    
    public static List<gFRS_Ltng_CAF_Application__c> getCAFFundingRequestsByLocationId(String locationId) {
        
        return [SELECT Id, Name, Vendor_Detail__c, Payment_Contact_Email_Address__c FROM gFRS_Ltng_CAF_Application__c WHERE Vendor_Detail__c = :locationId AND Status__c NOT IN ('Intake', 'Closed') ORDER BY Record_Type__c];
    }
    
/**
* @author GFRS Dev Team
* @date 29/03/2022
* @description linkBudgetLIsToFMV method - Creates links from Budget Line Items records to FMV Records.
*/
  /*  public static void linkBudgetLIsToFMV(gFRS_Ltng_Request_Budget_Detail__c[] newBudgetLIs, Map<Id, gFRS_Ltng_Request_Budget_Detail__c> oldBudgetLIsMap) {

        gFRS_Ltng_Request_Budget_Detail__c[] budgetLIs = [SELECT Id, Name, FMV_Lower__c, gFRS_Request_Budget__r.Budget_Summary_Description__c, Category__c, Subcategory__c, gFRS_Request_Budget__r.gFRS_Application__c FROM gFRS_Ltng_Request_Budget_Detail__c WHERE Id IN :newBudgetLIs];

        gFRS_Ltng_FMV__c[] eligibleFMVs = [SELECT Id, Lower_Amount__c, Median_Amount__c, Upper_Amount__c, Budget_Category__c, Budget_SubCategory__c, Program_Name__c FROM gFRS_Ltng_FMV__c];

        Map<String, gFRS_Ltng_FMV__c> virtualMap = new Map<String, gFRS_Ltng_FMV__c>();
        Map<String, gFRS_Ltng_FMV__c> digitalMap = new Map<String, gFRS_Ltng_FMV__c>();
        Map<String, gFRS_Ltng_FMV__c> liveMap = new Map<String, gFRS_Ltng_FMV__c>();
        String fmvKey = null;

        for (gFRS_Ltng_FMV__c fmv : eligibleFMVs) {
            fmvKey = fmv.Budget_Category__c + '-' + fmv.Budget_SubCategory__c;
            if (fmv.Program_Name__c == null) {
            } else if (fmv.Program_Name__c == 'Symposium') {
                virtualMap.put(fmvKey, fmv);
            } else if (fmv.Program_Name__c == 'Digital or Printed Resource') {
                digitalMap.put(fmvKey, fmv);
            } else if (fmv.Program_Name__c == 'Meeting Series' || fmv.Program_Name__c == 'Satellite Symposium') {
                liveMap.put(fmvKey, fmv);
            }
        }

        gFRS_Ltng_Request_Budget_Detail__c oldBudgetLI = null;
        gFRS_Ltng_Request_Budget_Detail__c[] updatedLIs = new gFRS_Ltng_Request_Budget_Detail__c[]{};

        gFRS_Ltng_FMV__c fmv = null;
        Map<String, gFRS_Ltng_FMV__c> fmvMap = null;

        gFRS_Ltng_Request_Budget_Detail__c[] eligibleLIs = new gFRS_Ltng_Request_Budget_Detail__c[]{};
        gFRS_ObjectUtil.filterChangedObjects(budgetLIs, oldBudgetLIsMap, 'Subcategory__c', eligibleLIs);

//-- only iterate over those that have changed the subcategory
        for (gFRS_Ltng_Request_Budget_Detail__c budgetLI : eligibleLIs) {

//-- determine which fmvMap we use
            
            if (budgetLI.gFRS_Request_Budget__r.Budget_Summary_Description__c != null && budgetLI.gFRS_Request_Budget__r.Budget_Summary_Description__c == 'Budget for Live Activity') {
                //fmvMap = liveMap;
                System.debug('--------------live');
                gFRS_Ltng_Program__c[] programList = [SELECT gFRS_Program_Live_Subtype__c FROM gFRS_Ltng_Program__c WHERE gFRS_Application__c = :budgetLI.gFRS_Request_Budget__r.gFRS_Application__c];
                for (gFRS_Ltng_Program__c p : programList) {
                    if (p.gFRS_Program_Live_Subtype__c == 'Satellite Symposium' || p.gFRS_Program_Live_Subtype__c == 'Meeting Series') {
                        System.debug('--------------live');
                        fmvMap = liveMap;
                        break;
                    }
                }
            } else if (budgetLI.gFRS_Request_Budget__r.Budget_Summary_Description__c != null && budgetLI.gFRS_Request_Budget__r.Budget_Summary_Description__c == 'Budget for virtual Activity') {
                //fmvMap = virtualMap;
                System.debug('--------------Virtual');
                gFRS_Ltng_Program__c[] programList = [SELECT gFRS_Program_Live_Subtype__c FROM gFRS_Ltng_Program__c WHERE gFRS_Application__c = :budgetLI.gFRS_Request_Budget__r.gFRS_Application__c];
                for (gFRS_Ltng_Program__c p : programList) {
                    if (p.gFRS_Program_Live_Subtype__c == 'Symposium') {
                        System.debug('--------------virtual');
                        fmvMap = virtualMap;
                        break;
                    }
                }
            } else {
                System.debug('--------------enduring');
                fmvMap = digitalMap;
            }

            fmv = null;
            fmvKey = budgetLI.Category__c + '-' + budgetLI.Subcategory__c;
            
            if(fmvMap != null){
                if (fmvMap.get(fmvKey) != null) {
                    System.debug('--------------cat exists');
                    fmv = fmvMap.get(fmvKey);
                }
            }
            
            System.debug('fmvFound : ' + fmv);

            if (fmv != null) {
                budgetLI.FMV_Lower__c = fmv.Lower_Amount__c;
                budgetLI.FMV_Median__c = fmv.Median_Amount__c;
                budgetLI.FMV_Upper__c = fmv.Upper_Amount__c;
            } else {
                budgetLI.FMV_Lower__c = null;
                budgetLI.FMV_Median__c = null;
                budgetLI.FMV_Upper__c = null;
            }
            updatedLIs.add(budgetLI);

        }
        System.debug('updatedLIs:' + updatedLIs);

        update updatedLIs;
    }   */
    
    public static void afterinsert_linkBudgetLIsToFMV(gFRS_Ltng_Request_Budget_Detail__c[] newBudgetLIs){
        
        linkBudgetLIsToFMV(newBudgetLIs);
    }
    
    public static void afterupdate_linkBudgetLIsToFMV(gFRS_Ltng_Request_Budget_Detail__c[] newBudgetLIs,Map<Id, gFRS_Ltng_Request_Budget_Detail__c> oldBudgetLIsMap){
        
        List<gFRS_Ltng_Request_Budget_Detail__c> budgetLiToUpdate = new List<gFRS_Ltng_Request_Budget_Detail__c>();
        
        for (gFRS_Ltng_Request_Budget_Detail__c rbd : newBudgetLIs){
            if ((rbd.Category__c != oldBudgetLIsMap.get(rbd.id).Category__c) ||
               (rbd.Subcategory__c != oldBudgetLIsMap.get(rbd.id).Subcategory__c)){
                budgetLiToUpdate.add(rbd);
            }
        }
        
        linkBudgetLIsToFMV(budgetLiToUpdate);
    }
    
    public static void linkBudgetLIsToFMV(gFRS_Ltng_Request_Budget_Detail__c[] newBudgetLIs) {

        if (firstRun){
        
        gFRS_Ltng_Request_Budget_Detail__c[] budgetLIs = [SELECT Id, Name, FMV_Lower__c, gFRS_Request_Budget__r.Budget_Summary_Description__c, Category__c, Subcategory__c, gFRS_Request_Budget__r.gFRS_Application__c FROM gFRS_Ltng_Request_Budget_Detail__c WHERE Id IN :newBudgetLIs];

        gFRS_Ltng_FMV__c[] eligibleFMVs = [SELECT Id, Lower_Amount__c, Median_Amount__c, Upper_Amount__c, Budget_Category__c, Budget_SubCategory__c, Program_Name__c FROM gFRS_Ltng_FMV__c];

        Map<String, gFRS_Ltng_FMV__c> virtualMap = new Map<String, gFRS_Ltng_FMV__c>();
       /* Map<String, gFRS_Ltng_FMV__c> digitalMap = new Map<String, gFRS_Ltng_FMV__c>();
        Map<String, gFRS_Ltng_FMV__c> liveMap = new Map<String, gFRS_Ltng_FMV__c>();  */
        String fmvKey = null;

        for (gFRS_Ltng_FMV__c fmv : eligibleFMVs) {
            fmvKey = fmv.Budget_Category__c + '-' + fmv.Budget_SubCategory__c;
            virtualMap.put(fmvKey, fmv);
        }

        gFRS_Ltng_Request_Budget_Detail__c oldBudgetLI = null;
        gFRS_Ltng_Request_Budget_Detail__c[] updatedLIs = new gFRS_Ltng_Request_Budget_Detail__c[]{};

        gFRS_Ltng_FMV__c fmv = null;
        Map<String, gFRS_Ltng_FMV__c> fmvMap = null;

        gFRS_Ltng_Request_Budget_Detail__c[] eligibleLIs = new gFRS_Ltng_Request_Budget_Detail__c[]{};
        
            for (gFRS_Ltng_Request_Budget_Detail__c rb : budgetLIs){
                eligibleLIs.add(rb);
            }
            
        //gFRS_ObjectUtil.filterChangedObjects(budgetLIs, oldBudgetLIsMap, 'Subcategory__c', eligibleLIs);

//-- only iterate over those that have changed the subcategory
        for (gFRS_Ltng_Request_Budget_Detail__c budgetLI : eligibleLIs) {


            fmvMap = virtualMap;
            
            fmv = null;
            fmvKey = budgetLI.Category__c + '-' + budgetLI.Subcategory__c;
            
            if(fmvMap != null){
                if (fmvMap.get(fmvKey) != null) {
                    System.debug('--------------cat exists');
                    fmv = fmvMap.get(fmvKey);
                }
            }
            
            System.debug('fmvFound : ' + fmv);

            if (fmv != null) {
                budgetLI.FMV_Lower__c = fmv.Lower_Amount__c;
                budgetLI.FMV_Median__c = fmv.Median_Amount__c;
                budgetLI.FMV_Upper__c = fmv.Upper_Amount__c;
            } else {
                budgetLI.FMV_Lower__c = null;
                budgetLI.FMV_Median__c = null;
                budgetLI.FMV_Upper__c = null;
            }
            updatedLIs.add(budgetLI);

        }
        System.debug('updatedLIs:' + updatedLIs);
		firstRun = false;
        update updatedLIs;
        }
    }
    
    public static gFRS2_0_Shutdown_Rule__c checkShutdownRule(String fundingRecordTypeName) {
gFRS2_0_Shutdown_Rule__c result = null;
Date currentDate = Date.today();
List<gFRS2_0_Shutdown_Rule__c> shutdownRules = [SELECT Message__c, Funding_type__c,Active__c FROM gFRS2_0_Shutdown_Rule__c WHERE Start_date__c <= :currentDate AND End_date__c >= :currentDate AND Active__c = true];
if (!shutdownRules.isEmpty()) {
    for (gFRS2_0_Shutdown_Rule__c sdr : shutdownRules) {
        if (sdr.Funding_type__c.contains(fundingRecordTypeName)) {
            sdr.Message__c = sdr.Message__c.replaceAll('<b>', '');
            result = sdr;
            break;
        }
    }
}

return result;
}
      
}