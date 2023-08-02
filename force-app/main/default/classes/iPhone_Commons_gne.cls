/******************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com
*  Created: 2013-05-24
*  Project: OTR2
*  Description: Common utility classes used to generate webservices (REST) response.
*******************************************************************************************/
global class iPhone_Commons_gne {
    public static DateTime startTimeStamp;
    
    /* ************************************************************************************** */
    /* *********************************** STATIC METHODS *********************************** */    
    /* ************************************************************************************** */
    
    
    /**
        A template method - builds a webservice response object. Specialized for a 'data
        retrieval' requests. The response object contains a reqested data and an operation
        status (and some debugging information).
    */              
    public static RestResponse buildResponse(ResponseBuilder builder, Object args) {        
        setStartTimeStamp();
        system.debug('Building Response: ' + args);         
        RestResponse response = null;                       
        try {
            response = builder.build(args);                                             
            response.setSuccessStatus();
            String builderClassName = String.valueOf(builder).substringBefore(':');
            iPhoneBase.handleLogging(args, response, builderClassName);
        } catch (Exception ex) {            
            response = new BasicResponse(ex);
            response.setErrorStatus(ex);
            String builderClassName = String.valueOf(builder).substringBefore(':');
            iPhoneBase.handleException(ex, UserInfo.getUserId(), 'OTR', '[iPhone REST] ' + builderClassName,
              args!=null && args instanceof iPhoneBase.RequestTestable2 ? ((iPhoneBase.RequestTestable2)args).getRequestType() : null, 
              args!=null && args instanceof iPhone_Commons_gne.BaseArgs ? ((iPhone_Commons_gne.BaseArgs)args).getIPhoneRequestId() : null,
              args, 
              '[iPhone REST] Error while processing ' + builderClassName
            );            
        }
        system.debug('Response: ' + response);                                                  
        return response;        
    }
    
    /**
        A template method specialized for a 'data altering' requests. The (webservice)
        response object contains an operation status only (and some debugging
        information).
    */
    public static RestResponse executeAlterData(Runnable runnable, Object args) {
        setStartTimeStamp();
        system.debug('Building Response: ' + args);
        Savepoint sp = Database.setSavepoint();         
        RestResponse response = null;                       
        try {
            Object ret = runnable.run(args);
            if(ret != null && ret instanceof AlterDataResponse) {
                response = (AlterDataResponse)ret;
            } else if(ret instanceof Map<String,Id>) {
            	response = new AlterDataResponse((Map<String,Id>)ret);
            } else if(ret instanceof AlterDataResponseItem) {
            	response = new AlterDataResponse((AlterDataResponseItem)ret);
            } else if(ret instanceof List<AlterDataResponseItem>) {
            	response = new AlterDataResponse((List<AlterDataResponseItem>)ret);
            } else {
            	response = new AlterDataResponse((String)ret);
            }            
            response.setSuccessStatus();
            String runnableClassName = String.valueOf(runnable).substringBefore(':');
            String iPhoneRequestId = null;
            if (args != null && (args instanceOf iPhone_Commons_gne.BaseArgs)) {
                iPhoneRequestId = ((iPhone_Commons_gne.BaseArgs)args).getIPhoneRequestId();
            }
            iPhoneBase.handleLogging(response, runnableClassName, iPhoneRequestId);
        } catch (Exception ex) {     
            response = new AlterDataResponse(ex);
            response.setErrorStatus(ex);
            Database.rollback(sp);
            String runnableClassName = String.valueOf(runnable).substringBefore(':');
            iPhoneBase.handleException(ex, UserInfo.getUserId(), 'OTR', '[iPhone REST] ' + runnableClassName, 
	            args!=null && args instanceof iPhoneBase.RequestTestable2 ? ((iPhoneBase.RequestTestable2)args).getRequestType() : null,
	            args!=null && args instanceof iPhone_Commons_gne.BaseArgs ? ((iPhone_Commons_gne.BaseArgs)args).getIPhoneRequestId() : null, 
	            args,
	            '[iPhone REST] Error while processing ' + runnableClassName);
	        response = checkManualFix(response);
        }
        system.debug('Response: ' + response);                                                  
        return response;                                
    }
    
    private static RestResponse checkManualFix(RestResponse response) {
        try {
            Object manualFixResponse = iPhoneBase.getManualFixResponse();
            response = manualFixResponse!=null ? (RestResponse)manualFixResponse : response;
        } catch(Exception e) {}
        
        return response;
    }
    
    public static void setStartTimeStamp() {
        if(startTimeStamp==null) {
            startTimeStamp = System.now();
        }
    }
    
    /* ************************************************************************************** */
    /* ****************************** PUBLIC CLASSES AND INTERFACES ************************* */    
    /* ************************************************************************************** */
    
    /**
        Allows to call a single method on the implenting class. The argument for the call is
        passed as an Object. The return Object contains an execution result (e.g. record
        modified id), it can also be null.
    */
    public interface Runnable {
        Object run(Object arg);
    }
    
    /**
        Designated for the classes responsible for the (REST) response generation. The 'build'
        method builds response for the parmeters passed as an Object. Cooperates with the
        template method: buildResponse.
    */
    public interface ResponseBuilder {
        RestResponse build(Object args);
    }
    
    public interface BaseArgs{
        String getIPhoneRequestId();
    }
    
    /**
        An ancestor for all classes that holds data of a single SFDC table record.  
    */
    public abstract class RestRecord {
        public String id;
    }
    
    /**
        An ancestor for all classes that holds data of a single SFDC table record and supports
        a 'delta' feature. The 'ax' field keeps a delta status (see DeltaCalculator class for
        more details).  
    */
    public abstract class DeltaRecord extends RestRecord {
        public String ax;
    }
    
    /**
        An input parameter class for the 'build' method of the ResponseBuilder interface.
    */  
    public abstract class DeltaArgs {
        public final String lastSyncDate;
        public transient DateTime lastSyncDt;
        public final String unixId;
        public final Boolean enhDelta;
        public final String otrVersion;
        public final List<String> accountIds;   
        public final List<String> brandAffiliationIds;
        public final Integer batchSize;
        
        public DeltaArgs() {}
        
        public DeltaArgs(String lastSyncDate, String unixId, List<String> accountIds, Boolean enhDelta, String otrVersion) {
            this.lastSyncDate = lastSyncDate;
            this.lastSyncDt = iPhone_StringUtil.hasValue(lastSyncDate) ? DateTime.valueofGmt(lastSyncDate) : null;
            this.unixId = unixId;
            this.accountIds = accountIds;
            this.enhDelta = enhDelta;
            this.otrVersion = otrVersion;
        }
        
        public virtual DateTime getLastSyncDate() {
        	return lastSyncDt;
        }
        
        public virtual Boolean isEnhancedDelta() {
          return this.enhDelta==true && lastSyncDt!=null;
        }
        
        public virtual Boolean isOtrVersionOrHigher(String otrVersion) {
          Boolean result = false;
          
          if(String.isNotBlank(this.otrVersion)) {
            String[] tokens = otrVersion.split('\\.');
            String[] currentTokens = this.otrVersion.split('\\.');
            
            for(Integer i=0; i<Math.min(tokens.size(),currentTokens.size()); i++) {
              if(tokens[i].isNumeric() && currentTokens[i].isNumeric()) {
                Integer vToken = Integer.valueOf(tokens[i]);
                Integer currentVToken = Integer.valueOf(currentTokens[i]);
                
                if(vToken==currentVToken) {
                  result = true;
                } else if(vToken<currentVToken) {
                  result = true;
                  break;
                } else {
                  result = false;
                  break;
                }
              }
            }
          }
          
          return result;
        }    
    }

    /**
        A default implementation of DeltaArgs abstract class. Contains an overloaded
        constructors for convenience.
    */
    public virtual class DefaultDeltaArgs extends DeltaArgs {
    	
        public DefaultDeltaArgs(String lastSyncDate, List<String> accountIds) {
            this(lastSyncDate, null, accountIds, false, null);
        }
        
        public DefaultDeltaArgs(String lastSyncDate, String unixId) {
            this(lastSyncDate, unixId, null, false, null);
        }
        
        public DefaultDeltaArgs(String lastSyncDate, String unixId, List<String> accountIds) {
        	  this(lastSyncDate, unixId, accountIds, false, null);
        }
        
        public DefaultDeltaArgs(String lastSyncDate, String unixId, List<String> accountIds, List<String> brandAffiliationIds) {
            this(lastSyncDate, unixId, accountIds, false, null);
            this.brandAffiliationIds = brandAffiliationIds;
        }

        public DefaultDeltaArgs(String lastSyncDate, String unixId, List<String> accountIds, Integer batchSize) {
            this(lastSyncDate, unixId, accountIds, false, null);
            this.batchSize = batchSize;
        }
        
        public DefaultDeltaArgs(String lastSyncDate, String unixId, List<String> accountIds, Boolean enhDelta, String otrVersion) {
            super(lastSyncDate, unixId, accountIds, enhDelta, otrVersion);
        }
    }
    
    /**
        A base class for all webservice response objects. Contains an operation status and
        some debugging information.
    */
    global abstract class RestResponse {    
        public Boolean success = false;
        public ExceptionInfo error;     
        public Map<String, String> debugInfo = new Map<String,String>();            
        
        public void setSuccessStatus() {    
            this.success = true;
            this.debugInfo.put('scriptStatements', Limits.getScriptStatements() + '/' + Limits.getLimitScriptStatements());
            this.debugInfo.put('queryStatements', Limits.getQueries() + '/' + Limits.getLimitQueries());
            this.debugInfo.put('queryRows', Limits.getQueryRows() + '/' + Limits.getLimitQueryRows());
            this.debugInfo.put('dmlStatements', Limits.getDmlStatements() + '/' + Limits.getLimitDmlStatements());
            this.debugInfo.put('dmlRows', Limits.getDmlRows() + '/' + Limits.getLimitDmlRows());
            this.debugInfo.put('cpuTime', Limits.getCpuTime() + '/' + Limits.getLimitCpuTime());
            
            if(iPhone_Commons_gne.startTimeStamp!=null) {
                this.debugInfo.put('execTime', String.valueOf(System.now().getTime() - iPhone_Commons_gne.startTimeStamp.getTime()));
            }
        }
        
        public void setErrorStatus(Exception ex) {      
            this.success = false;
            this.debugInfo.put('scriptStatements', Limits.getScriptStatements() + '/' + Limits.getLimitScriptStatements());
            this.debugInfo.put('queryStatements', Limits.getQueries() + '/' + Limits.getLimitQueries());
            this.debugInfo.put('queryRows', Limits.getQueryRows() + '/' + Limits.getLimitQueryRows());
            this.debugInfo.put('dmlStatements', Limits.getDmlStatements() + '/' + Limits.getLimitDmlStatements());
            this.debugInfo.put('dmlRows', Limits.getDmlRows() + '/' + Limits.getLimitDmlRows());
            this.debugInfo.put('cpuTime', Limits.getCpuTime() + '/' + Limits.getLimitCpuTime());
            
            if(iPhone_Commons_gne.startTimeStamp!=null) {
                this.debugInfo.put('execTime', String.valueOf(System.now().getTime() - iPhone_Commons_gne.startTimeStamp.getTime()));
            }
            
            this.error = new ExceptionInfo(ex);
            System.debug('failed: ' + this.error);
        }                           
    }
    
    /**
        Holds a (REST) response payload. Supports the 'delta' feature. If 'delta' is used (the 'lastSyncDate'
        request parameter is used), the structure 'records'  keeps  only new and modified records and
        'xids' list contains ids of all requested  records (to let finding the deleted records at the
        ipad's side). If 'delta' is not used the 'records' contains all requested data (with an 'ax' field
        empty) and 'xids' (eXisting ids) list empty.        
    */
    public class DeltaRecordsResponse extends RestResponse {    
        public final List<DeltaRecord> records;
        public final List<String> xids;     
        
        public DeltaRecordsResponse(List<DeltaRecord> records, List<String> xids) {
            this.records = records;
            this.xids = xids;
        }           
    }   
    
    /**
        Holds a (REST) response payload. Used in the cases where the returned columns set is not known
        at the development  time (is user configurable).                
    */
    public class DeltaRowSetResponse extends RestResponse {
        
        public final FlexDeltaTable rowset;
        
        public DeltaRowSetResponse(List<DataColumn> columns, List<SObject> sObjects, String lastSyncDate) {
            this.rowset = new FlexDeltaTable(columns, sObjects, lastSyncDate);
        }
                
        public DeltaRowSetResponse(List<DataColumn> columns, List<SObject> sObjects, DeltaCalculator deltaCalculator, Boolean alwaysIncludeXids) {
            this.rowset = new FlexDeltaTable(columns, sObjects, deltaCalculator, alwaysIncludeXids);
        }
    }

    /**
        A table-like container class. Usefull for cases where the number of data columns is not known
        at the development time. The 'columns' list contains metadata information for the columns used.
        The 'rows' list contains data only. For 'xids' information read 'DeltaRecordsResponse' class
        description.
    */
    public class FlexDeltaTable {
        
        public final List<DataColumn> columns = new List<DataColumn>();
        public final List<List<String>> rows = new List<List<String>>();
        public final List<String> xids = new List<String>();
        
        private transient List<DataColumn> sObjColumns;
        
        public FlexDeltaTable(List<DataColumn> columns, List<SObject> sObjects, String lastSyncDate) {
            buildColumns(columns);
            DeltaCalculator deltaCalculator = null;
        	if (iPhone_StringUtil.hasValue(lastSyncDate)){
        	 	deltaCalculator = new DeltaCalculator(lastSyncDate);
        	}
        	buildRows(sObjects, deltaCalculator, false);            
        }
        
        public FlexDeltaTable(List<DataColumn> columns, List<SObject> sObjects, DeltaCalculator deltaCalculator, Boolean alwaysIncludeXids) {
            buildColumns(columns);
            buildRows(sObjects, deltaCalculator, alwaysIncludeXids);
        }
        
        private void buildColumns(List<DataColumn> columns) {
            this.sObjColumns = columns;
            this.columns.add(new DataColumn('','ax', 'Delta', 'DELTA', '', null));
            this.columns.addAll(columns);
        }
        
        private void buildRows(List<SObject> sObjects, DeltaCalculator deltaCalculator, Boolean alwaysIncludeXids) {
            if(deltaCalculator != null) {
                for(SObject sObj: sObjects) {
                    this.xids.add(sObj.id);
                    String deltaStatus = deltaCalculator.getDeltaStatus(sObj);
                    if(deltaCalculator.STAT_INSERT == deltaStatus || deltaCalculator.STAT_UPDATE == deltaStatus) {
                        this.rows.add(buildRow(deltaStatus, sObj));
                    }               
                }           
            } else {            	
                for(SObject sObj: sObjects) {
                	if (alwaysIncludeXids == true){
                		this.xids.add(sObj.id);
                	}
                    this.rows.add(buildRow('', sObj));
                }
            }         
        }
        
        private List<String> buildRow(String deltaStatus, SObject sObj) {
            List<String> rowCells = new List<String>();
            rowCells.add(deltaStatus);                  // this is: column[0]           
            for(DataColumn column: sObjColumns) {       // the rest of the columns:
                rowCells.add(column.getValue(sObj));            
            }
            return rowCells;            
        }                           
    }           
    
    /**
        The ResponseBuilder implementation that handles the case where the number of columns
        (in the REST response) is not fixed (not known at the development time). The metadata
        for the columns used is retrieved during the response object creation (see method
        'getDataColumns').
    */
    public abstract class DeltaRowSetResponseBuilder implements ResponseBuilder {
        
        protected Boolean alwaysIncludeXids = false;
        
        public RestResponse build(Object objArg) {
            DeltaArgs args = (DeltaArgs)objArg;
            User currentUser = validateUser(args.unixId);
            onInit(currentUser, args);
            
            List<DataColumn> columns = getDataColumns(args);            
            List<String> columnNames = getColumnNames(columns);
            List<SObject> sObjects = getSObjects(columnNames, args);
            DeltaCalculator deltaCalculator = iPhone_StringUtil.hasValue(args.lastSyncDate) ? getDeltaCalculator(args.lastSyncDate) : null;            
            return new DeltaRowSetResponse(columns, sObjects, deltaCalculator, alwaysIncludeXids);
        }
        
        protected abstract List<DataColumn> getDataColumns(DeltaArgs args);
        protected abstract List<SObject> getSObjects(List<String> columnNames, DeltaArgs args);
        
        protected virtual void onInit(User currentUser, DeltaArgs deltaArgs){}
        protected virtual DeltaCalculator getDeltaCalculator(String lastSyncDate){
        	return new DeltaCalculator(lastSyncDate);
        }
        
        private User validateUser(String unixId) {            
            User currentUser = null;
            if(iPhone_StringUtil.hasValue(unixId)) {
                currentUser = iPhone_DAO.getUserByExternalId(unixId);
                if(currentUser == null) {
                	throw new IPhoneException('User not found: ' + unixId);
                }
            }
            return currentUser;
        }
        
        private List<String> getColumnNames(List<DataColumn> columns) {
            List<String> cols = new List<String>();
            for(DataColumn column: columns) {
                cols.add(column.srcColumn);
            }
            return cols;
        }           
    }

    /**
        The ResponseBuilder implementation created for cases where response the metadata structure
        is known is known/fixed at the development time. During the response object building, each
        SObject item is converted into DeltaRecord (descendant) object (and add into response).         
    */
    public abstract class DeltaRecordsResponseBuilder implements ResponseBuilder {
        public Set<String> xids;
        public DeltaCalculator deltaCalculator;
        
        public RestResponse build(Object objArgs) {
            return buildResponse((DeltaArgs)objArgs);           
        }
        
        private DeltaRecordsResponse buildResponse(DeltaArgs args) {
        	xids = new Set<String>();
        	deltaCalculator = getDeltaCalculator(args.lastSyncDate);
            List<SObject> sObjects = selectSObjects(args);                          
            sObjects = filterAccessibleSObjects(sObjects, args.unixId);
            return buildDeltaResponse(sObjects, args);         
        }               
        
        private DeltaRecordsResponse buildDeltaResponse(List<SObject> sObjects, DeltaArgs args) {          
            List<DeltaRecord> records = new List<DeltaRecord>();
            String lastSyncDate = args.lastSyncDate;
            Boolean useDeltaFeature = iPhone_StringUtil.hasValue(lastSyncDate);
            if(useDeltaFeature) {
                for(SObject sObj: sObjects) {
                	  if(!args.isEnhancedDelta()) {
                      xids.add(sObj.id);
                	  }
                    String deltaStatus = deltaCalculator.getDeltaStatus(sObj);
                    if(deltaCalculator.STAT_INSERT == deltaStatus || deltaCalculator.STAT_UPDATE == deltaStatus) {
                        DeltaRecord record = getAsRecord(sObj);
                        record.ax = deltaStatus;
                        records.add(record);                        
                    }               
                }               
            } else {
                for(SObject sObj: sObjects) {
                    DeltaRecord record = getAsRecord(sObj);
                    record.ax = '';
                    records.add(record);
                }
            }               
            return new DeltaRecordsResponse(records, new List<String>(xids));         
        }
        
        private List<SObject> filterAccessibleSObjects(List<SObject> sObjects, String unixId) {
            if(iPhone_StringUtil.hasValue(unixId)){
                User user = iPhone_DAO.getUserByExternalId(unixId);
                boolean useImpersonation = (Userinfo.getUserId() != user.id);
                if(useImpersonation){                                                           // perform filtering:
                    UserRecordAccessBasedSObjectsFilter sObjectsFilter = new UserRecordAccessBasedSObjectsFilter(user);

                    return sObjectsFilter.getAccessibleSObjects(sObjects);
                }
            }
            return sObjects;            
        }                       
        
        protected virtual DeltaCalculator getDeltaCalculator(String lastSyncDate){
            return new DeltaCalculator(lastSyncDate);
        }
        
        protected abstract List<SObject> selectSObjects(DeltaArgs args);
        
        protected abstract DeltaRecord getAsRecord(SObject sObj);
    }
    
    /**
        Implements SObject list filtering based on the information from UserRecordAccess table.
        The returned list contains only user accessible items.
    */
    public class UserRecordAccessBasedSObjectsFilter {
        
        private final User user;
        
        private final Integer USER_RECORD_ACCESS_CHUNK_SIZE = 200;
        
        public UserRecordAccessBasedSObjectsFilter(User user) {
            this.user = user;
        }
        
        public List<SObject> getAccessibleSObjects(List<SObject> sObjects) {
            List<Id> sObjectIds = getSObjectsIds(sObjects);
            List<UserRecordAccess> userAccessibleRecords = getUserRecordAccessForIds(sObjectIds);
            Set<Id> accessibleIds = getRecordIds(userAccessibleRecords);
            List<SObject> accessibleSObjects = filterSObjectsByIds(sObjects, accessibleIds);                                                                            
            return accessibleSObjects;          
        }
        
        private List<UserRecordAccess> getUserRecordAccessForIds(List<Id> recordIds) {
            List<UserRecordAccess> result = new List<UserRecordAccess>();
            if ((null != this.user) && (null != recordIds) && (!recordIds.isEmpty())) {
                Integer numRecordsToCheck = recordIds.size();
                Integer numRecordsChecked = 0;
                while (numRecordsToCheck > numRecordsChecked) {
                    List<Id> recordIdsChunk = new List<Id>();
                    Integer i = 0;
                    while ((numRecordsToCheck > numRecordsChecked + i) && (i < USER_RECORD_ACCESS_CHUNK_SIZE)) {
                        recordIdsChunk.add(recordIds[numRecordsChecked + i]);
                        i++;
                    }
                    numRecordsChecked += i;
                    result.addAll(iPhone_DAO.getUserAccessibleRecords(this.user.Id, recordIdsChunk));
                }
            }
            return result;
        }
        
        private List<Id> getSObjectsIds(List<SObject> sObjects) {
            List<Id> result = new List<Id>();
            for(SObject sObj: sObjects) {
                result.add(sObj.id);
            }           
            return result;
        }
        
        private Set<Id> getRecordIds(List<UserRecordAccess> records) {
            Set<Id> result = new Set<Id>();
            for(UserRecordAccess record: records) {
                result.add(record.RecordId);
            }
            return result;
        }       
        
        private List<SObject> filterSObjectsByIds(List<SObject> sObjects, Set<Id> allowedIds) {
            List<SObject> result = new List<SObject>();
            for(SObject sObj: sObjects) {
                if(allowedIds.contains(sObj.id)) {
                    result.add(sObj);
                }
            }
            return result;          
        }                                                               
    }       
    
    /**
        Holds a description data for a single data column. The 'getValue' method can be used
        to retrive a String formated data from SObject argument.
    */
    public class DataColumn {                   
        public final String tableName;
        public final String fieldName;
        public final String fieldLabel;
        public final String fieldType;
        
        public final transient String srcColumn;               
        private final transient ColumnValueConverter valueConverter;
        
        public DataColumn(String apiTableName, String apiFieldName, String apiFieldLabel, String apiFieldType, String scrColumn, ColumnValueConverter valueConverter) {
            this.tableName = apiTableName;
            this.fieldName = apiFieldName;
            this.fieldLabel = apiFieldLabel;
            this.fieldType = apiFieldType;
            this.srcColumn = scrColumn;
            this.valueConverter = valueConverter;
        }
        
        public String getValue(SObject sObj) {
            return valueConverter.getValueAsString(sObj, this.srcColumn);
        }               
    }
    
    /**
        A factory class that builds a DataColumn object for the specified column name.
    */      
    public class DataColumnFactory {
        
        private final Map<String, Map<String,Schema.SObjectField>> tablesFieldsMap;
        private final Map<Schema.DisplayType, ColumnValueConverter> convertersMap;
        private final Map<String, String> relationPathsMap;
        
        public DataColumnFactory(Map<String, String> relationPathsMap) {            
            this.convertersMap = buildConvertersMap();
            this.tablesFieldsMap = buildTablesFieldsMap(relationPathsMap.values());
            this.relationPathsMap = relationPathsMap;                                                   
        }
        
        public DataColumn newInstance(String fullColumnName) {          
            String fieldName = getFieldName(fullColumnName);    
            String relationsPath = getRelationsPath(fullColumnName);
            String tableName = this.relationPathsMap.get(relationsPath);            
            if(tableName == null)
            throw new IPhoneException('Unknown relation path: ' + relationsPath);
            
            Map<String,Schema.SObjectField> fieldsMap = this.tablesFieldsMap.get(tableName);            
            if(fieldsMap.containsKey(fieldName)) {
                Schema.SObjectField field = fieldsMap.get(fieldName);
                DescribeFieldResult fieldDescr = field.getDescribe();               
                if(convertersMap.containsKey(fieldDescr.getType())) {
                    return new DataColumn(
                    tableName,
                    fieldDescr.getName(),
                    fieldDescr.getLabel(),
                    String.valueOf(fieldDescr.getType()),
                    fullColumnName,
                    convertersMap.get(fieldDescr.getType())
                    );                                  
                } else {
                    throw new IPhoneException('Converter not found for field: ' + fieldDescr);
                }                                               
            } else {
                throw new IPhoneException('Unknown field name: ' + fieldName);
            }           
        }
        
        private Map<String, Map<String,Schema.SObjectField>> buildTablesFieldsMap(List<String> tableNames) {
            Map<String, Schema.SObjectType> globalDescrMap = Schema.getGlobalDescribe();        
            Map<String, Map<String,Schema.SObjectField>> resultMap = new Map<String, Map<String,Schema.SObjectField>>();
            for(String tableName: tableNames) {
                Schema.SObjectType sObjType = globalDescrMap.get(tableName);
                resultMap.put(tableName, sObjType.getDescribe().fields.getMap());               
            }           
            return resultMap;
        }
        
        private Map<Schema.DisplayType, ColumnValueConverter> buildConvertersMap() {
            Map<Schema.DisplayType, ColumnValueConverter> convertersMap = new Map<Schema.DisplayType, ColumnValueConverter>();
            convertersMap.put(Schema.DisplayType.Id, new ColumnStringValueConverter());
            convertersMap.put(Schema.DisplayType.Reference, new ColumnStringValueConverter());
            convertersMap.put(Schema.DisplayType.String, new ColumnStringValueConverter()); 
            convertersMap.put(Schema.DisplayType.Picklist, new ColumnStringValueConverter());           
            convertersMap.put(Schema.DisplayType.Boolean, new ColumnBooleanValueConverter());
            convertersMap.put(Schema.DisplayType.Double, new ColumnDecimalValueConverter());            
            convertersMap.put(Schema.DisplayType.DateTime, new ColumnDateTimeValueConverter());                     
            return convertersMap;
        }
        
        private String getFieldName(String fullColumnName) {    
            List<String> parts = fullColumnName.split('\\.');
            if(parts.size() > 0) {
                return parts[parts.size() - 1]; 
            }
            return fullColumnName;      
        }
        
        private String getRelationsPath(String fullColumnName) {
            List<String> parts = fullColumnName.split('\\.', 0);
            if(parts.size() > 1) {                  // if contains 'relation path':
                parts.remove(parts.size() - 1);     // remove last element
                return String.join(parts, '.');     // return 'fullColumnName' without last '.'-separated chunk.                            
            }           
            return '';  // no relation path (only table field name).
        }                   
    }
    
    /**
        Utility class for the SFA2UserAppContext table. 
    */
    public class UserAppContextUtil {
        
        public GNE_SFA2_User_App_Context_gne__c getAppCtx(String userId) {      
            GNE_SFA2_User_App_Context_gne__c appCtx = GNE_SFA2_User_App_Context_gne__c.getValues(userId);   
            if(appCtx == null) {
                //If user settings not found in ApplicationContext search for it in UserSalesRoster table:
                SFA2_User_Sales_Roster_gne__c roster = iPhone_DAO.getSalesRosterByUserId(userId);
                system.debug('Roster found: ' + roster);    
                if(roster != null) {
                    // If user settings found in UserSalesRoster then create a entry in ApplicationContext basing on the data from 'roster'.
                    appCtx = iPhone_DAO.insertUserAppliactionContext(userId, roster.Sales_Roster_gne__r.Type_gne__c, roster.Sales_Roster_gne__r.Brand_Name_gne__c, roster.Role_gne__c);
                    system.debug('ApplicationContext created: ' + appCtx);  
                }
            }
            return appCtx;              
        }
    }
    
    public class IPhoneException extends Exception {
    }
    
    public class ExceptionInfo {
        public String stackTrace;
        public String typeName;
        public String cause;
        public Integer lineNumber;
        public String message;
        
        public ExceptionInfo(Exception ex) {
            Exception cEx = ex.getCause();
            
            stackTrace  = ex.getStackTraceString();
            typeName    = ex.getTypeName();
            cause       = cEx!=null ? cEx.getMessage() : '';
            lineNumber  = ex.getLineNumber();
            message     = ex.getMessage();
        }
    }                   
    
    /* ************************************************************************************** */
    /* ****************************** PRIVATE CLASSES AND INTERFACES ************************ */    
    /* ************************************************************************************** */            
    
    public virtual class AlterDataResponse extends RestResponse {
        
        public final String sfdcId;
        public final List<Map<String,String>> sfdcIds;
        public List<AlterDataResponseItem> responseItems;
        
        public AlterDataResponse() {}
        
        public AlterDataResponse(String sfdcId) {
            this.sfdcId = sfdcId;
            setSuccessStatus();
        }
        
        public AlterDataResponse(Map<String,Id> requestIdToSfdcIdMap) {
            this.sfdcIds = new List<Map<String,String>>();
            
            if(requestIdToSfdcIdMap!=null) {
            	for(String reqId : requestIdToSfdcIdMap.keySet()) {
            		sfdcIds.add(new Map<String,String>{
            			'rid' => reqId,
            			'id' => requestIdToSfdcIdMap.get(reqId)
            		});
            	}
            }
            
            setSuccessStatus();
        }
        
        public AlterDataResponse(AlterDataResponseItem ri) {
        	this(new List<AlterDataResponseItem>{ri});
        }
        
        public AlterDataResponse(List<AlterDataResponseItem> riList) {
          this.responseItems = riList;
        }
        
        public AlterDataResponse(Exception ex) {
            setErrorStatus(ex);
        }       
    }
    
    public virtual class AlterDataResponseItem {
    	public String rid;
    	public Id id;
    	
    	public AlterDataResponseItem(String rid, Id id) {
    		this.rid = rid;
    		this.id = id;
    	}
    }
    
    public virtual class BasicResponse extends RestResponse {
        
        public BasicResponse() {
            setSuccessStatus();
        }   
        
        public BasicResponse(Exception ex) {            
            setErrorStatus(ex);
        }       
    }               
    
    private interface ColumnValueConverter {        
        String getValueAsString(SObject sObj, String column);
    }   
    
    private abstract class ColumnValueConverterBase {
        
        protected Object getValueAsObject(SObject sObj, String fieldName) {                         
            if (fieldName.contains('__r.')) {
                String[] ref = fieldName.split('__r.');
                Integer i = 0, n = ref.size() - 1;
                for (; i < n; i++) {
                    sObj = sObj.getSObject(ref[i] + '__r');
                    if (sObj == null) {
                        return null;
                    }
                }
                fieldName = ref[i];
            }
            return sObj.get(fieldName);
        }
    }
    
    private class ColumnStringValueConverter extends ColumnValueConverterBase implements ColumnValueConverter {     
        public String getValueAsString(SObject sObj, String column) {
            Object value = getValueAsObject(sObj, column);
            return iPhone_StringUtil.getString((String)value);
        }
    }
    
    private class ColumnBooleanValueConverter extends ColumnValueConverterBase implements ColumnValueConverter {        
        public String getValueAsString(SObject sObj, String column) {
            Object value = getValueAsObject(sObj, column);
            return iPhone_StringUtil.getString((Boolean)value);         
        }
    }
    
    private class ColumnDecimalValueConverter extends ColumnValueConverterBase implements ColumnValueConverter {        
        public String getValueAsString(SObject sObj, String column) {
            Object value = getValueAsObject(sObj, column);
            return iPhone_StringUtil.getString((Decimal)value);                 
        }
    }
    
    private class ColumnDateTimeValueConverter extends ColumnValueConverterBase implements ColumnValueConverter {       
        public String getValueAsString(SObject sObj, String column) {
            Object value = getValueAsObject(sObj, column);
            return iPhone_StringUtil.getString((DateTime)value);                    
        }
    }               
    
    public virtual class DeltaCalculator {
        protected final DateTime lastSynchronized;      
        public final String STAT_INSERT = 'i';      
        public final String STAT_UPDATE = 'u';
        public final String STAT_SYNC = 'x';            
        
        public DeltaCalculator(String lastSyncDate) {
            this.lastSynchronized = iPhone_StringUtil.hasValue(lastSyncDate) ? DateTime.valueofGmt(lastSyncDate) : DateTime.newInstance(0);
        }
        
        protected virtual String getDeltaStatus(SObject sObj) {
            if(lastSynchronized == null) // delta is OFF.
            return null;        
            Datetime created = (Datetime)sObj.get('CreatedDate');
            Datetime lastModified =(Datetime)sObj.get('LastModifiedDate');              
            if(created >= lastSynchronized) {
                return STAT_INSERT;     // created AFTER last synchronization.
            } else {
                if( lastModified >= lastSynchronized) {
                    return STAT_UPDATE; // created BEFORE last synchonization but updated AFTER last synchronization.
                } else {
                    return STAT_SYNC; // created and updated BEFORE last synchronization (is eXisting = already synchronized).
                }
            }                           
        }                           
    }               
}