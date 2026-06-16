public with sharing class CaseFunExt {

    public String taint {get;set;}
    public String taint2 {get;set;}


    public CaseFunExt(ApexPages.StandardSetController controller) {
        taint = '"});alert(9);doNothing({"p":"p>' + ApexPages.currentPage().getParameters().get('myParamName');
        taint2 = 'hover me" x=">" onmouseover="alert(777)" ' + ApexPages.currentPage().getParameters().get('myParamName');
    }
}