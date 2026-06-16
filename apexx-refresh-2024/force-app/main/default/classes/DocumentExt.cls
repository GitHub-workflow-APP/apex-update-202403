public class DocumentExt {

    public String taint {get;set;}

    public DocumentExt(ApexPages.StandardController controller) {
        taint = ApexPages.currentPage().getParameters().get('myParamName');
        Document d = (Document) controller.getRecord();
        d.folderid = UserInfo.getUserId(); //this puts it in My Personal Documents
    }                 
}