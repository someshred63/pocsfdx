/*
* @File Name:   prp_lookupSearchResult
* @Description: Class used to serialize a single Lookup search result item. The Lookup controller returns a List<LookupSearchResult> when sending search result back to Lightning.
* @group:       Apex Class
* @Modification Log  :
______________________________________________________________________________________
* Ver       Date         Modification
* 1.0       2022-06-09   Created the Component
*/
public class prp_lookupSearchResult {

    @testVisible private Id id;
    @testVisible private String sObjectType;
    @testVisible private String icon;
    @testVisible private String title;
    @testVisible private String subtitle;

    public prp_lookupSearchResult(Id id, String sObjectType, String icon, String title, String subtitle) {
        this.id = id;
        this.sObjectType = sObjectType;
        this.icon = icon;
        this.title = title;
        this.subtitle = subtitle;
    }

    @AuraEnabled
    public Id getId() {
        return id;
    }

    @AuraEnabled
    public String getSObjectType() {
        return sObjectType;
    }

    @AuraEnabled
    public String getIcon() {
        return icon;
    }

    @AuraEnabled
    public String getTitle() {
        return title;
    }

    @AuraEnabled
    public String getSubtitle() {
        return subtitle;
    }
}