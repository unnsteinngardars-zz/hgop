const { Client } = require('pg');

function getClient() {
    return new Client({
        host: 'db',
        user: 'dissteinn',
        password: '1234',
        database: 'day4',
        port: '5432'
    });
}

function initialize() {
    var client = getClient();
    client.connect(() => {
        client.query('CREATE TABLE IF NOT EXISTS Item (ID SERIAL PRIMARY KEY, Name VARCHAR(32) NOT NULL, InsertDate TIMESTAMP NOT NULL);', (err) => {
            console.log('successfully connected to postgres!')
            client.end();
        });
    });
}


// give the postgres container a couple of seconds to setup.
setTimeout(initialize, 10000);

// module.exports: if you are not familiar with NodeJS module.exports is similar to C#/C++ public access modifier.
// you use it to call functions or access properties from outside the file.
module.exports = {
    // Should insert an item to the items table.
    // param name: item name.
    // param insertDate: item insertdate.
    // param onInsert: on item insert callback method.

    insert: (name, insertDate, onInsert) => {
        var client = getClient();
        client.connect(() => {
            const query = {
                text: 'INSERT INTO Item(Name, InsertDate) VALUES($1,$2);',
                values: [name, insertDate],
            }
            client.query(query, (err, res) => {
                if(err){
                    console.log(err.stack);
                }
                else{
                    console.log('item inserted successfully');
                    console.log(res.rows[0]);
                }
                client.end();
            });
        });
        return;
        
    },

    // Should get the top 10 items sorted by inserteddate descending.
    // param onGet: on items get callback method.
    get: (onGet) => {
        // todo
        var client = getClient();
        client.connect(() => {
            const query = {
                text: 'SELECT name FROM Item ORDER BY InsertDate DESC LIMIT 10;',
                rowMode: 'array',
            }
            var rows = [];
            client.query(query, (err, res) => {
                if (err){
                    console.log(err.stack);

                }
                else{
                    console.log("items fetched successfully");
                    for(var i = 0; i < res.rowCount; i++){
                        rows.push(res.rows[i][0]);
                    }
                    console.log(rows);
                }
                client.end();
            });
        });
        return;
        
    }
}
