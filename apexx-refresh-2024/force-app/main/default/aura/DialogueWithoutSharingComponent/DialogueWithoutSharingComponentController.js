({
    init : function(component, event, helper) {
        component.set('v.mycolumns', [
            {label: 'Dialogue Name', fieldName: 'Name', type: 'text'},
            {label: 'Message', fieldName:'Message__c', type: 'text'}
        ]);
        helper.getData(component);
    }
})
