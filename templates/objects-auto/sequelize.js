module.exports.objectSchema = function (sequelize, DataTypes) {
  return sequelize.define(
    "objects",
    {
      objectId: {
        type: DataTypes.STRING(255),
        allowNull: false,
        primaryKey: true,
      },
      text: {
        type: DataTypes.TEXT,
        allowNull: true,
      },
      number: {
        type: DataTypes.INTEGER,
        allowNull: true,
      },
      double: {
        type: DataTypes.REAL,
        allowNull: true,
      },
      boolean: {
        type: DataTypes.BOOLEAN,
        allowNull: true,
      },
    },
    {
      sequelize,
      tableName: "objects",
      schema: "public",
      timestamps: true,
      indexes: [
        {
          name: "objects_pkey",
          unique: true,
          fields: [{ name: "objectId" }],
        },
      ],
    }
  );
};
