exports.up = function (knex) {
  return knex.schema.createTable("recipes", (table) => {
    table.increments("id").primary();
    table.string("title").notNullable();
    table.text("description").notNullable();
    table.string("image_url");
    table.json("ingredients").notNullable();
    table.json("steps").notNullable();
    table.string("category");
    table.string("created_by");
    table.timestamps(true, true);
  });
};

exports.down = function (knex) {
  return knex.schema.dropTableIfExists("recipes");
};