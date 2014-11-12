var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function (req, res) {
  console.log('index');
  res.render('index', {
    title: 'Atrocity Watch'
  });
});

module.exports = router;
