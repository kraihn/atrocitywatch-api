var express = require('express');
var router = express.Router();

/* GET users listing. */
router.get('/', function (req, res) {
    res.send('respond with a resource');
});

router.post('/', function (req, res) {
    // Require phone, latitude and longitude
    if (req.body && (req.body.phone && req.body.lat && req.body.lng)) {
        // TODO: record data to the database
        res.send({success: true})
    }
    else {
        res.send(400, {success: false});
    }
});

module.exports = router;
