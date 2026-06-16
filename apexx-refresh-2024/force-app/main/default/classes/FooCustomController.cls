public with sharing class FooCustomController {

    public String foo {get; set;}
    public String fnName {get; set;}
    public String taintVariable {get; set;}
    public String contentType {get; set;}
    public String taintLink {get; set;}
    
    public FooCustomController() {
        String taint = ApexPages.currentPage().getParameters().get('myParamName');
        foo = 'smth' + taint;
        fnName = 'alert(1);runMe'  + taint;
        taintVariable = 'alert(2)' + taint;
        contentType = 'whatever"\'calamaro<b>;' + taint;
        taintLink = 'javascript:alert(99);' + taint;
        System.debug('.ctrl');

    }

    // public String getFoo() {
    //     return this.foo;
    // }

    public void aSimpleMethod(){
        this.foo = 'aSimpleMethod';
        System.debug('PIPPO');
        // return null;
    }


    public void aSimpleMethod2(){
        this.foo = 'aSimpleMethod2';
        // return 'aSimpleMethod return value';
    }

    public void doNothing(){
        
    }


}