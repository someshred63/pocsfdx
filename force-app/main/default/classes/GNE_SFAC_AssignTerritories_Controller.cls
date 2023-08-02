global class GNE_SFAC_AssignTerritories_Controller {

    private static final String SFA_CANADA_PARENT_TERRITORY = 'ROCHE-CANADA';

    public String selectedTerritoryId { get; set;}
    public String selectedTerritoryName { get; set;}
    public Boolean userPrompt { get; set;}
    public String userMsg { get; set;}
    public Boolean isError { get; set;}

    private static final String SFA_CANADA_NO_ACCOUNTS_SELECTED = 'There are no Accounts in selected territories';
    private static final String SFA_CANADA_NO_NEW_ACCOUNTS_SELECTED = 'There are no new Accounts in selected territories';
    private static final String SFA_CANADA_WAIT_FOR_MAIL = 'It will take few minutes to add Accounts to Questionnaire. At complition you will receive an email notification';
    private static final String SFA_CANADA_SELECT_TERR_FIRST = 'Select Territory first, please.';

    public TerritoryWrapper parentTerritoryWrapper { get; set;}
    public Boolean generalAudience { get; set;}
    public Id questionaryId { get; set;}

    public Set<String> copyOfSelectedTerritories = new Set<String>();

    private final ApexPages.StandardSetController theController;
    private Map<String, String> allSelectedTerrritorisMap;
    private static Set<String> allSavedSelectedTerritorisSet = new Set<String>();

    private List<Error_log_gne__c> errorLogList = new List<Error_log_gne__c>();

    public GNE_SFAC_AssignTerritories_Controller(ApexPages.StandardSetController controller) {
        theController = controller;
        PageReference pageRef = ApexPages.currentPage();
        questionaryId = pageRef.getParameters().get('id');
        generalAudience = isGeneralAudience(questionaryId);
        allSelectedTerrritorisMap = new Map<String, String>();
        parentTerritoryWrapper = getParentTerritory();
        Questionnaire_gne__c qstr = [SELECT Id, Territories_can_gne__c FROM Questionnaire_gne__c WHERE Id = :questionaryId LIMIT 1];
		List<String> territoriesList = new List<String>();
		if(qstr != null && qstr.Territories_can_gne__c != null){
			String territories = qstr.Territories_can_gne__c;
			territoriesList = territories.split(';');
		}
		for(String terr : territoriesList){
			copyOfSelectedTerritories.add(terr);
		}

        userPrompt = false;
        isError = false;
    }

    public Boolean getAlreadySelected(){
    	if(allSavedSelectedTerritorisSet.isEmpty()){
    		return false;
    	}else{
    		return true;
    	}
    }

    public interface ObjectComparator {
        Integer compare(Object object1, Object object2);
    }

    public interface SObjectComparator {
        Integer compare(SObject object1, SObject object2);
    }

    @RemoteAction
    global static TerritoryWrapper tree(String questionaryId){

        //populate list of territories which should be checked
        Questionnaire_gne__c qstr = [SELECT Id, Territories_can_gne__c FROM Questionnaire_gne__c WHERE Id = :questionaryId LIMIT 1];
		List<String> territoriesList = new List<String>();
		if(qstr != null && qstr.Territories_can_gne__c != null){
			String territories = qstr.Territories_can_gne__c;
			territoriesList = territories.split(';');
		}
		for(String terr : territoriesList){
			allSavedSelectedTerritorisSet.add(terr);
		}

        return getParentTerritory();
    }

    public PageReference assignTargetedTerritories(){
        try {
        	if(!checkIfAccountsSelected(true)){
        		userPrompt = true;
       			if(copyOfSelectedTerritories.isEmpty()){
       				userMsg = SFA_CANADA_NO_ACCOUNTS_SELECTED;
       			}else{
       				userMsg = SFA_CANADA_NO_NEW_ACCOUNTS_SELECTED;
       			}
        		isError = true;
        		return null;
        	}
        } catch(Exception ex){
        	return GNE_SFA2_Util.redirectToErrorPage('An unexpected error occurs', Apexpages.currentPage().getUrl(), ex.getMessage());
        }

        updateQuestionnairTerritoriesField();
        Id batchinstanceid = database.executeBatch(new GNE_SFA_Canada_AssignTerritoryBatch(String.valueOf(questionaryId), true, allSelectedTerrritorisMap), 50);

        userPrompt = true;
        userMsg = SFA_CANADA_WAIT_FOR_MAIL;
        isError = false;

        return null;
    }

    public PageReference assignTerritories(){
        try {
        	if(!checkIfAccountsSelected(false)){
        		userPrompt = true;
       			if(copyOfSelectedTerritories.isEmpty()){
       				userMsg = SFA_CANADA_NO_ACCOUNTS_SELECTED;
       			}else{
       				userMsg = SFA_CANADA_NO_NEW_ACCOUNTS_SELECTED;
       			}
        		isError = true;
        		return null;
        	}
        } catch(Exception ex){
        	return GNE_SFA2_Util.redirectToErrorPage('An unexpected error occurs', Apexpages.currentPage().getUrl(), ex.getMessage());
        }

        updateQuestionnairTerritoriesField();
        Id batchinstanceid = database.executeBatch(new GNE_SFA_Canada_AssignTerritoryBatch(String.valueOf(questionaryId), false, allSelectedTerrritorisMap), 50);

        userPrompt = true;
        userMsg = SFA_CANADA_WAIT_FOR_MAIL;
        isError = false;

        return null;
    }

    private void updateQuestionnairTerritoriesField(){
		Questionnaire_gne__c qstr = [SELECT Id, Territories_can_gne__c FROM Questionnaire_gne__c WHERE Id = :questionaryId LIMIT 1];
		List<String> territoriesList = new List<String>();
		if(qstr != null && qstr.Territories_can_gne__c != null){
			String territories = qstr.Territories_can_gne__c;
			territoriesList = territories.split(';');
		}

		Set<String> territoriesSet = new Set<String>();
		for(String terr : territoriesList){
			territoriesSet.add(terr);
		}

		for(String terr : allSelectedTerrritorisMap.values()){
			territoriesSet.add(terr);
		}

		String allTerrs = '';
		Boolean firstRun = true;
		for(String terr : territoriesSet){
			if(firstRun){
				allTerrs = terr;
				firstRun = false;
			}else{
				allTerrs = allTerrs + ';' +terr;
			}
		}
		qstr.Territories_can_gne__c = allTerrs;
		update qstr;

	}

    public PageReference cancelAdding(){
        Questionnaire_gne__c quest = [Select id from Questionnaire_gne__c where id = :questionaryId];
        PageReference questionaryPage = new ApexPages.StandardController(quest).view();
        questionaryPage.setRedirect(true);
        return questionaryPage;
    }

    public PageReference selectTerritory(){
        selectSubTerritory(selectedTerritoryId,parentTerritoryWrapper);
        return null;
    }

    public PageReference unselectTerritory(){
        unselectSubTerritory(selectedTerritoryId,parentTerritoryWrapper);
        return null;
    }

    private void unselectSubTerritory(String terrId, TerritoryWrapper terrWrapper){
        if(terrWrapper.territoryItem.Id == terrId){
            if(!copyOfSelectedTerritories.contains(terrWrapper.territoryItem.Name)){
            	allSelectedTerrritorisMap.remove(terrId);
            }
            for(TerritoryWrapper tw : terrWrapper.children){
            	if(!copyOfSelectedTerritories.contains(tw.territoryItem.Name)){
                	removeAll(tw);
            	}
            }
        }else{
            for(TerritoryWrapper tw : terrWrapper.children){
                unselectSubTerritory(terrId,tw);
            }
        }

    }

    private void selectSubTerritory(String terrId, TerritoryWrapper terrWrapper){
        if(terrWrapper.territoryItem.Id == terrId){
            allSelectedTerrritorisMap.put(terrId, terrWrapper.territoryItem.Name);
            for(TerritoryWrapper tw : terrWrapper.children){
                selectAll(tw);
            }
        }else{
            for(TerritoryWrapper tw : terrWrapper.children){
                selectSubTerritory(terrId,tw);
            }
        }

    }

    private void removeAll(TerritoryWrapper terrWrapper){
        allSelectedTerrritorisMap.remove(terrWrapper.territoryItem.Id);
        for(TerritoryWrapper tw : terrWrapper.children){
            if(!copyOfSelectedTerritories.contains(tw.territoryItem.Name)){
            	removeAll(tw);
            }

        }
    }

    private void selectAll(TerritoryWrapper terrWrapper){
        allSelectedTerrritorisMap.put(terrWrapper.territoryItem.Id, terrWrapper.territoryItem.Name);
        for(TerritoryWrapper tw : terrWrapper.children){
            selectAll(tw);
        }
    }

    private Boolean checkIfAccountsSelected(Boolean checkTarget){
    	String query = GNE_SFA_Canada_AssignTerritoryBatch.getTsfQuery(checkTarget, allSelectedTerrritorisMap);
    	if (String.isBlank(query)){
    		return false;
    	}
    	query += 'Limit 1 ';
        return Database.query(query).size() > 0;
    }

    global class TerritoryWrapper {
        public Boolean selected { get; set;}
        public Territory2 territoryItem { get; set; }
        public String territoryShort { get; set; }
        public List<TerritoryWrapper> children { get; set; }
        public String itemTest { get; set; }
    }

    public class TerritoryWrapperComparator implements ObjectComparator {
        public Integer compare(Object object1, Object object2) {
            return ((TerritoryWrapper)object1).territoryItem.Name.compareTo(((TerritoryWrapper)object2).territoryItem.Name);
        }
    }

    private static TerritoryWrapper wrapTerritory(Territory2 terr){
        TerritoryWrapper terrWrapper = new TerritoryWrapper();
        terrWrapper.territoryItem = terr;

        if(allSavedSelectedTerritorisSet.contains(terr.Name)){
        	terrWrapper.selected = true;
        }else{
         	terrWrapper.selected = false;
        }
        terrWrapper.children = new List<TerritoryWrapper>();
        terrWrapper.territoryShort = terr.Name.substring(terr.Name.indexOf('-')+1,terr.Name.length());
        return terrWrapper;
    }

    private static void getTerritoriesByParents(Map<String, TerritoryWrapper> parentTerritoryWrapper, Map<String, TerritoryWrapper> resultMap){
        List<Territory2> childrenTerritories = new List<Territory2>([Select
                                    t.Id,
                                    t.Name,
                                    t.Territory_Number_gne__c,
                                    t.ParentTerritory2Id
                                from Territory2 t
                                where t.ParentTerritory2Id = :parentTerritoryWrapper.keySet()]);
        Map<String, TerritoryWrapper> newLevelMap = new Map<String, TerritoryWrapper>();
        for(Territory2 terr : childrenTerritories){
            if(parentTerritoryWrapper.get(terr.ParentTerritory2Id).children == null){
                parentTerritoryWrapper.get(terr.ParentTerritory2Id).children = new List<TerritoryWrapper>();
            }
            parentTerritoryWrapper.get(terr.ParentTerritory2Id).children.add(wrapTerritory(terr));
            newLevelMap.put(terr.Id,wrapTerritory(terr));
            resultMap.put(terr.Id,wrapTerritory(terr));
        }

        if(newLevelMap.size() > 0){
            getTerritoriesByParents(newLevelMap,resultMap);
        }

    }

    private static void mergeMaps(TerritoryWrapper parentTerrWrapper, Map<String, TerritoryWrapper> inputMap) {
        List<TerritoryWrapper> newRec = new List<TerritoryWrapper>();
        for(String terrId : inputMap.keySet()) {
            TerritoryWrapper terrWrapper = inputMap.get(terrId);
            if(terrWrapper.territoryItem.ParentTerritory2Id == parentTerrWrapper.territoryItem.Id){
                newRec.add(terrWrapper);
            }
        }
        if(newRec.size() > 0){
            for(TerritoryWrapper tw : newRec){
                mergeMaps(tw,inputMap);
            }
        }
        parentTerrWrapper.children = (List<TerritoryWrapper>)qsort(newRec, new TerritoryWrapperComparator());

    }

     /**
    * Apex Objects sorting method
    * @author: Krzysztof Wilczek, source apex-lang-1.14 (http://code.google.com/p/apex-lang/)
    */
    public static List<Object> qsort(List<Object> theList, ObjectComparator comparator)
    {
        return qsort(theList, comparator, true);
    }

    public static List<Object> qsort(List<Object> theList, ObjectComparator comparator, Boolean sortAsc)
    {
        return qsort(theList, 0, (theList == null ? 0 : theList.size()-1), comparator, sortAsc);
    }

    public static List<SObject> qsort(List<SObject> theList, SObjectComparator comparator)
    {
        return qsort(theList, comparator, true);
    }

    public static List<SObject> qsort(List<SObject> theList, SObjectComparator comparator, Boolean sortAsc)
    {
        return qsort(theList, 0, (theList == null ? 0 : theList.size()-1), comparator, sortAsc);
    }

    private static List<Object> qsort(List<Object> theList,
                                Integer lo0,
                                Integer hi0,
                                ObjectComparator comparator,
                                Boolean sortAsc)
    {
        Integer lo = lo0;
        Integer hi = hi0;

        if (lo >= hi) {
            return theList;
        } else if( lo == hi - 1 ) {

            if (( comparator.compare(theList[lo],theList[hi])>0 && sortAsc) ||
                  (comparator.compare(theList[lo],theList[hi])<0 && !sortAsc)
                ) {
                 Object prs = theList[lo];
                 theList[lo]         = theList[hi];
                 theList[hi]         = prs;
            }
            return theList;
        }

        Object pivot = theList[(lo + hi) / 2];
        theList[(lo + hi) / 2] = theList[hi];
        theList[hi] = pivot;

        while( lo < hi ) {
            while ((comparator.compare(theList[lo], pivot)<=0 && lo < hi && sortAsc) ||
                   (comparator.compare(theList[lo], pivot)>=0 && lo < hi && !sortAsc)
                  ) { lo++; }
            while (( comparator.compare(pivot,theList[hi])<=0 && lo < hi && sortAsc) ||
                   ( comparator.compare(pivot,theList[hi])>=0 && lo < hi && !sortAsc)
                  ) { hi--; }

            if( lo < hi ){
                 Object prs = theList[lo];
                 theList[lo]   = theList[hi];
                 theList[hi]    = prs;
            }
        }

        theList[hi0] = theList[hi];
        theList[hi] = pivot;

        qsort(theList, lo0, lo-1,comparator,sortAsc);
        qsort(theList, hi+1, hi0,comparator,sortAsc);
        return theList;
    }

    private static List<SObject> qsort(List<SObject> theList,
                                 Integer lo0,
                                 Integer hi0,
                                 SObjectComparator comparator,
                                 Boolean sortAsc)
    {
        Integer lo = lo0;
        Integer hi = hi0;

        if (lo >= hi) {
            return theList;
        } else if( lo == hi - 1 ) {

            if (( comparator.compare(theList[lo],theList[hi])>0 && sortAsc) ||
                  (comparator.compare(theList[lo],theList[hi])<0 && !sortAsc)
                ) {
                 SObject prs = theList[lo];
                 theList[lo]         = theList[hi];
                 theList[hi]         = prs;
            }
            return theList;
        }

        SObject pivot = theList[(lo + hi) / 2];
        theList[(lo + hi) / 2] = theList[hi];
        theList[hi] = pivot;

        while( lo < hi ) {
            while ((comparator.compare(theList[lo], pivot)<=0 && lo < hi && sortAsc) ||
                   (comparator.compare(theList[lo], pivot)>=0 && lo < hi && !sortAsc)
                  ) { lo++; }
            while (( comparator.compare(pivot,theList[hi])<=0 && lo < hi && sortAsc) ||
                   ( comparator.compare(pivot,theList[hi])>=0 && lo < hi && !sortAsc)
                  ) { hi--; }

            if( lo < hi ){
                 SObject prs = theList[lo];
                 theList[lo]   = theList[hi];
                 theList[hi]    = prs;
            }
        }

        theList[hi0] = theList[hi];
        theList[hi] = pivot;

        qsort(theList, lo0, lo-1,comparator,sortAsc);
        qsort(theList, hi+1, hi0,comparator,sortAsc);
        return theList;
    }

    global static TerritoryWrapper getParentTerritory(){

        //Parent territory
        List<Territory2> parentTerritories = new List<Territory2>([Select
                                    t.Id,
                                    t.Name,
                                    t.Territory_Number_gne__c
                                from Territory2 t
                                where t.Name =:SFA_CANADA_PARENT_TERRITORY LIMIT 1]);

        TerritoryWrapper parentTerritoryWrapper = wrapTerritory(parentTerritories.get(0));
        Map<String, TerritoryWrapper> newLevelMap = new Map<String, TerritoryWrapper>();
        Map<String, TerritoryWrapper> resultMap = new Map<String, TerritoryWrapper>();
        newLevelMap.put(parentTerritories.get(0).Id, parentTerritoryWrapper);
        getTerritoriesByParents(newLevelMap, resultMap);

        mergeMaps(parentTerritoryWrapper,resultMap);

        return parentTerritoryWrapper;
    }


    private Boolean isGeneralAudience(Id questionaryId){
        List<Questionnaire_gne__c> quests = [SELECT id,Audience_Type_gne__c
                                      FROM Questionnaire_gne__c where id = :questionaryId];

        if(quests != null && quests.size() > 0 && quests.get(0).Audience_Type_gne__c == 'General'){
            return true;
        }else{
            return false;
        }

    }

    private static Set<Id> filtrAccountToTargetedOnly(Set<Id> accountIds){

        List<Product_Metrics_vod__c> brandAffilations = [SELECT id,
                                                                Account_vod__c,
                                                                Account_vod__r.IsPersonAccount,
                                                                Target_can_gne__c
                                                         FROM Product_Metrics_vod__c
                                                         WHERE Account_vod__c in :accountIds
                                                            AND Target_can_gne__c = true
                                                            AND Account_vod__r.IsPersonAccount = true
                                                           ];


        Set<Id> resultAccountsIds = new Set<Id>();
        for(Product_Metrics_vod__c brandAff : brandAffilations){
            resultAccountsIds.add(brandAff.Account_vod__c);
        }
        return  resultAccountsIds;
    }


}