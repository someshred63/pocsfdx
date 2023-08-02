public abstract with sharing class SPCM_SearchBase {
	

    public List<SPCM_Medicaid_Payment_Packet__c> ResultList {get; set;}
    public List<FilterWrapper> Filters  {get;set;}
    public List<SelectOption> Fields    {get; set;}
    public List<SelectOption> Operators {get; set;}
    public List<SelectOption> Connective {get; set;}
    public Integer SelectedFieldId      {get; set;}
    public Integer FilterToDelete       {get; set;}
    public Integer FiltersSize          {get; set;}
    public Boolean IsExcel				{get; set;}
    public string errmsg                {get; set;}
    public string errmsg2               {get; set;}

    
    private Set<string> arithmeticTypes = new Set<string> { 'INTEGER', 'DOUBLE', 'DATE', 'DATETIME', 'DECIMAL', 'LONG', 'CURRENCY' };
    private Set<string> arithmeticOperators = new Set<string> { '=', '!=', '>', '<' };
    private Set<string> booleanOperators = new Set<string> { '=', '!=' };
    private Set<string> stringOperators = new Set<string> { '=', '!='};
    private integer idCounter = 0;
    
    
    // returns selectOptions collection with field api name and field name
    protected abstract List<SelectOption> GetFields();

    protected abstract string GetObjectName();

    
    public SPCM_SearchBase() 
    {
        FiltersSize = 1;
        IsExcel = false;
        ResultList = new List<SPCM_Medicaid_Payment_Packet__c>();
        Fields = GetFields();
        Operators = GetOperators();
        Connective = GetConnective();
        Filters = new List<FilterWrapper>();
        Filters.add(new FilterWrapper(++idCounter));
    }


    public void Add()
    {
        FiltersSize++;
        Filters.add(new FilterWrapper(++idCounter));
    }

    public PageReference Remove()
    {
        if (FiltersSize == 1)
            return null;

        FiltersSize--;
        for(Integer i = 0; i < Filters.size(); i++) {
            if (FilterToDelete == Filters[i].Id){
                Filters.remove(i);
            }
        }
        return null;
    }


    protected Sobject[] Search() 
    {
        Sobject[] result;
        if (! SetErrors()){
            string query = BuildQuery();
            errmsg = query;

            try
            {
                result = Database.query(query);
                if (result.Size() == 300){
                    ApexPages.addmessage(new ApexPages.message(
                        ApexPages.severity.INFO, 'Query returned more than 300 records, but only 300 are displayed.'));
                }
                return result;
            }
            catch(Exception ex)
            {
                ApexPages.addmessage(new ApexPages.message(
                    ApexPages.severity.ERROR, 'Could not perform requested query. Please fix all the parameters and values and try again.'));
            }
        }
        return null;
    }


    public void FieldSelected()
    {
        for (FilterWrapper filter : Filters){
            if (filter.Id == SelectedFieldId){
                string type = getFieldType(filter.Field);
                filter.DataType = type;
                filter.Value = GetDefaultFieldValue(type);
                if (type == 'PICKLIST')
                    filter.PicklistValues = getPicklistFor(filter.Field);
                if (type == 'BOOLEAN')
                    filter.PicklistValues = getPicklistForBoolean();
            }
        }
    }




    //build left associative query ((((a) and b) or c) and d)
    private string BuildQuery()
    {
        string query = 'select id, name, Approval_Amount__c, Initiated_by__c, Approval_Status__c, Requested_Final_Approval_Date__c, Appr_Approver_1__c,' +
        ' Program__c, State__c, Period__c, Year__c, Settlement_Number__c, Payment_Due_Date__c, SAP_Id__c from ' + GetObjectName() + ' where ';

        for(integer i = 0; i < Filters.size(); i++)
        {
            query += '(';
        }

        for(integer i = 0; i < Filters.size(); i++)
        {
            //transform dates
            if (Filters[i].dataType == 'DATE')
                Filters[i].value = string.valueof(Filters[i].DateValue);
            if (Filters[i].dataType == 'DATETIME')
                 Filters[i].value = datetime.newInstance(Filters[i].DateValue.year(), Filters[i].DateValue.month(), Filters[i].DateValue.day())
                                .format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
            //transform references
            String refField;
            if (Filters[i].dataType == 'REFERENCE'){
                refField = Filters[i].field.endsWith('__c') 
                    ? (Filters[i].field.removeEnd('c') + 'r.name')
                    : (Filters[i].field + '.name');
            }

            // replace = with like for Strings
            if(Filters[i].dataType == 'STRING' || Filters[i].dataType == 'REFERENCE'){
                if (Filters[i].operator == '=')
                    Filters[i].operator = 'like';
            }

            query += (i == 0 ? '' : Filters[i].Connective) + ' '             // skip fist connective
                    + (refField == null ? Filters[i].field : refField) + ' ' // handle reference types
                    + Filters[i].Operator + ' '
                    + AddParenthesisIfNeeded(Filters[i]) + ' ' // value
                    + ') ' ;
        }
        
        query += ' order by Submitted_Date__c limit 300';
        return query;
    }

    //set some default value on change as a hint for the user
    private string GetDefaultFieldValue(string type)
    {
        if (type == 'DOUBLE') return '0.00';
        else if (type == 'INTEGER') return '0';
        else if (type == 'DECIMAL') return '0.00';
        else if (type == 'CURRENCY') return '0.00';
        else if (type == 'BOOLEAN') return 'TRUE';
        else return '';
    }


    //set error message on each field and return true if eny error was found
    private boolean SetErrors()
    {
        errmsg2 = '';
        boolean anyError = false;
        for(integer i = 0; i < Filters.size(); i++)
        {
            string type = getFieldType(Filters[i].Field);

            if (String.isBlank(Filters[i].Field)){
                Filters[i].Error = 'Field must be selected';
                anyError = true;
                continue;
            }
            
            if ((string.isBlank(Filters[i].Value) && Filters[i].DataType == 'STRING')
                || (Filters[i].DateValue == null && (Filters[i].DataType == 'DATE' || Filters[i].DataType == 'DATETIME')) ){
                Filters[i].Error = 'Value can not be blank';
                anyError = true;
                continue;
            }

            if (string.isBlank(Filters[i].Connective) && i > 0){
                Filters[i].Error = 'Select AND/OR connective.';
                anyError = true;
                continue;
            }

            // if field is arithmetic but operator is non-erithmetic (eg. "contains")
            if (arithmeticTypes.contains(type) && !arithmeticOperators.contains(Filters[i].Operator)){
                Filters[i].Error = 'Cannot apply non-arithmetic operator to field of type ' + type;
                anyError = true;
            }

            
            else if (type == 'DOUBLE' || type == 'DECIMAL' || type == 'CURRENCY') {
                if (! Pattern.compile('^[0-9]+(\\.[0-9]+)?$').matcher(Filters[i].Value).matches()){
                    Filters[i].Error = 'Value for this field should be in 0.00 format.';
                    anyError = true;
                }
            }

            else if (type == 'INTEGER' || type == 'LONG'){
                if (!Filters[i].Value.isNumeric()){
                    Filters[i].Error = 'Wrong value format. Value must be numeric.';
                    anyError = true;
                }
            }

            else if (type == 'BOOLEAN'){
                if (!Filters[i].Value.equalsIgnoreCase('true') && !Filters[i].Value.equalsIgnoreCase('false')){
                    Filters[i].Error = 'Only "true" or "false" values can be set for this field.';
                    anyError = true;
                }
                else if (!booleanOperators.contains(Filters[i].Operator)){
                    Filters[i].Error = 'Only "Equals" and "Not Equals" operators can be applied to this field.';
                    anyError = true;
                }
            }


            else if (type == 'ID'){
                if (!booleanOperators.contains(Filters[i].Operator)){
                    Filters[i].Error = 'Only "Equals" and "Not Equals" operators can be applied to this field.';
                    anyError = true;
                }
                if (! validateId(Filters[i].value)){
                    Filters[i].Error = 'Given value is not a valid Id.';
                    anyError = true;
                }
            }

            else if ((type == 'STRING' || type == 'PICKLIST' || type == 'REFERENCE') && !stringOperators.contains(Filters[i].Operator)){
                Filters[i].Error = 'Only "Equals" and "Not Equals" operators can be applied to this field.';
                anyError = true;
            }

            else if (type == ''){
                Filters[i].Error = 'This field can not be used as a query condition.';
                anyError = true;
            }
            
            if (anyError == false)
                Filters[i].Error = '';


            errmsg2 += Filters[i].field + ' ' + type + '***';
        }
        return anyError;
    }

    private Boolean validateId(String Idparam) 
    {
        String id = String.escapeSingleQuotes(Idparam);
        if((id.length() == 15 || id.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', id)) {
            return true;
        }
        return false;
    }

    //for some types, add the parenthesis (if not already added)
    private string AddParenthesisIfNeeded(FilterWrapper filter)
    {
        string res = filter.Value;
        String type = getFieldType(filter.Field);
        if (!string.isBlank(filter.Value) && filter.Value.startsWith('\'') && filter.Value.endsWith('\''))
            return res;
        if (type == 'STRING' || type == 'ID' || type == 'REFERENCE' || type == 'PICKLIST')
            res = '\'' + filter.Value + '\'';

        return res;
    }

    private List<SelectOption> GetOperators()
    {
        return new List<SelectOption>{
            new SelectOption('=', 'Equals'),
            new SelectOption('!=', 'Not Equals'),
            new SelectOption('<', 'Less Than'),
            new SelectOption('>', 'Greater Than')
        };
    }

    private List<SelectOption> GetConnective()
    {
        return new List<SelectOption>{
            new SelectOption('AND', 'AND'),
            new SelectOption('OR', 'OR')
        };
    }


    private List<SelectOption> getPicklistForBoolean()
    {
    	List<SelectOption> lstPickvals = new List<SelectOption>();
    	lstPickvals.add(new SelectOption('TRUE', 'Yes'));
    	lstPickvals.add(new SelectOption('FALSE', 'No'));

	    return lstPickvals;
    }

    private List<SelectOption> getPicklistFor(string field)
    {
    	List<SelectOption> lstPickvals = new List<SelectOption>();
		List<Schema.PicklistEntry> pick_list_values = fieldMap.get(field).getDescribe().getPickListValues();
		
	    for (Schema.PicklistEntry a : pick_list_values)
	    	lstPickvals.add(new SelectOption(a.getValue(), a.getLabel()));

	    return lstPickvals;
    }

    // return fieldMap used in other methods, to avoid multiple fetching
    private Map <String, Schema.SObjectField> fieldMap
    {
        get {
            if (fieldMap == null)
                fieldMap = Schema.getGlobalDescribe().get(GetObjectName()).getDescribe().fields.getMap();
            return fieldMap;
        }
        set;
    }

    private string getFieldType(string fieldApiName)
    {
        string type = fieldTypes.get(fieldApiName);
        return string.isBlank(type) ? 'REFERENCE' : type;

    }

    //returns map of field names and data types. Data type is empty if not filterable
    private Map<string, string> fieldTypes
    {
        get {
            if (fieldTypes == null){
                fieldTypes = new Map<string, string>();
                for(Schema.SObjectField sfield : fieldMap.Values())
                {
                    schema.describefieldresult dfield = sfield.getDescribe();
                    fieldTypes.put(dfield.getName(), string.valueOf(dfield.getType())); 
                }
            }
            return fieldTypes;
        }
        set;
    }


    public class FilterWrapper
    {
        public FilterWrapper(integer i){
            Id = i;
        }

    	public string Field {get; set;}
    	public string Operator {get; set;}
    	public string Value {get; set;}
        public Date DateValue {get; set;}
    	public string Connective {get; set;}
        public string Error {get; set;}
        public string DataType {get; set;}
        public integer Id {get; set;}
        public List<SelectOption> PicklistValues {get; set;}
    }
}