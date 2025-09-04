/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> } 
 */
exports.seed = async function (knex) {
  await knex('users').del();
  await knex('users').insert([
    { id: 1, name: 'John Doe', email: 'johndoe@example.com', profile_image_url: null },
  ]);
};