## Using Docker for Automation 
### Executing simple admin tasks in a container
1. Let us assume we need to strip all leading whitespaces from a file and we find the following handy `Perl` script to do exactly that
```shell
$ cat sample.txt | perl -lpe 's/^\s*//'
```
2. Let us assume that we don't have Perl installed on our working machine. However we have `Docker` installed on our system. 
   1. Should we install Perl and then execute the script or can we do even without it? 
   2. We can solve this problem without requiring to install Perl
   3. Create a folder named `simple-task` and navigate to it
   ```shell
    $ mkdir -p ./simple-task && cd ./simple-task 
    ```
   4. Next create the simple `sample.txt` file with the following content
   ```text
   1234567890
      This is some text 
          another line of text 
     more text 
        final line 
   ```
   5. Now we can run a container with the `Perl` installed on it. Execute the following command
   ```shell
   $ docker container run --rm -it -v $(pwd):/usr/src/app -w /usr/src/app perl:slim sh -c "cat sample.txt | perl -lpe 's/^\s*//'"
   1234567890
   This is some text
   another line of text
   more text
   final line

   ```
   6. Thus we have achieved the formatting without requiring to install Perl
3. Multiple such scenarios can be there like if we have different version of Perl on our system and we have to run a `Perl script` with some other version. In this case rather than installing the desired Perl version on our system we can just execute it using Docker with that specific Perl version 
   1. This is relevant for many other languages like Python 

## Integration tests for a Node.js application
### NodeJS application Testing Use Case 
1. Let us look at the `sample integration test` implemented in Node.js. This is the kind of setup that we are going to look into 

2. Create the `project root` and navigate to it 
```shell
$ mkdir -p integration-test-node && cd integration-test-node
```
3. Within this folder, we create three subfolders, `tests, api and database`
```shell
$ mkdir tests api database 
```
4. To the `database` folder, add an `init-script.sql` file with the following content
```sql
CREATE TABLE hobbies(hobby_id serial PRIMARY KEY, hobby VARCHAR (255) UNIQUE NOT NULL);

insert into hobbies(hobby) values ('swimming');
insert into hobbies(hobby) values ('diving');
insert into hobbies(hobby) values ('jogging');
insert into hobbies(hobby) values ('dancing');
insert into hobbies(hobby) values ('cooking');
```
5. The above `sql script` will be able to create and populate the `hobbies` table in `PostgreSQL` database
6. Let us first create a `pg-data` docker volume to store the data using the following command
```shell
$ docker volume create pg-data 
```
7. Next start the database container using the following command from the project root folder `integration-test-node`
```shell
$ docker container run -d --name postgres -p 5432:5432 -v $(pwd)/database:/docker-entrypoint-initdb.d -v pg-data:/var/lib/postgresql/data -e POSTGRES_USER=dbuser -e POSTGRES_DB=sample_db postgres:13.1-alpine 
```
8. Let us verify that the container is running by executing the following command
```shell
$ docker container logs postgres 

 done
server started
CREATE DATABASE


/usr/local/bin/docker-entrypoint.sh: running /docker-entrypoint-initdb.d/init-script.sql
CREATE TABLE
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1


waiting for server to shut down...2022-01-07 07:39:46.122 UTC [37] LOG:  received fast shutdown request
.2022-01-07 07:39:46.123 UTC [37] LOG:  aborting any active transactions
2022-01-07 07:39:46.123 UTC [37] LOG:  background worker "logical replication launcher" (PID 44) exited with exit code 1
2022-01-07 07:39:46.123 UTC [39] LOG:  shutting down
2022-01-07 07:39:46.136 UTC [37] LOG:  database system is shut down
 done
server stopped

PostgreSQL init process complete; ready for start up.

2022-01-07 07:39:46.235 UTC [1] LOG:  listening on IPv4 address "0.0.0.0", port 5432
2022-01-07 07:39:46.235 UTC [1] LOG:  listening on IPv6 address "::", port 5432
2022-01-07 07:39:46.243 UTC [1] LOG:  database system is ready to accept connections

```
9. In the terminal window, navigate to the `api` folder and execute the following command
```shell
$ npm init -y
```
10. `package.json` will be created and then modify the file `scripts` section with the following lines
```json
"scripts": {
    "start": "node server.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  }
```
11. Next execute the following command to add npm dependencis 
```shell
$ npm install express 
```
12. This will install the npm libraries and add a `dependencies` section in package.json 
```json
"dependencies": {
    "express": "^4.17.2"
  }
```
13. Next in the `api` folder create a `server.js` file and add the following code snippet
```js

```
14. Next start the application using the following command
```shell
$ npm run start 
> api@1.0.0 start
> node server.js

Application is running at 0.0.0.0:3000

```
15. Open the browser `https://localhost:3000`