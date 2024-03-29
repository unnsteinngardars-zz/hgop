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
app.get('/items', (req, res) => {
    database.get(function (error, response){
      if(error) {console.error("an error occured ") }
      else{
        var msg = 'items fetched successfully';
        console.log(msg);
        res.send(response.rows.map(value => value.toString()));
        return;
      }
    });
    // todo
});

//api call to /items/name which executes the callback function in the database.insert function.
app.post('/items/:name', (req, res) => {
    var name = req.params.name;
    var date = 'now()';
    database.insert(name, date, function(error, response) {
      if(error){console.log("error occured")}
      else{
        var msg = 'item inserted successfully';
        console.log(msg);
        res.send(response.rows[0]);
        return;
      }
    });
    // todo
})

app.listen(3000);
