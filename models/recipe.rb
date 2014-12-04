class Recipe
  attr_reader :id, :name, :description, :instructions, :ingredients
  def initialize(id, name, description, instructions, ingredients)
    @id = id
    @name = name
    @description = description
    @instructions = instructions
    @ingredients = []
  end

  def self.all
    attribute = []
    sql = "SELECT id, name FROM recipes
    ORDER BY name"

    recipes = Database.db_connection do |db|
      db.exec(sql)
    end
    recipes.each do |recipe|
      addition = Recipe.new(recipe["id"],recipe["name"], nil, nil, nil)
      attribute << addition
    end
    attribute
  end

  def ingredients
    get_ingredients = Database.db_connection do |db|
      sql = "SELECT name, id FROM ingredients i
      WHERE $1 = i.recipe_id"
      db.exec_params(sql, [id])
    end
    get_ingredients.each do |ingredient|
      @ingredients << Ingredient.new(ingredient['name'])
    end
    @ingredients
  end

  def self.find(id)
    sql = "SELECT recipes.id, recipes.name, recipes.description,
    recipes.instructions, ingredients.name AS ing_name
    FROM recipes
    JOIN ingredients on recipes.id = ingredients.recipe_id
    WHERE recipes.id = ($1)
    ORDER BY recipes.name"

    recipes_id = Database.db_connection do |db|
      db.exec_params(sql, [id])
    end

    attribute = nil

    recipes_id.each do |recipe_info|
      attribute = Recipe.new(recipe_info["id"], recipe_info["name"],
      recipe_info["description"], recipe_info["instructions"], @ingredients)
    end

    attribute
  end

end
