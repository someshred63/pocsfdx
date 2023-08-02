public with sharing class HistoryItemWrapper extends EMS_Wrapper {
    public Object oldValue { get; set; }
    public Object newValue { get; set; }
    public String field { get; set; }
    public String modifiedBy { get; set; }
    public String modifiedByLink { get; set; }
    public Id modifiedById { get; set; }
    public String modificationDate { get; set; }
    public String actionValue { get; set; }
    public Datetime modificationDateTime { get; set; }

    // cache variables
    private static Map<String, Map<String, SObjectField>> fieldsMap = new Map<String, Map<String, SObjectField>>();
    private static Map<String, String> sObjectLabels = new Map<String, String>();
    private static Map<String, Schema.DescribeFieldResult> fieldDescribes = new Map<String, Schema.DescribeFieldResult>();

    public HistoryItemWrapper(String sObjectName, String recordName, Boolean isChild, Object oldValue, Object newValue, String field, String modifiedBy, Id modifiedById, Datetime modificationDate) {
        this.oldValue = oldValue;
        this.newValue = newValue;
        this.modifiedBy = modifiedBy;
        this.modifiedById = modifiedById;
        this.modificationDateTime = modificationDate;
        this.modifiedByLink = '/apex/EMS_User_Layout?id=' + modifiedById;
        this.modificationDate = modificationDate.format('M/d/yyyy hh:mm a', UserInfo.getTimeZone().getID());
        this.compareBy = 'modificationDate';
        this.ascending = false;

        if (!fieldsMap.containsKey(sObjectName)) {
            fieldsMap.put(sObjectName, Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap());
        }

        if (!sObjectLabels.containsKey(sObjectName)) {
            sObjectLabels.put(sObjectName, Schema.getGlobalDescribe().get(sObjectName).getDescribe().getLabel());
        }

        String sObjectLabel = sObjectLabels.get(sObjectName);

        Schema.DescribeFieldResult fieldDescribe;
        Schema.DisplayType fieldType;

        // Convert field nam to field label
        if (String.isNotEmpty(field) && !field.equalsIgnoreCase('created') && !field.equalsIgnoreCase('locked') && !field.equalsIgnoreCase('unlocked') && !field.equalsIgnoreCase('RecordType')) {
            if (!fieldDescribes.containsKey(field)) {
                fieldDescribes.put(field, fieldsMap.get(sObjectName).get(field).getDescribe());
            }

            fieldDescribe = fieldDescribes.get(field);

            fieldType = fieldDescribe.getType();
            this.field = fieldDescribe.getLabel();
        }

        if (sObjectLabel.startsWith('EMS ')) {
            sObjectLabel = sObjectLabel.removeStart('EMS ');
        }

        if (isChild && recordName != null) {
            actionValue = sObjectLabel + ' <b>' + recordName + '</b>: ';
        } else {
            actionValue = '';
        }

        if (String.isNotEmpty(field) && field.equalsIgnoreCase('created')) {
            actionValue += 'Created.';
        } else if (String.isNotEmpty(field) && field.equalsIgnoreCase('locked')) {
            actionValue += 'Locked.';
        } else if (String.isNotEmpty(field) && field.equalsIgnoreCase('unlocked')) {
            actionValue += 'Unlocked.';
        } else if (String.isNotEmpty(field) && field.equalsIgnoreCase('RecordType')) {
            actionValue += 'Changed <b>Record Type</b> from ' + getValue(this.oldValue, fieldType) + ' to <b>' + getValue(this.newValue, fieldType) + '</b>';
        } else if (newValue != null && oldValue != null) {
            actionValue += 'Changed <b>' + this.field + '</b> from ' + getValue(this.oldValue, fieldType) + ' to <b>' + getValue(this.newValue, fieldType) + '</b>';
        } else if (newValue != null && oldValue == null) {
            actionValue += 'Changed <b>' + this.field + '</b> to <b>' + getValue(this.newValue, fieldType) + '</b>';
        } else if (newValue == null && oldValue != null) {
            actionValue += 'Changed <b>' + this.field + '</b> from ' + getValue(this.oldValue, fieldType) + ' to <b>empty</b>';
        } else if (newValue == null && oldValue == null) {
            actionValue += 'Changed <b>' + this.field + '</b>.';
        }
    }

    public override Integer compareTo(Object compareTo) {
        if (compareBy == null || compareBy == '') {
            return 0;
        } else if (!ascending) {
            return compareToDescending(compareTo);
        } else {
            return compareToAscending(compareTo);
        }
    }

    public Integer compareToDescending(Object compareTo) {
        HistoryItemWrapper wrapper = (HistoryItemWrapper) compareTo;
        if (compareBy == 'modifiedBy') {
            if (wrapper.modifiedBy == this.modifiedBy) return 0;
            if (wrapper.modifiedBy > this.modifiedBy) return 1;
        } else if (compareBy == 'modificationDate') {
            if (wrapper.modificationDateTime == this.modificationDateTime) {
                return 0;
            } else if (wrapper.modificationDateTime > this.modificationDateTime) {
                return 1;
            }
        } else if (compareBy == 'actionValue') {
            if (wrapper.actionValue == this.actionValue) return 0;
            if (wrapper.actionValue > this.actionValue) return 1;
        }
        return -1;
    }

    public Integer compareToAscending(Object compareTo) {
        HistoryItemWrapper wrapper = (HistoryItemWrapper) compareTo;
        if (compareBy == 'modifiedBy') {
            if (wrapper.modifiedBy == this.modifiedBy) return 0;
            if (wrapper.modifiedBy > this.modifiedBy) return -1;
        } else if (compareBy == 'modificationDate') {
            if (wrapper.modificationDateTime == this.modificationDateTime) {
                return 0;
            } else if (wrapper.modificationDateTime > this.modificationDateTime) {
                return -1;
            }
        } else if (compareBy == 'actionValue') {
            if (wrapper.actionValue == this.actionValue) return 0;
            if (wrapper.actionValue > this.actionValue) return -1;
        }
        return 1;
    }

    private String getValue(Object value, Schema.DisplayType fieldType) {
        String result;

        if (fieldType == Schema.DisplayType.DATE) {
            result = ((Date) value).format();
        } else if (fieldType == Schema.DisplayType.DATETIME) {
            result = ((DateTime) value).format('M/d/yyyy hh:mm a', UserInfo.getTimeZone().getID());
        } else if (fieldType == Schema.DisplayType.CURRENCY) {
            Decimal currencyValue = Decimal.valueOf((String) value);
            result = '$' + EMS_Util.currency(currencyValue);
        } else {
            result = String.valueOf(value);
        }

        return result;
    }
}