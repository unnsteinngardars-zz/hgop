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

// export callback functions
module.exports = {
    insert: (name, insertDate, onInsert) => {
        var client = getClient();
        client.connect(() => {
            const query = {
                text: 'INSERT INTO Item(Name, InsertDate) VALUES($1,$2);',
                values: [name, insertDate],
            }
            client.query(query, (err, res) => {
              onInsert(err,res);
              client.end();
            });
        });
        return;
    },
    get: (onGet) => {
        // todo
        var client = getClient();
        client.connect(() => {
            const query = {
                text: 'SELECT name FROM Item ORDER BY InsertDate DESC LIMIT 10;',
                rowMode: 'array'
            }
            client.query(query, (err, res) => {
              onGet(err, res);
              client.end();
            });
        });
        return;
    }
}
