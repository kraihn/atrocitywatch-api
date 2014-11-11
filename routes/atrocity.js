var express = require('express');
var router = express.Router();

/* GET users listing. */
router.post('/', function (req, res) {
    res.send({success: true});
});

module.exports = router;
