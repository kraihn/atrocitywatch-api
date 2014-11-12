"use strict";
module.exports = {
  up: function(migration, DataTypes, done) {
    migration.createTable("Atrocities", {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: DataTypes.INTEGER
      },
      latitude: {
        type: DataTypes.DECIMAL
      },
      longitude: {
        type: DataTypes.DECIMAL
      },
      reportedDate: {
        type: DataTypes.DATE
      },
      severity: {
        type: DataTypes.INTEGER
      },
      type: {
        type: DataTypes.STRING
      },
      description: {
        type: DataTypes.STRING
      },
      createdAt: {
        allowNull: false,
        type: DataTypes.DATE
      },
      updatedAt: {
        allowNull: false,
        type: DataTypes.DATE
      }
    }).done(done);
  },
  down: function(migration, DataTypes, done) {
    migration.dropTable("Atrocities").done(done);
  }
};