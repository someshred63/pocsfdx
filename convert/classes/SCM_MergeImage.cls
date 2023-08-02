public virtual class  SCM_MergeImage {

	public String key{get; set;}
	public String value;
	public virtual String getValue()
	{
		return value;
	}
	public virtual void setValue(String val)
	{
		value=val;
	}
}