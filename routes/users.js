var express = require('express');
var router = express.Router();

// Get users in hotspot
router.get('/', function (req, res) {
    if (req.query && (req.query.lat && req.query.lng)) {
        // TODO: get users
        res.send({success: true})
    }
    else {
        res.send(400, {success: false});
    }
});

// Register a new user
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
