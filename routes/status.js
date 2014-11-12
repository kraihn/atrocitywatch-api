var models = require('../models');
var express = require('express');
var router = express.Router();

/* GET users listing. */
router.get('/', function (req, res) {

  var lat = req.query.lat;
  var lng = req.query.lng;
  var radius = 1; // miles

  // getting atrocities
  models.Atrocity.findAll({
    where: [
      "earth_box(ll_to_earth(" + lat + ", " + lng + "), " + radius + ") @> ll_to_earth(latitude, longitude)"
    ]
  }).success(function (atrocities) {
    res.send({success: true, safe: (atrocities && atrocities.length > 0 ? false : true), atrocities: atrocities || []});
  })
    .error(function (error) {
      res.send(400);
    });

});

module.exports = router;
