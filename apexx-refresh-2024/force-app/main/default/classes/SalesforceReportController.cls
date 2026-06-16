/*** Controller ***/
public with sharing class SalesforceReportController {

    public String fnName1 {get; set;}
    public String fnName2 {get; set;}
    public String sectionDescription {get; set;}
    public String chartSize {get; set;}
    
    public SalesforceReportController() {
        fnName1 = ApexPages.currentPage().getParameters().get('fnName1');

        fnName2 = ApexPages.currentPage().getParameters().get('fnName2');

        sectionDescription = ApexPages.currentPage().getParameters().get('sectionDescription');

        chartSize = ApexPages.currentPage().getParameters().get('chartSize');
    }

    public PageReference aSimpleMethod(){
        return new PageReference(ApexPages.currentPage().getParameters().get('redirect')); // CWEID 99
    }

    public List<PieWedgeData> getPieData() {
        List<PieWedgeData> data = new List<PieWedgeData>();
        data.add(new PieWedgeData('Jan', 30));
        return data;
    }

        
        // Wrapper class
        public class PieWedgeData {
    
            public String name { get; set; }
            public Integer data { get; set; }
    
            public PieWedgeData(String name, Integer data) {
                this.name = name;
                this.data = data;
            }
        }


}