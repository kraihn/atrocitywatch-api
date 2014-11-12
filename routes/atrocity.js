var models = require('../models');
var express = require('express');
var router = express.Router();

/* GET users listing. */
router.post('/', function (req, res) {
  if (req.body && (req.body.lat && req.body.lng)) {

    models.Atrocity.create({
      latitude: req.body.lat,
      longitude: req.body.lng,
      reportedDate: new Date(),
      severity: 3,
      type: req.body.type,
      description: req.body.msg
    }).success(function (atrocity) {
      res.send(200, {success: true});
    }).error(function (error) {
      res.send(400, {success: false});
    });
    
  }
  else {
    res.send(400, {success: false});
  }
});

module.exports = router;
