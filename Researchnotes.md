# Research Notes

## Visual Force Remote Objects
Tested them by tampering the tags attributes and they seems to properly escape / reject unacceptable values.
In addition to the tag attributes I Tested how the remote object get returned in JAvascript. The idea was to test if we should consider values returned from the remote object as network tainted especially for XSS. From my tests it turned out that these values are already returned html encoded.

[RemoteObjFun](force-app/main/default/pages/RemoteObjFun.page)

```
            // Create a new Remote Object
            var wh = new SObjectModel.Lead();
            
            // Use the Remote Object to query for 10 Lead records
            wh.retrieve({ limit: 30 }, function(err, records, event){
                if(err) {
                    alert(err.message);
                }
                else {
                    var ul = document.getElementById("LeadsList");
                    records.forEach(function(record) {
                        // Build the text for a Lead line item
                        var whText = record.get("Name");
                        whText += " -- ";
                        whText += record.get("Id");;
                        whText += " -- ";
                        whText += record.get("Locations");
                        
                        // Add the line item to the Leads list
                        var li = document.createElement("li");
                        li.appendChild(document.createTextNode(whText));
                        var foo = document.createElement("span");
                        // record.get("Name") returns html encoded values
                        foo.innerHTML = record.get("Name");  // <-- this is not XSS
                        li.appendChild(foo);
                        ul.appendChild(li);
                    });
                }
            });
```

## Charting capabilities
All chart releted objects seems to inherit from the same root object where all attributes are properly handled.
I have tested the charting tags using [ChartFun](force-app/main/default/classes/ChartController.cls) in case we need to go over this again in future.


## Apex Recipes
This repository, mainteined by Salesforce it is a good resource for new functionalities being released and to investigate how a feature works

https://github.com/trailheadapps/apex-recipes/blob/main/force-app/main/default/classes/Security%20Recipes/CanTheUser.cls

## Using Test classes from Production code
Since we were going to not report `WITHOUT SHARING` when used in `@isTest` annotated class, I wanted to check if it was possible to access data using a method defined in a test class. This test was implemented creating two equal lwc components, `DialogueComponent.cmp` relying on a normal APEX class, `DialogueController`, and `DialogueFromTestComponent` relying on a method defined in `DialogueControllerTest` class, that is annotated by `@isTest` annotation. 
The result is that it is not possible to access "real" data by using `@isTest` annotated classes. When the aura component accesses the `Dialog` object through `DialogueControllerTest`, the SOQL query returns an empty string for all tested users, including System Administrator.
Similar result is obtained from Visualforce pages. 
Using the `@isTest(SeeAllData=True)` annotation doesn't change the behaviour described above.

## Release notes reviewed
https://help.salesforce.com/s/articleView?id=sf.whats_new.htm&type=5

- Spring '23 - API Version 57.0
 - https://help.salesforce.com/s/articleView?id=release-notes.rn_apex_User_Mode_GA.htm&release=242&type=5
    - Added new methods: 
        - Database.queryWithBinds
        - Database.getQueryLocatorWithBinds
        - Database.countQueryWithBinds
    - Added specifications for correct use of `as user`/`as system`/`AccessLevel`
        - Database.query method
        - Database.countQuery method
        - Database.getQueryLocator methods
        - Search.query method
        - Database DML methods (insert, insertAsync, insertImmediate, update, updateAsync, updateImmediate, upsert, merge, delete, deleteAsync, deleteImmediate, undelete, and convertLead)
    - https://help.salesforce.com/s/articleView?id=release-notes.rn_apex_enforce_RFC_header_validation.htm&language=en_US&type=5&release=242
        - Added specifications for RestResource apis
    - https://help.salesforce.com/s/articleView?id=release-notes.rn_api_tooling_new_and_changed_objects.htm&release=242&type=5
        - Check ExternalCredentialParameter
- Summer '23 - API Version 58.0
    - Nothing security relevant with this release. Many features released here were introduced as Pilot in Spring '23 or prior.
    - Report deprecated `getHeadlessFrgtPswEnabled()` ?
    - Can we spec data from `InboundEmail` as taint ?
- Winter '24 - API Version 59.0
    - https://help.salesforce.com/s/articleView?id=release-notes.rn_apex_User_Mode_PermSets.htm&release=246&type=5
        - Adding Specifications for AccessLevel.User_mode.withPermissionSetId(X)
    - https://help.salesforce.com/s/articleView?id=release-notes.rn_apex_iterator_foreach.htm&release=246&type=5
        - Support for Iterable
    - https://help.salesforce.com/s/articleView?id=release-notes.rn_apex_nc.htm&release=246&type=5
        - Try to add support for the usage of Security.stripInaccessible() in alternative to useing `as user`/`as system`/`AccessLevel`
- Spring '24 - API Version 60.0
    - https://help.salesforce.com/s/articleView?id=release-notes.rn_apex_compression.htm&release=248&type=5
        - Spec Zip API (Only Dev preview - Not specced for now)
        - Spec Dynamic Formula evaluation (Only Dev preview - Not specced for now)
    - https://help.salesforce.com/s/articleView?id=release-notes.rn_apex_TypeForName.htm&release=248&type=5
        - Type.forName deserialization issue?
- Summer '24 - API Version 61.0 - Preview at time of review




