# eScholarship Sinatra Graphql Server

### Setup and Running locally
Prior to running the setup script you should have installed:
ruby
mysql
node

```bash
git clone repo
cd to folder
./setup.sh
# run the server
source env.sh   # use a jschol-compatible env file
./run.sh
# Visit http://localhost:4001/graphql/iql
```

[Visit browser](http://localhost:4001/graphql/iql)

# Features
* Graphql API

### DB
* MySQL (with ruby Sequel ORM)

### Testing

There is a small (but growing) number of tests in `tools/testApi.rb`.  In order to run these tests you need to have a local version of the API running as described above. It should be connected to the dev database. So far it won't make any actual changes to the DB but it expects a few records to already exist.
