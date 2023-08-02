//Updated
global virtual class SCM_MergeField {
    public enum FieldTypes {textboxField ,checkboxField, phoneNumberField, extensionField, 
                            fullNameField, emailField, dateField, fieldGroup}

    public String className{get; set;} 
    public  String key;
    
    public virtual String getKey()
    {
        return key;
    } 
    public virtual void setKey(String arg)
    {
        key = arg;
    }
    public  String cssClass;
    
    public virtual String getCssClass()
    {
        return cssClass;
    } 
    public virtual void setCssClass(String arg)
    {
        cssClass = arg;
    }
    public  String label { get; set;}

    // This property is used for long html formatted labels in wizard pages. 
    public String extraHTML { get; set; }
    
    
    public  String fieldValue; 
    public virtual String getFieldValue()
    {
        return fieldValue;
    } 
    public virtual void setFieldValue(String arg)
    {
        fieldValue = arg;
    }
    
    
    
    public Boolean allowCache{get;set;}
    
    // This property is used to add a \n\r in the end of the merge value
    // while creating the field XML
    public Boolean requireNewLineInTemplate{get; set;}
    
    public Boolean initialValue{get; set;}
    
    
    public String mergeValue;
    public virtual String getMergeValue()
    {try {
        if(initialValue)
        {
            fieldValue = getFieldValue();
            mergeValue = fieldValue;
            initialValue= false;
            
        }
        return mergeValue;
    }catch(exception ex) {return '';}
    } 
    public virtual void setMergeValue(String arg)
    {
        mergeValue = arg;
        if(initialValue)
            initialValue=false;
    }
    
    public  Boolean checked;
    public Boolean getChecked()
    {
        return checked;
    } 
    public void setChecked(Boolean val)
    {
        checked = val;
    } 
    public  Boolean displayCheck { get; set;}
    
    public  Boolean displayTextBox;
    public Boolean getDisplayTextBox()
    {
        return displayTextBox;
    } 
    public void setDisplayTextBox(Boolean val)
    {
        displayTextBox = val;
    }
    
    
    public Boolean displayExtraHTML;
    public Boolean getDisplayExtraHTML()
    {
        return displayExtraHTML;
    }
    public void setDisplayExtraHTML(Boolean val)
    {
        displayExtraHTML = val; 
    }
    
    public  Boolean displayLabel;
    public Boolean getdisplayLabel()
    {
        return displayLabel;
    } 
    public void setdisplayLabel(Boolean val)
    {
        displayLabel = val;
    }
    //Added by Stylus -- Start
    public  Boolean displayRadio { get; set;}
    
   // public  Boolean displayButton { get; set;}
    public  Boolean displayDropDown { get; set;} // Combo box
   // public  Boolean displayEllipsis { get; set;}
   
    public  Boolean displayTextArea;
    public Boolean getDisplayTextArea()
    {
        return displayTextArea;
    } 
    public void setDisplayTextArea(Boolean val)
    {
         displayTextArea = val;
    }
    //Added by Stylus -- End
    
    // The display configuration for the whole field section
    public Boolean displayField{
        get
        {
            if( !this.isFieldGroup && 
                                (this.displayCheck ||
                                 this.displayTextBox ||
                                 this.displayLabel ||
                                 this.displayRadio ||
                                 this.displayDropDown ||
                                 this.displayTextArea)
              )
              return true;
            else if(this.isFieldGroup && this.subFields.size()>0 )
                return true;
            else
             return false;
            //return true;
        } 
        set;}
    
    public List<SelectOption> selectionItems;
    public List<SelectOption> getSelectionItems()
    {
        return selectionItems;
    } 
    public void setSelectionItems(List<SelectOption> val)
    {
        selectionItems = val;
    }
    public String selectedValue;
    public String getSelectedValue()
    { 
        return selectedValue;
    } 
    public void setSelectedValue(String val)
    {
        selectedValue = val;
    }
         
    
    public FieldTypes fieldType;
    public FieldTypes getFieldType()
    {
        return fieldType;
    } 
    public void setFieldType(FieldTypes val)
    {
        fieldType = val;
    }
    
    public Boolean isFieldGroup;
    public Boolean getIsFieldGroup()
    {
        return isFieldGroup;
    } 
    public void setIsFieldGroup(Boolean val)
    {
        isFieldGroup = val;
    }
    
    
    public String headerText { get; set; }
    
    // This read-only property is used by Fax-Cover Wizard pages 
    // in order to configure the render process. 
   // public Boolean isSingleField { get{return !isFieldGroup;}}
    
    public List<SCM_MergeField> subFields {get; set;}
    
    public Boolean isNewLine { get; set; }
    public Boolean isRequired { get; set; }
    public Boolean isFormField { get; set; }
    
    // The width property is to set 
    // the necessary css sytlng & validation at front end 
    // especially for textarea fields
     
    public String width;
    public virtual String getWidth()
    {
        return width;
    }
    public virtual void setWidth(String val)
    {
        width = val;
    }
    
    public String height;
    public virtual String getHeight()
    {
        return height;
    }
    public virtual void setHeight(String val)
    {
        height = val;
    }
    public String totalWidth;
    public virtual String getTotalWidth()
    {
        return totalWidth;
    }
    public virtual void setTotalWidth(String val)
    {
        totalWidth = val;
    }

    public String totalHeight;
    public virtual String getTotalHeight()
    {
        return totalHeight;
    }
    public virtual void setTotalHeight(String val)
    {
        totalHeight = val;
    }
    
    
    public String controlStyle;
    public virtual String getControlStyle()
    {
        if(controlStyle==null || controlStyle=='')
        {
            controlStyle='';
            if(width!=null && width!='')
                controlStyle+='width:' + width +'px;';
        
            if(height!=null && height!='')
                controlStyle+='height:' + height + 'px;';
        }
        return controlStyle;    
    }
    
    public virtual void setControlStyle(String val)
    {
        controlStyle = val;
    }
        

     
    public String  fieldStyle;
    public virtual String getFieldStyle()
    {
        
        if(fieldStyle==null || fieldStyle=='')
        {
            fieldStyle='';
            if(totalWidth!=null && totalWidth!='')
                fieldStyle+='width:' + totalWidth +'px;';
        
            if(totalHeight!=null && totalHeight!='')
                fieldStyle+='height:' + totalHeight + 'px';
        }
        if(totalWidth!=null && totalWidth!='')
        	fieldStyle+='width:' + totalWidth +'px;';
       // fieldStyle+=' display:inline;';
        return fieldStyle;      
    }
    public virtual void setFieldStyle(String val)
    {
        fieldStyle = val;
    }
   
    
    public virtual String getFieldTypeName()
    {
        String css = cssClass;
        if(isFormField)
            css += ' formField ';
        if(isNewLine)
            css += ' newFormLine ';
        if(isRequired)
            css += ' requiredField ';
        
        
        css += fieldType.Name();
        return css;
    }
        
    public SCM_MergeField()
    {
        Initialize();
    }
    
    
    
    public SCM_MergeField(String Key, String Label, Boolean DisplayCheckbox )
    {
        Initialize();
        key = Key;
        
        label= Label;

        displayCheck = DisplayCheckbox;
        displayLabel = DisplayCheckbox;
        
    }
    
    private void Initialize()
    {
        className ='SCM_MergeField';
        fieldType = FieldTypes.textboxField;
        initialValue = true;  
        //displayField=true;
        displayLabel=displayTextBox=displayCheck=true;
        displayRadio=displayDropdown=displayTextArea=displayExtraHTML=false;
        
        cssClass = '';
        isNewLine = true;
        isRequired = true; 
        isFormField= true;
        allowCache = true;
        checked = false;
        isFieldGroup=false;
        requireNewLineInTemplate=false;
        subFields = new List<SCM_MergeField>();
        selectionItems = new List<SelectOption>();
        //fieldStyle = 'width:50';
        //controlStyle = 'width:40';
       // width = '95';  
       // totalWidth = '100';
         // as a default value for width        
     }
}