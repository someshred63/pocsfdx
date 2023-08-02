//--------------------------------------------------------------------------------
// COMPONENT: SFA Primary Care
//     CLASS: GNE_Pager_Controller
//   PURPOSE: Controller for the Pager
// 
//     OWNER: Genentech
//   CREATED: 05/2010
//--------------------------------------------------------------------------------
Public Class GNE_Pager_Controller extends GNE_Base_Controller
{
    Public GNE_Pager_Controller()
    {
        //setClassName('GNE_Pager_Controller'); 
    }
    public Integer resultsSize {get;set;}
    public String PageNumberText { get; set; }
    public String actualPage {get;set;}
    public String countPage {get;set;}

    private GNE_Base_Pager pager;
    
    public GNE_Base_Pager getPager()
    {
        return pager;
    }
    public void setPager(GNE_Base_Pager value)
    {
        if (value != null && value.getRecordCount() != null)
        {
            PageNumberText = '';
            Decimal numPages = Double.valueOf(String.valueOf(value.getRecordCount())) / value.getDispRows();
			countPage = 'of ' + numPages.round(system.roundingMode.CEILING);
            if (numPages > 1)
                PageNumberText = 'Page ' + value.getCurrentPage() + ' of ' + numPages.round(system.roundingMode.CEILING);
        		actualPage = String.valueOf(value.getCurrentPage());
            pager = value;
        }
    }
       

    private String reRender;
    public String getReRender()
    {
        return reRender;
    }
    public void setReRender(String value)
    {
        reRender = value;
    }
}