var express = require('express');
var router = express.Router();

/* GET users listing. */
router.get('/', function (req, res) {
    if (req.query && (req.query.lat && req.query.lng)) {
        // TODO: get data
        res.send({success: true, safe: true})
    }
    else {
        res.send(400, {success: false});
    }
});

module.exports = router;
