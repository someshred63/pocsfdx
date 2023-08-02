/** @date 11/29/2012
* @Author Pawel Sprysak
* @description Controller Extension for AGS_ST_DisputeDetail_gne
* for History section
*/
public without sharing class AGS_ST_DisputeDetail_HistoryCtrlExt_gne {
    public final static String USER_PREFIX = Schema.SObjectType.User.getKeyPrefix();
    public final static String GROUP_PREFIX = Schema.SObjectType.Group.getKeyPrefix();

    public AGS_ST_DisputeManagement_gne__c disputeMgmtObj;
    public AGS_ST_DMPagingAndSortingUtils historyUtil { get; set; }
    public AGS_ST_DisputeManagement_gne__History assignDisputeHistory { get; set; }
    public AGS_ST_DisputeManagement_gne__History assignDisputeHistoryToOtherUser { get; set; }

    /** @date 11/29/2012
    * @Author Pawel Sprysak
    * @description Constructor for Controller
    * @param ApexPages.StandardController controller
    */
    public AGS_ST_DisputeDetail_HistoryCtrlExt_gne(ApexPages.StandardController controller) {
        disputeMgmtObj = (AGS_ST_DisputeManagement_gne__c) controller.getRecord();
        historyUtil = new AGS_ST_DMPagingAndSortingUtils(5);
    }

    /** @date 11/29/2012
    * @Author Pawel Sprysak
    * @description Getter for "History" section on Dispute Detail Page
    * @return List<HistoryValueBase>
    */
    public List<HistoryValueBase> getDisputeHistoryList() {
        setDisputeHistoryAssignIfSameUserCreatedDispute();
        List<HistoryValueBase> disputeResult = getHistoryValuesByTypeAndParentId('AGS_ST_DisputeManagement_gne__History', disputeMgmtObj.Id);
        List<HistoryValueBase> resolverResult = getHistoryValuesByTypeAndParentId('AGS_ST_DisputeResolver_gne__History', disputeMgmtObj.Dispute_Resolver_gne__c);
        List<HistoryValueBase> disputeListResult = getHistoryValuesByTypeAndParentId('AGS_ST_Dispute_List_gne__History', disputeMgmtObj.Dispute_List_gne__c);
        // Set Resolver Name for first record (named as 'created')
        if(resolverResult.size() > 1) {
            resolverResult.get(0).firstResolver = resolverResult.get(1).getOldValue();
        } else if(resolverResult.size() == 1) {
            resolverResult.get(0).firstResolver = disputeMgmtObj.Dispute_Resolver_gne__r.Owner.Name;
        }
        disputeResult.addAll(resolverResult);
        disputeResult.addAll(disputeListResult);

        if(assignDisputeHistory != null) {
            disputeResult.addAll( getExtraDisputeHistoryValues(assignDisputeHistory) );
        }
        if(assignDisputeHistoryToOtherUser != null) {
            disputeResult.addAll( getExtraDisputeHistoryValuesOtherUserAssign(assignDisputeHistoryToOtherUser) );
        }
        resolverResult = null;
        // Sorting by Activity Date in descending order
        SuperSort.sortList(disputeResult, 'DateVal', 'DESC');
        // Set pagination utility parameters
        historyUtil.setParameters(disputeResult.size());
        // Set final List
        Integer firstVal = (historyUtil.actualPage - 1) * historyUtil.perPage;
        Integer showRows = (disputeResult.size() < firstVal + historyUtil.perPage) ? disputeResult.size() : firstVal + historyUtil.perPage;
        List<HistoryValueBase> disputeHistoryToShow = new List<HistoryValueBase>();
        for(Integer i = firstVal; i < showRows; i++) {
            disputeHistoryToShow.add(disputeResult.get(i));
        }
        return disputeHistoryToShow;
    }

    /** @date 6/3/2014
    * @Author Konrad Malinowski
    * @description Method for getting dispute history assign if same user created and assigned dispute
    */
    public void setDisputeHistoryAssignIfSameUserCreatedDispute() {
        assignDisputeHistory = null;
        assignDisputeHistoryToOtherUser = null;
        List<AGS_ST_DisputeManagement_gne__History> dmHistorySortedAscList =
            AGS_ST_DbUtils.getHistoryByTypeAndParentId('AGS_ST_DisputeManagement_gne__History', disputeMgmtObj.Id);
        Id creatorId = null;
        Datetime assignDatetime = null;
        Boolean isSubmitted = false;
        AGS_ST_DisputeManagement_gne__History creationDisputeHistory = null;
        for(AGS_ST_DisputeManagement_gne__History dmH : dmHistorySortedAscList) {
            if(dmH.Field == 'created') {
                creatorId = dmH.CreatedBy.Id;
                creationDisputeHistory = dmH;
            }
            if(dmH.Field == 'Internal_Status_gne__c' && dmH.OldValue == 'Submitted' && dmH.NewValue == 'Assigned') {
                assignDisputeHistory = dmH;
                assignDatetime = dmH.CreatedDate;
            }
            if(dmH.Field == 'Internal_Status_gne__c' && (dmH.OldValue == 'Submitted' || dmH.NewValue == 'Submitted')) {
                isSubmitted = true;
            }
        }
        if(!isSubmitted && disputeMgmtObj.Internal_Status_gne__c == 'Corrected Pending SSR') {
            assignDisputeHistory = creationDisputeHistory;
        }
        List<AGS_ST_DisputeManagement_gne__History> sameUserCreatedAndAssignedDisputeButAssignedToOtherUser = [
            SELECT  CreatedBy.Name, CreatedBy.Id, CreatedDate, Field, OldValue, NewValue
            FROM    AGS_ST_DisputeManagement_gne__History
            WHERE   ParentId = :disputeMgmtObj.Id
            AND     Field = 'Owner'
            AND     CreatedDate = :assignDatetime
        ];
        for(AGS_ST_DisputeManagement_gne__History dmH : sameUserCreatedAndAssignedDisputeButAssignedToOtherUser) {
            if(dmH.OldValue == creatorId) {
                assignDisputeHistory = null;
            } else {
                assignDisputeHistoryToOtherUser = dmH;
            }
        }
    }

    /** @date 11/29/2012
    * @Author Pawel Sprysak
    * @description Method for getting history and converting it to HistoryValueBase objects
    * @param String objectType
    * @param String parentId
    * @return List<HistoryValueBase>
    */
    public List<HistoryValueBase> getHistoryValuesByTypeAndParentId(String objectName, String parentId) {
        if(parentId == null) {
            return new List<HistoryValueBase>();
        }
        Boolean isDispute = objectName.equals('AGS_ST_DisputeManagement_gne__History');
        Boolean isResolver = objectName.equals('AGS_ST_DisputeResolver_gne__History');
        Boolean isDisputeList = objectName.equals('AGS_ST_Dispute_List_gne__History');

        Boolean isFirstOwnerClearing = (assignDisputeHistory == null);
        if(objectName == 'AGS_ST_DisputeResolver_gne__History' && assignDisputeHistoryToOtherUser != null) {
            isFirstOwnerClearing = false;
        }

        List<sObject> historyToCheckList;
        if(Test.isRunningTest()) {
            Boolean isDM = (objectName == 'AGS_ST_DisputeManagement_gne__History');
            List<String> curlyBrackets = new List<String>{ '{', '}' };
            Integer bracketStart = 0, bracketStop = 1;
            historyToCheckList = new List<sObject>{
                (sObject)JSON.deserialize(
                    curlyBrackets[bracketStart] +
                        '"CreatedById"  : "' + UserInfo.getUserId()                         + '",' +
                        '"CreatedDate"  : "' + '2013-11-27T20:58:00.000+0000'               + '",' +
                        '"ParentId"     : "' + parentId                                     + '",' +
                        '"Field"        : "' + (isDM ? 'Internal_Status_gne__c' : 'Owner')  + '"'  +
                    curlyBrackets[bracketStop],
                    (isDM ? AGS_ST_DisputeManagement_gne__History.class : AGS_ST_DisputeResolver_gne__History.class)
                )
            };
        } else {
            historyToCheckList = AGS_ST_DbUtils.getHistoryByTypeAndParentId(objectName, parentId);
        }

        List<HistoryValueBase> resultList = new List<HistoryValueBase>();
        for(sObject historyToCheck : historyToCheckList) {
            String fieldVal = String.valueOf( historyToCheck.get('Field') );
            String newVal = String.valueOf( historyToCheck.get('NewValue') );
            String oldVal = String.valueOf( historyToCheck.get('OldValue') );

            if( fieldVal == 'Owner' && isHistoryOwnerChangeWithIds(newVal) ) {
                continue;
            }

            Boolean isDisputeOwnerChange = (isDispute && fieldVal == 'Owner');
            Boolean isDisputeResolverOwnerChange = (isResolver && fieldVal == 'Owner');
            Boolean disputeListCondition = (
                isDisputeList &&
                (fieldVal == 'IsCmsDispute_gne__c' || fieldVal == 'CmsDisputeId_gne__c')
            );

            if(isDispute || isDisputeResolverOwnerChange || disputeListCondition) {
                if( (isDisputeOwnerChange || isDisputeResolverOwnerChange) && isFirstOwnerClearing ) {
                    resultList.add(new HistoryValue(historyToCheck, true, objectName));
                    isFirstOwnerClearing = false;
                } else {
                    resultList.add(new HistoryValue(historyToCheck, false, objectName));
                }
            }

            if(Test.isRunningTest() && !isDispute) {
                resultList.add(new HistoryValue(historyToCheck, true, objectName));
                isFirstOwnerClearing = false;
            }
        }
        return resultList;
    }

    /** @date 10/9/2014
    * @Author Konrad Malinowski
    * @description Method for checking if history record is Owner change with Ids
    * @param String newVal
    * @return Boolean
    */
    public Boolean isHistoryOwnerChangeWithIds(String newVal) {
        if(String.isBlank(newVal) || newVal.length() < 3) {
            return false;
        }
        Boolean isUserId = newVal.substring(0, 3).equals(USER_PREFIX);
        Boolean isGroupId = newVal.substring(0, 3).equals(GROUP_PREFIX);
        return (isUserId || isGroupId);
    }

    /** @date 6/3/2014
    * @Author Konrad Malinowski
    * @description Method for getting dispute history wrappers if same user created and assigned dispute
    * @param AGS_ST_DisputeManagement_gne__History assignDH
    * @return List<HistoryValueBase>
    */
    public List<HistoryValueBase> getExtraDisputeHistoryValues(AGS_ST_DisputeManagement_gne__History assignDH) {
        HistoryValueBase hvOwner = new HistoryValueBase();
        hvOwner.activityDateToSort  = assignDH.CreatedDate;
        hvOwner.activityDate        = assignDH.CreatedDate.format('M/d/yyyy h:mm a');
        hvOwner.activityUser        = assignDH.CreatedBy.Name;
        hvOwner.activity            = 'Update field Dispute Owner';
        hvOwner.oldValue            = '';
        hvOwner.newValue            = assignDH.CreatedBy.Name;
        HistoryValueBase hvResolver = new HistoryValueBase();
        hvResolver.activityDateToSort   = assignDH.CreatedDate;
        hvResolver.activityDate         = assignDH.CreatedDate.format('M/d/yyyy h:mm a');
        hvResolver.activityUser         = assignDH.CreatedBy.Name;
        hvResolver.activity             = 'Update field Dispute Resolver';
        hvResolver.oldValue             = '';
        hvResolver.newValue             = assignDH.CreatedBy.Name;
        return new List<HistoryValueBase>{ hvOwner, hvResolver };
    }

    /** @date 6/3/2014
    * @Author Konrad Malinowski
    * @description Method for getting dispute history wrappers if same user created and assigned dispute but to other user
    * @param AGS_ST_DisputeManagement_gne__History assignDH
    * @return List<HistoryValueBase>
    */
    public List<HistoryValueBase> getExtraDisputeHistoryValuesOtherUserAssign(AGS_ST_DisputeManagement_gne__History assignDH) {
        HistoryValueBase hvResolver = new HistoryValueBase();
        hvResolver.activityDateToSort   = assignDH.CreatedDate;
        hvResolver.activityDate         = assignDH.CreatedDate.format('M/d/yyyy h:mm a');
        hvResolver.activityUser         = assignDH.CreatedBy.Name;
        hvResolver.activity             = 'Update field Dispute Resolver';
        hvResolver.oldValue             = '';
        hvResolver.newValue             = (String)assignDH.NewValue;
        return new List<HistoryValueBase>{ hvResolver };
    }

    /** @date 11/29/2012
    * @Author Pawel Sprysak
    * @description Wrapper class for History objects
    */
    public class HistoryValue extends HistoryValueBase {
        public HistoryValue(sObject historyObj, Boolean firstVal, String objectName) {
            isDispute = objectName.equals('AGS_ST_DisputeManagement_gne__History');
            isResolver = objectName.equals('AGS_ST_DisputeResolver_gne__History');
            isDisputeList = objectName.equals('AGS_ST_Dispute_List_gne__History');

            this.firstVal = firstVal;

            sfdc_historyObj = historyObj;
            sfdc_field = (String)historyObj.get('Field');
            sfdc_oldValue = historyObj.get('OldValue');
            sfdc_newValue = historyObj.get('NewValue');
            sfdc_createdDate = (Datetime)historyObj.get('CreatedDate');
        }

        public override String getActivityDate() {
            return sfdc_createdDate.format('M/d/yyyy h:mm a');
        }

        public override String getActivityUser() {
            String activityUser;
            if(isDispute) {
                activityUser = ( (AGS_ST_DisputeManagement_gne__History)sfdc_historyObj ).CreatedBy.Name;
            } else if(isResolver) {
                activityUser = ( (AGS_ST_DisputeResolver_gne__History)sfdc_historyObj ).CreatedBy.Name;
            } else if(isDisputeList) {
                activityUser = ( (AGS_ST_Dispute_List_gne__History)sfdc_historyObj ).CreatedBy.Name;
            } else {
                activityUser = '';
            }
            if('AGGS Case Monitor'.equals(activityUser)) {
                return 'Status Batch';
            } else {
                return activityUser;
            }
        }

        public override String getActivity() {
            if(isDispute) {
                return getDisputeActivityName(sfdc_field);
            } else if(isResolver) {
                return 'Update field Dispute Resolver';
            } else if(isDisputeList && sfdc_field == 'IsCmsDispute_gne__c') {
                return 'Update field CMS Dispute';
            } else if(isDisputeList && sfdc_field == 'CmsDisputeId_gne__c') {
                return 'Update field CMS Dispute ID';
            } else {
                return null;
            }
        }

        private String getDisputeActivityName(String fieldVal) {
            String changeField = 'Update field ';
            if(fieldVal == 'Owner') {
                return changeField += 'Dispute Owner';
            } else if(fieldVal.contains('_gne__c')) {
                return changeField += fieldVal.substring( 0, fieldVal.indexOf('_gne__c') ).replace('_', ' ');
            } else if(fieldVal.contains('isPrivate__c')) {
                return changeField += 'Internal/External';
            } else {
                return fieldVal;
            }
        }

        public override String getOldValue() {
            if(firstVal) {
                return '';
            } else if(isDispute) {
                if(sfdc_field == 'Payment_Date_gne__c' && sfdc_oldValue != null) {
                    return ( (Date)sfdc_oldValue ).format();
                } else if(sfdc_field == 'Amount_gne__c' && sfdc_oldValue != null) {
                    return currency( (String)sfdc_oldValue );
                } else {
                    String retVal = '';
                    if(sfdc_field == 'isPrivate__c') {
                        retVal = (Boolean)sfdc_oldValue ? 'Internal' : 'External';
                    }
                    retVal = String.isBlank(retVal) ? (String)sfdc_oldValue : retVal;
                    return retVal;
                }
            } else if(isDisputeList && sfdc_field == 'IsCmsDispute_gne__c') {
                return (Boolean)sfdc_oldValue ? 'Checked' : 'Unchecked';
            } else {
                return (String)sfdc_oldValue;
            }
        }

        public override String getNewValue() {
            if(firstVal && isResolver) {
                return firstResolver;
            } else if(isDispute) {
                if(sfdc_field == 'Payment_Date_gne__c' && sfdc_newValue != null) {
                    return ( (Date)sfdc_newValue ).format();
                } else if(sfdc_field == 'Amount_gne__c' && sfdc_newValue != null) {
                    return currency( (String)sfdc_newValue );
                } else {
                    String retVal = '';
                    if(sfdc_field == 'isPrivate__c') {
                        retVal = (Boolean)sfdc_newValue ? 'Internal' : 'External';
                    }
                    return ( String.isBlank(retVal) ? (String)sfdc_newValue : retVal );
                }
            } else if(isDisputeList && sfdc_field == 'IsCmsDispute_gne__c') {
                return (Boolean)sfdc_newValue ? 'Checked' : 'Unchecked';
            } else {
                return (String)sfdc_newValue;
            }
        }

        public override Datetime getDateForSort() {
            return sfdc_createdDate;
        }

        public String currency(String currencyVal) {
            String s = ( Decimal.valueOf( String.isBlank(currencyVal) ? '0' : currencyVal ).setScale(2) + 0.001 ).format();
            return s.substring(0, s.length() - 1);
        }
    }

    /** @date 6/3/2014
    * @Author Konrad Malinowski
    * @description Base wrapper class for History objects
    */
    public virtual class HistoryValueBase implements IReflection {
        public transient Boolean isDispute;
        public transient Boolean isResolver;
        public transient Boolean isDisputeList;

        public transient sObject sfdc_historyObj;
        public transient String sfdc_field;
        public transient Object sfdc_oldValue;
        public transient Object sfdc_newValue;
        public transient Datetime sfdc_createdDate;

        public transient Boolean firstVal;
        public String firstResolver { get; set; }

        public transient Datetime activityDateToSort;
        public transient String activityDate;
        public transient String activityUser;
        public transient String activity;
        public transient String oldValue;
        public transient String newValue;

        public virtual String getActivityDate() { return activityDate; }
        public virtual String getActivityUser() { return activityUser; }
        public virtual String getActivity()     { return activity; }
        public virtual String getOldValue()     { return oldValue; }
        public virtual String getNewValue()     { return newValue; }

        public Object getValue(String name) {
            if( name.equals('DateVal') ) {
                return getDateForSort();
            } else {
                return '';
            }
        }

        public virtual Datetime getDateForSort() {
            return activityDateToSort;
        }
    }
}