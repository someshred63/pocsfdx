@isTest
public class Merge_Type_Controller_Test {
	
	private static final string REGION_CODE_CANADA = '2';
    private static final string REGION_CODE_US = '1';

    // test method canada merge project
    // initial version -  guru k dec 10 2012
    public static Merge_Type_gne__c createAccountMergeType (Decimal regionCode) {
        Merge_Type_gne__c mergeType = new  Merge_Type_gne__c( Name = 'Account', object_name_gne__c = 'Account', region_code_gne__c = regionCode, OwnerId = getMergeUser().Id);
        insert mergeType;

        List<Merge_Type_Business_Rule_gne__c> ruleList = new List<Merge_Type_Business_Rule_gne__c>();
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Name',field_type_gne__c = 'Not Null', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Phone',field_type_gne__c = 'Not Null', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Chemo_Center_can_gne__c',field_type_gne__c = 'Boolean OR', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Fax',field_type_gne__c = 'DeferOnConflict', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Website',field_type_gne__c = 'DeferOnConflictConsiderNullAsUnique', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'NumberOfEmployees',field_type_gne__c = 'PreferLowValue', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'AnnualRevenue',field_type_gne__c = 'PreferHighValue', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'createddate asc',field_type_gne__c = 'Sort By Columns', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Archive Query 1',field_type_gne__c = 'Archive Query', active_gne__c = true, RelatedList_Query_Text_gne__c='select id, name from account'));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'updateLoserParentCalls()',field_type_gne__c = 'CustomPreMergeAction', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'updateAddressPrimaryFlag()',field_type_gne__c = 'CustomPostMergeAction', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = (regionCode == 2 ? 'Canada ' : '') + 'Archived Records',field_type_gne__c = 'Archive Owner', active_gne__c = true));
        insert ruleList;
 
        return mergeType;
    }

    public static Merge_Type_gne__c createPersonAccountAddressMergeTypeWithDeferOnLoserSignificantRelatedListCountOnCall (Decimal regionCode) {
        Merge_Type_gne__c mergeType = new  Merge_Type_gne__c( Name = 'Person Account Address', object_name_gne__c = 'Address_vod__c', region_code_gne__c = regionCode, OwnerId = getMergeUser().Id);
        insert mergeType;

        List<Merge_Type_Business_Rule_gne__c> ruleList = new List<Merge_Type_Business_Rule_gne__c>();
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Name',field_type_gne__c = 'Not Null', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'city_vod__c',field_type_gne__c = 'Not Null', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'state_vod__c',field_type_gne__c = 'DeferOnConflict', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'createddate asc',field_type_gne__c = 'Sort By Columns', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Archive Query 1',field_type_gne__c = 'Archive Query', active_gne__c = true, RelatedList_Query_Text_gne__c='select id from address_vod__c'));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Call2_vod__r',field_type_gne__c = 'DeferOnLoserSignificantRelatedListCount', active_gne__c = true, RelatedList_Query_Text_gne__c='select id from call2_vod__r', exception_code_gne__c='DeferOnLoserAddressHavingCalls'));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = (regionCode == 2 ? 'Canada ' : '') + 'Archived Records',field_type_gne__c = 'Archive Owner', active_gne__c = true));
        insert ruleList;

        return mergeType;
    }

    public static Merge_Type_gne__c createPersonAccountMergeType (Decimal regionCode) {
        Merge_Type_gne__c mergeType = new  Merge_Type_gne__c( Name = 'Person Account', object_name_gne__c = 'Account', region_code_gne__c = regionCode, OwnerId = getMergeUser().Id);
        insert mergeType;

        List<Merge_Type_Business_Rule_gne__c> ruleList = new List<Merge_Type_Business_Rule_gne__c>();
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'FirstName',field_type_gne__c = 'Not Null', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Phone',field_type_gne__c = 'Not Null', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Fax',field_type_gne__c = 'DeferOnConflict', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'createddate asc',field_type_gne__c = 'Sort By Columns', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Archive Query 1',field_type_gne__c = 'Archive Query', active_gne__c = true, RelatedList_Query_Text_gne__c='select id, ispersonaccount, firstname, lastname from account'));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'updateLoserParentCalls()',field_type_gne__c = 'CustomPreMergeAction', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'updateAddressPrimaryFlag()',field_type_gne__c = 'CustomPostMergeAction', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = (regionCode == 2 ? 'Canada ' : '') + 'Archived Records',field_type_gne__c = 'Archive Owner', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Tier_Level_gne__c',field_type_gne__c = 'Not Null', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'HCP_Stakeholder_Type_gne__c',field_type_gne__c = 'Not Null', active_gne__c = true));
        insert ruleList;

        return mergeType;
    }

    public static Merge_Type_gne__c createAccountAddressMergeType (Decimal regionCode) {
        Merge_Type_gne__c mergeType = new  Merge_Type_gne__c( Name = 'Account Address', object_name_gne__c = 'Address_vod__c', region_code_gne__c = regionCode, OwnerId = getMergeUser().Id);
        insert mergeType;

        List<Merge_Type_Business_Rule_gne__c> ruleList = new List<Merge_Type_Business_Rule_gne__c>();
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Name',field_type_gne__c = 'Not Null', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'city_vod__c',field_type_gne__c = 'Not Null', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'state_vod__c',field_type_gne__c = 'DeferOnConflict', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'createddate asc',field_type_gne__c = 'Sort By Columns', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Archive Query 1',field_type_gne__c = 'Archive Query', active_gne__c = true, RelatedList_Query_Text_gne__c='select id from address_vod__c'));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Call2_vod__r',field_type_gne__c = 'Relationship To Move', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Account_vod__c',field_type_gne__c = 'DeferOnConflict', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'updateAddressPrimaryFlag()',field_type_gne__c = 'CustomPostMergeAction', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = (regionCode == 2 ? 'Canada ' : '') + 'Archived Records',field_type_gne__c = 'Archive Owner', active_gne__c = true));
        insert ruleList;

        return mergeType;
    }

    public static Merge_Type_gne__c createPersonAccountAddressMergeType (Decimal regionCode) {
        Merge_Type_gne__c mergeType = new  Merge_Type_gne__c( Name = 'Person Account Address', object_name_gne__c = 'Address_vod__c', region_code_gne__c = regionCode, OwnerId = getMergeUser().Id);
        insert mergeType;

        List<Merge_Type_Business_Rule_gne__c> ruleList = new List<Merge_Type_Business_Rule_gne__c>();
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Name',field_type_gne__c = 'Not Null', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'city_vod__c',field_type_gne__c = 'Not Null', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'state_vod__c',field_type_gne__c = 'DeferOnConflict', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'createddate asc',field_type_gne__c = 'Sort By Columns', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Archive Query 1',field_type_gne__c = 'Archive Query', active_gne__c = true, RelatedList_Query_Text_gne__c='select id from address_vod__c'));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Call2_vod__r',field_type_gne__c = 'Relationship To Move', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Account_vod__c',field_type_gne__c = 'DeferOnConflict', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'updateAddressPrimaryFlag()',field_type_gne__c = 'CustomPostMergeAction', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = (regionCode == 2 ? 'Canada ' : '') + 'Archived Records',field_type_gne__c = 'Archive Owner', active_gne__c = true));
        insert ruleList;

        return mergeType;
    }

    public static Merge_Type_gne__c createTerritoryFieldMergeType (Decimal regionCode) {
        Merge_Type_gne__c mergeType = new  Merge_Type_gne__c( Name = 'TerritoryField', object_name_gne__c = 'tsf_vod__c', region_code_gne__c = regionCode, OwnerId = getMergeUser().Id);
        insert mergeType;

        List<Merge_Type_Business_Rule_gne__c> ruleList = new List<Merge_Type_Business_Rule_gne__c>();
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Name',field_type_gne__c = 'Not Null', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Account_vod__c',field_type_gne__c = 'Not Null', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Territory_vod__c',field_type_gne__c = 'DeferOnConflict', active_gne__c = true));

        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Account_vod__c, Allowed_Products_vod__c, lastmodifieddate desc',field_type_gne__c = 'Sort By Columns', active_gne__c = true));
        // test purpose unique key, production rule will be using Unique_Key_Calc_gne__c
        // see test method testInsertCandidateBatchShouldFindDuplicates 
        //ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Unique_Key_Calc_gne__c',field_type_gne__c = 'Unique Set Field Name', active_gne__c = true));
        //ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Account_vod__c, Territory_vod__c, lastmodifieddate desc',field_type_gne__c = 'Sort By Columns', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Allowed_Products_vod__c',field_type_gne__c = 'Unique Set Field Name', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Region_code_gne__c = ' + regionCode,field_type_gne__c = 'Where Clause', active_gne__c = true));

        insert ruleList;

        return mergeType;
    }

    public static Merge_Type_gne__c createTerritoryFieldMergeTypeWithoutUniqueKeyFieldRule (Decimal regionCode) {
        Merge_Type_gne__c mergeType = new  Merge_Type_gne__c( Name = 'TerritoryField', object_name_gne__c = 'tsf_vod__c', region_code_gne__c = regionCode, OwnerId = getMergeUser().Id);
        insert mergeType;

        List<Merge_Type_Business_Rule_gne__c> ruleList = new List<Merge_Type_Business_Rule_gne__c>();
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Name',field_type_gne__c = 'Not Null', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Account_vod__c',field_type_gne__c = 'Not Null', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Territory_vod__c',field_type_gne__c = 'DeferOnConflict', active_gne__c = true));

        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Account_vod__c, Territory_vod__c, lastmodifieddate desc',field_type_gne__c = 'Sort By Columns', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Region_code_gne__c = ' + regionCode,field_type_gne__c = 'Where Clause', active_gne__c = true));

        insert ruleList;

        return mergeType;
    }
    
    public static Merge_Type_gne__c createTargetAndTiersMergeType (Decimal regionCode) {
        Merge_Type_gne__c mergeType = new  Merge_Type_gne__c( Name = 'Targets and Tiers', object_name_gne__c = 'Targets_and_Tiers_can_gne__c', region_code_gne__c = regionCode, OwnerId = getMergeUser().Id);
        insert mergeType;

        List<Merge_Type_Business_Rule_gne__c> ruleList = new List<Merge_Type_Business_Rule_gne__c>();
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'My_Target_gne__c',field_type_gne__c = 'DeferOnConflict', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Tier_can_gne__c',field_type_gne__c = 'Not Null', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Segment_gne__c',field_type_gne__c = 'Not Null', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'createddate asc',field_type_gne__c = 'Sort By Columns', active_gne__c = true));                
        insert ruleList;

        return mergeType;
    }
    
    public static Merge_Type_gne__c createAffiliationMergeType (Decimal regionCode) {

        Merge_Type_gne__c mergeType = new  Merge_Type_gne__c( Name = 'Affiliation', object_name_gne__c = 'Affiliation_vod__c', region_code_gne__c = regionCode, OwnerId = getMergeUser().Id);
        insert mergeType;

        List<Merge_Type_Business_Rule_gne__c> ruleList = new List<Merge_Type_Business_Rule_gne__c>();
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'To_Account_vod__c',field_type_gne__c = 'DeferOnConflict', active_gne__c = true));        
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Source_gne__c',field_type_gne__c = 'Not Null', active_gne__c = true));        
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Note_gne__c',field_type_gne__c = 'Not Null', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Parent_vod__c',field_type_gne__c = 'Boolean OR', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'createddate asc',field_type_gne__c = 'Sort By Columns', active_gne__c = true));                
        insert ruleList;
        					
        return mergeType;
    }

	public static Merge_Type_gne__c createBrandAffiliationsMergeType (Decimal regionCode) {

        Merge_Type_gne__c mergeType = new  Merge_Type_gne__c( Name = 'Brand Affiliations', object_name_gne__c = 'Product_Metrics_vod__c', region_code_gne__c = regionCode, OwnerId = getMergeUser().Id);
        insert mergeType;

        List<Merge_Type_Business_Rule_gne__c> ruleList = new List<Merge_Type_Business_Rule_gne__c>();
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Account_vod__c',field_type_gne__c = 'DeferOnConflict', active_gne__c = true));        
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Advocacy_Assessment_gne__r',field_type_gne__c = 'Relationship To Move', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Brand_Affiliation_Status_gne__c',field_type_gne__c = 'Not Null', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Tier_gne__c',field_type_gne__c = 'Not Null', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'Company_Target_gne__c',field_type_gne__c = 'Boolean OR', active_gne__c = true));
        ruleList.add ( new Merge_Type_Business_Rule_gne__c ( Merge_Type_ref_gne__c = mergeType.Id,field_name_gne__c = 'createddate asc',field_type_gne__c = 'Sort By Columns', active_gne__c = true));                
        insert ruleList;

        return mergeType;
    }
    
    private static GNE_SFA2_Merge_Mode_gne__c switchMergeMode(Boolean mergeModeOn) {
    	GNE_SFA2_Merge_Mode_gne__c mergeModeSetting = GNE_SFA2_Merge_Mode_gne__c.getInstance();
		mergeModeSetting.GNE_SFA2_Is_Merge_Mode__c = mergeModeOn;
		upsert mergeModeSetting;
		return mergeModeSetting;
    }
    
    private static void startBatch(Merge_Type_Console_Controller controller, Boolean checkMode) {
    	System.runAs(getMergeUser()) {
	    	if(checkMode) {
	    		Test.startTest();
	    		controller.startBatchInCheckMode();
	    		Test.stopTest();
	    	} else {
	    		switchMergeMode(true);
	    		Test.startTest();
		    	controller.startBatch();
		    	system.assert ( controller.canLaunch == false, 'Can Launch returned true, should be false.');
		    	controller.actionPollerSupport();
		    	Test.stopTest();
		    	switchMergeMode(false);
	    	}
    	}
    }
    
    private static User mergeUser;
    
    private static User getMergeUser() {
    	if(mergeUser==null) {
    		mergeUser = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'RCanada-SFA-Ops' LIMIT 1];
    	}
    	
    	return mergeUser;
    }
    
    private static void setOwner(List<SObject> sObjs) {
    	for(SObject sObj : sObjs) {
    		sObj.put('OwnerId', getMergeUser().Id);
    	}
    }
    
    private static void prepareAddressPrimaryFlagTest(Merge_Type_Console_Controller controller, Merge_Type_gne__c mergeType,
    		List<Account> accountList, List<Address_vod__c> addressList, Integer numberOfDuplicates, Boolean callMode) {
    	system.assert ( controller.canLaunch, 'Can Launch returned false, should be true.');
		
		for(Integer i=0;i<numberOfDuplicates+1;i++) {
			if(mergeType.Name.contains('Person')) {
				accountList.add ( new Account ( FirstName = 'Duplicate 1.1', LastName='Person'));
			} else {
				accountList.add ( new Account ( Name = 'Duplicate 1.1'));
			}
			
			if(mergeType.Name.contains('Address')) {
				break;
			}
		}
        
        setOwner(accountList);
        insert accountList;
        
        for(Integer i=0;i<numberOfDuplicates+1;i++) {
        	addressList.add ( new Address_vod__c ( Name = 'Duplicate 1.1',  account_vod__c = accountList[(mergeType.Name.contains('Address') ? 0 : i)].Id, city_vod__c='test city', state_vod__c='test state', Primary_vod__c = true));	
        }
        
        insert addressList;

		if(callMode==true) {
	        List<Call2_vod__c> callList = new List<Call2_vod__c>();
	        DateTime dt= system.now();
	        
	        for(Integer i=0;i<numberOfDuplicates+1;i++) {
	        	callList.add (new Call2_vod__c (account_vod__c = accountList[(mergeType.Name.contains('Address') ? 0 : i)].Id, parent_address_vod__c= addressList[i].Id, call_datetime_vod__c = dt));	
	        }
	        
	        setOwner(callList);
	        insert callList;
		}
        
        List<Merge_Type_Candidate_Stage_gne__c> stageList = new List<Merge_Type_Candidate_Stage_gne__c>();
        for(Integer i=0;i<numberOfDuplicates+1;i++) {
        	if(mergeType.Name.contains('Address')) {
        		stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = addressList[i].Id, parentid_gne__c=addressList[0].Id,Merge_Type_ref_gne__c = mergeType.Id));	
        	} else {
        		stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = accountList[i].Id, parentid_gne__c=accountList[0].Id,Merge_Type_ref_gne__c = mergeType.Id));
        	}
        	
        }
        
        insert stageList;
    }
    
    private static void runAddressPrimaryFlagTest(Merge_Type_Console_Controller controller, Merge_Type_gne__c mergeType,
    		List<Account> accountList, List<Address_vod__c> addressList, Integer numberOfDuplicates) {        
        startBatch(controller, false);
        
        System.assert ( controller.canLaunch == true, 'Can Launch returned false, should be true.');
        List<Merge_Type_Apex_Job_gne__c> apexJobList = [select Id, Log_gne__c,Apex_Job_Type_gne__c from Merge_Type_Apex_Job_gne__c where Merge_Type_ref_gne__c = :mergeType.Id];
        Integer jobPerformed = apexJobList.size();
        System.assertEquals(1, jobPerformed, 'Merge Type Apex Job should be 1. Actual job count is ' + jobPerformed);
        
        if(mergeType.Name.contains('Address')) {
        	Integer totalAddress = [select count() from Address_vod__c];
        	Integer totalAccount = [select count() from Account];
        	Address_vod__c winnerAddress = [select Id, (select id from call2_vod__r) from address_vod__c where id = :addressList[0].Id];
        	String exceptionDesc = [select id, dch_merge_type_exception_desc_gne__c from Merge_Type_Candidate_Stage_gne__c where parentid_gne__c  =  :addressList[0].Id and id_gne__c = :addressList[0].Id  limit 1].dch_merge_type_exception_desc_gne__c;
        	System.assertEquals(numberOfDuplicates+2, totalAddress, 'Total address should be ' + (numberOfDuplicates+2) + ' (including ' + (numberOfDuplicates+1)  +' dch archive records).  Actual total address is ' + totalAddress + '\nLog=> ' + apexJobList[0].Log_gne__c + '. exception captured =>' +  exceptionDesc);
        	System.assertEquals(2, totalAccount, 'Total Account should be 2 (including 1 dch archive records).  Actual total account is ' + totalAccount + '\nLog=> ' + apexJobList[0].Log_gne__c + '. exception captured =>' +  exceptionDesc);
        	System.assert( winnerAddress.call2_vod__r != null && winnerAddress.call2_vod__r.size() == numberOfDuplicates+1, 'call should be ' + (numberOfDuplicates+1) + ' actual is ' + winnerAddress.call2_vod__r.size() + ' please review relationship to move business rule and its related code.' );
        	system.assertEquals(numberOfDuplicates+1, [select count() from Address_vod__c where dch_action_gne__c in ('Merge (Winner)','Merge (Loser)')], 'Number Of Placeholders is not valid.');
        	
        	for(Integer i=1;i<numberOfDuplicates+1;i++) {
	        	String loserAddressId = addressList[i].Id;
	        	Map<String,String> m_loser_winner_dch = iPhoneApexUtil.findMergedAddresses ( new List<String>{ loserAddressId } );         
	        	System.assert ( m_loser_winner_dch.size() == 1 && m_loser_winner_dch.get (loserAddressId) != null && m_loser_winner_dch.get (loserAddressId) == addressList[0].Id, 'There should be loser address w/ winner address associated. please verify iPhoneApexUtil.findMergedAddresses.');	
	        }
	    } else {
        	Integer totalAccounts = [select count() from Account];
	        System.assertEquals(1, jobPerformed, 'Merge Type Apex Job should be 1. Actual job count is ' + jobPerformed);
	        String exceptionDesc = [select id, dch_merge_type_exception_desc_gne__c from Merge_Type_Candidate_Stage_gne__c where parentid_gne__c  =  :accountList[0].Id and id_gne__c = :accountList[0].Id  limit 1].dch_merge_type_exception_desc_gne__c;
	        System.assertEquals(numberOfDuplicates+2, totalAccounts, 'Total Account should be ' + (numberOfDuplicates+2) + ' (including ' + (numberOfDuplicates+1)  +' dch archive records).  Actual total account is ' + totalAccounts + '\nLog=> ' + apexJobList[0].Log_gne__c + '. exception captured =>' +  exceptionDesc);
	        System.assertEquals(numberOfDuplicates+1, [select count() from Account where dch_action_gne__c in ('Merge (Winner)','Merge (Loser)')], 'Number Of Placeholders is not valid.');
	        
	        for(Integer i=1;i<numberOfDuplicates+1;i++) {
	        	String loserAccountId = accountList[i].Id;
	        	Map<String,String> m_loser_winner_dch = iPhoneApexUtil.findMergedAccounts ( new List<String>{ loserAccountId } );         
	        	System.assert ( m_loser_winner_dch.size() == 1 && m_loser_winner_dch.get (loserAccountId) != null && m_loser_winner_dch.get (loserAccountId) == accountList[0].Id, 'There should be loser account w/ winner account associated. please verify iPhoneApexUtil.findMergedAccounts');	
	        }
        }
        
        
        
    }
    
    private static void sleep(Integer milis) {
    	Long startingTime = System.now().getTime();
		Integer delayInMilliseconds = milis==null ? 1000 : milis;
		while (System.now().getTime() - startingTime < delayInMilliseconds) {}
    }
    
    static testMethod void testMergeTypeConsoleControllerInitialization() {
    	Merge_Type_gne__c mergeType = createAccountMergeType (2);
	    Merge_Type_Console_Controller controller = new Merge_Type_Console_Controller (new Apexpages.Standardcontroller(mergeType));
	    system.assert ( controller.canLaunch, 'Can Launch returned false, should be true.');
    }

    static testMethod void testAccountMergeTypeEngineBatchInCheckMode() {
        Merge_Type_gne__c mergeType = createAccountMergeType (2);
        Merge_Type_Console_Controller controller = new Merge_Type_Console_Controller (new Apexpages.Standardcontroller(mergeType));
        system.assert ( controller.canLaunch, 'Can Launch returned false, should be true.');

        List<Account> accountList = new List<Account>();
        accountList.add ( new Account ( Name = 'Duplicate 1.1',  Phone='6502551000', Fax='6502551000', NumberOfEmployees=10, AnnualRevenue=100.00));
        accountList.add ( new Account ( Name = 'Duplicate 1.2',  Phone='6502551000', NumberOfEmployees=1, AnnualRevenue=200.00));
        setOwner(accountList);
        insert accountList;

        List<Merge_Type_Candidate_Stage_gne__c> stageList = new List<Merge_Type_Candidate_Stage_gne__c>();
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = accountList[0].Id, parentid_gne__c=accountList[0].Id,Merge_Type_ref_gne__c = mergeType.Id));
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = accountList[1].Id, parentid_gne__c=accountList[0].Id, Merge_Type_ref_gne__c = mergeType.Id));
        insert stageList;

        startBatch(controller, true);
        
        List<Merge_Type_Apex_Job_gne__c> apexJobList = [select Id, Log_gne__c,Apex_Job_Type_gne__c from Merge_Type_Apex_Job_gne__c where Merge_Type_ref_gne__c = :mergeType.Id];
        Integer jobPerformed = apexJobList.size();
        Integer totalAccounts = [select count() from Account];
        System.assert (  jobPerformed == 1, 'Merge Type Apex Job should be 1. Actual job count is ' + jobPerformed);
        System.assert (  totalAccounts == 4, 'Total Account should be 4 (including 2 dch archive records).  Actual total account is ' + totalAccounts + '\nLog=> ' +  apexJobList[0].Log_gne__c);
        String loserAccountId = accountList[1].Id;
        Map<String,String> m_loser_winner_dch = iPhoneApexUtil.findMergedAccounts ( new List<String>{  loserAccountId } );         
        system.assert ( m_loser_winner_dch.size() == 0, 'There should be no loser account w/ winner account associated. please verify iPhoneApexUtil.findMergedAccounts');
    }

    static testMethod void testAccountMergeTypeEngineBatchInCheckModeWithParentIdSet() {
        Merge_Type_gne__c mergeType = createAccountMergeType (2);

        List<Account> accountList = new List<Account>();
        accountList.add ( new Account ( Name = 'Duplicate 1.1',  Phone='6502551000', Fax='6502551000', NumberOfEmployees=10, AnnualRevenue=100.00));
        accountList.add ( new Account ( Name = 'Duplicate 1.2',  Phone='6502551000', NumberOfEmployees=1, AnnualRevenue=200.00));
        setOwner(accountList);
        insert accountList;

        List<Merge_Type_Candidate_Stage_gne__c> stageList = new List<Merge_Type_Candidate_Stage_gne__c>();
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = accountList[0].Id, parentid_gne__c=accountList[0].Id,Merge_Type_ref_gne__c = mergeType.Id));
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = accountList[1].Id, parentid_gne__c=accountList[0].Id, Merge_Type_ref_gne__c = mergeType.Id));
        insert stageList;

        Test.startTest();
            Merge_Type_Apex_Job_gne__c job = new Merge_Type_Apex_Job_gne__c(Merge_Type_ref_gne__c = mergeType.Id, Apex_Job_Type_gne__c = Merge_Type_Util.APEX_JOB_TYPE_MERGE_CHECKMODE);
            insert job;
            boolean checkMode = true;
            Merge_Type_Engine_Batch mbatch = new Merge_Type_Engine_Batch (mergeType, checkMode, new Set<String>{accountList[0].Id},job);
            database.executeBatch ( mbatch, 10 );
        Test.stopTest();
        Integer totalAccounts = [select count() from Account];
        List<Merge_Type_Apex_Job_gne__c> apexJobList = [select Id, Log_gne__c,Apex_Job_Type_gne__c from Merge_Type_Apex_Job_gne__c where Merge_Type_ref_gne__c = :mergeType.Id];
        String exceptionDesc = [select id, dch_merge_type_exception_desc_gne__c from Merge_Type_Candidate_Stage_gne__c where parentid_gne__c  =  :accountList[0].Id and id_gne__c = :accountList[0].Id  limit 1].dch_merge_type_exception_desc_gne__c;
        System.assert (  totalAccounts == 4, 'Total Account should be 4 (including 2 dch archive records).  Actual total account is ' + totalAccounts + '\nLog=> ' +  apexJobList[0].Log_gne__c + '\nError => ' + exceptionDesc);
        String loserAccountId = accountList[1].Id;
        Map<String,String> m_loser_winner_dch = iPhoneApexUtil.findMergedAccounts ( new List<String>{  loserAccountId } );         
        system.assert ( m_loser_winner_dch.size() == 0, 'There should be no loser account w/ winner account associated. please verify iPhoneApexUtil.findMergedAccounts');
    }



    static testMethod void testAccountMergeTypeEngineBatchInCheckModeWithDeferOnConflictException() {
        Merge_Type_gne__c mergeType = createAccountMergeType (2);
        Merge_Type_Console_Controller controller = new Merge_Type_Console_Controller (new Apexpages.Standardcontroller(mergeType));
        system.assert ( controller.canLaunch, 'Can Launch returned false, should be true.');

        // defer on conflict: fax, website field value
        List<Account> accountList = new List<Account>();
        accountList.add ( new Account ( Name = 'Duplicate 1.1',  Phone='6502551000', Fax='6502551000', NumberOfEmployees=10, AnnualRevenue=100.00, Website='www.gene.com'));
        accountList.add ( new Account ( Name = 'Duplicate 1.2',  Phone='6502551000', Fax='8002551000', NumberOfEmployees=1, AnnualRevenue=200.00, website='www.roche.com'));
        setOwner(accountList);
        insert accountList;

        List<Merge_Type_Candidate_Stage_gne__c> stageList = new List<Merge_Type_Candidate_Stage_gne__c>();
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = accountList[0].Id, parentid_gne__c=accountList[0].Id,Merge_Type_ref_gne__c = mergeType.Id));
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = accountList[1].Id, parentid_gne__c=accountList[0].Id, Merge_Type_ref_gne__c = mergeType.Id));
        insert stageList;

        startBatch(controller, true);
        
        List<Merge_Type_Apex_Job_gne__c> apexJobList = [select Id, Log_gne__c,Apex_Job_Type_gne__c from Merge_Type_Apex_Job_gne__c where Merge_Type_ref_gne__c = :mergeType.Id];
        Integer jobPerformed = apexJobList.size();
        Integer totalAccounts = [select count() from Account];
        System.assert (  jobPerformed == 1, 'Merge Type Apex Job should be 1. Actual job count is ' + jobPerformed);
        System.assert (  totalAccounts == 4, 'Total Account should be 4(including 2 dch archive records).  Actual total account is ' + totalAccounts + '\nLog=> ' +  apexJobList[0].Log_gne__c);
        String loserAccountId = accountList[1].Id;
        Map<String,String> m_loser_winner_dch = iPhoneApexUtil.findMergedAccounts ( new List<String>{  loserAccountId } );         
        system.assert ( m_loser_winner_dch.size() == 0, 'There should be no loser account w/ winner account associated. please verify iPhoneApexUtil.findMergedAccounts');
    }

    static testMethod void testAccountMergeTypeEngineBatchInMergeMode() {
        Merge_Type_gne__c mergeType = createAccountMergeType (2);
        Merge_Type_Console_Controller controller = new Merge_Type_Console_Controller (new Apexpages.Standardcontroller(mergeType));
        system.assert ( controller.canLaunch, 'Can Launch returned false, should be true.');

        List<Account> accountList = new List<Account>();
        accountList.add ( new Account ( Name = 'Duplicate 1.1',  Phone='6502551000', Fax='6502551000', NumberOfEmployees=10, AnnualRevenue=100.00, Chemo_Center_can_gne__c = false));
        accountList.add ( new Account ( Name = 'Duplicate 1.2',  Phone='6502551000', NumberOfEmployees=1, AnnualRevenue=200.00, Chemo_Center_can_gne__c=true));
        setOwner(accountList);
        insert accountList;

        List<Merge_Type_Candidate_Stage_gne__c> stageList = new List<Merge_Type_Candidate_Stage_gne__c>();
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = accountList[0].Id, parentid_gne__c=accountList[0].Id,Merge_Type_ref_gne__c = mergeType.Id));
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = accountList[1].Id, parentid_gne__c=accountList[0].Id, Merge_Type_ref_gne__c = mergeType.Id));
        insert stageList;
        String loserAccountId = accountList[1].Id;

        startBatch(controller, false);
        
        system.assert ( controller.canLaunch, 'Can Launch returned false, should be true.');
        List<Merge_Type_Apex_Job_gne__c> apexJobList = [select Id, Log_gne__c,Apex_Job_Type_gne__c from Merge_Type_Apex_Job_gne__c where Merge_Type_ref_gne__c = :mergeType.Id];
        Integer jobPerformed = apexJobList.size();
        Integer totalAccounts = [select count() from Account];
        System.assert (  jobPerformed == 1, 'Merge Type Apex Job should be 1. Actual job count is ' + jobPerformed);
        String exceptionDesc = [select id, dch_merge_type_exception_desc_gne__c from Merge_Type_Candidate_Stage_gne__c where parentid_gne__c  =  :accountList[0].Id and id_gne__c = :accountList[0].Id  limit 1].dch_merge_type_exception_desc_gne__c;
        System.assert (  totalAccounts == 3, 'Total Account should be 3(including 2 dch archive records).  Actual total account is ' + totalAccounts + '\nLog=> ' + apexJobList[0].Log_gne__c + '. exception captured =>' +  exceptionDesc);
        accountList = [select Id, Name, Phone, Fax,NumberOfEmployees, AnnualRevenue,Chemo_Center_can_gne__c from Account where id = :accountList[0].Id];
        system.assert ( accountList[0].NumberOfEmployees == 1);
        system.assert ( accountList[0].AnnualRevenue == 200);
        system.assert ( accountList[0].Chemo_Center_can_gne__c);
        Map<String,String> m_loser_winner_dch = iPhoneApexUtil.findMergedAccounts ( new List<String>{  loserAccountId } );         
        system.assert ( m_loser_winner_dch.size() == 1 && m_loser_winner_dch.get (loserAccountId) != null && m_loser_winner_dch.get (loserAccountId) == accountList[0].Id, 'There should be loser account w/ winner account associated. please verify iPhoneApexUtil.findMergedAccounts');
    }


    static testMethod void testPersonAccountMergeTypeEngineBatchInMergeMode() {
        Merge_Type_gne__c mergeType = createPersonAccountMergeType (2);
        Merge_Type_Console_Controller controller = new Merge_Type_Console_Controller (new Apexpages.Standardcontroller(mergeType));
        system.assert ( controller.canLaunch, 'Can Launch returned false, should be true.');

        List<Account> accountList = new List<Account>();
        accountList.add ( new Account ( FirstName = 'Duplicate 1.1', LastName='Person',  Phone='6502551000'));
        accountList.add ( new Account ( FirstName = 'Duplicate 1.1', LastName='Person',  Phone='6502551000', Fax='6502551000'));
        setOwner(accountList);
        insert accountList;

        List<Merge_Type_Candidate_Stage_gne__c> stageList = new List<Merge_Type_Candidate_Stage_gne__c>();
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = accountList[0].Id, parentid_gne__c=accountList[0].Id,Merge_Type_ref_gne__c = mergeType.Id));
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = accountList[1].Id, parentid_gne__c=accountList[0].Id, Merge_Type_ref_gne__c = mergeType.Id));
        insert stageList;
        String loserAccountId = accountList[1].Id;

        startBatch(controller, false);
        
        system.assert ( controller.canLaunch == true, 'Can Launch returned false, should be true.');
        List<Merge_Type_Apex_Job_gne__c> apexJobList = [select Id, Log_gne__c,Apex_Job_Type_gne__c from Merge_Type_Apex_Job_gne__c where Merge_Type_ref_gne__c = :mergeType.Id];
        Integer jobPerformed = apexJobList.size();
        Integer totalAccounts = [select count() from Account];
        System.assert (  jobPerformed == 1, 'Merge Type Apex Job should be 1. Actual job count is ' + jobPerformed);
        String exceptionDesc = [select id, dch_merge_type_exception_desc_gne__c from Merge_Type_Candidate_Stage_gne__c where parentid_gne__c  =  :accountList[0].Id and id_gne__c = :accountList[0].Id  limit 1].dch_merge_type_exception_desc_gne__c;
        System.assert (  totalAccounts == 3, 'Total Account should be 3(including 2 dch archive records).  Actual total account is ' + totalAccounts + '\nLog=> ' + apexJobList[0].Log_gne__c + '. exception captured =>' +  exceptionDesc);
        accountList = [select Id, Name, Phone, Fax from Account where id = :accountList[0].Id or Id = :accountList[1].Id];
        system.assert ( accountList[0].Fax != null);
        system.assert ([select count() from Account where dch_action_gne__c in ('Merge (Winner)','Merge (Loser)')] == 2);
        Map<String,String> m_loser_winner_dch = iPhoneApexUtil.findMergedAccounts ( new List<String>{  loserAccountId } );         
        system.assert ( m_loser_winner_dch.size() == 1 && m_loser_winner_dch.get (loserAccountId) != null && m_loser_winner_dch.get (loserAccountId) == accountList[0].Id, 'There should be loser account w/ winner account associated. please verify iPhoneApexUtil.findMergedAccounts');
    }

    static testMethod void testPersonAccountMergeTypeEngineBatchInMergeMode_andTierLevelStakeholder() {
        Merge_Type_gne__c mergeType = createPersonAccountMergeType (2);
        Merge_Type_Console_Controller controller = new Merge_Type_Console_Controller (new Apexpages.Standardcontroller(mergeType));
        system.assert ( controller.canLaunch, 'Can Launch returned false, should be true.');

        List<Account> accountList = new List<Account>();
        accountList.add ( new Account ( FirstName = 'Duplicate 1.1', LastName='Person1',  Phone='6502551001', Tier_Level_gne__c='Tier 1', HCP_Stakeholder_Type_gne__c = 'Stakeholder 1'));
        accountList.add ( new Account ( FirstName = 'Duplicate 1.1', LastName='Person1',  Phone='6502551001'));

        accountList.add ( new Account ( FirstName = 'Duplicate 1.2', LastName='Person2',  Phone='6502551002'));
        accountList.add ( new Account ( FirstName = 'Duplicate 1.2', LastName='Person2',  Phone='6502551002', Tier_Level_gne__c='Tier 2', HCP_Stakeholder_Type_gne__c = 'Stakeholder 2'));

        accountList.add ( new Account ( FirstName = 'Duplicate 1.3', LastName='Person3',  Phone='6502551003', Tier_Level_gne__c='Tier 3', HCP_Stakeholder_Type_gne__c = 'Stakeholder 3'));
        accountList.add ( new Account ( FirstName = 'Duplicate 1.3', LastName='Person3',  Phone='6502551003', Tier_Level_gne__c='Tier 4', HCP_Stakeholder_Type_gne__c = 'Stakeholder 4'));

        accountList.add ( new Account ( FirstName = 'Duplicate 1.4', LastName='Person4',  Phone='6502551004', Tier_Level_gne__c=null, HCP_Stakeholder_Type_gne__c = 'Stakeholder 5'));
        accountList.add ( new Account ( FirstName = 'Duplicate 1.4', LastName='Person4',  Phone='6502551004', Tier_Level_gne__c='Tier 5', HCP_Stakeholder_Type_gne__c = null));

        setOwner(accountList);
        insert accountList;

        for (integer i = 0; i < accountList.size(); i++) {
            System.debug('accountList['+ i + '].id = ' + accountList[i].id);
        }

        Account winnerAccount1 = accountList[0];
        Account winnerAccount2 = accountList[2];
        Account winnerAccount3 = accountList[4];
        Account winnerAccount4 = accountList[6];
        
        Account loserAccount1 = accountList[1];
        Account loserAccount2 = accountList[3];
        Account loserAccount3 = accountList[5];
        Account loserAccount4 = accountList[7];
        

        List<Merge_Type_Candidate_Stage_gne__c> stageList = new List<Merge_Type_Candidate_Stage_gne__c>();
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = winnerAccount1.Id, parentid_gne__c=winnerAccount1.Id,Merge_Type_ref_gne__c = mergeType.Id)); 
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = loserAccount1.Id, parentid_gne__c=winnerAccount1.Id, Merge_Type_ref_gne__c = mergeType.Id)); 

        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = winnerAccount2.Id, parentid_gne__c=winnerAccount2.Id,Merge_Type_ref_gne__c = mergeType.Id)); 
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = loserAccount2.Id, parentid_gne__c=winnerAccount2.Id, Merge_Type_ref_gne__c = mergeType.Id)); 

        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = winnerAccount3.Id, parentid_gne__c=winnerAccount3.Id,Merge_Type_ref_gne__c = mergeType.Id)); 
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = loserAccount3.Id, parentid_gne__c=winnerAccount3.Id, Merge_Type_ref_gne__c = mergeType.Id)); 

        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = winnerAccount4.Id, parentid_gne__c=winnerAccount4.Id,Merge_Type_ref_gne__c = mergeType.Id)); 
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = loserAccount4.Id, parentid_gne__c=winnerAccount4.Id, Merge_Type_ref_gne__c = mergeType.Id)); 

        insert stageList;
        

        startBatch(controller, false);
        
        system.assert ( controller.canLaunch == true, 'Can Launch returned false, should be true.');
        List<Merge_Type_Apex_Job_gne__c> apexJobList = [select Id, Log_gne__c,Apex_Job_Type_gne__c from Merge_Type_Apex_Job_gne__c where Merge_Type_ref_gne__c = :mergeType.Id];
        Integer jobPerformed = apexJobList.size();
        Integer totalAccounts = [select count() from Account];
        System.assert (  jobPerformed == 1, 'Merge Type Apex Job should be 1. Actual job count is ' + jobPerformed);

        List<Merge_Type_Candidate_Stage_gne__c> exceptionList = [select id, dch_merge_type_exception_desc_gne__c from Merge_Type_Candidate_Stage_gne__c 
            where 
                (parentid_gne__c = :winnerAccount1.Id and id_gne__c = :winnerAccount1.Id) OR
                (parentid_gne__c = :winnerAccount2.Id and id_gne__c = :winnerAccount2.Id) OR
                (parentid_gne__c = :winnerAccount3.Id and id_gne__c = :winnerAccount3.Id) OR
                (parentid_gne__c = :winnerAccount4.Id and id_gne__c = :winnerAccount4.Id)
                  limit 10];

        String exceptionDesc = '';
        for (Merge_Type_Candidate_Stage_gne__c item : exceptionList) {
            exceptionDesc += '; ' + item.dch_merge_type_exception_desc_gne__c;
        }

        System.assert (  totalAccounts == 12, 'Total Account should be 12(including 2 dch archive records for every pair).  Actual total account is ' + totalAccounts + '\nLog=> ' + apexJobList[0].Log_gne__c + '. exception captured =>' +  exceptionDesc);
        
       
        List<Account> accountAfterList = [select Id, Name, Phone, Tier_Level_gne__c, HCP_Stakeholder_Type_gne__c, dch_action_gne__c from Account where id 
            in (:winnerAccount1.Id, :loserAccount1.Id, :winnerAccount2.Id, :loserAccount2.Id, :winnerAccount3.Id, :loserAccount3.Id, :winnerAccount4.Id, :loserAccount4.Id)];

        for (integer i =0; i< accountAfterList.size(); i++) {     
            System.debug('accountAfterList['+ i + '].Id = ' + accountAfterList[i].Id);
            System.debug('accountAfterList['+ i + '].Tier_Level_gne__c = ' + accountAfterList[i].Tier_Level_gne__c);
            System.debug('accountAfterList['+ i + '].HCP_Stakeholder_Type_gne__c = ' + accountAfterList[i].HCP_Stakeholder_Type_gne__c);
            System.debug('accountAfterList['+ i + '].dch_action_gne__c = ' + accountAfterList[i].dch_action_gne__c);
        }
        for (integer i =0; i< accountAfterList.size(); i++) {    
            if (accountAfterList[i].Id == winnerAccount1.Id ) {
                system.assert ( accountAfterList[i].Tier_Level_gne__c == 'Tier 1');        
                system.assert ( accountAfterList[i].HCP_Stakeholder_Type_gne__c == 'Stakeholder 1');        
            }
            if (accountAfterList[i].Id == winnerAccount2.Id ) {
                system.assert ( accountAfterList[i].Tier_Level_gne__c == 'Tier 2');        
                system.assert ( accountAfterList[i].HCP_Stakeholder_Type_gne__c == 'Stakeholder 2');        
            }
            if (accountAfterList[i].Id == winnerAccount3.Id ) {
                system.assert ( accountAfterList[i].Tier_Level_gne__c == 'Tier 3');        
                system.assert ( accountAfterList[i].HCP_Stakeholder_Type_gne__c == 'Stakeholder 3');        
            }
            if (accountAfterList[i].Id == winnerAccount4.Id ) {
                system.assert ( accountAfterList[i].Tier_Level_gne__c == 'Tier 5');        
                system.assert ( accountAfterList[i].HCP_Stakeholder_Type_gne__c == 'Stakeholder 5');        
            }
            if (accountAfterList[i].Id == loserAccount1.Id ) {
                system.assert ( accountAfterList[i].Tier_Level_gne__c == 'Tier 1');        
                system.assert ( accountAfterList[i].HCP_Stakeholder_Type_gne__c == 'Stakeholder 1');        
            }
            if (accountAfterList[i].Id == loserAccount2.Id ) {
                system.assert ( accountAfterList[i].Tier_Level_gne__c == 'Tier 2');        
                system.assert ( accountAfterList[i].HCP_Stakeholder_Type_gne__c == 'Stakeholder 2');        
            }
            if (accountAfterList[i].Id == loserAccount3.Id ) {
                system.assert ( accountAfterList[i].Tier_Level_gne__c == 'Tier 3');        
                system.assert ( accountAfterList[i].HCP_Stakeholder_Type_gne__c == 'Stakeholder 3');        
            }
            if (accountAfterList[i].Id == loserAccount4.Id ) {
                system.assert ( accountAfterList[i].Tier_Level_gne__c == 'Tier 5');        
                system.assert ( accountAfterList[i].HCP_Stakeholder_Type_gne__c == 'Stakeholder 5');        
            }
        }

        List<Account> accountWinnerLoserList = [select Id, Name, Phone, Tier_Level_gne__c, HCP_Stakeholder_Type_gne__c, dch_action_gne__c from Account where dch_action_gne__c in ('Merge (Winner)','Merge (Loser)')];
        for (integer i =0; i< accountWinnerLoserList.size(); i++) {    
            System.debug('accountWinnerLoserList['+ i + '].Id = ' + accountWinnerLoserList[i].Id);
            System.debug('accountWinnerLoserList['+ i + '].Tier_Level_gne__c = ' + accountWinnerLoserList[i].Tier_Level_gne__c);
            System.debug('accountWinnerLoserList['+ i + '].HCP_Stakeholder_Type_gne__c = ' + accountWinnerLoserList[i].HCP_Stakeholder_Type_gne__c);
            System.debug('accountWinnerLoserList['+ i + '].dch_action_gne__c = ' + accountWinnerLoserList[i].dch_action_gne__c);
        }

        system.assert (accountWinnerLoserList.size() == 8, 'accountWinnerLoserList size should be 8 but is ' + accountWinnerLoserList.size());

        Map<String,String> m_loser_winner_dch = iPhoneApexUtil.findMergedAccounts ( new List<String>{  loserAccount1.Id } );         
        system.assert ( m_loser_winner_dch.size() == 1 && m_loser_winner_dch.get (loserAccount1.Id) != null && m_loser_winner_dch.get (loserAccount1.Id) == winnerAccount1.Id, 'There should be loser account w/ winner account associated. please verify iPhoneApexUtil.findMergedAccounts');

        m_loser_winner_dch = iPhoneApexUtil.findMergedAccounts ( new List<String>{  loserAccount2.Id } );         
        system.assert ( m_loser_winner_dch.size() == 1 && m_loser_winner_dch.get (loserAccount2.Id) != null && m_loser_winner_dch.get (loserAccount2.Id) == winnerAccount2.Id, 'There should be loser account w/ winner account associated. please verify iPhoneApexUtil.findMergedAccounts');
        
    }

    static testMethod void testAddressMergeTypeEngineBatchInMergeMode() {
        Merge_Type_gne__c mergeType = createAccountAddressMergeType (2);
        Merge_Type_Console_Controller controller = new Merge_Type_Console_Controller (new Apexpages.Standardcontroller(mergeType));
        system.assert ( controller.canLaunch, 'Can Launch returned false, should be true.');

        List<Account> accountList = new List<Account>();
        accountList.add ( new Account ( Name = 'Account',  Phone='6502551000', Fax='6502551000'));
        setOwner(accountList);
        insert accountList;

        List<Address_vod__c> addressList = new List<Address_vod__c>();
        addressList.add ( new Address_vod__c ( Name = 'Duplicate 1.1',  account_vod__c = accountList[0].Id, city_vod__c='test city', state_vod__c='test state'));
        addressList.add ( new Address_vod__c ( Name = 'Duplicate 1.2',  account_vod__c = accountList[0].Id, city_vod__c='test city', state_vod__c='test state'));
        insert addressList;

        List<Call2_vod__c> callList = new List<Call2_vod__c>();
        DateTime dt= system.now();
        callList.add (new Call2_vod__c (account_vod__c = accountList[0].Id, parent_address_vod__c= addressList[0].Id, call_datetime_vod__c = dt));
        callList.add (new Call2_vod__c (account_vod__c = accountList[0].Id, parent_address_vod__c= addressList[1].Id, call_datetime_vod__c= dt));
        setOwner(callList);
        insert callList;

        List<Merge_Type_Candidate_Stage_gne__c> stageList = new List<Merge_Type_Candidate_Stage_gne__c>();
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = addressList[0].Id, parentid_gne__c=addressList[0].Id,Merge_Type_ref_gne__c = mergeType.Id));
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = addressList[1].Id, parentid_gne__c=addressList[0].Id, Merge_Type_ref_gne__c = mergeType.Id));
        insert stageList;
        String loserAddressId = addressList[1].Id;

        startBatch(controller, false);
        
        system.assert ( controller.canLaunch == true, 'Can Launch returned false, should be true.');
        Integer totalAddress = [select count() from Address_vod__c];
        Integer totalAccount = [select count() from Account];
        Address_vod__c winnerAddress = [select Id, (select id from call2_vod__r) from address_vod__c where id = :addressList[0].Id];
        List<Merge_Type_Apex_Job_gne__c> apexJobList = [select Id, Log_gne__c,Apex_Job_Type_gne__c from Merge_Type_Apex_Job_gne__c where Merge_Type_ref_gne__c = :mergeType.Id];
        Integer jobPerformed = apexJobList.size();
        System.assert (  jobPerformed == 1, 'Merge Type Apex Job should be 1. Actual  count is ' + jobPerformed);
        String exceptionDesc = [select id, dch_merge_type_exception_desc_gne__c from Merge_Type_Candidate_Stage_gne__c where parentid_gne__c  =  :addressList[0].Id and id_gne__c = :addressList[0].Id  limit 1].dch_merge_type_exception_desc_gne__c;
        System.assert (  totalAddress == 3, 'Total address should be 3 (including 2 dch archive records).  Actual total address is ' + totalAddress + '\nLog=> ' + apexJobList[0].Log_gne__c + '. exception captured =>' +  exceptionDesc);
        System.assert (  totalAccount == 2, 'Total Account should be 2 (including 1 dch archive records).  Actual total account is ' + totalAccount + '\nLog=> ' + apexJobList[0].Log_gne__c + '. exception captured =>' +  exceptionDesc);
        System.assert ( winnerAddress.call2_vod__r != null && winnerAddress.call2_vod__r.size() == 2, 'call should be 2 actual is ' + winnerAddress.call2_vod__r.size() + ' please review relationship to move business rule and its related code.' );
        system.assert ([select count() from Address_vod__c where dch_action_gne__c in ('Merge (Winner)','Merge (Loser)')] == 2);
        Map<String,String> m_loser_winner_dch = iPhoneApexUtil.findMergedAddresses ( new List<String>{  loserAddressId } );         
        system.assert ( m_loser_winner_dch.size() == 1 && m_loser_winner_dch.get (loserAddressId) != null && m_loser_winner_dch.get (loserAddressId) == addressList[0].Id, 'There should be loser address w/ winner address associated. please verify iPhoneApexUtil.findMergedAddresses.');
    }

    static testMethod void testPersonAccountAddressMergeTypeEngineBatchInMergeMode() {
        Merge_Type_gne__c mergeType = createPersonAccountAddressMergeType (2);
        Merge_Type_Console_Controller controller = new Merge_Type_Console_Controller (new Apexpages.Standardcontroller(mergeType));
        system.assert ( controller.canLaunch, 'Can Launch returned false, should be true.');

        List<Account> accountList = new List<Account>();
        accountList.add ( new Account ( FirstName = 'Person', LastName='Account',  Phone='6502551000', Fax='6502551000'));
        setOwner(accountList);
        insert accountList;

        List<Address_vod__c> addressList = new List<Address_vod__c>();
        addressList.add ( new Address_vod__c ( Name = 'Duplicate 1.1',  account_vod__c = accountList[0].Id, city_vod__c='test city', state_vod__c='test state'));
        addressList.add ( new Address_vod__c ( Name = 'Duplicate 1.2',  account_vod__c = accountList[0].Id, city_vod__c='test city', state_vod__c='test state'));
        insert addressList;

        List<Call2_vod__c> callList = new List<Call2_vod__c>();
        DateTime dt= system.now();
        callList.add (new Call2_vod__c (account_vod__c = accountList[0].Id, parent_address_vod__c= addressList[0].Id, call_datetime_vod__c = dt));
        callList.add (new Call2_vod__c (account_vod__c = accountList[0].Id, parent_address_vod__c= addressList[1].Id, call_datetime_vod__c= dt));
        setOwner(callList);
        insert callList;

        List<Merge_Type_Candidate_Stage_gne__c> stageList = new List<Merge_Type_Candidate_Stage_gne__c>();
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = addressList[0].Id, parentid_gne__c=addressList[0].Id,Merge_Type_ref_gne__c = mergeType.Id));
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = addressList[1].Id, parentid_gne__c=addressList[0].Id, Merge_Type_ref_gne__c = mergeType.Id));
        insert stageList;
        String loserAddressId = addressList[1].Id;

        startBatch(controller, false);
        
        Integer totalAddress = [select count() from Address_vod__c];
        Integer totalAccount = [select count() from Account];
        Address_vod__c winnerAddress = [select Id, (select id from call2_vod__r) from address_vod__c where id = :addressList[0].Id];
        List<Merge_Type_Apex_Job_gne__c> apexJobList = [select Id, Log_gne__c,Apex_Job_Type_gne__c from Merge_Type_Apex_Job_gne__c where Merge_Type_ref_gne__c = :mergeType.Id];
        Integer jobPerformed = apexJobList.size();
        System.assert (  jobPerformed == 1, 'Merge Type Apex Job should be 1. Actual  count is ' + jobPerformed);
        String exceptionDesc = [select id, dch_merge_type_exception_desc_gne__c from Merge_Type_Candidate_Stage_gne__c where parentid_gne__c  =  :addressList[0].Id and id_gne__c = :addressList[0].Id  limit 1].dch_merge_type_exception_desc_gne__c;
        System.assert (  totalAddress == 3, 'Total address should be 3 (including 2 dch archive records).  Actual total address is ' + totalAddress + '\nLog=> ' + apexJobList[0].Log_gne__c + '. exception captured =>' +  exceptionDesc);
        System.assert (  totalAccount == 2, 'Total Account should be 2 (including 1 dch archive records).  Actual total account is ' + totalAccount + '\nLog=> ' + apexJobList[0].Log_gne__c + '. exception captured =>' +  exceptionDesc);
        System.assert ( winnerAddress.call2_vod__r != null && winnerAddress.call2_vod__r.size() == 2, 'call should be 2 actual is ' + winnerAddress.call2_vod__r.size() + ' please review relationship to move business rule and its related code.' );
        Map<String,String> m_loser_winner_dch = iPhoneApexUtil.findMergedAddresses ( new List<String>{  loserAddressId } );         
        system.assert ( m_loser_winner_dch.size() == 1 && m_loser_winner_dch.get (loserAddressId) != null && m_loser_winner_dch.get (loserAddressId) == addressList[0].Id, 'There should be loser address w/ winner address associated. please verify iPhoneApexUtil.findMergedAddresses');
    }

    static testMethod void testPersonAccountAddressMergeTypeEngineBatchInMergeModeOnDeferOnLoserSignificantRelatedListCount() {
        Merge_Type_gne__c mergeType = createPersonAccountAddressMergeTypeWithDeferOnLoserSignificantRelatedListCountOnCall (2);
        Merge_Type_Console_Controller controller = new Merge_Type_Console_Controller (new Apexpages.Standardcontroller(mergeType));
        system.assert ( controller.canLaunch, 'Can Launch returned false, should be true.');

        List<Account> accountList = new List<Account>();
        accountList.add ( new Account ( FirstName = 'Person', LastName='Account',  Phone='6502551000', Fax='6502551000'));
        setOwner(accountList);
        insert accountList;

        List<Address_vod__c> addressList = new List<Address_vod__c>();
        addressList.add ( new Address_vod__c ( Name = 'Duplicate 1.1',  account_vod__c = accountList[0].Id, city_vod__c='test city', state_vod__c='test state'));
        addressList.add ( new Address_vod__c ( Name = 'Duplicate 1.2',  account_vod__c = accountList[0].Id, city_vod__c='test city', state_vod__c='test state'));
        insert addressList;

        List<Call2_vod__c> callList = new List<Call2_vod__c>();
        DateTime dt= system.now();
        callList.add (new Call2_vod__c (account_vod__c = accountList[0].Id, parent_address_vod__c= addressList[0].Id, call_datetime_vod__c = dt));
        callList.add (new Call2_vod__c (account_vod__c = accountList[0].Id, parent_address_vod__c= addressList[1].Id, call_datetime_vod__c= dt));
        setOwner(callList);
        insert callList;

        List<Merge_Type_Candidate_Stage_gne__c> stageList = new List<Merge_Type_Candidate_Stage_gne__c>();
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = addressList[0].Id, parentid_gne__c=addressList[0].Id,Merge_Type_ref_gne__c = mergeType.Id));
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = addressList[1].Id, parentid_gne__c=addressList[0].Id, Merge_Type_ref_gne__c = mergeType.Id));
        insert stageList;

        startBatch(controller, false);
        
        Integer totalAddress = [select count() from Address_vod__c];
        Integer totalAccount = [select count() from Account];
        Address_vod__c winnerAddress = [select Id, (select id from call2_vod__r) from address_vod__c where id = :addressList[0].Id];
        List<Merge_Type_Apex_Job_gne__c> apexJobList = [select Id, Log_gne__c,Apex_Job_Type_gne__c from Merge_Type_Apex_Job_gne__c where Merge_Type_ref_gne__c = :mergeType.Id];
        Integer jobPerformed = apexJobList.size();
        System.assert (  jobPerformed == 1, 'Merge Type Apex Job should be 1. Actual  count is ' + jobPerformed);
        Merge_Type_Candidate_Stage_gne__c winnerMergeTypeCandidate = [select id, dch_merge_type_exception_gne__c, dch_merge_type_exception_desc_gne__c from Merge_Type_Candidate_Stage_gne__c where parentid_gne__c  =  :addressList[0].Id and id_gne__c = :addressList[0].Id  limit 1];
        System.assert ( winnerMergeTypeCandidate.dch_merge_type_exception_gne__c != null && winnerMergeTypeCandidate.dch_merge_type_exception_gne__c == 'DeferOnLoserAddressHavingCalls', 'exception code/desc ' + winnerMergeTypeCandidate.dch_merge_type_exception_gne__c + '/' + winnerMergeTypeCandidate.dch_merge_type_exception_desc_gne__c);
        System.assert (  totalAddress == 4, 'Total address should be 4 (including 2 dch archive records).  Actual total address is ' + totalAddress + '\nLog=> ' + apexJobList[0].Log_gne__c + '. exception captured =>' +  winnerMergeTypeCandidate.dch_merge_type_exception_desc_gne__c);
        System.assert (  totalAccount == 2, 'Total Account should be 2 (including 1 dch archive records).  Actual total account is ' + totalAccount + '\nLog=> ' + apexJobList[0].Log_gne__c + '. exception captured =>' +  winnerMergeTypeCandidate.dch_merge_type_exception_desc_gne__c);
    }
    
     static testMethod void testTargetAndTiersMergeTypeEngineBatchInCheckMode() {
     	Merge_Type_gne__c mergeType = createTargetAndTiersMergeType(2);
     	
        Merge_Type_Console_Controller controller = new Merge_Type_Console_Controller (new Apexpages.Standardcontroller(mergeType));
        system.assert ( controller.canLaunch, 'Can Launch returned false, should be true.');
          
        List<Account> accountList = new List<Account>();
		accountList.add ( new Account ( FirstName = 'Person', LastName='Account',  Phone='6502551000', Fax='6502551000'));
		setOwner(accountList);
		insert accountList		;
        
        List<Product_vod__c> productList = new List<Product_vod__c>();
        productList.add(new Product_vod__c(Name = 'Product Catalog Item 1'));         
        insert productList;           
        
        List<TSF_vod__c> teritoryFieldList = new List<TSF_vod__c>(); 
        teritoryFieldList.add(new tsf_vod__c ( Name = 'Duplicate 1.1', account_vod__c = accountList[0].Id, territory_vod__c='test territory1' ));         
        insert teritoryFieldList;                       
        switchMergeMode(true); 
        List<Targets_and_Tiers_can_gne__c> targetAndTiersList = new List<Targets_and_Tiers_can_gne__c>();
        targetAndTiersList.add( new Targets_and_Tiers_can_gne__c( Name = 'Duplicate 1.1', Account_can_gne__c = accountList[0].id, My_Target_gne__c = 'HI', Product_Catalog_gne__c = productList[0].Id, Segment_gne__c = null, Tier_can_gne__c = null, Territory_gne__c = teritoryFieldList[0].id ) );
        targetAndTiersList.add( new Targets_and_Tiers_can_gne__c( Name = 'Duplicate 1.2', Account_can_gne__c = accountList[0].id, My_Target_gne__c = 'HI', Product_Catalog_gne__c = productList[0].Id, Segment_gne__c = 'SegmentTestValue', Tier_can_gne__c = 'TierTestValue', Territory_gne__c = teritoryFieldList[0].id ) );        
        insert targetAndTiersList;        
        switchMergeMode(false);
        List<Merge_Type_Candidate_Stage_gne__c> stageList = new List<Merge_Type_Candidate_Stage_gne__c>();
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = targetAndTiersList[0].Id, parentid_gne__c=targetAndTiersList[0].Id, Merge_Type_ref_gne__c = mergeType.Id));
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = targetAndTiersList[1].Id, parentid_gne__c=targetAndTiersList[0].Id, Merge_Type_ref_gne__c = mergeType.Id));
        insert stageList;
        
        startBatch(controller, true);
        
        List<Merge_Type_Apex_Job_gne__c> apexJobList = [select Id, Log_gne__c,Apex_Job_Type_gne__c from Merge_Type_Apex_Job_gne__c where Merge_Type_ref_gne__c = :mergeType.Id];
        Integer jobPerformed = apexJobList.size();
        Integer totalTargetsAndTiers = [select count() from Targets_and_Tiers_can_gne__c];
        System.assert (  jobPerformed == 1, 'Merge Type Apex Job should be 1. Actual job count is ' + jobPerformed);
        System.assert (  totalTargetsAndTiers == 2, 'Total Targets and Tiers should be 2.  Actual total Target and Tiers is ' + totalTargetsAndTiers + '\nLog=> ' +  apexJobList[0].Log_gne__c);             	
     }
     
     static testMethod void testTargetAndTiersMergeTypeEngineBatchInMergeMode() {
     	Merge_Type_gne__c mergeType = createTargetAndTiersMergeType(2);
     	
        Merge_Type_Console_Controller controller = new Merge_Type_Console_Controller (new Apexpages.Standardcontroller(mergeType));
        system.assert ( controller.canLaunch, 'Can Launch returned false, should be true.');
          
        List<Account> accountList = new List<Account>();
		accountList.add ( new Account ( FirstName = 'Person', LastName='Account',  Phone='6502551000', Fax='6502551000'));
		setOwner(accountList);
		insert accountList		;
        
		List<Product_vod__c> productList = new List<Product_vod__c>();
        productList.add(new Product_vod__c(Name = 'Product Catalog Item 1'));         
        insert productList;           
             
        List<TSF_vod__c> teritoryFieldList = new List<TSF_vod__c>(); 
        teritoryFieldList.add(new tsf_vod__c ( Name = 'Duplicate 1.1', account_vod__c = accountList[0].Id, territory_vod__c='test territory1' ));         
        insert teritoryFieldList;                       
        switchMergeMode(true);
        List<Targets_and_Tiers_can_gne__c> targetAndTiersList = new List<Targets_and_Tiers_can_gne__c>();  
     	targetAndTiersList.add( new Targets_and_Tiers_can_gne__c( Name = 'Duplicate 1.1', Account_can_gne__c = accountList[0].id, My_Target_gne__c = 'HI', Product_Catalog_gne__c = productList[0].Id, Segment_gne__c = null, Tier_can_gne__c = null, Territory_gne__c = teritoryFieldList[0].id ) );
        targetAndTiersList.add( new Targets_and_Tiers_can_gne__c( Name = 'Duplicate 1.2', Account_can_gne__c = accountList[0].id, My_Target_gne__c = 'HI', Product_Catalog_gne__c = productList[0].Id, Segment_gne__c = 'SegmentTestValue', Tier_can_gne__c = 'TierTestValue', Territory_gne__c = teritoryFieldList[0].id ) );           
        insert targetAndTiersList;        
        switchMergeMode(false);
        List<Merge_Type_Candidate_Stage_gne__c> stageList = new List<Merge_Type_Candidate_Stage_gne__c>();
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = targetAndTiersList[0].Id, parentid_gne__c=targetAndTiersList[0].Id, Merge_Type_ref_gne__c = mergeType.Id));
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = targetAndTiersList[1].Id, parentid_gne__c=targetAndTiersList[0].Id, Merge_Type_ref_gne__c = mergeType.Id));
        insert stageList;
        
        startBatch(controller, false);
        
        List<Merge_Type_Apex_Job_gne__c> apexJobList = [select Id, Log_gne__c,Apex_Job_Type_gne__c from Merge_Type_Apex_Job_gne__c where Merge_Type_ref_gne__c = :mergeType.Id];
        Integer jobPerformed = apexJobList.size();
        Integer totalTargetsAndTiers = [select count() from Targets_and_Tiers_can_gne__c];
        System.assert (  jobPerformed == 1, 'Merge Type Apex Job should be 1. Actual job count is ' + jobPerformed);
        System.assert (  totalTargetsAndTiers == 1, 'Total Targets and Tiers should be 1.  Actual total Targets and Tiers is ' + totalTargetsAndTiers + '\nLog=> ' +  apexJobList[0].Log_gne__c);             	
     }
     
     static testMethod void testTargetAndTiersMergeTypeEngineBatchInMergeModeWithDeferOnConflictException() {
		Merge_Type_gne__c mergeType = createTargetAndTiersMergeType(2);
     	
        Merge_Type_Console_Controller controller = new Merge_Type_Console_Controller (new Apexpages.Standardcontroller(mergeType));
        system.assert ( controller.canLaunch, 'Can Launch returned false, should be true.');
          
        List<Account> accountList = new List<Account>();
		accountList.add ( new Account ( FirstName = 'Person', LastName='Account',  Phone='6502551000', Fax='6502551000'));
		setOwner(accountList);
		insert accountList		;
        
		List<Product_vod__c> productList = new List<Product_vod__c>();
        productList.add(new Product_vod__c(Name = 'Product Catalog Item 1'));         
        insert productList;                        
        
        List<TSF_vod__c> teritoryFieldList = new List<TSF_vod__c>(); 
        teritoryFieldList.add(new tsf_vod__c ( Name = 'Duplicate 1.1', account_vod__c = accountList[0].Id, territory_vod__c='test territory1' ));         
        insert teritoryFieldList;

        switchMergeMode(true);
        List<Targets_and_Tiers_can_gne__c> targetAndTiersList = new List<Targets_and_Tiers_can_gne__c>();
     	targetAndTiersList.add( new Targets_and_Tiers_can_gne__c( Name = 'Duplicate 1.1', Account_can_gne__c = accountList[0].id, My_Target_gne__c = 'HI', Product_Catalog_gne__c = productList[0].Id, Segment_gne__c = null, Tier_can_gne__c = null, Territory_gne__c = teritoryFieldList[0].id ) );
        targetAndTiersList.add( new Targets_and_Tiers_can_gne__c( Name = 'Duplicate 1.2', Account_can_gne__c = accountList[0].id, My_Target_gne__c = 'LOW', Product_Catalog_gne__c = productList[0].Id, Segment_gne__c = 'SegmentTestValue', Tier_can_gne__c = 'TierTestValue', Territory_gne__c = teritoryFieldList[0].id ) );           
        insert targetAndTiersList;        
        switchMergeMode(false);
        List<Merge_Type_Candidate_Stage_gne__c> stageList = new List<Merge_Type_Candidate_Stage_gne__c>();
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = targetAndTiersList[0].Id, parentid_gne__c=targetAndTiersList[0].Id, Merge_Type_ref_gne__c = mergeType.Id));
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = targetAndTiersList[1].Id, parentid_gne__c=targetAndTiersList[0].Id, Merge_Type_ref_gne__c = mergeType.Id));
        insert stageList;
        
        startBatch(controller, false);
        
        List<Merge_Type_Apex_Job_gne__c> apexJobList = [select Id, Log_gne__c,Apex_Job_Type_gne__c from Merge_Type_Apex_Job_gne__c where Merge_Type_ref_gne__c = :mergeType.Id];
        Integer jobPerformed = apexJobList.size();
        Integer totalTargetsAndTiers = [select count() from Targets_and_Tiers_can_gne__c];
        System.assert (  jobPerformed == 1, 'Merge Type Apex Job should be 1. Actual job count is ' + jobPerformed);
        System.assert (  totalTargetsAndTiers == 2, 'Total Targets and Tiers should be 2 (including 1 record for approval).  Actual total Targets and Tiers is ' + totalTargetsAndTiers + '\nLog=> ' +  apexJobList[0].Log_gne__c);             	
     }     
      
     static testMethod void testBrandAffiliationsMergeTypeEngineBatchInMergeMode() {
     	Merge_Type_gne__c mergeType = createBrandAffiliationsMergeType(2);
     	
        Merge_Type_Console_Controller controller = new Merge_Type_Console_Controller (new Apexpages.Standardcontroller(mergeType));
        system.assert ( controller.canLaunch, 'Can Launch returned false, should be true.');
           
		List<Account> accountList = new List<Account>();
		accountList.add ( new Account ( FirstName = 'Person', LastName='Account',  Phone='6502551000', Fax='6502551000'));
		setOwner(accountList);
		insert accountList		;

		List<Product_vod__c> productList = new List<Product_vod__c>();
        productList.add(new Product_vod__c(Name = 'Product Catalog Item 1'));
        productList.add(new Product_vod__c(Name = 'Product Catalog Item 2'));           
        insert productList;    
                                               
        List<Product_Metrics_vod__c> productMetricsList = new List<Product_Metrics_vod__c>();
       	productMetricsList.add( new Product_Metrics_vod__c(Account_vod__c = accountList[0].id, Products_vod__c = productList[0].id, Brand_Affiliation_Status_gne__c = null, Tier_gne__c = null, Company_Target_gne__c = false ) ); 
       	productMetricsList.add( new Product_Metrics_vod__c(Account_vod__c = accountList[0].id, Products_vod__c = productList[1].id, Brand_Affiliation_Status_gne__c = 'Active', Tier_gne__c = null, Company_Target_gne__c = true ) );        
        insert productMetricsList;   
     
        Advocacy_Assessment_gne__c advocacyAssessment = new Advocacy_Assessment_gne__c(Brand_Affiliations_gne__c = productMetricsList[1].id, Brand_Message_1_gne__c = 1);
        insert advocacyAssessment;         
             
        List<Merge_Type_Candidate_Stage_gne__c> stageList = new List<Merge_Type_Candidate_Stage_gne__c>();
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = productMetricsList[0].Id, parentid_gne__c=productMetricsList[0].Id, Merge_Type_ref_gne__c = mergeType.Id));
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = productMetricsList[1].Id, parentid_gne__c=productMetricsList[0].Id, Merge_Type_ref_gne__c = mergeType.Id));
        insert stageList;
         
        startBatch(controller, false);
                
        Product_Metrics_vod__c prodMetrics = [select Id, (select id from Advocacy_Assessment_gne__r) from Product_Metrics_vod__c where id = :productMetricsList[0].Id];
                
        List<Merge_Type_Apex_Job_gne__c> apexJobList = [select Id, Log_gne__c,Apex_Job_Type_gne__c from Merge_Type_Apex_Job_gne__c where Merge_Type_ref_gne__c = :mergeType.Id];
        Integer jobPerformed = apexJobList.size();
        Integer totalBrandAffiliations = [select count() from Product_Metrics_vod__c];
        System.assert (  jobPerformed == 1, 'Merge Type Apex Job should be 1. Actual job count is ' + jobPerformed);
        System.assert (  totalBrandAffiliations == 1, 'Total Brand Affiliations should be 1.  Actual total Brand Affiliations is ' + totalBrandAffiliations + '\nLog=> ' +  apexJobList[0].Log_gne__c);        
 		System.assert (  prodMetrics.Advocacy_Assessment_gne__r != null && prodMetrics.Advocacy_Assessment_gne__r.size() == 1, 'Advocacy Assessment should be 2 actual is ' + prodMetrics.Advocacy_Assessment_gne__r.size() + ' please review relationship to move business rule and its related code.' );                     	
     }      
           
     static testMethod void testBrandAffiliationsMergeTypeEngineBatchInMergeModeWithDeferOnConflictException() {
     	Merge_Type_gne__c mergeType = createBrandAffiliationsMergeType(2);
     	
        Merge_Type_Console_Controller controller = new Merge_Type_Console_Controller (new Apexpages.Standardcontroller(mergeType));
        system.assert ( controller.canLaunch, 'Can Launch returned false, should be true.');
           
		List<Account> accountList = new List<Account>();
		accountList.add ( new Account ( FirstName = 'Person', LastName='Account',  Phone='6502551000', Fax='6502551000'));
		accountList.add ( new Account ( FirstName = 'Person2', LastName='Account2',  Phone='6502551002', Fax='6502551002'));
		setOwner(accountList);
		insert accountList		;
                                               
        List<Product_Metrics_vod__c> productMetricsList = new List<Product_Metrics_vod__c>();
       	productMetricsList.add( new Product_Metrics_vod__c(Account_vod__c = accountList[0].id, Brand_Affiliation_Status_gne__c = null ) ); 
       	productMetricsList.add( new Product_Metrics_vod__c(Account_vod__c = accountList[1].id, Brand_Affiliation_Status_gne__c = 'Active', Company_Target_gne__c = true ) );        
        insert productMetricsList;   
     
        Advocacy_Assessment_gne__c advocacyAssessment = new Advocacy_Assessment_gne__c(Brand_Affiliations_gne__c = productMetricsList[1].id, Brand_Message_1_gne__c = 1);
        insert advocacyAssessment;         
             
        List<Merge_Type_Candidate_Stage_gne__c> stageList = new List<Merge_Type_Candidate_Stage_gne__c>();
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = productMetricsList[0].Id, parentid_gne__c=productMetricsList[0].Id, Merge_Type_ref_gne__c = mergeType.Id));
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = productMetricsList[1].Id, parentid_gne__c=productMetricsList[0].Id, Merge_Type_ref_gne__c = mergeType.Id));
        insert stageList;
         
		startBatch(controller, false);
                                       
        List<Merge_Type_Apex_Job_gne__c> apexJobList = [select Id, Log_gne__c,Apex_Job_Type_gne__c from Merge_Type_Apex_Job_gne__c where Merge_Type_ref_gne__c = :mergeType.Id];
        Integer jobPerformed = apexJobList.size();
        Integer totalBrandAffiliations = [select count() from Product_Metrics_vod__c];
        System.assert (  jobPerformed == 1, 'Merge Type Apex Job should be 1. Actual job count is ' + jobPerformed);
        System.assert (  totalBrandAffiliations == 2, 'Total Brand Affiliations should be 2 (including 1 record for approval).  Actual total Brand Affiliations is ' + totalBrandAffiliations + '\nLog=> ' +  apexJobList[0].Log_gne__c);                             	
     }     
          
     static testMethod void testAffiliationMergeTypeEngineBatchInMergeMode() {
     	Merge_Type_gne__c mergeType = createAffiliationMergeType(2);
     	
        Merge_Type_Console_Controller controller = new Merge_Type_Console_Controller (new Apexpages.Standardcontroller(mergeType));
        system.assert ( controller.canLaunch, 'Can Launch returned false, should be true.');
           
		List<Account> accountList = new List<Account>();
		accountList.add ( new Account ( Name = 'Hospital'));
		accountList.add ( new Account ( FirstName = 'Person2', LastName='Account2',  Phone='6502551002', Fax='6502551002'));
		accountList.add ( new Account ( FirstName = 'Person3', LastName='Account3',  Phone='6502551003', Fax='6502551003'));
		setOwner(accountList);
		insert accountList		;
         	
        List<Affiliation_vod__c> affiliationList = new List<Affiliation_vod__c>();
       	affiliationList.add( new Affiliation_vod__c(To_Account_vod__c = accountList[0].id, From_Account_vod__c = accountList[1].id, Source_gne__c = 'Source 1', Note_gne__c = null,Affiliation_Type_gne__c = 'Doctor') ); 
       	affiliationList.add( new Affiliation_vod__c(To_Account_vod__c = accountList[0].id, From_Account_vod__c = accountList[2].id, Source_gne__c = 'Source 2', Note_gne__c = null, Affiliation_Type_gne__c = 'Doctor') );        
        insert affiliationList;                
             
        List<Merge_Type_Candidate_Stage_gne__c> stageList = new List<Merge_Type_Candidate_Stage_gne__c>();
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = affiliationList[0].Id, parentid_gne__c=affiliationList[0].Id, Merge_Type_ref_gne__c = mergeType.Id));
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = affiliationList[1].Id, parentid_gne__c=affiliationList[0].Id, Merge_Type_ref_gne__c = mergeType.Id));
        insert stageList;
         
		system.assert ( [select count() from affiliation_vod__c] == 4);
		merge accountList[1] accountList[2];
		system.assert ( [select count() from affiliation_vod__c] == 4); // it appears veeva does not merge affiliation automatically as its doen for TSF records.
        startBatch(controller, false);
                
        List<Merge_Type_Apex_Job_gne__c> apexJobList = [select Id, Log_gne__c,Apex_Job_Type_gne__c from Merge_Type_Apex_Job_gne__c where Merge_Type_ref_gne__c = :mergeType.Id];
        Integer jobPerformed = apexJobList.size();
        Integer totalAffiliations = [select count() from Affiliation_vod__c  where IsDeleted = false];
        
        List<Affiliation_vod__c> aList =  [select id, To_Account_vod__c, From_Account_vod__c, Source_gne__c, Parent_vod__c, IsDeleted from Affiliation_vod__c];
        System.assert (  jobPerformed == 1, 'Merge Type Apex Job should be 1. Actual job count is ' + jobPerformed);
        System.assert (  totalAffiliations == 2, 'Total Affiliations should be 2.  Actual total Affiliations is ' + totalAffiliations + '\nLog=> ' +  apexJobList[0].Log_gne__c);                             	
     }                           
             
             
             
     static testMethod void testInsertCandidateBatchWithoutUniqueKeyFieldRule () {
        Decimal regionCode = Decimal.valueOf(REGION_CODE_CANADA);
        Merge_Type_gne__c mergeType = createTerritoryFieldMergeTypeWithoutUniqueKeyFieldRule (regionCode);
        Merge_Type_Console_Controller controller = new Merge_Type_Console_Controller (new Apexpages.Standardcontroller(mergeType));
        system.assert ( controller.canLaunch, 'Can Launch returned false, should be true.');

        List<Account> accountList = new List<Account>();
        accountList.add ( new Account ( Name = 'Duplicate 1.1',  Phone='6502551000', Fax='6502551000', Region_Code_gne__c = regionCode));
        accountList.add ( new Account ( Name = 'Duplicate 1.2',  Phone='6502551000', Region_Code_gne__c = regionCode));
        setOwner(accountList);
        insert accountList;

        // Teritory Field:
        List<tsf_vod__c> tsflist = new List<tsf_vod__c>();
        tsflist.add ( new tsf_vod__c ( Name = 'Duplicate 1.1', account_vod__c = accountList[0].Id, territory_vod__c='test territory1' ));
        tsflist.add ( new tsf_vod__c ( Name = 'Duplicate 1.2', account_vod__c = accountList[1].Id, territory_vod__c='test territory2' ));
        tsflist.add ( new tsf_vod__c ( Name = 'Duplicate 1.1', account_vod__c = accountList[0].Id, territory_vod__c='test territory3' ));
        tsflist.add ( new tsf_vod__c ( Name = 'Duplicate 1.2', account_vod__c = accountList[1].Id, territory_vod__c='test territory4' ));
        insert tsflist;

        system.assert ( controller.showPopulateMergeCandidates );
        Exception ex = null;
        try {
	        Test.startTest();
	            merge accountList[0] accountList[1].Id;
	            system.assert ( controller.canLaunch == true, 'Can Launch returned false, should be true.');
	            controller.populateMergeCandidates();
	        Test.stopTest();
        } catch (Exception e) {
        	ex = e;
        }
        system.assert ( ex != null && ex instanceOf Merge_Type_Exception && ex.getMessage().contains('Sort By Columns, Where Clause, Unique Set Field Name rules are required '));
    }

    static testMethod void testInsertCandidateBatchWithNoDuplicates () {
    	Decimal regionCode = Decimal.valueOf(REGION_CODE_CANADA);
        Merge_Type_gne__c mergeType = createTerritoryFieldMergeType (regionCode);
        Merge_Type_Console_Controller controller = new Merge_Type_Console_Controller (new Apexpages.Standardcontroller(mergeType));
        system.assert ( controller.canLaunch, 'Can Launch returned false, should be true.');

        List<Account> accountList = new List<Account>();
        accountList.add ( new Account ( Name = 'Duplicate 1.1',  Phone='6502551000', Fax='6502551000', Region_Code_gne__c = regionCode));
        accountList.add ( new Account ( Name = 'Duplicate 1.2',  Phone='6502551000', Region_Code_gne__c = regionCode));
        setOwner(accountList);
        insert accountList;

        // Teritory Field:
        List<tsf_vod__c> tsflist = new List<tsf_vod__c>();
        tsflist.add ( new tsf_vod__c ( Name = 'Duplicate 1.1', Allowed_Products_vod__c = '1', account_vod__c = accountList[0].Id, territory_vod__c='test territory1' ));
        tsflist.add ( new tsf_vod__c ( Name = 'Duplicate 1.2', Allowed_Products_vod__c = '2', account_vod__c = accountList[1].Id, territory_vod__c='test territory2' ));
        tsflist.add ( new tsf_vod__c ( Name = 'Duplicate 1.1', Allowed_Products_vod__c = '3', account_vod__c = accountList[0].Id, territory_vod__c='test territory3' ));
        tsflist.add ( new tsf_vod__c ( Name = 'Duplicate 1.2', Allowed_Products_vod__c = '4', account_vod__c = accountList[1].Id, territory_vod__c='test territory4' ));
        insert tsflist;

        system.assert ( controller.showPopulateMergeCandidates );
        Test.startTest();
            merge accountList[0] accountList[1].Id;
            system.assert ( controller.canLaunch == true, 'Can Launch returned false, should be true.');
            controller.populateMergeCandidates();
            system.assert ( controller.canLaunch == false, 'Can Launch returned true, should be false.');
        Test.stopTest();
        system.assert ( controller.canLaunch == true, 'Can Launch returned false, should be true.');

        List<Merge_Type_Apex_Job_gne__c> apexJobList = [select Id, Log_gne__c,Apex_Job_Type_gne__c from Merge_Type_Apex_Job_gne__c where Merge_Type_ref_gne__c = :mergeType.Id];
        Integer jobPerformed = apexJobList.size();
        System.assert (  jobPerformed == 1, 'Merge Type Apex Job should be 1. Actual  count is ' + jobPerformed);
        Integer duplicateSet = [select count() from Merge_Type_Candidate_Stage_gne__c where merge_type_ref_gne__c = :mergeType.Id];
        system.assert ( duplicateSet == 0, 'Should have found 0 candidates, please check.\nLog=> ' + apexJobList[0].Log_gne__c );
    }

    static testMethod void testInsertCandidateBatchShouldFindDuplicates () {
        Decimal regionCode = Decimal.valueOf(REGION_CODE_CANADA);
        Merge_Type_gne__c mergeType = createTerritoryFieldMergeType (regionCode);
        Merge_Type_Console_Controller controller = new Merge_Type_Console_Controller (new Apexpages.Standardcontroller(mergeType));
        system.assert ( controller.canLaunch, 'Can Launch returned false, should be true.');

        List<Account> accountList = new List<Account>();
        accountList.add ( new Account ( Name = 'Duplicate 1.1',  Phone='6502551000', Fax='6502551000', Region_Code_gne__c = regionCode));
        accountList.add ( new Account ( Name = 'Duplicate 1.2',  Phone='6502551000', Region_Code_gne__c = regionCode));
        setOwner(accountList);
        insert accountList;

		// Teritory Field:
        List<tsf_vod__c> tsflist = new List<tsf_vod__c>();
        tsflist.add ( new tsf_vod__c ( Name = 'Duplicate 1.1', Allowed_Products_vod__c = '1', account_vod__c = accountList[0].Id, territory_vod__c='test territory1' ));
        tsflist.add ( new tsf_vod__c ( Name = 'Duplicate 1.2', Allowed_Products_vod__c = '1', account_vod__c = accountList[1].Id, territory_vod__c='test territory2' ));
        tsflist.add ( new tsf_vod__c ( Name = 'Duplicate 1.1', Allowed_Products_vod__c = '2', account_vod__c = accountList[0].Id, territory_vod__c='test territory3' ));
        tsflist.add ( new tsf_vod__c ( Name = 'Duplicate 1.2', Allowed_Products_vod__c = '2', account_vod__c = accountList[1].Id, territory_vod__c='test territory4' ));
        insert tsflist;

        system.assert ( controller.showPopulateMergeCandidates );
        Test.startTest();
            merge accountList[0] accountList[1].Id;
            system.assert ( controller.canLaunch == true, 'Can Launch returned false, should be true.');
            controller.populateMergeCandidates();
            system.assert ( controller.canLaunch == false, 'Can Launch returned true, should be false.');
        Test.stopTest();
        system.assert ( controller.canLaunch == true, 'Can Launch returned false, should be true.');

        system.assert ( [select count() from tsf_vod__c] == 4);
        List<Merge_Type_Apex_Job_gne__c> apexJobList = [select Id, Log_gne__c,Apex_Job_Type_gne__c from Merge_Type_Apex_Job_gne__c where Merge_Type_ref_gne__c = :mergeType.Id];
        Integer jobPerformed = apexJobList.size();
        System.assert (  jobPerformed == 1, 'Merge Type Apex Job should be 1. Actual  count is ' + jobPerformed);
        Integer duplicateSet = [select count() from Merge_Type_Candidate_Stage_gne__c where merge_type_ref_gne__c = :mergeType.Id];
        system.assert ( duplicateSet == 4, 'Should have found 4 merge type candidates(2 duplicates), actual count is ' + duplicateSet + '. please check.\nLog=> ' + apexJobList[0].Log_gne__c );
    }

    static testMethod void testMergeTypeException () {
    	Merge_Type_Exception mte= new Merge_Type_Exception('test exception');
    	try {
    		system.assert ( mte != null);
    		mte.getMessage();
            throw mte;
    	} catch (Exception e) {
    	}
    }
    
    static testMethod void testAddressPrimaryFlagCase1() {
    	Merge_Type_gne__c mergeType = createPersonAccountMergeType (2);
        Merge_Type_Console_Controller controller = new Merge_Type_Console_Controller (new Apexpages.Standardcontroller(mergeType));
        List<Account> accountList = new List<Account>();
        List<Address_vod__c> addressList = new List<Address_vod__c>();
        Integer numberOfDuplicates = 2;
        prepareAddressPrimaryFlagTest(controller, mergeType, accountList, addressList, numberOfDuplicates, true);
        sleep(1000);
        runAddressPrimaryFlagTest(controller, mergeType, accountList, addressList, numberOfDuplicates);
        
        Map<Id,Address_vod__c> addrMap = new Map<Id,Address_vod__c>([SELECT Id, Primary_vod__c FROM Address_vod__c WHERE Id IN :addressList]);
        
        System.assertEquals(true, addrMap.get(addressList[0].Id).Primary_vod__c, 'Winner\'s address should be primary.');
        
        for(Integer i = 1;i<addressList.size();i++) {
        	System.assertEquals(false, addrMap.get(addressList[i].Id).Primary_vod__c, 'Loser\'s address shouldn\'t be primary.');	
        }
    }
    
    static testMethod void testAddressPrimaryFlagCase2() {
    	Merge_Type_gne__c mergeType = createAccountMergeType(2);
        Merge_Type_Console_Controller controller = new Merge_Type_Console_Controller (new Apexpages.Standardcontroller(mergeType));
        List<Account> accountList = new List<Account>();
        List<Address_vod__c> addressList = new List<Address_vod__c>();
        Integer numberOfDuplicates = 2;
        prepareAddressPrimaryFlagTest(controller, mergeType, accountList, addressList, numberOfDuplicates, false);
        
        for(Address_vod__c addr : addressList) {
        	addr.Primary_vod__c = false;
        }
        
        switchMergeMode(true);
        update addressList;
        switchMergeMode(false);
        
        sleep(1000);
        
        runAddressPrimaryFlagTest(controller, mergeType, accountList, addressList, numberOfDuplicates);
        
        Map<Id,Address_vod__c> addrMap = new Map<Id,Address_vod__c>([SELECT Id, Primary_vod__c FROM Address_vod__c WHERE Id IN :addressList]);
        
        System.assertEquals(true, addrMap.get(addressList[0].Id).Primary_vod__c, 'Winner\'s address should be primary.');
        
        for(Integer i = 1;i<addressList.size();i++) {
        	System.assertEquals(false, addrMap.get(addressList[i].Id).Primary_vod__c, 'Loser\'s address shouldn\'t be primary.');	
        }
    }
    
    static testMethod void testAddressPrimaryFlagCase3() {
    	Merge_Type_gne__c mergeType = createAccountMergeType(2);
        Merge_Type_Console_Controller controller = new Merge_Type_Console_Controller (new Apexpages.Standardcontroller(mergeType));
        List<Account> accountList = new List<Account>();
        List<Address_vod__c> addressList = new List<Address_vod__c>();
        Integer numberOfDuplicates = 2;
        prepareAddressPrimaryFlagTest(controller, mergeType, accountList, addressList, numberOfDuplicates, false);
        
        for(Address_vod__c addr : addressList) {
        	addr.Primary_vod__c = false;
        }
        
        switchMergeMode(true);
        update addressList;
        switchMergeMode(false);
        sleep(1000);
        
        runAddressPrimaryFlagTest(controller, mergeType, accountList, addressList, numberOfDuplicates);
        
        Map<Id,Address_vod__c> addrMap = new Map<Id,Address_vod__c>([SELECT Id, Primary_vod__c FROM Address_vod__c WHERE Id IN :addressList]);
        
        System.assertEquals(true, addrMap.get(addressList[0].Id).Primary_vod__c, 'Winner\'s address should be primary.');
        
        for(Integer i = 1;i<addressList.size();i++) {
        	System.assertEquals(false, addrMap.get(addressList[i].Id).Primary_vod__c, 'Loser\'s address shouldn\'t be primary.');	
        }
    }
    
    static testMethod void testAddressPrimaryFlagCase4() {
    	Merge_Type_gne__c mergeType = createPersonAccountMergeType(2);
        Merge_Type_Console_Controller controller = new Merge_Type_Console_Controller (new Apexpages.Standardcontroller(mergeType));
        List<Account> accountList = new List<Account>();
        List<Address_vod__c> addressList = new List<Address_vod__c>();
        Integer numberOfDuplicates = 3;
        prepareAddressPrimaryFlagTest(controller, mergeType, accountList, addressList, numberOfDuplicates, false);
        
        for(Address_vod__c addr : addressList) {
        	addr.Primary_vod__c = false;
        }
        
        switchMergeMode(true);
        update addressList;
        switchMergeMode(false);
        
        List<Call2_vod__c> callList = new List<Call2_vod__c>();
	    DateTime dt= system.now();
	    callList.add (new Call2_vod__c (account_vod__c = accountList[2].Id, parent_address_vod__c= addressList[2].Id, call_datetime_vod__c = dt));	
	    setOwner(callList);
	    insert callList;
        
        runAddressPrimaryFlagTest(controller, mergeType, accountList, addressList, numberOfDuplicates);
        
        Map<Id,Address_vod__c> addrMap = new Map<Id,Address_vod__c>([SELECT Id, Primary_vod__c FROM Address_vod__c WHERE Id IN :addressList]);
        
        System.assertEquals(false, addrMap.get(addressList[0].Id).Primary_vod__c, 'Winner\'s address shouldn\'t be primary.');
        
        for(Integer i = 1;i<addressList.size();i++) {
        	if(i==2) {
        		System.assertEquals(true, addrMap.get(addressList[i].Id).Primary_vod__c, 'Loser\'s address should be primary.');	
        	} else {
        		System.assertEquals(false, addrMap.get(addressList[i].Id).Primary_vod__c, 'Loser\'s address shouldn\'t be primary.');
        	}
        }
    }
    
    static testMethod void testAddressPrimaryFlagCase5() {
    	Merge_Type_gne__c mergeType = createPersonAccountMergeType(2);
        Merge_Type_Console_Controller controller = new Merge_Type_Console_Controller (new Apexpages.Standardcontroller(mergeType));
        List<Account> accountList = new List<Account>();
        List<Address_vod__c> addressList = new List<Address_vod__c>();
        Integer numberOfDuplicates = 3;
        prepareAddressPrimaryFlagTest(controller, mergeType, accountList, addressList, numberOfDuplicates, true);
        
        for(Address_vod__c addr : addressList) {
        	addr.Primary_vod__c = false;
        }
        
        switchMergeMode(true);
        update addressList;
        switchMergeMode(false);
        sleep(1000);
        List<Call2_vod__c> callList = new List<Call2_vod__c>();
	    DateTime dt= system.now();
	    callList.add (new Call2_vod__c (account_vod__c = accountList[2].Id, parent_address_vod__c= addressList[2].Id, call_datetime_vod__c = dt));	
	    setOwner(callList);
	    insert callList;
        
        runAddressPrimaryFlagTest(controller, mergeType, accountList, addressList, numberOfDuplicates);
        
        Map<Id,Address_vod__c> addrMap = new Map<Id,Address_vod__c>([SELECT Id, Primary_vod__c FROM Address_vod__c WHERE Id IN :addressList]);
        
        System.assertEquals(false, addrMap.get(addressList[0].Id).Primary_vod__c, 'Winner\'s address shouldn\'t be primary.');
        
        for(Integer i = 1;i<addressList.size();i++) {
        	if(i==2) {
        		System.assertEquals(true, addrMap.get(addressList[i].Id).Primary_vod__c, 'Loser\'s address should be primary.');	
        	} else {
        		System.assertEquals(false, addrMap.get(addressList[i].Id).Primary_vod__c, 'Loser\'s address shouldn\'t be primary.');
        	}
        }
    }
    
    static testMethod void testAddressPrimaryFlagCase6() {
    	Merge_Type_gne__c mergeType = createAccountAddressMergeType(2);
        Merge_Type_Console_Controller controller = new Merge_Type_Console_Controller (new Apexpages.Standardcontroller(mergeType));
        List<Account> accountList = new List<Account>();
        List<Address_vod__c> addressList = new List<Address_vod__c>();
        Integer numberOfDuplicates = 1;
        prepareAddressPrimaryFlagTest(controller, mergeType, accountList, addressList, numberOfDuplicates, true);
        
        addressList[0].Primary_vod__c = false;
        switchMergeMode(true);
        update addressList[0];
        switchMergeMode(false);
        
        runAddressPrimaryFlagTest(controller, mergeType, accountList, addressList, numberOfDuplicates);
        
        Map<Id,Address_vod__c> addrMap = new Map<Id,Address_vod__c>([SELECT Id, Primary_vod__c FROM Address_vod__c WHERE Id IN :addressList]);
        System.assertEquals(true, addrMap.get(addressList[0].Id).Primary_vod__c, 'Winner address should be primary.');
    }
    
    static testMethod void testAddressPrimaryFlagCase7() {
    	Merge_Type_gne__c mergeType = createPersonAccountAddressMergeType(2);
        Merge_Type_Console_Controller controller = new Merge_Type_Console_Controller (new Apexpages.Standardcontroller(mergeType));
        List<Account> accountList = new List<Account>();
        List<Address_vod__c> addressList = new List<Address_vod__c>();
        Integer numberOfDuplicates = 1;
        prepareAddressPrimaryFlagTest(controller, mergeType, accountList, addressList, numberOfDuplicates, true);
        
        for(Address_vod__c addr : addressList) {
        	addr.Primary_vod__c = false;
        }
        
        switchMergeMode(true);
        update addressList;
        switchMergeMode(false);
        
        runAddressPrimaryFlagTest(controller, mergeType, accountList, addressList, numberOfDuplicates);
        
        Map<Id,Address_vod__c> addrMap = new Map<Id,Address_vod__c>([SELECT Id, Primary_vod__c FROM Address_vod__c WHERE Id IN :addressList]);
        System.assertEquals(true, addrMap.get(addressList[0].Id).Primary_vod__c, 'Winner address should be primary.');
    }
    
    static testMethod void testActiveUSLicenseNullValuesCase1() {
        Merge_Type_gne__c mergeType = createPersonAccountMergeType(2);
        insert new Merge_Type_Business_Rule_gne__c (
        	merge_type_ref_gne__c = mergeType.Id,
        	field_name_gne__c = 'Active_US_License_gne__c',
        	field_type_gne__c = 'Not Null', 
        	active_gne__c = true, 
        	relatedlist_query_text_gne__c = JSON.serialize(new Map<String,Object>{
        		'NullValues' => new Set<String>{'Unknown'}
        	})
        );
        Merge_Type_Console_Controller controller = new Merge_Type_Console_Controller (new Apexpages.Standardcontroller(mergeType));
        system.assert ( controller.canLaunch, 'Can Launch returned false, should be true.');

        List<Account> accountList = new List<Account>();
        accountList.add ( new Account ( FirstName = 'Duplicate 1.1', LastName='Person',  Phone='6502551000', Active_US_License_gne__c = 'Unknown'));
        accountList.add ( new Account ( FirstName = 'Duplicate 1.1', LastName='Person',  Phone='6502551000', Fax='6502551000', Active_US_License_gne__c = 'No'));
        setOwner(accountList);
        insert accountList;

        List<Merge_Type_Candidate_Stage_gne__c> stageList = new List<Merge_Type_Candidate_Stage_gne__c>();
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = accountList[0].Id, parentid_gne__c=accountList[0].Id,Merge_Type_ref_gne__c = mergeType.Id));
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = accountList[1].Id, parentid_gne__c=accountList[0].Id, Merge_Type_ref_gne__c = mergeType.Id));
        insert stageList;
        String loserAccountId = accountList[1].Id;

        startBatch(controller, false);
        
        system.assert ( controller.canLaunch == true, 'Can Launch returned false, should be true.');
        List<Merge_Type_Apex_Job_gne__c> apexJobList = [select Id, Log_gne__c,Apex_Job_Type_gne__c from Merge_Type_Apex_Job_gne__c where Merge_Type_ref_gne__c = :mergeType.Id];
        Integer jobPerformed = apexJobList.size();
        Integer totalAccounts = [select count() from Account];
        System.assert (  jobPerformed == 1, 'Merge Type Apex Job should be 1. Actual job count is ' + jobPerformed);
        String exceptionDesc = [select id, dch_merge_type_exception_desc_gne__c from Merge_Type_Candidate_Stage_gne__c where parentid_gne__c  =  :accountList[0].Id and id_gne__c = :accountList[0].Id  limit 1].dch_merge_type_exception_desc_gne__c;
        System.assert (  totalAccounts == 3, 'Total Account should be 3(including 2 dch archive records).  Actual total account is ' + totalAccounts + '\nLog=> ' + apexJobList[0].Log_gne__c + '. exception captured =>' +  exceptionDesc);
        List<Account> accountListAfterMerge = [select Id, Name, Phone, Fax, Active_US_License_gne__c from Account where id IN :accountList];
        system.assertEquals(1, accountListAfterMerge.size(), 'There should be only 1 Account (excluding Archived ones) after the merge');
        system.assertEquals(accountList[0].Id, accountListAfterMerge[0].Id, 'Wrong Account left after merge');
        system.assertEquals(accountList[1].Active_US_License_gne__c, accountListAfterMerge[0].Active_US_License_gne__c, 'Active_US_License_gne__c should be copied from the loser');
    }
    
    static testMethod void testActiveUSLicenseNullValuesCase2() {
        Merge_Type_gne__c mergeType = createPersonAccountMergeType(2);
        insert new Merge_Type_Business_Rule_gne__c (
        	merge_type_ref_gne__c = mergeType.Id,
        	field_name_gne__c = 'Active_US_License_gne__c',
        	field_type_gne__c = 'Not Null', 
        	active_gne__c = true, 
        	relatedlist_query_text_gne__c = JSON.serialize(new Map<String,Object>{
        		'NullValues' => new Set<String>{'Unknown'}
        	})
        );
        Merge_Type_Console_Controller controller = new Merge_Type_Console_Controller (new Apexpages.Standardcontroller(mergeType));
        system.assert ( controller.canLaunch, 'Can Launch returned false, should be true.');

        List<Account> accountList = new List<Account>();
        accountList.add ( new Account ( FirstName = 'Duplicate 1.1', LastName='Person',  Phone='6502551000', Active_US_License_gne__c = 'Yes'));
        accountList.add ( new Account ( FirstName = 'Duplicate 1.1', LastName='Person',  Phone='6502551000', Fax='6502551000', Active_US_License_gne__c = 'Unknown'));
        setOwner(accountList);
        insert accountList;

        List<Merge_Type_Candidate_Stage_gne__c> stageList = new List<Merge_Type_Candidate_Stage_gne__c>();
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = accountList[0].Id, parentid_gne__c=accountList[0].Id,Merge_Type_ref_gne__c = mergeType.Id));
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = accountList[1].Id, parentid_gne__c=accountList[0].Id, Merge_Type_ref_gne__c = mergeType.Id));
        insert stageList;
        String loserAccountId = accountList[1].Id;

        startBatch(controller, false);
        
        system.assert ( controller.canLaunch == true, 'Can Launch returned false, should be true.');
        List<Merge_Type_Apex_Job_gne__c> apexJobList = [select Id, Log_gne__c,Apex_Job_Type_gne__c from Merge_Type_Apex_Job_gne__c where Merge_Type_ref_gne__c = :mergeType.Id];
        Integer jobPerformed = apexJobList.size();
        Integer totalAccounts = [select count() from Account];
        System.assert (  jobPerformed == 1, 'Merge Type Apex Job should be 1. Actual job count is ' + jobPerformed);
        String exceptionDesc = [select id, dch_merge_type_exception_desc_gne__c from Merge_Type_Candidate_Stage_gne__c where parentid_gne__c  =  :accountList[0].Id and id_gne__c = :accountList[0].Id  limit 1].dch_merge_type_exception_desc_gne__c;
        System.assert (  totalAccounts == 3, 'Total Account should be 3(including 2 dch archive records).  Actual total account is ' + totalAccounts + '\nLog=> ' + apexJobList[0].Log_gne__c + '. exception captured =>' +  exceptionDesc);
        List<Account> accountListAfterMerge = [select Id, Name, Phone, Fax, Active_US_License_gne__c from Account where id IN :accountList];
        system.assertEquals(1, accountListAfterMerge.size(), 'There should be only 1 Account (excluding Archived ones) after the merge');
        system.assertEquals(accountList[0].Id, accountListAfterMerge[0].Id, 'Wrong Account left after merge');
        system.assertEquals(accountList[0].Active_US_License_gne__c, accountListAfterMerge[0].Active_US_License_gne__c, 'Active_US_License_gne__c should be left without any change on winner');
    }
    
    static testMethod void testActiveUSLicenseNullValuesCase3() {
        Merge_Type_gne__c mergeType = createPersonAccountMergeType(2);
        insert new Merge_Type_Business_Rule_gne__c (
        	merge_type_ref_gne__c = mergeType.Id,
        	field_name_gne__c = 'Active_US_License_gne__c',
        	field_type_gne__c = 'Not Null', 
        	active_gne__c = true, 
        	relatedlist_query_text_gne__c = JSON.serialize(new Map<String,Object>{
        		'NullValues' => new Set<String>{'Unknown'}
        	})
        );
        Merge_Type_Console_Controller controller = new Merge_Type_Console_Controller (new Apexpages.Standardcontroller(mergeType));
        system.assert ( controller.canLaunch, 'Can Launch returned false, should be true.');

        List<Account> accountList = new List<Account>();
        accountList.add ( new Account ( FirstName = 'Duplicate 1.1', LastName='Person',  Phone='6502551000', Active_US_License_gne__c = 'Yes'));
        accountList.add ( new Account ( FirstName = 'Duplicate 1.1', LastName='Person',  Phone='6502551000', Fax='6502551000', Active_US_License_gne__c = 'No'));
        setOwner(accountList);
        insert accountList;

        List<Merge_Type_Candidate_Stage_gne__c> stageList = new List<Merge_Type_Candidate_Stage_gne__c>();
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = accountList[0].Id, parentid_gne__c=accountList[0].Id,Merge_Type_ref_gne__c = mergeType.Id));
        stageList.add ( new Merge_Type_Candidate_Stage_gne__c ( id_gne__c = accountList[1].Id, parentid_gne__c=accountList[0].Id, Merge_Type_ref_gne__c = mergeType.Id));
        insert stageList;
        String loserAccountId = accountList[1].Id;

        startBatch(controller, false);
        
        system.assert ( controller.canLaunch == true, 'Can Launch returned false, should be true.');
        List<Merge_Type_Apex_Job_gne__c> apexJobList = [select Id, Log_gne__c,Apex_Job_Type_gne__c from Merge_Type_Apex_Job_gne__c where Merge_Type_ref_gne__c = :mergeType.Id];
        Integer jobPerformed = apexJobList.size();
        Integer totalAccounts = [select count() from Account];
        System.assert (  jobPerformed == 1, 'Merge Type Apex Job should be 1. Actual job count is ' + jobPerformed);
        String exceptionDesc = [select id, dch_merge_type_exception_desc_gne__c from Merge_Type_Candidate_Stage_gne__c where parentid_gne__c  =  :accountList[0].Id and id_gne__c = :accountList[0].Id  limit 1].dch_merge_type_exception_desc_gne__c;
        System.assert (  totalAccounts == 3, 'Total Account should be 3(including 2 dch archive records).  Actual total account is ' + totalAccounts + '\nLog=> ' + apexJobList[0].Log_gne__c + '. exception captured =>' +  exceptionDesc);
        List<Account> accountListAfterMerge = [select Id, Name, Phone, Fax, Active_US_License_gne__c from Account where id IN :accountList];
        system.assertEquals(1, accountListAfterMerge.size(), 'There should be only 1 Account (excluding Archived ones) after the merge');
        system.assertEquals(accountList[0].Id, accountListAfterMerge[0].Id, 'Wrong Account left after merge');
        system.assertEquals(accountList[0].Active_US_License_gne__c, accountListAfterMerge[0].Active_US_License_gne__c, 'Active_US_License_gne__c should be left without any change on winner');
    }
}