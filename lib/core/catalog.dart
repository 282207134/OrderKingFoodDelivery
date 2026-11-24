import 'package:flutter/material.dart';

const gold = Color(0xffffc323);
const amberText = Color(0xffa66b00);
const lavender = Color(0xffd2cefd);
const blush = Color(0xffffcaed);
const honey = Color(0xffffde85);
const mint = Color(0xffb4ecd1);
const sky = Color(0xffc4e6ff);

String money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';

enum FoodSection { appetizer, main, dessert }

class Dish {
  const Dish(this.name, this.asset, this.cents, this.section, this.description);

  final String name;
  final String asset;
  final int cents;
  final FoodSection section;
  final String description;

  Color get color => switch (section) {
    FoodSection.appetizer => lavender,
    FoodSection.main => honey,
    FoodSection.dessert => blush,
  };
}

const _seasoned = 'Well seasoned. Served hot and fresh';
const _sweet = 'Topped with fresh berries & chocolate chips';
const fries = Dish(
  'French fries',
  'dish-fries',
  399,
  FoodSection.appetizer,
  _seasoned,
);
const cookies = Dish(
  'Cookies',
  'dish-cookies',
  299,
  FoodSection.appetizer,
  _sweet,
);
const burger = Dish(
  'Hamburger',
  'dish-burger',
  799,
  FoodSection.main,
  _seasoned,
);
const hotdog = Dish('Hotdog', 'dish-hotdog', 599, FoodSection.main, _seasoned);
const tacos = Dish('Tacos', 'dish-tacos', 799, FoodSection.main, _seasoned);
const pizza = Dish(
  'Pepperoni pizza',
  'dish-pizza',
  1199,
  FoodSection.main,
  'A pizza with tomato sauce, mozzarella cheese, and slices of spicy pepperoni sausage',
);
const cupcake = Dish(
  'Cupcakes',
  'dish-cupcake',
  299,
  FoodSection.dessert,
  _sweet,
);
const donut = Dish('Donut', 'dish-donut', 299, FoodSection.dessert, _sweet);
const menu = [fries, cookies, burger, hotdog, tacos, pizza, cupcake, donut];

class Restaurant {
  const Restaurant(
    this.name,
    this.asset,
    this.rating,
    this.minutes,
    this.cuisine,
  );

  final String name;
  final String asset;
  final String rating;
  final String minutes;
  final String cuisine;
}

const bowlClub = Restaurant(
  'One Bowl Club',
  'photo-dumplings',
  '4.5',
  '20–30 mins',
  'Fast food',
);
const yogurt = Restaurant(
  'Hi Yogurt!',
  'photo-yogurt',
  '4.0',
  '20–25 mins',
  'Breakfast',
);
const sandwich = Restaurant(
  'Sandwich factory',
  'photo-featured',
  '4.3',
  '20–25 mins',
  'Sandwich',
);
const dumplings = Restaurant(
  'Dumpling house',
  'photo-dumplings',
  '4.0',
  '20–25 mins',
  'Asian food',
);
const pho = Restaurant(
  'I love Pho',
  'photo-salad',
  '4.5',
  '20–25 mins',
  'Asian food',
);
const donuts = Restaurant(
  'Dunkin Donuts',
  'photo-donuts',
  '4.0',
  '10–20 mins',
  'Dessert',
);
const secondSandwich = Restaurant(
  'Sandwich factory',
  'photo-sandwich',
  '4.0',
  '20–25 mins',
  'Asian food',
);
const restaurants = [
  bowlClub,
  yogurt,
  sandwich,
  dumplings,
  pho,
  donuts,
  secondSandwich,
];

const categories = [
  ('Pizza', 'cat-pizza', honey),
  ('Hotdog', 'cat-hotdog', mint),
  ('Sushi', 'cat-sushi', blush),
  ('Breakfast', 'cat-breakfast', lavender),
  ('Dessert', 'cat-dessert', blush),
  ('Burger', 'cat-burger', lavender),
  ('Asian', 'cat-asian', sky),
  ('Coffee', 'cat-coffee', honey),
  ('Cake', 'cat-cake', blush),
  ('Veggie', 'cat-veggie', mint),
  ('Fast food', 'cat-fries', lavender),
  ('Italian', 'cat-italian', sky),
];
