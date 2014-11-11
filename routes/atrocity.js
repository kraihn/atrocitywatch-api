var express = require('express');
var router = express.Router();

/* GET users listing. */
router.post('/', function (req, res) {
    if (req.body && (req.body.lat && req.body.lng && req.body.type && req.body.description)) {
        var atrocity = {
            date: new Date(),
            latitude: req.body.lat,
            longitude: req.body.lng,
            type: req.body.type.split(','),
            description: req.body.description,
            severity: req.body.severity,
            radius: 25
        };
        // TODO: record data to the database
        res.send({success: true})
    }
    else {
        res.send(400, {success: false});
    }
});

module.exports = router;
