// This set of testcases aimed at documenting CRUD/FLS functionalities will have a dual set of CWEs assigned
// for some of the specific cases that will be documented below. We want to allow customers to be notified from
// day 1 of the release but without affecting their policy too much with an high-severity cwe while
// allowing them time to adapt their code to the latest Salesforce best practices. 
// The lines with two CWEs on the same line should be initialli reported with the first CWE listed.
// After a specified settling time, these findings will be reported with the 2nd CWE expressed on the same line
// i.e. :  // CWE 274  -->  CWE 284
// Initially the flaw will be identified as CWE 274. Finally it will be reported only as CWE 284.

public without sharing class CRUDFLSTestcaseWithoutSharing {

    // This variable represents the output sink, that can be potentially used in a VisualForce page, Aura or LWC page
    public String foo {get; set;}

    // This variable represents the output sink, that can be potentially used in a VisualForce page, Aura or LWC page
    public List<Dialog__c> fooDialogs {get; set;}

    // in a class 'without sharing' the data access issues are data Read, CRUD, FLS. stripInaccessible doesn't filter for 
    // records that are not readable to the current user


    public void noSpecifierInSOQLAndNoStrip1(){
        List<Dialog__c> retrievedDialogs = [SELECT ID, Name, Message__c, Secret_Field__c, OwnerId FROM Dialog__c]; // CWE 284
        fooDialogs = retrievedDialogs;
    }

    public void noSpecifierInSOQLAndNoStrip2(){
        List<Dialog__c> retrievedDialogs = [SELECT ID, Name, Message__c, Secret_Field__c, OwnerId FROM Dialog__c]; // CWE 284
        retrievedDialogs = applyNoStripping(retrievedDialogs);
        fooDialogs = retrievedDialogs;
        
    }

    // Stripping applied to the return value of a SOQL query before it is used as RHS of an operation. 
    // If technically possible it can be considered as an valid attemp at mitigating FLS.
    // We can keep flaggin it as CWE 274 to allow the customer to review them.
    public void noSpecifierInSOQLStrip1(){
        List<Dialog__c> retrievedDialogs = [SELECT ID, Name, Message__c, Secret_Field__c, OwnerId FROM Dialog__c]; // CWE 284 because of without sharing in place 

        List<Dialog__c> sanitizedRetrievedDialogs =  Security.stripInaccessible(AccessType.READABLE,retrievedDialogs).getRecords(); // This line sanitizes the extracted records only for FLS

        // even though stripInaccessible is applied, sharing is still not verified
        fooDialogs = sanitizedRetrievedDialogs;

    }

    //  Similar as noSpecifierInSOQLStrip1 but stripping happens in a secondary level to the SOQL query return value.
    public void noSpecifierInSOQLStrip2(){
        List<Dialog__c> retrievedDialogs = [SELECT ID, Name, Message__c, Secret_Field__c, OwnerId FROM Dialog__c]; // CWE 284
        fooDialogs = applyFieldsStripping(retrievedDialogs);
    }

    // Similar to noSpecifierInSOQLStrip1, but the unsanitized data being assigned to the output sink, so it is vulnerable.
    public void noSpecifierInSOQLStrip3(){
        List<Dialog__c> retrievedDialogs = [SELECT ID, Name, Message__c, Secret_Field__c, OwnerId FROM Dialog__c]; // CWE 284

        List<Dialog__c> sanitizedRetrievedDialogs =  Security.stripInaccessible(AccessType.READABLE,retrievedDialogs).getRecords(); // This line sanitizes the extracted records only for FLS.

        // We are assigning the sanitized/stripped object to the "output" sink., but in a without sharing class that would still leave the SOQL not safe. All records are accessible.
        fooDialogs = retrievedDialogs;

    }


    // Similar to noSpecifierInSOQLStrip3, but this time the initial SOQL is safe, so no vulnerable.
    public void noSpecifierInSOQLStrip4(){
        List<Dialog__c> retrievedDialogs = [SELECT ID, Name, Message__c, Secret_Field__c, OwnerId FROM Dialog__c WITH USER_MODE]; // FP
        // READABLE is the options we want with variable assignment, but not relevant in this case, since WITH USER MODE is used on the initial SOQL
        List<Dialog__c> sanitizedRetrievedDialogs =  Security.stripInaccessible(AccessType.READABLE,retrievedDialogs).getRecords(); // This line sanitizes the extracted records only for FLS, but WITH USER_MODE does the proper validation already

        // All good here. Data extracted WITH USER_MODE.
        fooDialogs = retrievedDialogs;

    }

    public void noSpecifierInSOQLStripButAssignment1(){
        List<Dialog__c> retrievedDialogs = [SELECT ID, Name, Message__c, Secret_Field__c, OwnerId FROM Dialog__c]; // CWE 284 because without sharing

        // foo can contain a restricted field. We can't flag here because we don't know which field is restricted
        foo = retrievedDialogs[0].secret_field__c;

        // stripping happening too late since foo was laready retrieved. Moreover in a without sharing class the proble is with records access, together with field/object access
        fooDialogs = Security.stripInaccessible(AccessType.READABLE,retrievedDialogs).getRecords();
    }

    //  Similar as noSpecifierInSOQLStripButAssignment1 but stripping happens in a secondary level to the SOQL query return value.
    public void noSpecifierInSOQLStripButAssignment2(){
        List<Dialog__c> retrievedDialogs = [SELECT ID, Name, Message__c, Secret_Field__c, OwnerId FROM Dialog__c]; // CWE 284 because without sharing

        // foo can contain a restricted field. We can't flag here because we don't know which field is restricted
        foo = retrievedDialogs[0].secret_field__c;

        // stripping happening too late since foo was laready retrieved. Moreover in a without sharing class the proble is with records access, together with field/object access
        retrievedDialogs = applyFieldsStripping(retrievedDialogs);
        fooDialogs = retrievedDialogs;
    }

    // The unsanitized value from SOQL is used as RHS value in an assignment 
    public void noSpecifierInSOQLStripButAssignment3(){
        List<Dialog__c> retrievedDialogs = [SELECT ID, Name, Message__c, Secret_Field__c, OwnerId FROM Dialog__c]; // CWE 284 because without sharing

        fooDialogs = Security.stripInaccessible(AccessType.READABLE,retrievedDialogs).getRecords();
        foo = retrievedDialogs[0].secret_field__c; // retrievedDialogs is not sanitised because of without sharing
    }

    // the original retrievedDialogs variable is overwritten sith stripped data but in a class using `without sharing` we still have CWE 284 on the SOQL
    public void noSpecifierInSOQLStripButAssignment4(){
        List<Dialog__c> retrievedDialogs = [SELECT ID, Name, Message__c, Secret_Field__c, OwnerId FROM Dialog__c]; // CWE 284 because without sharing

        retrievedDialogs = Security.stripInaccessible(AccessType.READABLE,retrievedDialogs).getRecords(); // overwrites the original retrievedDialogs but only for CRUD and FLS
        foo = retrievedDialogs[0].secret_field__c; // retrievedDialogs is now sanitised because of without sharing
    }

    //  Similar to noSpecifierInSOQLStripButAssignment4 but stripping happend in a secondary level to the SOQL query return value.
    public void noSpecifierInSOQLStripButAssignment5(){
        List<Dialog__c> retrievedDialogs = [SELECT ID, Name, Message__c, Secret_Field__c, OwnerId FROM Dialog__c]; // CWE 284 because without sharing
        retrievedDialogs = applyFieldsStripping(retrievedDialogs);
        foo = retrievedDialogs[0].secret_field__c;
    }
    

    // This case showcase the case when the SOQL uses SECURITY_ENFORCED, that is not enough in a `without sharing` class
    public void withSecurityEnforcedInSOQL(){
        // WITH SECURITY_ENFORCED is not a reccommended approach because of it limitations but still an acceptable approach at FLS
        List<Dialog__c> retrievedDialogs = [SELECT ID, Name, Message__c, Secret_Field__c, OwnerId FROM Dialog__c WITH SECURITY_ENFORCED]; // CWE 284 because without sharing
    }

    // This case showcase the case when the SOQL uses WITH USER_MODE, currently reccommended approach at solving CRUD and FLS
    public void withUserModeInSOQL(){
        // WITH USER MODE is the reccommended approach for CRUD and FLS, maintaining the proper with/withotu sharing in place.
        List<Dialog__c> retrievedDialogs = [SELECT ID, Name, Message__c, Secret_Field__c, OwnerId FROM Dialog__c WITH USER_MODE]; // FP
    }

    // This case showcase the case when the SOQL uses WITH SYSTEM_MODE, currently reccommended approach at solving CRUD and FLS
    public void withSystemModeInSOQL(){
        // WITH SYSTEM_MODE is a valid approach at CRUS/FLS and released together with WITH USER_MODE. We will be probably flagging it
        // with a lower severity CWE is that if used lightly, in a `without sharing` class will still allow access to records accessible from system 
        // and also to all fields of the retrieved record, including those that should not be accessible to the current user. The use of WITH SYSTEM_MODE
        // can be willingnly be chosed by the developer to configure a specific level of access to a recordset, but can be also the result of a forgotten
        // missconfiguration. We will initially flag them with a low severity CWE to allow customers to review them if they decide to.
        List<Dialog__c> retrievedDialogs = [SELECT ID, Name, Message__c, Secret_Field__c, OwnerId FROM Dialog__c WITH SYSTEM_MODE]; // CWE 284
    }










    // The following testcases are to showcase how to flag when `as user` or `as system` is used in various CRUD operations.
    // Since we can't statically determine if an sObject, field, Custom Object or custom field is accessible to the current user,
    // we can't validate programmatical approaches, such as using isAccessible, is Creatable ...
    // For this reason we are going to initially flag as CWE 274 all cases that are not using `as user`, and then use cwe 274
    // when `as system` is used and all cases without any `as user` or `as system` to cwe 284.
    public void insertSamples1(){

        Dialog__c bar = new Dialog__c(secret_field__c = 'my secret');
        // bar.secret_field__c = 'my secret';

        insert bar;            // CWE 274 --> CWE 284
        Database.insert(bar);  // CWE 274 --> CWE 284
        

        // can't validate which field can be inserted with the programmatical approach. Flagging it to let the developer ensure the proper validation is in place.
        if( Schema.SObjectType.Dialog__c.isAccessible() && 
            Schema.SObjectType.Dialog__c.isCreateAble() && 
            Schema.SObjectType.Dialog__c.fields.Secret_field__c.isCreateAble()){
                insert bar;           // CWE 274 --> CWE 284
                Database.insert(bar); // CWE 274 --> CWE 284
            }

    }


    // stripInaccessible if used correctly can be considered a valid approach at FLS and CRUD. In a without sharing class there is still risk of inserting fields in an sObject owned by other users
    public void insertSamples2(){

        Dialog__c bar = new Dialog__c();
        Dialog__c baz = new Dialog__c();
        List<Dialog__c> myDialogs = new List<Dialog__c>{bar,baz};
        bar.secret_field__c = 'some secret';
        baz.Message__c = 'a message here';
                
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, myDialogs);
        insert securityDecision.getRecords();           // CWE 274 --> CWE 284  when insert and !with sharing
        Database.insert(securityDecision.getRecords()); // CWE 274 --> CWE 284  when insert and !with sharing
    }

    public void insertSamples3(){

        Dialog__c bar = new Dialog__c();
        Dialog__c baz = new Dialog__c();
        List<Dialog__c> myDialogs = new List<Dialog__c>{bar,baz};
        bar.secret_field__c = 'some secret';
        baz.Message__c = 'a message here';
                
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPSERTABLE, myDialogs);
        insert securityDecision.getRecords();            // CWE 274 --> CWE 284  when insert and !(AccessType.CREATABLE) and !with sharing
        Database.insert(securityDecision.getRecords());  // CWE 274 --> CWE 284  when insert and !(AccessType.CREATABLE) and !with sharing
    }

    // when stripInaccessible is used with the wrong AccessType value (first parameter) for the operation to validate for
    public void insertSamples4(){

        Dialog__c bar = new Dialog__c();
        Dialog__c baz = new Dialog__c();
        List<Dialog__c> myDialogs = new List<Dialog__c>{bar,baz};
        bar.secret_field__c = 'some secret';
        baz.Message__c = 'a message here';
                
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE, myDialogs);
        insert securityDecision.getRecords();           // CWE 274 --> CWE 284 READABLE is not a valid check to apply when performing insert
        Database.insert(securityDecision.getRecords()); // CWE 274 --> CWE 284 READABLE is not a valid check to apply when performing insert
    }


    // stripInaccessible also checks for CRUD by default, unless disabled in its third parameter (enforceRootObjectCRUD) when set to false.
    // This example may not be very realistic but can still be possible to have a SOQL query directly inside the stripInaccessible 2nd parameter.
    public void insertSamples5(){
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPSERTABLE, [SELECT Name, Message__c, Secret_Field__c, OwnerId FROM Dialog__c WITH SECURITY_ENFORCED], false); // CWE 284 because without sharing

        // the return value of getRecords() as in  List<Dialog__s> qaz = securityDecision.getRecords() is not safe in this case, because of the third parameter of stripInaccessible being set to false.
        // reported because validation of CRUD permissions is disabled: stripInaccessible 3rd param == false
        insert securityDecision.getRecords();           // CWE 274 --> CWE 284
        Database.insert(securityDecision.getRecords()); // CWE 274 --> CWE 284
    }

    // insert as user/as system is the reccommended approach.
    // We will initially report `as system`  with CWE 274. Later on we may decide to drop it as for the use of `WITH SYSTEM_MODE` described above.
    public void insertSample6(){
        Dialog__c bar = new Dialog__c();

        insert as user bar;                          // FP
        Database.insert(bar, AccessLevel.USER_MODE); // FP equivalent to the line before

        insert as system bar;                           // CWE 274 - allows access to fields/objects. We use 274 because can be used to insert objects having fields that should not be accessible
        Database.insert(bar, AccessLevel.SYSTEM_MODE);  // CWE 274 - allows access to fields/objects. We use 274 because can be used to insert objects having fields that should not be accessible

    }


    // ----------------------- UPDATE Tests ---------------------
    // Update tests
    public void updateSamples1(){

        Dialog__c bar = [SELECT id, name, message__c from Dialog__c LIMIT 1];  // CWE 284 because without sharing
        bar.secret_field__c = 'my secret';

        update bar;           // CWE 274 --> CWE 284
        Database.update(bar); // CWE 274 --> CWE 284
        

        // can't validate programmatical approach. Flagging it to let the developer ensure the proper validation is in place.
        if( Schema.SObjectType.Dialog__c.isAccessible() && 
            Schema.SObjectType.Dialog__c.isUpdateable() && 
            Schema.SObjectType.Dialog__c.fields.Secret_field__c.isUpdateable()){
                update bar;           // CWE 274 --> CWE 284
                Database.update(bar); // CWE 274 --> CWE 284
            }

    }


    // stripInaccessible if used correctly can be considered a valid approach at FLS and CRUD
    public void updateSamples2(){

        Dialog__c bar = new Dialog__c();
        Dialog__c baz = new Dialog__c();
        List<Dialog__c> myDialogs = new List<Dialog__c>{bar,baz};
        bar.secret_field__c = 'some secret';
        baz.Message__c = 'a message here';
                
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, myDialogs);
        update securityDecision.getRecords();           // CWE 274 --> CWE 284 because in a `without sharing` class it can be possible to update other's users objects
        Database.update(securityDecision.getRecords()); // CWE 274 --> CWE 284 because in a `without sharing` class it can be possible to update other's users objects
    }


    // when stripInaccessible is used with the wrong AccessType value (first parameter) for the operation to validate for
    public void updateSamples3(){

        Dialog__c bar = new Dialog__c();
        Dialog__c baz = new Dialog__c();
        List<Dialog__c> myDialogs = new List<Dialog__c>{bar,baz};
        bar.secret_field__c = 'some secret';
        baz.Message__c = 'a message here';
                
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPSERTABLE, myDialogs);
        update securityDecision.getRecords();            // CWE 274 --> CWE 284 because in a `without sharing` class it can be possible to update other's users objects
        Database.update(securityDecision.getRecords());  // CWE 274 --> CWE 284 because in a `without sharing` class it can be possible to update other's users objects
    }

    // when stripInaccessible is used with the wrong AccessType value (first parameter) for the operation to validate for
    public void updateSamples4(){

        Dialog__c bar = new Dialog__c();
        Dialog__c baz = new Dialog__c();
        List<Dialog__c> myDialogs = new List<Dialog__c>{bar,baz};
        bar.secret_field__c = 'some secret';
        baz.Message__c = 'a message here';
                
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE, myDialogs);
        update securityDecision.getRecords();            // CWE 274 --> CWE 284 because in a `without sharing` class it can be possible to update other's users objects
        Database.update(securityDecision.getRecords());  // CWE 274 --> CWE 284 because in a `without sharing` class it can be possible to update other's users objects
    }


    // stripInaccessible also checks for CRUD by default, unless disabled in its third parameter (enforceRootObjectCRUD) when set to false.
    // This example may not be very realistic but can still be possible to have a SOQL query directly inside the stripInaccessible 2nd parameter.
    public void updateSamples5(){
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, [SELECT Name, Message__c, Secret_Field__c, OwnerId FROM Dialog__c WITH SECURITY_ENFORCED], false); // CWE 284 because without sharing
        // reported because validation of CRUD permissions is disabled: stripInaccessible 3rd param == false
        update securityDecision.getRecords();           // CWE 274 --> CWE 284 because in a `without sharing` class it can be possible to update other's users objects
        Database.update(securityDecision.getRecords()); // CWE 274 --> CWE 284 because in a `without sharing` class it can be possible to update other's users objects
    }

    // update as user/as system is the reccommended approach.
    // We will initially report `as system`  with CWE 274. Later on we may decide to drop it as for the use of `WITH SYSTEM_MODE` described above.
    public void updateSample6(){
        Dialog__c bar = new Dialog__c();

        update as user bar; // FP
        Database.update(bar, AccessLevel.USER_MODE); // FP 
        update as system bar; // CWE 274 --> ?
        Database.update(bar, AccessLevel.SYSTEM_MODE); // CWE 274 --> ?
    }



    // ----------------- UPSERT Tests ---------------
    public void upsertSamples1(){

        List<Dialog__c> bars = [SELECT id, name, message__c from Dialog__c]; // CWE 284 because without sharing
        bars[0].secret_field__c = 'my secret';

        upsert bars;            // CWE 274 --> CWE 284
        Database.upsert(bars);  // CWE 274 --> CWE 284
        

        // can't validate programmatical approach. Flagging it to let the developer ensure the proper validation is in place.
        if( Schema.SObjectType.Dialog__c.isAccessible() && 
            Schema.SObjectType.Dialog__c.isUpdateable() && 
            Schema.SObjectType.Dialog__c.fields.Secret_field__c.isUpdateable()){
                upsert bars;            // CWE 274 --> CWE 284
                Database.upsert(bars);  // CWE 274 --> CWE 284
            }

    }


    // stripInaccessible if used correctly can be considered a valid approach at FLS and CRUD
    public void upsertSamples2(){

        Dialog__c bar = new Dialog__c();
        Dialog__c baz = new Dialog__c();
        List<Dialog__c> myDialogs = new List<Dialog__c>{bar,baz};
        bar.secret_field__c = 'some secret';
        baz.Message__c = 'a message here';
                
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPSERTABLE, myDialogs);
        upsert securityDecision.getRecords();           // CWE 274 --> CWE 284 because in a `without sharing` class it can be possible to update other's users objects
        Database.upsert(securityDecision.getRecords()); // CWE 274 --> CWE 284 because in a `without sharing` class it can be possible to update other's users objects
    }

    // when stripInaccessible is used with the wrong AccessType value (first parameter) for the operation to validate for
    public void upsertSamples3(){

        Dialog__c bar = new Dialog__c();
        Dialog__c baz = new Dialog__c();
        List<Dialog__c> myDialogs = new List<Dialog__c>{bar,baz};
        bar.secret_field__c = 'some secret';
        baz.Message__c = 'a message here';
                
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, myDialogs);
        upsert securityDecision.getRecords();           // CWE 274 --> CWE 284 because in a `without sharing` class it can be possible to update other's users objects
        Database.upsert(securityDecision.getRecords()); // CWE 274 --> CWE 284 because in a `without sharing` class it can be possible to update other's users objects

    }

    // when stripInaccessible is used with the wrong AccessType value (first parameter) for the operation to validate for
    public void upsertSamples4(){

        Dialog__c bar = new Dialog__c();
        Dialog__c baz = new Dialog__c();
        List<Dialog__c> myDialogs = new List<Dialog__c>{bar,baz};
        bar.secret_field__c = 'some secret';
        baz.Message__c = 'a message here';
                
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE, myDialogs);
        upsert securityDecision.getRecords();           // CWE 274 --> CWE 284 because in a `without sharing` class it can be possible to update other's users objects
        Database.upsert(securityDecision.getRecords()); // CWE 274 --> CWE 284 because in a `without sharing` class it can be possible to update other's users objects
    }


    // stripInaccessible also checks for CRUD by default, unless disabled in its third parameter (enforceRootObjectCRUD) when set to false.
    // This example may not be very realistic but can still be possible to have a SOQL query directly inside the stripInaccessible 2nd parameter.
    public void upsertSamples5(){
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPSERTABLE, [SELECT Name, Message__c, Secret_Field__c, OwnerId FROM Dialog__c WITH SECURITY_ENFORCED], false); // CWE 284 because without sharing
        // reported because validation of CRUD permissions is disabled: stripInaccessible 3rd param == false
        upsert securityDecision.getRecords();           // CWE 274 --> CWE 284 because in a `without sharing` class it can be possible to update other's users objects
        Database.upsert(securityDecision.getRecords()); // CWE 274 --> CWE 284 because in a `without sharing` class it can be possible to update other's users objects
    }

    // upsert as user/as system is the reccommended approach.
    // We will initially report `as system`  with CWE 274. Later on we may decide to drop it as for the use of `WITH SYSTEM_MODE` described above.
    public void upsertSample6(){
        Dialog__c bar = new Dialog__c();

        upsert as user bar;                            // FP
        Database.upsert(bar, AccessLevel.USER_MODE);   // FP 

        upsert as system bar;                          // CWE 274 --> ?
        Database.upsert(bar, AccessLevel.SYSTEM_MODE); // CWE 274 --> ?

    }





    // ------ Delete testcases
    // Delete DML works differently than other DML operation in that is not covered by stripInaccessible. 
    // Depending on how the object to be deleted is identified, there are different approaches at deletion.
    // If the ID is passed as input, it could be possible to validate this id with a SOQL query with the current user
    // or , if the list of IDs to delete are retrived from a SOQL query, ensure that the query is coming from a properly validated query.
    // We are going to simplify this detection by reporting with CWE 274 all the delete operations that are not characterized by `as user`
    // to le the developer validate that the proper DML validation is in place.


    // When the object to be deleted is provided as taint, we can't be sure the Object can be deleted. Let the developer verify the proper validation is in place.
    // stripInaccessible is not applicable here, since it works only on FLS for specific actions.
    public void deleteSample1(){
        Dialog__c delElement = new Dialog__c();
        delElement.id = foo;

        delete delElement;           // CWE 274
        Database.delete(delElement); // CWE 274
    }


    
    // if the clause `as user` in place we can assume APEX will do the proper validation.
    public void deleteSample2(){
        Dialog__c delElement = new Dialog__c();
        delElement.id = foo;

        delete as user delElement;                          // FP
        Database.delete(delElement, AccessLevel.USER_MODE); // FP

    }


    // if the clause `as system` in place we can assume APEX will do the proper validation, but we cannot be sure it is a leftover during debugging or development. 
    // Let's allow the developer to validate and possibly mitigate.
    public void deleteSample3(){
        Dialog__c delElement = new Dialog__c();
        delElement.id = foo;

        delete as system delElement;                          // CWE 274 --> ?
        Database.delete(delElement, AccessLevel.SYSTEM_MODE); // CWE 274 --> ?

    }

    // deleting items by Ids or Strings inside a without sharing class
    public void deleteSample4(){
        Id idToDelete = foo;
        List<Id> idsToDelete = new List<Id>{foo};
        List<String> stringsIdsToDelete = new List<String>{foo};

        // Delete by Id available only in Database methods
        Database.delete(idToDelete);         // CWE 274 --> CWE 284
        Database.delete(idsToDelete);        // CWE 274 --> CWE 284
        Database.delete(foo);                // CWE 274 --> CWE 284
        Database.delete(stringsIdsToDelete); // CWE 274 --> CWE 284
    }


    // Utility functions

    // This function doesn't apply any stripping
    public List<Dialog__c> applyNoStripping( List<Dialog__c> objs){
        return objs;
    }

    // This function applies a READABLE stripping to the received input
    public List<Dialog__c> applyFieldsStripping( List<Dialog__c> objs){
        objs = Security.stripInaccessible(AccessType.READABLE,objs).getRecords();
        return objs;
    }
}





