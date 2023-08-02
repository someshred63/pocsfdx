public class SCM_MergeDocumentCaching {
	private static Boolean setBooleanValue(String strBoolean)
    {
    	if(strBoolean!=null)
    	{
    		if(strBoolean=='true')
    			return true;
    		else
    			return false;
    	}
    	else
    		return false;
    }
    
    private static String setStringValue(String str)
    {
    	if(str!=null)
    	{
    		if(str=='null')
    			return null;
    		else
    		{
    			str = str.replace('&amp;','&');
    			str = str.replace('&quot;','"');
    			str = str.replace('&gt;','>');
    			str = str.replace('&lt;','<');
    			return str;
    		}
    	}
    	else
    		return null;
    }
    
    private static String getStringValue(String str)
    {
    	if(str!=null)
    	{
    		str = str.replace('&','&amp;');
    		str = str.replace('"','&quot;');
    		str = str.replace('>','&gt;');
    		str = str.replace('<','&lt;');
    		return str;
    	}
    	else
    		return 'null';
    }
    
    private static void parseSelectionItems(XmlStreamReader reader, SCM_MergeField mField)
    { 	
    	try
    	{
    	while(reader.hasNext())
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'In Parse Selection Event Type:' +reader.getEventType() + ' Local : ' + reader.getLocalName() ));
    		if (reader.getEventType() == XmlTag.END_ELEMENT && 
    			reader.getLocalName()=='MergeField')
    		{
    		    break;	
    		}
           	else if(reader.getEventType() == XmlTag.START_ELEMENT && 
    			    reader.getLocalName()=='selectionItem')
           	{  
           		
           		// Check this part for value-label... 
           		String attLabel=reader.getAttributeValue(null,'selectionItemLabel');
           		String attValue=reader.getAttributeValue(null,'selectionItemValue');
           		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Parse Selection AttVal :'+ attValue ));
           		if(reader.getLocalName()=='selectionItem' && attValue!=null)
           		{
           			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Selected Value is being set...'));
           			SelectOption option=new SelectOption(attValue,attLabel);
           			mField.selectionItems.add(option);
           			if(mField.getMergeValue()==attValue)
           				mField.setSelectedValue(attValue);  		
           		}
           	}
           //	else
    	//	{
    	//		reader.next();
    	//		continue;
    	//	}
           	reader.next();
    	}
    	}
    	catch(Exception exp)
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'EXCEPTION in parseSelectionItems Message:'+ exp.getMessage() ));
    	}
    }
    

    private static void parseAttributeValues(XmlStreamReader reader, SCM_MergeField mField)
    {
    	
    	mField.className = setStringValue(reader.getAttributeValue(null,'className'));
    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Parse Attribute ClassName :' +  mField.className));
    	mField.key = setStringValue(reader.getAttributeValue(null,'key'));
    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Parse Attribute Key :' +  mField.key));
    	mField.setFieldValue(setStringValue(reader.getAttributeValue(null,'mergeValue')));
    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Parse Attribute FieldValue :' +  mField.fieldValue));
    	mField.setMergeValue(setStringValue(reader.getAttributeValue(null,'mergeValue')));
    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Parse Attribute MergeValue :' +  mField.mergeValue));
    	mField.isFieldGroup =  setBooleanValue(reader.getAttributeValue(null,'isFieldGroup'));
    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Parse Attribute isFieldGroup :' +  mField.isFieldGroup));
    	mField.label = setStringValue(reader.getAttributeValue(null,'label'));
    	mField.displayCheck = setBooleanValue(reader.getAttributeValue(null,'displayCheck'));
    	mField.displayTextBox = setBooleanValue(reader.getAttributeValue(null,'displayTextBox'));
    	mField.displayLabel = setBooleanValue(reader.getAttributeValue(null,'displayLabel'));
    	mField.displayRadio = setBooleanValue(reader.getAttributeValue(null,'displayRadio'));
    	mField.displayDropDown = setBooleanValue(reader.getAttributeValue(null,'displayDropDown'));
    	mField.displayTextArea = setBooleanValue(reader.getAttributeValue(null,'displayTextArea'));
    	mField.displayField = setBooleanValue(reader.getAttributeValue(null,'displayField'));
    	mField.isNewLine = setBooleanValue(reader.getAttributeValue(null,'isNewLine'));
    	mField.isRequired = setBooleanValue(reader.getAttributeValue(null,'isRequired'));
    	mField.isFormField = setBooleanValue(reader.getAttributeValue(null,'isFormField'));
    	mField.headerText = setStringValue(reader.getAttributeValue(null,'headerText'));
    	mField.width = setStringValue(reader.getAttributeValue(null,'width'));
    	mField.totalWidth = setStringValue(reader.getAttributeValue(null,'totalWidth'));
    	mField.height = setStringValue(reader.getAttributeValue(null,'height'));
    	mField.checked = setBooleanValue(reader.getAttributeValue(null,'checked'));
    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Parse Attribute checked :' +  mField.checked));
    }
    
    private static SCM_MergeField parseMergeField(XmlStreamReader reader)
    {
    	SCM_MergeField mField = new SCM_MergeField();
    	
    	parseAttributeValues(reader, mField);
    	
    	while(reader.hasNext())
    	{
    		System.debug('\nElement Name :' + reader.getLocalName());
    		if (reader.getEventType() == XmlTag.END_ELEMENT && 
    			reader.getLocalName()=='MergeField') 
           		break;
        	else if(reader.getEventType() == XmlTag.START_ELEMENT &&
        			reader.getLocalName()=='selectionItem')
        	{
        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Selection Items starting...'));
        		parseSelectionItems(reader, mField);
        		break;	
        	}
        	reader.next();
    	}
    	return mField;
    }
    
    private static SCM_MergeField parseMergeFieldGroup(XmlStreamReader reader)
    {
    	SCM_MergeField mField = new SCM_MergeField();
        parseAttributeValues(reader, mField);
    	
    	while(reader.hasNext())
    	{
    		System.debug('\nElement Name :' + reader.getLocalName());
    		if (reader.getEventType() == XmlTag.END_ELEMENT && 
    			reader.getLocalName()=='MergeFieldGroup') 
           		break;
        	else if(reader.getEventType() == XmlTag.START_ELEMENT &&
        			reader.getLocalName()=='MergeField')
        	{
        		SCM_MergeField subField= parseMergeField(reader);
        		mField.subFields.add(subField);	
        	}
        	reader.next();
    	}
    	
    	return mField;
    }
     
    
     
    private static void getMergeFieldsFromViewStateXML(XmlStreamReader reader , List<SCM_MergeField> mFields,String sectionName)
    {
    	while(reader.hasNext())
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Event Type :' + XmlTag.START_ELEMENT));
    		System.debug('\n Event Type :' + XmlTag.START_ELEMENT);
    		if (reader.getEventType() == XmlTag.START_ELEMENT) 
    		{
    			System.debug('\nElement Name :' + reader.getLocalName());
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Element Name :' + reader.getLocalName()));
    			if ( reader.getLocalName() =='MergeField') 
    			{
                	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'XML Parse MergeField'));
                	SCM_MergeField mField = parseMergeField(reader);
                	mFields.add(mField);
            	}
            	else if( reader.getLocalName() =='MergeFieldGroup') 
    			{
                	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'XML Parse MergeFieldGroup'));
                	SCM_MergeField mField = parseMergeFieldGroup(reader);
                	mFields.add(mField);
            	}
    			
    		}
    		if(reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() ==sectionName)
    			break; 
    		reader.next();
    	}  	
    }   
       
    public static  List<SCM_MergeField> getSectionMergeFields(String fieldXML, String sectionName)
    {
    	XmlStreamReader reader = new XmlStreamReader(fieldXML);
    	List<SCM_MergeField> mFields= new List<SCM_MergeField>();
    	while(reader.hasNext())
    	{
    		
    		if(reader.getEventType() == XmlTag.START_ELEMENT &&
    		   reader.getLocalName() ==sectionName )
    		   {
    		   	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Section Name:'+ sectionName));
    		   getMergeFieldsFromViewStateXML(reader, mFields, sectionName);
    		   }
    		reader.next();
    	}
    	return mFields;
    }   
    
    public static void printMergeField(SCM_MergeField mField)
	{
		System.debug('\n Label : '  + mField.label + ' Value : ' +  mField.getMergeValue() + ' Key : '+ mField.key + ' isFieldGroup :' + mField.isFieldGroup + '\n');
        if(mField.selectionItems.size()>0)
        {
        	System.debug('\n SELECTION START \n');
        	for(SelectOption selection:  mField.selectionItems)
        		System.debug('\n Selection Item : ' + selection.getValue() );
        	System.debug('\n SELECTION END \n');
        }
        if(mField.isFieldGroup)
        {
        	System.debug('\n SUBFIELDS COUNT :' + mField.subFields.size()+ '\n');
        	for(SCM_MergeField subField:mField.subFields)
        		printMergeField(subField);
        		
        	System.debug('\n SUBFIELDS END \n');
        }
	}
	
	
	    /*
    <document>
    <recipientinfo>
    		*<MergeField />
    		*<MergeFieldGroup>
    			<MergeField/>
 		 	</MergeFieldGroup>
    <recipientinfo>
    <mergefields>
    		*<MergeField />
    		*<MergeFieldGroup>
    			<MergeField/>
 		 	</MergeFieldGroup>
    </mergefields>
    <document>
    */
    
    private static String setAttributes(SCM_MergeField mField)
    {
    	String fieldXML = '';
    	fieldXML += ' className= "' + getStringValue(mField.className) +'" ';
    	fieldXML += ' key= "' + getStringValue(mField.key) +'" ';
    	fieldXML += ' mergeValue= "' + getStringValue(mField.getMergeValue())+ '" ';
    	fieldXML += ' checked= "' + mField.checked + '" ';
 		fieldXML += ' isFieldGroup= "' + mField.isFieldGroup + '" ';
         /*   	
    	fieldXML += ' label= "'+ getStringValue(mField.label) + '" ';
    	
    	fieldXML += ' displayCheck= "' + mField.displayCheck + '" ';
    	fieldXML += ' displayTextBox= "' + mField.displayTextBox + '" ';
    	fieldXML += ' displayLabel= "' + mField.displayLabel + '" ';
    	fieldXML += ' displayRadio= "' + mField.displayRadio + '" ';
    	fieldXML += ' displayDropDown= "' + mField.displayDropDown + '" ';
    	fieldXML += ' displayTextArea= "' + mField.displayTextArea + '" ';
    	fieldXML += ' displayField= "' + mField.displayField + '" ';
    	fieldXML += ' headerText= "' + mField.headerText + '" ';
    	fieldXML += ' isNewLine= "' + mField.isNewLine + '" ';
    	fieldXML += ' isRequired= "' + mField.isRequired + '" ';
    	fieldXML += ' isFormField= "' + mField.isFormField + '" ';
    	fieldXML += ' width= "' + mField.width + '" ';
    	fieldXML += ' totalWidth= "' + mField.totalWidth+ '" ';
    	fieldXML += ' height= "' + mField.height + '" ';
    	*/
    	
    	return fieldXML;
    }
    
    private static String setMergeField(SCM_MergeField mField)
    {
    	String fieldXML='<MergeField ';
    	
    	fieldXML+= setAttributes(mField);
    	if(mField.selectionItems.size()>0)
    	{
    		fieldXML += ' > ';
    		for(SelectOption selectionItem : mField.SelectionItems)
    		{
    			fieldXML += ' <selectionItem ';
    			fieldXML += ' selectionItemLabel= "'+ selectionItem.getLabel() + '" ';
    			fieldXML += ' selectionItemValue= "'+ selectionItem.getValue() + '" ';
    			fieldXML += '/>';
    		} 
    		
    		fieldXML += ' </MergeField>';
    	}
    	else
    		fieldXML +=' />';
    	
    	return fieldXML;
    	
    }
    
    private static String setMergeFieldGroup(SCM_MergeField mFieldGroup)
    {
    	String fieldXML='<MergeFieldGroup ';
    	fieldXML +=  setAttributes(mFieldGroup);
    	fieldXML += '>';
    	
    	for(SCM_MergeField subField:mFieldGroup.subFields)
    	{
    		fieldXML += setMergeField(subField);
    	}
    	
    	fieldXML += ' </MergeFieldGroup>';
    	
    	
    	return fieldXML;
    }
    
    private static String setMergeFieldsToViewStateXML(SCM_MergeField[] mFields)
    {
    	String strViewState=''; 
    	for(SCM_MergeField mField:mFields)
    	{
    	 	if(mField.isFieldGroup)
    	 		strViewState+=setMergeFieldGroup(mField);
    	 	else
    	 		strViewState+=setMergeField( mField);
    	}
    	return strViewState;
    }
    
    public static String createViewStateXML(List<SCM_MergeField > mergeFields)
    {
    	try
    	{
    		String strViewState='<?xml version="1.0" encoding="UTF-8"?>';
    		strViewState+='<document>';
    	
    		//strViewState+= '<RecipientInfo>';
    		//strViewState +=setMergeFieldsToViewStateXML(mergeRecipientInfo);
    		//strViewState+= '</RecipientInfo>';
    		strViewState+= '<MergeFields>';
    		strViewState +=setMergeFieldsToViewStateXML(mergeFields);
    		strViewState+= '</MergeFields>';
    		strViewState+='</document>';
    		
    		return strViewState;
    	}
    	catch(Exception exp)
    	{
    		return '';
    	}
    }
}