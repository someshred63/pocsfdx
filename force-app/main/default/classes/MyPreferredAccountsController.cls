public with sharing class MyPreferredAccountsController {

        public integer currentPageIndex{get;set;}
        public List<String> pageNumbers{get;set;}
        public boolean noRecords{get;set;}
        public List<SelectOption> lstFilters{get;set;}
        public List<String> keywords{get;set;}
        public String AccountId{get;set;}
        public String ContactId{get;set;}
        public String selectedFilter{get;set;}
        public Static string selFilter{get;set;}
        public Integer lastIndex { get;set; }
        public Integer totalCaseCount{get{if(totalCaseCount == null){ totalCaseCount = 0;} return totalCaseCount;}set;}
        public string likekeyword{get;set;}
        public boolean isKeySearhValid{get;set;}
        public String  queryString  {get;set;}
        public integer pageSize{
        	get{
        		if(pageSize == null)
        		  pageSize = 50;
        		return pageSize;
        	}
        	set;}
        public string initSearch {
            get{
                 return '';
            }set;
        }
        private dynamicObject obj;
        private boolean isAdminUser;

        public string whereCondition{get;set;}

        public String sortDirectionImageSrc{
            get{
                sortDirectionImageSrc = '/img/sort_' + sortDirection + '_arrow.gif';
                return sortDirectionImageSrc;
            }
            set;
        }

        public Map<String,String> columnMap {get;set;}

        public string sortColumn {get; set;}

        public string selectedColumn {get;set;}

        public string sortDirection {get;set;}

        public MyPreferredAccountsController(){
            initializeVariables();
            sObjectName='tsf_vod__c' ;
            sObjectNameLabel='Accounts List';
            sObjectColumnNames = 'Account_vod__r.Name,Address_vod__r.Name,Address_vod__r.City_vod__c,Address_vod__r.State_vod__c,Last_Interaction_Date_gne__c';
	        sObjectColumnNamesLabels = 'Name,Street Address,City,State,Last Interaction Date' ;
        }

        public void SearchOnChangeType(){
        	initializeVariables();
        	doSearch();
        }
        public void filteredSearch(){
        	doSearch();
        }
        public void initializeVariables(){
        	this.lstFilters = new List<SelectOption>();
            this.Results = new List<dynamicObject>();
            this.pageNumbers = new List<String>();
            this.currentPageIndex = 0;
            this.selectedFilter = '1';
            this.sortDirection = 'asc';
            this.whereCondition = '';
            this.sortColumn = 'Name';
            this.initKeywords();
            this.noRecords = true;
        }
        public List<SelectOption> allViewType{
            get{
                if(allViewType == null ) {
                   allViewType = new List<SelectOption>();
                   allViewType.add(new selectOption('My HCPs','My HCPs'));
                   allViewType.add(new selectOption('My HCOs','My HCOs'));
                }
                return allViewType;
            }set;
        }

        public string selectedViewType {
        	get{
        		if(selectedViewType == null){
        		  selectedViewType = 'My HCOs';
        		}
        		return selectedViewType;
        	}
        	set;}

        public void initKeywords(){
            this.keywords = new List<String>();
            List<String> letters = new List<String>{'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q',
                 'R','S','T','U','V','W','X','Y','Z'};
            for (String letter : letters) {
                this.keywords.add(letter);
            }
        }

        public PageReference doPaging(){
            doSearch();
            return null;
        }

        public PageReference doSorting(){
            sortDirection = (sortDirection == 'asc' ? 'desc' : 'asc');
            this.currentPageIndex = 1;
            doSearch();
            return null;
        }
        public string oldSelectedFilter{get;set;}
        public string oldsortColumn{get;set;}

        public String territoryName{
        get{
        	if(territoryName == null){
        	   territoryName = '(\'';
	           Set<Id> territoryIds = new Set<Id>();
	           for(UserTerritory2Association  userTerritory:[Select Territory2Id, UserId from UserTerritory2Association where UserId=:UserInfo.getUserId()]){
	             if(userTerritory.Territory2Id != null){
	                territoryIds.add(userTerritory.Territory2Id);
	             }
	           }

	           for(Territory2  territory:[Select Id,Name from Territory2 where Id in:territoryIds]){
	             territoryName += territory.Name + '\',\'' ;
	           }
	           territoryName +='\')';
        	}
           return territoryName;
         }set;
       }

        public void doSearch(){
            this.columnMap = new Map<String,String>();
            this.Results.clear();
            this.pageNumbers.clear();
            this.columnNames = new List<String>();

            whereCondition = ' WHERE territory_vod__c in '+ territoryName;
            whereCondition += ' and my_target_vod__c = TRUE AND Account_vod__r.IsPersonAccount = ' + ( selectedViewType == 'My HCOs' ? 'false' : 'true' );

            fields = Schema.getGlobalDescribe().get(this.sObjectName).getDescribe().fields.getMap();
            //TODO - Do not use language based label as the key of columnMap
            integer colIndexI = 0;
            for(String colname : this.mycolumnNames){
                if(colname.indexOf('.') == -1 && colname.indexOf('(') == -1){
                    refFields.put(colname,fields.get(colname).getDescribe().getType());
                }
               if(colname.indexOf('.') != -1 && colname.indexOf('(') == -1){
                    refFields.put(colname,getReferenceType(colname));
                }
                this.columnNames.add(columnLabels[colIndexI]);
                this.columnMap.put(columnLabels[colIndexI],colname);
                colIndexI++;
            }
            if(sortColumn == null || sortColumn == ''){
              sortColumn = fields.get('Name').getDescribe().getLabel();
            }
            // always show sort order desc when new column is selected first time for sorting.
            if(oldsortColumn != null && oldsortColumn != '' && oldsortColumn != sortColumn){
              sortDirection = 'desc';
            }
            oldsortColumn = sortColumn;
            isKeySearhValid = false;
            selectedColumn = (this.columnMap.get(sortColumn) == null ? sortColumn : this.columnMap.get(sortColumn));
            if(selectedColumn != null && selectedColumn != ''){
               Schema.DisplayType disptype;
               if(selectedColumn.indexOf('.') != -1){
                     disptype = getReferenceType(selectedColumn);
               }else{
                     disptype = fields.get(selectedColumn).getDescribe().getType();
               }
               if(disptype != Schema.DisplayType.Date && disptype != Schema.DisplayType.DateTime && disptype != Schema.DisplayType.Id && disptype != Schema.DisplayType.Boolean){
                    isKeySearhValid = true;
                    if(selectedColumn != '' && selectedColumn != 'id' && likekeyword != '' && likekeyword != null){
                          whereCondition += ' AND ' + selectedColumn + ' LIKE ' + '\'' + '' + likekeyword + '%' + '\'';
                    }
               }
            }


            this.totalCaseCount = Database.countQuery('Select count() from ' + sObjectName +  ' ' + whereCondition + ' limit 5000 ');
            if (this.totalCaseCount > 0) {
                if (this.currentPageIndex == 0) {
                    this.currentPageIndex = 1;
                }
                queryString = 'Select ' + sObjectColumnNames + ' from ' + sObjectName +  ' ' + whereCondition ;
                queryString += ' order by ' + selectedColumn +  ' ' +  sortDirection + ' nulls last limit ' + this.currentPageIndex * this.pageSize ;

                //TODO: Shuchun - Research how to solve the issue when the number of cases is more than 1000
                List<SObject> sObjects = Database.Query(queryString);
                for(Integer i = ((this.currentPageIndex-1) * this.pageSize); i < sObjects.size() ; i++) {
                         this.obj = new dynamicObject(sObjects[i],this.mycolumnNames,this.selectedFilter,i,selectedViewType);
                         this.Results.add(obj);
                }
                this.lastIndex = math.mod(this.totalCaseCount, this.pageSize) == 0 ? (this.totalCaseCount/this.pageSize) : (this.totalCaseCount/this.pageSize)+1;
                for (Integer j=1; j<=this.lastIndex; j++) {
                      this.pageNumbers.add(string.valueOf(j));
                }
                this.noRecords = false;
            } else {
                this.noRecords = true;
            }
        }

        public String getReferenceLabel(string columnName){
               columnName = columnName.replace('__r','__c');

               columnName = columnName.replace('.',' ');
               String[] strarr = columnName.split(' ');

               if(strarr.size() >= 2){
                 return getObjectLabel(strarr[strarr.size() - 2],strarr[strarr.size() - 1]);

               }else
                return strarr[strarr.size() - 1];

        }

        public Schema.DisplayType getReferenceType(string columnName){
               columnName = columnName.replace('__r','__c');

               columnName = columnName.replace('.',' ');
               String[] strarr = columnName.split(' ');

               if(strarr.size() >= 2){
                return getObjectType(strarr[strarr.size() - 2],strarr[strarr.size() - 1]);
               }else
                return Schema.DisplayType.STRING;

        }


        public static Map<String, Schema.SObjectField> fields{get;set;}

        public static Map<String, Schema.DisplayType> refFields{
            get{
                if(refFields == null)
                {refFields = new Map<String,Schema.DisplayType>();}
                return refFields;
            }set;
        }

        public Schema.DisplayType getObjectType(string objectname,string fieldname){
          Schema.DisplayType dtpe;
          try{
          dtpe = fields.get(objectname).getDescribe().getReferenceTo()[0].getDescribe().fields.getMap().get(fieldname).getDescribe().getType();
          }catch(Exception ex){
           dtpe = Schema.DisplayType.STRING;
          }

          return dtpe;
        }

        // to store reference fields schema once if there is any reference field column in the query
        public Map<String,Map<String,Schema.SObjectField>> otherRefFields{
            get{
               if(otherRefFields == null){
                 otherRefFields = new Map<String,Map<String,Schema.SObjectField>>();
               }
               return otherRefFields;
            }set;
        }
        // to store reference object schema once if there is any reference column in the query
        public Map<String,String> objectLanguageLabels{
           get{
               if(objectLanguageLabels == null){
                 objectLanguageLabels = new Map<String,String>();
               }
               return objectLanguageLabels;
           }set;
        }
        public String getObjectLabel(string objectname,string fieldname){
          String LabelName;
          if(objectname == 'Account_vod__c'){
          	 objectname = 'Account';
          }
          if(otherRefFields.get(objectname) == null){
          	 if(Schema.getGlobalDescribe().get(objectname) != null){
          	    otherRefFields.put(objectname,Schema.getGlobalDescribe().get(objectname).getDescribe().fields.getMap());
             	objectLanguageLabels.put(objectname,Schema.getGlobalDescribe().get(objectname).getDescribe().getLabel());
          	 }
          }
          try{
            string objectLabel = '';
            string fieldLabel = '';
            objectLabel = objectLanguageLabels.get(objectname);
            if(otherRefFields.get(objectname).get(fieldname).getDescribe().getLabel() != null)
            	fieldLabel = otherRefFields.get(objectname).get(fieldname).getDescribe().getLabel();

            LabelName = objectLabel + ' ' + fieldLabel;

          }catch(Exception ex){
          	LabelName = objectname + ' ' + fieldname;
          }
          return LabelName;
        }

        public String sObjectNameLabel {get;set;}
        public String sObjectName{get;set;}

        /* Comma separated string of column names */
        public String sObjectColumnNames{get;set;}
        public String sObjectColumnNamesLabels{get;set;}



        public List<dynamicObject> Results {
            get{
                return Results;
            }set{
                Results = value;
            }
        }

        public List<String> columnNames{
            get{

                if(this.columnNames == null){
                  this.columnNames = new List<String>();
                }
                return this.columnNames;
            }set;
        }

        public List<String> columnLabels {
            get {
                if(this.columnLabels == null){
                    this.columnLabels = this.sObjectColumnNamesLabels.split(',');
                }
                return this.columnLabels;
            }set;
        }
         public List<String> mycolumnNames{
            get{
                if(this.mycolumnNames == null){
                this.mycolumnNames = new List<String>();
                String sObjectColumnNames1 = this.sObjectColumnNames;

                    if(sObjectColumnNames1 != null){
                        if(sObjectColumnNames1.indexOf('(') != -1){
                          Integer startIndex =  sObjectColumnNames1.indexOf('(');
                          Integer endIndex = sObjectColumnNames1.indexOf(')');
                          String strtoreplace = sObjectColumnNames1.substring(startIndex,endIndex);

                          String strafterreplace = strtoreplace.replace(',','$');

                          sObjectColumnNames1 = sObjectColumnNames1.replace(strtoreplace,strafterreplace);

                        }

                        String[] strArr = sObjectColumnNames1.split(',');
                        if(strArr.size() > 0){
                            for(string arr : strArr){
                             this.mycolumnNames.add(arr);
                            }
                        }
                    }
                }

                return this.mycolumnNames;
            }set{
                this.mycolumnNames = value;
            }
           }

       /********************************************************
         FIELDSLIST OBJECT CLASS BELOW
        *********************************************************/
        public with sharing class childObjects{
            public List<String> lstValue{get;set;}
            public childObjects(List<String> lstValue){
                this.lstValue = lstValue;
            }
        }



        public with sharing class FieldsList{

           public string svalue{get;set;}
           public string stype{get;set;}
           public string id{get;set;}

           public SObject[] sObjArr{get;set;}

           public List<childObjects> childLists{get;set;}

           public FieldsList(string svalue,string stype,SObject[] sObjArr){
              this.svalue = svalue;
              this.stype = stype;
              this.sObjArr = sObjArr;
              this.childLists = new List<childObjects>();

           }


           public FieldsList(string svalue,string stype,Schema.DisplayType sdisplayType,string id){
           	 this.svalue = svalue;
             this.stype = stype;
             this.id = id;
           }

           public FieldsList(string svalue,string stype,Schema.DisplayType sdisplayType){
            this.svalue = svalue;
            this.stype = 'string';

            if(sdisplayType == Schema.DisplayType.Id || sdisplayType == Schema.DisplayType.REFERENCE){
             this.stype = 'id';
            }

            if(sdisplayType == Schema.DisplayType.EMAIL){
             this.stype = 'email';
            }

            if(sdisplayType == Schema.DisplayType.DATE){
              try{
              if(this.svalue != null && this.svalue != '')
              	this.svalue = string.valueOf(date.valueOf(this.svalue));
              }catch(Exception ex){
              	this.svalue = 'error:' + ex.getMessage();
              }
            }

            if(sdisplayType == Schema.DisplayType.DATETIME){
              try{
                  if(this.svalue != null && this.svalue != '')
                    this.svalue = datetime.valueOf(this.svalue).format('MM/dd/yy hh:mm:ss a');

              } catch(Exception ex) {
                this.svalue = 'error:' + ex.getMessage();
              }
            }

            if(sdisplayType == Schema.DisplayType.BOOLEAN){
              this.stype = 'boolean';
            }

            if(stype == 'viewlink'){

              this.stype = stype;
            }

            if(stype == 'Name'){
              this.stype = stype;
            }
           }
        }
        /********************************************************
         DYNAMIC OBJECT CLASS BELOW
        *********************************************************/
        public with sharing class dynamicObject{

            public List<FieldsList> FldList{get{return FldList;}set{FldList = value;}}
            private List<FieldsList>  fld;

            public String retURL{
                get{
                  if(this.retURL == null)
                  {
                    this.retURL = System.CurrentPageReference().getURL();

                    if(this.retURL.indexOf('?') != -1)
                    this.retURL = this.retURL.substring(0,this.retURL.indexOf('?'));

                  }
                  return this.retURL;
                }set;
            }
            public boolean isEditable{get{return false;}}
            public String editURL{
              get{
                return '/' + this.delegate.get('id') + '/e';
              }
            }
            public boolean isViewable{get{return false;}}

            public string viewURL{
               get{
               	 return '/' + this.delegate.get('id');
               }set;
            }
            public boolean isDeleteable{get{return false;}}
            public String deleteURL{
              get{
                 deleteURL = '/setup/own/deleteredirect.jsp?delID=' + this.delegate.get('Id') + '&retURL=' + this.retURL;
                 return deleteURL;
              }set{
                deleteURL = value;
              }
            }
            public List<String> columnNames{get;set;}
            private final SObject delegate;
            public string selectedFilter{get;set;}

            //public Case caseRow{get;set;}
            public String alternateClass{get;set;}
            public dynamicObject(SObject SObj,List<String> columnNames,String selectedFilter,Integer rowNumber,String selectedViewType){
                this.selectedFilter = selectedFilter;
                this.delegate = SObj;
                //this.caseRow = (Case)SObj;
                this.alternateClass = (math.mod(rowNumber,2) == 1 ? 'separate-holder' : 'case-holder');
                this.columnNames = columnNames;
                 if (fld == null) {
                    fld = new List<FieldsList>();
                    for(string columnName : this.columnNames){

                           try {
                                if(columnName.indexOf('.') != -1 && columnName.indexOf('(') == -1){
                                	if(columnName == 'Name'){
                                  		fld.add(new FieldsList(getReferenceValue(columnName),'Name',getType(columnName)));

                                	}else if(columnName == 'Account_vod__r.Name'){
                                		fld.add(new FieldsList(getReferenceValue(columnName),'nameLink',getType(columnName),getReferenceObjectId(columnName)));
                                	}
                                  	else{
                                  		fld.add(new FieldsList(getReferenceValue(columnName),'',getType(columnName)));
                                  	}
                                }else if(columnName.indexOf('.') == -1 && columnName.indexOf('(') == -1){
                                   fld.add(new FieldsList(getValue(columnName),'',getType(columnName)));
                                }else if(columnName.indexOf('(') != -1){
                                   fld.add(new FieldsList('child','child',delegate.getSObjects('contacts')));
                                }
                            } catch (System.SObjectException x) {
                                fld.add(new FieldsList(x.getMessage(),'',Schema.DisplayType.STRING));
                               // Do nothing - just means that the field was not selected in the select list
                           }

                    }
                 }
                 this.FldList = fld;

            }


            public Schema.DisplayType getType(string columnName){
                Schema.DisplayType sType;
                try{
                sType = refFields.get(columnName);
                }catch(Exception ex){
                sType = Schema.DisplayType.String;
                }
                return sType;
            }

            public string getValue(string columnName){

                return String.valueOf((delegate.get(columnName)== null? '' : delegate.get(columnName)));
            }

            public string getReferenceObjectId(string columnName){
               columnName = columnName.replace('.',' ');
               String[] strarr = columnName.split(' ');
               SObject sobj1;
               for(Integer i = 0; i < strarr.size() - 1 ; i ++){
                 sobj1 = delegate.getSObject(strarr[i]);
               }

               if(sobj1 != null){
                return string.valueOf(sobj1.get('id'));
               }else
                return '';
            }

            public String getReferenceValue(string columnName){
               columnName = columnName.replace('.',' ');
               String[] strarr = columnName.split(' ');
               SObject sobj1;
               for(Integer i = 0; i < strarr.size() - 1 ; i ++){
                 sobj1 = delegate.getSObject(strarr[i]);
               }

               if(sobj1 != null){
                return string.valueOf(sobj1.get(strarr[strarr.size() - 1]));
               }else
                return '';
            }

        }
    }