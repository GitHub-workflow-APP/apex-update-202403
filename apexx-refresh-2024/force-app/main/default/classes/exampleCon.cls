public with sharing class exampleCon {
        Integer count = 0;
        String whatever = '5';
        public String funnyString {get; set;}
        public String funnyString2 {get; set;}
        public String funnyString3 {get; set;}
        public String funnyString4 {get; set;}
        public String secretValue {get; set;}
        public String inputValue {get; set;}

        


        public exampleCon () {
            String taint = ApexPages.currentPage().getParameters().get('taint');
            funnyString = '"<script>alert(1)</script>' + taint;
            funnyString2 = 'ciccio' + taint;
            funnyString3 = '" onclick="alert(900);">' + taint;
            funnyString4 = '" onmouseover="alert(557799);">' + taint;
            secretValue = 'this is a secret' + taint;
            inputValue = funnyString4;
        }

        public PageReference incrementCounter() {
            count++;
            return null;
        }
                
        public Integer getCount() {
            return count;
        }


        public String getWhatever() {
            return whatever;
        }

        public PageReference getMyLink(){
            return new PageReference(ApexPages.currentPage().getParameters().get('taint')); // CWEID 99
        }


        public List<PieWedgeData> getPieData() {
            List<PieWedgeData> data = new List<PieWedgeData>();
            data.add(new PieWedgeData('Jan<script>alert(1)</script>', 30));
            data.add(new PieWedgeData('Feb', 15));
            data.add(new PieWedgeData('Mar', 10));
            data.add(new PieWedgeData('Apr', 20));
            data.add(new PieWedgeData('May', 20));
            data.add(new PieWedgeData('Jun', 5));
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