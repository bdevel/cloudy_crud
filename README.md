# Cloudy Crud - Ruby Implementation

## Overview
Cloudy Crud is an implementation of a generic JSON store and JSON REST API.
Similar to CouchDB which provides storage and a REST API, Cloudy Crud provides
a generic document handler.

The library tries to remain agnostic about which web framework you
use and how you want to format your requests and responses. 

## REST API
By default, the handlers for REST try to conform to the specifications
outlined in [JSON API 1.0](http://jsonapi.org/). If you want a different
output you can customize this.

### Example Requests

http://jsonapi.org/extensions/bulk/
```http
POST /bdevel/my-app-dev/photos/_import HTTP/1.1
Content-Type: application/vnd.api+json;
Accept: application/vnd.api+json;

[
  {"title": "Hamster", "src": "hampster.png"},
  {"title": "Mustaches", "src": "mustaches.png"},
  ...
]
```


### Queries
`GET /bdevel/my-app-dev/photos?query=`


#### Update a Record's Permissions

Only users who have been granted `admin` rights on a record can change permissions.

```
POST /photos/123/permissions
{read: {groups: ["public"]}}
```



## Documents and Ruby objects

```ruby
params = {
  type: "cars",# plural form is standard
  attributes: {
    manufacturerName: "Honda",
    year: 2002,
  }
}

user   = User.find(session[:user_id]))
record = CloudyCrud::Record.build(params, user)

record.id   # xxxxx-xxxxx-xxxxx
record.type # cars
record.manufacturer_name # Honda  - attributes are case-insensative
record.year

record.permissions.is_admin?(user)        # true
record.permissions.can_read?(user)        # true
record.permissions.can_write?(user)       # true
record.permissions.can_write?(other_user) # false

record.save()
```


### Permissions

- **Admin:** Allow grantees to delete and change permissions of the. Records are considered owned by a user if the user is granted admin rights.
- **Read:** Allows grantees to view the attributes of the record and will return the record in index listings.
- **Write:** Allow grantees to update attributes. Grantees cannot change permissions or delete.

Each set of permissions (`admin`, `read`, `write`) has the property `users` and `groups` which is an array of grantees. Records with permissions having `pubic` in the group array will grant those rights to all users.


### ID Generation
By default each new CloudyCrud record will get a new ID with the pattern `xxxxx-xxxxx-xxxxx`
where `x` is `a-z A-Z 2-9` with the exclusion of characters that look alike (i,I,l,0,O,o).
Should `54^(5*3)` not be a large enough domain when scoped by object type and user, you can
expand it by setting `CloudyCrud::Record::ID_SEGMENTS` AND `CloudyCrud::Record::ID_SEGMENT_LENGTH`
to larger values than `3` and `5`, respectively.


### JSON
#### Case Matching
Since the key matching is fuzzy, should there be two attributes with
the same name but different case (`first-name` and `firstName`), the
library will return first value that it finds. For an assignment it
will assign all matching attributes to the new value.

#### Default Case
Should you assign an attribute to the hash that does not already exist
the library will try to figure out which case to use based on other
keys in the hash. If it cannot determine which case is being used
it will fall back to `RecursiveCaseIndifferentOstruct::DEFAULT_CASE=:snake`
which you could set to override. Another option is to pass the default
case on initialization `RecursiveCaseIndifferentOstruct.new(hash, :snake)`.

Available options:
* `:snake` *this_is_snake*
* `:lower_camel` *thisIsLowerCamel*
* `:upper_camel` *ThisIsUpperCamel*
* `:kabab` *this-is-kabab*
* `:train` *This-Is-Train*


If you need to assign a value to a key that has an odd case you can
use a string with the bracket syntax like so: `json["PI:Value"] = 3.14`.
The value can still be accessed via `json.pi_value`.





## Document Storage

Making a request to `/bdevel/my-app-dev/photos` will save data under the
**domain** of `bdevel/my-app-dev` and the collection **photos**. It's up to the
database store if and how it wants to segment the records based on the domain
and the collection name.

When defining your routes, ensure that they have dynamic segments
`/api/:_domain/:_collection`

### Database Stores

Cloudy Crud can be extended to support any JSON store but currently Postgres is the
only available implementation.

```ruby
# Set the global store to Postgres
CloudyCrud.store do
  CloudyCrud::Postgres # return class to use
end

# Tell the Postgres how to checkout from your connection pool
CloudyCrud::Store::Postgres.with_connection = lambda do |&block|
  ActiveRecord::Base.with_connection(&block)# Rails example
end
```

#### Postgres

By default, the Postgres store handler will create a new schema namespace for 
each domain and a new table for each collection. The schema namespaces allows
for different users or applications to have the same collection names and having
separate tables for collections allows for better indexing and faster access.

?? What about permissions?

```sql
---supports indexing the @> operator only. Key and value is hashed as index key
-- http://www.postgresql.org/docs/9.5/static/datatype-json.html#JSON-INDEXING
CREATE INDEX idxginp ON api USING GIN (jdoc jsonb_path_ops);

-- Individual fields:
-- my_json = {tags: ['summer', 'winter']}
-- Now can use jdoc -> 'tags' ? winter;
CREATE INDEX idxgintags ON api USING GIN ((my_json -> 'tags'));

SELECT '{"read": {"users": ["bob"]}  }'::jsonb -> 'read' -> 'users' ? 'bob';

-- Need b-tree indexes for > < <= >=

```

Indexes: (-> id, -> type), (-> permissions -> read -> groups)...

Requires version `0.18.2` or later of [Ruby PG](https://github.com/ged/ruby-pg).








## Integration

### Users and Groups
By default CloudyCrud will use `.id` property on user and group
objects it is given as reference values for permissions. It also
expects `.groups` on user objects to determine which groups a user
belongs to. If you have different properties names you can override
the default by creating an accessor blocks like so:

```ruby

# Define how to get the current user from the request
CloudyCrud::Request.current_user = lambda do |request|
  User.find(request.session[:user_id])
  # Also available: `request.env` and `request.params` 
end

CloudyCrud::User.find = lambda do |id|
  User.find(id)
end

CloudyCrud::User.id = lambda do |user|
  user.uuid # use .uuid instead of .id, the default
end

CloudyCrud::User.groups = lambda do |user|
  user.permission_groups # default is [] for no groups
end

CloudyCrud::UserGroup.id = lambda do |group|
  group.uuid # default is .id
end

```

### Handling Requests
If you want use all the defaults for a Rails controller you can extended
from `CloudyCrud::Rails::Controller`

```ruby
res = CloudyCrud::JsonApi.get(request.env)
render :json => res.body, :status => res.status, :headers => res.headers
```


### Stores
You will need to assign a store for Cloudy Crud to use.



#### Bulk import endpoint

CloudyCrud supports an efficient way of importing large quantities
of documents with a single POST request.

```ruby
# config/application.rb
config.middleware.insert_before(
  ActionDispatch::ParamsParser,
  Rack::BulkImport,
  :handler => MyCloudyCrudHandler,
  :only => /_import$/ # ill only activate for _import 
)

```

`match 'photos/:id', to: Rack::BulkImport, via: :get`
`Rack::BulkImport`
`Rack::BulkImport::PostgresHandler`


##### For Ruby on Rails in `config/routes.rb`
```ruby
MyApp::Application.routes.draw do
  scope '/api' do # optional scope
    match '/:username/:namespace/:collection/_import', to: CloudyCrud::BulkImport, via: :post
  end
end
```
