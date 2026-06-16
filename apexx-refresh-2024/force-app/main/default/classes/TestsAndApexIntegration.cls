public with sharing class TestsAndApexIntegration {
    List<lead> recoveredFromTest {get; set;}
    public TestsAndApexIntegration() {

        ValidateSoqlQueriesTest v = new ValidateSoqlQueriesTest();

        recoveredFromTest = v.returnSomething();
    }
}