public with sharing class EDM_AABP_Multiple_Update_Controller extends GNE_SFA2_List_View_Base_Controller {
  public GNE_SFA2_List_View_Base_Controller baseListController {get;set;}
  public Paginate paginater {get;set;}
  public List<EDM_AABP_Wrapper> genericList {get;set;}
  public List<List<EDM_AABP_Wrapper>> fullGenericList {get;set;}
  public static final Integer QUERY_LIMIT = 50000;
  public static final Integer PAGE_SIZE = 50;
  public static final String MANAGER_SORT = 'manager';
  public static final String NAME_SORT = 'name';
  public static final String YEAR_SORT = 'year';
  public static final String GROUP_SORT = 'group';
  public static final String UNIT_SORT = 'unit';    
  public static final String TEAM_SORT = 'team';
  public static final String DETAIL_SORT = 'detail';
  public static final String LEAD_SORT = 'lead';
  public static final String EVENT_SORT = 'event';
  public static String SORT_BY = MANAGER_SORT;
  public static String SORT_METHOD;
  public String sortKey {get;set;}
  public String sortOrder {get;set;}
  public List<SelectOption> newManagerOptions {get;set;}
  public Id selectedManagerId {get;set;}
  public String nameOfThePage {get;set;}
  public String filterBy {get;set;}
  public String selectedFilter {get;set;}
  public List<SelectOption> filtersList {get;set;}
  List<SFA2_View_Config_gne__c> viewConfigList;
  public SFA2_View_Config_gne__c currentViewConfig {get;set;}
  public List<String> filters {get;set;}
  public String sfBaseLink {get;set;}
  public String listPageName {get;set;}
  public Boolean isOddIteration;
  private String query;

  public EDM_AABP_Multiple_Update_Controller() {
    super('Call2_vod__c');
    baseListController = this;
    sfBaseLink = URL.getSalesforceBaseUrl().toExternalForm();
    newManagerOptions = new List<SelectOption>();
    listPageName = 'AABP Multiple Update';
    isOddIteration = false;

    SFA2_Configuration_Object_gne__c pageConfiguration = GNE_SFA2_Util.getListPageConfiguration('EDM_AABP_gne__c');

    if(pageConfiguration != null) {
      nameOfThePage = pageConfiguration.Section_Header_gne__c;
    } else {
      nameOfThePage = '';
    }

    viewConfigList = [
      SELECT Id, OwnerId, View_Name_gne__c, View_Fields_gne__c, Sorting_Field_gne__c, Sorting_Order_gne__c, Filter_Statement_gne__c, Person_Record_Types_gne__c, Account_Record_Types_gne__c, Product_gne__c
      FROM SFA2_View_Config_gne__c
      WHERE ((Visibility_gne__c='private' AND OwnerId = :UserInfo.getUserId()) OR Visibility_gne__c='public') AND Page_Name_gne__c = :nameOfThePage ORDER BY View_Name_gne__c
    ];

    filtersList = new List<SelectOption>();
    filtersList.add(new SelectOption('ALL_AABPS', 'All AABPs'));

    for(SFA2_View_Config_gne__c vc : viewConfigList) {
      filtersList.add(new SelectOption(vc.View_Name_gne__c, vc.View_Name_gne__c));
    }

    for(User usr : [SELECT Id, Name FROM User WHERE Profile.Name = 'GNE-TLS-AB-SB-Admin']) {
      newManagerOptions.add(new SelectOption(usr.Id, usr.Name));
    }

    List<EDM_AABP_Wrapper> resultsList = populateData();
    this.paginater = new Paginate(resultsList.size(), PAGE_SIZE);

    this.fullGenericList = new List<List<EDM_AABP_Wrapper>>();
    this.genericList = new List<EDM_AABP_Wrapper>();

    if(resultsList.size() > 0) {
      List<EDM_AABP_Wrapper> tempCC = new List<EDM_AABP_Wrapper>();
      Integer i = 0;

      for(EDM_AABP_Wrapper cc : resultsList){
        tempCC.add(cc);
        i++;
        if(i == PAGE_SIZE){
          this.fullGenericList.add(tempCC);
          tempCC = new List<EDM_AABP_Wrapper>();
          i = 0;
        }
      }

      if(!tempCC.isEmpty()) {
        this.fullGenericList.add(tempCC);
      }

      this.genericList = this.fullGenericList.get(this.paginater.index);
    }

    sortByManager();
  }

  public PageReference applyFilter1() {
    if(filterBy == null || filterBy == '') {
      return applyFilter2();
    }

    filterBy = filterBy.trim();
    filterBy = String.escapeSingleQuotes(filterBy);

    if(selectedFilter.equals('ALL_AABPS')) {
      query = 'SELECT Id, Name, EDM_ABS_Manager_gne__c, EDM_ABS_Manager_gne__r.Name, EDM_Plan_Year_gne__c, EDM_Group_gne__c, EDM_Unit_gne__c, EDM_Team_gne__c, EDM_AABP_Optional_Detail_gne__c, EDM_AB_Lead_gne__c, EDM_AB_Lead_gne__r.Name, EDM_Total_Number_of_Meetings_gne__c FROM EDM_AABP_gne__c WHERE (EDM_ABS_Manager_gne__r.Name LIKE \'%' + filterBy + '%\' OR Name LIKE \'%' + filterBy + '%\' OR EDM_Plan_Year_gne__c = \'' + filterBy + '\' OR EDM_Group_gne__c LIKE \'%' + filterBy + '%\' OR EDM_Unit_gne__c LIKE \'%' + filterBy + '%\' OR EDM_Unit_gne__c LIKE \'%' + filterBy + '%\' OR EDM_Team_gne__c LIKE \'%' + filterBy + '%\' OR EDM_AABP_Optional_Detail_gne__c LIKE \'%' + filterBy + '%\' OR EDM_AB_Lead_gne__r.Name LIKE \'%' + filterBy + '%\') ';
      currentViewConfig = null;
    } else {
      for(SFA2_View_Config_gne__c vc : viewConfigList) {
        if(vc.View_Name_gne__c.equals(selectedFilter)) {
          currentViewConfig = vc;
          break;
        }
      }

      filters = getFiltersBySelectedView(currentViewConfig);

      query = 'SELECT Id, Name, EDM_ABS_Manager_gne__c, EDM_ABS_Manager_gne__r.Name, EDM_Plan_Year_gne__c, EDM_Group_gne__c, EDM_Unit_gne__c, EDM_Team_gne__c, EDM_AABP_Optional_Detail_gne__c, EDM_AB_Lead_gne__c, EDM_AB_Lead_gne__r.Name, EDM_Total_Number_of_Meetings_gne__c FROM EDM_AABP_gne__c WHERE (EDM_ABS_Manager_gne__r.Name LIKE \'%' + filterBy + '%\' OR Name LIKE \'%' + filterBy + '%\' OR EDM_Plan_Year_gne__c = \'' + filterBy + '\' OR EDM_Group_gne__c LIKE \'%' + filterBy + '%\' OR EDM_Unit_gne__c LIKE \'%' + filterBy + '%\' OR EDM_Unit_gne__c LIKE \'%' + filterBy + '%\' OR EDM_Team_gne__c LIKE \'%' + filterBy + '%\' OR EDM_AABP_Optional_Detail_gne__c LIKE \'%' + filterBy + '%\' OR EDM_AB_Lead_gne__r.Name LIKE \'%' + filterBy + '%\') AND ';

      if(filters!=null && !filters.isEmpty()) {
        for(String s : filters) {
          query += s + ' AND ';
        }
      }

      query = query.removeEnd(' AND ');
      query += ' LIMIT ' + QUERY_LIMIT;
    }

    try{

      List<EDM_AABP_Wrapper> EDM_AABP_AfterSortList = wrapAABPList(Database.query(query));
      this.paginater = new Paginate(EDM_AABP_AfterSortList.size(), PAGE_SIZE);

      this.fullGenericList = new List<List<EDM_AABP_Wrapper>>();
      this.genericList = new List<EDM_AABP_Wrapper>();

      if(EDM_AABP_AfterSortList.size() > 0) {
        List<EDM_AABP_Wrapper> tempCC = new List<EDM_AABP_Wrapper>();
        Integer i = 0;

        for(EDM_AABP_Wrapper cc : EDM_AABP_AfterSortList){
          tempCC.add(cc);
          i++;
          if(i == PAGE_SIZE){
            this.fullGenericList.add(tempCC);
            tempCC = new List<EDM_AABP_Wrapper>();
            i = 0;
          }
        }

        if(!tempCC.isEmpty()) {
          this.fullGenericList.add(tempCC);
        }

        this.genericList = this.fullGenericList.get(this.paginater.index);
      }

      sortKey = 'MANAGER';
    } catch(Exception ex) {
      System.debug(ex.getMessage());
    }

    return null;
  }

  public PageReference applyFilter2() {
    if(selectedFilter.equals('ALL_AABPS')) {
      query = 'SELECT Id, Name, EDM_ABS_Manager_gne__c, EDM_ABS_Manager_gne__r.Name, EDM_Plan_Year_gne__c, EDM_Group_gne__c, EDM_Unit_gne__c, EDM_Team_gne__c, EDM_AABP_Optional_Detail_gne__c, EDM_AB_Lead_gne__c, EDM_AB_Lead_gne__r.Name, EDM_Total_Number_of_Meetings_gne__c FROM EDM_AABP_gne__c';
      currentViewConfig = null;
    } else {
      for(SFA2_View_Config_gne__c vc : viewConfigList) {
        if(vc.View_Name_gne__c.equals(selectedFilter)) {
          currentViewConfig = vc;
          break;
        }
      }

      filters = getFiltersBySelectedView(currentViewConfig);

      query = 'SELECT Id, Name, EDM_ABS_Manager_gne__c, EDM_ABS_Manager_gne__r.Name, EDM_Plan_Year_gne__c, EDM_Group_gne__c, EDM_Unit_gne__c, EDM_Team_gne__c, EDM_AABP_Optional_Detail_gne__c, EDM_AB_Lead_gne__c, EDM_AB_Lead_gne__r.Name, EDM_Total_Number_of_Meetings_gne__c FROM EDM_AABP_gne__c';

      if(filters!=null && !filters.isEmpty()) {
        query += ' WHERE ';

        for(String s : filters) {
          query += s + ' AND ';
        }

        query = query.removeEnd(' AND ');
      }

      query += ' LIMIT ' + QUERY_LIMIT;
    }

    try{
      List<EDM_AABP_Wrapper> EDM_AABP_AfterSortList = wrapAABPList(Database.query(query));
      this.paginater = new Paginate(EDM_AABP_AfterSortList.size(), PAGE_SIZE);

      this.fullGenericList = new List<List<EDM_AABP_Wrapper>>();
      this.genericList = new List<EDM_AABP_Wrapper>();

      if(EDM_AABP_AfterSortList.size() > 0) {
        List<EDM_AABP_Wrapper> tempCC = new List<EDM_AABP_Wrapper>();
        Integer i = 0;

        for(EDM_AABP_Wrapper cc : EDM_AABP_AfterSortList){
          tempCC.add(cc);
          i++;
          if(i == PAGE_SIZE){
            this.fullGenericList.add(tempCC);
            tempCC = new List<EDM_AABP_Wrapper>();
            i = 0;
          }
        }

        if(!tempCC.isEmpty()) {
          this.fullGenericList.add(tempCC);
        }

        this.genericList = this.fullGenericList.get(this.paginater.index);
      }

      sortKey = 'MANAGER';
    } catch(Exception ex) {
      System.debug(ex.getMessage());
    }

    return null;
  }

  private List<String> getFiltersBySelectedView(SFA2_View_Config_gne__c selectedView){
    List<String> filters = new List<String>();
    if(selectedView.Filter_Statement_gne__c != null && selectedView.Filter_Statement_gne__c != '') {
      List<GNE_SFA2_List_View_Setup_Ext.ConditionItem>conditionItems = (List<GNE_SFA2_List_View_Setup_Ext.ConditionItem>)JSON.deserializeStrict(selectedView.Filter_Statement_gne__c,  List<GNE_SFA2_List_View_Setup_Ext.ConditionItem>.class);
      for(Integer i=0; i<conditionItems.size(); i++) {
        GNE_SFA2_List_View_Setup_Ext.ConditionItem conditionItem = conditionItems.get(i);
        String filterExpr = conditionItem.field;
        
        if(conditionItem.valueType == 'PICKLIST'){
          if(conditionItem.operator=='inc'){
            filterExpr += ' IN '+GNE_SFA2_Util.createInListForQueryNotEscaping(conditionItem.multiValue);
          }else if(conditionItem.operator=='ecl'){
            filterExpr += ' NOT IN '+GNE_SFA2_Util.createInListForQueryNotEscaping(conditionItem.multiValue);
          }
        } else if(conditionItem.valueType == 'MULTIPICKLIST'){
          if(conditionItem.operator == 'inc'){
            filterExpr += ' INCLUDES '+GNE_SFA2_Util.createInListForQueryNotEscaping(conditionItem.multiValue);
          } else if(conditionItem.operator=='ecl'){
            filterExpr += ' EXCLUDES '+GNE_SFA2_Util.createInListForQueryNotEscaping(conditionItem.multiValue);
          }
        } else if(conditionItem.valueType == 'BOOLEAN') {
          if(conditionItem.operator == 'eq'){
            filterExpr += ' = '+conditionItem.value;
          } else if(conditionItem.operator == 'ne'){
            filterExpr += ' != '+conditionItem.value;
          }
           
        } else if(conditionItem.valueType=='STRING'||conditionItem.valueType=='EMAIL'||conditionItem.valueType=='URL' || conditionItem.valueType=='PHONE' || conditionItem.valueType=='REFERENCE' || conditionItem.valueType=='COMBOBOX') {
          if(conditionItem.valueType=='REFERENCE' && conditionItem.value=='CURRENT_USER') {
            conditionItem.value = UserInfo.getUserId();
          }
                            
          if(conditionItem.operator=='eq'){
            filterExpr += ' = \''+ String.escapeSingleQuotes(conditionItem.value) +'\'';
          }else if(conditionItem.operator=='ne'){
            filterExpr += ' != \''+String.escapeSingleQuotes(conditionItem.value)+'\'';
          }else if(conditionItem.operator=='lt'){
            filterExpr += ' < \''+String.escapeSingleQuotes(conditionItem.value)+'\'';
          }else if(conditionItem.operator=='lte'){
            filterExpr += ' <= \''+String.escapeSingleQuotes(conditionItem.value)+'\'';
          }else if(conditionItem.operator=='gt'){
            filterExpr += ' > \''+String.escapeSingleQuotes(conditionItem.value)+'\'';
          }else if(conditionItem.operator=='gte'){
            filterExpr += ' >= \''+String.escapeSingleQuotes(conditionItem.value)+'\'';
          }else if(conditionItem.operator=='c'){
            filterExpr += ' LIKE \'%'+String.escapeSingleQuotes(conditionItem.value)+'%\'';
          }else if(conditionItem.operator=='nc'){
            filterExpr =  '(NOT ' + +conditionItem.field + ' LIKE \'%'+String.escapeSingleQuotes(conditionItem.value)+'%\')';
          }else if(conditionItem.operator=='sw'){
            filterExpr += ' LIKE \''+String.escapeSingleQuotes(conditionItem.value)+'%\'';
          }
        } else if(conditionItem.valueType=='CUSTOM_FILTER') {
          filterExpr = baseListController.getCustomFilterExpression(conditionItem);
          if(String.isBlank(filterExpr)) {
            continue;
          }
        } else {
          String value='';
          boolean do_not_split=false;
          Boolean needQuotes = true;                    
            try{
              if (conditionItem.valueType=='DOUBLE'||conditionItem.valueType=='CURRENCY'||conditionItem.valueType=='PERCENT'){
                value = Double.valueOf(conditionItem.value).format();
                needQuotes = false;
              } else if(conditionItem.valueType=='INTEGER'){
                value = Integer.valueOf(conditionItem.value).format();
                needQuotes = false;
              } else if(conditionItem.valueType=='DATE') {
                if(conditionItem.value.equals('TODAY')) {
                  String currentDate_T=String.valueOf(System.today());
                  System.debug('**date today value'+currentDate_T);
                  String[] today_Parts = currentDate_T.split('-');
                  conditionItem.value=today_Parts[1]+'/'+today_Parts[2]+'/'+today_Parts[0];                                   
                }
                
                String[] dateParts = conditionItem.value.split('/');
                DateTime dtime = DateTime.newInstance(Integer.valueOf(dateParts[2]), Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]));
                value = dtime.format('yyyy-MM-dd');
                needQuotes = false;
              } else if (conditionItem.valueType=='DATETIME'){
                if(conditionItem.value.equals('TODAY'))
                {
                  String currentDate_T=String.valueOf(System.today());
                  String[] today_Parts = currentDate_T.split('-');
                  conditionItem.value=today_Parts[1]+'/'+today_Parts[2]+'/'+today_Parts[0];                                   
                }
                else if(conditionItem.value.contains('_N_DAYS'))
                {
                  do_not_split = true;
                }
                 String[] dateParts = conditionItem.value.split('/');
                                             
                filterExpr = String.format('DAY_ONLY(CONVERTTIMEZONE({0}))', new String[]{filterExpr});
                if(!do_not_split)
                {
                 DateTime dtime = DateTime.newInstance(Integer.valueOf(dateParts[2]), Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), 0, 0, 0);
                 value = dtime.format('yyyy-MM-dd');
                }
                else{
                  value=conditionItem.value;
                }
                 needQuotes = false;
              } else if(conditionItem.valueType=='ID'){
                Id tmpId = conditionItem.value;
                value = tmpId;
              } else{
                value = conditionItem.value;
              }
            } catch(Exception e){
              System.debug(e.getMessage());
            }
          if(conditionItem.operator=='eq'){
              filterExpr +=  ' = ' + (needQuotes ? ('\''+value+'\'') : value);
          }else if(conditionItem.operator=='ne'){
              filterExpr +=  ' != ' + (needQuotes ? ('\''+value+'\'') : value);
          }else if(conditionItem.operator=='lt'){
              filterExpr +=  ' < ' + (needQuotes ? ('\''+value+'\'') : value);
          }else if(conditionItem.operator=='lte'){
              filterExpr +=  ' <= ' + (needQuotes ? ('\''+value+'\'') : value);
          }else if(conditionItem.operator=='gt'){
              filterExpr +=  ' > ' + (needQuotes ? ('\''+value+'\'') : value);
          }else if(conditionItem.operator=='gte'){
              filterExpr +=  ' >= ' + (needQuotes ? ('\''+value+'\'') : value);
          }
        }
        filters.add(filterExpr);                    
      }
    }
    
    populateCustomFilterVariables();
    
    return filters;
  }
    
  private void populateCustomFilterVariables() {
      customFilterVariable_1  = baseListController.customFilterVariable_1;
      customFilterVariable_2  = baseListController.customFilterVariable_2;
      customFilterVariable_3  = baseListController.customFilterVariable_3;
      customFilterVariable_4  = baseListController.customFilterVariable_4;
      customFilterVariable_5  = baseListController.customFilterVariable_5;
      customFilterVariable_6  = baseListController.customFilterVariable_6;
      customFilterVariable_7  = baseListController.customFilterVariable_7;
      customFilterVariable_8  = baseListController.customFilterVariable_8;
      customFilterVariable_9  = baseListController.customFilterVariable_9;
      customFilterVariable_10 = baseListController.customFilterVariable_10;
  }

  public List<List<EDM_AABP_Wrapper>> constructFullGenericList(List<EDM_AABP_Wrapper> oldGenericList) {
    List<List<EDM_AABP_Wrapper>> newFullGenericList = new List<List<EDM_AABP_Wrapper>>();

    if(oldGenericList.size() > 0) {
      List<EDM_AABP_Wrapper> tempCC = new List<EDM_AABP_Wrapper>();
      Integer i = 0;

      for(EDM_AABP_Wrapper cc : oldGenericList){
        tempCC.add(cc);
        i++;
        if(i == PAGE_SIZE){
          newFullGenericList.add(tempCC);
          tempCC = new List<EDM_AABP_Wrapper>();
          i = 0;
        }
      }

      if(!tempCC.isEmpty()) {
        newFullGenericList.add(tempCC);
      }
    }

    return newFullGenericList;
  }

  public List<EDM_AABP_Wrapper> convertFullGenericListToOrdinaryList(List<List<EDM_AABP_Wrapper>> fullGenericList) {
    List<EDM_AABP_Wrapper> newOrdinaryList = new List<EDM_AABP_Wrapper>();

    for(List<EDM_AABP_Wrapper> edmList : fullGenericList) {
      newOrdinaryList.addAll(edmList);
    }

    return newOrdinaryList;
  }

  public void reverse_EDM_List(List<EDM_AABP_Wrapper> edm_AABP_List) {
    List<EDM_AABP_Wrapper> cloned_edm_AABP_List = edm_AABP_List.clone();
    edm_AABP_List.clear();

    for(Integer i = cloned_edm_AABP_List.size() - 1; i >= 0; i--){
      edm_AABP_List.add(cloned_edm_AABP_List[i]);
    }
  }

  public void basicSortingLogic() {
    List<EDM_AABP_Wrapper> ordinaryEDM_AABP_List = convertFullGenericListToOrdinaryList(this.fullGenericList);
    if(ordinaryEDM_AABP_List == null || ordinaryEDM_AABP_List.size() < 1) {
      return;
    }
    ordinaryEDM_AABP_List.sort();

    if(isOddIteration) {
      isOddIteration = false;
      reverse_EDM_List(ordinaryEDM_AABP_List);
      sortOrder = 'DSC';
    } else {
      isOddIteration = true;
      sortOrder = 'ASC';
    }

    this.fullGenericList = constructFullGenericList(ordinaryEDM_AABP_List);
    changeData();
  }

  public PageReference sortByManager() {
    if(sortKey != 'MANGER') {
      sortKey = 'MANAGER';
      sortOrder = 'DSC';
    }

    EDM_AABP_Multiple_Update_Controller.SORT_BY = EDM_AABP_Multiple_Update_Controller.MANAGER_SORT;
    basicSortingLogic();

    return null;
  }

  public PageReference sortByName() {
    if(sortKey != 'NAME') {
      sortKey = 'NAME';
      sortOrder = 'DSC';
    }

    EDM_AABP_Multiple_Update_Controller.SORT_BY = EDM_AABP_Multiple_Update_Controller.NAME_SORT;
    basicSortingLogic();
    return null;
  }

  public PageReference sortByYear() {
    if(sortKey != 'YEAR') {
      sortKey = 'YEAR';
      sortOrder = 'DSC';
    }

    EDM_AABP_Multiple_Update_Controller.SORT_BY = EDM_AABP_Multiple_Update_Controller.YEAR_SORT;
    basicSortingLogic();
    return null;
  }

  public PageReference sortByGroup() {
    if(sortKey != 'GROUP') {
      sortKey = 'GROUP';
      sortOrder = 'DSC';
    }

    EDM_AABP_Multiple_Update_Controller.SORT_BY = EDM_AABP_Multiple_Update_Controller.GROUP_SORT;
    basicSortingLogic();
    return null;
  }

  public PageReference sortByUnit() {
    if(sortKey != 'UNIT') {
      sortKey = 'UNIT';
      sortOrder = 'DSC';
    }

    EDM_AABP_Multiple_Update_Controller.SORT_BY = EDM_AABP_Multiple_Update_Controller.UNIT_SORT;
    basicSortingLogic();
    return null;
  }

  public PageReference sortByTeam() {
    if(sortKey != 'TEAM') {
      sortKey = 'TEAM';
      sortOrder = 'DSC';
    }

    EDM_AABP_Multiple_Update_Controller.SORT_BY = EDM_AABP_Multiple_Update_Controller.TEAM_SORT;
    basicSortingLogic();
    return null;
  }

  public PageReference sortByDetail() {
    if(sortKey != 'DETAIL') {
      sortKey = 'DETAIL';
      sortOrder = 'DSC';
    }

    EDM_AABP_Multiple_Update_Controller.SORT_BY = EDM_AABP_Multiple_Update_Controller.DETAIL_SORT;
    basicSortingLogic();
    return null;
  }

  public PageReference sortByLead() {
    if(sortKey != 'LEAD') {
      sortKey = 'LEAD';
      sortOrder = 'DSC';
    }

    EDM_AABP_Multiple_Update_Controller.SORT_BY = EDM_AABP_Multiple_Update_Controller.LEAD_SORT;
    basicSortingLogic();
    return null;
  }

  public PageReference sortByEvents() {
    if(sortKey != 'EVENTS') {
      sortKey = 'EVENTS';
      sortOrder = 'DSC';
    }

    EDM_AABP_Multiple_Update_Controller.SORT_BY = EDM_AABP_Multiple_Update_Controller.EVENT_SORT;
    basicSortingLogic();
    return null;
  }

  public PageReference previousPage() {
    this.paginater.decrement();
    return changeData();
  }

  public PageReference nextPage() {
    this.paginater.increment();
    return changeData();
  }

  public PageReference updatePage() {
    this.paginater.updateNumbers();
    return changeData();
  }

  public PageReference changeData() {
    this.genericList = this.fullGenericList.get(this.paginater.index);
    return null;
  }

  public List<EDM_AABP_Wrapper> wrapAABPList(List<EDM_AABP_gne__c> aabpList) {
    List<EDM_AABP_Wrapper> edmAABPWrapperList = new List<EDM_AABP_Wrapper>();

    for(EDM_AABP_gne__c edmAABP : aabpList) {
      edmAABPWrapperList.add(new EDM_AABP_Wrapper(edmAABP));
    }

    return edmAABPWrapperList;
  }

  public List<EDM_AABP_Wrapper> populateData() {
    return wrapAABPList([
      SELECT Id, Name, EDM_ABS_Manager_gne__c, EDM_ABS_Manager_gne__r.Name, EDM_Plan_Year_gne__c, EDM_Group_gne__c, EDM_Unit_gne__c, EDM_Team_gne__c, EDM_AABP_Optional_Detail_gne__c, EDM_AB_Lead_gne__c, EDM_AB_Lead_gne__r.Name, EDM_Total_Number_of_Meetings_gne__c
      FROM EDM_AABP_gne__c
      LIMIT :QUERY_LIMIT
    ]);
  }

  static public Boolean validateId(String idParam) {
    String id = String.escapeSingleQuotes(idParam);
    if((id.length() == 15 || id.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', id)) {
      return true;
    }
    return false;
  }

  static public Boolean validateNumber(String numberText) {
    return numberText.isNumeric();
  }

  static public Boolean validateText(String text) {
    return text.isAsciiPrintable();
  }

  static public Boolean filterOptionFilled(String filterOption) {
    return filterOption != null && filterOption != '' ? true : false;
  }

  public PageReference save() {
    List<EDM_AABP_Wrapper> ordinaryEDM_AABP_List = convertFullGenericListToOrdinaryList(this.fullGenericList);

    List<EDM_AABP_gne__c> edm_aabps_ListToUpdate = new List<EDM_AABP_gne__c>();

    for(EDM_AABP_Wrapper edm_aabp_Wrapper : ordinaryEDM_AABP_List) {
      if(edm_aabp_Wrapper.isSelected) {
        edm_aabp_Wrapper.aabp.EDM_ABS_Manager_gne__c = selectedManagerId;
        edm_aabps_ListToUpdate.add(edm_aabp_Wrapper.aabp);
      }
    }

    try {
      update edm_aabps_ListToUpdate;
    } catch(Exception ex) {
      System.debug(ex.getMessage());
    } 

    PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
    pageRef.setRedirect(true);
    return pageRef;
  }

  public class EDM_AABP_Wrapper implements Comparable {
    public Boolean isSelected {get;set;}
    public EDM_AABP_gne__c aabp {get;set;}

    public EDM_AABP_Wrapper(EDM_AABP_gne__c aabp) {
      isSelected = false;
      this.aabp = aabp;
    }

    public Integer compareTo(Object obj) {
      EDM_AABP_Wrapper edmWrapper = (EDM_AABP_Wrapper)(obj);

      if(SORT_BY == NAME_SORT) {
        return sortByName(edmWrapper);
      } else if(SORT_BY == YEAR_SORT) {
        return sortByYear(edmWrapper);
      } else if(SORT_BY == MANAGER_SORT) {
        return sortByManager(edmWrapper);
      } else if(SORT_BY == GROUP_SORT) {
        return sortByGroup(edmWrapper);
      } else if(SORT_BY == UNIT_SORT) {
        return sortByUnit(edmWrapper);
      } else if(SORT_BY == TEAM_SORT) {
        return sortByTeam(edmWrapper);
      } else if(SORT_BY == DETAIL_SORT) {
        return sortByDetail(edmWrapper);
      } else if(SORT_BY == LEAD_SORT) {
        return sortByLead(edmWrapper);
      } else if(SORT_BY == EVENT_SORT) {
        return sortByEvents(edmWrapper);
      }
      return 0;
    }

    private Integer sortByName(EDM_AABP_Wrapper edmWrapper) {
      if(this.aabp.Name > edmWrapper.aabp.Name) {
        return 1;
      } else if(this.aabp.Id == edmWrapper.aabp.Id) {
        return 0;
      }
      return -1;
    }

    private Integer sortByYear(EDM_AABP_Wrapper edmWrapper) {
      if(this.aabp.EDM_Plan_Year_gne__c > edmWrapper.aabp.EDM_Plan_Year_gne__c) {
        return 1;
      } else if(this.aabp.EDM_Plan_Year_gne__c == edmWrapper.aabp.EDM_Plan_Year_gne__c) {
        return 0;
      }
      return -1;
    }

    private Integer sortByManager(EDM_AABP_Wrapper edmWrapper) {
      if(this.aabp.EDM_ABS_Manager_gne__r.Name > edmWrapper.aabp.EDM_ABS_Manager_gne__r.Name) {
        return 1;
      } else if(this.aabp.EDM_ABS_Manager_gne__r.Name == edmWrapper.aabp.EDM_ABS_Manager_gne__r.Name) {
        return 0;
      }
      return -1;
    }

    private Integer sortByGroup(EDM_AABP_Wrapper edmWrapper) {
      if(this.aabp.EDM_Group_gne__c > edmWrapper.aabp.EDM_Group_gne__c) {
        return 1;
      } else if(this.aabp.EDM_Group_gne__c == edmWrapper.aabp.EDM_Group_gne__c) {
        return 0;
      }
      return -1;
    }

    private Integer sortByUnit(EDM_AABP_Wrapper edmWrapper) {
      if(this.aabp.EDM_Unit_gne__c > edmWrapper.aabp.EDM_Unit_gne__c) {
        return 1;
      } else if(this.aabp.EDM_Unit_gne__c == edmWrapper.aabp.EDM_Unit_gne__c) {
        return 0;
      }
      return -1;
    }

    private Integer sortByTeam(EDM_AABP_Wrapper edmWrapper) {
      if(this.aabp.EDM_Team_gne__c > edmWrapper.aabp.EDM_Team_gne__c) {
        return 1;
      } else if(this.aabp.EDM_Team_gne__c == edmWrapper.aabp.EDM_Team_gne__c) {
        return 0;
      }
      return -1;
    }

    private Integer sortByDetail(EDM_AABP_Wrapper edmWrapper) {
      if(this.aabp.EDM_AABP_Optional_Detail_gne__c > edmWrapper.aabp.EDM_AABP_Optional_Detail_gne__c) {
        return 1;
      } else if(this.aabp.EDM_AABP_Optional_Detail_gne__c == edmWrapper.aabp.EDM_AABP_Optional_Detail_gne__c) {
        return 0;
      }
      return -1;
    }

    private Integer sortByLead(EDM_AABP_Wrapper edmWrapper) {
      if(this.aabp.EDM_AB_Lead_gne__r.Name > edmWrapper.aabp.EDM_AB_Lead_gne__r.Name) {
        return 1;
      } else if(this.aabp.EDM_AB_Lead_gne__r.Name == edmWrapper.aabp.EDM_AB_Lead_gne__r.Name) {
        return 0;
      }
      return -1;
    }

    private Integer sortByEvents(EDM_AABP_Wrapper edmWrapper) {
      if(this.aabp.EDM_Total_Number_of_Meetings_gne__c > edmWrapper.aabp.EDM_Total_Number_of_Meetings_gne__c) {
        return 1;
      } else if(this.aabp.EDM_Total_Number_of_Meetings_gne__c == edmWrapper.aabp.EDM_Total_Number_of_Meetings_gne__c) {
        return 0;
      }
      return -1;
    }
  }

  public class Paginate {
    public Integer index {get;set;}
    public Integer pageNum {get;set;}
    public Integer totalPage {get;set;}
    public Integer totalResults {get;set;}
    public List<Pager> pageList {get;set;}
    public Boolean showPrevious {get;set;}
    public Boolean showNext {get;set;}
    public Boolean isAll {get;set;}

    public Paginate(Integer listSize, Integer pageSize) {
      this.totalResults = listSize;
      pageSize = (pageSize > 0) ? pageSize : 10;
      this.totalPage = (Integer)Math.ceil((Double)listSize / (Double)pageSize);
      this.pageNum = 1;
      this.index = 0;
      this.isAll = (listSize == pageSize) ? true : false;
      updateNumbers();
    }

    public void updateNumbers() {
      this.pageList = new List<Pager>();
      for(Integer i = 1; i < (this.totalPage + 1); i++) {
        Boolean b = (i == pageNum) ? true:false;
        this.pageList.add(new Pager(i, b));
      }
      this.showPrevious = (this.pageNum == 1) ? false : true;
      this.showNext = (this.pageNum == this.totalPage) ? false : true;
      this.index = this.pageNum - 1;
    }

    public void decrement() {
      this.pageNum = this.pageNum - 1;
      updateNumbers();
    }

    public void increment() {
      this.pageNum++;
      updateNumbers();
    }
  }

  public class Pager {
    public Integer pageNum {get;set;}
    public Boolean isActive {get;set;}

    public Pager(Integer num, Boolean active){
      this.pageNum = num;
      this.isActive = active;
    }
  }
}