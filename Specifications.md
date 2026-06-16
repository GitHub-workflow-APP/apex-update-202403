# Apex Refresh April 2024

## Visual Force tags review
Reviewing the results of customers' scans of Visual Force pages we identified a need to tightened up the analisys we do for `<apex:` tags and in particular the tags' attributes. The following paragraph lists the attributes that we should analyse for security flaws and attributes that can be considered safe.

### Problematic Visual Force attributes
In this paragraph we list VisualForce tags, that appears in the form of `<apex:component_name` and the attribute that can be problematic if are assigned a taint or specific values. Attributes not listed in this list can be considered safe.

|   CWE     | VisualForce tag       | Vulnerable attribute | testcase |
| --------- | ---------------       | -------------------- | ---------|
|  CWE 80   | all tags              | all attributes `on*` | [CustomControllerDemo.page](apexx-refresh-2024/force-app/main/default/pages/CustomControllerDemo.page)  |
|           | apex:actionFunction   | name                 | [CustomControllerDemo.page#L9](apexx-refresh-2024/force-app/main/default/pages/CustomControllerDemo.page#L9) |
|           |                       |                      | [SalesforceReport.page#L7](apexx-refresh-2024/force-app/main/default/pages/SalesforceReport.page#L7) |
|           | apex:chart            | width                | [SalesforceReport.page#L28](apexx-refresh-2024/force-app/main/default/pages/SalesforceReport.page#L28) |
|           |                       | height               | [SalesforceReport.page#L21](apexx-refresh-2024/force-app/main/default/pages/SalesforceReport.page#L21) |
|           | apex:includeScript    | value                | [DemoPoller.page#L66](apexx-refresh-2024/force-app/main/default/pages/DemoPoller.page#L66)|
|           | apex:sectionHeader    | description          | [ChartsFun.page#L15](apexx-refresh-2024/force-app/main/default/pages/ChartsFun.page#L15)|
|           |                       |                      | [SalesforceReport.page#L35](apexx-refresh-2024/force-app/main/default/pages/SalesforceReport.page#L35)|
|           | apex:outputLink       | value                | [DemoPoller.page#L70](apexx-refresh-2024/force-app/main/default/pages/DemoPoller.page#L70)|
|           |                       |                      | [CustomControllerDemo.page#L50](apexx-refresh-2024/force-app/main/default/pages/CustomControllerDemo.page#L50)|
|           | apex:logCallPublisher | logCallBody          | [CaseFun.page#L3](apexx-refresh-2024/force-app/main/default/pages/CaseFun.page#L3)|
|           |                       | submitButtonName     | [CaseFun.page2#L4](apexx-refresh-2024/force-app/main/default/pages/CaseFun2.page#L4)|
|           |                       | submitFunctionName   | [CaseFun.page3#L3](apexx-refresh-2024/force-app/main/default/pages/CaseFun3.page#L3)|
| CWE 918   | apex:commandButton    | image                | [CustomControllerDemo.page#L25](apexx-refresh-2024/force-app/main/default/pages/CustomControllerDemo.page#L25)|
|           | apex:iframe           | src                  | [DemoPoller.page#L55](apexx-refresh-2024/force-app/main/default/pages/DemoPoller.page#L55)|
|           | apex:image            | value                | [DemoPoller.page#L58](apexx-refresh-2024/force-app/main/default/pages/DemoPoller.page#L58)|
|           | apex:stylesheet       | value                | [ChartsFun.page#L3](apexx-refresh-2024/force-app/main/default/pages/ChartsFun.page#L3)|
| CWE 285   | apex:inputField       | ignoreEditPermissionForRendering = true or tainted | [InputFieldFun.page#L9](apexx-refresh-2024/force-app/main/default/pages/InputFieldFun.page#L9)|

### Message text to use for CWE 918 in Apex when in VisualForce pages

```
ssrf_visualforce,default <span>The identified security flaw allows an attacker to specify an arbitrary URL or part of it as the %s attribute of an %s tag. This can enable an attacker to manipulate the URL or include references to Apex variables, potentially allowing them to send values to a remote server under their control.
This vulnerability constitutes a form of Server-Side Request Forgery (SSRF), which can lead to unauthorized access to a variety of sensitive information, data exfiltration, or other malicious activities.</span><span> To mitigate this issue, it is crucial to validate and sanitize user-supplied input. Additionally, consider using allowlists or denylists for permitted domains to restrict potential SSRF attacks.</span><span>References : <a href="https://cwe.mitre.org/data/definitions/918.html">CWE 918</a><BR><a href="https://developer.salesforce.com/docs/atlas.en-us.securityImplGuide.meta/securityImplGuide/review_and_certification.htm">Security Guidelines for Apex and Visualforce Development</a></span>
```

## APEX Tests

Classes annotated with `@isTest` should not be checked for the presence or absence of the `with sharing` modifier, as these classes cannot be used to access org records from a non-test context. Even when `SeeAllData=true` is set, data remains inaccessible from a non-test context. For this reason we are not flagging SOQL queries with **CWE 284** in `@isTest` annotated class.
However, using `SeeAllData=true` should still be avoided due to the risk of leaking production or sensitive data in debug logs. As a result, we are going to flag the presence of this annotation specifier with **CWE-532** to highlight the potential unintended exposure of sensitive information.

[CWE 532 Class level - DialogueControllerTest.csl:22](force-app/main/default/classes/DialogueControllerTest.cls#L22)
[CWE 532 Method level - ValidateSoqlQueriesTest.csl:27](force-app/main/default/classes/ValidateSoqlQueriesTest.cls#L27)

[FP 284 - DialogueControllerTest.csl:29](force-app/main/default/classes/DialogueControllerTest.cls#L29)
[FP 284 - ValidateSoqlQueriesTest.csl:30](force-app/main/default/classes/ValidateSoqlQueriesTest.cls#L30)
[FP 284 - ValidateSoqlQueriesTest.csl:35](force-app/main/default/classes/ValidateSoqlQueriesTest.cls#L35)

### Message text to use for CWE 532 in Apex when SeeAllData=true


> The @isTest(SeeAllData=true) annotation allows test methods to access all organization records, potentially exposing sensitive production data in debug logs or other unintended contexts. This can lead to unintended exposure of sensitive information,  violating data privacy and security principles. Unless necessary for specific test sets, it's advised to create and utilize test-specific data in Apex test classes, ensuring data isolation and preventing the leakage of sensitive information.



## User Mode for Database Operations WITH USER_MODE / WITH SYSTEM_MODE
 Winter '23 (API Version 56) Salesforce released better native capabilities to enforce CRUD and FLS security on SOQL and DML. This release introduced two mode of operation: `WITH USER_MODE` and `WITH SYSTEM_MODE` that can be used in SOQL and SOSL query.

[Salesforce - Enforce User Mode for Database Operations](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_enforce_usermode.htm)
[Salesforce FOR ARTISANS - Secure access to data with Apex – the new way](https://salesforcegraells.wordpress.com/2023/06/05/secure-access-to-data-with-apex/)
[Medium - Salesforce Inherited sharing](https://medium.com/salesforce-champion/salesforce-inherited-sharing-c010a6832097)

>Salesforce recommends that you enforce Field Level Security (FLS) by using WITH USER_MODE rather than WITH SECURITY-ENFORCED because of these additional advantages.
>
>    - WITH USER_MODE accounts for polymorphic fields like Owner and Task.whatId.
>    - WITH USER_MODE processes all clauses in the SOQL SELECT statement including the WHERE clause.
>    - WITH USER_MODE finds all FLS errors in your SOQL query, while WITH SECURITY ENFORCED finds only the first error. Further, in user mode, you can use the getInaccessibleFields() method on QueryException to examine the full set of access errors.


With this mode of operations available, we should extend our current CWE 284 detection to cover the following cases, but allow customers time to allign their code to the latest guidelines. For this reason we can temporarily use `CWE 274 - Improper Handling of Insufficient Privileges` that has a *Severity 0*, to start reporting code requiring update without impacting the customer compliance with CWE 284 right from the start. 
We should also highlight this behaviour in the release notes and define a deadline after which we will switch this findings into CWE 284.

| Class declared as | Mode Of Operation | CWE on SOQL / SOSL | testcase                |
| ----------------- | ----------------- | ------------------ | ----------------------- |
| not defined       |  not defined      |  CWE 284           | [DialogueUnspecifiedSharing.cls#L27](apexx-refresh-2024/force-app/main/default/classes/DialogueUnspecifiedSharing.cls#L27) |
| not defined       | WITH SYSTEM_MODE  |  CWE 284           | [DialogueUnspecifiedSharing.cls#L44](apexx-refresh-2024/force-app/main/default/classes/DialogueUnspecifiedSharing.cls#L44) |
| not defined       | WITH USER_MODE    |  FP 284            | [DialogueUnspecifiedSharing.cls#L10](apexx-refresh-2024/force-app/main/default/classes/DialogueUnspecifiedSharing.cls#L10) |
| `without sharing` |  not defined      |  CWE 284           | [DialogueWithoutSharingController.cls#L27](apexx-refresh-2024/force-app/main/default/classes/DialogueWithoutSharingController.cls#L27) |
| `without sharing` | WITH SYSTEM_MODE  |  CWE 284           | [DialogueWithoutSharingController.cls#L44](apexx-refresh-2024/force-app/main/default/classes/DialogueWithoutSharingController.cls#L44) |
| `without sharing` | WITH USER_MODE    |  FP  284           | [DialogueWithoutSharingController.cls#L10](apexx-refresh-2024/force-app/main/default/classes/DialogueWithoutSharingController.cls#L10) |
| `with sharing`    |  not defined      |  FP  284           | [DialogueController.cls#L27](apexx-refresh-2024/force-app/main/default/classes/DialogueController.cls#L27) |
| `with sharing`    | WITH SYSTEM_MODE  |  CWE 284           | [DialogueController.cls#L44](apexx-refresh-2024/force-app/main/default/classes/DialogueController.cls#L44) |
| `with sharing`    | WITH USER_MODE    |  FP  284           | [DialogueController.cls#L10](apexx-refresh-2024/force-app/main/default/classes/DialogueController.cls#L10) |

### @AuraEnabled annotation
`@AuraEnabled` annotation makes the code inside the annotated method defaults to `with sharing` only when there is no sharing defined in the external class definition.
When the external class explicitly declares its sharing mode, the `@AuraEnabled` annotated methods will foolow the same sharing model of the containing class.


#### External class with explicit sharing mode defined
In this case, the `@AuraEnabled` method inherits the same sharing mode of the containing class.

```
public without sharing class PagghiazzuController {

    @AuraEnabled
    public static List<Pagghiazzu__c> getPagghiazzi() {
        try {
            // AuraEnabled methods default to WITH_SHARING ONLY when no sharing condition is specified at class level
            return [SELECT Id, Name, Color__c, OwnerId FROM Pagghiazzu__c]; // CWE 284
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
```


#### External class without explicit sharing mode defined
In this case, the `@AuraEnabled` method defaults to `with sharing` because the containing class doesn't have a sharing mode defined.


```
public class UserModeDemoUndefSharing {

    // This method is not vulnerable because of the @AuraEnabled annotation. This method is like it is executed inside with 'with sharing'
    @AuraEnabled
    public static List<Dialog__c> getMyDialogues() {
        List<Dialog__c> allDialoguesAuraEnabled;
        allDialoguesAuraEnabled = [SELECT name, Message__c, OwnerId FROM Dialog__c]; // CWE 274 because row access is safe but column access is not checked
        if(allDialoguesAuraEnabled.size()>0)
        {
            return allDialoguesAuraEnabled;
        }
        return null;
    }

```

## Extending CRUD/FLS (CreateReadUpdateDelete/FieldLevelSecurity) checks
In the recent years Salesforce has tried to provide developers with different means of implementing security around data access and handling of records and fields within records. This approach has not been omogeneous, 
leading to a flourishing of different keywords that can be used separately or together and that create an additional layer of confusion around the topic. In this research phase we have tried to implement an automated 
validation for all those situation where it can be statically possible to identify when best practices are not applied or when relying on an unsafe default can lead to a flaw.
The following table tries to summarise the logic we would like to implement wherever technically possible, considering that APEX scan happens within Simple Scanner.
SOQL queries will be evaluated in the context of the containing class's sharing configuration together with the FLS checks that are applied to the returned Resulteset, before the final assignment to an output sink.

| Class Sharing Mode | Operation | SOQL Qualifier           | ResultSet handling                         | CWE         | Testcase                                                                                                                               | Notes                                        | 
| ------------------ | --------- | ------------------------ | --------------------------------------     | ----------- | ----------------------------------------------------------------------------------------------------------------------------------     | -------------------------------------------- | 
| with sharing       | SOQL      |  no qualifier            | no field stripping                         | 274 --> 284 | [CRUDFLSTestcaseWithSharing.cls#L27](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L27)             |                                              | 
| with sharing       | SOQL      |                          |                                            |             | [CRUDFLSTestcaseWithSharing.cls#L33](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L33)             |                                              | 
| with sharing       | SOQL      |                          |                                            |             | [CRUDFLSTestcaseWithSharing.cls#L60](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L60)             |                                              | 
| with sharing       | SOQL      |                          |                                            |             | [CRUDFLSTestcaseWithSharing.cls#L84](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L84)             |                                              | 
| with sharing       | SOQL      |                          |                                            |             | [CRUDFLSTestcaseWithSharing.cls#L95](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L95)             |                                              | 
| with sharing       | SOQL      |                          |                                            |             | [CRUDFLSTestcaseWithSharing.cls#L107](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L107)           |                                              | 
| with sharing       | SOQL      |  no qualifier            | stripInaccessible(AccessType.READABLE)     | FP          | [CRUDFLSTestcaseWithSharing.cls#L43](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L43)             |                                              | 
| with sharing       | SOQL      |                          |                                            |             | [CRUDFLSTestcaseWithSharing.cls#L54](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L54)             |                                              | 
| with sharing       | SOQL      |  no qualifier            | stripInaccessible( != AccessType.READABLE) | 274 --> 284 | [CRUDFLSTestcaseWithSharing.cls#L43](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L43)             |                                              | 
| with sharing       | SOQL      |  WITH SECURITY_ENFORCED  |                                            | FP          | [CRUDFLSTestcaseWithSharing.cls#L133](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L133)           |                                              | 
| with sharing       | SOQL      |  WITH USER_MODE          |                                            | FP          | [CRUDFLSTestcaseWithSharing.cls#L139](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L139)           |                                              | 
| with sharing       | SOQL      |  WITH SYSTEM_MODE        |                                            | 284         | [CRUDFLSTestcaseWithSharing.cls#L149](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L149)           |                                              | 
| without sharing    | SOQL      |  no qualifier            | no field stripping                         | 284         | [CRUDFLSTestcaseWithoutSharing.cls#L23](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L23)       |                                              | 
| without sharing    | SOQL      |                          |                                            |             | [CRUDFLSTestcaseWithoutSharing.cls#L28](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L28)       |                                              | 
| without sharing    | SOQL      |                          | stripInaccessible(AccessType.READABLE)     | 284         | [CRUDFLSTestcaseWithoutSharing.cls#L38](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L38)       | stripping is not enough without sharing      | 
| without sharing    | SOQL      |                          |                                            |             | [CRUDFLSTestcaseWithoutSharing.cls#L49](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L49)       |                                              | 
| without sharing    | SOQL      |  WITH SECURITY_ENFORCED  |                                            | 284         | [CRUDFLSTestcaseWithoutSharing.cls#L125](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L125)     |                                              | 
| without sharing    | SOQL      |  WITH USER_MODE          |                                            | FP          | [CRUDFLSTestcaseWithoutSharing.cls#L131](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L131)     |                                              | 
| without sharing    | SOQL      |  WITH SYSTEM_MODE        |                                            | 284         | [CRUDFLSTestcaseWithoutSharing.cls#L141](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L141)     | SYSTEM_MODE emulates the class sharing + FLS | 
| inherited sharing  | SOQL      |  no qualifier            | no field stripping                         | 284         | [CRUDFLSTestcaseInheritedSharing.cls#L23](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseInheritedSharing.cls#L23)   |                                              | 
| inherited sharing  | SOQL      |                          |                                            |             | [CRUDFLSTestcaseInheritedSharing.cls#L28](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseInheritedSharing.cls#L28)   |                                              | 
| inherited sharing  | SOQL      |                          | stripInaccessible(AccessType.READABLE)     | 284         | [CRUDFLSTestcaseInheritedSharing.cls#L38](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseInheritedSharing.cls#L38)   | stripping is not enough without sharing      | 
| inherited sharing  | SOQL      |                          |                                            |             | [CRUDFLSTestcaseInheritedSharing.cls#L49](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseInheritedSharing.cls#L49)   |                                              | 
| inherited sharing  | SOQL      |  WITH SECURITY_ENFORCED  |                                            | 284         | [CRUDFLSTestcaseInheritedSharing.cls#L125](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseInheritedSharing.cls#L125) |                                              | 
| inherited sharing  | SOQL      |  WITH USER_MODE          |                                            | FP          | [CRUDFLSTestcaseInheritedSharing.cls#L131](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseInheritedSharing.cls#L131) |                                              | 
| inherited sharing  | SOQL      |  WITH SYSTEM_MODE        |                                            | 284         | [CRUDFLSTestcaseInheritedSharing.cls#L141](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseInheritedSharing.cls#L141) | SYSTEM_MODE emulates the class sharing + FLS | 
| no sharing defined | SOQL      |  no qualifier            | no field stripping                         | 284         | [CRUDFLSTestcaseNoSharing.cls#L23](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseNoSharing.cls#L23)                 |                                              | 
| no sharing defined | SOQL      |                          |                                            |             | [CRUDFLSTestcaseNoSharing.cls#L28](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseNoSharing.cls#L28)                 |                                              | 
| no sharing defined | SOQL      |                          | stripInaccessible(AccessType.READABLE)     | 284         | [CRUDFLSTestcaseNoSharing.cls#L38](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseNoSharing.cls#L38)                 | stripping is not enough without sharing      | 
| no sharing defined | SOQL      |                          |                                            |             | [CRUDFLSTestcaseNoSharing.cls#L49](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseNoSharing.cls#L49)                 |                                              | 
| no sharing defined | SOQL      |  WITH SECURITY_ENFORCED  |                                            | 284         | [CRUDFLSTestcaseNoSharing.cls#L125](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseNoSharing.cls#L125)               |                                              | 
| no sharing defined | SOQL      |  WITH USER_MODE          |                                            | FP          | [CRUDFLSTestcaseNoSharing.cls#L131](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseNoSharing.cls#L131)               |                                              | 
| no sharing defined | SOQL      |  WITH SYSTEM_MODE        |                                            | 284         | [CRUDFLSTestcaseNoSharing.cls#L141](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseNoSharing.cls#L141)               | SYSTEM_MODE emulates the class sharing + FLS | 



| Class sharing mode    | Operation       | Sharing/CRUD/FLS validation           | Notes                                                   | CWE                 | Testcase                                                                                                                           |
| --------------------- | --------------- | ------------------------------------- | ------------------------------------------------------- | ------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| *                     | *               | stripInaccessible(x,x, false)         | enforceRootObjectCRUD=false doesn't validate for CRUD   | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithSharing.cls#L223](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L223)       |
| with sharing          | insert          | none                                  |                                                         | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithSharing.cls#L163](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L163)       |
| with sharing          | insert          | programmatic validation               | impossible to confirm statically the proper validation  | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithSharing.cls#L171](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L171)       |
| with sharing          | insert          | stripInaccessible(CREATABLE)          | CREATABLE is the only AccessType valid for insert       | FP                  | [CRUDFLSTestcaseWithSharing.cls#L188](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L188)       |
| with sharing          | insert          | stripInaccessible(!=CREATABLE)        | CREATABLE is the only AccessType valid for insert       | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithSharing.cls#L201](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L201)       |
| with sharing          | insert          | as user                               |                                                         | FP                  | [CRUDFLSTestcaseWithSharing.cls#L236](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L236)       |
| with sharing          | insert          | as system                             | Can be a leftover from debug or mistake. Dev to confirm | CWE 274             | [CRUDFLSTestcaseWithSharing.cls#L239](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L239)       |
| with sharing          | update          | none                                  |                                                         | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithSharing.cls#L252](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L252)       |
| with sharing          | update          | programmatic validation               | impossible to confirm statically the proper validation  | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithSharing.cls#L260](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L260)       |
| with sharing          | update          | stripInaccessible(UPDATABLE)          | UPDATABLE is the only AccessType valid for update       | FP                  | [CRUDFLSTestcaseWithSharing.cls#L277](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L277)       |
| with sharing          | update          | stripInaccessible(!=UPDATABLE)        | UPDATABLE is the only AccessType valid for update       | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithSharing.cls#L292](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L292)       |
| with sharing          | update          | as user                               |                                                         | FP                  | [CRUDFLSTestcaseWithSharing.cls#L325](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L325)       |
| with sharing          | update          | as system                             | Can be a leftover from debug or mistake. Dev to confirm | CWE 274             | [CRUDFLSTestcaseWithSharing.cls#L327](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L327)       |
| with sharing          | upsert          | none                                  |                                                         | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithSharing.cls#L339](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L339)       |
| with sharing          | upsert          | programmatic validation               | impossible to confirm statically the proper validation  | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithSharing.cls#L347](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L347)       |
| with sharing          | upsert          | stripInaccessible(UPSERTABLE)         | UPSERTABLE is the only AccessType valid for update      | FP                  | [CRUDFLSTestcaseWithSharing.cls#L364](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L364)       |
| with sharing          | upsert          | stripInaccessible(!=UPSERTABLE)       | UPSERTABLE is the only AccessType valid for update      | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithSharing.cls#L378](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L378)       |
| with sharing          | upsert          | as user                               |                                                         | FP                  | [CRUDFLSTestcaseWithSharing.cls#L412](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L412)       |
| with sharing          | upsert          | as system                             | Can be a leftover from debug or mistake. Dev to confirm | CWE 274             | [CRUDFLSTestcaseWithSharing.cls#L415](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L415)       |
| with sharing          | delete          | none                                  | with sharing prevails                                   | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithSharing.cls#L439](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L439)       |
| with sharing          | delete          | as user                               |                                                         | FP                  | [CRUDFLSTestcaseWithSharing.cls#L450](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L450)       |
| with sharing          | delete          | as system                             | Can be a leftover from debug or mistake. Dev to confirm | CWE 274             | [CRUDFLSTestcaseWithSharing.cls#L462](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L462)       |
| without sharing       | insert          | none                                  |                                                         | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithoutSharing.cls#L163](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L163)       |
| without sharing       | insert          | programmatic validation               | impossible to confirm statically the proper validation  | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithoutSharing.cls#L171](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L171)       |
| without sharing       | insert          | stripInaccessible(CREATABLE)          | CREATABLE is the only AccessType valid for insert       | FP                  | [CRUDFLSTestcaseWithoutSharing.cls#L188](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L188)       |
| without sharing       | insert          | stripInaccessible(!=CREATABLE)        | CREATABLE is the only AccessType valid for insert       | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithoutSharing.cls#L201](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L201)       |
| without sharing       | insert          | as user                               |                                                         | FP                  | [CRUDFLSTestcaseWithoutSharing.cls#L236](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L236)       |
| without sharing       | insert          | as system                             | Can be a leftover from debug or mistake. Dev to confirm | CWE 274             | [CRUDFLSTestcaseWithoutSharing.cls#L239](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L239)       |
| without sharing       | update          | none                                  |                                                         | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithoutSharing.cls#L252](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L252)       |
| without sharing       | update          | programmatic validation               | impossible to confirm statically the proper validation  | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithoutSharing.cls#L260](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L260)       |
| without sharing       | update          | stripInaccessible(UPDATABLE)          | it can be possible to update other's users objects      | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithoutSharing.cls#L277](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L277)       |
| without sharing       | update          | stripInaccessible(!=UPDATABLE)        | it can be possible to update other's users objects      | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithoutSharing.cls#L292](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L292)       |
| without sharing       | update          | as user                               |                                                         | FP                  | [CRUDFLSTestcaseWithoutSharing.cls#L325](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L325)       |
| without sharing       | update          | as system                             | Can be a leftover from debug or mistake. Dev to confirm | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithoutSharing.cls#L327](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L327)       |
| without sharing       | upsert          | none                                  |                                                         | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithoutSharing.cls#L339](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L339)       |
| without sharing       | upsert          | programmatic validation               | impossible to confirm statically the proper validation  | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithoutSharing.cls#L347](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L347)       |
| without sharing       | upsert          | stripInaccessible(UPSERTABLE)         | it can be possible to update other's users objects      | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithoutSharing.cls#L364](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L364)       |
| without sharing       | upsert          | stripInaccessible(!=UPSERTABLE)       | it can be possible to update other's users objects      | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithoutSharing.cls#L378](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L378)       |
| without sharing       | upsert          | as user                               |                                                         | FP                  | [CRUDFLSTestcaseWithoutSharing.cls#L412](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L412)       |
| without sharing       | upsert          | as system                             | Can be a leftover from debug or mistake. Dev to confirm | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithoutSharing.cls#L415](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L415)       |
| without sharing       | delete          | none                                  | without sharing allows to delete other user's objects   | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithoutSharing.cls#L439](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L439)       |
| without sharing       | delete          | as user                               |                                                         | FP                  | [CRUDFLSTestcaseWithoutSharing.cls#L450](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L450)       |
| without sharing       | delete          | as system                             | without sharing allows to delete other user's objects   | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithoutSharing.cls#L462](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L462)       |
| with sharing          | Database.insert | none                                  |                                                         | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithSharing.cls#L164](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L164)       |
| with sharing          | Database.insert | stripInaccessible(CREATABLE)          | CREATABLE is the only AccessType valid for insert       | FP                  | [CRUDFLSTestcaseWithSharing.cls#L189](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L189)       |
| with sharing          | Database.insert | programmatic validation               | impossible to confirm statically the proper validation  | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithSharing.cls#L172](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L172)       |
| with sharing          | Database.insert | stripInaccessible(!=CREATABLE)        | CREATABLE is the only AccessType valid for insert       | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithSharing.cls#L202](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L202)       |
| with sharing          | Database.insert | AccessLevel.USER_MODE                 |                                                         | FP                  | [CRUDFLSTestcaseWithSharing.cls#L237](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L237)       |
| with sharing          | Database.insert | AccessLevel.SYSTEM_MODE               | Can be a leftover from debug or mistake. Dev to confirm | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithSharing.cls#L240](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L240)       |
| with sharing          | Database.update | none                                  |                                                         | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithSharing.cls#L253](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L253)       |
| with sharing          | Database.update | programmatic validation               | impossible to confirm statically the proper validation  | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithSharing.cls#L261](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L261)       |
| with sharing          | Database.update | stripInaccessible(UPDATABLE)          | UPDATABLE is the only AccessType valid for update       | FP                  | [CRUDFLSTestcaseWithSharing.cls#L278](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L278)       |
| with sharing          | Database.update | stripInaccessible(!=UPDATABLE)        | UPDATABLE is the only AccessType valid for update       | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithSharing.cls#L293](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L293)       |
| with sharing          | Database.update | AccessLevel.USER_MODE                 |                                                         | FP                  | [CRUDFLSTestcaseWithSharing.cls#L326](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L326)       |
| with sharing          | Database.update | AccessLevel.SYSTEM_MODE               | Can be a leftover from debug or mistake. Dev to confirm | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithSharing.cls#L328](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L328)       |
| with sharing          | Database.upsert | none                                  |                                                         | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithSharing.cls#L340](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L340)       |
| with sharing          | Database.upsert | programmatic validation               | impossible to confirm statically the proper validation  | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithSharing.cls#L348](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L348)       |
| with sharing          | Database.upsert | stripInaccessible(UPSERTABLE)         | UPSERTABLE is the only AccessType valid for update      | FP                  | [CRUDFLSTestcaseWithSharing.cls#L365](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L365)       |
| with sharing          | Database.upsert | stripInaccessible(!=UPSERTABLE)       | UPSERTABLE is the only AccessType valid for update      | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithSharing.cls#L379](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L379)       |
| with sharing          | Database.upsert | AccessLevel.USER_MODE                 |                                                         | FP                  | [CRUDFLSTestcaseWithSharing.cls#L413](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L413)       |
| with sharing          | Database.upsert | AccessLevel.SYSTEM_MODE               | Can be a leftover from debug or mistake. Dev to confirm | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithSharing.cls#L416](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L416)       |
| with sharing          | Database.delete | none                                  | with sharing prevails                                   | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithSharing.cls#L440](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L440)       |
| with sharing          | Database.delete | AccessLevel.USER_MODE                 |                                                         | FP                  | [CRUDFLSTestcaseWithSharing.cls#L451](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L451)       |
| with sharing          | Database.delete | AccessLevel.SYSTEM_MODE               | with sharing prevails                                   | FP                  | [CRUDFLSTestcaseWithSharing.cls#L463](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithSharing.cls#L463)       |
| without sharing       | Database.insert | none                                  |                                                         | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithoutSharing.cls#L164](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L164)       |
| without sharing       | Database.insert | programmatic validation               | impossible to confirm statically the proper validation  | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithoutSharing.cls#L172](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L172)       |
| without sharing       | Database.insert | stripInaccessible(CREATABLE)          | CREATABLE is the only AccessType valid for insert       | FP                  | [CRUDFLSTestcaseWithoutSharing.cls#L189](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L189)       |
| without sharing       | Database.insert | stripInaccessible(!=CREATABLE)        | CREATABLE is the only AccessType valid for insert       | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithoutSharing.cls#L202](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L202)       |
| without sharing       | Database.insert | AccessLevel.USER_MODE                 |                                                         | FP                  | [CRUDFLSTestcaseWithoutSharing.cls#L237](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L237)       |
| without sharing       | Database.insert | AccessLevel.SYSTEM_MODE               | Can be a leftover from debug or mistake. Dev to confirm | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithoutSharing.cls#L240](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L240)       |
| without sharing       | Database.update | none                                  |                                                         | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithoutSharing.cls#L253](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L253)       |
| without sharing       | Database.update | programmatic validation               | impossible to confirm statically the proper validation  | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithoutSharing.cls#L261](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L261)       |
| without sharing       | Database.update | stripInaccessible(UPDATABLE)          | it can be possible to update other's users objects      | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithoutSharing.cls#L278](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L278)       |
| without sharing       | Database.update | stripInaccessible(!=UPDATABLE)        | it can be possible to update other's users objects      | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithoutSharing.cls#L293](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L293)       |
| without sharing       | Database.update | AccessLevel.USER_MODE                 |                                                         | FP                  | [CRUDFLSTestcaseWithoutSharing.cls#L326](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L326)       |
| without sharing       | Database.update | AccessLevel.SYSTEM_MODE               | Can be a leftover from debug or mistake. Dev to confirm | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithoutSharing.cls#L328](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L328)       |
| without sharing       | Database.upsert | none                                  |                                                         | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithoutSharing.cls#L340](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L340)       |
| without sharing       | Database.upsert | programmatic validation               | impossible to confirm statically the proper validation  | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithoutSharing.cls#L348](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L348)       |
| without sharing       | Database.upsert | stripInaccessible(UPSERTABLE)         | it can be possible to update other's users objects      | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithoutSharing.cls#L365](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L365)       |
| without sharing       | Database.upsert | stripInaccessible(!=UPSERTABLE)       | it can be possible to update other's users objects      | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithoutSharing.cls#L379](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L379)       |
| without sharing       | Database.upsert | AccessLevel.USER_MODE                 |                                                         | FP                  | [CRUDFLSTestcaseWithoutSharing.cls#L413](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L413)       |
| without sharing       | Database.upsert | AccessLevel.SYSTEM_MODE               | Can be a leftover from debug or mistake. Dev to confirm | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithoutSharing.cls#L416](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L416)       |
| without sharing       | Database.delete | none                                  | without sharing allows to delete other user's objects   | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithoutSharing.cls#L440](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L440)       |
| without sharing       | Database.delete | AccessLevel.USER_MODE                 |                                                         | FP                  | [CRUDFLSTestcaseWithoutSharing.cls#L451](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L451)       |
| without sharing       | Database.delete | AccessLevel.SYSTEM_MODE               | without sharing allows to delete other user's objects   | CWE 274 --> CWE 284 | [CRUDFLSTestcaseWithoutSharing.cls#L463](apexx-refresh-2024/force-app/main/default/classes/CRUDFLSTestcaseWithoutSharing.cls#L463)       |

Note: Class with no sharing specified can be considered the same as `without sharing` classes.


### Message text to use for CWE 274 in APEX

```
apex_permissions_handling,default <span>The reported finding highlights an SOQL or database query that may allow broader access than required. The modifiers "with sharing" or "inherited sharing" enforce proper sharing rules at the record level, but field-level security (FLS) settings are not respected. Various strategies can be applied to implement the correct FLS depending on the business requirements or preferred approach.
While it is possible to verify the correct permissions programmatically via methods from the Schema.DescribeSObjectResult, Salesforce has recently introduced additional modes of operation to automatically apply the proper sharing mode and FLS to SOQL, database queries, and CRUD operations.</span><span>When possible, consider using  'WITH USER_MODE' in SOQL queries, `as user` with CRUD operations and `AccessLevel.USER_MODE` in Database and Search methods. While `WITH SECURITY ENFORCED` is still available and a valid approach for field-level security, Salesforce reported that it can be deprecated/decommissioned in future.</span><span>References : <a href="https://cwe.mitre.org/data/definitions/274.html">CWE 274</a><BR><a href="https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_keywords_sharing.htm">Using the with sharing, without sharing, and inherited sharing Keywords</a><BR><a href="https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_enforce_usermode.htm">Enforce User Mode for Database Operations</a></span>
```


## Entry Points

### EmailMessaging.InboundEmailHandler.handleInboundEmail
Classes implementing `Messaging.InboundEmailHandler` must implement the method `Messaging.InboundEmailHandler.handleInboundEmail` . This method can be considered as entry point with its two input parameters being Network.Taint.

[MyEmailHandler](apex-update-202403/apexx-refresh-2024/force-app/main/default/classes/MyEmailHandler.cls)


## Type Info
- Messaging.InboundEmail.ccAddresses returns String[]
- Messaging.InboundEmail.fromAddress return String
- Messaging.InboundEmail.fromName return String
- Messaging.InboundEmail.inReplyTo return String
- Messaging.InboundEmail.replyTo return String
- Messaging.InboundEmail.plainTextBody return String
- Messaging.InboundEmail.subject return String
- Messaging.InboundEmail.toAddresses return String[]
- Messaging.InboundEmail.htmlBody return String
- Messaging.InboundEmail.headers returns a InboundEmail.Header[]
    - InboundEmail.Header.name and InboundEmail.Header.value are strings
- Messaging.InboundEmail.binaryAttachments return InboundEmail.BinaryAttachment[]
    - Messaging.InboundEmail.BinaryAttachment.body is Blob
    - Messaging.InboundEmail.BinaryAttachment.fileName is String
    - Messaging.InboundEmail.BinaryAttachment.headers is InboundEmail.Header[]
- Messaging.InboundEmail.textAttachments return InboundEmail.TextAttachment[]
    - InboundEmail.TextAttachment.body is String
    - InboundEmail.TextAttachment.fileName is String
    - InboundEmail.TextAttachment.charset is String
    - InboundEmail.TextAttachment.headers is InboundEmail.Header[]
- Messaging.InboundEnvelope.fromAddress is String
- Messaging.InboundEnvelope.toAddress is String


## Taint Sinks

*CWEID 943 (when T = Taint.Network)*
- Database.queryWithBinds(T, x, x)
    - [AddedQueryMethods.cls#L20](apexx-refresh-2024/force-app/main/default/classes/AddedQueryMethods.cls#L20) 
- Database.getQueryLocatorWithBinds(T, x, x)
    - [AddedQueryMethods.cls#L35](apexx-refresh-2024/force-app/main/default/classes/AddedQueryMethods.cls#L35)
- Database.countQueryWithBinds(T, x, x)
    - [AddedQueryMethods.cls#L54](apexx-refresh-2024/force-app/main/default/classes/AddedQueryMethods.cls#L54)


## Taint Propagators
- Database.QueryLocator =  (String)Database.getQueryLocatorWithBinds(IN, x, x)
    - taints the internal query string of QueryLocator
    - [AddedQueryMethods.cls#L38](apexx-refresh-2024/force-app/main/default/classes/AddedQueryMethods.cls#L38) 

