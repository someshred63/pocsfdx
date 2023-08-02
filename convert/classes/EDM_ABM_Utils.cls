public without sharing class EDM_ABM_Utils {
    public class EDM_ABMShareException extends Exception {}
    public class EDM_ABMFieldLengthException extends Exception {}

    public static final String ABLEAD = 'EDM_ABM_AB_Lead_no_license';
    public static final String ABAPPROVER = 'EDM_AB_Approver';
    public static final String ABAPPROVER_NO_LIC = 'EDM_AB_Approver_no_license';
    public static final String ABREVIEWER = 'EDM_AB_Reviewer';
    public static final String ABREVIEWER_NO_LIC = 'EDM_AB_Reviewer_no_license';
    public static final String ABS = 'EDM_ABS_Manager';
    public static final String VDST_ABM = 'EDM_VDST_Partner_External_ABM';

    public static final String AL_EDIT = 'Edit';
    public static final String AL_READ = 'Read';

    public static final String SHARE_DIRECT = 'EDM_DirectShare__c';
    public static final String SHARE_PARENT = 'EDM_ParentShare__c';
    public static final String SHARE_DIRECTCHILD = 'EDM_DirectChildShare__c';

    public static final String GROUP_2_UNIT_MAPPING = 'EDM_Group_2_Unit_Mapping';
    public static final String UNIT_2_TEAM_MAPPING = 'EDM_Unit_2_Team_Mapping';

    public static List<VDST_EventProvider_gne__c> eventProviders;

    public static void shareRecord(Id recordId, List<User> shareWithList, String accessLevel, String reason) {
        String objectName = recordId.getSObjectType().getDescribe().getName();
        if (accessLevel != AL_EDIT && accessLevel != AL_READ) {
            throw new EDM_ABMShareException('Unsuppor ted access level. Use Read or Edit.');
        }

        if (objectName == 'EDM_AABP_gne__c') {
            shareAABPRecord(recordId, shareWithList, accessLevel, reason);
        } else if (objectName == 'EDM_IABP_gne__c') {
            shareIABPRecord(recordId, shareWithList, accessLevel, reason);
        } 
        else {
            throw new EDM_ABMShareException('Unsupported object type.');
        }
    }

    private static void shareAABPRecord(Id recordId, List<User> shareWithList, String accessLevel, String reason) {
        if (reason != SHARE_DIRECT && reason != SHARE_PARENT) {
            throw new EDM_ABMShareException('Unsupported share reason for AABP. Use EDM_DirectShare__c or EDM_ParentShare__c.');
        }

        List<EDM_IABP_gne__c> iabps = [SELECT Id, EDM_Joint_AABP_gne__c FROM EDM_IABP_gne__c WHERE EDM_Parent_AABP_gne__c = :recordId];
        Map<Id, List<User>> usersOnJointsByIABP = new Map<Id, List<User>>();

        List<User> usersToShareWith = new List<User>();
        usersToShareWith.addAll(shareWithList);
        if (reason == SHARE_DIRECT) {
            usersOnJointsByIABP = getUsersFromJointsByIABP(iabps, shareWithList);
            usersToShareWith.addAll(getUniqueUserListFromMap(usersOnJointsByIABP));
        }

        List<EDM_AABP_gne__Share> aabpShareList = new List<EDM_AABP_gne__Share>();
        for(User uShare : usersToShareWith) {
            if (uShare.IsActive) {
                EDM_AABP_gne__Share aabpShare = new EDM_AABP_gne__Share();
                aabpShare.ParentId = recordId;
                aabpShare.UserOrGroupId = uShare.Id;
                aabpShare.AccessLevel = accessLevel;
                aabpShare.RowCause = reason;
                aabpShareList.add(aabpShare);
            }
        }
        System.debug('SHARING AABP: ' + aabpShareList);
        insert aabpShareList;

        List<EDM_IABP_gne__Share> childIabpsShares = new List<EDM_IABP_gne__Share>();
        for (EDM_IABP_gne__c iabp : iabps) {
            if (reason == SHARE_DIRECT) { //if AABP shared manually -> share also child IABP 
                List<User> shareWithListWithJoints = usersOnJointsByIABP.get(iabp.Id);
                shareWithListWithJoints.addAll(shareWithList);
                childIabpsShares.addAll(createChildIabpShares(iabp.Id, shareWithListWithJoints, AL_EDIT, SHARE_DIRECTCHILD));
            }
        }
        insert childIabpsShares;
    }

    private static List<User> getUniqueUserListFromMap(Map<Id, List<User>> usersByIABP) {
        List<User> results = new List<User>();
        Set<Id> used = new Set<Id>();
        for (List<User> userList : usersByIABP.values()) {
            for (User u : userList) {
                if (!used.contains(u.Id)) {
                    used.add(u.Id);
                    results.add(u);
                }
            }
        }

        return results;
    }

    private static void shareIABPRecord(Id recordId, List<User> shareWithList, String accessLevel, String reason) {
        if (reason != SHARE_DIRECT && reason != SHARE_DIRECTCHILD) {
            throw new EDM_ABMShareException('Unsupported share reason for IABP. Use EDM_DirectShare__c or EDM_DirectChildShare__c.');
        }

        List<EDM_IABP_gne__Share> iabpShareList = new List<EDM_IABP_gne__Share>();
        for(User uShare : shareWithList) {
            if (uShare.IsActive) {
                EDM_IABP_gne__Share iabpShare = new EDM_IABP_gne__Share();
                iabpShare.ParentId = recordId;
                iabpShare.UserOrGroupId = uShare.Id;
                iabpShare.AccessLevel = accessLevel;
                iabpShare.RowCause = reason;
                iabpShareList.add(iabpShare);
            }
        }
        System.debug('SHARING IABP: ' + iabpShareList);
        insert iabpShareList;

        //if IABP shared manually -> share also parent AABP
        if (reason == SHARE_DIRECT) {
            Id parentId = [SELECT EDM_Parent_AABP_gne__c FROM EDM_IABP_gne__c WHERE Id = :recordId].EDM_Parent_AABP_gne__c;
            shareAABPRecord(parentId, shareWithList, AL_READ, SHARE_PARENT);
        }
    }

    private static List<EDM_IABP_gne__Share> createChildIabpShares(Id recordId, List<User> shareWithList, String accessLevel, String reason) {
        if (reason != SHARE_DIRECT && reason != SHARE_DIRECTCHILD) {
            throw new EDM_ABMShareException('Unsupported share reason for IABP. Use EDM_DirectShare__c or EDM_DirectChildShare__c.');
        }

        List<EDM_IABP_gne__Share> iabpShareList = new List<EDM_IABP_gne__Share>();
        for(User uShare : shareWithList) {
            if (uShare.IsActive) {
                EDM_IABP_gne__Share iabpShare = new EDM_IABP_gne__Share();
                iabpShare.ParentId = recordId;
                iabpShare.UserOrGroupId = uShare.Id;
                iabpShare.AccessLevel = accessLevel;
                iabpShare.RowCause = reason;
                iabpShareList.add(iabpShare);
            }
        }
        System.debug('SHARING IABP: ' + iabpShareList);
        
        return iabpShareList;        
    }

    private static Map<Id, List<User>> getUsersFromJointsByIABP(List<EDM_IABP_gne__c> iabps, List<User> doNotIncludeUsers) {
        Map<Id, Set<Id>> userIdsByIABPId = new Map<Id, Set<Id>>();
        Map<Id, EDM_AABP_gne__c> jointAABPsByAabpId = getJointAABPsFor(iabps);

        for (EDM_IABP_gne__c iabp : iabps) {
            userIdsByIABPId.put(iabp.Id, new Set<Id>());
            for (String aabpId : splitJointAABPsToIds(iabp)) {
                EDM_AABP_gne__c aabp = jointAABPsByAabpId.get(aabpId);
                if (aabp != null) {
                    userIdsByIABPId.get(iabp.Id).add(aabp.EDM_AB_Lead_gne__c);
                    userIdsByIABPId.get(iabp.Id).add(aabp.EDM_Vendor_Lead_gne__c);
                }
            }

            for (User u : doNotIncludeUsers) {
                userIdsByIABPId.get(iabp.Id).remove(u.Id);
            }

            userIdsByIABPId.get(iabp.Id).remove(null);
        }

        return convertResultsFromIdsToUsers(userIdsByIABPId);
    }

    private static Map<Id, EDM_AABP_gne__c> getJointAABPsFor(List<EDM_IABP_gne__c> iabps) {
        Set<String> jointAABPs = new Set<String>();

        for (EDM_IABP_gne__c iabp : iabps) {
            jointAABPs.addAll(splitJointAABPsToIds(iabp));
        }
        Map<Id, EDM_AABP_gne__c> jointAABPsByAabpId = new Map<Id, EDM_AABP_gne__c>(
                [SELECT Id, EDM_AB_Lead_gne__c, EDM_Vendor_Lead_gne__c
                        FROM EDM_AABP_gne__c 
                        WHERE Id IN :jointAABPs]);

        return jointAABPsByAabpId;
    }

    public static List<String> splitJointAABPsToIds(EDM_IABP_gne__c iabp) {
        List<String> jointAABPsIds = new List<String>();
        if (String.isNotBlank(iabp.EDM_Joint_AABP_gne__c)) {
            jointAABPsIds = iabp.EDM_Joint_AABP_gne__c.split(',');
        }
        return jointAABPsIds;
    }

    private static Map<Id, List<User>> convertResultsFromIdsToUsers(Map<Id, Set<Id>> userIdsByIABPId) {
        Map<Id, List<User>> usersByIABPId = new Map<Id, List<User>>();
        List<Set<Id>> usersIdsSets = userIdsByIABPId.values();
        Set<Id> userIds = new Set<Id>();
        for (Set<Id> userIdSet : usersIdsSets) {
            userIds.addAll(userIdSet);
        }
        Map<Id, User> usersById = new Map<Id, User>(getUsers(userIds));
        for (Id iabpId : userIdsByIABPId.keySet()) {
            usersByIABPId.put(iabpId, new List<User>());
            for (Id userId : userIdsByIABPId.get(iabpId)) {
                usersByIABPId.get(iabpId).add(usersById.get(userId));
            }
        }

        return usersByIABPId;
    }

    public static void unShareRecord(Set<Id> recordIds, List<User> unShareWith, String reason) {
        if (unShareWith.isEmpty()) {
            return;
        }

        Id firstRecordId;
        for(Id recordId : recordIds) {
            firstRecordId = recordId;
            break;
        }
        String objectName = firstRecordId.getSObjectType().getDescribe().getName();

        if(objectName == 'EDM_AABP_gne__c') {
            List<EDM_AABP_gne__Share> aabpSharesToDel = new List<EDM_AABP_gne__Share>();
            if (reason == SHARE_DIRECT) {

                aabpSharesToDel.addAll([SELECT Id FROM EDM_AABP_gne__Share 
                                        WHERE ParentId IN :recordIds
                                            AND RowCause = :reason
                                            AND UserOrGroupId IN :unShareWith]);

                System.debug('UNSHARING AABP: ' + aabpSharesToDel);
                delete aabpSharesToDel;

                Set<Id> childIds = (new Map<Id,EDM_IABP_gne__c>([SELECT Id FROM EDM_IABP_gne__c WHERE EDM_Parent_AABP_gne__c = :recordIds])).keySet();

                unShareRecord(childIds, unShareWith, SHARE_DIRECTCHILD);
            }
            else if (reason == SHARE_PARENT) {
                Set<Id> childIds = (new Map<Id,EDM_IABP_gne__c>([SELECT Id FROM EDM_IABP_gne__c WHERE EDM_Parent_AABP_gne__c = :recordIds])).keySet();

                aabpSharesToDel.addAll([SELECT Id FROM EDM_AABP_gne__Share 
                                        WHERE ParentId IN :recordIds
                                            AND RowCause = :reason
                                            AND UserOrGroupId IN :unShareWith]);
                System.debug('UNSHARING AABP: ' + aabpSharesToDel);
                delete aabpSharesToDel;
            }
            else {
                throw new EDM_ABMShareException('Unsupported share reason for AABP. Use EDM_DirectShare__c or EDM_ParentShare__c.');
            }
        }
        else if (objectName == 'EDM_IABP_gne__c') {
            if (reason == SHARE_DIRECT || reason == SHARE_DIRECTCHILD) {
                List<EDM_IABP_gne__Share> iabpSharesToDel = new List<EDM_IABP_gne__Share>();
                iabpSharesToDel.addAll([SELECT Id FROM EDM_IABP_gne__Share 
                                        WHERE ParentId IN :recordIds
                                            AND RowCause = :reason
                                            AND UserOrGroupId IN :unShareWith]);
                System.debug('UNSHARING IABP: ' + iabpSharesToDel);
                delete iabpSharesToDel;
            }
            else {
                throw new EDM_ABMShareException('Unsupported share reason for IABP. Use EDM_DirectShare__c, EDM_DirectChildShare__c.');
            }
        }
        else {
            throw new EDM_ABMShareException('Unsupported object type.');
        }
    }

    public static List<User> getSharedWithUsers(Id recordId, String userRole, String reason) {
        String objectName;
        if (recordId != null) {
            objectName = recordId.getSObjectType().getDescribe().getName();
        }

        List<User> uShared = new List<User>();
        if (objectName == 'EDM_IABP_gne__c') {
            if (userRole == ABS) {
                Set<Id> uIds = new Set<id>();
                List<User> usrs = getUsersForRoles(new List<String> { ABLEAD, ABAPPROVER, ABAPPROVER_NO_LIC, ABREVIEWER, ABREVIEWER_NO_LIC, VDST_ABM }); 
                for (User u : usrs) {
                    uIds.add(u.id);
                }
                uShared.addAll([SELECT Id, Name, IsActive FROM User WHERE Id IN (SELECT UserOrGroupId FROM EDM_IABP_gne__Share WHERE ParentId = :recordId AND RowCause = :reason)
                                                                AND Id IN :uIds]);
            }
            else if (userRole == ABLEAD || userRole == VDST_ABM) {
                Set<Id> uIds = new Set<id>();
                List<User> usrs = getUsersForRoles(new List<String> { ABLEAD, VDST_ABM });
                for (User u : usrs) {
                    uIds.add(u.id);
                }
                uShared.addAll([SELECT Id, Name, IsActive FROM User WHERE Id IN (SELECT UserOrGroupId FROM EDM_IABP_gne__Share WHERE ParentId = :recordId AND RowCause = :reason)
                                                                AND Id IN :uIds]);
            }
            
        }
        else if(objectName == 'EDM_AABP_gne__c') {
            if (userRole == ABS) {
                Set<Id> uIds = new Set<id>();
                List<User> usrs = getUsersForRoles(new List<String> { ABLEAD, ABAPPROVER, ABAPPROVER_NO_LIC, ABREVIEWER, ABREVIEWER_NO_LIC, VDST_ABM });
                for (User u : usrs) {
                    uIds.add(u.id);
                }
                uShared.addAll([SELECT Id, Name, IsActive FROM User WHERE Id IN (SELECT UserOrGroupId FROM EDM_AABP_gne__Share WHERE ParentId = :recordId AND RowCause = :reason)
                                                                AND Id IN :uIds]);
            }
            else if (userRole == ABLEAD || userRole == VDST_ABM) {
                Set<Id> uIds = new Set<id>();
                List<User> usrs = getUsersForRoles(new List<String> { ABLEAD, VDST_ABM });
                for (User u : usrs) {
                    uIds.add(u.id);
                }
                uShared.addAll([SELECT Id, Name, IsActive FROM User WHERE Id IN (SELECT UserOrGroupId FROM EDM_AABP_gne__Share WHERE ParentId = :recordId AND RowCause = :reason)
                                                                AND Id IN :uIds]);
            }
        }
        return uShared;
    }

    public static List<User> getSharedWithUsers(Id recordId, String userRole) {
        String objectName = '';
        if (recordId != null) {
            objectName = recordId.getSObjectType().getDescribe().getName();
        }

        List<User> uShared = new List<User>();
        if (objectName == 'EDM_IABP_gne__c') {
            if (userRole == ABS) {
                Set<Id> uIds = new Set<id>();
                List<User> usrs = getUsersForRoles(new List<String> { ABLEAD, ABAPPROVER, ABAPPROVER_NO_LIC, ABREVIEWER, ABREVIEWER_NO_LIC, VDST_ABM });

                for (User u : usrs) {
                    uIds.add(u.id);
                }
                uShared.addAll([SELECT Id, Name, IsActive FROM User WHERE Id IN (SELECT UserOrGroupId FROM EDM_IABP_gne__Share WHERE ParentId = :recordId)
                                                                AND Id IN :uIds]);
            }
            else if (userRole == ABLEAD || userRole == VDST_ABM) {
                Set<Id> uIds = new Set<id>();
                List<User> usrs = getUsersForRoles(new List<String> { ABLEAD, VDST_ABM });
                for (User u : usrs) {
                    uIds.add(u.id);
                }
                uShared.addAll([SELECT Id, Name FROM User WHERE Id IN (SELECT UserOrGroupId FROM EDM_IABP_gne__Share WHERE ParentId = :recordId)
                                                                AND Id IN :uIds]);
            }
            
        }
        else if(objectName == 'EDM_AABP_gne__c') {
            if (userRole == ABS) {
                Set<Id> uIds = new Set<id>();
                List<User> usrs = getUsersForRoles(new List<String> { ABLEAD, ABAPPROVER, ABAPPROVER_NO_LIC, ABREVIEWER, ABREVIEWER_NO_LIC, VDST_ABM });
                for (User u : usrs) {
                    uIds.add(u.id);
                }
                uShared.addAll([SELECT Id, Name, IsActive FROM User WHERE Id IN (SELECT UserOrGroupId FROM EDM_AABP_gne__Share WHERE ParentId = :recordId)
                                                                AND Id IN :uIds]);
            }
            else if (userRole == ABLEAD || userRole == VDST_ABM) {
                Set<Id> uIds = new Set<id>();
                List<User> usrs = getUsersForRoles(new List<String> { ABLEAD, VDST_ABM });
                for (User u : usrs) {
                    uIds.add(u.id);
                }
                uShared.addAll([SELECT Id, Name, IsActive FROM User WHERE Id IN (SELECT UserOrGroupId FROM EDM_AABP_gne__Share WHERE ParentId = :recordId)
                                                                AND Id IN :uIds]);
            }
        }
        return uShared;
    }

    public static List<User> getUsersToShareWith(String sharingUserRole) {
        List<User> uShare = new List<User>();
        if (sharingUserRole == ABS) {
            uShare = getUsersForRoles(new List<String> { ABLEAD, ABAPPROVER, ABAPPROVER_NO_LIC, ABREVIEWER, ABREVIEWER_NO_LIC, VDST_ABM });
        }
        else if (sharingUserRole == ABLEAD || sharingUserRole == VDST_ABM) {
            uShare = getUsersForRoles(new List<String> { ABLEAD, VDST_ABM });
        }

        return uShare;
    }

    public static Set<Id> getUserIdsToShareWithBaseOnAABPs(EDM_AABP_gne__c currentAABP, List<String> jointAABPs) {
        Set<Id> userIds = new Set<Id> {
                currentAABP.EDM_AB_Lead_gne__c,
                currentAABP.EDM_Vendor_Lead_gne__c
        };

        if (!jointAABPs.isEmpty()) {
            List<EDM_AABP_gne__c> jointAABPsList = [SELECT Id, EDM_AB_Lead_gne__c, EDM_Vendor_Lead_gne__c
                                                FROM EDM_AABP_gne__c 
                                                WHERE Id IN :jointAABPs];

            for (EDM_AABP_gne__c jointAABP : jointAABPsList) {
                userIds.add(jointAABP.EDM_AB_Lead_gne__c);
                userIds.add(jointAABP.EDM_Vendor_Lead_gne__c);
            }
        }

        return userIds;
    }

    public static List<User> getUsers(Set<Id> userIds) {
        return [SELECT Id, Name, IsActive, FirstName, LastName, External_Id_gne__c FROM User WHERE Id IN :userIds];
    }

    public static List<User> getUsersForRole(String userRole) {
        return getUsersForRoles(new List<String> {userRole});
    }

    public static Set<Id> getUserIdsForRole(String userRole) {
        return getUserIdsForRoles(new List<String> {userRole});
    }

    public static List<User> getUsersForRoles(List<String> userRoles) {
        Set<Id> userIds = getUserIdsForRoles(userRoles);

        return [SELECT Id, Name, IsActive FROM User WHERE IsActive = true AND Id in :userIds ORDER BY Name];
    }

    public static Set<Id> getUserIdsForRoles(List<String> userRoles) {
        List<PermissionSetAssignment> permSetAssign = [SELECT Id, AssigneeId FROM PermissionSetAssignment
                                                        WHERE PermissionSetId IN (SELECT Id FROM PermissionSet WHERE Name in :userRoles)];
        Set<Id> userIds = new Set<Id>();
        for (PermissionSetAssignment psa : permSetAssign) {
            userIds.add(psa.AssigneeId);
        }
        
        return userIds;
    }

    public static String getUserRole(Id userId) {
        List<PermissionSetAssignment> permList = [SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :userId AND PermissionSet.Name IN (:ABLEAD, :ABAPPROVER, :ABAPPROVER_NO_LIC, :ABREVIEWER, :ABREVIEWER_NO_LIC, :ABS, :VDST_ABM) ORDER BY PermissionSet.Name DESC];
        if (permList.size() == 1) {
            return permList[0].PermissionSet.Name;
        } else if(permList.size() > 1) {
            String psName = '';
            for(PermissionSetAssignment ps : permList) {
                    psName = ps.PermissionSet.Name;
            }
            return psName;
        } else {
            return '';
        }
    }

    public static Boolean isVdstExternalPartner(Id userId) {
        List<PermissionSetAssignment> vdstPermList = [
                SELECT PermissionSet.Name
                FROM PermissionSetAssignment
                WHERE AssigneeId = :userId
                AND PermissionSet.Name IN ( :VDST_ABM) LIMIT 1];
        return !vdstPermList.isEmpty() ? true : false;
    }
    
    //@Return - new share user ids 
    public static List<Id> setSharing(Id recordId, Set<Id> usersIdToShareWith, String userRole) {
        Set<Id> currentSharedUsersIds = (new Map<Id,User>(getSharedWithUsers(recordId, userRole, SHARE_DIRECT))).keySet();
        Set<Id> newSharedUsersIds = new Set<Id>();
        for (Id u : usersIdToShareWith) {
            newSharedUsersIds.add(u);
        }

        Set<Id> allIds = new Set<Id>();
        allIds.addAll(currentSharedUsersIds);
        allIds.addAll(newSharedUsersIds);

        List<Id> uShareAdd = new List<Id>();
        List<Id> uShareDel = new List<Id>();
        for (Id uId : allIds) {
            if (currentSharedUsersIds.contains(uId) && !newSharedUsersIds.contains(uId)) {
                uShareDel.add(uId);
            }
            if (!currentSharedUsersIds.contains(uId) && newSharedUsersIds.contains(uId)) {
                uShareAdd.add(uId);
            }
        }

        if (!uShareAdd.isEmpty()) {
            shareRecord(recordId, [SELECT Id, Name, IsActive FROM User WHERE Id IN :uShareAdd], AL_EDIT, SHARE_DIRECT);
        }

        if (!uShareDel.isEmpty()) {
            unShareRecord(new Set<Id> {recordId}, [SELECT Id, Name, IsActive FROM User WHERE Id IN :uShareDel], SHARE_DIRECT);
        }

        return uShareAdd;
    }

    public static String getTimeDifference(Boolean inMinutes, String timeStart, String timeEnd) {
        if (timeStart == null || timeEnd == null) {
            System.debug('timeStart = ' + timeStart + ', timeEnd = ' + timeEnd);
            return '0';
        }
        List<String> t1Split = timeStart.split(':|\\s');
        if (t1Split.size() != 3) {
            new EDM_ABMShareException('Time 1 is in the wrong format! hh:mm AM/PM');
        }
        Integer h1 = Integer.valueOf(t1Split[0]);
        h1 = h1 == 12 ? 0 : h1;
        if (t1Split[2] == 'PM') {
            h1 += 12;
        }
        Integer m1 = Integer.valueOf(t1Split[1]);

        List<String> t2Split = timeEnd.split(':|\\s');
        if (t2Split.size() != 3) {
            new EDM_ABMShareException('Time 2 is in the wrong format! hh:mm AM/PM');
        }
        Integer h2 = Integer.valueOf(t2Split[0]);
        h2 = h2 == 12 ? 0 : h2;
        if (t2Split[2] == 'PM') {
            h2 += 12;
        }
        Integer m2 = Integer.valueOf(t2Split[1]);

        Time t1 = Time.newInstance(h1, m1, 0, 0);
        Time t2 = Time.newInstance(h2, m2, 0, 0);
        Integer min1 = t1.minute() + t1.hour() * 60;
        Integer min2 = t2.minute() + t2.hour() * 60;
        Integer minDiff = Math.abs(min1 - min2);
        if (inMinutes) {
            return String.valueOf(minDiff);
        }

        return getTimeInHoursMinutes(minDiff);
    }

    public static String getTimeInHoursMinutes(Integer minutes) {
        if (minutes > 0) {
            Decimal hours = Math.floor(minutes * 1.0/60);
            Decimal min = minutes - hours * 60;
            String sMin = (min >= 10 ? '' + min : '0' + min);
            return hours + ':' + sMin;
        }
        else {
            return '0:00';
        }        
    }

    public static Integer getMinutesFromHM(String sTime) {
        if (!String.isBlank(sTime) && sTime.split(':').size() == 2) {
            return (Integer.valueOf(sTime.split(':')[0]) * 60 + Integer.valueOf(sTime.split(':')[1]));
        }
        else {
            return -1;
        }
    }

    public static Set<String> permissionSetAssignedToCurrentUser {
        get {
            if (permissionSetAssignedToCurrentUser == null) {
                List<PermissionSetAssignment> ps = [SELECT PermissionSet.Name 
                                                    FROM PermissionSetAssignment 
                                                    WHERE AssigneeId = :UserInfo.getUserId()];
                permissionSetAssignedToCurrentUser = new Set<String>();
                for(PermissionSetAssignment p : ps) {
                    permissionSetAssignedToCurrentUser.add(p.PermissionSet.Name.toUpperCase());
                }
            }
            return permissionSetAssignedToCurrentUser;
        }
        private set;
    }

    public static Boolean hasPermissionSet(String permissionSetName) {
        return permissionSetAssignedToCurrentUser.contains(permissionSetName.toUpperCase());
    }

    public static List<SelectOption> populateSharedWith(Id objectId, String userRole) {
        List<SelectOption> selectOptions = new List<SelectOption>();
        List<User> availableUsers = getSharedWithUsers(objectId, userRole, SHARE_DIRECT);
        for (User u : availableUsers) {
            selectOptions.add(new SelectOption(u.Id, u.Name));
        }

        return selectOptions;       
    }

    // Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
    public static String getCreatableFieldsSOQL(String objectName, Id recordId) {
        if (recordId == null) { 
            return null; 
        }
        return getCreatableFieldsSOQL(objectName, 'Id =\'' + recordId + '\'');
    }

    public static String getCreatableFieldsSOQL(String objectName, String whereClause) {
        return getCreatableFieldsSOQL(objectName, whereClause, new List<String>());
    }

    public static String getCreatableFieldsSOQL(String objectName, String whereClause, List<String> extraFields) {
        Boolean onlyCreatable = true;
        return getFieldsSOQL(objectName, whereClause, extraFields, onlyCreatable);
    }

    // Returns a dynamic SOQL statement for the whole object, includes all fields, not loooking at FLS - HPALM-489
    public static String getAllFieldsSOQL(String objectName, Id recordId) {
        if (recordId == null) { 
            return null; 
        }
        return getAllFieldsSOQL(objectName, 'Id =\'' + recordId + '\'');
    }

    public static String getAllFieldsSOQL(String objectName, String whereClause) {
        return getAllFieldsSOQL(objectName, whereClause, new List<String>());
    }

    public static String getAllFieldsSOQL(String objectName, String whereClause, List<String> extraFields) {
        Boolean onlyCreatable = false;
        return getFieldsSOQL(objectName, whereClause, extraFields, onlyCreatable);
    }

    public static String getFieldsSOQL(String objectName, String whereClause, List<String> extraFields, Boolean onlyCreatable) {
        String selects = '';
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        Set<String> selectFields = new Set<String>();
         
        if (fMap != null) {
            for (Schema.SObjectField ft : fMap.values()) { // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (!onlyCreatable || fd.isCreateable()) { // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
        
        if (extraFields != null && !extraFields.isEmpty()) {
            selectFields.addAll(extraFields);
        }

        if (!selectFields.isEmpty()) {
            for (String s : selectFields) {
                selects += s + ',';
            }
            if (selects.endsWith(',')) {
                selects = selects.substring(0, selects.lastIndexOf(','));
            }
             
        }
        String qry = 'SELECT ' + selects + ' FROM ' + objectName;
        if (whereClause != '') {
            qry +=  ' WHERE ' + whereClause;
        }
        System.debug(qry);
        return qry;
    }

    public static EDM_IABP_gne__c createSnapshot(Id recordId) {
        String objectName = '';
        if (recordId != null) {
            objectName = recordId.getSObjectType().getDescribe().getName();
        }

        if (objectName == 'EDM_IABP_gne__c') {
            List<sObject> relatedLists = new List<sObject>();

            EDM_IABP_gne__c doc = (EDM_IABP_gne__c)Database.query(getAllFieldsSOQL('EDM_IABP_gne__c', recordId));
            EDM_IABP_gne__c duplicate = doc.clone(false, true, false, true);
            duplicate.EDM_History_Parent_IABP_gn__c = recordId;
            duplicate.EDM_Historical_gne__c = true;

            insert duplicate;

            for(EDM_Attendee_gne__c att : (List<EDM_Attendee_gne__c>)Database.query(getAllFieldsSOQL('EDM_Attendee_gne__c', 'EDM_Parent_IABP_gne__c = \'' + recordId + '\''))) {
                att.EDM_Parent_IABP_gne__c = duplicate.Id;                
                relatedLists.add(att.clone(false, true, false, true));
            }

            for(EDM_Objective_gne__c obj : (List<EDM_Objective_gne__c>)Database.query(getAllFieldsSOQL('EDM_Objective_gne__c', 'EDM_Parent_IABP_gne__c = \'' + recordId + '\''))) {
                obj.EDM_Parent_IABP_gne__c = duplicate.Id;
                relatedLists.add(obj.clone(false, true, false, true));
            }

            for(EDM_Budget_gne__c budItem : (List<EDM_Budget_gne__c>)Database.query(getAllFieldsSOQL('EDM_Budget_gne__c', 'EDM_Parent_IABP_gne__c = \'' + recordId + '\''))) {
                budItem.EDM_Parent_IABP_gne__c = duplicate.Id;
                relatedLists.add(budItem.clone(false, true, false, true));
            }

            for(EDM_Question_gne__c qs : (List<EDM_Question_gne__c>)Database.query(getAllFieldsSOQL('EDM_Question_gne__c', 'EDM_Parent_Exe_Summary_gne__c = \'' + recordId + '\''))) {
                qs.EDM_Parent_Exe_Summary_gne__c = duplicate.Id;
                relatedLists.add(qs.clone(false, true, false, true));
            }
            
            for(EDM_Response_gne__c resp : (List<EDM_Response_gne__c>)Database.query(getAllFieldsSOQL('EDM_Response_gne__c', 'EDM_Parent_Exe_Summary_gne__c = \'' + recordId + '\''))) {
                resp.EDM_Parent_Exe_Summary_gne__c = duplicate.Id;
                relatedLists.add(resp.clone(false, true, false, true));
            }

            for(EDM_Attachment_gne__c attachment : (List<EDM_Attachment_gne__c>)Database.query(getAllFieldsSOQL('EDM_Attachment_gne__c', 'EDM_Parent_IABP_gne__c = \'' + recordId + '\' AND (EDM_Pull_Through_Doc_gne__c = true OR EDM_System_Type_gne__c = \'Event Document\')'))) {
                attachment.EDM_Parent_IABP_gne__c = duplicate.Id;
                relatedLists.add(attachment.clone(false, true, false, true));
            }

            for(EDM_ABS_Comment_gne__c absComment : (List<EDM_ABS_Comment_gne__c>)Database.query(getAllFieldsSOQL('EDM_ABS_Comment_gne__c', 'EDM_Parent_IABP_gne__c = \'' + recordId + '\''))) {
                absComment.EDM_Parent_IABP_gne__c = duplicate.Id;
                relatedLists.add(absComment.clone(false, true, false, true));
            }

            // sorting to prevent "Cannot have more than 10 chunks in a single operation." exception
            relatedLists.sort();
            insert relatedLists;

            
            List<EDM_Session_gne__c> sessions = new List<EDM_Session_gne__c>();
            for(EDM_Session_gne__c sess : [SELECT Id, Name, EDM_Description_gne__c, EDM_Discussion_End_Time_gne__c, EDM_Discussion_Start_Time_gne__c, EDM_Parent_IABP_gne__c, EDM_ID_For_Comparator_gne__c,
                                                    EDM_Presentation_End_Time_gne__c, EDM_Presentation_Start_Time_gne__c, EDM_Presenter_gne__c, EDM_Title_gne__c, EDM_Is_Break_gne__c,
                                                    EDM_No_Discussion_gne__c, EDM_No_Presentation_gne__c, EDM_Information_Gained_gne__c,
                                                    EDM_Session_Objectives_gne__c, EDM_Representative_AB_Questions_gne__c, EDM_Content_Description_gne__c,
                                                    EDM_Session_Date_gne__c
                                            FROM EDM_Session_gne__c 
                                            WHERE EDM_Parent_IABP_gne__c = :recordId]) {
                sess.EDM_Parent_IABP_gne__c = duplicate.Id;
                sessions.add(sess.clone(false, true, false, true));
            }
            insert sessions;

            return duplicate;
        }
        else {
            throw new EDM_ABMShareException('Unsupported object type.');
            return null;
        }
    }

    public static EDM_IABP_gne__c getSnapshot(Id recordId) {
        String objectName = '';
        if (recordId != null) {
            objectName = recordId.getSObjectType().getDescribe().getName();
        }

        if (objectName == 'EDM_IABP_gne__c') {
            EDM_IABP_gne__c doc = (EDM_IABP_gne__c)Database.query(getCreatableFieldsSOQL('EDM_IABP_gne__c', recordId));
            EDM_IABP_gne__c duplicate = doc.clone(false, true, false, true);
            duplicate.EDM_History_Parent_IABP_gn__c = recordId;
            duplicate.EDM_Historical_gne__c = true;
            return duplicate;
        }
        else {
            throw new EDM_ABMShareException('Unsupported object type.');
        }
        return null;
    }

    public static void dupliacateSharings(Id source, Id target) {
        String objectName = '';
        if (source != null) {
            objectName = source.getSObjectType().getDescribe().getName();
        }

        if (objectName == 'EDM_IABP_gne__c') {
            List<EDM_IABP_gne__Share> targetShares = new List<EDM_IABP_gne__Share>();
            List<EDM_IABP_gne__Share> sourceShares = [SELECT AccessLevel, ParentId, RowCause, UserOrGroupId
                                                        FROM EDM_IABP_gne__Share 
                                                        WHERE ParentId = :source
                                                        AND RowCause != 'Owner'];
            for (EDM_IABP_gne__Share shr : sourceShares) {
                targetShares.add(new EDM_IABP_gne__Share(
                                        AccessLevel = shr.AccessLevel,
                                        ParentId = target,
                                        RowCause = shr.RowCause,
                                        UserOrGroupId = shr.UserOrGroupId
                                    ));
            }
            Database.SaveResult[] saveResultsUpdate = Database.insert(targetShares, false);
        }
        else {
            throw new EDM_ABMShareException('Unsupported object type.');
        }
    }

    public static Id getIABPRecordType(String name) {
        List<RecordType> rtList = [SELECT Id, Name FROM RecordType 
                                    WHERE Name = :name
                                    AND SobjectType = 'EDM_IABP_gne__c'];
        if (rtList.size() == 1) {
            return rtList[0].Id;
        }
        else {
            return null;
        }
    }

    public static Messaging.SingleEmailMessage prepEmail(Id TargetObjectId,Id WhatId,Id TemplateId ,List<String> CcAddresses){

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        try{
            email.setTargetObjectId(TargetObjectId);
            email.setWhatId(WhatId);
            email.setTemplateId(TemplateId);
            email.setSaveAsActivity(false);
            email.setCcAddresses(CcAddresses);

            return email;
        } catch(Exception e) {
            String errorMessage = e.getMessage()+'\n'+e.getStackTraceString();
            System.debug(errorMessage);
            return null;
        }
    }

    public static Messaging.SingleEmailMessage prepEmailWithAttachments(Id TargetObjectId, Id WhatId, Id TemplateId, List<String> CcAddresses, List<Attachment> attachments) {
        Messaging.SingleEmailMessage email = prepEmail(TargetObjectId, WhatId, TemplateId, CcAddresses);

        if (attachments != null) {
            List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();
            for (Attachment attach :attachments) {
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(attach.Name);
                efa.setBody(attach.Body);
                fileAttachments.add(efa);
            }
            email.setFileAttachments(fileAttachments);
        }

        return email;
    }

    static public Boolean isValidId(String strId) {
        Boolean isValid = (strId InstanceOf ID) ? true : false ;
        return isValid ;
    }

    public static List<String> getListOfBrands() {
        Set<String> brandsSet = new Set<String>();
        List<String> result = new List<String>();
        List<Product_vod__c> products = [SELECT Name FROM Product_vod__c 
                                        WHERE Product_Type_vod__c = 'Detail' 
                                            AND Detail_Product_Subtype_Code_gne__c = 'Brand' 
                                            AND Brand_Code_gne__c != null
                                            ORDER BY NAME ASC];
        for (Product_vod__c p : products) {
            brandsSet.add(p.Name);
        }
        result.addAll(brandsSet);
        result.sort();
        return result;
    }

    public static void setApprovalStatus(EDM_IABP_gne__c iabp, String status) {
        iabp.EDM_Approval_Status_gne__c = status;
        if (status == 'Canceled') {
            iabp.EDM_Status_gne__c = 'IABP Under Review';
        }
        update iabp;
    }

    public static void removeAllComments(Id parentIABP) {
        if (parentIABP != null) {
            delete [SELECT Id FROM EDM_Comment_gne__c WHERE EDM_Parent_IABP_gne__c = :parentIABP];
        }
    }

    public static void removeAllCommentsForSection(Id parentIABP, String sectionHeader) {
        if (parentIABP != null && String.isNotBlank(sectionHeader)) {
            delete [SELECT Id FROM EDM_Comment_gne__c WHERE EDM_Parent_IABP_gne__c = :parentIABP AND EDM_Section_gne__c = :sectionHeader];
        }
    }

     // Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
    public static List<string> getCreatableFields(String objectName){
         
         
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }

        return selectFields;
    }

    public static List<VDST_EventProvider_gne__c> getEventProviders() {
        if(eventProviders == null){
            eventProviders = [SELECT Id, Name, EventTypeProvideCode_gne__c, Region_Code_gne__c, 
                    VDST_EventProvider_gne__c, VendorCode_gne__c, VendorID_gne__c, VendorName_gne__c 
                FROM VDST_EventProvider_gne__c
                WHERE EventTypeProvideCode_gne__c IN ('AdBoard - Content', 'AdBoard - Logistics')
                ORDER BY VendorName_gne__c];
        }
        return eventProviders;
    }

    public static List<VDST_EventProvider_gne__c> getContentVendors() {
        List<VDST_EventProvider_gne__c> contentVendors = new List<VDST_EventProvider_gne__c>();
        for(VDST_EventProvider_gne__c eventProvider :getEventProviders()){
            if(eventProvider.EventTypeProvideCode_gne__c.equalsIgnoreCase('AdBoard - Content')){
                contentVendors.add(eventProvider);
            }
        }
        return contentVendors;
    }

    public static List<VDST_EventProvider_gne__c> getLogisticVendors() {
        List<VDST_EventProvider_gne__c> logisticVendors = new List<VDST_EventProvider_gne__c>();
        for(VDST_EventProvider_gne__c eventProvider :getEventProviders()){
            if(eventProvider.EventTypeProvideCode_gne__c.equalsIgnoreCase('AdBoard - Logistics')){
                logisticVendors.add(eventProvider);
            }
        }
        return logisticVendors;
    }

    public static Map<String, String> getIABPNames(Id iabpID) {
        Map<String, String> names = new Map<String, String>();
        EDM_IABP_gne__c iabp = [SELECT EDM_Primary_AB_Lead_gne__c, EDM_Primary_AB_Lead_gne__r.Name,
                EDM_Secondary_AB_Lead_gne__c, EDM_Secondary_AB_Lead_gne__r.Name,
                EDM_Third_AB_Lead_gne__c, EDM_Third_AB_Lead_gne__r.Name,
                EDM_Admin_gne__c, EDM_Admin_gne__r.Name,
                EDM_Primary_Vendor_Lead_gne__c, EDM_Primary_Vendor_Lead_gne__r.Name,
                EDM_Second_Vendor_Lead_gne__c, EDM_Second_Vendor_Lead_gne__r.Name,
                EDM_ABS_Manager_gne__c, EDM_ABS_Manager_gne__r.Name
        FROM EDM_IABP_gne__c WHERE Id = :iabpID];

        names.put('EDM_Primary_AB_Lead_gne__c', iabp.EDM_Primary_AB_Lead_gne__c != null ? iabp.EDM_Primary_AB_Lead_gne__r.Name : null);
        names.put('EDM_Secondary_AB_Lead_gne__c', iabp.EDM_Secondary_AB_Lead_gne__c != null ? iabp.EDM_Secondary_AB_Lead_gne__r.Name : null);
        names.put('EDM_Third_AB_Lead_gne__c', iabp.EDM_Third_AB_Lead_gne__c != null ? iabp.EDM_Third_AB_Lead_gne__r.Name : null);
        names.put('EDM_Admin_gne__c', iabp.EDM_Admin_gne__c != null ? iabp.EDM_Admin_gne__r.Name : null);
        names.put('EDM_Primary_Vendor_Lead_gne__c', iabp.EDM_Primary_Vendor_Lead_gne__c != null ? iabp.EDM_Primary_Vendor_Lead_gne__r.Name : null);
        names.put('EDM_Second_Vendor_Lead_gne__c', iabp.EDM_Second_Vendor_Lead_gne__c != null ? iabp.EDM_Second_Vendor_Lead_gne__r.Name : null);
        names.put('EDM_ABS_Manager_gne__c', iabp.EDM_ABS_Manager_gne__c != null ? iabp.EDM_ABS_Manager_gne__r.Name : null);

        return names;
    }

    public static Map<String, String> getAABPNames(Id aabpId) {
        Map<String, String> names = new Map<String, String>();
        EDM_AABP_gne__c aabp = [SELECT EDM_AB_Lead_gne__c, EDM_AB_Lead_gne__r.Name,
                                       EDM_Vendor_Lead_gne__c, EDM_Vendor_Lead_gne__r.Name,
                                       EDM_ABS_Manager_gne__c, EDM_ABS_Manager_gne__r.Name
                                FROM EDM_AABP_gne__c
                                WHERE Id = :aabpId];

        names.put('EDM_AB_Lead_gne__c', aabp.EDM_AB_Lead_gne__c != null ? aabp.EDM_AB_Lead_gne__r.Name : null);
        names.put('EDM_Vendor_Lead_gne__c', aabp.EDM_Vendor_Lead_gne__c != null ? aabp.EDM_Vendor_Lead_gne__r.Name : null);
        names.put('EDM_ABS_Manager_gne__c', aabp.EDM_ABS_Manager_gne__c != null ? aabp.EDM_ABS_Manager_gne__r.Name : null);

        return names;
    }

    public static void deleteAttachement(Id attachementId) {
        delete [SELECT Id FROM EDM_Attachment_gne__c WHERE Id = :attachementId];
    }

    public static void deleteSystemGeneratedDocuments(Id iabpId) {
        delete [SELECT Id 
                FROM EDM_Attachment_gne__c 
                WHERE EDM_Parent_IABP_gne__c = :iabpId AND EDM_System_Type_gne__c = 'System Generated'];
    }

    public static List<String> getSortedTeams(EDM_IABP_gne__c iabp) {
        List<String> teams = new List<String>();

        EDM_AABP_gne__c parentAABP = [SELECT Id, EDM_Group_gne__c, EDM_Team_gne__c, EDM_Unit_gne__c FROM EDM_AABP_gne__c WHERE Id = :iabp.EDM_Parent_AABP_gne__c];
	String parentGroup = String.isNotBlank(String.valueOf(parentAABP.EDM_Group_gne__c)) ? String.valueOf(parentAABP.EDM_Group_gne__c) : '';
        String patentUnit = String.isNotBlank(String.valueOf(parentAABP.EDM_Unit_gne__c)) ? String.valueOf(parentAABP.EDM_Unit_gne__c) : '';
        String parentTeam = String.isNotBlank(String.valueOf(parentAABP.EDM_Team_gne__c)) ? String.valueOf(parentAABP.EDM_Team_gne__c) : '';
        teams.add(parentGroup.replace(';', ',') + ' - ' + patentUnit.replace(';', ',') + ' - ' + parentTeam.replace(';', ','));

        for (EDM_AABP_gne__c aabp : getJointAABPs(iabp)) {
	    String jointGroup = String.isNotBlank(String.valueOf(aabp.EDM_Group_gne__c)) ? String.valueOf(aabp.EDM_Group_gne__c) : '';
            String jointUnit = String.isNotBlank(String.valueOf(aabp.EDM_Unit_gne__c)) ? String.valueOf(aabp.EDM_Unit_gne__c) : '';
            String jointTeam = String.isNotBlank(String.valueOf(aabp.EDM_Team_gne__c)) ? String.valueOf(aabp.EDM_Team_gne__c) : '';
            teams.add(jointGroup.replace(';', ',') + ' - ' + jointUnit.replace(';', ',') + ' - ' + jointTeam.replace(';', ','));
        }    
        teams.sort();

        return teams;
    }

    public static List<EDM_AABP_gne__c> getJointAABPs(EDM_IABP_gne__c iabp) {
        if (iabp.EDM_Joint_AABP_gne__c != null && iabp.EDM_Joint_AABP_gne__c != '') {
            Set<String> jointIds = new Set<String>(/*[SELECT EDM_Joint_AABP_gne__c FROM EDM_IABP_gne__c WHERE Id = :iabp.Id]*/ iabp.EDM_Joint_AABP_gne__c.split(','));
            List<EDM_AABP_gne__c> aabps = [SELECT Id, EDM_Group_gne__c, EDM_Team_gne__c, EDM_Unit_gne__c,EDM_Plan_Year_gne__c,EDM_AB_Lead_gne__r.Name FROM EDM_AABP_gne__c WHERE Id IN :jointIds];
            return aabps;
        }
        else {
            return new List<EDM_AABP_gne__c>();
        }
    }

    public static String getRandomID() {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < 20) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), 62);
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }

    public static void changeOwner(Id aabpId, Id newABSId){
        List<EDM_IABP_gne__c> toUpdate = [SELECT Id, OwnerId FROM EDM_IABP_gne__c WHERE EDM_Parent_AABP_gne__c = :aabpId AND EDM_Historical_gne__c = false AND EDM_Parent_IABP_gne__c = null AND OwnerId != :newABSId];
        for(EDM_IABP_gne__c iabp :toUpdate){
            iabp.OwnerId = newABSId;
        }
        if(toUpdate.size()>0){
            try{
                update toUpdate;
            } catch(Exception ex){
                system.debug('Failed to change owner: ' + ex);
            }
        }
    }

    public static List<EDM_IABP_gne__c> retrieveRelatedIABPsWithoutSharing(Id aabpId) {
        return [SELECT Id, Name, EDM_Start_Date_gne__c, EDM_Estimated_Quarter_gne__c, 
                        EDM_Canceled_gne__c, EDM_Optional_Detail_gne__c, EDM_Event_Name_gne__c, 
                        EDM_Type_of_Event_gne__c, EDM_Ad_Hoc_Event_gne__c,
                        EDM_Cancel_Reason_gne__c, EDM_Status_gne__c, EDM_Name_gne__c, EDM_Year_gne__c
                FROM EDM_IABP_gne__c
                WHERE EDM_Parent_AABP_gne__c = :aabpId
                AND EDM_History_Parent_IABP_gn__c = null
                AND EDM_Historical_gne__c = false 
                AND EDM_Executive_Summary_gne__c = false
                ORDER BY Name];
    }

    public static String retrieveGroup2UnitMapping() {
        StaticResource srObject = [SELECT Id, Body FROM StaticResource WHERE Name = :GROUP_2_UNIT_MAPPING];
        String content = srObject.Body.toString().replaceAll('(\\r|\\n)+', '');
        return content;
    }

    public static String retrieveUnit2TeamMapping() {
        StaticResource srObject = [SELECT Id, Body FROM StaticResource WHERE Name = :UNIT_2_TEAM_MAPPING];
        String content = srObject.Body.toString().replaceAll('(\\r|\\n)+', '');
        return content;
    }
}