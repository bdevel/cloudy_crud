Cloudy Crud - Ruby Implementation
#####################################


### Permissions

- **Admin:** Allow grantees to delete and change permissions of the object. Records are considered owned by a user if the user is granted admin rights.
- **Read:** Allows grantees to view the attributes of the recod and will return the record in index listings.
- **Write:** Allow grantees to update attributes. Grantees cannot change permissions or delete.

Each set of permissions (`admin`, `read`, `write`) has the property `users` and `groups` which is an array of grantees. Records with permissions having `pubic` in the group array will grant those rights to all users.


#### Update a Record's Permissions

Only users who have been granted `admin` rights on a record can change permissions.

```
POST /photos/123/permissions
{read: {groups: ["public"]}}
```


