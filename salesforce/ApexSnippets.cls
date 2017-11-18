//TO CHECK OBJECT PERMISSIONS IN AN ORG
List<PermissionSet> permissionSets = [Select Id, Name, Description,IsOwnedByProfile, IsCustom From PermissionSet WHERE Id IN (SELECT ParentId FROM ObjectPermissions WHERE SObjectType ='Case' AND PermissionsViewAllRecords=true ) AND IsOwnedByProfile = false];
for(PermissionSet ps : permissionSets ){
  System.debug('PermissionSet-->'+ps.Name);
}
Set<Id> profileIds = new Set<Id>();
for(PermissionSet ps : [Select Id, Name, Description,IsOwnedByProfile, IsCustom From PermissionSet WHERE Id IN (SELECT ParentId FROM ObjectPermissions WHERE SObjectType ='Tesla_Queue__c' AND PermissionsRead=true ) AND IsOwnedByProfile = true]){
    profileIds.add(ps.Name.substring(1,16));
}
for(Profile theProfile : [ SELECT Name FROM Profile WHERE Id in:profileIds]){
    System.debug('Profile-->'+theProfile.Name);
}
