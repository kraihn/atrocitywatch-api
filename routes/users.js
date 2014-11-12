var models = require('../models');
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
    models.User.create({
      phone: req.body.phone,
      latitude: parseFloat(req.body.lat),
      longitude: parseFloat(req.body.lng)
    })
      .success(function (user) {
        res.send({success: true})
      })
      .error(function (error) {
        res.send(400, {success: false, message: 'Failed to save'});
      });
  }
  else {
    res.send(400, {success: false, message: 'Invalid model'});
  }
});

module.exports = router;
