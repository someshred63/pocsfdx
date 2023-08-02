public without sharing class VDST_AdminsManagementUtils {
    public Describer describer { get; set; }

    public VDST_AdminsManagementUtils() {
        describer = new Describer();
    }

    public List<SelectOption> getSObjectList(Boolean sortBySObjectLabel) {
        List<SelectOption> sObjectList = new List<SelectOption>();
        for (DescribeSort ds : (sortBySObjectLabel ? describer.sortedSObjectsByLabel : describer.sortedSObjectsByName)) {
            DescribeSObjectResult describeResult = ds.descSObjectResult;
            sObjectList.add(
                sortBySObjectLabel ?
                    new SelectOption(describeResult.getName().toLowerCase(), describeResult.getLabel()) :
                    new SelectOption(describeResult.getName().toLowerCase(), describeResult.getName())
            );
        }
        return sObjectList;
    }

    public List<Field> getFieldList(String sObjectName, Boolean sortByFieldLabel) {
        describer.prepareFieldDescribeListBySObjectName(sObjectName);
        List<Field> fieldList = new List<Field>();
        for (DescribeSort ds : (sortByFieldLabel ? describer.sortedFieldsByLabel : describer.sortedFieldsByName)) {
            DescribeFieldResult describeResult = ds.descFieldResult;
            fieldList.add(
                new Field(
                    describeResult.getName(),
                    describeResult.getLabel(),
                    '',
                    describeResult.getType(),
                    describeResult.isNillable(),
                    describeResult.getLength()
                )
            );
        }
        return fieldList;
    }

    public class Describer {
        public Map<String, Schema.SObjectType> schemaMap    { get; set; }

        public List<DescribeSort>   sortedSObjectsByName    { get; set; }
        public List<DescribeSort>   sortedSObjectsByLabel   { get; set; }
        public List<DescribeSort>   sortedFieldsByName      { get; set; }
        public List<DescribeSort>   sortedFieldsByLabel     { get; set; }

        public Describer() {
            schemaMap = Schema.getGlobalDescribe();
            initSortedLists();
        }

        public void initSortedLists() {
            sortedSObjectsByName = new List<DescribeSort>();
            sortedSObjectsByLabel = new List<DescribeSort>();
            for (String lowercaseName : schemaMap.keySet()) {
                DescribeSObjectResult describeResult = schemaMap.get(lowercaseName).getDescribe();
                if (!describeResult.isCreateable() || !describeResult.isAccessible()) {
                    continue;
                }
                sortedSObjectsByName.add(
                    new DescribeSort(describeResult.getName(), describeResult)
                );
                sortedSObjectsByLabel.add(
                    new DescribeSort(describeResult.getLabel(), describeResult)
                );
            }
            sortedSObjectsByName.sort();
            sortedSObjectsByLabel.sort();
        }

        public void prepareFieldDescribeListBySObjectName(String sObjectName) {
            sortedFieldsByName = new List<DescribeSort>();
            sortedFieldsByLabel = new List<DescribeSort>();
            for (SObjectField f : schemaMap.get(sObjectName).getDescribe().fields.getMap().values()) {
                DescribeFieldResult describeResult = f.getDescribe();
                Boolean isMasterDetailRelationship = describeResult.getRelationshipOrder() != null;
                if (describeResult.isAutoNumber()  || !describeResult.isUpdateable() && describeResult.getName() != 'Id' && describeResult.getName() != 'Name' && !isMasterDetailRelationship) {
                    continue;
                }
                sortedFieldsByName.add(
                    new DescribeSort(describeResult.getName(), describeResult)
                );
                sortedFieldsByLabel.add(
                    new DescribeSort(describeResult.getLabel(), describeResult)
                );
            }
            sortedFieldsByName.sort();
            sortedFieldsByLabel.sort();
        }
    }

    public class DescribeSort implements Comparable {
        public String sortValue;
        public DescribeSObjectResult descSObjectResult;
        public DescribeFieldResult descFieldResult;

        public DescribeSort(String sortValue, DescribeSObjectResult descSObjectResult) {
            this.sortValue = sortValue;
            this.descSObjectResult = descSObjectResult;
        }

        public DescribeSort(String sortValue, DescribeFieldResult descFieldResult) {
            this.sortValue = sortValue;
            this.descFieldResult = descFieldResult;
        }

        public Integer compareTo(Object compareTo) {
            DescribeSort compareToObj = (DescribeSort)compareTo;
            return sortValue.toLowerCase().compareTo(compareToObj.sortValue.toLowerCase());
        }
    }

    public class Field {
        public String fieldName                 { get; set; }
        public String fieldLabel                { get; set; }
        public Object value                     { get; set; }
        public DisplayType valueDisplayType     { get; set; }
        public Boolean isNillable               { get; set; }
        public Integer length                   { get; set; }

        public Field(String fieldName, String fieldLabel, Object value, DisplayType valueDisplayType, Boolean isNillable, Integer length) {
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.value = value;
            this.valueDisplayType = valueDisplayType;
            this.isNillable = isNillable;
            this.length = length;
        }

        public Object getCastValue() {
            DisplayType dt = valueDisplayType;
            if (dt == DisplayType.Boolean) {
                return Boolean.valueOf(value);
            } else if (dt == DisplayType.Integer) {
                return Integer.valueOf(value);
            } else if (dt == DisplayType.Double || dt == DisplayType.Percent || dt == DisplayType.Currency) {
                return Double.valueOf(value);
            } else if (dt == DisplayType.Date) {
                return Date.valueOf(String.valueOf(value) + ' 00:00:00'); // yyyy-MM-dd 00:00:00
            } else if (dt == DisplayType.DateTime) {
                return DateTime.valueOf(String.valueOf(value)); // yyyy-MM-dd HH:mm:ss
            } else {
                return value;
            }
        }

        public String getFieldLengthText() {
            Set<DisplayType> includedTypesSet = new Set<DisplayType>{
                DisplayType.String, DisplayType.TextArea
            };
            if (includedTypesSet.contains(valueDisplayType)) {
                return ' (' + length + ')';
            } else {
                return '';
            }
        }

        public String getDisplayTypeText() {
            return String.valueOf(valueDisplayType).toLowerCase().capitalize() + getFieldLengthText();
        }

        public Boolean getIsFieldRequired() {
            return !isNillable && valueDisplayType != DisplayType.Boolean && !fieldName.equalsIgnoreCase('OwnerId');
        }

        public Boolean getIsValueNotBlank() {
            return String.isNotBlank(String.valueOf(value));
        }
    }
}