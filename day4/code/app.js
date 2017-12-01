const express = require('express');
const redis = require('redis');
const database = require('./database');

var app = express();
var client = redis.createClient(6379, 'my_redis_container', {
  retry_strategy: options => {
    return;
  },
});

app.get('/', (req, res) => {
  if (client.connected) {
    client.incr('page_load_count', (error, reply) => {
      var msg = 'Connected to redis, you are awesome :D' + 'Page loaded ' + reply + ' times!';
      res.statusCode = 200;
      res.send(msg);
      return;
    });
  } else {
    var msg = "Failed to connect to redis :'(";
    res.statusCode = 500;
    res.send(msg);
  }
});

//api call to /items which executes the callback function in the database.get function.
//
app.get('/items', (req, res) => {
    database.get(function(response){
      if(!response) {console.error("an error occured ") }
      else{
        var msg = 'items fetched successfully';
        console.log(msg);
        console.log(reply);
        res.statusCode =200;
        res.send(response.rows[0])
        res.send(msg);
        return;
      }
    });
    // todo
});

// Should add an item to the database.

app.post('/items/:name', (req, res) => {
    var name = req.params.name;
    var date = 'now()';
    database.insert(name, date, function(response) {
      if(!response){console.log("error occured")}
      else{
        var msg = 'item inserted successfully';
        console.log(msg);
        res.statusCode = 200;
        res.send(response.rows.map(name => name.name))
        res.send(msg);
        return;
      }
    });
    // todo
})

app.listen(3000);
