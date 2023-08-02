/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-08-20
*  Description: This is a helper class for handling Affiliation child record updates
*  Test class: GNE_SFA2_Affiliation_Trigger_Test
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public without sharing class GNE_SFA2_Affiliation_Child_Record_Update {

    private static void updateTopPayerAffiliations(List<Affiliation_vod__c> triggerOld, List<Affiliation_vod__c> triggerNew) {
        if (triggerNew.size() == 1) {
            for (Integer i = 0; i < triggerNew.size(); i++) {
                //check if affiliation is not Trigger created
                if (triggerNew[i].Parent_vod__c && triggerNew[i].From_Account_vod__c != null && triggerNew[i].To_Account_vod__c != null) {
                    //Is the Role of 'Top Payer Type'
                    String affiliationRole = triggerNew[i].Role_vod__c;
                    if (affiliationRole != null) {
                        if (affiliationRole.contains('Top Payer')) {
                            //Call @future method from Affiliation Handler
                            autoContactAffiliationHandler.updateTopPayerAffiliations(triggerNew[i].From_Account_vod__c, triggerNew[i].To_Account_vod__c, affiliationRole);
                        }
                    }
                }
            }
        }
    }

    private static void alignTerritory(List<Affiliation_vod__c> triggerNew) {
        String[] profileList = system.Label.AlignTerritory_AfterInsertAffilitaion_UserProfile_list.split(',');
        String currentUserProfile = GNE_SFA2_Util.getCurrentUserProfileName();
        Boolean profileMatch = false;

        for (String profile : profileList) {
            if (currentUserProfile.startsWith(profile)) {
                profileMatch = true;
            }
        }

        if (!profileMatch) {
            return ;
        }

        //get affiliation types for which this trigger needs to be executed
        String affTypes = System.Label.AlignTerritory_AfterInsertAffilitaion_AffTypes;

        List<Id> affiliationsList = new List<Id>();
        for (Affiliation_vod__c affiliation : triggerNew) {
            if (affiliation.From_Account_vod__c != null && affiliation.To_Account_vod__c != null
                    && affTypes.contains(affiliation.Affiliation_Type_gne__c)) {
                affiliationsList.add(affiliation.id);
            }
        }
        if (affiliationsList.size() > 0) {
            Affiliation_alignTerritory.AlignTerritory_fromTrigger(affiliationsList);
        }
    }

    private static void deleteChildAffiliations(List<Affiliation_vod__c> triggerOld) {
        List<Affiliation_vod__c> affiliationsToDelete = new List<Affiliation_vod__c>();
        Map<String, Affiliation_vod__c> affiliationsMap = new Map<String, Affiliation_vod__c>();
        for (Affiliation_vod__c affiliation : triggerOld) {
            if (!affiliationsMap.containsKey(affiliation.id)) {
                affiliationsMap.put(affiliation.id, affiliation);
            }
        }

        for (Affiliation_vod__c affiliation : triggerOld) {
            if (affiliation.Child_affiliation_vod__c != null && !affiliationsMap.containsKey(affiliation.Child_affiliation_vod__c)) {
                affiliationsToDelete.add(new Affiliation_vod__c (Id = affiliation.Child_affiliation_vod__c));
            }
        }
        if (affiliationsToDelete.size() > 0) {
            delete affiliationsToDelete;
        }
    }

    private static void createInverseAffiliations(List<Affiliation_vod__c> triggerNew, Boolean inAffilTrig) {
        if (!inAffilTrig) {
            return;
        }
        List<Affiliation_vod__c> affiliationsToInsert = new List<Affiliation_vod__c>();
        List<Affiliation_vod__c> affiliationsToUpdate = new List<Affiliation_vod__c>();

        Boolean hasCanadaProfile = GNE_SFA2_Util.isCanadaUser();

        for (Affiliation_vod__c affiliation : triggerNew) {
            Affiliation_vod__c newAffiliation = new Affiliation_vod__c (
                    From_Account_vod__c = affiliation.To_Account_vod__c,
                    From_Contact_vod__c = affiliation.To_Contact_vod__c,
                    To_Account_vod__c = affiliation.From_Account_vod__c,
                    To_Contact_vod__c = affiliation.From_Contact_vod__c,
                    Affiliation_Type_gne__c = affiliation.Affiliation_Type_gne__c,
                    Comments_vod__c = affiliation.Comments_vod__c,
                    Role_vod__c = (!hasCanadaProfile ? affiliation.Role_vod__c : affiliation.Role_opposite_vod__c),
                    Role_opposite_vod__c = affiliation.Role_vod__c,
                    Primary_gne__c = affiliation.Primary_gne__c,
                    Child_affiliation_vod__c = affiliation.Id

            );

            if (affiliation.Influence_vod__c == 'Has influence') {
                newAffiliation.Influence_vod__c = 'Is influenced';
            } else if (affiliation.Influence_vod__c == 'Is influenced') {
                newAffiliation.Influence_vod__c = 'Has influence';
            }
            affiliationsToInsert.add(newAffiliation);
        }

        insert affiliationsToInsert;

        // update parent affiliations
        for (Affiliation_vod__c affiliation : affiliationsToInsert) {
            if (affiliation.Child_affiliation_vod__c == null) {
                continue;
            }
            Affiliation_vod__c parentAffiliation = new Affiliation_vod__c (
                    Id = affiliation.Child_affiliation_vod__c,
                    Child_affiliation_vod__c = affiliation.Id,
                    Parent_vod__c = true
            );
            affiliationsToUpdate.add(parentAffiliation);
        }

        if (affiliationsToUpdate.size() > 0) {
            update affiliationsToUpdate;
        }
    }

    private static void updateChildAffiliations(List<Affiliation_vod__c> triggerOld, List<Affiliation_vod__c> triggerNew, Boolean inAffilTrig) {
        if (!inAffilTrig) {
            return;
        }
        List<Affiliation_vod__c> affiliationsToUpdate = new List<Affiliation_vod__c>();
        Affiliation_vod__c affiliation, affiliationOld;
        for (Integer i = 0; i < triggerNew.size(); i++) {
            affiliation = triggerNew[i];
            if (affiliation.Child_affiliation_vod__c == null) {
                continue;
            }

            affiliationOld = triggerOld[i];

            if (affiliationOld.Comments_vod__c == affiliation.Comments_vod__c &&
                    affiliationOld.Role_vod__c == affiliation.Role_vod__c &&
                    affiliationOld.Role_opposite_vod__c == affiliation.Role_opposite_vod__c &&
                    affiliationOld.Primary_gne__c == affiliation.Primary_gne__c &&
                    affiliationOld.Influence_vod__c == affiliation.Influence_vod__c) {
                continue;
            }

            Affiliation_vod__c childAffiliation = new Affiliation_vod__c(
                    Id = affiliation.Child_affiliation_vod__c,
                    Comments_vod__c = affiliation.Comments_vod__c,
                    Role_vod__c = (!GNE_SFA2_Util.isCanadaUser() ? affiliation.Role_vod__c : affiliation.Role_opposite_vod__c),
                    Role_opposite_vod__c = affiliation.Role_vod__c,
                    Primary_gne__c = affiliation.Primary_gne__c
            );

            if (affiliation.Influence_vod__c == 'Has influence') {
                childAffiliation.Influence_vod__c = 'Is influenced';
            } else if (affiliation.Influence_vod__c == 'Is influenced') {
                childAffiliation.Influence_vod__c = 'Has influence';
            }

            affiliationsToUpdate.add(childAffiliation);
        }
        if (affiliationsToUpdate.size() > 0) {
            update affiliationsToUpdate;
        }
    }

    private static void updatePrimaryFlag(Map<Id, Affiliation_vod__c> triggerOldMap, Map<Id, Affiliation_vod__c> triggerNewMap) {
        Set<Id> newPrimaryAffiliations = new Set<Id>();
        Set<Id> noLongerPrimaryAffiliations = new Set<Id>();
        Map<Id, Affiliation_vod__c> affiliationToUpdate = new Map<Id, Affiliation_vod__c>();
        Set<Id> parentsAndChildrenAffiliationIds = new Set<Id>();
        for (Affiliation_vod__c affiliation : triggerNewMap.values()) {
            parentsAndChildrenAffiliationIds.add(affiliation.Child_affiliation_vod__c);
            parentsAndChildrenAffiliationIds.add(affiliation.Id);
        }
        Map<Id, Affiliation_vod__c> parentAndChildrenAffiliations = new Map<Id, Affiliation_vod__c>([
                SELECT Id, From_Account_vod__c, From_Account_vod__r.IsPersonAccount, From_Contact_vod__c,
                        To_Account_vod__c, To_Account_vod__r.INS_ID_gne__c, INS_ID_gne__c
                FROM Affiliation_vod__c
                WHERE Id IN :parentsAndChildrenAffiliationIds
        ]);

        for (Id affiliationId : triggerNewMap.keySet()) {
            Affiliation_vod__c affiliation = triggerNewMap.get(affiliationId);
            Affiliation_vod__c oldAffiliation = triggerOldMap.get(affiliationId);
            if (affiliation.Primary_gne__c == true && (oldAffiliation == null || oldAffiliation.Primary_gne__c == false)) {
                newPrimaryAffiliations.add(affiliationId);
                if (affiliation.Child_affiliation_vod__c != null) {
                    newPrimaryAffiliations.add(affiliation.Child_affiliation_vod__c);
                    affiliationToUpdate.put(affiliation.Child_affiliation_vod__c, new Affiliation_vod__c(Id = affiliation.Child_affiliation_vod__c, Primary_gne__c = true));
                }
            } else if (affiliation.Primary_gne__c == false && oldAffiliation?.Primary_gne__c == true) {
                noLongerPrimaryAffiliations.add((affiliation.Id));
                if (affiliation.Child_affiliation_vod__c != null) {
                    noLongerPrimaryAffiliations.add(affiliation.Child_affiliation_vod__c);
                    affiliationToUpdate.put(affiliation.Child_affiliation_vod__c, new Affiliation_vod__c(Id = affiliation.Child_affiliation_vod__c, Primary_gne__c = false));
                }
            }
        }
        Set<Id>fromAccountIds = new Set<Id>();
        Set<Id>fromContactIds = new Set<Id>();

        for (Affiliation_vod__c affiliation : parentAndChildrenAffiliations.values()) {
            if (isPersonAffiliation(affiliation) && (newPrimaryAffiliations.contains(affiliation.Id) || noLongerPrimaryAffiliations.contains(affiliation.Id))) {
                if (affiliation.From_Account_vod__c != null) {
                    fromAccountIds.add(affiliation.From_Account_vod__c);
                } else if (affiliation.From_Contact_vod__c != null) {
                    fromContactIds.add(affiliation.From_Contact_vod__c);
                }
            }
        }
        List<Affiliation_vod__c> otherAffiliationToUpdate = [
                SELECT Id, Child_affiliation_vod__c, From_Account_vod__c, From_Contact_vod__c, To_Account_vod__c, To_Account_vod__r.INS_ID_gne__c, Primary_gne__c, INS_ID_gne__c
                FROM Affiliation_vod__c
                WHERE (From_Account_vod__c IN :fromAccountIds OR From_Contact_vod__c IN :fromContactIds) AND Id NOT IN :parentAndChildrenAffiliations.keySet()
        ];
        Map<Id, List<Affiliation_vod__c>> hcpOrContactIdToAffiliations = new Map<Id, List<Affiliation_vod__c>>();
        for (Affiliation_vod__c affiliation : otherAffiliationToUpdate) {
            if (affiliation.From_Account_vod__c != null) {
                if (!hcpOrContactIdToAffiliations.containsKey(affiliation.From_Account_vod__c)) {
                    hcpOrContactIdToAffiliations.put(affiliation.From_Account_vod__c, new List<Affiliation_vod__c>());
                }
                hcpOrContactIdToAffiliations.get(affiliation.From_Account_vod__c).add(affiliation);
            } else if (affiliation.From_Contact_vod__c != null) {
                if (!hcpOrContactIdToAffiliations.containsKey(affiliation.From_Contact_vod__c)) {
                    hcpOrContactIdToAffiliations.put(affiliation.From_Contact_vod__c, new List<Affiliation_vod__c>());
                }
                hcpOrContactIdToAffiliations.get(affiliation.From_Contact_vod__c).add(affiliation);
            }
        }

        for (Id primaryAffiliationId : newPrimaryAffiliations) {
            Affiliation_vod__c primaryAffiliation = parentAndChildrenAffiliations.get(primaryAffiliationId);
            List<Affiliation_vod__c> otherAffiliations;
            if (primaryAffiliation.From_Account_vod__c != null) {
                otherAffiliations = hcpOrContactIdToAffiliations.get(primaryAffiliation.From_Account_vod__c);
            } else if (primaryAffiliation.From_Contact_vod__c != null) {
                otherAffiliations = hcpOrContactIdToAffiliations.get(primaryAffiliation.From_Contact_vod__c);
            }
            if (otherAffiliations != null) {
                for (Affiliation_vod__c affiliation : otherAffiliations) {
                    if (isTheSameToAccount(primaryAffiliation, affiliation)) {
                        if (affiliation.Primary_gne__c != true) {
                            affiliation.Primary_gne__c = true;
                            affiliationToUpdate.put(affiliation.Id, affiliation);
                            if (affiliation.Child_affiliation_vod__c != null) {
                                affiliationToUpdate.put(affiliation.Child_affiliation_vod__c, new Affiliation_vod__c(Id = affiliation.Child_affiliation_vod__c, Primary_gne__c = true));
                            }
                        }
                    } else if ((String.isNotBlank(primaryAffiliation.INS_ID_gne__c) && primaryAffiliation.INS_ID_gne__c == affiliation.INS_ID_gne__c)
                            && affiliation.Primary_gne__c == false) {
                        affiliation.Primary_gne__c = true;
                        affiliationToUpdate.put(affiliation.Id, affiliation);
                        if (affiliation.Child_affiliation_vod__c != null) {
                            affiliationToUpdate.put(affiliation.Child_affiliation_vod__c, new Affiliation_vod__c(Id = affiliation.Child_affiliation_vod__c, Primary_gne__c = true));
                        }
                    } else if ((String.isBlank(primaryAffiliation.INS_ID_gne__c) || primaryAffiliation.INS_ID_gne__c != affiliation.INS_ID_gne__c)
                            && affiliation.Primary_gne__c == true) {
                        affiliation.Primary_gne__c = false;
                        affiliationToUpdate.put(affiliation.Id, affiliation);
                        if (affiliation.Child_affiliation_vod__c != null) {
                            affiliationToUpdate.put(affiliation.Child_affiliation_vod__c, new Affiliation_vod__c(Id = affiliation.Child_affiliation_vod__c, Primary_gne__c = false));
                        }
                    }
                }
            }
        }
        for (Id noLongerPrimaryAffiliationId : noLongerPrimaryAffiliations) {
            Affiliation_vod__c noLongerPrimaryAffiliation = parentAndChildrenAffiliations.get(noLongerPrimaryAffiliationId);
            List<Affiliation_vod__c> otherAffiliations;
            if (noLongerPrimaryAffiliation.From_Account_vod__c != null) {
                otherAffiliations = hcpOrContactIdToAffiliations.get(noLongerPrimaryAffiliation.From_Account_vod__c);
            } else if (noLongerPrimaryAffiliation.From_Contact_vod__c != null) {
                otherAffiliations = hcpOrContactIdToAffiliations.get(noLongerPrimaryAffiliation.From_Contact_vod__c);
            }
            if (otherAffiliations != null) {
                for (Affiliation_vod__c affiliation : otherAffiliations) {
                    if (isTheSameToAccount(noLongerPrimaryAffiliation, affiliation) && affiliation.Primary_gne__c == true) {
                        affiliation.Primary_gne__c = false;
                        affiliationToUpdate.put(affiliation.Id, affiliation);
                        if (affiliation.Child_affiliation_vod__c != null) {
                            affiliationToUpdate.put(affiliation.Child_affiliation_vod__c, new Affiliation_vod__c(Id = affiliation.Child_affiliation_vod__c, Primary_gne__c = false));
                        }
                    }
                    if (String.isNotBlank(noLongerPrimaryAffiliation.INS_ID_gne__c) && noLongerPrimaryAffiliation.INS_ID_gne__c == affiliation.INS_ID_gne__c && affiliation.Primary_gne__c == true) {
                        affiliation.Primary_gne__c = false;
                        affiliationToUpdate.put(affiliation.Id, affiliation);
                        if (affiliation.Child_affiliation_vod__c != null) {
                            affiliationToUpdate.put(affiliation.Child_affiliation_vod__c, new Affiliation_vod__c(Id = affiliation.Child_affiliation_vod__c, Primary_gne__c = true));
                        }
                    }
                }
            }
        }
        update affiliationToUpdate.values();
    }

    private static Boolean isTheSameToAccount(Affiliation_vod__c primaryAffiliation, Affiliation_vod__c affiliation) {
        return (primaryAffiliation.To_Account_vod__c != null && primaryAffiliation.To_Account_vod__c == affiliation.To_Account_vod__c);
    }

    private static Boolean isPersonAffiliation(Affiliation_vod__c affiliation) {
        return ((true == affiliation.From_Account_vod__r?.IsPersonAccount) || affiliation.From_Contact_vod__c != null);
    }


    public static void onAfterUpdate(List<Affiliation_vod__c> triggerOld, List<Affiliation_vod__c> triggerNew, Boolean inAffilTrig) {
        updateTopPayerAffiliations(triggerOld, triggerNew);
        updatePrimaryFlag(new Map<Id, Affiliation_vod__c>(triggerOld), new Map<Id, Affiliation_vod__c>(triggerNew));
    }

    public static void onAfterInsert(List<Affiliation_vod__c> triggerOld, List<Affiliation_vod__c> triggerNew, Boolean inAffilTrig) {
        updateTopPayerAffiliations(triggerOld, triggerNew);
        createInverseAffiliations(triggerNew, inAffilTrig);
        updatePrimaryFlag(new Map<Id, Affiliation_vod__c>(), new Map<Id, Affiliation_vod__c>(triggerNew));
        alignTerritory(triggerNew);
        if(!Test.isRunningTest() && GNE_SFA2_Util.isNotCanadaUser())
            sendToReltio(triggerNew, false);
    }

    private static void sendToReltio(List<Affiliation_vod__c> affiliationVods, Boolean isDelete) {
        for(Affiliation_vod__c aff : affiliationVods) {
            GNE_ReltioCreateRequest.sendRequest(aff, isDelete ? GNE_ReltioCreateRequest.OperationType.DEL : GNE_ReltioCreateRequest.OperationType.INS);
        }
    }

    public static void onAfterDelete(List<Affiliation_vod__c> triggerOld) {
        deleteChildAffiliations(triggerOld);
        if(!Test.isRunningTest() && GNE_SFA2_Util.isNotCanadaUser())
            sendToReltio(triggerOld, true);
    }
}